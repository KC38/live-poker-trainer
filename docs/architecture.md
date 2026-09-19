# Architecture

## Layers

1. **UI** (`lib/ui`) — responsive felt table, action dock, coach shelf, Home / Stats / Settings.
2. **Providers** (`lib/providers`) — Riverpod for settings, table session, coach verdict, stats.
3. **Engine** (`lib/engine`) — `DeckEvaluator`, `PokerEngine` (full-hand streets, pots, archetype AI, auto-rebuy, replay events), `BetSizing`/`RaiseRange` (legal hero raise range), the coach stack below, `ScenarioManager` (optional cache / prefetch).
4. **Services** (`lib/services`) — `GeminiService`: coach text, scenario JSON, and image generation.
5. **Persistence** (`lib/core/database`) — Drift (`scenarios`, `played_scenarios`, `user_stats_rows`) with native SQLite and web WASM.

## Unified training

Home launches a single **Start training** path. Every hand:

1. `ScenarioManager.nextScenario()` pulls an engineered spot from the Firestore
   Gemini pool (or a diverse offline template). Prefer playable / postflop
   setups over automatic fold-preflop junk.
2. `PokerEngine.dealScenarioHand` deals that spot **from preflop** (scenario
   hole cards + featured villain). Mid-street boards in the JSON are ignored
   for the live deal so every hand starts with blinds and an empty board.
3. A preflop lead-in script folds seats before hero (and raises with the
   featured villain when `call_amount > 0`). `GameController` replays those
   steps via `PokerEngine.nextEvent()` so the user sees the action.
4. Hero acts; remaining streets use normal villain AI with the same paced
   replay. `LiveCoach` grades each hero decision.
5. **Next** fetches another scenario (stacks preserved via continue-table).

`PokerEngine.startPracticeScenario` still exists for EV stamping
(`[ScenarioGrader]`) — it jumps to the decision spot without animation.

### Replay events

`PokerEngine.nextEvent()` returns a `TableEvent` and stops at the hero:

| Kind | Meaning | Pacing |
|------|---------|--------|
| `villainAction` | one seat acted | ~520ms passive, ~680ms with chips |
| `collectPot` | street bets slide into the pot | ~420ms |
| `dealStreet` | board cards revealed | ~620ms |
| `handOver` | pot flies to winner(s) | ~720ms award animation |

`null` means the hand is over or the hero owes an action. `runToHeroOrEnd()`
drains the same stream instantly for tests and non-animated callers, so both
paths share one code path. A monotonically increasing replay token cancels an
in-flight replay when a new hand is dealt.

## Money math

Chip amounts are `double` dollars, so repeated pot splits and percent-of-pot
sizing accumulate binary dust (`450.99999999999994`). `Money` rounds every
amount to whole cents at the boundaries and provides an inverted-range-safe
`clamp`; `num.clamp` throwing `ArgumentError` on `lower > upper` is what
crashed the action dock with `Invalid argument(s): 451.0` when a short hero
could not cover a min-raise. `RaiseRange.forHero` models that case explicitly
as all-in-only instead of producing an impossible range.

## Layout bands

The table screen is a strict `Column`: header → felt (flexible) → hero rail →
coach shelf → action dock. The felt takes what is left, so a long coach line
shrinks the felt and can never draw over the hero's hole cards. `HeroRailWidget`
owns the hole cards; the coach shelf is height-capped and scrolls internally.

Inside the felt the same rule applies between elements, since archetype, stack,
committed chips, pucks, last action, and the board are all decision inputs.
`FeltTableView` resolves them in order: seats claim the ring and shrink together
until no two footprints touch, the board then takes the largest scale no seat
reaches, and committed chips ride inside the seat HUD rather than floating
toward the pot — on a phone there is no lane between a side seat and the board
wide enough for a chip pill. Chips only cross the felt during the collect beat,
fading as they go. `test/ui/poker_table_layout_test.dart` asserts this pairwise
on every street.

Live-table amounts go through `ChipDisplayMode.tableMode`, which collapses
**Both** to currency-only. Hand review, EV, stats, and table setup keep the
user's full choice via `ChipFormat`.

## Cash sim AI

Archetype decision trees inspired by the domain demo (not a line-by-line port). Universal rule: if `callAmount == 0`, never fold — free check.

## How the coach decides

Grading is expected value in chips. There is no table of hand-class thresholds;
every recommendation is the highest-EV line among the ones actually available.

| File | Job |
| --- | --- |
| `fast_evaluator.dart` | Allocation-light 7-card scoring, ~0.1µs per hand. Ordering is proven equal to `DeckEvaluator` by test, so the coach and the pot never disagree about who won. |
| `preflop_chart.dart` | The 169 starting hands ranked, and top-N% selection over them. The one hand-authored table. |
| `hand_range.dart` | Weighted combo ranges. Built from an archetype's VPIP / PFR read as a top-N% slice, adjusted for seat, then narrowed street by street. |
| `hand_class.dart` | What a holding *is* on a board — top pair, weak pair, strong draw, air — plus draw outs. |
| `villain_model.dart` | Per-archetype bet / call / raise frequencies for each hand class, with size response. The behavioural half of the opponent model. |
| `equity.dart` | Hero equity against those ranges. Exact enumeration on turn and river heads-up; seeded Monte Carlo elsewhere. |
| `decision_ev.dart` | Prices fold / check / call / raise-at-several-sizes in chips, with pot odds, fold equity, and an equity-realization discount. |
| `live_coach.dart` | Builds the spot, picks the best line, grades hero against it. |
| `coach_policy.dart` | Plain-language description of the above, derived from the same numbers, for the Leak Finder. |

