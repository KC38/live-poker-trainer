# Agent validation paths

Journeys that tickets and `/implement-open-jira` may name. Add a path here
when the product grows a journey. Do not invent a path during a session.

`requires` is the simulator precondition. `watch` prefixes mark when
`origin/main` changes those files matter for re-validation.

Phases run in order: `bootstrap`, `guest-home`, `fresh-variant`,
`destructive`. Inside a phase, lower `order` is first.

## fresh-guest-recommended

- phase: `bootstrap`
- order: 1
- requires: `fresh-install`
- watch: `lib/ui/screens/onboarding_screens.dart`, `lib/ui/screens/lesson_runner_screen.dart`, `lib/ui/screens/lesson_result_screen.dart`, `lib/ui/screens/first_lesson_launch_screen.dart`, `lib/routing/app_root.dart`, `lib/ui/screens/home_screen.dart`, `lib/models/course/onboarding_models.dart`

Goal: a brand-new guest finishes the recommended first lesson and lands on Home.

1. Welcome — **Get started**. Leave **I already have an account** for `welcome-existing-account`.
2. Experience — pick one band. Record the label in `notes`.
3. Daily goal — pick one. Record the minutes in `notes`.
4. Rex intro — **Continue**.
5. Recommended start — take the recommended lesson. Leave **Start from the beginning instead** for `guest-from-beginning`.
6. Play that lesson to the end. Grade, coach copy, layout, and poker on each step.
7. Save progress — open **Create an account to save your progress**, inspect, dismiss. Do not submit. Then **Continue learning**.
8. Confirm Home shows guest progress on this device. Stop. Profile, Settings, and Live Training are later paths.

## home-continue

- phase: `guest-home`
- order: 2
- requires: `guest-home`
- watch: `lib/ui/screens/home_screen.dart`, `lib/ui/home/`, `lib/providers/course_progress_provider.dart`, `lib/providers/course_home_provider.dart`, `lib/models/course/course_progress.dart`, `lib/models/course/course_home_models.dart`, `lib/ui/screens/lesson_runner_screen.dart`, `lib/ui/screens/lesson_result_screen.dart`

Goal: the next lesson Home offers can be finished, and the status bar moves with it.

1. Record streak, lifetime XP, and accepted accuracy.
2. Start the lesson Home is offering. That is the **Resume** card when it is showing, otherwise **Start** or the next path node.
3. Finish the lesson.
4. Home shows the new XP, streak, and accuracy, and the finished node is no longer the next step.

## lesson-abandon-resume

- phase: `guest-home`
- order: 3
- requires: `guest-home`
- watch: `lib/ui/screens/home_screen.dart`, `lib/ui/home/course_resume_card.dart`, `lib/ui/screens/lesson_runner_screen.dart`, `lib/models/course/course_home_models.dart`, `lib/models/course/course_session_models.dart`

Goal: killing the app mid-lesson restores the same lesson and activity.

1. Start a lesson from Home. Submit at least one step. Record the lesson title and the activity you are on.
2. There is no leave control on the runner. Terminate the app on the simulator this workflow is driving (`xcrun simctl terminate <that UDID> com.pokerlab.livePokerTrainer`). The Pro session uses the iPhone 17 Pro. `/implement-open-jira` uses the iPhone 17. Do not terminate the other phone. Do not uninstall.
3. Launch again. Home shows a **Resume** card with that lesson title and activity index.
4. Open it. The runner continues that lesson, including the catch-up notice when the product shows one. Finish or leave after the restored step is visible.

## live-training-gate

- phase: `guest-home`
- order: 4
- requires: `guest-home`
- watch: `lib/ui/screens/live_training_screen.dart`, `lib/models/live_access.dart`, `lib/ui/screens/app_shell.dart`

Goal: an anonymous guest cannot start a Live Training hand.

1. Open the **Live Training** tab.
2. Read the hub copy. Tap the primary start control.
3. An anonymous guest gets **Create an account before Live Training.** A signed-in player who is still locked gets the Section 2 or Section 4 snackbar from `live_training_screen.dart`. Record which text appeared.
4. The table must not deal. Do not create an account.

## live-training-one-hand

