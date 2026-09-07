# Architecture

## Layers

1. **UI** (`lib/ui`) — responsive felt table, action dock, coach shelf, Home / Stats / Settings.
2. **Providers** (`lib/providers`) — Riverpod for settings, table session, coach verdict, stats.
3. **Engine** (`lib/engine`) — `DeckEvaluator`, `PokerEngine` (full-hand streets, pots, archetype AI, auto-rebuy, replay events), `BetSizing`/`RaiseRange` (legal hero raise range), `LiveCoach` + `CoachLines` (exploit grading and copy), `ScenarioManager` (optional cache / prefetch).
4. **Services** (`lib/services`) — `GeminiService`: coach text, TTS speech, and image generation, each on its own model.
5. **Persistence** (`lib/core/database`) — Drift (`scenarios`, `played_scenarios`, `user_stats_rows`) with native SQLite and web WASM.

## Unified training

Home launches a single **Start training** path. Every hand:

1. Deal from preflop with blinds posted, without resolving villain action (`startHand(resolve: false)`); D / SB / BB pucks on seats.
2. `GameController` pulls `PokerEngine.nextEvent()` on a timer and applies one step per tick, so villain decisions, pot collection, and board cards animate in order.
3. On each Hero action, `LiveCoach` grades when a clear exploit line exists; Gemini (or `CoachLines`) supplies a spot-specific line; `SoundService` plays cached Gemini speech or device TTS.
4. Continue streets until fold-out or showdown; deal a **fresh shuffled hand** on **Next** (hole-card layouts are fingerprinted so consecutive deals cannot clone the prior hand). Mid-hand hero actions never re-deal — the same hole cards continue until the hand ends.

### Replay events

`PokerEngine.nextEvent()` returns a `TableEvent` and stops at the hero:

| Kind | Meaning | Pacing |
|------|---------|--------|
| `villainAction` | one seat acted | ~520ms passive, ~680ms with chips |
| `collectPot` | street bets slide into the pot | ~420ms |
| `dealStreet` | board cards revealed | ~620ms |
| `handOver` | hand resolved | ~560ms before review |

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

Live-table amounts go through `ChipDisplayMode.tableMode`, which collapses
**Both** to currency-only. Hand review, EV, stats, and table setup keep the
user's full choice via `ChipFormat`.

## Cash sim AI

Archetype decision trees inspired by the domain demo (not a line-by-line port). Universal rule: if `callAmount == 0`, never fold — free check.

## Coaching copy

`LiveCoach.grade` produces a `LiveCoachGrade` carrying the street, the primary
villain (last aggressor, else whoever committed the most), the hero action, and
the `CoachMismatch` between the taken and better line. `CoachLines` composes
copy from those facts with rotating phrasings, so no two spots read the same
and an INCORRECT verdict explains itself. The same grade builds the Gemini
prompt (`toPrompt`), keeping the online line grounded in the same facts as the
offline fallback.

## Audio

`SoundService` plays `assets/sounds/{deal,chip,knock,fold,win}.wav`, generated
by `tool/gen_sfx.py`. SFX and TTS toggles are independent. On web (and iOS),
call `unlock()` after a user gesture (done when starting a session). Audio
session is configured for playback.

Coach voice priority: cached clip → fresh Gemini TTS → `flutter_tts`. Gemini
speech is raw 16-bit PCM / L16 (often `audio/pcm;rate=24000`), which
`WavCodec.ensurePlayable` wraps as WAV. `VoiceCache` stores clips under the app
support directory keyed by a SHA-256 of text + voice + model, bounded by bytes
and a TTL with LRU eviction, so repeated lines are instant and free. When no
key, network, or cached clip is available, `flutter_tts` speaks the text and a
one-shot note may surface on the coach shelf.

## Lineup

Home supports **Random Pool** and **Custom**. Custom shows a dropdown per villain seat (Seat 2…N); Hero remains seat 1 / bottom. Duplicate archetypes get unique display names. Choices persist via SharedPreferences and feed `PokerEngine.buildLineup`.

## Breakpoints

- Compact: phone vertical table; coach shelf above dock.
- Expanded (≥900px width): table + side coach shelf for tablets / desktop web.

## Asset generation

`tool/gen_app_art.py` calls the Gemini image model for the emblem, then derives
the iOS `AppIcon.appiconset` and Android `mipmap-*` launchers from the master,
palette-quantizing so generated felt grain does not balloon the PNGs.
`tool/gen_sfx.py` synthesizes the table sounds locally (noise bursts and damped
resonant modes through biquad filters) — deterministic, royalty free, and a few
kilobytes each.

## Tooling

Tested on Flutter **3.47.2** / Dart **3.13.2**. `flutter_riverpod` remains on 2.x by design.
