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
#   tools/ui_design_agent_loop.sh stop     finish the current run, then stop
#   tools/ui_design_agent_loop.sh kill     stop now and free a lock this loop holds
#   tools/ui_design_agent_loop.sh once     one run in the foreground
#
# Each run claims the mini, brings up Flutter programmatically (refresh +
# wait for a Dart VM), and only then starts a fresh `agent -p`. If the mini
# is busy or never reaches a Dart VM, the loop skips without starting the
# agent (no agentic burn on SIM_NOT_READY). It frees the lock if a run dies
# while holding it.
#
# Runs authenticate without the macOS keychain or a browser, so they keep
# working over SSH and after a reboot. Keys live in
# ~/.live-poker-trainer/secrets.env (mode 600): CURSOR_API_KEY for the CLI,
# and ATLASSIAN_EMAIL + ATLASSIAN_API_TOKEN for tools/jira.py (Jira REST).
#
# Environment:
#   UI_AGENT_MODEL              model for `agent --model` (default: CLI default)
#   UI_AGENT_GAP                seconds between runs (default 60)
#   UI_AGENT_BUSY_SLEEP         seconds to sleep when the mini is busy (default 300)
#   UI_AGENT_SIM_NOT_READY_SLEEP  seconds after programmatic SIM_NOT_READY (default 600)
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
SESSION="ui-design-agent"
TMUX_SOCKET="ui-agent"
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
VM_WAIT_SECONDS="${UI_AGENT_VM_WAIT_SECONDS:-180}"
MAX_RUN="${UI_AGENT_MAX_RUN_SECONDS:-14400}"
STALL_SECONDS="${UI_AGENT_STALL_SECONDS:-600}"
COVERAGE_FILE="$STATE_DIR/ui-agent-coverage.jsonl"
FLUTTER_RUN_LOG="/tmp/flutter-live-poker-trainer.run.log"
REFRESH_SCRIPT="$(cd "$TOOLS/.." && pwd)/.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh"

mkdir -p "$LOG_DIR"

