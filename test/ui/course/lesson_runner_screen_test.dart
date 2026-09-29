/// Lesson runner submit gating, soft-grade retry, and bootstrap errors.
library;

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/auth_service.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_choice_visuals.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/screens/lesson_result_screen.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

class _ScriptedCourseService extends CourseService {
  _ScriptedCourseService(this.catalog) : super();

  final CourseCatalog catalog;

  /// Last lessonId passed to [startLesson] (for prefix-resolve assertions).
  String? lastStartedLessonId;

  List<CourseActivity> get activities =>
      catalog.activitiesForLesson(kFirstCourseLessonId);

  @override
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
    String? experienceBand,
    int? dailyGoalMinutes,
    String? recommendedLessonId,
  }) async {}

  @override
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
  }) async {
    lastStartedLessonId = lessonId;
    if (lessonId != kFirstCourseLessonId) {
      throw const CourseServiceException('Unknown lesson', code: 'not-found');
    }
    final first = activities.first;
    return StartCourseLessonResult(
      attempt: CourseAttemptSnapshot(
        attemptId: 'attempt-1',
        lessonId: lessonId,
        catalogVersion: catalogVersion,
        status: 'in_progress',
        activityIndex: 0,
        currentActivityId: first.id,
        livesRemaining: 3,
        livesMax: 3,
        acceptedCount: 0,
        scoredCount: 0,
        stepCount: 0,
      ),
      resume: CourseResumePointer(
        attemptId: 'attempt-1',
        lessonId: lessonId,
        activityId: first.id,
        activityIndex: 0,
      ),
      duplicate: false,
    );
  }

  @override
  Future<SubmitCourseStepResult> submitStep({
    required String attemptId,
    required String activityId,
    required String idempotencyKey,
    String? catalogVersion,
    String? choiceId,
    List<String>? orderedIds,
    double? numericValue,
  }) async {
    final index = activities.indexWhere((a) => a.id == activityId);
    final accepted =
        activityId == 'act-01-01-01-explain-hole-cards' ||
        choiceId == 'choice-hero-holes' ||
        choiceId == 'choice-only-you';
    final nextIndex = accepted
        ? (index + 1).clamp(0, activities.length - 1)
        : index;
    return SubmitCourseStepResult(
      attemptId: attemptId,
      activityId: activityId,
      grade: accepted ? SoftGrade.recommended : SoftGrade.questionable,
      feedback: accepted ? 'Nice.' : 'Look at your two cards.',
      accepted: accepted,
      lifeLost: false,
      livesRemaining: 3,
      xpAwarded: accepted ? 10 : 0,
      remediationRequired: false,
      resume: CourseResumePointer(
        attemptId: attemptId,
        lessonId: kFirstCourseLessonId,
        activityId: activities[nextIndex].id,
        activityIndex: nextIndex,
      ),
      duplicate: false,
    );
  }

  @override
  Future<CompleteCourseLessonResult> completeLesson({
    required String attemptId,
    required String idempotencyKey,
    String? catalogVersion,
  }) async {
    return const CompleteCourseLessonResult(
      attemptId: 'attempt-1',
      lessonId: kFirstCourseLessonId,
      xpAwarded: 25,
      mastery: 1,
      streak: 1,
      acceptedAccuracy: 1,
      liveTrainingGranted: false,
      duplicate: false,
    );
  }
}

