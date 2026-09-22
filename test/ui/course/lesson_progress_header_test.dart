/// Widget tests for denser lesson progress chrome.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_progress_header.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

Widget _wrap(Widget child) {
  final base = buildPokerTheme();
  return MaterialApp(
    theme: base.copyWith(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('progress header keeps lives and streak on one dense row', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const LessonProgressHeader(
          progress: 0.4,
          livesRemaining: 2,
          livesMax: 3,
          acceptedStreak: 3,
          hintEnabled: true,
          onHint: null,
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    // Old second-row chrome must stay gone.
    expect(find.textContaining('IN A ROW'), findsNothing);

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.minHeight, 8);
  });

  testWidgets('streak stays hidden until it is meaningful', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const LessonProgressHeader(
          progress: 0.1,
          livesRemaining: 3,
          livesMax: 3,
          acceptedStreak: 1,
        ),
      ),
    );

    expect(find.byIcon(Icons.local_fire_department), findsNothing);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('lives chip pulses once when livesRemaining decreases', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const LessonProgressHeader(
          progress: 0.5,
          livesRemaining: 3,
          livesMax: 3,
          acceptedStreak: 0,
        ),
      ),
    );
    expect(find.text('3'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const LessonProgressHeader(
          progress: 0.5,
          livesRemaining: 2,
          livesMax: 3,
          acceptedStreak: 0,
        ),
      ),
    );
    expect(find.text('2'), findsOneWidget);

    // Mid-pulse: scale/opacity animating away from identity.
    await tester.pump(const Duration(milliseconds: 100));
    final midOpacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(LessonProgressHeader),
        matching: find.byType(Opacity),
      ),
    );
    expect(midOpacity.opacity, lessThan(1));

    await tester.pumpAndSettle();
    final settledOpacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(LessonProgressHeader),
        matching: find.byType(Opacity),
      ),
    );
    expect(settledOpacity.opacity, 1);
  });

  testWidgets('streak chip pulses once when acceptedStreak increases', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const LessonProgressHeader(
          progress: 0.5,
          livesRemaining: 3,
          livesMax: 3,
          acceptedStreak: 2,
        ),
      ),
    );
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const LessonProgressHeader(
          progress: 0.5,
          livesRemaining: 3,
          livesMax: 3,
          acceptedStreak: 4,
        ),
      ),
    );
    expect(find.text('4'), findsOneWidget);

    // Mid-pulse: Transform.scale animating away from identity.
    await tester.pump(const Duration(milliseconds: 100));
    final scales = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(LessonProgressHeader),
            matching: find.byType(Transform),
          ),
        )
        .where((t) => t.transform.getMaxScaleOnAxis() != 1.0)
        .toList();
    expect(scales, isNotEmpty);

    await tester.pumpAndSettle();
    final settledScales = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(LessonProgressHeader),
            matching: find.byType(Transform),
          ),
        )
        .map((t) => t.transform.getMaxScaleOnAxis())
        .toList();
    expect(settledScales.every((s) => (s - 1.0).abs() < 0.001), isTrue);
  });
}
