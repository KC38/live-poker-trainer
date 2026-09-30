/// The poker table: felt, seats, board, pot, and blinds.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/action_badge.dart';
import 'package:live_poker_trainer/ui/widgets/community_cards_view.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

/// Mobile-first poker table used by Live Training and every lesson.
///
/// The hero sits at the bottom center with the largest hole cards. The
/// other seats take fixed slots for the player count, clockwise from the
/// hero, and straddle the rail so the felt spends its area on the board.
/// Side seats sit above or below the board row rather than beside it.
///
/// Layout resolves in a fixed order so nothing hides decision input:
///
/// 1. Seats take their slots. Each seat claims its box, its hole cards,
///    its position pucks, its street bet, and its action badge.
/// 2. The board takes the largest scale that no seat claim reaches.
///
/// [features] (or the nearest [TableFeaturesScope]) turns optional layers
/// off for lessons that have not taught them yet.
class FeltTableView extends StatelessWidget {
  /// Creates the table.
  const FeltTableView({
    super.key,
    required this.game,
    required this.chipDisplayMode,
    this.collectingChips = false,
    this.awardingChips = false,
    this.review = false,
    this.waitingOnSeat,
    this.onPlayerTap,
    this.includeHero = true,
    this.showHoleCardBacks = false,
    this.heroCardsFaceUp = false,
    this.faceUpPlayerIds = const {},
    this.highlightHero = false,
    this.highlightBoard = false,
    this.onSeatTap,
    this.onBoardTap,
    this.onBoardCardTap,
    this.selectedBoardIndexes = const {},
    this.highlightBoardIndexes = const {},
    this.boardOrderBadges = const {},
    this.features,
    this.heroStatus,
  });

  final GameState game;

  /// Table amounts are currency-only; see [ChipDisplayMode.tableMode].
  final ChipDisplayMode chipDisplayMode;

  /// True while the street's bets animate into the pot.
  final bool collectingChips;

  /// True while the pot animates out to the winner seat(s).
  final bool awardingChips;

  /// True once the hand is over. The board may grow a little.
  final bool review;

  /// Seat currently waiting on an LLM decision, if any.
  final int? waitingOnSeat;

  /// Opens a villain's visible modeled tendency profile.
  final ValueChanged<PlayerModel>? onPlayerTap;

  /// Draw the hero seat. When false the hero's slot stays empty.
  final bool includeHero;

  /// Lesson mode: seats show two backs until their faces are turned up.
  ///
  /// The hero's faces then need [heroCardsFaceUp], and a villain's need
  /// [faceUpPlayerIds]. When false the hero is always face up.
  final bool showHoleCardBacks;

  /// Hero hole cards face up. Used with [showHoleCardBacks].
  final bool heroCardsFaceUp;

  /// Extra seats whose hole cards are face up, by player id.
  final Set<int> faceUpPlayerIds;

  /// Arrows on the hero seat, the lesson cue for "tap your cards".
  final bool highlightHero;

  /// An arrow on the community cards.
  final bool highlightBoard;

  /// Tap on a seat, including the hero. Lesson stages use this.
  final ValueChanged<PlayerModel>? onSeatTap;

  /// Tap on the community cards.
  final VoidCallback? onBoardTap;

  /// Tap on one dealt board card by index. Prefer this over [onBoardTap]
  /// when the lesson needs a single card.
  final ValueChanged<int>? onBoardCardTap;

  /// Board indexes with a selected gold ring.
  final Set<int> selectedBoardIndexes;

  /// Board indexes that bounce a cue arrow.
  final Set<int> highlightBoardIndexes;

  /// 1-based order badge drawn on a selected board card.
  final Map<int, int> boardOrderBadges;

  /// Optional layers. Null reads [TableFeaturesScope].
  final TableFeatures? features;

  /// Short hero state under the hero's box, such as `YOUR TURN`. An action
  /// badge or the winner badge takes that spot first.
  final String? heroStatus;

