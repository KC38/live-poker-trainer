/// Authored multi-step hand decisions on a mini felt + action dock.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Walks authored street steps; submits the active step's choice.
class AuthoredMultiStepActivity extends StatelessWidget {
  /// Creates the activity.
  const AuthoredMultiStepActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  String get _coachText {
    return switch (activity.id) {
      'act-01-06-01-guided-steps' =>
        'Button toy hand — open, then see if it ends.',
      'act-01-06-01-scaffolded-multi' =>
        'Called open — confirm the flop, then act.',
      'act-01-06-01-checkpoint-finish' =>
        'Finish a short button hand without freezing.',
      'act-01-06-02-jump-hand' =>
        'Jump check — open the button, then take the blinds.',
      _ => 'Play the street — tap your action on the dock.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final steps = activity.handSteps;
        if (steps.isEmpty) {
          return const RexCoachLine(
            text: 'This multi-step hand is missing public steps.',
          );
        }
        final index =
            controller.draft.handStepIndex.clamp(0, steps.length - 1);
        final step = steps[index];
        final locked = controller.submitting || controller.lastResult != null;
        final selected = controller.draft.choiceId;
        final spot = resolveToyHandStepSpot(
          activityId: activity.id,
          stepId: step.id,
        );
        final tableMode = isLessonActionTableActivity(activity) && spot != null;

        if (tableMode) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RexCoachLine(text: _coachText),
              const SizedBox(height: 10),
              Text(
                'Street ${index + 1} of ${steps.length}',
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step.prompt,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              LessonActionTable(spot: spot),
              const SizedBox(height: 14),
              LessonActionDock(
                choices: step.choices,
                selectedId: selected,
                enabled: !locked,
                onSelect: controller.selectChoice,
              ),
              const SizedBox(height: 10),
              Text(
                selected == null
                    ? 'Tap your action on the dock.'
                    : 'Ready — Lock in below.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showGuidance)
              RexCoachLine(
                text: 'Street ${index + 1} of ${steps.length}: ${step.street}',
              ),
            const SizedBox(height: 12),
            Text(
              step.prompt,
              style: GoogleFonts.manrope(
                color: AppColors.cream,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < step.choices.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              LessonChoiceButton(
                label: step.choices[i].label,
                accessibilityText: step.choices[i].accessibilityText,
                selected: selected == step.choices[i].id,
                enabled: !locked,
                onPressed: () =>
                    controller.selectChoice(step.choices[i].id),
              ),
            ],
          ],
        );
      },
    );
  }
}
