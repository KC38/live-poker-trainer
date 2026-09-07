/// Post-hand EV breakdown and coaching reveal modal.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';

/// Modal sheet summarizing hand-end EV audit.
class EvAuditModal extends StatelessWidget {
  /// Creates the EV audit modal.
  const EvAuditModal({
    super.key,
    required this.game,
    required this.feedback,
    required this.chipDisplayMode,
    required this.onClose,
    this.onNext,
  });

  final GameState game;
  final CoachFeedback feedback;
  final ChipDisplayMode chipDisplayMode;
  final VoidCallback onClose;
  final VoidCallback? onNext;

  /// Shows the modal as a bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required GameState game,
    required CoachFeedback feedback,
    required ChipDisplayMode chipDisplayMode,
    VoidCallback? onNext,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => EvAuditModal(
        game: game,
        feedback: feedback,
        chipDisplayMode: chipDisplayMode,
        onClose: () => Navigator.pop(ctx),
        onNext: onNext,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final correct = feedback.verdict == CoachVerdict.correct;
    final optimalLabel = feedback.optimalAction == null
        ? null
        : ChipFormat.optimalLine(
            actionLabel: feedback.optimalAction!.label,
            sizingBb: feedback.optimalSizingBb,
            bigBlind: game.bigBlind,
            mode: chipDisplayMode,
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slateDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Hand review',
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.goldBright,
            ),
          ),
          const SizedBox(height: 14),
          if (feedback.hasVerdict)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: correct ? AppColors.success : AppColors.danger,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                correct ? 'CORRECT' : 'INCORRECT',
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.w800,
                  color: AppColors.bgDark,
                ),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            feedback.message,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              height: 1.45,
              fontSize: 15,
            ),
          ),
          if (optimalLabel != null) ...[
            const SizedBox(height: 16),
            Text(
              'Optimal: $optimalLabel',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.gold,
                fontSize: 12,
              ),
            ),
          ],
          if (feedback.heroAction != null) ...[
            const SizedBox(height: 8),
            Text(
              'You: ${feedback.heroAction}',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.slate,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            ChipFormat.evDelta(
              feedback.evDeltaBb,
              game.bigBlind,
              chipDisplayMode,
            ),
            style: GoogleFonts.jetBrainsMono(
              color: feedback.evDeltaBb >= 0
                  ? AppColors.success
                  : AppColors.danger,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClose,
                  child: const Text('Close'),
                ),
              ),
              if (onNext != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onClose();
                      onNext!();
                    },
                    child: const Text('Next hand'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
