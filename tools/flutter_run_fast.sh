#!/usr/bin/env bash
# Start `flutter run` on the iPhone 13 mini, skipping Xcode when possible.
#
# Dart-only checkouts reuse a cached debug Runner.app keyed by
# tools/native_build_key.py (pubspec.lock + ios/ + Flutter engine). The
# cached app is installed with --use-application-binary, then hot-restarted
# so this checkout's Dart (synced by the tool) is what runs. On a cache miss
# it does a normal Xcode build and saves Runner.app for the next run.
#
# Usage:
#   tools/flutter_run_fast.sh --checkout DIR --log LOG --pid-file PID \
#     [--device UDID] [--timeout SECONDS] [--purpose TEXT] [--no-cache]
#
# Blocks until the app runs this checkout's code (exit 0) or the timeout
# (exit 1; a cold build keeps going and is cached when it lands).
# Heartbeats the sim lock while waiting when SIM_LOCK_RUN_ID is set.
#
# Env: FLUTTER_RUN_FAST=0 disables the cache. UI_AGENT_APP_CACHE_DIR
# (default ~/.live-poker-trainer/app-cache), UI_AGENT_APP_CACHE_KEEP
# (default 2 keys).
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin:${PATH:-}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SELF="$ROOT/tools/flutter_run_fast.sh"
READY_PY="$ROOT/tools/flutter_log_ready.py"
CACHE_DIR="${UI_AGENT_APP_CACHE_DIR:-$HOME/.live-poker-trainer/app-cache}"
CACHE_KEEP="${UI_AGENT_APP_CACHE_KEEP:-2}"
FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
PREBUILT_VM_WAIT="${FLUTTER_RUN_FAST_VM_WAIT:-120}"
PREBUILT_RESTART_WAIT="${FLUTTER_RUN_FAST_RESTART_WAIT:-90}"

CHECKOUT=""
LOG=""
PIDFILE=""
DEVICE=""
TIMEOUT=600
# Empty PURPOSE keeps the holder's own purpose (e.g. "LPT-74: validate").
PURPOSE=""
USE_CACHE=1
MODE="run"
KEY=""

usage() {
  sed -n '2,20p' "$0" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --checkout) CHECKOUT="$2"; shift 2 ;;
    --log) LOG="$2"; shift 2 ;;
    --pid-file) PIDFILE="$2"; shift 2 ;;
    --device) DEVICE="$2"; shift 2 ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    --purpose) PURPOSE="$2"; shift 2 ;;
    --no-cache) USE_CACHE=0; shift ;;
    --populate-key) MODE="populate"; KEY="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "unknown arg: $1" >&2; usage ;;
  esac
done

[[ -n "$CHECKOUT" && -n "$LOG" ]] || usage
CHECKOUT="$(cd "$CHECKOUT" && pwd)"
[[ -n "$PIDFILE" ]] || PIDFILE="${LOG%.log}.pid"
[[ "${FLUTTER_RUN_FAST:-1}" == "0" ]] && USE_CACHE=0
MINI="$(bash "$ROOT/tools/iphone_13_mini_udid.sh" 2>/dev/null || true)"
[[ -n "$DEVICE" ]] || DEVICE="$MINI"

FLUTTER_PID=""
last_beat=0

heartbeat() {
  local now
  now=$(date +%s)
  # The lock only covers the iPhone 13 mini; never beat it for another sim.
  [[ "$DEVICE" == "$MINI" ]] || return 0
  if [[ -n "${SIM_LOCK_RUN_ID:-}" ]] && (( now - last_beat >= 30 )); then
    python3 "$ROOT/tools/sim_lock.py" heartbeat ${PURPOSE:+--purpose "$PURPOSE"} >/dev/null 2>&1 || true
    last_beat=$now
  fi
}

flutter_alive() {
  [[ -z "$FLUTTER_PID" ]] || kill -0 "$FLUTTER_PID" 2>/dev/null
}

# wait_until <seconds> <check-fn>; 0 ready, 1 timeout, 2 flutter exited.
wait_until() {
  local seconds="$1" check="$2" deadline
  deadline=$(( $(date +%s) + seconds ))
  while (( $(date +%s) < deadline )); do
    if "$check"; then return 0; fi
    if ! flutter_alive; then
      "$check" && return 0
      return 2
    fi
    heartbeat
    sleep 2
  done
  return 1
}

vm_up() { python3 "$READY_PY" --vm-only "$LOG" >/dev/null 2>&1; }
log_ready() { python3 "$READY_PY" "$LOG" >/dev/null 2>&1; }
restarted() { grep -aq 'Restarted application in' "$LOG" 2>/dev/null; }
signal_ready() { vm_up && [[ -s "$PIDFILE" ]]; }

stop_device_flutter() {
  local pid
  while IFS= read -r pid; do
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
  done < <(pgrep -f "flutter_tools\\.snapshot run -d ${DEVICE}" 2>/dev/null || true)
  if [[ -f "$PIDFILE" ]]; then
    pid="$(tr -d '[:space:]' <"$PIDFILE" 2>/dev/null || true)"
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
  fi
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    pgrep -f "flutter_tools\\.snapshot run -d ${DEVICE}" >/dev/null 2>&1 || break
    sleep 0.5
  done
}

