/// Progress, lives, streak, and hint chrome for the lesson runner.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Top chrome for an in-progress lesson.
///
/// Duolingo-chess density: one tight row (track + lives + optional streak +
/// hint). Optional title sits flush underneath only when callers pass it.
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
          child: SizedBox(
            height: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.slateDark,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.favorite, size: 16, color: AppColors.danger),
                const SizedBox(width: 3),
                Text(
                  '$livesRemaining',
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    height: 1,
                  ),
                ),
                if (showStreak) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.local_fire_department,
                    size: 15,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$acceptedStreak',
                    style: GoogleFonts.manrope(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      height: 1,
                    ),
                  ),
                ],
                if (onHint != null) ...[
                  const SizedBox(width: 2),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: IconButton(
                      tooltip: 'Hint',
                      onPressed: hintEnabled ? onHint : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.lightbulb_outline,
                        size: 18,
                        color:
                            hintEnabled
                                ? AppColors.gold
                                : AppColors.slateDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasTitle) ...[
          const SizedBox(height: 6),
          Text(
            title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
