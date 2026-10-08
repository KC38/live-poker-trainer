#!/usr/bin/env bash
# Run /ui-design-agent back to back, unattended, inside tmux.
#
#   tools/ui_design_agent_loop.sh setup    one-time: save the Cursor API key and Atlassian token
#   tools/ui_design_agent_loop.sh verify   check both work, including Jira tools inside the CLI
#   tools/ui_design_agent_loop.sh start    start the loop in tmux session ui-design-agent
#   tools/ui_design_agent_loop.sh status   loop, simulator lock, and latest run log
#   tools/ui_design_agent_loop.sh attach   watch the loop
#   tools/ui_design_agent_loop.sh stop     finish the current run, then stop
#   tools/ui_design_agent_loop.sh kill     stop now and free a lock this loop holds
#   tools/ui_design_agent_loop.sh once     one run in the foreground
#
# Each run is a fresh `agent -p` (Cursor CLI). The loop skips a run without
# starting the agent while another agent holds the iPhone 13 mini, and frees
# the lock if a run dies while holding it.
#
# Runs authenticate without the macOS keychain or a browser, so they keep
# working over SSH and after a reboot. Keys live in
# ~/.live-poker-trainer/secrets.env (mode 600): CURSOR_API_KEY for the CLI,
# and an Atlassian email + API token sent as Basic auth to the Rovo MCP server.
# The CLI only reads that server from its workspace's .cursor/mcp.json, so
# each run's workspace is a detached worktree at ~/.live-poker-trainer/runner,
# reset to origin/main, holding an mcp.json that reads the header from
# $ATLASSIAN_BASIC. The IDE never opens it. The primary checkout is added
# with --add-dir and stays where the agent makes changes.
#
# Environment:
#   UI_AGENT_MODEL              model for `agent --model` (default: CLI default)
#   UI_AGENT_GAP                seconds between runs (default 60)
#   UI_AGENT_BUSY_SLEEP         seconds to sleep when the mini is busy (default 300)
#   UI_AGENT_MAX_RUN_SECONDS    hard cap per run (default 14400)
#   UI_AGENT_PLUGIN_DIRS        extra colon-separated --plugin-dir paths (default none)
set -euo pipefail

export PATH="$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin:${PATH:-}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
SESSION="ui-design-agent"
STATE_DIR="$HOME/.live-poker-trainer"
LOG_DIR="$STATE_DIR/ui-agent-logs"
STOP_FILE="$STATE_DIR/ui-agent.stop"
PID_FILE="$STATE_DIR/ui-agent.pid"
SECRETS_FILE="$STATE_DIR/secrets.env"
RUNNER_DIR="$STATE_DIR/runner"
GAP="${UI_AGENT_GAP:-60}"
BUSY_SLEEP="${UI_AGENT_BUSY_SLEEP:-300}"
MAX_RUN="${UI_AGENT_MAX_RUN_SECONDS:-14400}"
ATLASSIAN_MCP_URL="https://mcp.atlassian.com/v2/mcp"
JIRA_CLOUD_ID="6c3dffc6-003e-49f8-a8fb-0acc800ca7e7"

mkdir -p "$LOG_DIR"

