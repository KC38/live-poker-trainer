/// Playing card drawn on the felt: board, hero hole cards, and revealed hands.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';

/// Height of a table card for each unit of width.
const double tableCardAspect = 1.4;

/// Face-up card with a corner rank and a large centered suit.
///
/// Rank stays in the top-left; a single suit glyph fills the face below
/// the rank (no second overlapping suit). Hole cards paint above their
/// seat box so nesting never hides the face.
class TableCard extends StatelessWidget {
  /// Creates a card face [width] wide.
  const TableCard({
    super.key,
    required this.card,
    required this.width,
    this.selected = false,
    this.highlighted = false,
    this.dimmed = false,
    this.orderBadge,
  });

  final CardModel card;
  final double width;

  /// Gold ring when the learner has tapped this card.
  final bool selected;

  /// Soft gold cue for the next card to tap.
  final bool highlighted;

  /// Fade leftover cards that do not play.
  final bool dimmed;

  /// Optional 1-based order badge drawn on a selected card.
  final int? orderBadge;

  @override
  Widget build(BuildContext context) {
    final color = card.suit.color;
    final radius = width * 0.12;
    final height = width * tableCardAspect;
    final borderColor = selected
        ? AppColors.gold
        : highlighted
        ? AppColors.gold.withValues(alpha: 0.75)
        : AppColors.slateDark.withValues(alpha: 0.35);
    final borderWidth = selected
        ? 2.2
        : highlighted
        ? 2.0
        : 0.6;
    // Leave clear air under the corner rank so the suit never overlaps it.
    final suitTop = width * 0.48;
    return Semantics(
      label: card.display,
      selected: selected,
      child: Opacity(
        opacity: dimmed && !selected ? 0.38 : 1,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
              if (selected || highlighted)
                BoxShadow(
                  color: AppColors.gold.withValues(
                    alpha: selected ? 0.45 : 0.28,
                  ),
                  blurRadius: selected ? 10 : 8,
                  spreadRadius: selected ? 1 : 0.5,
                ),
            ],
          ),
          child: ExcludeSemantics(
            child: Stack(
              children: [
                Positioned(
                  left: width * 0.1,
                  top: width * 0.06,
                  child: Text(
                    card.rankLabel,
                    maxLines: 1,
                    style: GoogleFonts.manrope(
                      fontSize: width * 0.46,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: suitTop,
                  bottom: width * 0.06,
                  child: Center(
                    child: Text(
                      card.suit.symbol,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.62,
                        height: 1,
                        color: color,
                      ),
                    ),
                  ),
                ),
                if (orderBadge != null)
                  Positioned(
                    right: width * 0.06,
                    top: width * 0.06,
                    child: Container(
                      width: width * 0.34,
                      height: width * 0.34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.bgDark,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$orderBadge',
                        style: GoogleFonts.manrope(
                          color: AppColors.bgDark,
                          fontSize: width * 0.2,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
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