primary() {
  bash "$TOOLS/primary_checkout.sh"
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

lt() {
  tmux -L "$TMUX_SOCKET" "$@"
}

# True only while run-loop is alive. A leftover tmux session after stop
# (idle shell) must not count — LaunchAgent ensure used to no-op forever.
loop_is_alive() {
  local pid=""
  [[ -f "$LOOP_PID_FILE" ]] || return 1
  pid="$(cat "$LOOP_PID_FILE" 2>/dev/null || true)"
  [[ -n "$pid" ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

prompt() {
  printf '%s' "Run the /ui-design-agent command: read .cursor/commands/ui-design-agent.md and .cursor/commands/ui-design-agent-learnings.md in this workspace and follow them exactly, from step 0. The loop already claimed the iPhone 13 mini (SIM_LOCK_RUN_ID is set — keep it; do not claim again) and the Dart VM is up on origin/main; start from step 2 (contract). Update the learnings file in step 10 when this run hits a durable mistake. This is an unattended run. Do not ask questions or wait for input."
}

load_secrets() {
  if [[ -f "$SECRETS_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    . "$SECRETS_FILE"
    set +a
  fi
}

agent_args() {
  local args=(-p --force --trust --sandbox disabled --output-format text --workspace "$(primary)")
  if [[ -n "${UI_AGENT_MODEL:-}" ]]; then
    args+=(--model "$UI_AGENT_MODEL")
  fi
  printf '%s\n' "${args[@]}"
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

# True when the Flutter run log already has a Dart VM service URI.
dart_vm_ready() {
  # macOS/BSD grep rejects [A-Za-z0-9_\-=] (invalid range). Keep '-' last.
  # -a: treat Flutter logs as text even if they contain NULs later.
  [[ -f "$FLUTTER_RUN_LOG" ]] || return 1
  grep -aqE 'http://127\.0\.0\.1:[0-9]+/[A-Za-z0-9_=-]+/' "$FLUTTER_RUN_LOG" 2>/dev/null
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
lock_heartbeat_stalled() {
  local agent_pid=""
  [[ -f "$PID_FILE" ]] && agent_pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  python3 - "$STALL_SECONDS" "${agent_pid:-}" <<'PY'
import json, os, subprocess, sys, time
from pathlib import Path

stall = int(sys.argv[1])
agent_pid = sys.argv[2].strip()
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
for base in (Path("/tmp"), Path("/private/tmp")):
    if not base.is_dir():
        continue
    for sess in base.glob("cursor-agent-logs-*/session-*.log"):
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
SIGNAL = re.compile(
    r"\b(LPT-\d+|SIM_NOT_READY|closed|stalled|needs-human|coverage:)\b",
    re.I,
)

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

coverage_by_ticket: dict[str, dict] = {}
for cov in load_jsonl(coverage_path):
    ticket = cov.get("ticket")
    if ticket:
        coverage_by_ticket[ticket] = cov

rows = load_jsonl(health_path)
if not rows:
    raise SystemExit(0)

changed = 0
out = []
for row in rows:
    tail = row.get("tail") or ""
    ticket = row.get("ticket")
    result = row.get("result")
    # Only rewrite pure CLI telemetry; leave coverage:/healed/reconciled tails.
    needs = (
        bool(tail)
        and bool(ticket or result)
        and TELEMETRY.search(tail) is not None
        and SIGNAL.search(tail) is None
        and not tail.startswith("coverage:")
        and not tail.startswith("healed from")
        and not tail.startswith("reconciled from")
    )
    if needs:
        cov = coverage_by_ticket.get(ticket or "") or {}
        surface = cov.get("surface")
        parts = []
        if result:
            parts.append(f"coverage:{result}")
        if ticket:
            parts.append(f"ticket:{ticket}")
        if surface:
            parts.append(f"surface:{surface}")
        if parts:
            new_tail = " ".join(parts)
            if new_tail != tail:
                row = dict(row)
                row["tail"] = new_tail
                row["tail_repaired"] = True
                changed += 1
    out.append(row)

if not changed:
    raise SystemExit(0)

tmp = health_path.with_suffix(health_path.suffix + ".tmp")
with tmp.open("w", encoding="utf-8") as handle:
    for row in out:
        handle.write(json.dumps(row) + "\n")
tmp.replace(health_path)
print(f"repaired {changed} health tail(s)", flush=True)
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
        try:
            ts = datetime.fromisoformat(at).timestamp()
        except ValueError:
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
        seconds = max(0, int(datetime.fromisoformat(chosen["at"]).timestamp() - start_ep))
    except (KeyError, ValueError, TypeError):
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
import json, sys, time
from datetime import datetime
from pathlib import Path

path, start_epoch, timeout = Path(sys.argv[1]), float(sys.argv[2]), int(sys.argv[3])
deadline = time.time() + max(0, timeout)

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
        try:
            ts = datetime.fromisoformat(at).timestamp()
        except ValueError:
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
NOISE = re.compile(
    r"("
    r"Connection lost, reconnecting|Retry attempt |\^D|backfilled from|"
    r"Cursor Agent Debug Session|User does not belong to a team|"
    r"Loaded global commands|telemetry-only|filtered out for missing"
    r")",
    re.I,
)
SIGNAL = re.compile(
    r"\b(LPT-\d+|SIM_NOT_READY|closed|stalled|needs-human|Lock|step\s*\d+)\b",
    re.I,
)

tail = ""
try:
    lines = []
    for ln in Path(log).read_text(encoding="utf-8", errors="replace").splitlines():
        s = ln.strip()
        if not s or "\x04" in s or NOISE.search(s):
            continue
        if s.startswith("# "):
            continue
        if "] logger " in s or "analytics.track" in s or "structured-log" in s:
            continue
        lines.append(s)
    tail = " ".join(lines[-5:])[:400]
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
        try:
            ts = dt.fromisoformat(at).timestamp()
        except ValueError:
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

# CLI session backfills are usually telemetry-only; prefer coverage summary.
if result and (not tail or not SIGNAL.search(tail)):
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
    if ! bash "$REFRESH_SCRIPT"; then
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

  if ! ensure_sim_ready; then
    log "SIM_NOT_READY after programmatic preflight; not starting agent"
    log_programmatic_sim_not_ready "$stamp" "$(( $(date +%s) - start ))" "$sha"
    sim_lock release --run-id "$run_id" >/dev/null 2>&1 || true
    unset SIM_LOCK_RUN_ID SIM_LOCK_PID
    log "run $stamp exited 12 after $(( ($(date +%s) - start) / 60 )) min (no agent)"
    return 12
  fi

  sim_lock heartbeat --purpose "agent starting" >/dev/null 2>&1 || true
  configure_agent_credentials
  while IFS= read -r line; do args+=("$line"); done < <(agent_args)
  text="$(prompt)"

  log "run $stamp starting agent (log $run_log; lock $run_id)"
  # Heal gaps from prior runs that died before write_health_row.
  heal_stale_run_health "$stamp"
  reconcile_health_from_coverage
  repair_health_tails
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
      exec agent "$@"
    ) >"$run_log" 2>&1 &
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
      if lock_heartbeat_stalled; then
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
  fi

  log "run $stamp exited $code after $(( ($(date +%s) - start) / 60 )) min"
  tail -n 15 "$run_log" 2>/dev/null | sed 's/^/    /' || true
  _one_run_finalize
  trap - EXIT
  find "$LOG_DIR" -name 'run-*.log' -mtime +14 -delete 2>/dev/null || true
  find "$LOG_DIR" -name 'run-*.health' -mtime +14 -delete 2>/dev/null || true
  return "$code"
}

run_loop() {
  echo $$ >"$LOOP_PID_FILE"
  # shellcheck disable=SC2064
  trap 'rm -f "$LOOP_PID_FILE"' EXIT
  rm -f "$STOP_FILE"
  log "ui-design-agent loop started (stop: $SCRIPT stop)"
  while [[ ! -f "$STOP_FILE" ]]; do
    local code=0
    one_run || code=$?
    [[ -f "$STOP_FILE" ]] && break
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
  rm -f "$STOP_FILE" "$LOOP_PID_FILE"
  trap - EXIT
  log "ui-design-agent loop stopped"
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
    rm -f "$LOOP_PID_FILE"
    # A server of our own, started from this login session with a clean
    # environment: a tmux server begun from an SSH login cannot reach the
    # keychain the CLI touches at startup, even with CURSOR_API_KEY set.
    # Exit (do not exec bash) after run-loop so the session dies and ensure
    # can restart instead of attaching to an idle shell forever.
    env -i HOME="$HOME" USER="$USER" LOGNAME="$USER" PATH="$PATH" \
      LANG="${LANG:-en_US.UTF-8}" TERM="${TERM:-xterm-256color}" SHELL=/bin/zsh \
      tmux -L "$TMUX_SOCKET" new-session -d -s "$SESSION" \
      "bash '$SCRIPT' run-loop; echo 'loop exited'; exit"
    echo "started the loop (watch: $SCRIPT attach)"
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
      exit 0
    fi
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
  stop)
    touch "$STOP_FILE"
    echo "the loop stops after the current run"
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
    reconcile_health_from_coverage
    repair_health_tails
    if loop_is_alive; then
      echo "loop: running (tmux -L $TMUX_SOCKET, session $SESSION, pid $(cat "$LOOP_PID_FILE"))"
    elif lt has-session -t "=$SESSION" 2>/dev/null; then
      echo "loop: idle tmux session (run-loop dead; ensure will restart)"
    else
      echo "loop: not running"
    fi
    if [[ -f "$PLIST" ]]; then echo "login item: installed ($LAUNCH_LABEL)"; else echo "login item: not installed ($SCRIPT install)"; fi
    if [[ -f "$STOP_FILE" ]]; then echo "loop: stop requested"; fi
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
        tail -n 10 "$latest"
      else
        echo "(run log empty — Cursor CLI often writes to /tmp/cursor-agent-logs-*/)"
        sess="$(ls -t /tmp/cursor-agent-logs-*/session-*.log 2>/dev/null | head -1 || true)"
        if [[ -n "$sess" ]]; then
          echo "cursor session log: $sess"
          tail -n 10 "$sess"
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
