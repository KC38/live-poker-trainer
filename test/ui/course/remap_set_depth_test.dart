/// Postflop remaps keep set depth (top / middle / bottom) (LPT-411).
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';

int _setDepth(List<String> hero, List<String> board) {
  final h0 = CardModel.fromCode(hero[0]).rank;
  final h1 = CardModel.fromCode(hero[1]).rank;
  if (h0 != h1) return -1;
  final ranks = {for (final c in board) CardModel.fromCode(c).rank}.toList()
    ..sort((a, b) => b.compareTo(a));
  return ranks.indexOf(h0);
}

void _expectSetDepth(List<String> hero, List<String> board, int want) {
  expect(_setDepth(hero, board), want, reason: 'template');
  for (var seed = 0; seed < 200; seed++) {
    final g = isomorphicLessonCardGroups([hero, board], Random(seed));
    expect(
      _setDepth(g[0], g[1]),
      want,
      reason: 'seed $seed: ${g[0]} on ${g[1]}',
    );
  }
}

void main() {
  test('top set 99 on 987 never remaps to middle/bottom (LPT-411)', () {
    _expectSetDepth(['9h', '9d'], ['9s', '8c', '7h'], 0);
  });

  test('middle set 77 on 7K2 stays middle (LPT-411)', () {
    _expectSetDepth(['7h', '7d'], ['7c', 'Kd', '2s'], 1);
  });

  test('broadway top sets stay top (LPT-411)', () {
    _expectSetDepth(['Kh', 'Kd'], ['Kc', '7s', '2d'], 0);
    _expectSetDepth(['As', 'Ad'], ['Ac', '9s', '4h', '2d', '7c'], 0);
  });
}
