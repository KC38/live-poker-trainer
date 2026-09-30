/// Streets and action order teaches on the full poker table.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/order_sequence_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_streets.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

Widget _frame(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: buildPokerTheme().copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(
        body: TableFeaturesScope(
          features: TableFeatures.forLessonId(
            'lesson-01-04-01-streets-and-order',
          ),
          child: LessonFrameScope(onLocalMiss: (_) {}, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('explain taps streets under the full table', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-04-01-explain-streets',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Four streets.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Preflop, flop, turn, river.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    var ack = 0;
    await tester.pumpWidget(
      _frame(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => ack += 1,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LessonStreetsExplainTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byType(StreetsTimelineDemo), findsNothing);

    for (final title in const ['PREFLOP', 'FLOP', 'TURN', 'RIVER']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(ack, 1);
  });

  testWidgets('guided street order uses the full table', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-04-01-guided-streets',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 40,
      accessibilityText: 'Order streets.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the streets from first to last.',
      sequenceItems: const [
        CourseChoice(id: 'st-pre', label: 'Preflop'),
        CourseChoice(id: 'st-flop', label: 'Flop'),
        CourseChoice(id: 'st-turn', label: 'Turn'),
        CourseChoice(id: 'st-river', label: 'River'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    await tester.pumpWidget(
      _frame(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LessonStreetsOrderTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);

    for (final label in const ['Preflop', 'Flop', 'Turn', 'River']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(controller.draft.orderedIds, [
      'st-pre',
      'st-flop',
      'st-turn',
      'st-river',
    ]);
    expect(autoSubmits, 1);
  });
}
