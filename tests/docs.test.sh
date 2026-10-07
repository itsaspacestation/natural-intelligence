#!/usr/bin/env bash
# Docs lint for the ni plugin: no platform-specific runtime, no platform leaks,
# shell-neutral snippets (DESIGN.md NFR1, NFR2, FR7). Linux CI leg only.
# Tools: git, grep, sed, awk, wc. Bash 3.2 compatible.
set -u

# Whole lines of skills/**/*.md must not contain these.
FORBIDDEN_LITERALS=('/mnt/c/' '.exe' 'grep -P' 'python3' '/tmp/' 'sudo ' '/usr/bin/env' '~/' 'caveman')
# Lines inside fenced code blocks of skills/**/*.md must not contain these.
SHELL_ISMS=('$(' '${' '<<' 'export ' '&&' '||' '2>/dev/null' '| sort' '| uniq' '| grep' '| awk' '| sed' '| xargs')
# Exact listing of skills/software-engineer.
SE_FILES='SKILL.md onboarding.md'
# Numbered onboarding steps, in order.
ONBOARDING_STEPS=('Host' 'Project stack' 'Target platform' 'Package manager' 'CI pipeline'
  'Repository conventions' 'Test and coverage' 'Variant' 'Command form' 'Trace')
STYLE_FILES='output-styles/lite.md output-styles/full.md'

PLATFORM_MARKER='<!-- platform-table -->'
SHELL_MARKER='<!-- shell-table -->'
ONBOARDING='skills/software-engineer/onboarding.md'

FAILED=0
ok() { printf 'ok %s\n' "$1"; }
fail() { FAILED=$((FAILED + 1)); printf 'FAIL %s: %s\n' "$1" "$2"; }

skill_docs() { git ls-files -co --exclude-standard -- 'skills/*.md'; }

# Prints file:line for every line holding a forbidden literal.
# Exempt: the line right after PLATFORM_MARKER; dotnet.exe on a "WSL interop" line.
scan_platform() {
  local file=$1 n=0 exempt=0 line lit rest
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n + 1))
    if [ "$exempt" = 1 ]; then exempt=0; continue; fi
    case $line in "$PLATFORM_MARKER"*) exempt=1; continue ;; esac
    for lit in "${FORBIDDEN_LITERALS[@]}"; do
      case $line in *"$lit"*) ;; *) continue ;; esac
      if [ "$lit" = '.exe' ]; then
        case $line in *'WSL interop'*)
          rest=${line//dotnet.exe/}
          case $rest in *.exe*) ;; *) continue ;; esac ;;
        esac
      fi
      printf '%s:%s\n' "$file" "$n"
      break
    done
  done <"$file"
}

# Prints file:line for every fenced line holding a shell-ism.
# Exempt: the table after SHELL_MARKER, until the next blank line.
scan_shell() {
  local file=$1 n=0 fence=0 table=0 line ism
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n + 1))
    case ${line#"${line%%[! ]*}"} in '```'*) fence=$((1 - fence)); continue ;; esac
    case $line in "$SHELL_MARKER"*) table=1; continue ;; esac
    if [ "$table" = 1 ]; then
      [ -z "$line" ] && table=0
      continue
    fi
    [ "$fence" = 1 ] || continue
    for ism in "${SHELL_ISMS[@]}"; do
      case $line in *"$ism"*) printf '%s:%s\n' "$file" "$n"; break ;; esac
    done
  done <"$file"
}

# Prints the frontmatter of a file (between the first two --- lines).
frontmatter() { awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { exit } fm' "$1"; }
# Prints the number of body lines after the frontmatter.
body_lines() {
  awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { fm = 0; body = 1; next } body { n++ } END { print n + 0 }' "$1"
}

test_no_runtime_files() {
  local hits
  hits=$(git ls-files | grep -E '\.(sh|ps1|cmd|js|py)$' | grep -v '^tests/')
  if [ -z "$hits" ]; then ok test_no_runtime_files; else fail test_no_runtime_files "$(echo $hits)"; fi
}

test_manifest_has_no_hooks() {
  local count
  count=$(grep -c '"hooks"' .claude-plugin/plugin.json)
  if [ "$count" = 0 ]; then ok test_manifest_has_no_hooks; else fail test_manifest_has_no_hooks ".claude-plugin/plugin.json has $count hooks key"; fi
}

test_no_platform_leaks() {
  local file hits=''
  while IFS= read -r file; do hits="$hits $(scan_platform "$file")"; done < <(skill_docs)
  hits=$(echo $hits)
  if [ -z "$hits" ]; then ok test_no_platform_leaks; else fail test_no_platform_leaks "$hits"; fi
}

test_no_shell_isms() {
  local file hits=''
  while IFS= read -r file; do hits="$hits $(scan_shell "$file")"; done < <(skill_docs)
  hits=$(echo $hits)
  if [ -z "$hits" ]; then ok test_no_shell_isms; else fail test_no_shell_isms "$hits"; fi
}

test_software_engineer_files() {
  local f names=''
  for f in skills/software-engineer/*; do names="$names ${f##*/}"; done
  names=${names# }
  if [ "$names" = "$SE_FILES" ]; then ok test_software_engineer_files; else fail test_software_engineer_files "skills/software-engineer holds '$names', want '$SE_FILES'"; fi
}

test_onboarding_checklist() {
  local lines prev=0 step ln missing='' errors=''
  if [ ! -f "$ONBOARDING" ]; then fail test_onboarding_checklist "$ONBOARDING missing"; return; fi
  lines=$(wc -l <"$ONBOARDING")
  [ "$lines" -le 100 ] || errors="$errors $lines lines (max 100);"
  for step in "${ONBOARDING_STEPS[@]}"; do
    ln=$(grep -n -E '^[0-9]+\. ' "$ONBOARDING" | grep -F -- "$step" | awk -F: -v p="$prev" '$1 > p { print $1; exit }')
    if [ -z "$ln" ]; then missing="$missing '$step'"; else prev=$ln; fi
  done
  [ -z "$missing" ] || errors="$errors steps missing or out of order:$missing;"
  grep -q -F -- "$SHELL_MARKER" "$ONBOARDING" || errors="$errors no $SHELL_MARKER;"
  if [ -z "$errors" ]; then ok test_onboarding_checklist; else fail test_onboarding_checklist "$ONBOARDING:${errors%;}"; fi
}

test_terse_styles_frontmatter() {
  local file fm lines errors=''
  for file in $STYLE_FILES; do
    if [ ! -f "$file" ]; then errors="$errors $file missing;"; continue; fi
    fm=$(frontmatter "$file")
    printf '%s\n' "$fm" | grep -q -x 'keep-coding-instructions: true' || errors="$errors $file lacks keep-coding-instructions: true;"
    printf '%s\n' "$fm" | grep -q 'force-for-plugin' && errors="$errors $file has force-for-plugin;"
    printf '%s\n' "$fm" | grep -q '^name:' && errors="$errors $file has a name: line;"
    lines=$(body_lines "$file")
    [ "$lines" -le 60 ] || errors="$errors $file body $lines lines (max 60);"
  done
  if [ -z "$errors" ]; then ok test_terse_styles_frontmatter; else fail test_terse_styles_frontmatter "${errors# }"; fi
}

test_no_runtime_files
test_manifest_has_no_hooks
test_no_platform_leaks
test_no_shell_isms
test_software_engineer_files
test_onboarding_checklist
test_terse_styles_frontmatter

[ "$FAILED" -eq 0 ] || { printf '%s test(s) failed\n' "$FAILED"; exit 1; }
