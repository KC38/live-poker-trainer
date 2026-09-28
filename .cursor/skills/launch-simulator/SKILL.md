---
name: launch-simulator
description: >-
  Boot the new-user-qa iPhone 17 Pro and launch the latest origin/main
  build when that Pro is not already running. A booted iPhone 17 does not
  count. If the Pro is already up, refresh only that device.
---

# Launch the new-user-qa simulator

Boot the iPhone 17 Pro and start the latest `origin/main` on it. This is
the [new-user-qa](../new-user-qa/SKILL.md) device.

The iPhone 17 (`20ACECD5-FBEE-4663-9044-E11D5F0A26FC`) belongs to
[implement-open-jira](../implement-open-jira/SKILL.md). A booted iPhone 17,
or a flutter run on it, is not "a simulator is already running" for this
skill. Do not refresh it, stop it, or skip booting the Pro because of it.

If the Pro is already booted, or a Pro `flutter run` is already up, follow
[simulator-refresh](../simulator-refresh/SKILL.md) for `qa` only.

## 1. Check

```bash
xcrun simctl list devices booted
pgrep -fl 'flutter_tools\.snapshot run -d F1AE4938-D9BE-4EA1-8C98-58555A0DE62A' || true
```

The Pro booted, or `flutter run -d F1AE4938-…` → `refresh-simulator.sh qa`.
Continue below when the Pro is shut down and no Pro flutter run exists,
even if the iPhone 17 is in that booted list.

## 2. Latest origin/main

Launch from the primary clone (`~/live-poker-trainer`), not a feature worktree.

```bash
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

## 3. Boot the Pro and run

Xcode 27 has no `Simulator.app`. Open **Device Hub**:

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin:$PATH"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

PRO=F1AE4938-D9BE-4EA1-8C98-58555A0DE62A
PRIMARY="$HOME/live-poker-trainer"
SESSION=flutter-pro-lessons

open -a /Applications/Xcode.app/Contents/Applications/DeviceHub.app
xcrun simctl bootstatus "$PRO" -b || xcrun simctl boot "$PRO"
```

Drive only that Pro UDID. Do not `simctl boot`, `uninstall`, `terminate`,
or `flutter run -d` the iPhone 17.

If `ios/Podfile.lock` and `ios/Pods/Manifest.lock` differ, `pod install` in
`ios/` before running. Put the long `flutter run` in tmux:

```bash
tmux has-session -t "$SESSION" 2>/dev/null || tmux new-session -d -s "$SESSION"
tmux send-keys -t "$SESSION" "cd '$PRIMARY' && flutter run -d $PRO --pid-file /tmp/flutter-live-poker-trainer.pid 2>&1 | tee /tmp/flutter-live-poker-trainer.run.log; echo EXIT:\$?" Enter
```

Wait until the log shows `Dart VM Service on iPhone 17 Pro` or
`Flutter run key commands`. The first build can take several minutes. Pid
and log stay on those `/tmp` paths because `tools/agent_tap.py` reads them
by default. Do not point this session at the iPhone 17 log.

Device Hub, Podfile, and Xcode failures:
[docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md).

A screenshot used to confirm launch goes in `.cursor/tmp/`. Delete it after
you have read it.

Report the `origin/main` SHA and whether the Pro session reached the Dart VM
service.
