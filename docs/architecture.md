# Architecture

## Layers

1. **UI** (`lib/ui`) — responsive felt table, action dock, coach shelf, Home / Stats / Settings.
2. **Providers** (`lib/providers`) — Riverpod for settings, table session, coach verdict, stats.
3. **Engine** (`lib/engine`) — `DeckEvaluator`, `PokerEngine` (full-hand streets, pots, archetype AI, auto-rebuy), `LiveCoach` (heuristic exploit grading), `ScenarioManager` (optional cache / prefetch).
4. **Services** (`lib/services`) — `GeminiService` (`gemini-3.8-flash` generateContent for coach text/AUDIO).
5. **Persistence** (`lib/core/database`) — Drift (`scenarios`, `played_scenarios`, `user_stats_rows`) with native SQLite and web WASM.

## Unified training

Home launches a single **Start training** path. Every hand:

1. Deal from preflop with blinds posted; D / SB / BB pucks on seats.
2. Run archetype villains until Hero acts or the hand ends.
3. On each Hero action, `LiveCoach` grades when a clear exploit line exists; Gemini (or offline copy) supplies a punchy line; `SoundService` plays Gemini AUDIO or device TTS.
4. Continue streets until fold-out or showdown; deal a fresh hand on **Next**.

Chip amounts respect Settings → **Chip display** (`$`, BB, or both) via `ChipFormat`.

## Cash sim AI

Archetype decision trees inspired by the domain demo (not a line-by-line port). Universal rule: if `callAmount == 0`, never fold — free check.

## Audio

`SoundService` plays `assets/sounds/{card,chip,knock,fold}.wav`. SFX and TTS toggles are independent. On web (and iOS), call `unlock()` after a user gesture (done when starting a session). Audio session is configured for playback.

Gemini coach AUDIO is typically raw 16-bit PCM / L16 (often `audio/pcm;rate=24000`). `WavCodec.ensurePlayable` wraps it as WAV. If AUDIO is missing or the key is absent, `flutter_tts` speaks the coaching text and a one-shot note may surface on the coach shelf.

## Lineup

Home supports **Random Pool** and **Custom**. Custom shows a dropdown per villain seat (Seat 2…N); Hero remains seat 1 / bottom. Duplicate archetypes get unique display names. Choices persist via SharedPreferences and feed `PokerEngine.buildLineup`.

## Breakpoints

- Compact: phone vertical table; coach shelf above dock.
- Expanded (≥900px width): table + side coach shelf for tablets / desktop web.

## Tooling

Tested on Flutter **3.47.2** / Dart **3.13.2**. `flutter_riverpod` remains on 2.x by design.
