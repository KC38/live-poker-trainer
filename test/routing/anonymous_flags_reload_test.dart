/// Anonymous sign-in must not send a guest to Auth or reset the first lesson
/// while course flags reload.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/main.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_flags_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/firestore/course_flags_repository.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';

const _guestFlags = CourseFlags(
  courseEnabled: true,
  courseStartsEnabled: true,
  guestCourseEnabled: true,
  placementTestsEnabled: true,
  catalogVersion: '2.0.0',
  minimumClientVersion: '2.0.0',
);

class _GatedFlagsRepository extends CourseFlagsRepository {
  _GatedFlagsRepository(this._gate, {CourseFlags? afterReload})
    : _afterReload = afterReload ?? _guestFlags;

  final Completer<void> _gate;
  final CourseFlags _afterReload;
  int loads = 0;

  @override
  Future<CourseFlags> load({String? clientVersion}) async {
    loads += 1;
    if (loads > 1) {
      await _gate.future;
      return _afterReload;
    }
    return _guestFlags;
  }
}

class _FirstLessonOnboarding extends OnboardingController {
  _FirstLessonOnboarding() : super(null) {
    state = const OnboardingDraft(step: OnboardingStep.firstLesson);
  }
}

/// Stand-in for [LessonRunnerScreen] after Start lesson replaces the launch CTA.
class _InProgressFirstLesson extends StatefulWidget {
  const _InProgressFirstLesson();

  @override
  State<_InProgressFirstLesson> createState() => _InProgressFirstLessonState();
}

class _InProgressFirstLessonState extends State<_InProgressFirstLesson> {
  static int mounts = 0;

  @override
  void initState() {
    super.initState();
    mounts += 1;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('In progress: your two cards'));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('anonymous sign-in keeps the first lesson while flags reload', (
    tester,
  ) async {
    _InProgressFirstLessonState.mounts = 0;
    final gate = Completer<void>();
    final repo = _GatedFlagsRepository(gate);
    final session = StateProvider<AppAuthSnapshot>(
      (ref) => const AppAuthSnapshot(),
    );
    final container = ProviderContainer(
      overrides: [
        appAuthProvider.overrideWith((ref) => AsyncData(ref.watch(session))),
        userDocProvider.overrideWith((ref) async => null),
        analyticsServiceProvider.overrideWithValue(
          AnalyticsService(enabled: false),
        ),
        onboardingControllerProvider.overrideWith(
          (ref) => _FirstLessonOnboarding(),
        ),
        courseFlagsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(() async {
      if (!gate.isCompleted) gate.complete();
      await Future<void>.delayed(Duration.zero);
      container.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PokerLabApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Get started'), findsOneWidget);
    expect(repo.loads, 1);
    expect(container.read(courseFlagsProvider).asData?.value, _guestFlags);

    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          MaterialPageRoute<void>(
            builder: (_) => const _InProgressFirstLesson(),
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('In progress: your two cards'), findsOneWidget);
    expect(find.text('Start lesson'), findsNothing);
    expect(_InProgressFirstLessonState.mounts, 1);

    container.read(session.notifier).state = const AppAuthSnapshot(
      uid: 'anon-uid',
      isAnonymous: true,
    );
    await tester.pump();

    final reloading = container.read(courseFlagsProvider);
    expect(reloading.isLoading, isTrue);
    expect(reloading.asData, isNull);
    expect(reloading.hasValue, isTrue);
    expect(repo.loads, 2);
    expect(courseFlagsForRouting(reloading).flags, _guestFlags);

    expect(find.byType(AuthScreen, skipOffstage: false), findsNothing);
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Start lesson'), findsNothing);
    expect(find.text('In progress: your two cards'), findsOneWidget);
    expect(_InProgressFirstLessonState.mounts, 1);

    gate.complete();
    await tester.pump();
    await tester.pump();

    expect(find.text('In progress: your two cards'), findsOneWidget);
    expect(find.byType(AuthScreen, skipOffstage: false), findsNothing);
    expect(_InProgressFirstLessonState.mounts, 1);
  });

  testWidgets(
    'a disabled flag read after anonymous sign-in still fails closed',
    (tester) async {
      _InProgressFirstLessonState.mounts = 0;
      final gate = Completer<void>();
      final repo = _GatedFlagsRepository(
        gate,
        afterReload: CourseFlags.disabled(),
      );
      final session = StateProvider<AppAuthSnapshot>(
        (ref) => const AppAuthSnapshot(),
      );
      final container = ProviderContainer(
        overrides: [
          appAuthProvider.overrideWith((ref) => AsyncData(ref.watch(session))),
          userDocProvider.overrideWith((ref) async => null),
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
          onboardingControllerProvider.overrideWith(
            (ref) => _FirstLessonOnboarding(),
          ),
          courseFlagsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(() async {
        if (!gate.isCompleted) gate.complete();
        await Future<void>.delayed(Duration.zero);
        container.dispose();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PokerLabApp(),
        ),
      );
      await tester.pump();
      await tester.pump();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              builder: (_) => const _InProgressFirstLesson(),
            ),
          );
      await tester.pumpAndSettle();

      container.read(session.notifier).state = const AppAuthSnapshot(
        uid: 'anon-uid',
        isAnonymous: true,
      );
      await tester.pump();

      expect(find.byType(AuthScreen, skipOffstage: false), findsNothing);
      expect(find.text('In progress: your two cards'), findsOneWidget);
      expect(_InProgressFirstLessonState.mounts, 1);

      gate.complete();
      await tester.pump();
      await tester.pump();

      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('In progress: your two cards'), findsNothing);
      expect(_InProgressFirstLessonState.mounts, 1);
    },
  );
}