Determinism is a requirement, not a nicety: the Monte Carlo seed is derived
from the spot (hole cards, board, street, pot), so grading the same decision
twice always returns the same equity and the same verdict.

A decision is marked **incorrect** only when it costs more than the model's own
margin — the larger of 0.75 BB, 4% of the pot, and the sampling error. Inside
that band the verdict is correct and the copy says the spot was close. Bet
sizing gets a wider band still, because a one-street model is far more reliable
about *which* action than about *how much*. `DecisionModel` also refuses to
propose a bet beyond 1.5× pot when stacks are deep; without that structural cap
a one-street model will talk itself into shoving twenty pots for a little fold
equity.

The model is one street deep. It prices the current decision against the range
in front of it and the cards to come, but does not solve the betting that
follows. That is why the close band and the sizing caps exist, and why
`test/engine/coach_golden_test.dart` pins the spots that must not regress.

## Coaching copy

`LiveCoach.grade` produces a `LiveCoachGrade` carrying the street, the primary
villain (last aggressor, else whoever committed the most), the hero action, the
equity and price behind the verdict, and the `CoachMismatch` between the taken
and better line. Every graded line leads with numbers the player can check —
what the call costs, what it needs, what the hand has — because an
unfalsifiable assertion about a tendency reads as bluster the moment the
verdict looks wrong. `CoachLines` composes
copy from those facts with rotating phrasings, so no two spots read the same
and an INCORRECT verdict explains itself. The same grade builds the Gemini
prompt (`toPrompt`), keeping the online line grounded in the same facts as the
offline fallback.

## Leak tracking

