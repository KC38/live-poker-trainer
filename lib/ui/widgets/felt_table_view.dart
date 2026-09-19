/// Elliptical felt with villain seats, live bets, and chips moving to the pot.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/community_cards_view.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

/// Responsive elliptical table view.
///
/// The hero is deliberately *not* drawn on the felt: hero cards live on their
/// own rail below, which is what keeps the coach shelf from ever covering them.
/// Every seat is laid out inside a fixed box and clamped to the felt band, so
/// nothing can spill into the bands below.
///
/// Everything drawn here is decision input — archetype, stack, committed
/// chips, position pucks, the last action, the board — so the layout resolves
/// in a fixed order that never lets one hide another:
///
/// 1. Seats claim the ring, shrinking together until no two footprints touch.
/// 2. The board takes the largest scale that no seat footprint reaches.
/// 3. Committed chips ride inside the seat HUD. A phone has no lane between a
///    side seat and the board wide enough for a floating pill, so a chip aimed
///    at the pot would always land on somebody's archetype tag.
///
/// Chips only leave the seats for the collect beat, where they fade out on
/// their way to the pot.
class FeltTableView extends StatelessWidget {
  /// Creates the felt table.
  const FeltTableView({
    super.key,
    required this.game,
    required this.chipDisplayMode,
    this.collectingChips = false,
    this.awardingChips = false,
    this.review = false,
  });

  final GameState game;

  /// Table amounts are currency-only; see [ChipDisplayMode.tableMode].
  final ChipDisplayMode chipDisplayMode;

  /// True while the street's bets animate into the pot.
  final bool collectingChips;

  /// True while the pot animates out to the winner seat(s).
  final bool awardingChips;

  /// True once the hand is over: the felt inherits the action dock's band and
  /// the board is allowed to grow into it (still bounded by the seat ring).
  final bool review;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final n = game.players.length;
        final compact = n >= 7 || w < 380 || h < 300;
        final heroIndex = game.players.indexWhere((p) => p.isHero);
        // The ring is sized to the felt, not the other way round: a nine-handed
        // phone shrinks its seats until no two touch rather than letting one
        // seat's archetype tag disappear behind its neighbour.
        final seatBox = _fitSeatBox(
          w,
          h,
          n,
          heroIndex,
          SeatMetrics.of(compactLayout: compact),
        );

        final cx = w / 2;
        final cy = h / 2;
        final rx = _ringRx(w, seatBox);
        final ry = _ringRy(h, seatBox);

        final seats = <Widget>[];
        final bets = <Widget>[];
        final awards = <Widget>[];
        // Hero sits on the rail below the felt; send their share to the bottom
        // edge so the flight reads as landing on the rail.
        final heroTarget = Offset(cx, h - 18);

        final winnerIdSet = game.winnerIds.toSet();

        // Geometry pass first: every seat's footprint has to be known before
        // the board is sized, so the board can shrink rather than slide under
        // a seat on a crowded nine-handed phone.
        final slots = <_SeatSlot>[];
        for (var i = 0; i < n; i++) {
          final player = game.players[i];
          if (player.isHero) continue;

          // Rotate so the hero's empty ring slot is always at the bottom of
          // the felt (π/2), matching the hero rail below — even when the
          // authored situation puts hero at a non-zero seat index.
          final angle = _seatAngle(i, heroIndex: heroIndex, seatCount: n);
          final left = _clamp(
            cx + rx * math.cos(angle) - seatBox.width / 2,
            0,
            math.max(0.0, w - seatBox.width),
          );
          final top = _clamp(
            cy + ry * math.sin(angle) - seatBox.height / 2,
            0,
            math.max(0.0, h - seatBox.height),
          );
          final box = Rect.fromLTWH(
            left,
            top,
            seatBox.width,
            seatBox.height,
          );
          final hasBadge = (player.lastActionLabel != null && !game.isHandOver) ||
              (game.isHandOver && winnerIdSet.contains(player.id));
          slots.add(
            _SeatSlot(
              index: i,
              box: box,
              // D / SB / BB pucks overhang the card by 6; the action / winner
              // badge hangs below. Both are readable state, so both count as
              // part of the seat's footprint.
              occupied: Rect.fromLTRB(
                box.left - _puckOverhang,
                box.top - _puckOverhang,
                box.right + _puckOverhang,
                box.bottom + (hasBadge ? _badgeBand : _puckOverhang),
              ),
            ),
          );
        }

