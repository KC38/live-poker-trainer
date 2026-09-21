# Plan 04 — Interactive Lesson Runtime

**Status: Done**

- Merged: https://github.com/KC38/live-poker-trainer/pull/172
  (`192fdb3`) on `main`
- Cloud Functions deploy: completed from `origin/main` at `192fdb3`
  (updated course callables with hand-step / hand-lab choice grading lookup)
- CI: `course-contract` passed on PR #172
  (https://github.com/KC38/live-poker-trainer/actions/runs/35580206435)
- Simulator: hot-restarted attached Flutter sessions after merge
- Runtime: `LessonRunnerScreen` / `LessonResultScreen`, activity registry for
  all 9 catalog renderers, soft-grade feedback, hint/undo/streak, resume +
  idempotent submits, standalone first-lesson launch route
- First lesson: Section 1 → Cards and the table → **Your two cards**
  (`lesson-01-01-01-your-two-cards`)

## Objective

Create a reusable lesson engine that teaches through short, tactile activities
and progressively removes help. Do not recreate the reverted all-multiple-choice
runner.

## Reuse

- `MiniCard`, community-card visuals, action-button styling, felt/table visual
  language, and coach feedback patterns.
- Server soft-grading contract from Plan 03.
- Sound service for restrained correct/error/celebration cues.

## Add

- `LessonRunnerScreen` and `LessonResultScreen`.
- Activity registry with explicit unsupported-type failure handling.
- Activity widgets for:
  - Coach demonstration
  - Select position/acting player
  - Arrange action order
  - Build or compare poker hands
  - Classify board/hand/draw
  - Pot, price, outs, and effective-stack interactions
  - Fold/check/call/bet/raise and sizing choices
  - Identify a player read/type
  - Authored multi-step hand decision
- Hint, undo where conceptually valid, progress, accepted-answer streak, and
  feedback sheet.
- Durable attempt resume.
- A minimal standalone launch route so onboarding can run the first lesson
  before the Home path exists.
- One production vertical-slice lesson at
  Section 1 → Cards and the table → **Your two cards**. It introduces hole
  cards through show/guided/scaffolded/unguided/checkpoint activities and is
  part of the real versioned catalog, not a test fixture. Plan 07 expands the
  surrounding section without replacing its stable IDs.

## Required lesson rhythm

1. **Show:** Rex gives one sentence and the UI demonstrates the first action.
2. **Guided rep:** target/highlight and hint are visible.
3. **Scaffolded rep:** some cues are removed.
4. **Unguided reps:** mixed examples with no arrow.
5. **Checkpoint:** transfer the skill to a fuller table/state.

The runtime must allow authored variation without creating one bespoke screen
per lesson.

## Feedback behavior

- `recommended`, `strong`, `reasonable`: green/positive continuation.
- `questionable`: neutral coaching and retry/continue; no life loss.
- `clear_mistake`: red corrective feedback; life loss only when the backend
  marks the activity eligible.
- Explain the selected choice, preferred alternative, and condition that could
  reverse the advice.
- Never present a close poker decision as objectively wrong.

## Course safety

- Client never sees private grade maps before submission.
- A lesson interruption resumes without replaying awarded XP.
- Course activities do not invoke random Live Training hands.
- Numeric activities define rounding/tolerance in the private grading bank.
- All authored poker state passes a server/domain validator.

## Acceptance criteria

- Every catalog activity resolves through the registry.
- An unknown activity produces a recoverable error, not a crash.
- Reasonable and questionable choices never animate life loss.
- Network retries cannot submit twice.
- Hints are tracked separately from correctness.
- Screen readers can understand cards, positions, pot, and available actions.
- Lessons work at large text sizes without hiding the primary action.
- The first lesson can run from onboarding without the tab shell/Home map.
- The production first lesson passes the same content validator and private
  grading separation as all later content.

## Verification

- Registry contract tests against the full catalog.
- Widget tests for every activity and grade state.
- Resume/idempotency integration tests.
- Accessibility semantics tests for cards and table positions.
- Representative end-to-end first lesson.

## Dependencies

Plans 02 and 03.
