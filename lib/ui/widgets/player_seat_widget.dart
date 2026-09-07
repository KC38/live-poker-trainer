/// Villain seat HUD — archetype-first so exploits are readable at nine seats.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Fixed seat footprints so the felt can guarantee seats never overflow their
/// band and cover the hero rail or coach shelf.
class SeatMetrics {
  const SeatMetrics._();

  /// Seat box at 7–9 seats or on a narrow phone.
  static const Size compact = Size(78, 84);

  /// Seat box at 2–6 seats.
  static const Size regular = Size(96, 96);

  /// Box for [compactLayout].
  static Size of({required bool compactLayout}) =>
      compactLayout ? compact : regular;
}

/// Seat node for 2–9 player layouts.
///
/// The archetype word is the primary label because the player has to pick an
/// exploit from it; the villain's name is secondary.
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
    this.compact = false,
    this.showCards = false,
  });

  final PlayerModel player;
  final double bigBlind;
  final ChipDisplayMode chipDisplayMode;
  final bool isActive;
  final bool isDealer;
  final bool isSmallBlind;
  final bool isBigBlind;
  final bool compact;
  final bool showCards;

  @override
  Widget build(BuildContext context) {
    final size = SeatMetrics.of(compactLayout: compact);
    final archetype = player.archetype;
    final accent = archetype.color;
    final dim = player.folded;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Opacity(
        opacity: dim ? 0.38 : 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _ArchetypeCard(
                  player: player,
                  accent: accent,
                  isActive: isActive,
                  compact: compact,
                ),
                if (isDealer)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: _Puck(label: 'D', color: AppColors.cream),
                  ),
                if (isSmallBlind)
                  Positioned(
                    left: -6,
                    bottom: -6,
                    child: _Puck(label: 'SB', color: AppColors.goldMuted),
                  ),
                if (isBigBlind)
                  Positioned(
                    right: -6,
                    bottom: -6,
                    child: _Puck(label: 'BB', color: AppColors.goldBright),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              ChipFormat.chips(player.stack, bigBlind, chipDisplayMode),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w700,
                color: AppColors.goldMuted,
              ),
            ),
            if (showCards && player.holeCards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final card in player.holeCards)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: MiniCard(card: card, size: MiniCardSize.tiny),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Archetype pill: colored ring, archetype word, name, and VPIP/PFR.
class _ArchetypeCard extends StatelessWidget {
  const _ArchetypeCard({
    required this.player,
    required this.accent,
    required this.isActive,
    required this.compact,
  });

  final PlayerModel player;
  final Color accent;
  final bool isActive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final archetype = player.archetype;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? AppColors.goldBright : accent.withValues(alpha: 0.9),
          width: isActive ? 2 : 1.2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.goldBright.withValues(alpha: 0.28),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              archetype.shortLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: GoogleFonts.jetBrainsMono(
                fontSize: compact ? 8.5 : 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: AppColors.bgDark,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: compact ? 9.5 : 11,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            ),
          ),
          if (!player.isHero)
            Text(
              '${player.vpip.toStringAsFixed(0)}/${player.pfr.toStringAsFixed(0)}',
              maxLines: 1,
              style: GoogleFonts.jetBrainsMono(
                fontSize: compact ? 7.5 : 8.5,
                fontWeight: FontWeight.w600,
                color: AppColors.slate,
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
      width: wide ? 20 : 15,
      height: 15,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(wide ? 7 : 15),
        border: Border.all(color: AppColors.bgDark.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: wide ? 7.5 : 8.5,
          fontWeight: FontWeight.w800,
          color: AppColors.bgDark,
        ),
      ),
    );
  }
}

/// Card back used for villains who still hold live cards.
class CardBack extends StatelessWidget {
  /// Creates a card back.
  const CardBack({super.key, this.size = MiniCardSize.tiny});

  /// Footprint matching [MiniCard].
  final MiniCardSize size;

  @override
  Widget build(BuildContext context) {
    final dims = size.dimensions;
    return Container(
      width: dims.width,
      height: dims.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C1D2B), Color(0xFF4A0F1B)],
        ),
        border: Border.all(color: AppColors.cream.withValues(alpha: 0.5)),
      ),
    );
  }
}
