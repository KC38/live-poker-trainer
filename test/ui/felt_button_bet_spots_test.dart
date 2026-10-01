/// Fixed potward felt lanes for pucks, bets, and CHECK (2–9 seats).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/action_badge.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/poker_table_bands.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

GameState _ring({
  required int seats,
  required int dealerIndex,
  Street street = Street.preflop,
}) {
  return lessonBandGame(
    villainSeatCount: seats - 1,
    dealerIndex: dealerIndex,
    boardCodes: street == Street.preflop
        ? const []
        : const ['Ac', 'Kd', '7h'],
  );
}

GameState _actionRing({
  required int seats,
  required List<String?> actions,
  required List<double> bets,
}) {
  final players = <PlayerModel>[
    PlayerModel(
      id: 0,
      name: 'You',
      archetype: PlayerArchetype.hero,
      stack: 200 - bets[0],
      currentBet: bets[0],
      isHero: true,
      lastActionLabel: actions[0],
      holeCards: [
        CardModel.fromCode('Ah'),
        CardModel.fromCode('Kd'),
      ],
    ),
    for (var i = 1; i < seats; i++)
      PlayerModel(
        id: i,
        name: 'P$i',
        archetype: PlayerArchetype.tag,
        stack: 200 - bets[i],
        currentBet: bets[i],
        lastActionLabel: actions[i],
        holeCards: [
          CardModel.fromCode('2c'),
          CardModel.fromCode('7d'),
        ],
      ),
  ];
  return GameState(
    players: players,
    mode: GameMode.training,
    community: const [],
    street: Street.flop,
    mainPot: 12,
    highestBet: bets.fold<double>(0, math.max),
    minRaise: 2,
    smallBlind: 1,
    bigBlind: 2,
    dealerIndex: 0,
    sbIndex: seats <= 2 ? 0 : 1,
    bbIndex: seats <= 2 ? 1 : 2,
    waitingForHero: true,
  );
}

TableLayout _layout(
  GameState game, {
  Size size = const Size(393, 520),
}) {
  return TableLayout.resolve(
    size: size,
    game: game,
    features: TableFeatures.full,
    includeHero: true,
    review: false,
    awarding: false,
    chipDisplayMode: ChipDisplayMode.dollars,
    collecting: false,
  );
}

double _along(Offset from, Offset point, Offset inward) {
  final d = point - from;
  return d.dx * inward.dx + d.dy * inward.dy;
}

