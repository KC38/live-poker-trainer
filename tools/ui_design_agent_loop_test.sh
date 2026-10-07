#!/usr/bin/env bash
# The ui-design-agent loop builds the right CLI call and skips busy runs.
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
export PRIMARY="$ROOT"
export SIM_LOCK_DIR="$tmp/lock"
mkdir -p "$HOME/.cursor/plugins/cache/cursor-public/atlassian/old" \
  "$HOME/.cursor/plugins/cache/cursor-public/atlassian/new" "$tmp/bin"
touch -t 202601010000 "$HOME/.cursor/plugins/cache/cursor-public/atlassian/old"

# A fake Cursor CLI: logged in, and records that it was started.
cat >"$tmp/bin/agent" <<EOF
#!/usr/bin/env bash
if [[ "\${1:-}" == "status" ]]; then echo "Logged in as test"; exit 0; fi
echo started >>"$tmp/agent-started"
EOF
chmod +x "$tmp/bin/agent"

export UI_AGENT_LOOP_SOURCE_ONLY=1
# shellcheck disable=SC1090
source "$LOOP"
export PATH="$tmp/bin:$PATH"

args="$(agent_args)"
for want in -p --force --trust --approve-mcps --sandbox disabled --workspace "$ROOT" --plugin-dir; do
  grep -qxF -- "$want" <<<"$args" || fail "agent args missing $want"
done
grep -q 'atlassian/new$' <<<"$args" || fail "should load the newest Atlassian plugin"
grep -q 'atlassian/old' <<<"$args" && fail "should not load the older Atlassian plugin"

UI_AGENT_MODEL=test-model
grep -qxF -- test-model <<<"$(agent_args)" || fail "UI_AGENT_MODEL not passed"
unset UI_AGENT_MODEL

UI_AGENT_PLUGIN_DIRS="$tmp/missing:$HOME/.cursor/plugins/cache/cursor-public/atlassian/old"
override="$(plugin_args)"
grep -q 'atlassian/old$' <<<"$override" || fail "UI_AGENT_PLUGIN_DIRS override ignored"
grep -q missing <<<"$override" && fail "missing plugin dir should be skipped"
unset UI_AGENT_PLUGIN_DIRS

sync_primary() { :; }

python3 "$ROOT/tools/sim_lock.py" claim --owner other-agent --purpose "holding" >/dev/null 2>&1
code=0
one_run >/dev/null 2>&1 || code=$?
[[ "$code" == 10 ]] || fail "busy mini should skip with 10, got $code"
[[ ! -f "$tmp/agent-started" ]] || fail "agent must not start while the mini is busy"

python3 "$ROOT/tools/sim_lock.py" release --force >/dev/null 2>&1
one_run >/dev/null 2>&1 || fail "free mini run failed"
[[ -f "$tmp/agent-started" ]] || fail "agent should start when the mini is free"

(unset UI_AGENT_LOOP_SOURCE_ONLY; bash "$LOOP" status >/dev/null) \
  || fail "status should exit 0"
rm -f "$LOG_DIR"/run-*.log
(unset UI_AGENT_LOOP_SOURCE_ONLY; bash "$LOOP" status >/dev/null) \
  || fail "status should exit 0 before the first run"

echo "ui-design-agent loop ok"
