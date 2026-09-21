/// Progress, lives, streak, and hint chrome for the lesson runner.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Top chrome for an in-progress lesson.
class LessonProgressHeader extends StatelessWidget {
  /// Creates the header.
  const LessonProgressHeader({
    super.key,
    this.title,
    required this.progress,
    required this.livesRemaining,
    required this.livesMax,
    required this.acceptedStreak,
    this.onHint,
    this.hintEnabled = false,
  });

  /// Optional secondary title. Prefer showing the activity prompt once in the
  /// activity body — leave null here to avoid duplicating the question.
  final String? title;
  final double progress;
  final int livesRemaining;
  final int livesMax;
  final int acceptedStreak;
  final VoidCallback? onHint;
  final bool hintEnabled;

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTitle || onHint != null)
          Row(
            children: [
              if (hasTitle)
                Expanded(
                  child: Text(
                    title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: AppColors.cream,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (onHint != null)
                TextButton.icon(
                  onPressed: hintEnabled ? onHint : null,
                  icon: const Icon(Icons.lightbulb_outline, size: 18),
                  label: const Text('Hint'),
                ),
            ],
          ),
        if (hasTitle || onHint != null) const SizedBox(height: 10),
        Semantics(
          label:
              'Lesson progress ${(progress * 100).round()} percent. '
              '$livesRemaining of $livesMax lives. '
              'Accepted streak $acceptedStreak.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.slateDark,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.favorite, size: 16, color: AppColors.danger),
                  const SizedBox(width: 4),
                  Text(
                    '$livesRemaining/$livesMax',
                    style: GoogleFonts.manrope(
                      color: AppColors.slate,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Streak $acceptedStreak',
                    style: GoogleFonts.manrope(
                      color: AppColors.slate,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