prepare_log() {
  [[ -L "$LOG" || -d "$LOG" ]] && rm -rf "$LOG"
  [[ -L "$PIDFILE" || -d "$PIDFILE" ]] && rm -rf "$PIDFILE"
  rm -f "$PIDFILE" "$LOG.prebuilt"
  mkdir -p "$(dirname "$LOG")"
  : >"$LOG"
}

# So agent_tap / agent_seed find this worktree log without an explicit --log.
mark_active_log() {
  [[ "$DEVICE" == "$MINI" ]] || return 0
  python3 "$ROOT/tools/flutter_active_log.py" set "$LOG" >/dev/null
}

# New session so agent shells that kill their process group on exit (Cursor
# tool calls) do not take the app session down with them.
start_flutter() {
  mark_active_log
  FLUTTER_PID="$(
    python3 - "$LOG" "$CHECKOUT" "$FLUTTER_BIN" run -d "$DEVICE" \
      --pid-file "$PIDFILE" "$@" <<'PY'
import subprocess
import sys

log, cwd, *cmd = sys.argv[1:]
with open(log, "ab") as out:
    proc = subprocess.Popen(
        cmd,
        cwd=cwd,
        stdin=subprocess.DEVNULL,
        stdout=out,
        stderr=subprocess.STDOUT,
        start_new_session=True,
    )
print(proc.pid)
PY
  )"
}

prune_cache() {
  local extra
  mkdir -p "$CACHE_DIR"
  # Newest first; keep CACHE_KEEP complete entries.
  # shellcheck disable=SC2012
  ls -1t "$CACHE_DIR" 2>/dev/null | grep -v '\.tmp\.' | tail -n +"$((CACHE_KEEP + 1))" |
    while IFS= read -r extra; do
      rm -rf "${CACHE_DIR:?}/$extra"
    done
}

populate_cache() {
  local key="$1" src dest tmp
  src="$CHECKOUT/build/ios/iphonesimulator/Runner.app"
  [[ -d "$src" ]] || { echo "cache: no $src to save"; return 0; }
  dest="$CACHE_DIR/$key"
  tmp="$dest.tmp.$$"
  mkdir -p "$CACHE_DIR"
  rm -rf "$tmp"
  mkdir -p "$tmp"
  ditto "$src" "$tmp/Runner.app"
  rm -rf "$dest"
  mv "$tmp" "$dest"
  prune_cache
  echo "cache: saved Runner.app for native key $key"
}

if [[ "$MODE" == "populate" ]]; then
  wait_until "$TIMEOUT" log_ready && populate_cache "$KEY"
  exit 0
fi

KEY="$(python3 "$ROOT/tools/native_build_key.py" "$CHECKOUT")"
APP="$CACHE_DIR/$KEY/Runner.app"

stop_device_flutter
prepare_log

# Worktrees live under the primary checkout. Without their own
# .dart_tool/package_config.json, a prebuilt run (no build step) resolves the
# primary's package config and the tool crashes. pub get is ~2 s when warm.
(cd "$CHECKOUT" && "$FLUTTER_BIN" pub get >/dev/null 2>&1) ||
  echo "warning: flutter pub get failed in $CHECKOUT"

if [[ "$USE_CACHE" == "1" && -d "$APP" ]]; then
  echo "prebuilt: native key $KEY cached; skipping Xcode for $CHECKOUT"
  touch "$LOG.prebuilt"
  start_flutter --use-application-binary "$APP"
  code=0
  wait_until "$PREBUILT_VM_WAIT" signal_ready || code=$?
  if [[ "$code" == 0 ]]; then
    # The cached app boots its bundled Dart; restart onto the synced checkout.
    kill -USR2 "$(tr -d '[:space:]' <"$PIDFILE")" 2>/dev/null || true
    wait_until "$PREBUILT_RESTART_WAIT" restarted || code=$?
  fi
  if [[ "$code" == 0 ]]; then
    rm -f "$LOG.prebuilt"
    echo "ready: $CHECKOUT on $DEVICE via cached Runner.app (log $LOG)"
    exit 0
  fi
  # A good full build below overwrites this cache entry.
  echo "prebuilt launch failed (code $code); falling back to a full build"
  tail -n 20 "$LOG" 2>/dev/null | sed 's/^/  /' || true
  stop_device_flutter
  prepare_log
fi

echo "build: native key $KEY not cached; full flutter run for $CHECKOUT"
python3 "$ROOT/tools/disk_guard.py" --quiet || true
start_flutter
code=0
wait_until "$TIMEOUT" log_ready || code=$?
if [[ "$code" == 0 ]]; then
  [[ "$USE_CACHE" == "1" ]] && populate_cache "$KEY"
  echo "ready: $CHECKOUT on $DEVICE (log $LOG)"
  exit 0
fi
if [[ "$code" == 1 && "$USE_CACHE" == "1" ]] && flutter_alive; then
  python3 -c 'import subprocess, sys; subprocess.Popen(sys.argv[1:], stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)' \
    "$SELF" --populate-key "$KEY" --checkout "$CHECKOUT" --log "$LOG" \
    --pid-file "$PIDFILE" --device "$DEVICE" --timeout 1800
fi
echo "timeout: no Dart VM in $LOG after ${TIMEOUT}s (code $code)" >&2
tail -n 20 "$LOG" 2>/dev/null | sed 's/^/  /' >&2 || true
exit 1
