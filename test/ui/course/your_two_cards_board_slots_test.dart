/// Your two cards region-tap steps hide empty turn/river outlines (LPT-66).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'guided find-holes hides empty board slot outlines at mini size',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final activity = CourseActivity(
        id: 'act-01-01-01-guided-find-holes',
        order: 2,
        stage: ActivityStage.guided,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 40,
        accessibilityText: 'Tap the two private hole cards in front of you.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Tap your hole cards on the table.',
        choices: const [
          CourseChoice(id: 'choice-hero-holes', label: 'Ah Kd in front of you'),
          CourseChoice(id: 'choice-board', label: 'The flop cards in the middle'),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme(),
          home: Scaffold(
            body: TableFeaturesScope(
              features: TableFeatures.forLessonId(
                'lesson-01-01-01-your-two-cards',
              ),
              child: LessonFrameScope(
                onLocalMiss: (_) {},
                child: LessonScreenLayout(
                  progress: 0.25,
                  livesRemaining: 5,
                  livesMax: 5,
                  onClose: () {},
                  speech: 'Tap your two cards.',
                  expression: LessonMascotExpression.thinking,
                  stage: SelectIdentifyActivity(
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

      expect(find.byType(TableCardSlot), findsNothing);
      expect(find.byType(FeltTableView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
