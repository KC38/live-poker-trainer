/// Root destination for the course kill switch.
library;

import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';

/// Where the signed-in or signed-out root should land.
enum AppRootDestination {
  /// Flags or auth are still resolving for a guest.
  loading,

  /// Guest course welcome. Only when guest course entry is enabled.
  welcome,

  /// Anonymous onboarding or first lesson.
  guestCourse,

  /// Save-progress prompt after the first guest lesson.
  saveProgress,

  /// Account sign-in. Used when course or guest entry is off.
  auth,

  /// Authenticated Home / Live Training / Profile shell.
  shell,
}

/// Guest welcome and anonymous course entry.
///
/// Requires the course kill switch and [CourseFlags.guestCourseEnabled].
/// Paused starts ([CourseFlags.courseStartsEnabled]) are enforced on Home,
/// not here, so guest onboarding still runs when the course is enabled for
/// guests. Fetch, parse, and minimum-version failures leave [flags] disabled.
bool guestCourseEntryEnabled(CourseFlags? flags) {
  return flags != null && flags.courseEnabled && flags.guestCourseEnabled;
}

/// Chooses the root screen.
///
/// `courseEnabled == false` (including fetch, parse, and minimum-version
/// failure) hides guest onboarding. `guestCourseEnabled == false` does the
/// same for signed-out and new anonymous guests. Authenticated accounts still
/// reach the shell so Live Training and Profile stay usable.
AppRootDestination resolveAppRoot({
  required bool signedIn,
  required bool anonymous,
  required bool flagsReady,
  required CourseFlags? flags,
  required OnboardingDraft onboarding,
}) {
  final courseOn = flags?.courseEnabled == true;
  final guestEntry = guestCourseEntryEnabled(flags);
  if (!signedIn) {
    if (!flagsReady) return AppRootDestination.loading;
    return guestEntry ? AppRootDestination.welcome : AppRootDestination.auth;
  }
  if (anonymous) {
    if (!flagsReady) return AppRootDestination.loading;
    if (!courseOn) return AppRootDestination.auth;
    if (onboarding.pendingSaveProgress || onboarding.firstLessonCompleted) {
      return AppRootDestination.saveProgress;
    }
    if (!guestEntry) return AppRootDestination.auth;
    return AppRootDestination.guestCourse;
  }
  return AppRootDestination.shell;
}
