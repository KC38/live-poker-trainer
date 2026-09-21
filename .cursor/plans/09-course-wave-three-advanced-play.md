# Plan 09 — Course Wave Three: Advanced and Integrated Live Play

**Status: Done**

- Merged: https://github.com/KC38/live-poker-trainer/pull/184
  (`43a5873`) on `main`
- Cloud Functions deploy: completed from `origin/main` at `43a5873`
  (course bank regenerated with Sections 5–7 content)
- CI: `course-contract` passed on PR #184
  (https://github.com/KC38/live-poker-trainer/actions/runs/35586575158)
- Simulator: hot-restarted attached Flutter sessions after merge
- Content: Section 5 (Winning 1/2) — 9 units / 10 lessons;
  Section 6 (Advanced Live Cash) — 13 units / 18 lessons including
  TAG/LAG observe→label→adjust; Section 7 (Full-Hand Integration) —
  12 units / 14 lessons including SRP/3-bet/multiway capstones,
  Live warm-up prep, and five-type final assessment
- Authoring source: `tools/course/wave_three_advanced_play.mjs`

## Objective

Complete a genuinely deep live cash curriculum for winning 1/2 players and
strong regulars. Integrate ranges, deep stacks, advanced sizing, live exploits,
and all five taught player types into full-hand planning.

## Section 5 — Winning 1/2

**Promise:** Win larger value pots and avoid expensive marginal mistakes.

1. Multiway range construction and nut potential
2. Deep-stack play at 150–300 BB
3. Implied odds and reverse implied odds
4. Thin value and bluff-catching
5. Check-raise, probe, delayed c-bet, and donk-bet interpretation
6. Line reading across streets
7. Live timing/sizing evidence without “magic tell” claims
8. Table dynamics: tilted, stuck, tired, or changing gears
9. Session discipline and bankroll guardrails for cash play

## Section 6 — Advanced Live Cash

**Promise:** Think in ranges, incentives, and future streets.

1. Range advantage and nut advantage
2. Equity realization in and out of position
3. Capped and uncapped ranges
4. Polarized versus merged betting
5. Overbets and geometric sizing
6. Blockers and unblockers
7. Minimum-defense intuition without solver-number theater
8. Mixed strategy as frequency, not randomness for its own sake
9. 3-bet/4-bet pots across stack depths
10. Difficult folds, domination, and cooler-versus-mistake review

Introduce:

- **TAG:** selective entry with disciplined aggression.
- **LAG:** wide entry with sustained pressure.

Teach identification and adjustment using observed frequencies/confidence, then
mix TAG/LAG with Calling Station, Nit, and Maniac.

## Section 7 — Full-Hand Integration

**Promise:** Build, execute, and review a complete exploitative plan.

1. Preflop plan → flop range interaction
2. Flop action → turn barrel map
3. River value/bluff composition
4. Limped, single-raised, 3-bet, and 4-bet pots
5. Heads-up and multiway pots
6. Shorter and deep effective stacks
7. Same cards against different player types
8. Type × board × line × sizing checkpoints
9. Personal leak review and default strategy book
10. Capstone authored hands
11. Coached warm-up hand in Live Training

## Content standards

- Full-hand lessons are deterministic authored attempts.
- Qualitative recommendations must not claim fabricated solver EV.
- Advanced math is visual and decision-linked, not a reading chapter.
- Every mixed decision includes baseline, exploit, confidence, and reversal
  condition.
- Rex uses shorter prompts as the course advances.
- Hints and arrows disappear by capstone lessons.

## Player-type graduation

The final assessment must use all five types:

- Calling Station
- Nit
- Maniac
- TAG
- LAG

It must test identification from behavior, adjustment selection, uncertainty,
and abandoning an old label when new evidence contradicts it.

## Acceptance criteria

- Advanced topics are represented by multiple units and full-hand transfer,
  not a single summary lesson.
- TAG/LAG never appear before explicit introductions.
- Capstones cover all major pot types and multiple stack depths.
- The same action is not graded identically across materially different,
  explicitly authored tendencies.
- All advice remains within live cash NLH scope.
- Full catalog passes validation and runner compatibility checks.

## Dependencies

Plan 08.
