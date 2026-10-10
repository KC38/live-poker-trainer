# 03 — Flutter client

## Stack

- Flutter 3.47+ / Dart 3.13+
- Riverpod for app state
- Firebase Auth, Firestore (persistence **disabled**), Crashlytics, Analytics
- No offline training continuation — live connection required for Live

## Bootstrap (`lib/main.dart`)

1. Legacy local-data cleanup migration.
2. `Firebase.initializeApp`.
3. Firestore `persistenceEnabled: false` (training state is live from Functions).
4. SharedPreferences: guest install generation, analytics toggle.
5. Crash reporting when analytics collection is on.
6. `ProviderScope` → root app that resolves auth + course flags.

**Agent note:** Root navigator keys are **per identity**. Reusing one
`GlobalKey` across remounts reused the old route stack and skipped Save
progress after the first lesson. See comments on `_navigatorKeysByIdentity`.

## Root routing (`lib/routing/app_root.dart`)

`resolveAppRoot` picks:

| Destination | When |
| --- | --- |
| `loading` | Guest flags not ready |
| `welcome` / `guestCourse` | Guest course entry enabled |
| `saveProgress` | First lesson done, account prompt pending |
| `auth` | Course/guest entry off, or user chose sign-in |
| `shell` | Linked account (or anonymous Home after onboarding) |

Course kill switch: `appConfig/courseFlags` (`CourseFlags`). Fetch/parse/
min-version failure disables course entry. Authenticated Live + Profile stay
usable when course is off.

`rootStackToken` forces new navigators at onboarding / save / celebrate /
home boundaries so Back and Continue cannot resurrect the wrong stack.

## Shell (`lib/ui/screens/app_shell.dart`)

Three tabs: **Home**, **Live Training**, **Profile**. Poker table pushes
above this navigator. Re-tapping Home scrolls to the next / in-progress
lesson.

## Providers (mental model)

| Provider area | Owns |
| --- | --- |
| `auth_provider` | Firebase user, anonymous vs linked |
| `course_flags_provider` | Kill switch; reload on uid change |
| `onboarding_provider` | Guest draft (experience, goal, steps) |
| `course_catalog_provider` | Public catalog asset |
| `course_progress_provider` / `course_home_provider` | Path, XP, hearts, resume |
| `game_provider` | Live (and some course-bridge) table session + replay pacing |
| `settings_provider` | Audio local; chip display / gameplay synced when signed in |
| `profile_provider` | Identity + aggregated display stats |
| `live_access_provider` | Whether Live Training is unlocked |
| `service_providers` | Concrete services (sound, course, user repo…) |

## Settings preferences

- **Music / SFX**: device-local SharedPreferences only.
- **Chip display** (`$` / `BB` / `Both`): gameplay preference; syncs to
  Firestore when signed in.
- Obsolete Gemini client key prefs are stripped on load — never restore.

## Guest vs account

- Guests can play course when flags allow; Live Training requires a
  non-anonymous account (and unlock rules).
- Sign-out must not keep guest Home progress looking like an account.
- Progress transfer callables merge anonymous → linked when the product flow
  issues/redeems a transfer.

## Client engine vs server engine

`lib/engine/` helps the UI (sizing labels, situation keys, local display).
The authoritative NLH engine for Live is `functions/src/live_poker_engine.ts`.
Do not add "offline solve the hand" paths in the client.
