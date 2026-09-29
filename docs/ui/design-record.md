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

Lesson result CONTINUE uses the elevated button (radius 14).

Home status values (streak, XP, accepted accuracy) use JetBrains Mono. The Rex card uses the card (`bgElevated`, radius 16, hairline `slateDark`, no elevation). Start uses the elevated button (gold on bgDark, height 54, radius 14, Manrope 16 w800).

The Settings Chip display segments ($, BB, Both) use JetBrains Mono.

### Shipped

Chip display segments on `SettingsScreen`
(`lib/ui/screens/settings_screen.dart`) use JetBrains Mono. The next screen
that labels a chip amount copies that data type.

Lesson feedback Continue is `_FeedbackFooter` in
`lib/ui/screens/lesson_runner_screen.dart`.

Lesson result CONTINUE uses the elevated button (radius 14). `LessonResultScreen` (`lib/ui/screens/lesson_result_screen.dart`) uses `ElevatedButton`, so the Theme elevated button supplies radius 14.

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

This column is the live-training table. A lesson step uses the lesson
screen layout instead: the hero sits on the felt, and the speech bubble
replaces the coach shelf. Do not add a third table widget.

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
| Mascot | `assets/brand/mascot_idle.png` — full body, calm mood, via `RexMascot` | Meet Rex, `RexCoachLine`, and `RexCoachCard` |
| Mascot celebrate | `assets/brand/mascot_celebrate.png` — the same coach, celebrating mood, the same coach as the calm drawing, via `RexMascot` | Right-answer beat in `LessonFeedbackSheet` and the lesson-result ceremony |
| Icons | Material / Cupertino. No branded icon set | Theme icon color (`slate` in the app bar) |
| Motion | Implicit widget motion only (band resize, `AnimatedSwitcher` 220ms in the runner). No Rive or Lottie | [flutter-ui-ux](../../.cursor/skills/flutter-ui-ux/SKILL.md) durations |
| Sound effects | `SoundService`: `deal.wav`, `chip.wav`, `knock.wav`, `fold.wav`, `win.wav` under `assets/sounds/` | Table actions call these. Do not add a second chip sound |
| Background music | `assets/sounds/lounge_ambient.mp3` via `SoundService.startHomeBgm` | Home. Pause when leaving Home. Settings toggle is `musicEnabled` |

The mascot slot is the full-body coach with a mood. Meet Rex and the Rex line on Your start show that drawing. Text-only `RexCoachLine` is not the slot.

The lesson result uses `RexMascot` for the ceremony. It does not draw a letter R.

A missing slot (Rex still text-only, a deal with no motion, a table action
with no `SoundService` call) is a ticket that names the slot. The walk does
not generate the file. The implementer adds it and fills the row.

The Live Training hub shows `assets/brand/logo_mark.png` above the lock or the table entry.

### Shipped

The Live Training hub shows `assets/brand/logo_mark.png` in `_LiveAccessGate` and the open table entry of `LiveTrainingScreen` (`lib/ui/screens/live_training_screen.dart`). Auth uses the same file in `lib/ui/screens/auth_screen.dart`.

The lesson result uses `RexMascot` for the ceremony. It does not draw a letter R. `LessonResultScreen` (`lib/ui/screens/lesson_result_screen.dart`) draws `RexMascot` with `RexMood.celebrate` (`assets/brand/mascot_celebrate.png`).

## Lesson screen layout

Every lesson step uses the same six regions, in this order, on a phone.
The regions do not move, swap, or collapse between steps. A step may
leave a region quiet (fewer seats, no arrows, hint disabled). It does
not invent a second header, a second prompt, or a second table.

Your two cards (`lesson-01-01-01-your-two-cards`) is the first lesson on
this frame. Later lessons copy `LessonScreenLayout` in
`lib/ui/course/widgets/lesson_screen_layout.dart`. They do not build
their own chrome.

```
┌──────────────────────────────────────┐
│ 1  X     progress bar          ♥ ♥ ♥ │
│ 2  [mascot]   speech bubble          │
│ 3                                    │
│    stage (table, or the step itself) │
│                                      │
│ 4  undo    redo    hint              │
└──────────────────────────────────────┘
        ↓ replaced, after an answer, by
┌──────────────────────────────────────┐
│ 5  Nice!  /  Oops, that's not correct│
│    Continue                          │
└──────────────────────────────────────┘
```

