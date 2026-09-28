---
name: simulator-refresh
description: >-
  Hot-restart one skill's simulator from origin/main. qa is the iPhone 17
  Pro in the primary clone. implement is the iPhone 17 in
  .worktrees/iphone17-main. Never touch the other device. Never a feature
  worktree. Use after that skill's merge, or when its device is already
  booted and should return to origin/main.
---

# Simulator refresh

Refresh **one** role. The other skill may be running on the other phone.
Do not restart both.

```bash
.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh qa
.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh implement
```

| Role | Who | Device | Checkout | Log |
|------|-----|--------|----------|-----|
| `qa` | new-user-qa | iPhone 17 Pro `F1AE4938-D9BE-4EA1-8C98-58555A0DE62A` | `~/live-poker-trainer` | `/tmp/flutter-live-poker-trainer.run.log` |
| `implement` | implement-open-jira | iPhone 17 `20ACECD5-FBEE-4663-9044-E11D5F0A26FC` | `~/live-poker-trainer/.worktrees/iphone17-main` | `/tmp/flutter-live-poker-trainer-iphone17.run.log` |

[make-change](../make-change/SKILL.md) calls `implement` after a merge.
[new-user-qa](../new-user-qa/SKILL.md) and
[launch-simulator](../launch-simulator/SKILL.md) call `qa` only when the
Pro is already up. If the Pro is shut down, launch-simulator boots it.
A booted iPhone 17 does not block that.

[ui-consistency-qa](../ui-consistency-qa/SKILL.md) is not a refresh role.
Do not pass `qa` or `implement` for that walk. It has its own Pro Max.

Always refresh from `origin/main`. Do not hot-restart a feature worktree
and pretend it is main. make-change previews a ticket worktree with
`flutter run` on the iPhone 17; this skill runs after that session is
stopped, and starts origin/main on the iPhone 17 from `.worktrees/iphone17-main`.
That second checkout keeps its `build/` off the Pro session in the primary
clone. The script creates the worktree when it is missing, fast-forwards
it, and copies gitignored Firebase files from the primary clone when they
are absent. It does not pull the primary clone on the `implement` role, so
a Pro session keeps the tree it was launched from.

**First-time / no GUI window:** Xcode 27+ uses **Device Hub**, not
`Simulator.app`. See [docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md).

## What the script does

1. `git fetch origin main`.
2. `qa`: the primary clone must be on `main` and clean. Fast-forward it.
   `implement`: fast-forward `.worktrees/iphone17-main` only. Do not pull
   or restart the primary clone.
3. Hot **restart** (`kill -USR2`) a `flutter run` whose `-d` is this role's
   UDID and whose checkout is the directory from the table. Known pid files
   for that role are included (`/tmp/flutter-live-poker-trainer.pid` for
   `qa`; `/tmp/flutter-live-poker-trainer-iphone17.pid` and the legacy
   `/tmp/flutter-live-poker-trainer-user.pid` for `implement`, and only when
   that process is actually on this device).
4. Stop a `flutter run` on **this** device that was started from any other
   checkout. Do not hot-restart it. Do not signal a process whose `-d` is
   the other UDID.
5. If this device's origin/main session was restarted, stop.
6. Otherwise start `flutter run -d <this UDID>` from the checkout in the
   table. The other device's flutter run does not count as "already
   running" and must not block the start.
7. If this device cannot boot, skip. Do not fail the ship.
