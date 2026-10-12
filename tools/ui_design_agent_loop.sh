#!/usr/bin/env bash
# Run /ui-design-agent back to back, unattended, inside tmux.
#
#   tools/ui_design_agent_loop.sh setup    one-time: save the Cursor API key and Atlassian token
#   tools/ui_design_agent_loop.sh verify   check both work, including Jira from inside the CLI
#   tools/ui_design_agent_loop.sh start    start the loop (its own tmux server, socket ui-agent)
#   tools/ui_design_agent_loop.sh install  start it at login, and again every 5 minutes if it died
#   tools/ui_design_agent_loop.sh ensure   start the loop only when run-loop is alive
#   tools/ui_design_agent_loop.sh status   loop, simulator lock, and latest run log
#   tools/ui_design_agent_loop.sh attach   watch the loop
#   tools/ui_design_agent_loop.sh stop     soft-stop: finish current run, then ensure restarts
#   tools/ui_design_agent_loop.sh soft-stop  alias for stop (reload bash / structural fixes)
#   tools/ui_design_agent_loop.sh kill     stop now and free a lock this loop holds
#   tools/ui_design_agent_loop.sh once     one run in the foreground
#
# Each run claims the mini, brings up Flutter programmatically (refresh +
# wait for a Dart VM), and only then starts a Cursor SDK cloud agent aimed
# at this Mac mini My Machines worker (tools/ui-agent-sdk/run.mjs) so the
# chat shows up in the Agents sidebar as bc-* on the remote machine. Set
# UI_AGENT_SDK_RUNTIME=local for on-process SDK, or UI_AGENT_LAUNCHER=cli
# for `agent -p`. If the mini is busy or never reaches a Dart VM, the loop
# skips without starting the agent. It frees the lock if a run dies while
# holding it.
#
# Runs authenticate without the macOS keychain or a browser, so they keep
# working over SSH and after a reboot. Keys live in
# ~/.live-poker-trainer/secrets.env (mode 600): CURSOR_API_KEY for the SDK/
# CLI, ATLASSIAN_EMAIL + ATLASSIAN_API_TOKEN for tools/jira.py (Jira REST),
# and optionally FIREBASE_TOKEN (or GOOGLE_APPLICATION_CREDENTIALS path) so
# make-change / deploy-functions.sh can deploy from LaunchAgent runs.
#
# Environment:
#   UI_AGENT_LAUNCHER           sdk (default) or cli
#   UI_AGENT_SDK_RUNTIME        machine (default, Agents sidebar bc-*) or local
#   UI_AGENT_MACHINE_NAME       My Machines worker label (default:
#                               cursor-agent-worker-4c8b3dc416 on this mini)
#   UI_AGENT_MODEL              model id (default: auto / SDK `default`).
#                               Non-auto values are passed through to the
#                               SDK or `agent --model`.
#   UI_AGENT_GAP                seconds between runs (default 60)
#   UI_AGENT_BUSY_SLEEP         seconds to sleep when the mini is busy (default 300)
#   UI_AGENT_SIM_NOT_READY_SLEEP  seconds after programmatic SIM_NOT_READY (default 600)
#   UI_AGENT_USAGE_LIMIT_SLEEP  seconds after ActionRequiredError usage limit
#                               (default: until stated reset day, else 3600)
#   UI_AGENT_VM_WAIT_SECONDS    seconds to wait for a Dart VM per refresh (default 180)
#   UI_AGENT_MAX_RUN_SECONDS    hard cap per run (default 14400)
#   UI_AGENT_STALL_SECONDS      kill agent when lock heartbeat is older
#                               than this while the process is still alive
#                               (default 600). Covers Cursor reconnect hangs
#                               that otherwise hold the mini until MAX_RUN.
set -euo pipefail

export PATH="$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin:${PATH:-}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
TOOLS="$(dirname "$SCRIPT")"
# Tests set UI_AGENT_TMUX_SOCKET / UI_AGENT_TMUX_SESSION so status/ensure
# cannot see the machine's live ui-agent session.
SESSION="${UI_AGENT_TMUX_SESSION:-ui-design-agent}"
TMUX_SOCKET="${UI_AGENT_TMUX_SOCKET:-ui-agent}"
LAUNCH_LABEL="com.livepokertrainer.ui-design-agent"
PLIST="$HOME/Library/LaunchAgents/$LAUNCH_LABEL.plist"
STATE_DIR="$HOME/.live-poker-trainer"
LOG_DIR="$STATE_DIR/ui-agent-logs"
HEALTH_FILE="$STATE_DIR/ui-agent-health.jsonl"
STOP_FILE="$STATE_DIR/ui-agent.stop"
PID_FILE="$STATE_DIR/ui-agent.pid"
# Pid of the run-loop bash (not the agent). ensure/status use this so an
# idle tmux shell left after stop is not mistaken for a live loop.
LOOP_PID_FILE="$STATE_DIR/ui-agent-loop.pid"
SECRETS_FILE="$STATE_DIR/secrets.env"
GAP="${UI_AGENT_GAP:-60}"
BUSY_SLEEP="${UI_AGENT_BUSY_SLEEP:-300}"
# After back-to-back SIM_NOT_READY (usually Flutter cache lock / pub get
# killed), back off so other agents can finish and the mini can boot.
SIM_NOT_READY_SLEEP="${UI_AGENT_SIM_NOT_READY_SLEEP:-600}"
# Override for Auto quota exhaustion; when unset, sleep_usage_limit_seconds
# parses the reset date from the run log (else 3600s).
USAGE_LIMIT_SLEEP="${UI_AGENT_USAGE_LIMIT_SLEEP:-}"
VM_WAIT_SECONDS="${UI_AGENT_VM_WAIT_SECONDS:-180}"
MAX_RUN="${UI_AGENT_MAX_RUN_SECONDS:-14400}"
STALL_SECONDS="${UI_AGENT_STALL_SECONDS:-600}"
# sdk = @cursor/sdk; cli = legacy `agent -p`.
LAUNCHER="${UI_AGENT_LAUNCHER:-sdk}"
# machine = cloud SDK on My Machines worker (bc-* in Agents sidebar).
SDK_RUNTIME="${UI_AGENT_SDK_RUNTIME:-machine}"
MACHINE_NAME="${UI_AGENT_MACHINE_NAME:-cursor-agent-worker-4c8b3dc416}"
COVERAGE_FILE="$STATE_DIR/ui-agent-coverage.jsonl"
# Machine-SDK shells often lack cloud.envVars; agents read this handoff instead.
HANDOFF_FILE="$STATE_DIR/ui-agent-handoff.json"
FLUTTER_RUN_LOG="/tmp/flutter-live-poker-trainer.run.log"
REFRESH_SCRIPT="$(cd "$TOOLS/.." && pwd)/.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh"
SDK_DIR="$TOOLS/ui-agent-sdk"
SDK_RUN="$SDK_DIR/run.mjs"

mkdir -p "$LOG_DIR"

primary() {
  bash "$TOOLS/primary_checkout.sh"
}