- phase: `guest-home`
- order: 5
- requires: a signed-in account the user gave you this session, with Live Training actually unlocked
- watch: `lib/ui/screens/live_training_screen.dart`, `lib/ui/screens/poker_table_screen.dart`, `lib/ui/widgets/action_dock_widget.dart`, `lib/ui/screens/profile_screen.dart`, `lib/models/live_access.dart`

Goal: one coached hand finishes, and only the Live Training stats move.

Without an account from the user, this path is not a candidate. Do not append a row. When you do have an account and the hub still blocks the hand, append `skipped` and leave the path due.

1. Start training from the hub.
2. Play until the hand ends or the product returns you to the hub. On each decision, the action, the pot, and the stacks on screen have to agree.
3. Profile: the Live Training section changed. The lesson-progress section did not.

## profile-settings-persist

- phase: `guest-home`
- order: 6
- requires: `guest-home`
- watch: `lib/ui/screens/profile_screen.dart`, `lib/ui/screens/settings_screen.dart`, `lib/providers/settings_provider.dart`, `lib/core/constants/chip_format.dart`

Goal: settings survive a relaunch, and Profile does not mix the two stat systems.

1. Profile. Course progress and Live Training are separate sections. Guest copy must not claim an account exists.
2. Open Settings from the gear or the Profile **Settings** row. Do not tap **Sign out**.
3. Toggle **Music** or **Sound effects**. Switch **Chip display** to a different mode (`$`, `BB`, or `Both`). Record the mode.
4. Leave Settings. The next surface that shows chips uses that mode. Force-quit, relaunch, and confirm the same mode and the same toggle.
5. Home still shows the same guest progress as before Settings.

## guest-from-beginning

- phase: `fresh-variant`
- order: 7
- requires: `fresh-install`
- watch: `lib/ui/screens/onboarding_screens.dart`, `lib/ui/screens/first_lesson_launch_screen.dart`, `lib/ui/screens/lesson_runner_screen.dart`

Goal: **Start from the beginning instead** runs a real lesson and still reaches Home.

1. Same Welcome, experience, daily goal, and Rex steps as `fresh-guest-recommended`. Record the labels.
2. On recommended start, tap **Start from the beginning instead**.
3. Finish that lesson. Save-progress: inspect **Create an account to save your progress**, dismiss, **Continue learning**.
4. Home is the guest shell. The lesson title on the result must be the from-the-beginning lesson, not the recommended one you declined.

## onboarding-change-answers

- phase: `fresh-variant`
- order: 8
- requires: `fresh-install`
- watch: `lib/ui/screens/onboarding_screens.dart`, `lib/models/course/onboarding_models.dart`

Goal: changing experience and daily goal changes the recommendation. Stop before the lesson.

1. **Get started**. Pick an experience band. Record it.
2. Go back. Pick a different band. Record it.
3. Pick a daily goal, go back, pick a different one. Record both.
4. Rex — **Continue**.
5. Recommended start names a lesson that matches the second answers. Do not start the lesson. Do not take **Start from the beginning instead**.

## welcome-existing-account

- phase: `fresh-variant`
- order: 9
- requires: `fresh-install`
- watch: `lib/ui/screens/onboarding_screens.dart`, `lib/ui/screens/auth_screen.dart`

Goal: **I already have an account** opens auth and can be left without an account.

1. Welcome — **I already have an account**. Do not tap **Get started**.
2. Inspect the auth screen. Do not submit sign-in or create-account.
3. Back returns to Welcome. **Get started** is still available.

## sign-out-discards-guest

- phase: `destructive`
- order: 10
- requires: `guest-home`
- watch: `lib/ui/screens/settings_screen.dart`, `lib/ui/screens/profile_screen.dart`, `lib/ui/screens/auth_screen.dart`, `lib/routing/app_root.dart`, `lib/providers/auth_provider.dart`

Goal: sign-out does not keep the guest's Home progress.

Walk this only when every earlier path is covered or not due. It destroys the guest container.

1. Record the Home status (XP, streak, lesson position).
2. Settings — **Sign out**.
3. The next screen is Welcome or sign-in, matching `guestCourseEnabled` in the Course rollout section of `README.md`.
4. Relaunch. Home does not still show the guest XP and lesson position from step 1.
