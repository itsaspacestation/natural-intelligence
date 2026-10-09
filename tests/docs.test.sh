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
PREFLIGHT_TEMPLATE='skills/plan/templates/preflight.md'
LINKLINT_FIXTURE='tests/fixtures/linklint.md'
# Untracked copy of the fixture, created and removed by the fixture test (never committed).
LINKLINT_UNTRACKED='tests/fixtures/linklint-untracked.md'
trap 'rm -f "$LINKLINT_UNTRACKED"' EXIT
# Unlinked backticked .md reference, with optional :line or :line-line suffix (FR6).
# POSIX ERE form used by the template, and the GNU-only PCRE form it replaces.
LINKLINT_ERE='(^|[^[])`([[:alnum:]._-]+/)*[[:alnum:]._-]+\.md(:[0-9]+([-,:][0-9]+)?)?`'
LINKLINT_PCRE='(?<!\[)\x60(?:[\w.-]+/)*[\w.-]+\.md(?::\d+(?:[-,:]\d+)?)?\x60'

# Skill files with command blocks; each links the onboarding shell rules once (FR7).
ONBOARDING_LINK='software-engineer/SKILL.md#onboarding'
ONBOARDING_LINKERS='skills/code-review/gitlab.md skills/code-review/github.md skills/git-conventions/gitlab.md skills/git-conventions/github.md skills/plan/SKILL.md skills/c4-graph/inputs.md'

# Shipped tree (NFR9): top-level entries of git ls-files allowed by the Claude Code plugin structure.
SHIPPED_ALLOWLIST='.claude-plugin agents commands skills output-styles assets README.md LICENSE NOTICE .github tests'
# Workspace entries tolerated off main only; the last PR commit removes them.
WORKSPACE_ENTRIES='docs CLAUDE.md'
SECRET_PATTERN='-----BEGIN|ghp_[A-Za-z0-9]{20}|glpat-|AKIA[0-9A-Z]{16}'
# Files that spell the secret patterns out: this lint and the workspace docs that specify it.
SECRET_EXEMPT=':!tests/docs.test.sh :!docs'
SHIPPED_MAX_BYTES=1048576

# Release 2.0.0 (FR8, FR9, NFR4): README sections, manifest version, CI matrix.
README='README.md'
MANIFEST='.claude-plugin/plugin.json'
WORKFLOW='.github/workflows/test.yml'
STYLE_COMMANDS=('/output-style ni:lite' '/output-style ni:full' '/output-style default')
LANGUAGE_NAMES=('dotnet' 'rust' '.NET' 'Rust' 'Cargo')
CI_RUNNERS=('ubuntu-latest' 'windows-latest' 'macos-latest')

PLATFORM_MARKER='<!-- platform-table -->'
SHELL_MARKER='<!-- shell-table -->'
ONBOARDING='skills/software-engineer/onboarding.md'

FAILED=0
ok() { printf 'ok %s\n' "$1"; }
fail() { FAILED=$((FAILED + 1)); printf 'FAIL %s: %s\n' "$1" "$2"; }

skill_docs() { git ls-files -co --exclude-standard -- 'skills/*.md'; }

# Prints file:line for every line holding a forbidden literal.
# Exempt: the table after PLATFORM_MARKER, until the next blank line; dotnet.exe on a "WSL interop" line.
scan_platform() {
  local file=$1 n=0 exempt=0 line lit rest
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n + 1))
    case $line in "$PLATFORM_MARKER"*) exempt=1; continue ;; esac
    if [ "$exempt" = 1 ]; then
      [ -z "$line" ] && exempt=0
      continue
    fi
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
# Only fences with no language tag or a shell tag (bash, sh, shell, zsh, console,
# powershell, pwsh, cmd, bat) are scanned; mermaid, json, yaml fences are not.
# Exempt: the table after SHELL_MARKER, until the next blank line.
scan_shell() {
  local file=$1 n=0 fence=0 shellfence=0 table=0 line ism tag
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n + 1))
    case ${line#"${line%%[! ]*}"} in
      '```'*)
        if [ "$fence" = 0 ]; then
          fence=1
          tag=${line#*'```'}
          tag=${tag%% *}
          case $tag in ''|bash|sh|shell|zsh|console|powershell|pwsh|cmd|bat) shellfence=1 ;; *) shellfence=0 ;; esac
        else
          fence=0; shellfence=0
        fi
        continue ;;
    esac
    case $line in "$SHELL_MARKER"*) table=1; continue ;; esac
    if [ "$table" = 1 ]; then
      [ -z "$line" ] && table=0
      continue
    fi
    [ "$shellfence" = 1 ] || continue
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

