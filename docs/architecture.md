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

## Breakpoints

- Compact: phone vertical table; coach shelf above dock.
- Expanded (≥900px width): table + side coach shelf for tablets / desktop web.
