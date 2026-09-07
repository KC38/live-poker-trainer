# Exploitative Poker Lab

Multi-platform Flutter trainer for exploitative No-Limit Hold'em (**iOS**, **Android**, **iPadOS/tablets**, **web**) with Gemini coaching, Drift local cache, and a luxury felt table UI.

## Quick start

Requires **Flutter 3.47+** / **Dart 3.13+** (tested on Flutter 3.47.2 · Dart 3.13.2).

```bash
git checkout feat/flutter-poker-lab
cp .env.example .env
# Set GEMINI_API_KEY in .env (optional — offline fallback spots work without it)

flutter pub get
flutter run                 # default device
flutter run -d chrome       # web
# Prefer an iPhone simulator whose runtime matches your Xcode SDK
# (Xcode 26.6 → install iOS 26.5 Simulator via: xcodebuild -downloadPlatform iOS)
flutter run -d <iphone-simulator-id>
flutter run -d android
```

With compile-time key (CI / no `.env` asset):

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

- **Never commit `.env`** or real API keys (gitignored).
- Commit only `.env.example`.
- Key order: Settings device override → `--dart-define=GEMINI_API_KEY` → dotenv `.env` / `.env.example`.
- Model: **`gemini-3.8-flash`** (single source: `Config.geminiModel`).

## Defaults

| Setting | Default |
|---------|---------|
| Blinds | $1 / $2 |
| Seats | 9 (2–9) |
| Stack depth | 200 BB |
| Auto-rebuy | On, top-up when &lt; 50 BB to configured stack |
| Lineup | Random pool, or **Custom** with per-seat archetype pickers |
| SFX / Coach TTS | On |

## Modes & UX flow

Home is teach-first: one primary **Start practice** CTA, secondary **Cash game**, and advanced options in a collapsed **Table setup** section (seats, blinds, stack, rebuy, lineup).

- **Practice:** Gemini (or cached / offline) tough spots; after you act, the coach shelf shows **CORRECT** or **INCORRECT** (never over hole/board cards), then a punchy line + EV audit.
- **Cash game:** archetype villains (Maniac / Nit / Calling Station / TAG / LAG) with free-check rule (never fold when check is free). Custom lineup assigns each villain seat under Table setup.

## Architecture

```
lib/
├── main.dart
├── core/          # config, colors, constants, audio (WAV codec), Drift DB
├── models/
├── engine/        # DeckEvaluator, PokerEngine, ScenarioManager
├── services/      # GeminiService
├── providers/     # Riverpod 2.x
└── ui/screens/ + ui/widgets/
```

See [docs/architecture.md](docs/architecture.md).

Coach TTS: Gemini AUDIO is usually raw PCM/L16 @ 24 kHz; `WavCodec` wraps it as WAV before `audioplayers` playback.

## Development

```bash
flutter analyze
flutter test
dart run build_runner build   # after Drift schema changes
```

Prefetch: when unplayed scenarios &lt; 5, `ScenarioManager` requests more from Gemini in the background.

**Dependency note:** `flutter_riverpod` stays on **2.x** (3.x is a breaking Notifier migration). Other direct deps track latest compatible versions.
