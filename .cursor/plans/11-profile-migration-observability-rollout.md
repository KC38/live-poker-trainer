# Plan 11 — Profile, Migration, Observability, Cleanup, and Rollout

**Status: Done**

- Merged: https://github.com/KC38/live-poker-trainer/pull/192
  (`7c3117c`) on `main`
- Acceptance fix: https://github.com/KC38/live-poker-trainer/pull/195
  (`95fcb15`) on `main`. Signed-out clients can read `appConfig/courseFlags`,
  and flags reload when the auth uid changes (including after anonymous
  sign-in). `guestCourseEnabled` gates guest welcome and new anonymous
  onboarding. `courseStartsEnabled=false` does not present a startable Home
  path; an in-progress attempt can still finish. Malformed, failed, and
  too-old-client reads stay fail-closed.
- Flags reload fix: https://github.com/KC38/live-poker-trainer/pull/197
  (`bef5d13`) on `main`. While flags reload after anonymous sign-in, root
  routing keeps the previous successful flags instead of treating Riverpod
  `AsyncLoading` as ready with null flags. A new anonymous guest is not sent
  to Auth during that reload when guest course is already enabled. Signed-out
  and anonymous sessions share the root navigator key, so an in-progress first
  lesson is not disposed just because flags reloaded. A completed error or
  disabled/malformed/too-old read still fails closed and clears that lesson.
  Functions and Firestore rules did not change, so they were not redeployed.
- Cloud Functions deploy: completed from `origin/main` at `95fcb15`
  (includes `completeCalibrationWarmUp`; v2 `fetchSituation` / `recordProgress`
  pool exports stay undeployed)
- Firestore rules deploy: released from `origin/main` at `95fcb15`
  (`appConfig/courseFlags` readable without sign-in; writes still denied)
- CI: `course-contract` passed on PR #192
  (https://github.com/KC38/live-poker-trainer/actions/runs/35592682209),
  on the acceptance fix PR #195
  (https://github.com/KC38/live-poker-trainer/actions/runs/35595600615),
  and on the flags reload fix PR #197
  (https://github.com/KC38/live-poker-trainer/actions/runs/35599163271)
- Simulator: hot-restarted attached Flutter sessions (pids 19321 and 44612)
  after the original ship, after the acceptance fix, and after the flags
  reload fix

## Objective

Finish the product transition safely: combine course and simulator progress in
Profile, add privacy-safe observability, remove proven dead code, migrate
compatible data, and roll out behind controlled gates.

## Profile design

Profile contains distinct sections:

- Identity/avatar
- Course: XP, streak, accepted accuracy, current section, mastery, reviews due
- Live Training: current coaching record, net result, street breakdown,
  personal style, and performance against player types
- Settings and sign-out

Do not merge course accuracy with Live Training coaching statistics; they
measure different activities.

## Reuse

- `ProfileScreen`, identity editor/avatar, `HeroProfiler`, charts, metric grid,
  coaching and archetype breakdown.
- `SettingsScreen` logic and providers.
- Analytics consent and Crashlytics plumbing.

## Modify

- Make Profile a tab root.
- Add a separate course progress model/repository rather than overloading
  `UserStatsModel`.
- Host or link settings from Profile.
- Add tab, onboarding, lesson, grade-band, life-loss, remediation, jump-test,
  warm-up, account-conversion, and merge analytics.
- Update README and architecture/trust-boundary documentation.
- Ensure Functions builds clean generated output before TypeScript compilation.

## Cleanup candidates

Delete only after search, tests, and production export checks prove no caller:

- `lib/ui/screens/stats_screen.dart`
- `lib/services/firestore/situation_service.dart`
- `lib/models/table_setup.dart`
- `situationServiceProvider`
- Dead v2 Functions pool/fetch/progress/generation stack
- Associated obsolete tests and Firestore indexes/rule comments
- Stale compiled academy output under `functions/lib/`

Do not delete situation/edge types still imported by current coach or action
dock code until those consumers are migrated.

## Migration

- Preserve authentication, identity, avatar, preferences, Live Training
  history/progress, and audio settings.
- New users begin with guest onboarding and receive server course state at
  account conversion.
- If data from the reverted academy exists, preserve lifetime XP as explicitly
  labeled legacy metadata only when catalog compatibility can be proven.
- Do not map old lesson IDs to new completion/unlocks automatically.
- Keep incompatible old learning data read-only until telemetry confirms the
  migration, then delete through a dry-run, exact-project guarded script.

## Feature gates and rollout

Use the Firestore `appConfig/courseFlags` contract and client provider added in
Plans 03 and 06. It is owner-independent, read-only to clients, cached only in
memory for the session, and defaults to course disabled on fetch/parse/version
failure. Disabling it hides course starts and guest onboarding while preserving
authenticated access to grandfathered Live Training and Profile.

1. Internal catalog/runtime validation.
2. Staff accounts with course state enabled.
3. New guest onboarding cohort.
4. Authenticated existing-user cohort.
5. Full rollout after crash, completion, merge, and Live Training regression
   gates pass.

Provide a kill switch for course entry without disabling existing Live
Training.

## Analytics privacy

Allowed:

- IDs of public course nodes/objectives
- Timing, grade band, hint/remediation use, completion, tab selections

Forbidden:

- Hole cards or unrevealed cards
- Private grading keys/answer maps
- Full coach/model prompts
- User-entered free text

## Acceptance criteria

- Existing Live Training stats match before and after migration.
- Course and Live metrics are visually and semantically distinct.
- Guest-to-account conversion funnel and merge failures are observable.
- A clean Functions build contains only intended exports.
- Cleanup scripts default to dry run and require exact project confirmation.
- Course can be disabled remotely while Live Training and Profile remain usable.
- Feature-flag tests cover enabled, disabled, malformed, fetch-failed, and
  minimum-version states.
- Full Flutter, Functions, rules, and integration suites pass.

## Dependencies

Plans 01–10.
