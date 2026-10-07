#!/usr/bin/env bash
# Run /ui-design-agent back to back, unattended, inside tmux.
#
#   tools/ui_design_agent_loop.sh setup    one-time: log in to Cursor and Jira
#   tools/ui_design_agent_loop.sh start    start the loop in tmux session ui-design-agent
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
# Environment:
#   UI_AGENT_MODEL              model for `agent --model` (default: CLI default)
#   UI_AGENT_GAP                seconds between runs (default 60)
#   UI_AGENT_BUSY_SLEEP         seconds to sleep when the mini is busy (default 300)
#   UI_AGENT_MAX_RUN_SECONDS    hard cap per run (default 14400)
#   UI_AGENT_PLUGIN_DIRS        colon-separated plugin dirs (default: newest Atlassian plugin)
set -euo pipefail

export PATH="$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin:${PATH:-}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
SESSION="ui-design-agent"
STATE_DIR="$HOME/.live-poker-trainer"
LOG_DIR="$STATE_DIR/ui-agent-logs"
STOP_FILE="$STATE_DIR/ui-agent.stop"
PID_FILE="$STATE_DIR/ui-agent.pid"
GAP="${UI_AGENT_GAP:-60}"
BUSY_SLEEP="${UI_AGENT_BUSY_SLEEP:-300}"
MAX_RUN="${UI_AGENT_MAX_RUN_SECONDS:-14400}"
PROMPT='Run the /ui-design-agent command: read .cursor/commands/ui-design-agent.md in this workspace and follow it exactly, from step 0. This is an unattended run. Do not ask questions or wait for input.'

mkdir -p "$LOG_DIR"

primary() {
  bash "$(dirname "$SCRIPT")/primary_checkout.sh"
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

plugin_args() {
  local dirs="${UI_AGENT_PLUGIN_DIRS:-}"
  if [[ -z "$dirs" ]]; then
    dirs="$(ls -td "$HOME"/.cursor/plugins/cache/cursor-public/atlassian/*/ 2>/dev/null | head -1 || true)"
  fi
  local IFS=:
  local dir
  for dir in $dirs; do
    [[ -n "$dir" && -d "$dir" ]] && printf -- '--plugin-dir\n%s\n' "${dir%/}"
  done
}

agent_args() {
  local args=(-p --force --trust --approve-mcps --sandbox disabled --output-format text --workspace "$(primary)")
  [[ -n "${UI_AGENT_MODEL:-}" ]] && args+=(--model "$UI_AGENT_MODEL")
  printf '%s\n' "${args[@]}"
  plugin_args
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
  python3 "$(primary)/tools/sim_lock.py" "$@"
}

logged_in() {
  ! agent status 2>&1 | grep -qi 'not logged in'
}

# One run. Returns 0 after a run, 10 when the mini was busy, 11 when not logged in.
one_run() {
  sync_primary
  if ! logged_in; then
    log "Cursor CLI is not logged in. Run: $SCRIPT setup"
    return 11
  fi
  if ! sim_lock status >/dev/null 2>&1; then
    log "iPhone 13 mini is busy; skipping this run"
    sim_lock status 2>&1 | sed 's/^/    /' || true
    return 10
  fi

  local stamp run_log pid watchdog code start line
  local args=()
  stamp="$(date '+%Y%m%d-%H%M%S')"
  run_log="$LOG_DIR/run-$stamp.log"
  while IFS= read -r line; do args+=("$line"); done < <(agent_args)

  log "run $stamp starting (log $run_log)"
  start="$(date +%s)"
  (
    cd "$(primary)"
    # exec keeps this pid, so the lock's --pid is the agent itself.
    exec bash -c 'export SIM_LOCK_PID=$$; exec agent "$@"' _ "${args[@]}" "$PROMPT"
  ) >"$run_log" 2>&1 &
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

if [[ "${UI_AGENT_LOOP_SOURCE_ONLY:-}" == "1" ]]; then
  return 0 2>/dev/null || exit 0
fi

case "${1:-}" in
  start)
    if tmux has-session -t "=$SESSION" 2>/dev/null; then
      echo "already running: tmux attach -t $SESSION"
      exit 0
    fi
    tmux new-session -d -s "$SESSION" "bash '$SCRIPT' run-loop; echo 'loop exited'; exec bash"
    echo "started tmux session $SESSION (attach: tmux attach -t $SESSION)"
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
    tmux kill-session -t "=$SESSION" 2>/dev/null || true
    rm -f "$PID_FILE" "$STOP_FILE"
    echo "killed $SESSION"
    ;;
  status)
    if tmux has-session -t "=$SESSION" 2>/dev/null; then echo "loop: running (tmux $SESSION)"; else echo "loop: not running"; fi
    [[ -f "$STOP_FILE" ]] && echo "loop: stop requested"
    [[ -f "$PID_FILE" ]] && echo "current run pid: $(cat "$PID_FILE")"
    sim_lock status || true
    latest="$(ls -t "$LOG_DIR"/run-*.log 2>/dev/null | head -1 || true)"
    [[ -n "$latest" ]] && { echo "latest log: $latest"; tail -n 10 "$latest"; }
    ;;
  attach)
    exec tmux attach -t "$SESSION"
    ;;
  setup)
    logged_in || agent login
    plugins=()
    while IFS= read -r line; do plugins+=("$line"); done < <(plugin_args)
    echo "Opening an interactive agent with the Atlassian plugin. Ask it to"
    echo "call getAccessibleAtlassianResources and finish the Atlassian login,"
    echo "then exit. After that: $SCRIPT start"
    cd "$(primary)"
    exec agent --trust --approve-mcps ${plugins[@]+"${plugins[@]}"}
    ;;
  *)
    sed -n '2,21p' "$SCRIPT" | sed 's/^# \{0,1\}//'
    exit 2
    ;;
esac
