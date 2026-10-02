/// Section picker progress counts review-due lessons; completed cards are minimal.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/ui/home/course_section_picker.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

CourseLesson _lesson(String id, {List<String> prerequisites = const []}) {
  return CourseLesson(
    id: id,
    order: 1,
    title: id,
    summary: 'summary',
    objectives: const [],
    prerequisites: prerequisites,
    remediationLessonIds: const [],
    estimatedMinutes: 3,
    difficultyBand: 1,
    playerTypeRefs: const [],
    introducesPlayerTypes: const [],
    activities: const [],
  );
}

CourseSection _section({
  required String id,
  required int order,
  required String title,
  required String band,
  required List<CourseLesson> lessons,
}) {
  return CourseSection(
    id: id,
    order: order,
    title: title,
    summary: 'Section summary for $title',
    experienceBand: band,
    units: [
      CourseUnit(
        id: '$id-unit-1',
        order: 1,
        title: 'Unit 1',
        summary: 'Unit summary',
        lessons: lessons,
      ),
    ],
  );
}

CourseMapNode _node({
  required String lessonId,
  required String sectionId,
  required CourseNodeState state,
  bool isNext = false,
}) {
  return CourseMapNode(
    lessonId: lessonId,
    title: lessonId,
    summary: 'node',
    kind: CourseNodeKind.lesson,
    state: state,
    sectionId: sectionId,
    sectionTitle: sectionId,
    unitId: 'unit-1',
    unitTitle: 'Unit 1',
    isNext: isNext,
    previewXp: 25,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildSectionProgress', () {
    final section1 = _section(
      id: 'sec-1',
      order: 1,
      title: 'Never Played',
      band: 'never_played',
      lessons: [
        _lesson('lesson-1'),
        _lesson('lesson-2', prerequisites: const ['lesson-1']),
        _lesson('lesson-3', prerequisites: const ['lesson-2']),
      ],
    );
    final section2 = _section(
      id: 'sec-2',
      order: 2,
      title: 'Rules Known / Home Games',
      band: 'rules_known',
      lessons: [_lesson('lesson-4', prerequisites: const ['lesson-3'])],
    );

    test('counts reviewDue lessons toward completion percent', () {
      final snapshot = CourseHomeSnapshot(
        status: CourseHomeLoadStatus.ready,
        sections: [section1, section2],
        nodes: [
          _node(
            lessonId: 'lesson-1',
            sectionId: 'sec-1',
            state: CourseNodeState.reviewDue,
          ),
          _node(
            lessonId: 'lesson-2',
            sectionId: 'sec-1',
            state: CourseNodeState.reviewDue,
          ),
          _node(
            lessonId: 'lesson-3',
            sectionId: 'sec-1',
            state: CourseNodeState.completed,
          ),
          _node(
            lessonId: 'lesson-4',
            sectionId: 'sec-2',
            state: CourseNodeState.available,
            isNext: true,
          ),
        ],
        nextLessonId: 'lesson-4',
        rexLine: 'Next up.',
      );

      final rows = buildSectionProgress(snapshot);
      expect(rows, hasLength(2));
      expect(rows[0].completed, 3);
      expect(rows[0].total, 3);
      expect(rows[0].percent, 100);
      expect(rows[0].isComplete, isTrue);
      expect(rows[0].isCurrent, isFalse);
      expect(rows[1].isCurrent, isTrue);
      expect(rows[1].isUnlocked, isTrue);
      expect(rows[1].isComplete, isFalse);
    });

    test('partial progress ignores locked and available lessons', () {
      final snapshot = CourseHomeSnapshot(
        status: CourseHomeLoadStatus.ready,
        sections: [section1],
        nodes: [
          _node(
            lessonId: 'lesson-1',
            sectionId: 'sec-1',
            state: CourseNodeState.mastered,
          ),
          _node(
            lessonId: 'lesson-2',
            sectionId: 'sec-1',
            state: CourseNodeState.available,
            isNext: true,
          ),
          _node(
            lessonId: 'lesson-3',
            sectionId: 'sec-1',
            state: CourseNodeState.locked,
          ),
        ],
        nextLessonId: 'lesson-2',
        rexLine: 'Keep going.',
      );

      final row = buildSectionProgress(snapshot).single;
      expect(row.completed, 1);
      expect(row.total, 3);
      expect(row.percent, 33);
      expect(row.isComplete, isFalse);
      expect(row.isCurrent, isTrue);
    });
  });

  testWidgets('completed section shows only title and full bar', (tester) async {
    final section1 = _section(
      id: 'sec-1',
      order: 1,
      title: 'Never Played',
      band: 'never_played',
      lessons: [_lesson('lesson-1'), _lesson('lesson-2')],
    );
    final section2 = _section(
      id: 'sec-2',
      order: 2,
      title: 'Rules Known / Home Games',
      band: 'rules_known',
      lessons: [_lesson('lesson-3')],
    );
    final snapshot = CourseHomeSnapshot(
      status: CourseHomeLoadStatus.ready,
      sections: [section1, section2],
      nodes: [
        _node(
          lessonId: 'lesson-1',
          sectionId: 'sec-1',
          state: CourseNodeState.reviewDue,
        ),
        _node(
          lessonId: 'lesson-2',
          sectionId: 'sec-1',
          state: CourseNodeState.mastered,
        ),
        _node(
          lessonId: 'lesson-3',
          sectionId: 'sec-2',
          state: CourseNodeState.available,
          isNext: true,
        ),
      ],
      nextLessonId: 'lesson-3',
      rexLine: 'Next section.',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: CourseSectionPickerSheet(
            rows: buildSectionProgress(snapshot),
            onJump: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Section 1'), findsOneWidget);
    expect(find.text('Section summary for Never Played'), findsNothing);
    expect(find.textContaining('NEVER PLAYED'), findsNothing);
    expect(find.text('9%'), findsNothing);
    expect(find.text('100%'), findsNothing);
    expect(find.text('33%'), findsNothing);

    expect(find.text('Section 2'), findsOneWidget);
    expect(find.text('Section summary for Rules Known / Home Games'), findsOneWidget);
    expect(find.text('CURRENT SECTION'), findsOneWidget);
    expect(find.textContaining('RULES KNOWN'), findsOneWidget);
  });
}
