# Architecture

## Layers

1. **UI** (`lib/ui`) — responsive felt table, action dock, coach shelf, screens.
2. **Providers** (`lib/providers`) — Riverpod state for settings, game, coach verdict, stats, prefetch.
3. **Engine** (`lib/engine`) — hand evaluation, street/pot logic, archetype AI, scenario cache orchestration.
4. **Services** (`lib/services`) — Gemini scenario generation + coach text/AUDIO.
5. **Persistence** (`lib/core/database`) — Drift DAOs for scenarios, played rows, user stats.

## Gameplay modes

- **Practice:** inject cached/Gemini scenarios; grade hero action vs `optimal_exploit_action` / sizing.
- **Cash Sim:** full ring simulation with archetype decision trees; coaching without forced grade unless added later.

## Coach verdict

In Practice, after Hero acts (and on EV audit), compare to the scenario optimal line and show an unmistakable CORRECT or INCORRECT badge plus a punchy coaching line.

## Audio

`SoundService` plays bundled WAVs (card/chip/knock/fold). SFX and TTS toggles are independent. Web playback may require a prior user gesture.
