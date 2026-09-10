# Exploitative Poker Lab

Multi-platform Flutter trainer for exploitative No-Limit Hold'em (**iOS**, **Android**, **iPadOS/tablets**, **web**) with **Claude** live coaching, Gemini scenarios, Drift local cache, and a luxury felt table UI.

## Quick start

Requires **Flutter 3.47+** / **Dart 3.13+** (tested on Flutter 3.47.2 · Dart 3.13.2).

```bash
git checkout feat/flutter-poker-lab
cp .env.example .env        # required: `.env` is a declared asset
# Set ANTHROPIC_API_KEY in .env for live coach text (required for AI coaching)
# Optionally set GEMINI_API_KEY for scenario generation / art

flutter pub get
flutter run                 # default device
flutter run -d chrome       # web
# Prefer an iPhone simulator whose runtime matches your Xcode SDK
# (Xcode 26.6 → install iOS 26.5 Simulator via: xcodebuild -downloadPlatform iOS)
flutter run -d <iphone-simulator-id>
flutter run -d android
```

With compile-time keys instead (CI):

```bash
flutter run \
  --dart-define=ANTHROPIC_API_KEY=your_anthropic_key \
  --dart-define=GEMINI_API_KEY=your_gemini_key
```

## Platforms

| Target | Notes |
|--------|--------|
| iOS / iPadOS | Phone + tablet breakpoints; larger seats / wider coach shelf on expanded |
| Android | Phone + tablet |
| Web | Requires `web/sqlite3.wasm` + `web/drift_worker.js` (committed). Unlock SFX after a user gesture |

## Secrets

Keys are **developer configuration**, baked into the build. There is no
Settings override, and no screen ever asks the player for a key or mentions one.

- **Never commit `.env`** or real API keys (gitignored).
- Commit only `.env.example` (empty `ANTHROPIC_API_KEY=` / `GEMINI_API_KEY=` placeholders).
- Key order: `--dart-define=…` → `.env` → `.env.example`.
- `.env` and `.env.example` are both declared under `flutter: assets:` in
  `pubspec.yaml`. `flutter_dotenv` reads env files through the **asset bundle**,
  so an undeclared `.env` is invisible to `flutter run` and release builds —
  coach text then falls back to offline lines. Because `.env` is
  a declared asset it must exist locally: run `cp .env.example .env` after
  cloning, or the build fails with a missing-asset error.
- `main()` loads `.env.example` as the base with `.env` as an override file, both
  optional, so a missing or empty file degrades to "no key" instead of throwing.
- Startup logs only the key *source* (`dart-define` / `env-asset` / `missing`),
  never the key.

Without `ANTHROPIC_API_KEY` the app still runs with heuristic (offline) coach text.
- Models (single source: `lib/core/constants/config.dart`):
  - **live coach text** — **`claude-sonnet-5`** (`Config.claudeCoachModel`) via Anthropic Messages API
  - scenario generation — **`gemini-3.8-flash`** (`Config.geminiModel`) — not used for coaching
  - art generation — **`gemini-3-pro-image`** (`Config.geminiImageModel`)

Coaching is **text-only** on the shelf (no TTS / spoken coach lines). Gemini is never used for coach advice.

## Defaults

| Setting | Default |
|---------|---------|
| Blinds | $1 / $2 |
| Seats | 9 (2–9) |
| Stack depth | 200 BB |
| Auto-rebuy | On, top-up when &lt; 50 BB to configured stack |
| Lineup | Random pool, or **Custom** with per-seat archetype pickers |
| Chip display | Both ($ and BB) — the live table always shows currency only |
| SFX / Music | On |

## Play flow

Home has one primary CTA — **Start training** — plus a collapsed **Table setup** section (seats, blinds, stack, rebuy, lineup).

Training always deals a **full cash-style hand** from preflop (blinds → streets → fold or showdown). Each **Next** hand gets a fresh shuffle — consecutive deals are checked so they cannot clone the previous hole-card layout, and mid-hand actions continue the same deal rather than resetting it. Archetype villains (Maniac / Nit / Calling Station / TAG / LAG) play with the free-check rule (never fold when check is free). D / SB / BB pucks mark the button and blinds.

The action **replays one seat at a time** instead of arriving resolved: each villain decision, the chips sliding into the pot, and every board card lands as its own step with table-realistic pacing, and the hero simply waits its turn. Seats show the archetype as a word plus VPIP/PFR along with the stack and whatever the villain has committed on the street, and the header's people icon opens a legend of every player type at the table with its exploit. All of it stays simultaneously legible: the felt shrinks its seat ring and its board until nothing on the table covers anything else.

