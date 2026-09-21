# Plan 05 — Lesson-First Onboarding and Account Linking

**Status: Done**

- Merged: https://github.com/KC38/live-poker-trainer/pull/176
  (`166a67f`) on `main`
- Cloud Functions deploy: verified from `origin/main` at `3adb18e`
  (includes `issueAnonymousProgressTransfer`,
  `redeemAnonymousProgressTransfer`,
  `cleanupExpiredCourseTransfersJob`; redeploy reported unchanged)
- Firestore rules deploy: released `courseTransferReceipts` /
  `courseTombstones` admin-only rules from the same main tip
- Acceptance review: PASS (guest-first onboarding, anonymous UID grading,
  link-preserves-UID, single-use transfer + entitlement merge, lesson-two
  account gate, Live Training blocked for anonymous)
- Simulator: refresh attempted after deploy; skip if no attached session

## Objective

Let a new user choose an experience level and complete the first interactive
lesson before seeing account creation. Use transparent Firebase anonymous
authentication so server grading is secure, then link or transfer progress
when the learner creates/signs into an account.

The user experience is “guest”; the implementation still has a temporary,
server-recognized UID.

## Reuse

- Existing email/password and Google authentication in `AuthScreen`,
  `AuthService`, and `AuthController`.
- Firebase Auth session observation and user-document bootstrap.
- Server course attempts from Plan 03 and lesson route from Plan 04.

## Modify

- `lib/main.dart` root state becomes:
  `anonymous onboarding → first lesson → save-progress prompt → linked shell`.
- Auth supports a save-progress context and returns to the exact post-lesson
  result after success.
- User-document validation/bootstrap supports anonymous course users without
  granting Live Training/Profile capabilities intended for linked accounts.

## Add

- Experience choices:
  - New to poker
  - Know the rules / home games
  - First casino sessions
  - Regular live cash player
- Daily time goal.
- Recommended start and optional placement/jump-test entry when the active
  catalog advertises a published test for that experience band.
- Transparent `signInAnonymously()` before the first server-backed attempt.
- Account linking/transfer workflow.
- Post-first-lesson save-progress prompt.
- `issueAnonymousProgressTransfer` and
  `redeemAnonymousProgressTransfer` callables.
- Admin-only top-level `courseTransferReceipts/{receiptId}` documents with
  source UID, nonce hash, catalog version, expiry, consumed destination UID,
  and status.
- Firestore TTL policy/cleanup job for expired receipts and tombstoned
  anonymous course data.

## Secure account conversion

1. New email/Google credential: link it to the anonymous Firebase user so the
   UID and progress remain unchanged.
2. Existing credential conflict:
   - While still anonymous, request a short-lived, single-use transfer receipt
     containing a random nonce and source UID.
   - Sign into the existing account.
   - Redeem the receipt through an authenticated callable.
   - Merge compatible progress transactionally and tombstone the source.
3. Retries use a merge receipt and cannot duplicate XP, streak, mastery, or
   completion.
4. The client cannot manufacture a source UID or transfer receipt.
5. The issue callable requires an anonymous auth token; the redeem callable
   requires a non-anonymous destination token. Both validate expiry, nonce
   hash, catalog compatibility, and one-time status in a transaction.
6. Redeemed/expired source data is retained only for the documented recovery
   window, then deleted by TTL/guarded cleanup.
7. In the same redemption transaction, copy/derive any server-validated
   `entitlements/liveTraining` grant from the anonymous source to the
   destination. Preserve a stronger/existing destination grant, record the
   original entitlement source, and never accept an entitlement claim from the
   client.

Until linking, copy clearly says progress is temporary and can be lost if the
anonymous session is cleared.

## UX sequence

1. Value proposition with **Get started** and **I already have an account**.
2. Experience choice.
3. Daily goal.
4. Rex introduction.
5. Recommended start; offer a jump test only when its catalog node exists and
   the server flags placement tests enabled.
6. First interactive lesson.
7. Celebration and earned progress.
8. “Create an account to save your progress.”
9. Successful link/transfer opens Home at the next node.

Default policy: an account is required before lesson two. This keeps the first
experience frictionless without building a broad anonymous-data lifecycle.

## Acceptance criteria

- Fresh users reach and finish the first interaction without an account form.
- All grading is server-authored under an anonymous Firebase UID.
- Creating a new account preserves the UID and progress.
- Signing into an existing account transfers compatible progress exactly once.
- A valid Live Training entitlement earned by the anonymous source transfers
  exactly once and survives source tombstoning.
- Failed/cancelled auth returns to the saved anonymous result state.
- Existing users can sign in immediately from the opening screen.
- Selecting “Regular” recommends a jump test but never unlocks content alone.
- Before the later content waves publish jump tests, the same experience choice
  stores its recommendation and starts at the production first lesson; it
  never links to a missing test.
- Anonymous users cannot access unrestricted Live Training.

## Verification

- Auth emulator tests for anonymous sign-in, credential linking, collision,
  transfer receipt expiry, replay, wrong destination state, TTL metadata, and
  authorization.
- Transfer tests cover source entitlement present/absent, stronger destination
  entitlement, retry, and forged client entitlement input.
- Widget tests for every onboarding/interruption route.
- Integration test: install → first lesson → Google/email link → Home next node.
- Analytics tests proving no cards, credentials, nonce, or answer keys log.

## Dependencies

Plans 01–04.