        final boardScale = _boardScale(
          w,
          h,
          seatBox,
          slots,
          Offset(cx, cy),
          review: review,
          awarding: awardingChips,
        );
        // Collect toward the pot label (above the card row), not the geometric
        // center of the board column — that used to blank the river mid-slide.
        final potTarget = Offset(cx, cy - 22 * boardScale);

        for (final slot in slots) {
          final i = slot.index;
          final player = game.players[i];
          final isWinner = winnerIdSet.contains(player.id);
          final hasBet = player.currentBet > Money.epsilon;

          seats.add(
            Positioned(
              left: slot.box.left,
              top: slot.box.top,
              child: PlayerSeatWidget(
                player: player,
                bigBlind: game.bigBlind,
                chipDisplayMode: chipDisplayMode,
                isActive: game.activePlayerIndex == i && !game.isHandOver,
                isWinner: game.isHandOver && isWinner,
                isDealer: game.dealerIndex == i,
                isSmallBlind: game.sbIndex == i,
                isBigBlind: game.bbIndex == i,
                compact: compact,
                size: seatBox,
                showCards: game.isHandOver && !player.folded,
                // While chips fly to the pot the flying pill carries the
                // amount, so the docked one would read as a double count.
                betLabel: hasBet && !collectingChips
                    ? ChipFormat.chips(
                        player.currentBet,
                        game.bigBlind,
                        chipDisplayMode,
                      )
                    : null,
              ),
            ),
          );

          if (player.lastActionLabel != null && !game.isHandOver) {
            seats.add(
              Positioned(
                left: slot.box.left,
                top: _clamp(slot.box.bottom - 6, 0, math.max(0.0, h - 18)),
                width: seatBox.width,
                child: _ActionBadge(
                  key: ValueKey('act-${player.id}-${player.lastActionLabel}'),
                  label: player.lastActionLabel!,
                  archetype: player.archetype,
                ),
              ),
            );
          }

          if (game.isHandOver && isWinner) {
            seats.add(
              Positioned(
                left: slot.box.left,
                top: _clamp(slot.box.bottom - 6, 0, math.max(0.0, h - 18)),
                width: seatBox.width,
                child: _WinnerBadge(
                  key: ValueKey('win-${player.id}-${game.handCount}'),
                  label: game.isSplitPot ? 'SPLIT' : 'WINS',
                ),
              ),
            );
          }
        }

        // Resting bets are docked in the seat HUD. Only the collect beat puts
        // chips on the felt, and it fades them out over the board.
        if (collectingChips) {
          for (final slot in slots) {
            final player = game.players[slot.index];
            if (player.currentBet <= Money.epsilon) continue;
            final at = Offset.lerp(slot.box.center, potTarget, _betCollectT)!;
            bets.add(
              _BetChip(
                key: ValueKey('bet-${player.id}'),
                left: at.dx,
                top: at.dy,
                label: ChipFormat.chips(
                  player.currentBet,
                  game.bigBlind,
                  chipDisplayMode,
                ),
                faded: true,
              ),
            );
          }
        }

