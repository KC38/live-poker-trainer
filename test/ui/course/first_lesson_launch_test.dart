/// First-lesson launch route and runner chrome.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/screens/first_lesson_launch_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  testWidgets('standalone launch route presents Your two cards CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: const FirstLessonLaunchScreen(),
      ),
    );
    expect(find.text('Your two cards'), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget);
    expect(kFirstCourseLessonId, 'lesson-01-01-01-your-two-cards');
  });

  testWidgets('large text keeps the primary CTA visible', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const FirstLessonLaunchScreen(),
        ),
      ),
    );
    expect(find.text('Start lesson'), findsOneWidget);
    await tester.ensureVisible(find.text('Start lesson'));
  });
}
