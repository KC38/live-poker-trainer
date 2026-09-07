/// Dedicated coach shelf with unmistakable CORRECT / INCORRECT verdict.
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgMid.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: feedback.verdict == CoachVerdict.correct
              ? AppColors.success
              : feedback.verdict == CoachVerdict.incorrect
                  ? AppColors.danger
                  : AppColors.slateDark,
          width: feedback.hasVerdict ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (feedback.hasVerdict) ...[
            _VerdictBadge(verdict: feedback.verdict),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COACH',
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feedback.message.isEmpty
                      ? 'Waiting for your decision…'
                      : feedback.message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.cream,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (feedback.hasVerdict && feedback.optimalAction != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Optimal: ${feedback.optimalAction!.label}'
                      '${feedback.heroAction != null ? ' · You: ${feedback.heroAction}' : ''}'
                      ' · EV ${feedback.evDeltaBb >= 0 ? '+' : ''}${feedback.evDeltaBb.toStringAsFixed(2)} BB',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: ttsEnabled ? 'Mute coach voice' : 'Unmute coach voice',
            onPressed: onMuteToggle,
            icon: Icon(
              ttsEnabled ? Icons.volume_up : Icons.volume_off,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