test_preflight_lint_is_git_grep() {
  local errors=''
  if [ ! -f "$PREFLIGHT_TEMPLATE" ]; then fail test_preflight_lint_is_git_grep "$PREFLIGHT_TEMPLATE missing"; return; fi
  grep -q -F 'grep -rPn' "$PREFLIGHT_TEMPLATE" && errors="$errors still has grep -rPn;"
  grep -q -F 'git grep --untracked -nE' "$PREFLIGHT_TEMPLATE" || errors="$errors lacks git grep --untracked -nE;"
  if [ -z "$errors" ]; then ok test_preflight_lint_is_git_grep; else fail test_preflight_lint_is_git_grep "$PREFLIGHT_TEMPLATE:${errors%;}"; fi
}

test_six_files_link_onboarding() {
  local file count errors=''
  for file in $ONBOARDING_LINKERS; do
    if [ ! -f "$file" ]; then errors="$errors $file missing;"; continue; fi
    count=$(grep -c -F -- "$ONBOARDING_LINK" "$file")
    [ "$count" = 1 ] || errors="$errors $file links $ONBOARDING_LINK $count times, want 1;"
  done
  if [ -z "$errors" ]; then ok test_six_files_link_onboarding; else fail test_six_files_link_onboarding "${errors# }"; fi
}

# The ERE lint must flag the fixture's lines 2 and 3 only, tracked or untracked (no staging);
# where grep -P exists, the PCRE it replaces must agree.
test_preflight_lint_matches_pcre_on_fixture() {
  local want='2 3' got untracked pcre errors=''
  if [ ! -f "$LINKLINT_FIXTURE" ]; then fail test_preflight_lint_matches_pcre_on_fixture "$LINKLINT_FIXTURE missing"; return; fi
  got=$(git grep -nE "$LINKLINT_ERE" -- "$LINKLINT_FIXTURE" | awk -F: '{ print $2 }')
  got=$(echo $got)
  [ "$got" = "$want" ] || errors="$errors git grep -nE flags lines '$got', want '$want';"
  cp "$LINKLINT_FIXTURE" "$LINKLINT_UNTRACKED"
  untracked=$(git grep --untracked -nE "$LINKLINT_ERE" -- "$LINKLINT_UNTRACKED" | awk -F: '{ print $2 }')
  untracked=$(echo $untracked)
  rm -f "$LINKLINT_UNTRACKED"
  [ "$untracked" = "$want" ] || errors="$errors git grep --untracked flags lines '$untracked', want '$want';"
  if echo a | grep -P a >/dev/null 2>&1; then
    pcre=$(grep -Pn "$LINKLINT_PCRE" "$LINKLINT_FIXTURE" | awk -F: '{ print $1 }')
    pcre=$(echo $pcre)
    [ "$pcre" = "$want" ] || errors="$errors grep -P flags lines '$pcre', want '$want';"
  fi
  if [ -z "$errors" ]; then ok test_preflight_lint_matches_pcre_on_fixture; else fail test_preflight_lint_matches_pcre_on_fixture "$LINKLINT_FIXTURE:${errors%;}"; fi
}

# Branch under test: GITHUB_REF_NAME in GitHub Actions, else the checked-out branch.
current_branch() {
  if [ -n "${GITHUB_REF_NAME:-}" ]; then printf '%s\n' "$GITHUB_REF_NAME"; else git branch --show-current; fi
}

