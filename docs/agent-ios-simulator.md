# Agent guide: launch iOS simulator + Flutter

How agents should boot the Live Poker Trainer app on the Mac mini iOS
simulator. Follow this instead of hunting for `Simulator.app` (gone on
Xcode 27+).

## One simulator: iPhone 13 mini

This project uses **one** simulator: the **iPhone 13 mini**. Resolve its
UDID every time — never hardcode it:

```bash
DEVICE="$(tools/iphone_13_mini_udid.sh)"
```

Do not boot, uninstall, terminate, kill, hot-restart, screenshot, or tap any
other simulator for agent work.

## Xcode 27+: Device Hub (not Simulator.app)

Xcode 27 **removed** `Simulator.app`. The GUI is **Device Hub**:

```text
/Applications/Xcode.app/Contents/Applications/DeviceHub.app
```

Bundle id: `com.apple.dt.Devices`

```bash
# Show the phone chrome on screen
open -a /Applications/Xcode.app/Contents/Applications/DeviceHub.app
# or
open -b com.apple.dt.Devices
```

If you see a process named `Simulator` whose binary lives under
`PKInstallSandboxTrash`, it is a **zombie from an old Xcode install** — kill it
and open Device Hub instead:

```bash
pkill -f 'PKInstallSandboxTrash.*Simulator' || true
open -a /Applications/Xcode.app/Contents/Applications/DeviceHub.app
```

`simctl` / `flutter run` can keep a device booted **without** a visible window.
No window ≠ app not running.

## One-time Xcode bootstrap (human may need sudo)

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcode-select -p   # must print .../Xcode.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
xcrun simctl help >/dev/null && echo "simctl OK"
```

`flutter doctor` may warn that a newer iOS simulator runtime is missing.
An available **iPhone 13 mini** is enough for day-to-day agent work. To install
a matching platform runtime:

```bash
xcodebuild -downloadPlatform iOS
# or Xcode → Settings → Components / Platforms → GET for iOS
```

Android SDK / Chrome warnings are unrelated — ignore them unless you need
those targets.

## Firebase secrets in worktrees

Never commit these. Copy from the primary clone into each feature worktree
before `flutter run`:

- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist`
- `android/app/google-services.json` (if present)

## Boot the mini + run Flutter (durable)

Long builds belong in **tmux** so they survive agent disconnects.

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

DEVICE="$(tools/iphone_13_mini_udid.sh)"
PRIMARY="$(tools/primary_checkout.sh)"
CHECKOUT="$PRIMARY"
SESSION=flutter-iphone-13-mini
PID_FILE=/tmp/flutter-live-poker-trainer.pid
LOG_FILE=/tmp/flutter-live-poker-trainer.run.log

# /implement-open-jira ticket worktree before merge may use:
# CHECKOUT="$PRIMARY/.worktrees/$SLUG"
# SESSION=flutter-iphone-13-mini-$SLUG
# PID_FILE=/tmp/flutter-$SLUG.pid
# LOG_FILE=/tmp/flutter-$SLUG.log

open -a /Applications/Xcode.app/Contents/Applications/DeviceHub.app
xcrun simctl bootstatus "$DEVICE" -b || xcrun simctl boot "$DEVICE"

cd "$CHECKOUT/ios"
if ! diff -q Podfile.lock Pods/Manifest.lock >/dev/null 2>&1; then
  pod install
fi

tmux has-session -t "$SESSION" 2>/dev/null || tmux new-session -d -s "$SESSION"
tmux send-keys -t "$SESSION" "cd '$CHECKOUT' && flutter run -d $DEVICE --pid-file $PID_FILE 2>&1 | tee $LOG_FILE; echo EXIT:\$?" Enter
```

Success markers in that session's log:

- `Flutter run key commands.`
- `A Dart VM Service on iPhone 13 mini is available at: http://127.0.0.1:…`

| File | Purpose |
|------|---------|
| `/tmp/flutter-live-poker-trainer.pid` | origin/main `flutter run` on the mini |
| `/tmp/flutter-live-poker-trainer.run.log` | stdout. `agent_tap.py` default |
| `/tmp/flutter-$SLUG.pid` and `.log` | Ticket worktree session on the mini, before merge |

Refresh after a merge (or when the mini should show `origin/main`):

```bash
.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh
```

That fast-forwards the primary clone and hot-restarts (or starts) the mini.

## Drive the UI (no OS clicks required)

```bash
python3 tools/agent_tap.py openlesson --text lesson-01-01-01-your-two-cards
python3 tools/agent_tap.py tap --text "Continue"
python3 tools/agent_tap.py tap --text "Your hole cards"
```

Ticket worktree before merge (pass that session's log):

```bash
python3 tools/agent_tap.py --log /tmp/flutter-$SLUG.log tap --text "Continue"
```

- The default VM URI comes from `/tmp/flutter-live-poker-trainer.run.log`.
- Isolate IDs change after hot restart — the script re-resolves each call.
- Prefer **exact lesson labels** (e.g. `Your hole cards`). Broad needles like
  `Continue` can match **home course map** controls under the lesson route and
  fire lock snackbars (`Finish "…" first.`).
- Screenshot:

```bash
DEVICE="$(tools/iphone_13_mini_udid.sh)"
xcrun simctl io "$DEVICE" screenshot /tmp/mini.png
```

## Common failures

| Symptom | Fix |
|---------|-----|
| `Unable to find application named 'Simulator'` / missing `Simulator.app` | Use **Device Hub** (paths above). |
| `error: no available iPhone 13 mini simulator found` | Create or download an iPhone 13 mini in Device Hub / Xcode Platforms. |
| `xcode-select` → Command Line Tools only | `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` |
| Unsigned / license errors | `sudo xcodebuild -license accept` then `-runFirstLaunch` |
| `sandbox is not in sync with the Podfile.lock` | `cd ios && pod install`; ensure `Podfile.lock` ↔ `Pods/Manifest.lock` match |
| Blank lesson / “Lesson content is still loading” | Wait for catalog/auth; reopen lesson after providers settle |
| `Flutter run` exits right after Impeller log | App may still be installed — relaunch via tmux recipe; check Device Hub window |
| Agent taps hit home “Finish … first” snackbars | Narrow tap needles; pop back to lesson or `openlesson:` again |

## Related

- Boot when none is running: [`.cursor/skills/launch-simulator/SKILL.md`](../.cursor/skills/launch-simulator/SKILL.md)
- Post-merge refresh: [`.cursor/skills/simulator-refresh/SKILL.md`](../.cursor/skills/simulator-refresh/SKILL.md)
- Ship open tickets: [`.cursor/commands/implement-open-jira.md`](../.cursor/commands/implement-open-jira.md)
- Code changes: [`.cursor/skills/make-change/SKILL.md`](../.cursor/skills/make-change/SKILL.md)
- Named journeys: [agent-paths.md](agent-paths.md)
- UDID resolver: [`tools/iphone_13_mini_udid.sh`](../tools/iphone_13_mini_udid.sh)