/// Nearest point of the seat claim facing the pot (past cards / box).
Offset _claimEdge(SeatSlot seat, Offset center) {
  final toward = center - seat.pod.center;
  final inward =
      toward.distance < 1 ? const Offset(0, -1) : toward / toward.distance;
  final claim = Rect.fromLTRB(
    math.min(seat.footprint.left, seat.pod.left),
    math.min(seat.footprint.top, seat.pod.top),
    math.max(seat.footprint.right, seat.pod.right),
    seat.pod.bottom + kSeatBadgeBelowPod,
  );
  return SeatFeltSpots.exitPoint(claim, seat.pod.center, inward);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SeatFeltSpots', () {
    test('template slots point toward the table origin', () {
      expect(SeatFeltSpots.inwardFor(const Offset(0, 1)).dy, lessThan(0));
      expect(SeatFeltSpots.inwardFor(const Offset(0, -1)).dy, greaterThan(0));
      expect(SeatFeltSpots.inwardFor(const Offset(1, 0)).dx, lessThan(0));
      expect(SeatFeltSpots.inwardFor(const Offset(-1, 0.55)).dx, greaterThan(0));
    });

    test('bet sits further along the potward lane than the puck', () {
      const pod = Rect.fromLTWH(250, 300, 100, 40);
      const footprint = Rect.fromLTWH(250, 240, 100, 100);
      final spots = SeatFeltSpots.forSeat(
        pod: pod,
        footprint: footprint,
        boardCenter: const Offset(196, 260),
        seatScale: 1,
      );
      const puckD = 18.0;
      const pill = Size(36, 18);
      final puck = spots.puckCenter(puckDiameter: puckD, index: 0, count: 1);
      final bet = spots.betCenter(
        pill: pill,
        puckDiameter: puckD,
        hasPucks: true,
      );
      expect(
        _along(spots.edge, bet, spots.inward),
        greaterThan(_along(spots.edge, puck, spots.inward)),
      );
    });

    test('clearances scale with seatScale', () {
      final a = SeatFeltSpots.forSeat(
        pod: const Rect.fromLTWH(100, 200, 100, 40),
        footprint: const Rect.fromLTWH(100, 140, 100, 100),
        boardCenter: const Offset(196, 200),
        seatScale: 1,
      );
      final b = SeatFeltSpots.forSeat(
        pod: const Rect.fromLTWH(100, 200, 100, 40),
        footprint: const Rect.fromLTWH(100, 140, 100, 100),
        boardCenter: const Offset(196, 200),
        seatScale: 1.2,
      );
      expect(b.puckClearance, greaterThan(a.puckClearance));
      expect(b.maxBetTravel, greaterThan(a.maxBetTravel));
    });
  });

  group('TableLayout fixed felt spots', () {
    for (var n = 2; n <= 9; n++) {
      test('$n-handed markers stay on the potward lane near each seat', () {
        final game = _ring(seats: n, dealerIndex: n > 2 ? 1 : 0);
        final layout = _layout(game);
        final center = Offset(layout.size.width / 2, layout.size.height / 2);

        for (final seat in layout.seats) {
          for (final puck in seat.pucks) {
            // Closest to its own seat, not a neighbor.
            final own = (puck.rect.center - seat.pod.center).distance;
            for (final other in layout.seats) {
              if (other.index == seat.index) continue;
              expect(
                own,
                lessThan((puck.rect.center - other.pod.center).distance),
                reason: 'puck ${puck.label} seat ${seat.index} nearer neighbor',
              );
            }
          }

          final bet = seat.bet;
          if (bet == null) continue;
          final own = (bet.rect.center - seat.pod.center).distance;
          expect(
            own,
            lessThan((center - seat.pod.center).distance),
            reason: 'bet seat ${seat.index} nearer pot than seat',
          );
          for (final other in layout.seats) {
            if (other.index == seat.index) continue;
            expect(
              own,
              lessThan((bet.rect.center - other.pod.center).distance + 8),
              reason: 'bet seat ${seat.index} nearer neighbor ${other.index}',
            );
          }
        }
      });
    }

    test('raise and call bets use the same potward home as blinds', () {
      final game = _actionRing(
        seats: 6,
        actions: [null, 'FOLD', 'CALL', 'RAISE', 'CHECK', 'CALL'],
        bets: [0, 0, 6, 18, 0, 6],
      );
      final layout = _layout(game);
      final center = Offset(layout.size.width / 2, layout.size.height / 2);

      for (final seat in layout.seats) {
        final player = game.players[seat.index];
        if (player.currentBet <= 0) continue;
        expect(seat.bet, isNotNull, reason: 'seat ${seat.index}');
        final own = (seat.bet!.rect.center - seat.pod.center).distance;
        expect(own, lessThan((center - seat.pod.center).distance));
      }
    });

    test('CHECK parks on the bet home, not under the seat box', () {
      final game = _actionRing(
        seats: 4,
        actions: [null, 'CHECK', 'CHECK', 'BET'],
        bets: [0, 0, 0, 8],
      );
      final layout = _layout(game);

      for (final seat in layout.seats) {
        final player = game.players[seat.index];
        if (!ActionBadge.isCheck(player.lastActionLabel)) continue;
        expect(seat.feltAction, isNotNull, reason: 'seat ${seat.index}');
        expect(seat.feltAction!.label, 'CHECK');
        // Not the under-pod action band.
        expect(
          seat.feltAction!.rect.center.dy,
          isNot(closeTo(seat.pod.bottom - kSeatBadgeOverlapPod, 6)),
        );
      }
    });

    test('spots move when the felt scales', () {
      final game = _ring(seats: 6, dealerIndex: 3);
      final small = _layout(game, size: const Size(320, 480));
      final large = _layout(game, size: const Size(430, 700));

      SeatSlot seatOf(TableLayout layout, int index) =>
          layout.seats.firstWhere((s) => s.index == index);

      final sbSmall = seatOf(small, game.sbIndex);
      final sbLarge = seatOf(large, game.sbIndex);
      expect(sbSmall.bet, isNotNull);
      expect(sbLarge.bet, isNotNull);
      expect(
        (sbLarge.bet!.rect.center - sbSmall.bet!.rect.center).distance,
        greaterThan(8),
      );
    });

    test('dealer puck on the top seat sits potward of the box', () {
      final game = _ring(seats: 6, dealerIndex: 3);
      final layout = _layout(game);
      final dealer = layout.seats.firstWhere((s) => s.index == 3);
      expect(dealer.pucks, isNotEmpty);
      final puck = dealer.pucks.firstWhere((p) => p.label == 'D');
      expect(puck.rect.center.dy, greaterThan(dealer.pod.bottom - 4));
      final center = Offset(layout.size.width / 2, layout.size.height / 2);
      final edge = _claimEdge(dealer, center);
      expect((puck.rect.center - edge).distance, lessThan(40));
    });

    test('hero pod leaves room for the showdown order badge', () {
      for (final size in const [
        Size(390, 320),
        Size(390, 420),
        Size(390, 560),
      ]) {
        final game = _ring(seats: 3, dealerIndex: 1);
        final layout = _layout(game, size: size);
        final hero = layout.seats.firstWhere((s) => s.index == 0);
        expect(
          hero.pod.bottom + kSeatBadgeBelowPod,
          lessThanOrEqualTo(size.height),
        );
      }
    });
  });
}