        if (awardingChips) {
          for (var i = 0; i < n; i++) {
            final player = game.players[i];
            if (!winnerIdSet.contains(player.id)) continue;
            final share = game.awardShareFor(player.id);
            if (share <= Money.epsilon) continue;

            final angle = _seatAngle(i, heroIndex: heroIndex, seatCount: n);
            awards.add(
              _AwardFlight(
                key: ValueKey('award-${player.id}-${game.handCount}'),
                from: potTarget,
                to: player.isHero
                    ? heroTarget
                    : Offset(
                        cx + rx * math.cos(angle),
                        cy + ry * math.sin(angle),
                      ),
                label: ChipFormat.chips(
                  share,
                  game.bigBlind,
                  chipDisplayMode,
                ),
              ),
            );
          }
        }

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _FeltPainter(seatBox: seatBox)),
            ),
            ...bets,
            // Seats first, board last. The board already shrinks until no seat
            // touches it, so this order only decides the tie on a felt too
            // short to hold the ring at all — and there the shared community
            // cards matter more than one villain's HUD.
            ...seats,
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: boardScale),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                builder: (context, scale, _) => CommunityCardsView(
                  community: game.community,
                  pot: game.displayPot,
                  street: game.street,
                  bigBlind: game.bigBlind,
                  chipDisplayMode: chipDisplayMode,
                  scale: scale,
                  awarding: awardingChips,
                  isSplit: game.isSplitPot,
                  resultMessage: game.isHandOver ? game.resultMessage : null,
                ),
              ),
            ),
            ...awards,
          ],
        );
      },
    );
  }

  /// Collect animation ends short of dead center so chips settle on the pot
  /// label rather than covering the card row while they fade.
  static const double _betCollectT = 0.82;

  /// How far D / SB / BB pucks hang outside the seat card.
  static const double _puckOverhang = 6;

  /// Vertical room the action / winner badge claims below a seat.
  static const double _badgeBand = 18;

  /// Horizontal radius of the seat ring for [seatBox].
  static double _ringRx(double width, Size seatBox) =>
      math.max(0.0, (width - seatBox.width) / 2) * 0.96;

  /// Vertical radius of the seat ring for [seatBox].
  static double _ringRy(double height, Size seatBox) =>
      math.max(0.0, (height - seatBox.height) / 2) * 0.94;

  /// Polar angle for seat [index], rotated so [heroIndex] sits at π/2 (bottom).
  static double _seatAngle(
    int index, {
    required int heroIndex,
    required int seatCount,
  }) {
    final anchor = heroIndex < 0 ? 0 : heroIndex;
    return (math.pi / 2) + (2 * math.pi * (index - anchor) / seatCount);
  }

  /// Seat footprints on the ring, hero's slot left empty for the rail.
  ///
  /// Each box is grown by [_badgeBand] at the bottom so the fit search accounts
  /// for the action badge that hangs there.
  static List<Rect> _ringBoxes(
    double width,
    double height,
    int seatCount,
    int heroIndex,
    Size seatBox,
  ) {
    final cx = width / 2;
    final cy = height / 2;
    final rx = _ringRx(width, seatBox);
    final ry = _ringRy(height, seatBox);
    return [
      for (var i = 0; i < seatCount; i++)
        if (i != heroIndex)
          () {
            final angle = _seatAngle(
              i,
              heroIndex: heroIndex,
              seatCount: seatCount,
            );
            return Rect.fromLTWH(
              _clamp(
                cx + rx * math.cos(angle) - seatBox.width / 2,
                0,
                math.max(0.0, width - seatBox.width),
              ),
              _clamp(
                cy + ry * math.sin(angle) - seatBox.height / 2,
                0,
                math.max(0.0, height - seatBox.height),
              ),
              seatBox.width,
              seatBox.height,
            );
          }(),
    ];
  }

  /// Largest seat box at which no two seats on the ring touch.
  ///
  /// Steps down from [natural] and stops at the first clear fit. The seat HUD
  /// scales its own contents to whatever box it is handed, so a smaller box
  /// costs legibility gradually — unlike an overlap, which costs it entirely.
  static Size _fitSeatBox(
    double width,
    double height,
    int seatCount,
    int heroIndex,
    Size natural,
  ) {
    var box = natural;
    for (var attempt = 0; attempt < _seatFitSteps; attempt++) {
      final boxes = _ringBoxes(width, height, seatCount, heroIndex, box)
          .map((r) => Rect.fromLTRB(r.left, r.top, r.right, r.bottom + _badgeBand))
          .toList();
      if (!_anyOverlap(boxes)) return box;
      box = Size(box.width * _seatFitStep, box.height * _seatFitStep);
    }
    return box;
  }

  static bool _anyOverlap(List<Rect> rects) {
    for (var i = 0; i < rects.length; i++) {
      for (var j = i + 1; j < rects.length; j++) {
        if (rects[i].overlaps(rects[j])) return true;
      }
    }
    return false;
  }

  /// Shrink applied per fit attempt, and how many attempts are allowed before
  /// the seat would stop being readable at arm's length.
  static const double _seatFitStep = 0.94;
  static const int _seatFitSteps = 7;

  /// Smallest board that still reads at arm's length.
  static const double _boardScaleMin = 0.62;

  /// Largest board that fits between the seats without touching one.
  ///
  /// The width and height budgets set the ceiling; the seat sweep then shrinks
  /// the board further if any seat — pucks and action badge included — would
  /// still land on it. Review only lifts the ceiling, so a nine-handed phone
  /// keeps its board and gains readability from the taller felt instead.
  static double _boardScale(
    double width,
    double height,
    Size seatBox,
    List<_SeatSlot> slots,
    Offset center, {
    required bool review,
    required bool awarding,
  }) {
    final natural = _boardNatural(awarding: awarding);
    final byWidth = (width - seatBox.width * 2 - 12) / natural.width;
    final byHeight = (height - seatBox.height * 2 - 12) / natural.height;
    var scale = _clamp(
      math.min(byWidth, byHeight),
      _boardScaleMin,
      review ? 1.34 : 1.2,
    );

    while (scale > _boardScaleMin) {
      final board = _boardContent(center, scale, awarding: awarding);
      if (!slots.any((slot) => slot.occupied.overlaps(board))) break;
      scale -= 0.04;
    }
    return math.max(scale, _boardScaleMin);
  }

  /// Board column size at scale 1. The result line only exists while awarding.
  static Size _boardNatural({required bool awarding}) => Size(
        CommunityCardsView.naturalWidth,
        CommunityCardsView.naturalHeight +
            (awarding ? CommunityCardsView.resultMessageHeight : 0),
      );

  /// Footprint of [CommunityCardsView] content (pot pill + card row) at [scale].
  ///
  /// Padded past the real widget bounds so a seat sitting flush against this
  /// rect still leaves visible daylight around the river.
  static Rect _boardContent(
    Offset center,
    double scale, {
    required bool awarding,
  }) {
    final natural = _boardNatural(awarding: awarding);
    return Rect.fromCenter(
      center: center,
      width: natural.width * scale + 20,
      height: natural.height * scale + 14,
    );
  }

  static double _clamp(double v, double lo, double hi) =>
      Money.clamp(v, lo, hi);
}

