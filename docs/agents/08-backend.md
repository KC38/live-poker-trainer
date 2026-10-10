# 08 — Backend (Cloud Functions + Firestore)

Project id: `live-poker-trainer`. Region for callables: `us-central1`.

## Mental model

Functions are the product brain. Flutter renders projected views and sends
idempotent commands. Secret `GEMINI_API_KEY` exists only in Functions /
Secret Manager.

## Major export groups (`functions/src/index.ts`)

**Live**

- `startLiveHand`, `submitLiveAction`, `resumeLiveHand`, `undoLiveAction`
- Pool workers: refill / process generation jobs / lease recovery
- Anonymous users rejected for Live callables

**Course**

- `getCourseState`, `initializeCourseProfile`, `startCourseLesson`,
  `submitCourseStep`, `completeCourseLesson`, heart refill, etc.
- Transfer: issue/redeem anonymous progress; scheduled cleanup

**Access / bridge**

- Live access resolution
- Course ↔ Live warm-up / calibration completion helpers

v2 `fetchSituation` / `recordProgress` / old pool exports are **gone**.
`npm run build` wipes `functions/lib/` before `tsc` so stale JS cannot ship.

## Key modules

| Module | Responsibility |
| --- | --- |
| `live_poker_engine.ts` | Cent-exact NLH: blinds, raises, side pots, runout, showdown |
| `live_session.ts` | Session cursor, submit/resume, projections |
| `live_tree.ts` / `live_pool.ts` | Shared nodes, leases, inventory policy |
| `live_hand_generation.ts` | Deal + warm jobs |
| `live_intelligence.ts` / `gemini.ts` | Villain + coaching model I/O |
| `coaching_facts.ts` | Deterministic facts for rubrics |
| `course_session.ts` | Lesson attempts, grading against private bank |
| `course_hearts.ts` | Hearts economy |
| `course_catalog.ts` | Server catalog / bank views |
| `live_access.ts` | Unlock rules |

## Firestore privacy sketch

| Data | Client |
| --- | --- |
| Private deals, tree nodes, jobs, receipts | Admin only |
| Session cursor / decision results | Owner session paths as designed |
| Course progress, live history/progress | Owner read |
| `appConfig/courseFlags` | Read (incl. signed-out); Admin write |
| Avatars | User Storage rules |

Full boundaries: [architecture.md](../architecture.md).

## Deploy

After every successful merge to `main`, make-change deploys Functions via
`.cursor/skills/make-change/scripts/deploy-functions.sh` (needs
`FIREBASE_SERVICE_ACCOUNT` / `GOOGLE_APPLICATION_CREDENTIALS` /
`FIREBASE_TOKEN`). GitHub Actions is the other path when credentials exist
there.

Do not `firebase login` interactively from an agent session.

## Tests / gates

- `cd functions && npm test` — unit + rules tests as configured.
- Coaching benchmark scripts when changing coaching models/prompts
  (`npm run benchmark:coach` …) — see coaching-quality.md.
- Emulator tests for session/transfer where marked `*.emulator.test.ts`.

## Agent gotchas

- Never put `GEMINI_API_KEY` in the Flutter app or commit secrets
  (`firebase_options.dart`, `GoogleService-Info.plist`, etc. stay untracked
  copies into worktrees only).
- Perspective isolation: villain prompts must not see Hero hole cards.
- Generation must stay inside function deadlines — jobs are split per hand.
