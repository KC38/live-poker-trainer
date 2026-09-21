/// Home status bar: streak, XP, accepted accuracy.
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
    required this.acceptedAccuracy,
  });

  final int streak;
  final int lifetimeXp;
  final double acceptedAccuracy;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (acceptedAccuracy * 100).clamp(0, 100).round();
    return Semantics(
      label:
          'Streak $streak days, $lifetimeXp XP, $accuracyPct percent accepted accuracy',
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
              icon: Icons.verified_outlined,
              label: 'Accepted',
              value: '$accuracyPct%',
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
  });

  final IconData icon;
  final String label;
  final String value;

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
          Icon(icon, size: 18, color: AppColors.gold),
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
                  style: GoogleFonts.manrope(
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
