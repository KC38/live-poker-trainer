# Architecture

## Layers

1. **UI** (`lib/ui`) — responsive felt table, action dock, coach shelf, Home / Stats / Settings.
2. **Providers** (`lib/providers`) — Riverpod for settings, table session, coach verdict, stats, unplayed count.
3. **Engine** (`lib/engine`) — `DeckEvaluator`, `PokerEngine` (streets, pots, archetype AI, auto-rebuy), `ScenarioManager`.
4. **Services** (`lib/services`) — `GeminiService` (`gemini-3.8-flash` generateContent for JSON scenarios + coach text/AUDIO).
5. **Persistence** (`lib/core/database`) — Drift (`scenarios`, `played_scenarios`, `user_stats_rows`) with native SQLite and web WASM.

## Practice grading

After Hero acts in Practice:

1. Map action to `ExploitAction` and compare to `optimal_exploit_action` (raise sizing within ±40% of `optimal_sizing_bb`).
2. Persist played row + stats.
3. Show **CORRECT** / **INCORRECT** on `CoachShelfWidget`, then Gemini punchy line (or offline exploit reasoning).
4. Open `EvAuditModal` with EV Δ in BB.

## Cash sim AI

Archetype decision trees inspired by the domain demo (not a line-by-line port). Universal rule: if `callAmount == 0`, never fold — free check.

## Audio

`SoundService` plays `assets/sounds/{card,chip,knock,fold}.wav`. SFX and TTS toggles are independent. On web, call `unlock()` after a user gesture (done when starting a session).

Gemini coach AUDIO is typically raw 16-bit PCM / L16 (often `audio/pcm;rate=24000` or `audio/L16;codec=pcm;rate=24000`). `WavCodec.ensurePlayable` detects existing WAV/MP3, otherwise wraps PCM in a RIFF/WAVE header so `audioplayers` can play reliably on iOS, Android, and web.

## Lineup

Home supports **Random Pool** and **Custom**. Custom shows a dropdown per villain seat (Seat 2…N); Hero remains seat 1 / bottom. Choices persist via SharedPreferences and feed `PokerEngine.buildLineup`.

## Breakpoints

- Compact: phone vertical table; coach shelf above dock.
- Expanded (≥900px width): table + side coach shelf for tablets / desktop web.

## Tooling

Tested on Flutter **3.47.2** / Dart **3.13.2**. `flutter_riverpod` remains on 2.x by design.
