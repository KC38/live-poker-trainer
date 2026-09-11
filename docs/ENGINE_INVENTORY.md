# Engine Inventory — `lib/engine`

> Snapshot taken from `main` on 2026-09-11.
> Covers structure, public APIs, interconnections, tests, and gaps/risks.

---

## 1. Module Map (19 files)

| Module | LOC\* | Role | Key public API |
|---|---|---|---|
| `poker_engine.dart` | ~1 345 | **Core table engine**: deals, blinds, streets, pot, showdown | `PokerEngine` — `startHand`, `submitHeroAction`, `applyHeroAction`, `nextEvent`, `runToHeroOrEnd`, `startPracticeScenario`, `dealScenarioHand`, `gradeHeroAction`; `PokerAction`, `PokerActionType`, `TableEvent`, `TableEventKind` |
| `live_coach.dart` | ~795 | **EV grading & recommendation** for hero decisions | `LiveCoach.grade(state, action)` → `LiveCoachGrade`; `LiveCoach.recommend(state)` → `LiveCoachRecommendation`; `LiveCoachGrade.toPrompt()` for Claude |
| `decision_ev.dart` | ~530 | **EV model**: prices fold/check/call/raise, picks best line | `DecisionModel.analyse(SpotView)` → `DecisionAnalysis`; `DecisionModel.priceHeroAction(...)` → `ActionEv`; `SpotView`, `VillainView`, `ActionEv` |
| `equity.dart` | ~350 | **Equity engine**: exact enumeration (turn/river HU) or seeded Monte Carlo | `EquitySimulator.heroEquity(...)` → `EquityResult`; `EquitySimulator.spotSeed(...)` |
| `fast_evaluator.dart` | ~255 | **Allocation-light 7-card evaluator** for Monte Carlo hot loops | `FastEvaluator.score(cards)`, `encode`, `decode`, `encodeAll`, `categoryOf`, `primaryRankOf`, `straightHigh`, `rankMaskOf` |
| `deck_evaluator.dart` | ~210 | **Canonical 7-card evaluator** (showdown, display names) | `DeckEvaluator.evaluate7Cards(cards)` → `HandRank`; `buildShuffledDeck()`; `checkStraight()` |
| `hand_class.dart` | ~170 | **Board-relative hand classification** | `HandClassifier.classify(a, b, board)` → `HandClass`; `HandClassifier.drawOuts(...)` |
| `hand_range.dart` | ~350 | **Weighted combo ranges** + building/narrowing logic | `HandRange` — `fromLabels`, `all`, `sample`, `removeCards`, `reweight`, `composition`; `RangeBuilder.preflop(...)`, `.narrow(...)`, `.foldEquity(...)`, `.continuingAgainst(...)` |
| `preflop_chart.dart` | ~150 | **169 starting-hand ranking** + top-N% selection | `PreflopChart.topPercent(percent)`, `ranking`, `expand(label)`, `labelFor(cardA, cardB)` |
| `villain_model.dart` | ~240 | **Archetype action frequencies** (bet/call/raise/fold by hand class) | `VillainModel.betFrequency(...)`, `callFrequency(...)`, `raiseFrequency(...)`, `foldFrequency(...)`, `continueFrequency(...)`, `profileFor(...)` |
| `villain_ai.dart` | ~300 | **Villain decision sampler** (one RNG draw per action) | `VillainAi.decide(state, playerIdx, random)` → `VillainChoice`; `handClassFor(...)`, `betSizeFraction(...)` |
| `bet_sizing.dart` | ~110 | **Legal raise-range math** for hero action dock | `RaiseRange.forHero(game)` — `min`, `max`, `allowed`, `isAllInOnly`, `snapToBb(...)`, `forFraction(...)` |
| `coach_lines.dart` | ~775 | **Offline coaching copy** (street-specific, archetype-aware) | `CoachLines.forGrade(...)`, `CoachLines.ambiguous(...)`, `CoachMismatch`, `CoachReasonCode`, `CoachEvidence`, `CoachPersona` |
| `coach_advice_guard.dart` | ~330 | **Post-process guard** for Claude/offline copy (contradiction, facts, curriculum) | `CoachAdviceGuard.reconcile(...)`, `.contradictsBest(...)`, `.isInternallyContradictory(...)`, `.contradictsFacts(...)` |
| `coach_policy.dart` | ~60 | **Grading-policy description** for Leak Finder UI | `CoachPolicy.ruleFor(archetype)`, `.closeSpotNote`, `.twoSidedNote` |
| `leak_lines.dart` | ~140 | **Repeat-mistake / improvement phrasing** | `LeakLines.repeatPrefix(...)`, `.improvementPrefix(...)`, `.repeatBadge(...)`, `.improvementBadge(...)` |
| `hero_profiler.dart` | ~710 | **Hero statistics & style classification** from hand history | `HeroProfiler.compute(hands)` → `HeroMetrics`; `classify(...)` → `StyleReadout`; `leaksFor(...)`, `trendFor(...)` |
| `scenario_grader.dart` | ~45 | **EV-stamps scenario optimal** via LiveCoach | `ScenarioGrader.resolveOptimal(scenario)` |
| `scenario_manager.dart` | ~455 | **Scenario orchestration** (Firestore pool, offline fallback, grading) | `ScenarioManager.nextScenario()`, `.gradeAndRecord(...)`, `.maybePrefetch()`, `.unplayedCount()`, `.engagementScore(...)` |

