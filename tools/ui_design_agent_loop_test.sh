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
echo "\$CURSOR_API_KEY|\$ATLASSIAN_API_TOKEN|\$AGENT_CLI_CREDENTIAL_STORE" >"$tmp/agent-env"
echo started >>"$tmp/agent-started"
EOF
chmod +x "$tmp/bin/agent"

# Fake security so configure_agent_credentials never touches the real keychain.
SEC_LOG="$tmp/security.log"
export SEC_LOG
: >"$SEC_LOG"
cat >"$tmp/bin/security" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"$SEC_LOG"
exit 1
EOF
chmod +x "$tmp/bin/security"

export UI_AGENT_LOOP_SOURCE_ONLY=1
export UI_AGENT_SKIP_SIM_PREFLIGHT=1
# shellcheck disable=SC1090
source "$LOOP"
export PATH="$tmp/bin:$PATH"
unset AGENT_CLI_CREDENTIAL_STORE

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
grep -q 'ui-design-agent-learnings.md' "$tmp/agent-args" \
  || fail "prompt should name the learnings file"
grep -q 'SIM_LOCK_RUN_ID is set' <<<"$(prompt)" \
  || fail "prompt should tell the agent the lock is preflight-claimed"
[[ "$(cat "$tmp/agent-env")" == 'key with space|tok-123|memory' ]] \
  || fail "run should inherit keys and set AGENT_CLI_CREDENTIAL_STORE=memory: $(cat "$tmp/agent-env")"

# Programmatic SIM_NOT_READY must not start the agent.
rm -f "$tmp/agent-started"
ensure_sim_ready() { return 1; }
code=0
one_run >/dev/null 2>&1 || code=$?
[[ "$code" == 12 ]] || fail "preflight failure should return 12, got $code"
[[ ! -f "$tmp/agent-started" ]] || fail "agent must not start on SIM_NOT_READY preflight"
grep -q '"result": "sim-not-ready"' "$COVERAGE_FILE" \
  || fail "preflight should append sim-not-ready coverage"
# Restore a passing preflight for the rest of the suite.
ensure_sim_ready() { return 0; }
python3 "$ROOT/tools/sim_lock.py" release --force >/dev/null 2>&1

(unset UI_AGENT_LOOP_SOURCE_ONLY; bash "$LOOP" status >/dev/null) \
  || fail "status should exit 0"
rm -f "$LOG_DIR"/run-*.log
(unset UI_AGENT_LOOP_SOURCE_ONLY; bash "$LOOP" status >/dev/null) \
  || fail "status should exit 0 before the first run"

# dart_vm_ready must match real Flutter VM URIs on macOS grep.
vm_log="$tmp/vm.log"
printf '%s\n' 'A Dart VM Service on iPhone 13 mini is available at: http://127.0.0.1:54552/IqQYiKnzOKQ=/' >"$vm_log"
FLUTTER_RUN_LOG="$vm_log"
dart_vm_ready || fail "dart_vm_ready should accept token ending in ="
printf '%s\n' 'Launching lib/main.dart on iPhone 13 mini in debug mode...' >"$vm_log"
dart_vm_ready && fail "dart_vm_ready should fail before the VM line"

# Stall helper: fresh heartbeat is fine; ancient heartbeat is stalled.
# HEARTBEAT_ONLY skips host flutter/tmux probes so CI/dev machines with a
# live mini build do not mask the age check.
python3 "$ROOT/tools/sim_lock.py" claim --owner stall-test --purpose "fresh" --pid $$ >/dev/null
STALL_SECONDS=600
UI_AGENT_STALL_HEARTBEAT_ONLY=1
export UI_AGENT_STALL_HEARTBEAT_ONLY
lock_heartbeat_stalled && fail "fresh heartbeat must not look stalled"
python3 - <<PY
import json, time
from pathlib import Path
path = Path("$SIM_LOCK_DIR") / "simulator-lock.json"
state = json.loads(path.read_text())
state["heartbeat_epoch"] = time.time() - 601
path.write_text(json.dumps(state))
PY
lock_heartbeat_stalled || fail "heartbeat older than STALL_SECONDS should be stalled"
unset UI_AGENT_STALL_HEARTBEAT_ONLY
python3 "$ROOT/tools/sim_lock.py" release --force >/dev/null 2>&1