/// A seat's resolved geometry: where it draws, and what it protects.
class _SeatSlot {
  const _SeatSlot({
    required this.index,
    required this.box,
    required this.occupied,
  });

  /// Index into `game.players`.
  final int index;

  /// Seat card footprint as positioned on the felt.
  final Rect box;

  /// [box] grown by puck overhang and the badge band below.
  final Rect occupied;
}

/// A chip pill representing a player's bet on the current street.
class _BetChip extends StatelessWidget {
  const _BetChip({
    super.key,
    required this.left,
    required this.top,
    required this.label,
    required this.faded,
  });

  final double left;
  final double top;
  final String label;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
      left: left,
      top: top,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 320),
        opacity: faded ? 0 : 1,
        // Transform anchors the pill on its center without a fixed width that
        // would clip long amounts under a seat-sized box.
        child: Transform.translate(
          offset: const Offset(0, -10),
          child: FractionalTranslation(
            translation: const Offset(-0.5, 0),
            child: _ChipPill(label: label),
          ),
        ),
      ),
    );
  }
}

/// Pot share flying from the board center to a winner seat (or hero rail).
class _AwardFlight extends StatefulWidget {
  const _AwardFlight({
    super.key,
    required this.from,
    required this.to,
    required this.label,
  });

  final Offset from;
  final Offset to;
  final String label;