\* Approximate, including doc comments.

---

## 2. Dependency Graph

```
                          ┌──────────────────┐
                          │  scenario_manager │  (Firebase: cloud_functions, firebase_auth,
                          │                   │   firestore repos, Config, DiagnosticsLog)
                          └──────┬──────┬─────┘
                                 │      │
                    ┌────────────┘      └──────────┐
                    ▼                               ▼
            ┌──────────────┐               ┌──────────────┐
            │scenario_grader│               │ poker_engine  │
            └───────┬───────┘               └──────┬───────┘
                    │                              │
                    ▼                              │
            ┌──────────────┐                       │
            │  live_coach   │ ◄────────────────────┘
            └──────┬───────┘
                   │
       ┌───────────┼───────────────────┐
       ▼           ▼                   ▼
 ┌───────────┐ ┌──────────┐  ┌──────────────┐
 │decision_ev│ │coach_lines│  │coach_advice_ │
 └─────┬─────┘ └────┬─────┘  │    guard     │
       │             │        └──────────────┘
       │         ┌───┘
       ▼         ▼
 ┌──────────┐  ┌──────────┐
 │  equity   │  │hand_class│
 └─────┬────┘  └─────┬────┘
       │             │
       ▼             ▼
 ┌───────────────────────┐
 │   fast_evaluator      │
 └───────────────────────┘

 ┌──────────┐  ┌──────────────┐  ┌──────────────┐
 │hand_range │──│preflop_chart │  │villain_model │
 └─────┬────┘  └──────────────┘  └──────┬───────┘
       │                                │
       └──────┐        ┌────────────────┘
              ▼        ▼
        ┌──────────────────┐
        │   villain_ai     │ ◄── poker_engine
        └──────────────────┘

 ┌────────────────┐  ┌──────────────┐  ┌────────────┐
 │ deck_evaluator  │  │  bet_sizing  │  │ leak_lines │
 └────────────────┘  └──────────────┘  └────────────┘
 ┌────────────────┐  ┌──────────────┐
 │  hero_profiler  │  │ coach_policy │
 └────────────────┘  └──────────────┘
```

**External model dependencies** (outside `lib/engine/`):
- `models/card_model.dart`, `game_state.dart`, `game_settings_model.dart`, `player_model.dart`, `scenario_model.dart`, `coach_feedback.dart`, `mistake_model.dart`, `hand_history_sample.dart`, `hero_metrics.dart`
- `core/constants/money.dart`, `core/constants/chip_format.dart`, `core/constants/config.dart`
- `core/diagnostics/diagnostics_log.dart`
- `services/firestore/` (3 repos: `scenario_pool_repo`, `played_scenarios_repo`, `user_repository` + `scenario_pool_doc`)
- Firebase SDKs: `cloud_functions`, `firebase_auth` (only in `scenario_manager.dart`)

