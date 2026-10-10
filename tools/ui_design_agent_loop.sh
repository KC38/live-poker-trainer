#!/usr/bin/env bash
# Run /ui-design-agent back to back, unattended, inside tmux.
#
#   tools/ui_design_agent_loop.sh setup    one-time: save the Cursor API key and Atlassian token
#   tools/ui_design_agent_loop.sh verify   check both work, including Jira from inside the CLI
#   tools/ui_design_agent_loop.sh start    start the loop (its own tmux server, socket ui-agent)
#   tools/ui_design_agent_loop.sh install  start it at login, and again every 5 minutes if it died
#   tools/ui_design_agent_loop.sh ensure   start the loop only when it is not already running
#   tools/ui_design_agent_loop.sh status   loop, simulator lock, and latest run log
#   tools/ui_design_agent_loop.sh attach   watch the loop
#   tools/ui_design_agent_loop.sh stop     finish the current run, then stop
#   tools/ui_design_agent_loop.sh kill     stop now and free a lock this loop holds
#   tools/ui_design_agent_loop.sh once     one run in the foreground
#
# Each run is a fresh `agent -p` (Cursor CLI) on the primary checkout. The
# loop skips a run without starting the agent while another agent holds the
# iPhone 13 mini, and frees the lock if a run dies while holding it.
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
#   UI_AGENT_MAX_RUN_SECONDS    hard cap per run (default 14400)
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
SECRETS_FILE="$STATE_DIR/secrets.env"
GAP="${UI_AGENT_GAP:-60}"
BUSY_SLEEP="${UI_AGENT_BUSY_SLEEP:-300}"
MAX_RUN="${UI_AGENT_MAX_RUN_SECONDS:-14400}"

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

prompt() {
  printf '%s' "Run the /ui-design-agent command: read .cursor/commands/ui-design-agent.md and .cursor/commands/ui-design-agent-learnings.md in this workspace and follow them exactly, from step 0. Update the learnings file in step 10 when this run hits a durable mistake. This is an unattended run. Do not ask questions or wait for input."
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

# One run. Returns 0 after a run, 10 when the mini was busy, 11 when not logged in.
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

  local stamp run_log pid watchdog code start line text
  local args=()
  stamp="$(date '+%Y%m%d-%H%M%S')"
  run_log="$LOG_DIR/run-$stamp.log"
  while IFS= read -r line; do args+=("$line"); done < <(agent_args)
  text="$(prompt)"

  log "run $stamp starting (log $run_log)"
  start="$(date +%s)"
  # script(1) gives the CLI a terminal and flushes the log, so a run can be
  # tailed while it works and a crash still leaves output on disk.
  if command -v script >/dev/null 2>&1; then
    (
      cd "$(primary)"
      exec bash -c 'export SIM_LOCK_PID=$$; exec script -q -F "$1" agent "${@:2}"' _ \
        "$run_log" "${args[@]}" "$text"
    ) &
  else
    (
      cd "$(primary)"
      exec bash -c 'export SIM_LOCK_PID=$$; exec agent "$@"' _ "${args[@]}" "$text"
    ) >"$run_log" 2>&1 &
  fi
  pid=$!
  echo "$pid" >"$PID_FILE"
  (
    deadline=$(( $(date +%s) + MAX_RUN ))
    while kill -0 "$pid" 2>/dev/null; do
      if (( $(date +%s) >= deadline )); then
        kill -TERM "$pid" 2>/dev/null || true
        break
      fi
      sleep 30
    done
  ) &
  watchdog=$!

  code=0
  wait "$pid" || code=$?
  kill "$watchdog" 2>/dev/null || true
  rm -f "$PID_FILE"
  sim_lock release --if-pid "$pid" >/dev/null 2>&1 || true

  log "run $stamp exited $code after $(( ($(date +%s) - start) / 60 )) min"
  tail -n 15 "$run_log" | sed 's/^/    /'
  python3 - "$HEALTH_FILE" "$stamp" "$code" "$(( $(date +%s) - start ))" "$run_log" <<'PY'
import json, sys
path, stamp, code, seconds, log = sys.argv[1:]
tail = ""
try:
    lines = open(log, encoding="utf-8", errors="replace").read().splitlines()
    tail = " ".join(lines[-5:])[:400]
except OSError:
    pass
with open(path, "a", encoding="utf-8") as handle:
    handle.write(json.dumps({
        "at": __import__("datetime").datetime.now().astimezone().isoformat(timespec="seconds"),
        "stamp": stamp, "exit": int(code), "seconds": int(seconds), "tail": tail,
    }) + "\n")
PY
  find "$LOG_DIR" -name 'run-*.log' -mtime +14 -delete 2>/dev/null || true
  return 0
}

run_loop() {
  rm -f "$STOP_FILE"
  log "ui-design-agent loop started (stop: $SCRIPT stop)"
  while [[ ! -f "$STOP_FILE" ]]; do
    local code=0
    one_run || code=$?
    [[ -f "$STOP_FILE" ]] && break
    case "$code" in
      10) sleep "$BUSY_SLEEP" ;;
      11) sleep 600 ;;
      *) sleep "$GAP" ;;
    esac
  done
  rm -f "$STOP_FILE"
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
    if lt has-session -t "=$SESSION" 2>/dev/null; then
      echo "already running: $SCRIPT attach"
      exit 0
    fi
    # A server of our own, started from this login session with a clean
    # environment: a tmux server begun from an SSH login cannot reach the
    # keychain the CLI touches at startup, even with CURSOR_API_KEY set.
    env -i HOME="$HOME" USER="$USER" LOGNAME="$USER" PATH="$PATH" \
      LANG="${LANG:-en_US.UTF-8}" TERM="${TERM:-xterm-256color}" SHELL=/bin/zsh \
      tmux -L "$TMUX_SOCKET" new-session -d -s "$SESSION" \
      "bash '$SCRIPT' run-loop; echo 'loop exited'; exec bash"
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
    if lt has-session -t "=$SESSION" 2>/dev/null; then
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
    if lt has-session -t "=$SESSION" 2>/dev/null; then echo "loop: running (tmux -L $TMUX_SOCKET, session $SESSION)"; else echo "loop: not running"; fi
    if [[ -f "$PLIST" ]]; then echo "login item: installed ($LAUNCH_LABEL)"; else echo "login item: not installed ($SCRIPT install)"; fi
    if [[ -f "$STOP_FILE" ]]; then echo "loop: stop requested"; fi
    if [[ -f "$PID_FILE" ]]; then echo "current run pid: $(cat "$PID_FILE")"; fi
    sim_lock status || true
    latest="$(ls -t "$LOG_DIR"/run-*.log 2>/dev/null | head -1 || true)"
    if [[ -n "$latest" ]]; then
      echo "latest log: $latest"
      tail -n 10 "$latest"
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
