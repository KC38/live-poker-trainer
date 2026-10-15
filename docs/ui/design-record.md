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
| Lesson result | `lib/ui/screens/lesson_result_screen.dart` | Finish a lesson. Lesson Complete CONTINUE never leaves an anonymous guest with course progress on Welcome — embedded completion (`openlesson` / Home) promotes the draft to shell so CONTINUE lands on Home (LPT-70). |
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
  with the seat so markers stay tight and consistent for 2–9 players. When the
  table accepts seat taps, D / SB / BB pucks forward taps to that seat
  (`FeltTableView`, LPT-67). SoftPulse for button/blinds presses rings the D /
  SB / BB puck on that lane (`cuePuckLabel`), not the seat name box — puck taps
  and gold cue share the same target (LPT-69). Other action badges (FOLD,
  CALL, RAISE, …) hang from the bottom of the box.
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
Street bets (including blinds) stay off the felt until hole cards have
landed; then blinds post, and each raise/call/fold lands in act order —
never while the deal is still running (Live Training + lesson felts).
Framed open-pot math (`kOpenPotActivityId` / `act-01-05-01-unguided-pot`)
does not redeal or replay post-deal actions when Nice! / Oops! locks the
dock (LPT-642).

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

Empty board slot outlines stay **off for every lesson** (LPT-80):
`TableFeatures` defaults `boardSlots` false, and `forLesson` /
`forLessonId` keep them false for every `lesson-SS-UU-LL` id. Only dealt
community cards draw. Live Training and an id that is not
`lesson-SS-UU-LL` get `TableFeatures.full`, which keeps empty street
placeholders (`boardSlots: true`). Your start uses the preset of the
lesson it recommends. Per-step builders may still pass
`boardSlots: false` explicitly; they must not turn empty slots back on.

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
`PokerTableBands` draws it for Your start. Button / blinds SoftPulse uses
`FeltTableView.cuePuckLabel` so gold rings the D / SB / BB puck (LPT-69),
including Button and blinds frame steps via `lessonPuckLabelForHighlight`;
the next puck-named SoftPulse copies that instead of `cueSeatIndex` on the
seat pod.

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

Your two cards region-tap steps that deal a three-card flop
(`act-01-01-01-*` on `LessonTableStage` in `select_identify_activity.dart`)
also keep `boardSlots: false` so undelt turn/river outlines do not draw
(LPT-66).

Button and blinds' explain step (`LessonBlindsClockwiseTable`) draws seats,
pot, pucks, posted blinds, and hole-card backs with empty board slot
outlines off (`boardSlots: false`) until a later step deals community cards.
Button and blinds hole-only frame steps (`act-01-01-03-guided-button` and
siblings that share `isLessonBlindsFrameActivity` without a dealt board)
pass the same `boardSlots: false` gate on their `LessonTableStage` (LPT-52).

Fold, check, call framed action steps (`PokerActionSizingActivity` →
`LessonTableStage` for `act-01-03-01-*` and the other framed action ids)
pass `boardSlots: false` so preflop spots draw no empty community slots and
flop spots show the dealt flop without empty turn/river outlines (LPT-77).

Lesson stages inherit `boardSlots: false` from `TableFeatures.forLessonId`
(LPT-80), so Streets explain/order and every other short board do not draw
empty later-street outlines without a per-builder opt-in.

### Cues

`GlowHighlight` (`lib/ui/widgets/glow_highlight.dart`) is the one cue. There
are no arrows. Guide cues and Hint-reopened cues use the same gold SoftPulse
ring — never a second cue language for hints.

| Ring | Meaning |
| --- | --- |
| Gold (`GlowKind.cue`) | SoftPulse: the coach's **one** current target. Breathes |
| Cyan (`GlowKind.selection`) | What the learner tapped. Stays on under Nice! and the miss dock — every graded felt or tile answer, including `LessonHoleHandTable` seat taps and framed hero/villain/board region taps on `LessonTableStage` (same contract as `selectedSeatIndexes` / densified `LessonTableContext` selection; LPT-641) |

SoftPulse rules:

- It appears only after the dealt cards have landed.
- At most one gold SoftPulse target at a time. It marks the first press of
  a multi-press step, then stays off unless Hint reopens SoftPulse for the
  **next** press only.
- Hint is disabled while gold SoftPulse is already on for this press.
- Review lessons hide cues by default. SoftPulse-quiet review is decided
  from live profile `completedLessonIds` at lesson start — not a stale
  Home `hasCompleted` node after the id was cleared (LPT-828).
- The ring's outset is reserved in layout, so toggling it never moves or
  resizes a tile.
- Board-group SoftPulse (`highlightBoardGroup` on `CommunityCardsView`)
  sizes to the dealt community cards only. Empty turn/river columns stay
  outside the glow when `boardSlots` is on, and are omitted when
  `boardSlots` is off — a three-card flop cue never rings phantom street
  width (LPT-68).
- Button / blinds SoftPulse (`cuePuckLabel` on `FeltTableView` via
  `LessonBlindsClockwiseTable`) rings the D, then SB, then BB puck — not the
  seat name box — so the gold cue matches the chip the coach names (LPT-69).
  Position labels SoftPulse (`act-02-01-01-*` on `LessonTableStage`) prefers
  the same D / SB / BB puck via `cuePuckLabel`, with seat-ring fallback only
  when that puck is not posted yet (LPT-118).
- Agent `tree` / `wait-gold` report gold SoftPulse for hero hole SoftPulse
  too: seat Semantics (`Your hole cards`) sits above face-down
  `GlowHighlight` backs, so `agentGlowOf` walks descendants as well as
  ancestors (LPT-840). Board SoftPulse still reports via Text labels inside
  the ring.

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
is the stage. Agent `tree` gold SoftPulse walks `GlowHighlight` descendants
under seat Semantics so hero hole SoftPulse is visible to `wait-gold`
(`agent_screen_tree.dart`, LPT-840). `LessonPeekTable` turns `boardSlots`
off so the first Your two cards step has no empty board outlines. Framed `act-01-01-01-*`
`LessonTableStage` copies the same gate for three-card flop teach steps
(LPT-66). Board-group SoftPulse on `CommunityCardsView` wraps only the
dealt flop/turn/river cards so empty street width stays outside the gold
ring (LPT-68). `LessonBlindsClockwiseTable`
turns `boardSlots` off the same way for Button and blinds explain, and
SoftPulses the D → SB → BB puck via `cuePuckLabel` (LPT-69). Position
labels framed steps in `select_identify_activity.dart` (`act-02-01-01-*`)
pass the same `cuePuckLabel` + seat fallback on `LessonTableStage`
(LPT-118). Blinds frame steps in `select_identify_activity.dart`
(`isLessonBlindsFrameActivity`) pass `boardSlots: false` on
`LessonTableStage` the same way (LPT-52). Lesson `boardSlots` stay off via the shared `TableFeatures` default / `forLesson` gate (LPT-80) so every unit inherits no empty community outlines. Pending
frames pass `showToolRow: false` so Undo / Redo / Hint stay off until an
activity binds (LPT-53).
`LessonCoachBand` maps `LessonMascotExpression` to calm, celebrate, or
think. `LessonChoiceButton` (`lib/ui/course/widgets/rex_coach_line.dart`)
is the one framed option button. `lessonFrameCanHint` is the shared Hint
content gate for the tools row and sequential SoftPulse reopen — scaffolded
non-assessment steps (Best five checkpoint-build) stay Hint-enabled until
gold SoftPulse is on (LPT-643). Pairs and suited guided densify
(`act-01-01-02-03-guided-suited`) stays on `supportsHoleHandSeatDeal` /
`LessonHoleHandTable` so the mini never bottom-overflows a Them/You felt
plus text docks (LPT-815 / LPT-816). Lesson start SoftPulse-quiet review
uses live `getCourseState` `completedLessonIds` (`lessonIsSoftPulseQuietReview`)
so `agent_seed.py fresh --open` cannot SoftPulse-quiet a guided teach from
a stale Home node (LPT-828).

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

Stages are only **guided** (SoftPulse teach, free misses) and **scaffolded**
(Hint unlocks SoftPulse, paid misses). Checkpoints and jump tests are
scaffolded with `assessmentRole` and **no Hint**. Authored deal/hint/cue
fields live in `teachSpec` (see course schemas). Audited by
`/lesson-content-agent`. Your two cards is the pilot. These lessons author
`teachSpec` on every interactive step the same way, with deal classes that
match what `lesson_card_deal.dart` deals (`deal.mode` `none` when the step
deals no cards): Suits and ranks (LPT-81), Button and blinds (LPT-85), Hand
ranks (LPT-88), Best five and kickers (LPT-91), Fold, check, call (LPT-94),
Bet, raise, all-in (LPT-98), Streets and action order (LPT-101), How pots
are won (LPT-104), Play a full toy hand (LPT-108), Section 1 jump check
(LPT-110), Position labels (LPT-112), Acting order (LPT-115), Hand families
(LPT-119), Open or fold baseline (LPT-122), Versus an open (LPT-125),
Effective stacks (LPT-128), Live table habits (LPT-131), Full-ring baseline
hand (LPT-135), Baseline jump check (LPT-137), Read the table first
(LPT-138), Name your flop class (LPT-141), Count outs, pay the right price
(LPT-144), Choose a flop line (LPT-149), Plan the turn card (LPT-152), Close
the river correctly (LPT-155), Play tighter multiway (LPT-158), Patch the
common leaks (LPT-161), Section 3 jump check (LPT-165), Think in ranges
(LPT-167), Navigate 3-bet pots (LPT-170), Plan beyond the flop (LPT-174),
Size with a message (LPT-177), SPR decides commitment (LPT-180), Observe
sticky callers (LPT-184), Meet the Calling Station (LPT-187), Adjust versus
Calling Station (LPT-190), Observe narrow players (LPT-193), Meet the Nit
(LPT-196), Adjust versus Nit (LPT-200), Observe wild aggressors (LPT-203),
Meet the Maniac (LPT-206), Adjust versus Maniac (LPT-210), Confidence and
samples (LPT-213), Same hand, different types (LPT-216), Section 4 jump
check (LPT-219), Build multiway ranges (LPT-222), Play 150–300bb stacks
(LPT-225), Implied and reverse odds (LPT-228), Thin value and bluff-catches
(LPT-231), Street-by-street updates (LPT-237), Advanced flop lines
(LPT-234), Live table dynamics (LPT-245), Keep cash session guardrails
(LPT-248), Section 5 checkpoint (LPT-251), Choose polarized or merged
betting (LPT-262), Use overbets and geometric pressure (LPT-265), Use
blockers without solver theater (LPT-268), Navigate 3-bet and 4-bet pots by
depth (LPT-280), Make difficult folds; review coolers fairly (LPT-283),
Observe selective aggression (LPT-286), Meet the TAG (LPT-289), Adjust
versus TAG (LPT-292), Meet the LAG (LPT-298), Same cards, five type models
(LPT-304), Section 6 checkpoint (LPT-307), Carry a preflop plan onto the
flop (LPT-308), Change plans by pot type (LPT-318), Switch gears between HU
and multiway (LPT-321), Rewrite plans when stacks change (LPT-324), Replay
the same hand versus each type (LPT-328), Integrate type, board, line, and
sizing (LPT-331), Capstone: single-raised pot (LPT-337), Capstone: 3-bet pot
(LPT-339), Capstone: multiway deep (LPT-341), Capstone: limped pot
(LPT-345), Capstone: 4-bet pot (LPT-347), Prep a coached Live warm-up hand
(LPT-349), Final: all five player types (LPT-352), Soft timing evidence
(LPT-242), Spot range advantage and nut advantage (LPT-252), Realize equity
in and out of position (LPT-255), Recognize capped versus uncapped ranges
(LPT-258), Defend enough without frequency theater (LPT-271), Mix with a
reason (LPT-275), Observe wide sustained pressure (LPT-295), Adjust versus
LAG (LPT-301), Map turn barrels before you bet flop (LPT-312), Compose river
value and bluffs (LPT-315), Write your default strategy book (LPT-334).

Lesson steps teach with the cards and coach on screen, not with static
demo text. `/ui-design-agent` checks these on every lesson walk:

