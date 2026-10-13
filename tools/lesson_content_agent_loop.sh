#!/usr/bin/env bash
# Run /lesson-content-agent back to back, unattended, inside tmux.
# No iPhone simulator — safe to run alongside ui_design_agent_loop.sh.
#
#   tools/lesson_content_agent_loop.sh setup|verify|start|install|ensure|
#     status|attach|stop|kill|once
#
# Auth: ~/.live-poker-trainer/secrets.env (same as ui-design-agent).
# Coverage: ~/.live-poker-trainer/content-agent-coverage.jsonl
# Logs: ~/.live-poker-trainer/content-agent-logs/
# Env: CONTENT_AGENT_GAP, CONTENT_AGENT_GATEWAY_TIMEOUT_SLEEP (default 600
#   after machine-SDK exit 15 / 504), CONTENT_AGENT_MAX_RUN_SECONDS, …
set -euo pipefail

export PATH="$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin:${PATH:-}"

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
TOOLS="$(dirname "$SCRIPT")"
SESSION="${CONTENT_AGENT_TMUX_SESSION:-lesson-content-agent}"
TMUX_SOCKET="${CONTENT_AGENT_TMUX_SOCKET:-content-agent}"
LAUNCH_LABEL="com.livepokertrainer.lesson-content-agent"
PLIST="$HOME/Library/LaunchAgents/$LAUNCH_LABEL.plist"
STATE_DIR="$HOME/.live-poker-trainer"
LOG_DIR="$STATE_DIR/content-agent-logs"
STOP_FILE="$STATE_DIR/content-agent.stop"
PID_FILE="$STATE_DIR/content-agent.pid"
LOOP_PID_FILE="$STATE_DIR/content-agent-loop.pid"
SECRETS_FILE="$STATE_DIR/secrets.env"
GAP="${CONTENT_AGENT_GAP:-60}"
MAX_RUN="${CONTENT_AGENT_MAX_RUN_SECONDS:-7200}"
USAGE_LIMIT_SLEEP="${CONTENT_AGENT_USAGE_LIMIT_SLEEP:-}"
# Seconds after machine-SDK 504 Gateway Time-out (exit 15). Match ui-agent
# default so content does not thrash 5-min failed starts every GAP second.
GATEWAY_TIMEOUT_SLEEP="${CONTENT_AGENT_GATEWAY_TIMEOUT_SLEEP:-600}"
LAUNCHER="${CONTENT_AGENT_LAUNCHER:-sdk}"
SDK_RUNTIME="${CONTENT_AGENT_SDK_RUNTIME:-machine}"
MACHINE_NAME="${CONTENT_AGENT_MACHINE_NAME:-cursor-agent-worker-4c8b3dc416}"
COVERAGE_FILE="$STATE_DIR/content-agent-coverage.jsonl"
SDK_DIR="$TOOLS/ui-agent-sdk"
SDK_RUN="$SDK_DIR/run.mjs"

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

