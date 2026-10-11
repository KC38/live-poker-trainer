#!/usr/bin/env bash
# Wait until a Flutter run log shows a Dart VM service URI.
#
# Used by /ui-design-agent worktree validate and closeout so agents do not
# busy-sleep with AwaitShell while Xcode builds. Heartbeats the sim lock when
# SIM_LOCK_RUN_ID is set so the stall watchdog does not kill a healthy wait.
#
# Usage:
#   tools/wait_flutter_vm.sh <log-path> [seconds] [--purpose <text>]
#
# Exit 0 when ready, 1 on timeout / missing log.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="${1:-}"
SECONDS_WAIT="${2:-300}"
PURPOSE="wait Flutter Dart VM"

if [[ -z "$LOG" || "$LOG" == -* ]]; then
  echo "usage: $0 <log-path> [seconds=300] [--purpose <text>]" >&2
  exit 2
fi
shift || true
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
  SECONDS_WAIT="$1"
  shift || true
fi
if [[ "${1:-}" == "--purpose" ]]; then
  PURPOSE="${2:-$PURPOSE}"
  shift 2 || true
fi

log_has_dart_vm() {
  local log="$1"
  [[ -f "$log" ]] || return 1
  # Ignore stale URIs left above a newer Launching… / Xcode rebuild.
  python3 "$ROOT/tools/flutter_log_ready.py" "$log" >/dev/null 2>&1
}

deadline=$(( $(date +%s) + SECONDS_WAIT ))
last_beat=0
while (( $(date +%s) < deadline )); do
  if log_has_dart_vm "$LOG"; then
    echo "Dart VM ready in $LOG"
    exit 0
  fi
  now=$(date +%s)
  if [[ -n "${SIM_LOCK_RUN_ID:-}" ]] && (( now - last_beat >= 30 )); then
    python3 "$ROOT/tools/sim_lock.py" heartbeat --purpose "$PURPOSE" >/dev/null 2>&1 || true
    last_beat=$now
  fi
  sleep 2
done

echo "timeout: no Dart VM URI in $LOG after ${SECONDS_WAIT}s" >&2
tail -n 20 "$LOG" 2>/dev/null | sed 's/^/  /' >&2 || true
exit 1
