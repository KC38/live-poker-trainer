/// Dedicated coach shelf — clear CORRECT / INCORRECT, never over cards.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';

/// Non-overlapping AI coach panel between the hero rail and the action dock.
///
/// The panel is height-capped by its parent band and scrolls internally, so a
/// long coaching line can never grow into the felt or the hero's hole cards.
class CoachShelfWidget extends StatelessWidget {
  /// Creates the coach shelf.
  const CoachShelfWidget({
    super.key,
    required this.feedback,
    required this.bigBlind,
    required this.chipDisplayMode,
    this.onMuteToggle,
    this.ttsEnabled = true,
    this.replaying = false,
    this.maxHeight,
  });

  final CoachFeedback feedback;
  final double bigBlind;
  final ChipDisplayMode chipDisplayMode;
  final VoidCallback? onMuteToggle;
  final bool ttsEnabled;

  /// True while villains are acting, shown as a subtle live indicator.
  final bool replaying;

  /// Hard cap for this band; content scrolls beyond it.
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final hasVerdict = feedback.hasVerdict;
    final borderColor = feedback.verdict == CoachVerdict.correct
        ? AppColors.success
        : feedback.verdict == CoachVerdict.incorrect
            ? AppColors.danger
            : AppColors.slateDark;

    final optimal = feedback.optimalAction == null
        ? null
        : ChipFormat.optimalLine(
            actionLabel: feedback.optimalAction!.label,
            sizingBb: feedback.optimalSizingBb,
            bigBlind: bigBlind,
            mode: chipDisplayMode,
          );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        if (replaying) ...[
                          const SizedBox(width: 8),
                          Text(
                            'TABLE ACTING…',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback.message.isEmpty
                          ? 'Your move — pick Fold, Check/Call, or Bet/Raise.'
                          : feedback.message,
                      style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        height: 1.35,
                        color: AppColors.cream,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasVerdict && optimal != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Best: $optimal'
                          '${feedback.heroAction != null ? '  ·  You: ${feedback.heroAction}' : ''}'
                          '  ·  ${ChipFormat.evDelta(feedback.evDeltaBb, bigBlind, chipDisplayMode)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9.5,
                            height: 1.35,
                            color: AppColors.slate,
                          ),
                        ),
                      ),
                    if (feedback.voiceNote != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          feedback.voiceNote!,
                          style: GoogleFonts.manrope(
                            fontSize: 10.5,
                            color: AppColors.warning,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: ttsEnabled ? 'Mute coach' : 'Unmute coach',
              onPressed: onMuteToggle,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                ttsEnabled
                    ? Icons.volume_up_outlined
                    : Icons.volume_off_outlined,
                color: AppColors.slate,
                size: 20,
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: correct ? AppColors.success : AppColors.danger,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        correct ? 'CORRECT' : 'INCORRECT',
        style: GoogleFonts.jetBrainsMono(
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
          color: AppColors.bgDark,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
