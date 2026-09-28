# Agent guide: launch iOS simulator + Flutter

How agents should boot the Live Poker Trainer app on the Mac mini iOS simulator.
Follow this instead of hunting for `Simulator.app` (gone on Xcode 27+).

## Three skills, three phones

The phones run at the same time. Each skill drives only its own device.

| Skill | Device | UDID |
|-------|--------|------|
| **new-user-qa** | iPhone 17 Pro | `F1AE4938-D9BE-4EA1-8C98-58555A0DE62A` |
| **implement-open-jira** | iPhone 17 | `20ACECD5-FBEE-4663-9044-E11D5F0A26FC` |
| **ui-consistency-qa** | iPhone 17 Pro Max (iOS 26.5) | `7CB7DDCF-CBEA-414F-8A92-D490C7AAE35F` |

Do not boot, uninstall, terminate, kill, hot-restart, screenshot, or tap the
other skill's phone. A `flutter run` on one device is not a reason to skip
starting the other. ui-consistency-qa runs from `.worktrees/ui-main`
on origin/main, so its `build/` stays off the Pro session in the primary
clone.

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

`flutter doctor` may warn that the **iOS 27** simulator runtime is missing.
An **iOS 26.5** Pro device is enough for day-to-day agent work. To install the
matching platform runtime:

```bash
xcodebuild -downloadPlatform iOS
# or Xcode → Settings → Components / Platforms → GET for iOS
```

Android SDK / Chrome warnings are unrelated to the iOS Pro walk — ignore them
unless you need those targets.

## Firebase secrets in worktrees

Never commit these. Copy from the primary clone into each feature worktree
before `flutter run`:

- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist`
- `android/app/google-services.json` (if present)

## Boot one phone + run Flutter (durable)

Long builds belong in **tmux** so they survive agent disconnects. Start the
phone this skill owns. Leave the other phone's tmux session up.

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

# new-user-qa
DEVICE=F1AE4938-D9BE-4EA1-8C98-58555A0DE62A
PRIMARY="${PRIMARY:-$HOME/live-poker-trainer}"
CHECKOUT="$PRIMARY"
SESSION=flutter-pro-lessons
PID_FILE=/tmp/flutter-live-poker-trainer.pid
LOG_FILE=/tmp/flutter-live-poker-trainer.run.log

# implement-open-jira uses the other phone. Before merge, CHECKOUT is the
# ticket worktree and the log is /tmp/flutter-$SLUG.log. After merge, refresh
# uses a second origin/main checkout so the two flutter runs do not share build/:
# DEVICE=20ACECD5-FBEE-4663-9044-E11D5F0A26FC
# CHECKOUT="$PRIMARY/.worktrees/iphone17-main"
# SESSION=flutter-iphone17-$SLUG
# PID_FILE=/tmp/flutter-live-poker-trainer-iphone17.pid
# LOG_FILE=/tmp/flutter-live-poker-trainer-iphone17.run.log

# ui-consistency-qa uses the Pro Max and its own origin/main checkout:
# DEVICE=7CB7DDCF-CBEA-414F-8A92-D490C7AAE35F
# CHECKOUT="$PRIMARY/.worktrees/ui-main"
# SESSION=flutter-ui-pro-max
# PID_FILE=/tmp/flutter-live-poker-trainer-ui.pid
# LOG_FILE=/tmp/flutter-live-poker-trainer-ui.run.log

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
- Pro: `A Dart VM Service on iPhone 17 Pro is available at: http://127.0.0.1:…`
- iPhone 17: `A Dart VM Service on iPhone 17 is available at: http://127.0.0.1:…`
- Pro Max: `A Dart VM Service on iPhone 17 Pro Max is available at: http://127.0.0.1:…`