There is no lesson-title row. Duolingo's "Solve the puzzle" line is not
copied, and the lesson title does not sit under the progress bar.

### 1. Chrome

One row, height 36.

| Slot | What it is |
| --- | --- |
| Close | `X` on the left. Leaves the lesson. It is not a back chevron and it is not beside a title. |
| Progress | The lesson bar fills the space between close and the hearts. It advances by activity, not by a second bar. |
| Hearts | One heart per life, filled while that life remains. A miss that costs a life empties one heart. Do not replace the row with a single heart and a number. |

### 2. Coach band

The mascot and one speech bubble share a row directly under the chrome.
The mascot box is 104 by 118, about the area Oscar takes on a phone
lesson. The bubble is a rounded rectangle with a tail aimed at the
coach's mouth. A plain rectangle is not the bubble. The bubble's top
and that tail stay in the same place on every step. More text grows
the bubble downward. Less text does not move the tail or the first line.

The bubble holds the only instruction for the step. The same sentence
is not repeated on the table, under the table, or in a second coach
line. Your two cards' first step says: "These two are your cards alone.
Nobody else sees them. Tap your cards to peek."

The mascot is a placeholder until Rex art for these expressions ships.
`LessonMascotExpression` picks the face:

| Moment | Expression |
| --- | --- |
| Prompt, before an answer | Thinking |
| Accepted answer | Happy |
| Miss | Wrong (the disappointed face) |

The answer dock does not draw a second face.

### 3. Stage

The stage is the large middle slot. It is the only region that changes
from step to step. Chrome, the coach band, the tools, and the answer
dock stay put whether or not this step draws a table.

When the step shows hole cards, a board, a pot, seats, or an action,
the stage is the full poker table: `LessonTableStage` on
`FeltTableView`. It draws the oval and every seat this step includes.
Fewer players, a shorter board, or no action dock is how a step focuses.
A mini felt, a loose row of cards, or a second table widget is not the
stage.

On that table the hero sits on the felt with the other seats. The
live-training rail (`HeroRailWidget` under the felt) stays the live
table. A lesson table does not add that rail, a street heading, or a
coach shelf. The pot pill names the street. The bubble says the
instruction.

Your two cards' first step shows four seats (you and three other
players), no board, your two cards face down, and arrows on your cards.
Tapping your cards turns them face up. Tapping another seat's cards is
a miss: a buzz, the wrong face, and the answer dock. Those cards stay
face down.

A step with no hand (suits, a rank order, a number, a list) still uses
this frame. Its own widget fills the stage slot. It does not grow a
felt, and it does not replace the frame with the old app-bar runner.

### 4. Tools

Undo, redo, and hint sit in one fixed row under the stage while the
step is unanswered. They are not in the chrome. Undo reverts the local
answer. Redo restores the answer undo just cleared. Hint shows that
step's hint in the speech bubble until it is tapped again. A step with
no hint leaves the button visible and disabled.

### 5. Answer dock

A graded answer replaces the tool row. It does not push a new route.

| Answer | Title | Button |
| --- | --- | --- |
| Accepted | Nice! | Continue, `AppColors.success` |
| Miss | Oops, that's not correct | Continue, `AppColors.danger` |

One short line under the title says why. Continue is the only button.
On a miss, Continue clears the dock and stays on the same step. On an
accepted answer, Continue advances. The gold elevated button stays the
primary button everywhere except this dock.

### Shipped

