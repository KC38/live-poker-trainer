---
name: launch-simulator
description: >-
  Boot the iPhone 13 mini and launch the latest origin/main build when it is
  not already running. Resolve the UDID via tools/iphone_13_mini_udid.sh —
  never hardcode it. If the mini is already up, refresh only that device.
---

# Launch the iPhone 13 mini simulator

Boot the **iPhone 13 mini** and start the latest `origin/main` on it. This
repo uses that one simulator only. Resolve its UDID each time:

```bash
DEVICE="$(tools/iphone_13_mini_udid.sh)"
```

Do not hardcode a UDID. Do not target any other simulator.

If the mini is already booted, or a `flutter run` is already up on it, follow
[simulator-refresh](../simulator-refresh/SKILL.md).

## 1. Check

```bash
DEVICE="$(tools/iphone_13_mini_udid.sh)"
xcrun simctl list devices booted
pgrep -fl "flutter_tools\\.snapshot run -d ${DEVICE}" || true
```

Mini booted, or `flutter run -d` that UDID → `refresh-simulator.sh`.
Continue below when the mini is shut down and no flutter run targets it.

## 2. Latest origin/main

Launch from the primary clone, not a feature worktree. Resolve the path
(machines use `~/live-poker-trainer` or `~/live_poker_trainer`):

```bash
PRIMARY="$(tools/primary_checkout.sh)"
cd "$PRIMARY"
git fetch origin main
git checkout main
git pull --ff-only origin main
```

If that checkout is dirty, on another branch, or will not fast-forward, stop
and report. Do not reset, stash, or add a worktree.

Copy gitignored Firebase files into that clone when they are missing:

- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist`
- `android/app/google-services.json`

## 3. Boot the mini and run

Xcode 27 has no `Simulator.app`. Open **Device Hub**:

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin:$PATH"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

DEVICE="$(tools/iphone_13_mini_udid.sh)"
PRIMARY="$(tools/primary_checkout.sh)"
SESSION=flutter-iphone-13-mini

open -a /Applications/Xcode.app/Contents/Applications/DeviceHub.app
xcrun simctl bootstatus "$DEVICE" -b || xcrun simctl boot "$DEVICE"
```

Drive only that UDID. Do not `simctl boot`, `uninstall`, `terminate`, or
`flutter run -d` any other simulator.

If `ios/Podfile.lock` and `ios/Pods/Manifest.lock` differ, `pod install` in
`ios/` before running. Put the long `flutter run` in tmux:

```bash
tmux has-session -t "$SESSION" 2>/dev/null || tmux new-session -d -s "$SESSION"
tmux send-keys -t "$SESSION" "cd '$PRIMARY' && flutter run -d $DEVICE --pid-file /tmp/flutter-live-poker-trainer.pid 2>&1 | tee /tmp/flutter-live-poker-trainer.run.log; echo EXIT:\$?" Enter
```

Wait until the log shows `Dart VM Service on iPhone 13 mini` or
`Flutter run key commands`. The first build can take several minutes. Pid
and log stay on those `/tmp` paths because `tools/agent_tap.py` reads them
by default.

Device Hub, Podfile, and Xcode failures:
[docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md).

A screenshot used to confirm launch goes in `.cursor/tmp/`. Delete it after
you have read it.

Report the `origin/main` SHA, the resolved UDID, and whether the session
reached the Dart VM service.
