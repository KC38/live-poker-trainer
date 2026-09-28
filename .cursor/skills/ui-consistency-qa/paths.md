# UI consistency paths

One row in the coverage log per chartered path. Add a path here when the
product grows a surface. Do not invent a path during a session.

`requires` is the simulator precondition from the skill. `watch` prefixes
mark a covered path due again when `origin/main` changes those files.

Phases run in order: `bootstrap`, `guest-home`, `table`. Inside a phase,
lower `order` is first.

Judge every path against `docs/ui/design-record.md` and
[flutter-ui-ux](../flutter-ui-ux/SKILL.md). This file is the route. The
design record is the visual contract.

## onboarding-chrome

- phase: `bootstrap`
- order: 1
- requires: `fresh-install`
- watch: `lib/ui/screens/onboarding_screens.dart`, `lib/ui/theme/`, `lib/core/constants/colors.dart`, `assets/brand/`

Goal: Welcome through Meet Rex uses the Theme and Asset inventory. Stop
before a lesson.

1. Welcome. Compare type, buttons, logo, and background to Theme and the logo slot.
2. Experience, then daily goal. The controls match Welcome. Record both labels in `notes`.
3. Meet Rex. This is the mascot slot. Record whether Rex is an image or only text.
4. Recommended start. Do not start the lesson. Leave **Start from the beginning instead** alone.

## home-chrome

- phase: `guest-home`
- order: 2
- requires: `guest-home`
- watch: `lib/ui/screens/home_screen.dart`, `lib/ui/home/`, `lib/ui/screens/app_shell.dart`, `lib/ui/theme/`

Goal: Home status, the path, Rex, and the shell tabs match Theme. Do not
finish a lesson.

1. Record the type, card, and button treatment on the status row and the next-lesson card.
2. Rex on Home matches the mascot slot.
3. Each tab label is readable and uses the theme icon color. Do not open Live Training past the hub.

## lesson-chrome

- phase: `guest-home`
- order: 3
- requires: `guest-home`
- watch: `lib/ui/screens/lesson_runner_screen.dart`, `lib/ui/course/widgets/rex_coach_line.dart`, `lib/ui/theme/`

Goal: runner chrome matches Theme. The table layout belongs to
`lesson-full-table`.

1. Start the lesson Home is offering.
2. On the first step, check the progress header, hint, feedback, and the primary button against Theme.
3. Record the lesson title. Leave after one step unless the first step has no chrome to judge.

## lesson-full-table

- phase: `guest-home`
- order: 4
- requires: `guest-home`
- watch: `lib/ui/screens/poker_table_screen.dart`, `lib/ui/widgets/felt_table_view.dart`, `lib/ui/widgets/hero_rail_widget.dart`, `lib/ui/widgets/coach_shelf_widget.dart`, `lib/ui/widgets/action_dock_widget.dart`, `lib/ui/course/widgets/lesson_action_table.dart`, `lib/ui/course/widgets/lesson_table_context.dart`, `lib/ui/course/activities/full_table_hand_lab_activity.dart`

Goal: a lesson step that shows a hand uses the Poker table bands.

1. Open the next lesson from Home. Advance until a step shows hole cards, a board, a pot, or an action choice. Record the lesson title and activity id.
2. Compare that step to the Poker table section. `LessonActionSpot` or `LessonTableScene` on a hand step is a finding.
3. One ticket for that layout. Do not open a second ticket for the next activity that shares it.
4. Calibration already pushes `PokerTableScreen`. That is the reference. Do not redesign it on this path.

## profile-settings-chrome

- phase: `guest-home`
- order: 5
- requires: `guest-home`
- watch: `lib/ui/screens/profile_screen.dart`, `lib/ui/screens/settings_screen.dart`, `lib/ui/theme/`

Goal: Profile and Settings match Theme. Do not sign out.

1. Profile sections use the card and type ramp.
2. Open Settings. Music and Sound effects are the music and sound-effect slots. Restore both toggles before leaving.
3. Chip display uses the data type (JetBrains Mono), not a new font.

## asset-inventory

- phase: `guest-home`
- order: 6
- requires: `guest-home`
- watch: `assets/`, `lib/core/audio/sound_service.dart`, `lib/ui/home/rex_coach_card.dart`, `lib/ui/course/widgets/rex_coach_line.dart`

Goal: each asset slot is present on the screens you visit, or has one ticket.

1. Visit Home, one lesson step, and Settings.
2. For logo, mascot, icons, motion, sound effects, and background music, write what you saw or heard.
3. One Story per missing slot. A second screen with the same gap is a comment on that ticket, not a new issue.

## live-table-reference

- phase: `table`
- order: 7
- requires: a signed-in account the user gave you this session, with Live Training unlocked
- watch: `lib/ui/screens/poker_table_screen.dart`, `lib/ui/screens/live_training_screen.dart`, `lib/ui/widgets/felt_table_view.dart`, `lib/ui/widgets/action_dock_widget.dart`, `lib/core/audio/sound_service.dart`

Goal: one Live Training decision shows the Poker table bands, and the
sound-effect slot plays on the action.

Without an account from the user, this path is not a candidate. Do not
append a row. When the hub still blocks the hand, append `skipped` and
leave the path due.

1. Start a hand from the hub.
2. Header, felt, hero rail, coach shelf, and action dock match the Poker table section. Nothing overlaps.
3. Fold, check, call, or a bet plays the matching `SoundService` cue. Record which cue you heard.
4. Stop after one decision. Do not grade strategy.