`LessonScreenLayout` (`lib/ui/course/widgets/lesson_screen_layout.dart`)
is the frame. `LessonTableStage` (`lib/ui/course/widgets/lesson_table_stage.dart`)
is the stage when the step is a hand. Your two cards uses both. Suits
and ranks uses the same frame; its stage is the suits-and-ranks widget,
not a felt. Button and blinds uses the same frame; its stage is the
full table, with the dealer button, small blind, and big blind on the
seats. Hand ranks uses the same frame: the ladder stays the rank
widget, and a made hand or a showdown uses the full table. Best five
and kickers uses the same frame: the five-card picker stays in the
stage, and a kicker battle or a board-plays pot uses the full table.
Fold, check, call uses the same frame: the three buttons stay the
explain stage, and each action spot uses the full table. Bet, raise,
all-in uses that same frame: Bet, Raise, and All-in stay the explain
stage, and each action spot uses the full table. Streets and action
order uses the same frame: the street timeline stays in the stage, and
postflop order uses the full table. How pots are won uses the same
frame: the three paths stay in the stage, and a fold-win or a called
river uses the full table. Play a full toy hand uses the same frame:
the three beats stay in the stage, and each street of the hand uses
the full table. Section 1 jump check uses the same frame: rank and
seat order stay lists, and the action spot and the toy hand use the
full table. Position labels uses the same frame: the six-max seats
are labeled on the full table. Acting order uses the same frame:
preflop order is EP, then HJ, then BTN on that table. Hand families
uses the same frame: the family list stays in the stage, and a
starting hand sits face up on the full table. Open or fold baseline
uses the same frame: early, button, and live size stay in the stage,
and each open sits face up on the full table. Versus an open uses
the same frame: fold, call, and 3-bet stay in the stage, and each
response sits face up on the full table. Effective stacks uses the
same frame: chips to big blinds, the shorter stack, and depth stay
in the stage. Live table habits uses the same frame: watch, say,
cover, and wait stay in the stage. Full-ring baseline hand uses the
same frame: nine seats, the same rules, and position stay in the
stage, and each decision sits face up on the full table. Baseline
jump check uses the same frame: the seat map and the starting hand
sit on the full table, the open and the 3-bet use that table, and
the stack check stays a list. Read the table first uses the same
frame: pot, stacks, button, and who acts stay in the stage, and the
first-to-act seat is tapped on the full table. Name your flop class
uses the same frame: made, draw, showdown value, and air stay in the
stage, and each flop sits face up on the full table. Count outs,
pay the right price uses the same frame: clean, dirty, and price
stay in the stage, the clean aces stay a card picker, and a priced
draw sits face up on the full table. Choose a flop line uses the
same frame: value, c-bet, check, call, fold, and raise stay in the
stage, and each flop decision sits face up on the full table. Plan
the turn card uses the same frame: brick, change, barrel, and delay
stay in the stage, and each turn sits face up on the full table.
Close the river correctly uses the same frame: value, bluff, catch,
and fold stay in the stage, and each river sits face up on the full
table. Play tighter multiway uses the same frame: stronger, fewer,
and nuts stay in the stage, and each multiway spot sits face up on
the full table. Patch the common leaks uses the same frame: top
pair, prices, passive, and crowds stay in the stage, and each leak
spot sits face up on the full table. Section 3 jump check uses the
same frame: the table-read stays a list, the flop class and the
bad-price draw sit face up on the full table, and the multiway fold
and the value bet use that table. Think in ranges uses the same
frame: one hand, range, and update stay in the stage, and the
bet-twice and same-board spots sit face up on the full table.
Navigate 3-bet pots uses the same frame: 3-bet, ranges, and squeeze
stay in the stage, and each 3-bet spot sits face up on the full
table. Plan beyond the flop uses the same frame: flop, turn, and
river stay in the stage, and each street of the plan sits face up
on the full table. Size with a message uses the same frame: value,
pressure, and size stay in the stage, and each sizing spot sits face
up on the full table. SPR decides commitment uses the same frame:
SPR, low, and high stay in the stage, and each commitment spot sits
face up on the full table. Observe sticky callers uses the same
frame: enters, calls, and folds stay in the stage, the participation
note and the observation bundle stay lists, and the sticky-call and
low-confidence spots sit face up on the full table. Meet the Calling
Station uses the same frame: station, high, and low stay in the stage,
and the label quizzes stay lists. Adjust versus Calling Station uses
the same frame: value, bluffs, and cite stay in the stage, each
adjustment spot sits face up on the full table, and the bluff-less
reason stays a list. Observe narrow players uses the same frame:
rare, enter, and mean it stay in the stage, and the entry quizzes stay
lists. Meet the Nit uses the same frame: nit, narrow, and respect stay
in the stage, and the label quizzes stay lists. Adjust versus Nit
uses the same frame: steal, credit, and explode stay in the stage,
each nit spot sits face up on the full table, and the respect reason
stays a list. Observe wild aggressors uses the same frame: raise,
barrel, and count stay in the stage, and the entry quizzes stay lists.
Meet the Maniac uses the same frame: maniac, entry, and aggro stay in
the stage, and the label quizzes stay lists. Adjust versus Maniac
uses the same frame: wider, hang, and ego stay in the stage, each
maniac spot sits face up on the full table, and the call-wider reason
stays a list. Confidence and samples uses the same frame: observe,
samples, and showdowns stay in the stage, and the confidence quizzes
stay lists. Same hand, different types uses the same frame: cards,
seats, and evidence stay in the stage, and each type spot sits face up
on the full table. Section 4 jump check uses the same frame: the
range, SPR, and player-type checks stay lists, and the 3-bet and the
sizing spot sit face up on the full table. Build multiway ranges
with nut potential uses the same frame: nutted, air, and domination
stay in the stage, the continue and priority checks stay lists, and
the connector and the set spots sit face up on the full table. Play
150–300bb stacks with a plan uses the same frame: deep, realize, and
stack stay in the stage, the implied, plan, and reward checks stay
lists, and the wet-flop fold sits face up on the full table. Implied
and reverse odds uses the same frame: implied, reverse, and second stay
in the stage, each price spot sits face up on the full table, and the
rise check stays a list. Thin value and bluff-catches uses the same
frame: thin, catch, and barrels stay in the stage, each thin-value spot
sits face up on the full table, and the read check stays a list.
Advanced flop lines uses the same frame: check-raise, probe, delay, and
donk stay in the stage, the nit, donk, and delay checks stay lists, and
the probe spot sits face up on the full table. Street-by-street
updates uses the same frame: action, rewrite, and update stay in the
stage, the capped, habit, and shove checks stay lists, and the turn
bomb sits face up on the full table. Soft timing evidence uses the
same frame: timing, sizing, and clues stay in the stage, and the timing
quizzes stay lists. Live table dynamics uses the same frame: stuck,
tilted, and gears stay in the stage, the stuck, gear, and freshness
checks stay lists, and the steaming spot sits face up on the full
table. Keep cash session guardrails uses the same frame: quit, guard,
and first stay in the stage, and the discipline quizzes stay lists.
The procedure for the
next lesson is
[lesson-screen-layout](../../.cursor/skills/lesson-screen-layout/SKILL.md).