`MistakePattern.derive` (`models/mistake_model.dart`) reduces a graded decision
to a fine **mistake key** `street:archetype:taken->best[:small|:large]`, a
**context key** `street:archetype:best` (the spot without the hero's action), a
coarse context key `archetype:best`, and ordered `MistakeTag`s — an
archetype-specific leak first when one applies (`overbluffing_vs_stations`,
`folding_too_much_vs_maniacs`, `paying_off_nits`, `raising_into_nits`, …), then
a generic action-shape tag (`raise_when_call_best`, `sizing_too_small`, …).
Tag ids are persisted; never rename one.

Persistence lives in `AppDatabase` (schema v2): `mistakes` stores session /
hand / decision ids, street, archetype, hero action + amount, best action +
sizing, EV Δ in BB and dollars, the key, tags, and the advice shown;
`improvement_events` stores each acknowledged fix with its streak. Both carry
`hand_id` / `decision_id` so they can join the hand-history and coach-decision
logging tables. `MistakeDao` does the queries: `recordMistake` returns a
`RepeatInfo` (exact-key count, count this session, coarse-tag count, last
seen); `findImprovement` matches a CORRECT decision against keys repeated ≥ 2
times by exact context first, then archetype + best action, and computes the
streak since the last mistake on that key; `loadStats` builds `MistakeStats`
for the Leak Finder.

The hook is `GameController.heroAct`: after `LiveCoach.grade`, `MistakeTracker`
records the mistake or improvement, `LeakLines` prefixes the offline copy with
rotating repeat / improvement phrasing, and `LiveCoachGrade.toPrompt` appends a
"Leak history" clause so Gemini names the repeat count or the fix. The Gemini
line is written back onto the mistake row via `saveAdvice`. `CoachFeedback`
carries `repeatCount` / `improvementStreak` for the shelf chips, and
`mistakeStatsProvider` feeds `LeakFinderSection` on the Progress screen.

## Audio

`SoundService` plays `assets/sounds/{deal,chip,knock,fold,win}.wav`, generated
by `tool/gen_sfx.py`, plus `lounge_ambient.mp3` from `tool/gen_ambient.py` for
the Home screen. SFX and Music toggles are independent. On web (and iOS),
call `unlock()` after a user gesture (done when starting a session / Home appear).
Audio session is configured for playback. Coaching is text-only — there is no
coach TTS path, voice cache, or SFX/BGM ducking for speech.

## Diagnostics logging

Everything useful for debugging and later analysis is persisted in
`AppDatabase` (Drift, schema **v3**; tables in
`lib/core/database/logging_tables.dart`). All timestamps are UTC epoch ms;
every table carries `created_at_ms` (and `updated_at_ms` where rows mutate),
and hot lookups are indexed on `session_id`, `hand_id`, `created_at_ms`, and
`model_id`.

| Table | What it holds | Written by |
| --- | --- | --- |
| `app_sessions` | one row per launch: uuid, app version/build, platform + OS, debug flag, schema version, started / last-seen / ended | `AppSessionService` (bootstrapped from `PokerLabApp`; heartbeats on lifecycle changes) |
| `ai_requests` | every Gemini HTTP attempt: kind (`scenario`/`coach`/`image`; legacy `tts` rows may still exist), model, SHA-256 of prompt + system instruction, prompt text (full prompt as blob when truncated), request/response timestamps, latency, HTTP status, success, redacted error, prompt/response/total tokens, response text or binary size, attempt number, cache flag | `GeminiService` → `AiRequestLogger` (`DiagnosticsDao`) |
| `voice_clips` | legacy TTS cache metadata (no longer written); retained for diagnostics retention / export | historical only |
| `scenarios` (+v3 columns) | `source` (`gemini`/`offline`), `model_id`, generated / last-updated / last-served, `times_served`, `payload_version` | `ScenarioDao` via `ScenarioManager` |
| `hands` | settings snapshot JSON, seat count, blinds, stack depth, dealer/SB/BB/hero seats, lineup JSON, hero cards, board per street, final street, showdown flag, result message, winner seats, final pot, hero net ($ and bb), hero EV delta, rebuy events JSON | `HandRecorder` from `GameController` |
| `hand_actions` | ordered action sequence: seat, name, archetype, hero flag, street, action type, amount, pot before/after, stack after | `HandRecorder` (batched per street) |
| `coach_decisions` | per graded hero decision: street, hero action + amount, best action + sizing, verdict, mismatch, EV delta (bb and $), villain, advice text + source (`gemini`/`offline`), linked `ai_requests.id`, legacy voice columns (always false for new rows), graded / narrated timestamps | `HandRecorder` (`recordHeroDecision`, then `completeDecision` after narration) |
| `settings_changes` | key, old value, new value per changed setting | `SettingsNotifier.onChanged` → `DiagnosticsDao.logSettingsDiff` |
| `diagnostic_events` | level, context, message, stack trace, extra JSON, optional hand link | `DiagnosticsLog` facade (sink = `DiagnosticsDao`), `FlutterError.onError`, `PlatformDispatcher.onError` |

Design rules:

- **Off the hot path.** Recorder and log calls are fire-and-forget
  (`unawaited`), actions are inserted in one batch per street, and the Gemini
  logger / voice store resolve their DAO lazily so building the Settings →
  Sound → Gemini provider graph never opens the database.
- **Never secrets.** `GeminiService.redact` strips the API key (and any `key=`
  query value) from every error before it is logged, and is installed as the
  `DiagnosticsLog.redactor`.
- **Bounded.** `RetentionPolicy` caps each high-volume table (newest N rows
  plus a max age for AI requests / events; hands take their actions with
  them; evicted voice clips age out). `AppSessionService` runs
  `DiagnosticsDao.prune()` shortly after launch.
- **Migration.** v1 → v2 added the leak tables; v2 → v3 creates the logging
  tables and indexes (`IF NOT EXISTS`) and adds the `scenarios` columns only
  when missing (`PRAGMA table_info`), so it is idempotent and keeps rows.
  `test/core/logging_migration_test.dart` exercises both legacy versions.
- **Reading.** `DiagnosticsDao` exposes `recentSessions`, `recentAiRequests`
  (filter by kind / model / session), `tokenUsageByModel`,
  `recentSettingsChanges`, `recentEvents`, `summary()` (row counts), and
  `exportDebugLog()` (JSON-safe snapshot, blobs elided). `HandHistoryDao`
  exposes `recentHands`, `actionsFor`, `decisionsFor`; the profile engine's
  `HandHistorySource` reads the same `hands` / `hand_actions` columns.
- A Drift column getter cannot be named `text` (it shadows `Table.text`); the
  voice clip column is `spoken_text`.

## Lineup

Home supports **Random Pool** and **Custom**. Custom shows a dropdown per villain seat (Seat 2…N); Hero remains seat 1 / bottom. Duplicate archetypes get unique display names. Table setup (seats, blinds, stack, rebuy, lineup) persists in SharedPreferences and syncs to Firestore `users/{uid}.preferences` when signed in; it is re-hydrated on login. Audio stays device-local. Lineup choices feed `PokerEngine.buildLineup`.

## Breakpoints

- Compact: phone vertical table; coach shelf above dock.
- Expanded (≥900px width): table + side coach shelf for tablets / desktop web.

## Asset generation

`tool/gen_app_art.py` calls the Gemini image model for the emblem, then derives
the iOS `AppIcon.appiconset` and Android `mipmap-*` launchers from the master,
palette-quantizing so generated felt grain does not balloon the PNGs.
`tool/gen_sfx.py` synthesizes the table sounds locally (noise bursts and damped
resonant modes through biquad filters) — deterministic, royalty free, and a few
kilobytes each. `tool/gen_ambient.py` builds the Home lounge loop and prefers
an ffmpeg MP3 encode for a compact asset.

## Tooling

Tested on Flutter **3.47.2** / Dart **3.13.2**. `flutter_riverpod` remains on 2.x by design.
