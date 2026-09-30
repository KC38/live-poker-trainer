# UI design record

Visual contract for Live Poker Trainer. A screen matches this file, or a
ticket names the section the change will update. Later work copies the
section. It does not invent a second button, type ramp, or table.

Tickets name the design-record section they will change.
`/implement-open-jira` updates this file in the same change as the widgets.
Read [flutter-ui-ux](../../.cursor/skills/flutter-ui-ux/SKILL.md) and the
[Duolingo Chess patterns](references/duolingo-chess/PATTERNS.md) before
editing.

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

One table, `FeltTableView` (`lib/ui/widgets/felt_table_view.dart`), is drawn
by Live Training, Your start, and every lesson step that shows a hand. There
is no second table widget.

The table is built for a phone held upright:

- **Hero.** You sit at the bottom center, on the felt, with the largest hole
  cards on the table (wider than a board card). Nothing covers them.
- **Seats.** The other players take fixed slots for the player count
  (`TableLayout.templates`, 2–9), clockwise from you. Seats straddle the rail
  so the felt spends its area on the board. Side seats sit above or below
  the board row, not beside it.
- **Seat box.** One box per seat: a generic player icon, the name, and the
  stack in large JetBrains Mono. Face-down cards tuck behind the top of the
  box. The icon ring is colored by player type when player types are on,
  and a type tag sits on the box's top edge.
- **Around a seat.** Dealer, SB, and BB pucks sit beside the box, facing the
  felt. A street bet sits on the line from the seat toward the pot, clear of
  every seat. The action badge hangs from the bottom of the box.
- **Center.** The pot pill (`FLOP · POT $10`) above the board, five large
  board cards, and `Blinds $1/$2 NLH` under them (`CommunityCardsView`). The
  board takes the largest scale that no seat, puck, or bet reaches.

The Live Training screen is a column of non-overlapping bands:

1. Header
2. Felt (`FeltTableView`) — flexible, with you at the bottom
3. Coach shelf (`CoachShelfWidget`)
4. Action dock (`ActionDockWidget`) — removed, not dimmed, when the hero has no decision

YOUR TURN, ACTION…, and FOLDED show as a chip under your seat box. Above
width 900 the coach moves to a side column. Band resize uses a short size
animation (about 280ms). The coach and the dock never cover your cards.
Once a hand is over your cards grow a little.

On Your start, Start lesson is below the coach shelf. The shelf shows the flop sentence for the preview hand.

A lesson step uses the lesson screen layout instead of the coach shelf: the
speech bubble is the instruction. Do not add a third table widget.

`HeroRailWidget` no longer draws the hero on any table. It only draws the
hand choices on the hole-card picker.

### Table features

`TableFeatures` (`lib/ui/widgets/table_features.dart`) turns the optional
layers on or off: stacks, pot, street name, blinds line, position pucks,
street bets, action badges, opponents' face-down cards, player types,
VPIP/PFR, and empty board slots. Seats, the board, and your cards always draw.

The lesson runner puts each lesson under `TableFeaturesScope` with
`TableFeatures.forLessonId`. Each layer switches on at the lesson that
teaches it and stays on for the rest of the course. Cards, seats, opponents'
face-down cards, and the board slots are on from the first lesson.

| Layer | On from | Constant |
| --- | --- | --- |
| Pucks, blinds line, posted chips, pot | 1.1.3 Button and blinds | `blindsLesson` |
| Action badges | 1.3.1 Fold, check, call | `actionsLesson` |
| Stack amounts | 1.3.2 Bet, raise, all-in | `stacksLesson` |
| Street name in the pot pill | 1.4.1 Streets and action order | `streetLesson` |
| Player types, VPIP/PFR | 4.6.1 Observe sticky callers | `playerTypesLesson` |

Your two cards and Suits and ranks show only seats, cards, and the board.
Live Training and an id that is not `lesson-SS-UU-LL` get
`TableFeatures.full`. Your start uses the preset of the lesson it recommends.