loop_is_alive() {
  local pid=""
  if [[ -f "$LOOP_PID_FILE" ]]; then
    pid="$(cat "$LOOP_PID_FILE" 2>/dev/null || true)"
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

load_secrets() {
  if [[ -f "$SECRETS_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    . "$SECRETS_FILE"
    set +a
  fi
}

resolved_agent_model() {
  local model="${CONTENT_AGENT_MODEL:-${UI_AGENT_MODEL:-auto}}"
  if [[ -z "$model" || "$model" == "auto" || "$model" == "default" ]]; then
    echo "auto"
    return 0
  fi
  echo "$model"
}

sdk_model_id() {
  local model="${CONTENT_AGENT_MODEL:-${UI_AGENT_MODEL:-auto}}"
  if [[ -z "$model" || "$model" == "auto" || "$model" == "default" ]]; then
    echo "default"
    return 0
  fi
  echo "$model"
}

prompt() {
  local primary_dir pending=""
  primary_dir="$(primary)"
  if [[ -s "$STATE_DIR/content-agent-learnings-pending.md" ]] && grep -q '^- ' "$STATE_DIR/content-agent-learnings-pending.md" 2>/dev/null; then
    pending=" Pending learnings in $STATE_DIR/content-agent-learnings-pending.md — run tools/fold_agent_learnings.sh content, distill into lesson-content-agent-learnings.md + content-agent-run-memory.md, and ship chore/content-agent-learnings-YYYYMMDD before or after the audit."
  fi
  printf '%s' "READY: lesson content agent (audit + file only). No simulator — do not claim sim_lock, refresh-simulator, agent_tap, or agent_seed. PRIMARY: ${primary_dir}. Read .cursor/commands/lesson-content-agent.md, lesson-content-agent-learnings.md, and grep docs/agents/content-agent-run-memory.md for the target act-/lesson- id. Every run: node tools/course/scan_content_gaps.mjs --counts then sync open (catalog) parents from --gap … --markdown. Store durable loop learnings in git (learnings + run-memory chore PR) — never leave them only in the home pending file. Prefer catalog-bundled tickets; never implement product fixes. Default Jira labels content,grokbot,lesson; use content,ui-agent,lesson only when Chrome cannot validate. Use python3 tools/jira.py only.${pending} Unattended: do not ask questions."
}

ensure_sdk_deps() {
  [[ -f "$SDK_DIR/package.json" ]] || return 1
  [[ -d "$SDK_DIR/node_modules/@cursor/sdk" ]] && return 0
  log "installing @cursor/sdk into $SDK_DIR"
  (cd "$SDK_DIR" && npm ci --omit=dev) || (cd "$SDK_DIR" && npm install --omit=dev)
  [[ -d "$SDK_DIR/node_modules/@cursor/sdk" ]]
}

sync_primary() {
  local dir branch
  dir="$(primary)"
  git -C "$dir" fetch -q origin main || return 0
  # Never touch a dirty tree — content-agent may be mid-edit.
  [[ -z "$(git -C "$dir" status --porcelain)" ]] || return 0
  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
  if [[ "$branch" == "main" ]]; then
    git -C "$dir" merge -q --ff-only origin/main || true
    return 0
  fi
  # Leftover learnings chore branches leave PRIMARY off tip after the agent
  # opens a PR from the primary checkout (sync used to no-op then). Return
  # to main so the next run audits against origin/main. Match every
  # cursor/chore-content-* name (nice47, lptNNNN-*, learnings-*, …) — product
  # work must not land on PRIMARY; only learnings chores do.
  case "$branch" in
    cursor/chore-content-*|chore/content-agent-learnings-*|chore/content-*)
      log "sync_primary: $branch → main (leftover learnings chore)"
      git -C "$dir" checkout -q main || return 0
      git -C "$dir" merge -q --ff-only origin/main || true
      ;;
  esac
}

logged_in() {
  [[ -n "${CURSOR_API_KEY:-}" ]] && return 0
  ! agent status 2>&1 | grep -qiE 'not logged in|keychain is locked|error'
}

run_log_has_usage_limit() {
  local run_log="$1"
  [[ -f "$run_log" ]] || return 1
  grep -qiE 'ActionRequiredError|usage limit|error_code=upgrade|resource_exhausted' "$run_log"
}

sleep_usage_limit_seconds() {
  if [[ -n "$USAGE_LIMIT_SLEEP" ]]; then
    echo "$USAGE_LIMIT_SLEEP"
    return 0
  fi
  echo 3600
}

configure_agent_credentials() {
  [[ -n "${CURSOR_API_KEY:-}" ]] || return 0
  if [[ -z "${AGENT_CLI_CREDENTIAL_STORE:-}" ]]; then
    export AGENT_CLI_CREDENTIAL_STORE=memory
  fi
  security delete-generic-password -s cursor-access-token -a cursor-user \
    >/dev/null 2>&1 || true
}

one_run() {
  sync_primary
  if ! logged_in; then
    log "Cursor CLI has no API key and no login. Run: $SCRIPT setup"
    return 11
  fi
  if ! python3 "$TOOLS/jira.py" check >/dev/null 2>&1; then
    log "Jira unavailable"
    return 12
  fi

  local stamp run_log pid code start text sha
  stamp="$(date '+%Y%m%d-%H%M%S')"
  run_log="$LOG_DIR/run-$stamp.log"
  start="$(date +%s)"
  sha="$(git -C "$(primary)" rev-parse HEAD 2>/dev/null || echo unknown)"

  configure_agent_credentials
  text="$(prompt)"
  log "run $stamp starting (launcher=$LAUNCHER model=$(resolved_agent_model); log $run_log)"

  if [[ "$LAUNCHER" == "sdk" ]]; then
    if ! ensure_sdk_deps; then
      log "SDK deps unavailable"
      return 11
    fi
    (
      cd "$(primary)"
      export CURSOR_API_KEY ATLASSIAN_EMAIL ATLASSIAN_API_TOKEN
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
    (
      cd "$(primary)"
      exec agent -p --force --trust --sandbox disabled --output-format text \
        --workspace "$(primary)" "$text"
    ) >"$run_log" 2>&1 &
  fi
  pid=$!
  echo "$pid" >"$PID_FILE"

  (
    deadline=$(( $(date +%s) + MAX_RUN ))
    while kill -0 "$pid" 2>/dev/null; do
      if (( $(date +%s) >= deadline )); then
        log "MAX_RUN exceeded; killing $pid"
        kill -TERM "$pid" 2>/dev/null || true
        sleep 5
        kill -KILL "$pid" 2>/dev/null || true
        break
      fi
      sleep 30
    done
  ) &
  local watchdog=$!

  code=0
  wait "$pid" || code=$?
  kill "$watchdog" 2>/dev/null || true
  wait "$watchdog" 2>/dev/null || true
  rm -f "$PID_FILE"

  if run_log_has_usage_limit "$run_log"; then
    code=14
    log "usage limit (exit 14)"
  fi

  log "run $stamp exited $code after $(( ($(date +%s) - start) / 60 )) min sha=$sha"
  tail -n 12 "$run_log" 2>/dev/null | sed 's/^/    /' || true
  find "$LOG_DIR" -name 'run-*.log' -mtime +14 -delete 2>/dev/null || true
  return "$code"
}

run_loop() {
  echo $$ >"$LOOP_PID_FILE"
  trap 'rm -f "$LOOP_PID_FILE"' EXIT
  rm -f "$STOP_FILE"
  log "lesson-content-agent loop started (stop: $SCRIPT stop)"
  while [[ ! -f "$STOP_FILE" ]]; do
    local code=0
    one_run || code=$?
    [[ -f "$STOP_FILE" ]] && break
    case "$code" in
      11) sleep 600 ;;
      12) sleep 300 ;;
      14)
        _s="$(sleep_usage_limit_seconds)"
        log "usage limit; sleeping ${_s}s"
        sleep "$_s"
        ;;
      15)
        log "sdk gateway timeout (exit 15); sleeping ${GATEWAY_TIMEOUT_SLEEP}s before retry"
        sleep "$GATEWAY_TIMEOUT_SLEEP"
        ;;
      *) sleep "$GAP" ;;
    esac
  done
  rm -f "$STOP_FILE" "$LOOP_PID_FILE"
  log "lesson-content-agent loop stopped"
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
    failed=1
  fi
  if [[ "$failed" == 0 ]]; then
    echo "ready: $SCRIPT start (no simulator; parallel with ui-design-agent OK)"
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
  echo "Saves to $SECRETS_FILE (mode 600). Same file as ui-design-agent."
  prompt_secret CURSOR_API_KEY "   Cursor API key"
  local email=""
  read -r -p "   Atlassian email${ATLASSIAN_EMAIL:+ [$ATLASSIAN_EMAIL]}: " email
  [[ -n "$email" ]] && ATLASSIAN_EMAIL="$email"
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
  verify
}

