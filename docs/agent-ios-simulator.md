# Agent guide: launch iOS simulator + Flutter

How agents should boot the Live Poker Trainer app on the Mac mini iOS simulator.
Follow this instead of hunting for `Simulator.app` (gone on Xcode 27+).

## Dual sims (do not mix)

| Role | Device | UDID |
|------|--------|------|
| **Agent** | iPhone 17 Pro | `F1AE4938-D9BE-4EA1-8C98-58555A0DE62A` |
| **User (human)** | iPhone 17 | `20ACECD5-FBEE-4663-9044-E11D5F0A26FC` |

Drive, screenshot, and `ext.poker.agent` **only** on the Pro UDID unless the
user asks otherwise.

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

## Boot Pro + run Flutter (durable)

Long builds belong in **tmux** so they survive agent disconnects.

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

PRO=F1AE4938-D9BE-4EA1-8C98-58555A0DE62A
PRIMARY="${PRIMARY:-$HOME/live-poker-trainer}"   # adjust if your clone path differs
SESSION=flutter-pro-lessons

# GUI
open -a /Applications/Xcode.app/Contents/Applications/DeviceHub.app

# Boot device (idempotent)
xcrun simctl bootstatus "$PRO" -b || xcrun simctl boot "$PRO"

# CocoaPods lock sync (common failure after Xcode upgrades)
cd "$PRIMARY/ios"
if ! diff -q Podfile.lock Pods/Manifest.lock >/dev/null 2>&1; then
  pod install
  # If Flutter rewrote a stub Podfile.lock (~Flutter-only), sync:
  #   cp Pods/Manifest.lock Podfile.lock   # when Manifest is the full lock
  # or re-run pod install after flutter pub get
fi

# Detached flutter run
tmux has-session -t "$SESSION" 2>/dev/null || tmux new-session -d -s "$SESSION"
tmux send-keys -t "$SESSION" "cd '$PRIMARY' && flutter run -d $PRO --pid-file /tmp/flutter-live-poker-trainer.pid 2>&1 | tee /tmp/flutter-live-poker-trainer.run.log; echo EXIT:\$?" Enter

# Wait for VM service (first Xcode build can take several minutes)
# Success markers in the log:
#   Flutter run key commands.
#   A Dart VM Service on iPhone 17 Pro is available at: http://127.0.0.1:...
```

Pid + log (agent convention):

| File | Purpose |
|------|---------|
| `/tmp/flutter-live-poker-trainer.pid` | Agent Pro `flutter run` |
| `/tmp/flutter-live-poker-trainer.run.log` | Stdout; parse for Dart VM URI |
| `/tmp/flutter-live-poker-trainer-user.pid` | User iPhone 17 session (do not steal) |

After a ship merges to `main`, prefer:

```bash
.cursor/skills/ship-change/scripts/refresh-simulator.sh
```

Or hot-restart an attached session: send `R` into the `flutter-pro-lessons`
tmux pane (`tmux send-keys -t flutter-pro-lessons R`).

## Drive the UI (no OS clicks required)

```bash
python3 tools/agent_tap.py openlesson --text lesson-01-01-01-your-two-cards
python3 tools/agent_tap.py tap --text "Continue"
python3 tools/agent_tap.py tap --text "Your hole cards"
```

- VM URI is scraped from `/tmp/flutter-live-poker-trainer.run.log`.
- Isolate IDs change after hot restart — the script re-resolves each call.
- Prefer **exact lesson labels** (e.g. `Your hole cards`). Broad needles like
  `Continue` can match **home course map** controls under the lesson route and
  fire lock snackbars (`Finish "…" first.`).
- Screenshots:

```bash
xcrun simctl io F1AE4938-D9BE-4EA1-8C98-58555A0DE62A screenshot /tmp/pro.png
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

- Dual-sim play loop: [`.cursor/skills/play-test-fix/SKILL.md`](../.cursor/skills/play-test-fix/SKILL.md)
- Post-merge refresh: [`.cursor/skills/ship-change/simulator-refresh.md`](../.cursor/skills/ship-change/simulator-refresh.md)
- Ship flow: [`.cursor/skills/ship-change/SKILL.md`](../.cursor/skills/ship-change/SKILL.md)
