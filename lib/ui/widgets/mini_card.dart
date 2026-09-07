/// Shared playing-card face used by seats, the hero rail, and the board.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';

/// Card footprints used across the table.
enum MiniCardSize {
  /// Villain hole cards revealed at showdown.
  tiny,

  /// Compact face for tight layouts.
  small,

  /// Hero hole cards on the hero rail.
  hero;

  /// Pixel footprint for this size.
  Size get dimensions => switch (this) {
        MiniCardSize.tiny => const Size(18, 26),
        MiniCardSize.small => const Size(26, 36),
        MiniCardSize.hero => const Size(44, 62),
      };

  /// Rank/suit text size for this footprint.
  double get fontSize => switch (this) {
        MiniCardSize.tiny => 8,
        MiniCardSize.small => 11,
        MiniCardSize.hero => 19,
      };
}

/// A single face-up card.
class MiniCard extends StatelessWidget {
  /// Creates a card face.
  const MiniCard({super.key, required this.card, this.size = MiniCardSize.small});

  final CardModel card;

  /// Footprint to render at.
  final MiniCardSize size;

  @override
  Widget build(BuildContext context) {
    final dims = size.dimensions;
    return Container(
      width: dims.width,
      height: dims.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(size == MiniCardSize.hero ? 7 : 4),
        border: Border.all(color: AppColors.slateDark.withValues(alpha: 0.35)),
        boxShadow: size == MiniCardSize.hero
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        card.display,
        maxLines: 1,
        style: GoogleFonts.jetBrainsMono(
          fontSize: size.fontSize,
          fontWeight: FontWeight.w800,
          color: card.suit == Suit.spades ? AppColors.spades : card.suit.color,
        ),
      ),
    );
  }
}