A step can pass its own `features` to `LessonTableStage` to hide more. A
lesson seat shows a player type only when the step names it
(`villainArchetypes`); a seat never shows a made-up type. An action spot
reads the type from its table label, then its prompt
(`lessonNamedVillainType`): Calling Station, station, or sticky caller is
the Calling Station; Nit, Maniac, TAG, and LAG are themselves. A spot that
says "unknown" stays a plain seat, because having no read is its point.

### Stakes

Lesson tables play `Blinds $1/$2 NLH` with 100 big blind stacks
(`lessonSmallBlind`, `lessonBigBlind`). Preflop, the small and big blind are
posted as bets in front of their seats, and the pot counts them. A step that
teaches another level passes `smallBlind` and `bigBlind` to
`LessonTableStage`; the blinds line and every amount follow.

### Shipped

`PokerTableScreen` is the Live Training table and the calibration warm-up
(`HomeScreen._openCalibrationWarmUp` pushes it with `softFadeRoute`).
`LessonTableStage` draws the same `FeltTableView` for lessons, and
`PokerTableBands` draws it for Your start.

## Lesson tables

Two older layouts still draw hands inside the lesson runner:

| Layout | File | What it is |
| --- | --- | --- |
| `LessonActionSpot` | `lib/ui/course/widgets/lesson_action_table.dart` | Mini felt plus an action dock. `isLessonActionTableActivity` turns it on per activity id. |
| `LessonTableScene` | `lib/ui/course/widgets/lesson_table_context.dart` | Authored teaching felt (hole cards, seats, button, captions). |

`FullTableHandLabActivity` still builds `PokerActionSizingActivity` and
`LessonActionSpot`. The name is not the full table above.

Contract: every lesson step uses the Poker table (`FeltTableView`, with
`CoachShelfWidget` and `ActionDockWidget` where the step has them). Retire
mini felts, suit tiles, and rank slots. When no table object fits the
answer, put choices in the action space under the felt.

Suits and ranks uses the full poker table for every step: suit taps hit
community cards (one of each suit), rank order taps board ranks low to high,
and suited / pair picks tap the seat whose holes match.

Best five and kickers uses the full poker table for every step: explain
and build-five taps hit hero holes and board cards; kicker and board-plays
steps tap You / Them / Board on that table.

Fold, check, call uses the full poker table for every step: explain taps
Fold, Check, and Call under a flop on the felt, and each action spot uses
that table with the dock under it.

Bet, raise, all-in uses the full poker table for every step: explain taps
Bet, Raise, and All-in under a flop on the felt, and each action spot uses
that table with the dock under it.

Streets and action order uses the full poker table for every step: explain
and street order advance the board with street labels under the felt, and
postflop order taps seats on that table.

How pots are won uses the full poker table for every step: explain taps
Fold win, Showdown, and Side pot under the felt, and each decision spot
uses that table.

Play a full toy hand uses the full poker table for every step: explain
taps Blinds, You act, and Ending under the felt, and each street uses
that table.

Hand families uses the full poker table for every step: explain taps
Pairs, Broadways, Suited aces, and Connectors under the felt while
holes update, and each classify spot uses that table.

Open or fold uses the full poker table for every step: explain taps
Early, Button, and Live 3x under the felt, and each open spot uses that
table.

Versus an open uses the full poker table for every step: explain taps
Fold, Call, and 3-bet under the felt, and each response spot uses that
table.

Effective stacks uses the full poker table for every step: explain taps
Chips→BB, Shorter, and Depth under the felt, and each spot uses that
table.

Live table habits uses the full poker table for every step: explain taps
Watch, Say, Cover, and Wait under the felt.

Full-ring baseline uses the full poker table for every step: explain taps
Nine, Same, and Position under the felt on a nine-max ring.

Read the table first uses the full poker table for every step: explain taps
Pot, Stacks, Button, and Who Acts under the felt.

Name your flop class uses the full poker table for every step: explain taps
Made, Draw, SDV, and Air under the felt.

Count outs, pay the right price uses the full poker table for every step:
explain taps Clean, Dirty, and Price under the felt.

Choose a flop line uses the full poker table for every step: explain taps
Value, C-bet, Check, Call, Fold, and Raise under the felt.

Plan the turn card uses the full poker table for every step: explain taps
Brick, Change, Barrel, and Delay under the felt.

