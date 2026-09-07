# Exploitative Poker Lab

Multi-platform Flutter trainer for exploitative No-Limit Hold'em (**iOS**, **Android**, **iPadOS/tablets**, **web**) with Gemini coaching, Drift local cache, and a luxury felt table UI.

## Quick start

```bash
git checkout feat/flutter-poker-lab
cp .env.example .env
# Set GEMINI_API_KEY in .env (optional — offline fallback spots work without it)

flutter pub get
flutter run                 # default device
flutter run -d chrome       # web
flutter run -d ios          # simulator
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
- Model: **`gemini-3.8-flash`**.

## Defaults

| Setting | Default |
|---------|---------|
| Blinds | $1 / $2 |
| Seats | 9 (2–9) |
| Stack depth | 200 BB |
| Auto-rebuy | On, top-up when &lt; 50 BB to configured stack |
| SFX / Coach TTS | On |

## Modes

- **Practice:** Gemini (or cached / offline) tough spots; after you act, coach shows **CORRECT** or **INCORRECT**, then a punchy line + EV audit.
- **Cash Sim:** archetype villains (Maniac / Nit / Calling Station / TAG / LAG) with free-check rule (never fold when check is free).

## Architecture

```
lib/
├── main.dart
├── core/          # config, colors, constants, audio, Drift DB
├── models/
├── engine/        # DeckEvaluator, PokerEngine, ScenarioManager
├── services/      # GeminiService
├── providers/     # Riverpod
└── ui/screens/ + ui/widgets/
```

See [docs/architecture.md](docs/architecture.md).

## Development

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs   # after Drift schema changes
```

Prefetch: when unplayed scenarios &lt; 5, `ScenarioManager` requests more from Gemini in the background.
