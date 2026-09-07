/// Compact player seat / Micro-HUD for the elliptical table.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Seat node for 2–9 player layouts.
class PlayerSeatWidget extends StatelessWidget {
  /// Creates a seat widget.
  const PlayerSeatWidget({
    super.key,
    required this.player,
    required this.bigBlind,
    required this.isActive,
    required this.isDealer,
    this.micro = false,
    this.showCards = false,
  });

  final PlayerModel player;
  final double bigBlind;
  final bool isActive;
  final bool isDealer;
  final bool micro;
  final bool showCards;

  @override
  Widget build(BuildContext context) {
    final opacity = player.folded ? 0.3 : 1.0;
    final stackBb = bigBlind <= 0 ? 0 : player.stack / bigBlind;
    final stackLabel = micro
        ? '${stackBb.toStringAsFixed(0)} BB'
        : '\$${player.stack.toStringAsFixed(0)} · ${stackBb.toStringAsFixed(0)} BB';

    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: micro ? 44 : 56,
                height: micro ? 44 : 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgMid,
                  border: Border.all(
                    color: isActive ? AppColors.gold : player.archetype.color,
                    width: isActive ? 3 : 2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.45),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    player.isHero ? 'H' : player.archetype.badge,
                    style: GoogleFonts.cinzel(
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                      fontSize: micro ? 12 : 14,
                    ),
                  ),
                ),
              ),
              if (isDealer)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'D',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.bgDark,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (!micro)
            Text(
              player.name,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.slate,
              ),
            ),
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.slateDark),
            ),
            child: Text(
              stackLabel,
              style: GoogleFonts.jetBrainsMono(
                fontSize: micro ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ),
          if (player.currentBet > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Bet \$${player.currentBet.toStringAsFixed(0)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: AppColors.cream,
                ),
              ),
            ),
          if (showCards && player.holeCards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final card in player.holeCards)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: _MiniCard(card: card, large: player.isHero),
                    ),
                ],
              ),
            ),
          if (player.lastActionLabel != null)
            Text(
              player.lastActionLabel!,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.card, this.large = false});

  final CardModel card;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final w = large ? 34.0 : 22.0;
    final h = large ? 48.0 : 32.0;
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.slateDark),
      ),
      child: Text(
        card.display,
        style: GoogleFonts.jetBrainsMono(
          fontSize: large ? 12 : 9,
          fontWeight: FontWeight.w800,
          color: card.suit == Suit.spades ? AppColors.spades : card.suit.color,
        ),
      ),
    );
  }
}
