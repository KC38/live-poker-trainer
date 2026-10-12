// LPT-384: Name your flop class fixed steps author deal.variants that keep the
// primary spot's hand class and draw outs (suit-rotated isomorphs).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';

const _ids = [
  'act-03-02-01-guided',
  'act-03-02-01-scaffolded',
  'act-03-02-01-unguided',
  'act-03-02-01-checkpoint',
];

int _enc(String c) => FastEvaluator.encode(CardModel.fromCode(c));

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final id in _ids) {
    test('$id variants keep the primary class (LPT-384)', () {
      final deal = catalog.activityById(id)!.teachSpec!['deal'] as Map;
      expect(deal['mode'], 'fixed');
      final primary = deal['fixedCards'] as Map;
      final hero = (primary['hero'] as List).cast<String>();
      final board = ((primary['board'] as List?) ?? const []).cast<String>();
      final variants = (deal['variants'] as List).cast<Map>();
      expect(variants, isNotEmpty);
      for (final v in variants) {
        final fc = v['fixedCards'] as Map;
        final vh = (fc['hero'] as List).cast<String>();
        final vb = ((fc['board'] as List?) ?? const []).cast<String>();
        expect(vh.length, hero.length);
        expect(vb.length, board.length);
        expect({...vh, ...vb}.length, vh.length + vb.length, reason: '$v');
        expect([...vh, ...vb], isNot([...hero, ...board]));
        expect([for (final c in vh) c[0]], [for (final c in hero) c[0]]);
        expect([for (final c in vb) c[0]], [for (final c in board) c[0]]);
        if (board.length >= 3) {
          expect(
            HandClassifier.classify(_enc(vh[0]), _enc(vh[1]), [
              for (final c in vb) _enc(c),
            ]),
            HandClassifier.classify(_enc(hero[0]), _enc(hero[1]), [
              for (final c in board) _enc(c),
            ]),
            reason: '$v',
          );
          expect(
            HandClassifier.drawOuts(_enc(vh[0]), _enc(vh[1]), [
              for (final c in vb) _enc(c),
            ]),
            HandClassifier.drawOuts(_enc(hero[0]), _enc(hero[1]), [
              for (final c in board) _enc(c),
            ]),
            reason: '$v',
          );
        }
      }
    });
  }
}
