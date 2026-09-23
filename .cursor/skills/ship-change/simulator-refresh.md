# Simulator refresh

Used after `main` is updated with a shipped change.

**First-time / no GUI window:** Xcode 27+ uses **Device Hub**, not
`Simulator.app`. See [docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md)
for boot, `open -a DeviceHub`, tmux `flutter run`, and Podfile sync.

## Prefer the script

```bash
.cursor/skills/ship-change/scripts/refresh-simulator.sh
```

Behavior:

1. Hot **restart** (`kill -USR2`) **every** attached iOS-simulator `flutter run`
   (UUID `-d <sim-id>`), plus known pid-files
   (`/tmp/flutter-live-poker-trainer.pid`,
   `/tmp/flutter-live-poker-trainer-user.pid`).
2. If no simulator sessions were restarted but some other `flutter run` exists →
   skip start (do not steal that terminal); report the pid.
3. Else start `flutter run` on a booted iOS simulator (fallback: Android, then
   macOS) with the default pid-file.
4. If no device → skip (do not fail the ship).

After any merge to `main`, always run this so **all** booted sims pick up the
new code — not just the first session found.
