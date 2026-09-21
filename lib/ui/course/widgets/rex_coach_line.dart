/// Shared Rex coach line for lesson activities.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';

/// One short Rex sentence with optional demonstration chrome.
class RexCoachLine extends StatelessWidget {
  /// Creates a Rex line.
  const RexCoachLine({
    super.key,
    required this.text,
    this.label = 'Rex',
    this.emphasize = false,
  });

  /// Builds from catalog media when present.
  factory RexCoachLine.fromActivity(CourseActivity activity, {Key? key}) {
    final media = activity.primaryCoachLine;
    return RexCoachLine(
      key: key,
      text: media?.text ?? activity.accessibilityText,
      emphasize: media?.kind == 'demonstration',
    );
  }

  final String text;
  final String label;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label says: $text',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                emphasize
                    ? AppColors.gold.withValues(alpha: 0.55)
                    : AppColors.slateDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: GoogleFonts.manrope(
                color: AppColors.cream,
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Choice chip/button used across select-style activities.
class LessonChoiceButton extends StatelessWidget {
  /// Creates a choice button.
  const LessonChoiceButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.accessibilityText,
    this.highlighted = false,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final String? accessibilityText;
  final bool highlighted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final border =
        selected
            ? AppColors.gold
            : highlighted
            ? AppColors.goldMuted
            : AppColors.slateDark;
    return Semantics(
      button: true,
      selected: selected,
      label: accessibilityText ?? label,
      child: AnimatedScale(
        scale: selected ? 1.015 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Material(
          color:
              selected
                  ? AppColors.gold.withValues(alpha: 0.22)
                  : highlighted
                  ? AppColors.gold.withValues(alpha: 0.08)
                  : AppColors.surfaceMuted.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: selected ? 2 : 1),
              ),
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  color: enabled ? AppColors.cream : AppColors.slate,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
