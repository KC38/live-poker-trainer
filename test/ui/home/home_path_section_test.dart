/// Home path shows one section; tapping another switches; finish auto-advances.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_home_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/home/course_section_picker.dart';
import 'package:live_poker_trainer/ui/home/rex_coach_card.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

class _SilentAnalytics extends AnalyticsService {
  _SilentAnalytics() : super(enabled: false);
}

const _sections = <CourseSection>[
  CourseSection(
    id: 'sec-1',
    order: 1,
    title: 'Section One',
    summary: 'Learn the basics of the live cash table.',
    experienceBand: 'never_played',
    units: [],
  ),
  CourseSection(
    id: 'sec-2',
    order: 2,
    title: 'Section Two',
    summary: 'Build a disciplined baseline.',
    experienceBand: 'rules_known',
    units: [],
  ),
];

CourseHomeSnapshot _twoSectionSnapshot({
  required String nextLessonId,
}) {
  return CourseHomeSnapshot(
    status: CourseHomeLoadStatus.ready,
    sections: _sections,
    streak: 1,
    lifetimeXp: 10,
    gems: 0,
    hearts: 3,
    nextLessonId: nextLessonId,
    nodes: [
      CourseMapNode(
        lessonId: 'lesson-a',
        title: 'Lesson A',
        summary: 'First',
        kind: CourseNodeKind.lesson,
        state: nextLessonId == 'lesson-a'
            ? CourseNodeState.available
            : CourseNodeState.completed,
        sectionId: 'sec-1',
        sectionTitle: 'Section One',
        unitId: 'unit-1',
        unitTitle: 'Unit One',
        isNext: nextLessonId == 'lesson-a',
        previewXp: 25,
      ),
      CourseMapNode(
        lessonId: 'lesson-b',
        title: 'Lesson B',
        summary: 'Second section start',
        kind: CourseNodeKind.lesson,
        state: nextLessonId == 'lesson-b'
            ? CourseNodeState.available
            : CourseNodeState.completed,
        sectionId: 'sec-2',
        sectionTitle: 'Section Two',
        unitId: 'unit-2',
        unitTitle: 'Unit Two',
        isNext: nextLessonId == 'lesson-b',
        previewXp: 25,
      ),
    ],
  );
}

class _MutableHome extends CourseHomeController {
  _MutableHome(this._snapshot);

  CourseHomeSnapshot _snapshot;

  @override
  Future<CourseHomeSnapshot> build() async => _snapshot;

  void replace(CourseHomeSnapshot snapshot) {
    _snapshot = snapshot;
    state = AsyncData(snapshot);
  }
}

Future<_MutableHome> _pumpMutableHome(
  WidgetTester tester, {
  required CourseHomeSnapshot snapshot,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late _MutableHome home;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        courseHomeProvider.overrideWith(() {
          home = _MutableHome(snapshot);
          return home;
        }),
        analyticsServiceProvider.overrideWithValue(_SilentAnalytics()),
        appAuthProvider.overrideWith(
          (ref) => const AsyncData(AppAuthSnapshot()),
        ),
      ],
      child: MaterialApp(
        theme: buildPokerTheme(),
        home: const HomeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return home;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolveHomePathSectionId / homePathNodesForSection', () {
    test('defaults to the next lesson section', () {
      final snap = _twoSectionSnapshot(nextLessonId: 'lesson-a');
      expect(resolveHomePathSectionId(snap), 'sec-1');
      expect(
        homePathNodesForSection(snap.nodes, 'sec-1').map((n) => n.lessonId),
        ['lesson-a'],
      );
    });

    test('honors an explicit JUMP HERE focus', () {
      final snap = _twoSectionSnapshot(nextLessonId: 'lesson-a');
      expect(
        resolveHomePathSectionId(snap, focusedSectionId: 'sec-2'),
        'sec-2',
      );
      expect(
        homePathNodesForSection(snap.nodes, 'sec-2').map((n) => n.lessonId),
        ['lesson-b'],
      );
    });

    test('falls back when focused section has no nodes', () {
      final snap = _twoSectionSnapshot(nextLessonId: 'lesson-b');
      expect(
        resolveHomePathSectionId(snap, focusedSectionId: 'missing'),
        'sec-2',
      );
    });
  });

  testWidgets('path shows only the current section lessons', (tester) async {
    await _pumpMutableHome(
      tester,
      snapshot: _twoSectionSnapshot(nextLessonId: 'lesson-a'),
    );

    expect(find.text('Lesson A'), findsOneWidget);
    expect(find.text('Lesson B'), findsNothing);
    expect(find.textContaining('SECTION 1'), findsOneWidget);
  });

  testWidgets('tapping an unlocked section switches the path', (tester) async {
    await _pumpMutableHome(
      tester,
      snapshot: _twoSectionSnapshot(nextLessonId: 'lesson-a'),
    );

    await tester.tap(find.textContaining('SECTION 1'));
    await tester.pumpAndSettle();
    expect(find.text('Sections'), findsOneWidget);
    expect(find.text('JUMP HERE'), findsNothing);
    expect(find.text('Section 2'), findsOneWidget);

    await tester.tap(find.text('Section 2'));
    await tester.pumpAndSettle();

    expect(find.text('Sections'), findsNothing);
    expect(find.text('Lesson B'), findsOneWidget);
    expect(find.text('Lesson A'), findsNothing);
    expect(find.textContaining('SECTION 2'), findsOneWidget);
    // Browsing another section must not revive the Rex+Start card that
    // would open the global next lesson (still in section 1).
    expect(find.byType(RexCoachCard), findsNothing);
    expect(find.text('Start'), findsNothing);
  });

  testWidgets('finishing a section auto-advances the path', (tester) async {
    final home = await _pumpMutableHome(
      tester,
      snapshot: _twoSectionSnapshot(nextLessonId: 'lesson-a'),
    );

    expect(find.text('Lesson A'), findsOneWidget);
    expect(find.text('Lesson B'), findsNothing);

    home.replace(_twoSectionSnapshot(nextLessonId: 'lesson-b'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson B'), findsOneWidget);
    expect(find.text('Lesson A'), findsNothing);
    expect(find.textContaining('SECTION 2'), findsOneWidget);
  });
}