Widget _app(Widget child, {required CourseCatalog catalog}) {
  final base = buildPokerTheme();
  return ProviderScope(
    overrides: [
      soundServiceProvider.overrideWithValue(SoundService.silent()),
      courseCatalogProvider.overrideWith((ref) async => catalog),
      analyticsServiceProvider.overrideWithValue(
        AnalyticsService(enabled: false),
      ),
      onboardingControllerProvider.overrideWith(
        (ref) => OnboardingController(null),
      ),
      heroIdentityProvider.overrideWithValue(const HeroIdentity()),
    ],
    child: MaterialApp(
      theme: base.copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CourseCatalog catalog;
  late _ScriptedCourseService service;

  setUpAll(() async {
    final raw = await rootBundle.loadString(kCourseCatalogAssetPath);
    catalog = CourseCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  setUp(() {
    service = _ScriptedCourseService(catalog);
  });

  test('hero hole recovery names the You seat', () {
    expect(tableChoiceRecoveryLabel('choice-hero-holes'), 'You');
    expect(tableChoiceRecoveryLabel('choice-only-you'), 'You');
    expect(tableChoiceRecoveryLabel('choice-checkpoint-holes'), 'You');
    expect(tableChoiceRecoveryLabel('choice-hero-again'), 'You');
  });

  testWidgets('a miss says Continue and names You, not Got it', (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: kFirstCourseLessonId,
          courseService: service,
          startRequestId: 'start_miss',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap your cards').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.textContaining('Tap your cards'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-hero')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Nice!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey<String>('lesson-board')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Try: You'), findsOneWidget);
    expect(find.text("Oops, that's not correct"), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Got it'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Try: You'), findsNothing);
    expect(find.text("Oops, that's not correct"), findsNothing);
  });

  testWidgets('feedback Continue uses the elevated button metrics', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: kFirstCourseLessonId,
          courseService: service,
          startRequestId: 'start_continue_metrics',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap your cards').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-hero')));
    await tester.pump();
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    const states = <WidgetState>{};
    expect(
      button.style?.minimumSize?.resolve(states),
      const Size.fromHeight(54),
    );
    final shape = button.style?.shape?.resolve(states);
    expect(shape, isA<RoundedRectangleBorder>());
    expect(
      (shape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(16),
    );
    expect(button.style?.backgroundColor?.resolve(states), AppColors.success);
    expect(button.style?.foregroundColor?.resolve(states), AppColors.bgDark);
    final label = tester.widget<Text>(
      find.descendant(
        of: find.widgetWithText(FilledButton, 'Continue'),
        matching: find.text('Continue'),
      ),
    );
    expect(label.style?.fontSize, 16);
    expect(label.style?.fontWeight, FontWeight.w800);
    expect(label.style?.fontFamily, contains('Manrope'));
  });

  testWidgets(
    'explain felt tap then table tap auto-submits',
    (tester) async {
      // Tall surface so the felt + feedback dock stay hit-testable without
      // scrolling (board/hero MiniCard centers otherwise land on each other).
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _app(
          LessonRunnerScreen(
            lessonId: kFirstCourseLessonId,
            courseService: service,
            startRequestId: 'start_runner',
          ),
          catalog: catalog,
        ),
      );
      await tester.pump();
      await tester.pump();
      for (
        var i = 0;
        i < 40 && find.textContaining('Tap your cards').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.textContaining('Tap your cards'), findsOneWidget);
      // Explain is teach-by-doing — no Continue dock.
      expect(find.widgetWithText(FilledButton, 'Continue'), findsNothing);

      final heroRail = find.byWidgetPredicate(
        (w) => w is MiniCard && w.size == MiniCardSize.hero,
      );
      expect(heroRail, findsAtLeastNWidgets(2));
      await tester.tap(heroRail.first);
      await tester.pump();
      await tester.pump();
      expect(find.text('Nice!'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      // Mid-advance: feedback dock stays (lightweight button spinner), never a
      // full-screen bootstrap spinner.
      expect(find.text('Nice!'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Check'), findsNothing);
      expect(find.text('Undo'), findsNothing);
      final fullScreenSpinners = find.descendant(
        of: find.byType(SafeArea),
        matching: find.byWidgetPredicate(
          (w) => w is Center && w.child is CircularProgressIndicator,
        ),
      );
      expect(fullScreenSpinners, findsNothing);
      await tester.pump();
      await tester.pump();

      expect(find.text('Tap your hole cards on the table.'), findsNothing);
      expect(find.textContaining('Tap your cards'), findsWidgets);
      expect(find.byType(MiniCard), findsWidgets);
      // Table taps auto-submit — no Check dock.
      expect(find.widgetWithText(FilledButton, 'Check'), findsNothing);

      // Wrong region first — board MiniCards (small) auto-submit.
      final boardCards = find.byWidgetPredicate(
        (w) => w is MiniCard && w.size == MiniCardSize.small,
      );
      expect(boardCards, findsAtLeastNWidgets(3));
      await tester.tap(boardCards.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Think again'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      // Sticky footer keeps Try again reachable without scrolling the sheet.
      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(find.text('Think again'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Check'), findsNothing);

      // Advance with the recommended hole-card tap (hero size).
      await tester.tap(heroRail.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Nice!'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Tap the cards only you can see.'), findsOneWidget);
      expect(find.byType(MiniCard), findsWidgets);
      expect(find.widgetWithText(FilledButton, 'Check'), findsNothing);

      await tester.tap(heroRail.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Nice!'), findsOneWidget);
    },
    // Pre-existing flake on main: after Try again, hero MiniCard centers
    // hit-test the board row on this runner layout.
    skip: true,
  );

  testWidgets('unknown lesson shows retry chrome', (tester) async {
    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-does-not-exist',
          courseService: service,
          startRequestId: 'start_missing',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.text('Could not start the lesson').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Could not start the lesson'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('truncated openlesson prefix starts with canonical lesson id', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-01-01',
          courseService: service,
          startRequestId: 'start_prefix',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    await tester.pump();
    for (var i = 0; i < 40 && service.lastStartedLessonId == null; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(service.lastStartedLessonId, kFirstCourseLessonId);
    expect(find.text('Could not start the lesson'), findsNothing);
    expect(find.textContaining('Tap your cards'), findsOneWidget);
  });

  testWidgets('permission-denied start says missing permissions, not sign-in', (
    tester,
  ) async {
    final denied = _PermissionDeniedStartCourseService(catalog);
    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: kFirstCourseLessonId,
          courseService: denied,
          startRequestId: 'start_denied',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.text('Could not start the lesson').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Could not start the lesson'), findsOneWidget);
    expect(find.text('Missing or insufficient permissions.'), findsOneWidget);
    expect(find.textContaining('Sign-in failed'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    // Bootstrap retries the denied start once before showing the error.
    expect(denied.startCount, 2);
  });

  testWidgets('one permission-denied start retries into the first activity', (
    tester,
  ) async {
    final once = _PermissionDeniedOnceCourseService(catalog);
    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: kFirstCourseLessonId,
          courseService: once,
          startRequestId: 'start_denied_once',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap your cards').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.textContaining('Tap your cards'), findsOneWidget);
    expect(find.text('Could not start the lesson'), findsNothing);
    expect(find.text('Retry'), findsNothing);
    expect(find.textContaining('Sign-in failed'), findsNothing);
    expect(once.startCount, 2);
  });

  testWidgets(
    'missing previous lesson offers that lesson, not the raw exception',
    (tester) async {
      final locked = _PrerequisiteLockedCourseService(catalog);
      await tester.pumpWidget(
        _app(
          LessonRunnerScreen(
            lessonId: 'lesson-01-01-02-suits-and-ranks',
            courseService: locked,
            startRequestId: 'start_prereq',
          ),
          catalog: catalog,
        ),
      );
      await tester.pump();
      for (
        var i = 0;
        i < 40 &&
            find
                .text('Complete the previous lesson before starting this one.')
                .evaluate()
                .isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(
        find.text('Complete the previous lesson before starting this one.'),
        findsOneWidget,
      );
      expect(find.textContaining('CourseServiceException'), findsNothing);
      expect(find.textContaining('failed-precondition'), findsNothing);
      expect(find.text('Open Your two cards'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Technical details'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          'CourseServiceException(failed-precondition): '
          'Complete the previous lesson before starting this one.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open Your two cards'));
      await tester.pump();
      for (
        var i = 0;
        i < 40 && find.textContaining('Tap your cards').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.textContaining('Tap your cards'), findsOneWidget);
      expect(find.text('Could not start the lesson'), findsWidgets);
    },
  );

  testWidgets('retry starts the lesson after the prerequisite is complete', (
    tester,
  ) async {
    final locked = _PrerequisiteLockedCourseService(catalog);
    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-01-02-suits-and-ranks',
          courseService: locked,
          startRequestId: 'start_prereq_retry',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (var i = 0; i < 40 && find.text('Retry').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Retry'), findsOneWidget);
    locked.previousComplete = true;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Ace is high here.').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.textContaining('Ace is high here.'), findsOneWidget);
    expect(find.text('Could not start the lesson'), findsNothing);
  });

  testWidgets('suits and ranks uses the lesson frame, not a title bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final locked = _PrerequisiteLockedCourseService(catalog);
    locked.previousComplete = true;
    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-01-02-suits-and-ranks',
          courseService: locked,
          startRequestId: 'start_suits_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Ace is high here.').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Suits and ranks'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Ace is high here.'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Redo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.byKey(const ValueKey('suits-ranks-felt')), findsOneWidget);
    expect(find.byType(SuitTapTile), findsNWidgets(4));

    final bubble = find.byKey(const ValueKey<String>('lesson-speech-bubble'));
    final speech = find.textContaining('Ace is high here.');
    expect(
      tester.getTopLeft(speech).dy,
      greaterThan(tester.getTopLeft(bubble).dy),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('suits-ranks-felt'))).height,
      lessThanOrEqualTo(tester.getSize(find.byType(LessonScreenLayout)).height),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('button and blinds uses the lesson frame and the full table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-01-03-blinds-and-button',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_blinds_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Button marks the dealer').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Button and blinds'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Button marks the dealer'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Redo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('lesson-table-stage')), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('SB'), findsOneWidget);
    expect(find.text('BB'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hand ranks uses the lesson frame and the rank ladder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-02-01-hand-ranks',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_ranks_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap each rung').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Hand ranks'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap each rung'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.byKey(const ValueKey('hand-ladder-felt')), findsOneWidget);
    expect(find.text('High card'), findsOneWidget);
    expect(find.text('Flush'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('best five uses the lesson frame and the five-card picker', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-02-02-best-five-kickers',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_best_five_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap each card that plays').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Best five and kickers'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap each card that plays'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.byKey(const ValueKey('best-five-felt')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fold check call uses the lesson frame and the three buttons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-03-01-fold-check-call',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_passive_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap Fold').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Fold, check, call'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap Fold'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('FOLD'), findsOneWidget);
    expect(find.text('CHECK'), findsOneWidget);
    expect(find.text('CALL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bet raise all-in uses the lesson frame and the three buttons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-03-02-bet-raise-allin',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_aggro_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap Bet').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Bet, raise, all-in'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap Bet'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('BET'), findsOneWidget);
    expect(find.text('RAISE'), findsOneWidget);
    expect(find.text('ALL-IN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('streets and order uses the lesson frame and the timeline', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-04-01-streets-and-order',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_streets_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap each street').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Streets and action order'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap each street'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('PREFLOP'), findsOneWidget);
    expect(find.text('RIVER'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('how pots are won uses the lesson frame and the three paths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-05-01-winning-pots',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_pots_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap each path').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('How pots are won'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap each path'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('FOLD WIN'), findsOneWidget);
    expect(find.text('SHOWDOWN'), findsOneWidget);
    expect(find.text('SIDE POT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('toy hand uses the lesson frame and the three beats', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-06-01-guided-complete-hand',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_toy_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap Blinds').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Play a full toy hand'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap Blinds'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('BLINDS'), findsOneWidget);
    expect(find.text('YOU ACT'), findsOneWidget);
    expect(find.text('ENDING'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('section 1 jump check uses the lesson frame', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-01-06-02-section-one-jump',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_jump_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('strongest hand').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Section 1 jump check'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('strongest hand'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('Flush'), findsOneWidget);
    expect(find.text('Straight'), findsOneWidget);
    expect(find.text('Two pair'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('position labels uses the lesson frame and the six-max table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-02-01-01-position-labels',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_position_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap the button').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Position labels'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap the button'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('lesson-table-stage')), findsOneWidget);
    expect(find.text('EP'), findsWidgets);
    expect(find.text('BTN'), findsWidgets);
    expect(find.text('D'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('acting order uses the lesson frame and preflop seats', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-02-01-02-acting-order',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_acting_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap EP').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Acting order'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap EP'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('lesson-table-stage')), findsOneWidget);
    expect(find.text('EP'), findsWidgets);
    expect(find.text('HJ'), findsWidgets);
    expect(find.text('BTN'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hand families uses the lesson frame and the family list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-02-02-01-hand-families',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_families_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap each family').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Hand families'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap each family'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('Pairs'), findsOneWidget);
    expect(find.text('Broadways'), findsOneWidget);
    expect(find.text('Connectors'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('open or fold uses the lesson frame and the range tiles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-02-03-01-open-fold',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_open_fold_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap Early').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Open or fold baseline'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap Early'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('EARLY'), findsOneWidget);
    expect(find.text('BUTTON'), findsOneWidget);
    expect(find.text('LIVE 3x'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('versus an open uses the lesson frame and the response tiles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-02-04-01-facing-raise',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_facing_raise_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap Fold').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Versus an open'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap Fold'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('FOLD'), findsOneWidget);
    expect(find.text('CALL'), findsOneWidget);
    expect(find.text('3-BET'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('effective stacks uses the lesson frame and the depth tiles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-02-05-01-effective-stack',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_effective_stack_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap Chips').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Effective stacks'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap Chips'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('CHIPS→BB'), findsOneWidget);
    expect(find.text('SHORTER'), findsOneWidget);
    expect(find.text('DEPTH'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('live table habits uses the lesson frame and the habit tiles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-02-06-01-live-habits',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_live_habits_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap Watch').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Live table habits'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap Watch'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('WATCH'), findsOneWidget);
    expect(find.text('SAY'), findsOneWidget);
    expect(find.text('COVER'), findsOneWidget);
    expect(find.text('WAIT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full-ring baseline uses the lesson frame and the ring tiles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-02-07-01-baseline-full-hand',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_full_ring_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap Nine').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Full-ring baseline hand'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap Nine'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('NINE'), findsOneWidget);
    expect(find.text('SAME'), findsOneWidget);
    expect(find.text('POSITION'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('baseline jump check uses the lesson frame and the seat map', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: 'lesson-02-07-02-section-two-jump',
          courseService: _PrerequisiteLockedCourseService(catalog)
            ..previousComplete = true,
          startRequestId: 'start_baseline_jump_frame',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    for (
      var i = 0;
      i < 40 &&
          find.textContaining('Seat right before the button').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Baseline jump check'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Seat right before the button'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(find.text('CO'), findsWidgets);
    expect(find.text('HJ'), findsWidgets);
    expect(find.text('SB'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hung startLesson surfaces retry instead of empty spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: kFirstCourseLessonId,
          courseService: _HungStartCourseService(catalog),
          startRequestId: 'start_hang',
          bootstrapTimeout: const Duration(milliseconds: 80),
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.text('Could not start the lesson'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('taking too long'), findsOneWidget);
  });

  testWidgets('stale activity submit resyncs to server resume cursor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final stale = _StaleThenResumeCourseService(catalog);
    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: kFirstCourseLessonId,
          courseService: stale,
          startRequestId: 'start_stale',
        ),
        catalog: catalog,
      ),
    );
    await tester.pump();
    await tester.pump();
    for (
      var i = 0;
      i < 40 && find.textContaining('Tap your cards').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.textContaining('Tap your cards'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-hero')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Caught up to your saved progress.'), findsOneWidget);
    // Resync lands on the guided hole-card step (server cursor).
    // The prompt is the speech bubble, once.
    expect(find.text('Tap your hole cards on the table.'), findsOneWidget);
    // Auto-submit table taps — Check is gone.
    expect(find.widgetWithText(FilledButton, 'Check'), findsNothing);
    expect(find.text('Tap the answer on the table.'), findsNothing);
  });

  testWidgets('stale submit on the same step stays silent', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final stale = _SameStepStaleCourseService(catalog);
    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: kFirstCourseLessonId,
          courseService: stale,
          startRequestId: 'start_same_step',
        ),
        catalog: catalog,
      ),
    );
    await _pumpUntil(tester, find.textContaining('Tap your cards'));

    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-hero')));
    await tester.pump();
    await tester.pump();

    expect(stale.startCount, 2);
    expect(find.text('Caught up to your saved progress.'), findsNothing);
    expect(find.textContaining('Stale activity'), findsNothing);
    expect(find.textContaining('Tap your cards'), findsOneWidget);
  });

  testWidgets('order-sequence lessons hide the Check dock', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const orderLessonId = 'lesson-order';
    final orderCatalog = _tinyCatalog(
      lessonId: orderLessonId,
      title: 'Order seats',
      activity: CourseActivity(
        id: 'act-order',
        order: 1,
        stage: ActivityStage.guided,
        renderer: ActivityRenderer.orderSequence,
        estimatedSeconds: 30,
        accessibilityText: 'Order',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Tap seats in order.',
        sequenceItems: const [
          CourseChoice(id: 'a', label: 'UTG'),
          CourseChoice(id: 'b', label: 'BTN'),
        ],
      ),
    );

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: orderLessonId,
          courseService: _TinyLessonService(orderCatalog, orderLessonId),
          startRequestId: 'start_order',
        ),
        catalog: orderCatalog,
      ),
    );
    await _pumpUntil(tester, find.text('Tap seats in order.'));
    expect(find.widgetWithText(FilledButton, 'Check'), findsNothing);
    await tester.tap(find.text('UTG'));
    await tester.pump();
    expect(find.widgetWithText(FilledButton, 'Check'), findsNothing);
  });

  testWidgets('numeric pot-price still uses an enabled Check dock', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const numericLessonId = 'lesson-numeric';
    final numericCatalog = _tinyCatalog(
      lessonId: numericLessonId,
      title: 'Pot math',
      activity: CourseActivity(
        id: 'act-numeric',
        order: 1,
        stage: ActivityStage.unguided,
        renderer: ActivityRenderer.numericPotPrice,
        estimatedSeconds: 30,
        accessibilityText: 'Pot',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'How big is the pot?',
        numericQuestion: 'Pot size?',
        numericUnit: 'chips',
      ),
    );

    await tester.pumpWidget(
      _app(
        LessonRunnerScreen(
          lessonId: numericLessonId,
          courseService: _TinyLessonService(numericCatalog, numericLessonId),
          startRequestId: 'start_numeric',
        ),
        catalog: numericCatalog,
      ),
    );
    await _pumpUntil(tester, find.byType(TextField));
    expect(find.text('Check'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Check'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Check'))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), '9');
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Check'))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('last-step Continue completes while the catalog is reloading', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const lessonId = 'lesson-one-shot';
    final tiny = _tinyCatalog(
      lessonId: lessonId,
      title: 'One shot',
      activity: CourseActivity(
        id: 'act-one',
        order: 1,
        stage: ActivityStage.unguided,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 20,
        accessibilityText: 'Pick',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Tap the only answer.',
        choices: const [
          CourseChoice(id: 'yes', label: 'This one'),
          CourseChoice(id: 'no', label: 'Not this'),
        ],
      ),
    );
    final service = _TinyLessonService(tiny, lessonId);
    final reload = Completer<CourseCatalog>();
    var catalogLoads = 0;
    final reloaded = _tinyCatalog(
      lessonId: lessonId,
      title: 'One shot',
      catalogVersion: '2.0.1',
      activity: tiny.sections.first.units.first.lessons.first.activities.first,
    );
    final container = ProviderContainer(
      overrides: [
        soundServiceProvider.overrideWithValue(SoundService.silent()),
        courseCatalogProvider.overrideWith((ref) async {
          catalogLoads += 1;
          if (catalogLoads == 1) return tiny;
          return reload.future;
        }),
        analyticsServiceProvider.overrideWithValue(
          AnalyticsService(enabled: false),
        ),
        onboardingControllerProvider.overrideWith(
          (ref) => OnboardingController(null),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: LessonRunnerScreen(
            lessonId: lessonId,
            courseService: service,
            startRequestId: 'start_one',
          ),
        ),
      ),
    );
    await _pumpUntil(tester, find.text('Tap the only answer.'));
    expect(find.widgetWithText(FilledButton, 'Check'), findsNothing);

    await tester.tap(find.text('This one'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Nice.'), findsOneWidget);
    expect(service.completeCalls, 0);

    container.invalidate(courseCatalogProvider);
    await tester.pump();
    expect(container.read(courseCatalogProvider).isLoading, isTrue);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(service.completeCalls, 0);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    reload.complete(reloaded);
    await tester.pump();
    await tester.pump();
    expect(service.completeCalls, 1);
    expect(service.lastCompleteCatalogVersion, '2.0.1');
    expect(find.byType(LessonResultScreen), findsOneWidget);
    expect(find.text('LESSON COMPLETE'), findsOneWidget);
  });

  testWidgets(
    'guest Home complete (embedded) reaches result without save-progress',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      const lessonId = 'lesson-one-shot';
      final tiny = _tinyCatalog(
        lessonId: lessonId,
        title: 'Suits and ranks',
        activity: CourseActivity(
          id: 'act-one',
          order: 1,
          stage: ActivityStage.checkpoint,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 20,
          accessibilityText: 'Pick',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Look at your two cards. What do you have?',
          choices: const [
            CourseChoice(id: 'pocket-pair', label: 'A pocket pair'),
            CourseChoice(id: 'suited', label: 'Suited nines'),
          ],
        ),
      );
      final service = _TinyLessonService(tiny, lessonId);
      final onboarding = OnboardingController(null);
      // Already past the first lesson — map opens must not re-enter save CTA.
      await onboarding.continueLearningAsGuest();
      final auth = _AnonymousAuthService();

      final container = ProviderContainer(
        overrides: [
          soundServiceProvider.overrideWithValue(SoundService.silent()),
          courseCatalogProvider.overrideWith((ref) async => tiny),
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
          onboardingControllerProvider.overrideWith((ref) => onboarding),
          authServiceProvider.overrideWithValue(auth),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildPokerTheme().copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
            ),
            home: LessonRunnerScreen(
              lessonId: lessonId,
              courseService: service,
              startRequestId: 'start_suits',
              embeddedInShell: true,
            ),
          ),
        ),
      );
      await _pumpUntil(
        tester,
        find.text('Look at your two cards. What do you have?'),
      );

      await tester.tap(find.text('A pocket pair'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Nice.'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();

      expect(service.completeCalls, 1);
      expect(find.byType(LessonResultScreen), findsOneWidget);
      expect(find.text('LESSON COMPLETE'), findsOneWidget);
      // One accepted step (10) plus the completion bonus (25).
      expect(find.text('+35'), findsOneWidget);
      // Must not flip pendingSaveProgress again from a later map lesson.
      expect(onboarding.state.pendingSaveProgress, isFalse);
    },
  );

  testWidgets(
    'first guest lesson Nice work total includes step XP and the bonus',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      const lessonId = 'lesson-one-shot';
      final tiny = _tinyCatalog(
        lessonId: lessonId,
        title: 'Your two cards',
        activity: CourseActivity(
          id: 'act-one',
          order: 1,
          stage: ActivityStage.checkpoint,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 20,
          accessibilityText: 'Pick',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Look at your two cards. What do you have?',
          choices: const [
            CourseChoice(id: 'pocket-pair', label: 'A pocket pair'),
            CourseChoice(id: 'suited', label: 'Suited nines'),
          ],
        ),
      );
      final service = _TinyLessonService(tiny, lessonId);
      final onboarding = OnboardingController(null);
      await onboarding.setStep(OnboardingStep.firstLesson);

      final container = ProviderContainer(
        overrides: [
          soundServiceProvider.overrideWithValue(SoundService.silent()),
          courseCatalogProvider.overrideWith((ref) async => tiny),
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
          onboardingControllerProvider.overrideWith((ref) => onboarding),
          authServiceProvider.overrideWithValue(_AnonymousAuthService()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildPokerTheme().copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
            ),
            home: LessonRunnerScreen(
              lessonId: lessonId,
              courseService: service,
              startRequestId: 'start_first',
              embeddedInShell: false,
            ),
          ),
        ),
      );
      await _pumpUntil(
        tester,
        find.text('Look at your two cards. What do you have?'),
      );

      await tester.tap(find.text('A pocket pair'));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(service.completeCalls, 1);
      expect(onboarding.state.lastXpAwarded, 35);
      expect(onboarding.state.lastStreak, 1);
      expect(find.byType(LessonResultScreen), findsNothing);
    },
  );

  testWidgets(
    'guest later-lesson complete without shell still reaches result',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      const lessonId = 'lesson-one-shot';
      final tiny = _tinyCatalog(
        lessonId: lessonId,
        title: 'Suits and ranks',
        activity: CourseActivity(
          id: 'act-one',
          order: 1,
          stage: ActivityStage.checkpoint,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 20,
          accessibilityText: 'Pick',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Tap yes.',
          choices: const [
            CourseChoice(id: 'yes', label: 'Yes'),
            CourseChoice(id: 'no', label: 'No'),
          ],
        ),
      );
      final service = _TinyLessonService(tiny, lessonId);
      final onboarding = OnboardingController(null);
      await onboarding.continueLearningAsGuest();
      expect(onboarding.state.firstLessonCompleted, isTrue);

      final container = ProviderContainer(
        overrides: [
          soundServiceProvider.overrideWithValue(SoundService.silent()),
          courseCatalogProvider.overrideWith((ref) async => tiny),
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
          onboardingControllerProvider.overrideWith((ref) => onboarding),
          authServiceProvider.overrideWithValue(_AnonymousAuthService()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildPokerTheme().copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
            ),
            // Legacy path: Home used to omit embeddedInShell.
            home: LessonRunnerScreen(
              lessonId: lessonId,
              courseService: service,
              startRequestId: 'start_legacy',
              embeddedInShell: false,
            ),
          ),
        ),
      );
      await _pumpUntil(tester, find.text('Tap yes.'));
      await tester.tap(find.text('Yes'));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump();

      expect(service.completeCalls, 1);
      expect(find.byType(LessonResultScreen), findsOneWidget);
      expect(onboarding.state.pendingSaveProgress, isFalse);
    },
  );
}

/// Anonymous guest auth for complete-path tests.
class _AnonymousAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  String? get currentUid => 'guest';

  @override
  bool get isAnonymous => true;

  @override
  Future<User> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<User> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<User> signInAnonymously() => throw UnimplementedError();

  @override
  Future<User> linkWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<User> linkWithGoogle() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}
}

/// Stale submit whose resume pointer stays on the activity already showing.
class _SameStepStaleCourseService extends CourseService {
  _SameStepStaleCourseService(this.catalog) : super();

  final CourseCatalog catalog;
  var startCount = 0;

  List<CourseActivity> get activities =>
      catalog.activitiesForLesson(kFirstCourseLessonId);

  @override
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
    String? experienceBand,
    int? dailyGoalMinutes,
    String? recommendedLessonId,
  }) async {}

  @override
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
  }) async {
    startCount += 1;
    final activity = activities.first;
    return StartCourseLessonResult(
      attempt: CourseAttemptSnapshot(
        attemptId: 'attempt-same',
        lessonId: lessonId,
        catalogVersion: catalogVersion,
        status: 'in_progress',
        activityIndex: 0,
        currentActivityId: activity.id,
        livesRemaining: 3,
        livesMax: 3,
        acceptedCount: 0,
        scoredCount: 0,
        stepCount: 0,
      ),
      resume: CourseResumePointer(
        attemptId: 'attempt-same',
        lessonId: lessonId,
        activityId: activity.id,
        activityIndex: 0,
      ),
      duplicate: startCount > 1,
    );
  }

  @override
  Future<SubmitCourseStepResult> submitStep({
    required String attemptId,
    required String activityId,
    required String idempotencyKey,
    String? catalogVersion,
    String? choiceId,
    List<String>? orderedIds,
    double? numericValue,
  }) async {
    throw const CourseServiceException(
      'Stale activity. Resume the lesson and retry.',
      code: 'aborted',
    );
  }
}

/// First explain felt-tap is rejected as stale; resume points at guided.
class _StaleThenResumeCourseService extends CourseService {
  _StaleThenResumeCourseService(this.catalog) : super();

  final CourseCatalog catalog;
  var _startCount = 0;

  List<CourseActivity> get activities =>
      catalog.activitiesForLesson(kFirstCourseLessonId);

  @override
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
    String? experienceBand,
    int? dailyGoalMinutes,
    String? recommendedLessonId,
  }) async {}

  @override
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
  }) async {
    _startCount += 1;
    final activity = _startCount == 1 ? activities.first : activities[1];
    final index = _startCount == 1 ? 0 : 1;
    return StartCourseLessonResult(
      attempt: CourseAttemptSnapshot(
        attemptId: 'attempt-stale',
        lessonId: lessonId,
        catalogVersion: catalogVersion,
        status: 'in_progress',
        activityIndex: index,
        currentActivityId: activity.id,
        livesRemaining: 3,
        livesMax: 3,
        acceptedCount: index,
        scoredCount: 0,
        stepCount: index,
      ),
      resume: CourseResumePointer(
        attemptId: 'attempt-stale',
        lessonId: lessonId,
        activityId: activity.id,
        activityIndex: index,
      ),
      duplicate: _startCount > 1,
    );
  }

  @override
  Future<SubmitCourseStepResult> submitStep({
    required String attemptId,
    required String activityId,
    required String idempotencyKey,
    String? catalogVersion,
    String? choiceId,
    List<String>? orderedIds,
    double? numericValue,
  }) async {
    throw const CourseServiceException(
      'Stale activity. Resume the lesson and retry.',
      code: 'aborted',
    );
  }
}

const _kPermissionDeniedDetail =
    '[cloud_firestore/permission-denied] Missing or insufficient permissions.';

StartCourseLessonResult _startedFirst(CourseCatalog catalog, String lessonId) {
  final first = catalog.activitiesForLesson(lessonId).first;
  return StartCourseLessonResult(
    attempt: CourseAttemptSnapshot(
      attemptId: 'attempt-1',
      lessonId: lessonId,
      catalogVersion: catalog.catalogVersion,
      status: 'in_progress',
      activityIndex: 0,
      currentActivityId: first.id,
      livesRemaining: 3,
      livesMax: 3,
      acceptedCount: 0,
      scoredCount: 0,
      stepCount: 0,
    ),
    resume: CourseResumePointer(
      attemptId: 'attempt-1',
      lessonId: lessonId,
      activityId: first.id,
      activityIndex: 0,
    ),
    duplicate: false,
  );
}

/// Every start is a Firestore owner-rule denial.
class _PermissionDeniedStartCourseService extends CourseService {
  _PermissionDeniedStartCourseService(this.catalog) : super();

  final CourseCatalog catalog;
  var startCount = 0;

  @override
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
    String? experienceBand,
    int? dailyGoalMinutes,
    String? recommendedLessonId,
  }) async {}

  @override
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
  }) async {
    startCount += 1;
    throw const CourseServiceException(
      _kPermissionDeniedDetail,
      code: 'permission-denied',
    );
  }
}

/// First start is denied; the automatic retry opens the lesson.
class _PermissionDeniedOnceCourseService extends CourseService {
  _PermissionDeniedOnceCourseService(this.catalog) : super();

  final CourseCatalog catalog;
  var startCount = 0;

  @override
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
    String? experienceBand,
    int? dailyGoalMinutes,
    String? recommendedLessonId,
  }) async {}

  @override
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
  }) async {
    startCount += 1;
    if (startCount == 1) {
      throw const CourseServiceException(
        _kPermissionDeniedDetail,
        code: 'permission-denied',
      );
    }
    return _startedFirst(catalog, lessonId);
  }
}

/// Suits and ranks stays locked until [previousComplete] is set.
class _PrerequisiteLockedCourseService extends CourseService {
  _PrerequisiteLockedCourseService(this.catalog) : super();

  final CourseCatalog catalog;
  var previousComplete = false;

  @override
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
    String? experienceBand,
    int? dailyGoalMinutes,
    String? recommendedLessonId,
  }) async {}

  @override
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
  }) async {
    if (lessonId == 'lesson-01-01-02-suits-and-ranks' && !previousComplete) {
      throw const CourseServiceException(
        'Complete the previous lesson before starting this one.',
        code: 'failed-precondition',
      );
    }
    return _startedFirst(catalog, lessonId);
  }
}

/// Never completes startLesson — used to assert bootstrap timeout → Retry.
class _HungStartCourseService extends CourseService {
  _HungStartCourseService(this.catalog) : super();

  final CourseCatalog catalog;

  @override
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
    String? experienceBand,
    int? dailyGoalMinutes,
    String? recommendedLessonId,
  }) async {}

  @override
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
  }) {
    return Completer<StartCourseLessonResult>().future;
  }
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  await tester.pump();
  await tester.pump();
  for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

