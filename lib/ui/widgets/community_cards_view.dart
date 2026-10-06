/// Felt center: pot, community cards, and the table's blinds.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/ui/widgets/dealt_card_reveal.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

/// Pot pill, five board slots, and `Blinds $1/$2 NLH`, top to bottom.
///
/// Sizes are fixed at [scale] 1 so the felt can size the board against the
/// seats without measuring text. Visibility is gated by [visibleCount] so the
/// felt deal controller can land each board card once, in order.
class CommunityCardsView extends StatelessWidget {
  /// Creates the felt center.
  const CommunityCardsView({
    super.key,
    required this.community,
    required this.pot,
    required this.street,
    required this.bigBlind,
    required this.chipDisplayMode,
    this.smallBlind = 0,
    this.scale = 1,
    this.awarding = false,
    this.isSplit = false,
    this.resultMessage,
    this.features = TableFeatures.full,
    this.visibleCount,
    this.onBoardCardTap,
    this.selectedBoardIndexes = const {},
    this.highlightBoardIndexes = const {},
    this.highlightBoardGroup = false,
    this.dimmedBoardIndexes = const {},
    this.boardOrderBadges = const {},
  });

  final List<CardModel> community;
  final double pot;
  final Street street;
  final double bigBlind;
  final double smallBlind;

  /// Table amounts are currency-only; see [ChipDisplayMode.tableMode].
  final ChipDisplayMode chipDisplayMode;
  final double scale;

  /// True while pot chips fly to the winner(s).
  final bool awarding;

  /// True when more than one seat shares the pot.
  final bool isSplit;

  /// Hand-end result line shown under the pot during the award beat.
  final String? resultMessage;

  /// Which of the pot, street, blinds, and empty slots to draw.
  final TableFeatures features;

  /// How many community cards to show. Null shows the full [community] list.
  final int? visibleCount;

  /// Tap on one dealt board card by index. Null leaves cards inert.
  final ValueChanged<int>? onBoardCardTap;

  /// Board indexes with a selected gold ring.
  final Set<int> selectedBoardIndexes;

  /// Board indexes SoftPulsed individually via [GlowHighlight].
  final Set<int> highlightBoardIndexes;

  /// SoftPulse the whole board card row as one [GlowHighlight].
  final bool highlightBoardGroup;

  /// Board indexes faded as leftovers.
  final Set<int> dimmedBoardIndexes;

  /// 1-based order badge drawn on a selected board card.
  final Map<int, int> boardOrderBadges;

  /// Board card width at scale 1.
  static const double cardWidth = 52;

  /// Gap between board cards at scale 1.
  static const double cardGap = 6;

  /// Card row width at scale 1.
  static const double naturalWidth = 5 * cardWidth + 4 * cardGap;

  /// Card row height at scale 1.
  static const double cardsHeight = cardWidth * tableCardAspect;

  /// Pot pill height plus its gap above the cards, at scale 1.
  static const double potBand = 24 + 8;

  /// Blinds line height plus its gap under the cards, at scale 1.
  static const double blindsBand = 6 + 15;

  /// Extra height the [resultMessage] line adds during the award beat.
  static const double resultMessageHeight = 4 + 14;

  /// Widest the pot pill or blinds line grows, at scale 1.
  static const double labelWidth = 190;

  /// Height above the card row at scale 1 for [features].
  static double bandAbove(TableFeatures features, {required bool awarding}) =>
      (features.pot || awarding ? potBand : 0) +
      (awarding ? resultMessageHeight : 0);

  /// Height below the card row at scale 1 for [features].
  static double bandBelow(TableFeatures features) =>
      features.blinds ? blindsBand : 0;

  /// Pot headline style at [scale].
  static TextStyle potStyle(double scale) => GoogleFonts.jetBrainsMono(
    fontWeight: FontWeight.w800,
    color: AppColors.goldBright,
    fontSize: 13 * scale,
    letterSpacing: 0.3,
  );

  /// Blinds line style at [scale].
  static TextStyle blindsStyle(double scale) => GoogleFonts.manrope(
    fontWeight: FontWeight.w700,
    color: AppColors.cream.withValues(alpha: 0.6),
    fontSize: 11.5 * scale,
    letterSpacing: 0.4,
  );

