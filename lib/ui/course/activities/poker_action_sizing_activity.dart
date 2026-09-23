/// Fold/check/call/bet/raise sizing choice activity.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Action + sizing choices styled like the live action dock.
class PokerActionSizingActivity extends StatelessWidget {
  /// Creates the activity.
  const PokerActionSizingActivity({
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
    final spot = resolveLessonActionSpot(activity);
    final tableMode = isLessonActionTableActivity(activity) && spot != null;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.draft.choiceId;
        final locked = controller.submitting || controller.lastResult != null;
        final feltFirstCoach = _feltFirstCoach(activity, spot);
        final fallback =
            feltFirstCoach ??
            (activity.id == 'act-01-06-01-unguided-lab'
                ? 'Big blind vs a button open — tap Fold, Call, or Jam.'
                : spot?.identifyUnavailable == true
                ? 'A bet is out — tap the action you cannot take.'
                : spot?.stackLabel != null
                ? 'Short stack — tap what you can put in.'
                : spot?.openPot == true
                ? 'The pot is open — tap the first chips.'
                : spot?.facingBet == true
                ? 'Read the pot and the bet — tap your action.'
                : spot != null
                ? 'Nothing to match — tap the free action.'
                : 'Choose the action you would take live.');
        // Felt already shows holes / villain line — never dump "72o" prompts.
        final resolved =
            tableMode
                ? (coach: fallback, showPrompt: false)
                : resolveLessonCoachPrompt(
                  activity: activity,
                  fallback: fallback,
                );
        final coach = resolved.coach;
        final showPrompt = resolved.showPrompt;
        final showCoach =
            !locked &&
            shouldShowLessonCoach(
              activity: activity,
              showGuidance: showGuidance,
              coach: coach,
            );

        if (tableMode) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showCoach) RexCoachLine(text: coach),
              if (showPrompt) ...[
                const SizedBox(height: 12),
                Text(
                  activity.prompt!,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              LessonActionTable(spot: spot),
              const SizedBox(height: 14),
              LessonActionDock(
                choices: activity.choices,
                selectedId: selected,
                enabled: !locked,
                identifyUnavailable: spot.identifyUnavailable,
                facingBet: spot.facingBet,
                onSelect:
                    (id) => controller.selectChoice(id, autoSubmit: true),
              ),
              Builder(
                builder: (context) {
                  final status = () {
                    if (controller.lastResult != null) return '';
                    if (controller.submitting) return 'Checking…';
                    if (selected == null) {
                      // Felt + Rex already name open pots — avoid a third
                      // "tap Bet" line under the dock.
                      return spot.identifyUnavailable
                          ? 'Tap the illegal action.'
                          : spot.stackLabel != null
                          ? 'Tap All-in, Call, or Fold on the dock.'
                          : 'Tap your action on the dock.';
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
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showCoach) RexCoachLine(text: coach),
            if (showPrompt) ...[
              const SizedBox(height: 12),
              Text(
                activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final choice in activity.choices)
                  _ActionPill(
                    label: choice.label,
                    accessibilityText:
                        choice.accessibilityText ??
                        [
                          if (choice.action != null) choice.action!,
                          choice.label,
                        ].join(' '),
                    selected: selected == choice.id,
                    enabled: !locked,
                    onPressed: () =>
                        controller.selectChoice(choice.id, autoSubmit: true),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final status = () {
                  if (controller.lastResult != null) return '';
                  if (controller.submitting) return 'Checking…';
                  if (selected == null) return 'Tap your action.';
                  return 'Checking…';
                }();
                if (status.isEmpty) return const SizedBox.shrink();
                return Text(
                  status,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Felt-first Rex lines for action spots (felt already shows cards/context).
String? _feltFirstCoach(CourseActivity activity, LessonActionSpot? _) {
  return switch (activity.id) {
    'act-01-03-01-guided-fold' => 'Worst hand vs a raise — tap Fold.',
    'act-01-03-01-scaffolded-check' => 'Nothing faces you — tap Check.',
    'act-01-03-01-unguided-call' => 'A bet is out — tap Call to continue.',
    'act-01-03-01-checkpoint-legal' =>
      'A bet is out — tap the action you cannot take.',
    'act-01-03-02-guided-bet' => 'The pot is open — tap a bet size.',
    'act-01-03-02-scaffolded-raise' => 'They bet — tap a raise size.',
    'act-01-03-02-unguided-allin' => 'Short vs a big bet — tap All-in.',
    'act-01-03-02-checkpoint-names' => 'The pot is open — tap Bet.',
    'act-02-07-01-guided-ep' =>
      'Suited broadway UTG — tap Open to 6.',
    'act-02-07-01-scaffolded-vs' =>
      'Pair on the button vs a small open — tap Call.',
    // Unguided: name the spot, not the answer.
    'act-02-07-01-unguided-lab' =>
      'CO open faces you on the button — tap Fold, Call, or 3-bet.',
    // Jump: name the spot, not the answer.
    'act-02-07-02-jump-open' =>
      'Trash UTG — tap Fold or Open.',
    'act-02-07-02-jump-vs' =>
      'Aces in the big blind vs an open — tap your action.',
    'act-03-04-01-guided' =>
      'Top pair top kicker checked to you — tap a value bet.',
    'act-03-04-01-scaffolded' =>
      'You opened; dry ace flops — tap a small c-bet.',
    // Unguided / checkpoint: name the spot, not the answer.
    'act-03-04-01-unguided' =>
      'Set multiway vs a bet — tap Raise, Call, or Fold.',
    'act-03-04-01-checkpoint' =>
      'Bottom pair vs bet and raise multiway — tap your action.',
    'act-03-05-01-scaffolded' =>
      'TPTK on a brick turn after a call — tap a barrel.',
    'act-03-05-01-unguided' =>
      'Flush comes in; checked to you — tap delayed value.',
    'act-03-06-01-guided' =>
      'Top two on a brick river — tap a value bet.',
    'act-03-06-01-scaffolded' =>
      'You missed; river completes the flush — tap the bluff.',
    'act-03-06-01-unguided' =>
      'Weak top pair faces a quiet-line jam — tap Fold or Call.',
    'act-03-07-01-guided' =>
      'Second pair four ways — tap Check or Bet.',
    'act-03-07-01-scaffolded' =>
      'Missed on a wet board with a crowd — tap Check.',
    'act-03-08-01-guided' =>
      'Weak top pair in a raise-reraise pot — tap Fold.',
    'act-03-08-01-scaffolded' =>
      'Gutshot vs an overbet — tap Fold.',
    'act-03-08-01-unguided' =>
      'Air multiway vs a bet — tap Fold.',
    'act-03-08-02-jump-mw' =>
      'Air four-way on a wet flop — tap Fold.',
    'act-03-08-02-jump-river' =>
      'Top two on a brick river — tap a value bet.',
    'act-04-02-01-guided' =>
      'Queens on the button vs a CO open — tap a 3-bet.',
    'act-04-02-01-scaffolded' =>
      '72o faces a BB 3-bet — tap Fold.',
    'act-04-02-01-unguided' =>
      'UTG open, two callers, AKo in BB — tap a squeeze.',
    'act-04-02-01-checkpoint' =>
      'KK vs a live open to 6 — tap a 3-bet size.',
    'act-04-03-01-scaffolded' =>
      'Air vs a flush turn — tap Check to shut down.',
    'act-04-03-01-unguided' =>
      'Medium hand multiway and deep — tap Keep pot small.',
    'act-04-04-01-guided' =>
      'Dry board, top pair — tap a value size into 20.',
    'act-04-04-01-scaffolded' =>
      'Missed draw on a scare river — tap a pressure size.',
    'act-04-04-01-checkpoint' =>
      'Strong hand for value into 30 — tap the worst size.',
    _ => null,
  };
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.enabled,
    this.accessibilityText,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final bool enabled;
  final String? accessibilityText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: accessibilityText ?? label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 108, minHeight: 48),
        child: Material(
          color:
              selected
                  ? AppColors.gold.withValues(alpha: 0.22)
                  : AppColors.feltDark.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.gold : AppColors.feltBorder,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
