/// Home course map widget / accessibility / analytics coverage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_home_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/home/course_path_view.dart';
import 'package:live_poker_trainer/ui/home/rex_coach_card.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

class _RecordingAnalytics extends AnalyticsService {
  _RecordingAnalytics() : super(enabled: true);

  final List<String> events = <String>[];

  @override
  Future<void> logHomeCourseView({required String status}) async {
    events.add('home_course_view:$status');
  }

  @override
  Future<void> logHomeNodeOpen({
    required String lessonId,
    required String nodeState,
  }) async {
    events.add('home_node_open:$lessonId:$nodeState');
  }

  @override
  Future<void> logHomeNodeLockedTap({required String lessonId}) async {
    events.add('home_node_locked_tap:$lessonId');
  }

  @override
  Future<void> logHomeResume({required String lessonId}) async {
    events.add('home_resume:$lessonId');
  }
}

CourseHomeSnapshot _readySnapshot({
  CourseNodeState second = CourseNodeState.locked,
}) {
  const sections = <CourseSection>[];
  return CourseHomeSnapshot(
    status: CourseHomeLoadStatus.ready,
    sections: sections,
    streak: 2,
    lifetimeXp: 40,
    acceptedAccuracy: 0.75,
    nextLessonId: 'lesson-a',
    rexLine: 'You are next to act on the path. One short lesson, then move.',
    nodes: [
      const CourseMapNode(
        lessonId: 'lesson-a',
        title: 'Lesson A',
        summary: 'First',
        kind: CourseNodeKind.lesson,
        state: CourseNodeState.available,
        sectionId: 'sec-1',
        sectionTitle: 'Section One',
        unitId: 'unit-1',
        unitTitle: 'Unit One',
        isNext: true,
      ),
      CourseMapNode(
        lessonId: 'lesson-b',
        title: 'Lesson B',
        summary: 'Second',
        kind: CourseNodeKind.jumpTest,
        state: second,
        sectionId: 'sec-1',
        sectionTitle: 'Section One',
        unitId: 'unit-1',
        unitTitle: 'Unit One',
        isNext: false,
        lockReason: second == CourseNodeState.locked
            ? 'Finish "Lesson A" first.'
            : null,
      ),
    ],
  );
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required CourseHomeSnapshot snapshot,
  required _RecordingAnalytics analytics,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        courseHomeProvider.overrideWith(() => _FixedHome(snapshot)),
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const HomeScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FixedHome extends CourseHomeController {
  _FixedHome(this.snapshot);

  final CourseHomeSnapshot snapshot;

  @override
  Future<CourseHomeSnapshot> build() async => snapshot;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ready Home shows status, Rex, path, and logs view', (
    tester,
  ) async {
    final analytics = _RecordingAnalytics();
    await _pumpHome(tester, snapshot: _readySnapshot(), analytics: analytics);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.byType(RexCoachCard), findsOneWidget);
    expect(find.byType(CoursePathView), findsOneWidget);
    expect(find.text('Lesson A'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
    expect(analytics.events, contains('home_course_view:ready'));
  });

  testWidgets('locked node tap explains prerequisite and logs', (tester) async {
    final analytics = _RecordingAnalytics();
    await _pumpHome(tester, snapshot: _readySnapshot(), analytics: analytics);

    await tester.ensureVisible(find.text('Lesson B'));
    await tester.tap(find.text('Lesson B'));
    await tester.pump();
    expect(find.textContaining('Finish "Lesson A" first.'), findsWidgets);
    expect(analytics.events, contains('home_node_locked_tap:lesson-b'));
  });

  testWidgets('disabled course shows recoverable unavailable state', (
    tester,
  ) async {
    final analytics = _RecordingAnalytics();
    await _pumpHome(
      tester,
      snapshot: const CourseHomeSnapshot(
        status: CourseHomeLoadStatus.disabled,
        nodes: [],
        sections: [],
        errorMessage: 'Course is temporarily unavailable.',
        rexLine: 'Course path is paused. Live Training and Profile still work.',
      ),
      analytics: analytics,
    );
    expect(find.text('Course unavailable'), findsOneWidget);
    expect(find.byType(RexCoachCard), findsOneWidget);
    expect(analytics.events, contains('home_course_view:disabled'));
  });

  testWidgets('small phone + large text keep next node reachable', (
    tester,
  ) async {
    final analytics = _RecordingAnalytics();
    await _pumpHome(
      tester,
      snapshot: _readySnapshot(),
      analytics: analytics,
      size: const Size(320, 568),
      textScale: 1.6,
    );
    expect(find.text('Lesson A'), findsOneWidget);
    await tester.ensureVisible(find.text('Lesson A'));
  });

  testWidgets('every node exposes a semantic label', (tester) async {
    final analytics = _RecordingAnalytics();
    await _pumpHome(tester, snapshot: _readySnapshot(), analytics: analytics);
    expect(
      find.bySemanticsLabel(RegExp(r'Lesson: Lesson A, available, next up')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Jump test: Lesson B, locked')),
      findsOneWidget,
    );
  });

  test('enabled flags helper still parses for snapshot mapper', () {
    // Keep CourseFlags import live for mapper-adjacent coverage.
    expect(
      const CourseFlags(
        courseEnabled: true,
        courseStartsEnabled: true,
        guestCourseEnabled: true,
        placementTestsEnabled: true,
        catalogVersion: '2.0.0',
        minimumClientVersion: '2.0.0',
      ).canStartCourse,
      isTrue,
    );
  });
}