**Coaching is expected value, in chips.** For every hero decision the coach builds each live villain's range from their archetype's VPIP/PFR and the action they have actually shown, measures hero's equity against those ranges, prices folding, checking, calling and raising at several sizes, and recommends whichever is worth the most. So the same hand is a call heads-up and a fold three-handed, a call at 30% of the pot and a fold at 80% — the price and the board decide, not a minimum hand to call with.

Equity is enumerated exactly on the turn and river heads-up and sampled with a spot-derived seed elsewhere, so grading the same decision twice always gives the same answer. Each line quotes the numbers behind it ("Calling $21.50 into $39 needs 36%; 3♦2♥ has a weak pair and 57% against Sammy's range here"), and the reported EV is the real cost of the decision against the best line available — a good decision costs nothing.

A decision is only marked **INCORRECT** when it costs more than the model's own margin of error; inside that band the verdict is CORRECT and the coach says the spot was close. A value bet at a slightly-off size is graded as the right decision with a sizing note, not as a mistake. `test/engine/coach_golden_test.dart` pins the spots this must never get wrong.

**Leak tracking.** Every INCORRECT decision is persisted (Drift `mistakes` table) under a stable mistake key — `street:archetype:heroAction->bestAction`, e.g. `river:nit:raise->call`, with `:small` / `:large` appended for sizing misses — plus coarse leak tags (bluffing into stations, folding too much vs maniacs, paying off nits, …). When the same key or leak recurs the coach says so by count ("That's the third time you've raised against a nit on the river…") in both the Gemini line and the offline copy, and the shelf shows a **Repeat ×N** chip. When you later get a previously-repeated spot right, the coach acknowledges the fix ("Nice — last time you raised here; calling was the right adjustment"), an `improvement` event is recorded, and the shelf shows **Improved** (with the streak).

**Progress.** The avatar button on Home opens one **Progress** screen: identity (name/avatar), style metrics, AI coach review, Leak Finder, coaching accuracy / EV charts, and street / archetype breakdowns. There is no separate Stats icon.

Metrics come from `HeroProfiler`, a pure engine over recorded hands (`lib/engine/hero_profiler.dart`): VPIP, PFR, 3-bet, fold-to-3bet, postflop aggression frequency and factor, WTSD, c-bet, fold-to-c-bet and won-at-showdown, plus a bet/call/fold mix per street and per villain archetype with net BB against each, and a ranked leak list.

Every rate is a `MetricSample` that carries its own numerator, denominator and **minimum sample**, and nothing is shown before it earns it — a thin stat renders `—` with a "needs N more" hint instead of a number, and tapping any tile explains in plain English what it measures and what a healthy range looks like. Style is derived from VPIP and the PFR/VPIP ratio (Nit → Tight-Passive → TAG → LAG → Maniac → Loose-Passive, thresholds in `StyleThresholds`) and is **withheld entirely below 20 hands**, where the header reads "Style forming" and says what is still missing. Confidence is banded by sample: low (20) → medium (60) → high (150+).

The review is Gemini JSON (summary / leaks / adjustments, markdown scrubbed), cached in Drift and only regenerated when it stops describing you — 25+ new hands, a changed style label, a summary older than 14 days, or an upgrade from offline copy — so opening the screen does not spend an API call. With no key or no network the same shape is derived locally from your own numbers, labelled "Offline read from your stats". The trend chart plots rolling VPIP, falling back to coached EV Δ until there are enough hands. **Leak Finder** is inline on Progress (top repeated mistakes, trends, archetype / street bars).

**Identity.** The Progress header edits your display name and picture. Pick a photo from the library (`image_picker`) or one of eight built-in avatars; photos are centre-cropped and downscaled to a 256px square PNG under `<app documents>/avatars/` with only the path stored, and replacing one deletes the file it replaced. Deletion is restricted to that directory, so a stale database path can never remove anything else. A missing file (cleared app data, restored backup) degrades to initials rather than a broken image, and a denied photo permission points at Settings and the built-in avatars. Your name and avatar then show at the hero seat; the default name renders as `YOU`.

Screen layout is a strict stack of bands — header, felt, hero rail, coach shelf, action dock — so the coach can never cover the hero's hole cards, down to a 320pt phone at 9 seats. When the hero cannot act (folded, hand over, table replaying), the action dock is removed entirely rather than greyed out.

Graded coach lines always show a **CORRECT** / **INCORRECT** badge (plus Best / You / EV when expanded). Ambiguous spots stay on the offline line — Claude is not asked to invent a verdict. Every shown line is post-validated against `bestAction` so advice cannot urge calling when the grade says fold (or the reverse). When the street advances, the prior grade is shelved as **Correct · preflop** / **Incorrect · turn** so it never looks like live advice for the current tip. Coaching is text-only on the shelf — there is no spoken coach voice.

