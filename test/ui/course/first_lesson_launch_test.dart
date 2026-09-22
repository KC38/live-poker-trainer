/// First-lesson launch route and runner chrome.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/screens/first_lesson_launch_screen.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  testWidgets('standalone launch route opens LessonRunner directly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: const FirstLessonLaunchScreen(),
      ),
    );
    expect(find.byType(LessonRunnerScreen), findsOneWidget);
    expect(find.text('Start lesson'), findsNothing);
    expect(kFirstCourseLessonId, 'lesson-01-01-01-your-two-cards');
  });

  testWidgets('open pushes LessonRunner without an intermediate CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () => FirstLessonLaunchScreen.open(context),
                child: const Text('Go'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(LessonRunnerScreen), findsOneWidget);
    expect(find.text('Start lesson'), findsNothing);
  });
}
