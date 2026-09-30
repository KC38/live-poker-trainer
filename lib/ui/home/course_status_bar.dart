/// Home status bar: sections, streak, gems, hearts — Duolingo-style strip.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Default hearts shown on Home (matches per-lesson lives max).
const int kHomeDefaultHearts = 3;

/// Compact course stats strip for Home.
///
/// Layout mirrors Duolingo chess: course mark on the left, then streak, gems,
/// and hearts spaced evenly across the row with matching accent colors.
class CourseStatusBar extends StatelessWidget {
  /// Creates the status bar.
  const CourseStatusBar({
    super.key,
    required this.streak,
    required this.gems,
    this.hearts = kHomeDefaultHearts,
    this.lifetimeXp,
    this.acceptedAccuracy,
    this.onCourseTap,
  });

  final int streak;
  final int gems;

  /// Remaining hearts / lives for the learner.
  final int hearts;

  /// Kept for callers that still pass XP; the strip no longer shows it.
  final int? lifetimeXp;

  /// Kept for callers that still pass accuracy; gems replace it in the strip.
  final double? acceptedAccuracy;

  /// Opens the section picker (course map).
  final VoidCallback? onCourseTap;

  static const Color _gemColor = Color(0xFF5EC8FF);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Streak $streak days, $gems gems, $hearts hearts',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: [
            _CourseMark(onTap: onCourseTap),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatIcon(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppColors.warning,
                    label: 'Streak',
                    value: '$streak',
                    valueColor: AppColors.warning,
                  ),
                  _StatIcon(
                    icon: Icons.diamond_rounded,
                    iconColor: _gemColor,
                    label: 'Gems',
                    value: '$gems',
                    valueColor: _gemColor,
                  ),
                  _StatIcon(
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.hearts,
                    label: 'Hearts',
                    value: '$hearts',
                    valueColor: AppColors.hearts,
                  ),
                ],
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
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 5),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