| Check | Contract |
| --- | --- |
| Randomization | Cards are randomized within the hand class each attempt. A second open of the same lesson should not always deal the identical hole/board when the activity supports a class of hands. |
| Coach follows the deal | Speech, grade lines, **action-dock choice labels that name a starting hand**, and chip math name the cards, seats, and amounts on the felt for this attempt — not a previous deal or a hard-coded template combo. `poker_action_sizing` docks run choice labels through `alignLessonActionChoices` so **Always steal K9o** becomes **Always steal J7o** (or the dealt chart hand) when isomorphic remap leaves K9o (LPT-455). Hand ranks showdown-order Hint copy is built from the dealt seat→hand-class map for this attempt (including after seat-role shuffle), not the static catalog line that assumes You / Sam / Jo keep the authored classes (LPT-54). Hand families classify Hint copy is rewritten from the isomorphic-remapped hero holes for this attempt (including unguided suited-connector and checkpoint trash), not the static catalog accessibility line that assumes authored 76s / 72o (LPT-134). Open or fold baseline UTG trash Oops / Nice grade lines rewrite English decade-compound hand names (`Seventy-two` → dealt spoken form) through `alignStartingHandCopy`, so feedback always names the isomorphic holes on the felt (LPT-164). Versus an open AQs checkpoint (and other strong suited-broadway templates) remaps only inside `strongSuitedBroadway` (Ace+broadway suited or KQs), not into weaker suited broadway like QTs (LPT-173). Navigate 3-bet pots unguided AKo (and other strong offsuit-broadway templates) remaps only inside `strongOffsuitBroadway` (Ace+broadway offsuit or KQo), not into weaker offsuit broadway like JTo / KJo (LPT-406). Baseline jump check select_identify densified asks (`jump-family`, `jump-stack`) flow through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` / `_lessonFrameLine` so the frame bubble matches the felt-first `_coachText` — never catalog quiz copy plus "Tap the best answer." (LPT-221). Name your flop class densified asks rewrite catalog board/hole card tokens and spoken rank/suit words in frame speech, Hint, and grade feedback through `alignLessonActionCopy` / `alignLessonTableCopy` so the bubble matches `dealtLessonTableScene` (LPT-261). `alignLessonTableCopy` protects English count phrases (`Your two cards`, `the two in front`) so a template board deuce remapped to another rank cannot turn Hint into "Your three cards" (LPT-791). Your two cards densified coach lines are stem-only — never hardcode template Ah Kd / Qs Jh 2c over remapped holes or board (LPT-792). Count outs densified asks (`act-03-03-01-guided` / scaffolded / unguided / checkpoint) route through the same `selectIdentifyDensifiedCoachLine` → frame speech path — never catalog quiz copy plus "Tap the best answer." (LPT-279). Count outs unguided framed `LessonTableStage` posts pot 20 + villain bet 10 so the felt matches Rex’s call-into-30 ask — never the blinds-only POT $10 default (LPT-274). Count outs checkpoint framed stage uses 200bb stacks ($400 at $1/$2) with a pot-sized sticky bet on the felt (LPT-278). Choose a flop line (and other postflop action spots) isomorphic-remap holes with a teach fingerprint beyond bare `HandClass` so TPTK templates stay top-pair-top-kicker and dual-broadway air stays two broadway holes — never Ace-weak-kicker under a TPTK bubble or Q9o under “offsuit broadway” (LPT-311). Plan the turn scaffolded Hint / felt-first coach names top pair on a brick without claiming TPTK when isomorphic remap deals a non-nut kicker such as AT/AJ (LPT-327). Close the river correctly checkpoint (`act-03-06-01-checkpoint`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-343). Close the river checkpoint framed `LessonTableStage` posts pot + villain river bet so the felt matches Rex’s big-bet ask — never blinds-only POT $10 (LPT-344). Play tighter multiway scaffolded (`act-03-07-01-scaffolded`) deals true air on the wet flop (no board-suit hole, no pair) and isomorphic remap keeps a made-pair teach bit so Rex’s “missed” ask never sits over a remapped pocket pair; framed `lessonFrameSpeech` uses the felt-first pick-verb line — never catalog “You missed entirely…” (LPT-367). Section 3 jump multiway (`act-03-08-02-jump-mw`) deals the same true-air template and remap contract so Rex’s air ask never sits over a remapped flush draw or pair (LPT-391). Section 3 jump river (`act-03-08-02-jump-river`) isomorphic remap keeps `isSet` / `distinctBoardPairingHoles` teach bits so a top-two ask never sits over a remapped set — `HandClass.strongMade` alone collapses two pair and set (LPT-392). Play tighter multiway unguided / checkpoint (`act-03-07-01-unguided`, `act-03-07-01-checkpoint`) route through the same `selectIdentifyDensifiedCoachLine` → frame speech path — never catalog quiz copy plus "Tap the best answer." (LPT-368). Patch the common leaks scaffolded (`act-03-08-01-scaffolded`) deals a true gutshot (`Jh 9d` on `Ks Tc 2d`, four outs to Q) and isomorphic remap keeps `drawOuts` / weak-draw teach bits so Rex’s gutshot / four-outs ask never sits over air (LPT-381). Patch the common leaks checkpoint (`act-03-08-01-checkpoint`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-382). Think in ranges densified asks (`act-04-01-01-guided` / scaffolded / unguided / checkpoint) route through the same helper (LPT-403). Plan beyond the flop checkpoint densified ask (`act-04-03-01-checkpoint`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-407). Size with a message unguided densified ask (`act-04-04-01-unguided`) routes through the same helper — never catalog quiz copy plus "Tap the best answer." (LPT-410). SPR decides commitment guided densified ask (`act-04-05-01-guided`) routes through the same helper — never catalog quiz copy plus "Tap the best answer." (LPT-412). Observe sticky callers densified asks (`act-04-06-01-guided` / scaffolded / unguided / checkpoint) route through the same helper — never catalog quiz copy plus "Tap the best answer." (LPT-416). Section 3 jump check gutshot price (`act-03-08-02-jump-leak`) deals the same true gutshot (`Jh 9d` on `Ks Tc 2d`) and its table-scene remap takes the postflop teach-fingerprint path (not run-gap rank shifts) so it keeps four outs, so the fold-price ask never sits over air (LPT-389). |
| Hint (one at a time) | Hint swaps the speech bubble to **one** hint for the current press until tapped again. Never stack hint + idle prompt, or two hint bubbles. Disabled whenever gold SoftPulse (`showTargetCue`) is already on for this press — including single-press scaffolded SoftPulse (Best five kicker showdown), not only multi-press sequential waves (LPT-63). Guided SoftPulse teach keeps Hint off while gold is on (04-course); scaffolded non-assessment SoftPulse stays off until Hint so the Hint dock stays enabled — Best five `act-01-02-02-checkpoint-build` is the lock (`lessonFrameCanHint`, LPT-643). `assessmentRole` checkpoint / jump_test / transfer still hide Hint (Capstone hands are `transfer`, LPT-348). Button and blinds scaffolded SoftPulse paints only after Hint — `showTargetCue` must stay off until then so Hint stays enabled; stage-alone scaffolded unlock left Hint disabled with no gold (LPT-73). While the felt deal is still settling (`feltDealReady` false), Hint stays **enabled** even after a Hint tap so SoftPulse can land when hero holes arrive — never a Hint-disabled / SoftPulse-none deadlock mid-deal (Open strong scaffolded LPT-678). Visible but **disabled** when there is no hint — including a multi-press / multi-turn step after the last press that had a hint. Grading a step (Nice! or Oops) clears Hint so the speech bubble is never the Hint line under the answer dock; SoftPulse from that Hint press ends with the grade (LPT-60). After that clear, graded speech is the short feedback line — not a fall-back to the idle ask (LPT-64). Oops Continue (`clearFeedbackForRetry`) clears Hint-used and SoftPulse wave state for the remounted deal so same-concept quiet steps can Hint-reopen SoftPulse again (LPT-71). On quiet same-concept multi-suit boards (`LessonSuitBoardTable`), sequential remaining-press progress counts untapped real suits even while SoftPulse is off, so Hint can reopen SoftPulse for each next suit (LPT-72). Suits explain Hint shows one per-press suit tip (e.g. Find a heart on the board.), never the all-four-suits completion accessibility line (LPT-813). |
| Cues (one system, one gold) | `GlowHighlight` only: gold SoftPulse for the guide/Hint target, cyan for the learner's picks. Hint-reopened SoftPulse looks the same as the guide cue. At most one gold target at a time; after that press is taken, gold stays off until Hint reopens the next — except on multi-press explain SoftPulse sequences with no hint text (button → SB → BB, best-five `playOrder`), where gold SoftPulse advances to the next required card/seat and Hint stays disabled while that gold cue is on. SoftPulse prefers the D / SB / BB puck when that puck is on the felt (LPT-69), including Position labels guided / Hint SoftPulse on `LessonTableStage` via `cuePuckLabel` (LPT-118); when the cued puck is not posted yet (scaffolded blinds hide BB until a correct tap), SoftPulse falls back to the BB seat ring so Hint still shows one gold target (LPT-73). SoftPulse / Hint rings unlock when the **hero** holes and board have landed — not after every villain hole-back in a six-max deal — so premium-pair asks SoftPulse as soon as both hero cards are up (Open strong LPT-678 / LPT-679). Best five explain SoftPulse marks only the next card in `playOrder` — never every remaining playing hole at once (LPT-55). Best five guided/scaffolded picker SoftPulse (`LessonBestFivePickerTable`) marks only the next untapped card in the recommended `choiceSets` list — one gold ring at a time — matching explain `playOrder` SoftPulse; Hint reopens that same card cue (LPT-57). Best five picker post-grade (Nice! / Oops) does not SoftPulse every correct card; cyan keeps the learner's picks and leftovers dim so the coach five reads without multi-target gold (LPT-61). Best five explain does not dim leftover hole/board cards until the five that play are tapped; SoftPulse and cyan selection are the only pre-answer emphasis (LPT-56). Best five kicker showdown SoftPulse marks the You seat once (`cueSeatIndex: 0`) — never both hole cards together via `LessonTableCue.hero` (LPT-75). Densified `LessonTableScene` outcome tiles (`_TappableRegion`) SoftPulse through `GlowHighlight` — never a second local pulse overlay — and correct-answer `_PotChipDot` chips stay slate until that SoftPulse (Effective stacks BB-convert / effective-stack; LPT-183). Review lessons hide cues by default. SoftPulse-quiet review is decided from **live** profile `completedLessonIds` at lesson start — never a stale Home `hasCompleted` node after `agent_seed.py fresh` (or any external clear) removed the id (LPT-828). No `CueArrows` / `CuePulse`. |
| Coach mood | Calm on the ask, celebrate on Nice!, think on Oops. When a step is graded, the coach bubble shows the short feedback line (same `result.feedback` as the dock body), never the idle ask or Hint copy (LPT-64; Hint clear on grade remains LPT-60). Hand ranks explain Nice! feedback is the short ladder line ("High card, then pair, then flush."), not the idle tap ask — `gradeCourseResponse` prefers authored `explainGrading.feedback` from the private bank when present (LPT-74). Best five explain Nice! uses "Exactly five cards — leave the extras out." the same way (LPT-76). Streets explain Nice! uses "Preflop → flop → turn → river." (LPT-79). Acting order explain Nice! uses "UTG → HJ → CO → BTN." (LPT-147). Live table habits explain Nice! uses "Watch → Say → Cover → Wait." (LPT-199). Observe wild aggressors explain Nice! uses "Raise → Barrel → Count." (LPT-463). Meet the Maniac explain Nice! uses "Maniac → Entry → Aggro." (LPT-490). Never an empty bubble after the deal, never a letter-R coach. While the lesson is bootstrapping (or recovering from a load error), the coach bubble shows one calm line such as getting the next step ready — never an empty bubble beside Rex. On a locked start, the bubble names Open `<previous lesson>` when that CTA is shown; otherwise Retry (LPT-51). |
| Hearts | A non-guided miss empties one heart in place. Guided free misses do not — `evaluateLifeAndAcceptance` sets `lifeLost` only when the stage is not `guided` (scaffolded, unguided, checkpoint, jump_test still spend; LPT-59). At zero, empty hearts breathe and the refill sheet opens from the hearts control. Practice / gem refill restores hearts in place (no toast, no rejected out-of-hearts dock). |
| Identify / naming docks | Action-name quizzes (`identifyUnavailable` on `LessonActionSpot`) keep every dock button looking live until the learner taps — no `CALL (off)` / `RAISE (off)` spoilers. Fold, check, call `checkpoint-legal` and Bet, raise, all-in `checkpoint-names` both set that flag (LPT-78). Capstone authored multi-step hands (`act-07-10-0*-hand`) set the same flag so Jam/Raise mistakes stay live on checked-to streets — never `RAISE (off)` beside a Bet/C-bet choice (LPT-670). Live realism `(off)` chrome stays on guided / scaffolded / short-stack spots that are not identify quizzes or Capstone transfer hands. |
| Toy-hand authored pot | Authored multi-step toy-hand spots apply labeled `potLabel` and completed call/open street bets on `LessonTableStage` even when `facingBet` is false — BB-calls-your-open shows Pot 13 with matched raise/call chips; flop c-bet keeps Pot 13 (not blinds-only $3 or the $10 street default) (LPT-97). Preflop folds-to-you "Pot 3" does not apply a zero street-bet list — SB/BB chips stay posted in front of those seats. |
| Section 1 jump ranks | `act-01-06-02-jump-ranks` orders three face-up showdown seats strongest→weakest (Flush → Straight → Two pair) via `LessonShowdownOrderTable` — not under-felt Flush/Straight/Two pair text chips on `LessonMadeHandTable` (LPT-107). |
| Showdown-order strict seats | Interactive showdown-order SoftPulse asks (`RandomizedLessonShowdownOrderTable` for Compare finished hands unguided / checkpoint, Section 1 jump ranks, and the same framed path) use `strictOrder: true` — a wrong seat is a miss via `onLocalMiss`, never appended as cyan order #1 while SoftPulse marks another seat. Matches `LessonShowdownOrderExplainTable` (LPT-707). |
| Acting order checkpoint flop | `act-02-01-02-checkpoint-full` deals a three-card flop (`Qs 7c 2d`) on framed `LessonTableStage` so street chrome is FLOP when the ask names a flop — not blinds-only PREFLOP (LPT-148; same board as scaffolded-post). |
| Effective stacks SoftPulse | BB-convert and effective-stack outcome tiles keep correct-answer `_PotChipDot` chips slate (no permanent gold tip). SoftPulse on densified `_TappableRegion` phases uses `GlowHighlight` so guided / Hint waves report gold SoftPulse in the agent tree (LPT-183). Effective-stack outcome panels (`effectiveStackOutcomes`, `effectiveStack150Outcomes`, `stackDepthOutcomes`) set `villainSeatCount: 0` so the felt never paints a decoy face-down Them seat (LPT-220). |
| Catalog permanent-gold tips | Densified outcome chips and correct-answer icons across the catalog stay slate/cream (`_PotChipDot(gold: false)`, Icon `AppColors.slate`) — including Call 10 / Villain bet, SPR 4, HI/LO participation, Sticky handshake, Narrow entry, Pot·effective, Take pot, habit / player-type / ranges tiles. SoftPulse `GlowHighlight` is the only gold teach signal (LPT-633). |
| Full-ring / `9-max` action spots | Spots whose street label names `9-max` (Full-ring baseline hand guided open, scaffolded vs-open, hand lab, and section jump opens) resolve nine seats on `LessonTableStage` via `resolveLessonActionFeltLayout` — not the six-max default — so coach "Nine-handed" / "Full ring" matches the felt (LPT-209). Read the table first scaffolded (`act-03-01-01-scaffolded`) paints a nine-handed numbered felt (button seat 7, `lessonNineMaxVillainCount`) so "Nine-handed… seat 7" matches the stage — not six-max EP/HJ/CO labels (LPT-240). Densify / no-frame path uses `blindsSeats` with `numberSeats: true` the same way. |
| Read the table outcome panels | Pot / verbal / table-read densified outcome scenes (`potMultiwayOutcomes`, `verbalBindingOutcomes`, `tableReadMattersOutcomes`) set `villainSeatCount: 0` so no decoy Them holes appear above the choice tiles (LPT-241; same contract as LPT-220). |
| Final five-type outcome panels | Final: all five player types densified outcome scenes (`fiveTypeCsOutcomes` … `fiveTypeRetireOutcomes`, `act-07-12-01-*`) set `villainSeatCount: 0` so the felt never paints a decoy face-down Them seat above Station / Nit / Maniac / TAG / LAG / certainty / retire tiles (LPT-671; same contract as LPT-220 / LPT-241). |
| Final five-type densified coach | Final: all five player types densified coach lines (`act-07-12-01-cs` / `nit` / `maniac` / `tag` / `lag` / `uncertain` / `retire`) use a non-spoiling stem (situation + tap verb, no correct exploit/tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` assessment checkpoints (LPT-672; SoftPulse-off intentional per LPT-653). |
| Section 4 jump densified coach | Section 4 jump densified coach lines (`act-04-10-02-jump-range` / `jump-spr` / `jump-station` / `jump-nit` / `jump-maniac`) use a non-spoiling stem (situation + tap verb, no correct tile/value/exploit label) while SoftPulse stays off for `teachSpec.cues.kind: none` jump_test asks (LPT-673; SoftPulse-off intentional per LPT-653; same class as LPT-672). |
| Section 3 jump densified coach | Section 3 jump densified coach lines (`act-03-08-02-jump-table` / `jump-leak`) use a non-spoiling stem (situation + tap verb, no correct tile label such as Pot · effective or Fold) while SoftPulse stays off for `teachSpec.cues.kind: none` jump_test asks; `jump-class` already stem-only (LPT-674; SoftPulse-off intentional per LPT-653; same class as LPT-672 / LPT-673). |
| Section 2 jump densified coach | Section 2 jump densified coach line (`act-02-07-02-jump-pos`) uses a non-spoiling stem (situation + pick/tap verb, no correct seat label such as Cutoff) while SoftPulse stays off for `teachSpec.cues.kind: none` jump_test asks; other Section 2 jump densify stems (`jump-family` / `jump-open` / `jump-vs` / `jump-stack`) already stem-only (LPT-675; SoftPulse-off intentional per LPT-653; same class as LPT-672 / LPT-673 / LPT-674). |
| Count outs framed pot / depth | `act-03-03-01-unguided` framed `LessonTableStage` posts `potTotal: 20` with villain street bet 10 (LPT-274). `act-03-03-01-checkpoint` uses 200bb (`heroStackChips` / `villainStackChips` 400 at $1/$2) plus the same pot-sized sticky bet money (LPT-278). |
| Close the river framed big bet | `act-03-06-01-checkpoint` framed `LessonTableStage` posts `potTotal: 40` with villain street bet 40 (BET) so the felt matches Rex’s big-bet ask — never blinds-only POT $10 (LPT-344). |
| Play tighter multiway missed air | `act-03-07-01-scaffolded` templates `7s 3d` on `Ah Kh 9h` (true air) and postflop remap rejects made pairs under draw-class HandClass so the missed ask matches the felt; guided/scaffolded frame speech is felt-first with a pick verb (LPT-367). |
| Play tighter multiway densified ask | Play tighter multiway unguided / checkpoint (`act-03-07-01-unguided`, `act-03-07-01-checkpoint`) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-368). |
| Patch the common leaks gutshot | `act-03-08-01-scaffolded` templates `Jh 9d` on `Ks Tc 2d` (true four-out gutshot to Q) and isomorphic remap keeps `drawOuts` / weak-draw teach bits so Rex’s gutshot / four-outs ask never sits over air (LPT-381; JT on A72 was zero outs). |
| Flop class air feedback | `act-03-02-01-unguided` (`5h 4h` on `Qc 7d 2s`, zero straight outs) grades `air` with “Five-high with no pair and no real draw is give-up territory multiway.” and never calls it gutshot-ish (LPT-414). |
| Deep-stack seat chrome | Action spots that name a depth paint it: `act-05-02-01-scaffolded` 250bb → `Stacks left 500`, `act-05-03-01-guided` 200bb → `Stacks left 400`, `act-06-09-01-scaffolded` 180bb → `Stacks left 360`, `act-04-10-01-checkpoint` lab 200bb → `Stacks left 400` (at $1/$2), so seat stacks match the claim instead of the default $200 / 100bb. The “Short stack” / “All-in, Call, or Fold” dock copy now keys on `isShortStack` (under 100bb) instead of any `stackLabel` (LPT-417). |
| Remap keeps set depth | Postflop teach fingerprint adds `setDepth`, the board-relative depth of the set rank, so top-set templates (`9h 9d` on `9s 8c 7h`) never remap into middle or bottom sets, and the middle “set of sevens” (`7h 7d` on `7c Kd 2s`) stays the sevens (LPT-411). |
| Remap keeps pair depth | Postflop teach fingerprint (`_postflopTeachKey`) adds `pairDepth`, the board-relative rank depth of hero's non-set board pair, so second-pair templates (`Jh 9d` on `Qc 9s 3h 2d 7c`, `7h 9d` on `Kc 7s 2d`) remap only into second pair, never third / fourth pair under the same `weakPair` (LPT-409). |
| Remap keeps nut flush draws | Postflop teach fingerprint adds `nutFlushDraw` (hero holds the best missing card of the four-flush suit before the river), and the flop-class scaffolded scene (`Ah 9h` on `Jh 8h 3c`, SoftPulse `nfd`) joins `_drawOutsLessonTableScenes`, so nut flush draw templates never remap into K-high / Q-high draws, and non-nut draws never become nut (LPT-408). Capstone multiway-deep `AhQh` uses suit-only toy-hand remaps, which already keep the Ace. |
| Close the river missed flush | `act-03-06-01-scaffolded` templates `9s 8s` on `Ks 7s 2h 3h Ah`: a flopped spade flush draw that bricks while the `3h` / `Ah` runout completes hearts, so “You missed a flush draw… River completes the flush” and the `bluff` (represent the flush) match the felt; LPT-155 `fixedCards` move with it (LPT-402; `Kh 7h 2c 3d Ah` never gave 98ss a draw). |
| Patch the common leaks weak top pair | `act-03-08-01-guided` (`Ah 4d` on `As 9c 7d`) reads “Flop · Weak top pair · Heat”: the 4 kicker loses to the unpaired 9 and 7, so this is TPWK, matching the catalog prompt, not “Weak TPTK” (LPT-401). |
| Capstone 3-bet flop texture | `act-07-10-02-hand` step-3b-flop deals `Ah Qd` on `Qs 8h 3d`, three suits, so streetLabel, catalog prompt, wave helper, and Rex line all say **Q83r** (rainbow), matching the capstone 4-bet `Q83r` flop; per-attempt suit permutation keeps it rainbow (LPT-405; was labelled Q83tt). |
| Type board line second pair | `act-07-08-01-guided` templates `Jh Td` on `Kh Ts 8h 2d`: true second pair (the T sits under the K) on a wet two-tone turn with no hero draw, so “Turn · second pair · wet” and the `call` bluff-catch versus the Maniac overbet match the felt; remaps keep `weakPair`, and pair depth is LPT-409 (LPT-396; `Ts 9h 8c 2d` was top pair plus an open-ender). |
| Turn map gutshot brick | `act-07-02-01-scaffolded` templates `Jh 9d` on `Ks Tc 2d 3s`: a true four-out gutshot to Q (as LPT-381) whose turn 3s bricked, under the “Gutshot · brick · raise” caption and the `give` map call; the scene joins `_drawOutsLessonTableScenes`, so remaps take the teach-fingerprint path and keep `DrawOuts.weak` / weak-draw (LPT-394; 98hh on K723 had zero outs). |
| Minimum defense third pair | `act-06-07-01-scaffolded` templates `9h 7d` on `Kc Qh 9d 4c 8s`: third pair (the 9 is the third-highest board rank) on a scary river that completes JT, with no hero blockers, so “River · third pair” and the `fold` default match the felt; remaps keep a non-top pair (`weakPair`), and pair depth is LPT-409 (LPT-397; `Kc Qh Jd 2c Ts` made 9-7 a straight, and `Kc Qh 9d 2c Ts` would be fourth pair). |
| Polar or merged second pair | `act-06-04-01-scaffolded` templates `Jh Td` on `Qc Ts 3h 2d 7c` (second pair) so “River · second pair” and the merged `mid` thin-value size match the felt after remap (LPT-395; `Qc 9s 3h 2d 7c` was air). |
| Implied odds gutshot + overs | `act-05-03-01-guided` templates `Jh 9d` on `8s 7c 2d`: four straight outs to a ten plus two overcards, so “Flop · gutshot + overs · 200bb” and `call-io` match the felt after remap (LPT-393; `Kc 7s 2h` had zero outs and no overs; teach key pins `overcardCount`). |
| Deep-stack light top pair | `act-05-02-01-scaffolded` templates `Ad 9c` on `As Th 7h`: top pair with a kicker below the ten (TPWK) on a two-heart wet flop, no hero heart and no straight draw, so “Flop · top pair weak · 250bb” and `fold-tp` match the felt after remap (LPT-404; `Ah 9d` on `As 8h 7h` was TPTK). |
| Adjust versus Calling Station missed draw | `act-04-06-03-scaffolded` templates `8h 7h` on `Kh 9h 2c 3d 5s`: a flop flush draw that bricks on the turn and river, so “River · missed draw” and the `give-up` versus the sticky seat match the felt after remap (LPT-399; `Kc 2s 2d 9c 3d` never had a draw). |
| Size with a message missed draw | `act-04-04-01-scaffolded` templates `9h 8h` on `Kh 7h 2c 3d As`: a flop flush draw that bricks, with a river scare Ace that does not complete hearts, so “River · scare Ace · missed draw” and the polar `big` pressure size match the felt after remap. Turn/river postflop remaps also match hero's earlier-street class + draw outs (`_postflopTeachKey.earlierStreets`), so a river missed draw really flopped one instead of any river air (LPT-398; `Kd 7c 2s 3d Ah` never had a draw). |
| Plan beyond the flop four-heart turn | `act-04-03-01-scaffolded` templates `Qd 9c` on `Kh 7h 2h 3h` so the “Turn · four hearts · air” label and flush-card abort match the felt: four board hearts, no hero heart, hero air after remap (LPT-400; `Kh 7h 2c 3h` was only three hearts). |
| Section 3 jump gutshot price | `act-03-08-02-jump-leak` templates `Jh 9d` on `Ks Tc 2d` (true four-out gutshot to Q, matching LPT-381) under the gutshot · pot 10 · bet 20 caption; `dealtLessonTableScene` remaps keep `DrawOuts.weak` / weak-draw so `j3-foldprice` never grades over air (LPT-389; JT on A72 was zero outs). |
| Patch the common leaks densified ask | Patch the common leaks checkpoint (`act-03-08-01-checkpoint`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-382). |
| Section 3 jump multiway air | `act-03-08-02-jump-mw` templates `7s 3d` on `Ah Kh 9h` (true air) and postflop remap keeps made-pair / board-suit teach bits so Rex’s air / fold-crowd ask never sits over a remapped flush draw or pair (LPT-391; same contract as LPT-367). Catalog `teachSpec.deal.fixedCards` and the wave helper author the same `7s 3d` / `Ah Kh 9h` (LPT-425). |
| Section 3 jump river top two | `act-03-08-02-jump-river` templates `Ah Kd` on `As Kc 7d 2h 3c` (top two) and isomorphic remap keeps `isSet` / `distinctBoardPairingHoles` teach bits so Rex’s “top two” / “Two pair value bets.” never sits over a remapped set (LPT-392; `HandClass.strongMade` alone collapses two pair and set). |
| Section 3 jump densified asks | Section 3 jump check densified asks (`act-03-08-02-jump-table` / `jump-class` / `jump-leak`) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-390). Think in ranges densified asks (`act-04-01-01-guided` / scaffolded / unguided / checkpoint) route through the same helper — never catalog quiz copy plus "Tap the best answer." (LPT-403). |
| Think in ranges densified asks | Think in ranges densified asks (`act-04-01-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-403). |
| Plan beyond the flop densified ask | Plan beyond the flop checkpoint densified ask (`act-04-03-01-checkpoint`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-407). |
| Size with a message densified ask | Size with a message unguided densified ask (`act-04-04-01-unguided`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-410). |
| SPR decides commitment densified ask | SPR decides commitment guided densified ask (`act-04-05-01-guided`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-412). |
| Estimate SPR checkpoint densified ask | Estimate SPR checkpoint densified ask (`act-04-05-01-checkpoint`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — SoftPulse-off densify stem with a tap verb, never the poker-action dock footer "below the table" and never naming Weigh SPR first (LPT-812; SoftPulse LPT-653). |
| Suits SoftPulse-off densify stems | Suits SoftPulse-quiet / SoftPulse-off densify asks (`act-01-01-02-guided-suits` idle, `act-01-01-02-01-scaffolded-suits`, `act-01-01-02-01-checkpoint-suits`) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — tap-verb stem only, never naming Hearts/diamonds/clubs/spades (LPT-814; SoftPulse LPT-653). |
| SPR decides commitment scaffolded stacks | SPR decides commitment scaffolded (`act-04-05-01-scaffolded`) framed stage posts remaining stacks that match Rex’s SPR ~1 ask (`Stacks left 60` into pot ~60; same shared-stack contract as checkpoint `Stacks left 55` for SPR ~1.4) (LPT-413). |
| SPR decides commitment unguided stacks | SPR decides commitment unguided (`act-04-05-01-unguided`) framed stage posts `Stacks left 240` into pot 12 so the felt matches Rex’s SPR 20 ask — never the default $200 stacks (SPR ~17) (LPT-415). |
| Observe sticky callers densified asks | Observe sticky callers densified asks (`act-04-06-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-416). Unguided SoftPulse-quiet densify stem is situation + tap verb only — never name Low conf / Low confidence while SoftPulse stays off until Hint (LPT-822; SoftPulse LPT-653; same class as LPT-821 / LPT-818 / LPT-811). Scaffolded SoftPulse-quiet densify stem is situation + tap verb only — never name Sticky while SoftPulse stays off until Hint (LPT-824; SoftPulse LPT-653; same class as LPT-823 / LPT-822). |
| Meet the Calling Station densified asks | Meet the Calling Station densified asks (`act-04-06-02-guided` / `act-04-06-02-scaffolded` / `act-04-06-02-unguided` / `act-04-06-02-checkpoint`) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-420). Scaffolded SoftPulse-quiet densify stem is situation + tap verb only — never name Working model while SoftPulse stays off until Hint (LPT-817; SoftPulse LPT-653). Unguided SoftPulse-quiet densify stem is situation + tap verb only — never name Station (or Maniac) while SoftPulse stays off until Hint (LPT-818; SoftPulse LPT-653). |
| Recognize capped densified asks | Recognize capped versus uncapped densified asks (`act-06-03-01-guided` / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-636). |
| Choose polarized densified asks | Choose polarized or merged betting densified asks (`act-06-04-01-guided` / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-637). |
| Use overbets densified asks | Use overbets and geometric pressure densified asks (`act-06-05-01-guided` / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-638). |
| Use blockers densified asks | Use blockers without solver theater densified asks (`act-06-06-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-639). |
| Defend enough densified asks | Defend enough without frequency theater densified asks (`act-06-07-01-guided` / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-640). |
| Mix with a reason densified asks | Mix with a reason densified asks (`act-06-08-01-scaffolded` / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-644). |
| Navigate 3-bet densified asks | Navigate 3-bet and 4-bet pots by depth densified asks (`act-06-09-01-guided` / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-645). |
| Make difficult folds densified asks | Make difficult folds densified asks (`act-06-10-01-scaffolded` / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-646). |
| Observe selective densified asks | Observe selective aggression densified asks (`act-06-11-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-647). |
| Meet the TAG densified asks | Meet the TAG densified asks (`act-06-11-02-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-648). |
| Observe wide densified asks | Observe wide sustained pressure densified asks (`act-06-12-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-649). |
| Meet the LAG densified asks | Meet the LAG densified asks (`act-06-12-02-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-650). |
| Adjust versus LAG densified asks | Adjust versus LAG densified asks (`act-06-12-03-unguided` / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-651). |
| Adjust versus TAG densified asks | Adjust versus TAG densified checkpoint (`act-06-11-03-checkpoint`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-652). |
| Same cards densified asks | Same cards, five type models densified checkpoint (`act-06-13-01-checkpoint`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-654). |
| Prefer nut potential multiway checkpoint densified coach | Prefer nut potential multiway checkpoint densified coach (`act-05-01-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Nut potential / clean equity tile labels) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-723; SoftPulse-off intentional per LPT-653; same class as LPT-717 / LPT-672). |
| Plan streets at high SPR checkpoint densified coach | Plan streets at high SPR checkpoint densified coach (`act-05-02-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Position / implied odds / disciplined folds tile labels) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-735; SoftPulse-off intentional per LPT-653; same class as LPT-723 / LPT-717 / LPT-672). |
| Estimate implied odds checkpoint densified coach | Estimate implied odds checkpoint densified coach (`act-05-03-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Deep stacks / opponents who pay / Depth + pay tile labels) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-734; SoftPulse-off intentional per LPT-653; same class as LPT-735 / LPT-723 / LPT-717 / LPT-672). |
| Thin value versus sticky callers checkpoint densified coach | Thin value versus sticky callers checkpoint densified coach (`act-05-04-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no The line / authored read tile labels) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-736; SoftPulse-off intentional per LPT-653; same class as LPT-734 / LPT-735 / LPT-723 / LPT-717 / LPT-672). |
| Probes and delayed c-bets checkpoint densified coach | Probes and delayed c-bets checkpoint densified coach (`act-05-05-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no After flop check / range strength / After weakness tile labels) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-742; SoftPulse-off intentional per LPT-653; same class as LPT-736 / LPT-734 / LPT-735 / LPT-723 / LPT-717 / LPT-672). |
| Soft timing evidence checkpoint densified coach | Soft timing evidence checkpoint densified coach (`act-05-07-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Tiny update / stronger reads tile labels) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-744; SoftPulse-off intentional per LPT-653; same class as LPT-742 / LPT-736 / LPT-734 / LPT-735 / LPT-723 / LPT-717 / LPT-672). |
| Capped versus uncapped lines checkpoint densified coach | Capped versus uncapped lines checkpoint densified coach (`act-05-06-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Uncapped / respect unless type tile labels) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-745; SoftPulse-off intentional per LPT-653; same class as LPT-744 / LPT-742 / LPT-736 / LPT-734 / LPT-735 / LPT-723 / LPT-717 / LPT-672). |
| Gear changes mid-session checkpoint densified coach | Gear changes mid-session checkpoint densified coach (`act-05-08-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Fresh samples tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-746; SoftPulse-off intentional per LPT-653; same class as LPT-745 / LPT-744 / LPT-742 / LPT-736 / LPT-734 / LPT-735 / LPT-723 / LPT-717 / LPT-672). |
| Gear changes mid-session scaffolded densified coach | Gear changes mid-session scaffolded SoftPulse-quiet densify (`act-05-08-01-scaffolded`) uses a non-spoiling stem (situation + tap verb, no Gear change / Old label) while SoftPulse stays off until Hint (LPT-825; SoftPulse LPT-653; same class as LPT-823 / LPT-824 / LPT-822). |
| End sessions early checkpoint densified coach | End sessions early checkpoint densified coach (`act-05-09-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Your edge tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-747; SoftPulse-off intentional per LPT-653; same class as LPT-746 / LPT-745 / LPT-744 / LPT-742 / LPT-736 / LPT-734 / LPT-735 / LPT-723 / LPT-717 / LPT-672). |
| Tag strong aggression checkpoint densified coach | Tag strong aggression checkpoint densified coach (`act-04-07-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Few hands / heavy action tile labels) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-763; SoftPulse-off intentional per LPT-653; same class as LPT-746 / LPT-747 / LPT-672). |
| The Nit model checkpoint densified coach | The Nit model checkpoint densified coach (`act-04-07-02-checkpoint`) uses a non-spoiling stem (situation + tap verb, no A working model with sample limits tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-765; SoftPulse-off intentional per LPT-653; same class as LPT-764 / LPT-763 / LPT-746 / LPT-672). |
| Respect their heavy action checkpoint densified coach | Respect their heavy action checkpoint densified coach (`act-04-07-03-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Range is strong when they raise tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-778; SoftPulse-off intentional per LPT-653; same class as LPT-777 / LPT-765 / LPT-770 / LPT-771 / LPT-672). |
| Tag constant aggression checkpoint densified coach | Tag constant aggression checkpoint densified coach (`act-04-08-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Enters constantly; barrels without mercy tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-770; SoftPulse-off intentional per LPT-653; same class as LPT-765 / LPT-764 / LPT-763 / LPT-746 / LPT-672). |
| Confidence grows with samples checkpoint densified coach | Confidence grows with samples checkpoint densified coach (`act-04-09-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Sample and confidence limits tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-777; SoftPulse-off intentional per LPT-653; same class as LPT-778 / LPT-765 / LPT-770 / LPT-771 / LPT-672). |
| Confidence grows with samples scaffolded densified coach | Confidence grows with samples scaffolded SoftPulse-quiet densify (`act-04-09-01-scaffolded`) uses a non-spoiling stem (situation + tap verb, no Rise / Stay zero) while SoftPulse stays off until Hint (LPT-823; SoftPulse LPT-653; same class as LPT-822 / LPT-821 / LPT-818). |
| Bluff less without equity checkpoint densified coach | Bluff less without equity checkpoint densified coach (`act-04-06-03-checkpoint`) uses a non-spoiling stem (situation + tap verb, no They fold too rarely tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-780; SoftPulse-off intentional per LPT-653; same class as LPT-777 / LPT-778 / LPT-765 / LPT-672). |
| Cite the aggression read checkpoint densified coach | Cite the aggression read checkpoint densified coach (`act-04-08-03-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Their betting range is too wide tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-781; SoftPulse-off intentional per LPT-653; same class as LPT-780 / LPT-777 / LPT-778 / LPT-765 / LPT-672). |
| Main and side pots checkpoint densified coach | Main and side pots checkpoint densified coach (`act-01-05-01-checkpoint-side`) uses a non-spoiling stem (situation + tap verb, no Side pot tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-782; SoftPulse-off intentional per LPT-653; same class as LPT-781 / LPT-780 / LPT-672). |
| Later seats play better checkpoint densified coach | Later seats play better checkpoint densified coach (`act-02-01-01-checkpoint-edge`) uses a non-spoiling stem (situation + tap verb, no On the button tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-783; SoftPulse-off intentional per LPT-653; same class as LPT-782 / LPT-781 / LPT-672). |
| Connectors versus trash checkpoint densified coach | Connectors versus trash checkpoint densified coach (`act-02-02-01-checkpoint-trash`) uses a non-spoiling stem (situation + tap verb, no Offsuit trash tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-784; SoftPulse-off intentional per LPT-653; same class as LPT-783 / LPT-782 / LPT-672). |
| Broadways scaffolded SoftPulse-quiet densify | Broadways and suited aces scaffolded SoftPulse-quiet densify (`act-02-02-01-scaffolded-broadway`) uses a non-spoiling stem (situation + tap verb, no Broadway) while SoftPulse stays off until Hint (LPT-841; SoftPulse LPT-653; same class as LPT-839 / LPT-838 / LPT-833). |
| Connectors unguided SoftPulse-quiet densify | Connectors versus trash unguided SoftPulse-quiet densify (`act-02-02-01-unguided-sc`) uses a non-spoiling stem (situation + tap verb, no Suited connector) while SoftPulse stays off until Hint (LPT-842; SoftPulse LPT-653; same class as LPT-841 / LPT-839 / LPT-838). |
| Say your action SoftPulse-quiet densify | Say your action scaffolded SoftPulse-quiet densify (`act-02-06-01-scaffolded-verbal`) uses a non-spoiling stem (situation + tap verb, no Say "raise" tile label) while SoftPulse stays off until Hint (LPT-843; SoftPulse LPT-653; same class as LPT-842 / LPT-841 / LPT-839). |
| Protect cards SoftPulse-quiet densify | Protect cards SoftPulse-quiet densify (`act-02-06-01-unguided-protect`) uses a non-spoiling stem (situation + tap verb, no Keep a chip / Chip on cards tile label) while SoftPulse stays off until Hint (LPT-844; SoftPulse LPT-653; same class as LPT-843 / LPT-842 / LPT-841). |
| Button and action SoftPulse-quiet densify | Button and action SoftPulse-quiet densify (`act-03-01-01-scaffolded`) uses a non-spoiling stem (situation + tap verb, no UTG / Seat left of the big blind) while SoftPulse stays off until Hint (LPT-845; SoftPulse LPT-653; same class as LPT-844 / LPT-843 / LPT-842). |
| Words are binding SoftPulse-quiet densify | Words are binding SoftPulse-quiet densify (`act-03-01-01-unguided`) uses a non-spoiling stem (situation + tap verb, no Raise stands / verbal is binding) while SoftPulse stays off until Hint (LPT-846; SoftPulse LPT-653; same class as LPT-845 / LPT-844 / LPT-843). |
| Draws versus showdown SoftPulse-quiet densify | Draws versus showdown value scaffolded SoftPulse-quiet densify (`act-03-02-01-scaffolded`) uses a non-spoiling stem (board + holes + tap verb; no Strong draw / nut flush draw) while SoftPulse stays off until Hint; card tokens stay alignLessonTableCopy-ready (LPT-847; SoftPulse LPT-653; same class as LPT-846 / LPT-845 / LPT-844). |
| Chips to big blinds checkpoint densified coach | Chips to big blinds checkpoint densified coach (`act-02-05-01-checkpoint-200`) uses a non-spoiling stem (situation + tap verb, no 200bb tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-785; SoftPulse-off intentional per LPT-653; same class as LPT-784 / LPT-783 / LPT-782 / LPT-672). |
| Protect cards wait checkpoint densified coach | Protect cards, wait your turn checkpoint densified coach (`act-02-06-01-checkpoint-oot`) uses a non-spoiling stem (situation + tap verb, no You acted out of turn tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-786; SoftPulse-off intentional per LPT-653; same class as LPT-785 / LPT-784 / LPT-672). |
| Pot and stacks checkpoint densified coach | Pot and stacks checkpoint densified coach (`act-03-01-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Effective 55bb / the 18 pot tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-787; SoftPulse-off intentional per LPT-653; same class as LPT-785 / LPT-786 / LPT-672). |
| Keep live habits checkpoint densified coach | Keep live habits while deciding checkpoint densified coach (`act-02-07-01-checkpoint-habit`) uses a non-spoiling stem (situation + tap verb, no Cover your cards and wait your turn tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-788; SoftPulse-off intentional per LPT-653; same class as LPT-786 / LPT-787 / LPT-672). |
| Postflop / pairs / draws SoftPulse-off densify | Postflop order checkpoint (`act-02-01-02-checkpoint-full`), Pairs and suited checkpoint (`act-01-01-02-checkpoint-pair`), and Draws versus showdown checkpoint (`act-03-02-01-checkpoint`) densified coaches use non-spoiling stems (situation + tap verb; no BTN / Pocket pair / Draw tile labels; draws stem omits template board/holes) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-803 / LPT-804 / LPT-805; SoftPulse-off intentional per LPT-653; same class as LPT-788 / LPT-672). |
| Pairs and suited guided densify seat-deal | Pairs and suited guided densify (`act-01-01-02-03-guided-suited`) uses `supportsHoleHandSeatDeal` / `LessonHoleHandTable` like unguided — never a Them/You felt plus Suited/Offsuit/Pocket pair text docks that overflow the mini; SoftPulse golds the suited seat; densify stem is situation + tap verb only (no Suited tile spoil) (LPT-815 / LPT-816). |
| Action order checkpoint SoftPulse-off densify | Action order checkpoint densified coach (`act-01-04-01-checkpoint-postflop`) uses a non-spoiling stem (situation + tap verb, no SB seat label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-808; SoftPulse-off intentional per LPT-653; same class as LPT-807 / LPT-803 / LPT-672). |
| Blinds unit SoftPulse-quiet / SoftPulse-off densify | Dealer button guided SoftPulse-quiet densify (`act-01-01-03-guided-button`) uses a non-spoiling stem (situation + tap verb, no D-chip choice title) while SoftPulse stays off until Hint (LPT-836; SoftPulse LPT-653; same class as LPT-835 / LPT-833 / LPT-834). Small and big blinds scaffolded SoftPulse-quiet densify (`act-01-01-03-scaffolded-blinds`) uses a non-spoiling stem (situation + tap verb, no BB choice label) while SoftPulse stays off until Hint (LPT-830; SoftPulse LPT-653; same class as LPT-823 / LPT-808). Checkpoint SoftPulse-off densify (`act-01-01-03-checkpoint-layout`) uses a non-spoiling stem (no SB seat geometry) while SoftPulse stays off for `kind: none` (LPT-831). Blinds post first unguided SoftPulse-quiet densify (`act-01-01-03-unguided-when`) uses a non-spoiling stem (no before-deal choice) while SoftPulse stays off until Hint (LPT-832). Blind labels scaffolded SoftPulse-quiet densify (`act-02-01-01-scaffolded-blinds`) uses a non-spoiling stem (situation + tap verb, no SB or BB) while SoftPulse stays off until Hint (LPT-833; SoftPulse LPT-653; same class as LPT-830 / LPT-832). Seat labels unguided SoftPulse-quiet densify (`act-02-01-01-unguided-co`) uses a non-spoiling stem (situation + tap verb, no Cutoff / CO) while SoftPulse stays off until Hint (LPT-834; SoftPulse LPT-653; same class as LPT-833 / LPT-675). |
| Tag low folding checkpoint SoftPulse-off densify | Tag low folding checkpoint densified coach (`act-04-06-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Bundle tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-810; SoftPulse-off intentional per LPT-653; same class as LPT-809 / LPT-811 / LPT-808 / LPT-672). |
| Station confidence checkpoint SoftPulse-off densify | Station confidence checkpoint densified coach (`act-04-06-02-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Low conf tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-811; SoftPulse-off intentional per LPT-653; same class as LPT-810 / LPT-809 / LPT-808 / LPT-672). |
| Attack capped ranges checkpoint SoftPulse-off densify | Attack capped ranges checkpoint densified coach (`act-06-03-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Attack tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-809; SoftPulse-off intentional per LPT-653; same class as LPT-810 / LPT-811 / LPT-808 / LPT-672). |
| The Maniac model checkpoint densified coach | The Maniac model checkpoint densified coach (`act-04-08-02-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Calling Station, Nit, and Maniac tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-771; SoftPulse-off intentional per LPT-653; same class as LPT-770 / LPT-765 / LPT-764 / LPT-746 / LPT-672). |
| Pressure when you own both checkpoint densified coach | Pressure when you own both checkpoint densified coach (`act-06-01-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Apply pressure tile label) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-764; SoftPulse-off intentional per LPT-653; same class as LPT-763 / LPT-746 / LPT-672). |
| Position realizes equity checkpoint densified coach | Position realizes equity checkpoint densified coach (`act-06-02-01-checkpoint`) uses a non-spoiling stem (situation + tap verb, no Position + initiative tile labels) while SoftPulse stays off for `teachSpec.cues.kind: none` (LPT-766; SoftPulse-off intentional per LPT-653; same class as LPT-764 / LPT-763 / LPT-746 / LPT-672). |
| Prefer nut potential / Section 5 outcome panels | Prefer nut potential multiway densified continue/priority panels (`multiwayContinueOutcomes` / `multiwayPriorityOutcomes`, `act-05-01-01-guided` / `checkpoint`) and other Section 5 conceptual `*Outcomes` scenes (`act-05-02` … `act-05-09` densify asks) set `villainSeatCount: 0` so the felt never paints a decoy face-down Them seat above the choice tiles (LPT-722; same contract as LPT-220 / LPT-241 / LPT-671). |
| Section 6 checkpoint densified asks | Section 6 checkpoint densified asks (`act-06-13-02-cp-adv` / `cp-cap` / `cp-polar` / `cp-tag` / `cp-lag`) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-655). |
| Carry a preflop plan densified asks | Carry a preflop plan onto the flop densified asks (`act-07-01-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-656). |
| Map turn barrels densified asks | Map turn barrels before you bet flop densified asks (`act-07-02-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-657). |
| Compose river densified asks | Compose river value and bluffs densified asks (`act-07-03-01-scaffolded` / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-658). Guided is `poker_action_sizing`. |
| Change plans by pot type densified asks | Change plans by pot type densified asks (`act-07-04-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-659). |
| Switch gears HU vs multiway densified asks | Switch gears between HU and multiway densified asks (`act-07-05-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-660). |
| Rewrite plans when stacks densified asks | Rewrite plans when stacks change densified asks (`act-07-06-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-661). |
| Replay same hand vs each type densified asks | Replay the same hand versus each type densified checkpoint (`act-07-07-01-checkpoint`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-664). |
| Integrate type board line densified asks | Integrate type, board, line, and sizing densified checkpoint (`act-07-08-01-checkpoint`) routes through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-665). |
| Write your default strategy book densified asks | Write your default strategy book densified asks (`act-07-09-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-662). |
| Prep a coached Live warm-up densified asks | Prep a coached Live warm-up hand densified asks (`act-07-11-01-guided` / scaffolded / unguided / checkpoint) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-663). |
| Densified asks still say Tap the best answer (catalog) densified ask | Densified asks still say Tap the best answer (catalog) densified ask () route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-628). |
| Densified asks still say Tap the best answer (catalog) densified asks | Densified asks still say Tap the best answer (catalog) densified asks (`act-01-01-01-guided-find-holes` / `act-01-01-01-scaffolded-private` / `act-01-01-01-unguided-mix` / `act-01-01-01-checkpoint-table` / `act-01-01-02-guided-suits` / `act-01-01-02-unguided-suited` / `act-01-01-02-checkpoint-pair` / `act-01-01-03-guided-button` / `act-01-01-03-scaffolded-blinds` / `act-01-01-03-unguided-when` / `act-01-02-02-guided-seven` / `act-01-02-02-checkpoint-build` / `act-01-04-01-unguided-end` / `act-01-04-01-checkpoint-postflop` / `act-01-05-01-guided-fold-win` / `act-01-05-01-scaffolded-showdown` / `act-01-05-01-checkpoint-side` / `act-02-01-01-guided-btn` / `act-02-01-01-scaffolded-blinds` / `act-02-01-01-unguided-co` / `act-02-01-01-checkpoint-edge` / `act-02-01-02-unguided-wait` / `act-02-01-02-checkpoint-full` / `act-02-02-01-guided-pair` / `act-02-02-01-scaffolded-broadway` / `act-02-02-01-unguided-sc` / `act-02-02-01-checkpoint-trash` / `act-02-05-01-guided-convert` / `act-02-05-01-scaffolded-eff` / `act-02-05-01-unguided-depth` / `act-02-05-01-checkpoint-200` / `act-02-06-01-guided-follow` / `act-02-06-01-scaffolded-verbal` / `act-02-06-01-unguided-protect` / `act-02-06-01-checkpoint-oot` / `act-02-07-01-checkpoint-habit` / `act-02-07-02-jump-pos` / `act-03-01-01-guided` / `act-03-01-01-scaffolded` / `act-03-01-01-unguided` / `act-03-01-01-checkpoint` / `act-03-02-01-guided` / `act-03-02-01-scaffolded` / `act-03-02-01-unguided` / `act-03-02-01-checkpoint` / `act-03-05-01-guided` / `act-03-05-01-checkpoint` / `act-04-06-03-checkpoint` / `act-04-07-01-guided` / `act-04-07-01-scaffolded` / `act-04-07-01-unguided` / `act-04-07-01-checkpoint` / `act-04-07-02-checkpoint` / `act-04-07-03-checkpoint` / `act-04-08-01-guided` / `act-04-08-01-scaffolded` / `act-04-08-01-unguided` / `act-04-08-01-checkpoint` / `act-04-08-02-checkpoint` / `act-04-08-03-checkpoint` / `act-04-09-01-guided` / `act-04-09-01-scaffolded` / `act-04-09-01-checkpoint` / `act-04-10-02-jump-range` / `act-04-10-02-jump-spr` / `act-05-01-01-guided` / `act-05-01-01-checkpoint` / `act-05-02-01-guided` / `act-05-02-01-unguided` / `act-05-02-01-checkpoint` / `act-05-03-01-checkpoint` / `act-05-04-01-checkpoint` / `act-05-05-01-guided` / `act-05-05-01-unguided` / `act-05-05-01-checkpoint` / `act-05-06-01-guided` / `act-05-06-01-unguided` / `act-05-06-01-checkpoint` / `act-05-07-01-guided` / `act-05-07-01-scaffolded` / `act-05-07-01-unguided` / `act-05-07-01-checkpoint` / `act-05-08-01-guided` / `act-05-08-01-scaffolded` / `act-05-08-01-checkpoint` / `act-05-09-01-guided` / `act-05-09-01-scaffolded` / `act-05-09-01-unguided` / `act-05-09-01-checkpoint` / `act-05-09-02-cp-multi` / `act-05-09-02-cp-tell` / `act-05-09-02-cp-stop` / `act-06-01-01-guided` / `act-06-01-01-scaffolded` / `act-06-01-01-checkpoint` / `act-06-02-01-guided` / `act-06-02-01-scaffolded` / `act-06-02-01-unguided` / `act-06-02-01-checkpoint` / `act-07-12-01-uncertain` / `act-07-12-01-retire`) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-628). |
| Densified asks still say Tap the best answer (catalog) remaining densified asks | Densified asks still say Tap the best answer (catalog) remaining densified asks (`act-01-01-03-checkpoint-layout` / `act-01-02-02-scaffolded-kicker` / `act-01-02-02-unguided-board` / `act-01-05-01-unguided-pot` / `act-04-07-02-guided` / `act-04-07-02-unguided` / `act-04-08-02-guided` / `act-04-08-02-unguided` / `act-04-09-01-unguided` / `act-04-10-02-jump-station` / `act-04-10-02-jump-nit` / `act-04-10-02-jump-maniac` / `act-07-12-01-cs` / `act-07-12-01-nit` / `act-07-12-01-maniac` / `act-07-12-01-tag` / `act-07-12-01-lag`) route through `selectIdentifyDensifiedCoachLine` into `lessonFrameSpeech` — never catalog quiz copy plus "Tap the best answer." (LPT-628). |
| Range-nut ADVANTAGE SoftPulse | Wave-three TAG/LAG early-name contract uses word-boundary token match so SoftPulse target `ADVANTAGE` on `act-06-01-01-explain` is not a false `TAG` leak (LPT-666). |
| Meet Calling Station SoftPulse one gold | Meet Calling Station scaffolded / unguided outcome SoftPulse passes `guideRegion` (`labelWorkingModel` / `playerTypeStationLimp`) so Hint paints one gold tile — never both Working model and Permanent, or Station and Maniac (LPT-424). |
| Observe narrow SoftPulse one gold | Observe narrow players densified asks (`act-04-07-01-guided` / scaffolded / unguided / checkpoint) pass `guideRegion` (`observeNarrowEntry` / `observeStrongAggression` / `observeWaitSamples` / `observeNitBundle`) so SoftPulse paints one gold tile — never both Narrow and Wide, Strong heat and Passive, Wait and Label now, or Few+heat and Calls all (LPT-433). |
| Meet the Nit SoftPulse one gold | Meet the Nit densified asks (`act-04-07-02-guided` / unguided / checkpoint) pass `guideRegion` (`meetNitLabel` / `meetNitLabel2` / `meetNitWorkingModel`) so SoftPulse paints one gold tile — never both Nit and Station, Nit and Maniac, or Working model and An insult (LPT-440). Unguided SoftPulse-quiet densify stem is situation + tap verb only — never name Nit (or Maniac) while SoftPulse stays off until Hint (LPT-819; SoftPulse LPT-653; same class as LPT-818). |
| Observe wild SoftPulse one gold | Observe wild aggressors densified asks (`act-04-08-01-guided` / scaffolded / unguided / checkpoint) pass `guideRegion` (`observeExtremeEntry` / `observeWidePressure` / `observeCalmNotes` / `observeManiacBundle`) so SoftPulse paints one gold tile — never both Extreme and Timid, Wide heat and Never bets, Frequencies and Revenge, or Enter+barrel and Never plays (LPT-462). |
| Meet the Maniac SoftPulse one gold | Meet the Maniac densified asks (`act-04-08-02-guided` / unguided / checkpoint) pass `guideRegion` (`meetManiacLabel` / `meetManiacLabel2` / `meetManiacMixThree`) so SoftPulse paints one gold tile — never both Maniac and Nit, Maniac and Station, or Three types and Unlabeled (LPT-489). Unguided SoftPulse-quiet densify stem is situation + tap verb only — never name Maniac (or Station) while SoftPulse stays off until Hint (LPT-820; SoftPulse LPT-653; same class as LPT-819 / LPT-818). |
| Meet the TAG SoftPulse one gold | Meet the TAG unguided densified ask (`act-06-11-02-unguided`) passes `guideRegion` (`meetTagLabel2`) so SoftPulse-after-Hint paints one gold TAG tile — never both TAG and Maniac (LPT-491). Guided / scaffolded / checkpoint already pass `meetTagLabel` / `meetTagSelectiveDiff` / `meetTagWorkingModel`. |
| Meet the LAG SoftPulse one gold | Meet the LAG unguided densified ask (`act-06-12-02-unguided`) passes `guideRegion` (`meetLagLabel2`) so SoftPulse-after-Hint paints one gold LAG tile — never both LAG and Nit (LPT-492). Guided / scaffolded / checkpoint already pass `meetLagLabel` / `meetLagPressureDiff` / `meetLagSampleLimits`. |
| Observe wide SoftPulse one gold | Observe wide sustained pressure unguided densified ask (`act-06-12-01-unguided`) passes `guideRegion` (`lagObserveKeepSampling`) so SoftPulse-after-Hint paints one gold Keep sampling tile — never both Keep sampling and Label now (LPT-493). Guided / scaffolded / checkpoint already pass `lagObserveWidePressure` / `lagObserveSomeFolds` / `lagObserveBundle`. |
| Observe selective SoftPulse one gold | Observe selective aggression unguided densified ask (`act-06-11-01-unguided`) passes `guideRegion` (`selectiveKeepSampling`) so SoftPulse-after-Hint paints one gold Keep sampling tile — never both Keep sampling and Max certainty (LPT-494). Guided / scaffolded / checkpoint already pass `selectivePlanOk` / `selectiveDisciplined` / `selectiveEvidenceBundle`. |
| Confidence and samples SoftPulse one gold | Confidence and samples densified asks (`act-04-09-01-guided` / scaffolded / unguided / checkpoint) pass `guideRegion` (`confidenceOneNote` / `confidenceRiseRevisable` / `confidenceUpdateModel` / `confidenceShowLimits`) so SoftPulse paints one gold tile — never both One note and Proven, Rise and Stay zero, Update and Freeze, or Limits and Destiny. Correct-answer chips/icons stay slate; SoftPulse owns the gold (LPT-495). Unguided SoftPulse-quiet densify stem is situation + tap verb only — never name Update / Calling Station model (or Freeze) while SoftPulse stays off until Hint (LPT-821; SoftPulse LPT-653; same class as LPT-820 / LPT-819 / LPT-818). |
| Use overbets SoftPulse one gold | Use overbets and geometric pressure unguided densified ask (`act-06-05-01-unguided`) passes `guideRegion` (`overbetAvoid`) so SoftPulse-after-Hint paints one gold Avoid tile — never both Avoid and Always fine (LPT-497). Guided / checkpoint already pass `overbetNutsBluffs` / `overbetMultiStreet`. |
| Use blockers SoftPulse one gold | Use blockers without solver theater unguided densified ask (`act-06-06-01-unguided`) passes `guideRegion` (`blockersTweak`) so SoftPulse-after-Hint paints one gold Tweak evidence tile — never both Tweak evidence and Replace all reasoning (LPT-498). Guided / scaffolded / checkpoint already pass `blockersAce` / `blockersUnblock` / `blockersNoFakeEv`. |
| Defend enough SoftPulse one gold | Defend enough without frequency theater unguided densified ask (`act-06-07-01-unguided`) passes `guideRegion` (`defendIntuition`) so SoftPulse-after-Hint paints one gold Intuition tile — never both Intuition and Exact percents (LPT-499). Guided / checkpoint already pass `defendStrongCatchers` / `defendPunishOverbluffs`. |
| Mix with a reason SoftPulse one gold | Mix with a reason unguided densified ask (`act-06-08-01-unguided`) passes `guideRegion` (`mixNeedReason`) so SoftPulse-after-Hint paints one gold Need a reason tile — never both Need a reason and Always random (LPT-500). Scaffolded / checkpoint already pass `mixLessBluff` / `mixPurposeFreq`. |
| Navigate 3-bet SoftPulse one gold | Navigate 3-bet and 4-bet pots by depth unguided densified ask (`act-06-09-01-unguided`) passes `guideRegion` (`threeBetAvoidEgo`) so SoftPulse-after-Hint paints one gold Avoid ego tile — never both Avoid ego and Ego 4-bet (LPT-501). Guided / checkpoint already pass `threeBetHighCommit` / `threeBetSprCommit`. |
| Make difficult folds SoftPulse one gold | Make difficult folds; review coolers fairly unguided densified ask (`act-06-10-01-unguided`) passes `guideRegion` (`hardFoldEgoCall`) so SoftPulse-after-Hint paints one gold Ego call tile — never both Ego call and Sound play (LPT-502). Guided / scaffolded / checkpoint already pass `hardFoldCoolerOk` / `hardFoldAskReview`. |
| Adjust versus LAG SoftPulse one gold | Adjust versus LAG unguided densified ask (`act-06-12-03-unguided`) passes `guideRegion` (`citeLagAvoid`) so SoftPulse-after-Hint paints one gold Usually avoid tile — never both Usually avoid and Bluff more (LPT-503). Checkpoint already passes `citeLagWidePressure`. |
| Unguided dock SoftPulse map | Every unguided (and `scaffolded-qq`) `poker_action_sizing` dock that authors a `soft_pulse` cue has a `_guidedPulseTargetId` arm to that cue target, so SoftPulse-after-Hint golds the authored choice — never the first-choice Hint fallback (LPT-625; 24 arms, `scan_content_gaps` unguided-softpulse-map 0). `lpt625_unguided_softpulse_map_test.dart` fails if a new unguided dock authors a cue without an arm. |
| Carry a preflop plan SoftPulse one gold | Carry a preflop plan onto the flop unguided densified ask (`act-07-01-01-unguided`) passes `guideRegion` (`preflopFlopNameThesis`) so SoftPulse-after-Hint paints one gold Name the thesis tile — never both Name the thesis and Wing it (LPT-505). Guided / scaffolded / checkpoint already pass `preflopFlopPlanSick` / `preflopFlopValueContinues` / `preflopFlopAbandon`. |
| Map turn barrels SoftPulse one gold | Map turn barrels before you bet flop unguided densified ask (`act-07-02-01-unguided`) passes `guideRegion` (`turnMapMapFirst`) so SoftPulse-after-Hint paints one gold Map first tile — never both Map first and Yolo barrels (LPT-506). Guided / scaffolded / checkpoint already pass `turnMapAcesBlanks` / `turnMapGiveUp` / `turnMapContinueKill`. |
| Compose river SoftPulse one gold | Compose river value and bluffs unguided densified ask (`act-07-03-01-unguided`) passes `guideRegion` (`riverCompCheck`) so SoftPulse-after-Hint paints one gold Check tile — never both Check and Blast off (LPT-507). Scaffolded / checkpoint already pass `riverCompBlocks` / `riverCompRule`. |
| Change plans by pot type SoftPulse one gold | Change plans by pot type unguided densified ask (`act-07-04-01-unguided`) passes `guideRegion` (`potTypeHigherCommit`) so SoftPulse-after-Hint paints one gold Higher commitment tile — never both Higher commitment and 300bb deep (LPT-508). Guided / scaffolded / checkpoint already pass `potTypeNutPotential` / `potTypeCbetMaps` / `potTypeRangesSpr`. |
| Switch gears HU vs multiway SoftPulse one gold | Switch gears between HU and multiway unguided densified ask (`act-07-05-01-unguided`) passes `guideRegion` (`huMwThickerValue`) so SoftPulse-after-Hint paints one gold Thicker value tile — never both Thicker value and Ultra-slow (LPT-509). Guided / scaffolded / checkpoint already pass `huMwUsuallyNo` / `huMwHigherHu` / `huMwFirstClass`. |
| Rewrite plans SoftPulse one gold | Rewrite plans when stacks change unguided densified ask (`act-07-06-01-unguided`) passes `guideRegion` (`stackDepth40bb`) so SoftPulse-after-Hint paints one gold 40bb tile — never both 40bb and 200bb (LPT-510). Guided / scaffolded / checkpoint already pass `stackDepthCloserCommit` / `stackDepthMoreAttractive` / `stackDepthEveryHand`. |
| Leak-review SoftPulse one gold | Keep a leak-review book unguided densified ask (`act-07-09-01-unguided`) passes `guideRegion` (`leakReviewOnSchedule`) so SoftPulse-after-Hint paints one gold On a schedule tile — never both On a schedule and Never (LPT-511). Guided / scaffolded / checkpoint already pass `leakReviewSpecific` / `leakReviewWrittenRange` / `leakReviewBaseline`. |
| Prep Live warm-up SoftPulse one gold | Prep a coached Live warm-up hand unguided densified ask (`act-07-11-01-unguided`) passes `guideRegion` (`liveWarmupCashScope`) so SoftPulse-after-Hint paints one gold Live cash NLH tile — never both Live cash NLH and Other games (LPT-512). Guided / scaffolded / checkpoint already pass `liveWarmupFullList` / `liveWarmupDefaults` / `liveWarmupOneHand`. |
| Build multiway ranges SoftPulse one gold | Build multiway ranges guided densified ask (`act-05-01-01-guided`) passes `guideRegion` (`multiwayNutFd`) so SoftPulse paints one gold Nut FD tile — never Nut FD + Weak FD + Air stab (LPT-513). Checkpoint (`act-05-01-01-checkpoint`) passes `multiwayNutsPriority` so SoftPulse paints one gold Nut potential tile — never both Nut potential and Any two. Correct-answer icons stay cream/slate; SoftPulse is the only gold teach signal. |
| Play 150–300bb SoftPulse one gold | Play 150–300bb stacks densified asks (`act-05-02-01-guided` / unguided / checkpoint) pass `guideRegion` (`deepImpliedOdds` / `deepMapPlans` / `deepRewardsPos`) so SoftPulse paints one gold tile — never Implied + Low SPR + Bluff all, Map streets + Jam now, or Skill edges + Light stacks. Correct-answer icons stay cream/slate; SoftPulse is the only gold teach signal (LPT-514). |
| Implied and reverse odds SoftPulse one gold | Implied and reverse odds checkpoint densified ask (`act-05-03-01-checkpoint`) passes `guideRegion` (`ioDepthPay`) so SoftPulse paints one gold Depth + pay tile — never both Depth + pay and Short always. Correct-answer icon stays cream; SoftPulse is the only gold teach signal (LPT-515). |
| Thin value SoftPulse one gold | Thin value and bluff-catches checkpoint densified ask (`act-05-04-01-checkpoint`) passes `guideRegion` (`thinValueReadLine`) so SoftPulse paints one gold The line tile — never both The line and Coin flip. Correct-answer icon stays cream; SoftPulse is the only gold teach signal (LPT-516). |
| Advanced flop lines SoftPulse one gold | Advanced flop lines densified asks (`act-05-05-01-guided` / unguided / checkpoint) pass `guideRegion` (`linesNitValueHeavy` / `linesDonkPolar` / `linesDelayAfterWeak`) so SoftPulse paints one gold tile — never Value-heavy + Always bluff, Polarized + Medium pairs, or After weakness + Every hand. Correct-answer icons stay cream/slate; SoftPulse is the only gold teach signal (LPT-517). |
| Street-by-street SoftPulse one gold | Street-by-street updates densified asks (`act-05-06-01-guided` / unguided / checkpoint) pass `guideRegion` (`lineReadCapped` / `lineReadRebuild` / `lineReadUncapped`) so SoftPulse paints one gold tile — never Fewer nuts + Still nuts, Rebuild + Lock flop, or Uncapped + Always bluff. Correct-answer icons stay cream/slate; SoftPulse is the only gold teach signal (LPT-518). |
| Soft timing SoftPulse one gold | Soft timing evidence densified asks (`act-05-07-01-guided` / scaffolded / unguided / checkpoint) pass `guideRegion` (`timingSoftEvidence` / `timingWeakerBlocking` / `timingRejectMagic` / `timingTinyUpdate`) so SoftPulse paints one gold tile — never Soft evidence + Proven nuts + Proven bluff, Weaker + Solver known, Reject + Trust book, or Tiny update + Only evidence. Correct-answer icons stay cream/slate; SoftPulse is the only gold teach signal (LPT-519). |
| Live table dynamics SoftPulse one gold | Live table dynamics densified asks (`act-05-08-01-guided` / scaffolded / checkpoint) pass `guideRegion` (`dynamicsStuckTilted` / `dynamicsGearChange` / `dynamicsFreshSamples`) so SoftPulse paints one gold tile — never Stuck/tilted + Ignore, Gear change + Old label, or Fresh samples + Permanent seats. Correct-answer icons stay cream/slate; SoftPulse is the only gold teach signal (LPT-520). Unguided is `poker_action_sizing` (out of densify SoftPulse path). |
| Keep cash session guardrails SoftPulse one gold | Keep cash session guardrails densified asks (`act-05-09-01-guided` / scaffolded / unguided / checkpoint) pass `guideRegion` (`disciplineStop` / `disciplineDecline` / `disciplineCashOut` / `disciplineEdge`) so SoftPulse paints one gold tile — never Stop/move down + Reload/chase, Decline + Jump up, Cash out + Stay forever, or Your edge + Soft skills only. Correct-answer icons stay cream; SoftPulse is the only gold teach signal (LPT-521). |
| Spot range advantage SoftPulse one gold | Spot range advantage and nut advantage densified asks (`act-06-01-01-guided` / scaffolded / checkpoint) pass `guideRegion` (`rangeAdvPfr` / `rangeAdvWideCaller` / `rangeAdvPress`) so SoftPulse paints one gold tile — never Preflop raiser + Flatting BB, Wide caller + PFR always, or Apply pressure + Bet any two. Correct-answer icons stay cream; SoftPulse is the only gold teach signal (LPT-523). Unguided is `poker_action_sizing` (out of densify SoftPulse path). |
| Realize equity SoftPulse one gold | Realize equity in and out of position densified asks (`act-06-02-01-guided` / scaffolded / unguided / checkpoint) pass `guideRegion` (`eqRealizeIp` / `eqRealizeDiscount` / `eqRealizeFoldEq` / `eqRealizePosInit`) so SoftPulse paints one gold tile — never In position + Out of position, Discount / fold + Hero-call, Fold equity + Fancy play, or Position + initiative + Hope alone. Correct-answer icons stay cream; SoftPulse is the only gold teach signal (LPT-524). |
| How pots SoftPulse one gold | How pots are won densified asks (`act-01-05-01-unguided-pot` / `act-01-05-01-checkpoint-side`) pass `guideRegion` (`potChipsNine` / `potSideForms`) so SoftPulse paints one gold tile — never every chip total, or Side pot + Win all + Hand dead. Side pot M/S chips stay slate; SoftPulse is the only gold teach signal (LPT-525). Framed open-pot SoftPulse stays on `_LessonChoiceStack` (`pot-correct`). Guided fold-win / scaffolded showdown already pass `potTakeQuiet` / `potShowdown`. |
| Catalog densify SoftPulse one gold | Remaining densify builders that still omitted `guideRegion` now pass it so SoftPulse paints one gold tile — Count outs unguided (`drawPriceCall`), Hand families unguided/checkpoint (`handFamilyUgSc` / `handFamilyCpTrash`), Baseline jump-family (`jumpFamilySuitedAce`), Think in ranges unguided/checkpoint (`rangesTooExact` / `rangesReadDrives`), Plan beyond the flop checkpoint (`planBranches`), Size with a message unguided (`sizingSoftBand`), Adjust vs Station/Nit/Maniac cite checkpoints (`citeRarelyFolds` / `citeNitStrongRange` / `citeManiacWideBet`), Section 4 jump-range (`jumpUtgNarrower`). Null SoftPulses every phase (LPT-634). |
| Adjust Nit dock starting-hand labels | Adjust versus Nit unguided (`act-04-07-03-unguided`) — and other `poker_action_sizing` docks — rewrite choice labels / a11y that name a starting hand through `alignLessonActionChoices` onto the remapped holes — never catalog **Always steal K9o** over a dealt J7o while Rex already says J7o (LPT-455). |

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

`alignLessonTableCopy` protects English count phrases (`Your two cards`,
`the two in front`, `Those two` / `These two` before stay/are) before spoken
rank-word remaps so a template board deuce cannot turn Your two cards Hint
into "Your three cards" (LPT-791) or Nice! "Those two stay…" into "Those
three stay…" (`lesson_starting_hand_copy.dart`, LPT-797). Your two cards
densified coach lines are stem-only — never hardcode template Ah Kd / Qs Jh
2c (`selectIdentifyDensifiedCoachLine`, LPT-792). The next densify Hint that
says "two cards" or feedback that says "Those two stay" copies that
protect; the next hole/board densify ask uses a stem or aligned felt names.

Calling Station explain STATION tile caption is **Working label**
(`CallingStationDemo.points` in `lesson_action_table.dart`, LPT-789) — same
type-tile caption as Nit/Maniac. The next player-type explain tile copies
that Working label language; never ship Temp tag learner chrome.

Graded felt answers keep cyan under Nice! / Oops via
`lessonTableStageSelectionForRegion` and `LessonHoleHandTable.selectedSeatIndexes`
(`lesson_table_context.dart` / `lesson_table_stage.dart`, LPT-641). The next
framed hero/villain/board or hole-hand seat ask copies those props — never a
grade dock with a bare unmarked felt.

Button and blinds (LPT-36) stacks the flop cards and the showdown card backs vertically in `_buildBlindsTiming` (`lib/ui/course/widgets/lesson_table_context.dart`). The next phase column copies that vertical stack.

Guided suits (`act-01-01-02-guided-suits` via `LessonSuitBoardTable` in
`select_identify_activity.dart`) owns progressive suit picks locally and
only syncs selection when the draft is already `suits-full`. The next
multi-press board picker that rebuilds from `LessonActivityController`
copies that gate so SoftPulse/Hint notifyListeners cannot clear cyan.

Suits and ranks `teachSpec` (LPT-81, `content/course/v2/course.json`, kept
in sync with `tools/course/wave_one_foundations.mjs`): guided suits deals
`random_in_class` / `four_suits` (`dealSuitLessonBoard`) with one
`soft_pulse` cue per suit press in board order; ranks deals
`random_in_class` / `high_card` + `rainbow` (`dealRankOrderSpot`) with
three `soft_pulse` cues `rank-2` → `rank-T` → `rank-A` (LPT-370; after
Hint, `LessonRankOrderTable` golds the next authored cue target, one at a
time, via `authoredSoftPulseTargets`);
unguided suited deals `suited` with offsuit and pocket-pair distractor
`variants` (`dealHoleHandSeatPlan`); the pair checkpoint deals `pair` with
suited and offsuit distractor `variants`, a `none` cue, and no
`pressHints` or Hint media. The next lesson that moves its deal into
`teachSpec` names the Dart dealer it mirrors the same way.

Curriculum residuals LPT-724, LPT-731, LPT-733, LPT-737, LPT-738, LPT-739, LPT-740, LPT-741, LPT-743, LPT-748, LPT-749 (Kushal-approved rule, 2026-10-14): leftover SoftPulse presses and checkpoints from a split move to the split sibling whose concept they teach. A reused first-child explain keeps only its own concept's presses; the dedicated felt demo shows only the tiles its authored cues name (`LessonAuthoredDemoScope` / `lessonAuthoredDemoPoints`, full ladder when no teachSpec).
- `act-01-01-03-explain-button`: SoftPulse was D → SB → BB, now D; SB/BB presses belong to Small and big blinds (LPT-724)
- `act-01-03-01-explain-passive`: SoftPulse was FOLD → CHECK → CALL, now FOLD; CHECK/CALL presses belong to Check and Call (LPT-731)
- `act-01-03-02-explain-aggro`: SoftPulse was BET → RAISE → ALL-IN, now BET; RAISE/ALL-IN presses belong to Raise and All-in (LPT-733)
- `act-01-05-01-explain-win`: SoftPulse was FOLD WIN → SHOWDOWN → SIDE POT, now FOLD WIN; SHOWDOWN/SIDE POT presses belong to Win at showdown and Main and side pots (LPT-738)
- `act-02-02-01-explain-families`: SoftPulse was Pairs → Broadways → Suited aces → Connectors, now Pairs; Broadways/Suited aces/Connectors presses belong to Broadways and suited aces and Connectors versus trash (LPT-740)
- `act-02-03-01-explain-open`: SoftPulse was EARLY → BUTTON → LIVE 3x, now EARLY; BUTTON/LIVE 3x presses belong to Widen on the button and Open strong hands (LPT-741)
- `act-02-04-01-explain-vs`: SoftPulse was FOLD → CALL → 3-BET, now FOLD; CALL/3-BET presses belong to Call in position and Value 3-bet (LPT-743)
- `act-02-05-01-explain-bb`: SoftPulse was CHIPS→BB → SHORTER → DEPTH, now CHIPS→BB; SHORTER/DEPTH presses belong to Shorter stack is effective and Stack depth (LPT-748)
- `act-02-06-01-explain-habits`: SoftPulse was WATCH → SAY → COVER → WAIT, now WATCH; SAY/COVER/WAIT presses belong to Say your action and Protect cards, wait your turn (LPT-749)
- `act-02-01-01-guided-btn`: `lesson-02-01-01-01-seat-labels` → `lesson-02-01-01-03-later-seats`; postflop last-actor guided practice moved from Seat labels to Later seats (LPT-739)
- `lesson-01-04-01-02-action-order`: objective "Know preflop order starts left of the big blind" → "Know who acts first before and after the flop"; lesson objective now matches its summary, so the postflop first-actor checkpoint grades the lesson's own concept (LPT-737)

Curriculum residuals LPT-750, LPT-751, LPT-752, LPT-753, LPT-754, LPT-755, LPT-756, LPT-757 (Kushal-approved rule, 2026-10-14): leftover SoftPulse presses and checkpoints from a split move to the split sibling whose concept they teach. A reused first-child explain keeps only its own concept's presses; the dedicated felt demo shows only the tiles its authored cues name (`LessonAuthoredDemoScope` / `lessonAuthoredDemoPoints`, full ladder when no teachSpec).
- `act-03-01-01-explain`: SoftPulse was POT → STACKS → BUTTON → WHO ACTS, now POT → STACKS; BUTTON/WHO ACTS presses belong to Button and action seat (LPT-750)
- `act-03-02-01-explain`: SoftPulse was MADE → DRAW → SDV → AIR, now MADE; DRAW/SDV/AIR presses belong to Draws versus showdown value and Recognize air (LPT-751)
- `act-03-03-01-explain`: SoftPulse was CLEAN → DIRTY → PRICE, now CLEAN → DIRTY; PRICE press belongs to Pot odds versus equity (LPT-752)
- `act-03-04-01-explain`: SoftPulse was VALUE → C-BET → CHECK → CALL → FOLD → RAISE, now VALUE; C-BET/CHECK/CALL/FOLD/RAISE presses belong to C-bet selectively and Raise, call, or fold with a plan (LPT-753)
- `act-03-05-01-explain`: SoftPulse was BRICK → CHANGE → BARREL → DELAY, now BRICK → CHANGE; BARREL/DELAY presses belong to Second barrel and Delayed aggression (LPT-754)
- `act-03-06-01-explain`: SoftPulse was VALUE → BLUFF → CATCH → FOLD, now VALUE; BLUFF/CATCH/FOLD presses belong to Credible bluffs and Bluff-catch or fold (LPT-755)
- `act-03-07-01-explain`: SoftPulse was STRONGER → FEWER → NUTS, now STRONGER; FEWER/NUTS presses belong to Bluff less multiway and Nut potential and position (LPT-756)
- `act-03-08-01-explain`: SoftPulse was TOP PAIR → PRICES → PASSIVE → CROWDS, now TOP PAIR; PRICES/PASSIVE/CROWDS presses belong to Fold bad prices and Passive calls and crowd bluffs (LPT-757)

Curriculum split LPT-83: old `lesson-01-01-02-suits-and-ranks` becomes unit
`unit-01-01-02-suits-and-ranks` with one lesson per concept (`…-01-suits`,
`…-02-ranks`, `…-03-pairs-and-suited`). Catalog `lessonSplitMap` expands
completed progress on the retired lesson id onto all three successors so
existing learners are not stranded. Button and blinds moves to
`unit-01-01-03-blinds-and-button` for path order (LPT-87 will split that
unit). Shipped.

Curriculum splits LPT-192: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-04-06-03-adjust-calling-station` → `lesson-04-06-03-01-value-wider`, `lesson-04-06-03-02-bluff-less`, `lesson-04-06-03-03-cite-sticky-call` (LPT-192)

Curriculum splits LPT-330, LPT-333, LPT-336, LPT-668: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-07-07-01-same-cards-types` → `lesson-07-07-01-01-station-value`, `lesson-07-07-01-02-tag-checkraise`, `lesson-07-07-01-03-lag-barrel`, `lesson-07-07-01-04-baseline-without-evidence` (LPT-330)
- `lesson-07-08-01-type-board-line` → `lesson-07-08-01-01-type-and-board`, `lesson-07-08-01-02-line-and-sizing`, `lesson-07-08-01-03-one-coherent-action` (LPT-333)
- `lesson-07-09-01-leak-review-book` → `lesson-07-09-01-01-name-leaks`, `lesson-07-09-01-02-default-lines`, `lesson-07-09-01-03-review-habits` (LPT-336)
- `lesson-02-07-01-baseline-full-hand` → `lesson-02-07-01-01-full-ring-open`, `lesson-02-07-01-02-vs-raise-plan`, `lesson-02-07-01-03-habits-while-deciding` (LPT-668)

Curriculum splits LPT-310, LPT-314, LPT-317, LPT-320, LPT-323, LPT-326: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-07-01-01-preflop-to-flop` → `lesson-07-01-01-01-preflop-thesis`, `lesson-07-01-01-02-flop-update`, `lesson-07-01-01-03-abandon-dead-plans` (LPT-310)
- `lesson-07-02-01-flop-to-turn-map` → `lesson-07-02-01-01-continue-cards`, `lesson-07-02-01-02-give-up-cards`, `lesson-07-02-01-03-bet-with-a-map` (LPT-314)
- `lesson-07-03-01-river-composition` → `lesson-07-03-01-01-river-value`, `lesson-07-03-01-02-blocker-bluffs`, `lesson-07-03-01-03-check-trash` (LPT-317)
- `lesson-07-04-01-pot-type-plans` → `lesson-07-04-01-01-limped-pots`, `lesson-07-04-01-02-single-raised-pots`, `lesson-07-04-01-03-threebet-fourbet-pots` (LPT-320)
- `lesson-07-05-01-hu-vs-multiway` → `lesson-07-05-01-01-bluff-less-multiway`, `lesson-07-05-01-02-value-thicker-multiway`, `lesson-07-05-01-03-widen-hu-bluffs` (LPT-323)
- `lesson-07-06-01-stack-depth-plans` → `lesson-07-06-01-01-commit-short`, `lesson-07-06-01-02-implied-odds-deep`, `lesson-07-06-01-03-recalc-effective` (LPT-326)

Curriculum splits LPT-288, LPT-291, LPT-294, LPT-297, LPT-300, LPT-303, LPT-306: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-06-11-01-observe-selective` → `lesson-06-11-01-01-selective-entry`, `lesson-06-11-01-02-disciplined-aggression`, `lesson-06-11-01-03-wait-for-samples` (LPT-288)
- `lesson-06-11-02-meet-tag` → `lesson-06-11-02-01-tag-model`, `lesson-06-11-02-02-spot-tag`, `lesson-06-11-02-03-tag-vs-maniac` (LPT-291)
- `lesson-06-11-03-adjust-tag` → `lesson-06-11-03-01-respect-aggression`, `lesson-06-11-03-02-no-light-reraise`, `lesson-06-11-03-03-thin-value-callers` (LPT-294)
- `lesson-06-12-01-observe-wide-pressure` → `lesson-06-12-01-01-wide-entry`, `lesson-06-12-01-02-sustained-pressure`, `lesson-06-12-01-03-planned-not-maniac` (LPT-297)
- `lesson-06-12-02-meet-lag` → `lesson-06-12-02-01-lag-model`, `lesson-06-12-02-02-spot-lag`, `lesson-06-12-02-03-lag-vs-station` (LPT-300)
- `lesson-06-12-03-adjust-lag` → `lesson-06-12-03-01-call-wider`, `lesson-06-12-03-02-trap-more`, `lesson-06-12-03-03-fewer-fancy-bluffs` (LPT-303)
- `lesson-06-13-01-mix-five-types` → `lesson-06-13-01-01-station-thin-value`, `lesson-06-13-01-02-nit-fold`, `lesson-06-13-01-03-lag-call`, `lesson-06-13-01-04-cite-tendency` (LPT-306)

Curriculum splits LPT-254, LPT-257, LPT-260, LPT-264, LPT-267, LPT-270, LPT-273, LPT-277, LPT-282, LPT-285: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-06-01-01-range-nut-advantage` → `lesson-06-01-01-01-range-advantage`, `lesson-06-01-01-02-nut-advantage`, `lesson-06-01-01-03-press-both` (LPT-254)
- `lesson-06-02-01-equity-realization` → `lesson-06-02-01-01-prefer-ip`, `lesson-06-02-01-02-discount-oop`, `lesson-06-02-01-03-aggression-realizes` (LPT-257)
- `lesson-06-03-01-capped-uncapped` → `lesson-06-03-01-01-spot-caps`, `lesson-06-03-01-02-respect-uncapped`, `lesson-06-03-01-03-attack-caps` (LPT-260)
- `lesson-06-04-01-polar-merged` → `lesson-06-04-01-01-polarized-sizing`, `lesson-06-04-01-02-merged-thin-value`, `lesson-06-04-01-03-matched-shapes` (LPT-264)
- `lesson-06-05-01-overbets-geometric` → `lesson-06-05-01-01-polar-overbets`, `lesson-06-05-01-02-geometric-sizes`, `lesson-06-05-01-03-no-random-huge` (LPT-267)
- `lesson-06-06-01-blockers` → `lesson-06-06-01-01-bluff-blockers`, `lesson-06-06-01-02-unblock-bluffs`, `lesson-06-06-01-03-no-fake-ev` (LPT-270)
- `lesson-06-07-01-minimum-defense` → `lesson-06-07-01-01-continue-catchers`, `lesson-06-07-01-02-fold-trash`, `lesson-06-07-01-03-no-fake-mdf` (LPT-273)
- `lesson-06-08-01-mixed-strategy` → `lesson-06-08-01-01-mix-strong`, `lesson-06-08-01-02-types-reduce-mixing`, `lesson-06-08-01-03-no-pure-random` (LPT-277)
- `lesson-06-09-01-threebet-fourbet` → `lesson-06-09-01-01-careful-4bet-pots`, `lesson-06-09-01-02-plan-3bet-spr`, `lesson-06-09-01-03-no-ego-4bets` (LPT-282)
- `lesson-06-10-01-difficult-folds` → `lesson-06-10-01-01-hard-folds`, `lesson-06-10-01-02-cooler-or-mistake`, `lesson-06-10-01-03-no-ego-calls` (LPT-285)

Curriculum splits LPT-224, LPT-227, LPT-230, LPT-233, LPT-236, LPT-239, LPT-244, LPT-247, LPT-250: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-05-01-01-multiway-ranges` → `lesson-05-01-01-01-nut-potential`, `lesson-05-01-01-02-tighten-speculative`, `lesson-05-01-01-03-thick-value` (LPT-224)
- `lesson-05-02-01-deep-stack-play` → `lesson-05-02-01-01-deep-implied-odds`, `lesson-05-02-01-02-fold-light-deep`, `lesson-05-02-01-03-plan-high-spr` (LPT-227)
- `lesson-05-03-01-implied-odds` → `lesson-05-03-01-01-estimate-implied`, `lesson-05-03-01-02-reverse-implied`, `lesson-05-03-01-03-skip-dominated-draws` (LPT-230)
- `lesson-05-04-01-thin-value-bluffcatch` → `lesson-05-04-01-01-thin-value`, `lesson-05-04-01-02-wider-catches`, `lesson-05-04-01-03-skip-thin-overfolders` (LPT-233)
- `lesson-05-05-01-lines-and-probes` → `lesson-05-05-01-01-read-check-raises`, `lesson-05-05-01-02-probes-and-delays`, `lesson-05-05-01-03-donk-bets` (LPT-236)
- `lesson-05-06-01-line-reading` → `lesson-05-06-01-01-update-each-street`, `lesson-05-06-01-02-capped-lines`, `lesson-05-06-01-03-drop-stale-stories` (LPT-239)
- `lesson-05-07-01-timing-sizing-evidence` → `lesson-05-07-01-01-timing-soft`, `lesson-05-07-01-02-sizing-language`, `lesson-05-07-01-03-no-magic-tells` (LPT-244)
- `lesson-05-08-01-table-dynamics` → `lesson-05-08-01-01-tilted-opponents`, `lesson-05-08-01-02-gear-changes`, `lesson-05-08-01-03-no-emotional-pots` (LPT-247)
- `lesson-05-09-01-session-discipline` → `lesson-05-09-01-01-stop-loss`, `lesson-05-09-01-02-bankroll-stakes`, `lesson-05-09-01-03-end-sessions` (LPT-250)

Curriculum splits LPT-186, LPT-189, LPT-195, LPT-198, LPT-202, LPT-205, LPT-208, LPT-212: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-04-06-01-observe-sticky-caller` → `lesson-04-06-01-01-high-participation`, `lesson-04-06-01-02-low-folding`, `lesson-04-06-01-03-observation-vs-certainty` (LPT-186)
- `lesson-04-06-02-meet-calling-station` → `lesson-04-06-02-01-calling-station-model`, `lesson-04-06-02-02-spot-calling-station`, `lesson-04-06-02-03-station-confidence` (LPT-189)
- `lesson-04-07-01-observe-narrow-player` → `lesson-04-07-01-01-narrow-entry`, `lesson-04-07-01-02-strong-aggression`, `lesson-04-07-01-03-wait-for-samples` (LPT-195)
- `lesson-04-07-02-meet-nit` → `lesson-04-07-02-01-nit-model`, `lesson-04-07-02-02-spot-nit` (LPT-198)
- `lesson-04-07-03-adjust-nit` → `lesson-04-07-03-01-steal-more`, `lesson-04-07-03-02-respect-heavy-action`, `lesson-04-07-03-03-cite-narrow-entry` (LPT-202)
- `lesson-04-08-01-observe-wild-aggressor` → `lesson-04-08-01-01-extreme-entry`, `lesson-04-08-01-02-constant-aggression`, `lesson-04-08-01-03-no-ego-notes` (LPT-205)
- `lesson-04-08-02-meet-maniac` → `lesson-04-08-02-01-maniac-model`, `lesson-04-08-02-02-spot-maniac` (LPT-208)
- `lesson-04-08-03-adjust-maniac` → `lesson-04-08-03-01-widen-value-catch`, `lesson-04-08-03-02-cite-aggression` (LPT-212)

Curriculum splits LPT-169, LPT-172, LPT-176, LPT-179, LPT-182, LPT-215, LPT-218: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-04-01-01-ranges-not-hands` → `lesson-04-01-01-01-seat-as-range`, `lesson-04-01-01-02-ranges-move`, `lesson-04-01-01-03-no-exact-hand` (LPT-169)
- `lesson-04-02-01-threebet-squeeze` → `lesson-04-02-01-01-value-3bet`, `lesson-04-02-01-02-facing-3bet`, `lesson-04-02-01-03-squeeze` (LPT-172)
- `lesson-04-03-01-continuation-plans` → `lesson-04-03-01-01-multi-street-plan`, `lesson-04-03-01-02-abort-plan`, `lesson-04-03-01-03-pot-size-control` (LPT-176)
- `lesson-04-04-01-sizing-communicates` → `lesson-04-04-01-01-value-vs-pressure`, `lesson-04-04-01-02-nearby-sizes`, `lesson-04-04-01-03-no-tiny-sizes` (LPT-179)
- `lesson-04-05-01-spr-commitment` → `lesson-04-05-01-01-estimate-spr`, `lesson-04-05-01-02-commit-low-spr`, `lesson-04-05-01-03-flexible-high-spr` (LPT-182)
- `lesson-04-09-01-type-identification` → `lesson-04-09-01-01-observation-not-certainty`, `lesson-04-09-01-02-confidence-with-samples`, `lesson-04-09-01-03-retire-labels` (LPT-215)
- `lesson-04-10-01-exploit-checkpoints` → `lesson-04-10-01-01-same-hand-types`, `lesson-04-10-01-02-combine-factors` (LPT-218)

Curriculum splits LPT-143, LPT-146, LPT-151, LPT-154, LPT-157, LPT-160, LPT-163: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-03-02-01-flop-hand-classes` → `lesson-03-02-01-01-made-hands`, `lesson-03-02-01-02-draws-vs-showdown`, `lesson-03-02-01-03-air` (LPT-143)
- `lesson-03-03-01-outs-and-price` → `lesson-03-03-01-01-clean-outs`, `lesson-03-03-01-02-pot-odds`, `lesson-03-03-01-03-implied-odds` (LPT-146)
- `lesson-03-04-01-flop-decisions` → `lesson-03-04-01-01-value-bet`, `lesson-03-04-01-02-selective-cbet`, `lesson-03-04-01-03-flop-plan` (LPT-151)
- `lesson-03-05-01-turn-decisions` → `lesson-03-05-01-01-brick-or-change`, `lesson-03-05-01-02-second-barrel`, `lesson-03-05-01-03-delayed-aggression` (LPT-154)
- `lesson-03-06-01-river-decisions` → `lesson-03-06-01-01-river-value`, `lesson-03-06-01-02-credible-bluff`, `lesson-03-06-01-03-catch-or-fold` (LPT-157)
- `lesson-03-07-01-multiway-fundamentals` → `lesson-03-07-01-01-stronger-value`, `lesson-03-07-01-02-bluff-less`, `lesson-03-07-01-03-nut-potential` (LPT-160)
- `lesson-03-08-01-leak-repair` → `lesson-03-08-01-01-weak-top-pair`, `lesson-03-08-01-02-bad-prices`, `lesson-03-08-01-03-passive-and-crowds` (LPT-163)

Curriculum splits LPT-114, LPT-117, LPT-121, LPT-124, LPT-127, LPT-130, LPT-133, LPT-140: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-02-01-01-position-labels` → `lesson-02-01-01-01-seat-labels`, `lesson-02-01-01-02-blind-labels`, `lesson-02-01-01-03-later-seats` (LPT-114)
- `lesson-02-01-02-acting-order` → `lesson-02-01-02-01-preflop-order`, `lesson-02-01-02-02-postflop-order`, `lesson-02-01-02-03-wait-your-turn` (LPT-117)
- `lesson-02-02-01-hand-families` → `lesson-02-02-01-01-pocket-pairs`, `lesson-02-02-01-02-broadways-suited-aces`, `lesson-02-02-01-03-connectors-vs-trash` (LPT-121)
- `lesson-02-03-01-open-fold` → `lesson-02-03-01-01-fold-early-trash`, `lesson-02-03-01-02-open-strong`, `lesson-02-03-01-03-widen-button` (LPT-124)
- `lesson-02-04-01-facing-raise` → `lesson-02-04-01-01-fold-to-open`, `lesson-02-04-01-02-call-in-position`, `lesson-02-04-01-03-value-3bet` (LPT-127)
- `lesson-02-05-01-effective-stack` → `lesson-02-05-01-01-chips-to-bb`, `lesson-02-05-01-02-shorter-stack`, `lesson-02-05-01-03-stack-depth` (LPT-130)
- `lesson-02-06-01-live-habits` → `lesson-02-06-01-01-follow-action`, `lesson-02-06-01-02-say-your-action`, `lesson-02-06-01-03-protect-and-wait` (LPT-133)
- `lesson-03-01-01-reading-live-table` → `lesson-03-01-01-01-pot-and-stacks`, `lesson-03-01-01-02-button-and-action`, `lesson-03-01-01-03-verbal-binds` (LPT-140)

Curriculum splits LPT-87, LPT-90, LPT-93, LPT-96, LPT-100, LPT-103, LPT-106: each retired multi-concept lesson stays inside its unit as one lesson per concept; catalog `lessonSplitMap` carries completed progress onto every successor. Existing activity ids are reused (Dart SoftPulse / densify arms keep working); only the new per-concept explains are new ids.
- `lesson-01-01-03-blinds-and-button` → `lesson-01-01-03-01-dealer-button`, `lesson-01-01-03-02-small-and-big-blind`, `lesson-01-01-03-03-blinds-post-first` (LPT-87)
- `lesson-01-02-01-hand-ranks` → `lesson-01-02-01-01-order-hand-ranks`, `lesson-01-02-01-02-pairs-straights-flushes`, `lesson-01-02-01-03-compare-finished-hands` (LPT-90)
- `lesson-01-02-02-best-five-kickers` → `lesson-01-02-02-01-best-five`, `lesson-01-02-02-02-kickers`, `lesson-01-02-02-03-board-plays` (LPT-93)
- `lesson-01-03-01-fold-check-call` → `lesson-01-03-01-01-fold`, `lesson-01-03-01-02-check`, `lesson-01-03-01-03-call` (LPT-96)
- `lesson-01-03-02-bet-raise-allin` → `lesson-01-03-02-01-bet`, `lesson-01-03-02-02-raise`, `lesson-01-03-02-03-all-in` (LPT-100)
- `lesson-01-04-01-streets-and-order` → `lesson-01-04-01-01-four-streets`, `lesson-01-04-01-02-action-order`, `lesson-01-04-01-03-street-ends` (LPT-103)
- `lesson-01-05-01-winning-pots` → `lesson-01-05-01-01-win-by-fold`, `lesson-01-05-01-02-showdown`, `lesson-01-05-01-03-main-and-side-pots` (LPT-106)


Button and blinds `teachSpec` (LPT-85): every step is `deal.mode` `none`
(seat/puck teaching; the felt shows card backs, no dealt classes). The
explain step authors three `soft_pulse` cues D → SB → BB, the guided button
step D, scaffolded blinds BB (the seat-ring fallback when the BB puck is
hidden stays in Dart), the timing step `before-deal`, and the checkpoint a
`none` cue on SB with no `pressHints` or Hint media. Cue targets are the
puck labels `lessonPuckLabelForHighlight` returns, so there is no second
cue system.

Hand ranks `teachSpec` (LPT-88): each step deals `random_in_class` with the
three classes `dealShowdownOrderCards` deals, the first-press class as
`handFamily` and the other two as seat `variants` (explain and guided: high
card, pair, flush; scaffolded spot: pair, straight, flush; unguided compare:
full house, trips, two pair; checkpoint: flush, straight, high card). Cues
target the role ids `you` → `sam` → `jo` in press order, not physical seats,
because `_shuffleShowdownSeatRoles` moves each role to a random seat and
SoftPulse / Hint follow the role (LPT-54). The checkpoint cues are `none`,
with no `pressHints` or Hint media.

Best five and kickers `teachSpec` (LPT-91): explain and guided seven deal
`random_in_class` / `pair` (`_dealTopPairBestKicker`, fresh pair and kicker
ranks). Explain cues follow `BestFiveExplainDeal.playOrder` (hero pair, hero
kicker, board pair, second then top board kicker); guided seven cues follow
the picker's guide order, the `best-pair-k` set (hero pair, board pair, hero
kicker, top then second board kicker). Scaffolded kicker deals a board
`pair` with a same-pair, weaker-kicker villain `variant` and cues
`hero_holes`; unguided board deals a `monotone` `straight_flush` board with
a small hero pair `variant` and cues `board`; the checkpoint deals
`full_house` from a pocket `pair` (`_dealTripsOverTwoPairs`) with a `none`
cue and no `pressHints` or Hint media.

Fold, check, call `teachSpec` (LPT-94): each `poker_action_sizing` step deals
`random_in_class` in the class `dealtLessonActionSpot` keeps: guided fold
re-deals `trash` / `offsuit` preflop holes; the flop steps keep the hero's
`HandClassifier` class (scaffolded check and checkpoint `weak_draw`,
unguided call `strong_draw`). Cues name the graded dock choice (`fold-72`,
`check-free`, `call-5`) as `soft_pulse`; the checkpoint cues
`check-illegal` with kind `none` and has no `pressHints` or Hint media.
`actionAct` in the wave helper now carries `assessmentRole` and
`teachSpec`.

Bet, raise, all-in `teachSpec` (LPT-98): each `poker_action_sizing` step
deals `random_in_class` in the class `dealtLessonActionSpot` keeps: guided
bet, scaffolded raise, and unguided all-in stay `top_pair` (top pair /
overpair on the flop templates); checkpoint-names stays `air`. Cues name the
graded dock choice (`bet-half`, `raise-15`, `shove-12`) as `soft_pulse`; the
checkpoint cues `named-bet` with kind `none` and has no `pressHints` or Hint
media.

Streets and action order `teachSpec` (LPT-101): each interactive step uses
`deal.mode` `none` (street/seat/identify teach — no handFamily). Guided
streets SoftPulse cues advance `st-pre` → `st-flop` → `st-turn` →
`st-river`; scaffolded order SoftPulse cues advance `seat-utg` → `seat-hj` →
`seat-co` → `seat-btn` (wave helper CO seat synced to course.json);
unguided-end SoftPulse cues `matched`; checkpoint-postflop cues `sb-first`
with kind `none` and has no `pressHints` or Hint media.

How pots are won `teachSpec` (LPT-104): guided fold-win and scaffolded
showdown author `fixed` hero (and river board) cards matching the Dart felt;
SoftPulse cues `no-show` / `showdown`. Unguided open-pot uses `deal.mode`
`none` with authored `variants` for open-to sizes 5–10
(`kLessonOpenToAmounts`) and SoftPulse cues `pot-correct`. Checkpoint-side
cues `side-exists` with kind `none` and has no `pressHints` or Hint media.

Play a full toy hand `teachSpec` (LPT-108): guided and scaffolded multi-step
hands deal `random_in_class` `suited_ace` / `suited` with SoftPulse cues on
`open-6`→`won-folds` and `ready-flop`→`cbet`. Unguided BB lab deals
`high_card` / `offsuit` (weak ace class) with SoftPulse on `call-bb`.
Checkpoint-finish deals `broadway` / `offsuit` with cues kind `none` on
`open-kq`→`take-down` and has no `pressHints`. `multiStepAct` / `handLabAct`
now carry `assessmentRole` and `teachSpec`.

Section 1 jump check `teachSpec` (LPT-110): every step is `jump_test` with
cues kind `none` and no `pressHints`. Jump-ranks deals `flush` with
straight/two_pair seat variants; jump-order uses `deal.mode` `none` (wave CO
seat synced); jump-legal authors the facing-bet flop as `fixed` QhJd/Td8s2c;
jump-hand deals `suited_ace`/`suited` with ATs-specific copy softened to the
class.

Position labels `teachSpec` (LPT-112): seat/puck lesson — every interactive
step uses `deal.mode` `none`. SoftPulse cues target `pos-btn`, `sb-bb`, and
`label-co`; checkpoint-edge cues `prefer-btn` with kind `none` and has no
`pressHints` or Hint media.

Acting order `teachSpec` (LPT-115): seat-order lesson — every interactive
step uses `deal.mode` `none` (no handFamily). Guided-pre SoftPulse cues
advance `ord-co` → `ord-btn` → `ord-sb`; scaffolded-post SoftPulse cues
advance `post-sb` → `post-btn`; unguided-wait SoftPulse cues `wait`;
checkpoint-full cues `last-btn` with kind `none` and has no `pressHints` or
Hint media.

Hand families `teachSpec` (LPT-119): each interactive step deals
`random_in_class` in the teaching family (`pair`/`pair`, `broadway`,
`connector`/`suited`, `trash`/`offsuit`). SoftPulse cues target `hf-pair`,
`hf-broadway`, and `hf-sc`; checkpoint-trash cues `hf-trash` with kind
`none` and has no `pressHints` or Hint media. Hero holes already randomize
in-class via `_isomorphicPreflopGroups` / `dealStartingHandFamily`.

Open or fold baseline `teachSpec` (LPT-122): each interactive step deals
`random_in_class` (trash/offsuit, premium-pair class, high_card/suited
button-open, broadway/offsuit). SoftPulse cues target dock ids `fold`,
`open-qq`, and `open-k9s`; checkpoint-hj cues `open-ato` with kind `none`
and has no `pressHints` or Hint media.

Versus an open `teachSpec` (LPT-125): each interactive step deals
`random_in_class` (trash/offsuit, connector/suited, premium pair,
broadway/suited). SoftPulse cues target `fold-j3`, `call-87s`, and
`3bet-kk`; checkpoint-aq cues `3bet-aqs` with kind `none` and has no
`pressHints` or Hint media.

Effective stacks `teachSpec` (LPT-128): chip/BB depth lesson — every
interactive step uses `deal.mode` `none`. SoftPulse cues target `bb-100`,
`eff-60`, and `depth-50`; checkpoint-200 cues `bb-200` with kind `none` and
has no `pressHints` or Hint media.

Live table habits `teachSpec` (LPT-131): habit/etiquette lesson — every step
uses `deal.mode` `none`. Explain SoftPulse advances `WATCH` → `SAY` →
`COVER` → `WAIT`; interactive SoftPulse cues target `watch`, `say-raise`,
and `chip-on-cards`; checkpoint-oot cues `oot-bad` with kind `none` and has
no `pressHints` or Hint media.

Full-ring baseline hand `teachSpec` (LPT-135): action/lab steps deal
`random_in_class` (broadway/suited, pair, broadway/offsuit) with SoftPulse
dock cues `open-ajs`, `call-22`, and `lab-3bet`; checkpoint-habit uses
`deal.mode` `none` and cues `cover-wait` with kind `none` (no pressHints).

Baseline jump check `teachSpec` (LPT-137): every step is `jump_test` with
cues kind `none` and no `pressHints`. Jump-pos and jump-stack use
`deal.mode` `none` (stack ask already densified on felt — Still-a-list
cleared); jump-family deals `suited_ace`/`suited` with pair/trash distractor
variants; jump-open deals `trash`/`offsuit`; jump-vs authors fixed AA
(`AhAd`) so coach copy follows the deal.

Section 1–2 explain `teachSpec` (LPT-635): the twelve S1–S2 SoftPulse
explains that still had no `teachSpec` (Fold, check, call through Full-ring
baseline) now author `deal.mode` `none` plus one `soft_pulse` cue per demo
press, in the order the Dart explain table already golds: FOLD → CHECK →
CALL; BET → RAISE → ALL-IN; PREFLOP → FLOP → TURN → RIVER; FOLD WIN →
SHOWDOWN → SIDE POT; BLINDS → YOU ACT → ENDING; the `D` puck (Position
labels); UTG → HJ → CO → BTN; Pairs → Broadways → Suited aces →
Connectors; EARLY → BUTTON → LIVE 3x; FOLD → CALL → 3-BET; CHIPS→BB →
SHORTER → DEPTH; NINE → SAME → POSITION. Targets are the demo tile labels
(`PassiveActionsDemo.actions`, `StreetsTimelineDemo.streets`, …), so the
catalog and the felt name the same GlowHighlight targets; no second cue
system. `scan_content_gaps` explain-teachSpec is 0 after this change; the
Nice! ladder (`explainGrading`) for these explains landed in LPT-624.

Read the table first `teachSpec` (LPT-138): explain SoftPulse advances POT →
STACKS → BUTTON → WHO ACTS; guided/scaffolded/unguided SoftPulse `pot-21` /
`utg-first` / `bound`; checkpoint cues `eff-55` with kind `none` (no
pressHints). All steps use `deal.mode` `none` (pot/seat/verbal tiles — not
hole-card families). Checkpoint objectives retagged to pot/stack tracking.

Name your flop class `teachSpec` (LPT-141): explain SoftPulse advances MADE
→ DRAW → SDV → AIR; guided/scaffolded/unguided author fixed KhQh/Ks9d2c,
Ah9h/Jh8h3c, and 5h4h/Qc7d2s with SoftPulse `made-tp` / `nfd` / `air`;
checkpoint authors Js8d/Ts9s4d and cues `oesd` with kind `none` (no
pressHints). Checkpoint objectives retagged to draw labeling.

Count outs, pay the right price `teachSpec` (LPT-144): explain SoftPulse
advances CLEAN → DIRTY → PRICE; guided authors fixed AhQh/Kc8h2d with
SoftPulse As→Ad→Ac; scaffolded call-price uses `deal.mode` `none` +
`call-10`; unguided fixed AhQh/Kc8h2d SoftPulse `call-draw`; checkpoint
fixed AhQh/Kh7h2c cues `implied-yes` kind `none`. Ledger Still-a-list "clean
aces (card picker)" cleared (already on the felt).

Choose a flop line `teachSpec` (LPT-149): explain SoftPulse advances VALUE →
C-BET → CHECK → CALL → FOLD → RAISE; guided/scaffolded/unguided author fixed
AhKd/As7c2d, KhQd/As7d2c, and 7h7d/7cKd2s with SoftPulse `bet-tp` / `cbet` /
`raise-set`; checkpoint authors 5h2d/Ah7c2s and cues `fold-bp` with kind
`none` (no pressHints).

Plan the turn card `teachSpec` (LPT-152): explain SoftPulse advances BRICK →
CHANGE → BARREL → DELAY; guided/scaffolded author fixed AhKd/As7d2c3h with
SoftPulse `brick` / `barrel`; unguided fixed Ah9h/Kh7h2c3h SoftPulse
`delay-bet`; checkpoint authors Jh9d/Kc8d3sQh and cues `give-up` with kind
`none` (no pressHints).

Close the river correctly `teachSpec` (LPT-155): explain SoftPulse advances
VALUE → BLUFF → CATCH → FOLD; guided/scaffolded/unguided author fixed
AhKd/AsKc7d2h3c, 9s8s/Ks7s2h3hAh, and Ah4d/As9c7d2h3c with SoftPulse
`val-bet` / `bluff` / `fold-weak`; checkpoint uses `deal.mode` `none` and
cues `role-catch` with kind `none` (no pressHints).

Play tighter multiway `teachSpec` (LPT-158): explain SoftPulse advances
STRONGER → FEWER → NUTS; guided/scaffolded author fixed 7h9d/Kc7s2d and
7s3d/AhKh9h with SoftPulse `check-2p` / `mw-check`; unguided uses
`deal.mode` `none` and SoftPulse `sc`; checkpoint uses `deal.mode` `none`
and cues `obs-many` with kind `none` (no pressHints).

Patch the common leaks `teachSpec` (LPT-161): explain SoftPulse advances TOP
PAIR → PRICES → PASSIVE → CROWDS; guided/scaffolded/unguided author fixed
Ah4d/As9c7d, Jh9d/KsTc2d, and 9h8d/Kc7s2d with SoftPulse `careful` /
`fold-gut` / `fold-air`; checkpoint uses `deal.mode` `none` and cues `notes`
with kind `none` (no pressHints).

Section 3 jump check `teachSpec` (LPT-165): all five jump steps stay
`assessmentRole: jump_test` with no pressHints and cue kind `none`;
jump-table uses `deal.mode` `none` (cue `j3-track`); jump-class, jump-mw,
jump-river, and jump-leak author fixed JdTd/Qd9d3c, 9h8d/AhKh7h,
AhKd/AsKc7d2h3c, and Jh9d/KsTc2d (the LPT-389 true gutshot) with cues
`j3-draw` / `j3-fold` / `j3-val` / `j3-foldprice`.

Think in ranges `teachSpec` (LPT-167): explain SoftPulse advances ONE HAND →
RANGE → UPDATE; guided/scaffolded range tiles use `deal.mode` `none` with
SoftPulse `strong-narrow` / `bb-stronger`; unguided authors fixed
AhKd/As7c2dKh with SoftPulse `too-exact`; checkpoint authors fixed
QhQd/Qc7s2d with cue `read-drives` kind `none` (no pressHints).

Navigate 3-bet pots `teachSpec` (LPT-170): explain SoftPulse advances 3-BET
→ RANGES → SQUEEZE; guided/scaffolded/unguided author fixed QhQd, 7h2d
(trash offsuit), and AhKd (broadway offsuit) with SoftPulse `3bet-qq` /
`fold-72` / `squeeze`; checkpoint authors fixed KhKd with cue `size-18` kind
`none` (no pressHints).

Plan beyond the flop `teachSpec` (LPT-174): explain SoftPulse advances FLOP
→ TURN → RIVER; guided multi-street authors fixed AhKd on As7c2d3h with
SoftPulse `flop-bet` then `turn-bet`; scaffolded authors fixed Qd9c on the
LPT-400 four-heart turn Kh7h2h3h with SoftPulse `abort`; unguided authors
fixed JhTd/Qc9s3h with SoftPulse `small-pot`; checkpoint uses `deal.mode`
`none` and cue `branches` kind `none` (no pressHints).

Size with a message `teachSpec` (LPT-177): explain SoftPulse advances VALUE
→ PRESSURE → SIZE; guided authors fixed AhKd/As7c2d with SoftPulse `half`;
scaffolded authors the LPT-398 missed draw 9h8h/Kh7h2c3dAs with SoftPulse
`big`; unguided soft-grade tiles use `deal.mode` `none` with SoftPulse
`soft`; checkpoint authors fixed AhAd/Kc9s3h with cue `bad-1` kind `none`
(no pressHints).

SPR decides commitment `teachSpec` (LPT-180): explain SoftPulse advances SPR
→ LOW → HIGH; guided SPR math uses `deal.mode` `none` with SoftPulse
`spr-4`; scaffolded/unguided author fixed KhKd/Kc7s2d and Jh9d/Qc9s3h with
SoftPulse `commit` / `flexible`; checkpoint authors fixed AhKd/Qs7c2d9h with
cue `before` kind `none` (no pressHints).

Observe sticky callers `teachSpec` (LPT-184): explain SoftPulse advances
ENTERS → CALLS → FOLDS; guided `none` → `high-part`; scaffolded `none` →
`sticky`; unguided `none` → `low-conf`; checkpoint `none` → `bundle`;
assessment steps use cue kind `none` (no pressHints).

Meet the Calling Station `teachSpec` (LPT-187): explain SoftPulse advances
STATION → HIGH → LOW; guided `none` → `pt-station`; scaffolded `none` →
`model`; unguided `none` → `station2`; checkpoint `none` → `low`; assessment
steps use cue kind `none` (no pressHints).

Adjust versus Calling Station `teachSpec` (LPT-190): explain SoftPulse
advances VALUE → BLUFFS → CITE; guided fixed JhTd/QcTs3h2d7c → `thin-val`;
scaffolded fixed 8h7h/Kh9h2c3d5s → `give-up`; unguided fixed JhTd/QcTs3h2d7c
→ `baseline-check`; checkpoint `none` → `cite-fold`; assessment steps use
cue kind `none` (no pressHints).

Observe narrow players `teachSpec` (LPT-193): explain SoftPulse advances
RARE → ENTER → MEAN IT; guided `none` → `narrow`; scaffolded `none` →
`strong-aggr`; unguided `none` → `wait`; checkpoint `none` → `bundle-nit`;
assessment steps use cue kind `none` (no pressHints).

Meet the Nit `teachSpec` (LPT-196): explain SoftPulse advances NIT → NARROW
→ RESPECT; guided `none` → `pt-nit`; unguided `none` → `nit2`; checkpoint
`none` → `model-n`; assessment steps use cue kind `none` (no pressHints).

Adjust versus Nit `teachSpec` (LPT-200): explain SoftPulse advances STEAL →
CREDIT → EXPLODE; guided fixed Kh9d → `steal`; scaffolded fixed Jh9d/Qc9s3h
→ `fold-mid`; unguided fixed Kh9d → `tighter`; checkpoint `none` → `cite-
strong`; assessment steps use cue kind `none` (no pressHints).

Observe wild aggressors `teachSpec` (LPT-203): explain SoftPulse advances
RAISE → BARREL → COUNT; guided `none` → `extreme`; scaffolded `none` →
`pressure`; unguided `none` → `calm`; checkpoint `none` → `bundle-m`;
assessment steps use cue kind `none` (no pressHints).

Meet the Maniac `teachSpec` (LPT-206): explain SoftPulse advances MANIAC →
ENTRY → AGGRO; guided `none` → `pt-maniac`; unguided `none` → `maniac2`;
checkpoint `none` → `three`; assessment steps use cue kind `none` (no
pressHints).

Adjust versus Maniac `teachSpec` (LPT-210): explain SoftPulse advances WIDER
→ HANG → EGO; guided fixed Ah9d/As7c2dTh3c → `call-wider`; scaffolded fixed
AhKd/AsKc2d9h3c → `val-m`; unguided fixed Ah9d/As7c2dTh3c → `baseline-fold`;
checkpoint `none` → `cite-wide`; assessment steps use cue kind `none` (no
pressHints).

Confidence and samples `teachSpec` (LPT-213): explain SoftPulse advances
OBSERVE → SAMPLES → SHOWDOWNS; guided `none` → `one-note`; scaffolded `none`
→ `rise`; unguided `none` → `update`; checkpoint `none` → `limits`;
assessment steps use cue kind `none` (no pressHints).

Same hand, different types `teachSpec` (LPT-216): explain SoftPulse advances
CARDS → SEATS → EVIDENCE; guided fixed JhTd/QcTs3h2d7c → `st-val`;
scaffolded fixed JhTd/QcTs3h2d7c → `nit-fold`; unguided fixed
JhTd/QcTs3h2d7c → `m-call`; checkpoint fixed KhTd → `lab-steal`; assessment
steps use cue kind `none` (no pressHints).

Section 4 jump check `teachSpec` (LPT-219): jump-range `none` → `j4-range`;
jump-3bet fixed KhKd → `j4-3bet`; jump-spr `none` → `spr-4`; jump-size fixed
AhKd/As7c2d → `j4-10`; jump-station `none` → `j4-cs`; jump-nit `none` →
`j4-nit`; jump-maniac `none` → `j4-man`; assessment steps use cue kind
`none` (no pressHints).

Build multiway ranges `teachSpec` (LPT-222): explain SoftPulse advances
NUTTED → AIR → DOMINATION; guided `none` → `nfd`; scaffolded fixed 7h6h →
`fold-76`; unguided fixed 9h9d/9s8c7h → `bet-set`; checkpoint `none` →
`nuts`; assessment steps use cue kind `none` (no pressHints).

Play 150–300bb stacks `teachSpec` (LPT-225): explain SoftPulse advances DEEP
→ REALIZE → STACK; guided `none` → `impl`; scaffolded fixed Ad9c/AsTh7h →
`fold-tp`; unguided `none` → `plan`; checkpoint `none` → `pos`; assessment
steps use cue kind `none` (no pressHints).

Implied and reverse odds `teachSpec` (LPT-228): explain SoftPulse advances
IMPLIED → REVERSE → SECOND; guided fixed Jh9d/8s7c2d → `call-io`; scaffolded
fixed KhJd/AsTh8h → `rio`; unguided fixed 7h6h/Kh9h2c → `nonut`; checkpoint
`none` → `depth-pay`; assessment steps use cue kind `none` (no pressHints).

Thin value and bluff-catches `teachSpec` (LPT-231): explain SoftPulse
advances THIN → CATCH → BARRELS; guided fixed Jh9d/Kc9s4h2d7c → `tv`;
scaffolded fixed Jh9d/Kc9s4h2d7c → `call-m`; unguided fixed Jh9d/Kc9s4h2d7c
→ `check-nit`; checkpoint `none` → `read`; assessment steps use cue kind
`none` (no pressHints).

Street-by-street updates `teachSpec` (LPT-237): explain SoftPulse advances
ACTION → REWRITE → UPDATE; guided `none` → `capped`; scaffolded fixed
7h6h/Kh9h2c3d → `repr`; unguided `none` → `update`; checkpoint `none` →
`uncap`; assessment steps use cue kind `none` (no pressHints).

Advanced flop lines `teachSpec` (LPT-234): explain SoftPulse advances X/R →
PROBE → DELAY → DONK; guided `none` → `strong`; scaffolded fixed 9h8d/Kc9s3h
→ `probe`; unguided `none` → `polar`; checkpoint `none` → `delay`;
assessment steps use cue kind `none` (no pressHints).

Live table dynamics `teachSpec` (LPT-245): explain SoftPulse advances STUCK
→ TILTED → GEARS; guided `none` → `stuck`; scaffolded `none` → `gear`;
unguided fixed JhTd/Kc9s4h2d7c → `reset`; checkpoint `none` → `temp`;
assessment steps use cue kind `none` (no pressHints).

Keep cash session guardrails `teachSpec` (LPT-248): explain SoftPulse
advances QUIT → GUARD → FIRST; guided `none` → `stop`; scaffolded `none` →
`decline`; unguided `none` → `cash`; checkpoint `none` → `edge`; assessment
steps use cue kind `none` (no pressHints).

Section 5 checkpoint `teachSpec` (LPT-251): cp-multi `none` → `nut`; cp-
value fixed Jh9d/Kc9s4h2d7c → `bet`; cp-catch fixed Jh9d/Kc9s4h2d7c →
`call`; cp-tell `none` → `soft`; cp-stop `none` → `stop`; assessment steps
use cue kind `none` (no pressHints). SoftPulse-off densify stems for
cp-multi / cp-tell / cp-stop use non-spoiling matching-priority / matching-
read / matching-plan copy (LPT-717; same class as LPT-672 / LPT-673 /
LPT-674).

Choose polarized or merged betting `teachSpec` (LPT-262): explain SoftPulse
advances POLAR → MERGED → SIZE; guided `none` → `polar`; scaffolded fixed
JhTd/QcTs3h2d7c → `mid`; unguided `none` → `mismatch`; checkpoint `none` →
`thin`; assessment steps use cue kind `none` (no pressHints).

Use overbets and geometric pressure `teachSpec` (LPT-265): explain SoftPulse
advances OVERBET → POLAR → GEO; guided `none` → `polar-ob`; scaffolded fixed
AsKd/Ah7c2d9s → `mid`; unguided `none` → `avoid`; checkpoint `none` →
`multi`; assessment steps use cue kind `none` (no pressHints).

Use blockers without solver theater `teachSpec` (LPT-268): explain SoftPulse
advances BLOCK → USE → NO EV; guided `none` → `as`; scaffolded `none` →
`unblock`; unguided `none` → `tweak`; checkpoint `none` → `no`; assessment
steps use cue kind `none` (no pressHints).

Navigate 3-bet and 4-bet pots by depth `teachSpec` (LPT-280): explain
SoftPulse advances 3BET → 4BET → DEPTH; guided `none` → `careful`;
scaffolded fixed AhQd/8c3h2s → `small`; unguided `none` → `avoid`;
checkpoint `none` → `spr`; assessment steps use cue kind `none` (no
pressHints).

Make difficult folds; review coolers fairly `teachSpec` (LPT-283): explain
SoftPulse advances HARD → COOLER → EGO; guided fixed Ah9d/As7c2hKd3c →
`fold`; scaffolded `none` → `cooler`; unguided `none` → `ego`; checkpoint
`none` → `ask`; assessment steps use cue kind `none` (no pressHints).

Observe selective aggression `teachSpec` (LPT-286): explain SoftPulse
advances TIGHT → BARREL → SAMPLE; guided `none` → `sel`; scaffolded `none` →
`disc`; unguided `none` → `low`; checkpoint `none` → `bundle`; assessment
steps use cue kind `none` (no pressHints).

Meet the TAG `teachSpec` (LPT-289): explain SoftPulse advances TIGHT → AGGRO
→ MODEL; guided `none` → `tag`; scaffolded `none` → `diff`; unguided `none`
→ `tag2`; checkpoint `none` → `model`; assessment steps use cue kind `none`
(no pressHints).

Adjust versus TAG `teachSpec` (LPT-292): explain SoftPulse advances CREDIT →
TIGHTER → NO LIGHT; guided fixed Jh9d/Qc9s3h → `fold`; scaffolded fixed Kh9d
→ `fold-k9`; unguided fixed JhTd/QcTs3h2d7c → `check`; checkpoint `none` →
`cite`; assessment steps use cue kind `none` (no pressHints).

Meet the LAG `teachSpec` (LPT-298): explain SoftPulse advances WIDE →
PRESSURE → MODEL; guided `none` → `lag`; scaffolded `none` → `diff`;
unguided `none` → `lag2`; checkpoint `none` → `limits`; assessment steps use
cue kind `none` (no pressHints).

Same cards, five type models `teachSpec` (LPT-304): explain SoftPulse
advances CARDS → SEATS → EVIDENCE; guided fixed JhTd/QcTs3h2d7c → `cs`;
scaffolded fixed JhTd/QcTs3h2d7c → `nit`; unguided fixed JhTd/QcTs3h2d7c →
`lag`; checkpoint `none` → `tag`; assessment steps use cue kind `none` (no
pressHints).

Section 6 checkpoint `teachSpec` (LPT-307): cp-adv `none` → `ra`; cp-cap
`none` → `cap`; cp-polar `none` → `polar`; cp-tag `none` → `tag`; cp-lag
`none` → `lag`; assessment steps use cue kind `none` (no pressHints).

Carry a preflop plan onto the flop `teachSpec` (LPT-308): explain SoftPulse
advances REASON → CONFIRM → CANCEL; guided `none` → `dead`; scaffolded
`none` → `value`; unguided `none` → `thesis`; checkpoint `none` → `abandon`;
assessment steps use cue kind `none` (no pressHints).

Change plans by pot type `teachSpec` (LPT-318): explain SoftPulse advances
LIMPED → SRP → 3-4BET; guided `none` → `nuts`; scaffolded `none` → `cb`;
unguided `none` → `commit`; checkpoint `none` → `both`; assessment steps use
cue kind `none` (no pressHints).

Switch gears between HU and multiway `teachSpec` (LPT-321): explain
SoftPulse advances FEWER → THICKER → WIDEN; guided `none` → `no`; scaffolded
`none` → `higher`; unguided `none` → `thick`; checkpoint `none` → `input`;
assessment steps use cue kind `none` (no pressHints).

Rewrite plans when stacks change `teachSpec` (LPT-324): explain SoftPulse
advances SHORT → DEEP → EFFECTIVE; guided `none` → `commit`; scaffolded
`none` → `yes`; unguided `none` → `40`; checkpoint `none` → `every`;
assessment steps use cue kind `none` (no pressHints).

Replay the same hand versus each type `teachSpec` (LPT-328): explain
SoftPulse advances CARDS → MODELS → CITE; guided fixed AhKd/Kc8s3h → `bet`;
scaffolded fixed AhKd/Kc8s3h → `fold`; unguided fixed AhKd/Kc8s3h2d →
`call`; checkpoint `none` → `base`; assessment steps use cue kind `none` (no
pressHints).

Integrate type, board, line, and sizing `teachSpec` (LPT-331): explain
SoftPulse advances TYPE → BOARD → LINE → SIZE; guided fixed JhTd/KhTs8h2d →
`call`; scaffolded fixed 9h8d/Ac7s2dKd → `raise`; unguided fixed
JhTd/QcTs3h2d7c → `fold`; checkpoint `none` → `four`; assessment steps use
cue kind `none` (no pressHints).

Capstone: single-raised pot `teachSpec` (LPT-337): explain SoftPulse
advances PLAN → UPDATE → FINISH; hand fixed AhQd/Kc7s2h2d9c →
`cb/barrel/check-r`; assessment steps use cue kind `none` (no pressHints).

Capstone: 3-bet pot `teachSpec` (LPT-339): explain SoftPulse advances SPR →
TURN → CLOSE; hand fixed AhQd/Qs8h3d2d7c → `bet/barrel/fold`; assessment
steps use cue kind `none` (no pressHints).

Capstone: multiway deep `teachSpec` (LPT-341): explain SoftPulse advances
NUTS → DEEP → NO-BLUFF; hand fixed AhQh/Jh8h2c3d9c → `call/bet/check-r`;
assessment steps use cue kind `none` (no pressHints).

Capstone: limped pot `teachSpec` (LPT-345): explain SoftPulse advances NUTS
→ VALUE → THIN; hand fixed AhKh/Kd9c4h2s8d → `bet/barrel/value`; assessment
steps use cue kind `none` (no pressHints).

Capstone: 4-bet pot `teachSpec` (LPT-347): explain SoftPulse advances SPR →
COMMIT → NO HERO; hand fixed KhKd/Qs8h3d2dAd → `bet/barrel/fold`; assessment
steps use cue kind `none` (no pressHints).

Capstone scaffolded hands are intentional no-Hint **transfer** assessments
(LPT-348): each `act-07-10-0N-hand` is `stage: scaffolded` with
`assessmentRole: transfer` and **no** authored `pressHints` / Hint media.
Scanners skip them via `assessmentRole` and keep the same ids in
`NO_HINT_ACTIVITY_IDS` (with Capstone *-explain* SoftPulse walks). Do not
reopen LPT-626 / LPT-667 for Capstone-only excludes. Capstone hand
`LessonActionSpot`s set `identifyUnavailable: true` so checked-to streets
never grey Jam/Raise as `RAISE (off)` beside a Bet/C-bet choice (LPT-670).
Shipped.

Prep a coached Live warm-up hand `teachSpec` (LPT-349): explain SoftPulse
advances CHECKLIST → DEFAULTS → ONE HAND; guided `none` → `list`; scaffolded
`none` → `defaults`; unguided `none` → `scope`; checkpoint `none` → `one`;
assessment steps use cue kind `none` (no pressHints).

Final: all five player types `teachSpec` (LPT-352): cs `none` → `cs`; nit
`none` → `nit`; maniac `none` → `man`; tag `none` → `tag`; lag `none` →
`lag`; uncertain `none` → `low`; retire `none` → `retire`; assessment steps
use cue kind `none` (no pressHints).

Soft timing evidence `teachSpec` (LPT-242): explain SoftPulse advances
TIMING → SIZING → CLUES; guided `none` → `soft`; scaffolded `none` →
`weakish`; unguided `none` → `reject`; checkpoint `none` → `tiny`;
assessment steps use cue kind `none` (no pressHints).

Spot range advantage and nut advantage `teachSpec` (LPT-252): explain
SoftPulse advances RANGE → NUT → ADVANTAGE; guided `none` → `pfr`;
scaffolded `none` → `caller-nuts`; unguided fixed AhKd/Kc7s2d → `cbet`;
checkpoint `none` → `press`; assessment steps use cue kind `none` (no
pressHints).

Realize equity in and out of position `teachSpec` (LPT-255): explain
SoftPulse advances EQUITY → CASH → POS; guided `none` → `ip`; scaffolded
`none` → `discount`; unguided `none` → `realize`; checkpoint `none` → `pos`;
assessment steps use cue kind `none` (no pressHints).

Recognize capped versus uncapped ranges `teachSpec` (LPT-258): explain
SoftPulse advances CAPPED → UNCAPPED → NUTS; guided `none` → `cap`;
scaffolded fixed Jh9d/Kc9s4h2d7c → `bet`; unguided `none` → `uncap`;
checkpoint `none` → `attack`; assessment steps use cue kind `none` (no
pressHints).

Defend enough without frequency theater `teachSpec` (LPT-271): explain
SoftPulse advances DEFEND → BLUFF → ENOUGH; guided `none` → `strong`;
scaffolded fixed 9h7d/KcQh9d4c8s → `fold`; unguided `none` → `int`;
checkpoint `none` → `punish`; assessment steps use cue kind `none` (no
pressHints).

Mix with a reason `teachSpec` (LPT-275): explain SoftPulse advances MIX →
PURPOSE → STRONG; guided fixed 7h7d/7cKd2s → `protect`; scaffolded `none` →
`less`; unguided `none` → `no`; checkpoint `none` → `freq`; assessment steps
use cue kind `none` (no pressHints).

Observe wide sustained pressure `teachSpec` (LPT-295): explain SoftPulse
advances WIDE → PRESSURE → SAMPLE; guided `none` → `wide`; scaffolded `none`
→ `sep`; unguided `none` → `wait`; checkpoint `none` → `bundle`; assessment
steps use cue kind `none` (no pressHints).

Adjust versus LAG `teachSpec` (LPT-301): explain SoftPulse advances CALL →
TRAP → FANCY LESS; guided fixed Jh9d/Qc9s3h2d7c → `call`; scaffolded fixed
AsAd/Ac7s2h → `trap`; unguided `none` → `avoid`; checkpoint `none` → `cite`;
assessment steps use cue kind `none` (no pressHints).

Map turn barrels before you bet flop `teachSpec` (LPT-312): explain
SoftPulse advances BARREL → GIVE-UP → MAP; guided `none` → `ok`; scaffolded
`none` → `give`; unguided `none` → `avoid`; checkpoint `none` → `list`;
assessment steps use cue kind `none` (no pressHints).

Compose river value and bluffs `teachSpec` (LPT-315): explain SoftPulse
advances VALUE → BLUFF → HOLD; guided fixed AsAd/Ac9s4h2d7c → `val`;
scaffolded `none` → `block`; unguided `none` → `check`; checkpoint `none` →
`rule`; assessment steps use cue kind `none` (no pressHints).

Write your default strategy book `teachSpec` (LPT-334): explain SoftPulse
advances LEAK → BOOK → REVIEW; guided `none` → `spec`; scaffolded `none` →
`book`; unguided `none` → `sched`; checkpoint `none` → `base`; assessment
steps use cue kind `none` (no pressHints).

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

Hand families classify Hint rewrite is `alignLessonActionCopy` falling
through to `dealtLessonTableScene` + `alignStartingHandCopy` when there is
no action spot (LPT-134). Catalog `accessibilityText` still names authored
76s / 72o; isomorphic remaps on densified classify scenes must rename the
Hint to the dealt holes. The next densified classify step that remaps hero
holes copies that path instead of raw `accessibilityText`.

Open or fold UTG trash Oops rewrite (LPT-164) extends
`alignStartingHandCopy` so English decade-compound names (`Seventy-two
offsuit`) match the same template holes as `seven-two offsuit` and become
the dealt spoken form (`Eight-five offsuit`). `alignLessonActionSubmitResult`
already runs on the grade path; catalog bank copy may keep the decade form.
The next trash / low-rank Oops line that uses a decade compound copies that
alias instead of hard-coding 72o on the dock.

Versus an open AQs checkpoint remap (LPT-173) splits
`LessonStartingHandFamily.strongSuitedBroadway` (Ace+broadway suited or
KQs) from weaker `suitedBroadway` so preflop isomorphic deals for value
3-bet templates never land on QTs / JTs / KTs. Deal helpers are
`_dealStrongSuitedBroadway` / `_dealWeakSuitedBroadway` in
`lesson_card_deal.dart`. The next value-3-bet suited-broadway template
copies that strong bucket.

Navigate 3-bet pots unguided AKo remap (LPT-406) splits
`LessonStartingHandFamily.strongOffsuitBroadway` (Ace+broadway offsuit or
KQo) from weaker `offsuitBroadway` so squeeze / value templates never land
on JTo / KJo / QTo. Deal helpers are `_dealStrongOffsuitBroadway` /
`_dealWeakOffsuitBroadway` in `lesson_card_deal.dart`. The next strong
offsuit-broadway template copies that strong bucket.

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

Oops Continue remount (LPT-71) is `clearFeedbackForRetry`: it clears
Hint-used, SoftPulse wave flags, and felt-deal ready when bumping
`bindGeneration`, so same-concept quiet steps (`lessonFrameSameConceptQuietIds`)
can Hint-reopen SoftPulse on the fresh deal. The next miss-retry remount
copies that reset instead of leaving Hint spent.

Quiet multi-suit remaining presses (LPT-72) are
`LessonSuitBoardTable.build` reporting untapped `h/d/c/s` count even when
`showGuidance` is false after a SoftPulse wave closes. The next
same-concept quiet multi-press board that gates SoftPulse on Hint copies
that remaining-press report instead of tying it to SoftPulse visibility.

Button and blinds scaffolded SoftPulse (LPT-73) keeps
`LessonActivityController.showTargetCue` off until Hint
(`lessonFrameBlindsSoftPulseWaitsForHint`) so Hint stays enabled — without
breaking Best five kicker SoftPulse-on-by-default (LPT-63). When Hint
unlocks a D / SB / BB puck SoftPulse and that puck is not on the felt yet,
`FeltTableView` falls back to the seat ring. The next blinds scaffolded
seat ask copies that unlock gate and puck-missing seat fallback.

Hand ranks explain Nice! feedback (LPT-74) is
`dialogue(..., { okFeedback })` → private-bank `explainGrading.feedback`,
read by `gradeCourseResponse` before falling back to `accessibilityText`.
Hand ranks explain uses "High card, then pair, then flush." Best five
explain (LPT-76) uses "Exactly five cards — leave the extras out." Streets
explain (LPT-79) uses "Preflop → flop → turn → river." Acting order
explain (LPT-147) uses "UTG → HJ → CO → BTN." Live table habits
explain (LPT-199) uses "Watch → Say → Cover → Wait." The next
`coach_dialogue` explain whose ask ends in a tap prompt copies that
authored why line instead of reusing the ask as Nice! copy.

Every SoftPulse `coach_dialogue` explain now authors that Nice! line
(LPT-624): the remaining 76 explains (S1–S7) got `okFeedback` →
`explainGrading` built from their cue chips in press order (for example
"Fold → Check → Call.", "SPR → Low → High."), written as a short why, never
the idle ask, a Tap prompt, or `accessibilityText`. `scan_content_gaps
--gap nice-ladder` is 0, and `lpt624_explain_nice_ladder_test.dart` locks
the list. A new SoftPulse explain ships its `okFeedback` in the same PR.

Curriculum-split SoftPulse explain successors (LPT-669): every
`coach_dialogue` SoftPulse explain with authored `teachSpec.cues` is a
table-tap SoftPulse walk (`isTableRegionTapActivity` reads those cues;
`resolveCoachDialogueVisual` keeps dedicated parent visuals and falls
through to `authoredCues` cue-tile SoftPulse for successors whose labels
do not match the parent demo). Do not leave a split SoftPulse explain on
Continue-only. `lpt669_split_softpulse_explain_maps_test.dart` locks the
catalog rule so later `lessonSplitMap` batches cannot reintroduce the gap.

Best five kicker showdown SoftPulse (LPT-75) is the framed
`LessonTableStage` for `act-01-02-02-scaffolded-kicker`: `cueSeatIndex: 0`
with `LessonTableCue.none`, so one gold ring on the You seat pod — not
`LessonTableCue.hero` (which expands to both hole SoftPulses). The next
region-tap showdown that cues "your cards" as one answer copies that seat
cue instead of dual hole SoftPulse.

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

How pots open-pot densify (LPT-84, `act-01-05-01-unguided-pot`) SoftPulses
the correct chip-amount dock choice after Hint via the same
`pulseChoiceId: _framedDockPulseChoiceId` gate as fold-win / showdown —
Hint must not unlock an empty SoftPulse wave. The next densify chip-total
dock that waits for Hint copies that `pulseChoiceId` pass.

Full-ring / `9-max` action spots (LPT-209) resolve nine seats through
`resolveLessonActionFeltLayout` / `lessonActionSpotIsNineMax` in
`lesson_action_felt_layout.dart` when the street label names `9-max`. The
next full-ring poker-action dock copies that nine-seat layout instead of
the six-max default under a nine-handed coach line.

Toy-hand authored pot / street bets (LPT-97) are
`shouldApplyLessonActionFeltMoney` + completed-line parsing in
`resolveLessonActionFeltMoney` (`lesson_action_felt_money.dart`): a labeled
`potLabel` paints even when `facingBet` is false, and preflop lines like
"BB calls your open" / "Blinds fold" place the open (and call) street bets
so Play a full toy hand scaffolded streets show Pot 13 / Pot 9 on
`LessonTableStage` instead of blinds-only defaults. Preflop folds-to-you
("Pot 3", no board, no street bets) does not take that gate — applying the
zero-bet list would pull posted SB/BB chips into the center. The next
authored multi-step hand whose coach names a completed pot copies that
apply gate instead of dropping money when SoftPulse owns the dock.

Bet, raise, all-in checkpoint-names (LPT-78) sets
`identifyUnavailable: true` on its `LessonActionSpot` so Raise and Call stay
live-looking on the unanswered dock — same gate as Fold, check, call
`checkpoint-legal`. Capstone transfer hands (`act-07-10-0*-hand`) copy that
flag on every street spot so Jam/Raise mistakes stay live when checked to
(LPT-670). The next action-naming quiz or Capstone hand copies that flag
instead of showing `(off)` chrome that spoils which label is legal.

Section 1 jump ranks (LPT-107) is `handRanksShowdownSpot` /
`dealShowdownOrderCards` for `act-01-06-02-jump-ranks` (Flush → Straight →
Two pair on You / Sam / Jo), rendered by `LessonShowdownOrderTable` like Hand
ranks compare — not `LessonMadeHandTable` plus under-felt hand-class chips.

Acting order checkpoint-full (LPT-148) passes flop `boardCodes` (`Qs 7c 2d`)
on the framed `LessonTableStage` for `act-02-01-02-checkpoint-full` — same
board as scaffolded-post — so FLOP street chrome matches the "Six-max flop"
ask. The next seat-map checkpoint whose coach names a street copies that
board pass instead of a blinds-only empty board.
The next jump-test rank order copies that showdown-seat path.

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

Finishing the last incomplete lesson of a catalog section shows the
section-end ceremony after Lesson Complete: `RexMascot` celebrating, the
section order and title, and one CONTINUE into Home on the next section.
Reviews of an already-finished section skip it.

The locked Live Training hub names the Home lesson that unlocks it for
signed-in learners. It does not say Section 2. Anonymous guests see
**Create an account before Live Training.** (not Baseline jump check) with
a Create-an-account CTA (LPT-697). The warm-up hub names **Section 4 jump
check** when random Live is still gated — not “Section 4 jump test”.

A learning screen that is a form, a wall of text, or a silent pop back to
Home misses this loop. File one ticket per missing beat.

### Shipped

`LessonFeedbackSheet` (`lib/ui/course/widgets/lesson_feedback_sheet.dart`)
uses `RexMascot` with `RexMood.celebrate` on a right answer and
`RexMood.think` on a miss. `LessonResultScreen`
(`lib/ui/screens/lesson_result_screen.dart`) draws `RexMascot` with
`RexMood.celebrate` and Duo celebration cards for TOTAL XP and the daily
goal (LPT-39). When goal minutes are unknown, the second card shows
accepted accuracy. Embedded CONTINUE (`standalone: false`) calls
`continueLearningAsGuest` when the anonymous draft is still pre-shell so
AppRoot remounts Home instead of Welcome (LPT-70).

`SectionCompleteScreen` (`lib/ui/screens/section_complete_screen.dart`) is
the section-end ceremony (LPT-793). `LessonResultScreen` CONTINUE
push-replaces it when `completedSection` is set; the runner fills that from
`CourseCatalog.sectionNewlyCompletedByLesson`. The next section-payoff
screen copies Rex celebrate + one elevated CONTINUE.

The locked Live Training hub copy for signed-in course-locked learners is
`liveTrainingLockedMessage` (`lib/models/live_access.dart`), which names
Baseline jump check via `kLiveWarmUpUnlockLessonTitle`. The gate is the
Home node `lesson-02-07-02-section-two-jump`. The snackbar
`liveTrainingLockedSnack` uses the same title. Anonymous guests use
`LiveAccessSnapshot.anonymous()` / `liveTrainingAnonymousLockedMessage`
(**Create an account before Live Training.**) with a Theme elevated
**Create an account** CTA to `pushSaveProgressAuth` (LPT-697) —
`liveAccessProvider` must not surface Baseline jump check to guests.
Warm-up hub copy is `liveTrainingWarmUpHubMessage`, naming **Section 4
jump check** via `kLiveUnrestrictedUnlockLessonTitle`
(`lesson-04-10-02-section-four-jump-test`).
`liveTrainingWarmUpUnrestrictedSnack` uses the same title.

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
| Your two cards | Your hole cards on the felt; Hint keeps "two cards" under board deuce remap (LPT-791); Nice! keeps "Those two stay" (LPT-797); densify coach stem-only (LPT-792); agent `tree` / `wait-gold` report gold SoftPulse on hero hole SoftPulse under seat Semantics (LPT-840) | — |
| Suits | Suit taps on board cards; explain SoftPulse hearts → diamonds → clubs → spades (LPT-353); explain Hint per-press suit tip not completion a11y (LPT-813); SoftPulse-off densify stem non-spoiling (no Hearts/diamonds/clubs/spades order) on guided idle / scaffolded / checkpoint (LPT-814); unit `unit-01-01-02-suits-and-ranks` (LPT-83 split) | — |
| Ranks | Board ranks low to high; SoftPulse cues rank-2 → rank-T → rank-A (LPT-370); unit `unit-01-01-02-suits-and-ranks` (LPT-83) | — |
| Pairs and suited | Suited / pair seats; scaffolded pressHints (LPT-82); checkpoint SoftPulse-off densify stem non-spoiling (LPT-804); guided densify uses seat-deal full table (no Them/You overflow; SoftPulse on suited seat; densify stem non-spoiling) (LPT-815 / LPT-816); unit `unit-01-01-02-suits-and-ranks` (LPT-83) | — |
| Dealer button | D chip on the button seat on the felt; explain SoftPulse cue D only — SB/BB presses belong to Small and big blinds (curriculum residual LPT-724); guided SoftPulse-quiet densify stem non-spoiling (no D-chip choice) (LPT-836); unit `unit-01-01-03-blinds-and-button` (LPT-87 split) | — |
| Small and big blinds | explain SoftPulse cues SB → BB; scaffolded SoftPulse-quiet densify stem non-spoiling (no BB choice) (LPT-830); checkpoint SoftPulse-off densify stem non-spoiling (no SB geometry) (LPT-831); unit `unit-01-01-03-blinds-and-button` (LPT-87 split) | — |
| Blinds post first | explain SoftPulse cues BLINDS → DEAL; unguided SoftPulse-quiet densify stem non-spoiling (no before-deal choice) (LPT-832); unit `unit-01-01-03-blinds-and-button` (LPT-87 split) | — |
| Order hand ranks | Showdown seats weakest to strongest; unit `unit-01-02-what-beats-what` (LPT-90 split) | scaffolded pressHints one-per-press (LPT-667) |
| Pairs, straights, flushes | explain SoftPulse cues PAIR → STRAIGHT → FLUSH; unit `unit-01-02-what-beats-what` (LPT-90 split) | — |
| Compare finished hands | explain SoftPulse cues FULL HOUSE → TRIPS → TWO PAIR; unguided/checkpoint showdown SoftPulse rejects a wrong seat as a miss (`strictOrder`, LPT-707); unit `unit-01-02-what-beats-what` (LPT-90 split) | — |
| Best five from seven | The five cards that play; You / Them / Board; unit `unit-01-02-what-beats-what` (LPT-93 split); guided SoftPulse-quiet densify stem non-spoiling (no Top pair / best kicker) (LPT-835) | scaffolded pressHints one-per-press (LPT-667) |
| Kickers break ties | explain SoftPulse cues SAME PAIR → KICKER; unit `unit-01-02-what-beats-what` (LPT-93 split) | — |
| When the board plays | explain SoftPulse cues BOARD → CHOP; unit `unit-01-02-what-beats-what` (LPT-93 split) | — |
| Fold | Fold under a flop on the felt; explain SoftPulse cue FOLD only — CHECK/CALL presses belong to Check and Call (curriculum residual LPT-731); unit `unit-01-03-five-actions` (LPT-96 split) | — |
| Check | explain SoftPulse cues NO BET → CHECK; unit `unit-01-03-five-actions` (LPT-96 split) | — |
| Call | explain SoftPulse cues BET → CALL; unit `unit-01-03-five-actions` (LPT-96 split) | — |
| Bet | Bet under a flop on the felt; explain SoftPulse cue BET only — RAISE/ALL-IN presses belong to Raise and All-in (curriculum residual LPT-733); unit `unit-01-03-five-actions` (LPT-100 split) | — |
| Raise | explain SoftPulse cues FACING BET → RAISE; unit `unit-01-03-five-actions` (LPT-100 split) | — |
| All-in | explain SoftPulse cues STACK → ALL-IN; unit `unit-01-03-five-actions` (LPT-100 split) | — |
| Four streets | Board advances by street; seat order on the table; explain SoftPulse cues PREFLOP → FLOP → TURN → RIVER (LPT-635); unit `unit-01-04-streets` (LPT-103 split) | scaffolded pressHints one-per-press (LPT-667) |
| Action order | explain SoftPulse cues BIG BLIND → CLOCKWISE → BUTTON; checkpoint SoftPulse-off densify stem non-spoiling (no SB) (LPT-808); unit `unit-01-04-streets` (LPT-103 split); objective "Know who acts first before and after the flop" so the checkpoint grades this lesson's concept (curriculum residual LPT-737) | — |
| When a street ends | explain SoftPulse cues BETS MATCHED → NEXT STREET; densify SoftPulse-quiet stem non-spoiling (no Bets matched) (LPT-837); unit `unit-01-04-streets` (LPT-103 split) | — |
| Win when everyone folds | Fold win on the felt; explain SoftPulse cue FOLD WIN only — SHOWDOWN/SIDE POT presses belong to Win at showdown and Main and side pots (curriculum residual LPT-738); densified SoftPulse one gold via `guideRegion` (LPT-525); unit `unit-01-05-winning-pots` (LPT-106 split) | — |
| Win at showdown | explain SoftPulse cues RIVER CALL → SHOWDOWN → BEST FIVE; densify SoftPulse-quiet stem non-spoiling (no Showdown) (LPT-839); unit `unit-01-05-winning-pots` (LPT-106 split) | — |
| Main and side pots | explain SoftPulse cues MAIN POT → SIDE POT; checkpoint SoftPulse-off densify stem non-spoiling (LPT-782); unit `unit-01-05-winning-pots` (LPT-106 split) | — |
| Play a full toy hand | Blinds, You act, Ending; explain SoftPulse cues BLINDS → YOU ACT → ENDING (LPT-635) | scaffolded pressHints one-per-press (LPT-667) |
| Section 1 jump check | Ranks: showdown seats Flush → Straight → Two pair; seats UTG → BTN | — |
| Seat labels | Six-max seats labeled on the table; explain SoftPulse cues D (LPT-635); unguided SoftPulse-quiet densify stem non-spoiling (no Cutoff / CO) (LPT-834); unit `unit-02-01-position-power` (LPT-114 split) | — |
| Blind labels | explain SoftPulse cues SB → BB; scaffolded SoftPulse-quiet densify stem non-spoiling (no SB or BB) (LPT-833); unit `unit-02-01-position-power` (LPT-114 split) | — |
| Later seats play better | explain SoftPulse cues D; checkpoint SoftPulse-off densify stem non-spoiling (LPT-783); unit `unit-02-01-position-power` (LPT-114 split); `act-02-01-01-guided-btn` moved here from Seat labels (curriculum residual LPT-739) | — |
| Preflop order | UTG, HJ, CO, BTN on the table; explain SoftPulse cues UTG → HJ → CO → BTN (LPT-635); unit `unit-02-01-position-power` (LPT-117 split) | scaffolded pressHints one-per-press (LPT-667) |
| Postflop order | explain SoftPulse cues SB → BTN; checkpoint SoftPulse-off densify stem non-spoiling (LPT-803); unit `unit-02-01-position-power` (LPT-117 split) | — |
| Wait your turn | explain SoftPulse cues EARLIER SEATS → YOUR TURN; densify SoftPulse-quiet stem non-spoiling (no Wait) (LPT-838); unit `unit-02-01-position-power` (LPT-117 split) | — |
| Pocket pairs | Pairs on the felt; explain SoftPulse cue Pairs only — Broadways/Suited aces/Connectors presses belong to Broadways and suited aces and Connectors versus trash (curriculum residual LPT-740); densified SoftPulse one gold via `guideRegion` (LPT-634); unit `unit-02-02-starting-hands` (LPT-121 split) | — |
| Broadways and suited aces | explain SoftPulse cues BROADWAY → SUITED ACE; scaffolded SoftPulse-quiet densify stem non-spoiling (no Broadway) (LPT-841); unit `unit-02-02-starting-hands` (LPT-121 split) | — |
| Connectors versus trash | explain SoftPulse cues CONNECTORS → TRASH; unguided SoftPulse-quiet densify stem non-spoiling (no Suited connector) (LPT-842); checkpoint SoftPulse-off densify stem non-spoiling (LPT-784); unit `unit-02-02-starting-hands` (LPT-121 split) | — |
| Fold trash early | Early on the felt; explain SoftPulse cue EARLY only — BUTTON/LIVE 3x presses belong to Widen on the button and Open strong hands (curriculum residual LPT-741); unit `unit-02-03-open-fold` (LPT-124 split) | — |
| Open strong hands | explain SoftPulse cues STRONG → LIVE SIZE; scaffolded Hint SoftPulse unlocks on hero holes (LPT-678 / LPT-679); unit `unit-02-03-open-fold` (LPT-124 split) | — |
| Widen on the button | explain SoftPulse cues BUTTON → WIDER; unit `unit-02-03-open-fold` (LPT-124 split) | — |
| Fold weak hands | Fold on the felt; explain SoftPulse cue FOLD only — CALL/3-BET presses belong to Call in position and Value 3-bet (curriculum residual LPT-743); unit `unit-02-04-facing-raise` (LPT-127 split) | — |
| Call in position | explain SoftPulse cues PLAYABLE → IN POSITION → CALL; unit `unit-02-04-facing-raise` (LPT-127 split) | — |
| Value 3-bet | explain SoftPulse cues STRONG → 3-BET; unit `unit-02-04-facing-raise` (LPT-127 split) | — |
| Chips to big blinds | Chips→BB on the felt; explain SoftPulse cue CHIPS→BB only — SHORTER/DEPTH presses belong to Shorter stack is effective and Stack depth (curriculum residual LPT-748); checkpoint SoftPulse-off densify stem non-spoiling (LPT-785); unit `unit-02-05-stacks` (LPT-130 split) | — |
| Shorter stack is effective | explain SoftPulse cues SHORTER → EFFECTIVE; unit `unit-02-05-stacks` (LPT-130 split) | — |
| Stack depth | explain SoftPulse cues 50BB → 100BB → 200BB; unit `unit-02-05-stacks` (LPT-130 split) | — |
| Follow the action | Watch on the felt; explain SoftPulse cue WATCH only — SAY/COVER/WAIT presses belong to Say your action and Protect cards, wait your turn (curriculum residual LPT-749); unit `unit-02-06-table-habits` (LPT-133 split) | — |
| Say your action | explain SoftPulse cues SAY → CHIPS; scaffolded SoftPulse-quiet densify stem non-spoiling (no Say "raise") (LPT-843); unit `unit-02-06-table-habits` (LPT-133 split) | — |
| Protect cards, wait your turn | explain SoftPulse cues COVER → WAIT; unguided SoftPulse-quiet densify stem non-spoiling (no Keep a chip) (LPT-844); checkpoint SoftPulse-off densify stem non-spoiling (LPT-786); unit `unit-02-06-table-habits` (LPT-133 split) | — |
| Open on a full ring | Nine, Same, Position; explain SoftPulse cues NINE → SAME → POSITION (LPT-635); unit `unit-02-07-baseline-checkpoint` (LPT-668 split) | — |
| Face a raise with a plan | explain SoftPulse cues OPEN → PLAN; unit `unit-02-07-baseline-checkpoint` (LPT-668 split) | — |
| Keep live habits while deciding | explain SoftPulse cues COVER → WAIT; checkpoint SoftPulse-off densify stem non-spoiling (LPT-788); unit `unit-02-07-baseline-checkpoint` (LPT-668 split) | — |
| Baseline jump check | Family / stack densified felt asks in the frame bubble (LPT-221); jump-family SoftPulse one gold via `guideRegion` (LPT-634) | — |
| Pot and stacks | Pot, Stacks on the felt; explain SoftPulse cue POT → STACKS only — BUTTON/WHO ACTS presses belong to Button and action seat (curriculum residual LPT-750); checkpoint SoftPulse-off densify stem non-spoiling (LPT-787); unit `unit-03-01-reading-table` (LPT-140 split) | — |
| Button and action seat | explain SoftPulse cues BUTTON → WHO ACTS; scaffolded SoftPulse-quiet densify stem non-spoiling (no UTG / Seat left of the big blind) (LPT-845); unit `unit-03-01-reading-table` (LPT-140 split) | — |
| Words are binding | explain SoftPulse cues SAY → BINDING; unguided SoftPulse-quiet densify stem non-spoiling (no Raise stands / verbal is binding) (LPT-846); unit `unit-03-01-reading-table` (LPT-140 split) | — |
| Made hands | Made on the felt; explain SoftPulse cue MADE only — DRAW/SDV/AIR presses belong to Draws versus showdown value and Recognize air (curriculum residual LPT-751); fixed steps author suit-rotated `deal.variants` (LPT-384); unit `unit-03-02-flop-classes` (LPT-143 split) | — |
| Draws versus showdown value | explain SoftPulse cues DRAW → SHOWDOWN VALUE; scaffolded SoftPulse-quiet densify stem non-spoiling (no Strong draw / nut flush draw; board+holes for alignLessonTableCopy) (LPT-847); checkpoint SoftPulse-off densify stem non-spoiling (no Draw tile / template cards) (LPT-805); unit `unit-03-02-flop-classes` (LPT-143 split) | — |
| Recognize air | explain SoftPulse cues AIR → FOLD EQUITY; unit `unit-03-02-flop-classes` (LPT-143 split) | — |
| Clean versus dirty outs | Clean, Dirty on the felt; explain SoftPulse cue CLEAN → DIRTY only — PRICE press belongs to Pot odds versus equity (curriculum residual LPT-752); densified frame asks (LPT-279); unguided SoftPulse one gold via `guideRegion` (LPT-634); unit `unit-03-03-outs-price` (LPT-146 split) | — |
| Pot odds versus equity | explain SoftPulse cues PRICE → POT → EQUITY; unit `unit-03-03-outs-price` (LPT-146 split) | — |
| Implied odds when deep | explain SoftPulse cues DEEP → IMPLIED ODDS; unit `unit-03-03-outs-price` (LPT-146 split) | — |
| Value bet the flop | Value on the felt; explain SoftPulse cue VALUE only — C-BET/CHECK/CALL/FOLD/RAISE presses belong to C-bet selectively and Raise, call, or fold with a plan (curriculum residual LPT-753); postflop TPTK/broadway remap fingerprint (LPT-311); unit `unit-03-04-flop-decisions` (LPT-151 split) | — |
| C-bet selectively | explain SoftPulse cues PREFLOP RAISER → C-BET; unit `unit-03-04-flop-decisions` (LPT-151 split) | — |
| Raise, call, or fold with a plan | explain SoftPulse cues RAISE → CALL → FOLD; unit `unit-03-04-flop-decisions` (LPT-151 split) | — |
| Brick or changing turn | Brick, Change on the felt; explain SoftPulse cue BRICK → CHANGE only — BARREL/DELAY presses belong to Second barrel and Delayed aggression (curriculum residual LPT-754); unit `unit-03-05-turn-decisions` (LPT-154 split) | — |
| Second barrel | explain SoftPulse cues BRICK → BARREL; unit `unit-03-05-turn-decisions` (LPT-154 split) | — |
| Delayed aggression | explain SoftPulse cues CHECKED BACK → BET TURN; checkpoint SoftPulse-off densify stem non-spoiling (no Often give up / template cards) (LPT-807); unit `unit-03-05-turn-decisions` (LPT-154 split) | — |
| River value | Value on the felt; explain SoftPulse cue VALUE only — BLUFF/CATCH/FOLD presses belong to Credible bluffs and Bluff-catch or fold (curriculum residual LPT-755); densified frame ask (LPT-343); unit `unit-03-06-river-decisions` (LPT-157 split) | — |
| Credible bluffs | explain SoftPulse cues STORY → BLUFF; unit `unit-03-06-river-decisions` (LPT-157 split) | — |
| Bluff-catch or fold | explain SoftPulse cues BLUFF-CATCH → FOLD; unit `unit-03-06-river-decisions` (LPT-157 split) | — |
| Stronger hands multiway | Stronger on the felt; explain SoftPulse cue STRONGER only — FEWER/NUTS presses belong to Bluff less multiway and Nut potential and position (curriculum residual LPT-756); unit `unit-03-07-multiway` (LPT-160 split) | — |
| Bluff less multiway | explain SoftPulse cues CROWD → FEWER BLUFFS; unit `unit-03-07-multiway` (LPT-160 split) | — |
| Nut potential and position | explain SoftPulse cues NUTS → POSITION; unit `unit-03-07-multiway` (LPT-160 split) | — |
| Weak top pair | Top pair on the felt; explain SoftPulse cue TOP PAIR only — PRICES/PASSIVE/CROWDS presses belong to Fold bad prices and Passive calls and crowd bluffs (curriculum residual LPT-757); unit `unit-03-08-leak-repair` (LPT-163 split) | — |
| Fold bad prices | explain SoftPulse cues BAD PRICE → FOLD; unit `unit-03-08-leak-repair` (LPT-163 split) | — |
| Passive calls and crowd bluffs | explain SoftPulse cues PASSIVE → CROWD; unit `unit-03-08-leak-repair` (LPT-163 split) | — |
| Section 3 jump check | densified frame asks (LPT-390) | — |
| A seat is a range | One hand, Range, Update; densified frame asks (LPT-403); unguided/checkpoint SoftPulse one gold via `guideRegion` (LPT-634); unit `unit-04-01-ranges` (LPT-169 split) | — |
| Action moves ranges | explain SoftPulse cues RAISE → NARROWER → CALL; unit `unit-04-01-ranges` (LPT-169 split) | — |
| No exact hand too early | explain SoftPulse cues ONE HAND → RANGE; unit `unit-04-01-ranges` (LPT-169 split) | — |
| Value 3-bet | 3-bet, Ranges, Squeeze; unit `unit-04-02-threebet` (LPT-172 split) | — |
| Facing a 3-bet | explain SoftPulse cues 3-BET → FOLD → CONTINUE; unit `unit-04-02-threebet` (LPT-172 split) | — |
| Squeeze spots | explain SoftPulse cues OPEN → CALLERS → SQUEEZE; unit `unit-04-02-threebet` (LPT-172 split) | — |
| Build a multi-street plan | Flop, Turn, River; densified frame ask (LPT-407); checkpoint SoftPulse one gold via `guideRegion` (LPT-634); unit `unit-04-03-continuation` (LPT-176 split) | — |
| Abort when the board changes | explain SoftPulse cues BOARD CHANGES → STOP; unit `unit-04-03-continuation` (LPT-176 split) | — |
| Match pot size to strength | explain SoftPulse cues MEDIUM → SMALL POT; unit `unit-04-03-continuation` (LPT-176 split) | — |
| Value or pressure size | Value, Pressure, Size; densified frame ask (LPT-410); unguided SoftPulse one gold via `guideRegion` (LPT-634); unit `unit-04-04-sizing` (LPT-179 split) | — |
| Nearby live sizes | explain SoftPulse cues NEARBY → STORY; unit `unit-04-04-sizing` (LPT-179 split) | — |
| Avoid tiny sizes | explain SoftPulse cues TINY → VALUE; unit `unit-04-04-sizing` (LPT-179 split) | — |
| Estimate SPR | SPR, Low, High; densified frame ask (LPT-412); scaffolded stacks match SPR ~1 (LPT-413); checkpoint SoftPulse-off densify stem non-spoiling (LPT-812); unit `unit-04-05-spr` (LPT-182 split) | — |
| Commit at low SPR | explain SoftPulse cues LOW SPR → COMMIT; unit `unit-04-05-spr` (LPT-182 split) | — |
| Stay flexible at high SPR | explain SoftPulse cues HIGH SPR → FLEXIBLE; unit `unit-04-05-spr` (LPT-182 split) | — |
| Tag high participation | Enters, Calls, Folds; densified frame asks (LPT-416); unit `unit-04-06-calling-station` (LPT-186 split) | participation note, observation bundle |
| Tag low folding | explain SoftPulse cues FOLDS TO BETS → STICKY; scaffolded SoftPulse-quiet densify stem non-spoiling (no Sticky) (LPT-824); checkpoint SoftPulse-off densify stem non-spoiling (no Bundle) (LPT-810); unit `unit-04-06-calling-station` (LPT-186 split) | — |
| Observation versus certainty | explain SoftPulse cues OBSERVATION → SAMPLES; unguided SoftPulse-quiet densify stem non-spoiling (no Low conf) (LPT-822); unit `unit-04-06-calling-station` (LPT-186 split) | — |
| The Calling Station model | Station, High, Low; STATION caption Working label (LPT-789); scaffolded/unguided SoftPulse one gold (LPT-424); densified frame asks (LPT-420); scaffolded SoftPulse-quiet densify stem non-spoiling (no Working model) (LPT-817); unguided SoftPulse-quiet densify stem non-spoiling (no Station) (LPT-818); unit `unit-04-06-calling-station` (LPT-189 split) | label quizzes |
| Spot a Calling Station | explain SoftPulse cues STICKY CALLS → RARE FOLDS; unguided SoftPulse-quiet densify stem non-spoiling (no Station) (LPT-818); unit `unit-04-06-calling-station` (LPT-189 split) | — |
| Small samples, low confidence | explain SoftPulse cues SAMPLE → CONFIDENCE; checkpoint SoftPulse-off densify stem non-spoiling (no Low conf) (LPT-811); unit `unit-04-06-calling-station` (LPT-189 split) | — |
| Value wider versus Calling Station | Value, Bluffs, Cite; unit `unit-04-06-calling-station` (LPT-192 split) | — |
| Bluff less without equity | explain SoftPulse cues RARELY FOLDS → GIVE UP; checkpoint SoftPulse-off densify stem non-spoiling (LPT-780); unit `unit-04-06-calling-station` (LPT-192 split) | — |
| Cite the sticky-call tendency | explain SoftPulse cues EVIDENCE → UNKNOWN; unit `unit-04-06-calling-station` (LPT-192 split) | — |
| Tag narrow entry | Rare, Enter, Mean It; unit `unit-04-07-nit` (LPT-195 split) | entry quizzes |
| Tag strong aggression | explain SoftPulse cues RARE ENTRY → BIG AGGRESSION; scaffolded SoftPulse-quiet densify stem non-spoiling (no Strong aggression / Strong heat) (LPT-827); checkpoint SoftPulse-off densify stem non-spoiling (LPT-763); unit `unit-04-07-nit` (LPT-195 split) | — |
| Wait for samples | explain SoftPulse cues TWO FOLDS → MORE HANDS; unguided SoftPulse-quiet densify stem non-spoiling (no No — sample too small / Wait) (LPT-826); unit `unit-04-07-nit` (LPT-195 split) | — |
| The Nit model | Nit, Narrow, Respect; densified SoftPulse one gold (LPT-440); checkpoint SoftPulse-off densify stem non-spoiling (LPT-765); unit `unit-04-07-nit` (LPT-198 split) | label quizzes |
| Spot a Nit | explain SoftPulse cues FEW HANDS → BIG RAISES; unguided SoftPulse-quiet densify stem non-spoiling (no Nit) (LPT-819); unit `unit-04-07-nit` (LPT-198 split) | — |
| Steal more versus Nits | Steal, Credit, Explode; checkpoint SoftPulse one gold via `guideRegion` (LPT-634); unit `unit-04-07-nit` (LPT-202 split) | respect reason |
| Respect their heavy action | explain SoftPulse cues NIT RAISES → CREDIT; checkpoint SoftPulse-off densify stem non-spoiling (LPT-778); unit `unit-04-07-nit` (LPT-202 split) | — |
| Cite the narrow-entry read | explain SoftPulse cues EVIDENCE → UNKNOWN; unit `unit-04-07-nit` (LPT-202 split) | — |
| Tag extreme entry | Raise, Barrel, Count; densified SoftPulse one gold (LPT-462); unit `unit-04-08-maniac` (LPT-205 split) | entry quizzes |
| Tag constant aggression | explain SoftPulse cues EVERY STREET → WEAK SHOWDOWNS; checkpoint SoftPulse-off densify stem non-spoiling (LPT-770); unit `unit-04-08-maniac` (LPT-205 split) | — |
| Notes without ego | explain SoftPulse cues FREQUENCIES → NO EGO; unit `unit-04-08-maniac` (LPT-205 split) | — |
| The Maniac model | Maniac, Entry, Aggro; densified SoftPulse one gold (LPT-489); explain Nice! short ladder (LPT-490); checkpoint SoftPulse-off densify stem non-spoiling (LPT-771); unit `unit-04-08-maniac` (LPT-208 split) | label quizzes |
| Spot a Maniac | explain SoftPulse cues CONSTANT RAISES → NEVER GIVES UP; unguided SoftPulse-quiet densify stem non-spoiling (no Maniac) (LPT-820); unit `unit-04-08-maniac` (LPT-208 split) | — |
| Widen value and bluff-catches | Wider, Hang, Ego; checkpoint SoftPulse one gold via `guideRegion` (LPT-634); unit `unit-04-08-maniac` (LPT-212 split) | call-wider reason |
| Cite the aggression read | explain SoftPulse cues EVIDENCE → UNKNOWN; checkpoint SoftPulse-off densify stem non-spoiling (LPT-781); unit `unit-04-08-maniac` (LPT-212 split) | — |
| Observation is not certainty | Observe, Samples, Showdowns; densified SoftPulse one gold (LPT-495); unit `unit-04-09-type-id` (LPT-215 split) | confidence quizzes |
| Confidence grows with samples | explain SoftPulse cues SAMPLES → SHOWDOWNS; scaffolded SoftPulse-quiet densify stem non-spoiling (no Rise) (LPT-823); checkpoint SoftPulse-off densify stem non-spoiling (LPT-777); unit `unit-04-09-type-id` (LPT-215 split) | — |
| Retire labels when evidence flips | explain SoftPulse cues NEW EVIDENCE → RETIRE; unguided SoftPulse-quiet densify stem non-spoiling (no Update / Calling Station model) (LPT-821); unit `unit-04-09-type-id` (LPT-215 split) | — |
| Same hand, different types | Cards, Seats, Evidence; unit `unit-04-10-exploits` (LPT-218 split) | — |
| Combine type, position, and stack | explain SoftPulse cues TYPE → POSITION → STACK; unit `unit-04-10-exploits` (LPT-218 split) | — |
| Section 4 jump check | jump-range SoftPulse one gold via `guideRegion` (LPT-634) | — |
| Prefer nut potential multiway | Nutted, Air, Domination; densify continue/priority panels omit decoy Them (LPT-722); checkpoint SoftPulse-off densify stem non-spoiling (LPT-723); unit `unit-05-01-multiway-ranges` (LPT-224 split) | — |
| Tighten speculative hands multiway | explain SoftPulse cues MULTIWAY → OOP → FOLD; unit `unit-05-01-multiway-ranges` (LPT-224 split) | — |
| Value thicker when callers stick | explain SoftPulse cues CALLERS → SET → BET; unit `unit-05-01-multiway-ranges` (LPT-224 split) | — |
| Depth pays speculative hands | Deep, Realize, Stack; unit `unit-05-02-deep-stacks` (LPT-227 split) | — |
| Don't stack off light deep | explain SoftPulse cues DEEP → ONE PAIR → FOLD; unit `unit-05-02-deep-stacks` (LPT-227 split) | — |
| Plan streets at high SPR | explain SoftPulse cues SPR → TURN → RIVER; unit `unit-05-02-deep-stacks` (LPT-227 split) | — |
| Estimate implied odds | Implied, Reverse, Second; densified SoftPulse one gold (LPT-515); checkpoint SoftPulse-off densify stem non-spoiling (LPT-734); unit `unit-05-03-implied-odds` (LPT-230 split) | — |
| Spot reverse implied odds | explain SoftPulse cues REVERSE → DOMINATED → FOLD; unit `unit-05-03-implied-odds` (LPT-230 split) | — |
| Skip dominated draws multiway | explain SoftPulse cues NON-NUT → MULTIWAY → SKIP; unit `unit-05-03-implied-odds` (LPT-230 split) | — |
| Thin value versus sticky callers | Thin, Catch, Barrels; densified SoftPulse one gold (LPT-516); checkpoint SoftPulse-off densify stem non-spoiling (LPT-736); unit `unit-05-04-thin-value` (LPT-233 split) | — |
| Catch wider versus aggression | explain SoftPulse cues MANIAC → BARREL → CALL; unit `unit-05-04-thin-value` (LPT-233 split) | — |
| Skip thin value versus overfolders | explain SoftPulse cues NIT → FOLDS → CHECK; unit `unit-05-04-thin-value` (LPT-233 split) | — |
| Read check-raises | X/R, Probe, Delay, Donk; densified SoftPulse one gold (LPT-517); unit `unit-05-05-lines-probes` (LPT-236 split) | — |
| Probes and delayed c-bets | explain SoftPulse cues PROBE → DELAY → PLAN; checkpoint SoftPulse-off densify stem non-spoiling (LPT-742); unit `unit-05-05-lines-probes` (LPT-236 split) | — |
| Donk bets are polarized | explain SoftPulse cues DONK → STRONG → AIR; unit `unit-05-05-lines-probes` (LPT-236 split) | — |
| Update each street | Action, Rewrite, Update; densified SoftPulse one gold (LPT-518); unit `unit-05-06-line-reading` (LPT-239 split) | — |
| Capped versus uncapped lines | explain SoftPulse cues CHECK → CAPPED → UNCAPPED; checkpoint SoftPulse-off densify stem non-spoiling (LPT-745); unit `unit-05-06-line-reading` (LPT-239 split) | — |
| Drop stale flop stories | explain SoftPulse cues FLOP → TURN → RE-PRICE; unit `unit-05-06-line-reading` (LPT-239 split) | — |
| Timing is soft evidence | Timing, Sizing, Clues; checkpoint SoftPulse-off densify stem non-spoiling (LPT-744); unit `unit-05-07-timing-sizing` (LPT-244 split) | — |
| Sizing is range language | explain SoftPulse cues TINY → BIG → RANGE; unit `unit-05-07-timing-sizing` (LPT-244 split) | — |
| No magic tells | explain SoftPulse cues TELL → MYTH → REJECT; unit `unit-05-07-timing-sizing` (LPT-244 split) | — |
| Spot tilted or stuck players | Stuck, Tilted, Gears; densified SoftPulse one gold (LPT-520); unit `unit-05-08-table-dynamics` (LPT-247 split) | — |
| Gear changes mid-session | explain SoftPulse cues GEAR → CHANGE → SAMPLE; scaffolded SoftPulse-quiet densify stem non-spoiling (no Gear change) (LPT-825); checkpoint SoftPulse-off densify stem non-spoiling (LPT-746); unit `unit-05-08-table-dynamics` (LPT-247 split) | — |
| Skip emotional pots | explain SoftPulse cues COOLER → CHASE → RESET; unit `unit-05-08-table-dynamics` (LPT-247 split) | — |
| Set a stop-loss | Quit, Guard, First; densified SoftPulse one gold (LPT-521); unit `unit-05-09-discipline` (LPT-250 split) | — |
| Bankroll fits stakes | explain SoftPulse cues BANKROLL → STAKES → DECLINE; unit `unit-05-09-discipline` (LPT-250 split) | — |
| End sessions early | explain SoftPulse cues TIRED → WILD → CASH OUT; checkpoint SoftPulse-off densify stem non-spoiling (LPT-747); unit `unit-05-09-discipline` (LPT-250 split) | — |
| Section 5 checkpoint | SoftPulse-off densify stems non-spoiling (LPT-717) | — |
| Spot range advantage | Range, Nut, Advantage; densified SoftPulse one gold (LPT-523); unit `unit-06-01-range-nut-adv` (LPT-254 split) | — |
| Spot nut advantage | explain SoftPulse cues NUTS → PAIRED → CALLER; unit `unit-06-01-range-nut-adv` (LPT-254 split) | — |
| Pressure when you own both | explain SoftPulse cues RANGE → NUTS → BET; checkpoint SoftPulse-off densify stem non-spoiling (LPT-764); unit `unit-06-01-range-nut-adv` (LPT-254 split) | — |
| Position realizes equity | Equity, Cash, Pos; densified SoftPulse one gold (LPT-524); checkpoint SoftPulse-off densify stem non-spoiling (LPT-766); unit `unit-06-02-eq-realize` (LPT-257 split) | — |
| Discount equity out of position | explain SoftPulse cues OOP → BARRELS → DISCOUNT; unit `unit-06-02-eq-realize` (LPT-257 split) | — |
| Aggression realizes equity | explain SoftPulse cues SEMI-BLUFF → FOLDS → OUTS; unit `unit-06-02-eq-realize` (LPT-257 split) | — |
| Spot capped ranges | Capped, Uncapped, Nuts; densified frame asks (LPT-636); unit `unit-06-03-capped` (LPT-260 split) | — |
| Respect uncapped aggression | explain SoftPulse cues RAISE → BET → RESPECT; unit `unit-06-03-capped` (LPT-260 split) | — |
| Attack capped ranges | explain SoftPulse cues CAPPED → THIN → BLUFF; checkpoint SoftPulse-off densify stem non-spoiling (no Attack) (LPT-809); unit `unit-06-03-capped` (LPT-260 split) | — |
| Recognize polarized sizing | Polar, Merged, Size; densified frame asks (LPT-637); unit `unit-06-04-polar-merged` (LPT-264 split) | — |
| Merged sizes for thin value | explain SoftPulse cues MERGED → MEDIUM → VALUE; unit `unit-06-04-polar-merged` (LPT-264 split) | — |
| Match size to shape | explain SoftPulse cues SIZE → SHAPE → MATCH; unit `unit-06-04-polar-merged` (LPT-264 split) | — |
| Overbet polar spots | Overbet, Polar, Geo; densified frame asks (LPT-638); unguided SoftPulse one gold (LPT-497); unit `unit-06-05-overbets` (LPT-267 split) | — |
| Plan geometric sizes | explain SoftPulse cues FLOP → TURN → RIVER; unit `unit-06-05-overbets` (LPT-267 split) | — |
| No random huge bets | explain SoftPulse cues HUGE → MEDIUM → AVOID; unit `unit-06-05-overbets` (LPT-267 split) | — |
| Bluff with the right blockers | Block, Use, No EV; densified frame asks (LPT-639); unguided SoftPulse one gold (LPT-498); unit `unit-06-06-blockers` (LPT-270 split) | — |
| Catch with unblockers | explain SoftPulse cues CATCH → UNBLOCK → BLUFFS; unit `unit-06-06-blockers` (LPT-270 split) | — |
| Blockers without fake EV | explain SoftPulse cues TWEAK → NO EV; unit `unit-06-06-blockers` (LPT-270 split) | — |
| Continue with stronger catchers | Defend, Bluff, Enough; densified frame asks (LPT-640); unguided SoftPulse one gold (LPT-499); unit `unit-06-07-min-defense` (LPT-273 split) | — |
| Fold dominated trash | explain SoftPulse cues THIRD PAIR → SCARY → FOLD; unit `unit-06-07-min-defense` (LPT-273 split) | — |
| No fake MDF math | explain SoftPulse cues MDF → INTUITION; unit `unit-06-07-min-defense` (LPT-273 split) | — |
| Mix strong hands sometimes | Mix, Purpose, Strong; unguided SoftPulse one gold Need a reason (LPT-500); densified frame asks (LPT-644); unit `unit-06-08-mixed` (LPT-277 split) | — |
| Types reduce mixing | explain SoftPulse cues TYPE → STATION → LESS; unit `unit-06-08-mixed` (LPT-277 split) | — |
| No mixing for its own sake | explain SoftPulse cues RANDOM → PURPOSE; unit `unit-06-08-mixed` (LPT-277 split) | — |
| Tighten up in 4-bet pots | 3-Bet, 4-Bet, Depth; unguided SoftPulse one gold Avoid ego (LPT-501); unit `unit-06-09-3bet4bet` (LPT-282 split) | — |
| Plan 3-bet pots by SPR | explain SoftPulse cues 3BET → 4BET → DEPTH; unit `unit-06-09-3bet4bet` (LPT-282 split) | — |
| No ego 4-bets | explain SoftPulse cues 4BET → EGO → AVOID; unit `unit-06-09-3bet4bet` (LPT-282 split) | — |
| Make hard folds | Hard, Cooler, Ego; unguided SoftPulse one gold Ego call (LPT-502); unit `unit-06-10-folds` (LPT-285 split) | — |
| Cooler or mistake? | explain SoftPulse cues COOLER → MISTAKE → REVIEW; unit `unit-06-10-folds` (LPT-285 split) | — |
| No ego call-downs | explain SoftPulse cues DUE → EGO → FOLD; unit `unit-06-10-folds` (LPT-285 split) | — |
| Note selective entry | Tight, Barrel, Sample; unguided SoftPulse one gold (LPT-494); unit `unit-06-11-tag` (LPT-288 split) | entry quizzes |
| Note disciplined aggression | explain SoftPulse cues CALLED → GIVES UP; unit `unit-06-11-tag` (LPT-288 split) | — |
| Wait for samples | explain SoftPulse cues TWO HANDS → NOTE BUNDLE; unit `unit-06-11-tag` (LPT-288 split) | — |
| The TAG model | Tight, Aggro, Model; unguided SoftPulse one gold (LPT-491); densified frame asks (LPT-648); unit `unit-06-11-tag` (LPT-291 split) | label quizzes |
| Spot a TAG | explain SoftPulse cues FOLDS MOST → PLANNED BARRELS; unit `unit-06-11-tag` (LPT-291 split) | — |
| TAG or Maniac? | explain SoftPulse cues ENTRY WIDTH → DISCIPLINE; unit `unit-06-11-tag` (LPT-291 split) | — |
| Respect TAG aggression | Credit, Tighter, No light; unit `unit-06-11-tag` (LPT-294 split) | respect check |
| No light bluffs into a TAG check-raise | explain SoftPulse cues CHECK-RAISE → FOLD; unit `unit-06-11-tag` (LPT-294 split) | — |
| Bet thin only into callers | explain SoftPulse cues RARELY CALLS → CHECK; unit `unit-06-11-tag` (LPT-294 split) | — |
| Note wide entry | Wide, Pressure, Sample; unguided SoftPulse one gold (LPT-493); densified frame asks (LPT-649); unit `unit-06-12-lag` (LPT-297 split) | entry quizzes |
| Note sustained pressure | explain SoftPulse cues BARRELS → MANY HANDS; unit `unit-06-12-lag` (LPT-297 split) | — |
| Planned pressure, not a Maniac | explain SoftPulse cues FOLDS SOMETIMES → PLAN; unit `unit-06-12-lag` (LPT-297 split) | — |
| The LAG model | Wide, Pressure, Model; unguided SoftPulse one gold (LPT-492); unit `unit-06-12-lag` (LPT-300 split) | label quizzes |
| Spot a LAG | explain SoftPulse cues WIDE OPENS → BARRELS; unit `unit-06-12-lag` (LPT-300 split) | — |
| LAG or Calling Station? | explain SoftPulse cues RAISES → CALLS; unit `unit-06-12-lag` (LPT-300 split) | — |
| Call down wider versus a LAG | Call, Trap, Fancy less; unguided SoftPulse one gold Usually avoid (LPT-503); densified frame asks (LPT-651); unit `unit-06-12-lag` (LPT-303 split) | avoid and cite checks |
| Trap strong hands more | explain SoftPulse cues STRONG HAND → LET THEM BET; unit `unit-06-12-lag` (LPT-303 split) | — |
| Fewer fancy bluffs | explain SoftPulse cues NO BIG BLUFF → LET THEM; unit `unit-06-12-lag` (LPT-303 split) | — |
| Same cards: thin value versus a Station | Cards, seats, and evidence in the stage; unit `unit-06-13-mix` (LPT-306 split) | — |
| Same cards: fold to Nit heat | explain SoftPulse cues NIT CHECK-RAISE → FOLD; unit `unit-06-13-mix` (LPT-306 split) | — |
| Same cards: call a LAG barrel | explain SoftPulse cues LAG BARREL → CALL; unit `unit-06-13-mix` (LPT-306 split) | — |
| Cite the tendency | explain SoftPulse cues TENDENCY → LINE; unit `unit-06-13-mix` (LPT-306 split) | — |
| Section 6 checkpoint | densified frame asks (LPT-655) | — |
| State a preflop thesis | Reason, Confirm, Cancel; unguided SoftPulse one gold Name the thesis (LPT-505); densified frame asks (LPT-656); unit `unit-07-01-preflop-flop` (LPT-310 split) | — |
| Update on the flop | explain SoftPulse cues TEXTURE → CONFIRM OR CANCEL; unit `unit-07-01-preflop-flop` (LPT-310 split) | — |
| Abandon dead plans quickly | explain SoftPulse cues DEAD PLAN → LET GO; unit `unit-07-01-preflop-flop` (LPT-310 split) | — |
| List turn continue cards | Barrel, Give-up, Map; unguided SoftPulse one gold Map first (LPT-506); densified frame asks (LPT-657); unit `unit-07-02-turn-map` (LPT-314 split) | — |
| List give-up cards | explain SoftPulse cues BRICK → GIVE UP; unit `unit-07-02-turn-map` (LPT-314 split) | — |
| Bet flop only with a turn map | explain SoftPulse cues CONTINUE → GIVE-UP → MAP; unit `unit-07-02-turn-map` (LPT-314 split) | — |
| Choose river value | Value, Bluff, Hold; densified frame asks (LPT-658); unit `unit-07-03-river` (LPT-317 split) | — |
| Choose bluffs with blockers | explain SoftPulse cues BLOCKER → FEWER CALLS; unit `unit-07-03-river` (LPT-317 split) | — |
| Check trash without a story | explain SoftPulse cues NO STORY → CHECK; unit `unit-07-03-river` (LPT-317 split) | — |
| Plan limped pots | Limped, SRP, 3-4bet; unit `unit-07-04-pot-types` (LPT-320 split) | — |
| Plan single-raised pots | explain SoftPulse cues HEADS-UP → C-BET; unit `unit-07-04-pot-types` (LPT-320 split) | — |
| Plan 3-bet and 4-bet pots | explain SoftPulse cues LOW SPR → COMMIT; unit `unit-07-04-pot-types` (LPT-320 split) | — |
| Bluff less multiway | Fewer, Thicker, Widen; unit `unit-07-05-hu-mw` (LPT-323 split) | — |
| Value thicker multiway | explain SoftPulse cues MULTIWAY → THICK VALUE; unit `unit-07-05-hu-mw` (LPT-323 split) | — |
| Widen selected heads-up bluffs | explain SoftPulse cues HEADS-UP → STEAL MORE; unit `unit-07-05-hu-mw` (LPT-323 split) | — |
| Commit earlier when short | Short, Deep, Effective; unit `unit-07-06-stacks` (LPT-326 split) | — |
| Use implied odds deep | explain SoftPulse cues DEEP → IMPLIED ODDS; unit `unit-07-06-stacks` (LPT-326 split) | — |
| Recalculate effective stacks | explain SoftPulse cues SHORTER STACK → PLAN; unit `unit-07-06-stacks` (LPT-326 split) | — |
| Same hand: bet value versus a Station | Cards, Models, Cite; unit `unit-07-07-same-cards` (LPT-330 split) | — |
| Same hand: respect a TAG check-raise | explain SoftPulse cues TAG CHECK-RAISE → CAREFUL; unit `unit-07-07-same-cards` (LPT-330 split) | — |
| Same hand: call a LAG barrel | explain SoftPulse cues LAG BARREL → CALL; unit `unit-07-07-same-cards` (LPT-330 split) | — |
| No evidence, baseline line | explain SoftPulse cues NO EVIDENCE → BASELINE; unit `unit-07-07-same-cards` (LPT-330 split) | — |
| Combine type with board | Type, Board, Line, Size; unit `unit-07-08-checkpoints` (LPT-333 split) | — |
| Combine line with sizing | explain SoftPulse cues LINE → SIZE; unit `unit-07-08-checkpoints` (LPT-333 split) | — |
| Produce one coherent action | explain SoftPulse cues FOUR INPUTS → ONE ACTION; unit `unit-07-08-checkpoints` (LPT-333 split) | — |
| Name your leaks | Leak, Book, Review; unit `unit-07-09-leaks` (LPT-336 split) | — |
| Write default lines | explain SoftPulse cues COMMON SPOT → DEFAULT; unit `unit-07-09-leaks` (LPT-336 split) | — |
| Schedule your review | explain SoftPulse cues AFTER SESSION → REVIEW; unit `unit-07-09-leaks` (LPT-336 split) | — |
| Capstone: single-raised pot | Plan, Update, Finish | — |
| Capstone: 3-bet pot | SPR, Turn, Close | — |
| Capstone: multiway deep | Nuts, Deep, No-bluff | — |
| Capstone: limped pot | Nuts, Value, Thin | — |
| Capstone: 4-bet pot | SPR, Commit, No Hero | — |
| Prep a coached Live warm-up hand | Checklist, Defaults, One hand | — |
| Final: all five player types | — | — |
