/// Postflop remaps keep second pair as second pair (LPT-409).
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';

int _depth(List<String> hero, List<String> board) {
  final ranks = {for (final c in board) CardModel.fromCode(c).rank}.toList()
    ..sort((a, b) => b.compareTo(a));
  final ds = [for (final c in hero) ranks.indexOf(CardModel.fromCode(c).rank)]
      .where((d) => d >= 0)
      .toList();
  return ds.isEmpty ? -1 : ds.reduce(min);
}

void _expectDepth(List<String> hero, List<String> board, int want, int n) {
  expect(_depth(hero, board), want, reason: 'template');
  for (var seed = 0; seed < n; seed++) {
    final g = isomorphicLessonCardGroups([hero, board], Random(seed));
    expect(_depth(g[0], g[1]), want, reason: 'seed $seed: ${g[0]} on ${g[1]}');
    expect(
      CardModel.fromCode(g[0][0]).rank,
      isNot(CardModel.fromCode(g[0][1]).rank),
      reason: 'seed $seed stays a board pair, not a pocket pair',
    );
  }
}

void main() {
  test('river second pair J9 on Q9327 stays depth 1 (LPT-409)', () {
    _expectDepth(['Jh', '9d'], ['Qc', '9s', '3h', '2d', '7c'], 1, 120);
  });

  test('flop second pair 97 on K72 stays depth 1 (LPT-409)', () {
    _expectDepth(['7h', '9d'], ['Kc', '7s', '2d'], 1, 80);
  });

  test('river second pair JT on QT327 stays depth 1 (LPT-409)', () {
    _expectDepth(['Jh', 'Td'], ['Qc', 'Ts', '3h', '2d', '7c'], 1, 80);
  });
}
