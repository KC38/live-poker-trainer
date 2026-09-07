/// Center board cards, pot label, and street indicator.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';

/// Community cards + pot display for the felt center.
class CommunityCardsView extends StatelessWidget {
  /// Creates the community cards view.
  const CommunityCardsView({
    super.key,
    required this.community,
    required this.pot,
    required this.street,
    this.scale = 1,
  });

  final List<CardModel> community;
  final double pot;
  final Street street;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${street.label}  ·  \$${pot.toStringAsFixed(0)}',
          style: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w700,
            color: AppColors.goldBright.withValues(alpha: 0.9),
            fontSize: 12 * scale,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 10 * scale),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5 * scale),
                child: i < community.length
                    ? _BoardCard(card: community[i], scale: scale)
                    : _EmptySlot(scale: scale),
              ),
          ],
        ),
      ],
    );
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.card, required this.scale});

  final CardModel card;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38 * scale,
      height: 54 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Text(
        card.display,
        style: GoogleFonts.jetBrainsMono(
          fontWeight: FontWeight.w800,
          fontSize: 12 * scale,
          color: card.suit == Suit.spades ? AppColors.spades : card.suit.color,
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38 * scale,
      height: 54 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppColors.feltBorder.withValues(alpha: 0.35),
        ),
        color: Colors.black.withValues(alpha: 0.12),
      ),
    );
  }
}
