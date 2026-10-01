/// Fixed felt lanes for position pucks and street bets (2–9 seats).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/game_state.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SeatFeltSpots', () {
    test('side seats point horizontally onto the felt', () {
      expect(SeatFeltSpots.inwardFor(const Offset(1, 0.55)), const Offset(-1, 0));
      expect(SeatFeltSpots.inwardFor(const Offset(-1, -0.55)), const Offset(1, 0));
    });

    test('mid-side seats drop below the box to clear the board', () {
      final inward = SeatFeltSpots.inwardFor(const Offset(1, 0.02));
      expect(inward.dx, lessThan(0));
      expect(inward.dy, greaterThan(0.5));
    });

    test('top and bottom seats point vertically onto the felt', () {
      expect(SeatFeltSpots.inwardFor(const Offset(0, -1)), const Offset(0, 1));
      expect(SeatFeltSpots.inwardFor(const Offset(0, 1)), const Offset(0, -1));
    });

    test('bet sits further along the lane than the puck', () {
      const pod = Rect.fromLTWH(200, 100, 100, 40);
      const footprint = Rect.fromLTWH(200, 40, 100, 100);
      final spots = SeatFeltSpots.forSeat(
        slot: const Offset(1, 0.55),
        pod: pod,
        footprint: footprint,
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
      final along = (bet - puck).dx; // inward is left for right seat
      expect(along, lessThan(0));
      expect(along.abs(), greaterThan(puckD / 2));
    });

    test('distances scale with seatScale', () {
      const pod = Rect.fromLTWH(100, 200, 100, 40);
      const footprint = Rect.fromLTWH(100, 140, 100, 100);
      Offset betAt(double scale) {
        final spots = SeatFeltSpots.forSeat(
          slot: const Offset(0, 1),
          pod: pod,
          footprint: footprint,
          seatScale: scale,
        );
        return spots.betCenter(
          pill: const Size(40, 18),
          puckDiameter: 18 * scale,
          hasPucks: false,
        );
      }

      final a = betAt(1);
      final b = betAt(1.2);
      // Hero lane is upward; larger scale moves the bet further from the edge.
      expect(b.dy, lessThan(a.dy));
      expect((a.dy - b.dy).abs(), greaterThan(2));
    });
  });

  group('TableLayout fixed felt spots', () {
    for (var n = 2; n <= 9; n++) {
      test('$n-handed pucks and bets stay on each seat inward lane', () {
        final game = _ring(seats: n, dealerIndex: n > 2 ? 1 : 0);
        final layout = _layout(game);
        final center = Offset(layout.size.width / 2, layout.size.height / 2);

        for (final seat in layout.seats) {
          final slot = TableLayout.slotFor(
            ((seat.index - game.players.indexWhere((p) => p.isHero)) % n + n) %
                n,
            n,
          );
          final inward = SeatFeltSpots.inwardFor(slot);

          for (final puck in seat.pucks) {
            final fromPod = puck.rect.center - seat.pod.center;
            final along = fromPod.dx * inward.dx + fromPod.dy * inward.dy;
            expect(
              along,
              greaterThan(0),
              reason: 'puck ${puck.label} seat ${seat.index} must sit '
                  'onto the felt (along=$along, inward=$inward)',
            );
          }

          final bet = seat.bet;
          if (bet == null) continue;
          final fromPod = bet.rect.center - seat.pod.center;
          final along = fromPod.dx * inward.dx + fromPod.dy * inward.dy;
          expect(
            along,
            greaterThan(0),
            reason: 'bet seat ${seat.index} must sit onto the felt',
          );

          if (seat.pucks.isEmpty) continue;
          final puckAlong = seat.pucks
              .map((p) {
                final d = p.rect.center - seat.pod.center;
                return d.dx * inward.dx + d.dy * inward.dy;
              })
              .reduce(math.max);
          expect(
            along,
            greaterThan(puckAlong),
            reason: 'bet should sit further inward than the puck',
          );

          // Stay nearer the seat than the board center.
          expect(
            (bet.rect.center - seat.pod.center).distance,
            lessThan((center - seat.pod.center).distance * 0.85),
          );
        }
      });
    }

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
      expect(sbSmall.pucks, isNotEmpty);
      expect(sbLarge.pucks, isNotEmpty);

      // Absolute positions change with the felt size.
      expect(
        (sbLarge.bet!.rect.center - sbSmall.bet!.rect.center).distance,
        greaterThan(8),
      );

      // Relative lane geometry stays the same: bet is further inward than puck.
      Offset inwardOf(TableLayout layout, SeatSlot seat) {
        final hero = game.players.indexWhere((p) => p.isHero);
        final r = ((seat.index - hero) % game.players.length +
                game.players.length) %
            game.players.length;
        return SeatFeltSpots.inwardFor(
          TableLayout.slotFor(r, game.players.length),
        );
      }

      double along(SeatSlot seat, Offset point, Offset inward) {
        final d = point - seat.pod.center;
        return d.dx * inward.dx + d.dy * inward.dy;
      }

      for (final layout in [small, large]) {
        final seat = seatOf(layout, game.sbIndex);
        final inward = inwardOf(layout, seat);
        final puckAlong = along(seat, seat.pucks.first.rect.center, inward);
        final betAlong = along(seat, seat.bet!.rect.center, inward);
        expect(betAlong, greaterThan(puckAlong));
      }
    });

    test('dealer puck on the top seat sits below the box, not beside it', () {
      final game = _ring(seats: 6, dealerIndex: 3);
      final layout = _layout(game);
      final dealer = layout.seats.firstWhere((s) => s.index == 3);
      expect(dealer.pucks, isNotEmpty);
      final puck = dealer.pucks.firstWhere((p) => p.label == 'D');
      expect(puck.rect.center.dy, greaterThan(dealer.pod.bottom));
      expect(
        (puck.rect.center.dx - dealer.pod.center.dx).abs(),
        lessThan(dealer.pod.width * 0.35),
      );
    });

    test('hero pod leaves room for the showdown order badge', () {
      // Short stage heights (Nice! dock) used to reserve only ~9px under the
      // hero while the gold order badge is 22px — Nice! covered the "2".
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
          reason: 'felt ${size.height}: order badge must fit under hero',
        );
      }
    });
  });
}