# configure_agent_credentials is a no-op without CURSOR_API_KEY; with a key
# it sets memory store and clears stuck keychain (fake security above).
: >"$SEC_LOG"
unset CURSOR_API_KEY AGENT_CLI_CREDENTIAL_STORE
configure_agent_credentials || fail "configure_agent_credentials should no-op without key"
[[ -z "${AGENT_CLI_CREDENTIAL_STORE:-}" ]] || fail "must not set store without API key"
[[ ! -s "$SEC_LOG" ]] || fail "security must not run without CURSOR_API_KEY"
CURSOR_API_KEY='test-key'
configure_agent_credentials || fail "configure_agent_credentials must be non-fatal"
[[ "${AGENT_CLI_CREDENTIAL_STORE}" == "memory" ]] || fail "expected memory store"
grep -q 'delete-generic-password -s cursor-access-token -a cursor-user' "$SEC_LOG" \
  || fail "should try to clear stuck cursor-access-token: $(cat "$SEC_LOG")"
unset CURSOR_API_KEY AGENT_CLI_CREDENTIAL_STORE

# Backoff helper: latest coverage result drives SIM_NOT_READY sleep.
mkdir -p "$(dirname "$COVERAGE_FILE")"
printf '%s\n' '{"result":"closed"}' >"$COVERAGE_FILE"
last_run_sim_not_ready && fail "closed coverage must not look like SIM_NOT_READY"
printf '%s\n' '{"result":"sim-not-ready","ticket":""}' >"$COVERAGE_FILE"
last_run_sim_not_ready || fail "sim-not-ready coverage should trigger backoff"

# The loop's own tmux server (socket ui-agent) and the login LaunchAgent.
# $HOME/.local/bin is first on the script's PATH, so these fakes win.
mkdir -p "$HOME/.local/bin"
TMUX_LOG="$tmp/tmux.log"
LAUNCH_LOG="$tmp/launchctl.log"
SESSION_FLAG="$tmp/tmux-has-session"
: >"$TMUX_LOG"
: >"$LAUNCH_LOG"
cat >"$HOME/.local/bin/tmux" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"$TMUX_LOG"
if [[ "\${1:-}" == "-L" && "\${3:-}" == "has-session" ]]; then
  [[ -f "$SESSION_FLAG" ]]
  exit \$?
fi
if [[ "\${1:-}" == "-L" && "\${3:-}" == "new-session" ]]; then
  touch "$SESSION_FLAG"
  exit 0
fi
if [[ "\${1:-}" == "-L" && "\${3:-}" == "kill-session" ]]; then
  rm -f "$SESSION_FLAG"
  exit 0
fi
exit 0
EOF
cat >"$HOME/.local/bin/launchctl" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"$LAUNCH_LOG"
exit 0
EOF
chmod +x "$HOME/.local/bin/tmux" "$HOME/.local/bin/launchctl"

unset UI_AGENT_LOOP_SOURCE_ONLY
start_out="$(bash "$LOOP" start)"
grep -q 'started the loop' <<<"$start_out" || fail "start should report started: $start_out"
grep -q -- '-L ui-agent new-session -d -s ui-design-agent ' "$TMUX_LOG" \
  || fail "start must create the session on socket ui-agent: $(cat "$TMUX_LOG")"
grep -q 'loop exited' "$TMUX_LOG" \
  || fail "start must exit after run-loop (no idle exec bash): $(cat "$TMUX_LOG")"
grep -q 'exec bash' "$TMUX_LOG" \
  && fail "start must not leave idle exec bash: $(cat "$TMUX_LOG")"
while IFS= read -r line; do
  [[ "$line" == "-L ui-agent "* ]] || fail "tmux call left socket ui-agent: $line"
done <"$TMUX_LOG"

# Fake tmux does not exec run-loop; simulate a live loop pid for "already running".
echo $$ >"$HOME/.live-poker-trainer/ui-agent-loop.pid"
again="$(bash "$LOOP" start)"
grep -q 'already running' <<<"$again" || fail "second start should see the live loop: $again"
new_count="$(grep -c 'new-session' "$TMUX_LOG" || true)"
[[ "$new_count" == 1 ]] || fail "a second start must not open another session (got $new_count)"

status_out="$(bash "$LOOP" status)"
grep -q 'loop: running (tmux -L ui-agent, session ui-design-agent' <<<"$status_out" \
  || fail "status should name the ui-agent socket: $status_out"
