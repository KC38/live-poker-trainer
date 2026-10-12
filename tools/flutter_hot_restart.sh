#!/usr/bin/env bash
# Hot-restart a running `flutter run` and wait for that restart to land.
#
# A bare `kill -USR2` + log grep can match an older "Restarted application"
# line and report ready before the new code runs. This counts restarts
# before signalling and waits for one more (or a compile error).
#
# Usage:
#   tools/flutter_hot_restart.sh <log> <pid-file> [seconds=90]
#
# Exit 0 restarted, 1 timeout / compile error, 2 no live flutter pid.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="${1:-}"
PIDFILE="${2:-}"
SECONDS_WAIT="${3:-90}"
if [[ -z "$LOG" || -z "$PIDFILE" ]]; then
  echo "usage: $0 <log> <pid-file> [seconds=90]" >&2
  exit 2
fi

pid="$(tr -d '[:space:]' <"$PIDFILE" 2>/dev/null || true)"
if [[ -z "$pid" ]] || ! kill -0 "$pid" 2>/dev/null; then
  echo "no live flutter pid in $PIDFILE; start it with tools/flutter_run_fast.sh" >&2
  exit 2
fi

count() { grep -ac "$1" "$LOG" 2>/dev/null || true; }
before_ok="$(count 'Restarted application in')"
before_err="$(count 'Error: \|Hot restart failed\|Try again after fixing')"
kill -USR2 "$pid"

deadline=$(( $(date +%s) + SECONDS_WAIT ))
last_beat=0
while (( $(date +%s) < deadline )); do
  if (( $(count 'Restarted application in') > before_ok )); then
    echo "hot-restarted: $(grep -a 'Restarted application in' "$LOG" | tail -1)"
    exit 0
  fi
  if (( $(count 'Error: \|Hot restart failed\|Try again after fixing') > before_err )); then
    echo "hot restart failed (compile error?):" >&2
    tail -n 25 "$LOG" | sed 's/^/  /' >&2
    exit 1
  fi
  now=$(date +%s)
  if [[ -n "${SIM_LOCK_RUN_ID:-}" ]] && (( now - last_beat >= 30 )); then
    python3 "$ROOT/tools/sim_lock.py" heartbeat --purpose "hot restart" >/dev/null 2>&1 || true
    last_beat=$now
  fi
  sleep 1
done
echo "timeout: no new 'Restarted application' in $LOG after ${SECONDS_WAIT}s" >&2
exit 1
