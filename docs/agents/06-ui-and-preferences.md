# 06 — UI and preferences

Authoritative contract: [ui/design-record.md](../ui/design-record.md).
This page is the agent shortlist so you do not invent a second language.

## Reference device

**iPhone 13 mini** (375 × 812 pt). Layouts that only work on large phones
are not done. Claim the mini with `tools/sim_lock.py` before driving it.

## Visual language

- Dark navy charcoal atmosphere, emerald felt, gold primary, cream text.
- Fonts: Cinzel / Manrope / JetBrains Mono (via theme — not Inter/Roboto).
- Theme metrics over one-off radii. Nothing clips on the mini.
- Playing cards: one face — `TableCard` (corner rank, centered suit).
  `MiniCard` / `CardBack` are size presets over that face, not a second art.

## Interaction preferences (owner)

| Preference | Do | Don't |
| --- | --- | --- |
| Teach by doing | Answer on the felt (tap cards, seats, chips, actions) | Default to text Q&A lists |
| One table | `FeltTableView` everywhere a hand is shown | Mini felts, suit tiles, rank slots |
| Live deal feel | One card at a time, clockwise from button, deal SFX | Instant full board dumps |
| Coach | Rex face + mood; bubble is the only instruction | Letter "R", duplicate title under progress |
| Cues | Gold SoftPulse after cards land, first press; cyan for learner picks | Bouncing `CueArrows`; multi SoftPulse on the coach answer under Nice!/Oops |
| Hint vs grade | Clear Hint (and Hint SoftPulse) when Nice! / Oops lands | Hint copy stuck under the answer dock |
| Undo local picks | Mirror multi-tap felt picks into `ActivityDraft` (`orderedIds` / choice) so Undo clears them | Widget-only `_selected` that leaves Undo disabled after a soft reject |
| Home | Path + START/REVIEW bubble | Resume card, Rex+Start box, START chip on node |
| Economy | Hearts / streak / XP celebrated | Silent XP math with no UI beat |
| Stats | Course and Live separate on Profile | Merged "accuracy" |

## Lesson layout preference

See `.cursor/rules/lesson-screen-layout.mdc`. When editing lesson UI, that
rule applies automatically via globs.

## Sounds

- Deal / action SFX through `SoundService`.
- Home BGM when music enabled; unlock audio on shell.
- Respect Settings toggles; do not hardcode muted-off in new screens.

## Motion

Purposeful micro-motion (deal, SoftPulse, pot award, Rex celebrate). Do not
add decorative glow stacks or multi-layer shadow noise that fights the felt.

## When UI changes ship

1. Match or update the design-record section in the **same** change.
2. Prefer widget tests that fail on overflow at mini width.
3. Update lesson ledger rows when a step moves onto the felt.
4. UI design agent learnings: `.cursor/commands/ui-design-agent-learnings.md`.
