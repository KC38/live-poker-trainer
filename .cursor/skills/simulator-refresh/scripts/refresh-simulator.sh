#!/usr/bin/env bash
# Refresh one skill's simulator from origin/main.
#
# qa        → iPhone 17 Pro, primary clone (new-user-qa)
# implement → iPhone 17, .worktrees/iphone17-main (implement-open-jira)
#
# The other device's flutter run is left running. A second checkout is used
# for the iPhone 17 origin/main session so it does not share build/ with the
# Pro session in ~/live-poker-trainer.
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin:${PATH:-}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

QA_DEVICE="F1AE4938-D9BE-4EA1-8C98-58555A0DE62A"
IMPLEMENT_DEVICE="20ACECD5-FBEE-4663-9044-E11D5F0A26FC"

cmdline_targets_device() {
  local cmd="$1" device="$2"
  [[ "$cmd" == *"flutter_tools.snapshot run -d ${device}"* || "$cmd" == *"flutter run -d ${device}"* ]]
}

select_device_pids() {
  local device="$1" pid cmd
  while IFS=$'\t' read -r pid cmd; do
    [[ -n "${pid:-}" ]] || continue
    if cmdline_targets_device "$cmd" "$device"; then
      printf '%s\n' "$pid"
    fi
  done
}

resolve_role() {
  local role="$1"
  EXTRA_PID_FILES=()
  case "$role" in
    qa)
      DEVICE_ID="$QA_DEVICE"
      PID_FILE="/tmp/flutter-live-poker-trainer.pid"
      LOG_FILE="/tmp/flutter-live-poker-trainer.run.log"
      CHECKOUT_KIND="primary"
      ;;
    implement)
      DEVICE_ID="$IMPLEMENT_DEVICE"
      PID_FILE="/tmp/flutter-live-poker-trainer-iphone17.pid"
      LOG_FILE="/tmp/flutter-live-poker-trainer-iphone17.run.log"
      CHECKOUT_KIND="iphone17-main"
      EXTRA_PID_FILES=(/tmp/flutter-live-poker-trainer-user.pid)
      ;;
    *)
      echo "usage: refresh-simulator.sh qa|implement" >&2
      return 2
      ;;
  esac
}

if [[ "${REFRESH_SIMULATOR_SOURCE_ONLY:-}" == "1" ]]; then
  return 0 2>/dev/null || exit 0
fi

ROLE="${1:-}"
resolve_role "$ROLE"

PRIMARY="${PRIMARY:-$HOME/live-poker-trainer}"

if [[ ! -f "$PRIMARY/pubspec.yaml" ]]; then
  echo "abort: no pubspec.yaml in $PRIMARY"
  exit 1
fi

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
  if [[ "$CHECKOUT_KIND" == "primary" && "$branch" != "main" ]]; then
    echo "abort: $dir is on '$branch', not main. Refresh uses origin/main."
    exit 1
  fi
  if [[ -n "$(git -C "$dir" status --porcelain)" ]]; then
    echo "abort: $dir has uncommitted changes. Refresh uses origin/main."
    exit 1
  fi
  git -C "$dir" merge --ff-only origin/main
  echo "origin/main $(git -C "$dir" rev-parse --short HEAD) at $label"
}

git -C "$PRIMARY" fetch origin main

if [[ "$CHECKOUT_KIND" == "primary" ]]; then
  ensure_clean_ff "$PRIMARY" "$PRIMARY"
  CHECKOUT="$PRIMARY"
else
  CHECKOUT="$PRIMARY/.worktrees/iphone17-main"
  git -C "$PRIMARY" worktree prune
  if [[ ! -e "$CHECKOUT/.git" ]]; then
    mkdir -p "$PRIMARY/.worktrees"
    git -C "$PRIMARY" worktree add --detach "$CHECKOUT" origin/main
  fi
  git -C "$CHECKOUT" fetch origin main
  ensure_clean_ff "$CHECKOUT" "$CHECKOUT"
  copy_firebase "$PRIMARY" "$CHECKOUT"
fi

cd "$CHECKOUT"

command -v flutter >/dev/null 2>&1 || {
  echo "skip: flutter not on PATH"
  exit 0
}

hot_restart_pid() {
  local pid="$1"
  if kill -0 "$pid" 2>/dev/null; then
    kill -USR2 "$pid"
    echo "hot-restarted flutter pid $pid on $ROLE ($DEVICE_ID)"
    return 0
  fi
  return 1
}

is_role_checkout() {
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
  if is_role_checkout "$pid"; then
    if hot_restart_pid "$pid"; then
      restarted=$((restarted + 1))
    fi
  elif kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    echo "stopped flutter pid $pid (not the $ROLE origin/main checkout)"
  fi
}

while IFS= read -r pid; do
  [[ -z "$pid" ]] && continue
  handle_pid "$pid"
done < <(pgrep -f 'flutter_tools\.snapshot run -d' 2>/dev/null || true)

pid_files=("$PID_FILE")
if [[ "${#EXTRA_PID_FILES[@]}" -gt 0 ]]; then
  pid_files+=("${EXTRA_PID_FILES[@]}")
fi
for file in "${pid_files[@]}"; do
  [[ -f "$file" ]] || continue
  pid="$(tr -d '[:space:]' <"$file" 2>/dev/null || true)"
  [[ -n "${pid:-}" ]] || continue
  if pid_targets_device "$pid"; then
    handle_pid "$pid"
  fi
  if ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$file"
  fi
done

if [[ "$restarted" -gt 0 ]]; then
  echo "hot-restarted $restarted $ROLE flutter run session(s)"
  exit 0
fi

if pgrep -f "flutter_tools\\.snapshot run -d ${DEVICE_ID}" >/dev/null 2>&1; then
  # A session we just stopped can still be exiting. Wait before starting
  # another flutter run on the same device.
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    pgrep -f "flutter_tools\\.snapshot run -d ${DEVICE_ID}" >/dev/null 2>&1 || break
    sleep 0.5
  done
fi
if pgrep -f "flutter_tools\\.snapshot run -d ${DEVICE_ID}" >/dev/null 2>&1; then
  echo "skip-start: a $ROLE flutter run is still active on $DEVICE_ID"
  exit 0
fi

if ! xcrun simctl bootstatus "$DEVICE_ID" -b >/dev/null 2>&1; then
  xcrun simctl boot "$DEVICE_ID" >/dev/null 2>&1 || true
fi

echo "starting flutter run on $DEVICE_ID from $CHECKOUT (pid-file $PID_FILE)"
flutter pub get
if [[ "${SHIP_FLUTTER_FOREGROUND:-}" == "1" ]]; then
  exec flutter run -d "$DEVICE_ID" --pid-file "$PID_FILE"
fi

nohup flutter run -d "$DEVICE_ID" --pid-file "$PID_FILE" >"$LOG_FILE" 2>&1 &
echo "started pid $! role=$ROLE log=$LOG_FILE"
