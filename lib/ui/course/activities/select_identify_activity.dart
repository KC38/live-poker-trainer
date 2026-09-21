/// Select / identify activity (positions, cards, classifications).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
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
    final selected = controller.draft.choiceId;
    final locked = controller.submitting || controller.lastResult != null;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (activity.primaryCoachLine != null || showGuidance)
              RexCoachLine(
                text: activity.primaryCoachLine?.text ??
                    'Pick the answer that matches the table.',
              ),
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
                highlighted: showGuidance &&
                    activity.stage == ActivityStage.guided &&
                    i == 0,
                enabled: !locked,
                onPressed: () =>
                    controller.selectChoice(activity.choices[i].id),
              ),
            ],
          ],
        );
      },
    );
  }
}
