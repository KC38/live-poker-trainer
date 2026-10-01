/// Seat on the felt: hole cards above one box with the icon, name, and stack.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/cue_arrows.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

/// Seat geometry: the box, the hole cards above it, and the seat footprint.
///
/// The footprint reserves the face-up card height for every seat, so the
/// ring does not move when a hand is revealed.
@immutable
class SeatMetrics {
  const SeatMetrics._({
    required this.pod,
    required this.cardWidth,
    required this.cardTuck,
    required this.cardGap,
    required this.scale,
  });

  /// Metrics for the hero or a villain seat.
  ///
  /// [compact] is the seven-to-nine seat size. [stats] adds a line to the
  /// box for VPIP/PFR. [review] enlarges the hero's cards once the hand is
  /// over. [scale] multiplies everything.
  factory SeatMetrics.of({
    required bool hero,
    bool compact = false,
    bool stats = false,
    bool review = false,
    double scale = 1,
  }) {
    final base =
        hero
            ? (compact ? const Size(124, 44) : const Size(140, 48))
            : (compact ? const Size(92, 40) : const Size(108, 44));
    final extra = stats && !hero ? 11.0 : 0.0;
    return SeatMetrics._(
      pod: Size(base.width * scale, (base.height + extra) * scale),
      cardWidth:
          (hero ? (compact ? 52.0 : 58.0) : (compact ? 26.0 : 30.0)) *
          (hero && review ? _reviewGrowth : 1) *
          scale,
      // No tuck — hole cards and the name box must not cover each other.
      cardTuck: 0,
      cardGap: (hero ? 4.0 : 2.0) * scale,
      scale: scale,
    );
  }

  /// Hero card growth while a finished hand is reviewed.
  static const double _reviewGrowth = 1.12;

  /// Clear air between the hole-card bottoms and the seat-box top.
  static const double cardBoxGap = 2;

  /// The seat box.
  final Size pod;

  /// Face-up hole card width.
  final double cardWidth;

  /// Share of a hole card's height that may sit over the box (always zero).
  final double cardTuck;

  /// Gap between the two hole cards.
  final double cardGap;

  /// Multiplier the felt applied.
  final double scale;

  /// Face-down cards are smaller than faces on villain seats.
  double backWidth({required bool hero}) => hero ? cardWidth : cardWidth * 0.74;

  /// Face-up hole card height.
  double get cardHeight => cardWidth * tableCardAspect;

  /// Pixels of a face-up card that may sit over the box (always zero).
  double get tuck => cardHeight * cardTuck;

  /// Vertical space reserved above the box for hole cards (+ gap).
  double get cardsAbove => cardHeight - tuck + cardBoxGap * scale;

  /// Width of a face-up pair.
  double get cardsWidth => cardWidth * 2 + cardGap;

  /// Box plus cards.
  Size get footprint =>
      Size(math.max(pod.width, cardsWidth), pod.height + cardsAbove);

  /// Where the box sits inside a footprint drawn at [footprint].
  Rect podIn(Rect footprint) => Rect.fromLTWH(
    footprint.center.dx - pod.width / 2,
    footprint.bottom - pod.height,
    pod.width,
    pod.height,
  );
}

/// One seat: hole cards fully above a box with the icon, name, and stack.
///
/// Pucks, bets, and action badges are placed by the felt around [SeatMetrics.podIn].
class PlayerSeatWidget extends StatelessWidget {
  /// Creates a seat.
  const PlayerSeatWidget({
    super.key,
    required this.player,
    required this.bigBlind,
    required this.chipDisplayMode,
    required this.isActive,
    this.isWinner = false,
    this.compact = false,
    this.showCards = false,
    this.revealHoleCards = false,
    this.showHoleBacks = false,
    this.isWaitingOnLlm = false,
    this.features = TableFeatures.full,
    this.scale = 1,
    this.review = false,
    this.onHeroCardTap,
    this.selectedHeroIndexes = const {},
    this.highlightHeroIndexes = const {},
    this.dimmedHeroIndexes = const {},
  });

  final PlayerModel player;
  final double bigBlind;
  final ChipDisplayMode chipDisplayMode;
  final bool isActive;
  final bool isWinner;
  final bool compact;

  /// Showdown: draw this seat's cards face up.
  final bool showCards;

  /// Draw this seat's hole cards face up even before showdown.
  final bool revealHoleCards;

  /// Two card backs when the faces stay hidden.
  final bool showHoleBacks;

  /// True while the server is waiting on this seat's LLM decision.
  final bool isWaitingOnLlm;

  /// Which optional layers to draw.
  final TableFeatures features;

  /// Multiplier on [SeatMetrics].
  final double scale;

  /// The hand is over; the hero's cards grow.
  final bool review;

  /// Tap one hero hole card by index (0 or 1).
  final ValueChanged<int>? onHeroCardTap;

  /// Hero hole indexes with a selected gold ring.
  final Set<int> selectedHeroIndexes;

