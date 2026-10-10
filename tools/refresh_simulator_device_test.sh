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
  "$ROOT/.cursor/commands/ui-design-agent.md" \
  "$ROOT/docs/agent-ios-simulator.md" >/dev/null
then
  fail "hard-coded legacy simulator UDIDs still present"
fi

if grep -E 'iPhone 17|Pro Max|iphone17-main|flutter-pro-lessons|flutter-ui-pro-max' \
  "$REFRESH" \
  "$ROOT/.cursor/skills/launch-simulator/SKILL.md" \
  "$ROOT/.cursor/skills/simulator-refresh/SKILL.md" \
  "$ROOT/.cursor/commands/ui-design-agent.md" \
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

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/refresh-ios-dirt.XXXXXX")"
cleanup_tmpdir() { rm -rf "$tmpdir"; }
trap cleanup_tmpdir EXIT

git -C "$tmpdir" init -q
git -C "$tmpdir" config user.email "test@example.com"
git -C "$tmpdir" config user.name "test"
mkdir -p \
  "$tmpdir/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata" \
  "$tmpdir/ios/Runner.xcworkspace/xcshareddata"
printf 'PODS:\n  - keep-me\n' >"$tmpdir/ios/Podfile.lock"
printf '// keep pbx\n' >"$tmpdir/ios/Runner.xcodeproj/project.pbxproj"
git -C "$tmpdir" add ios/Podfile.lock ios/Runner.xcodeproj/project.pbxproj
git -C "$tmpdir" commit -qm "seed"

printf 'PODS:\n  - wiped\n' >"$tmpdir/ios/Podfile.lock"
printf '// wiped pbx\n' >"$tmpdir/ios/Runner.xcodeproj/project.pbxproj"
mkdir -p \
  "$tmpdir/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm" \
  "$tmpdir/ios/Runner.xcworkspace/xcshareddata/swiftpm"
printf '{}\n' >"$tmpdir/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
printf '{}\n' >"$tmpdir/ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved"

discard_ios_machine_dirt "$tmpdir" >/dev/null
grep -q 'keep-me' "$tmpdir/ios/Podfile.lock" || fail "Podfile.lock not restored"
grep -q 'keep pbx' "$tmpdir/ios/Runner.xcodeproj/project.pbxproj" \
  || fail "project.pbxproj not restored"
[[ ! -e "$tmpdir/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm" ]] \
  || fail "project.xcworkspace swiftpm not removed"
[[ ! -e "$tmpdir/ios/Runner.xcworkspace/xcshareddata/swiftpm" ]] \
  || fail "Runner.xcworkspace swiftpm not removed"

logdir="$(mktemp -d "${TMPDIR:-/tmp}/flutter-log.XXXXXX")"
ln -s /nonexistent "$logdir/run.log"
mkdir "$logdir/app.pid"
prepare_flutter_log "$logdir/run.log" "$logdir/app.pid"
[[ -f "$logdir/run.log" && ! -L "$logdir/run.log" ]] || fail "stale log symlink not replaced"
[[ ! -e "$logdir/app.pid" ]] || fail "pid directory not removed"
rm -rf "$logdir"

# Resilient pub get: succeeds on a later attempt after a killed first call.
fake_bin="$(mktemp -d "${TMPDIR:-/tmp}/fake-flutter.XXXXXX")"
cat >"$fake_bin/flutter" <<'EOF'
#!/usr/bin/env bash
state_dir="${FAKE_FLUTTER_STATE:?}"
n=0
[[ -f "$state_dir/n" ]] && n="$(cat "$state_dir/n")"
n=$((n + 1))
echo "$n" >"$state_dir/n"
if [[ "$n" -lt 3 ]]; then
  echo "fake flutter pub get killed" >&2
  exit 143
fi
echo "fake flutter pub get ok"
exit 0
EOF
chmod +x "$fake_bin/flutter"
export PATH="$fake_bin:$PATH"
export FAKE_FLUTTER_STATE="$(mktemp -d "${TMPDIR:-/tmp}/fake-flutter-state.XXXXXX")"
export FLUTTER_PUB_GET_LOCK_WAIT=0
export FLUTTER_PUB_GET_ATTEMPTS=4
flutter_pub_get_resilient >/dev/null \
  || fail "flutter_pub_get_resilient should succeed after retries"
[[ "$(cat "$FAKE_FLUTTER_STATE/n")" == 3 ]] \
  || fail "expected three fake flutter invocations"
rm -rf "$fake_bin" "$FAKE_FLUTTER_STATE"

echo "iphone 13 mini simulator helpers ok (udid=$udid)"
