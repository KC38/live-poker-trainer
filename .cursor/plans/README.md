# Interactive Live Cash Course Plans

These plans replace the repository's prior planning direction. No older plan
files existed in the current tree, so there was nothing to delete.

## Product destination

The app has exactly three persistent destinations:

1. **Home** — a deep, interactive live cash NLH course.
2. **Live Training** — the existing advanced full-hand simulator.
3. **Profile** — identity, course progress, simulator statistics, and settings.

The course is inspired by lessons from Duolingo Chess without copying its
visual identity. It teaches by doing, introduces one idea at a time, reduces
scaffolding over repeated attempts, and keeps reading short.

## Locked product decisions

- Scope is live cash No-Limit Hold'em only.
- Exclude tournaments, online-specific strategy/HUDs, PLO/other variants, and
  rake instruction.
- Placement is based on experience, not stakes.
- New users start onboarding and complete their first lesson before account
  creation. A transparent anonymous Firebase UID secures that attempt; creating
  or signing into an account links/transfers the progress idempotently.
- The course coach is **Rex**, a concise live-reg character who speaks in one
  short sentence at a time.
- `recommended`, `strong`, and `reasonable` choices are accepted.
- `questionable` choices receive coaching but do not cost a life.
- Only a server-graded `clear_mistake` may cost a life, and guided examples
  never cost lives.
- Player types are a progressive course thread, not a single glossary lesson.
- A Home capstone node launches a coached warm-up in Live Training.
- Leagues, social competition, quests, and a shop are not planned.

## Current-state disposition

### Reuse

- Server-authoritative poker engine, legal actions, pots, and showdown:
  `functions/src/live_poker_engine.ts`, `holdem_evaluator.ts`, `payout.ts`.
- Coaching rubric and soft ratings:
  `functions/src/live_intelligence.ts`, `coaching_facts.ts`,
  `functions/src/live_types.ts`.
- Player archetypes and bounded tendencies:
  `functions/src/tendency_profiles.ts`, `lib/models/player_model.dart`,
  `lib/models/tendency_profile_model.dart`.
- Full Live Training experience:
  `lib/ui/screens/poker_table_screen.dart`, `lib/providers/game_provider.dart`,
  `lib/services/firestore/live_hand_service.dart`, and table widgets.
- Profile identity and simulator statistics.
- Auth, theme, audio, analytics plumbing, and Firebase bootstrap.

### Modify

- `lib/main.dart`: route guests through onboarding/course before auth and
  authenticated users into the three-tab shell.
- `lib/ui/screens/home_screen.dart`: replace the training launcher with the
  course path.
- Existing Home setup/launch logic: move it to the Live Training tab.
- `lib/ui/screens/profile_screen.dart`: become a tab root and include course
  progress plus settings access.
- Live session infrastructure: support isolated, lesson-scoped hand labs
  without contaminating Live Training history or progress.
- Firestore rules and analytics vocabulary for course state and guest merge.

### Retire or delete

- The current Home-as-training-launcher presentation after its logic is moved.
- `lib/ui/screens/stats_screen.dart` after confirming no external route uses it.
- Dead v2 situation client/runtime code after replacement tests prove it has no
  production callers.
- Stale generated curriculum JavaScript under `functions/lib/`; source and
  generated output must be rebuilt from the new course contract.
- Do not restore the reverted Learning Academy wholesale. Its schema and tests
  are references only; its four-tab shell, binary grading, and broad poker
  scope conflict with this product.

### Add

- Three-tab shell.
- Versioned live-cash course catalog and validator.
- Guest-first onboarding and idempotent account merge.
- Authoritative course attempts, progress, streak, XP, lives, mastery, and
  reviews.
- Home path, Rex coach components, lesson runtime, authored activities, jump
  tests, and lesson-scoped hand labs.
- Course progress in Profile and course analytics.

## Plan order

| Plan | Scope | Depends on | Status |
|---|---|---|---|
| [01](01-three-tab-shell-and-live-hub.md) | Three-tab shell and Live hub | — | Done (PR #164 / #165; deploy from `db50d28`) |
| [02](02-course-contract-and-content-pipeline.md) | Course schema and validator | — | Done (PR #168; deploy from `9e3c93e`) |
| [03](03-course-state-and-gamification-backend.md) | Attempts, grading, XP, streak, lives | 02 | Done (PR #170; deploy from `90b2cdf`) |
| [04](04-interactive-lesson-runtime.md) | Guided-to-unguided activity engine | 02, 03 | Done (PR #172; deploy from `192fdb3`) |
| [05](05-lesson-first-onboarding-and-account-linking.md) | Anonymous lesson-first onboarding/linking | 01–04 | Done (PR #176; deploy verified from `3adb18e`) |
| [06](06-home-course-map-and-rex-coach.md) | Home path and coach | 01–05 | Done (PR #180; deploy from `5fe26c4`) |
| [07](07-course-wave-one-foundations.md) | Sections 1–2 | 02, 04 | Done (PR #174; deploy from `ecf3ba9`) |
| [08](08-course-wave-two-live-competence.md) | Sections 3–4 and player types | 07 | |
| [09](09-course-wave-three-advanced-play.md) | Sections 5–7 and integrated play | 08 | |
| [10](10-live-training-course-bridge.md) | Coached warm-up and hand labs | 03, 04, 07–09 | |
| [11](11-profile-migration-observability-rollout.md) | Profile, cleanup, rollout | 01–10 | |

Plans 01 and 02 can run in parallel. Then implement 03 → 04 → 05 → 06.
Content waves begin only after the content validator and interactive runtime are
stable.

## Quality bar for every implementation PR

- Preserve the server trust boundary and hidden information.
- Add tests before deleting old behavior.
- Keep course and Live Training progress isolated.
- Provide deterministic authored exercises; do not make beginner progress
  depend on live model generation.
- Validate accessibility, small-phone layout, interruption/resume behavior,
  idempotency, and analytics privacy.
- Ship each plan as one or more reviewable PRs; do not combine all plans into
  one release.