Close the river correctly uses the full poker table for every step: explain
taps Value, Bluff, Catch, and Fold under the felt.

Play tighter multiway uses the full poker table for every step: explain taps
Stronger, Fewer, and Nuts under the felt.

Patch the common leaks uses the full poker table for every step: explain taps
Top pair, Prices, Passive, and Crowds under the felt.

Think in ranges uses the full poker table for every step: explain taps
One hand, Range, and Update under the felt.

Navigate 3-bet pots uses the full poker table for every step: explain taps
3-bet, Ranges, and Squeeze under the felt.

Plan beyond the flop uses the full poker table for every step: explain taps
Flop, Turn, and River under the felt.

Size with a message uses the full poker table for every step: explain taps
Value, Pressure, and Size under the felt.

SPR decides commitment uses the full poker table for every step: explain taps
SPR, Low, and High under the felt.

Observe sticky callers uses the full poker table for every step: explain taps
Enters, Calls, and Folds under the felt.

Meet the Calling Station uses the full poker table for every step: explain taps
Station, High, and Low under the felt.

Adjust versus Calling Station uses the full poker table for every step: explain
taps Value, Bluffs, and Cite under the felt.

Observe narrow players uses the full poker table for every step: explain taps
Rare, Enter, and Mean It under the felt.

Meet the Nit uses the full poker table for every step: explain taps Nit,
Narrow, and Respect under the felt.

Adjust versus Nit uses the full poker table for every step: explain taps Steal,
Credit, and Explode under the felt.

Observe wild aggressors uses the full poker table for every step: explain taps
Raise, Barrel, and Count under the felt.

Meet the Maniac uses the full poker table for every step: explain taps Maniac,
Entry, and Aggro under the felt.

Adjust versus Maniac uses the full poker table for every step: explain taps
Wider, Hang, and Ego under the felt.

Confidence and samples uses the full poker table for every step: explain taps
Observe, Samples, and Showdowns under the felt.

Same hand, different types uses the full poker table for every step: explain
taps Cards, Seats, and Evidence under the felt.

Build multiway ranges with nut potential uses the full poker table for every
step: explain taps Nutted, Air, and Domination under the felt.

Play 150–300bb stacks with a plan uses the full poker table for every step:
explain taps Deep, Realize, and Stack under the felt.

Implied and reverse odds uses the full poker table for every step: explain
taps Implied, Reverse, and Second under the felt.

Thin value and bluff-catches uses the full poker table for every step: explain
taps Thin, Catch, and Barrels under the felt.

Advanced flop lines uses the full poker table for every step: explain taps
X/R, Probe, Delay, and Donk under the felt.

Street-by-street updates uses the full poker table for every step: explain
taps Action, Rewrite, and Update under the felt.

Soft timing evidence uses the full poker table for every step: explain taps
Timing, Sizing, and Clues under the felt.

Live table dynamics uses the full poker table for every step: explain taps
Stuck, Tilted, and Gears under the felt.

Keep cash session guardrails uses the full poker table for every step: explain
taps Quit, Guard, and First under the felt.

Spot range advantage and nut advantage uses the full poker table for every
step: explain taps Range, Nut, and Advantage under the felt.

Realize equity in and out of position uses the full poker table for every
step: explain taps Equity, Cash, and Pos under the felt.

Recognize capped versus uncapped ranges uses the full poker table for every
step: explain taps Capped, Uncapped, and Nuts under the felt.

Choose polarized or merged betting uses the full poker table for every step:
explain taps Polar, Merged, and Size under the felt.

Use overbets and geometric pressure uses the full poker table for every step: explain taps Overbet, Polar, and Geo under the felt.

Use blockers without solver theater uses the full poker table for every step: explain taps Block, Use, and No EV under the felt.

Defend enough without frequency theater uses the full poker table for every step: explain taps Defend, Bluff, and Enough under the felt.

Mix with a reason uses the full poker table for every step: explain taps Mix, Purpose, and Strong under the felt.

Navigate 3-bet and 4-bet pots by depth uses the full poker table for every step: explain taps 3-Bet, 4-Bet, and Depth under the felt.

Make difficult folds; review coolers fairly uses the full poker table for every step: explain taps Hard, Cooler, and Ego under the felt.

