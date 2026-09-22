/// Lesson runner submit gating, soft-grade retry, and bootstrap errors.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

class _ScriptedCourseService extends CourseService {
  _ScriptedCourseService(this.catalog) : super();

  final CourseCatalog catalog;

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
    final nextIndex =
        accepted ? (index + 1).clamp(0, activities.length - 1) : index;
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
    ],
    child: MaterialApp(theme: buildPokerTheme(), home: child),
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

  testWidgets('explain felt tap then table tap auto-submits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
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
      i < 40 &&
          find.text('Tap your two cards on the felt.').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Tap your two cards on the felt.'), findsOneWidget);
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
    await tester.pump();

    expect(find.text('Tap your hole cards on the table.'), findsOneWidget);
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
  });

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
      i < 40 &&
          find.text('Tap your two cards on the felt.').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Tap your two cards on the felt.'), findsOneWidget);
    final heroRail = find.byWidgetPredicate(
      (w) => w is MiniCard && w.size == MiniCardSize.hero,
    );
    await tester.tap(heroRail.first);
    await tester.pump();
    await tester.pump();
    expect(find.text('Caught up to your saved progress.'), findsOneWidget);
    // Resync lands on the guided hole-card step (server cursor).
    expect(find.text('Tap your hole cards on the table.'), findsOneWidget);
    // Auto-submit table taps — Check is gone.
    expect(find.widgetWithText(FilledButton, 'Check'), findsNothing);
    expect(find.text('Tap the answer on the table.'), findsOneWidget);
  });
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
    final activity =
        _startCount == 1 ? activities.first : activities[1];
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
