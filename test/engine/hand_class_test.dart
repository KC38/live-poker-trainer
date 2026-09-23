/// Board-relative classes the coach and villain model both bet on.
///
/// A raw pair score treats bottom pair and an overpair as the same hand.
/// [HandClassifier] is what splits them, so these cases lock that split.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';

int _code(String raw) => FastEvaluator.encode(CardModel.fromCode(raw));

HandClass _classOf(String holes, String board) {
  final hole = holes.split(' ');
  final cards = board.isEmpty
      ? const <int>[]
      : board.split(' ').map(_code).toList(growable: false);
  return HandClassifier.classify(_code(hole[0]), _code(hole[1]), cards);
}

int _outs(String holes, String board) {
  final hole = holes.split(' ');
  return HandClassifier.drawOuts(
    _code(hole[0]),
    _code(hole[1]),
    board.split(' ').map(_code).toList(growable: false),
  );
}

void main() {
  group('HandClassifier.classify', () {
    test('preflop and short boards stay unclassified', () {
      expect(_classOf('Ah Kd', ''), HandClass.air);
      expect(_classOf('Ah Kd', '2s'), HandClass.air);
      expect(_classOf('Ah Kd', '2s 3c'), HandClass.air);
    });

    test('top pair, overpair, and second pair stay distinct', () {
      expect(_classOf('Ah Kd', 'As 7c 2d'), HandClass.topPair);
      expect(_classOf('Ah Ad', 'Kc 7s 2d'), HandClass.topPair);
      // Pairing the seven on a king-high flop is second pair, not top pair.
      expect(_classOf('7h 9d', 'Kc 7s 2d'), HandClass.weakPair);
      expect(_classOf('Kh 9d', 'Kc 7s 2d'), HandClass.topPair);
    });

    test('bottom pair and an underpair are weak pairs', () {
      expect(_classOf('5h 2d', 'Ah 7c 2s'), HandClass.weakPair);
      expect(_classOf('5h 5d', 'Ah Kd 2c'), HandClass.weakPair);
    });

    test('sets and two pair outrank one pair', () {
      expect(_classOf('7h 7d', '7c Kd 2s'), HandClass.strongMade);
      expect(_classOf('Ah Kd', 'As Kc 7d'), HandClass.strongMade);
    });

    test('straights and flushes are monsters', () {
      expect(_classOf('9h 8d', 'Jc Ts 7c'), HandClass.monster);
      expect(_classOf('Ah 9h', 'Kh 7h 2c 3h'), HandClass.monster);
    });

    test('draws outrank unpaired air, and a draw upgrades a weak pair', () {
      expect(_classOf('Ah 9h', 'Kh 7h 2c'), HandClass.strongDraw);
      expect(_outs('Ah 9h', 'Kh 7h 2c'), DrawOuts.flushDraw);
      expect(_classOf('9h 8d', 'Jc Ts 2d'), HandClass.strongDraw);
      expect(_outs('9h 8d', 'Jc Ts 2d'), DrawOuts.strong);
      expect(_classOf('9h 8d', 'Jc 7s 2d'), HandClass.weakDraw);
      expect(_outs('9h 8d', 'Jc 7s 2d'), DrawOuts.weak);
      expect(_classOf('9h 8h', 'Jh Th 2c'), HandClass.strongDraw);
      expect(_outs('9h 8h', 'Jh Th 2c'), DrawOuts.combo);
      // Pair of eights plus a flush draw plays as the draw.
      expect(_classOf('8h 7h', 'Kh 8c 2h'), HandClass.strongDraw);
    });

    test('two overcards are a weak draw and blank high-card is air', () {
      expect(_classOf('Ah Kd', '9c 7s 2d'), HandClass.weakDraw);
      expect(_classOf('7h 2d', 'As Kd Qc'), HandClass.air);
    });

    test('rivers stop counting draws', () {
      expect(_outs('8h 7h', 'Kh 8c 2h 3d 4s'), 0);
      expect(_classOf('8h 7h', 'Kh 8c 2h 3d 4s'), HandClass.weakPair);
    });

    test('a board-only straight is not hero\'s draw', () {
      expect(_outs('2h 2d', '9c 8d 7s 6h'), 0);
      expect(_classOf('2h 2d', '9c 8d 7s 6h'), HandClass.weakPair);
    });
  });
}
