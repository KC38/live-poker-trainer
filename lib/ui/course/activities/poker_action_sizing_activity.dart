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
        final coach =
            activity.primaryCoachLine?.text ??
            (spot?.identifyUnavailable == true
                ? 'A bet is out — tap the action you cannot take.'
                : spot?.facingBet == true
                ? 'Read the pot and the bet — tap your action.'
                : spot != null
                ? 'Nothing to match — tap the free action.'
                : 'Choose the action you would take live.');

        if (tableMode) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RexCoachLine(text: coach),
              if (activity.prompt != null) ...[
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
                onSelect: controller.selectChoice,
              ),
              const SizedBox(height: 10),
              Text(
                selected == null
                    ? (spot.identifyUnavailable
                        ? 'Tap the illegal action.'
                        : 'Tap Fold, Check, or Call on the dock.')
                    : 'Ready — Check when it looks right.',
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
            if (showGuidance || activity.primaryCoachLine != null)
              RexCoachLine(text: coach),
            if (activity.prompt != null) ...[
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
                    onPressed: () => controller.selectChoice(choice.id),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
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
