#!/usr/bin/env bash
# Refresh the iPhone 13 mini simulator from origin/main (primary clone).
#
# Resolves the device UDID via tools/iphone_13_mini_udid.sh (never hardcoded).
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin:${PATH:-}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# refresh lives at .cursor/skills/simulator-refresh/scripts/
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
# shellcheck source=../../../../tools/iphone_13_mini_udid.sh
source "$REPO_ROOT/tools/iphone_13_mini_udid.sh"
# shellcheck source=../../../../tools/primary_checkout.sh
source "$REPO_ROOT/tools/primary_checkout.sh"

cmdline_targets_device() {
  local cmd="$1" device="$2"
  [[ "$cmd" == *"flutter_tools.snapshot run -d ${device}"* || "$cmd" == *"flutter run -d ${device}"* ]]
}

# Xcode / CocoaPods noise that appears in the primary clone and is never
# intentional agent work. Discard before requiring a clean tree.
discard_ios_machine_dirt() {
  local dir="$1"
  local restored=0 removed=0
  local path
  for path in \
    ios/Podfile.lock \
    ios/Runner.xcodeproj/project.pbxproj
  do
    if ! git -C "$dir" diff --quiet -- "$path" 2>/dev/null ||
      ! git -C "$dir" diff --cached --quiet -- "$path" 2>/dev/null
    then
      git -C "$dir" checkout -- "$path"
      restored=$((restored + 1))
    fi
  done
  for path in \
    ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm \
    ios/Runner.xcworkspace/xcshareddata/swiftpm
  do
    # Untracked Xcode SPM metadata only — never delete tracked paths.
    if [[ -e "$dir/$path" && -z "$(git -C "$dir" ls-files -- "$path")" ]]; then
      rm -rf "$dir/$path"
      removed=$((removed + 1))
    fi
  done
  if [[ "$restored" -gt 0 || "$removed" -gt 0 ]]; then
    echo "discarded iOS machine dirt (restored=$restored removed=$removed) in $dir"
  fi
}

if [[ "${REFRESH_SIMULATOR_SOURCE_ONLY:-}" == "1" ]]; then
  return 0 2>/dev/null || exit 0
fi

DEVICE_ID="$(resolve_iphone_13_mini_udid)"
PID_FILE="/tmp/flutter-live-poker-trainer.pid"
LOG_FILE="/tmp/flutter-live-poker-trainer.run.log"
PRIMARY="$(resolve_primary_checkout)"

copy_firebase() {
  local src="$1" dest="$2" rel
  for rel in \
    lib/firebase_options.dart \
    ios/Runner/GoogleService-Info.plist \
    android/app/google-services.json
  do
    if [[ ! -f "$dest/$rel" && -f "$src/$rel" ]]; then
      mkdir -p "$(dirname "$dest/$rel")"
      cp "$src/$rel" "$dest/$rel"
    fi
  done
}

ensure_clean_ff() {
  local dir="$1" label="$2"
  local branch
  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
  if [[ "$branch" != "main" ]]; then
    echo "abort: $dir is on '$branch', not main. Refresh uses origin/main."
    exit 1
  fi
  discard_ios_machine_dirt "$dir"
  if [[ -n "$(git -C "$dir" status --porcelain)" ]]; then
    echo "abort: $dir has uncommitted changes. Refresh uses origin/main."
    exit 1
  fi
  git -C "$dir" merge --ff-only origin/main
  echo "origin/main $(git -C "$dir" rev-parse --short HEAD) at $label"
}

git -C "$PRIMARY" fetch origin main
ensure_clean_ff "$PRIMARY" "$PRIMARY"
CHECKOUT="$PRIMARY"
copy_firebase "$PRIMARY" "$CHECKOUT"

cd "$CHECKOUT"

command -v flutter >/dev/null 2>&1 || {
  echo "skip: flutter not on PATH"
  exit 0
}

hot_restart_pid() {
  local pid="$1"
  if kill -0 "$pid" 2>/dev/null; then
    kill -USR2 "$pid"
    echo "hot-restarted flutter pid $pid on iPhone 13 mini ($DEVICE_ID)"
    return 0
  fi
  return 1
}

is_checkout() {
  local pid="$1" cwd top resolved want
  cwd="$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | awk '/^n/ {print substr($0,2); exit}')"
  [[ -n "$cwd" ]] || return 1
  top="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -n "$top" ]] || return 1
  resolved="$(cd "$top" && pwd -P)"
  want="$(cd "$CHECKOUT" && pwd -P)"
  [[ "$resolved" == "$want" ]]
}

pid_targets_device() {
  local pid="$1" cmd
  cmd="$(ps -p "$pid" -o args= 2>/dev/null || true)"
  cmdline_targets_device "$cmd" "$DEVICE_ID"
}

HANDLED=" "
restarted=0
handle_pid() {
  local pid="$1"
  [[ " ${HANDLED} " == *" ${pid} "* ]] && return 0
  HANDLED="${HANDLED} ${pid}"
  pid_targets_device "$pid" || return 0
  if is_checkout "$pid"; then
    if hot_restart_pid "$pid"; then
      restarted=$((restarted + 1))
    fi
  elif kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    echo "stopped flutter pid $pid (not the origin/main checkout)"
  fi
}

while IFS= read -r pid; do
  [[ -z "$pid" ]] && continue
  handle_pid "$pid"
done < <(pgrep -f 'flutter_tools\.snapshot run -d' 2>/dev/null || true)

if [[ -f "$PID_FILE" ]]; then
  pid="$(tr -d '[:space:]' <"$PID_FILE" 2>/dev/null || true)"
  if [[ -n "${pid:-}" ]]; then
    if pid_targets_device "$pid"; then
      handle_pid "$pid"
    fi
    if ! kill -0 "$pid" 2>/dev/null; then
      rm -f "$PID_FILE"
    fi
  fi
fi

if [[ "$restarted" -gt 0 ]]; then
  echo "hot-restarted $restarted flutter run session(s) on iPhone 13 mini"
  exit 0
fi

if pgrep -f "flutter_tools\\.snapshot run -d ${DEVICE_ID}" >/dev/null 2>&1; then
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    pgrep -f "flutter_tools\\.snapshot run -d ${DEVICE_ID}" >/dev/null 2>&1 || break
    sleep 0.5
  done
fi
if pgrep -f "flutter_tools\\.snapshot run -d ${DEVICE_ID}" >/dev/null 2>&1; then
  echo "skip-start: a flutter run is still active on $DEVICE_ID"
  exit 0
fi

open -a /Applications/Xcode.app/Contents/Applications/DeviceHub.app 2>/dev/null || true
if ! xcrun simctl bootstatus "$DEVICE_ID" -b >/dev/null 2>&1; then
  xcrun simctl boot "$DEVICE_ID" >/dev/null 2>&1 || true
fi

echo "starting flutter run on iPhone 13 mini ($DEVICE_ID) from $CHECKOUT (pid-file $PID_FILE)"
flutter pub get
if [[ "${SHIP_FLUTTER_FOREGROUND:-}" == "1" ]]; then
  exec flutter run -d "$DEVICE_ID" --pid-file "$PID_FILE"
fi

nohup flutter run -d "$DEVICE_ID" --pid-file "$PID_FILE" >"$LOG_FILE" 2>&1 &
echo "started pid $! device=$DEVICE_ID log=$LOG_FILE"
