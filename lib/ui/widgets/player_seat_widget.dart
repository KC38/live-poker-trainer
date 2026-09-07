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
    final opacity = player.folded ? 0.32 : 1.0;
    final stackBb = bigBlind <= 0 ? 0 : player.stack / bigBlind;
    final stackLabel = micro
        ? '${stackBb.toStringAsFixed(0)} BB'
        : '\$${player.stack.toStringAsFixed(0)}';

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
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: micro ? 42 : 52,
                height: micro ? 42 : 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgElevated,
                  border: Border.all(
                    color: isActive ? AppColors.goldBright : player.archetype.color,
                    width: isActive ? 2.5 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    player.isHero ? 'H' : player.archetype.badge,
                    style: GoogleFonts.cinzel(
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                      fontSize: micro ? 11 : 13,
                    ),
                  ),
                ),
              ),
              if (isDealer)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'D',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
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
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.slate,
              ),
            ),
          Text(
            stackLabel,
            style: GoogleFonts.jetBrainsMono(
              fontSize: micro ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: AppColors.goldMuted,
            ),
          ),
          if (player.currentBet > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '\$${player.currentBet.toStringAsFixed(0)}',
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
              style: GoogleFonts.manrope(
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
    final w = large ? 32.0 : 20.0;
    final h = large ? 44.0 : 30.0;
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.slateDark.withValues(alpha: 0.35)),
      ),
      child: Text(
        card.display,
        style: GoogleFonts.jetBrainsMono(
          fontSize: large ? 11 : 8,
          fontWeight: FontWeight.w800,
          color: card.suit == Suit.spades ? AppColors.spades : card.suit.color,
        ),
      ),
    );
  }
}