  @override
  Widget build(BuildContext context) {
    final features = this.features ?? TableFeaturesScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = TableLayout.resolve(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          game: game,
          features: features,
          includeHero: includeHero,
          review: review,
          awarding: awardingChips,
          chipDisplayMode: chipDisplayMode,
          collecting: collectingChips,
        );
        return _build(context, layout, features);
      },
    );
  }

  Widget _build(BuildContext context, TableLayout layout, TableFeatures f) {
    final h = layout.size.height;
    final winners = game.winnerIds.toSet();
    final villains = <Widget>[];
    final hero = <Widget>[];
    final decorations = <Widget>[];
    final heroDecorations = <Widget>[];

    for (final slot in layout.seats) {
      final player = game.players[slot.index];
      final isWinner = game.isHandOver && winners.contains(player.id);
      final seatLayer = player.isHero ? hero : villains;
      final decoLayer = player.isHero ? heroDecorations : decorations;
      final faceUp =
          player.isHero
              ? (!showHoleCardBacks || heroCardsFaceUp)
              : faceUpPlayerIds.contains(player.id);
      final showdown = game.isHandOver && !player.folded;
      final backs =
          !faceUp &&
          !(showdown && player.holeCards.isNotEmpty) &&
          (player.isHero
              ? showHoleCardBacks
              : (showHoleCardBacks || f.opponentCards) && !player.folded);

      seatLayer.add(
        Positioned.fromRect(
          rect: slot.footprint,
          child: GestureDetector(
            behavior:
                onSeatTap == null
                    ? HitTestBehavior.deferToChild
                    : HitTestBehavior.opaque,
            key:
                onSeatTap == null
                    ? null
                    : ValueKey<String>(
                      player.isHero
                          ? 'lesson-seat-hero'
                          : 'lesson-seat-${player.id}',
                    ),
            onTap: _seatTap(player),
            child: Semantics(
              button: onSeatTap != null,
              label:
                  onSeatTap == null
                      ? null
                      : player.isHero
                      ? (faceUp
                          ? 'Your hole cards, face up'
                          : 'Your hole cards')
                      : "${player.name}'s hole cards",
              child: PlayerSeatWidget(
                player: player,
                bigBlind: game.bigBlind,
                chipDisplayMode: chipDisplayMode,
                isActive:
                    game.activePlayerIndex == slot.index && !game.isHandOver,
                isWinner: isWinner,
                isWaitingOnLlm: waitingOnSeat == player.id,
                compact: layout.compact,
                scale: layout.seatScale,
                review: review,
                features: f,
                showCards: showdown,
                revealHoleCards: faceUp,
                showHoleBacks: backs,
              ),
            ),
          ),
        ),
      );

      for (final puck in slot.pucks) {
        decoLayer.add(
          Positioned.fromRect(
            rect: puck.rect,
            child: SeatPuck(label: puck.label, scale: layout.seatScale),
          ),
        );
      }

      final bet = slot.bet;
      if (bet != null) {
        decoLayer.add(
          Positioned(
            key: ValueKey<String>('bet-${player.id}'),
            left: bet.rect.center.dx - 60,
            top: bet.rect.top,
            width: 120,
            height: bet.rect.height,
            child: Center(
              child: StreetBetPill(label: bet.label, compact: layout.compact),
            ),
          ),
        );
      }

      final badgeTop = _clamp(slot.pod.bottom - 7, 0, math.max(0.0, h - 16));
      if (f.actions && player.lastActionLabel != null && !game.isHandOver) {
        decoLayer.add(
          Positioned(
            left: slot.pod.left,
            top: badgeTop,
            width: slot.pod.width,
            child: ActionBadge(
              key: ValueKey('act-${player.id}-${player.lastActionLabel}'),
              label: player.lastActionLabel!,
            ),
          ),
        );
      }

      final status = heroStatus;
      final hasBadge =
          f.actions && player.lastActionLabel != null && !game.isHandOver;
      if (player.isHero && status != null && !hasBadge && !isWinner) {
        decoLayer.add(
          Positioned(
            left: slot.pod.left,
            top: badgeTop,
            width: slot.pod.width,
            child: _HeroStatusChip(label: status),
          ),
        );
      }

      if (isWinner) {
        decoLayer.add(
          Positioned(
            left: slot.pod.left,
            top: badgeTop,
            width: slot.pod.width,
            child: _WinnerBadge(
              key: ValueKey('win-${player.id}-${game.handCount}'),
              label: game.isSplitPot ? 'SPLIT' : 'WINS',
            ),
          ),
        );
      }

      if (highlightHero && player.isHero) {
        heroDecorations.add(
          Positioned(
            left: slot.footprint.left,
            top: _clamp(slot.footprint.top - 30, 0, math.max(0.0, h - 28)),
            width: slot.footprint.width,
            child: const _CueArrows(count: 2),
          ),
        );
      }
    }

    final collects = <Widget>[];
    if (collectingChips) {
      for (final slot in layout.seats) {
        final player = game.players[slot.index];
        if (player.currentBet <= Money.epsilon) continue;
        final at =
            Offset.lerp(slot.pod.center, layout.potTarget, _betCollectT)!;
        collects.add(
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

    final awards = <Widget>[];
    if (awardingChips) {
      for (final slot in layout.seats) {
        final player = game.players[slot.index];
        if (!winners.contains(player.id)) continue;
        final share = game.awardShareFor(player.id);
        if (share <= Money.epsilon) continue;
        awards.add(
          _AwardFlight(
            key: ValueKey('award-${player.id}-${game.handCount}'),
            from: layout.potTarget,
            to: slot.pod.center,
            label: ChipFormat.chips(share, game.bigBlind, chipDisplayMode),
          ),
        );
      }
    }

    final board = layout.board;
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _FeltPainter(felt: layout.felt)),
        ),
        ...collects,
        ...villains,
        Positioned(
          left: 0,
          right: 0,
          top: board.columnTop -
              (highlightBoard || highlightBoardIndexes.isNotEmpty ? 30 : 0),
          child: Center(
            child: GestureDetector(
              key:
                  onBoardTap == null
                      ? null
                      : const ValueKey<String>('lesson-board'),
              behavior: HitTestBehavior.translucent,
              // Per-card taps own the hit target; whole-board tap stays for
              // steps that treat the board as one answer.
              onTap: onBoardCardTap == null ? onBoardTap : null,
              child: Semantics(
                button: onBoardTap != null && onBoardCardTap == null,
                label: onBoardTap == null || onBoardCardTap != null
                    ? null
                    : 'Community cards',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (highlightBoard && highlightBoardIndexes.isEmpty)
                      const SizedBox(height: 30, child: _CueArrows(count: 1)),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: board.scale),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      builder:
                          (context, scale, _) => CommunityCardsView(
                            community: game.community,
                            pot: game.displayPot,
                            street: game.street,
                            bigBlind: game.bigBlind,
                            smallBlind: game.smallBlind,
                            chipDisplayMode: chipDisplayMode,
                            scale: scale,
                            awarding: awardingChips,
                            isSplit: game.isSplitPot,
                            features: f,
                            resultMessage:
                                game.isHandOver ? game.resultMessage : null,
                            onBoardCardTap: onBoardCardTap,
                            selectedBoardIndexes: selectedBoardIndexes,
                            highlightBoardIndexes: highlightBoardIndexes,
                            boardOrderBadges: boardOrderBadges,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ...decorations,
        ...hero,
        ...heroDecorations,
        ...awards,
      ],
    );
  }

  VoidCallback? _seatTap(PlayerModel player) {
    if (onSeatTap == null && (player.tendency == null || onPlayerTap == null)) {
      return null;
    }
    return () {
      onSeatTap?.call(player);
      if (player.tendency != null) onPlayerTap?.call(player);
    };
  }

  /// Collect animation ends short of the pot so chips settle on the pill.
  static const double _betCollectT = 0.82;

  static double _clamp(double v, double lo, double hi) =>
      Money.clamp(v, lo, math.max(lo, hi));
}

/// A position puck beside a seat box.
@immutable
class SeatPuckSlot {
  const SeatPuckSlot(this.label, this.rect);

  /// `D`, `SB`, or `BB`.
  final String label;
  final Rect rect;
}

/// A street bet beside a seat box.
@immutable
class SeatBetSlot {
  const SeatBetSlot(this.label, this.rect);

  final String label;
  final Rect rect;
}

/// Where one seat draws and everything it claims.
@immutable
class SeatSlot {
  const SeatSlot({
    required this.index,
    required this.footprint,
    required this.pod,
    required this.pucks,
    required this.bet,
    required this.claims,
  });

  /// Index into `game.players`.
  final int index;

  /// Seat widget bounds: hole cards and box.
  final Rect footprint;

  /// The seat box.
  final Rect pod;

  final List<SeatPuckSlot> pucks;
  final SeatBetSlot? bet;

  /// Every rect this seat needs clear: footprint, pucks, bet, badge band.
  final List<Rect> claims;
}

/// The board column once it has been sized.
@immutable
class BoardSlot {
  const BoardSlot({
    required this.scale,
    required this.columnTop,
    required this.row,
    required this.labels,
  });

  final double scale;

  /// Top of the pot pill, or of the card row when the pot is hidden.
  final double columnTop;

  /// The five card slots.
  final Rect row;

  /// Pot pill and blinds line, sized to their text.
  final List<Rect> labels;

  /// Every rect the board needs clear.
  List<Rect> get rects => [row, ...labels];
}

/// Resolved geometry for one frame of [FeltTableView].
@immutable
class TableLayout {
  const TableLayout._({
    required this.size,
    required this.compact,
    required this.seatScale,
    required this.seats,
    required this.board,
    required this.felt,
    required this.potTarget,
  });

  final Size size;
  final bool compact;
  final double seatScale;
  final List<SeatSlot> seats;
  final BoardSlot board;

  /// Felt outline.
  final Rect felt;

  /// Where bets collect and awards leave from.
  final Offset potTarget;

  /// Smallest board that still reads at arm's length.
  static const double boardScaleMin = 0.55;

  /// Seat slots for 1–9 players as `(x, y)` in -1..1, hero first, clockwise.
  static const Map<int, List<Offset>> templates = {
    1: [Offset(0, 1)],
    2: [Offset(0, 1), Offset(0, -1)],
    3: [Offset(0, 1), Offset(-0.95, -0.62), Offset(0.95, -0.62)],
    4: [Offset(0, 1), Offset(-1, -0.42), Offset(0, -1), Offset(1, -0.42)],
    5: [
      Offset(0, 1),
      Offset(-1, 0.5),
      Offset(-0.5, -1),
      Offset(0.5, -1),
      Offset(1, 0.5),
    ],
    6: [
      Offset(0, 1),
      Offset(-1, 0.55),
      Offset(-1, -0.55),
      Offset(0, -1),
      Offset(1, -0.55),
      Offset(1, 0.55),
    ],
    7: [
      Offset(0, 1),
      Offset(-1, 0.6),
      Offset(-1, -0.4),
      Offset(-0.42, -1),
      Offset(0.42, -1),
      Offset(1, -0.4),
      Offset(1, 0.6),
    ],
    8: [
      Offset(0, 1),
      Offset(-1, 0.68),
      Offset(-1, 0.02),
      Offset(-1, -0.66),
      Offset(0, -1),
      Offset(1, -0.66),
      Offset(1, 0.02),
      Offset(1, 0.68),
    ],
    9: [
      Offset(0, 1),
      Offset(-1, 0.68),
      Offset(-1, 0.02),
      Offset(-1, -0.66),
      Offset(-0.36, -1),
      Offset(0.36, -1),
      Offset(1, -0.66),
      Offset(1, 0.02),
      Offset(1, 0.68),
    ],
  };

  /// Slot for relative seat [r] of [n], where 0 is the hero.
  static Offset slotFor(int r, int n) {
    final template = templates[n];
    if (template != null) return template[r];
    final angle = (math.pi / 2) + (2 * math.pi * r / n);
    return Offset(math.cos(angle), math.sin(angle));
  }

  /// Lays out [game] in [size].
  static TableLayout resolve({
    required Size size,
    required GameState game,
    required TableFeatures features,
    required bool includeHero,
    required bool review,
    required bool awarding,
    required ChipDisplayMode chipDisplayMode,
    bool collecting = false,
  }) {
    final w = size.width;
    final h = size.height;
    final n = game.players.length;
    final heroIndex = game.players.indexWhere((p) => p.isHero);
    final anchor = heroIndex < 0 ? 0 : heroIndex;
    final compact = n >= 7 || w < 340;
    final seatScale = math.min(
      (w / 390).clamp(0.82, 1.2),
      (h / 440).clamp(0.8, 1.2),
    );
    final villainM = SeatMetrics.of(
      hero: false,
      compact: compact,
      stats: features.stats,
      scale: seatScale,
    );
    final heroM = SeatMetrics.of(
      hero: true,
      compact: compact,
      review: review,
      scale: seatScale,
    );
    const margin = 4.0;
    final badge = 9 * seatScale;
    final cx = w / 2;

    final topY = villainM.cardsAbove + villainM.pod.height / 2 + margin;
    final bottomY = h - villainM.pod.height / 2 - badge;
    final heroPodCy = h - heroM.pod.height / 2 - badge;
    final heroTop =
        includeHero
            ? heroPodCy - heroM.pod.height / 2 - heroM.cardsAbove
            : h - margin;
    final hasTopSeat = [
      for (var r = 1; r < n; r++) slotFor(r, n),
    ].any((s) => s.dy <= -0.99);
    final freeTop =
        hasTopSeat ? topY + villainM.pod.height / 2 + badge : margin * 2;
    final midY = (freeTop + heroTop) / 2;

    final placed = <_PlacedSeat>[];
    for (var i = 0; i < n; i++) {
      final player = game.players[i];
      if (player.isHero && !includeHero) continue;
      final r = ((i - anchor) % n + n) % n;
      final slot = slotFor(r, n);
      final m = player.isHero ? heroM : villainM;
      final fp = m.footprint;
      final podCx = cx + slot.dx * (w / 2 - m.pod.width / 2 - margin);
      final double podCy;
      if (player.isHero) {
        podCy = heroPodCy;
      } else if (slot.dy < 0) {
        podCy = midY + slot.dy * (midY - topY);
      } else {
        podCy = midY + slot.dy * (bottomY - midY);
      }
      final left = _clamp(podCx - fp.width / 2, 0, w - fp.width);
      final top = _clamp(
        podCy + m.pod.height / 2 - fp.height,
        0,
        h - fp.height,
      );
      final footprint = Rect.fromLTWH(left, top, fp.width, fp.height);
      final pod = m.podIn(footprint);

      // Side seats put pucks toward the felt. A seat in the top row has a
      // neighbor on its inward side, so its pucks go outward. The hero and a
      // lone top seat use the right.
      final side = slot.dx.abs() >= 0.9;
      final toward =
          slot.dx > 0.1
              ? -1.0
              : slot.dx < -0.1
              ? 1.0
              : 0.0;
      final puckDir =
          side
              ? toward
              : toward == 0
              ? 1.0
              : -toward;
      final puckD = SeatPuck.diameter * seatScale;
      final labels = [
        if (features.positions && game.dealerIndex == i) 'D',
        if (features.positions && game.sbIndex == i) 'SB',
        if (features.positions && game.bbIndex == i) 'BB',
      ];
      final puckX = puckDir > 0 ? pod.right + 3 : pod.left - 3 - puckD;
      final stackH = labels.length * puckD + (labels.length - 1) * 2;
      final pucks = [
        for (var k = 0; k < labels.length; k++)
          SeatPuckSlot(
            labels[k],
            Rect.fromLTWH(
              puckX,
              pod.center.dy - stackH / 2 + k * (puckD + 2),
              puckD,
              puckD,
            ),
          ),
      ];
      placed.add(
        _PlacedSeat(
          index: i,
          slot: slot,
          footprint: footprint,
          pod: pod,
          pucks: pucks,
          body: Rect.fromLTRB(
            footprint.left,
            footprint.top,
            footprint.right,
            pod.bottom + badge,
          ),
        ),
      );
    }

    final bodies = [
      for (final p in placed) ...[p.body, for (final k in p.pucks) k.rect],
    ];
    final boardCenter = Offset(cx, midY);
    final seats = <SeatSlot>[];
    final bets = <Rect>[];
    for (final p in placed) {
      final player = game.players[p.index];
      SeatBetSlot? bet;
      if (features.bets && !collecting && player.currentBet > Money.epsilon) {
        final label = ChipFormat.chips(
          player.currentBet,
          game.bigBlind,
          chipDisplayMode,
        );
        final rect = _placeBet(
          seat: p,
          pill: StreetBetPill.sizeFor(label, compact: compact),
          boardCenter: boardCenter,
          blocked: [...bodies, ...bets],
          bounds: Offset.zero & size,
          badge: badge,
        );
        bets.add(rect);
        bet = SeatBetSlot(label, rect);
      }
      seats.add(
        SeatSlot(
          index: p.index,
          footprint: p.footprint,
          pod: p.pod,
          pucks: p.pucks,
          bet: bet,
          claims: [
            p.body,
            for (final k in p.pucks) k.rect,
            if (bet != null) bet.rect,
          ],
        ),
      );
    }

    final feltInset = villainM.pod.width * 0.3;
    final felt = Rect.fromLTRB(
      feltInset,
      hasTopSeat ? topY : margin * 3,
      w - feltInset,
      includeHero ? heroPodCy : h - margin * 3,
    );

    final board = _fitBoard(
      midY: midY,
      cx: cx,
      felt: felt,
      freeTop: freeTop,
      heroTop: heroTop,
      claims: [for (final s in seats) ...s.claims],
      features: features,
      review: review,
      awarding: awarding,
      potText: _potText(game, features, chipDisplayMode, awarding),
      blindsText: CommunityCardsView.blindsLabel(
        game.smallBlind,
        game.bigBlind,
      ),
    );
    // A board already at its smallest can still touch a bet on a crowded
    // short felt. Bets move; the board does not shrink further.
    final boardRects = board.rects;
    for (var k = 0; k < seats.length; k++) {
      final bet = seats[k].bet;
      if (bet == null || !boardRects.any(bet.rect.overlaps)) continue;
      final seat = placed.firstWhere((p) => p.index == seats[k].index);
      final others = [
        for (final s in seats)
          if (s.bet != null && s.index != seats[k].index) s.bet!.rect,
      ];
      final rect = _placeBet(
        seat: seat,
        pill: bet.rect.size,
        boardCenter: boardCenter,
        blocked: [...bodies, ...others, ...boardRects],
        bounds: Offset.zero & size,
        badge: badge,
      );
      seats[k] = SeatSlot(
        index: seats[k].index,
        footprint: seats[k].footprint,
        pod: seats[k].pod,
        pucks: seats[k].pucks,
        bet: SeatBetSlot(bet.label, rect),
        claims: [...seats[k].claims.where((c) => c != bet.rect), rect],
      );
    }

    final potTarget =
        board.labels.isNotEmpty && (features.pot || awarding)
            ? board.labels.first.center
            : board.row.center;

    return TableLayout._(
      size: size,
      compact: compact,
      seatScale: seatScale,
      seats: seats,
      board: board,
      felt: felt,
      potTarget: potTarget,
    );
  }

  static String _potText(
    GameState game,
    TableFeatures features,
    ChipDisplayMode mode,
    bool awarding,
  ) {
    final pot = ChipFormat.chips(game.displayPot, game.bigBlind, mode);
    if (awarding) return 'TAKES  ·  $pot';
    return features.street ? '${game.street.label}  ·  POT $pot' : 'POT $pot';
  }

  static BoardSlot _board({
    required double scale,
    required double midY,
    required double cx,
    required TableFeatures features,
    required bool awarding,
    required String potText,
    required String blindsText,
  }) {
    final rowW = CommunityCardsView.naturalWidth * scale;
    final rowH = CommunityCardsView.cardsHeight * scale;
    final row = Rect.fromCenter(
      center: Offset(cx, midY),
      width: rowW + 10,
      height: rowH + 6,
    );
    final above =
        CommunityCardsView.bandAbove(features, awarding: awarding) * scale;
    final labelMax = CommunityCardsView.labelWidth * scale;
    final labels = <Rect>[];
    if (features.pot || awarding) {
      final text = CommunityCardsView.labelWidthFor(
        potText,
        CommunityCardsView.potStyle(scale),
      );
      final width = math.min(labelMax, text + 22 * scale);
      labels.add(
        Rect.fromLTWH(
          cx - width / 2,
          midY - rowH / 2 - above,
          width,
          24 * scale,
        ),
      );
    }
    if (features.blinds) {
      final width = math.min(
        labelMax,
        CommunityCardsView.labelWidthFor(
          blindsText,
          CommunityCardsView.blindsStyle(scale),
        ),
      );
      labels.add(
        Rect.fromLTWH(
          cx - width / 2,
          midY + rowH / 2 + 6 * scale,
          width,
          15 * scale,
        ),
      );
    }
    return BoardSlot(
      scale: scale,
      columnTop: midY - rowH / 2 - above,
      row: row,
      labels: labels,
    );
  }

  static BoardSlot _fitBoard({
    required double midY,
    required double cx,
    required Rect felt,
    required double freeTop,
    required double heroTop,
    required List<Rect> claims,
    required TableFeatures features,
    required bool review,
    required bool awarding,
    required String potText,
    required String blindsText,
  }) {
    final natural =
        CommunityCardsView.cardsHeight +
        CommunityCardsView.bandAbove(features, awarding: awarding) +
        CommunityCardsView.bandBelow(features);
    final byWidth = (felt.width - 16) / CommunityCardsView.naturalWidth;
    final byHeight = (heroTop - freeTop - 8) / natural;
    var scale = math.min(byWidth, byHeight);
    scale = scale.clamp(boardScaleMin, review ? 1.3 : 1.2);
    final above = CommunityCardsView.bandAbove(features, awarding: awarding);
    final below = CommunityCardsView.bandBelow(features);
    final rowH = CommunityCardsView.cardsHeight;
    BoardSlot build(double s, double y) => _board(
      scale: s,
      midY: y,
      cx: cx,
      features: features,
      awarding: awarding,
      potText: potText,
      blindsText: blindsText,
    );
    bool clear(BoardSlot b) => !claims.any((c) => b.rects.any(c.overlaps));

    // Largest scale first; at each scale the row may slide off center within
    // the free band before the board gives up size.
    while (true) {
      final lo = freeTop + (above + rowH / 2) * scale;
      final hi = heroTop - (below + rowH / 2) * scale;
      final reach = math.max(hi - midY, midY - lo);
      for (var step = 0; ; step++) {
        final offset = (step.isEven ? 1 : -1) * ((step + 1) ~/ 2) * 4.0;
        if (offset.abs() > reach) break;
        final y = midY + offset;
        if (step > 0 && (y < lo || y > hi)) continue;
        final board = build(scale, y);
        if (clear(board)) return board;
      }
      if (scale <= boardScaleMin) return build(boardScaleMin, midY);
      scale = math.max(boardScaleMin, scale - 0.03);
    }
  }

  /// Street bet position for [seat]: on the line toward the pot, just clear
  /// of every seat. A side seat level with the board puts it under its box
  /// instead, where it does not narrow the board.
  static Rect _placeBet({
    required _PlacedSeat seat,
    required Size pill,
    required Offset boardCenter,
    required List<Rect> blocked,
    required Rect bounds,
    required double badge,
  }) {
    bool clear(Rect r) =>
        r.left >= bounds.left &&
        r.right <= bounds.right &&
        r.top >= bounds.top &&
        r.bottom <= bounds.bottom &&
        !blocked.any(r.overlaps);

    final pod = seat.pod;
    final inward =
        seat.slot.dx > 0.1
            ? -1.0
            : seat.slot.dx < -0.1
            ? 1.0
            : 0.0;
    final under = Rect.fromLTWH(
      inward > 0
          ? pod.right - pill.width
          : inward < 0
          ? pod.left
          : pod.center.dx - pill.width / 2,
      pod.bottom + badge + 2,
      pill.width,
      pill.height,
    );
    if (seat.slot.dx.abs() >= 0.9 && seat.slot.dy.abs() < 0.3 && clear(under)) {
      return under;
    }

    final from = pod.center;
    final delta = boardCenter - from;
    final dir =
        delta.distance < 1 ? const Offset(0, -1) : delta / delta.distance;
    Rect at(double d) => Rect.fromCenter(
      center: from + dir * d,
      width: pill.width,
      height: pill.height,
    );
    final limit = math.max(40.0, delta.distance);
    for (var d = 20.0; d <= limit; d += 4) {
      final r = at(d);
      if (clear(r)) return r;
    }
    if (clear(under)) return under;

    // Crowded short felt: the nearest clear spot anywhere on the table.
    Rect? best;
    var bestDistance = double.infinity;
    for (var y = bounds.top; y + pill.height <= bounds.bottom; y += 6) {
      for (var x = bounds.left; x + pill.width <= bounds.right; x += 6) {
        final r = Rect.fromLTWH(x, y, pill.width, pill.height);
        final distance = (r.center - from).distanceSquared;
        if (distance < bestDistance && clear(r)) {
          best = r;
          bestDistance = distance;
        }
      }
    }
    return best ?? at(limit * 0.6);
  }

  static double _clamp(double v, double lo, double hi) =>
      Money.clamp(v, lo, math.max(lo, hi));
}

/// A seat before its bet is placed.
class _PlacedSeat {
  const _PlacedSeat({
    required this.index,
    required this.slot,
    required this.footprint,
    required this.pod,
    required this.pucks,
    required this.body,
  });

  final int index;
  final Offset slot;
  final Rect footprint;
  final Rect pod;
  final List<SeatPuckSlot> pucks;

  /// Footprint down to the bottom of the action badge.
  final Rect body;
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

/// Pot share flying from the pot to a winner seat.
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
        final travel = Curves.easeInOutCubic.transform(
          (_controller.value / 0.72).clamp(0.0, 1.0),
        );
        final fade =
            _controller.value < 0.62
                ? 1.0
                : (1 - (_controller.value - 0.62) / 0.38).clamp(0.0, 1.0);
        final pos = Offset.lerp(widget.from, widget.to, travel)!;
        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: Opacity(opacity: fade, child: child),
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

/// Hero state under the hero's box: YOUR TURN, ACTION…, or FOLDED.
class _HeroStatusChip extends StatelessWidget {
  const _HeroStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final turn = label == 'YOUR TURN';
    return Center(
      child: Container(
        key: const ValueKey<String>('hero-status'),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: turn ? AppColors.goldBright : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(5),
          border:
              turn
                  ? null
                  : Border.all(color: AppColors.slate.withValues(alpha: 0.6)),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: turn ? AppColors.bgDark : AppColors.slate,
          ),
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

/// Bouncing gold arrows that mark the tap the step is teaching.
class _CueArrows extends StatefulWidget {
  const _CueArrows({required this.count});

  final int count;

  @override
  State<_CueArrows> createState() => _CueArrowsState();
}

class _CueArrowsState extends State<_CueArrows>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounce = CurvedAnimation(parent: _motion, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, child) {
        final dip = 2.0 + (_bounce.value * 8.0);
        final glow = 0.35 + (_bounce.value * 0.55);
        return Transform.translate(
          offset: Offset(0, dip),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldBright.withValues(alpha: glow * 0.75),
                  blurRadius: 10 + (8 * _bounce.value),
                  spreadRadius: 1 + (2 * _bounce.value),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Row(
        key: const ValueKey<String>('felt-cue-arrows'),
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.count; i++)
            Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 22,
                color: AppColors.goldBright,
                shadows: [
                  Shadow(
                    color: AppColors.gold.withValues(alpha: 0.9),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Rounded felt with a padded rail, seats straddling its edge.
class _FeltPainter extends CustomPainter {
  const _FeltPainter({required this.felt});

  final Rect felt;

  @override
  void paint(Canvas canvas, Size size) {
    if (felt.width <= 0 || felt.height <= 0) return;
    final ry = math.min(felt.width / 2, felt.height * 0.3);
    final shape = RRect.fromRectXY(felt, felt.width / 2, ry);

    final rail =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2B2F36), Color(0xFF15181D)],
          ).createShader(felt.inflate(10));
    canvas.drawRRect(shape.inflate(10), rail);

    final rim =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.gold.withValues(alpha: 0.28);
    canvas.drawRRect(shape.inflate(10), rim);

    final cloth =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, -0.1),
            radius: 0.9,
            colors: [AppColors.feltLight, AppColors.feltDark],
          ).createShader(felt);
    canvas.drawRRect(shape, cloth);

    final line =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.gold.withValues(alpha: 0.18);
    canvas.drawRRect(shape.deflate(9), line);
  }

  @override
  bool shouldRepaint(covariant _FeltPainter oldDelegate) =>
      oldDelegate.felt != felt;
}
