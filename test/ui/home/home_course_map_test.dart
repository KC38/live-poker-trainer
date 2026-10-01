/// Home course map widget / accessibility / analytics coverage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_home_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/home/course_path_view.dart';
import 'package:live_poker_trainer/ui/home/course_status_bar.dart';
import 'package:live_poker_trainer/ui/home/rex_coach_card.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';
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
    gems: 0,
    hearts: 3,
    acceptedAccuracy: 0.75,
    nextLessonId: 'lesson-a',
    rexLine: 'Next lesson on the path. One short lesson, then move.',
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
        previewXp: 25,
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
        appAuthProvider.overrideWith(
          (ref) => const AsyncData(AppAuthSnapshot()),
        ),
      ],
      child: MaterialApp(
        theme: buildPokerTheme(),
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.linear(textScale)),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const HomeScreen(),
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

void _expectHomeThemeMetrics(WidgetTester tester) {
  // Streak 2, gems 0, hearts 3 — Duo strip uses JetBrains Mono for counts.
  for (final value in ['2', '0', '3']) {
    expect(
      tester.widget<Text>(find.text(value)).style?.fontFamily,
      contains('JetBrains'),
    );
  }
  expect(find.byType(RexCoachCard), findsNothing);
  expect(find.byType(RexMascot), findsNothing);
  expect(find.text('START +25 XP'), findsOneWidget);
  final marked = find.ancestor(
    of: find.text('START +25 XP'),
    matching: find.byType(Column),
  ).first;
  expect(
    find.descendant(of: marked, matching: find.text('Lesson A')),
    findsOneWidget,
  );
  expect(
    find.descendant(of: marked, matching: find.text('Lesson B')),
    findsNothing,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ready Home shows status, path, and logs view', (
    tester,
  ) async {
    final analytics = _RecordingAnalytics();
    await _pumpHome(tester, snapshot: _readySnapshot(), analytics: analytics);

    expect(find.byType(CourseStatusBar), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byType(RexCoachCard), findsNothing);
    expect(find.byType(RexMascot), findsNothing);
    expect(find.byType(CoursePathView), findsOneWidget);
    expect(find.text('Lesson A'), findsOneWidget);
    expect(find.text('START +25 XP'), findsOneWidget);
    expect(find.textContaining('SECTION'), findsWidgets);
    expect(find.text('SECTION 1, UNIT 1'), findsOneWidget);
    expect(
      find.textContaining('Guest progress stays on this device'),
      findsNothing,
    );
    expect(analytics.events, contains('home_course_view:ready'));
    _expectHomeThemeMetrics(tester);
  });

  testWidgets('anonymous Home omits guest progress banner', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseHomeProvider.overrideWith(
            () => _FixedHome(_readySnapshot()),
          ),
          analyticsServiceProvider.overrideWithValue(_RecordingAnalytics()),
          appAuthProvider.overrideWith(
            (ref) => const AsyncData(
              AppAuthSnapshot(uid: 'guest', isAnonymous: true),
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Guest progress stays on this device'),
      findsNothing,
    );
    expect(find.byType(CoursePathView), findsOneWidget);
  });

  testWidgets('start bubble marks only the next node', (tester) async {
    await _pumpHome(
      tester,
      snapshot: _readySnapshot(),
      analytics: _RecordingAnalytics(),
    );
    _expectHomeThemeMetrics(tester);
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

  testWidgets('paused starts do not open a completed lesson', (tester) async {
    final analytics = _RecordingAnalytics();
    final snapshot = _readySnapshot();
    await _pumpHome(
      tester,
      snapshot: CourseHomeSnapshot(
        status: snapshot.status,
        nodes: [
          const CourseMapNode(
            lessonId: 'lesson-a',
            title: 'Lesson A',
            summary: 'First',
            kind: CourseNodeKind.lesson,
            state: CourseNodeState.completed,
            sectionId: 'sec-1',
            sectionTitle: 'Section One',
            unitId: 'unit-1',
            unitTitle: 'Unit One',
            isNext: false,
          ),
          snapshot.nodes[1],
        ],
        sections: snapshot.sections,
        startsEnabled: false,
        rexLine:
            'New lessons are paused. Live Training and Profile still work.',
      ),
      analytics: analytics,
    );

    await tester.ensureVisible(find.text('Lesson A'));
    await tester.tap(find.text('Lesson A'));
    await tester.pump();
    expect(find.text('New course attempts are paused.'), findsOneWidget);
    expect(analytics.events, contains('home_node_locked_tap:lesson-a'));
    expect(find.byType(HomeScreen), findsOneWidget);
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
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(CourseStatusBar), findsOneWidget);
    expect(find.byType(RexCoachCard), findsNothing);
    expect(find.byType(CustomScrollView), findsOneWidget);
    // Path nodes live in a lower sliver; scroll until the next node paints.
    await tester.dragUntilVisible(
      find.text('Lesson A'),
      find.byType(CustomScrollView),
      const Offset(0, -120),
    );
    expect(find.text('Lesson A'), findsOneWidget);
    expect(find.text('START +25 XP'), findsOneWidget);
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

  testWidgets('open attempt has no Resume card; next node stays marked', (
    tester,
  ) async {
    final analytics = _RecordingAnalytics();
    final snapshot = _readySnapshot();
    await _pumpHome(
      tester,
      snapshot: CourseHomeSnapshot(
        status: snapshot.status,
        nodes: [
          const CourseMapNode(
            lessonId: 'lesson-a',
            title: 'Lesson A',
            summary: 'First',
            kind: CourseNodeKind.lesson,
            state: CourseNodeState.active,
            sectionId: 'sec-1',
            sectionTitle: 'Section One',
            unitId: 'unit-1',
            unitTitle: 'Unit One',
            isNext: true,
          ),
          snapshot.nodes[1],
        ],
        sections: snapshot.sections,
        streak: snapshot.streak,
        lifetimeXp: snapshot.lifetimeXp,
        acceptedAccuracy: snapshot.acceptedAccuracy,
        nextLessonId: snapshot.nextLessonId,
        rexLine: 'Pick up where you left off. The table is still waiting.',
        resume: const CourseResumePointer(
          attemptId: 'attempt-1',
          lessonId: 'lesson-a',
          activityId: 'act-1',
          activityIndex: 0,
        ),
      ),
      analytics: analytics,
    );

    expect(find.text('Resume'), findsNothing);
    expect(find.text('START +25 XP'), findsOneWidget);
    expect(find.byType(RexMascot), findsNothing);
    expect(find.text('Lesson A'), findsOneWidget);
  });

  testWidgets('Home re-focus scrolls the next lesson back into view', (
    tester,
  ) async {
    final focusRequests = ValueNotifier<int>(0);
    addTearDown(focusRequests.dispose);

    final nodes = <CourseMapNode>[
      for (var i = 0; i < 12; i++)
        CourseMapNode(
          lessonId: 'lesson-$i',
          title: 'Lesson $i',
          summary: 'Node $i',
          kind: CourseNodeKind.lesson,
          state: i < 11 ? CourseNodeState.completed : CourseNodeState.available,
          sectionId: 'sec-1',
          sectionTitle: 'Section One',
          unitId: 'unit-1',
          unitTitle: 'Unit One',
          isNext: i == 11,
        ),
    ];

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseHomeProvider.overrideWith(
            () => _FixedHome(
              CourseHomeSnapshot(
                status: CourseHomeLoadStatus.ready,
                nodes: nodes,
                sections: const [],
                nextLessonId: 'lesson-11',
                streak: 1,
                lifetimeXp: 10,
              ),
            ),
          ),
          analyticsServiceProvider.overrideWithValue(_RecordingAnalytics()),
          appAuthProvider.overrideWith(
            (ref) => const AsyncData(AppAuthSnapshot()),
          ),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: HomeScreen(focusRequests: focusRequests),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lesson 11').hitTestable(), findsOneWidget);
    expect(find.text('START +25 XP').hitTestable(), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Lesson 0'),
      find.byType(CustomScrollView),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lesson 11').hitTestable(), findsNothing);

    focusRequests.value++;
    await tester.pumpAndSettle();
    expect(find.text('Lesson 11').hitTestable(), findsOneWidget);
    expect(find.text('START +25 XP').hitTestable(), findsOneWidget);
  });

  testWidgets('unit banner opens organized section picker', (tester) async {
    final analytics = _RecordingAnalytics();
    final sections = [
      const CourseSection(
        id: 'sec-1',
        order: 1,
        title: 'Section One',
        summary: 'Learn the basics of the live cash table.',
        experienceBand: 'never_played',
        units: [],
      ),
      const CourseSection(
        id: 'sec-2',
        order: 2,
        title: 'Section Two',
        summary: 'Build a disciplined baseline.',
        experienceBand: 'rules_known',
        units: [],
      ),
    ];
    final base = _readySnapshot();
    await _pumpHome(
      tester,
      snapshot: CourseHomeSnapshot(
        status: base.status,
        nodes: base.nodes,
        sections: sections,
        streak: base.streak,
        lifetimeXp: base.lifetimeXp,
        acceptedAccuracy: base.acceptedAccuracy,
        nextLessonId: base.nextLessonId,
        rexLine: base.rexLine,
      ),
      analytics: analytics,
    );

    expect(find.byType(CourseUnitBanner), findsOneWidget);
    expect(find.textContaining('SECTION 1'), findsOneWidget);
    await tester.tap(find.textContaining('SECTION 1'));
    await tester.pumpAndSettle();
    expect(find.text('Sections'), findsOneWidget);
    expect(find.text('CURRENT SECTION'), findsOneWidget);
    expect(find.text('LOCKED'), findsOneWidget);
    expect(find.textContaining('NEVER PLAYED'), findsOneWidget);
    expect(find.textContaining('RULES KNOWN'), findsOneWidget);
  });

  testWidgets('sticky unit banner replaces instead of stacking', (tester) async {
    final analytics = _RecordingAnalytics();
    final sections = [
      const CourseSection(
        id: 'sec-1',
        order: 1,
        title: 'Section One',
        summary: 'Learn the basics.',
        experienceBand: 'never_played',
        units: [],
      ),
    ];
    final nodes = <CourseMapNode>[
      for (var i = 0; i < 4; i++)
        CourseMapNode(
          lessonId: 'lesson-a-$i',
          title: 'Lesson A$i',
          summary: 'Unit one lesson',
          kind: CourseNodeKind.lesson,
          state: i == 0 ? CourseNodeState.available : CourseNodeState.locked,
          sectionId: 'sec-1',
          sectionTitle: 'Section One',
          unitId: 'unit-1',
          unitTitle: 'Unit One',
          isNext: i == 0,
          lockReason: i == 0 ? null : 'Finish prior lesson first.',
        ),
      for (var i = 0; i < 6; i++)
        CourseMapNode(
          lessonId: 'lesson-b-$i',
          title: 'Lesson B$i',
          summary: 'Unit two lesson',
          kind: CourseNodeKind.lesson,
          state: CourseNodeState.locked,
          sectionId: 'sec-1',
          sectionTitle: 'Section One',
          unitId: 'unit-2',
          unitTitle: 'Unit Two',
          isNext: false,
          lockReason: 'Finish prior lesson first.',
        ),
    ];

    await _pumpHome(
      tester,
      snapshot: CourseHomeSnapshot(
        status: CourseHomeLoadStatus.ready,
        nodes: nodes,
        sections: sections,
        streak: 1,
        lifetimeXp: 10,
        acceptedAccuracy: 0.5,
        nextLessonId: 'lesson-a-0',
        rexLine: 'Keep going.',
      ),
      analytics: analytics,
    );

    expect(find.byType(CourseUnitBanner), findsOneWidget);
    expect(find.textContaining('SECTION 1'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CourseUnitBanner),
        matching: find.text('Unit One'),
      ),
      findsOneWidget,
    );
    // Second unit appears only as a path divider, not a second colored banner.
    expect(find.text('Unit Two'), findsOneWidget);
    expect(find.byType(CourseUnitBanner), findsOneWidget);

    final position = tester.state<ScrollableState>(find.byType(Scrollable)).position;
    expect(position.maxScrollExtent, greaterThan(100));
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();

    expect(find.byType(CourseUnitBanner), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CourseUnitBanner),
        matching: find.text('Unit Two'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(CourseUnitBanner),
        matching: find.text('Unit One'),
      ),
      findsNothing,
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