## Gamified learning

Lessons teach like a game. The loop is
[Duolingo Chess](references/duolingo-chess/PATTERNS.md): one step, the
board as the hero, a mascot beat when the answer lands, then a payoff.
Frames are in `docs/ui/references/duolingo-chess/frames/`. Use the pattern.
Do not copy their palette, owl, or words.

| Beat | What the screen does |
| --- | --- |
| Step | The lesson screen layout: close, progress, hearts, one speech bubble, the stage, then undo / redo / hint. No title row. The stage is the full table only when the step is a hand. |
| Right | The coach face turns happy. The dock says Nice! and one Continue. |
| Wrong | The coach face turns wrong. The dock says Oops. Continue stays on the step. |
| Hint | Hint replaces the speech bubble until it is tapped again. |
| Payoff | Lesson XP and the daily goal before Home. |
| Home | A path. The next lesson is the marked node. Rex stands on it. |

On Home, Rex stands on the marked next-lesson node. A Rex card above the path is not that beat.
| Section end | One ceremony: character, title, one button. |

The lesson result shows this lesson’s XP and the daily goal before Home.

A right answer shows the same coach in a celebrating mood beside the short line. The calm drawing and the celebrating drawing are the same coach. The Asset inventory celebrate row uses that same coach.

The locked Live Training hub names the Home lesson that unlocks it. It does not say Section 2.

Rex on a teaching step has a face and a mood. A text-only coach line on a
right or wrong answer is a gap in the mascot slot and in this section.
File one ticket per missing beat.

### Shipped

A right answer shows the same coach in a celebrating mood beside the short line. `LessonFeedbackSheet` (`lib/ui/course/widgets/lesson_feedback_sheet.dart`) uses `RexMascot` with `RexMood.celebrate` (`assets/brand/mascot_celebrate.png`). That drawing is the same coach as `assets/brand/mascot_idle.png`.

The locked Live Training hub names Baseline jump check in `liveTrainingLockedMessage` (`lib/models/live_access.dart`). That title is the Home node for `lesson-02-07-02-section-two-jump`.

The lesson result shows this lesson’s XP and the daily goal before Home. `LessonResultScreen` (`lib/ui/screens/lesson_result_screen.dart`) lists XP earned and a Daily goal row of the onboarding minutes.
