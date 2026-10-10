# UI design record

The visual and interaction contract for Live Poker Trainer. A screen either
matches this file, or a ticket names the section the change will update.
Later work copies a section. It does not invent a second button, type ramp,
table, sound, or mascot.

`/ui-design-agent` ([command](../../.cursor/commands/ui-design-agent.md))
walks the app against this file, files the gap in Jira, ships it, and lands
the section update in the same change. It also keeps
[ui-design-agent-learnings.md](../../.cursor/commands/ui-design-agent-learnings.md)
updated so later runs do not repeat operational mistakes. Any other UI
change follows the same rules. Read
[flutter-ui-ux](../../.cursor/skills/flutter-ui-ux/SKILL.md) and the
[Duolingo Chess patterns](references/duolingo-chess/PATTERNS.md) before
editing.

Reference device: **iPhone 13 mini** (375 × 812 pt). Small phones are where
this app breaks first. A layout that only works on a large phone is not done.

## What the stakeholders are asking for

Distilled from the commit history, PR test plans, LPT tickets, and the
owner's own instructions to agents. When a screen is ambiguous, these win.

1. **Duolingo Chess, for poker.** The course is a game, not a textbook.
   The reference is the 130-frame walkthrough in
   `references/duolingo-chess/frames/`. Copy the loop, not the palette, the
   owl, or the words.
2. **Teach by doing.** Every step is answered in the world: tap your cards,
   a board card, a seat, a chip, an action. A text Q&A list is the last
   resort, used only when the answer really is a label. The owner's words:
   "No boring text Q&A quizzes — Duolingo wasn't like that; teach by doing."
3. **One phone-first poker table everywhere.** Live Training, Your start,
   and every lesson step that shows a hand draw the same `FeltTableView`.
   No mini felts, suit tiles, rank slots, or second table widget.
4. **It feels like a real live table.** The dealer deals one card at a time,
   clockwise from the button, then the board one card at a time, with a
   deal sound per card. Blinds are posted in front of their seats. Early
   folds are shown. Bets and CHECK sit on the felt lane in front of a seat.
   The pot flies to the winner and stacks update.
5. **Rex is the coach, with a face and a mood.** One mascot, the same
   drawing everywhere, calm / celebrating / thinking. Never a letter R,
   never a text-only coach on a right or wrong beat.
6. **Gentle, honest guidance.** Gold glow (SoftPulse) marks the target only
   after the cards have landed, and only for the first press. Hint is off
   while cues are already on. The learner's own picks stay visible in cyan
   under the coach feedback. Review lessons hide cues. Coach copy names
   the cards actually dealt, not a template combo.
7. **The game economy is visible and fair.** Five hearts. A non-guided
   mistake costs a heart. At zero hearts the lesson is blocked in place and
   the empty hearts breathe; the refill sheet opens when the last heart is
   spent (and from the Oops CTA / empty-heart chrome). Practice on a weak
   finished lesson earns a heart back. Streak, gems, XP, and the daily goal
   are celebrated, not reported.
8. **Home is a path.** One section at a time, a sticky unit banner, circular
   nodes on a zig-zag, a pulse on the next lesson, and a Duolingo-style
   START / REVIEW bubble when a node is tapped.
9. **Polish without a second visual language.** Dark navy and emerald felt,
   gold primary, cream text, Cinzel / Manrope / JetBrains Mono. Theme
   metrics, not hand-tuned radii. Nothing clips or overflows on the mini.
10. **Depth before breadth.** Finish one screen or one lesson properly
    before moving on. A real teach-by-doing or behavior gap beats another
    round of spacing chrome.

### Rejected on purpose

Do not bring these back. Each was removed after the owner asked for it.

| Removed | Replaced by |
| --- | --- |
| Text-only explain steps with a lone Continue | Teach-by-doing taps under the felt |
| Mini felts, suit tiles, rank slots, `_HoleCardFeltTray` | The full poker table |
| Bouncing cue arrows (`CueArrows`, `CuePulse`) | `GlowHighlight` SoftPulse ring |
| Rex card and Rex + Start box on the Home path | START / REVIEW bubble on the tapped node |
| START chip on the path node | The same bubble |
| Home Resume card and guest-progress banner | The path scrolls to the next lesson |
| Home course mark above the status strip | A centered streak / gems / hearts strip |
| "Step x of 4" and title rows on onboarding | A progress bar and Rex's bubble |
| Lesson-title row under the lesson progress bar | Nothing. The bubble is the instruction |
| Out of hearts / Restore hearts dock | Breathing empty hearts in the chrome |
| Heart-restored confirmation toast | The heart count changes in place |
| Duo sky blue, Nunito, slab buttons | Theme gold and the Theme button metrics |

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
6. A stakeholder ask that is not shipped yet goes under Known gaps, not in
   a contract section. Remove it from Known gaps when it ships.

## Surfaces

Every screen the app has, and where to reach it on the mini. Walk paths and
preconditions are in [agent-paths.md](../agent-paths.md).