  /// Painted width of [text] in [style].
  static double labelWidthFor(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  /// `Blinds $1/$2 NLH`.
  static String blindsLabel(double smallBlind, double bigBlind) =>
      'Blinds ${ChipFormat.dollars(smallBlind)}/'
      '${ChipFormat.dollars(bigBlind)} NLH';

  @override
  Widget build(BuildContext context) {
    final potLabel = ChipFormat.chips(pot, bigBlind, chipDisplayMode);
    final headline =
        awarding
            ? (isSplit ? 'SPLIT  ·  $potLabel' : 'TAKES  ·  $potLabel')
            : features.street
            ? '${street.label}  ·  POT $potLabel'
            : 'POT $potLabel';
    final showPot = features.pot || awarding;
    final w = CommunityCardsView.cardWidth * scale;
    final slot = features.boardSlots
        ? TableCardSlot(width: w)
        : SizedBox(width: w);
    final shown = (visibleCount ?? community.length).clamp(0, community.length);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showPot) ...[
          SizedBox(
            height: 24 * scale,
            child: _PinnedToLabelWidth(
              scale: scale,
              child: AnimatedContainer(
                key: const ValueKey<String>('felt-pot'),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 3 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(
                    color: AppColors.gold.withValues(
                      alpha: awarding ? 0.8 : 0.4,
                    ),
                    width: awarding ? 1.2 : 0.8,
                  ),
                  boxShadow:
                      awarding
                          ? [
                            BoxShadow(
                              color: AppColors.goldBright.withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 10,
                            ),
                          ]
                          : null,
                ),
                child: Text(
                  headline,
                  maxLines: 1,
                  softWrap: false,
                  style: CommunityCardsView.potStyle(scale),
                ),
              ),
            ),
          ),
          SizedBox(height: 8 * scale),
        ],
        if (resultMessage case final message? when awarding) ...[
          SizedBox(
            height: 14 * scale,
            child: _PinnedToLabelWidth(
              scale: scale,
              child: Text(
                message,
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
          ),
          SizedBox(height: 4 * scale),
        ],
        GlowHighlight(
          active: highlightBoardGroup,
          reserveLayout: false,
          borderRadius: 10 * scale,
          padding: EdgeInsets.all(4 * scale),
          child: SizedBox(
            key: const ValueKey<String>('felt-board-row'),
            height: CommunityCardsView.cardsHeight * scale,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 5; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      left: i == 0 ? 0 : CommunityCardsView.cardGap * scale,
                    ),
                    child:
                        i < shown
                            ? _BoardCardTarget(
                              key: ValueKey(
                                'board-card-$i-${community[i].code}',
                              ),
                              index: i,
                              card: community[i],
                              width: w,
                              selected: selectedBoardIndexes.contains(i),
                              highlight:
                                  !highlightBoardGroup &&
                                  highlightBoardIndexes.contains(i),
                              dimmed: dimmedBoardIndexes.contains(i),
                              orderBadge: boardOrderBadges[i],
                              onTap: onBoardCardTap == null
                                  ? null
                                  : () => onBoardCardTap!(i),
                            )
                            : slot,
                  ),
              ],
            ),
          ),
        ),
        if (features.blinds) ...[
          SizedBox(height: 6 * scale),
          SizedBox(
            height: 15 * scale,
            child: _PinnedToLabelWidth(
              scale: scale,
              child: Text(
                CommunityCardsView.blindsLabel(smallBlind, bigBlind),
                key: const ValueKey<String>('felt-blinds'),
                maxLines: 1,
                softWrap: false,
                style: CommunityCardsView.blindsStyle(scale),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Centers [child] in [CommunityCardsView.labelWidth], scaling it down if wider.
class _PinnedToLabelWidth extends StatelessWidget {
  const _PinnedToLabelWidth({required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: CommunityCardsView.labelWidth * scale,
      child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: child)),
    );
  }
}

/// One tappable board card with an optional [GlowHighlight].
class _BoardCardTarget extends StatelessWidget {
  const _BoardCardTarget({
    super.key,
    required this.index,
    required this.card,
    required this.width,
    required this.selected,
    required this.highlight,
    required this.dimmed,
    required this.orderBadge,
    required this.onTap,
  });

  final int index;
  final CardModel card;
  final double width;
  final bool selected;
  final bool highlight;
  final bool dimmed;
  final int? orderBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardFace = GlowHighlight(
      active: highlight || selected,
      animated: highlight && !selected,
      reserveLayout: false,
      borderRadius: width * 0.12,
      child: DealtCardReveal(
        key: ValueKey<String>('dealt-board-$index'),
        // FeltDealController owns deal SFX + order.
        playSound: false,
        child: TableCard(
          card: card,
          width: width,
          dimmed: dimmed,
          orderBadge: orderBadge,
        ),
      ),
    );
    if (onTap == null) return cardFace;
    return Semantics(
      button: true,
      label: card.display,
      selected: selected,
      child: GestureDetector(
        key: ValueKey<String>('lesson-board-card-$index'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: cardFace,
      ),
    );
  }
}
