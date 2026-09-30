---
name: simulator-refresh
description: >-
  Hot-restart the iPhone 13 mini from origin/main in the primary clone.
  Resolve the UDID via tools/iphone_13_mini_udid.sh — never hardcode it.
  Never a feature worktree. Use after /implement-open-jira merge, or when
  the mini is already booted and should return to origin/main.
---

# Simulator refresh

Refresh the **iPhone 13 mini** only. Resolve its UDID each time — do not
hardcode it.

```bash
.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh
```

| Item | Value |
|------|-------|
| Device | iPhone 13 mini (UDID from `tools/iphone_13_mini_udid.sh`) |
| Checkout | primary clone from `tools/primary_checkout.sh` on `origin/main` |
| Log | `/tmp/flutter-live-poker-trainer.run.log` |
| Pid file | `/tmp/flutter-live-poker-trainer.pid` |

[make-change](../make-change/SKILL.md) calls this in step 9 after a
successful primary `git pull --ff-only`. Skip when that pull failed.
[/implement-open-jira](../../commands/implement-open-jira.md) and
[launch-simulator](../launch-simulator/SKILL.md) also call this when the
mini should show `origin/main`.

Always refresh from `origin/main` in the primary clone (resolved via
`tools/primary_checkout.sh` — `~/live-poker-trainer` or
`~/live_poker_trainer`). Do not hot-restart a feature worktree and pretend
it is main. The script fast-forwards the primary clone when it is clean
and on `main`, and copies gitignored Firebase files when they are missing.

**First-time / no GUI window:** Xcode 27+ uses **Device Hub**, not
`Simulator.app`. See [docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md).

## What the script does

1. Resolve the iPhone 13 mini UDID via `tools/iphone_13_mini_udid.sh`.
2. `git fetch origin main`. The primary clone must be on `main` and clean.
   Fast-forward it.
3. Hot **restart** (`kill -USR2`) a `flutter run` whose `-d` is that UDID
   and whose checkout is the primary clone (`/tmp/flutter-live-poker-trainer.pid`).
4. Stop a `flutter run` on that device that was started from any other
   checkout. Do not hot-restart it.
5. If the origin/main session was restarted, stop.
6. Otherwise start `flutter run -d <UDID>` from the primary clone.
7. If the device cannot boot, skip. Do not fail the ship.
