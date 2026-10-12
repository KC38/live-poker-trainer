#!/usr/bin/env bash
# Block until a tee_exit sibling .done file appears, heartbeating the sim lock.
#
# Prefer this over bare AwaitShell/sleep while `test-LPT-*` / `analyze-LPT-*`
# tmux sessions run — silent waits risk the stall watchdog (LPT-72 / LPT-390).
#
# Usage:
#   tools/tee_exit.sh /tmp/test-LPT-390.log flutter test …   # in tmux
#   tools/wait_done.sh /tmp/test-LPT-390.done                 # in the agent shell
#   tools/wait_done.sh /tmp/test-LPT-390.log                  # also accepts .log
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

DONE="${1:-}"
TIMEOUT="${2:-1800}"
PURPOSE=""
if [[ "${3:-}" == "--purpose" ]]; then
  PURPOSE="${4:-}"
fi

if [[ -z "$DONE" ]]; then
  echo "usage: $0 <done-or-log-path> [timeout-seconds=1800] [--purpose TEXT]" >&2
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
  # Clamp to a single exit byte.
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

deadline=$(( $(date +%s) + TIMEOUT ))
last_beat=0
while (( $(date +%s) < deadline )); do
  if [[ -f "$DONE" ]]; then
    body="$(cat "$DONE" 2>/dev/null || true)"
    if code="$(parse_done_body "$body")"; then
      echo "done: $DONE → EXIT:$code"
      exit "$code"
    fi
    # File present but body is junk / partial — try sibling log once it has EXIT.
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

echo "timeout: $DONE not ready after ${TIMEOUT}s" >&2
if [[ -f "$DONE" ]]; then
  echo "  .done body: $(head -c 80 "$DONE" | tr '\n' ' ')" >&2
fi
exit 124
