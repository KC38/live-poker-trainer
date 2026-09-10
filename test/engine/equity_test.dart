/// Checks the equity engine against hand-vs-hand numbers that are matters of
/// arithmetic, not opinion.
///
/// If these drift, every EV figure the coach reports is wrong, so the
/// tolerances are deliberately tight.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/equity.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_range.dart';
import 'package:live_poker_trainer/models/card_model.dart';

List<int> _codes(String cards) => cards.isEmpty
    ? <int>[]
    : cards.split(' ').map((c) => FastEvaluator.encode(CardModel.fromCode(c))).toList();

HandRange _range(List<String> labels, {String dead = ''}) {
  final range = HandRange.fromLabels(labels);
  if (dead.isNotEmpty) range.removeCards(_codes(dead).toSet());
  return range;
}

EquityResult _equity({
  required String hero,
  String board = '',
  required List<String> villain,
  int iterations = 60000,
}) {
  final heroCards = _codes(hero);
  final boardCards = _codes(board);
  final dead = {...heroCards, ...boardCards};
  final range = HandRange.fromLabels(villain)..removeCards(dead);
  return EquitySimulator.heroEquity(
    heroCards: heroCards,
    board: boardCards,
    villains: [range],
    seed: 12345,
    iterations: iterations,
  );
}

void main() {
  group('known preflop matchups', () {
    test('AA versus KK is about 82%', () {
      final r = _equity(hero: 'As Ah', villain: ['KK']);
      expect(r.equity, closeTo(0.822, 0.012));
    });

    test('AKs versus QQ is about 46%', () {
      final r = _equity(hero: 'Ah Kh', villain: ['QQ']);
      expect(r.equity, closeTo(0.462, 0.012));
    });

    test('AKo versus 22 is about 47%', () {
      final r = _equity(hero: 'Ah Ks', villain: ['22']);
      expect(r.equity, closeTo(0.470, 0.015));
    });

    test('being suited is worth about three points in the same race', () {
      final offsuit = _equity(hero: 'Ah Ks', villain: ['22']);
      final suited = _equity(hero: 'Ah Kh', villain: ['22']);
      expect(suited.equity, closeTo(0.500, 0.015));
      expect(suited.equity - offsuit.equity, closeTo(0.030, 0.015));
    });

    test('76s versus AA is about 23%', () {
      final r = _equity(hero: '7h 6h', villain: ['AA']);
      expect(r.equity, closeTo(0.229, 0.015));
    });
  });

  group('postflop', () {
    test('nut flush draw plus an ace overcard is near a coin flip', () {
      // Nine flush outs plus three aces against a made top pair, so roughly
      // twelve outs twice — a shade under even money.
      final r = _equity(
        hero: 'Ah 4h',
        board: 'Kh 9h 2c',
        villain: ['KQo'],
      );
      expect(r.equity, closeTo(0.46, 0.03));
    });

    test('set on the turn is a huge favourite over top pair', () {
      final r = _equity(
        hero: '9s 9c',
        board: 'Kh 9h 2c 3d',
        villain: ['KQo'],
      );
      expect(r.equity, greaterThan(0.94));
      expect(r.exact, isTrue, reason: 'turn versus one range enumerates');
    });

    test('river equity is exact and has no sampling error', () {
      final r = _equity(
        hero: '9s 9c',
        board: 'Kh 9h 2c 3d 7s',
        villain: ['KQo', 'AKo', 'KJs'],
      );
      expect(r.exact, isTrue);
      expect(r.standardError, 0);
      expect(r.equity, greaterThan(0.99));
    });

    test('drawing dead on the river returns zero', () {
      final r = _equity(
        hero: '2c 3d',
        board: 'Ah Kh Qh Jh Th',
        villain: ['22'],
      );
      // Board plays as a royal flush for everyone: a pure split.
      expect(r.equity, closeTo(0.5, 0.001));
    });
  });

  group('determinism', () {
    test('the same spot grades to the same equity every time', () {
      EquityResult run() => _equity(
            hero: '3d 2h',
            board: 'Qd 3s 5d',
            villain: ['A5s', 'KQo', '76s', 'JTs'],
            iterations: 8000,
          );
      final first = run();
      final second = run();
      final third = run();
      expect(first.equity, second.equity);
      expect(second.equity, third.equity);
    });

    test('sampled results report a usable standard error', () {
      final r = _equity(
        hero: '3d 2h',
        board: 'Qd 3s 5d',
        villain: ['A5s', 'KQo', '76s', 'JTs'],
        iterations: 8000,
      );
      expect(r.exact, isFalse);
      expect(r.standardError, greaterThan(0));
      expect(r.standardError, lessThan(0.01));
    });
  });

  group('card removal', () {
    test('villain never holds a card the hero holds', () {
      final range = _range(['AA'], dead: 'As Ah');
      // Only one ace pair combo survives: Ad Ac.
      var live = 0;
      for (var i = 0; i < range.length; i++) {
        if (range.weightAt(i) > 0) live++;
      }
      expect(live, 1);
    });

    test('an empty range falls back instead of dividing by zero', () {
      final range = _range(['AA'], dead: 'As Ah Ad Ac');
      final r = EquitySimulator.heroEquity(
        heroCards: _codes('Kd Kc'),
        board: _codes('7h 5s 2d'),
        villains: [range],
        seed: 1,
      );
      expect(r.equity, EquityResult.unknown.equity);
    });
  });

  test('multiway equity is lower than the same hand heads-up', () {
    final headsUp = _equity(
      hero: 'Ah Kd',
      board: 'Ac 8s 3h',
      villain: ['KQo'],
      iterations: 20000,
    );
    final heroCards = _codes('Ah Kd');
    final board = _codes('Ac 8s 3h');
    final dead = {...heroCards, ...board};
    final multiway = EquitySimulator.heroEquity(
      heroCards: heroCards,
      board: board,
      villains: [
        HandRange.fromLabels(['KQo'])..removeCards(dead),
        HandRange.fromLabels(['87s', '33'])..removeCards(dead),
      ],
      seed: 99,
      iterations: 20000,
    );
    expect(multiway.equity, lessThan(headsUp.equity));
  });
}
