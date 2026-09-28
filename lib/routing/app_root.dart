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

/// [MaterialApp] key for the root navigator.
///
/// Signed-out and anonymous sessions share `guest` so anonymous sign-in does
/// not dispose an in-progress first lesson. [resetForAuthGate] is set only
/// when routing has resolved to sign-in, so a real denial still clears guest
/// routes. A linked account keeps its uid so sign-out and account switches
/// still drop pushed routes such as Settings.
String rootNavigatorKeyFor({
  String? uid,
  bool anonymous = false,
  bool resetForAuthGate = false,
}) {
  final identity = (uid == null || anonymous) ? 'guest' : uid;
  if (resetForAuthGate) return '$identity-auth';
  return identity;
}

/// Extra navigator identity so a home swap actually drops the old stack.
///
/// Welcome pushes (experience, daily goal, Meet Rex) share `guest`. Changing
/// `home` to Your start does not pop that stack, so Meet Rex stayed on screen.
/// `-course` is a new navigator for Your start and the first lesson, and it
/// stays stable across anonymous sign-in. `-save` and `-home` are new again so
/// returning to `guest` cannot restore the lesson over Save progress or Home.
String rootStackToken({
  required AppRootDestination destination,
  required OnboardingDraft onboarding,
  required bool anonymous,
}) {
  if (destination == AppRootDestination.saveProgress ||
      onboarding.pendingSaveProgress) {
    return '-save';
  }
  if (destination == AppRootDestination.shell && anonymous) {
    return '-home';
  }
  if (destination == AppRootDestination.guestCourse &&
      (onboarding.step == OnboardingStep.recommendedStart ||
          onboarding.step == OnboardingStep.firstLesson)) {
    return '-course';
  }
  return '';
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
    if (!guestEntry) return AppRootDestination.auth;
    // The account prompt is the root even before anonymous sign-in lands, so
    // a finished first lesson cannot fall through to Welcome or Home.
    if (onboarding.pendingSaveProgress) {
      return AppRootDestination.saveProgress;
    }
    // Once the learner leaves the welcome gate, keep the guestCourse root so
    // anonymous sign-in (during the first lesson bootstrap) does not change
    // MaterialApp.home and dispose the in-progress lesson route.
    if (onboarding.step == OnboardingStep.firstLesson ||
        onboarding.step == OnboardingStep.recommendedStart) {
      return AppRootDestination.guestCourse;
    }
    return AppRootDestination.welcome;
  }
  if (anonymous) {
    if (!flagsReady) return AppRootDestination.loading;
    if (!courseOn) return AppRootDestination.auth;
    // Soft account CTA after the first lesson — dismissible so guests can keep
    // learning on Home without linking yet.
    if (onboarding.pendingSaveProgress) {
      return AppRootDestination.saveProgress;
    }
    if (onboarding.step == OnboardingStep.done ||
        onboarding.firstLessonCompleted) {
      return AppRootDestination.shell;
    }
    if (!guestEntry) return AppRootDestination.auth;
    // Reinstall deletes onboarding_draft_v1 and keeps the anonymous keychain
    // user. That draft is still the welcome step, so Welcome stays the root
    // and Get started can push Your experience with a way back.
    if (onboarding.step == OnboardingStep.welcome) {
      return AppRootDestination.welcome;
    }
    return AppRootDestination.guestCourse;
  }
  return AppRootDestination.shell;
}