  /// Hero hole indexes that cue the next tap.
  final Set<int> highlightHeroIndexes;

  /// Hero hole indexes faded as leftovers.
  final Set<int> dimmedHeroIndexes;

  /// Geometry this seat draws with.
  SeatMetrics get metrics => SeatMetrics.of(
    hero: player.isHero,
    compact: compact,
    stats: features.stats,
    review: review,
    scale: scale,
  );

  bool get _typed => features.playerTypes && !player.isHero;

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    final size = m.footprint;
    final faces = (showCards || revealHoleCards) && player.holeCards.isNotEmpty;
    final cards =
        faces
            ? _faceCards(m)
            : showHoleBacks
            ? _backCards(m)
            : null;
    final pod = m.podIn(Offset.zero & size);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Opacity(
        opacity: player.folded ? 0.4 : 1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (cards != null)
              Positioned(
                key: ValueKey<String>('seat-cards-layer-${player.id}'),
                left: 0,
                right: 0,
                bottom: pod.height + SeatMetrics.cardBoxGap * scale - m.tuck,
                child: Align(alignment: Alignment.bottomCenter, child: cards),
              ),
            Positioned.fromRect(
              key: ValueKey<String>('seat-box-layer-${player.id}'),
              rect: pod,
              child: _box(m),
            ),
            if (_typed)
              Positioned(
                // Keep the type tag on the box face so it never covers cards.
                left: pod.left + 4 * scale,
                top: pod.top + 2 * scale,
                child: _TypeTag(archetype: player.archetype, scale: scale),
              ),
          ],
        ),
      ),
    );
  }

  Widget _faceCards(SeatMetrics m) => Row(
    key: ValueKey<String>('seat-faces-${player.id}'),
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < player.holeCards.length && i < 2; i++) ...[
        if (i > 0) SizedBox(width: m.cardGap),
        if (player.isHero && onHeroCardTap != null)
          GestureDetector(
            key: ValueKey<String>('lesson-hero-card-$i'),
            behavior: HitTestBehavior.opaque,
            onTap: () => onHeroCardTap!(i),
            child: Semantics(
              button: true,
              selected: selectedHeroIndexes.contains(i),
              label: player.holeCards[i].display,
              child: _cuedCard(m, i),
            ),
          )
        else
          _cuedCard(m, i),
      ],
    ],
  );

  Widget _cuedCard(SeatMetrics m, int i) {
    final selected = selectedHeroIndexes.contains(i);
    final highlighted = highlightHeroIndexes.contains(i);
    return CuePulse(
      active: highlighted && !selected,
      borderRadius: m.cardWidth * 0.12,
      child: TableCard(
        card: player.holeCards[i],
        width: m.cardWidth,
        selected: selected,
        highlighted: highlighted,
        dimmed: dimmedHeroIndexes.contains(i),
      ),
    );
  }

  Widget _backCards(SeatMetrics m) {
    final width = m.backWidth(hero: player.isHero);
    return Row(
      key: ValueKey<String>('seat-backs-${player.id}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        TableCardBack(width: width),
        SizedBox(width: m.cardGap),
        TableCardBack(width: width),
      ],
    );
  }

  Widget _box(SeatMetrics m) {
    final s = scale;
    final iconColor =
        player.isHero
            ? AppColors.hero
            : features.playerTypes
            ? player.archetype.color
            : AppColors.slate;
    final highlight = isWinner || isActive || isWaitingOnLlm;
    final ring =
        isWinner
            ? AppColors.goldBright
            : isWaitingOnLlm
            ? AppColors.warning
            : isActive
            ? AppColors.goldBright
            : AppColors.slateDark;
    final iconSize = math.min(m.pod.height - 12 * s, 34 * s);
    return AnimatedContainer(
      key: ValueKey<String>('seat-box-${player.id}'),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(5 * s, 4 * s, 8 * s, 4 * s),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: ring, width: highlight ? 2 : 1.2),
        boxShadow: [
          BoxShadow(
            color:
                highlight
                    ? (isWaitingOnLlm
                            ? AppColors.warning
                            : AppColors.goldBright)
                        .withValues(alpha: isWinner ? 0.45 : 0.3)
                    : Colors.black.withValues(alpha: 0.35),
            blurRadius: highlight ? 12 : 6,
            offset: highlight ? Offset.zero : const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _SeatIcon(color: iconColor, size: iconSize),
          SizedBox(width: 6 * s),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: (compact ? 10 : 11) * s,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cream.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                    if (isWaitingOnLlm) ...[
                      SizedBox(width: 3 * s),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _SeatWaitTimer(compact: compact),
                        ),
                      ),
                    ],
                  ],
                ),
                if (features.stacks)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ChipFormat.chips(player.stack, bigBlind, chipDisplayMode),
                      key: ValueKey<String>('seat-stack-${player.id}'),
                      maxLines: 1,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: (compact ? 13 : 15) * s,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cream,
                      ),
                    ),
                  ),
                if (features.stats && !player.isHero)
                  Text(
                    '${player.vpip.toStringAsFixed(0)}/'
                    '${player.pfr.toStringAsFixed(0)}',
                    maxLines: 1,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: (compact ? 8 : 8.5) * s,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic player icon in a ring colored by player type.
class _SeatIcon extends StatelessWidget {
  const _SeatIcon({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 1.6),
      ),
      child: Icon(Icons.person_rounded, size: size * 0.72, color: color),
    );
  }
}