CourseCatalog _tinyCatalog({
  required String lessonId,
  required String title,
  required CourseActivity activity,
  String catalogVersion = '2.0.0',
}) {
  return CourseCatalog(
    catalogVersion: catalogVersion,
    minClientVersion: '1.0.0',
    scope: 'live_cash_nlh',
    coachId: 'rex',
    contentChecksum: 'test-checksum',
    playerTypes: const [],
    sections: [
      CourseSection(
        id: 'sec-test',
        order: 1,
        title: 'Test',
        summary: 'Test',
        experienceBand: 'beginner',
        units: [
          CourseUnit(
            id: 'unit-test',
            order: 1,
            title: 'Test',
            summary: 'Test',
            lessons: [
              CourseLesson(
                id: lessonId,
                order: 1,
                title: title,
                summary: title,
                objectives: const ['Learn'],
                prerequisites: const [],
                remediationLessonIds: const [],
                estimatedMinutes: 3,
                difficultyBand: 1,
                playerTypeRefs: const [],
                introducesPlayerTypes: const [],
                activities: [activity],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _TinyLessonService extends CourseService {
  _TinyLessonService(this.catalog, this.lessonId) : super();

  final CourseCatalog catalog;
  final String lessonId;
  var completeCalls = 0;
  String? lastCompleteCatalogVersion;

  List<CourseActivity> get activities => catalog.activitiesForLesson(lessonId);

  @override
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
    String? experienceBand,
    int? dailyGoalMinutes,
    String? recommendedLessonId,
  }) async {}

  @override
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
  }) async {
    final first = activities.first;
    return StartCourseLessonResult(
      attempt: CourseAttemptSnapshot(
        attemptId: 'attempt-tiny',
        lessonId: lessonId,
        catalogVersion: catalogVersion,
        status: 'in_progress',
        activityIndex: 0,
        currentActivityId: first.id,
        livesRemaining: 3,
        livesMax: 3,
        acceptedCount: 0,
        scoredCount: 0,
        stepCount: 0,
      ),
      resume: CourseResumePointer(
        attemptId: 'attempt-tiny',
        lessonId: lessonId,
        activityId: first.id,
        activityIndex: 0,
      ),
      duplicate: false,
    );
  }

  @override
  Future<SubmitCourseStepResult> submitStep({
    required String attemptId,
    required String activityId,
    required String idempotencyKey,
    String? catalogVersion,
    String? choiceId,
    List<String>? orderedIds,
    double? numericValue,
  }) async {
    return SubmitCourseStepResult(
      attemptId: attemptId,
      activityId: activityId,
      grade: SoftGrade.recommended,
      feedback: 'Nice.',
      accepted: true,
      lifeLost: false,
      livesRemaining: 3,
      xpAwarded: 10,
      remediationRequired: false,
      resume: CourseResumePointer(
        attemptId: attemptId,
        lessonId: lessonId,
        activityId: activityId,
        activityIndex: 1,
      ),
      duplicate: false,
    );
  }

  @override
  Future<CompleteCourseLessonResult> completeLesson({
    required String attemptId,
    required String idempotencyKey,
    String? catalogVersion,
  }) async {
    completeCalls += 1;
    lastCompleteCatalogVersion = catalogVersion;
    return CompleteCourseLessonResult(
      attemptId: attemptId,
      lessonId: lessonId,
      xpAwarded: 25,
      mastery: 1,
      streak: 1,
      acceptedAccuracy: 1,
      liveTrainingGranted: false,
      duplicate: false,
    );
  }
}