# Written after programmatic preflight so cloud agents (envVars often unset in
# the tool shell) can adopt the lock and trust the ready Dart VM without
# re-claiming or re-refreshing.
write_sim_handoff() {
  local run_id="$1" primary_dir device
  primary_dir="$(primary)"
  device="$(bash "$TOOLS/iphone_13_mini_udid.sh" 2>/dev/null || true)"
  python3 - "$HANDOFF_FILE" "$run_id" "$primary_dir" "$FLUTTER_RUN_LOG" "$device" <<'PY'
import json, sys, time
from pathlib import Path
path, run_id, primary, flutter_log, device = sys.argv[1:6]
Path(path).write_text(
    json.dumps(
        {
            "at": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
            "sim_lock_run_id": run_id,
            "primary": primary,
            "flutter_run_log": flutter_log,
            "device": device or None,
            "dart_vm_ready": True,
            "do_not_refresh_at_start": True,
            "skip_sim_verify_at_start": True,
            "start_from_step": 2,
        },
        indent=2,
    )
    + "\n",
    encoding="utf-8",
)
PY
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

lt() {
  tmux -L "$TMUX_SOCKET" "$@"
}

# Pid of bash `run-loop` under our tmux session (zsh wrapper → run-loop).
# Empty when the session is missing or only an idle shell remains.
tmux_run_loop_pid() {
  local pane_pid="" child=""
  lt has-session -t "=$SESSION" 2>/dev/null || return 1
  pane_pid="$(lt list-panes -t "=$SESSION" -F '#{pane_pid}' 2>/dev/null | head -1 || true)"
  [[ -n "$pane_pid" ]] || return 1
  child="$(pgrep -P "$pane_pid" -f 'ui_design_agent_loop\.sh run-loop' 2>/dev/null | head -1 || true)"
  if [[ -z "$child" ]]; then
    # Pane may already be the run-loop bash (no zsh wrapper).
    if ps -p "$pane_pid" -o command= 2>/dev/null | grep -q 'ui_design_agent_loop\.sh run-loop'; then
      child="$pane_pid"
    fi
  fi
  [[ -n "$child" ]] || return 1
  echo "$child"
}

# True only while run-loop is alive. A leftover tmux session after stop
# (idle shell) must not count — LaunchAgent ensure used to no-op forever.
# Also recover when the pid file was cleared by one_run's EXIT trap (or a
# crash) while the session is still running — otherwise ensure/start would
# kill-session a healthy mid-ticket agent every 5 minutes.
loop_is_alive() {
  local pid="" recovered=""
  if [[ -f "$LOOP_PID_FILE" ]]; then
    pid="$(cat "$LOOP_PID_FILE" 2>/dev/null || true)"
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
  fi
  recovered="$(tmux_run_loop_pid 2>/dev/null || true)"
  if [[ -n "$recovered" ]] && kill -0 "$recovered" 2>/dev/null; then
    # Only adopt PIDs that are actually this script's run-loop.
    if ps -p "$recovered" -o command= 2>/dev/null \
      | grep -qF "ui_design_agent_loop.sh run-loop"; then
      echo "$recovered" >"$LOOP_PID_FILE"
      return 0
    fi
  fi
  return 1
}

prompt() {
  local run_id="${SIM_LOCK_RUN_ID:-}"
  local handoff_id="" primary_dir
  primary_dir="$(primary)"
  if [[ -f "$HANDOFF_FILE" ]]; then
    handoff_id="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("sim_lock_run_id") or "")' "$HANDOFF_FILE" 2>/dev/null || true)"
  fi
  [[ -n "$run_id" ]] || run_id="$handoff_id"
  local pending=""
  if [[ -s "$STATE_DIR/ui-agent-learnings-pending.md" ]]; then
    pending=" Pending learnings in $STATE_DIR/ui-agent-learnings-pending.md: fold them into this run's ticket PR (step 6)."
  fi
  # Lead with READY facts: agents otherwise spend the first ~60s re-grepping
  # the Dart VM / reconciling the lock even though preflight already did that.
  printf '%s' "READY (loop preflight done): iPhone 13 mini claimed, Dart VM up on origin/main, handoff at ${HANDOFF_FILE} has dart_vm_ready=true. Skip steps 0–1 sim work — do not claim, do not refresh-simulator.sh, do not grep/wait the flutter log at start. One shell only: export SIM_LOCK_RUN_ID='${run_id}' (cloud shells often lack it; also in that handoff), then go straight to step 2 (read design-record + learnings + pick ticket). Flutter log (only after a later build switch): ${FLUTTER_RUN_LOG}. PRIMARY: ${primary_dir}. Launch worktree builds with tools/flutter_run_fast.sh (cached Runner.app, ~20 s for Dart-only) and hot-restart with tools/flutter_hot_restart.sh — both block; never bare AwaitShell/sleep. Long flutter test/analyze: tools/tee_exit.sh in test-LPT-*/analyze-LPT-* tmux, then tools/wait_done.sh on the sibling .done. Jump to later lessons / heart states with tools/agent_seed.py and read screens with agent_tap.py tree; after openlesson use agent_tap.py wait-gold before taps; screenshot for judgment and proof only. Read .cursor/commands/ui-design-agent.md and .cursor/commands/ui-design-agent-learnings.md and follow them exactly. Never claim or fix tickets labeled grokbot (GrokBot / Chrome layout on Linux); queue JQL must include labels != grokbot. Filing only grokbot tickets is not a finished run — keep walking until you have a ui-agent KEY (do not end early so the loop starts another agent). Open PRs with gh pr create (not ManagePullRequest draft); gh pr ready before gh pr merge --squash. Step 10 coverage: python3 tools/ui_agent_coverage.py append … (never hand-write JSONL or strftime %z +0530). Learnings ride the ticket PR (write them before the merge; after it, append to the pending file).${pending} When this run has both a ticket key and a PR number, rename this Agents chat via cloud MCP rename-chat to 'LPT-NN PR-<number>' (step 8; step 10 fallback). This is an unattended run. Do not ask questions or wait for input."
}

# Long-lived run-loop bash keeps function bodies from process start. Re-eval
# prompt() from on-disk $SCRIPT before each agent so merges (wait-gold,
# grokbot continue, …) apply without soft-stop. Soft-stop still reloads the
# whole script for structural loop changes.
reload_prompt_from_disk() {
  local def
  def="$(sed -n '/^prompt() {/,/^}$/p' "$SCRIPT" 2>/dev/null || true)"
  if [[ -z "$def" ]]; then
    return 0
  fi
  # shellcheck disable=SC1090
  eval "$def"
}

load_secrets() {
  if [[ -f "$SECRETS_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    . "$SECRETS_FILE"
    set +a
  fi
}

# Human-facing model label for logs/status (auto when unset).
resolved_agent_model() {
  local model="${UI_AGENT_MODEL:-auto}"
  if [[ -z "$model" || "$model" == "auto" || "$model" == "default" ]]; then
    echo "auto"
    return 0
  fi
  echo "$model"
}

# SDK catalog id. Agents UI Auto is `default` (not `auto`).
sdk_model_id() {
  local model="${UI_AGENT_MODEL:-auto}"
  if [[ -z "$model" || "$model" == "auto" || "$model" == "default" ]]; then
    echo "default"
    return 0
  fi
  echo "$model"
}

# CLI `--model` flag value; empty means omit (CLI Auto router).
cli_model_flag() {
  local model="${UI_AGENT_MODEL:-auto}"
  if [[ -z "$model" || "$model" == "auto" || "$model" == "default" ]]; then
    echo ""
    return 0
  fi
  echo "$model"
}

agent_args() {
  local args=(-p --force --trust --sandbox disabled --output-format text --workspace "$(primary)")
  local model
  model="$(cli_model_flag)"
  if [[ -n "$model" ]]; then
    args+=(--model "$model")
  fi
  printf '%s\n' "${args[@]}"
}

ensure_sdk_deps() {
  [[ -f "$SDK_DIR/package.json" ]] || {
    log "missing $SDK_DIR/package.json"
    return 1
  }
  if [[ -d "$SDK_DIR/node_modules/@cursor/sdk" ]]; then
    return 0
  fi
  log "installing @cursor/sdk into $SDK_DIR"
  if ! (cd "$SDK_DIR" && npm ci --omit=dev) && ! (cd "$SDK_DIR" && npm install --omit=dev); then
    log "SDK npm install failed in $SDK_DIR"
    return 1
  fi
  if [[ ! -d "$SDK_DIR/node_modules/@cursor/sdk" ]]; then
    log "SDK install left $SDK_DIR without @cursor/sdk"
    return 1
  fi
}

# Install SDK deps before claiming the mini so the first machine/local SDK
# run after a soft-stop or reboot does not hold the lock during npm ci.
prepare_launcher() {
  [[ "$LAUNCHER" == "sdk" ]] || return 0
  ensure_sdk_deps
}

sync_primary() {
  local dir
  dir="$(primary)"
  git -C "$dir" fetch -q origin main || return 0
  if [[ "$(git -C "$dir" rev-parse --abbrev-ref HEAD)" == "main" && -z "$(git -C "$dir" status --porcelain)" ]]; then
    git -C "$dir" merge -q --ff-only origin/main || true
  fi
}

sim_lock() {
  python3 "$TOOLS/sim_lock.py" "$@"
}

logged_in() {
  [[ -n "${CURSOR_API_KEY:-}" ]] && return 0
  ! agent status 2>&1 | grep -qiE 'not logged in|keychain is locked|error'
}

# True when the latest coverage line is sim-not-ready (or the health tail
# says so when coverage is missing).
# True when a run log shows Cursor Auto / headless usage-limit errors.
run_log_has_usage_limit() {
  local run_log="$1"
  [[ -f "$run_log" ]] || return 1
  grep -qiE \
    'ActionRequiredError|usage limit|error_code=upgrade|resource_exhausted' \
    "$run_log"
}

# Seconds to sleep after a usage-limit exit (override via UI_AGENT_USAGE_LIMIT_SLEEP).
sleep_usage_limit_seconds() {
  local run_log="${1:-}"
  if [[ -n "$USAGE_LIMIT_SLEEP" ]]; then
    echo "$USAGE_LIMIT_SLEEP"
    return 0
  fi
  python3 - "$run_log" <<'PY' || echo 3600
import re, sys
from datetime import datetime, timedelta
from pathlib import Path

path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path()
text = ""
try:
    text = path.read_text(encoding="utf-8", errors="replace") if path.is_file() else ""
except OSError:
    pass
# "Your usage limits will reset when your monthly cycle ends on 10/11/2026."
# That date is the *last* day of the cycle; midnight of that day is often
# already past while Auto is still blocked. Sleep until the next local
# midnight after the stated day (+5m), not until a past 00:05 that floors
# forever at the 30m minimum and thrashes every half hour.
match = re.search(
    r"ends on\s+(\d{1,2})/(\d{1,2})/(\d{4})",
    text,
    re.I,
)
now = datetime.now().astimezone()
if match:
    month, day, year = (int(match.group(1)), int(match.group(2)), int(match.group(3)))
    try:
        day_start = datetime(year, month, day, 0, 0, tzinfo=now.tzinfo)
        next_cycle = day_start + timedelta(days=1, minutes=5)
        seconds = int((next_cycle - now).total_seconds())
        if seconds < 1800:
            tomorrow = (now + timedelta(days=1)).replace(
                hour=0, minute=5, second=0, microsecond=0
            )
            seconds = int((tomorrow - now).total_seconds())
        # Cap at 24h so a wrong far-future date cannot freeze the loop for days.
        print(max(1800, min(seconds, 86400)))
        raise SystemExit(0)
    except ValueError:
        pass
print(3600)
PY
}

last_run_sim_not_ready() {
  if [[ -f "$COVERAGE_FILE" ]]; then
    python3 - "$COVERAGE_FILE" <<'PY'
import json, sys
path = sys.argv[1]
try:
    lines = [ln for ln in open(path, encoding="utf-8") if ln.strip()]
except OSError:
    raise SystemExit(1)
if not lines:
    raise SystemExit(1)
try:
    obj = json.loads(lines[-1])
except json.JSONDecodeError:
    raise SystemExit(1)
raise SystemExit(0 if obj.get("result") == "sim-not-ready" else 1)
PY
    return $?
  fi
  if [[ -f "$HEALTH_FILE" ]]; then
    grep -q 'SIM_NOT_READY' <<<"$(tail -n 1 "$HEALTH_FILE")" && return 0
  fi
  return 1
}

# True when the Flutter run log has a Dart VM URI after the latest Launching
# (and, for a cached-Runner.app launch, after the first hot restart).
dart_vm_ready() {
  [[ -f "$FLUTTER_RUN_LOG" ]] || return 1
  python3 "$TOOLS/flutter_log_ready.py" "$FLUTTER_RUN_LOG" >/dev/null 2>&1
}

wait_for_dart_vm() {
  local deadline=$(( $(date +%s) + VM_WAIT_SECONDS ))
  while (( $(date +%s) < deadline )); do
    if dart_vm_ready; then
      return 0
    fi
    sleep 5
  done
  return 1
}

# True when the holder looks dead: lock heartbeat older than STALL_SECONDS
# and nothing is still working for this run. Heartbeat-only stalls
# false-killed worktree `flutter run` (often started via tmux, not as a
# child of agent -p) and long compiles that skip sim_lock heartbeats.
# Args: [run_log] — when set, a recently written run log counts as alive
# (machine SDK streams tool/thinking here while skipping heartbeats).
lock_heartbeat_stalled() {
  local agent_pid="" run_log="${1:-}"
  [[ -f "$PID_FILE" ]] && agent_pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  python3 - "$STALL_SECONDS" "${agent_pid:-}" "$run_log" <<'PY'
import json, os, subprocess, sys, time
from pathlib import Path

stall = int(sys.argv[1])
agent_pid = sys.argv[2].strip()
run_log = Path(sys.argv[3]) if len(sys.argv) > 3 and sys.argv[3] else None
now = time.time()
lock_dir = Path(os.environ.get("SIM_LOCK_DIR") or Path.home() / ".live-poker-trainer")
path = lock_dir / "simulator-lock.json"
try:
    state = json.loads(path.read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError):
    raise SystemExit(1)
if state.get("state") != "in_use":
    raise SystemExit(1)
beat = float(state.get("heartbeat_epoch") or state.get("claimed_epoch") or 0)
if (now - beat) <= stall:
    raise SystemExit(1)

# Machine SDK (and CLI) append thinking/tool_call lines to the run log while
# skipping sim_lock heartbeats. A fresh mtime means the agent is still live —
# false stall exit 13 killed mid-flutter-test on 20261012-123827.
# Checked before HEARTBEAT_ONLY so unit tests can cover it without host
# flutter/tmux probes masking the age check.
if run_log is not None and run_log.is_file():
    try:
        if (now - run_log.stat().st_mtime) <= stall:
            raise SystemExit(1)
    except OSError:
        pass

# Unit tests set this to exercise heartbeat age without host flutter/tmux.
if os.environ.get("UI_AGENT_STALL_HEARTBEAT_ONLY") == "1":
    raise SystemExit(0)

def _ps() -> str:
    try:
        return subprocess.check_output(
            ["ps", "-o", "pid=,ppid=,command=", "-ax"],
            text=True,
            errors="replace",
        )
    except (OSError, subprocess.CalledProcessError):
        return ""

ps_out = _ps()

# Worktree flutter/dart only. The loop's own preflight run on primary
# (flutter-live-poker-trainer / device UDID) must not mask a dead agent —
# that left stall forever after LPT-48 while primary flutter stayed up.
for line in ps_out.splitlines():
    low = line.lower()
    if ".worktrees/" not in low:
        continue
    if any(tok in low for tok in ("flutter", "dartvm", "dart ", "xcodebuild")):
        raise SystemExit(1)

# tmux sessions the ui-agent starts (default server and -L ui-agent).
# Include deploy/refresh helpers — firebase deploy skips heartbeats and
# used to look stalled while deploy-LPT-* was still running.
session_names: list[str] = []
for tmux_cmd in (
    ["tmux", "list-sessions", "-F", "#{session_name}"],
    ["tmux", "-L", "ui-agent", "list-sessions", "-F", "#{session_name}"],
):
    try:
        session_names.extend(
            subprocess.check_output(
                tmux_cmd,
                text=True,
                errors="replace",
                stderr=subprocess.DEVNULL,
            ).splitlines()
        )
    except (OSError, subprocess.CalledProcessError):
        pass
alive_prefixes = (
    "flutter-iphone-13-mini",
    "deploy-LPT-",
    "refresh-LPT-",
    "ship-refresh",
    "test-LPT-",
    "analyze-LPT-",
)
for name in session_names:
    if any(name.startswith(p) for p in alive_prefixes):
        raise SystemExit(1)

# Busy descendants under the script/agent pid.
if agent_pid.isdigit():
    children: dict[str, list[tuple[str, str]]] = {}
    for line in ps_out.splitlines():
        parts = line.strip().split(None, 2)
        if len(parts) < 3:
            continue
        pid_s, ppid_s, cmd = parts
        children.setdefault(ppid_s, []).append((pid_s, cmd))
    stack = [agent_pid]
    seen: set[str] = set()
    descendants: set[str] = set()
    busy_needles = (
        "flutter", "dart", "xcodebuild", "git ", "rsync", "pub get",
        "agent_tap", "simctl", "firebase", "npm ", "gh ", "deploy-functions",
    )
    while stack:
        cur = stack.pop()
        if cur in seen:
            continue
        seen.add(cur)
        descendants.add(cur)
        for child_pid, cmd in children.get(cur, []):
            stack.append(child_pid)
            low = cmd.lower()
            if any(n in low for n in busy_needles):
                raise SystemExit(1)
    for base in (Path("/tmp"), Path("/private/tmp")):
        if not base.is_dir():
            continue
        for log in base.glob("cursor-agent-logs-*/session-*.log"):
            if not any(f"-{pid}-" in log.name for pid in descendants):
                continue
            try:
                if (now - log.stat().st_mtime) <= stall:
                    raise SystemExit(1)
            except OSError:
                pass

raise SystemExit(0)
PY
}

# Unattended runs authenticate with CURSOR_API_KEY. The CLI still defaults
# to the macOS keychain and can burn on errSecDuplicateItem / persistFailed.
# Prefer an in-memory credential store (file|memory|default); memory skips
# keychain entirely. Also delete a stuck cursor-access-token item.
configure_agent_credentials() {
  [[ -n "${CURSOR_API_KEY:-}" ]] || return 0
  if [[ -z "${AGENT_CLI_CREDENTIAL_STORE:-}" ]]; then
    export AGENT_CLI_CREDENTIAL_STORE=memory
    log "AGENT_CLI_CREDENTIAL_STORE=memory (API key; skip macOS keychain)"
  fi
  if security delete-generic-password -s cursor-access-token -a cursor-user \
      >/dev/null 2>&1; then
    log "cleared stuck cursor-access-token keychain item (API key auth)"
  fi
}

# Back-compat name used in older comments/tests.
clear_stuck_cursor_keychain() {
  configure_agent_credentials
}

# Cursor CLI often leaves the script(1) TTY log empty or full of ^D /
# reconnect noise while the real session lives under
# /tmp/cursor-agent-logs-*/session-*-<pid>-*.log. Copy a readable summary
# into the run log when needed.
# Args: run_log start_epoch [root_pid] [quiet]
# quiet=1 suppresses the "backfilled …" line (watchdog mid-run).
backfill_run_log_from_session() {
  local run_log="$1" start_epoch="$2" root_pid="${3:-}" quiet="${4:-}"
  python3 - "$run_log" "$start_epoch" "$root_pid" "$quiet" <<'PY' || true
import hashlib, os, re, sys
from pathlib import Path

run_log = Path(sys.argv[1])
start_epoch = int(float(sys.argv[2]))
root_pid = sys.argv[3].strip() if len(sys.argv) > 3 else ""
quiet = (sys.argv[4].strip() if len(sys.argv) > 4 else "") in ("1", "true", "yes")

NOISE = re.compile(
    r"(Connection lost, reconnecting|Retry attempt |\^D|\x04|\x08)",
    re.I,
)
# Cursor session logs are mostly structured telemetry; keep human/signal lines.
DROP_LINE = re.compile(
    r"("
    r"\] logger |analytics\.track|structured-log\.|"
    r"startup\.|privacy\.|protoPrivacy|ripgrep\.|sandbox\.|"
    r"serverConfig|statsig\.|atFileSuggestions\.|OpenTelemetry|"
    r"cc-marketplace|logger\.default|debug-session-start|"
    r"Stack trace:|^\s*at "
    r")",
    re.I,
)


def cleaned_text(path: Path) -> str:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""
    return text.replace("\x04", "").replace("^D", "")


def useful(text: str) -> bool:
    lines = []
    for ln in text.splitlines():
        s = ln.strip()
        if not s or NOISE.search(s) or DROP_LINE.search(s):
            continue
        if s.startswith("# backfilled from"):
            continue
        if set(s) <= {"^", "D", "\x08", "."}:
            continue
        lines.append(s)
    body = "\n".join(lines)
    if len(body) < 80:
        return False
    # Prefer signal words over raw logger spam alone.
    if re.search(r"\b(LPT-\d+|SIM_NOT_READY|closed|stalled|Lock|step\s*\d+)\b", body, re.I):
        return True
    return False


def descendant_pids(root: str) -> set[str]:
    if not root.isdigit():
        return set()
    try:
        import subprocess
        out = subprocess.check_output(
            ["ps", "-ax", "-o", "pid=,ppid=,command="], text=True
        )
    except (OSError, subprocess.CalledProcessError):
        return {root}
    children: dict[str, list[str]] = {}
    for line in out.splitlines():
        parts = line.strip().split(None, 2)
        if len(parts) < 2:
            continue
        pid_s, ppid_s = parts[0], parts[1]
        children.setdefault(ppid_s, []).append(pid_s)
    seen: set[str] = set()
    stack = [root]
    while stack:
        cur = stack.pop()
        if cur in seen:
            continue
        seen.add(cur)
        stack.extend(children.get(cur, []))
    return seen


cur = cleaned_text(run_log) if run_log.is_file() else ""
# Refresh when the TTY log lacks ticket/result signal (typical for CLI).
force_refresh = cur.lstrip().startswith("# backfilled from") or not useful(cur)
if useful(cur) and not force_refresh:
    raise SystemExit(0)

pids = descendant_pids(root_pid) if root_pid else set()
candidates: list[tuple[float, int, Path]] = []
# Tests set UI_AGENT_SESSION_LOG_DIR so a live /tmp agent session cannot steal.
override = os.environ.get("UI_AGENT_SESSION_LOG_DIR", "").strip()
session_globs: list[tuple[Path, str]] = []
if override:
    session_globs.append((Path(override), "session-*.log"))
else:
    for base in (Path("/tmp"), Path("/private/tmp")):
        session_globs.append((base, "cursor-agent-logs-*/session-*.log"))
for base, pattern in session_globs:
    if not base.is_dir():
        continue
    for sess in base.glob(pattern):
        try:
            st = sess.stat()
        except OSError:
            continue
        name = sess.name
        pid_hit = any(f"-{p}-" in name for p in pids) if pids else False
        # Session created/updated during this run window.
        if not pid_hit and st.st_mtime < start_epoch - 15:
            continue
        # Prefer pid-matched logs; among those, largest wins (main vs sidecar).
        rank = 2.0 if pid_hit else 1.0
        candidates.append((rank, st.st_size, sess))

if not candidates:
    if not cur.strip():
        run_log.parent.mkdir(parents=True, exist_ok=True)
        run_log.write_text(
            f"(empty TTY log; no cursor session log found after epoch {start_epoch})\n",
            encoding="utf-8",
        )
    raise SystemExit(0)

candidates.sort(key=lambda t: (t[0], t[1]), reverse=True)
best = candidates[0][2]
prev_src = ""
prev_size = -1
m = re.match(r"# backfilled from (.+) \((\d+) bytes\)", cur.splitlines()[0] if cur else "")
if m:
    prev_src, prev_size = m.group(1), int(m.group(2))
try:
    best_size = best.stat().st_size
except OSError:
    best_size = 0
if prev_src == str(best) and prev_size >= best_size:
    raise SystemExit(0)

sess_text = cleaned_text(best)
body: list[str] = []
for ln in sess_text.splitlines():
    if DROP_LINE.search(ln) or NOISE.search(ln):
        continue
    body.append(ln)
if len(body) < 2:
    # Telemetry-only: stable marker (no trailing logger dump — that changed
    # every few seconds and spammed the loop pane via rewrite+print).
    body = ["(session log was telemetry-only)"]
for ln in cur.splitlines():
    if ln.startswith("# backfilled from") or ln.startswith("(session log was telemetry-only"):
        continue
    if ln.strip() and not NOISE.search(ln) and not DROP_LINE.search(ln) and ln not in body:
        body.append(ln)

def body_key(lines: list[str]) -> str:
    return hashlib.sha1("\n".join(lines).encode("utf-8", errors="replace")).hexdigest()

prev_body = []
for ln in cur.splitlines()[1:]:
    if ln.startswith("# backfilled from"):
        continue
    prev_body.append(ln)
# Same filtered body and only session bytes grew → bump header silently.
if prev_src == str(best) and body_key(prev_body) == body_key(body):
    header = f"# backfilled from {best} ({best_size} bytes)"
    run_log.parent.mkdir(parents=True, exist_ok=True)
    run_log.write_text(header + "\n" + "\n".join(body).rstrip() + "\n", encoding="utf-8")
    raise SystemExit(0)

kept = [f"# backfilled from {best} ({best_size} bytes)", *body]
run_log.parent.mkdir(parents=True, exist_ok=True)
run_log.write_text("\n".join(kept).rstrip() + "\n", encoding="utf-8")
if not quiet:
    print(f"backfilled {run_log} from {best}", flush=True)
PY
}

# Append health rows for coverage tickets that never got a health line
# (loop killed before one_run cleanup, empty TTY log, etc.).
reconcile_health_from_coverage() {
  python3 - "$HEALTH_FILE" "$COVERAGE_FILE" <<'PY' || true
import json, sys
from pathlib import Path

health_path, coverage_path = Path(sys.argv[1]), Path(sys.argv[2])
if not coverage_path.is_file():
    raise SystemExit(0)

def load_jsonl(path: Path) -> list[dict]:
    rows = []
    try:
        for ln in path.read_text(encoding="utf-8").splitlines():
            if not ln.strip():
                continue
            try:
                rows.append(json.loads(ln))
            except json.JSONDecodeError:
                pass
    except OSError:
        pass
    return rows

health = load_jsonl(health_path)
coverage = load_jsonl(coverage_path)
seen_tickets = {
    h.get("ticket") for h in health
    if h.get("ticket") and h.get("result") not in (None, "stalled", "sim-not-ready")
}
# Also treat stamps already recorded as done.
seen_at = {h.get("at") for h in health if h.get("at")}
appended = 0
for cov in coverage:
    ticket = cov.get("ticket")
    result = cov.get("result")
    at = cov.get("at")
    if not ticket or result in (None, "sim-not-ready", "stalled"):
        continue
    if ticket in seen_tickets:
        continue
    if at and at in seen_at:
        continue
    row = {
        "at": at or __import__("datetime").datetime.now().astimezone().isoformat(timespec="seconds"),
        "stamp": "reconciled",
        "exit": 0 if result == "closed" else -1,
        "seconds": None,
        "ticket": ticket,
        "result": result,
        "tail": f"reconciled from coverage surface={cov.get('surface')}",
        "reconciled": True,
    }
    health_path.parent.mkdir(parents=True, exist_ok=True)
    with health_path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(row) + "\n")
    seen_tickets.add(ticket)
    appended += 1
if appended:
    print(f"reconciled {appended} health row(s) from coverage", flush=True)
PY
}

# Rows written before coverage-preferring tails still store CLI telemetry.
# Rewrite those tails in place from ticket/result/surface (coverage or row).
repair_health_tails() {
  python3 - "$HEALTH_FILE" "$COVERAGE_FILE" <<'PY' || true
import json, re, sys
from datetime import datetime
from pathlib import Path

health_path, coverage_path = Path(sys.argv[1]), Path(sys.argv[2])
if not health_path.is_file():
    raise SystemExit(0)

TELEMETRY = re.compile(
    r"("
    r"Cursor Agent Debug Session|User does not belong to a team|"
    r"Loaded global commands|telemetry-only|filtered out for missing|"
    r"analytics\.track|structured-log"
    r")",
    re.I,
)
USAGE_LIMIT = re.compile(
    r"ActionRequiredError|usage limit|error_code=upgrade|resource_exhausted",
    re.I,
)
SDK_STREAM = re.compile(
    r'\{\s*"t"\s*:\s*\d+\s*,\s*"type"\s*:\s*"(?:thinking|assistant|tool_call|status)"\s*\}'
)


def scrub_sdk_stream(text: str) -> str:
    cleaned = SDK_STREAM.sub(" ", text or "")
    return re.sub(r"\s+", " ", cleaned).strip()


def _parse_iso_epoch(value):
    """Epoch seconds; accept Z and compact ±HHMM (macOS Python 3.9)."""
    if not value:
        return None
    text = str(value).strip()
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    else:
        m = re.search(r"([+-])(\d{2})(\d{2})$", text)
        if m is not None:
            text = text[: m.start()] + f"{m.group(1)}{m.group(2)}:{m.group(3)}"
    try:
        return datetime.fromisoformat(text).timestamp()
    except ValueError:
        return None

def stamp_epoch(stamp: str):
    try:
        return datetime.strptime(stamp, "%Y%m%d-%H%M%S").timestamp()
    except ValueError:
        return None


def stamp_run_window(row: dict):
    """Return (start_ep, run_end, end_ep) or (None, None, None)."""
    stamp = row.get("stamp") or ""
    start_ep = stamp_epoch(stamp)
    if start_ep is None:
        return None, None, None
    seconds = row.get("seconds")
    if isinstance(seconds, int):
        run_end = start_ep + max(seconds, 0)
        end_ep = run_end + 900
    else:
        end_ep = start_ep + 4 * 3600
        run_end = end_ep
    return start_ep, run_end, end_ep


def best_coverage_for_stamp(row: dict, exclude_tickets=None):
    """Coverage closest to start+seconds within the padded window."""
    start_ep, run_end, end_ep = stamp_run_window(row)
    if start_ep is None or run_end is None or end_ep is None:
        return None
    exclude = exclude_tickets or set()
    best = None
    best_delta = None
    for cov in coverage_rows:
        cov_ticket = cov.get("ticket")
        if not cov_ticket or cov_ticket in exclude:
            continue
        cov_ts = _parse_iso_epoch(cov.get("at"))
        if cov_ts is None:
            continue
        if cov.get("result") in (None, "sim-not-ready", "stalled"):
            continue
        if start_ep - 5 <= cov_ts <= end_ep:
            delta = abs(cov_ts - run_end)
            if best_delta is None or delta < best_delta:
                best = cov
                best_delta = delta
    return best


def apply_coverage_fill(row: dict, cov: dict, was_stalled: bool = False) -> None:
    ticket = cov.get("ticket")
    result = cov.get("result")
    row["ticket"] = ticket
    row["result"] = result
    surface = cov.get("surface")
    parts = [f"coverage:{result}", f"ticket:{ticket}"]
    if surface:
        parts.append(f"surface:{surface}")
    row["tail"] = " ".join(parts)
    row["tail_repaired"] = True
    if was_stalled:
        row["stall_upgraded"] = True


def load_jsonl(path: Path) -> list[dict]:
    rows = []
    try:
        for ln in path.read_text(encoding="utf-8").splitlines():
            if not ln.strip():
                continue
            try:
                rows.append(json.loads(ln))
            except json.JSONDecodeError:
                pass
    except OSError:
        return []
    return rows

TICKET_RE = re.compile(r"\bLPT-\d+\b")

coverage_rows = load_jsonl(coverage_path)
coverage_by_ticket: dict[str, dict] = {}
for cov in coverage_rows:
    ticket = cov.get("ticket")
    if ticket:
        coverage_by_ticket[ticket] = cov

rows = load_jsonl(health_path)
if not rows:
    raise SystemExit(0)

changed = 0
out = []
for row in rows:
    row = dict(row)
    tail = row.get("tail") or ""
    ticket = row.get("ticket")
    result = row.get("result")
    stamp = row.get("stamp") or ""

    # Pull LPT-NN out of closeout prose when ticket was never attributed
    # (coverage +0530 parse miss left stamp rows with null ticket).
    prose_ticket = None
    if not ticket and tail:
        m = TICKET_RE.search(tail)
        if m is not None:
            prose_ticket = m.group(0)

    # Fill empty / false-stall stamp rows from coverage in the run window.
    # Pad the end so a ticket closed after SIGTERM / stall-kill + reconcile
    # still matches (LPT-134 exit 143, LPT-240 exit 13 then closed).
    # Prefer coverage closest to the recorded run end (start+seconds), not
    # the latest row in the padded window — overlapping pads used to pin
    # the next ticket onto the previous stamp (LPT-490/491).
    if (
        stamp
        and stamp != "reconciled"
        and result not in ("usage-limit", "sim-not-ready")
        and (not ticket or not result or result == "stalled")
    ):
        best = best_coverage_for_stamp(row)
        if best is not None:
            was_stalled = result == "stalled"
            apply_coverage_fill(row, best, was_stalled=was_stalled)
            ticket = row["ticket"]
            result = row["result"]
            changed += 1
            tail = row["tail"]
            prose_ticket = None

    if not result and USAGE_LIMIT.search(tail):
        row["result"] = "usage-limit"
        row["tail"] = "coverage:usage-limit"
        row["tail_repaired"] = True
        changed += 1
        result = "usage-limit"
        tail = row["tail"]

    # Rewrite CLI telemetry and long agent-report prose; leave structured tails.
    structured = (
        tail.startswith("coverage:")
        or tail.startswith("healed from")
        or tail.startswith("reconciled from")
    )
    sdk_polluted = bool(tail) and not structured and SDK_STREAM.search(tail) is not None
    prose_report = (
        bool(tail)
        and bool(ticket or result or prose_ticket)
        and not structured
        and (
            TELEMETRY.search(tail) is not None
            or "**" in tail
            or len(tail) > 120
            or "Functions deploy:" in tail
            or "Leads:" in tail
            or sdk_polluted
            or prose_ticket is not None
        )
    )
    if prose_report:
        use_ticket = ticket or prose_ticket
        cov = coverage_by_ticket.get(use_ticket or "") or {}
        surface = cov.get("surface")
        use_result = result or cov.get("result")
        use_ticket = use_ticket or cov.get("ticket")
        if use_ticket and not ticket:
            row["ticket"] = use_ticket
            ticket = use_ticket
            changed += 1
        if use_result and not result:
            row["result"] = use_result
            result = use_result
            changed += 1
        parts = []
        if use_result:
            parts.append(f"coverage:{use_result}")
        if use_ticket:
            parts.append(f"ticket:{use_ticket}")
        if surface:
            parts.append(f"surface:{surface}")
        if parts:
            new_tail = " ".join(parts)
            if new_tail != tail:
                row["tail"] = new_tail
                row["tail_repaired"] = True
                changed += 1
                tail = new_tail
                structured = True
    if sdk_polluted and not structured:
        cleaned = scrub_sdk_stream(tail)[:400]
        if not cleaned:
            exit_code = row.get("exit")
            cleaned = f"exit:{exit_code}" if exit_code is not None else "sdk-stream"
        if cleaned != tail:
            row["tail"] = cleaned
            row["tail_repaired"] = True
            changed += 1
    out.append(row)

# Resolve duplicate durable tickets across real stamps: keep the stamp whose
# run end is closest to that ticket's coverage time; re-fill the others
# (LPT-491 twice left LPT-490 as reconciled-only).
from collections import defaultdict

by_ticket = defaultdict(list)
for i, row in enumerate(out):
    t = row.get("ticket")
    st = row.get("stamp")
    if (
        t
        and st not in (None, "", "reconciled")
        and row.get("result") not in (None, "stalled", "sim-not-ready")
    ):
        by_ticket[t].append(i)

dup_reassigned = 0
for ticket, idxs in by_ticket.items():
    if len(idxs) < 2:
        continue
    cov = coverage_by_ticket.get(ticket) or {}
    cov_ts = _parse_iso_epoch(cov.get("at"))
    if cov_ts is None:
        continue
    scored = []
    for i in idxs:
        _start, run_end, _end = stamp_run_window(out[i])
        if run_end is None:
            continue
        scored.append((abs(run_end - cov_ts), i))
    if len(scored) < 2:
        continue
    scored.sort()
    for _delta, i in scored[1:]:
        row = dict(out[i])
        was_stalled = row.get("result") == "stalled"
        best = best_coverage_for_stamp(row, exclude_tickets={ticket})
        if best is not None:
            apply_coverage_fill(row, best, was_stalled=was_stalled)
        else:
            row["ticket"] = None
            row["result"] = None
            row["tail"] = ""
            row["tail_repaired"] = True
        row["dup_reattributed"] = True
        out[i] = row
        changed += 1
        dup_reassigned += 1

# Drop stamp=reconciled rows when a real stamp already has the same ticket
# with a durable result (false-stall upgrade left LPT-240 duplicated).
held = {
    r.get("ticket")
    for r in out
    if r.get("ticket")
    and r.get("stamp") not in (None, "", "reconciled")
    and r.get("result") not in (None, "stalled", "sim-not-ready")
}
deduped = []
dropped = 0
for row in out:
    if (
        row.get("stamp") == "reconciled"
        and row.get("reconciled")
        and row.get("ticket") in held
    ):
        dropped += 1
        changed += 1
        continue
    deduped.append(row)
out = deduped

if not changed:
    raise SystemExit(0)

tmp = health_path.with_suffix(health_path.suffix + ".tmp")
with tmp.open("w", encoding="utf-8") as handle:
    for row in out:
        handle.write(json.dumps(row) + "\n")
tmp.replace(health_path)
msg = f"repaired {changed} health tail(s)"
if dup_reassigned:
    msg += f" (reattributed {dup_reassigned} duplicate stamp ticket(s))"
if dropped:
    msg += f" (dropped {dropped} duplicate reconciled)"
print(msg, flush=True)
PY
}

# When the loop is killed before _one_run_finalize, run-*.health is missing
# and tickets only show up as stamp=reconciled. Rebuild proper stamp rows
# from run logs + coverage, and skip the in-flight run.
# Args: [active_stamp]
heal_stale_run_health() {
  local active_stamp="${1:-}"
  python3 - "$HEALTH_FILE" "$COVERAGE_FILE" "$LOG_DIR" "$active_stamp" <<'PY' || true
import json, re, sys
from datetime import datetime
from pathlib import Path

health_path, coverage_path, log_dir = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
active = (sys.argv[4] or "").strip()
stamp_re = re.compile(r"run-(\d{8}-\d{6})\.log$")

def _parse_iso_epoch(value):
    """Epoch seconds; accept Z and compact ±HHMM (macOS Python 3.9)."""
    if not value:
        return None
    text = str(value).strip()
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    else:
        m = re.search(r"([+-])(\d{2})(\d{2})$", text)
        if m is not None:
            text = text[: m.start()] + f"{m.group(1)}{m.group(2)}:{m.group(3)}"
    try:
        return datetime.fromisoformat(text).timestamp()
    except ValueError:
        return None

def load_jsonl(path: Path) -> list[dict]:
    rows = []
    if not path.is_file():
        return rows
    try:
        for ln in path.read_text(encoding="utf-8").splitlines():
            if not ln.strip():
                continue
            try:
                rows.append(json.loads(ln))
            except json.JSONDecodeError:
                pass
    except OSError:
        pass
    return rows

def stamp_epoch(stamp: str):
    try:
        return datetime.strptime(stamp, "%Y%m%d-%H%M%S").timestamp()
    except ValueError:
        return None

health = load_jsonl(health_path)
coverage = load_jsonl(coverage_path)
seen_stamps = {h.get("stamp") for h in health if h.get("stamp") and h.get("stamp") != "reconciled"}
seen_tickets = {
    h.get("ticket") for h in health
    if h.get("ticket") and not h.get("reconciled")
    and h.get("result") not in (None, "stalled", "sim-not-ready")
}

runs: list[tuple[str, float, Path]] = []
if log_dir.is_dir():
    for path in sorted(log_dir.glob("run-*.log")):
        m = stamp_re.search(path.name)
        if not m:
            continue
        stamp = m.group(1)
        if stamp == active:
            continue
        health_marker = log_dir / f"run-{stamp}.health"
        pids_leftover = log_dir / f"run-{stamp}.agent-pids"
        if health_marker.is_file():
            # Finalize sometimes left agent-pids behind after a kill/restart.
            if pids_leftover.is_file():
                try:
                    pids_leftover.unlink()
                except OSError:
                    pass
            continue
        if stamp in seen_stamps:
            # Marker lost; still skip duplicate stamp rows.
            health_marker.touch()
            if pids_leftover.is_file():
                try:
                    pids_leftover.unlink()
                except OSError:
                    pass
            continue
        ep = stamp_epoch(stamp)
        if ep is None:
            continue
        runs.append((stamp, ep, path))

runs.sort(key=lambda t: t[1])
healed = 0
for i, (stamp, start_ep, _run_log) in enumerate(runs):
    end_ep = runs[i + 1][1] if i + 1 < len(runs) else datetime.now().timestamp() + 1
    chosen = None
    for cov in reversed(coverage):
        at = cov.get("at")
        ticket = cov.get("ticket")
        result = cov.get("result")
        if not at or not ticket or result in (None, "sim-not-ready", "stalled"):
            continue
        if ticket in seen_tickets:
            continue
        ts = _parse_iso_epoch(at)
        if ts is None:
            continue
        if start_ep - 5 <= ts < end_ep:
            chosen = cov
            break
    marker = log_dir / f"run-{stamp}.health"
    if chosen is None:
        # Empty / no-ticket run — mark so we do not retry forever.
        marker.touch()
        continue
    ticket = chosen.get("ticket")
    result = chosen.get("result")
    try:
        cov_ts = _parse_iso_epoch(chosen.get("at"))
        seconds = max(0, int(cov_ts - start_ep)) if cov_ts is not None else None
    except (TypeError, ValueError):
        seconds = None
    row = {
        "at": chosen.get("at") or datetime.now().astimezone().isoformat(timespec="seconds"),
        "stamp": stamp,
        "exit": 0 if result == "closed" else -1,
        "seconds": seconds,
        "ticket": ticket,
        "result": result,
        "tail": f"healed from coverage surface={chosen.get('surface')}",
        "healed": True,
    }
    health_path.parent.mkdir(parents=True, exist_ok=True)
    with health_path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(row) + "\n")
    marker.touch()
    pids_path = log_dir / f"run-{stamp}.agent-pids"
    if pids_path.is_file():
        try:
            pids_path.unlink()
        except OSError:
            pass
    seen_tickets.add(ticket)
    seen_stamps.add(stamp)
    healed += 1
if healed:
    print(f"healed {healed} health row(s) from run logs", flush=True)
PY
}

# Poll coverage for a row written at/after start_epoch (agent often lands
# coverage moments after script(1) exits).
# Args: start_epoch [timeout_seconds]
wait_for_coverage_after() {
  local start_epoch="$1" timeout="${2:-90}"
  python3 - "$COVERAGE_FILE" "$start_epoch" "$timeout" <<'PY' || true
import json, re, sys, time
from datetime import datetime
from pathlib import Path

path, start_epoch, timeout = Path(sys.argv[1]), float(sys.argv[2]), int(sys.argv[3])
deadline = time.time() + max(0, timeout)

def _parse_iso_epoch(value):
    """Epoch seconds; accept Z and compact ±HHMM (macOS Python 3.9)."""
    if not value:
        return None
    text = str(value).strip()
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    else:
        m = re.search(r"([+-])(\d{2})(\d{2})$", text)
        if m is not None:
            text = text[: m.start()] + f"{m.group(1)}{m.group(2)}:{m.group(3)}"
    try:
        return datetime.fromisoformat(text).timestamp()
    except ValueError:
        return None

def found() -> bool:
    if not path.is_file():
        return False
    try:
        rows = []
        for ln in path.read_text(encoding="utf-8").splitlines():
            if not ln.strip():
                continue
            try:
                rows.append(json.loads(ln))
            except json.JSONDecodeError:
                pass
    except OSError:
        return False
    for cov in reversed(rows):
        at = cov.get("at")
        if not at or not cov.get("ticket"):
            continue
        if cov.get("result") in (None, "sim-not-ready", "stalled"):
            continue
        ts = _parse_iso_epoch(at)
        if ts is None:
            continue
        if ts + 5 >= start_epoch:
            return True
    return False

while time.time() < deadline:
    if found():
        raise SystemExit(0)
    time.sleep(2)
PY
}

# Write one health.jsonl row. Prefer coverage lines at/after start_epoch so a
# prior closed ticket is not attributed to a failed/empty run.
# Args: stamp code seconds run_log [start_epoch]
write_health_row() {
  local stamp="$1" code="$2" seconds="$3" run_log="$4" start_epoch="${5:-0}"
  python3 - "$HEALTH_FILE" "$stamp" "$code" "$seconds" "$run_log" \
    "$COVERAGE_FILE" "$start_epoch" <<'PY' || true
import json, re, sys
from datetime import datetime
from pathlib import Path

path, stamp, code, seconds, log, coverage, start_epoch = sys.argv[1:]
start_epoch = int(float(start_epoch or "0"))

def _parse_iso_epoch(value):
    """Epoch seconds; accept Z and compact ±HHMM (macOS Python 3.9)."""
    if not value:
        return None
    text = str(value).strip()
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    else:
        m = re.search(r"([+-])(\d{2})(\d{2})$", text)
        if m is not None:
            text = text[: m.start()] + f"{m.group(1)}{m.group(2)}:{m.group(3)}"
    try:
        return datetime.fromisoformat(text).timestamp()
    except ValueError:
        return None

NOISE = re.compile(
    r"("
    r"Connection lost, reconnecting|Retry attempt |\^D|backfilled from|"
    r"Cursor Agent Debug Session|User does not belong to a team|"
    r"Loaded global commands|telemetry-only|filtered out for missing"
    r")",
    re.I,
)
# Machine SDK streams interleave assistant text with NDJSON markers; those
# used to land in health.jsonl tails on kill/empty coverage (exit 143).
SDK_STREAM = re.compile(
    r'\{\s*"t"\s*:\s*\d+\s*,\s*"type"\s*:\s*"(?:thinking|assistant|tool_call|status)"\s*\}'
)


def scrub_sdk_stream(text: str) -> str:
    cleaned = SDK_STREAM.sub(" ", text or "")
    return re.sub(r"\s+", " ", cleaned).strip()


tail = ""
try:
    lines = []
    for ln in Path(log).read_text(encoding="utf-8", errors="replace").splitlines():
        s = scrub_sdk_stream(ln)
        if not s or "\x04" in s or NOISE.search(s):
            continue
        if s.startswith("# "):
            continue
        if "] logger " in s or "analytics.track" in s or "structured-log" in s:
            continue
        lines.append(s)
    tail = scrub_sdk_stream(" ".join(lines[-5:]))[:400]
except OSError:
    pass

ticket = None
result = None
surface = None
try:
    cov_rows = []
    for ln in Path(coverage).read_text(encoding="utf-8").splitlines():
        if not ln.strip():
            continue
        try:
            cov_rows.append(json.loads(ln))
        except json.JSONDecodeError:
            pass
    chosen = None
    from datetime import datetime as dt
    for cov in reversed(cov_rows):
        at = cov.get("at")
        if not at:
            continue
        ts = _parse_iso_epoch(at)
        if ts is None:
            continue
        # Never attribute a prior run's coverage to this stamp.
        if start_epoch > 0 and ts + 5 < start_epoch:
            continue
        chosen = cov
        break
    if chosen:
        ticket = chosen.get("ticket")
        result = chosen.get("result")
        surface = chosen.get("surface")
except (OSError, json.JSONDecodeError, TypeError, ValueError):
    pass

USAGE_LIMIT = re.compile(
    r"ActionRequiredError|usage limit|error_code=upgrade|resource_exhausted",
    re.I,
)
log_blob = ""
try:
    log_blob = Path(log).read_text(encoding="utf-8", errors="replace")
except OSError:
    pass
if not result and USAGE_LIMIT.search(log_blob):
    result = "usage-limit"

# Prefer a short coverage summary whenever coverage landed. Agent report
# prose used to win because it also contained LPT-NN / closed, stuffing
# markdown into health.jsonl (LPT-61).
structured = (
    tail.startswith("coverage:")
    or tail.startswith("healed from")
    or tail.startswith("reconciled from")
)
if result and not structured:
    parts = [f"coverage:{result}"]
    if ticket:
        parts.append(f"ticket:{ticket}")
    if surface:
        parts.append(f"surface:{surface}")
    tail = " ".join(parts)

with open(path, "a", encoding="utf-8") as handle:
    handle.write(json.dumps({
        "at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "stamp": stamp,
        "exit": int(code),
        "seconds": int(seconds),
        "ticket": ticket,
        "result": result,
        "tail": tail,
    }) + "\n")
PY
}

# Print the last meaningful lines of a machine-SDK run log for `status`.
# Strips interleaved NDJSON stream markers so health checks are readable.
# Machine SDK often emits one token per line; those are coalesced into prose.
# Args: log_path [max_lines=10]
print_run_log_preview() {
  local log="${1:-}" max_lines="${2:-10}"
  if [[ -z "$log" || ! -s "$log" ]]; then
    return 0
  fi
  python3 - "$log" "$max_lines" <<'PY' || true
import re, sys
from pathlib import Path

log = Path(sys.argv[1])
try:
    max_lines = max(1, int(sys.argv[2]))
except ValueError:
    max_lines = 10

NOISE = re.compile(
    r"("
    r"Connection lost, reconnecting|Retry attempt |\^D|backfilled from|"
    r"Cursor Agent Debug Session|User does not belong to a team|"
    r"Loaded global commands|telemetry-only|filtered out for missing"
    r")",
    re.I,
)
SDK_STREAM = re.compile(
    r'\{\s*"t"\s*:\s*\d+\s*,\s*"type"\s*:\s*"(?:thinking|assistant|tool_call|status)"\s*\}'
)


def scrub_sdk_stream(text: str) -> str:
    cleaned = SDK_STREAM.sub(" ", text or "")
    return re.sub(r"\s+", " ", cleaned).strip()


def is_token_fragment(text: str) -> bool:
    """True when a scrubbed line looks like a single streamed token."""
    if text in {".", ",", ":", ";", "/", "-", "—", "…", "!", "?", "'", '"'}:
        return True
    # Multi-word thinking prose stays as its own line.
    if " " in text:
        return False
    return 1 <= len(text) <= 24


def repair_stream_prose(text: str) -> str:
    """Fix common SDK token splits that survive join (LPT closeout reports)."""
    repairs = (
        (r"\bL PT\b", "LPT"),
        (r"\bLPT\s*-\s*(\d+)\b", r"LPT-\1"),
        (r"\bLear nings\b", "Learnings"),
        (r"\bgro ?k ?bot\b", "grokbot"),
        (r"\bung uided\b", "unguided"),
        (r"\bKC 38\b", "KC38"),
        (r"\b(fix|feature)\s*/\s*LPT\b", r"\1/LPT"),
        (r"\blive\s*-\s*poker\s*-\s*trainer\b", "live-poker-trainer"),
        (r"\bneeds\s*-\s*human\b", "needs-human"),
        (r"\bui\s*-\s*agent\b", "ui-agent"),
    )
    for pat, repl in repairs:
        text = re.sub(pat, repl, text, flags=re.I)
    return text


def join_token_run(parts: list[str]) -> str:
    """Rejoin a contiguous token run into one prose string."""
    if not parts:
        return ""
    out: list[str] = []
    for s in parts:
        if not out:
            out.append(s)
            continue
        prev = out[-1]
        # Glue path separators and trailing punctuation; keep spaces around
        # em/en dashes so "confirmed — jumping" stays readable.
        if s in {".", ",", ":", ";", "/", "!", "?", "'", '"', "-"} or prev.endswith(
            ("/", "-")
        ):
            out[-1] = prev + s
            continue
        # Ticket digits after LPT-: "LPT-" + "410".
        if prev.endswith("-") and s.isdigit():
            out[-1] = prev + s
            continue
        # Single-letter crumbs: "L"+"PT" handled below; "gro"+"k".
        if len(s) == 1 and s.isalnum() and prev[-1:].isalnum():
            out[-1] = prev + s
            continue
        # Short acronym crumbs: "L" + "PT".
        if (
            prev.isalpha()
            and 1 <= len(prev) <= 2
            and s.isalpha()
            and s.isupper()
            and 1 <= len(s) <= 3
        ):
            out[-1] = prev + s
            continue
        # Mid-word continuations only for common suffixes
        # ("Implement"+"ing", "dens"+"ify", "Lear"+"nings").
        if (
            prev[-1:].isalpha()
            and s.isalpha()
            and s.lower()
            in {
                "ing",
                "ings",
                "nings",
                "ed",
                "er",
                "ly",
                "ify",
                "ion",
                "tion",
                "ness",
                "ment",
                "ous",
                "ive",
                "est",
                "ies",
                "ied",
            }
        ):
            out[-1] = prev + s
            continue
        out.append(s)
    joined = " ".join(out)
    joined = re.sub(r"\s+([.,:;!?])", r"\1", joined)
    joined = re.sub(r"\s+", " ", joined).strip()
    return repair_stream_prose(joined)


def soft_wrap(text: str, width: int = 80) -> list[str]:
    wrapped: list[str] = []
    while text:
        if len(text) <= width:
            wrapped.append(text)
            break
        cut = text.rfind(" ", 0, width + 1)
        if cut < width // 2:
            cut = width
        wrapped.append(text[:cut].rstrip())
        text = text[cut:].lstrip()
    return wrapped


def coalesce_token_lines(lines: list[str]) -> list[str]:
    """Join contiguous one-token runs; keep multi-word prose lines intact.

    Mixed thinking prose + assistant token streams used to skip coalescing
    when the whole sample was under 2/3 tokenish — status then printed one
    word per line again.
    """
    if not lines:
        return []
    result: list[str] = []
    run: list[str] = []

    def flush_run() -> None:
        nonlocal run
        if not run:
            return
        if len(run) >= 3:
            result.extend(soft_wrap(join_token_run(run)))
        else:
            result.extend(run)
        run = []

    for s in lines:
        if is_token_fragment(s):
            run.append(s)
            continue
        flush_run()
        result.append(s)
    flush_run()
    return result


try:
    lines = []
    for ln in log.read_text(encoding="utf-8", errors="replace").splitlines():
        s = scrub_sdk_stream(ln)
        if not s or "\x04" in s or NOISE.search(s):
            continue
        if s.startswith("# "):
            continue
        if "] logger " in s or "analytics.track" in s or "structured-log" in s:
            continue
        lines.append(s)
    for s in coalesce_token_lines(lines)[-max_lines:]:
        print(s)
except OSError:
    pass
PY
}

# Record agent/node PIDs under root_pid into a stamp file (watchdog).
# Args: root_pid pid_file
record_agent_pids() {
  local root_pid="$1" pid_file="$2"
  python3 - "$root_pid" "$pid_file" <<'PY' || true
import os, subprocess, sys
from pathlib import Path

root, path = sys.argv[1], Path(sys.argv[2])
if not root.isdigit():
    raise SystemExit(0)
try:
    os.kill(int(root), 0)
except OSError:
    raise SystemExit(0)
try:
    out = subprocess.check_output(
        ["ps", "-ax", "-o", "pid=,ppid=,command="], text=True
    )
except (OSError, subprocess.CalledProcessError):
    raise SystemExit(0)
children: dict[str, list[str]] = {}
cmds: dict[str, str] = {}
for line in out.splitlines():
    parts = line.strip().split(None, 2)
    if len(parts) < 3:
        continue
    pid_s, ppid_s, cmd = parts
    children.setdefault(ppid_s, []).append(pid_s)
    cmds[pid_s] = cmd
stack = [root]
seen: set[str] = set()
found: set[str] = set()
while stack:
    cur = stack.pop()
    if cur in seen:
        continue
    seen.add(cur)
    for child in children.get(cur, []):
        stack.append(child)
        low = cmds.get(child, "").lower()
        if "ui_design_agent_loop" in low:
            continue
        if "agent" in low or low.rstrip().endswith("node") or "/node " in f" {low} ":
            found.add(child)
prior: set[str] = set()
if path.is_file():
    prior = {ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip().isdigit()}
merged = sorted(prior | found, key=int)
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text("\n".join(merged) + ("\n" if merged else ""), encoding="utf-8")
PY
}

# After script(1) exits, the node agent may still be alive (TTY disconnect
# reparents children). Wait only on PIDs recorded for this stamp.
# Args: pid_file deadline_epoch
wait_lingering_agent() {
  local pid_file="$1" deadline="$2"
  python3 - "$pid_file" "$deadline" <<'PY' || true
import os, sys, time
from pathlib import Path

path, deadline = Path(sys.argv[1]), int(sys.argv[2])
if not path.is_file():
    raise SystemExit(0)

def alive(pid: str) -> bool:
    try:
        os.kill(int(pid), 0)
        return True
    except (OSError, ValueError):
        return False

tracked = {ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip().isdigit()}
if not tracked:
    raise SystemExit(0)

while time.time() < deadline:
    live = {p for p in tracked if alive(p)}
    if not live:
        break
    time.sleep(5)
PY
}

# Refresh (or hot-restart) origin/main and wait for a Dart VM. Caller must
# hold SIM_LOCK_RUN_ID. Returns 0 when ready.
# Set UI_AGENT_SKIP_SIM_PREFLIGHT=1 in unit tests to skip the real device.
ensure_sim_ready() {
  if [[ "${UI_AGENT_SKIP_SIM_PREFLIGHT:-}" == "1" ]]; then
    return 0
  fi
  local attempt
  for attempt in 1 2; do
    log "preflight refresh attempt $attempt (programmatic; no agent yet)"
    # We already hold the lock as ui-design-agent; allow refresh without
    # reclaiming as refresh-simulator (see refresh-simulator.sh).
    if ! REFRESH_ALLOW_HOLDER=1 bash "$REFRESH_SCRIPT"; then
      log "refresh-simulator exited non-zero on attempt $attempt"
    fi
    if wait_for_dart_vm; then
      log "Dart VM ready in $FLUTTER_RUN_LOG"
      return 0
    fi
    log "Dart VM not ready after attempt $attempt (${VM_WAIT_SECONDS}s)"
  done
  return 1
}

log_programmatic_sim_not_ready() {
  local stamp="$1" seconds="$2" sha="$3"
  local run_log="$LOG_DIR/run-$stamp.log"
  {
    echo "SIM_NOT_READY (programmatic preflight; agent not started)"
    echo "sha=$sha"
    echo "flutter_log=$FLUTTER_RUN_LOG"
    tail -n 20 "$FLUTTER_RUN_LOG" 2>/dev/null | sed 's/^/  /' || true
  } >"$run_log"
  python3 - "$COVERAGE_FILE" "$sha" <<'PY'
import json, sys
from datetime import datetime
path, sha = sys.argv[1], sys.argv[2]
path_p = __import__("pathlib").Path(path)
path_p.parent.mkdir(parents=True, exist_ok=True)
with path_p.open("a", encoding="utf-8") as handle:
    handle.write(json.dumps({
        "at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "sha": sha,
        "surface": "none",
        "result": "sim-not-ready",
        "ticket": None,
        "leads": ["programmatic preflight: Dart VM never appeared after two refreshes"],
        "learnings": "unchanged",
    }) + "\n")
PY
  write_health_row "$stamp" "12" "$seconds" "$run_log" 0
}

# One run. Returns 0 after an agent run, 10 when the mini was busy, 11 when
# not logged in, 12 when the Dart VM never came up (agent not started),
# 13 when the agent was killed for a stalled lock heartbeat.
one_run() {
  sync_primary
  if ! logged_in; then
    log "Cursor CLI has no API key and no login. Run: $SCRIPT setup"
    return 11
  fi
  if ! sim_lock status >/dev/null 2>&1; then
    log "iPhone 13 mini is busy; skipping this run"
    sim_lock status 2>&1 | sed 's/^/    /' || true
    return 10
  fi

  local stamp run_log pid watchdog code start line text run_id sha
  local agent_pids_file
  local args=()
  stamp="$(date '+%Y%m%d-%H%M%S')"
  run_log="$LOG_DIR/run-$stamp.log"
  agent_pids_file="$LOG_DIR/run-$stamp.agent-pids"
  start="$(date +%s)"
  sha="$(git -C "$(primary)" rev-parse HEAD 2>/dev/null || echo unknown)"

  # Claim before any agent work so preflight and the agent share one lock.
  run_id="$(sim_lock claim --owner ui-design-agent --purpose "preflight: sim ready" --pid $$ 2>/dev/null)" || {
    log "iPhone 13 mini is busy; skipping this run"
    sim_lock status 2>&1 | sed 's/^/    /' || true
    return 10
  }
  export SIM_LOCK_RUN_ID="$run_id"
  export SIM_LOCK_PID=$$

  if [[ "${UI_AGENT_SKIP_SIM_PREFLIGHT:-}" != "1" ]]; then
    python3 "$TOOLS/disk_guard.py" --quiet 2>&1 | while IFS= read -r line; do log "$line"; done || true
  fi

  if ! ensure_sim_ready; then
    log "SIM_NOT_READY after programmatic preflight; not starting agent"
    log_programmatic_sim_not_ready "$stamp" "$(( $(date +%s) - start ))" "$sha"
    sim_lock release --run-id "$run_id" >/dev/null 2>&1 || true
    unset SIM_LOCK_RUN_ID SIM_LOCK_PID
    log "run $stamp exited 12 after $(( ($(date +%s) - start) / 60 )) min (no agent)"
    return 12
  fi

  write_sim_handoff "$run_id"
  sim_lock heartbeat --purpose "agent starting" >/dev/null 2>&1 || true
  configure_agent_credentials
  reload_prompt_from_disk
  text="$(prompt)"

  _model="$(resolved_agent_model)"
  log "run $stamp starting agent (launcher=$LAUNCHER runtime=$SDK_RUNTIME model=${_model}; log $run_log; lock $run_id)"
  unset _model
  # Heal gaps from prior runs that died before write_health_row.
  heal_stale_run_health "$stamp"
  # Repair before reconcile so a false-stall stamp upgraded from coverage
  # is already seen and does not spawn a duplicate stamp=reconciled row.
  repair_health_tails
  reconcile_health_from_coverage
  if [[ "$LAUNCHER" == "sdk" ]]; then
    if ! ensure_sdk_deps; then
      log "SDK deps unavailable; not starting agent"
      sim_lock release --run-id "$run_id" >/dev/null 2>&1 || true
      unset SIM_LOCK_RUN_ID SIM_LOCK_PID
      return 11
    fi
    (
      cd "$(primary)"
      export SIM_LOCK_RUN_ID SIM_LOCK_PID CURSOR_API_KEY
      export ATLASSIAN_EMAIL ATLASSIAN_API_TOKEN FIREBASE_TOKEN
      exec node "$SDK_RUN" \
        --cwd "$(primary)" \
        --model "$(sdk_model_id)" \
        --runtime "$SDK_RUNTIME" \
        --machine "$MACHINE_NAME" \
        --log "$run_log" \
        --meta "$LOG_DIR/run-$stamp.sdk.json" \
        -- "$text"
    ) >>"$run_log" 2>&1 &
  else
    while IFS= read -r line; do args+=("$line"); done < <(agent_args)
    # script(1) gives the CLI a terminal and flushes the log, so a run can be
    # tailed while it works and a crash still leaves output on disk.
    if command -v script >/dev/null 2>&1; then
      (
        cd "$(primary)"
        export SIM_LOCK_RUN_ID SIM_LOCK_PID
        exec bash -c 'exec script -q -F "$1" agent "${@:2}"' _ \
          "$run_log" "${args[@]}" "$text"
      ) &
    else
      (
        cd "$(primary)"
        export SIM_LOCK_RUN_ID SIM_LOCK_PID
        exec agent "${args[@]}" "$text"
      ) >"$run_log" 2>&1 &
    fi
  fi
  pid=$!
  echo "$pid" >"$PID_FILE"
  : >"$agent_pids_file"
  # Early snapshot so a fast TTY disconnect still has PIDs to wait on.
  sleep 2
  record_agent_pids "$pid" "$agent_pids_file"
  (
    deadline=$(( $(date +%s) + MAX_RUN ))
    while kill -0 "$pid" 2>/dev/null; do
      if (( $(date +%s) >= deadline )); then
        log "MAX_RUN ${MAX_RUN}s exceeded; killing agent pid $pid"
        kill -TERM "$pid" 2>/dev/null || true
        sleep 5
        kill -KILL "$pid" 2>/dev/null || true
        break
      fi
      if lock_heartbeat_stalled "$run_log"; then
        # Marker before kill so wait-return cannot race past it.
        echo 1 >"$LOG_DIR/run-$stamp.stalled"
        log "agent stalled (lock heartbeat > ${STALL_SECONDS}s); killing pid $pid"
        kill -TERM "$pid" 2>/dev/null || true
        sleep 5
        kill -KILL "$pid" 2>/dev/null || true
        break
      fi
      record_agent_pids "$pid" "$agent_pids_file"
      # Mid-run: quiet refresh (no pane spam when session bytes grow).
      backfill_run_log_from_session "$run_log" "$start" "$pid" 1
      sleep 30
    done
  ) &
  watchdog=$!

  # If the loop is killed mid-run, still land health/coverage before exit.
  # shellcheck disable=SC2329
  _one_run_finalize() {
    local marker="$LOG_DIR/run-$stamp.health"
    [[ -f "$marker" ]] && return 0
    if [[ -f "$run_log" ]]; then
      python3 - "$run_log" <<'PY' || true
import sys
from pathlib import Path
path = Path(sys.argv[1])
try:
    text = path.read_text(encoding="utf-8", errors="replace")
except OSError:
    raise SystemExit(0)
cleaned = text.replace("\x04", "")
if cleaned != text:
    path.write_text(cleaned, encoding="utf-8")
PY
    fi
    backfill_run_log_from_session "$run_log" "$start" "${pid:-}"
    # Coverage is often flushed after script(1) returns; wait briefly.
    wait_for_coverage_after "$start" "${UI_AGENT_COVERAGE_WAIT:-90}"
    write_health_row "$stamp" "${code:-1}" "$(( $(date +%s) - start ))" "$run_log" "$start"
    repair_health_tails
    reconcile_health_from_coverage
    touch "$marker"
    rm -f "$agent_pids_file"
  }
  # shellcheck disable=SC2064
  trap '_one_run_finalize; sim_lock release --run-id "'"$run_id"'" >/dev/null 2>&1 || true' EXIT

  code=0
  wait "$pid" || code=$?
  # Final PID snapshot before script tree disappears, then wait for node.
  record_agent_pids "$pid" "$agent_pids_file"
  wait_lingering_agent "$agent_pids_file" "$(( start + MAX_RUN ))"
  kill "$watchdog" 2>/dev/null || true
  wait "$watchdog" 2>/dev/null || true
  rm -f "$PID_FILE"
  sim_lock release --run-id "$run_id" >/dev/null 2>&1 || true
  unset SIM_LOCK_RUN_ID SIM_LOCK_PID

  if [[ -f "$LOG_DIR/run-$stamp.stalled" ]]; then
    code=13
    rm -f "$LOG_DIR/run-$stamp.stalled"
    log "run $stamp marked stalled (exit 13)"
    # Coverage so the ledger records stalls even when the agent died before
    # step 10 (LPT-48 closed in Jira with no coverage line).
    python3 - "$COVERAGE_FILE" "$sha" <<'PY' || true
import json, sys
from datetime import datetime
from pathlib import Path
path, sha = sys.argv[1], sys.argv[2]
Path(path).parent.mkdir(parents=True, exist_ok=True)
with Path(path).open("a", encoding="utf-8") as handle:
    handle.write(json.dumps({
        "at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "sha": sha,
        "surface": "none",
        "result": "stalled",
        "ticket": None,
        "leads": ["loop stall watchdog: stale heartbeat and no worktree flutter/agent activity"],
        "learnings": "unchanged",
    }) + "\n")
PY
  elif run_log_has_usage_limit "$run_log"; then
    code=14
    log "run $stamp hit Cursor usage limit (exit 14); model was $(resolved_agent_model || echo auto)"
    python3 - "$COVERAGE_FILE" "$sha" <<'PY' || true
import json, sys
from datetime import datetime
from pathlib import Path
path, sha = sys.argv[1], sys.argv[2]
Path(path).parent.mkdir(parents=True, exist_ok=True)
with Path(path).open("a", encoding="utf-8") as handle:
    handle.write(json.dumps({
        "at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "sha": sha,
        "surface": "none",
        "result": "usage-limit",
        "ticket": None,
        "leads": [
            "Cursor usage limit (ActionRequiredError); switch UI_AGENT_MODEL "
            "or wait for the monthly cycle reset (loop sleeps until next day)"
        ],
        "learnings": "unchanged",
    }) + "\n")
PY
  fi

  log "run $stamp exited $code after $(( ($(date +%s) - start) / 60 )) min"
  tail -n 15 "$run_log" 2>/dev/null | sed 's/^/    /' || true
  _one_run_finalize
  # Restore run_loop's pid-file cleanup. `trap - EXIT` used to clear it, so
  # after the first one_run LaunchAgent ensure saw a stale/missing pid file
  # and `start` killed the live tmux session (mid-ticket) every 5 minutes.
  trap 'rm -f "$LOOP_PID_FILE"' EXIT
  find "$LOG_DIR" -name 'run-*.log' -mtime +14 -delete 2>/dev/null || true
  find "$LOG_DIR" -name 'run-*.health' -mtime +14 -delete 2>/dev/null || true
  # Reclaim disk from abandoned flutter tool scratch dirs (86%+ Data volume).
  find /tmp -maxdepth 1 -type d -name 'flutter_tools.*' -mtime +1 \
    -exec rm -rf {} + 2>/dev/null || true
  return "$code"
}

# Soft-stop means "restart with fresh code soon", not "stay down". Kick
# ensure after a short delay so we do not sit idle until LaunchAgent's
# StartInterval (300s). Override in unit tests. Use `kill`/`uninstall` to
# leave the loop down.
#
# Must survive the tmux pane exiting after `run-loop` returns (`…; exit`).
# A plain `( sleep; ensure ) &` stayed in that process group and died on
# SIGHUP, leaving the mini down until LaunchAgent or a manual ensure
# (2026-10-13 soft-stop after LPT-513).
#
# Soft-stop-ensure.log must record schedule → wake → ensure stdout → exit.
# A silent `exec ensure` left only an orphan "bridge: waiting" line when
# ensure was already-alive (exit 0, no stdout) or died before writing.
schedule_ensure_after_soft_stop() {
  mkdir -p "$LOG_DIR"
  local ensure_log="$LOG_DIR/soft-stop-ensure.log"
  local delay="${UI_AGENT_SOFT_STOP_ENSURE_SLEEP:-2}"
  {
    echo "$(date "+%Y-%m-%dT%H:%M:%S%z") ensure: scheduled (sleep ${delay}s then ensure)"
  } >>"$ensure_log"
  # nohup + disown: detach from the dying run-loop / tmux pane.
  nohup bash -c '
    script="$1"
    logf="$2"
    delay="$3"
    sleep "$delay"
    echo "$(date "+%Y-%m-%dT%H:%M:%S%z") ensure: waking after soft-stop sleep" >>"$logf"
    set +e
    bash "$script" ensure >>"$logf" 2>&1
    code=$?
    echo "$(date "+%Y-%m-%dT%H:%M:%S%z") ensure: exit=$code" >>"$logf"
    exit "$code"
  ' _ "$SCRIPT" "$ensure_log" "$delay" >/dev/null 2>&1 &
  disown $! 2>/dev/null || true
}

run_loop() {
  echo $$ >"$LOOP_PID_FILE"
  # shellcheck disable=SC2064
  trap 'rm -f "$LOOP_PID_FILE"' EXIT
  rm -f "$STOP_FILE"
  log "ui-design-agent loop started (stop: $SCRIPT stop|soft-stop)"
  local soft_stopped=0
  while [[ ! -f "$STOP_FILE" ]]; do
    local code=0
    one_run || code=$?
    if [[ -f "$STOP_FILE" ]]; then
      soft_stopped=1
      break
    fi
    case "$code" in
      10) sleep "$BUSY_SLEEP" ;;
      11) sleep 600 ;;
      12)
        log "SIM_NOT_READY preflight; sleeping ${SIM_NOT_READY_SLEEP}s before retry"
        sleep "$SIM_NOT_READY_SLEEP"
        ;;
      13)
        log "agent stalled; sleeping ${GAP}s then starting a fresh run"
        sleep "$GAP"
        ;;
      14)
        _usage_sleep="$(sleep_usage_limit_seconds "$(ls -t "$LOG_DIR"/run-*.log 2>/dev/null | head -1)")"
        log "usage limit; sleeping ${_usage_sleep}s (model=$(resolved_agent_model || echo auto))"
        sleep "$_usage_sleep"
        ;;
      *)
        if last_run_sim_not_ready; then
          log "last run was SIM_NOT_READY; sleeping ${SIM_NOT_READY_SLEEP}s before retry"
          sleep "$SIM_NOT_READY_SLEEP"
        else
          sleep "$GAP"
        fi
        ;;
    esac
  done
  # STOP_FILE during busy/gap sleep exits the while without the post-one_run
  # check — still treat that as soft-stop so ensure restarts promptly.
  if [[ -f "$STOP_FILE" ]]; then
    soft_stopped=1
  fi
  rm -f "$STOP_FILE" "$LOOP_PID_FILE"
  trap - EXIT
  log "ui-design-agent loop stopped"
  if [[ "$soft_stopped" -eq 1 ]]; then
    log "soft-stop complete; scheduling ensure (skip LaunchAgent StartInterval wait)"
    schedule_ensure_after_soft_stop
  fi
}

