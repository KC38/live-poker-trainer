/// Home status bar: streak, XP, accepted accuracy — Duolingo-style strip.
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
    this.onCourseTap,
  });

  final int streak;
  final int lifetimeXp;
  final double acceptedAccuracy;

  /// Opens the section picker (course map).
  final VoidCallback? onCourseTap;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (acceptedAccuracy * 100).clamp(0, 100).round();
    return Semantics(
      label:
          'Streak $streak days, $lifetimeXp XP, $accuracyPct percent accepted accuracy',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          children: [
            _CourseMark(onTap: onCourseTap),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatIcon(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.warning,
                      label: 'Streak',
                      value: '$streak',
                      valueColor: AppColors.cream,
                    ),
                    const SizedBox(width: 14),
                    _StatIcon(
                      icon: Icons.bolt_rounded,
                      iconColor: AppColors.goldBright,
                      label: 'XP',
                      value: '$lifetimeXp',
                      valueColor: AppColors.goldBright,
                    ),
                    const SizedBox(width: 14),
                    _StatIcon(
                      icon: Icons.favorite_rounded,
                      iconColor: AppColors.danger,
                      label: 'Accepted',
                      value: '$accuracyPct%',
                      valueColor: AppColors.danger,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseMark extends StatelessWidget {
  const _CourseMark({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: 'Course sections',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.feltLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF053528),
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.style_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  const _StatIcon({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
