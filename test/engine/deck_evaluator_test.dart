import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/deck_evaluator.dart';
import 'package:live_poker_trainer/models/card_model.dart';

CardModel c(String code) => CardModel.fromCode(code);

void main() {
  group('DeckEvaluator', () {
    test('detects royal flush', () {
      final hand = [
        c('As'),
        c('Ks'),
        c('Qs'),
        c('Js'),
        c('Ts'),
        c('2d'),
        c('3c'),
      ];
      final result = DeckEvaluator.evaluate7Cards(hand);
      expect(result.rankName, 'Royal Flush');
      expect(result.score, greaterThan(8000000));
    });

    test('detects four of a kind beats full house', () {
      final quads = DeckEvaluator.evaluate7Cards([
        c('Ah'),
        c('Ad'),
        c('Ac'),
        c('As'),
        c('Kd'),
        c('2c'),
        c('3h'),
      ]);
      final boat = DeckEvaluator.evaluate7Cards([
        c('Kh'),
        c('Kd'),
        c('Kc'),
        c('Qs'),
        c('Qd'),
        c('2c'),
        c('3h'),
      ]);
      expect(quads.rankName, 'Four of a Kind');
      expect(boat.rankName, 'Full House');
      expect(quads.score, greaterThan(boat.score));
    });

    test('uses kickers for one pair', () {
      final better = DeckEvaluator.evaluate7Cards([
        c('Ah'),
        c('Ad'),
        c('Kc'),
        c('Qd'),
        c('Js'),
        c('2c'),
        c('3h'),
      ]);
      final worse = DeckEvaluator.evaluate7Cards([
        c('Ah'),
        c('Ad'),
        c('Kc'),
        c('Qd'),
        c('9s'),
        c('2c'),
        c('3h'),
      ]);
      expect(better.rankName, 'One Pair');
      expect(worse.rankName, 'One Pair');
      expect(better.score, greaterThan(worse.score));
    });

    test('wheel straight via ace-low', () {
      final hand = DeckEvaluator.evaluate7Cards([
        c('Ah'),
        c('2d'),
        c('3c'),
        c('4s'),
        c('5d'),
        c('9c'),
        c('Jh'),
      ]);
      expect(hand.rankName, 'Straight');
      expect(hand.score, 4000000 + 5);
    });

    test('shuffled deck has 52 unique cards', () {
      final deck = DeckEvaluator.buildShuffledDeck();
      expect(deck.length, 52);
      expect(deck.toSet().length, 52);
    });
  });
}