Observe selective aggression uses the full poker table for every step: explain taps Tight, Barrel, and Sample under the felt.

Meet the TAG uses the full poker table for every step: explain taps Tight, Aggro, and Model under the felt.

Observe wide sustained pressure uses the full poker table for every step: explain taps Wide, Pressure, and Sample under the felt.

Meet the LAG uses the full poker table for every step: explain taps Wide, Pressure, and Model under the felt.

Your start’s hand preview uses the Poker table bands (`FeltTableView`, `CoachShelfWidget`), with your cards on the felt. It does not use `LessonTableScene`.

The first lesson’s hole-card explain uses that same column. Other teaching felts stay on `LessonTableScene` until their own ticket.

A lesson step that shows hole cards, including Suits and ranks “Tap the suited hole cards,” places those cards on the hero seat of the Poker table. Retire `_HoleCardFeltTray` for that step.

Hole-card choice bands (`_HoleCardBands` in `select_identify_activity.dart`) fill the lesson stage height and scale the felt and choice rails together so a short phone never overflows. On the lesson frame the coach shelf and street heading stay off — the speech bubble owns the instruction.

A phase column on a teaching felt stacks its playing cards vertically. A horizontal row of `MiniCard` or `CardBack` widgets is not used inside an `Expanded` phase column. Scaling the row down with `FittedBox` is not a substitute for that rule.

### Shipped

Button and blinds (LPT-36) stacks the flop cards and the showdown card backs vertically in `_buildBlindsTiming` (`lib/ui/course/widgets/lesson_table_context.dart`). The next phase column copies that vertical stack.

`_HoleCardBands` (`lib/ui/course/activities/select_identify_activity.dart`) fills the stage and scales felt plus rails with available height. The next hole-card picker step copies that proportional column.

File one ticket per layout you still see, not one ticket per activity id.

## Asset inventory

Slots are the only place a new animation, icon, sound, logo, or mascot is
introduced. Reuse the path already listed. Add a row when a new file ships.

| Slot | Current | Reuse |
| --- | --- | --- |
| Logo | `assets/brand/logo_mark.svg` — gold mark, transparent background, via `BrandLogo` | Welcome, Auth screen, and Live Training hub. Rasterized to launcher / notification icons via `tools/brand/render_logo_assets.mjs` |
| Mascot | `assets/brand/mascot_idle.png` — full body, calm mood, via `RexMascot` | Welcome, Meet Rex, `RexCoachLine`, `RexCoachCard`, and the lesson coach band |
| Mascot celebrate | `assets/brand/mascot_celebrate.png` — the same coach, celebrating mood, the same coach as the calm drawing, via `RexMascot` | Right-answer beat in `LessonFeedbackSheet`, the lesson coach band on accept, and the lesson-result ceremony |
| Icons | Material / Cupertino. No branded icon set | Theme icon color (`slate` in the app bar) |
| Motion | Implicit widget motion only (band resize, `AnimatedSwitcher` 220ms in the runner). No Rive or Lottie | [flutter-ui-ux](../../.cursor/skills/flutter-ui-ux/SKILL.md) durations |
| Sound effects | `SoundService`: `deal.wav`, `chip.wav`, `knock.wav`, `fold.wav`, `win.wav` under `assets/sounds/` | Table actions call these. Do not add a second chip sound |
| Background music | `assets/sounds/lounge_ambient.mp3` via `SoundService.startHomeBgm` | Home. Pause when leaving Home. Settings toggle is `musicEnabled` |

The mascot slot is the full-body coach with a mood. Meet Rex and the Rex line on Your start show that drawing. Text-only `RexCoachLine` is not the slot.

The lesson result uses `RexMascot` for the ceremony. It does not draw a letter R.

A missing slot (Rex still text-only, a deal with no motion, a table action
with no `SoundService` call) is a ticket that names the slot. The walk does
not generate the file. The implementer adds it and fills the row.

The Live Training hub shows `assets/brand/logo_mark.svg` above the lock or the table entry.

### Shipped