primary() {
  bash "$(dirname "$SCRIPT")/primary_checkout.sh"
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

prompt() {
  printf '%s' "Run the /ui-design-agent command: read .cursor/commands/ui-design-agent.md in this workspace and follow it exactly, from step 0. The primary checkout is $(primary); run every command from there as the command says. This is an unattended run. Do not ask questions or wait for input."
}

load_secrets() {
  if [[ -f "$SECRETS_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    . "$SECRETS_FILE"
    set +a
  fi
  if [[ -n "${ATLASSIAN_EMAIL:-}" && -n "${ATLASSIAN_API_TOKEN:-}" ]]; then
    ATLASSIAN_BASIC="$(printf '%s:%s' "$ATLASSIAN_EMAIL" "$ATLASSIAN_API_TOKEN" | base64 | tr -d '\n')"
    export ATLASSIAN_BASIC
  fi
}

main_ref() {
  local dir="$1"
  if git -C "$dir" rev-parse -q --verify origin/main >/dev/null; then
    echo origin/main
  else
    echo HEAD
  fi
}

# Detached worktree of the primary at origin/main, with the CLI's mcp.json.
ensure_runner() {
  local dir ref
  dir="$(primary)"
  ref="$(main_ref "$dir")"
  if ! git -C "$RUNNER_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    rm -rf "$RUNNER_DIR"
    git -C "$dir" worktree prune
    git -C "$dir" worktree add -q --detach "$RUNNER_DIR" "$ref"
  else
    git -C "$RUNNER_DIR" checkout -q --detach --force "$(git -C "$dir" rev-parse "$ref")"
  fi
  mkdir -p "$RUNNER_DIR/.cursor"
  # The header is read from $ATLASSIAN_BASIC at run time; no secret on disk here.
  printf '{"mcpServers": {"atlassian": {"url": "%s", "headers": {"Authorization": "Basic ${env:ATLASSIAN_BASIC}"}}}}\n' \
    "$ATLASSIAN_MCP_URL" >"$RUNNER_DIR/.cursor/mcp.json"
}

plugin_args() {
  local IFS=:
  local dir
  for dir in ${UI_AGENT_PLUGIN_DIRS:-}; do
    if [[ -n "$dir" && -d "$dir" ]]; then
      printf -- '--plugin-dir\n%s\n' "${dir%/}"
    fi
  done
}

agent_args() {
  local args=(-p --force --trust --approve-mcps --sandbox disabled --output-format text
    --workspace "$RUNNER_DIR" --add-dir "$(primary)")
  if [[ -n "${UI_AGENT_MODEL:-}" ]]; then
    args+=(--model "$UI_AGENT_MODEL")
  fi
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
  python3 "$(dirname "$SCRIPT")/sim_lock.py" "$@"
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
  ensure_runner

  local stamp run_log pid watchdog code start line text
  local args=()
  stamp="$(date '+%Y%m%d-%H%M%S')"
  run_log="$LOG_DIR/run-$stamp.log"
  while IFS= read -r line; do args+=("$line"); done < <(agent_args)
  text="$(prompt)"

  log "run $stamp starting (log $run_log)"
  start="$(date +%s)"
  (
    cd "$(primary)"
    # exec keeps this pid, so the lock's --pid is the agent itself.
    exec bash -c 'export SIM_LOCK_PID=$$; exec agent "$@"' _ "${args[@]}" "$text"
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

mcp_post() {
  local body="$1"
  shift
  curl -s --max-time 30 -X POST "$ATLASSIAN_MCP_URL" \
    -H "Authorization: Basic $ATLASSIAN_BASIC" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json, text/event-stream' \
    "$@" -d "$body"
}

# Call the Atlassian MCP with the saved token and confirm the Jira tools exist.
atlassian_check() {
  if [[ -z "${ATLASSIAN_BASIC:-}" ]]; then
    echo "atlassian: no token saved (run: $SCRIPT setup)"
    return 1
  fi
  local headers code sid tools missing="" name
  headers="$(mktemp)"
  mcp_post '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"ui-design-agent-loop","version":"1"}}}' \
    -D "$headers" -o /dev/null || true
  code="$(awk 'NR==1 {print $2}' "$headers")"
  sid="$(awk 'tolower($1) == "mcp-session-id:" {print $2}' "$headers" | tr -d '\r')"
  rm -f "$headers"
  if [[ "$code" != "200" ]]; then
    echo "atlassian: token rejected (HTTP ${code:-none}). Check the email, the token's scopes,"
    echo "  and that API-token auth for the Rovo MCP server is enabled in admin.atlassian.com."
    return 1
  fi
  local session=()
  [[ -n "$sid" ]] && session=(-H "Mcp-Session-Id: $sid")
  mcp_post '{"jsonrpc":"2.0","method":"notifications/initialized"}' ${session[@]+"${session[@]}"} -o /dev/null || true
  tools="$(mcp_post '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' ${session[@]+"${session[@]}"} || true)"
  for name in searchJiraIssuesUsingJql getJiraIssue createJiraIssue addOrEditJiraIssueComment transitionJiraIssue; do
    grep -q "\"$name\"" <<<"$tools" || missing="$missing $name"
  done
  if [[ -n "$missing" ]]; then
    echo "atlassian: connected, but missing Jira tools:$missing"
    echo "  Recreate the token with scopes read:jira-work, write:jira-work, read:jira-user."
    return 1
  fi
  local search
  search="$(mcp_post "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"searchJiraIssuesUsingJql\",\"arguments\":{\"cloudId\":\"$JIRA_CLOUD_ID\",\"jql\":\"project = LPT ORDER BY created DESC\",\"maxResults\":1,\"fields\":[\"summary\"]}}}" \
    ${session[@]+"${session[@]}"} || true)"
  if ! grep -q 'LPT-[0-9]' <<<"$search"; then
    echo "atlassian: tools listed, but a Jira search failed:"
    sed -n 's/^data: //p' <<<"$search" | grep -o '"message[^}]*' | head -1 | sed 's/^/    /'
    echo "  A classic token cannot call Jira through the MCP server. Create one with"
    echo "  'Create API token with scopes' → Jira → read:jira-work, write:jira-work, read:jira-user."
    return 1
  fi
  echo "atlassian: ok (Jira search works)"
}

# A real CLI run in the runner workspace: proves the API key and the Jira tools.
cli_jira_check() {
  local out key
  ensure_runner
  out="$(cd "$(primary)" && agent -p --force --trust --approve-mcps --output-format text \
    --workspace "$RUNNER_DIR" --add-dir "$(primary)" \
    "Call the Atlassian searchJiraIssuesUsingJql tool once with cloudId $JIRA_CLOUD_ID, jql 'project = LPT ORDER BY created DESC', maxResults 1. Reply with only the issue key it returns, or NO_JIRA if the call fails." 2>&1 | tail -n 5 || true)"
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
  atlassian_check || failed=1
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
    ;;
  attach)
    exec tmux attach -t "$SESSION"
    ;;
  setup)
    setup
    ;;
  verify)
    verify
    ;;
  *)
    sed -n '2,32p' "$SCRIPT" | sed 's/^# \{0,1\}//'
    exit 2
    ;;
esac
