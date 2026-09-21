# Plan 01 — Three-Tab Shell and Live Training Hub

**Status: Done**

- Merged: https://github.com/KC38/live-poker-trainer/pull/164
  (`44d1305`) and follow-up https://github.com/KC38/live-poker-trainer/pull/165
  (`db50d28`) on `main`
- Cloud Functions deploy: completed from `origin/main` at `db50d28`
  (unchanged Functions skipped — UI-only ship)
- Simulator: hot-restarted attached Flutter sessions after merge

## Objective

Create exactly three persistent destinations—Home, Live Training, and
Profile—while preserving the existing full-screen simulator behavior.

## Reuse

- Auth and user-document hydration in `lib/main.dart`.
- `PokerTableScreen`, `GameController`, `LiveHandService`, table widgets, and
  the prepare-before-route/start-after-route handoff.
- Current Home table-setup controls, settings provider, launch analytics, and
  home BGM behavior.
- `ProfileScreen` and the shared theme.

## Modify

- Replace signed-in `HomeScreen` root with an `AppShell`.
- Convert `HomeScreen` into a course placeholder/path root.
- Move `_launchTraining`, `_TableSetupSection`, stake/seat/stack controls, and
  launch analytics into `LiveTrainingScreen`.
- Make `ProfileScreen` a tab root without a back affordance.
- Move Settings entry from the old Home header into Profile.
- Give tab selections explicit analytics events; Navigator observers do not
  observe `IndexedStack` switches.

## Retire

- Old Home marketing/launcher layout after its training logic is moved.
- Home profile and settings buttons; tabs/Profile replace them.
- `StatsScreen` alias only after repository and deep-link searches prove it is
  unused.

## Add

- `lib/ui/screens/app_shell.dart`.
- `lib/ui/screens/live_training_screen.dart`.
- Tests for tab count, tab-state retention, table launch, and Profile root
  behavior.

## Implementation sequence

1. Add an `IndexedStack` shell with Home, Live Training, and Profile.
2. Keep the poker table as a full-screen pushed route above the shell.
3. Extract the existing training launcher and table setup without changing
   their provider or server contracts.
4. Relocate BGM ownership to the shell or idle Live Training hub so tab changes
   cannot create duplicate audio sessions.
5. Update screen names and integration-test navigation.
6. Remove old Home chrome only after equivalent access exists.

## Acceptance criteria

- Bottom navigation contains exactly three items.
- Each tab preserves scroll/state while switching.
- The table remains full screen and returns to the Live Training tab.
- `prepareTraining()` still occurs before navigation; network kickoff waits for
  route presentation.
- Current table setup and Live Training behavior are unchanged.
- Settings are reachable from Profile.
- Small-phone and accessibility tests cover all three tab labels.

## Verification

- Update `test/ui/start_training_handoff_test.dart`.
- Add `test/ui/app_shell_test.dart` and Live hub widget tests.
- Update `integration_test/play_hands_test.dart` to select Live Training first.
- Run Flutter analyze, widget tests, and the hand-play integration test.

## Out of scope

Course data, onboarding, lesson UI, and new backend state.

## Dependencies

None. Plan 02 may proceed in parallel.
