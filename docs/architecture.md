# Architecture

## Trust and information boundaries

The Flutter app is an authenticated online renderer and input client. The
server owns legal actions, chip movement, turn order, streets, side pots,
showdowns, shared branches, and progress. The client never receives unrevealed
runout cards or folded/opponent private cards.

Gemini is not a poker engine:

- Deal generation chooses button, varied 20–maximum-BB stacks, private cards,
  and a fixed runout for an app-defined random lineup.
- A villain call receives only that actor's cards, visible state/history, and
  bounded tendency profile.
- A coaching call receives Hero's cards, public state/history, and the same
  tendency profiles visible in the UI.
- Deterministic code validates and applies every selected action id.

Training requires a live connection. There is no offline continuation.

## Setup and inventory

The default setup is six-handed $1/$2 with a 200 BB maximum and Hero at logical
seat zero. The setup pool key excludes the per-hand lineup:

`live-v3|random|s6|max200bb|sb1|bb2`

For each generated hand the server creates a new ordered archetype lineup from
bounded templates; Gemini chooses the button, so Hero's position varies.

Inventory is unseen per user:

- a new setup queues ten fully ready hands;
- allocating a hand creates `users/{uid}/liveHandReceipts/{handId}`;
- five or fewer unseen ready hands queues ten more shared hands;
- only zero unseen hands blocks allocation while generation catches up.

A hand is `ready` only after its first Hero node has a complete coaching rubric
and three useful non-fold continuations have been expanded through the next
Hero decision or terminal.

Generation is split into per-hand `liveGenerationJobs` so sequential
perspective-isolated model calls stay inside event-function deadlines.

## Immutable hand and shared lazy tree

`liveTableSetups/{setupKey}/hands/{handId}` stores the server-only immutable
deal and root state hash. A hand's subcollections contain:

```text
nodes/{stateHash}
  state
  public action history
  fixed legal actions
  hidden all-actions coaching rubric

nodes/{stateHash}/actions/{actionId}
  selected action
  coaching for that action
  replay events
  child state hash
```

Node hashes include canonical state and public history. Action documents use
generation leases, making branches shared, deterministic, and idempotent under
concurrent users.

## Online sessions

Callables:

- `startLiveHand(tableSetup, clientVersion)`
- `submitLiveAction(sessionId, handId, stateVersion, decisionId,
  idempotencyKey, actionId)`
- `resumeLiveHand(sessionId, clientVersion)`

The per-user cursor lives at `users/{uid}/liveSessions/{sessionId}`. Decision
results are stored beneath the session by idempotency key. Duplicate requests
return the original result; stale state versions are rejected.

The client receives a projected `LiveHandView`: Hero cards, currently visible
board, public seat state, visible tendencies, fixed legal actions, and terminal
pots/winners. Villain cards are included only for non-folded players at an
actual showdown. Hero folding terminates training immediately.

## Fixed actions

No free fold is offered. When checked to, Hero receives Check plus fixed legal
bet buckets. When facing a price, Hero receives Fold, Call, fixed legal raises,
and All-in where available.

- Preflop open: 3 BB, 4 BB, 5 BB, all-in (live-cash sized; prefer 4 BB)
- Preflop re-raise: 3×, 4×, 5× the current bet, all-in (prefer 4×)
- Postflop bet: 33%, 67%, 100% pot, all-in
- Postflop raise: minimum, 50% and 100% pot-after-call, all-in

Older pooled hands may still expose retired open/3-bet buckets (e.g. 2.5 BB
opens); those action ids remain playable so existing deals are unchanged.

Targets that are illegal, unaffordable, or duplicates after stack clamping are
removed. Incomplete all-ins do not reopen betting.

## Authoritative poker engine

`live_poker_engine.ts` uses cent-exact commitments and supports:

- heads-up and multiway blind/turn order;
- full and incomplete raises;
- fixed runout street progression;
- unequal stacks and all-in runouts;
- unmatched-chip refunds;
- main and side pots with folded contributors and eligibility;
- tied pots and deterministic odd-cent assignment;
- deterministic seven-card showdown evaluation.

Gemini returns only one supplied legal action id. It never returns snapshots,
payouts, winners, or arbitrary amounts.

## Exploit coaching

Every Hero node is evaluated before the action is revealed.
`gemini-3.7-flash` (medium thinking) drafts and critiques a rubric covering
every action. Villain decisions use `gemini-3.8-flash` at low thinking for
latency.

Server-computed facts include position, effective stack, SPR, pot odds, board
texture, Hero features, fixed actions, public history, and visible bounded
tendencies. Coaching is qualitative:

`recommended | strong | reasonable | questionable | clear_mistake`

It carries confidence, profile-grounded reasoning, sizing guidance, a better
alternative where appropriate, and the read that would reverse the advice.
There are no fabricated EV numbers.

See `docs/coaching-quality.md` for the 720-case release benchmark, hidden-data
metamorphic tests, and deployment gates.

## Progress and privacy

Each action is persisted incrementally. Terminal sessions write:

- `users/{uid}/liveHandHistory/{sessionId}`
- `users/{uid}/liveProgress/main`
- completed `liveHandReceipts`

Owners can read history and progress. Sessions, receipts, pool definitions,
private tree nodes, jobs, and all private cards remain Admin-only.

## Migration

Version 2 callable exports are removed, enforcing a mandatory client upgrade.
The guarded production reset preserves Firebase Auth, display name, avatar, and
device-local audio while deleting old/new training data and resetting gameplay
preferences to the v3 default.

After deployment/reset, `seed_live_default.ts` creates the launch setup, enables
client version 2.0.0, and waits until ten warmed hands are ready.
