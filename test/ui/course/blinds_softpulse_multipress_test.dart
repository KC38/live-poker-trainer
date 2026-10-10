/// SoftPulse continuity on Button and blinds explain (LPT-49).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_soft_pulse_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'blinds SoftPulse advances to SB after button when Hint cannot reopen',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final activity = CourseActivity(
        id: 'act-01-01-03-explain-button',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Clockwise from the button: small blind, then big blind.',
        acceptedGrades: const [SoftGrade.recommended],
      );
      final controller = LessonActivityController(activity: activity);
      addTearDown(controller.dispose);
      controller.notifyFeltDealReady(true);

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
                    child: LessonBlindsClockwiseTable(onComplete: () {}),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      // SoftPulse waits for deal settle inside FeltTableView.
      await tester.pump(const Duration(milliseconds: 900));

      LessonTargetGlow seatGlow(int seatIndex) {
        final seat = find.byKey(ValueKey<String>('lesson-seat-$seatIndex'));
        return tester.widget<LessonTargetGlow>(
          find.descendant(of: seat, matching: find.byType(LessonTargetGlow)),
        );
      }

      expect(seatGlow(lessonBlindsButtonIndex).highlighted, isTrue);
      expect(seatGlow(lessonBlindsSmallBlindIndex).highlighted, isFalse);

      await tester.tap(
        find.byKey(ValueKey<String>('lesson-seat-$lessonBlindsButtonIndex')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.showTargetCue, isTrue);
      expect(controller.canRequestHint, isFalse);
      expect(seatGlow(lessonBlindsButtonIndex).highlighted, isFalse);
      expect(seatGlow(lessonBlindsSmallBlindIndex).highlighted, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
