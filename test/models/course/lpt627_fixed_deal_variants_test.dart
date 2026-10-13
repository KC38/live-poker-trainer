/// LPT-627: every fixed `teachSpec.deal` in the catalog authors
/// `deal.variants`, and each variant is a suit-rotated isomorph of the primary
/// spot (same ranks, no duplicate cards, same hand class and draw outs), so
/// cues and grading still fit every variant.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';

int _enc(String c) => FastEvaluator.encode(CardModel.fromCode(c));

bool _suited(List<String> cs) =>
    cs.length == 2 && cs[0].substring(1) == cs[1].substring(1);

void main() {
  late List<CourseActivity> fixed;
  setUpAll(() {
    final catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    fixed = [
      for (final section in catalog.sections)
        for (final unit in section.units)
          for (final lesson in unit.lessons)
            for (final a in lesson.activities)
              if ((a.teachSpec?['deal'] as Map?)?['mode'] == 'fixed') a,
    ];
  });

  test('every fixed deal authors deal.variants (LPT-627)', () {
    expect(fixed.length, greaterThanOrEqualTo(99));
    final missing = [
      for (final a in fixed)
        if (((a.teachSpec!['deal'] as Map)['variants'] as List?)?.isEmpty ??
            true)
          a.id,
    ];
    expect(missing, isEmpty);
  });

  test('variants keep ranks, suitedness, class, and draw outs', () {
    for (final a in fixed) {
      final deal = a.teachSpec!['deal'] as Map;
      final primary = deal['fixedCards'] as Map;
      final hero = (primary['hero'] as List).cast<String>();
      final board = ((primary['board'] as List?) ?? const []).cast<String>();
      for (final v in (deal['variants'] as List).cast<Map>()) {
        final fc = v['fixedCards'] as Map?;
        if (fc == null) continue; // class-only variants (random_in_class)
        final vh = (fc['hero'] as List).cast<String>();
        final vb = ((fc['board'] as List?) ?? const []).cast<String>();
        final why = '${a.id} ${v['id']}';
        expect(vh.length, hero.length, reason: why);
        expect(vb.length, board.length, reason: why);
        expect({...vh, ...vb}.length, vh.length + vb.length, reason: why);
        expect([for (final c in vh) c[0]], [for (final c in hero) c[0]]);
        expect([for (final c in vb) c[0]], [for (final c in board) c[0]]);
        expect(_suited(vh), _suited(hero), reason: why);
        if (board.length >= 3) {
          final vBoard = [for (final c in vb) _enc(c)];
          final pBoard = [for (final c in board) _enc(c)];
          expect(
            HandClassifier.classify(_enc(vh[0]), _enc(vh[1]), vBoard),
            HandClassifier.classify(_enc(hero[0]), _enc(hero[1]), pBoard),
            reason: why,
          );
          expect(
            HandClassifier.drawOuts(_enc(vh[0]), _enc(vh[1]), vBoard),
            HandClassifier.drawOuts(_enc(hero[0]), _enc(hero[1]), pBoard),
            reason: why,
          );
        }
      }
    }
  });
}