| Surface | Code | Reach it |
| --- | --- | --- |
| Welcome | `WelcomeScreen` in `lib/ui/screens/onboarding_screens.dart` | Fresh install |
| Rex intro | `CoachIntroScreen` in `onboarding_screens.dart` | Welcome → Get started |
| Onboarding questions (experience, daily goal) | `onboarding_screens.dart` | After Rex intro |
| Rex motivation | `onboarding_screens.dart` | After the questions |
| Recommended start / Your start | `lib/ui/screens/first_lesson_launch_screen.dart` | After Rex intro |
| Auth | `lib/ui/screens/auth_screen.dart` | Welcome → I already have an account |
| Lesson runner | `lib/ui/screens/lesson_runner_screen.dart`, `LessonScreenLayout` | Any lesson; `agent_tap.py openlesson --text <lesson id>` |
| Answer dock | `LessonAnswerDock` in `lesson_screen_layout.dart` | Answer any step |
| Hint | `lesson_runner_screen.dart` | Tools row → Hint |
| Heart refill sheet | `lib/ui/course/widgets/heart_refill_sheet.dart` | Tap the hearts in lesson chrome or on Home |
| Lesson result | `lib/ui/screens/lesson_result_screen.dart` | Finish a lesson |
| First-lesson celebration chain | `DayStreakScreen` → `StreakGoalScreen` → `DailyQuestsCompleteScreen` → `GemsRewardScreen` | After the first guest lesson |
| Save progress | `SaveProgressScreen` in `onboarding_screens.dart` | After the celebration chain |
| Home path | `lib/ui/screens/home_screen.dart`, `lib/ui/home/course_path_view.dart` | Home tab |
| Status strip | `lib/ui/home/course_status_bar.dart` | Top of Home |
| Section picker | `lib/ui/home/course_section_picker.dart` | Tap the unit banner |
| Bottom navigation | `ShellBottomNav` in `lib/ui/widgets/shell_bottom_nav.dart` | Every tab |
| Live Training hub and lock | `lib/ui/screens/live_training_screen.dart` | Live Training tab |
| Live table | `lib/ui/screens/poker_table_screen.dart` | Unlocked hub → start |
| Profile | `lib/ui/screens/profile_screen.dart` | Profile tab |
| Settings | `lib/ui/screens/settings_screen.dart` | Profile → Settings |

## Theme

Source: `lib/ui/theme/app_theme.dart` (`buildPokerTheme`) and
`lib/core/constants/colors.dart` (`AppColors`).

Dark Material 3. Navy charcoal scaffold (`bgDark`), emerald felt, gold
primary, cream text. Display type is Cinzel. UI type is Manrope. Data
(chips, labels, counts) is JetBrains Mono.

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

| Accent | Use |
| --- | --- |
| Gold | Primary actions, coach cues (SoftPulse) |
| Cyan (`#5EC8FF`) | Gems, and the learner's own selection ring |
| `warning` / gold | Streak |
| `AppColors.hearts` | Hearts |
| `AppColors.success` / `AppColors.danger` | The answer dock only |

Onboarding primary actions use the elevated button. On Welcome, “I already
have an account” uses the outlined button.

Rex intro is a single `CoachIntroScreen` route that advances its two coach
lines in place, then pushes Experience; it does not stack a second CONTINUE
under the visible one.

Save progress uses the same radial felt gradient as other onboarding
scaffolds. CREATE A PROFILE uses the elevated button. LATER uses the
outlined button. “I already have an account” is a gold-bright Manrope text
link. Nice work and XP / streak chips use `AppColors` gold / warning on
`bgElevated` with JetBrains Mono values.

After the first guest lesson and before Save progress, the celebration chain
is Day streak → Streak goal → Daily quests → Gems reward. CONTINUE and
I CAN DO IT use the elevated button.

Lesson feedback Continue and lesson result CONTINUE use the elevated button
(radius 14). The Settings Chip display segments ($, BB, Both) use JetBrains
Mono. Settings Account **Create an account** / **Sign out** and Profile guest
**Create an account** use the Theme elevated and outlined button metrics
(radius 14); they are not stadium `FilledButton`s.

### Shipped

Rex intro is `CoachIntroScreen` in `lib/ui/screens/onboarding_screens.dart`
(two lines, one route, then Experience). The next multi-line coach beat
advances in place the same way.

Save progress CTAs and celebration chips are `SaveProgressScreen` in
`lib/ui/screens/onboarding_screens.dart`. The next guest conversion screen
copies those elevated / outlined / gold-bright link roles.

Chip display segments and Account CTAs are on `SettingsScreen`
(`lib/ui/screens/settings_screen.dart`). Profile guest **Create an account**
is the Theme elevated button on `ProfileScreen`
(`lib/ui/screens/profile_screen.dart`). The next screen that labels a chip
amount copies that data type. Account primary / secondary copy the elevated
and outlined Theme metrics.

Heart refill sheet copy is Manrope with JetBrains Mono on the countdown
(`lib/ui/course/widgets/heart_refill_sheet.dart`, LPT-58). The next help or
economy sheet copies that Theme pair and does not bring Nunito back.

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
  stack in large JetBrains Mono. Hole cards sit fully above the box with a
  small gap — neither covers the other. The icon ring is colored by player
  type when player types are on, and a type tag sits on the box face.
- **Around a seat.** Dealer, SB, and BB pucks, the street bet, and CHECK park
  on a fixed potward felt lane for that seat (`SeatFeltSpots`) — the ray from
  the seat toward the pot, starting just past the seat claim. Distances scale
  with the seat so markers stay tight and consistent for 2–9 players. Other
  action badges (FOLD, CALL, RAISE, …) hang from the bottom of the box.
- **Center.** The pot pill (`FLOP · POT $10`) above the board, five large
  board cards, and `Blinds $1/$2 NLH` under them (`CommunityCardsView`). The
  board leaves clear side margins on the felt (`TableLayout.boardSideInset`)
  and takes the largest scale that no seat, puck, or bet reaches.
- **Cards.** Playing cards use one face everywhere (see Lesson tables).
  Suits are traditional red and black.

### The deal

`DealtCardReveal` with `CardDealPace` (`lib/core/deal/card_deal_pace.dart`)
deals like a live dealer: hole cards clockwise from the button in two
rounds, then the board one card at a time. Each card lands once, in order,
with one of the eight `deal_0N.wav` hits. A later-street start deals only
the arriving street. A tap on a lesson button never redeals the hand. Folds
before the hero's decision are shown after the deal, not before it.

When a lesson hand is won, the pot flies to the winner seat and the stacks
update (`lessonTableStageGame`).

### Live Training bands

The Live Training screen is a column of non-overlapping bands:

1. Header
2. Felt (`FeltTableView`) — flexible, with you at the bottom
3. Coach shelf (`CoachShelfWidget`)
4. Action dock (`ActionDockWidget`) — removed, not dimmed, when the hero has no decision

