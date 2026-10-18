#!/usr/bin/env bash
# Run /lesson-content-agent back to back, unattended, inside tmux.
# No iPhone simulator — safe to run alongside ui_design_agent_loop.sh.
#
# Runs the SDK/CLI agent in PRIMARY/.worktrees/content-agent (detached
# origin/main), never with --cwd PRIMARY. Learnings chore PRs must be
# opened from that worktree so ui-agent keeps a clean main tip.
#
#   tools/lesson_content_agent_loop.sh setup|verify|tick|install|uninstall|
#     status|attach|stop|release-hold|kill|once|start|ensure
#
# Schedule (Kushal 2026-10-16): ONE run every 12h, never a back-to-back loop.
#   install   launchd StartCalendarInterval -> `tick` at 03:00 and 15:00
#             America/Chicago (CONTENT_AGENT_CT_TARGETS). The IST mini
#             registers both CDT and CST local candidates; tick runs only
#             within +/-10 min of a CT target, once per slot, so DST (Nov 1)
#             needs no edits (tools/agent_ct_slot.sh). No RunAtLoad, no
#             KeepAlive, no StartInterval.
#   tick      one run; skips if held/stopped, a run or loop is live, or the
#             CT time is not a target. CONTENT_AGENT_TICK_FORCE=1 skips the
#             time gate; CONTENT_AGENT_TICK_DRY=1 only reports.
#   stop/kill also write content-agent.hold, which persists (run-loop exit
#             no longer erases the stop state). start/ensure/tick/run-loop
#             refuse while it exists; only `release-hold` clears it.
#   start/ensure  legacy continuous tmux loop; refused while held. Agents
#             must not call these (Oct 15 2026: an agent's `start` wiped
#             the stop file and restarted the loop after Kushal stopped it).
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
HOLD_FILE="$STATE_DIR/content-agent.hold"
CONTENT_CT_TARGETS="${CONTENT_AGENT_CT_TARGETS:-03:00 15:00}"
CONTENT_TICK_STAMP="$STATE_DIR/content-agent-tick-slots"
PID_FILE="$STATE_DIR/content-agent.pid"
LOOP_PID_FILE="$STATE_DIR/content-agent-loop.pid"
SECRETS_FILE="$STATE_DIR/secrets.env"
GAP="${CONTENT_AGENT_GAP:-60}"
# After a run ends with IDLE_NO_GAPS, sleep this long (default 6h) or until
# origin/main's content/ tree hash changes (polled every IDLE_POLL seconds).
IDLE_SLEEP="${CONTENT_AGENT_IDLE_SLEEP:-21600}"
IDLE_POLL="${CONTENT_AGENT_IDLE_POLL:-900}"
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
  local primary_dir worktree_dir pending=""
  primary_dir="$(primary)"
  worktree_dir="${CONTENT_AGENT_WORKTREE:-$primary_dir/.worktrees/content-agent}"
  if [[ -s "$STATE_DIR/content-agent-learnings-pending.md" ]] && grep -q '^- ' "$STATE_DIR/content-agent-learnings-pending.md" 2>/dev/null; then
    pending=" Pending learnings in $STATE_DIR/content-agent-learnings-pending.md — run tools/fold_agent_learnings.sh content, distill into lesson-content-agent-learnings.md + content-agent-run-memory.md, and ship chore/content-agent-learnings-YYYYMMDD only if it is a genuinely new rule (max one learnings PR per day)."
  fi
  printf '%s' "READY: lesson content agent (audit + file only). No simulator — do not claim sim_lock, refresh-simulator, agent_tap, or agent_seed. WORKTREE: ${worktree_dir} (all git edits + learnings chore PRs here; cwd is already this tree). Never checkout, commit, or edit PRIMARY (${primary_dir}) — reserved for ui-design-agent on clean main. Scratch bodies under ${worktree_dir}/.cursor/tmp/content-agent/. Read .cursor/commands/lesson-content-agent.md, lesson-content-agent-learnings.md, and grep docs/agents/content-agent-run-memory.md for the target act-/lesson- id. Every run: node tools/course/scan_content_gaps.mjs --counts then sync open (catalog) parents from --gap … --markdown. If --counts is unchanged since the last coverage line and only needs-human parents remain, log coverage clean, open no PR, post no Jira comments, and end with IDLE_NO_GAPS. Open a learnings chore PR only for a genuinely new Never/Prefer rule (max one per UTC day; never rescue or chain other chore PRs); clean re-checks and Prefer-next notes go to the coverage jsonl, not git. Prefer catalog-bundled tickets; never implement product fixes. Default Jira labels content,grokbot,lesson; use content,ui-agent,lesson only when Chrome cannot validate. Use python3 tools/jira.py only.${pending} Unattended: do not ask questions."
}

