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
# Exit code is the integer written to .done (0–255). Timeout → exit 124.
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

deadline=$(( $(date +%s) + TIMEOUT ))
last_beat=0
while (( $(date +%s) < deadline )); do
  if [[ -f "$DONE" ]]; then
    code="$(tr -d '[:space:]' <"$DONE" 2>/dev/null || true)"
    if [[ "$code" =~ ^[0-9]+$ ]]; then
      echo "done: $DONE → EXIT:$code"
      exit "$code"
    fi
    # File present but empty/partial — keep waiting briefly.
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
exit 124