YOUR TURN, ACTION…, and FOLDED show as a chip under your seat box. Above
width 900 the coach moves to a side column. Band resize uses a short size
animation (about 280ms). The coach and the dock never cover your cards.
Once a hand is over your cards grow a little.

On Your start, Start lesson is below the coach shelf. The shelf shows the
flop sentence for the preview hand.

A lesson step uses the lesson screen layout instead of the coach shelf: the
speech bubble is the instruction.

`HeroRailWidget` no longer draws the hero on any table. It only draws the
hand choices on the hole-card picker.

### Table features

`TableFeatures` (`lib/ui/widgets/table_features.dart`) turns the optional
layers on or off: stacks, pot, street name, blinds line, position pucks,
street bets, action badges, opponents' face-down cards, player types,
VPIP/PFR, and empty board slots. Seats, the board, and your cards always draw.

The lesson runner puts each lesson under `TableFeaturesScope` with
`TableFeatures.forLessonId`. Each layer switches on at the lesson that
teaches it and stays on for the rest of the course.

| Layer | On from | Constant |
| --- | --- | --- |
| Pucks, blinds line, posted chips, pot | 1.1.3 Button and blinds | `blindsLesson` |
| Action badges | 1.3.1 Fold, check, call | `actionsLesson` |
| Stack amounts | 1.3.2 Bet, raise, all-in | `stacksLesson` |
| Street name in the pot pill | 1.4.1 Streets and action order | `streetLesson` |
| Player types, VPIP/PFR | 4.6.1 Observe sticky callers | `playerTypesLesson` |

Your two cards and Suits and ranks show only seats, cards, and the board
when a step deals one. A hole-only step (Your two cards peek, Button and
blinds explain, and Button and blinds frame steps that share
`isLessonBlindsFrameActivity` without a dealt board) turns `boardSlots`
off so empty outlines do not draw. Live Training and an id that is not
`lesson-SS-UU-LL` get `TableFeatures.full`. Your start uses the preset of
the lesson it recommends.

A lesson seat shows a player type only when the step names it
(`villainArchetypes`); a seat never shows a made-up type. A spot that says
"unknown" stays a plain seat, because having no read is its point.

### Stakes

Lesson tables play `Blinds $1/$2 NLH` with 100 big blind stacks
(`lessonSmallBlind`, `lessonBigBlind`). Preflop, the small and big blind are
posted as bets in front of their seats, and the pot counts them. A step that
teaches another level passes `smallBlind` and `bigBlind` to
`LessonTableStage`; the blinds line and every amount follow.

### Shipped

`PokerTableScreen` is the Live Training table and the calibration warm-up.
`LessonTableStage` draws the same `FeltTableView` for lessons, and
`PokerTableBands` draws it for Your start.

## Lesson screen layout

Every lesson step uses the same five regions, in this order, on a phone.
The regions do not move, swap, or collapse between steps. A step may leave
a region quiet (fewer seats, hint disabled). It does not invent a second
header, a second prompt, or a second table.

Your two cards (`lesson-01-01-01-your-two-cards`) is the first lesson on
this frame. Every lesson uses `LessonScreenLayout` in
`lib/ui/course/widgets/lesson_screen_layout.dart`. None builds its own
chrome. The procedure is the
[lesson-screen-layout](../../.cursor/rules/lesson-screen-layout.mdc) rule.

