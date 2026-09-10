/// Center board cards, pot label, and street indicator.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
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
    required this.bigBlind,
    required this.chipDisplayMode,
    this.scale = 1,
    this.awarding = false,
    this.isSplit = false,
    this.resultMessage,
  });

  final List<CardModel> community;
  final double pot;
  final Street street;
  final double bigBlind;

  /// Table amounts are currency-only; see [ChipDisplayMode.tableMode].
  final ChipDisplayMode chipDisplayMode;
  final double scale;

  /// True while pot chips fly to the winner(s).
  final bool awarding;

  /// True when more than one seat shares the pot.
  final bool isSplit;

  /// Hand-end result line shown briefly above the board during the award beat.
  final String? resultMessage;

  /// Width of the board column at [scale] 1: five slots of 38 plus 5 of gap.
  ///
  /// The pot pill and result line are pinned to this width so the felt can
  /// reason about the board's footprint without measuring text — a long
  /// headline shrinks to fit instead of widening the column into the seats.
  static const double naturalWidth = 5 * 43.0;

  /// Height of the board column at [scale] 1, excluding [resultMessage].
  static const double naturalHeight = 18 + 10 + 54;

  /// Extra height the [resultMessage] line adds during the award beat.
  static const double resultMessageHeight = 4 + 11;

  @override
  Widget build(BuildContext context) {
    final potLabel = ChipFormat.chips(pot, bigBlind, chipDisplayMode);
    final headline = awarding
        ? (isSplit ? 'SPLIT  ·  $potLabel' : 'TAKES  ·  $potLabel')
        : '${street.label}  ·  $potLabel';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dark pill so street · pot stays readable even when a bet chip
        // paints nearby — thin gold text alone disappears over dark chips.
        _PinnedToBoardWidth(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: 8 * scale,
              vertical: 3 * scale,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(8 * scale),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: awarding ? 0.75 : 0.35),
                width: awarding ? 1.2 : 0.8,
              ),
              boxShadow: awarding
                  ? [
                      BoxShadow(
                        color: AppColors.goldBright.withValues(alpha: 0.28),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              headline,
              maxLines: 1,
              softWrap: false,
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.w700,
                color: AppColors.goldBright.withValues(alpha: 0.95),
                fontSize: (awarding ? 13 : 12) * scale,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        if (resultMessage != null && awarding) ...[
          SizedBox(height: 4 * scale),
          _PinnedToBoardWidth(
            scale: scale,
            child: Text(
              resultMessage!,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: AppColors.cream.withValues(alpha: 0.92),
                fontSize: 11 * scale,
              ),
            ),
          ),
        ],
        SizedBox(height: 10 * scale),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5 * scale),
                child: i < community.length
                    ? _RevealedCard(
                        // Keying on the card makes each newly dealt street
                        // card animate in on its own, in order.
                        key: ValueKey(community[i].code),
                        card: community[i],
                        scale: scale,
                      )
                    : _EmptySlot(scale: scale),
              ),
          ],
        ),
      ],
    );
  }
}

/// Centers [child] in exactly one board-width, scaling it down if it is wider.
class _PinnedToBoardWidth extends StatelessWidget {
  const _PinnedToBoardWidth({required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: CommunityCardsView.naturalWidth * scale,
      child: Center(
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      ),
    );
  }
}

/// A board card that flips/scales in when it is first dealt.
class _RevealedCard extends StatefulWidget {
  const _RevealedCard({super.key, required this.card, required this.scale});

  final CardModel card;
  final double scale;

  @override
  State<_RevealedCard> createState() => _RevealedCardState();
}

class _RevealedCardState extends State<_RevealedCard> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _progress = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: _progress,
      child: AnimatedScale(
        scale: 0.82 + 0.18 * _progress,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        child: _BoardCard(card: widget.card, scale: widget.scale),
      ),
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
