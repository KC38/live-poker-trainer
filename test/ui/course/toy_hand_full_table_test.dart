/// Play a full toy hand teach beats on the full poker table.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/authored_multi_step_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_toy_hand.dart';
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
            'lesson-01-06-01-guided-complete-hand',
          ),
          child: LessonFrameScope(onLocalMiss: (_) {}, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('explain taps Blinds You act Ending under the full table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-06-01-explain-run',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'One short hand.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Blinds, you act, ending.',
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

    expect(find.byType(LessonToyHandExplainTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byType(ToyHandRunDemo), findsNothing);

    for (final title in const ['BLINDS', 'YOU ACT', 'ENDING']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(ack, 1);
  });

  testWidgets('scaffolded BB-call street paints authored Pot 13 on full table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-06-01-scaffolded-multi',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'BB calls your open — confirm the flop.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-01-06-bb-defend',
          street: 'preflop',
          prompt: 'You open BTN to 6. BB calls. Next?',
          choices: [
            CourseChoice(id: 'ready-flop', label: 'See flop'),
            CourseChoice(id: 'already-won', label: 'Already over'),
          ],
        ),
        CourseHandStep(
          id: 'step-01-06-flop-cbet',
          street: 'flop',
          prompt: 'Flop Ace-high rainbow. BB checks.',
          choices: [
            CourseChoice(
              id: 'cbet',
              label: 'Bet 6',
              action: 'BET',
              amountBb: 3,
            ),
            CourseChoice(id: 'check-back', label: 'Check', action: 'CHECK'),
          ],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _frame(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.textContaining('POT \$13'), findsOneWidget);
    expect(find.textContaining('POT \$3'), findsNothing);
    expect(tester.takeException(), isNull);

    controller.setHandStepIndex(1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('POT \$13'), findsOneWidget);
    expect(find.textContaining('POT \$10'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
