/// Flop-class unguided Air feedback never claims a gutshot (LPT-414).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';

int _enc(String code) => FastEvaluator.encode(CardModel.fromCode(code));

Map<String, dynamic>? _find(Object? node, String id) {
  if (node is Map<String, dynamic>) {
    if (node['id'] == id) return node;
    for (final v in node.values) {
      final hit = _find(v, id);
      if (hit != null) return hit;
    }
  } else if (node is List) {
    for (final v in node) {
      final hit = _find(v, id);
      if (hit != null) return hit;
    }
  }
  return null;
}

void main() {
  test('air feedback is honest for 54 on Q72 (LPT-414)', () {
    // Authored source of truth (catalog omits grading.feedback).
    final course = jsonDecode(
      File('content/course/v2/course.json').readAsStringSync(),
    );
    final act = _find(course, 'act-03-02-01-unguided')!;
    final fixed = act['teachSpec']['deal']['fixedCards'];
    expect(fixed['hero'], ['5h', '4h']);
    expect(fixed['board'], ['Qc', '7d', '2s']);
    final air = (act['choices'] as List).firstWhere((c) => c['id'] == 'air');
    final feedback = ((air['grading'] as Map)['feedback'] as String)
        .toLowerCase();
    expect(feedback, isNot(contains('gutshot')));
    expect(feedback, contains('no real draw'));

    // Served catalog still locks the same fixed deal + air choice id.
    final catalog = jsonDecode(
      File('assets/course/v2/catalog.json').readAsStringSync(),
    );
    final catAct = _find(catalog, 'act-03-02-01-unguided')!;
    final catFixed = catAct['teachSpec']['deal']['fixedCards'];
    expect(catFixed['hero'], ['5h', '4h']);
    expect(catFixed['board'], ['Qc', '7d', '2s']);
    final catAir = (catAct['choices'] as List).firstWhere(
      (c) => c['id'] == 'air',
    );
    expect(catAir['id'], 'air');

    final outs = HandClassifier.drawOuts(_enc('5h'), _enc('4h'), [
      _enc('Qc'),
      _enc('7d'),
      _enc('2s'),
    ]);
    expect(outs, lessThan(DrawOuts.weak));
  });
}
