/// Home → calibration warm-up → lesson result → Home.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/live_access.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/course_home_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/screens/lesson_result_screen.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/screens/poker_table_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

class _RecordingAnalytics extends AnalyticsService {
  _RecordingAnalytics() : super(enabled: true);

  @override
  Future<void> logHomeCourseView({required String status}) async {}

  @override
  Future<void> logHomeNodeOpen({
    required String lessonId,
    required String nodeState,
  }) async {}

  @override
  Future<void> logHomeNodeLockedTap({required String lessonId}) async {}

  @override
  Future<void> logHomeResume({required String lessonId}) async {}
}

class _CalibrationCourse extends CourseService {
  int completeCalls = 0;
  String? lastLessonId;
  String? lastSessionId;

  @override
  Future<CompleteCourseLessonResult> completeCalibrationWarmUp({
    required String lessonId,
    String? sessionId,
    String? catalogVersion,
  }) async {
    completeCalls += 1;
    lastLessonId = lessonId;
    lastSessionId = sessionId;
    return CompleteCourseLessonResult(
      attemptId: 'attempt-cal',
      lessonId: lessonId,
      xpAwarded: 25,
      mastery: 1,
      streak: 4,
      acceptedAccuracy: 0.8,
      liveTrainingGranted: false,
      duplicate: false,
    );
  }
}

class _TableController extends GameController {
  _TableController(super.ref);

  CourseLiveContext? launched;

  @override
  void prepareTraining({CourseLiveContext? courseContext}) {
    launched = courseContext;
    state = TableSession(loading: true, courseContext: courseContext);
  }

  @override
  Future<void> startTraining({bool continueTable = false}) async {}

  void emit(TableSession session) => state = session;
}

class _FixedHome extends CourseHomeController {
  _FixedHome(this.snapshot);

  final CourseHomeSnapshot snapshot;

  @override
  Future<CourseHomeSnapshot> build() async => snapshot;
}

const _course = CourseLiveContext(
  courseHandId: 'course-calibration-srp',
  kind: 'calibration',
  lessonId: HomeScreen.calibrationLessonId,
  returnNodeId: HomeScreen.calibrationResultNodeId,
  scaffolding: 'reduced',
);

CourseHomeSnapshot _snapshot() {
  return const CourseHomeSnapshot(
    status: CourseHomeLoadStatus.ready,
    sections: [],
    streak: 4,
    lifetimeXp: 80,
    acceptedAccuracy: 0.8,
    nextLessonId: HomeScreen.calibrationLessonId,
    catalogVersion: 'course-v2',
    rexLine: 'One calibration hand, then the result.',
    nodes: [
      CourseMapNode(
        lessonId: HomeScreen.calibrationLessonId,
        title: 'Prep a coached Live warm-up hand',
        summary: 'Calibration warm-up',
        kind: CourseNodeKind.lesson,
        state: CourseNodeState.available,
        sectionId: 'sec-7',
        sectionTitle: 'Section Seven',
        unitId: 'unit-07-11-warmup',
        unitTitle: 'Live Training warm-up prep',
        isNext: true,
      ),
    ],
  );
}

GameState _hand({required bool over}) {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 400,
        isHero: true,
        holeCards: [CardModel.fromCode('As'), CardModel.fromCode('Js')],
      ),
      const PlayerModel(
        id: 1,
        name: 'Sam',
        archetype: PlayerArchetype.tag,
        stack: 380,
      ),
    ],
    mode: GameMode.training,
    street: over ? Street.river : Street.preflop,
    mainPot: 12,
    isHandOver: over,
    waitingForHero: !over,
    resultMessage: over ? 'Hand complete' : null,
    winnerIds: over ? const [0] : const [],
  );
}

TableSession _session({required bool over}) {
  return TableSession(
    game: _hand(over: over),
    liveView: LiveHandViewModel.fromJson({
      'sessionId': 'sess-calibration-1',
      'status': over ? 'complete' : 'playing',
      'street': over ? 'river' : 'preflop',
    }),
    coach:
        over
            ? const CoachFeedback(
              verdict: CoachVerdict.correct,
              message: 'Standard open. Trust the plan.',
            )
            : const CoachFeedback(),
    courseContext: _course,
  );
}

Future<_Harness> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final course = _CalibrationCourse();
  final analytics = _RecordingAnalytics();
  final slot = _TableSlot();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        heroIdentityProvider.overrideWithValue(const HeroIdentity()),
        courseHomeProvider.overrideWith(() => _FixedHome(_snapshot())),
        courseServiceProvider.overrideWithValue(course),
        analyticsServiceProvider.overrideWithValue(analytics),
        gameControllerProvider.overrideWith((ref) {
          return slot.controller ??= _TableController(ref);
        }),
      ],
      child: MaterialApp(theme: buildPokerTheme(), home: const HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(course, slot);
}

class _TableSlot {
  _TableController? controller;
}

class _Harness {
  _Harness(this.course, this.slot);

  final _CalibrationCourse course;
  final _TableSlot slot;

  _TableController get table => slot.controller!;
}

Future<void> _openWarmUp(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Prep a coached Live warm-up hand'));
  await tester.tap(find.text('Prep a coached Live warm-up hand'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home → warm-up → result → Home after a finished hand', (
    tester,
  ) async {
    final harness = await _pump(tester);
    await _openWarmUp(tester);

    expect(find.byType(PokerTableScreen), findsOneWidget);
    expect(
      harness.table.launched?.returnNodeId,
      HomeScreen.calibrationResultNodeId,
    );
    expect(
      harness.table.launched?.returnNodeId,
      isNot(HomeScreen.calibrationLessonId),
    );

    harness.table.emit(_session(over: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Back to course'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LessonResultScreen), findsOneWidget);
    expect(find.text('Lesson complete'), findsOneWidget);
    expect(find.byType(LessonRunnerScreen), findsNothing);
    expect(find.text('Warm-up checklist must include?'), findsNothing);
    expect(harness.course.completeCalls, 1);
    expect(harness.course.lastLessonId, HomeScreen.calibrationLessonId);
    expect(harness.course.lastSessionId, 'sess-calibration-1');

    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();

    expect(find.byType(LessonResultScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(harness.course.completeCalls, 1);
  });

  testWidgets('coach return from a finished warm-up opens the result', (
    tester,
  ) async {
    final harness = await _pump(tester);
    await _openWarmUp(tester);
    harness.table.emit(_session(over: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.ensureVisible(find.text('Back to course'));
    await tester.tap(find.text('Back to course'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Lesson complete'), findsOneWidget);
    expect(find.byType(LessonRunnerScreen), findsNothing);
    expect(harness.course.completeCalls, 1);
  });

  testWidgets('leaving before the hand finishes does not complete the lesson', (
    tester,
  ) async {
    final harness = await _pump(tester);
    await _openWarmUp(tester);
    harness.table.emit(_session(over: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PokerTableScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byType(PokerTableScreen), findsNothing);
    expect(find.byType(LessonResultScreen), findsNothing);
    expect(find.byType(LessonRunnerScreen), findsNothing);
    expect(find.text('Home'), findsWidgets);
    expect(harness.course.completeCalls, 0);
  });
}