# A real CLI run that calls tools/jira.py: proves the API key, shell access, and Jira.
cli_jira_check() {
  local out key
  out="$(cd "$(primary)" && agent -p --force --trust --sandbox disabled --output-format text --workspace "$(primary)" \
    "Run this shell command once: python3 tools/jira.py search 'project = LPT ORDER BY created DESC' --max 1. Reply with only the issue key it prints, or NO_JIRA if it fails." 2>&1 | tail -n 5 || true)"
  key="$(grep -oE 'LPT-[0-9]+' <<<"$out" | head -1 || true)"
  if [[ -n "$key" ]]; then
    echo "cli jira: ok (latest issue $key)"
    return 0
  fi
  echo "cli jira: FAILED"
  printf '%s\n' "$out" | sed 's/^/    /'
  return 1
}

verify() {
  local failed=0
  if [[ -n "${CURSOR_API_KEY:-}" ]]; then
    echo "cursor: API key saved"
  elif logged_in; then
    echo "cursor: logged in"
  else
    echo "cursor: no API key and no login (run: $SCRIPT setup)"
    failed=1
  fi
  if ! python3 "$TOOLS/jira.py" check; then
    echo "  Use a token from id.atlassian.com/manage-profile/security/api-tokens →"
    echo "  Create API token with scopes → Jira → read:jira-work, write:jira-work, read:jira-user."
    failed=1
  fi
  if [[ "$failed" == 0 ]]; then
    cli_jira_check || failed=1
  fi
  if [[ "$failed" == 0 ]]; then
    echo "ready: $SCRIPT start"
  fi
  return "$failed"
}