---

## 3. How the Subsystems Hang Together

### Game Logic
`PokerEngine` is the mutable table state machine. It deals cards (`DeckEvaluator.buildShuffledDeck`), posts blinds, advances streets, runs villain AI (`VillainAi.decide`), and resolves showdowns (`DeckEvaluator.evaluate7Cards`). Immutable `GameState` snapshots flow out after every action. The step-wise `nextEvent()` produces `TableEvent`s so the UI can replay felt animation one seat at a time.

### Villain AI / Opponent Model
`VillainModel` holds hand-authored action-frequency tables per archetype × `HandClass`. `VillainAi` samples these using a single RNG draw per action to pick fold/check/call/raise. Preflop uses chart-based heuristics; postflop uses `HandClassifier` + the frequency tables. The frequencies feed both the felt play and the coaching ranges.

### Coaching / EV Grading
`LiveCoach.grade()` is the hot path: it builds villain ranges (`RangeBuilder.preflop` + `RangeBuilder.narrow`), runs equity (`EquitySimulator.heroEquity`), prices every legal line (`DecisionModel.analyse`), and compares the hero's action to the best. `CoachLines` builds offline copy; `CoachAdviceGuard` validates Claude-generated advice against the graded facts. `LeakLines` handles repeated-mistake / improvement phrasing.

### Ranges & Equity
`PreflopChart` provides the 169-hand ranking. `HandRange` stores 1326 weighted combos; `RangeBuilder` builds from archetype VPIP/PFR and narrows by observed action. `EquitySimulator` runs exact enumeration (turn/river HU) or seeded Monte Carlo. `FastEvaluator` is the low-allocation evaluator for hot loops; `DeckEvaluator` is canonical for showdown.

### Scenarios
`ScenarioManager` pulls practice scenarios from a Firestore pool (or offline fallback templates), EV-stamps them via `ScenarioGrader.resolveOptimal()` → `LiveCoach.recommend()`, and grades hero actions via `gradeAndRecord()`. `ScenarioGrader` sets up a `PokerEngine` in practice mode and delegates to the same EV stack used in full-hand training.

### Hero Profiling
`HeroProfiler.compute()` derives VPIP, PFR, aggression frequency, WTSD, c-bet, 3-bet, and more from `HeroHandSample` records. Classifies playing style (nit / TAG / LAG / station / maniac / balanced) and surfaces up to 5 ranked leaks.

---

## 4. Engine Test Inventory

### Direct engine tests (`test/engine/`)

| Test file | Covers | Type |
|---|---|---|
| `poker_engine_test.dart` | Chip conservation, hand resolution, blind posting, position labels, scenario deals, minRaise, short-stack all-ins | Unit (randomised soak: 40+ full hands) |
| `replay_test.dart` | `nextEvent()` step-wise replay stream, collectPot/dealStreet/handOver sequencing | Unit (randomised) |
| `deal_uniqueness_test.dart` | Consecutive deals never clone hole-card layouts | Unit |
| `live_coach_context_test.dart` | Position + aggressor grounding for Claude prompts | Unit |
| `coach_golden_test.dart` | Golden spots the coach must get right (contract tests) | Unit |
| `coach_lines_test.dart` | Coaching copy is decision-specific, varies, includes evidence & curriculum | Unit |
| `coach_advice_guard_test.dart` | Contradiction detection, fact checking, fallback rewrites | Unit |
| `coach_latency_test.dart` | Grade runs within 40ms budget | Perf |
| `deck_evaluator_test.dart` | Hand rankings, straight detection, kicker tie-breaks | Unit |
| `fast_evaluator_test.dart` | FastEvaluator agrees with DeckEvaluator on random deals | Fuzz (1000+ deals) |
| `equity_test.dart` | Equity accuracy vs known hand-vs-hand numbers | Unit |
| `bet_sizing_test.dart` | Hero raise-range math, short-stack edge cases | Unit |
| `hero_profiler_test.dart` | Metric computation, style classification, trend, leaks | Unit |
| `villain_ai_test.dart` | Free-check rule, postflop action, preflop heuristics | Unit |
| `leak_lines_test.dart` | Repeat / improvement phrasing, Gemini prompt context | Unit |
| `scenario_grader_test.dart` | EV-stamped optimal comes from LiveCoach, not Gemini | Unit |
| `scenario_manager_test.dart` | Offline template rotation, EV stamping when uid is null | Unit |

