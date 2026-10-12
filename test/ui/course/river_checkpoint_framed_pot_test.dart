/// Close the river checkpoint framed stage posts big-bet money (LPT-344).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
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
            'lesson-03-06-01-river-decisions',
          ),
          child: LessonFrameScope(onLocalMiss: (_) {}, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'river checkpoint framed stage shows pot-sized big bet not POT \$10',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final activity = CourseActivity(
        id: 'act-03-06-01-checkpoint',
        order: 5,
        stage: ActivityStage.scaffolded,
        assessmentRole: AssessmentRole.checkpoint,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 45,
        accessibilityText: 'Medium one pair is often a bluff-catch decision.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt:
            'Which river job matches medium-strength one pair versus a big bet?',
        choices: const [
          CourseChoice(
            id: 'role-catch',
            label: 'Bluff-catch or fold — not thin value',
          ),
          CourseChoice(id: 'role-value', label: 'Always thin-value shove'),
          CourseChoice(id: 'role-air', label: 'Pure bluff with one pair'),
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
      // Pot-sized sticky bet: display pot 40 with villain street bet 40.
      expect(find.textContaining('POT \$40'), findsOneWidget);
      expect(find.textContaining('POT \$10'), findsNothing);
      expect(find.text('BET'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