prompt_secret() {
  local var="$1" label="$2" value=""
  read -r -s -p "$label${!var:+ [saved, Enter to keep]}: " value
  echo
  [[ -n "$value" ]] && printf -v "$var" '%s' "$value"
  return 0
}

setup() {
  echo "Each value is hidden as you type and saved to $SECRETS_FILE (mode 600)."
  echo
  echo "1. Cursor API key: cursor.com/dashboard → Integrations → User API Keys → New."
  prompt_secret CURSOR_API_KEY "   Cursor API key"
  echo "2. Atlassian account email (the one that signs in to livepokertrainer.atlassian.net)."
  local email=""
  read -r -p "   Email${ATLASSIAN_EMAIL:+ [$ATLASSIAN_EMAIL]}: " email
  [[ -n "$email" ]] && ATLASSIAN_EMAIL="$email"
  echo "3. Atlassian API token: id.atlassian.com/manage-profile/security/api-tokens →"
  echo "   Create API token with scopes → Jira → read:jira-work, write:jira-work, read:jira-user."
  prompt_secret ATLASSIAN_API_TOKEN "   Atlassian API token"
  (
    umask 077
    {
      printf 'CURSOR_API_KEY=%q\n' "${CURSOR_API_KEY:-}"
      printf 'ATLASSIAN_EMAIL=%q\n' "${ATLASSIAN_EMAIL:-}"
      printf 'ATLASSIAN_API_TOKEN=%q\n' "${ATLASSIAN_API_TOKEN:-}"
    } >"$SECRETS_FILE"
  )
  chmod 600 "$SECRETS_FILE"
  load_secrets
  echo
  verify
}

