/// Distinct face-down seat labels on the first-lesson checkpoint felt.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_feedback_sheet.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('several opponents get distinct labels', () {
    expect(faceDownSeatLabel(index: 0, count: 1), 'Them');
    expect(faceDownSeatLabel(index: 0, count: 3), 'Opponent 1');
    expect(faceDownSeatLabel(index: 1, count: 3), 'Opponent 2');
    expect(faceDownSeatLabel(index: 2, count: 3), 'Opponent 3');
    expect(
      seatLabelForTableTap(
        const LessonTableScene(villainSeatCount: 3),
        const LessonTableTapTarget(LessonTableRegion.villain, seatIndex: 1),
      ),
      'Opponent 2',
    );
    expect(
      seatLabelForTableTap(
        const LessonTableScene(villainSeatCount: 3),
        const LessonTableTapTarget(LessonTableRegion.hero),
      ),
      isNull,
    );
  });

  testWidgets('checkpoint felt does not repeat Them on every seat', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: const Scaffold(
          body: LessonTableContext(
            scene: LessonTableScene(
              heroCodes: ['Ah', 'Kd'],
              boardCodes: ['Qs', 'Jh', '2c'],
              villainSeatCount: 3,
              caption: 'You',
            ),
            enabled: true,
          ),
        ),
      ),
    );

    expect(find.text('You'), findsWidgets);
    expect(find.text('Opponent 1'), findsOneWidget);
    expect(find.text('Opponent 2'), findsOneWidget);
    expect(find.text('Opponent 3'), findsOneWidget);
    expect(find.text('Them'), findsNothing);
  });

  testWidgets('miss feedback names the tapped seat', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonFeedbackSheet(
            result: const SubmitCourseStepResult(
              attemptId: 'a',
              activityId: 'act-01-01-01-checkpoint-table',
              accepted: false,
              grade: SoftGrade.questionable,
              feedback:
                  'You can see the board, but those cards are not yours alone.',
              livesRemaining: 3,
              lifeLost: false,
              xpAwarded: 0,
              remediationRequired: false,
              duplicate: false,
              resume: CourseResumePointer(
                attemptId: 'a',
                lessonId: 'lesson',
                activityId: 'act',
                activityIndex: 0,
              ),
            ),
            seatLabel: 'Opponent 2',
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Opponent 2'), findsOneWidget);
    expect(find.text('You'), findsNothing);
  });
}
