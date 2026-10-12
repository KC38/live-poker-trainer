#!/usr/bin/env bash
# Block until a tee_exit sibling .done file appears, heartbeating the sim lock.
#
# Prefer this over bare AwaitShell/sleep while `test-LPT-*` / `analyze-LPT-*`
# tmux sessions run — silent waits risk the stall watchdog (LPT-72 / LPT-390).
#
# Usage:
#   tools/tee_exit.sh /tmp/test-LPT-390.log flutter test …   # in tmux
#   tools/wait_done.sh /tmp/test-LPT-390.done
#   tools/wait_done.sh /tmp/test-LPT-390.log --timeout 600
#   tools/wait_done.sh /tmp/test-LPT-390.done --purpose "LPT-390: tests"
#
# Flags may appear in any order after the path. Do not pass --purpose as the
# positional timeout — bash arithmetic then treats `--purpose` as decrementing
# an unbound `purpose` variable under `set -u` (LPT-462).
#
# .done body accepted (LPT-410: agents sometimes write DONE, not 0):
#   0 / 7          → that exit code
#   EXIT:0         → that exit code
#   DONE / DONE:0  → 0 (or DONE:N → N)
# Falls back to the last EXIT:N line in the sibling .log when the .done
# body is present but unparseable.
#
# Exit code is the parsed status (0–255). Timeout → exit 124.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  echo "usage: $0 <done-or-log-path> [--timeout SECONDS] [--purpose TEXT]" >&2
  echo "       $0 <done-or-log-path> [timeout-seconds] [--purpose TEXT]" >&2
}

DONE=""
WAIT_SECS=1800
PURPOSE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --timeout)
      if [[ $# -lt 2 || ! "$2" =~ ^[0-9]+$ ]]; then
        echo "error: --timeout needs an integer second count" >&2
        usage
        exit 2
      fi
      WAIT_SECS="$2"
      shift 2
      ;;
    --purpose)
      if [[ $# -lt 2 ]]; then
        echo "error: --purpose needs a value" >&2
        usage
        exit 2
      fi
      PURPOSE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "error: unknown flag $1" >&2
      usage
      exit 2
      ;;
    *)
      if [[ -z "$DONE" ]]; then
        DONE="$1"
        shift
      elif [[ "$1" =~ ^[0-9]+$ ]]; then
        # Legacy positional timeout.
        WAIT_SECS="$1"
        shift
      else
        echo "error: unexpected argument: $1" >&2
        usage
        exit 2
      fi
      ;;
  esac
done

if [[ -z "$DONE" ]]; then
  usage
  exit 2
fi

if [[ "$DONE" == *.log ]]; then
  DONE="${DONE%.log}.done"
fi
LOG="${DONE%.done}.log"

parse_done_body() {
  local raw="$1" code=""
  raw="$(printf '%s' "$raw" | tr -d '[:space:]')"
  [[ -n "$raw" ]] || return 1
  if [[ "$raw" =~ ^[0-9]+$ ]]; then
    code="$raw"
  elif [[ "$raw" =~ ^[Ee][Xx][Ii][Tt]:([0-9]+)$ ]]; then
    code="${BASH_REMATCH[1]}"
  elif [[ "$raw" =~ ^[Dd][Oo][Nn][Ee]:([0-9]+)$ ]]; then
    code="${BASH_REMATCH[1]}"
  elif [[ "$raw" =~ ^[Dd][Oo][Nn][Ee]$ ]]; then
    code="0"
  else
    return 1
  fi
  if (( code > 255 )); then
    code=255
  fi
  printf '%s\n' "$code"
}

parse_log_exit() {
  local log="$1" line code
  [[ -f "$log" ]] || return 1
  line="$(grep -E '^EXIT:[0-9]+$' "$log" 2>/dev/null | tail -n 1 || true)"
  [[ -n "$line" ]] || return 1
  code="${line#EXIT:}"
  printf '%s\n' "$code"
}

deadline=$(( $(date +%s) + WAIT_SECS ))
last_beat=0
while (( $(date +%s) < deadline )); do
  if [[ -f "$DONE" ]]; then
    body="$(cat "$DONE" 2>/dev/null || true)"
    if code="$(parse_done_body "$body")"; then
      echo "done: $DONE → EXIT:$code"
      exit "$code"
    fi
    if code="$(parse_log_exit "$LOG")"; then
      echo "done: $DONE (via $LOG EXIT:$code)"
      exit "$code"
    fi
  fi
  now=$(date +%s)
  if [[ -n "${SIM_LOCK_RUN_ID:-}" ]] && (( now - last_beat >= 30 )); then
    python3 "$ROOT/tools/sim_lock.py" heartbeat ${PURPOSE:+--purpose "$PURPOSE"} \
      >/dev/null 2>&1 || true
    last_beat=$now
  fi
  sleep 1
done

echo "timeout: $DONE not ready after ${WAIT_SECS}s" >&2
if [[ -f "$DONE" ]]; then
  echo "  .done body: $(head -c 80 "$DONE" | tr '\n' ' ')" >&2
fi
exit 124
