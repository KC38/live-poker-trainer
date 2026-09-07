# Exploitative Poker Lab

Multi-platform Flutter trainer for exploitative No-Limit Hold'em (iOS, Android, iPadOS/tablets, web) with Gemini coaching, Drift local cache, and a luxury felt table UI.

## Platforms

| Target | Command |
|--------|---------|
| iOS Simulator | `flutter run -d ios` |
| Android | `flutter run -d android` |
| Chrome (web) | `flutter run -d chrome` |
| macOS (if enabled) | `flutter run -d macos` |

Phone and tablet layouts use compact / medium / expanded breakpoints. The elliptical felt table scales seats 2–9.

## Setup

```bash
cp .env.example .env
# Edit .env and set GEMINI_API_KEY=your_key

flutter pub get
flutter run
```

### Secrets

- **Never commit `.env`** or real API keys.
- Commit only `.env.example` (empty placeholder).
- Key resolution order: Settings device override → `--dart-define=GEMINI_API_KEY=...` → `.env` / `.env.example`.

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key
```

Model: **`gemini-3.8-flash`**.

## Defaults

| Setting | Default |
|---------|---------|
| Blinds | $1 / $2 |
| Seats | 9 (range 2–9) |
| Stack depth | 200 BB |
| Auto-rebuy | On, top-up when &lt; 50 BB |
| SFX / Coach TTS | On |

## Architecture

```
lib/
├── main.dart
├── core/          # config, colors, constants, audio, Drift DB
├── models/        # cards, players, game state, scenarios, settings, stats
├── engine/        # DeckEvaluator, PokerEngine, ScenarioManager
├── services/      # GeminiService
├── providers/     # Riverpod wiring
└── ui/screens/ + ui/widgets/
```

- **Practice mode:** Gemini tough spots + clear CORRECT / INCORRECT coach verdict.
- **Cash Sim:** archetype villains (Maniac, Nit, Calling Station, TAG, LAG) with free-check rule.
- **Storage:** Drift (SQLite native + web-capable) for scenarios / played history / stats; SharedPreferences for lightweight prefs.

## Docs

See [docs/architecture.md](docs/architecture.md) for module notes.

## Development

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs   # after Drift schema changes
```