### Engine-adjacent tests (outside `test/engine/` that import engine modules)

| Test file | What it touches |
|---|---|
| `test/providers/game_provider_next_test.dart` | Game provider ↔ PokerEngine integration |
| `test/providers/coach_timing_test.dart` | Coach pacing ↔ LiveCoach integration |
| `test/services/anthropic_service_test.dart` | Claude prompt ↔ LiveCoachGrade.toPrompt |
| `test/services/profile_coach_test.dart` | Profile coach ↔ HeroProfiler |
| `test/models/mistake_pattern_test.dart` | MistakePattern derivation from coach types |
| `test/core/mistake_dao_test.dart` | Mistake persistence ↔ engine enums |
| `test/core/profile_database_test.dart` | Profile DB ↔ HeroProfiler types |

### Integration test

| Test file | Scope |
|---|---|
| `integration_test/play_hands_test.dart` | 5 full hands end-to-end on a device: deals, villain replay, hero actions (fold/call/raise), showdown, "Next hand" cycle. Budget ~30s/hand. |

---

## 5. Gaps & Risks

### Missing Test Coverage

| Gap | Severity | Notes |
|---|---|---|
| **`hand_class.dart`** — no dedicated test file | **High** | `HandClassifier.classify` and `drawOuts` are called by the villain AI, the EV model, and the range narrowing. A misclassification (e.g. calling a weak pair "top pair") silently corrupts every downstream frequency and equity. Currently exercised only indirectly through coach and villain tests. |
| **`hand_range.dart`** — no dedicated test file | **High** | `HandRange.sample`, `composition`, `reweight`, `RangeBuilder.preflop`, `RangeBuilder.narrow`, `RangeBuilder.foldEquity` are the foundation of the coaching grades. No direct assertions on range shapes, narrowing correctness, or fold-equity output. Exercised indirectly only. |
| **`preflop_chart.dart`** — no dedicated test file | **Medium** | `topPercent` and `expand` feed every range. A duplicate or missing label in the 169-hand ranking would silently shift every archetype's range. The doc comment claims "exhaustive and duplicate-free by test" but there is no visible test asserting that. |
| **`villain_model.dart`** — no dedicated test file | **Medium** | The hand-authored frequency tables are the single source of truth for how each archetype behaves. No test asserts that frequencies are internally consistent (e.g. bet + call + fold ≤ 1 at reference sizing, monotone in hand strength for each archetype). |
| **`decision_ev.dart`** — no dedicated test file | **Medium** | `DecisionModel.analyse` and `priceHeroAction` are the core of the EV stack. Tested indirectly through `coach_golden_test` and `live_coach_context_test`, but no isolated unit tests on pricing arithmetic, raise-candidate generation, or the realization discount. |
| **`coach_policy.dart`** — no dedicated test file | **Low** | Pure string-building from `VillainModel` frequencies and `LiveCoach` constants. Low risk but easy to cover. |
| **`leak_lines.dart`** — `improvementPrefix` paths | **Low** | `repeatPrefix` is well tested; `improvementPrefix` coverage is partial (only streak ≥ 2 branch visible in tests). |

### Incomplete or Fragile Modules

