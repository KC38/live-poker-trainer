# Plan 10 — Course and Live Training Bridge

**Status: Done**

- Merged: https://github.com/KC38/live-poker-trainer/pull/188
  (`2af3de2`) on `main` — isolated course warm-ups, hand labs, calibration
  launch, and Live access gates
- Return path fix: https://github.com/KC38/live-poker-trainer/pull/191
  (`f9da7fc`) on `main`. A finished calibration hand
  (`lesson-07-11-01-live-warmup-prep`) resumes the lesson result node
  (`result:lesson-07-11-01-live-warmup-prep`) on `LessonResultScreen`.
  Header back after the hand still opens that result and marks the lesson
  complete via `completeCalibrationWarmUp`. Leaving before the hand finishes
  returns to Home and does not mark the lesson complete. It does not restart
  the first activity.
- Cloud Functions deploy: `completeCalibrationWarmUp` created from
  `origin/main` at `f9da7fc`. A follow-up deploy from `origin/main` at
  `7c3117c` reported no function changes, so production matches current main
  (the return-path callable plus later course profile fields).
- CI: `course-contract` passed on PR #191
  (https://github.com/KC38/live-poker-trainer/actions/runs/35592701791)
  and on PR #188
  (https://github.com/KC38/live-poker-trainer/actions/runs/35588907459)
- Simulator: hot-restarted attached Flutter sessions after merge
- Bridge: course-v1 warm-ups, curated hand labs, and Section 7 calibration
  stay off `live-v3` pools and do not write live receipts, history, or progress
- Access: anonymous Live callables rejected; pre-cutoff accounts grandfathered;
  Section 2 jump unlocks warm-ups; Section 4 entitlement unlocks random Live

## Objective

Connect deterministic course hand labs and coached warm-ups to the mature Live
Training engine without mixing their pools, attempts, statistics, or grading.

## Reuse

- Authoritative engine, legal actions, side pots, showdown, fixed runout, and
  hidden-information projection.
- Live table widgets, action dock, coach shelf, replay events, and tendency
  sheets.
- Coaching rubric and player-type reasoning.

## Add

- Course session mode and lesson-attempt context.
- Lesson-scoped setup keys and curated hand specifications.
- Small pre-generated pools for course hand labs.
- Course-specific completion callback mapping action assessments to mastery.
- Rex overlay/prompt mode for coached warm-ups.
- Explicit Live Training readiness gates.

## Access progression

The Live Training tab is always visible so the app structure stays predictable:

1. **Before Section 2 checkpoint:** tab explains that Live Training is advanced
   and links to the next Home lesson or placement test.
2. **After Section 2/table-ready checkpoint:** a Rex-guided warm-up is
   available with hints and selected authored situations.
3. **After Section 4 checkpoint or equivalent jump test:** unrestricted
   existing random Live Training unlocks.
4. **Section 7 capstone:** Home launches a calibration warm-up in the same table
   surface with reduced scaffolding, then returns to the result node.

Access gates apply to accounts created on or after a configured rollout
cutoff. Every linked account created before that cutoff is grandfathered into
unrestricted access, regardless of whether it has recorded a hand. Experience
placement can offer the Section 4 jump test once Plan 08 publishes it and the
server enables placement tests. Anonymous users cannot access unrestricted
Live Training.

The gate is enforced in the Live Functions, not only in Flutter:

- All start/resume/submit/undo Live callables reject anonymous auth tokens.
- `startLiveHand` checks a server-authored Live entitlement or the rollout
  cutoff against immutable user creation time.
- New linked users unlock through the Section 4 checkpoint/jump test, written
  by the course backend.
- Grandfathering configuration is server-controlled and covered by emulator
  tests.

## Isolation rules

- Course keys use a separate prefix/version from `live-v3|random|...`.
- Course hands never consume `liveHandReceipts`.
- Course completion never writes `liveProgress` or `liveHandHistory`.
- Live Training never advances a course node unless launched with a signed
  course attempt token.
- Curated course lineups specify player types, positions, stacks, and runout.
- The same engine validates all actions and payouts in both modes.

## Modify

- Parameterize live setup/session infrastructure with a strongly typed mode,
  rather than duplicating the engine.
- Extend `GameController`/table entry with immutable course context.
- Adapt coach shelf copy/continue behavior for lesson completion.
- Preserve current unrestricted Live Training defaults and API compatibility.

## Cost and latency controls

- Author/publish deterministic hand definitions ahead of use.
- Warm only the branches required by the lesson.
- Cap course hand-lab decisions.
- Static authored feedback may be used for early deterministic activities;
  model-generated coaching is reserved for suitable advanced hand labs.

## Acceptance criteria

- A course hand and random live hand can never be allocated from the same pool.
- Course decisions affect course mastery only.
- Existing Live Training statistics are byte-for-byte unchanged by a course
  attempt.
- Grandfathered existing users retain the access they had before rollout.
- Direct callable use cannot bypass anonymous or readiness restrictions.
- Hidden cards and future runout remain server-only.
- Returning from a warm-up resumes the exact Home node/result.
- Undo/hints follow the lesson stage; unrestricted Live Training retains its
  current behavior.
- Existing Live Training tests remain green.

## Verification

- Engine parity tests with identical hand definitions in both modes.
- Emulator tests for pool/progress isolation.
- Integration tests for Home → warm-up → result → Home.
- Regression soak for unrestricted Live Training.

## Dependencies

Plans 03 and 04. Full unlock behavior also depends on content checkpoints in
Plans 07–09.
