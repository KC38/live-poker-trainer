/// Post-hand EV breakdown and scenario reveal modal.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';

/// Modal sheet summarizing practice EV audit.
class EvAuditModal extends StatelessWidget {
  /// Creates the EV audit modal.
  const EvAuditModal({
    super.key,
    required this.game,
    required this.feedback,
    required this.onClose,
    this.onNext,
  });

  final GameState game;
  final CoachFeedback feedback;
  final VoidCallback onClose;
  final VoidCallback? onNext;

  /// Shows the modal as a bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required GameState game,
    required CoachFeedback feedback,
    VoidCallback? onNext,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EvAuditModal(
        game: game,
        feedback: feedback,
        onClose: () => Navigator.pop(ctx),
        onNext: onNext,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenario = game.activeScenario;
    final correct = feedback.verdict == CoachVerdict.correct;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slateDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'EV Audit',
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          Text(
            feedback.message,
            style: GoogleFonts.inter(color: AppColors.cream, height: 1.4),
          ),
          if (scenario != null) ...[
            const SizedBox(height: 14),
            Text(
              scenario.name ?? 'Scenario',
              style: GoogleFonts.cinzel(
                color: AppColors.goldMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              scenario.theoreticalEvExplanation,
              style: GoogleFonts.inter(color: AppColors.slate, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Optimal: ${scenario.optimalExploitAction.label}'
              '${scenario.optimalSizingBb > 0 ? ' · ${scenario.optimalSizingBb.toStringAsFixed(1)} BB' : ''}',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.gold,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'EV Δ ${feedback.evDeltaBb >= 0 ? '+' : ''}${feedback.evDeltaBb.toStringAsFixed(2)} BB',
            style: GoogleFonts.jetBrainsMono(
              color: feedback.evDeltaBb >= 0
                  ? AppColors.success
                  : AppColors.danger,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
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
                    child: const Text('Next Spot'),
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
