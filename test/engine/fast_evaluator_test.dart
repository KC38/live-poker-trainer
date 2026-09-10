/// Proves [FastEvaluator] ranks hands identically to [DeckEvaluator].
///
/// The equity engine grades with the fast evaluator while the pot is awarded
/// by the slow one. Any ordering disagreement would let the coach reason about
/// a different winner than the table pays, so this is a correctness gate, not
/// a performance test.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/deck_evaluator.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/models/card_model.dart';

List<CardModel> _cards(String codes) =>
    codes.split(' ').map(CardModel.fromCode).toList();

int _sign(int a, int b) => a == b ? 0 : (a > b ? 1 : -1);

void main() {
  group('FastEvaluator categories', () {
    final cases = <String, int>{
      'As Ks Qs Js Ts 2h 3c': HandCategory.straightFlush,
      '5s 4s 3s 2s As 9h Kc': HandCategory.straightFlush,
      'Ah Ad Ac As Kh 2c 3d': HandCategory.quads,
      'Ah Ad Ac Kh Kd 2c 3d': HandCategory.fullHouse,
      'Ah Ad Ac Kh Kd Qs Qc': HandCategory.fullHouse,
      'Ah 9h 7h 5h 3h Kc Qd': HandCategory.flush,
      'Ah Kd Qc Js Th 3c 2d': HandCategory.straight,
      'Ah 2d 3c 4s 5h Kc Qd': HandCategory.straight,
      'Ah Ad Ac Kh Qd Js 9c': HandCategory.trips,
      'Ah Ad Kh Kd Qs Jc 9d': HandCategory.twoPair,
      'Ah Ad Kh Qd Js 9c 7h': HandCategory.pair,
      'Ah Kd Qc Js 9h 7c 5d': HandCategory.highCard,
    };

    cases.forEach((hand, expected) {
      test('$hand is ${HandCategory.label(expected)}', () {
        expect(
          FastEvaluator.categoryOf(FastEvaluator.scoreCards(_cards(hand))),
          expected,
        );
      });
    });
  });

  test('wheel straight loses to six-high straight', () {
    final wheel = FastEvaluator.scoreCards(_cards('Ah 2d 3c 4s 5h Kc Qd'));
    final six = FastEvaluator.scoreCards(_cards('2d 3c 4s 5h 6c Kc Qd'));
    expect(wheel, lessThan(six));
  });

  test('kickers break ties within a category', () {
    final aceKicker = FastEvaluator.scoreCards(_cards('Ah Ad Kh 7d 5s 3c 2d'));
    final queenKicker =
        FastEvaluator.scoreCards(_cards('Ah Ad Qh 7d 5s 3c 2d'));
    expect(aceKicker, greaterThan(queenKicker));
  });

  test('identical hand values tie exactly', () {
    final a = FastEvaluator.scoreCards(_cards('Ah Ad Kh 7d 5s 3c 2d'));
    final b = FastEvaluator.scoreCards(_cards('As Ac Kd 7h 5c 3s 2h'));
    expect(a, b);
  });

  test('agrees with DeckEvaluator ordering across random deals', () {
    final rng = Random(20260907);
    final deck = [
      for (final suit in Suit.values)
        for (var rank = 2; rank <= 14; rank++)
          CardModel(rank: rank, suit: suit),
    ];

    var compared = 0;
    for (var trial = 0; trial < 4000; trial++) {
      final shuffled = [...deck]..shuffle(rng);
      final board = shuffled.take(5).toList();
      final left = [...board, shuffled[5], shuffled[6]];
      final right = [...board, shuffled[7], shuffled[8]];

      final slow = _sign(
        DeckEvaluator.evaluate7Cards(left).score,
        DeckEvaluator.evaluate7Cards(right).score,
      );
      final fast = _sign(
        FastEvaluator.scoreCards(left),
        FastEvaluator.scoreCards(right),
      );

      expect(
        fast,
        slow,
        reason: 'disagreement on board ${board.map((c) => c.code).join(' ')} '
            'between ${left.sublist(5).map((c) => c.code).join('')} and '
            '${right.sublist(5).map((c) => c.code).join('')}',
      );
      compared++;
    }
    expect(compared, 4000);
  });
}
