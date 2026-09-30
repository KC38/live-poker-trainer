/// Home status bar: streak, XP, gems.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Compact course stats strip for Home.
class CourseStatusBar extends StatelessWidget {
  /// Creates the status bar.
  const CourseStatusBar({
    super.key,
    required this.streak,
    required this.lifetimeXp,
    required this.gems,
    this.acceptedAccuracy,
  });

  final int streak;
  final int lifetimeXp;
  final int gems;

  /// Kept for callers that still pass accuracy; no longer shown in the bar.
  final double? acceptedAccuracy;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Streak $streak days, $lifetimeXp XP, $gems gems',
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              icon: Icons.local_fire_department_outlined,
              label: 'Streak',
              value: '$streak',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatChip(
              icon: Icons.bolt_outlined,
              label: 'XP',
              value: '$lifetimeXp',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatChip(
              icon: Icons.diamond_outlined,
              label: 'Gems',
              value: '$gems',
              iconColor: const Color(0xFF5EC8FF),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slateDark.withValues(alpha: 0.85)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.cream,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
