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
}
