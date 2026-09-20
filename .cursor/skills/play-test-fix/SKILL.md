---
name: play-test-fix
description: >-
  Continuous live play → test → fix loop on the agent iPhone 17 Pro simulator.
  Use when the user asks to keep playing/testing/fixing, run OCR play
  batches, dual-sim agent isolation, or /play-test-fix / /goal play.
---

# Play → test → fix (iterative)

Keep playing, testing, and fixing `live_poker_trainer` iteratively until the
user explicitly says **stop**. Do **not** mark a durable goal complete early.
There is no turn/token budget—leave the goal active and keep cycling.

For every product fix, follow [ship-change](../ship-change/SKILL.md)
(feature branch → PR → squash-merge → deploy functions → refresh sims).
Never push features straight to `main`.

## Stay in sync with main

Other agents push to `origin/main` while you work. Always:

- `git fetch` / `pull --ff-only` before creating a branch
- Rebase onto `origin/main` if main moves mid-PR; re-push
- Pull `main` after every merge before the next cycle
- If you find unrelated dirty WIP or stashes from other agents, **leave them
  alone** (stash around them; do not steal their work)

## Dual simulators (strict isolation)

| Role | Device | UDID |
|------|--------|------|
| **Agent (you)** | iPhone 17 Pro | `A22BEBB0-4093-426B-A535-0C0B558CA2EF` |
| **User (human)** | iPhone 17 | `AF6D4B36-11A4-44DB-B656-76DA4D87B020` |

- Drive / OCR / agent commands **only** on the Pro UDID. Pin screenshots:
  `xcrun simctl io A22BEBB0-4093-426B-A535-0C0B558CA2EF screenshot …`
- Do **not** send `ext.poker.agent` cmds to the user sim. Do not hot-restart
  the user sim alone for agent convenience.
- Ship refresh script may restart **both**—that is OK.
- Pid files: agent `/tmp/flutter-live-poker-trainer.pid`; user
  `/tmp/flutter-live-poker-trainer-user.pid`
- When you (re)launch the **user** iPhone 17 instance, **tell the user** it
  is ready for them.

## How to drive the agent app

- Rediscover Dart VM URI from `/tmp/flutter-live-poker-trainer.run.log`
  (`Dart VM Service on iPhone 17 Pro`). Isolate IDs change after hot
  restart—call `getVM` and refresh `isolateId` before **every** command.
- Debug bus: `ext.poker.agent` with cmds: `start`, `fold`, `call`, `check`,
  `raise` / `raise:N`, `allin`, `next` / `dismiss`, `retry` / `resume`,
  `back`
- Mid-hand coach: `next`/`dismiss` clears Continue shelf (#95). Hand-over:
  `next` deals next hand.
- Retry banner (“The table changed…”): send `retry` / `resume`.
- OCR: macOS Vision (`VNRecognizeTextRequest`) on Pro screenshots. Treat OCR
  garbage (`CAII`, `DATCE`, `uTCH` for CALL/BEST) as **harness noise**, not
  product bugs, unless the UI clearly shows wrong strings.

PATH:
`/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Applications/flutter/bin`

## Each cycle

1. Sync `main`
2. Play ~6–10 hands on Pro; log to `/tmp/play_<batch>.log`
3. On coach overlays: capture copy; then `next` to dismiss / advance
4. If a **clear product bug** appears → fix + ship-change + deploy + refresh
5. If clean → report status; start another cycle (goal still active)
6. Prefer parallelizing independent workstreams when useful (inventory vs
   play/fix), but do not double-drive the same sim

## Already fixed / intentional — do not re-ship

| Item | Status |
|------|--------|
| Agent `next` no-op mid-hand coach | Fixed #95 |
| `liveActionFeed` Crashlytics permission-denied spam | Fixed #96 (`onError`, `cancelOnError: false`); rules allow owner read on `users/{uid}/liveActionFeed/*` |
| Coach polish: paired `%`, `requiring only`, split percents, tendency `(N.N)` → `%`, number-before-label (`51.5 river bluff`) | Fixed through #98+ (`polishCoachCopy` in `live_hand_model.dart`) |
| CLOSE without CORRECT/INCORRECT | **Intentional** (#85 strong/reasonable → CLOSE) |
| SPR not on felt | **Intentional** (street · pot on felt; SPR in coach copy) |
| BEST/YOU OCR misreads | Harness noise (product labels fixed historically) |
| Long REVIEWING / coach-prep looking like “TABLE ACTING hang” | Usually slow grading, not stuck replay |
| Intermittent “table changed / Retry” | Open **ops**; ship only if you find a clear client bug |

## What counts as a real bug to ship

- Bad coach copy in the **product string** (missing `%`, broken grammar, wrong
  labels, raw action keys)
- Broken agent bus / dismiss / retry / back behavior
- Felt/UI logic bugs (stale pills, wrong dock, etc.)
- Clear client hangs (not OCR mistaking REVIEWING for TABLE ACTING)

## Report format (each batch)

- Hands played + coach verdicts (CORRECT / CLOSE / INCORRECT)
- Bugs found / PRs shipped / HEAD
- `main` sync status (behind 0?)
- Open ops / watchlist
- Confirm user iPhone 17 left alone

## Completion

Only the user saying **stop** ends this goal. Do **not** mark the goal
complete because a batch was clean or known bugs were cleared. Keep iterating.
