/// LPT-883: Authored SoftPulse explain tiles use teaching captions, not Tap N of M.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

CourseActivity _authoredExplain({
  required String id,
  required List<String> targets,
}) {
  return CourseActivity(
    id: id,
    order: 1,
    stage: ActivityStage.guided,
    renderer: ActivityRenderer.coachDialogue,
    estimatedSeconds: 30,
    accessibilityText: 'Test SoftPulse explain',
    acceptedGrades: const [SoftGrade.recommended],
    prompt: 'Tap the cues in order.',
    teachSpec: {
      'cues': [
        for (var i = 0; i < targets.length; i++)
          {
            'press': i + 1,
            'target': targets[i],
            'kind': 'soft_pulse',
          },
      ],
    },
  );
}

void main() {
  test('authoredSoftPulseExplainCaption teaches, never Tap N of M', () {
    expect(authoredSoftPulseExplainCaption('DRAW'), 'Need a card');
    expect(authoredSoftPulseExplainCaption('SHOWDOWN VALUE'), 'Weak made');
    expect(authoredSoftPulseExplainCaption('BETS MATCHED'), 'All caught up');
    expect(authoredSoftPulseExplainCaption('NEXT STREET'), 'Deal continues');
    expect(authoredSoftPulseExplainCaption('UNKNOWN-TARGET-XYZ'), isEmpty);
    expect(
      authoredSoftPulseExplainCaption('DRAW'),
      isNot(matches(RegExp(r'^Tap \d+ of \d+$'))),
    );
  });

  testWidgets(
    'LessonAuthoredCueExplainTable shows teaching captions at 375×812',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-03-02-01-02-explain-draws',
        targets: const ['DRAW', 'SHOWDOWN VALUE'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
                enabled: true,
                showGuidance: true,
              ),
            ),
          ),
        ),
      );
      // SoftPulse breathes forever — do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('DRAW'), findsWidgets);
      expect(find.text('SHOWDOWN VALUE'), findsWidgets);
      expect(find.text('Need a card'), findsOneWidget);
      expect(find.text('Weak made'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );

  testWidgets(
    'street-ends AuthoredCueExplain captions stay non-meta at phone width',
    (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => binding.setSurfaceSize(null));

      final activity = _authoredExplain(
        id: 'act-01-04-01-03-explain-end',
        targets: const ['BETS MATCHED', 'NEXT STREET'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 375,
              height: 500,
              child: LessonAuthoredCueExplainTable(
                activity: activity,
                onAllPointsTapped: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('All caught up'), findsOneWidget);
      expect(find.text('Deal continues'), findsOneWidget);
      expect(find.textContaining(RegExp(r'Tap \d+ of \d+')), findsNothing);
    },
  );
}
