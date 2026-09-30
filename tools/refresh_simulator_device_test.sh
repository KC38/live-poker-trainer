#!/usr/bin/env bash
# UDID resolver and refresh helpers target the iPhone 13 mini only.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UDID_SCRIPT="$ROOT/tools/iphone_13_mini_udid.sh"
PRIMARY_SCRIPT="$ROOT/tools/primary_checkout.sh"
REFRESH="$ROOT/.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

udid="$("$UDID_SCRIPT")"
[[ "$udid" =~ ^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$ ]] \
  || fail "resolver returned non-UDID: $udid"

primary="$("$PRIMARY_SCRIPT")"
[[ -f "$primary/pubspec.yaml" ]] || fail "primary_checkout missing pubspec: $primary"
case "$primary" in
  */live-poker-trainer|*/live_poker_trainer) ;;
  *) fail "primary_checkout unexpected path: $primary" ;;
esac

# Must not embed legacy hard-coded device IDs.
if grep -E 'F1AE4938|20ACECD5|7CB7DDCF' "$REFRESH" "$UDID_SCRIPT" \
  "$ROOT/.cursor/skills/launch-simulator/SKILL.md" \
  "$ROOT/.cursor/skills/simulator-refresh/SKILL.md" \
  "$ROOT/.cursor/commands/implement-open-jira.md" \
  "$ROOT/docs/agent-ios-simulator.md" >/dev/null
then
  fail "hard-coded legacy simulator UDIDs still present"
fi

if grep -E 'iPhone 17|Pro Max|iphone17-main|flutter-pro-lessons|flutter-ui-pro-max' \
  "$REFRESH" \
  "$ROOT/.cursor/skills/launch-simulator/SKILL.md" \
  "$ROOT/.cursor/skills/simulator-refresh/SKILL.md" \
  "$ROOT/.cursor/commands/implement-open-jira.md" \
  "$ROOT/docs/agent-ios-simulator.md" >/dev/null
then
  fail "legacy multi-simulator wording still present"
fi

export REFRESH_SIMULATOR_SOURCE_ONLY=1
# shellcheck disable=SC1090
source "$REFRESH"

other="00000000-0000-0000-0000-000000000000"
cmdline_targets_device \
  "dartvm flutter_tools.snapshot run -d ${udid} --pid-file /tmp/flutter-live-poker-trainer.pid" \
  "$udid" || fail "mini command should match"

if cmdline_targets_device \
  "dartvm flutter_tools.snapshot run -d ${other}" \
  "$udid"
then
  fail "other device command must not match the mini"
fi

echo "iphone 13 mini simulator helpers ok (udid=$udid)"