The Live Training hub shows `assets/brand/logo_mark.svg` in `_LiveAccessGate` and the open table entry of `LiveTrainingScreen` (`lib/ui/screens/live_training_screen.dart`). Auth uses the same file in `lib/ui/screens/auth_screen.dart`. Welcome uses the same logo mark above `RexMascot` on `WelcomeScreen` (`lib/ui/screens/onboarding_screens.dart`).

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
The mascot is `RexMascot` at width 78 (height follows the full-body
drawing), the same coach as Meet Rex and the lesson-result ceremony.
The bubble is a rounded rectangle with a tail aimed at the
coach's mouth. A plain rectangle is not the bubble. The bubble's top
and that tail stay in the same place on every step. More text grows
the bubble downward. Less text does not move the tail or the first line.

The bubble holds the only instruction for the step. The same sentence
is not repeated on the table, under the table, or in a second coach
line. Your two cards' first step says: "These two are your cards alone.
Nobody else sees them. Tap your cards to peek."

`LessonMascotExpression` picks the Rex mood:

| Moment | Expression | Rex mood |
| --- | --- | --- |
| Prompt, before an answer | Thinking | Calm |
| Accepted answer | Happy | Celebrate |
| Miss | Wrong | Think |

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

On that table the hero sits on the felt with the other seats, exactly
as on the Live Training table. A lesson table does not add a street
heading or a coach shelf. The pot pill names the street. The bubble says
the instruction.

Your two cards' first step shows four seats (you and three other
players), no board, your two cards face down, and arrows on your cards.
Tapping your cards turns them face up. Tapping another seat's cards is
a miss: a buzz, the wrong face, and the answer dock. Those cards stay
face down.

