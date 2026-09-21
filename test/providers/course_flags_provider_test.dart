import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_flags_provider.dart';
import 'package:live_poker_trainer/routing/app_root.dart';
import 'package:live_poker_trainer/services/firestore/course_flags_repository.dart';

class _CountingFlagsRepository extends CourseFlagsRepository {
  _CountingFlagsRepository(this._flags);

  final CourseFlags _flags;
  int loads = 0;

  @override
  Future<CourseFlags> load({String? clientVersion}) async {
    loads += 1;
    return _flags;
  }
}

class _GatedFlagsRepository extends CourseFlagsRepository {
  _GatedFlagsRepository(this._flags, this._gate);

  final CourseFlags _flags;
  final Completer<void> _gate;
  int loads = 0;

  @override
  Future<CourseFlags> load({String? clientVersion}) async {
    loads += 1;
    if (loads > 1) await _gate.future;
    return _flags;
  }
}

void main() {
  test('course flags reload when the auth uid changes', () async {
    const flags = CourseFlags(
      courseEnabled: true,
      courseStartsEnabled: true,
      guestCourseEnabled: true,
      placementTestsEnabled: false,
      catalogVersion: '2.0.0',
      minimumClientVersion: '2.0.0',
    );
    final repo = _CountingFlagsRepository(flags);
    final uid = StateProvider<String?>((ref) => null);
    final container = ProviderContainer(
      overrides: [
        courseFlagsRepositoryProvider.overrideWithValue(repo),
        authUidProvider.overrideWith((ref) => ref.watch(uid)),
      ],
    );
    addTearDown(container.dispose);

    final first = await container.read(courseFlagsProvider.future);
    expect(first.canStartAsGuest, isTrue);
    expect(repo.loads, 1);

    container.read(uid.notifier).state = 'anon-uid';
    final second = await container.read(courseFlagsProvider.future);
    expect(second.guestCourseEnabled, isTrue);
    expect(repo.loads, 2);
  });

  test('uid reload keeps previous flags until the new read finishes', () async {
    const flags = CourseFlags(
      courseEnabled: true,
      courseStartsEnabled: true,
      guestCourseEnabled: true,
      placementTestsEnabled: false,
      catalogVersion: '2.0.0',
      minimumClientVersion: '2.0.0',
    );
    final gate = Completer<void>();
    final repo = _GatedFlagsRepository(flags, gate);
    final uid = StateProvider<String?>((ref) => null);
    final container = ProviderContainer(
      overrides: [
        courseFlagsRepositoryProvider.overrideWithValue(repo),
        authUidProvider.overrideWith((ref) => ref.watch(uid)),
      ],
    );
    addTearDown(() async {
      if (!gate.isCompleted) gate.complete();
      await Future<void>.delayed(Duration.zero);
      container.dispose();
    });

    await container.read(courseFlagsProvider.future);
    container.read(uid.notifier).state = 'anon-uid';
    final reloading = container.read(courseFlagsProvider);
    expect(reloading.isLoading, isTrue);
    expect(reloading.asData, isNull);
    expect(reloading.hasValue, isTrue);
    expect(repo.loads, 2);

    final resolved = courseFlagsForRouting(reloading);
    expect(resolved.ready, isTrue);
    expect(resolved.flags, flags);
    expect(
      resolveAppRoot(
        signedIn: true,
        anonymous: true,
        flagsReady: resolved.ready,
        flags: resolved.flags,
        onboarding: const OnboardingDraft(step: OnboardingStep.firstLesson),
      ),
      AppRootDestination.guestCourse,
    );

    final failed = courseFlagsForRouting(
      AsyncError<CourseFlags>(StateError('unread'), StackTrace.empty),
    );
    expect(failed.ready, isTrue);
    expect(failed.flags, isNull);
    expect(
      resolveAppRoot(
        signedIn: true,
        anonymous: true,
        flagsReady: failed.ready,
        flags: failed.flags,
        onboarding: const OnboardingDraft(step: OnboardingStep.firstLesson),
      ),
      AppRootDestination.auth,
    );
  });
}
