/// The starting-hand chart is the only hand-authored table in the coach.
///
/// Villain ranges are a top-N% slice of [PreflopChart], then narrowed by
/// [RangeBuilder]. A duplicate class, a dropped combo, or a seat factor that
/// drifts changes every equity number the coach reports.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/engine/hand_range.dart';
import 'package:live_poker_trainer/engine/preflop_chart.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';

int _code(String raw) => FastEvaluator.encode(CardModel.fromCode(raw));

int _combos(Iterable<String> labels) {
  var n = 0;
  for (final label in labels) {
    n += PreflopChart.combosFor(label);
  }
  return n;
}

void main() {
  group('PreflopChart ranking', () {
    test('lists each of the 169 classes once and covers 1326 combos', () {
      expect(PreflopChart.ranking.length, 169);
      expect(PreflopChart.ranking.toSet().length, 169);
      expect(_combos(PreflopChart.ranking), PreflopChart.totalCombos);
      expect(PreflopChart.percentOf(PreflopChart.ranking), 100);
      expect(PreflopChart.percentOf(const []), 0);
    });

    test('combo counts are six, four, and twelve', () {
      expect(PreflopChart.combosFor('AA'), 6);
      expect(PreflopChart.combosFor('AKs'), 4);
      expect(PreflopChart.combosFor('AKo'), 12);
    });

    test('expand round-trips through labelFor with no shared cards', () {
      final seen = <String>{};
      for (final label in PreflopChart.ranking) {
        final combos = PreflopChart.expand(label);
        expect(combos.length, PreflopChart.combosFor(label), reason: label);
        for (final combo in combos) {
          expect(combo[0], inInclusiveRange(0, 51));
          expect(combo[1], inInclusiveRange(0, 51));
          expect(combo[0], isNot(combo[1]));
          final lo = min(combo[0], combo[1]);
          final hi = max(combo[0], combo[1]);
          expect(seen.add('$lo-$hi'), isTrue, reason: '$label reused $lo-$hi');
          expect(PreflopChart.labelFor(combo[0], combo[1]), label);
          expect(PreflopChart.labelFor(combo[1], combo[0]), label);
        }
      }
      expect(seen.length, 1326);
    });

    test('chart codes match the fast evaluator', () {
      expect(PreflopChart.labelFor(_code('As'), _code('Ah')), 'AA');
      expect(PreflopChart.labelFor(_code('As'), _code('Ks')), 'AKs');
      expect(PreflopChart.labelFor(_code('As'), _code('Kd')), 'AKo');
      final suited = PreflopChart.expand('AKs');
      expect(
        suited.any(
          (combo) => combo.contains(_code('As')) && combo.contains(_code('Ks')),
        ),
        isTrue,
      );
    });

    test('unknown labels sort after every real class', () {
      expect(PreflopChart.rankOf('AA'), 0);
      expect(PreflopChart.rankOf('82o'), PreflopChart.ranking.length - 1);
      expect(PreflopChart.rankOf('72o'), PreflopChart.ranking.length - 2);
      expect(PreflopChart.rankOf('nope'), PreflopChart.ranking.length);
      expect(PreflopChart.ranking.first, 'AA');
      expect(PreflopChart.ranking.last, '82o');
    });

    test('topPercent keeps whole classes and the documented bounds', () {
      expect(PreflopChart.topPercent(0), isEmpty);
      expect(PreflopChart.topPercent(-4), isEmpty);
      expect(
        identical(PreflopChart.topPercent(100), PreflopChart.ranking),
        isTrue,
      );
      expect(
        identical(PreflopChart.topPercent(140), PreflopChart.ranking),
        isTrue,
      );
      // AA is 6 combos, about 0.45%. A sliver still takes the whole class.
      expect(PreflopChart.topPercent(0.01), ['AA']);

      for (final percent in [1.0, 9.36, 23.0, 58.0, 75.4]) {
        final selected = PreflopChart.topPercent(percent);
        expect(PreflopChart.percentOf(selected), greaterThanOrEqualTo(percent));
        expect(
          PreflopChart.percentOf(selected.take(selected.length - 1)),
          lessThan(percent),
        );
      }
    });
  });

  group('RangeBuilder', () {
    test('seat factors widen the button and tighten early seats', () {
      expect(RangeBuilder.positionFactor('UTG'), 0.72);
      expect(RangeBuilder.positionFactor('UTG+1'), 0.72);
      expect(RangeBuilder.positionFactor('MP'), 0.85);
      expect(RangeBuilder.positionFactor('MP+1'), 0.85);
      expect(RangeBuilder.positionFactor('HJ'), 0.95);
      expect(RangeBuilder.positionFactor('CO'), 1.10);
      expect(RangeBuilder.positionFactor('BTN'), 1.30);
      expect(RangeBuilder.positionFactor('SB'), 1.05);
      expect(RangeBuilder.positionFactor('BB'), 1.25);
      expect(RangeBuilder.positionFactor(''), 1);
      expect(RangeBuilder.positionFactor('UTG+2'), 1);

      final utg = RangeBuilder.preflop(
        archetype: PlayerArchetype.tag,
        positionLabel: 'UTG',
      );
      final btn = RangeBuilder.preflop(
        archetype: PlayerArchetype.tag,
        positionLabel: 'BTN',
      );
      expect(
        utg.length,
        _combos(PreflopChart.topPercent(PlayerArchetype.tag.vpip * 0.72)),
      );
      expect(btn.length, greaterThan(utg.length));
      expect(HandRange.all().length, 1326);
    });

    test('raising range is the PFR slice, not the full VPIP slice', () {
      final opening = RangeBuilder.preflop(
        archetype: PlayerArchetype.callingStation,
        positionLabel: 'CO',
        asAggressor: true,
      );
      final continuing = RangeBuilder.preflop(
        archetype: PlayerArchetype.callingStation,
        positionLabel: 'CO',
      );
      expect(opening.length, lessThan(continuing.length));
      expect(
        opening.length,
        _combos(
          PreflopChart.topPercent(PlayerArchetype.callingStation.pfr * 1.10),
        ),
      );
    });

    test('a short board does not narrow, and a copy stays independent', () {
      final range = HandRange.fromLabels(['AA', 'AKs', '72o']);
      final before = range.totalWeight;
      RangeBuilder.narrow(
        range: range,
        archetype: PlayerArchetype.nit,
        board: [_code('Qs'), _code('3h')],
        action: RangeAction.bet,
      );
      expect(range.totalWeight, before);

      final copy = range.copy();
      copy.reweight((int a, int b) => 0);
      expect(copy.isEmpty, isTrue);
      expect(range.totalWeight, before);
    });

    test('surviving an unseen street tightens less than a called bet', () {
      final flop = [_code('Qs'), _code('3h'), _code('5d')];
      final called = RangeBuilder.preflop(
        archetype: PlayerArchetype.tag,
        positionLabel: 'BTN',
      );
      final survived = called.copy();
      final before = called.totalWeight;
      RangeBuilder.narrow(
        range: called,
        archetype: PlayerArchetype.tag,
        board: flop,
        action: RangeAction.called,
        sizeToPot: 0.5,
      );
      RangeBuilder.narrow(
        range: survived,
        archetype: PlayerArchetype.tag,
        board: flop,
        action: RangeAction.survived,
      );
      expect(called.totalWeight, lessThan(before));
      expect(survived.totalWeight, greaterThan(called.totalWeight));
      expect(survived.totalWeight, lessThan(before));
    });

    test('fold equity is zero preflop and on an empty range', () {
      final range = HandRange.fromLabels(['AKs', 'QQ', '76s']);
      final flop = [_code('Qs'), _code('3h'), _code('5d')];
      expect(
        RangeBuilder.foldEquity(
          range: range,
          archetype: PlayerArchetype.lag,
          board: const [],
          priceToPot: 0.5,
        ),
        0,
      );
      final live = RangeBuilder.foldEquity(
        range: range,
        archetype: PlayerArchetype.nit,
        board: flop,
        priceToPot: 1,
      );
      expect(live, inInclusiveRange(0, 1));
      expect(live, greaterThan(0));

      range.removeCards({
        for (var i = 0; i < range.length; i++) ...[
          range.cardA(i),
          range.cardB(i),
        ],
      });
      expect(range.isEmpty, isTrue);
      expect(
        RangeBuilder.foldEquity(
          range: range,
          archetype: PlayerArchetype.nit,
          board: flop,
          priceToPot: 1,
        ),
        0,
      );
      final composition = range.composition(flop);
      expect(composition.keys, HandClass.values.toSet());
      expect(composition.values.every((weight) => weight == 0), isTrue);
    });

    test('continuing against a bet does not mutate the facing range', () {
      final facing = RangeBuilder.preflop(
        archetype: PlayerArchetype.lag,
        positionLabel: 'BB',
      );
      final before = facing.totalWeight;
      final preflop = RangeBuilder.continuingAgainst(
        range: facing,
        archetype: PlayerArchetype.lag,
        board: const [],
        priceToPot: 0.5,
      );
      expect(preflop.totalWeight, before);
      preflop.reweight((int a, int b) => 0);
      expect(facing.totalWeight, before);

      final flop = [_code('Ah'), _code('7c'), _code('2d')];
      final continued = RangeBuilder.continuingAgainst(
        range: facing,
        archetype: PlayerArchetype.lag,
        board: flop,
        priceToPot: 1.5,
      );
      expect(facing.totalWeight, before);
      expect(continued.totalWeight, lessThan(before));
      expect(continued.totalWeight, greaterThan(0));
    });

    test(
      'sampling follows live weight and stays empty when nothing remains',
      () {
        final range = HandRange.fromLabels(['AA', 'KK']);
        final first = Random(4);
        range.sample(first);
        final deadAces = <int>{};
        for (var i = 0; i < range.length; i++) {
          if (PreflopChart.labelFor(range.cardA(i), range.cardB(i)) == 'AA') {
            deadAces.add(range.cardA(i));
            deadAces.add(range.cardB(i));
          }
        }
        range.removeCards(deadAces);
        final rng = Random(9);
        for (var n = 0; n < 20; n++) {
          final index = range.sample(rng);
          expect(
            PreflopChart.labelFor(range.cardA(index), range.cardB(index)),
            'KK',
          );
        }

        range.removeCards({
          for (var i = 0; i < range.length; i++) ...[
            range.cardA(i),
            range.cardB(i),
          ],
        });
        expect(range.sample(Random(1)), -1);
        expect(HandRange.fromLabels(const []).sample(Random(1)), -1);

        int draw(int seed) {
          final fresh = HandRange.fromLabels(['AA', 'KK', 'AKs']);
          return fresh.sample(Random(seed));
        }

        expect(draw(4), draw(4));
      },
    );
  });
}