Settings → **Chip display** chooses Dollars only, BB only, or Both (default) for hand review, EV, and stats. The live felt is always currency-only so the table stays readable.

Settings → **Music** (default On) plays a quiet lounge ambient loop on Home, independent of table SFX. It fades in on appear, fades out when entering Training, and resumes on return.

## Architecture

```
lib/
├── main.dart
├── core/          # config, colors, chip format, audio (SFX + BGM), Drift DB
├── models/
├── engine/        # DeckEvaluator, PokerEngine, ScenarioManager, HeroProfiler,
│                 # coach: FastEvaluator, PreflopChart, HandRange, HandClass,
│                 # VillainModel, EquitySimulator, DecisionModel, LiveCoach
├── services/      # AnthropicService (coach), GeminiService (scenarios), AvatarStore, ProfileCoach
├── providers/     # Riverpod 2.x
└── ui/screens/ + ui/widgets/
```

Local storage is two Drift databases. `AppDatabase` (schema v3) holds gameplay:
scenarios, user stats, the `mistakes` / `improvement_events` leak history, and
the diagnostics log — `app_sessions`, `ai_requests`, `voice_clips`, `hands`,
`hand_actions`, `coach_decisions`, `settings_changes`, `diagnostic_events` (see
[Diagnostics logging](docs/architecture.md#diagnostics-logging)).
`ProfileDatabase` holds the player profile — identity, the metric snapshot, and
the cached coach review — deliberately kept separate so the profile schema does
not have to migrate in lockstep with gameplay. It reads the shared hand log
through `HandHistorySource`, which probes `sqlite_master` first and returns an
empty history when the log is not there, so the profile screen degrades to
"needs more hands" instead of failing.

See [docs/architecture.md](docs/architecture.md).

## Assets

Brand art and table sounds are generated by re-runnable scripts in `tool/`
(Python 3 + Pillow for the art):

```bash
python3 tool/gen_app_art.py          # Gemini emblem + iOS/Android icon sets
python3 tool/gen_app_art.py --icons  # re-derive platform icons from the master
python3 tool/gen_sfx.py              # synthesize assets/sounds/*.wav
python3 tool/gen_ambient.py          # lounge loop → assets/sounds/lounge_ambient.mp3
```

`gen_app_art.py` needs `GEMINI_API_KEY` (environment or `.env`) and writes
`assets/brand/`, the iOS `AppIcon.appiconset`, and the Android `mipmap-*`
launchers. Output is palette-quantized to keep each bundled PNG near 100 KB.
`gen_sfx.py` needs no key or network: table sounds are modal impacts, so they
are synthesized deterministically into sub-40 KB WAVs. `gen_ambient.py`
builds an 8s seamless pad and encodes MP3 via ffmpeg when available (~28 KB).

## Firebase (Auth, Firestore, Functions)

Project id: **`live-poker-trainer`**. FlutterFire config is already wired
(`lib/firebase_options.dart`, platform plist / `google-services.json`).

Shared scenario pool lives in Firestore (`scenarios/{contentHash}`); clients
read via `lib/services/firestore/`. Generation is the callable Cloud Function
`ensureScenarioPool` (Gemini key stays server-side).

### Blaze requirement

**Cloud Functions (and Functions secrets) need the Blaze (pay-as-you-go) plan.**
Firestore/Auth/rules can run on the free Spark plan. If deploy fails with a billing
error, upgrade the project in the Firebase console first, then re-run the
commands below.

### Deploy commands

```bash
# From repo root (requires `firebase login` + project `live-poker-trainer`)
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes

# After Blaze is enabled:
firebase functions:secrets:set GEMINI_API_KEY   # paste the Gemini API key
cd functions && npm ci && npm run build && cd ..
firebase deploy --only functions:ensureScenarioPool
# (predeploy runs `npm --prefix "$RESOURCE_DIR" run build` automatically)
```

Local Functions emulator (optional): set `GEMINI_API_KEY` in the shell, then
`cd functions && npm run serve`.

## Development

```bash
flutter analyze
flutter test
dart run build_runner build   # after Drift schema changes

# Play several full hands on a real device / simulator (~30s per hand).
# The harness may report a leaked audioplayers frame callback at teardown;
# the per-hand assertions inside the run are the real signal.
flutter test integration_test/play_hands_test.dart -d <device-id>
```

**Dependency note:** `flutter_riverpod` stays on **2.x** (3.x is a breaking Notifier migration). Other direct deps track latest compatible versions.
