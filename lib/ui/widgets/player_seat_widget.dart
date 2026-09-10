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
///
/// The box reserves room for the committed-chips pill whether or not the
/// villain has bet, so seat geometry — and therefore every collision check on
/// the felt — is identical on all streets.
class SeatMetrics {
  const SeatMetrics._();

  /// Seat box at 7–9 seats or on a narrow phone.
  static const Size compact = Size(78, 100);

  /// Seat box at 2–6 seats.
  static const Size regular = Size(96, 114);

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
    this.isWinner = false,
    this.compact = false,
    this.showCards = false,
    this.betLabel,
    this.size,
  });

  final PlayerModel player;
  final double bigBlind;
  final ChipDisplayMode chipDisplayMode;
  final bool isActive;
  final bool isDealer;
  final bool isSmallBlind;
  final bool isBigBlind;
  final bool isWinner;
  final bool compact;
  final bool showCards;

  /// Chips this villain has committed on the current street, if any.
  ///
  /// Docked to the seat rather than floated toward the pot: on a phone there
  /// is no lane between a side seat and the board wide enough for a pill, so a
  /// floating chip inevitably lands on somebody's archetype tag or the board.
  final String? betLabel;

  /// Footprint to render into, defaulting to [SeatMetrics.of].
  ///
  /// The felt shrinks this below the natural box on crowded tables; the HUD
  /// scales its contents down to match rather than spilling onto a neighbour.
  final Size? size;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? SeatMetrics.of(compactLayout: compact);
    final archetype = player.archetype;
    final accent = archetype.color;
    final dim = player.folded;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Opacity(
        opacity: dim ? 0.38 : 1,
        // A revealed showdown hand adds a card row to an already full seat,
        // which overflowed the fixed footprint. Scaling down keeps the seat
        // inside its band instead of bleeding into the hero rail.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          // FittedBox hands its child unbounded width, so pin the seat to its
          // own footprint and let only the overflowing height be scaled.
          child: SizedBox(
            width: size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _ArchetypeCard(
                      player: player,
                      accent: accent,
                      isActive: isActive,
                      isWinner: isWinner,
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
                SizedBox(height: betLabel == null ? 0 : 3),
                if (betLabel != null)
                  // A four-figure bet is wider than a nine-handed seat; shrink
                  // the pill rather than truncate the amount or overflow onto
                  // the neighbour.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _BetPill(label: betLabel!, compact: compact),
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
                            child: MiniCard(
                              card: card,
                              size: MiniCardSize.tiny,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Committed chips for the current street, docked under the seat's stack.
class _BetPill extends StatelessWidget {
  const _BetPill({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.85),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: GoogleFonts.jetBrainsMono(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w800,
              color: AppColors.cream,
            ),
          ),
        ],
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
    required this.isWinner,
    required this.compact,
  });

  final PlayerModel player;
  final Color accent;
  final bool isActive;
  final bool isWinner;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final archetype = player.archetype;
    final highlight = isWinner || isActive;
    final ring = isWinner
        ? AppColors.goldBright
        : isActive
            ? AppColors.goldBright
            : accent.withValues(alpha: 0.9);
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
          color: ring,
          width: highlight ? 2 : 1.2,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: AppColors.goldBright.withValues(
                    alpha: isWinner ? 0.42 : 0.28,
                  ),
                  blurRadius: isWinner ? 14 : 10,
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