load_secrets

if [[ "${UI_AGENT_LOOP_SOURCE_ONLY:-}" == "1" ]]; then
  return 0 2>/dev/null || exit 0
fi

case "${1:-}" in
  start)
    if loop_is_alive; then
      echo "already running: $SCRIPT attach"
      exit 0
    fi
    # Idle leftover after stop: session exists but run-loop is gone. Kill it
    # so LaunchAgent ensure can create a fresh run-loop session.
    if lt has-session -t "=$SESSION" 2>/dev/null; then
      echo "replacing idle tmux session (run-loop not alive)"
      lt kill-session -t "=$SESSION" 2>/dev/null || true
    fi
    rm -f "$LOOP_PID_FILE" "$STOP_FILE"
    if ! prepare_launcher; then
      echo "launcher prep failed (SDK deps); not starting" >&2
      exit 1
    fi
    # A server of our own, started from this login session with a clean
    # environment: a tmux server begun from an SSH login cannot reach the
    # keychain the CLI touches at startup, even with CURSOR_API_KEY set.
    # Exit (do not exec bash) after run-loop so the session dies and ensure
    # can restart instead of attaching to an idle shell forever.
    env -i HOME="$HOME" USER="$USER" LOGNAME="$USER" PATH="$PATH" \
      LANG="${LANG:-en_US.UTF-8}" TERM="${TERM:-xterm-256color}" SHELL=/bin/zsh \
      tmux -L "$TMUX_SOCKET" new-session -d -s "$SESSION" \
      "bash '$SCRIPT' run-loop; echo 'loop exited'; exit"
    echo "started the loop (launcher=$LAUNCHER runtime=$SDK_RUNTIME model=$(resolved_agent_model); watch: $SCRIPT attach)"
    ;;
  install)
    mkdir -p "$(dirname "$PLIST")"
    cat >"$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LAUNCH_LABEL</string>
    <key>ProgramArguments</key>
  <array><string>/bin/bash</string><string>$(primary)/tools/ui_design_agent_loop.sh</string><string>ensure</string></array>
  <key>RunAtLoad</key><true/>
  <key>StartInterval</key><integer>300</integer>
  <key>AbandonProcessGroup</key><true/>
  <key>StandardOutPath</key><string>$LOG_DIR/launchd.log</string>
  <key>StandardErrorPath</key><string>$LOG_DIR/launchd.log</string>
