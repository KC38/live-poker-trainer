# 05 — Live Training

## Goal

Server-authoritative six-max $1/$2 (200 BB max) cash hands with fixed legal
actions, exploitative villain play, and pre-generated exploit rubrics for
Hero decisions.

Deep detail: [architecture.md](../architecture.md).

## Trust boundary (never violate)

Client is an authenticated **renderer and input client**. It must never:

- receive unrevealed runout cards or folded/opponent private cards early;
- invent legal actions or chip amounts;
- continue a hand offline;
- call Gemini with a client-held API key.

Villain cards appear only for non-folded players at a real showdown. Hero
fold ends training immediately.

## Callables

| Callable | Role |
| --- | --- |
| `startLiveHand` | Allocate unseen warmed hand + session |
| `submitLiveAction` | Idempotent Hero action → shared branch / coaching / next view |
| `resumeLiveHand` | Restore after interrupt |
| `undoLiveAction` | Server-supported undo when available |

Cursor: `users/{uid}/liveSessions/{sessionId}`. Duplicate idempotency keys
return the original result; stale `stateVersion` is rejected.

## Fixed actions (product preference)

No free fold when Check is free. Buckets (current):

- Preflop open: 3 / 4 / 5 BB, all-in (prefer 4 BB)
- Preflop re-raise: 3× / 4× / 5×, all-in (prefer 4×)
- Postflop bet: 33% / 67% / 100% pot, all-in
- Postflop raise: min / 50% / 100% pot-after-call, all-in

Older pooled hands may still expose retired buckets; keep those action ids
playable.

## Client UI path

1. `LiveTrainingScreen` hub — gate copy for guests / locked accounts.
2. `PokerTableScreen` + `FeltTableView` + `ActionDockWidget` + coach shelf.
3. `game_provider` holds `TableSession`: projected `LiveHandView`, legal
   actions, replay pacing, coach feedback.

Replay pacing (`ReplayPace`) times deal / action / pot collect so the felt
feels live. Tests scale via `ReplayPace.testScale`.

## Pools and trees

- Setup key excludes lineup; each hand gets a new archetype lineup.
- Hands warm until first Hero node has a full rubric and three non-fold
  branches expanded.
- Shared lazy tree under `liveTableSetups/{setupKey}/hands/{handId}/nodes`.
- Generation leases make first expansion idempotent under concurrency.

## Coaching

- Rubric generated **before** Hero acts; revealed for the chosen action.
- Qualitative grades + profile-grounded reasoning; no fabricated EV.
- Villain decisions: sequential, perspective-isolated model calls.
- Quality gate: [coaching-quality.md](../coaching-quality.md).

## Access

`live_access` / `LiveAccess` — anonymous guests cannot start hands. Unlock
rules (Baseline jump / section gates) live with hub copy in
`live_training_screen.dart`. Do not invent unlock text in tests; assert
product strings.
