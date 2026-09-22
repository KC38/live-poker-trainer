/// Progress, lives, streak, and hint chrome for the lesson runner.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Top chrome for an in-progress lesson.
///
/// Layout mirrors teach-by-doing apps: thick progress track with lives inline,
/// optional hint, and streak only when it is already meaningful.
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
    final showStreak = acceptedStreak >= 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label:
              'Lesson progress ${(progress * 100).round()} percent. '
              '$livesRemaining of $livesMax lives. '
              'Accepted streak $acceptedStreak.',
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: AppColors.slateDark,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.favorite, size: 18, color: AppColors.danger),
              const SizedBox(width: 4),
              Text(
                '$livesRemaining',
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              if (onHint != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Hint',
                  onPressed: hintEnabled ? onHint : null,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color:
                        hintEnabled ? AppColors.gold : AppColors.slateDark,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showStreak) ...[
          const SizedBox(height: 8),
          Text(
            '$acceptedStreak IN A ROW',
            style: GoogleFonts.manrope(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
        if (hasTitle) ...[
          const SizedBox(height: 12),
          Text(
            title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}
