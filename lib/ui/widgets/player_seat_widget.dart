/// Compact player seat / Micro-HUD for the elliptical table.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
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
    required this.chipDisplayMode,
    required this.isActive,
    required this.isDealer,
    this.isSmallBlind = false,
    this.isBigBlind = false,
    this.micro = false,
    this.showCards = false,
  });

  final PlayerModel player;
  final double bigBlind;
  final ChipDisplayMode chipDisplayMode;
  final bool isActive;
  final bool isDealer;
  final bool isSmallBlind;
  final bool isBigBlind;
  final bool micro;
  final bool showCards;

  @override
  Widget build(BuildContext context) {
    final opacity = player.folded ? 0.32 : 1.0;
    final stackLabel = ChipFormat.chips(
      player.stack,
      bigBlind,
      chipDisplayMode,
      bbDecimals: 0,
    );

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
                  child: _Puck(label: 'D', color: AppColors.cream),
                ),
              if (isSmallBlind)
                Positioned(
                  left: -4,
                  bottom: -2,
                  child: _Puck(label: 'SB', color: AppColors.goldMuted),
                ),
              if (isBigBlind)
                Positioned(
                  right: -4,
                  bottom: -2,
                  child: _Puck(label: 'BB', color: AppColors.goldBright),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            micro ? player.archetype.badge : player.name,
            style: GoogleFonts.manrope(
              fontSize: micro ? 9 : 11,
              fontWeight: FontWeight.w600,
              color: AppColors.slate,
            ),
          ),
          if (!micro && !player.isHero)
            Text(
              'V${player.vpip.toStringAsFixed(0)}/P${player.pfr.toStringAsFixed(0)}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: AppColors.slate.withValues(alpha: 0.85),
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
                ChipFormat.chips(
                  player.currentBet,
                  bigBlind,
                  chipDisplayMode,
                  bbDecimals: 1,
                ),
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

class _Puck extends StatelessWidget {
  const _Puck({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final wide = label.length > 1;
    return Container(
      width: wide ? 22 : 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(wide ? 8 : 16),
        border: Border.all(color: AppColors.bgDark.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: wide ? 8 : 9,
          fontWeight: FontWeight.w800,
          color: AppColors.bgDark,
        ),
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
