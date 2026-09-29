# UI design record

Visual contract for Live Poker Trainer. A screen matches this file, or a
ticket names the section the change will update. Later work copies the
section. It does not invent a second button, type ramp, or table.

`/ui-consistency-qa` files the tickets.
`/implement-open-jira` updates this file in the same change as the widgets.
Read [flutter-ui-ux](../../.cursor/skills/flutter-ui-ux/SKILL.md) and the
[Duolingo Chess patterns](references/duolingo-chess/PATTERNS.md) before
either one.

## How a change is recorded

1. The ticket names the section below it will change, and what that section
   should say when the change ships.
2. The PR edits that section in the same commit as the widget, asset, or
   theme change. The ticket text and this file say the same thing.
3. A new pattern gets its own section before a second screen uses it.
4. Add a `Shipped` note under the section: the widget or asset path, and
   what the next screen must copy. Git history is the date. Do not put a
   calendar date in this file.
5. A layout change that can overflow at phone width names the Lesson tables sentence it will write, and the same change includes a widget test that fails on overflow.

## Theme

Source: `lib/ui/theme/app_theme.dart` (`buildPokerTheme`) and
`lib/core/constants/colors.dart` (`AppColors`).

Dark Material 3. Navy charcoal scaffold (`bgDark`), emerald felt, gold
primary, cream text. Display type is Cinzel. UI type is Manrope. Data
(chips, labels) is JetBrains Mono.

| Control | Look |
| --- | --- |
| Elevated button | Gold on `bgDark`, height 54, radius 14, Manrope 16 w800 |
| Outlined button | Gold-bright label, gold-muted border, height 50, radius 14 |
| Card | `bgElevated`, radius 16, hairline `slateDark`, no elevation |
| Input | Filled `bgElevated`, radius 12, gold-muted focus border |
| Snackbar | Floating, `bgElevated`, radius 12 |
| Page change | Cupertino on iOS, fade-forward on Android. Primary launches use `softFadeRoute` |

New controls use `Theme.of(context).colorScheme` and these metrics. Do not
hard-code a second gold or a second radius for the same role.

Onboarding primary actions use the elevated button (gold on bgDark, height 54, radius 14, Manrope 16 w800). “I already have an account” uses the outlined button (gold-bright label, gold-muted border, height 50, radius 14).

Lesson feedback Continue uses the elevated button (gold on bgDark, height 54, radius 14, Manrope 16 w800).

Home status values (streak, XP, accepted accuracy) use JetBrains Mono. The Rex card uses the card (`bgElevated`, radius 16, hairline `slateDark`, no elevation). Start uses the elevated button (gold on bgDark, height 54, radius 14, Manrope 16 w800).

The Settings Chip display segments ($, BB, Both) use JetBrains Mono.

### Shipped

Chip display segments on `SettingsScreen`
(`lib/ui/screens/settings_screen.dart`) use JetBrains Mono. The next screen
that labels a chip amount copies that data type.

Lesson feedback Continue is `_FeedbackFooter` in
`lib/ui/screens/lesson_runner_screen.dart`.

## Poker table

The full table is `PokerTableScreen` (`lib/ui/screens/poker_table_screen.dart`).
It is a column of non-overlapping bands:

1. Header
2. Felt (`FeltTableView`) — flexible. Seats, board, pot. The hero is not drawn on the felt.
3. Hero rail (`HeroRailWidget`) — hole cards
4. Coach shelf (`CoachShelfWidget`)
5. Action dock (`ActionDockWidget`) — removed, not dimmed, when the hero has no decision

Above width 900 the coach moves to a side column. Band resize uses a short
size animation (about 280ms). Chips, board, and seats stay inside the felt
band. The dock never covers the hole cards.

On Your start, Start lesson is below the coach shelf. It does not cover the hero rail. The shelf shows the flop sentence for the preview hand.

This column is the layout lessons reuse. Do not add another table widget.

### Shipped

`PokerTableScreen` is the Live Training table and the calibration warm-up
(`HomeScreen._openCalibrationWarmUp` pushes it with `softFadeRoute`).

## Lesson tables

Two older layouts still draw hands inside the lesson runner:

| Layout | File | What it is |
| --- | --- | --- |
| `LessonActionSpot` | `lib/ui/course/widgets/lesson_action_table.dart` | Mini felt plus an action dock. `isLessonActionTableActivity` turns it on per activity id. |
| `LessonTableScene` | `lib/ui/course/widgets/lesson_table_context.dart` | Authored teaching felt (hole cards, seats, button, captions). |

`FullTableHandLabActivity` still builds `PokerActionSizingActivity` and
`LessonActionSpot`. The name is not the full table above.

Contract: a lesson step that shows hole cards, a board, a pot, or an action
uses the Poker table bands (`FeltTableView`, `HeroRailWidget`,
`CoachShelfWidget`, `ActionDockWidget`). Retire the mini-table for that
step. A step with no hand (welcome, a list, settings, a number with no
cards) stays on the Theme section and does not grow a felt.

Suit taps and rank order in Suits and ranks stay on the Theme section. They do not use a felt. A felt is only for a step that shows hole cards, a board, a pot, or an action, and that step uses the Poker table bands.