# (a) top-level entries within the allowlist, (b) no secret pattern, (c) tracked size under 1 MB.
test_shipped_tree() {
  local branch allowed entry extra='' hits file bytes total=0 errors=''
  branch=$(current_branch)
  allowed=$SHIPPED_ALLOWLIST
  [ "$branch" = main ] || allowed="$allowed $WORKSPACE_ENTRIES"
  while IFS= read -r entry; do
    case " $allowed " in *" $entry "*) ;; *) extra="$extra $entry" ;; esac
  done < <(git ls-files | cut -d/ -f1 | sort -u)
  [ -z "$extra" ] || errors="$errors top-level entries outside the plugin structure on '$branch':$extra;"
  hits=$(git grep -lE -e "$SECRET_PATTERN" -- . $SECRET_EXEMPT)
  [ -z "$hits" ] || errors="$errors secret pattern in: $(echo $hits);"
  while IFS= read -r file; do
    bytes=$(wc -c <"$file")
    total=$((total + bytes))
  done < <(git ls-files)
  [ "$total" -lt "$SHIPPED_MAX_BYTES" ] || errors="$errors tracked files $((total / 1024)) KB (max $((SHIPPED_MAX_BYTES / 1024)) KB);"
  if [ -z "$errors" ]; then ok test_shipped_tree; else fail test_shipped_tree "${errors# }"; fi
}

test_readme_has_requirements_section() {
  if grep -q -x '## Requirements' "$README"; then ok test_readme_has_requirements_section; else fail test_readme_has_requirements_section "$README lacks a '## Requirements' heading"; fi
}

test_readme_reply_styles_section() {
  local cmd missing=''
  for cmd in "${STYLE_COMMANDS[@]}"; do
    grep -q -F -- "$cmd" "$README" || missing="$missing '$cmd'"
  done
  if [ -z "$missing" ]; then ok test_readme_reply_styles_section; else fail test_readme_reply_styles_section "$README lacks:$missing"; fi
}

test_readme_release_notes_migration() {
  local errors=''
  grep -q -x '### 2.0.0' "$README" || errors="$errors no '### 2.0.0' heading;"
  grep -q -F '/output-style ni:lite' "$README" || errors="$errors no /output-style ni:lite mention;"
  if [ -z "$errors" ]; then ok test_readme_release_notes_migration; else fail test_readme_release_notes_migration "$README:${errors%;}"; fi
}

test_readme_names_no_language() {
  local name hits=''
  for name in "${LANGUAGE_NAMES[@]}"; do
    hits="$hits $(grep -n -F -- "$name" "$README" | cut -d: -f1 | sed "s|^|$README:|")"
  done
  hits=$(echo $hits)
  if [ -z "$hits" ]; then ok test_readme_names_no_language; else fail test_readme_names_no_language "$hits"; fi
}

test_plugin_version_is_2_0_0() {
  if grep -q -F '"version": "2.0.0"' "$MANIFEST"; then ok test_plugin_version_is_2_0_0; else fail test_plugin_version_is_2_0_0 "$MANIFEST version is not 2.0.0"; fi
}

test_ci_workflow_matrix() {
  local runner errors=''
  if [ ! -f "$WORKFLOW" ]; then fail test_ci_workflow_matrix "$WORKFLOW missing"; return; fi
  for runner in "${CI_RUNNERS[@]}"; do
    grep -q -r -F -- "os: $runner" .github/workflows || errors="$errors no $runner caller;"
  done
  grep -q -F 'plugin validate' "$WORKFLOW" || errors="$errors no plugin validate step;"
  grep -q -E '^[[:space:]]*shell:' "$WORKFLOW" && errors="$errors has a shell: line;"
  if [ -z "$errors" ]; then ok test_ci_workflow_matrix; else fail test_ci_workflow_matrix "$WORKFLOW:${errors%;}"; fi
}

test_no_runtime_files
test_manifest_has_no_hooks
test_no_platform_leaks
test_no_shell_isms
test_software_engineer_files
test_onboarding_checklist
test_terse_styles_frontmatter
test_preflight_lint_is_git_grep
test_preflight_lint_matches_pcre_on_fixture
test_six_files_link_onboarding
test_shipped_tree
test_readme_has_requirements_section
test_readme_reply_styles_section
test_readme_release_notes_migration
test_readme_names_no_language
test_plugin_version_is_2_0_0
test_ci_workflow_matrix

[ "$FAILED" -eq 0 ] || { printf '%s test(s) failed\n' "$FAILED"; exit 1; }
