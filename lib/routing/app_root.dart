/// Root destination for the course kill switch.
library;

import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';

/// Where the signed-in or signed-out root should land.
enum AppRootDestination {
  /// Flags or auth are still resolving for a guest.
  loading,

  /// Guest course welcome. Only when the course is enabled.
  welcome,

  /// Anonymous onboarding or first lesson.
  guestCourse,

  /// Save-progress prompt after the first guest lesson.
  saveProgress,

  /// Account sign-in. Used when the course kill switch is off.
  auth,

  /// Authenticated Home / Live Training / Profile shell.
  shell,
}

/// Chooses the root screen.
///
/// `courseEnabled == false` (including fetch, parse, and minimum-version
/// failure) hides guest onboarding. Authenticated accounts still reach the
/// shell so Live Training and Profile stay usable.
AppRootDestination resolveAppRoot({
  required bool signedIn,
  required bool anonymous,
  required bool flagsReady,
  required CourseFlags? flags,
  required OnboardingDraft onboarding,
}) {
  final courseOn = flags?.courseEnabled == true;
  if (!signedIn) {
    if (!flagsReady) return AppRootDestination.loading;
    return courseOn ? AppRootDestination.welcome : AppRootDestination.auth;
  }
  if (anonymous) {
    if (!flagsReady) return AppRootDestination.loading;
    if (!courseOn) return AppRootDestination.auth;
    if (onboarding.pendingSaveProgress || onboarding.firstLessonCompleted) {
      return AppRootDestination.saveProgress;
    }
    return AppRootDestination.guestCourse;
  }
  return AppRootDestination.shell;
}
