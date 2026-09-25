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
      ('act-01-06-01-guided-steps', 'step-01-06-pre') =>
        'Button toy hand — open, then see if it ends.',
      ('act-01-06-01-guided-steps', 'step-01-06-flop') =>
        'Blinds folded — what happened to the pot?',
      ('act-01-06-01-guided-steps', _) =>
        'Button toy hand — open, then see if it ends.',
      ('act-01-06-01-scaffolded-multi', 'step-01-06-bb-defend') =>
        'BB called — is the hand still alive?',
      ('act-01-06-01-scaffolded-multi', 'step-01-06-flop-cbet') =>
        'Top pair on A72 — charge when checked to.',
      ('act-01-06-01-scaffolded-multi', _) =>
        'Called open — confirm the flop, then act.',
      ('act-01-06-01-checkpoint-finish', 'step-01-06-cp-end') =>
        'Blinds folded — what happened to the pot?',
      ('act-01-06-01-checkpoint-finish', _) =>
        'Finish a short button hand without freezing.',
      // SoftPulse-quiet jump: list options with pick — no SoftPulse, no meta.
      ('act-01-06-02-jump-hand', 'j-hand-end') =>
        'Blinds folded — pick Won pot or Need showdown.',
      ('act-01-06-02-jump-hand', _) =>
        'Button with ATs — folds to you. Pick Raise to 6 or Fold.',
      ('act-04-03-01-guided', 'step-flop-tp') =>
        'TPTK on a dry flop — start the multi-street plan.',
      ('act-04-03-01-guided', 'step-turn-tp') =>
        'Brick turn after a call — keep charging for value.',
      // Section 7 lab hands are SoftPulse-quiet (unguided) — conceptual only.
      ('act-07-10-01-hand', 'step-flop') =>
        'BTN SRP on K72r — you are first in with the betting lead.',
      ('act-07-10-01-hand', 'step-turn') =>
        'Called · paired blank — keep pressure on blanks.',
      ('act-07-10-01-hand', 'step-river') =>
        'Ace-high on 9c — no value left; pot control.',
      ('act-07-10-02-hand', 'step-3b-flop') =>
        '3-bet pot · Q83tt — strong made hand with the lead.',
      ('act-07-10-02-hand', 'step-3b-turn') =>
        'Called · blank turn — keep charging value.',
      ('act-07-10-02-hand', 'step-3b-river') =>
        'TAG check-raises huge — respect the size.',
      ('act-07-10-03-hand', 'step-mw-flop') =>
        'Deep multiway · flush draw — price is right to continue.',
      ('act-07-10-03-hand', 'step-mw-turn') =>
        'Turn checked · nut draw — apply pressure as a semi-bluff.',
      ('act-07-10-03-hand', 'step-mw-river') =>
        'Missed river · two behind — give up without a showdown.',
      ('act-07-10-04-hand', 'step-limp-flop') =>
        'Limped · top pair — charge when checked to.',
      ('act-07-10-04-hand', 'step-limp-turn') =>
        'Two callers · blank — keep extracting value.',
      ('act-07-10-04-hand', 'step-limp-river') =>
        'Both call · thin value — still extract one street.',
      ('act-07-10-05-hand', 'step-4b-flop') =>
        '4-bet pot · Q83r — small pot, keep the lead.',
      ('act-07-10-05-hand', 'step-4b-turn') =>
        'Called · blank — stacks are committed to the end.',
      ('act-07-10-05-hand', 'step-4b-river') =>
        'Ace hits · jam — behind the overcard; release.',
      _ => 'Read the board — act on the dock.',
    };
  }

  /// Guided/scaffolded soft-pulse target — teaches by doing, not by spoiling
  /// checkpoint/unguided grades.
  String? _pulseChoiceIdFor(CourseHandStep step) {
    if (!showGuidance) return null;
    return switch ((activity.id, step.id)) {
      ('act-01-06-01-guided-steps', 'step-01-06-pre') => 'open-6',
      ('act-01-06-01-guided-steps', 'step-01-06-flop') => 'won-folds',
      ('act-01-06-01-scaffolded-multi', 'step-01-06-bb-defend') => 'ready-flop',
      ('act-01-06-01-scaffolded-multi', 'step-01-06-flop-cbet') => 'cbet',
      ('act-01-06-02-jump-hand', 'j-hand-open') => 'j-open',
      ('act-01-06-02-jump-hand', 'j-hand-end') => 'j-yes',
      ('act-04-03-01-guided', 'step-flop-tp') => 'flop-bet',
      ('act-04-03-01-guided', 'step-turn-tp') => 'turn-bet',
      _ => null,
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
          final pulseChoiceId =
              locked || selected != null ? null : _pulseChoiceIdFor(step);
          // SoftPulse and/or Rex own the cue — hide a third gold felt tip
          // (including SoftPulse-quiet checkpoint/jump where SoftPulse is off).
          final coachOwnsCue = !locked;
          return LayoutBuilder(
            builder: (context, constraints) {
              final fill =
                  constraints.hasBoundedHeight &&
                  constraints.maxHeight.isFinite;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
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
                  if (fill)
                    Expanded(
                      child: LessonActionTable(
                        spot: spot,
                        coachOwnsCue: coachOwnsCue,
                      ),
                    )
                  else
                    LessonActionTable(
                      spot: spot,
                      coachOwnsCue: coachOwnsCue,
                    ),
                  const SizedBox(height: 14),
                  LessonActionDock(
                    choices: step.choices,
                    selectedId: selected,
                    enabled: !locked,
                    facingBet: spot.facingBet,
                    heroStackAmount: spot.heroStackAmount,
                    pulseChoiceId: pulseChoiceId,
                    onSelect:
                        (id) => controller.selectChoice(id, autoSubmit: true),
                  ),
                  Builder(
                    builder: (context) {
                      final status = () {
                        if (controller.lastResult != null) return '';
                        if (controller.submitting) return 'Checking…';
                        if (selected == null) {
                          // Rex already cues the dock — SoftPulse (guided) or
                          // the dock itself teaches. No third "tap…" line.
                          return '';
                        }
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
            },
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
