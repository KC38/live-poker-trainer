/// Count outs, pay the right price explain teaches on the full poker table.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
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
            'lesson-03-03-01-outs-and-price',
          ),
          child: LessonFrameScope(onLocalMiss: (_) {}, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('explain taps Clean Dirty Price under the full table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-03-03-01-explain',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Clean outs help. Dirty outs improve you into second-best. Price the call.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Clean outs help. Dirty outs improve you into second-best. Price the call.',
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

    expect(find.byType(LessonOutsPriceExplainTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byType(OutsPriceDemo), findsNothing);

    for (final title in const ['CLEAN', 'DIRTY', 'PRICE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(ack, 1);
  });

  testWidgets('unguided framed stage shows Pot 20 with villain bet 10', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-03-03-01-unguided',
      order: 4,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText:
          'Nine-outish equity is close; with implied odds deep, call is fine.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Pot 20, bet 10 (call 10 into 30). You have ~8 clean outs on the turn. Call?',
      choices: const [
        CourseChoice(
          id: 'call-draw',
          label: 'Call — price is acceptable with outs',
        ),
        CourseChoice(
          id: 'fold-draw',
          label: 'Fold always without a made hand',
        ),
        CourseChoice(id: 'raise-auto', label: 'Raise every draw'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _frame(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LessonTableStage), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.textContaining('POT \$20'), findsOneWidget);
    expect(find.textContaining('POT \$10'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('checkpoint framed stage shows 200bb stacks and pot bet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-03-03-01-checkpoint',
      order: 5,
      stage: ActivityStage.scaffolded,
      assessmentRole: AssessmentRole.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Deep stacks add implied odds versus sticky players.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          '200bb deep. Nut flush draw, pot-sized bet from a sticky caller. Edge?',
      choices: const [
        CourseChoice(
          id: 'implied-yes',
          label: 'Implied odds improve — they pay when you hit',
        ),
        CourseChoice(
          id: 'implied-no',
          label: 'Depth never changes draw price',
        ),
        CourseChoice(
          id: 'fold-nfd',
          label: 'Fold nut flush draws to any bet',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _frame(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LessonTableStage), findsOneWidget);
    expect(find.textContaining('POT \$20'), findsOneWidget);
    expect(find.textContaining('POT \$10'), findsNothing);
    // $400 at $1/$2 = 200bb (not the band default $200).
    expect(find.textContaining('\$400'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