load_secrets

if [[ "${CONTENT_AGENT_LOOP_SOURCE_ONLY:-}" == "1" ]]; then
  return 0 2>/dev/null || exit 0
fi

case "${1:-}" in
  start)
    if loop_is_alive; then
      echo "already running: $SCRIPT attach"
      exit 0
    fi
    if lt has-session -t "=$SESSION" 2>/dev/null; then
      lt kill-session -t "=$SESSION" 2>/dev/null || true
    fi
    rm -f "$LOOP_PID_FILE" "$STOP_FILE"
    if [[ "$LAUNCHER" == "sdk" ]] && ! ensure_sdk_deps; then
      echo "SDK deps failed" >&2
      exit 1
    fi
    env -i HOME="$HOME" USER="$USER" LOGNAME="$USER" PATH="$PATH" \
      LANG="${LANG:-en_US.UTF-8}" TERM="${TERM:-xterm-256color}" SHELL=/bin/zsh \
      tmux -L "$TMUX_SOCKET" new-session -d -s "$SESSION" \
      "bash '$SCRIPT' run-loop; echo 'loop exited'; exit"
    echo "started lesson-content-agent (model=$(resolved_agent_model); attach: $SCRIPT attach)"
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
  <array><string>/bin/bash</string><string>$(primary)/tools/lesson_content_agent_loop.sh</string><string>ensure</string></array>
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
    echo "installed $PLIST"
    ;;
  ensure)
    loop_is_alive && exit 0
    bash "$SCRIPT" start
    ;;
  uninstall)
    launchctl bootout "gui/$(id -u)/$LAUNCH_LABEL" 2>/dev/null || true
    rm -f "$PLIST"
    echo "removed $LAUNCH_LABEL"
    ;;
  run-loop)
    run_loop
    ;;
  once)
    one_run
    ;;
  stop)
    touch "$STOP_FILE"
    echo "loop stops after current run"
    ;;
  kill)
    touch "$STOP_FILE"
    if [[ -f "$PID_FILE" ]]; then
      kill -TERM "$(cat "$PID_FILE")" 2>/dev/null || true
    fi
    lt kill-session -t "=$SESSION" 2>/dev/null || true
    rm -f "$PID_FILE" "$STOP_FILE"
    echo "killed $SESSION"
    ;;
  status)
    if loop_is_alive; then
      echo "loop: running (tmux -L $TMUX_SOCKET, session $SESSION, pid $(cat "$LOOP_PID_FILE"))"
    else
      echo "loop: not running"
    fi
    echo "model: $(resolved_agent_model)"
    echo "coverage: $COVERAGE_FILE"
    latest="$(ls -t "$LOG_DIR"/run-*.log 2>/dev/null | head -1 || true)"
    if [[ -n "$latest" ]]; then
      echo "latest log: $latest"
      tail -n 8 "$latest"
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
    sed -n '2,12p' "$SCRIPT" | sed 's/^# \{0,1\}//'
    exit 2
    ;;
esac
