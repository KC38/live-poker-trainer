/// Soft-grade feedback sheet for lesson activities.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

/// Maps server soft grades to lesson feedback chrome.
class LessonFeedbackSheet extends StatelessWidget {
  /// Creates a feedback sheet.
  ///
  /// When [showActions] is false, the runner owns sticky Continue / Try again
  /// buttons in the footer so they stay reachable above the home indicator.
  const LessonFeedbackSheet({
    super.key,
    required this.result,
    required this.onContinue,
    this.onRetry,
    this.betterChoiceLabel,
    this.showActions = true,
  });

  /// Enter fade/slide duration when a grade result appears.
  static const Duration enterDuration = Duration(milliseconds: 180);

  final SubmitCourseStepResult result;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;
  final String? betterChoiceLabel;
  final bool showActions;

  Color get _accent {
    return switch (result.grade) {
      SoftGrade.recommended || SoftGrade.strong || SoftGrade.reasonable =>
        AppColors.success,
      SoftGrade.questionable => AppColors.warning,
      SoftGrade.clearMistake => AppColors.danger,
    };
  }

  String get _title {
    return switch (result.grade) {
      SoftGrade.recommended => 'Nice!',
      SoftGrade.strong => 'Strong!',
      SoftGrade.reasonable => 'Playable',
      SoftGrade.questionable => 'Think again',
      SoftGrade.clearMistake => 'Not quite',
    };
  }

  @override
  Widget build(BuildContext context) {
    // Reasonable/questionable must never look like a life-loss event.
    final showLifeLoss = result.lifeLost;
    // Sticky footer owns CTAs — tighten bottom padding so sheet + dock hug.
    final bottomPad = showActions ? 14.0 : 10.0;
    return Semantics(
      liveRegion: true,
      label: '$_title. ${result.feedback}',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: enterDuration,
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 12),
              child: child,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _accent.withValues(alpha: 0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    result.accepted
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    color: _accent,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _title,
                      style: GoogleFonts.manrope(
                        color: _accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (showLifeLoss)
                    Text(
                      'Life −1',
                      style: GoogleFonts.manrope(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                result.feedback,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (betterChoiceLabel != null) ...[
                const SizedBox(height: 10),
                // Preferred recovery as a scannable chip (not flat slate prose).
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'Preferred: $betterChoiceLabel',
                    style: GoogleFonts.manrope(
                      color: AppColors.cream,
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              if (result.reversalRead != null &&
                  result.reversalRead!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'When it flips: ${result.reversalRead}',
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
              if (showActions) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (onRetry != null && !result.accepted) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onRetry,
                          child: const Text('Try again'),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: onContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.bgDark,
                        ),
                        child: Text(result.accepted ? 'Continue' : 'Got it'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
