#!/usr/bin/env bash
# Refresh Flutter apps on booted iOS simulators from origin/main.
# Always the primary clone. Never a worktree.
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin:${PATH:-}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

PRIMARY="${PRIMARY:-$HOME/live-poker-trainer}"
PID_FILE="${FLUTTER_PID_FILE:-/tmp/flutter-live-poker-trainer.pid}"

if [[ ! -f "$PRIMARY/pubspec.yaml" ]]; then
  echo "abort: no pubspec.yaml in $PRIMARY"
  exit 1
fi

git -C "$PRIMARY" fetch origin main
branch="$(git -C "$PRIMARY" rev-parse --abbrev-ref HEAD)"
if [[ "$branch" != "main" ]]; then
  echo "abort: $PRIMARY is on '$branch', not main. Refresh uses origin/main. Do not use a worktree."
  exit 1
fi
if [[ -n "$(git -C "$PRIMARY" status --porcelain)" ]]; then
  echo "abort: $PRIMARY has uncommitted changes. Refresh uses origin/main. Do not use a worktree."
  exit 1
fi
git -C "$PRIMARY" pull --ff-only origin main
echo "origin/main $(git -C "$PRIMARY" rev-parse --short HEAD) at $PRIMARY"
cd "$PRIMARY"

command -v flutter >/dev/null 2>&1 || {
  echo "skip: flutter not on PATH"
  exit 0
}

hot_restart_pid() {
  local pid="$1"
  if kill -0 "$pid" 2>/dev/null; then
    kill -USR2 "$pid"
    echo "hot-restarted flutter pid $pid"
    return 0
  fi
  return 1
}

# Hot-restart only sessions already running from the primary clone.
# A worktree session cannot become origin/main via hot restart — stop it.
primary_root="$(cd "$PRIMARY" && pwd -P)"
is_primary_checkout() {
  local pid="$1" cwd top resolved
  cwd="$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | awk '/^n/ {print substr($0,2); exit}')"
  [[ -n "$cwd" ]] || return 1
  top="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -n "$top" ]] || return 1
  resolved="$(cd "$top" && pwd -P)"
  [[ "$resolved" == "$primary_root" ]]
}

restarted=0
while IFS= read -r pid; do
  [[ -z "$pid" ]] && continue
  if is_primary_checkout "$pid"; then
    if hot_restart_pid "$pid"; then
      restarted=$((restarted + 1))
    fi
  elif kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    echo "stopped non-primary flutter pid $pid (not origin/main)"
  fi
done < <(
  pgrep -f 'flutter_tools\.snapshot run -d [A-Fa-f0-9-]{36}' 2>/dev/null || true
)

# Also honor known pid-files (covers sessions whose cmdline shape differs).
for file in \
  "$PID_FILE" \
  /tmp/flutter-live-poker-trainer.pid \
  /tmp/flutter-live-poker-trainer-user.pid
do
  [[ -f "$file" ]] || continue
  pid="$(cat "$file" 2>/dev/null || true)"
  [[ -n "${pid:-}" ]] || continue
  if is_primary_checkout "$pid"; then
    if hot_restart_pid "$pid"; then
      restarted=$((restarted + 1))
    else
      rm -f "$file"
    fi
  elif kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    rm -f "$file"
    echo "stopped non-primary flutter pid $pid (not origin/main)"
  else
    rm -f "$file"
  fi
done

if [[ "$restarted" -gt 0 ]]; then
  echo "hot-restarted $restarted flutter run session(s) across sims"
  exit 0
fi

EXISTING_PID="$(pgrep -f "flutter_tools\.snapshot run" 2>/dev/null | head -n 1 || true)"
if [[ -n "$EXISTING_PID" ]]; then
  echo "skip-start: flutter run already active (pid $EXISTING_PID); press R in that terminal"
  exit 0
fi

DEVICE_ID="$(
  flutter devices --machine 2>/dev/null | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ios, android, macos, other = [], [], [], []
for d in data:
    did = d.get("id") or ""
    if not did:
        continue
    platform = (d.get("targetPlatform") or "").lower()
    if "ios" in platform:
        ios.append(did)
    elif platform.startswith("android"):
        android.append(did)
    elif did == "macos":
        macos.append(did)
    else:
        other.append(did)
for group in (ios, android, macos, other):
    if group:
        print(group[0])
        break
'
)"

if [[ -z "${DEVICE_ID:-}" ]]; then
  echo "skip: no Flutter device/simulator available"
  exit 0
fi

echo "starting flutter run on $DEVICE_ID (pid-file $PID_FILE)"
flutter pub get
if [[ "${SHIP_FLUTTER_FOREGROUND:-}" == "1" ]]; then
  exec flutter run -d "$DEVICE_ID" --pid-file "$PID_FILE"
fi

nohup flutter run -d "$DEVICE_ID" --pid-file "$PID_FILE" \
  >"/tmp/flutter-live-poker-trainer.run.log" 2>&1 &
echo "started pid $! (log: /tmp/flutter-live-poker-trainer.run.log)"
