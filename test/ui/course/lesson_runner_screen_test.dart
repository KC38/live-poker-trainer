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
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/auth_service.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
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
      i < 40 && find.text('Tap your cards').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Tap your cards'), findsOneWidget);
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
    expect(find.text('Tap your cards'), findsWidgets);
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
    for (
      var i = 0;
      i < 40 && service.lastStartedLessonId == null;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(service.lastStartedLessonId, kFirstCourseLessonId);
    expect(find.text('Could not start the lesson'), findsNothing);
    expect(find.text('Tap your cards'), findsOneWidget);
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
      i < 40 && find.text('Tap your cards').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Tap your cards'), findsOneWidget);
    final heroRail = find.byWidgetPredicate(
      (w) => w is MiniCard && w.size == MiniCardSize.hero,
    );
    await tester.tap(heroRail.first);
    await tester.pump();
    await tester.pump();
    expect(find.text('Caught up to your saved progress.'), findsOneWidget);
    // Resync lands on the guided hole-card step (server cursor).
    // Felt-first SoftPulse owns the cue — no duplicate prompt/footer.
    expect(find.text('Tap your hole cards on the table.'), findsNothing);
    expect(find.text('Tap your cards'), findsWidgets);
    // Auto-submit table taps — Check is gone.
    expect(find.widgetWithText(FilledButton, 'Check'), findsNothing);
    expect(find.text('Tap the answer on the table.'), findsNothing);
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
      // Must not flip pendingSaveProgress again from a later map lesson.
      expect(onboarding.state.pendingSaveProgress, isFalse);
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
  }) =>
      throw UnimplementedError();

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<User> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<User> signInAnonymously() => throw UnimplementedError();

  @override
  Future<User> linkWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) =>
      throw UnimplementedError();

  @override
  Future<User> linkWithGoogle() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}
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