ensure_sdk_deps() {
  # Test hook: prove tick does not stamp the CT slot when prep fails.
  if [[ "${CONTENT_AGENT_TICK_PREPARE_FAIL:-}" == "1" ]]; then
    echo "tick: SDK deps failed" >&2
    return 1
  fi
  [[ -f "$SDK_DIR/package.json" ]] || return 1
  [[ -d "$SDK_DIR/node_modules/@cursor/sdk" ]] && return 0
  log "installing @cursor/sdk into $SDK_DIR"
  (cd "$SDK_DIR" && npm ci --omit=dev) || (cd "$SDK_DIR" && npm install --omit=dev)
  [[ -d "$SDK_DIR/node_modules/@cursor/sdk" ]]
}

# Keep PRIMARY on clean main for ui-design-agent. Content-agent edits live in
# prepare_content_run_worktree — never leave chore branches on PRIMARY.
ensure_primary_clean_main() {
  local dir branch
  dir="$(primary)"
  # Soft fetch — offline / no-remote test fixtures still need chore→main.
  git -C "$dir" fetch -q origin main 2>/dev/null || true
  # Drop merged chore branches left as ": gone]" after squash-merge.
  # Best-effort — never fail the run if prune hits a locked worktree.
  bash "$TOOLS/prune_gone_branches.sh" "$dir" >/dev/null 2>&1 || true
  # Drop scratch ticket bodies if an old run wrote them on PRIMARY.
  rm -rf "$dir/.cursor/tmp/content-agent" 2>/dev/null || true
  # Never destroy unrelated dirty work on PRIMARY.
  if [[ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]]; then
    log "PRIMARY dirty; not forcing checkout (ui-agent will skip until clean)"
    return 0
  fi
  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
  if [[ "$branch" != "main" ]]; then
    case "$branch" in
      cursor/chore-content-*|chore/content-agent-learnings-*|chore/content-*|content-agent/*)
        log "PRIMARY on $branch → main (content-agent uses worktree now)"
        git -C "$dir" checkout -q main || return 0
        ;;
      *)
        log "PRIMARY on $branch (not main); not forcing checkout"
        return 0
        ;;
    esac
  fi
  if git -C "$dir" rev-parse --verify -q origin/main >/dev/null 2>&1; then
    git -C "$dir" merge -q --ff-only origin/main || true
  fi
}

# Detached worktree at origin/main for the agent cwd. Recreated/reset each run
# so leftover uncommitted audit edits do not accumulate.
prepare_content_run_worktree() {
  local primary wt tip
  primary="$(primary)"
  wt="${CONTENT_AGENT_WORKTREE:-$primary/.worktrees/content-agent}"
  mkdir -p "$(dirname "$wt")"
  git -C "$primary" fetch -q origin main 2>/dev/null || true
  tip="$(git -C "$primary" rev-parse origin/main 2>/dev/null || true)"
  [[ -n "$tip" ]] || tip="$(git -C "$primary" rev-parse main 2>/dev/null || true)"
  [[ -n "$tip" ]] || return 1
  if [[ ! -e "$wt/.git" ]]; then
    rm -rf "$wt"
    git -C "$primary" worktree prune 2>/dev/null || true
    # stdout must stay clean — callers capture the path via $(...).
    git -C "$primary" worktree add --detach "$wt" "$tip" >/dev/null 2>&1 \
      || return 1
  else
    if ! git -C "$wt" checkout -q --detach "$tip" 2>/dev/null; then
      git -C "$primary" worktree remove --force "$wt" 2>/dev/null || rm -rf "$wt"
      git -C "$primary" worktree prune 2>/dev/null || true
      git -C "$primary" worktree add --detach "$wt" "$tip" >/dev/null 2>&1 \
        || return 1
    else
      git -C "$wt" reset -q --hard "$tip"
      git -C "$wt" clean -fdq
    fi
  fi
  mkdir -p "$wt/.cursor/tmp/content-agent"
  printf '%s\n' "$wt"
}

# Back-compat name used by older call sites / docs.
sync_primary() {
  ensure_primary_clean_main
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
  local worktree_dir
  ensure_primary_clean_main
  worktree_dir="$(prepare_content_run_worktree)" || {
    log "content-agent worktree unavailable"
    return 11
  }
  export CONTENT_AGENT_WORKTREE="$worktree_dir"
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
  LAST_RUN_LOG="$run_log"
  start="$(date +%s)"
  sha="$(git -C "$worktree_dir" rev-parse HEAD 2>/dev/null || echo unknown)"

  configure_agent_credentials
  text="$(prompt)"
  log "run $stamp starting (launcher=$LAUNCHER model=$(resolved_agent_model); worktree=$worktree_dir; log $run_log)"

  if [[ "$LAUNCHER" == "sdk" ]]; then
    if ! ensure_sdk_deps; then
      log "SDK deps unavailable"
      return 11
    fi
    (
      cd "$worktree_dir"
      export CURSOR_API_KEY ATLASSIAN_EMAIL ATLASSIAN_API_TOKEN
      exec node "$SDK_RUN" \
        --cwd "$worktree_dir" \
        --model "$(sdk_model_id)" \
        --runtime "$SDK_RUNTIME" \
        --machine "$MACHINE_NAME" \
        --log "$run_log" \
        --meta "$LOG_DIR/run-$stamp.sdk.json" \
        -- "$text"
    ) >>"$run_log" 2>&1 &
  else
    (
      cd "$worktree_dir"
      exec agent -p --force --trust --sandbox disabled --output-format text \
        --workspace "$worktree_dir" "$text"
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
  # Scrub SDK stream crumbs (same helper as status) so tmux/attach stays readable.
  print_content_run_log_preview "$run_log" 12 | sed 's/^/    /' || true
  find "$LOG_DIR" -name 'run-*.log' -mtime +14 -delete 2>/dev/null || true
  return "$code"
}

# Scrub finished SDK stream logs for `status` — raw `tail` interleaved
# {"t":…,"type":"assistant"} crumbs with closeout prose (health timers).
print_content_run_log_preview() {
  local log="${1:-}" max_lines="${2:-8}"
  [[ -n "$log" && -s "$log" ]] || return 0
  python3 - "$log" "$max_lines" <<'PY' || true
import re, sys
from pathlib import Path

path = Path(sys.argv[1])
try:
    max_lines = max(1, int(sys.argv[2]))
except ValueError:
    max_lines = 8

SDK_STREAM = re.compile(
    r'\{\s*"t"\s*:\s*\d+\s*,\s*"type"\s*:\s*'
    r'"(?:thinking|assistant|tool_call|status)"\s*\}'
)
NOISE = re.compile(
    r"("
    r"Connection lost, reconnecting|Retry attempt |\^D|"
    r"Cursor Agent Debug Session|User does not belong to a team|"
    r"Loaded global commands|telemetry-only|filtered out for missing"
    r")",
    re.I,
)

try:
    raw = path.read_text(encoding="utf-8", errors="replace")
except OSError:
    raise SystemExit(0)

SUMMARY = re.compile(
    r"("
    r"^# ui-agent-sdk status=|"
    r"^\*\*Result:\*\*|"
    r"^\*\*Tickets:\*\*|"
    r"^\*\*Leads:\*\*|"
    r"^\*\*Learnings:\*\*"
    r")",
    re.I,
)

kept: list[str] = []
summary: list[str] = []
for ln in raw.splitlines():
    cleaned = SDK_STREAM.sub(" ", ln)
    cleaned = re.sub(r"\s+", " ", cleaned).strip()
    if not cleaned or NOISE.search(cleaned):
        continue
    # Drop lone streamed tokens / punctuation crumbs.
    if len(cleaned) <= 2 and not cleaned.startswith("#"):
        continue
    kept.append(cleaned)
    if SUMMARY.search(cleaned):
        summary.append(cleaned)

for ln in (summary or kept)[-max_lines:]:
    print(ln)
PY
}

# Sleep up to N seconds but wake every few seconds so stop/soft-stop
# (STOP_FILE) is honored during long gaps — usage-limit sleeps of 3600s
# previously blocked kill/stop until the bare sleep finished.
sleep_unless_stopped() {
  local total="${1:-0}" stepped=0 chunk
  [[ "$total" =~ ^[0-9]+$ ]] || total=0
  while (( stepped < total )); do
    [[ -f "$STOP_FILE" ]] && return 0
    chunk=5
    if (( total - stepped < chunk )); then
      chunk=$(( total - stepped ))
    fi
    (( chunk > 0 )) || break
    sleep "$chunk"
    stepped=$(( stepped + chunk ))
  done
}

# Tree hash of origin/main:content (empty on failure).
origin_content_hash() {
  git -C "$(primary)" fetch -q origin main 2>/dev/null || true
  git -C "$(primary)" rev-parse -q --verify origin/main:content 2>/dev/null || true
}

# Sleep IDLE_SLEEP seconds, waking early on STOP_FILE or when
# origin/main's content/ tree changes.
idle_sleep_until_content_changes() {
  local base now waited=0 chunk
  base="$(origin_content_hash)"
  log "IDLE_NO_GAPS; sleeping up to ${IDLE_SLEEP}s or until origin/main content/ changes (base ${base:-unknown})"
  while (( waited < IDLE_SLEEP )); do
    [[ -f "$STOP_FILE" ]] && return 0
    chunk=$IDLE_POLL
    (( IDLE_SLEEP - waited < chunk )) && chunk=$(( IDLE_SLEEP - waited ))
    sleep_unless_stopped "$chunk"
    waited=$(( waited + chunk ))
    now="$(origin_content_hash)"
    if [[ -n "$base" && -n "$now" && "$now" != "$base" ]]; then
      log "origin/main content/ changed ($base -> $now); waking"
      return 0
    fi
  done
}

run_loop() {
  if [[ -f "$HOLD_FILE" ]]; then
    log "held ($HOLD_FILE); not starting the loop"
    return 0
  fi
  echo $$ >"$LOOP_PID_FILE"
  trap 'rm -f "$LOOP_PID_FILE"' EXIT
  rm -f "$STOP_FILE"
  log "lesson-content-agent loop started (stop: $SCRIPT stop)"
  while [[ ! -f "$STOP_FILE" ]]; do
    local code=0
    one_run || code=$?
    [[ -f "$STOP_FILE" ]] && break
    case "$code" in
      11) sleep_unless_stopped 600 ;;
      12) sleep_unless_stopped 300 ;;
      14)
        _s="$(sleep_usage_limit_seconds)"
        log "usage limit; sleeping ${_s}s"
        sleep_unless_stopped "$_s"
        ;;
      15)
        log "sdk gateway timeout (exit 15); sleeping ${GATEWAY_TIMEOUT_SLEEP}s before retry"
        sleep_unless_stopped "$GATEWAY_TIMEOUT_SLEEP"
        ;;
      *)
        if [[ -n "${LAST_RUN_LOG:-}" ]] && grep -q 'IDLE_NO_GAPS' "$LAST_RUN_LOG" 2>/dev/null; then
          idle_sleep_until_content_changes
        else
          sleep_unless_stopped "$GAP"
        fi
        ;;
    esac
    # STOP_FILE during gap sleep exits the while without a second one_run.
    if [[ -f "$STOP_FILE" ]]; then
      break
    fi
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
    if [[ -f "$HOLD_FILE" && "${CONTENT_AGENT_FORCE_START:-}" != "1" ]]; then
      echo "held ($HOLD_FILE): not starting. Kushal must approve; then: $SCRIPT release-hold" >&2
      exit 3
    fi
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
    # Twice-daily one-shot runs at CT targets (see header). Replaces the old
    # RunAtLoad + StartInterval=300 `ensure` plist that respawned the loop.
    # shellcheck source=agent_ct_slot.sh
    source "$TOOLS/agent_ct_slot.sh"
    mkdir -p "$(dirname "$PLIST")"
    _cal="$(ct_slot_plist_entries "$CONTENT_CT_TARGETS")"
    cat >"$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LAUNCH_LABEL</string>
  <key>ProgramArguments</key>
  <array><string>/bin/bash</string><string>$(primary)/tools/lesson_content_agent_loop.sh</string><string>tick</string></array>
  <key>StartCalendarInterval</key>
  <array>
$_cal
  </array>
  <key>RunAtLoad</key><false/>
  <key>KeepAlive</key><false/>
  <key>AbandonProcessGroup</key><true/>
  <key>StandardOutPath</key><string>$LOG_DIR/launchd.log</string>
  <key>StandardErrorPath</key><string>$LOG_DIR/launchd.log</string>
</dict>
</plist>
EOF
    if [[ "${CONTENT_AGENT_INSTALL_NO_BOOTSTRAP:-}" != "1" ]]; then
      launchctl bootout "gui/$(id -u)/$LAUNCH_LABEL" 2>/dev/null || true
      launchctl bootstrap "gui/$(id -u)" "$PLIST"
    fi
    echo "installed $PLIST: one run (tick) at $CONTENT_CT_TARGETS CT; next $(ct_slot_next "$CONTENT_CT_TARGETS")"
    [[ -f "$HOLD_FILE" ]] && echo "note: held ($HOLD_FILE); ticks are no-ops until: $SCRIPT release-hold"
    unset _cal
    ;;
  tick)
    if [[ -f "$HOLD_FILE" ]]; then echo "tick: held ($HOLD_FILE); skipping"; exit 0; fi
    if [[ -f "$STOP_FILE" ]]; then echo "tick: stop file present; skipping"; exit 0; fi
    if loop_is_alive; then echo "tick: legacy loop is live; skipping"; exit 0; fi
    if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
      echo "tick: a run is already live; skipping"; exit 0
    fi
    # shellcheck source=agent_ct_slot.sh
    source "$TOOLS/agent_ct_slot.sh"
    _slot="manual-$(date +%s)"
    if [[ "${CONTENT_AGENT_TICK_FORCE:-}" != "1" ]]; then
      _slot="$(ct_slot_due "$CONTENT_CT_TARGETS" "$CONTENT_TICK_STAMP")" || { echo "tick: $_slot; skipping"; exit 0; }
    fi
    if [[ "${CONTENT_AGENT_TICK_DRY:-}" == "1" ]]; then echo "tick: due for slot $_slot (dry run; not starting)"; exit 0; fi
    # Mark only after SDK prep succeeds so a deps failure does not burn the
    # CT slot (dual-calendar +1h candidate can still fire).
    if [[ "$LAUNCHER" == "sdk" ]] && ! ensure_sdk_deps; then echo "tick: SDK deps failed" >&2; exit 1; fi
    ct_slot_mark "$CONTENT_TICK_STAMP" "$_slot"
    log "tick: starting one run (CT slot $_slot)"
    one_run || log "tick: one_run exited $?"
    ;;
  ensure)
    [[ -f "$HOLD_FILE" ]] && { echo "ensure: held ($HOLD_FILE)"; exit 0; }
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
    touch "$STOP_FILE" "$HOLD_FILE"
    echo "loop stops after current run; held until: $SCRIPT release-hold"
    ;;
  release-hold)
    rm -f "$HOLD_FILE" "$STOP_FILE"
    echo "hold released; scheduled ticks may run (next $(source "$TOOLS/agent_ct_slot.sh"; ct_slot_next "$CONTENT_CT_TARGETS"))"
    ;;
  kill)
    touch "$STOP_FILE" "$HOLD_FILE"
    if [[ -f "$PID_FILE" ]]; then
      kill -TERM "$(cat "$PID_FILE")" 2>/dev/null || true
    fi
    lt kill-session -t "=$SESSION" 2>/dev/null || true
    rm -f "$PID_FILE" "$STOP_FILE"
    echo "killed $SESSION (held: $HOLD_FILE)"
    ;;
  status)
    if loop_is_alive; then
      echo "loop: running (tmux -L $TMUX_SOCKET, session $SESSION, pid $(cat "$LOOP_PID_FILE"))"
    else
      echo "loop: not running"
    fi
    [[ -f "$HOLD_FILE" ]] && echo "hold: $HOLD_FILE (release-hold to allow runs)"
    if [[ -f "$PLIST" ]]; then echo "schedule: tick at $CONTENT_CT_TARGETS CT ($PLIST)"; else echo "schedule: not installed"; fi
    echo "model: $(resolved_agent_model)"
    echo "worktree: $(primary)/.worktrees/content-agent"
    echo "primary: $(primary) (ui-agent only; content-agent must not edit)"
    echo "coverage: $COVERAGE_FILE"
    latest="$(ls -t "$LOG_DIR"/run-*.log 2>/dev/null | head -1 || true)"
    if [[ -n "$latest" ]]; then
      echo "latest log: $latest"
      # Skip mid-run NDJSON crumbs (same idea as ui-agent status).
      if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
        echo "(active run — log preview skipped)"
      else
        print_content_run_log_preview "$latest" 8
      fi
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
    sed -n '2,30p' "$SCRIPT" | sed 's/^# \{0,1\}//'
    exit 2
    ;;
esac
