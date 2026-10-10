# 02 — Repo map

Primary checkout path differs by machine (`~/live-poker-trainer` or
`~/live_poker_trainer`). Always resolve with:

```bash
PRIMARY="$(tools/primary_checkout.sh)"
```

Feature work happens in `$PRIMARY/.worktrees/<slug>` — never edit the
primary tree for a change.

## Top level

| Path | Role |
| --- | --- |
| `lib/` | Flutter client (Dart) |
| `functions/` | Firebase Cloud Functions (TypeScript) |
| `content/course/` | Course source (`course.json`, schemas, fixtures) |
| `assets/` | Bundled catalog, brand art, audio, course bank public bits |
| `test/` | Flutter unit/widget tests |
| `integration_test/` | Integration tests |
| `docs/` | Architecture, coaching, UI contract, **this handbook** |
| `tools/` | Agent/sim/Jira/course scripts |
| `.cursor/` | Rules, skills, UI design agent command |
| `ios/`, `android/`, `web/` | Platform runners |

## Flutter (`lib/`)

| Path | Role |
| --- | --- |
| `main.dart` | Firebase init, Crashlytics, root `MaterialApp`, agent debug hooks |
| `routing/app_root.dart` | Auth/flags → Welcome / guest course / shell / auth |
| `providers/` | Riverpod: auth, course, game/live session, settings, profile |
| `services/` | Auth, Firestore repos, analytics, guest install, avatars |
| `models/` | Wire models; `models/course/` is catalog + session + onboarding |
| `ui/screens/` | Full screens (Home, Live, Profile, lesson runner, onboarding…) |
| `ui/home/` | Course path, status bar, section picker |
| `ui/course/` | Activity registry, lesson frame widgets, per-renderer activities |
| `ui/widgets/` | Shared table, dock, Rex, cards, nav — **prefer these** |
| `ui/theme/`, `core/constants/` | Theme, colors, chip format, money |
| `core/deal/` | Deal pacing and felt deal/reveal controllers |
| `core/audio/` | Sound / BGM |
| `core/debug/` | Agent UI driver and commands (debug builds) |
| `engine/` | Client-side helpers for display/authored edges — **not** the live authority |

## Backend (`functions/src/`)

| Cluster | Files (examples) |
| --- | --- |
| Entry / exports | `index.ts` |
| Live session + pool | `live_session.ts`, `live_pool.ts`, `live_tree.ts`, `live_hand_generation.ts` |
| Poker engine | `live_poker_engine.ts`, `holdem_evaluator.ts`, `payout.ts` |
| Coaching / LLM | `gemini.ts`, `live_intelligence.ts`, `coaching_facts.ts`, coaches |
| Course | `course_session.ts`, `course_catalog.ts`, `course_hearts.ts`, `course_transfer.ts` |
| Access / setup | `live_access.ts`, `live_setup.ts`, `setup_key.ts` |

## Content pipeline

- Authoring source: `content/course/v2/` (and validators under `tools/course/`).
- Public catalog asset the app loads: `assets/course/v2/catalog.json`.
- Private grading bank is server-side only — never ship answer keys in the
  client catalog tree (`course_catalog.dart` documents this boundary).

## Agent tooling

| Tool | Use |
| --- | --- |
| `tools/primary_checkout.sh` | Resolve primary path |
| `tools/iphone_13_mini_udid.sh` | Resolve mini UDID (never hardcode) |
| `tools/sim_lock.py` | Claim / release the shared mini |
| `tools/agent_tap.py` | Simulator taps for UI agents |
| `tools/jira.py` | Jira from agents |
| `tools/ui_design_agent_loop.sh` | Continuous UI design agent |

## Docs vs code comments

- **Handbook** (`docs/agents/`) — orientation, goals, maps, preferences.
- **Deep contracts** (`docs/architecture.md`, `docs/ui/design-record.md`) —
  authoritative detail; update when behavior/contract changes.
- **File/library comments** — why this module exists, agent gotchas, links
  back to the handbook section that owns the topic.
