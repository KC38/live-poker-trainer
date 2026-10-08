#!/usr/bin/env bash
# The ui-design-agent loop builds the right CLI call, loads secrets, and skips
# runs while the mini is busy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOOP="$ROOT/tools/ui_design_agent_loop.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

tmp="$(mktemp -d "${TMPDIR:-/tmp}/ui-agent-loop.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export SIM_LOCK_DIR="$tmp/lock"
export PRIMARY="$ROOT"
mkdir -p "$HOME/.live-poker-trainer" "$tmp/bin"

printf 'CURSOR_API_KEY=%q\nATLASSIAN_EMAIL=%q\nATLASSIAN_API_TOKEN=%q\n' \
  'key with space' 'kc@example.com' 'tok-123' >"$HOME/.live-poker-trainer/secrets.env"

# A fake Cursor CLI that records each run's arguments and environment.
cat >"$tmp/bin/agent" <<EOF
#!/usr/bin/env bash
if [[ "\${1:-}" == "status" ]]; then echo "Not logged in"; exit 0; fi
printf '%s\n' "\$@" >"$tmp/agent-args"
echo "\$CURSOR_API_KEY|\$ATLASSIAN_API_TOKEN" >"$tmp/agent-env"
echo started >>"$tmp/agent-started"
EOF
chmod +x "$tmp/bin/agent"

export UI_AGENT_LOOP_SOURCE_ONLY=1
# shellcheck disable=SC1090
source "$LOOP"
export PATH="$tmp/bin:$PATH"

[[ "${CURSOR_API_KEY:-}" == 'key with space' ]] || fail "secrets.env not loaded"
logged_in || fail "a saved API key counts as logged in"

args="$(agent_args)"
for want in -p --force --trust --sandbox disabled --workspace "$(primary)"; do
  grep -qxF -- "$want" <<<"$args" || fail "agent args missing $want"
done
grep -q 'tok-123' <<<"$args" && fail "the token must not appear on the command line"
grep -q -- '--plugin-dir\|--approve-mcps' <<<"$args" && fail "runs do not load MCP plugins"

UI_AGENT_MODEL=test-model
grep -qxF -- test-model <<<"$(agent_args)" || fail "UI_AGENT_MODEL not passed"
unset UI_AGENT_MODEL

sync_primary() { :; }

python3 "$ROOT/tools/sim_lock.py" claim --owner other-agent --purpose "holding" >/dev/null 2>&1
code=0
one_run >/dev/null 2>&1 || code=$?
[[ "$code" == 10 ]] || fail "busy mini should skip with 10, got $code"
[[ ! -f "$tmp/agent-started" ]] || fail "agent must not start while the mini is busy"

python3 "$ROOT/tools/sim_lock.py" release --force >/dev/null 2>&1
one_run >/dev/null 2>&1 || fail "free mini run failed"
[[ -f "$tmp/agent-started" ]] || fail "agent should start when the mini is free"
grep -q 'ui-design-agent.md' "$tmp/agent-args" || fail "prompt should name the command"
[[ "$(cat "$tmp/agent-env")" == 'key with space|tok-123' ]] || fail "run should inherit the saved keys"

(unset UI_AGENT_LOOP_SOURCE_ONLY; bash "$LOOP" status >/dev/null) \
  || fail "status should exit 0"
rm -f "$LOG_DIR"/run-*.log
(unset UI_AGENT_LOOP_SOURCE_ONLY; bash "$LOOP" status >/dev/null) \
  || fail "status should exit 0 before the first run"

echo "ui-design-agent loop ok"
