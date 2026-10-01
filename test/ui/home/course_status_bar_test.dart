/// CourseStatusBar shows streak, gems, and hearts spaced across the row.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/home/course_status_bar.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('status bar shows streak, gems, and hearts without course mark', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: CourseStatusBar(
            streak: 7,
            gems: 42,
            hearts: 3,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.style_rounded), findsNothing);
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

  testWidgets('stats span the full width evenly', (tester) async {
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

    final bar = tester.getRect(find.byType(CourseStatusBar));
    final streak = tester.getCenter(
      find.byIcon(Icons.local_fire_department_rounded),
    );
    final gems = tester.getCenter(find.byIcon(Icons.diamond_rounded));
    final hearts = tester.getCenter(find.byIcon(Icons.favorite_rounded));

    expect(streak.dx, lessThan(gems.dx));
    expect(gems.dx, lessThan(hearts.dx));

    final gapStreakGems = gems.dx - streak.dx;
    final gapGemsHearts = hearts.dx - gems.dx;
    expect((gapStreakGems - gapGemsHearts).abs(), lessThan(20));

    // Left and right stats sit near the bar edges (not clustered center).
    final leftBound =
        tester.getTopLeft(find.byIcon(Icons.local_fire_department_rounded)).dx;
    final rightBound = tester.getTopRight(find.text('3')).dx;
    expect(leftBound - bar.left, lessThan(16));
    expect(bar.right - rightBound, lessThan(16));

    // Middle gem roughly at bar center.
    expect((gems.dx - bar.center.dx).abs(), lessThan(24));
  });
}