/// Player-type word on the seat box's top edge.
class _TypeTag extends StatelessWidget {
  const _TypeTag({required this.archetype, required this.scale});

  final PlayerArchetype archetype;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 1),
      decoration: BoxDecoration(
        color: archetype.color,
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Text(
        archetype.shortLabel,
        maxLines: 1,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 8 * scale,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: AppColors.bgDark,
        ),
      ),
    );
  }
}

/// Dealer, small-blind, or big-blind puck on a seat's felt lane.
class SeatPuck extends StatefulWidget {
  /// Creates a puck reading [label] (`D`, `SB`, or `BB`).
  const SeatPuck({super.key, required this.label, this.scale = 1});

  final String label;
  final double scale;

  /// Diameter at scale 1.
  static const double diameter = 18;

  @override
  State<SeatPuck> createState() => _SeatPuckState();
}

class _SeatPuckState extends State<SeatPuck> {
  double _pop = 0.7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _pop = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final scale = widget.scale;
    final color = switch (label) {
      'D' => AppColors.cream,
      'SB' => AppColors.goldMuted,
      _ => AppColors.goldBright,
    };
    final d = SeatPuck.diameter * scale;
    return AnimatedScale(
      scale: _pop,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Container(
        key: ValueKey<String>('puck-$label'),
        width: d,
        height: d,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.bgDark.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: (label.length > 1 ? 7.5 : 9.5) * scale,
            fontWeight: FontWeight.w800,
            color: AppColors.bgDark,
          ),
        ),
      ),
    );
  }
}

/// Committed chips for the current street.
class StreetBetPill extends StatefulWidget {
  /// Creates a street-commitment chip pill.
  const StreetBetPill({super.key, required this.label, this.compact = false});

  /// Amount text style.
  static TextStyle textStyle({required bool compact}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: compact ? 10 : 11,
        fontWeight: FontWeight.w800,
        color: AppColors.cream,
      );

  /// Pill size for [label], measured the way it paints.
  static Size sizeFor(String label, {required bool compact}) {
    final text = TextPainter(
      text: TextSpan(text: label, style: textStyle(compact: compact)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final pad = compact ? 5.0 : 7.0;
    return Size(text.width + pad * 2 + 8 + 4 + 2, math.max(text.height, 8) + 6);
  }

  /// Formatted chip amount for the current street.
  final String label;

  /// Tighter padding and type for nine-handed seats.
  final bool compact;

  @override
  State<StreetBetPill> createState() => _StreetBetPillState();
}

class _StreetBetPillState extends State<StreetBetPill> {
  double _pop = 0.55;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _pop = 1;
          _opacity = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: _pop,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 5 : 7,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.85),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.danger,
                    border: Border.all(color: AppColors.cream, width: 1.2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.label,
                  maxLines: 1,
                  softWrap: false,
                  style: StreetBetPill.textStyle(compact: compact),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Elapsed wait while an LLM decides for this seat.
class _SeatWaitTimer extends StatefulWidget {
  const _SeatWaitTimer({required this.compact});

  final bool compact;

  @override
  State<_SeatWaitTimer> createState() => _SeatWaitTimerState();
}

class _SeatWaitTimerState extends State<_SeatWaitTimer> {
  late final Stopwatch _watch;
  Timer? _ticker;
  int _tenths = 0;

  @override
  void initState() {
    super.initState();
    _watch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() => _tenths = _watch.elapsedMilliseconds ~/ 100);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _tenths / 10;
    final label =
        seconds < 10 ? seconds.toStringAsFixed(1) : seconds.toStringAsFixed(0);
    return Text(
      '${label}s',
      maxLines: 1,
      style: GoogleFonts.jetBrainsMono(
        fontSize: widget.compact ? 7.5 : 8.5,
        fontWeight: FontWeight.w800,
        color: AppColors.warning,
      ),
    );
  }
}

/// Card back used by lesson widgets that draw [MiniCard] rows.
///
/// Matches [TableCardBack] so face-down cards share one design with the
/// live table.
class CardBack extends StatelessWidget {
  /// Creates a card back.
  const CardBack({super.key, this.size = MiniCardSize.tiny});

  /// Footprint matching [MiniCard].
  final MiniCardSize size;

  @override
  Widget build(BuildContext context) {
    return TableCardBack(width: size.dimensions.width);
  }
}
