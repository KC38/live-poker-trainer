# Plan 08 — Course Wave Two: Live Competence and Player Types

**Status: Done**

- Merged: https://github.com/KC38/live-poker-trainer/pull/181
  (`9abd823`) on `main`
- Cloud Functions deploy: completed from `origin/main` at `9abd823`
  (course bank regenerated with Sections 3–4 content)
- CI: `course-contract` passed on PR #181
  (https://github.com/KC38/live-poker-trainer/actions/runs/35584946789)
- Content: Section 3 (First Casino) — 8 units including jump test;
  Section 4 (Regular Live) — 10 units including Calling Station / Nit /
  Maniac observe→label→adjust lessons and Section 4 jump test
- Authoring source: `tools/course/wave_two_live_competence.mjs`
- Entitlement: Section 4 jump grants `liveTraining` with source
  `section4_jump` (unit + emulator coverage)

## Objective

Author Sections 3–4 for first-casino and regular 1/2 players. Establish sound
postflop fundamentals, then teach player types as evidence-based adjustments.

## Section 3 — First Casino Sessions

**Promise:** Reach the river with a plan and avoid the common beginner leaks.

1. **Reading the live table**
   - Pot, stacks, commitments, button, action, and verbal declarations
2. **Flop hand classes**
   - Made hands, draws, showdown value, air
3. **Outs and price**
   - Clean/dirty outs, pot odds, implied-odds intuition
4. **Flop decisions**
   - Value bet, c-bet, check back, call, fold, raise
5. **Turn decisions**
   - Brick versus changing card, second barrel, delayed aggression
6. **River decisions**
   - Value, bluff, bluff-catch, fold
7. **Multiway fundamentals**
   - Stronger ranges, less bluffing, position and nut potential
8. **Leak repair**
   - Top-pair overplay, chasing bad prices, passive calling, bluffing crowds

Behavioral observations begin here without fixed labels:

- Plays many/few hands
- Raises versus calls
- Gives up versus continues
- Uses unusual sizing

## Section 4 — Regular Live Cash Player

**Promise:** Build ranges, recognize opponents, and make deliberate exploits.

1. **Ranges, not exact hands**
2. **3-bet and squeezed pots**
3. **Continuation plans across streets**
4. **Bet sizing that communicates a range**
5. **SPR and commitment**
6. **Player type: Calling Station**
   - Evidence: high participation, low folding
   - Exploit: wider/thicker value, fewer unsupported bluffs
7. **Player type: Nit**
   - Evidence: narrow entry and strong aggression
   - Exploit: steal more, respect heavy action
8. **Player type: Maniac**
   - Evidence: extreme entry/aggression
   - Exploit: widen bluff-catching/value range; avoid ego battles
9. **Type identification**
   - Separate observed behavior from certainty
   - Confidence grows with samples
10. **Exploit checkpoints**
   - Same hand against different types
   - Type × position × stack × board

## Placement and jump tests

- Publish the Section 3 and Section 4 boundary jump tests referenced by
  onboarding and Live Training readiness.
- The Section 4 test covers baseline ranges, postflop planning, sizing, SPR,
  and all three introduced player types.
- Catalog publication and `placementTestsEnabled` are coordinated so
  onboarding can never route to an unpublished test.
- Passing writes the server-authored unrestricted-Live entitlement described
  by Plan 03; self-reported experience alone never writes it. Plan 10 later
  enforces that entitlement in Live callables.

## Player-type teaching rules

- Baseline strategy always precedes the exploit.
- One type is introduced at a time.
- Learners tag observed behavior before seeing the archetype label.
- A label is a working model, not a personality judgment.
- The course displays sample/confidence limits; no type is inferred from one
  dramatic hand.
- Later exercises mix only types already introduced.
- Advice must cite the specific tendency that changes the decision.

## Acceptance criteria

- Section 3 can be completed without archetype terminology.
- Calling Station, Nit, and Maniac each receive introduction, identification,
  adjustment, and mixed checkpoint lessons.
- Equivalent baseline spots produce different recommendations only when the
  authored read justifies the change.
- Alternative reasonable sizings receive soft grades.
- Every player-type exercise has an explicit reversal read.
- Multiway and deep-stack live conditions appear throughout, not as footnotes.
- Section 3/4 jump tests are published, validated, and covered by entitlement
  write integration tests against the Plan 03 backend before placement tests
  are enabled.

## Dependencies

Plan 07.