| Risk | Severity | Details |
|---|---|---|
| **No side-pot support** | **High** | `PokerEngine._showdown` awards the entire main pot to the best hand. In multiway all-in scenarios with unequal stacks, short-stack players should only compete for a side pot. The current logic can award a short-stack player more than they can win, or a deep-stack player less. This will produce wrong results in 3+ way all-in pots. |
| **Preflop villain AI uses card-rank heuristics, not VillainModel** | **Medium** | Postflop uses `HandClassifier` + `VillainModel` frequencies, but preflop (`VillainAi._preflopFacingBet`) uses ad-hoc rank checks (e.g. nit: pair ≥ 10 or suited ace). This means the preflop felt play does not align with the preflop range the coach builds from VPIP/PFR. Players can observe a nit calling with 87o preflop, then the coach says their range is top 12%. |
| **`_ScenarioLeadIn` only handles preflop** | **Medium** | `_ScenarioLeadIn.actionFor` returns null for non-preflop streets. Scenario deals always start from preflop regardless of the scenario's board length, so mid-street scenarios are set up via `startPracticeScenario` (which teleports), not `dealScenarioHand`. This works but means the animated lead-in path never exercises postflop scripted action. |
| **Equity engine is synchronous / UI-thread** | **Medium** | `EquitySimulator` runs on the UI thread. The latency test asserts ≤ 40ms, which holds for HU spots but could break on multiway or if iteration counts increase. Doc comments acknowledge this and defer isolate migration to when it starts failing. |
| **`scenario_manager.dart` is the only engine file with Firebase imports** | **Low** | All other engine modules are pure Dart. `ScenarioManager` couples to `cloud_functions`, `firebase_auth`, and three Firestore repos. This makes it the hardest engine file to unit test; the existing test only covers the offline-template path. |
| **Mutable static `_rotation` / `_fallbackRotation` counters** | **Low** | `CoachLines._rotation`, `LeakLines._rotation`, and `ScenarioManager._fallbackRotation` are module-level mutable statics. Tests call `resetRotation()` for determinism, but parallel test runs or hot-reload could see stale state. Low practical risk. |

### Hard-Coded Assumptions That Could Block Live Training

| Assumption | Location | Risk |
|---|---|---|
| **Seat 0 is always hero** | `poker_engine.dart` throughout, `startPracticeScenario`, many `isHero` checks | If multi-hero or observer mode is ever needed, this is baked in deep. |
| **Max 9 seats** | `_prepareScenarioLineup`: `clamp(2, 9)` | Reasonable for NLH cash but hard-coded. |
| **Big blind ≥ 1 (fallback)** | `live_coach.dart`: `bb < 1 ? 1.0 : bb` | Micro-stakes or custom blind structures with fractional BBs may misbehave. |
| **Single villain range per grade** | `LiveCoach._evaluateSpot` builds views for all live villains, but `DecisionAnalysis.villainComposition` only reads `spot.villains.first` | Multiway pot composition only reflects the first villain. |
| **±40% sizing band** | `poker_engine.dart` line 865: hard-coded 0.4 | The sizing tolerance that decides whether a raise is "correct" is a magic constant. |
| **6000 Monte Carlo iterations (HU)** | `equity.dart` `defaultIterations = 6000` | Tuned for speed; increasing for accuracy requires re-validating latency. |
| **`maxRecommendedPotMultiple = 1.5`** | `decision_ev.dart` | Caps recommended bet at 1.5× pot. Deep-stacked river overbets beyond this are never recommended even when correct. |
| **Offline fallback has 8 fixed templates** | `scenario_manager.dart` `_fallbackScenario` | When Firestore/Gemini are unavailable, only 8 scenarios rotate. Repeated sessions will recycle quickly. |
| **Showdown evaluator requires ≥ 5 cards** | `deck_evaluator.dart` line 29 | Returns a dummy `HandRank(score: 0)` for < 5 cards. If showdown is somehow reached before the river (edge case), results are wrong. |
| **`_canStillAct` ignores sitting-out** | `poker_engine.dart` | No concept of a player sitting out mid-hand — all non-folded, non-all-in players must act. |

---

## 6. Summary

The engine is a well-structured, thoroughly documented NLH training system with **19 modules** and **17 dedicated test files** (plus 7 adjacent tests and 1 integration test). The coaching pipeline — ranges → equity → EV → copy — is coherent and internally consistent. The biggest structural gap is the lack of side-pot support (blocks accurate multiway all-in training), and the biggest test gaps are missing dedicated tests for `hand_class`, `hand_range`, `preflop_chart`, `villain_model`, and `decision_ev`, all of which are load-bearing for coaching accuracy.
