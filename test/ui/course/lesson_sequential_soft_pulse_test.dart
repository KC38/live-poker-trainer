/// SoftPulse only the first press; Hint stays until the sequence ends.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_soft_pulse_scope.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  testWidgets(
    'passive-actions SoftPulse only the first press inside the lesson frame',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-01-03-01-explain-passives',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 40,
        accessibilityText: 'Tap Fold, Check, and Call.',
        acceptedGrades: const [SoftGrade.recommended],
        coachMedia: const [
          CoachMediaRef(id: 'h', kind: 'hint', text: 'Start with Fold'),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme(),
          home: Scaffold(
            body: LessonFrameScope(
              onLocalMiss: (_) {},
              activityController: controller,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return LessonSoftPulseScope(
                    allowed: controller.showTargetCue,
                    child: PassiveActionsDemo(
                      interactive: true,
                      enabled: true,
                      onAllActionsTapped: () {},
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(controller.canRequestHint, isTrue);
      expect(controller.showTargetCue, isTrue);
      // SoftPulse paints a non-empty ring decoration while the wave is open.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.key == const ValueKey<String>('glow-highlight-ring') &&
              w.decoration != const BoxDecoration(),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('FOLD'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(controller.showTargetCue, isFalse);
      expect(controller.canRequestHint, isTrue);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.key == const ValueKey<String>('glow-highlight-ring') &&
              w.decoration != const BoxDecoration(),
        ),
        findsNothing,
      );

      controller.revealHint();
      await tester.pump();
      expect(controller.showTargetCue, isTrue);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.key == const ValueKey<String>('glow-highlight-ring') &&
              w.decoration != const BoxDecoration(),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('CHECK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.showTargetCue, isFalse);
      expect(controller.canRequestHint, isTrue);

      await tester.tap(find.text('CALL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.sequentialPressesRemaining, isFalse);
      expect(controller.canRequestHint, isFalse);

      controller.dispose();
    },
  );
}
