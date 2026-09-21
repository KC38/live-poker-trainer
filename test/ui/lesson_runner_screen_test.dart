/// Lesson runner scoring flows into the result summary UI.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/curriculum/lesson_exercises.dart';
import 'package:live_poker_trainer/ui/screens/learning/lesson_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const payload = LessonExercisesPayload(
    lessonId: 'lesson-test',
    title: 'Test lesson',
    questions: [
      ExerciseQuestion(
        id: 'q1',
        prompt: 'First question?',
        choices: [
          ExerciseChoice(id: 'a', text: 'Wrong'),
          ExerciseChoice(id: 'b', text: 'Right'),
        ],
        correctChoiceId: 'b',
      ),
      ExerciseQuestion(
        id: 'q2',
        prompt: 'Second question?',
        choices: [
          ExerciseChoice(id: 'a', text: 'Also right'),
          ExerciseChoice(id: 'b', text: 'Wrong again'),
        ],
        correctChoiceId: 'a',
      ),
    ],
  );

  Future<void> pumpRunner(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LessonRunnerScreen(
            lessonId: 'lesson-test',
            exercises: payload,
          ),
        ),
      ),
    );
    // Theme optional; avoid google fonts network in tests where possible.
    await tester.pumpAndSettle();
  }

  testWidgets('scores correct answers and shows result summary', (tester) async {
    await pumpRunner(tester);

    expect(find.text('First question?'), findsOneWidget);
    await tester.tap(find.text('Right'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Second question?'), findsOneWidget);
    await tester.tap(find.text('Also right'));
    await tester.pump();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson complete'), findsOneWidget);
    expect(find.byKey(const Key('lesson_score_label')), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('100% correct'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('counts incorrect answers in the score', (tester) async {
    await pumpRunner(tester);

    await tester.tap(find.text('Wrong'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Also right'));
    await tester.pump();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('50% correct'), findsOneWidget);
  });
}