| File | Purpose |
|------|---------|
| `/tmp/flutter-live-poker-trainer.pid` | new-user-qa Pro `flutter run` |
| `/tmp/flutter-live-poker-trainer.run.log` | Pro stdout. `agent_tap.py` default |
| `/tmp/flutter-live-poker-trainer-iphone17.pid` | implement-open-jira iPhone 17 `flutter run` on origin/main |
| `/tmp/flutter-live-poker-trainer-iphone17.run.log` | iPhone 17 origin/main stdout. Pass `--log` |
| `/tmp/flutter-$SLUG.pid` and `.log` | Ticket worktree session on the iPhone 17, before merge |
| `/tmp/flutter-live-poker-trainer-user.pid` | Legacy iPhone 17 pid file. Refresh treats it as implement, and only if the process is on that device |
| `/tmp/flutter-live-poker-trainer-ui.pid` | ui-consistency-qa Pro Max `flutter run` |
| `/tmp/flutter-live-poker-trainer-ui.run.log` | Pro Max stdout. Pass `--log` |

Refresh one role after its merge. Do not refresh both:

```bash
.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh qa
.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh implement
```

`implement` fast-forwards `.worktrees/iphone17-main` and does not pull or
restart the primary clone. Hot-restart only that role's pane (`R` in
`flutter-pro-lessons` for QA, or `flutter-iphone17-$SLUG` while a ticket
worktree is on the iPhone 17).

## Drive the UI (no OS clicks required)

new-user-qa (default log is the Pro):

```bash
python3 tools/agent_tap.py openlesson --text lesson-01-01-01-your-two-cards
python3 tools/agent_tap.py tap --text "Continue"
python3 tools/agent_tap.py tap --text "Your hole cards"
```

implement-open-jira (pass that phone's log, or the ticket worktree log):

```bash
python3 tools/agent_tap.py --log /tmp/flutter-live-poker-trainer-iphone17.run.log tap --text "Continue"
```

ui-consistency-qa (pass the Pro Max log):

```bash
python3 tools/agent_tap.py --log /tmp/flutter-live-poker-trainer-ui.run.log tap --text "Continue"
```

- The default VM URI comes from `/tmp/flutter-live-poker-trainer.run.log`.
  `--log` is required for the iPhone 17, or taps hit the Pro.
- Isolate IDs change after hot restart — the script re-resolves each call.
- Prefer **exact lesson labels** (e.g. `Your hole cards`). Broad needles like
  `Continue` can match **home course map** controls under the lesson route and
  fire lock snackbars (`Finish "…" first.`).
- Screenshots, one device per skill:

```bash
xcrun simctl io F1AE4938-D9BE-4EA1-8C98-58555A0DE62A screenshot /tmp/pro.png
xcrun simctl io 20ACECD5-FBEE-4663-9044-E11D5F0A26FC screenshot /tmp/iphone17.png
xcrun simctl io 7CB7DDCF-CBEA-414F-8A92-D490C7AAE35F screenshot /tmp/pro-max.png
```

## Common failures

| Symptom | Fix |
|---------|-----|
| `Unable to find application named 'Simulator'` / missing `Simulator.app` | Use **Device Hub** (paths above). |
| `xcode-select` → Command Line Tools only | `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` |
| Unsigned / license errors | `sudo xcodebuild -license accept` then `-runFirstLaunch` |
| `sandbox is not in sync with the Podfile.lock` | `cd ios && pod install`; ensure `Podfile.lock` ↔ `Pods/Manifest.lock` match |
| Blank lesson / “Lesson content is still loading” | Wait for catalog/auth; reopen lesson after providers settle |
| `Flutter run` exits right after Impeller log | App may still be installed — relaunch via tmux recipe; check Device Hub window |
| Agent taps hit home “Finish … first” snackbars | Narrow tap needles; pop back to lesson or `openlesson:` again |

## Related

- Boot a simulator when none is running: [`.cursor/skills/launch-simulator/SKILL.md`](../.cursor/skills/launch-simulator/SKILL.md)
- Post-merge refresh: [`.cursor/skills/simulator-refresh/SKILL.md`](../.cursor/skills/simulator-refresh/SKILL.md)
- Code changes: [`.cursor/skills/make-change/SKILL.md`](../.cursor/skills/make-change/SKILL.md)
