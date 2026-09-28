#!/usr/bin/env bash
# The refresh script must target one skill's simulator and ignore the other.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh"

export REFRESH_SIMULATOR_SOURCE_ONLY=1
# shellcheck disable=SC1090
source "$SCRIPT"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

cmdline_targets_device \
  "dartvm flutter_tools.snapshot run -d ${QA_DEVICE} --pid-file /tmp/flutter-live-poker-trainer.pid" \
  "$QA_DEVICE" || fail "Pro command should match qa"

if cmdline_targets_device \
  "dartvm flutter_tools.snapshot run -d ${IMPLEMENT_DEVICE}" \
  "$QA_DEVICE"
then
  fail "iPhone 17 command must not match the Pro"
fi

selected="$(
  printf '%s\t%s\n' \
    11 "flutter_tools.snapshot run -d ${QA_DEVICE}" \
    22 "flutter_tools.snapshot run -d ${IMPLEMENT_DEVICE}" \
    | select_device_pids "$QA_DEVICE"
)"
[[ "$selected" == "11" ]] || fail "qa select returned '$selected'"

selected="$(
  printf '%s\t%s\n' \
    11 "flutter_tools.snapshot run -d ${QA_DEVICE}" \
    22 "flutter run -d ${IMPLEMENT_DEVICE}" \
    | select_device_pids "$IMPLEMENT_DEVICE"
)"
[[ "$selected" == "22" ]] || fail "implement select returned '$selected'"

resolve_role qa
[[ "$DEVICE_ID" == "$QA_DEVICE" ]] || fail "qa device"
[[ "$CHECKOUT_KIND" == "primary" ]] || fail "qa checkout"
[[ "$PID_FILE" == "/tmp/flutter-live-poker-trainer.pid" ]] || fail "qa pid file"
[[ "$LOG_FILE" == "/tmp/flutter-live-poker-trainer.run.log" ]] || fail "qa log"

resolve_role implement
[[ "$DEVICE_ID" == "$IMPLEMENT_DEVICE" ]] || fail "implement device"
[[ "$CHECKOUT_KIND" == "iphone17-main" ]] || fail "implement checkout"
[[ "$PID_FILE" == "/tmp/flutter-live-poker-trainer-iphone17.pid" ]] || fail "implement pid"
[[ "$LOG_FILE" == "/tmp/flutter-live-poker-trainer-iphone17.run.log" ]] || fail "implement log"
[[ " ${EXTRA_PID_FILES[*]} " == *" /tmp/flutter-live-poker-trainer-user.pid "* ]] || fail "legacy pid"

if resolve_role both; then
  fail "missing role should fail"
fi

echo "refresh device isolation ok"
