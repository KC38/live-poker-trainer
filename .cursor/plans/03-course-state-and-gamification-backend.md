# Plan 03 — Course State and Gamification Backend

## Objective

Add authoritative course attempts, soft grading, XP, accepted accuracy,
streaks, lives, mastery, review scheduling, resume, feature gating, and
jump-test results while keeping course progress isolated from Live Training.

## Reuse

- Firebase callable, authentication, idempotency, transaction, and rate-limit
  patterns from `functions/src/live_session.ts`.
- Coaching grade vocabulary from `functions/src/live_types.ts`.
- Firestore security-rule and emulator-test patterns.
- Server-authoritative trust boundary.

## Add

Cloud Functions:

- `startCourseLesson`
- `submitCourseStep`
- `completeCourseLesson`
- `getCourseState`
- `initializeCourseProfile`

Firestore:

- `users/{uid}/course/main`
- `users/{uid}/courseAttempts/{attemptId}`
- `users/{uid}/courseStepReceipts/{idempotencyKey}`
- `users/{uid}/courseReviews/{reviewId}`
- `users/{uid}/courseXpLedger/{entryId}`
- `users/{uid}/entitlements/liveTraining` (Admin SDK only), containing
  unrestricted-access state, source (`grandfathered`, `section4_jump`,
  `admin`), and granted timestamp.
- `appConfig/courseFlags`
- `lib/providers/course_flags_provider.dart` and a small repository/model for
  parsing the flag document.

Feature flags are read-only to clients and server-controlled. Define:

- `courseEnabled`
- `courseStartsEnabled`
- `guestCourseEnabled`
- `placementTestsEnabled`
- `catalogVersion`
- `minimumClientVersion`

Fetch failure defaults to course disabled. Authenticated users still retain
Live Training and Profile when course is disabled.

Firestore rules allow signed-in users (including anonymous users) to read only
`appConfig/courseFlags`; writes remain Admin SDK only.

Every course callable performs a server-side `assertCourseAvailable` check.
New starts/profile initialization require `courseEnabled`,
`courseStartsEnabled`, and a compatible catalog/client version. Anonymous
initialization/starts additionally require `guestCourseEnabled`; this check is
server-side. Starting any node whose format/stage is placement or jump test
also requires `placementTestsEnabled`; direct callable use cannot bypass it.
Step submission/completion behavior is explicit:
`courseEnabled=false` rejects all mutations for an emergency stop; a separate
`courseStartsEnabled=false` can pause new attempts while allowing already
started attempts to finish. Direct callable clients cannot bypass these gates.

Completing the published Section 4 jump-test objective writes the Live Training
entitlement transactionally with course completion. Plan 10 consumes and
enforces this contract; content plans only define which validated objective
grants it.

## Soft-grading contract

| Grade | Accepted | Costs life | Effect |
|---|---:|---:|---|
| recommended | yes | no | full mastery weight |
| strong | yes | no | high mastery weight |
| reasonable | yes | no | accepted, coaching may compare |
| questionable | no | no | corrective feedback/remediation |
| clear_mistake | no | eligible | corrective feedback/remediation |

Additional rules:

- Guided and scaffolded activities never cost lives.
- Only scored unguided/checkpoint/jump-test `clear_mistake` choices are life
  eligible.
- Lives are lesson-local learning affordances, not purchasable energy.
- Reaching zero triggers a short remediation loop and retry, not a paywall.
- Accepted accuracy and weighted mastery are separate metrics.

## Streak and XP rules

- Credit at most one study day per user-local calendar day.
- Missed days end the streak without deleting lifetime XP/mastery.
- XP is awarded through an auditable ledger and idempotency key.
- Attempts resume at the exact unfinished activity.
- Catalog version is recorded on every attempt.

## Security and abuse controls

- Every attempt belongs to a Firebase UID, including transparent anonymous
  users introduced in Plan 05.
- App Check is enforced where supported before broad guest rollout.
- Per-UID and per-device/IP coarse rate limits protect lesson start/submission.
- Clients never submit a grade; they submit only activity and choice IDs.
- Private grading banks remain Functions-only.

## Course/Live isolation

- Course writes never increment `liveProgress`, `liveHandHistory`, or
  `liveHandReceipts`.
- Live Training remains governed by its current session and pool contracts.
- Hand labs use a mode/attempt context and course-specific completion path.

## Acceptance criteria

- Duplicate start/submit/complete calls cannot duplicate state changes.
- Reasonable or questionable answers never lose lives.
- Private grading keys never reach Flutter.
- Owner can read aggregate course progress; client cannot write progress.
- Resume works across devices for linked accounts.
- Course state can be rebuilt/audited from attempts and XP receipts.
- Turning the course flag off does not disable existing Live Training.
- Disabled/version-incompatible course callables fail closed server-side, not
  only in the client.
- Placement/jump-test callables fail closed when their dedicated flag is off.
- Entitlement writes are server-only, idempotent, and tied to a validated
  passing attempt.

## Verification

- Unit tests for every grade/stage combination.
- Timezone streak tests: same day, next day, missed day, DST boundary.
- Firestore emulator tests for authorization and idempotency.
- Concurrency and abuse-limit tests.
- Regression tests proving existing Live Training documents are unchanged.
- Feature-flag tests for enabled, disabled, version mismatch, and read failure.

## Dependencies

Plan 02.
