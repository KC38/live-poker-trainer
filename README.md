# Exploitative Poker Lab

Multi-platform Flutter trainer for exploitative No-Limit Hold'em (**iOS**, **Android**, **iPadOS/tablets**, **web**) with Gemini coaching, Drift local cache, and a luxury felt table UI.

## Quick start

Requires **Flutter 3.47+** / **Dart 3.13+** (tested on Flutter 3.47.2 · Dart 3.13.2).

```bash
git checkout feat/flutter-poker-lab
cp .env.example .env        # required: `.env` is a declared asset
# Set GEMINI_API_KEY in .env — the build ships this key; players never enter one

flutter pub get
flutter run                 # default device
flutter run -d chrome       # web
# Prefer an iPhone simulator whose runtime matches your Xcode SDK
# (Xcode 26.6 → install iOS 26.5 Simulator via: xcodebuild -downloadPlatform iOS)
flutter run -d <iphone-simulator-id>
flutter run -d android
```

With a compile-time key instead (CI):

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key
```

## Platforms

| Target | Notes |
|--------|--------|
| iOS / iPadOS | Phone + tablet breakpoints; larger seats / wider coach shelf on expanded |
| Android | Phone + tablet |
| Web | Requires `web/sqlite3.wasm` + `web/drift_worker.js` (committed). Unlock SFX after a user gesture |

## Secrets

The key is **developer configuration**, baked into the build. There is no
Settings override, and no screen ever asks the player for a key or mentions one.

- **Never commit `.env`** or real API keys (gitignored).
- Commit only `.env.example` (empty `GEMINI_API_KEY=` placeholder).
- Key order: `--dart-define=GEMINI_API_KEY` → `.env` → `.env.example`.
- `.env` and `.env.example` are both declared under `flutter: assets:` in
  `pubspec.yaml`. `flutter_dotenv` reads env files through the **asset bundle**,
  so an undeclared `.env` is invisible to `flutter run` and release builds — that
  is what silently demoted the coach to the flat device voice. Because `.env` is
  a declared asset it must exist locally: run `cp .env.example .env` after
  cloning, or the build fails with a missing-asset error.
- `main()` loads `.env.example` as the base with `.env` as an override file, both
  optional, so a missing or empty file degrades to "no key" instead of throwing.
- Startup logs only the key *source* (`dart-define` / `env-asset` / `missing`),
  never the key.

Without a key the app still runs: heuristic coach lines plus the device voice,
degraded silently. Voice fallbacks are logged, never surfaced in the UI.
- Models (single source: `lib/core/constants/config.dart`):
  - coach text — **`gemini-3.8-flash`** (`Config.geminiModel`)
  - coach voice — **`gemini-3.1-flash-tts-preview`**, voice `Puck` (`Config.geminiTtsModel`)
  - art generation — **`gemini-3-pro-image`** (`Config.geminiImageModel`)

The general text model silently ignores an `AUDIO` modality request, which is
why speech uses the dedicated TTS model.

## Defaults

| Setting | Default |
|---------|---------|
| Blinds | $1 / $2 |
| Seats | 9 (2–9) |
| Stack depth | 200 BB |
| Auto-rebuy | On, top-up when &lt; 50 BB to configured stack |
| Lineup | Random pool, or **Custom** with per-seat archetype pickers |
| Chip display | Both ($ and BB) — the live table always shows currency only |
| SFX / Coach TTS | On |

## Play flow

Home has one primary CTA — **Start training** — plus a collapsed **Table setup** section (seats, blinds, stack, rebuy, lineup).

Training always deals a **full cash-style hand** from preflop (blinds → streets → fold or showdown). Each **Next** hand gets a fresh shuffle — consecutive deals are checked so they cannot clone the previous hole-card layout, and mid-hand actions continue the same deal rather than resetting it. Archetype villains (Maniac / Nit / Calling Station / TAG / LAG) play with the free-check rule (never fold when check is free). D / SB / BB pucks mark the button and blinds.

The action **replays one seat at a time** instead of arriving resolved: each villain decision, the chips sliding into the pot, and every board card lands as its own step with table-realistic pacing, and the hero simply waits its turn. Seats show the archetype as a word plus VPIP/PFR, and the header's people icon opens a legend of every player type at the table with its exploit.

The coach grades each hero decision when a clear exploit line exists (**CORRECT** / **INCORRECT**) and explains it in terms of the street, the villain type, and what the better line was.

Screen layout is a strict stack of bands — header, felt, hero rail, coach shelf, action dock — so the coach can never cover the hero's hole cards, down to a 320pt phone at 9 seats.

Settings → **Chip display** chooses Dollars only, BB only, or Both (default) for hand review, EV, and stats. The live felt is always currency-only so the table stays readable.

Coach voice: Gemini TTS audio (voice `Puck`) via the dedicated `Config.geminiTtsModel`, cached on disk so a repeated line replays instantly and never re-hits the API; device TTS (`flutter_tts`) is the last-resort fallback. Fallbacks are **silent** — the shelf shows the coaching line only, and the reason goes to the debug log (`[coach-voice] …`). Mute via Settings or the coach shelf speaker icon.

Settings → **Music** (default On) plays a quiet lounge ambient loop on Home, independent of table SFX. It fades in on appear, fades out when entering Training, and resumes on return. Coach speech ducks both SFX and BGM.

Table SFX **duck to 18%** of their level while the coach is speaking and ramp back afterwards, on both the Gemini and device-voice paths (`SfxDucker`). Each line takes a hold that only it can release, so a line interrupted mid-sentence by the next one cannot un-duck audio that is still playing, and a stop, error, or missing completion callback (30s watchdog) always restores volume. Muted SFX skip ducking entirely; muted coach voice never triggers it.

## Architecture

```
lib/
├── main.dart
├── core/          # config, colors, chip format, audio (WAV + TTS), Drift DB
├── models/
├── engine/        # DeckEvaluator, PokerEngine, LiveCoach, ScenarioManager
├── services/      # GeminiService
├── providers/     # Riverpod 2.x
└── ui/screens/ + ui/widgets/
```

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
