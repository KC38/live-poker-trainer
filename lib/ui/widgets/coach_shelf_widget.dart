/// Dedicated coach shelf — clear CORRECT / INCORRECT, never over cards.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';

/// Non-overlapping AI coach panel between felt and action dock.
class CoachShelfWidget extends StatelessWidget {
  /// Creates the coach shelf.
  const CoachShelfWidget({
    super.key,
    required this.feedback,
    this.onMuteToggle,
    this.ttsEnabled = true,
  });

  final CoachFeedback feedback;
  final VoidCallback? onMuteToggle;
  final bool ttsEnabled;

  @override
  Widget build(BuildContext context) {
    final hasVerdict = feedback.hasVerdict;
    final borderColor = feedback.verdict == CoachVerdict.correct
        ? AppColors.success
        : feedback.verdict == CoachVerdict.incorrect
            ? AppColors.danger
            : AppColors.slateDark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: hasVerdict ? 1.5 : 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasVerdict) ...[
            _VerdictBadge(verdict: feedback.verdict),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coach',
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldMuted,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feedback.message.isEmpty
                      ? 'Your move — pick Fold, Check/Call, or Bet/Raise.'
                      : feedback.message,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.cream,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasVerdict && feedback.optimalAction != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Best: ${feedback.optimalAction!.label}'
                      '${feedback.heroAction != null ? '  ·  You: ${feedback.heroAction}' : ''}'
                      '  ·  EV ${feedback.evDeltaBb >= 0 ? '+' : ''}${feedback.evDeltaBb.toStringAsFixed(2)} BB',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        height: 1.35,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: ttsEnabled ? 'Mute coach' : 'Unmute coach',
            onPressed: onMuteToggle,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              ttsEnabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
              color: AppColors.slate,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerdictBadge extends StatelessWidget {
  const _VerdictBadge({required this.verdict});

  final CoachVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final correct = verdict == CoachVerdict.correct;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: correct ? AppColors.success : AppColors.danger,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        correct ? 'CORRECT' : 'INCORRECT',
        style: GoogleFonts.jetBrainsMono(
          fontWeight: FontWeight.w800,
          fontSize: 11,
          color: AppColors.bgDark,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
