#!/usr/bin/env bash
# Validate the plugin from a clean Claude Code install inside Docker (maintainer-run).
# The host config is never touched: a throwaway config dir holds a copy of the OAuth
# credentials only, the repository is mounted read-only, scratch projects live in the
# container. Prints: plugin validate result, /ni:help output, one reply under ni:full
# and one under default with output token counts.
# Env: CLAUDE_CREDENTIALS (default ~/.claude/.credentials.json), DOCKER_IMAGE (node:22),
#      VALIDATE_MODEL (sonnet).
set -u

REPO=$(cd "$(dirname "$0")/.." && pwd)
CREDS=${CLAUDE_CREDENTIALS:-$HOME/.claude/.credentials.json}
IMAGE=${DOCKER_IMAGE:-node:22}
MODEL=${VALIDATE_MODEL:-sonnet}

[ -r "$CREDS" ] || { echo "no credentials file at $CREDS (run claude once on the host, or set CLAUDE_CREDENTIALS)" >&2; exit 2; }

CFG=$(mktemp -d)
LOG=$CFG.log
# The container runs as root and writes into /cfg; it chowns everything back to the
# host user before exiting so the host can delete the directory.
trap 'rm -rf "$CFG"' EXIT
cp "$CREDS" "$CFG/.credentials.json"
chmod 600 "$CFG/.credentials.json"

cat >"$CFG/run.sh" <<'EOF'
set -u
trap 'chown -R "$HOST_UID:$HOST_GID" /cfg' EXIT
export CLAUDE_CONFIG_DIR=/cfg
export HOME=/cfg/home
mkdir -p "$HOME"
npm install -g --silent @anthropic-ai/claude-code >/dev/null 2>&1 || { echo "npm install failed"; exit 3; }
echo "== claude $(claude --version)"
echo "== plugin validate"
claude plugin validate /plugin; echo "exit=$?"
echo "== /ni:help"
mkdir -p /work/help && cd /work/help
claude --plugin-dir /plugin -p "/ni:help" --model "$MODEL" 2>&1 | head -40
for style in ni:full default; do
  d=/work/$(printf '%s' "$style" | tr ':' '_')
  mkdir -p "$d/.claude" && cd "$d"
  printf '{"outputStyle":"%s"}\n' "$style" >.claude/settings.local.json
  echo "== reply under $style"
  claude --plugin-dir /plugin -p "Explain database connection pooling." --model "$MODEL" --output-format json >out.json 2>err.txt
  node -e 'const d=JSON.parse(require("fs").readFileSync("out.json","utf8"));console.log("output_tokens:",d.usage&&d.usage.output_tokens);console.log(d.result)' || cat err.txt
done
EOF

docker run --rm \
  -v "$REPO:/plugin:ro" \
  -v "$CFG:/cfg" \
  -e MODEL="$MODEL" -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
  "$IMAGE" bash /cfg/run.sh 2>&1 | tee "$LOG"
printf '\nLog kept at %s\n' "$LOG"
