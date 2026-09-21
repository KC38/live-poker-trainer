# Plan 02 — Course Contract and Content Pipeline

**Status: Done**

- Merged: https://github.com/KC38/live-poker-trainer/pull/168
  (`9e3c93e`) on `main`
- Cloud Functions deploy: completed from `origin/main` at `9e3c93e`
- CI: `course-contract` passed on PR #168
  (https://github.com/KC38/live-poker-trainer/actions/runs/35575745744)
- Simulator: hot-restarted attached Flutter sessions after merge

## Objective

Define a versioned, validated, live-cash-NLH-only curriculum contract shared by
Flutter and Cloud Functions. This plan adds no production lesson UI.

## Reuse

- Qualitative coaching grades from `functions/src/live_types.ts`:
  `recommended`, `strong`, `reasonable`, `questionable`, `clear_mistake`.
- Existing card, street, action, archetype, and tendency vocabulary.
- Useful schema/testing ideas from the reverted Learning Academy, reviewed
  file by file rather than restored wholesale.

## Add

- Canonical source under `content/course/v2/`.
- JSON schemas for course, section, unit, lesson, activity, grading, hand-lab
  specification, and coach media references.
- `tools/course/validate_course.mjs`.
- Sanitized client catalog under `assets/course/v2/`.
- Private grading/content bank generated for Cloud Functions.
- Matching Dart and TypeScript parser models.
- `pubspec.yaml` asset registration for `assets/course/v2/`.
- Root/Functions package scripts that validate and generate content before
  build, and clean `functions/lib/` before `tsc` so reverted academy output
  cannot survive a build.
- A course-validation GitHub workflow, because the repository has no CI
  workflow today.

## Course hierarchy

`Course → Section → Unit → Lesson node → Activity`

Activity stages:

1. `explain`
2. `guided`
3. `scaffolded`
4. `unguided`
5. `checkpoint`
6. `jump_test`

Supported formats initially:

- Coach dialogue/demonstration
- Select/identify
- Order/sequence
- Compare/rank
- Numeric pot/price interaction
- Poker action and sizing choice
- Player-read classification
- Authored multi-step hand
- Lesson-scoped full-table hand lab

## Required metadata

- Stable IDs, version, prerequisites, objectives, remediation IDs, and
  estimated duration.
- `scope: live_cash_nlh`.
- Difficulty/experience band.
- `playerTypeRefs`, with an explicit introduction objective before use.
- Public prompt/choice data separated from private grade and feedback data.
- Accepted grade bands and whether a step is eligible for life loss.
- Accessibility text for visual-only interactions.

## Validator rules

- Reject tournaments, online-only/HUD instruction, PLO/Omaha, other variants,
  and rake instruction.
- Reject cycles, unreachable nodes, broken prerequisites, missing remediation,
  duplicate IDs, or unknown activity renderers.
- Reject a player type before its introduction.
- Reject client assets containing correct answers, grades, reversal reads, or
  other private grading metadata.
- Reject `clear_mistake` life loss on guided/scaffolded activities.
- Reject hand labs without an authoritative server specification.
- Verify generated client/server catalogs share the same version and checksum.

## Acceptance criteria

- One command validates source content and generates both sanitized outputs.
- Flutter bundles the generated public catalog and Functions builds from the
  generated private bank.
- Dart and TypeScript parse the same fixture and produce matching IDs/order.
- No private grading data appears in Flutter assets.
- The contract supports all seven planned course sections without adding
  excluded poker formats.
- A clean Functions build contains no stale/reverted academy exports.
- CI runs schema validation, generation-diff checks, and parser tests.

## Verification

- Catalog invariant tests in Dart and TypeScript.
- Deliberately invalid fixtures for every validator rule.
- Snapshot/checksum test preventing unsynchronized generated assets.

## Out of scope

Authoring the full course, persistence, UI, XP, streaks, and Live Training
integration.

## Dependencies

None. Plan 01 may proceed in parallel.
