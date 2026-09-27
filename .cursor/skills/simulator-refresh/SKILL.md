---
name: simulator-refresh
description: >-
  Hot-restart simulator sessions from origin/main in the primary clone, or
  start flutter run there when a simulator is already booted. Never a
  worktree. Use when a simulator is already running, after a ship merges
  to main, or when make-change reaches simulator refresh. If no simulator
  is booted, use launch-simulator.
---

# Simulator refresh

Used when a simulator is already running. make-change calls this skill after
a merge. If no iOS simulator is booted, use
[launch-simulator](../launch-simulator/SKILL.md) instead.

Always refresh from `origin/main` in the primary clone
(`~/live-poker-trainer`). Do not refresh a worktree, and do not create one.
make-change previews a worktree by running `flutter run` from that worktree
on the agent Pro; call this skill only after the merge, which stops that
session and returns sims to `origin/main`.

**First-time / no GUI window:** Xcode 27+ uses **Device Hub**, not
`Simulator.app`. See [docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md)
for boot, `open -a DeviceHub`, tmux `flutter run`, and Podfile sync.

## Prefer the script

```bash
.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh
```

Behavior:

1. In `~/live-poker-trainer`, `git fetch` and `git pull --ff-only origin main`.
   If that clone is not on `main` or has uncommitted changes, stop and report.
   Do not reset, stash, or add a worktree.
2. Hot **restart** (`kill -USR2`) simulator `flutter run` sessions whose
   project is that primary clone, plus known pid-files when they are that
   same checkout (`/tmp/flutter-live-poker-trainer.pid`,
   `/tmp/flutter-live-poker-trainer-user.pid`).
3. Stop a simulator `flutter run` that was started from any other checkout.
   Do not hot-restart it.
4. If no primary session was restarted but some other `flutter run` exists →
   skip start (do not steal that terminal); report the pid.
5. Else start `flutter run` from the primary clone on a booted iOS simulator
   (fallback: Android, then macOS) with the default pid-file.
6. If no device → skip (do not fail the ship).

After any merge to `main`, always run this so **all** booted sims pick up the
new code — not just the first session found.