</dict>
</plist>
EOF
    launchctl bootout "gui/$(id -u)/$LAUNCH_LABEL" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$PLIST"
    echo "installed $PLIST: starts at login, and every 5 minutes when the loop is down"
    ;;
  ensure)
    if loop_is_alive; then
      echo "ensure: already running (loop pid $(cat "$LOOP_PID_FILE" 2>/dev/null || echo '?'))"
      exit 0
    fi
    echo "ensure: starting loop"
    bash "$SCRIPT" start
    ;;
  uninstall)
    launchctl bootout "gui/$(id -u)/$LAUNCH_LABEL" 2>/dev/null || true
    rm -f "$PLIST"
    echo "removed $LAUNCH_LABEL (a running loop keeps going: $SCRIPT stop)"
    ;;
  run-loop)
    run_loop
    ;;
  once)
    one_run
    ;;
  stop|soft-stop)
    # Soft-stop: finish the current run, exit run-loop, then schedule ensure
    # so a fresh bash reloads structural loop changes. `kill`/`uninstall`
    # leave the loop down.
    touch "$STOP_FILE"
    echo "soft-stop requested: loop finishes the current run, then ensure restarts it"
    ;;
  kill)
    touch "$STOP_FILE"
    if [[ -f "$PID_FILE" ]]; then
      pid="$(cat "$PID_FILE")"
      kill -TERM "$pid" 2>/dev/null || true
      sim_lock release --if-pid "$pid" >/dev/null 2>&1 || true
    fi
    lt kill-session -t "=$SESSION" 2>/dev/null || true
    rm -f "$PID_FILE" "$STOP_FILE"
    echo "killed $SESSION"
    ;;
  status)
    active_stamp=""
    latest_for_heal="$(ls -t "$LOG_DIR"/run-*.log 2>/dev/null | head -1 || true)"
    if [[ -n "$latest_for_heal" && -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
      active_stamp="$(basename "$latest_for_heal" .log)"
      active_stamp="${active_stamp#run-}"
    fi
    heal_stale_run_health "$active_stamp"
    repair_health_tails
    reconcile_health_from_coverage
    if loop_is_alive; then
      echo "loop: running (tmux -L $TMUX_SOCKET, session $SESSION, pid $(cat "$LOOP_PID_FILE"))"
    elif lt has-session -t "=$SESSION" 2>/dev/null; then
      echo "loop: idle tmux session (run-loop dead; ensure will restart)"
    else
      echo "loop: not running"
    fi
    echo "launcher: $LAUNCHER"
    echo "sdk-runtime: $SDK_RUNTIME"
    if [[ "$SDK_RUNTIME" == "machine" ]]; then
      echo "machine: $MACHINE_NAME"
    fi
    echo "model: $(resolved_agent_model)"
    latest_meta="$(ls -t "$LOG_DIR"/run-*.sdk.json 2>/dev/null | head -1 || true)"
    if [[ -n "$latest_meta" ]]; then
      python3 - "$latest_meta" <<'PY' 2>/dev/null || true
import json, sys
from pathlib import Path
obj = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
aid = obj.get("agentId") or ""
url = obj.get("agentUrl") or (f"https://cursor.com/agents/{aid}" if str(aid).startswith("bc-") else "")
if aid:
    print(f"last sdk agent: {aid}")
if url:
    print(f"last sdk url: {url}")
PY
    fi
    if [[ -f "$PLIST" ]]; then echo "login item: installed ($LAUNCH_LABEL)"; else echo "login item: not installed ($SCRIPT install)"; fi
    if [[ -f "$STOP_FILE" ]]; then
      echo "loop: stop requested (exits after current run; next ensure → launcher=$LAUNCHER runtime=$SDK_RUNTIME model=$(resolved_agent_model))"
    fi
    if [[ -f "$PID_FILE" ]]; then echo "current run pid: $(cat "$PID_FILE")"; fi
    sim_lock status || true
    latest="$(ls -t "$LOG_DIR"/run-*.log 2>/dev/null | head -1 || true)"
    if [[ -n "$latest" ]]; then
      # Always attempt backfill; helper no-ops when the session has not grown.
      stamp_guess="$(basename "$latest" .log)"
      stamp_guess="${stamp_guess#run-}"
      start_guess="$(date -j -f '%Y%m%d-%H%M%S' "$stamp_guess" '+%s' 2>/dev/null || echo 0)"
      root_guess="$(cat "$PID_FILE" 2>/dev/null || true)"
      backfill_run_log_from_session "$latest" "$start_guess" "$root_guess"
      echo "latest log: $latest"
      if [[ -s "$latest" ]]; then
        # Machine SDK logs interleave NDJSON markers; scrub before preview.
        print_run_log_preview "$latest" 10
      else
        echo "(run log empty — Cursor CLI often writes to /tmp/cursor-agent-logs-*/)"
        sess="$(ls -t /tmp/cursor-agent-logs-*/session-*.log 2>/dev/null | head -1 || true)"
        if [[ -n "$sess" ]]; then
          echo "cursor session log: $sess"
          print_run_log_preview "$sess" 10
        fi
      fi
    else
      echo "latest log: none yet"
    fi
    if [[ -f "$HEALTH_FILE" ]]; then
      echo "last run: $(tail -n 1 "$HEALTH_FILE")"
    fi
    ;;
  attach)
    exec tmux -L "$TMUX_SOCKET" attach -t "$SESSION"
    ;;
  setup)
    setup
    ;;
  verify)
    verify
    ;;
  *)
    sed -n '2,28p' "$SCRIPT" | sed 's/^# \{0,1\}//'
    exit 2
    ;;
esac
