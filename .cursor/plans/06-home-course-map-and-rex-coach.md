# Plan 06 — Home Course Map and Rex Coach

**Status: Done**

- Merged: https://github.com/KC38/live-poker-trainer/pull/180
  (`5fe26c4`) on `main`
- Cloud Functions deploy: completed from `origin/main` at `5fe26c4`
  (`startCourseLesson` now enforces catalog prerequisites / deep-link locks)
- CI: `course-contract` passed on PR #180
  (https://github.com/KC38/live-poker-trainer/actions/runs/35584915884)
- Simulator: refresh attempted after merge
- Home: status bar, winding path, resume card, Rex coach, lock/next/resume
  derivation from `getCourseState` + catalog

## Objective

Build Home as a clear section/unit/lesson path with one obvious next action,
durable progress states, jump tests, and Rex as the course coach.

## Reuse

- App theme, typography, colors, panels, animations, and audio plumbing.
- Server course state and lesson runtime from Plans 03–04.

## Add

- Course status bar: streak, XP, accepted accuracy.
- Section header and unit banners.
- Winding lesson path with node types:
  lesson, practice, checkpoint, reward, jump test, hand lab.
- Node states:
  locked, available, active, completed, mastered, review due.
- Resume card for interrupted attempts.
- Rex coach card/poses with accessible text.
- Loading, disabled-feature, offline, stale-catalog, empty, error, and retry
  states.

## Rex character direction

- Experienced live cash regular; calm, observant, lightly wry.
- Never presents himself as infallible or as a solver.
- One short sentence at a time.
- Points attention to cards, positions, chips, or player behavior.
- Uses plain language first; introduces poker terms only when needed.
- Celebrates specific behavior, not generic praise.

Example lines:

- “You’re last to act. That extra information is power.”
- “This player calls too much. Bet your good hands.”
- “That line is fine. Smaller keeps worse hands in.”

## Modify

- Replace the placeholder/new Home root created in Plan 01.
- Explicitly log Home tab view, node opens, locked-node taps, and resume.
- Own Home scroll position inside the tab shell.

## UX rules

- Exactly one node is emphasized as next.
- Locked nodes explain the prerequisite in one sentence.
- Jump tests appear only at section boundaries.
- Home shows curriculum only; table setup belongs to Live Training.
- Reward nodes celebrate progress without a shop/currency economy.
- Review nodes come from server scheduling, not local guesses.
- Disabled course flag shows a recoverable unavailable state; authenticated
  users can still switch to Live Training/Profile.

## Acceptance criteria

- Lock and completion states are server-derived.
- Deep-linking to a locked node cannot start it.
- Active attempts take priority over suggesting new work.
- Scroll position survives tab switches and app restoration.
- Every icon-only node has a semantic label and sufficient touch target.
- Path remains usable on the smallest supported phone and at large text scale.
- Rex copy never blocks starting an activity.

## Verification

- Widget/golden tests for every node state and major loading state.
- Accessibility tests for order, labels, contrast, and text scaling.
- Provider tests for resume/next-node selection.
- Analytics tests for tab and node events.

## Dependencies

Plans 01–05.
