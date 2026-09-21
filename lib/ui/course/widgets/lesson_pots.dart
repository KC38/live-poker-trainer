/// Felt visuals for How pots are won — fold-win, showdown, side pots.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Explain-step demo: three ways a pot is decided.
class WinningPathsDemo extends StatelessWidget {
  /// Creates the demo.
  const WinningPathsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.feltLight, AppColors.feltDark],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.feltBorder.withValues(alpha: 0.85),
          ),
        ),
        child: Column(
          children: [
            Text(
              'How a pot is won',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const _PathLane(
              step: 1,
              title: 'FOLD WIN',
              detail: 'Everyone folds — take it, no show',
              visual: _ChipStack(label: 'POT', amount: '9'),
            ),
            const SizedBox(height: 8),
            const _PathLane(
              step: 2,
              title: 'SHOWDOWN',
              detail: 'Call to the end — best five wins',
              visual: _ShowdownMini(),
            ),
            const SizedBox(height: 8),
            const _PathLane(
              step: 3,
              title: 'SIDE POT',
              detail: 'Short all-in — main vs unmatched chips',
              visual: _SidePotMini(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathLane extends StatelessWidget {
  const _PathLane({
    required this.step,
    required this.title,
    required this.detail,
    required this.visual,
  });

  final int step;
  final String title;
  final String detail;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.25),
              border: Border.all(color: AppColors.gold),
            ),
            child: Text(
              '$step',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          visual,
        ],
      ),
    );
  }
}

class _ChipStack extends StatelessWidget {
  const _ChipStack({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withValues(alpha: 0.35),
            border: Border.all(color: AppColors.gold, width: 2),
          ),
          child: Text(
            amount,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppColors.gold,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ShowdownMini extends StatelessWidget {
  const _ShowdownMini();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MiniCard(card: CardModel.fromCode('Ah'), size: MiniCardSize.tiny),
        const SizedBox(width: 2),
        MiniCard(card: CardModel.fromCode('Kd'), size: MiniCardSize.tiny),
        const SizedBox(width: 6),
        Text(
          'vs',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        MiniCard(card: CardModel.fromCode('Qs'), size: MiniCardSize.tiny),
        const SizedBox(width: 2),
        MiniCard(card: CardModel.fromCode('Jh'), size: MiniCardSize.tiny),
      ],
    );
  }
}

class _SidePotMini extends StatelessWidget {
  const _SidePotMini();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _miniPot(label: 'MAIN', color: AppColors.gold),
        const SizedBox(width: 6),
        _miniPot(label: 'SIDE', color: AppColors.slate),
      ],
    );
  }

  Widget _miniPot({required String label, required Color color}) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.3),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
