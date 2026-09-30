/// CourseStatusBar layout matches Duolingo: sections, streak, gems, hearts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/home/course_status_bar.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('status bar shows course mark, streak, gems, and hearts', (
    tester,
  ) async {
    var openedSections = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: CourseStatusBar(
            streak: 7,
            gems: 42,
            hearts: 3,
            onCourseTap: () => openedSections = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.style_rounded), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    expect(find.byIcon(Icons.diamond_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    // XP is no longer in the Home strip.
    expect(find.byIcon(Icons.bolt_rounded), findsNothing);

    final streakText = tester.widget<Text>(find.text('7'));
    expect(streakText.style?.color, AppColors.warning);
    expect(streakText.style?.fontFamily, contains('JetBrains'));

    final gemsText = tester.widget<Text>(find.text('42'));
    expect(gemsText.style?.color, const Color(0xFF5EC8FF));

    final heartsText = tester.widget<Text>(find.text('3'));
    expect(heartsText.style?.color, AppColors.hearts);

    await tester.tap(find.byIcon(Icons.style_rounded));
    await tester.pump();
    expect(openedSections, isTrue);
  });

  testWidgets('defaults hearts to the lesson lives max', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: const Scaffold(
          body: CourseStatusBar(streak: 1, gems: 0),
        ),
      ),
    );

    expect(find.text('$kHomeDefaultHearts'), findsOneWidget);
  });

  testWidgets('stats sit in an evenly spaced row beside the course mark', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: const Scaffold(
          body: SizedBox(
            width: 390,
            child: CourseStatusBar(streak: 1, gems: 5, hearts: 3),
          ),
        ),
      ),
    );

    final course = tester.getCenter(find.byIcon(Icons.style_rounded));
    final streak = tester.getCenter(
      find.byIcon(Icons.local_fire_department_rounded),
    );
    final gems = tester.getCenter(find.byIcon(Icons.diamond_rounded));
    final hearts = tester.getCenter(find.byIcon(Icons.favorite_rounded));

    expect(course.dx, lessThan(streak.dx));
    expect(streak.dx, lessThan(gems.dx));
    expect(gems.dx, lessThan(hearts.dx));

    final gapStreakGems = gems.dx - streak.dx;
    final gapGemsHearts = hearts.dx - gems.dx;
    expect((gapStreakGems - gapGemsHearts).abs(), lessThan(12));
  });
}