Every step uses this frame and the full poker table in the stage. Tap
table objects when the answer is on the felt. When no table object fits,
answers sit in the action space under the felt. Do not replace the frame
with the old app-bar runner, a mini felt, suit tiles, or rank slots.

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
is the stage. Your two cards uses both. Suits and ranks uses the same
frame and the full table: one community card per suit, board ranks for
order, and face-up seats for suited / pair. Button and blinds uses the
same frame; its stage is the full table, with the dealer button, small
blind, and big blind on the seats. Hand ranks uses the same frame and the
full table: the explain ladder cycles made hands on the felt, order steps
show a made hand on the table with category answers under the felt, the
spot sits face up on the table, and the showdown taps You / Them on that
table. Best five
and kickers uses the same frame and the full table: explain taps the
five cards that play on hero holes and the board, guided and checkpoint
build the best five by tapping those seven cards, and a kicker battle
or a board-plays pot uses that table.
Fold, check, call uses the same frame and the full table: explain
shows a flop on the felt with Fold, Check, and Call under it, and
each action spot uses that table. Bet, raise,
all-in uses the same frame and the full table: explain shows a flop on
the felt with Bet, Raise, and All-in under it, and each action spot
uses that table. Streets and action
order uses the same frame and the full table: explain and street order
advance the board under Preflop / Flop / Turn / River labels, and
postflop seat order uses that table. How pots are won uses the same
frame and the full table: explain taps Fold win, Showdown, and Side pot
under the felt while the board updates, and a fold-win or a called
river uses that table. Play a full toy hand uses the same frame and the full table:
explain taps Blinds, You act, and Ending under the felt, and each
street of the hand uses that table. Section 1 jump check uses the same frame: rank and
seat order stay lists, and the action spot and the toy hand use the
full table. Position labels uses the same frame: the six-max seats
are labeled on the full table. Acting order uses the same frame:
preflop order is EP, then HJ, then BTN on that table. Hand families
uses the same frame and the full table: explain taps Pairs, Broadways,
Suited aces, and Connectors under the felt while holes update, and a
starting hand sits face up on that table. Open or fold baseline
uses the same frame and the full table: explain taps Early, Button, and
Live 3x under the felt, and each open sits face up on that table. Versus an open uses
the same frame and the full table: explain taps Fold, Call, and 3-bet
under the felt, and each response sits face up on that table. Effective stacks uses the
same frame and the full table: explain taps Chips→BB, Shorter, and Depth
under the felt. Live table habits uses the same frame and the full
table: explain taps Watch, Say, Cover, and Wait under the felt.
Full-ring baseline hand uses the same frame and the full table:
explain taps Nine, Same, and Position under the felt on a nine-max
ring, and each decision sits face up on that table. Baseline
jump check uses the same frame: the seat map and the starting hand
sit on the full table, the open and the 3-bet use that table, and
the stack check stays a list. Read the table first uses the same
frame and the full table: explain taps Pot, Stacks, Button, and Who
Acts under the felt, and the first-to-act seat is tapped on that
table. Name your flop class uses the same frame and the full table:
explain taps Made, Draw, SDV, and Air under the felt, and each flop
sits face up on that table. Count outs, pay the right price uses the
same frame and the full table: explain taps Clean, Dirty, and Price
under the felt, the clean aces stay a card picker, and a priced draw
sits face up on that table. Choose a flop line uses the same frame
and the full table: explain taps Value, C-bet, Check, Call, Fold, and
Raise under the felt, and each flop decision sits face up on that
table. Plan the turn card uses the same frame and the full table:
explain taps Brick, Change, Barrel, and Delay under the felt, and
each turn sits face up on that table. Close the river correctly uses
the same frame and the full table: explain taps Value, Bluff, Catch,
and Fold under the felt, and each river sits face up on that table.
Play tighter multiway uses the same frame and the full table: explain
taps Stronger, Fewer, and Nuts under the felt, and each multiway spot
sits face up on that table. Patch the common leaks uses the same frame
and the full table: explain taps Top pair, Prices, Passive, and Crowds
under the felt, and each leak spot sits face up on that table. Section 3 jump check uses the
same frame: the table-read stays a list, the flop class and the
bad-price draw sit face up on the full table, and the multiway fold
and the value bet use that table. Think in ranges uses the same
frame and the full table: explain taps One hand, Range, and Update
under the felt, and the bet-twice and same-board spots sit face up
on that table. Navigate 3-bet pots uses the same frame and the full
table: explain taps 3-bet, Ranges, and Squeeze under the felt, and
each 3-bet spot sits face up on that table. Plan beyond the flop uses
the same frame and the full table: explain taps Flop, Turn, and River
under the felt, and each street of the plan sits face up on that
table. Size with a message uses the same frame and the full table:
explain taps Value, Pressure, and Size under the felt, and each
sizing spot sits face up on that table. SPR decides commitment uses
the same frame and the full table: explain taps SPR, Low, and High
under the felt, and each commitment spot sits face up on that table.
Observe sticky callers uses the same frame and the full table: explain
taps Enters, Calls, and Folds under the felt, the participation note
and the observation bundle stay lists, and the sticky-call and
low-confidence spots sit face up on that table. Meet the Calling
Station uses the same frame and the full table: explain taps Station,
High, and Low under the felt, and the label quizzes stay lists. Adjust
versus Calling Station uses the same frame and the full table: explain
taps Value, Bluffs, and Cite under the felt, each adjustment spot sits
face up on that table, and the bluff-less reason stays a list. Observe
narrow players uses the same frame and the full table: explain taps
Rare, Enter, and Mean It under the felt, and the entry quizzes stay
lists. Meet the Nit uses the same frame and the full table: explain taps
Nit, Narrow, and Respect under the felt, and the label quizzes stay lists.
Adjust versus Nit uses the same frame and the full table: explain taps
Steal, Credit, and Explode under the felt, each nit spot sits face up on
that table, and the respect reason stays a list. Observe wild aggressors
uses the same frame and the full table: explain taps Raise, Barrel, and
Count under the felt, and the entry quizzes stay lists. Meet the Maniac
uses the same frame and the full table: explain taps Maniac, Entry, and
Aggro under the felt, and the label quizzes stay lists. Adjust versus
Maniac uses the same frame and the full table: explain taps Wider, Hang,
and Ego under the felt, each maniac spot sits face up on that table, and
the call-wider reason stays a list. Confidence and samples uses the same
frame and the full table: explain taps Observe, Samples, and Showdowns
under the felt, and the confidence quizzes stay lists. Same hand,
different types uses the same frame and the full table: explain taps
Cards, Seats, and Evidence under the felt, and each type spot sits face
up on that table. Section 4 jump check uses the same frame: the
range, SPR, and player-type checks stay lists, and the 3-bet and the
sizing spot sit face up on the full table. Build multiway ranges
with nut potential uses the same frame and the full table: explain taps
Nutted, Air, and Domination under the felt, the continue and priority
checks stay lists, and the connector and the set spots sit face up on
that table. Play
150–300bb stacks with a plan uses the same frame and the full table:
explain taps Deep, Realize, and Stack under the felt, the implied, plan,
and reward checks stay lists, and the wet-flop fold sits face up on that
table. Implied
and reverse odds uses the same frame and the full table: explain taps
Implied, Reverse, and Second under the felt, each price spot sits face
up on that table, and the rise check stays a list. Thin value and bluff-catches uses the same frame and the full table:
explain taps Thin, Catch, and Barrels under the felt, each thin-value
spot sits face up on that table, and the read check stays a list.
Advanced flop lines uses the same frame and the full table: explain taps
X/R, Probe, Delay, and Donk under the felt, the nit, donk, and delay
checks stay lists, and the probe spot sits face up on that table. Street-by-street
updates uses the same frame and the full table: explain taps Action,
Rewrite, and Update under the felt, the capped, habit, and shove checks
stay lists, and the turn bomb sits face up on that table. Soft timing evidence uses the same frame and the full table: explain taps
Timing, Sizing, and Clues under the felt, and the timing quizzes stay
lists. Live table dynamics uses the same frame and the full table: explain taps
Stuck, Tilted, and Gears under the felt, the stuck, gear, and freshness
checks stay lists, and the steaming spot sits face up on that table. Keep
cash session guardrails uses the same frame and the full table: explain
taps Quit, Guard, and First under the felt, and the discipline quizzes
stay lists.
Section 5 checkpoint uses the same frame: the multiway, tell, and stop
checks stay lists, and the thin-value and bluff-catch spots sit face
up on the full table. Spot range advantage and nut advantage uses the same frame and the full
table: explain taps Range, Nut, and Advantage under the felt, the
dry-board, paired-board, and press checks stay lists, and the c-bet
spot sits face up on that table. Realize equity in and out of
position uses the same frame and the full table: explain taps Equity,
Cash, and Pos under the felt, and the realization quizzes stay lists.
Recognize capped versus uncapped ranges uses the same frame and the full
table: explain taps Capped, Uncapped, and Nuts under the felt, the
check-turn, bomb, and attack checks stay lists, and the thin-value spot
sits face up on the full table. Choose polarized or merged betting uses
the same frame and the full table: explain taps Polar, Merged, and Size
under the felt, the overbet, mismatch, and aim checks stay lists, and the
merged-size spot sits face up on the full table. Use overbets and geometric pressure uses the same frame and the full
table: explain taps Overbet, Polar, and Geo under the felt, the
candidate, avoid, and plan checks stay lists, and the geometric turn
sits face up on the full table. Use blockers without solver theater uses the same frame and the full
table: explain taps Block, Use, and No EV under the felt, the unblock,
tweak, and EV checks stay lists, and the flush board sits face up on
the full table. Defend enough without frequency theater uses the same frame and the full
table: explain taps Defend, Bluff, and Enough under the felt, the continue, intuition, and punish checks stay lists,
and the third-pair fold sits face up on the full table. Mix with a reason uses the same frame and the full table: explain taps
Mix, Purpose, and Strong under the felt, the station, reason, and purpose checks stay lists, and the
set check sits face up on the full table. Navigate 3-bet and 4-bet pots by depth uses the same frame and the full
table: explain taps 3-Bet, 4-Bet, and Depth under the felt, the commit, ego, and SPR checks stay lists, and the missed
AQo flop sits face up on the full table. Make difficult folds; review coolers fairly uses the same frame and the full table: explain taps Hard, Cooler, and Ego under the felt, the cooler, ego, and review checks stay lists, and the
weak-kicker fold sits face up on the full table. Observe selective aggression uses the same frame and the full table: explain taps Tight, Barrel, and Sample under the felt, and the entry quizzes stay lists. Meet the TAG uses the same frame and the full table: explain taps
Tight, Aggro, and Model under the felt, and the label quizzes stay
lists. Adjust versus TAG uses the same frame: credit, tighter, and no
light stay in the stage, the respect check stays a list, and the heat,
steal, and thin-value spots sit face up on the full table. Observe wide sustained pressure uses the same frame and the full table: explain taps Wide, Pressure, and Sample under the felt, and the entry quizzes stay
lists. Meet the LAG uses the same frame and the full table: explain taps Wide, Pressure, and Model under the felt, and the label quizzes stay lists. Adjust versus LAG uses
the same frame: call, trap, and fancy less stay in the stage, the
avoid and cite checks stay lists, and the call-wider and trap spots
sit face up on the full table. Same cards, five type models uses the
same frame: cards, seats, and evidence stay in the stage, the label
check stays a list, and the station, nit, and LAG spots sit face up on
the full table. Section 6 checkpoint uses the same frame: the
advantage, cap, polar, TAG, and LAG checks stay lists. Carry a preflop
plan onto the flop uses the same frame: reason, confirm, and cancel
stay in the stage, and the plan quizzes stay lists. Map turn barrels
before you bet flop uses the same frame: barrel, give-up, and map stay
in the stage, the no-plan and definition checks stay lists, and the
continue and brick spots sit face up on the full table. Compose river
value and bluffs uses the same frame: value, bluff, and hold stay in
the stage, the blocker, empty, and rule checks stay lists, and the
top-set value spot sits face up on the full table. Change plans by
pot type uses the same frame: limped, SRP, and 3-4bet stay in the
stage, and the pot-type quizzes stay lists. Switch gears between HU
and multiway uses the same frame: fewer, thicker, and widen stay in
the stage, and the player-count quizzes stay lists. Rewrite plans
when stacks change uses the same frame: short, deep, and effective
stay in the stage, and the depth quizzes stay lists. Replay the same
hand versus each type uses the same frame: cards, models, and cite
stay in the stage, the no-evidence check stays a list, and the
station, TAG, and LAG spots sit face up on the full table. Integrate
type, board, line, and sizing uses the same frame: type, board, line,
and size stay in the stage, the integration check stays a list, and
the maniac, nit, and TAG spots sit face up on the full table. Write
your default strategy book uses the same frame: leak, book, and review
stay in the stage, and the book quizzes stay lists. Capstone:
single-raised pot uses the same frame: plan, update, and finish stay
in the stage, and the three streets sit face up on the full table.
Capstone: 3-bet pot uses the same frame: SPR, turn, and close stay in
the stage, and the three streets sit face up on the full table.
Capstone: multiway deep uses the same frame: nuts, deep, and no-bluff
stay in the stage, and the three streets sit face up on the full table.
Capstone: limped pot uses the same frame: nuts, value, and thin stay
in the stage, and the three streets sit face up on the full table.
Capstone: 4-bet pot uses the same frame: SPR, commit, and no hero stay
in the stage, and the three streets sit face up on the full table.
Prep a coached Live warm-up hand uses the same frame: checklist,
defaults, and one hand stay in the stage, and the warm-up quizzes stay
lists. Final: all five player types uses the same frame: the station,
nit, maniac, TAG, LAG, certainty, and retire checks stay lists. The procedure for the
next lesson is
[lesson-screen-layout](../../.cursor/rules/lesson-screen-layout.mdc).

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
| Wrong | The coach brings both arms in. The dock says Think again or Not quite. Continue stays on the step. |
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

A miss shows that coach thinking beside the short line. `LessonFeedbackSheet` uses `RexMascot` with `RexMood.think`. It does not celebrate.

The lesson coach band uses the same `RexMascot` slot. `LessonCoachBand` (`lib/ui/course/widgets/lesson_screen_layout.dart`) maps `LessonMascotExpression` to calm, celebrate, or think. It does not draw a placeholder face.

The locked Live Training hub names Baseline jump check in `liveTrainingLockedMessage` (`lib/models/live_access.dart`). That title is the Home node for `lesson-02-07-02-section-two-jump`.

The lesson result shows this lesson’s XP and the daily goal before Home. `LessonResultScreen` (`lib/ui/screens/lesson_result_screen.dart`) lists XP earned and a Daily goal row of the onboarding minutes.