```
┌──────────────────────────────────────┐
│ 1  X     progress bar    ♥ ♥ ♥ ♥ ♥   │
│ 2  [Rex]   speech bubble             │
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

There is no lesson-title row.

### 1. Chrome

One row, height 36.

| Slot | What it is |
| --- | --- |
| Close | `X` on the left. Leaves the lesson. It is not a back chevron. |
| Progress | The lesson bar fills the space between close and the hearts. It advances by activity. |
| Hearts | One heart per life, filled while that life remains. A miss that costs a life empties one heart. At zero, the empty hearts breathe slowly, the refill sheet opens, a blocked stage tap nudges, and the Oops CTA becomes Restore hearts (not Continue). |

### 2. Coach band

The mascot and one speech bubble share a row directly under the chrome.
The mascot is `RexMascot` at width 78 with `RexMascotCrop.upperBody`, the
same coach as Meet Rex and the lesson-result ceremony. The bubble is a
rounded rectangle with a tail aimed at the coach's mouth. The bubble's top
and that tail stay in the same place on every step. More text grows the
bubble downward.

The bubble holds the only instruction for the step. Your two cards' first
step says: "These two are your cards alone. Nobody else sees them. Tap your
cards to peek."

While the lesson is bootstrapping (or recovering from a load error), the
coach bubble shows one calm line such as getting the next step ready —
never an empty bubble beside Rex.

Every bubble ends by saying what to tap (`lessonFrameSpeech`). A test walks
the whole catalog and fails on a bubble with no tap line. Copy that names
hole cards names the cards actually dealt. Loading lines name what is
happening. On a locked start, Rex's bubble names the primary recovery
control (Open `<previous lesson>` when shown; otherwise Retry) — never a
Retry-only line while Open previous is the gold CTA.

| Moment | Expression | Rex mood |
| --- | --- | --- |
| Prompt, before an answer | Thinking | Calm |
| Accepted answer | Happy | Celebrate |
| Miss | Wrong | Think |

### 3. Stage

The stage is the large middle slot and the only region that changes from
step to step. When the step shows hole cards, a board, a pot, seats, or an
action, the stage is the full poker table: `LessonTableStage` on
`FeltTableView`. Fewer players, a shorter board, or no action dock is how a
step focuses. Tap table objects when the answer is on the felt. When no
table object fits, answers sit in the action space under the felt as
`LessonChoiceButton`s.

Your two cards' first step shows four seats, no board, your two cards face
down. Empty board slot outlines stay off (`boardSlots: false` on
`LessonPeekTable`) until a step deals community cards. Tapping your cards
turns them face up. Tapping another seat's cards is a miss.

Button and blinds' explain step (`LessonBlindsClockwiseTable`) draws seats,
pot, pucks, posted blinds, and hole-card backs with empty board slot
outlines off (`boardSlots: false`) until a later step deals community cards.
Button and blinds hole-only frame steps (`act-01-01-03-guided-button` and
siblings that share `isLessonBlindsFrameActivity` without a dealt board)
pass the same `boardSlots: false` gate on their `LessonTableStage` (LPT-52).

### Cues

`GlowHighlight` (`lib/ui/widgets/glow_highlight.dart`) is the one cue. There
are no arrows. Guide cues and Hint-reopened cues use the same gold SoftPulse
ring — never a second cue language for hints.

| Ring | Meaning |
| --- | --- |
| Gold (`GlowKind.cue`) | SoftPulse: the coach's **one** current target. Breathes |
| Cyan (`GlowKind.selection`) | What the learner tapped. Stays on under Nice! and the miss dock |

SoftPulse rules:

- It appears only after the dealt cards have landed.
- At most one gold SoftPulse target at a time. It marks the first press of
  a multi-press step, then stays off unless Hint reopens SoftPulse for the
  **next** press only.
- Hint is disabled while gold SoftPulse is already on for this press.
- Review lessons hide cues by default.
- The ring's outset is reserved in layout, so toggling it never moves or
  resizes a tile.

### 4. Tools

Undo, redo, and hint sit in one fixed row under the stage while the step is
unanswered. Undo reverts the local answer. Redo restores what undo cleared.
Best five card picks (including an invalid five that only shows "try a
stronger five") stay in the activity draft so Undo clears them like any
other local answer (LPT-62). Hint shows **one** hint for the current press
in the speech bubble until it is tapped again — not stacked with the idle
coach line. A step with no hint leaves the button visible and disabled,
including mid multi-turn sequence when the current press has nothing left
to hint.

Bootstrap, locked-start, and start-error frames hide `LessonToolRow`; the tool row appears only after an activity is bound.

### 5. Answer dock

A graded answer replaces the tool row. It does not push a new route. The
dock is a Duolingo-style full-bleed bar: opaque elevated color from edge to
edge, extending under the home indicator, with a clear gap
(`LessonAnswerDock.stageClearance`) above it. The stage shrinks when the
dock appears.

| Answer | Title | Button |
| --- | --- | --- |
| Accepted | Nice! | Continue, `AppColors.success` |
| Miss | Oops, that's not correct | Continue, `AppColors.danger` |

One short line under the title says why. Continue is the only button. On a
miss, Continue clears the dock and stays on the same step. On an accepted
answer, Continue advances.

### Shipped

`LessonScreenLayout` (`lib/ui/course/widgets/lesson_screen_layout.dart`)
is the frame. `LessonTableStage` (`lib/ui/course/widgets/lesson_table_stage.dart`)
is the stage. `LessonPeekTable` turns `boardSlots` off so the first Your
two cards step has no empty board outlines. `LessonBlindsClockwiseTable`
turns `boardSlots` off the same way for Button and blinds explain. Blinds
frame steps in `select_identify_activity.dart`
(`isLessonBlindsFrameActivity`) pass `boardSlots: false` on
`LessonTableStage` the same way (LPT-52). Pending frames pass
`showToolRow: false` so Undo / Redo / Hint stay off until an activity
binds (LPT-53).
`LessonCoachBand` maps `LessonMascotExpression` to calm, celebrate, or
think. `LessonChoiceButton` (`lib/ui/course/widgets/rex_coach_line.dart`)
is the one framed option button.

## Lesson tables

Contract: every lesson step uses the Poker table (`FeltTableView`, with
`CoachShelfWidget` and `ActionDockWidget` where the step has them). Retire
mini felts, suit tiles, and rank slots.

Two older layouts still exist inside the lesson runner. New work does not
copy them:

| Layout | File | What it is |
| --- | --- | --- |
| `LessonActionSpot` | `lib/ui/course/widgets/lesson_action_table.dart` | Mini felt plus an action dock. `isLessonActionTableActivity` turns it on per activity id. |
| `LessonTableScene` | `lib/ui/course/widgets/lesson_table_context.dart` | Authored teaching felt (hole cards, seats, button, captions). |

`FullTableHandLabActivity` still builds `PokerActionSizingActivity` and
`LessonActionSpot`. The name is not the full table above.

Your start’s hand preview uses the Poker table bands (`FeltTableView`,
`CoachShelfWidget`), with your cards on the felt.

### Lesson content

Lesson steps teach with the cards and coach on screen, not with static
demo text. `/ui-design-agent` checks these on every lesson walk:

| Check | Contract |
| --- | --- |
| Randomization | Cards are randomized within the hand class each attempt. A second open of the same lesson should not always deal the identical hole/board when the activity supports a class of hands. |
| Coach follows the deal | Speech, grade lines, and chip math name the cards, seats, and amounts on the felt for this attempt — not a previous deal or a hard-coded template combo. Hand ranks showdown-order Hint copy is built from the dealt seat→hand-class map for this attempt (including after seat-role shuffle), not the static catalog line that assumes You / Sam / Jo keep the authored classes (LPT-54). |
| Hint (one at a time) | Hint swaps the speech bubble to **one** hint for the current press until tapped again. Never stack hint + idle prompt, or two hint bubbles. Disabled whenever gold SoftPulse (`showTargetCue`) is already on for this press — including single-press scaffolded SoftPulse (Best five kicker showdown), not only multi-press sequential waves (LPT-63). Visible but **disabled** when there is no hint — including a multi-press / multi-turn step after the last press that had a hint. Grading a step (Nice! or Oops) clears Hint so the speech bubble is never the Hint line under the answer dock; SoftPulse from that Hint press ends with the grade (LPT-60). |
| Cues (one system, one gold) | `GlowHighlight` only: gold SoftPulse for the guide/Hint target, cyan for the learner's picks. Hint-reopened SoftPulse looks the same as the guide cue. At most one gold target at a time; after that press is taken, gold stays off until Hint reopens the next — except on multi-press explain SoftPulse sequences with no hint text (button → SB → BB, best-five `playOrder`), where gold SoftPulse advances to the next required card/seat and Hint stays disabled while that gold cue is on. Best five explain SoftPulse marks only the next card in `playOrder` — never every remaining playing hole at once (LPT-55). Best five guided/scaffolded picker SoftPulse (`LessonBestFivePickerTable`) marks only the next untapped card in the recommended `choiceSets` list — one gold ring at a time — matching explain `playOrder` SoftPulse; Hint reopens that same card cue (LPT-57). Best five picker post-grade (Nice! / Oops) does not SoftPulse every correct card; cyan keeps the learner's picks and leftovers dim so the coach five reads without multi-target gold (LPT-61). Best five explain does not dim leftover hole/board cards until the five that play are tapped; SoftPulse and cyan selection are the only pre-answer emphasis (LPT-56). Review lessons hide cues by default. No `CueArrows` / `CuePulse`. |
| Coach mood | Calm on the ask, celebrate on Nice!, think on Oops. Never an empty bubble after the deal, never a letter-R coach. While the lesson is bootstrapping (or recovering from a load error), the coach bubble shows one calm line such as getting the next step ready — never an empty bubble beside Rex. On a locked start, the bubble names Open `<previous lesson>` when that CTA is shown; otherwise Retry (LPT-51). |
| Hearts | A non-guided miss empties one heart in place. Guided free misses do not — `evaluateLifeAndAcceptance` sets `lifeLost` only when the stage is not `guided` (scaffolded, unguided, checkpoint, jump_test still spend; LPT-59). At zero, empty hearts breathe and the refill sheet opens from the hearts control. Practice / gem refill restores hearts in place (no toast, no rejected out-of-hearts dock). |

Guided Suits and ranks keeps cyan board picks across SoftPulse/Hint
rebuilds until all four real suits are in; `syncSelection` only mirrors a
completed `suits-full` draft (LPT-47).

Playing cards use one face everywhere: `TableCard` (corner rank, one centered suit). `MiniCard` and `CardBack` are size presets over `TableCard` / `TableCardBack` for densified lesson trays — they must not invent a second face.

A phase column on a teaching felt stacks its playing cards vertically. A horizontal row of `MiniCard` or `CardBack` widgets is not used inside an `Expanded` phase column. Scaling the row down with `FittedBox` is not a substitute for that rule.

Hole-card choice bands (`_HoleCardBands` in `select_identify_activity.dart`)
fill the lesson stage height and scale the felt and choice rails together so
a short phone never overflows.

Densified teach felts that ask for ~58% of screen height
(`kTeachFeltHeightFactor` in `teach_felt_height.dart`) clamp to the stage
when Nice! / Continue shrinks it. `LessonScreenLayout` rewrites MediaQuery
height for every stage child, and `_feltShell` clamps again.

### Shipped

Button and blinds (LPT-36) stacks the flop cards and the showdown card backs vertically in `_buildBlindsTiming` (`lib/ui/course/widgets/lesson_table_context.dart`). The next phase column copies that vertical stack.

Guided suits (`act-01-01-02-guided-suits` via `LessonSuitBoardTable` in
`select_identify_activity.dart`) owns progressive suit picks locally and
only syncs selection when the draft is already `suits-full`. The next
multi-press board picker that rebuilds from `LessonActivityController`
copies that gate so SoftPulse/Hint notifyListeners cannot clear cyan.

Bootstrap / start-error coach copy is `kLessonBootstrapSpeech` /
`lessonStartErrorSpeech` (`lesson_screen_layout.dart`), passed from
`LessonRunnerScreen` while the stage shows the spinner or Retry (LPT-48,
LPT-51). Locked starts pass the previous lesson title so the bubble names
Open `<title>`; Retry-only errors keep `kLessonStartErrorSpeech`. The next
pending lesson frame copies that helper instead of `speech: ''`.

Multi-press explain SoftPulse with no hint text
(`LessonActivityController.showTargetCue` / `_canReopenSequentialCueViaHint`,
LPT-49) keeps gold on the next seat after each correct tap — Hint stays
disabled while that cue is on. The next explain SoftPulse sequence without
a hint fallback copies that gate instead of closing the wave forever.

Hand ranks showdown-order Hint is `showdownOrderHintSpeech`
(`lesson_card_deal.dart`), wired from `lessonFrameHintFallback` (LPT-54).
Role ids stay the strength tiers; after seat-role shuffle the Hint names the
physical You / Sam / Jo seat that holds each role. The next showdown-order
step that shuffles seats copies that helper instead of raw
`accessibilityText`.

Best five explain SoftPulse (`LessonBestFiveExplainTable` in
`lesson_best_five.dart`, LPT-55) highlights only `_nextCode` from
`playOrder` — one gold ring on that hole or board card. It does not ring
every remaining playing hole together. Leftover dimming waits until those
five are tapped (LPT-56) so the ask does not grey out the answer. Best five
guided picker SoftPulse (`LessonBestFivePickerTable`, LPT-57) highlights
only the next untapped card in the recommended `choiceSets` list the same
way — never every remaining recommended card, never the You name box.
Hint reopens that card cue when the SoftPulse wave closes. After Nice! or
Oops, that picker keeps SoftPulse off and dims cards outside the coach
five while cyan stays on the learner's picks (LPT-61) — it does not gold
every correct card at once. The next multi-press felt explain or picker
that cues cards copies that single-target advance, the no-early-dim rule,
and the no multi SoftPulse post-grade reveal.

Guided free misses (LPT-59) are `evaluateLifeAndAcceptance` in
`functions/src/course_session.ts`: `lifeLost` is false when `stage` is
`guided`. Scaffolded, unguided, checkpoint, and jump_test still spend.
Redeploy Cloud Functions after changing that helper. The next soft-grade
life rule copies that stage gate instead of charging every rejection.

Hint clears on grade (LPT-60) in `LessonActivityController.finishSubmit` /
`presentLocalMiss` (`_hintVisible = false`) and `showTargetCue` stays off
while `lastResult` is set. `LessonRunnerScreen._frameSpeech` also ignores
Hint when a result is present. The next graded coach beat copies that clear
instead of leaving Hint copy under the dock.

Best five picker picks (LPT-62) mirror into `ActivityDraft.orderedIds` whenever
the tap set is not yet a mapped choice (`LessonBestFivePickerTable` /
`BestFiveCardPicker` via `setOrderedIds`). `selectChoice` clears ordered ids
and `setOrderedIds` clears `choiceId`, so Undo/Redo restore one draft shape.
The next multi-tap felt picker that soft-rejects before grade copies that
draft mirror instead of keeping picks only in widget state.

Hint while SoftPulse is already on (LPT-63) is gated in
`LessonActivityController.canRequestHint`: any `showTargetCue` keeps Hint
disabled, including single-press scaffolded SoftPulse (kicker showdown). The
next SoftPulse teach beat copies that gate instead of only disabling Hint
when `sequentialPressesRemaining` is true.

The per-lesson state is the Lesson ledger at the end of this file.

File one ticket per layout you still see, not one ticket per activity id.

## Home

The Home tab is a Duolingo path.

- **Status strip.** `CourseStatusBar` (`lib/ui/home/course_status_bar.dart`):
  flame + streak, diamond + gems, heart + hearts, centered and spaced across
  the full row. JetBrains Mono numbers in each accent color. Tapping the
  hearts opens the refill sheet.
- **Unit banner.** One full-width, rounded, sticky banner reads
  `SECTION N, UNIT M` with the unit title, swaps as the path scrolls, and
  opens the section picker on tap. Color comes from
  `unitBannerColorForSection`.
- **Path.** One section at a time. Circular nodes on a zig-zag
  (`CoursePathView`). The next lesson pulses; the pulse ring starts at the
  node edge and expands evenly without shifting the layout. The pulse stays
  on the course frontier while reviews are due.
- **Start.** Tapping an unlocked node shows a speech bubble under it with
  START (or REVIEW) and the XP preview. Lessons launch only from that
  bubble. A locked node explains what to finish first.
- **Section picker.** `CourseSectionPickerSheet`
  (`lib/ui/home/course_section_picker.dart`): one card per section with a
  summary, a progress bar or JUMP HERE. Jump scrolls the path to that
  section.
- **Bottom navigation.** `ShellBottomNav`, illustrated icons
  `assets/brand/nav_home.svg`, `nav_live.svg`, `nav_profile.svg`.

Rex appears on Home only in non-ready message states (loading, error,
empty). He does not stand on the path.

### Hearts

Five hearts per user, shared across lessons (`kHomeDefaultHearts`). Guided
steps are free; any other miss costs one. Out of hearts blocks the lesson in
place. The refill sheet (`heart_refill_sheet.dart`) offers Practice (+1
heart on finishing a weak, already-played lesson) and a full refill for
gems. Hearts update in place on Home without blanking it. The sheet uses
Theme Manrope for titles and option copy and JetBrains Mono for the next-
heart countdown; it does not use Nunito.

## Profile

The Profile tab keeps Course and Live Training in separate blocks. Guest
copy offers **Create an account** as the Theme elevated button (radius 14)
and never claims a signed-in account exists.

The Course card shows lifetime XP, streak, accepted accuracy, mastery, and
the learner’s place as `SECTION N, UNIT M` plus the current unit title from
the catalog — the same place language as the Home unit banner. It does not
show an experience-band section title alone as the place line (for example
bare `Never Played` next to earned XP).

Live Training on the same screen stays about full-hand play: style, coaching
record, and the empty state that asks for more hands. Lesson mastery never
appears as live-hand style in the header.

### Shipped

`CourseProgress.coursePlaceEyebrow` / `coursePlaceTitle`
(`lib/models/course/course_progress.dart`) feed `_CourseProgressCard` on
`ProfileScreen`. The next surface that names the learner’s course place
copies that SECTION / UNIT + unit title pair.

## Gamified learning

Lessons teach like a game. The loop is
[Duolingo Chess](references/duolingo-chess/PATTERNS.md): one step, the
board as the hero, a mascot beat when the answer lands, then a payoff.
Frames are in `docs/ui/references/duolingo-chess/frames/`. Use the pattern.
Do not copy their palette, owl, or words.

| Beat | What the screen does | Frame |
| --- | --- | --- |
| Step | The lesson screen layout | `001.png` |
| Right | Rex celebrates, the dock says Nice! and one Continue | `002.png` |
| Wrong | Rex thinks, the dock says Oops, a heart empties, Continue stays on the step | `090.png` |
| Hint | Hint replaces the speech bubble until it is tapped again | `020.png` |
| Payoff | The lesson result: Rex celebrating, this lesson's XP, the daily goal, one CONTINUE | `117.png` |
| Home | The path, the next node marked, the start bubble | `125.png` |
| Section end | One ceremony: character, title, one button | `128.png` |

A right answer shows the same coach in a celebrating mood beside the short line. The calm drawing and the celebrating drawing are the same coach. The Asset inventory celebrate row uses that same coach.

A miss shows that coach thinking beside the short line. It does not
celebrate.

The lesson result uses `RexMascot` for the ceremony. It does not draw a
letter R. It shows this lesson’s XP and the daily goal before Home. Review
lessons award 25% of the XP earned.

The locked Live Training hub names the Home lesson that unlocks it. It does not say Section 2.

A learning screen that is a form, a wall of text, or a silent pop back to
Home misses this loop. File one ticket per missing beat.

### Shipped

`LessonFeedbackSheet` (`lib/ui/course/widgets/lesson_feedback_sheet.dart`)
uses `RexMascot` with `RexMood.celebrate` on a right answer and
`RexMood.think` on a miss. `LessonResultScreen`
(`lib/ui/screens/lesson_result_screen.dart`) draws `RexMascot` with
`RexMood.celebrate` and a TOTAL XP and daily goal row.

The locked Live Training hub copy is `liveTrainingLockedMessage`
(`lib/models/live_access.dart`), which names Baseline jump check via
`kLiveWarmUpUnlockLessonTitle`. The gate is the Home node
`lesson-02-07-02-section-two-jump`. The snackbar
`liveTrainingLockedSnack` uses the same title.

## Asset inventory

Slots are the only place a new animation, icon, sound, logo, or mascot is
introduced. Reuse the path already listed. Add a row when a new file ships.

| Slot | Current | Reuse |
| --- | --- | --- |
| Logo | `assets/brand/logo_mark.svg` — gold mark, transparent background, via `BrandLogo` | Welcome, Auth, Live Training hub. Rasterized to launcher / notification icons via `tools/brand/render_logo_assets.mjs` |
| Mascot | `assets/brand/mascot_idle.png` — full body, calm mood, via `RexMascot` | Welcome, Meet Rex, `RexCoachLine`, `RexCoachCard`; lesson coach band uses the same slot with `RexMascotCrop.upperBody` |
| Mascot celebrate | `assets/brand/mascot_celebrate.png` — the same coach, celebrating mood, the same coach as the calm drawing, via `RexMascot` | Right-answer beat, the coach band on accept, the lesson-result ceremony |
| Mascot rig | `mascot_body`, `mascot_arm_left`, `mascot_arm_right`, `mascot_mouth_happy` (`.svg` + `.png`), posed by `RexMascot` (`lib/ui/widgets/rex_mascot.dart`): calm blinks, celebrate raises an arm and opens the mouth, think folds both arms in front of the chest. `mascot_think`, `mascot_side`, `mascot_back` are drawn but not wired | Any new Rex motion or expression extends this rig. It does not add a second drawing of Rex |
| Navigation icons | `assets/brand/nav_home.svg`, `nav_live.svg`, `nav_profile.svg` | `ShellBottomNav` |
| Icons | Material / Cupertino otherwise. No other branded set | Theme icon color |
| Motion | Implicit widget motion (band resize, `AnimatedSwitcher` in the runner, pulses, shake, pot flight). No Rive or Lottie | [flutter-ui-ux](../../.cursor/skills/flutter-ui-ux/SKILL.md) durations |
| Sound effects | `SoundService`: `deal_01.wav`–`deal_08.wav`, `chip.wav`, `knock.wav`, `fold.wav`, `win.wav` under `assets/sounds/` | One deal hit per dealt card. Other table actions call chip / knock / fold / win. Do not add a second chip sound |
| Background music | `assets/sounds/lounge_ambient.wav` via `SoundService.startHomeBgm` from app launch. SoLoud loops it gaplessly; `integration_test/bgm_loop_test.dart` checks the restart | Pauses in background and in Live Training. Settings toggle is `musicEnabled` |

The mascot slot is the full-body coach with a mood. Text-only
`RexCoachLine` is not the slot.

The Live Training hub shows `assets/brand/logo_mark.svg` above the lock or the table entry.

A missing slot (Rex text-only, a deal with no motion, a table action with no
`SoundService` call) is a ticket that names the slot. The implementer adds
the file and fills the row.

## Known gaps

Stakeholder asks that are not shipped yet. These are the first places to
look for work. Verify on the mini before filing: the code may have moved
past this list.

- **Text quizzes inside lessons.** The Lesson ledger's "Still a list"
  column is every step that is still a text Q&A list. Each one is a
  teach-by-doing gap when the answer can live on the felt.
- **Older lesson layouts.** Steps still on `LessonActionSpot` or
  `LessonTableScene` instead of `LessonTableStage`.
- **Section end ceremony.** Finishing a section has no character, title,
  one-button ceremony (frame `128.png`).
- **Gems do nothing on tap.** The status strip shows the balance, but there
  is no shop or explanation. The plan is the gem economy rollout (wallet,
  more ways to earn, a Gem Shop, Streak Freeze).
- **Rex motion.** The rig has three poses. The ask is a scalable mascot
  with more expressions and short, smooth full-body movements on each beat
  (the side, back, and think drawings are not wired yet).
- **Live Training** has had far less polish than lessons and Home. Walk it
  against Theme and Poker table.
- **Lesson content regressions.** Steps that always deal the same cards,
  Hint that no-ops / stacks / stays enabled with nothing to show, multiple
  gold SoftPulse targets or a second cue style for hints, missing SoftPulse
  on a guided first press, coach copy that does not name the dealt cards,
  or hearts that do not empty on a paid miss / restore on Practice or
  refill. Verify on the mini (two attempts when checking randomization;
  screenshot heart counts around a miss) before filing.

## Lesson ledger

One row per lesson. "Explain taps" are the teach-by-doing targets under the
felt on the explain step. "Still a list" is what the record says remains a
text list. Update the row in the same change that moves a step onto the
felt.

| Lesson | Explain taps | Still a list |
| --- | --- | --- |
| Your two cards | Your hole cards on the felt | — |
| Suits and ranks | Suit taps on board cards, board ranks low to high, suited / pair seats | — |
| Button and blinds | Dealer button, SB, BB on the seats | — |
| Hand ranks | Showdown seats weakest to strongest | — |
| Best five and kickers | The five cards that play; You / Them / Board | — |
| Fold, check, call | Fold, Check, Call under a flop | — |
| Bet, raise, all-in | Bet, Raise, All-in under a flop | — |
| Streets and action order | Board advances by street; seat order on the table | — |
| How pots are won | Fold win, Showdown, Side pot | — |
| Play a full toy hand | Blinds, You act, Ending | — |
| Section 1 jump check | — | rank and seat order |
| Position labels | Six-max seats labeled on the table | — |
| Acting order | UTG, HJ, CO, BTN on the table | — |
| Hand families | Pairs, Broadways, Suited aces, Connectors | — |
| Open or fold baseline | Early, Button, Live 3x | — |
| Versus an open | Fold, Call, 3-bet | — |
| Effective stacks | Chips→BB, Shorter, Depth | — |
| Live table habits | Watch, Say, Cover, Wait | — |
| Full-ring baseline hand | Nine, Same, Position | — |
| Baseline jump check | — | stack check |
| Read the table first | Pot, Stacks, Button, Who Acts | — |
| Name your flop class | Made, Draw, SDV, Air | — |
| Count outs, pay the right price | Clean, Dirty, Price | clean aces (card picker) |
| Choose a flop line | Value, C-bet, Check, Call, Fold, Raise | — |
| Plan the turn card | Brick, Change, Barrel, Delay | — |
| Close the river correctly | Value, Bluff, Catch, Fold | — |
| Play tighter multiway | Stronger, Fewer, Nuts | — |
| Patch the common leaks | Top pair, Prices, Passive, Crowds | — |
| Section 3 jump check | — | table-read |
| Think in ranges | One hand, Range, Update | — |
| Navigate 3-bet pots | 3-bet, Ranges, Squeeze | — |
| Plan beyond the flop | Flop, Turn, River | — |
| Size with a message | Value, Pressure, Size | — |
| SPR decides commitment | SPR, Low, High | — |
| Observe sticky callers | Enters, Calls, Folds | participation note, observation bundle |
| Meet the Calling Station | Station, High, Low | label quizzes |
| Adjust versus Calling Station | Value, Bluffs, Cite | bluff-less reason |
| Observe narrow players | Rare, Enter, Mean It | entry quizzes |
| Meet the Nit | Nit, Narrow, Respect | label quizzes |
| Adjust versus Nit | Steal, Credit, Explode | respect reason |
| Observe wild aggressors | Raise, Barrel, Count | entry quizzes |
| Meet the Maniac | Maniac, Entry, Aggro | label quizzes |
| Adjust versus Maniac | Wider, Hang, Ego | call-wider reason |
| Confidence and samples | Observe, Samples, Showdowns | confidence quizzes |
| Same hand, different types | Cards, Seats, Evidence | — |
| Section 4 jump check | — | range, SPR, and player-type checks |
| Build multiway ranges with nut potential | Nutted, Air, Domination | continue and priority checks |
| Play 150–300bb stacks with a plan | Deep, Realize, Stack | implied, plan, and reward checks |
| Implied and reverse odds | Implied, Reverse, Second | rise check |
| Thin value and bluff-catches | Thin, Catch, Barrels | read check |
| Advanced flop lines | X/R, Probe, Delay, Donk | nit, donk, and delay checks |
| Street-by-street updates | Action, Rewrite, Update | capped, habit, and shove checks |
| Soft timing evidence | Timing, Sizing, Clues | timing quizzes |
| Live table dynamics | Stuck, Tilted, Gears | stuck, gear, and freshness checks |
| Keep cash session guardrails | Quit, Guard, First | discipline quizzes |
| Section 5 checkpoint | — | multiway, tell, and stop checks |
| Spot range advantage and nut advantage | Range, Nut, Advantage | dry-board, paired-board, and press checks |
| Realize equity in and out of position | Equity, Cash, Pos | realization quizzes |
| Recognize capped versus uncapped ranges | Capped, Uncapped, Nuts | check-turn, bomb, and attack checks |
| Choose polarized or merged betting | Polar, Merged, Size | overbet, mismatch, and aim checks |
| Use overbets and geometric pressure | Overbet, Polar, Geo | candidate, avoid, and plan checks |
| Use blockers without solver theater | Block, Use, No EV | unblock, tweak, and EV checks |
| Defend enough without frequency theater | Defend, Bluff, Enough | continue, intuition, and punish checks |
| Mix with a reason | Mix, Purpose, Strong | station, reason, and purpose checks |
| Navigate 3-bet and 4-bet pots by depth | 3-Bet, 4-Bet, Depth | commit, ego, and SPR checks |
| Make difficult folds; review coolers fairly | Hard, Cooler, Ego | cooler, ego, and review checks |
| Observe selective aggression | Tight, Barrel, Sample | entry quizzes |
| Meet the TAG | Tight, Aggro, Model | label quizzes |
| Adjust versus TAG | Credit, Tighter, No light | respect check |
| Observe wide sustained pressure | Wide, Pressure, Sample | entry quizzes |
| Meet the LAG | Wide, Pressure, Model | label quizzes |
| Adjust versus LAG | Call, Trap, Fancy less | avoid and cite checks |
| Same cards, five type models | Cards, seats, and evidence in the stage | label check |
| Section 6 checkpoint | — | advantage, cap, polar, TAG, and LAG checks |
| Carry a preflop plan onto the flop | Reason, Confirm, Cancel | plan quizzes |
| Map turn barrels before you bet flop | Barrel, Give-up, Map | no-plan and definition checks |
| Compose river value and bluffs | Value, Bluff, Hold | blocker, empty, and rule checks |
| Change plans by pot type | Limped, SRP, 3-4bet | pot-type quizzes |
| Switch gears between HU and multiway | Fewer, Thicker, Widen | player-count quizzes |
| Rewrite plans when stacks change | Short, Deep, Effective | depth quizzes |
| Replay the same hand versus each type | Cards, Models, Cite | no-evidence check |
| Integrate type, board, line, and sizing | Type, Board, Line, Size | integration check |
| Write your default strategy book | Leak, Book, Review | book quizzes |
| Capstone: single-raised pot | Plan, Update, Finish | — |
| Capstone: 3-bet pot | SPR, Turn, Close | — |
| Capstone: multiway deep | Nuts, Deep, No-bluff | — |
| Capstone: limped pot | Nuts, Value, Thin | — |
| Capstone: 4-bet pot | SPR, Commit, No Hero | — |
| Prep a coached Live warm-up hand | Checklist, Defaults, One hand | warm-up quizzes |
| Final: all five player types | — | station, nit, maniac, TAG, LAG, certainty, and retire checks |
