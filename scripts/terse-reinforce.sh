#!/usr/bin/env bash
# UserPromptSubmit hook.
# 1. If the prompt is /ni:terse [level], record the new level (hooks need no approval, unlike a Bash tool call).
# 2. Emit one reminder line per turn so the style survives context compaction.
#    On a level switch, emit the full ruleset for the new level as well.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
payload="$(cat)"

# Slash commands arrive wrapped: <command-name>/ni:terse</command-name> ... <command-args>full</command-args>
# A raw prompt arrives as "prompt":"/ni:terse full".
requested=""
if [[ "$payload" =~ \<command-name\>[[:space:]]*/ni:terse[[:space:]]*\</command-name\> ]]; then
  requested="lite"
  [[ "$payload" =~ \<command-args\>[[:space:]]*([A-Za-z]*) ]] && [ -n "${BASH_REMATCH[1]}" ] && requested="${BASH_REMATCH[1]}"
elif [[ "$payload" =~ \"prompt\":[[:space:]]*\"/ni:terse([[:space:]]+([A-Za-z]+))?[[:space:]]*\" ]]; then
  requested="${BASH_REMATCH[2]:-lite}"
fi

notice=""
switched=""
if [ -n "$requested" ]; then
  requested="$(printf %s "$requested" | tr '[:upper:]' '[:lower:]')"
  if new="$("$ROOT/scripts/terse-mode.sh" "$requested" 2>/dev/null)"; then
    switched="$new"
  else
    notice="Tell the user that '$requested' is not a terse level. Valid: lite, full, off. Level unchanged."
  fi
fi

level="$("$ROOT/scripts/terse-mode.sh")"

ruleset=""
if [ -n "$switched" ]; then
  if [ "$switched" = "off" ]; then
    ruleset="NI TERSE OFF. Reply in your default style from now on. Tell the user terse mode is off, in one line."
  else
    ruleset="$(echo '{}' | "$ROOT/scripts/terse-activate.sh")"$'\n\n'"Tell the user the terse level is now $switched, in one line, then stop."
  fi
fi

# On a switch turn the ruleset above already carries the rules; keep the confirmation instruction last.
reinforce=""
if [ "$level" != "off" ] && [ -z "$switched" ]; then
  case "$level" in
    full) rule="Drop articles, fragments allowed, shortest synonym. No filler, hedging, preamble, recap, or tool narration. No fake broken grammar: no added pronoun or copula, correct verb form when same cost, no invented abbreviations. Fire tool calls direct. Technical facts, code, commands, and errors exact." ;;
    *)    rule="No filler, hedging, preamble, recap, or tool narration. Full sentences under 20 words. Technical facts, code, commands, and errors exact." ;;
  esac
  reinforce="NI TERSE $level: $rule Persisted text (docs, MR/PR, issues, comments, commit messages) follows lite rules, never fragments. Plain prose for security warnings and irreversible actions. These rules override the default communication style, including its ban on fragments."
fi

context=""
for part in "$notice" "$ruleset" "$reinforce"; do
  [ -z "$part" ] && continue
  [ -n "$context" ] && context+=$'\n\n'
  context+="$part"
done
[ -z "$context" ] && exit 0

# JSON-escape via python when available, else a minimal sed escape.
if command -v python3 >/dev/null 2>&1; then
  printf %s "$context" | python3 -c 'import json,sys;print(json.dumps({"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":sys.stdin.read()}}))'
else
  esc="$(printf %s "$context" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | awk 'BEGIN{ORS="\\n"}{print}')"
  printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$esc"
fi