Your start’s hand preview uses the Poker table bands (`FeltTableView`, `HeroRailWidget`, `CoachShelfWidget`). It does not use `LessonTableScene`.

The first lesson’s hole-card explain uses that same column. Other teaching felts stay on `LessonTableScene` until their own ticket.

A lesson step that shows hole cards, including Suits and ranks “Tap the suited hole cards,” places those cards on HeroRailWidget inside the Poker table bands. Retire `_HoleCardFeltTray` for that step.

A phase column on a teaching felt stacks its playing cards vertically. A horizontal row of `MiniCard` or `CardBack` widgets is not used inside an `Expanded` phase column. Scaling the row down with `FittedBox` is not a substitute for that rule.

### Shipped

Button and blinds (LPT-36) stacks the flop cards and the showdown card backs vertically in `_buildBlindsTiming` (`lib/ui/course/widgets/lesson_table_context.dart`). The next phase column copies that vertical stack.

File one ticket per layout you still see, not one ticket per activity id.

## Asset inventory

Slots are the only place a new animation, icon, sound, logo, or mascot is
introduced. Reuse the path already listed. Add a row when a new file ships.

| Slot | Current | Reuse |
| --- | --- | --- |
| Logo | `assets/brand/logo_mark.png` | Auth screen and Live Training hub |
| Mascot | `assets/brand/rex_calm.png` — a face, calm mood, via `RexMascot` | Meet Rex, `RexCoachLine`, and `RexCoachCard` |
| Mascot celebrate | `assets/brand/rex_celebrate.png` — Rex’s own face, celebrating mood, the same coach as the calm portrait, via `RexMascot` | Right-answer beat in `LessonFeedbackSheet` |
| Icons | Material / Cupertino. No branded icon set | Theme icon color (`slate` in the app bar) |
| Motion | Implicit widget motion only (band resize, `AnimatedSwitcher` 220ms in the runner). No Rive or Lottie | [flutter-ui-ux](../../.cursor/skills/flutter-ui-ux/SKILL.md) durations |
| Sound effects | `SoundService`: `deal.wav`, `chip.wav`, `knock.wav`, `fold.wav`, `win.wav` under `assets/sounds/` | Table actions call these. Do not add a second chip sound |
| Background music | `assets/sounds/lounge_ambient.mp3` via `SoundService.startHomeBgm` | Home. Pause when leaving Home. Settings toggle is `musicEnabled` |

The mascot slot is a Rex image with a face and a mood. Meet Rex and the Rex line on Your start show that face. Text-only `RexCoachLine` is not the slot.

A missing slot (Rex still text-only, a deal with no motion, a table action
with no `SoundService` call) is a ticket that names the slot. The walk does
not generate the file. The implementer adds it and fills the row.

The Live Training hub shows `assets/brand/logo_mark.png` above the lock or the table entry.

### Shipped

The Live Training hub shows `assets/brand/logo_mark.png` in `_LiveAccessGate` and the open table entry of `LiveTrainingScreen` (`lib/ui/screens/live_training_screen.dart`). Auth uses the same file in `lib/ui/screens/auth_screen.dart`.

## Gamified learning

Lessons teach like a game. The loop is
[Duolingo Chess](references/duolingo-chess/PATTERNS.md): one step, the
board as the hero, a mascot beat when the answer lands, then a payoff.
Frames are in `docs/ui/references/duolingo-chess/frames/`. Use the pattern.
Do not copy their palette, owl, or words.

| Beat | What the screen does |
| --- | --- |
| Step | One prompt, the poker table or the choice, one primary button. Progress and lives stay in a thin header. |
| Right | Rex celebrates on the same screen. A short line says why. One continue. |
| Wrong | Rex shows the miss. The better action is visible. Lives move. Retry or continue is one tap. |
| Hint | A sheet over the step, not a new route. |
| Payoff | Lesson XP and the daily goal before Home. |
| Home | A path. The next lesson is the marked node. Rex stands on it. |

On Home, Rex stands on the marked next-lesson node. A Rex card above the path is not that beat.
| Section end | One ceremony: character, title, one button. |

A right answer shows Rex’s own face in a celebrating mood beside the short line. The calm portrait and the celebrating portrait are the same coach. The Asset inventory celebrate row uses that same face.

The locked Live Training hub names the Home lesson that unlocks it. It does not say Section 2.

Rex on a teaching step has a face and a mood. A text-only coach line on a
right or wrong answer is a gap in the mascot slot and in this section.
File one ticket per missing beat.

### Shipped

A right answer shows Rex’s own face in a celebrating mood beside the short line. `LessonFeedbackSheet` (`lib/ui/course/widgets/lesson_feedback_sheet.dart`) uses `RexMascot` with `RexMood.celebrate` (`assets/brand/rex_celebrate.png`). That portrait is the same coach as `assets/brand/rex_calm.png`.

The locked Live Training hub names Baseline jump check in `liveTrainingLockedMessage` (`lib/models/live_access.dart`). That title is the Home node for `lesson-02-07-02-section-two-jump`.