grep -q 'login item: not installed' <<<"$status_out" \
  || fail "login item should start uninstalled: $status_out"

# Idle leftover session (tmux up, run-loop dead) must be replaced by ensure.
rm -f "$HOME/.live-poker-trainer/ui-agent-loop.pid"
: >"$TMUX_LOG"
ensure_out="$(bash "$LOOP" ensure)"
grep -q 'replacing idle tmux session' <<<"$ensure_out$start_out$(cat "$TMUX_LOG")" \
  || grep -q 'kill-session' "$TMUX_LOG" \
  || fail "ensure must kill idle session when run-loop is dead: out=$ensure_out log=$(cat "$TMUX_LOG")"
grep -q 'new-session' "$TMUX_LOG" \
  || fail "ensure must start a fresh session after idle: $(cat "$TMUX_LOG")"

install_out="$(bash "$LOOP" install)"
plist="$HOME/Library/LaunchAgents/com.livepokertrainer.ui-design-agent.plist"
[[ -f "$plist" ]] || fail "install should write $plist ($install_out)"
grep -q '<string>com.livepokertrainer.ui-design-agent</string>' "$plist" \
  || fail "plist label missing"
grep -q '<string>ensure</string>' "$plist" || fail "plist must launch ensure"
grep -q '<key>StartInterval</key>' "$plist" || fail "plist must retry when the loop is down"
grep -q 'ui_design_agent_loop.sh' "$plist" || fail "plist must name the loop script"
grep -F -q "bootstrap gui/$(id -u) $plist" "$LAUNCH_LOG" \
  || fail "install should bootstrap the agent: $(cat "$LAUNCH_LOG")"
grep -q 'login item: installed (com.livepokertrainer.ui-design-agent)' \
  <<<"$(bash "$LOOP" status)" || fail "status should see the login item"

bash "$LOOP" uninstall >/dev/null
[[ ! -f "$plist" ]] || fail "uninstall should remove the plist"
grep -q 'login item: not installed' <<<"$(bash "$LOOP" status)" \
  || fail "status should clear the login item"

# Session-log backfill + health reconcile (TTY log often empty).
export UI_AGENT_LOOP_SOURCE_ONLY=1
# shellcheck disable=SC1090
source "$LOOP"
empty_run="$LOG_DIR/run-backfill-test.log"
: >"$empty_run"
sess_dir="/tmp/cursor-agent-logs-uiagenttest-$$"
mkdir -p "$sess_dir"
trap 'rm -rf "$tmp" "$sess_dir"' EXIT
sess="$sess_dir/session-2026-10-10T12-00-00-000Z-$$-1.log"
printf '%s\n' '--- Cursor Agent Debug Session ---' 'User prompt' \
  'LPT-99 closed Lock released' >"$sess"
start_epoch=$(( $(date +%s) - 5 ))
backfill_run_log_from_session "$empty_run" "$start_epoch" ""
grep -q 'backfilled from' "$empty_run" || fail "backfill should annotate source: $(cat "$empty_run")"
grep -q 'LPT-99 closed' "$empty_run" || fail "backfill should copy session prose: $(cat "$empty_run")"

: >"$HEALTH_FILE"
printf '%s\n' \
  '{"at":"2026-10-10T15:29:26+05:30","sha":"x","surface":"s","result":"closed","ticket":"LPT-50","leads":[],"learnings":"updated"}' \
  '{"at":"2026-10-10T15:51:14+05:30","sha":"y","surface":"s","result":"closed","ticket":"LPT-51","leads":[],"learnings":"updated"}' \
  >"$COVERAGE_FILE"
reconcile_health_from_coverage
grep -q '"ticket": "LPT-50"' "$HEALTH_FILE" || fail "reconcile should add LPT-50: $(cat "$HEALTH_FILE")"
grep -q '"ticket": "LPT-51"' "$HEALTH_FILE" || fail "reconcile should add LPT-51: $(cat "$HEALTH_FILE")"
# Idempotent.
reconcile_health_from_coverage
[[ "$(grep -c LPT-50 "$HEALTH_FILE")" == 1 ]] || fail "reconcile must not duplicate LPT-50"

write_health_row "20261010-160000" "0" "12" "$empty_run" "$start_epoch"
grep -q '"stamp": "20261010-160000"' "$HEALTH_FILE" || fail "write_health_row should append"

echo "ui-design-agent loop ok"
