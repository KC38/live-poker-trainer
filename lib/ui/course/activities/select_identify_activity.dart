/// Select / identify activity (positions, cards, classifications).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Multiple-choice identify activity with optional guided highlight.
class SelectIdentifyActivity extends StatelessWidget {
  /// Creates the activity.
  const SelectIdentifyActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  @override
  Widget build(BuildContext context) {
    final scene = resolveLessonTableScene(activity);
    final coachText =
        activity.primaryCoachLine?.text ??
        (scene == null
            ? 'Pick the best answer.'
            : 'Look at the table, then pick the answer that matches.');

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.draft.choiceId;
        final locked = controller.submitting || controller.lastResult != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (activity.primaryCoachLine != null || showGuidance)
              RexCoachLine(text: coachText),
            if (scene != null) ...[
              const SizedBox(height: 14),
              LessonTableContext(scene: scene),
            ],
            if (activity.prompt != null) ...[
              const SizedBox(height: 14),
              Text(
                activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 16),
            for (var i = 0; i < activity.choices.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              LessonChoiceButton(
                label: activity.choices[i].label,
                accessibilityText: activity.choices[i].accessibilityText,
                selected: selected == activity.choices[i].id,
                highlighted:
                    showGuidance &&
                    activity.stage == ActivityStage.guided &&
                    i == 0 &&
                    selected == null,
                enabled: !locked,
                onPressed:
                    () => controller.selectChoice(activity.choices[i].id),
              ),
            ],
          ],
        );
      },
    );
  }
}
