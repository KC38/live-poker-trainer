import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/routing/app_root.dart';

void main() {
  const enabled = CourseFlags(
    courseEnabled: true,
    courseStartsEnabled: true,
    guestCourseEnabled: true,
    placementTestsEnabled: true,
    catalogVersion: '2.0.0',
    minimumClientVersion: '2.0.0',
  );
  final disabled = CourseFlags.disabled();

  test('course off sends guests to auth and keeps accounts in the shell', () {
    expect(
      resolveAppRoot(
        signedIn: false,
        anonymous: false,
        flagsReady: true,
        flags: disabled,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.auth,
    );
    expect(
      resolveAppRoot(
        signedIn: true,
        anonymous: true,
        flagsReady: true,
        flags: disabled,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.auth,
    );
    expect(
      resolveAppRoot(
        signedIn: true,
        anonymous: false,
        flagsReady: true,
        flags: disabled,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.shell,
    );
  });

  test('course on keeps guest onboarding', () {
    expect(
      resolveAppRoot(
        signedIn: false,
        anonymous: false,
        flagsReady: true,
        flags: enabled,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.welcome,
    );
    expect(
      resolveAppRoot(
        signedIn: true,
        anonymous: true,
        flagsReady: true,
        flags: enabled,
        onboarding: const OnboardingDraft(pendingSaveProgress: true),
      ),
      AppRootDestination.saveProgress,
    );
    expect(
      resolveAppRoot(
        signedIn: true,
        anonymous: true,
        flagsReady: true,
        flags: enabled,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.guestCourse,
    );
  });

  test('guestCourseEnabled false sends new guests to auth', () {
    const guestsOff = CourseFlags(
      courseEnabled: true,
      courseStartsEnabled: true,
      guestCourseEnabled: false,
      placementTestsEnabled: true,
      catalogVersion: '2.0.0',
      minimumClientVersion: '2.0.0',
    );
    expect(guestCourseEntryEnabled(guestsOff), isFalse);
    expect(
      resolveAppRoot(
        signedIn: false,
        anonymous: false,
        flagsReady: true,
        flags: guestsOff,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.auth,
    );
    expect(
      resolveAppRoot(
        signedIn: true,
        anonymous: true,
        flagsReady: true,
        flags: guestsOff,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.auth,
    );
    expect(
      resolveAppRoot(
        signedIn: true,
        anonymous: true,
        flagsReady: true,
        flags: guestsOff,
        onboarding: const OnboardingDraft(firstLessonCompleted: true),
      ),
      AppRootDestination.saveProgress,
    );
    expect(
      resolveAppRoot(
        signedIn: true,
        anonymous: false,
        flagsReady: true,
        flags: guestsOff,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.shell,
    );
  });

  test('paused starts still allow guest entry when guests are enabled', () {
    const startsPaused = CourseFlags(
      courseEnabled: true,
      courseStartsEnabled: false,
      guestCourseEnabled: true,
      placementTestsEnabled: true,
      catalogVersion: '2.0.0',
      minimumClientVersion: '2.0.0',
    );
    expect(guestCourseEntryEnabled(startsPaused), isTrue);
    expect(
      resolveAppRoot(
        signedIn: false,
        anonymous: false,
        flagsReady: true,
        flags: startsPaused,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.welcome,
    );
  });

  test('flags still loading do not flash guest onboarding', () {
    expect(
      resolveAppRoot(
        signedIn: false,
        anonymous: false,
        flagsReady: false,
        flags: null,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.loading,
    );
    expect(
      resolveAppRoot(
        signedIn: true,
        anonymous: false,
        flagsReady: false,
        flags: null,
        onboarding: const OnboardingDraft(),
      ),
      AppRootDestination.shell,
    );
  });

  test('anonymous sign-in keeps the guest navigator key', () {
    expect(
      rootNavigatorKeyFor(uid: null),
      rootNavigatorKeyFor(uid: 'anon-uid', anonymous: true),
    );
    expect(
      rootNavigatorKeyFor(uid: 'linked-uid'),
      isNot(rootNavigatorKeyFor(uid: null)),
    );
    expect(
      rootNavigatorKeyFor(
        uid: 'anon-uid',
        anonymous: true,
        resetForAuthGate: true,
      ),
      'guest-auth',
    );
  });
}