  @override
  State<_AwardFlight> createState() => _AwardFlightState();
}

class _AwardFlightState extends State<_AwardFlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 640),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Travel for most of the beat, then fade out near the seat.
        final travel = Curves.easeInOutCubic.transform(
          (_controller.value / 0.72).clamp(0.0, 1.0),
        );
        final fade = _controller.value < 0.62
            ? 1.0
            : (1 - (_controller.value - 0.62) / 0.38).clamp(0.0, 1.0);
        final pos = Offset.lerp(widget.from, widget.to, travel)!;
        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: Opacity(
            opacity: fade,
            child: child,
          ),
        );
      },
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: FractionalTranslation(
          translation: const Offset(-0.5, 0),
          child: _ChipPill(label: widget.label, emphasize: true),
        ),
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({required this.label, this.emphasize = false});

  final String label;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      // Stack order keeps chips under the seats and the board; elevation 0 so
      // physical layers cannot climb over the pot label or river.
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.bgDark.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: emphasize ? 1 : 0.85),
            width: emphasize ? 1.4 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: emphasize ? 0.45 : 0.3),
              blurRadius: emphasize ? 6 : 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold "WINS" / "SPLIT" badge under a winning seat at hand end.
class _WinnerBadge extends StatefulWidget {
  const _WinnerBadge({super.key, required this.label});

  final String label;

  @override
  State<_WinnerBadge> createState() => _WinnerBadgeState();
}

class _WinnerBadgeState extends State<_WinnerBadge> {
  double _scale = 0.7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _scale = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.goldBright.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldBright.withValues(alpha: 0.35),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: AppColors.bgDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pops the villain's most recent action so the replay reads as live play.
class _ActionBadge extends StatefulWidget {
  const _ActionBadge({
    super.key,
    required this.label,
    required this.archetype,
  });

  final String label;
  final PlayerArchetype archetype;

  @override
  State<_ActionBadge> createState() => _ActionBadgeState();
}

class _ActionBadgeState extends State<_ActionBadge> {
  double _scale = 0.7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _scale = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final color = switch (label) {
      'FOLD' => AppColors.slate,
      'CHECK' => AppColors.slate,
      'BLIND' => AppColors.goldMuted,
      'CALL' => AppColors.warning,
      _ => AppColors.danger,
    };
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: AppColors.bgDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeltPainter extends CustomPainter {
  const _FeltPainter({required this.seatBox});

  final Size seatBox;

  @override
  void paint(Canvas canvas, Size size) {
    final width = math.max(60.0, size.width - seatBox.width * 0.75);
    final height = math.max(60.0, size.height - seatBox.height * 0.7);
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: width,
      height: height,
    );

    final rim = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.feltRim, AppColors.feltBorder, AppColors.feltRim],
      ).createShader(rect);
    canvas.drawOval(rect.inflate(11), rim);

    final felt = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.15),
        radius: 0.95,
        colors: [
          AppColors.feltLight.withValues(alpha: 0.95),
          AppColors.feltDark,
        ],
      ).createShader(rect);
    canvas.drawOval(rect, felt);

    final rail = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.gold.withValues(alpha: 0.22);
    canvas.drawOval(rect.deflate(8), rail);
  }

  @override
  bool shouldRepaint(covariant _FeltPainter oldDelegate) =>
      oldDelegate.seatBox != seatBox;
}
