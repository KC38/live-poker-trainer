/// Fold / check / call action steps hide empty board slot outlines (LPT-77).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/poker_action_sizing_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpActionStep(
    WidgetTester tester, {
    required CourseActivity activity,
  }) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    // SoftPulse / felt deal unlock for framed tables.
    controller.notifyFeltDealReady(true);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: TableFeaturesScope(
            features: TableFeatures.forLessonId(
              'lesson-01-03-01-fold-check-call',
            ),
            child: LessonFrameScope(
              onLocalMiss: (_) {},
              child: LessonScreenLayout(
                progress: 0.25,
                livesRemaining: 5,
                livesMax: 5,
                onClose: () {},
                speech: activity.prompt ?? 'Tap your action.',
                expression: LessonMascotExpression.thinking,
                stage: PokerActionSizingActivity(
                  activity: activity,
                  controller: controller,
                  showGuidance: true,
                ),
                onUndo: () {},
                onRedo: () {},
                onHint: () {},
                canUndo: false,
                canRedo: false,
                canHint: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets(
    'guided-fold preflop hides empty board slot outlines at mini size',
    (tester) async {
      await pumpActionStep(
        tester,
        activity: CourseActivity(
          id: 'act-01-03-01-guided-fold',
          order: 2,
          stage: ActivityStage.guided,
          renderer: ActivityRenderer.pokerActionSizing,
          estimatedSeconds: 55,
          accessibilityText: 'Tap Fold with seven-two offsuit versus an open.',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Worst hand vs a raise — pick how you leave.',
          choices: const [
            CourseChoice(id: 'fold-72', label: 'Fold', action: 'FOLD'),
            CourseChoice(id: 'call-72', label: 'Call 6', action: 'CALL'),
            CourseChoice(
              id: 'raise-72',
              label: 'Raise to 18',
              action: 'RAISE',
            ),
          ],
        ),
      );

      expect(find.byType(TableCardSlot), findsNothing);
      expect(find.byType(FeltTableView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'scaffolded-check flop hides empty turn/river outlines at mini size',
    (tester) async {
      await pumpActionStep(
        tester,
        activity: CourseActivity(
          id: 'act-01-03-01-scaffolded-check',
          order: 3,
          stage: ActivityStage.scaffolded,
          renderer: ActivityRenderer.pokerActionSizing,
          estimatedSeconds: 55,
          accessibilityText: 'Tap Check when the action is free.',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Nothing faces you — pick the free action.',
          choices: const [
            CourseChoice(
              id: 'check-free',
              label: 'Check free',
              action: 'CHECK',
            ),
            CourseChoice(id: 'call-free', label: 'Call', action: 'CALL'),
            CourseChoice(id: 'fold-free', label: 'Fold', action: 'FOLD'),
          ],
        ),
      );

      // Dealt flop cards remain; empty street placeholders do not.
      expect(find.byType(TableCardSlot), findsNothing);
      expect(find.byType(FeltTableView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
