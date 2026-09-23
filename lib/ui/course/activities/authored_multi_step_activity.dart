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

  String _coachTextFor(CourseHandStep step) {
    return switch ((activity.id, step.id)) {
      ('act-01-06-01-guided-steps', _) =>
        'Button toy hand — open, then see if it ends.',
      ('act-01-06-01-scaffolded-multi', _) =>
        'Called open — confirm the flop, then act.',
      ('act-01-06-01-checkpoint-finish', _) =>
        'Finish a short button hand without freezing.',
      ('act-01-06-02-jump-hand', _) =>
        'Jump check — open the button, then take the blinds.',
      ('act-04-03-01-guided', 'step-flop-tp') =>
        'TPTK on a dry flop — tap Bet to start the plan.',
      ('act-04-03-01-guided', 'step-turn-tp') =>
        'Brick turn after a call — tap Bet again for value.',
      ('act-07-10-01-hand', 'step-flop') =>
        'BTN SRP on K72r — tap Bet.',
      ('act-07-10-01-hand', 'step-turn') =>
        'Called · paired turn — tap Barrel many blanks.',
      ('act-07-10-01-hand', 'step-river') =>
        'Ace-high on 9c — tap Check.',
      ('act-07-10-02-hand', 'step-3b-flop') =>
        '3-bet pot · Q83tt — tap C-bet value.',
      ('act-07-10-02-hand', 'step-3b-turn') =>
        'Called · blank turn — tap Continue value.',
      ('act-07-10-02-hand', 'step-3b-river') =>
        'TAG check-raises huge — tap Fold.',
      ('act-07-10-03-hand', 'step-mw-flop') =>
        'Deep multiway · flush draw — tap Call.',
      ('act-07-10-03-hand', 'step-mw-turn') =>
        'Turn checked · nut draw — tap Bet semi-bluff.',
      ('act-07-10-03-hand', 'step-mw-river') =>
        'Missed river · two behind — tap Check.',
      ('act-07-10-04-hand', 'step-limp-flop') =>
        'Limped · top pair — tap Bet value.',
      ('act-07-10-04-hand', 'step-limp-turn') =>
        'Two callers · blank — tap Continue value.',
      ('act-07-10-04-hand', 'step-limp-river') =>
        'Both call · thin value — tap Bet thin value.',
      ('act-07-10-05-hand', 'step-4b-flop') =>
        '4-bet pot · Q83r — tap Bet.',
      ('act-07-10-05-hand', 'step-4b-turn') =>
        'Called · blank — tap Continue / commit.',
      ('act-07-10-05-hand', 'step-4b-river') =>
        'Ace hits · jam — tap Fold.',
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
        final coachText = _coachTextFor(step);

        if (tableMode) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nice! owns the line — hide stale Rex; felt already shows cards.
              if (!locked) RexCoachLine(text: coachText),
              const SizedBox(height: 10),
              Text(
                'Street ${index + 1} of ${steps.length}',
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              LessonActionTable(spot: spot),
              const SizedBox(height: 14),
              LessonActionDock(
                choices: step.choices,
                selectedId: selected,
                enabled: !locked,
                facingBet: spot.facingBet,
                onSelect:
                    (id) => controller.selectChoice(id, autoSubmit: true),
              ),
              Builder(
                builder: (context) {
                  final status = () {
                    if (controller.lastResult != null) return '';
                    if (controller.submitting) return 'Checking…';
                    if (selected == null) return 'Tap your action on the dock.';
                    return 'Checking…';
                  }();
                  if (status.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AppColors.slate,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!locked && showGuidance)
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
                onPressed: () => controller.selectChoice(
                      step.choices[i].id,
                      autoSubmit: true,
                    ),
              ),
            ],
          ],
        );
      },
    );
  }
}
