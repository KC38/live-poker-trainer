/// SoftPulse only the first press; Hint stays until the sequence ends.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_soft_pulse_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

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

      expect(controller.showTargetCue, isTrue);
      // SoftPulse already cues Fold — Hint stays off until that press lands.
      expect(controller.canRequestHint, isFalse);
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
      expect(controller.canRequestHint, isFalse);
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

  testWidgets(
    'showdown SoftPulse only You, then stays quiet until Hint',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final activity = CourseActivity(
        id: 'act-01-02-01-explain-ladder',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 40,
        accessibilityText:
            'Showdown — tap You (high card), Sam (pair), then Jo (flush).',
        acceptedGrades: const [SoftGrade.recommended],
      );
      final controller = LessonActivityController(activity: activity);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildPokerTheme(),
            home: Scaffold(
              body: TableFeaturesScope(
                features: TableFeatures.forLessonId(
                  'lesson-01-02-01-hand-ranks',
                ),
                child: LessonFrameScope(
                  onLocalMiss: (_) {},
                  activityController: controller,
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      return LessonSoftPulseScope(
                        allowed: controller.showTargetCue,
                        child: LessonShowdownOrderExplainTable(
                          activityId: activity.id,
                          showGuidance: controller.showTargetCue,
                          onComplete: () {},
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(controller.showTargetCue, isTrue);
      expect(controller.canRequestHint, isFalse);
      LessonTableStage stage() => tester.widget<LessonTableStage>(
        find.byType(LessonTableStage),
      );
      final table = tester.widget<LessonShowdownOrderTable>(
        find.byType(LessonShowdownOrderTable),
      );
      final firstId = table.spot.correctOrder.first;
      final firstSeat = table.spot.seatIds.indexOf(firstId);
      expect(firstSeat, greaterThanOrEqualTo(0));
      if (firstSeat == 0) {
        expect(stage().cue, LessonTableCue.hero);
        expect(stage().cueSeatIndex, isNull);
      } else {
        expect(stage().cue, LessonTableCue.none);
        expect(stage().cueSeatIndex, firstSeat);
      }

      final firstKey = firstSeat == 0
          ? const ValueKey<String>('lesson-seat-hero')
          : ValueKey<String>('lesson-seat-$firstSeat');
      await tester.tap(find.byKey(firstKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(controller.showTargetCue, isFalse);
      expect(controller.canRequestHint, isTrue);
      expect(stage().cue, LessonTableCue.none);
      expect(stage().cueSeatIndex, isNull);

      controller.revealHint();
      await tester.pump();
      expect(controller.showTargetCue, isTrue);
      expect(controller.canRequestHint, isFalse);
      final nextId = table.spot.correctOrder[1];
      final nextSeat = table.spot.seatIds.indexOf(nextId);
      if (nextSeat == 0) {
        expect(stage().cue, LessonTableCue.hero);
        expect(stage().cueSeatIndex, isNull);
      } else {
        expect(stage().cue, LessonTableCue.none);
        expect(stage().cueSeatIndex, nextSeat);
      }
    },
  );
}
