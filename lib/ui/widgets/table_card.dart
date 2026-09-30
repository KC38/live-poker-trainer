/// Playing card drawn on the felt: board, hero hole cards, and revealed hands.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';

/// Height of a table card for each unit of width.
const double tableCardAspect = 1.4;

/// Face-up card with a large corner index, readable at arm's length.
///
/// Rank and suit sit in the top 60% so a seat box may tuck the bottom of a
/// hole card behind it without hiding what the card is.
class TableCard extends StatelessWidget {
  /// Creates a card face [width] wide.
  const TableCard({super.key, required this.card, required this.width});

  final CardModel card;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color = card.suit.color;
    return Semantics(
      label: card.display,
      child: Container(
        width: width,
        height: width * tableCardAspect,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(width * 0.12),
          border: Border.all(
            color: AppColors.slateDark.withValues(alpha: 0.35),
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: ExcludeSemantics(
          child: Stack(
            children: [
              Positioned(
                left: width * 0.1,
                top: width * 0.06,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      card.rankLabel,
                      maxLines: 1,
                      style: GoogleFonts.manrope(
                        fontSize: width * 0.5,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      card.suit.symbol,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: width * 0.36,
                        height: 1,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: width * 0.08,
                bottom: width * 0.04,
                child: Text(
                  card.suit.symbol,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: width * 0.52,
                    height: 1,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Face-down card that matches [TableCard].
class TableCardBack extends StatelessWidget {
  /// Creates a card back [width] wide.
  const TableCardBack({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * tableCardAspect,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8C2233), Color(0xFF4A0F1B)],
        ),
        border: Border.all(
          color: AppColors.cream.withValues(alpha: 0.75),
          width: width < 30 ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width * 0.06),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

/// Outline where a board card will be dealt.
class TableCardSlot extends StatelessWidget {
  /// Creates an empty slot [width] wide.
  const TableCardSlot({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * tableCardAspect,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.12),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.4)),
        color: Colors.black.withValues(alpha: 0.12),
      ),
    );
  }
}
