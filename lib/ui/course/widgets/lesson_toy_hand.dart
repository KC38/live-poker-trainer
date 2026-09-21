/// Felt visuals for Play a full toy hand — blinds → act → ending.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Explain-step demo: one short hand from blinds to a finish.
class ToyHandRunDemo extends StatelessWidget {
  /// Creates the demo.
  const ToyHandRunDemo({super.key});

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
              'One short hand',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const _RunLane(
              step: 1,
              title: 'BLINDS',
              detail: 'SB and BB post — pot starts',
              visual: _BlindDots(),
            ),
            const SizedBox(height: 8),
            const _RunLane(
              step: 2,
              title: 'YOU ACT',
              detail: 'Open, call, or fold on a street',
              visual: _HeroMini(),
            ),
            const SizedBox(height: 8),
            const _RunLane(
              step: 3,
              title: 'ENDING',
              detail: 'Folds win it — or keep going',
              visual: _PotEndChip(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunLane extends StatelessWidget {
  const _RunLane({
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
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.feltDark.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.22),
              border: Border.all(color: AppColors.gold, width: 1.4),
            ),
            child: Text(
              '$step',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  detail,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          visual,
        ],
      ),
    );
  }
}

class _BlindDots extends StatelessWidget {
  const _BlindDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _chip('1'),
        const SizedBox(width: 4),
        _chip('2'),
      ],
    );
  }

  Widget _chip(String amount) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold.withValues(alpha: 0.3),
        border: Border.all(color: AppColors.gold, width: 1.3),
      ),
      child: Text(
        amount,
        style: GoogleFonts.manrope(
          color: AppColors.gold,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeroMini extends StatelessWidget {
  const _HeroMini();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final code in const ['Ah', '9h']) ...[
          MiniCard(card: CardModel.fromCode(code), size: MiniCardSize.tiny),
          const SizedBox(width: 2),
        ],
      ],
    );
  }
}

class _PotEndChip extends StatelessWidget {
  const _PotEndChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.75)),
      ),
      child: Text(
        'POT',
        style: GoogleFonts.manrope(
          color: AppColors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
