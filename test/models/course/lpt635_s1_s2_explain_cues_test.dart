/// LPT-635: every Section 1–2 SoftPulse explain authors `teachSpec`
/// (`deal.mode` `none` + one `soft_pulse` cue per demo press) in the order
/// the Dart explain table golds. Curriculum residuals (LPT-731..LPT-749)
/// shrank reused first-child explains to their own concept's presses; the
/// demo shows only those tiles, so cues name a subset of the tile labels.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_streets.dart';

const _explains = <String, List<String>>{
  'act-01-03-01-explain-passive': ['FOLD'],
  'act-01-03-02-explain-aggro': ['BET'],
  'act-01-04-01-explain-streets': ['PREFLOP', 'FLOP', 'TURN', 'RIVER'],
  'act-01-05-01-explain-win': ['FOLD WIN'],
  'act-01-06-01-explain-run': ['BLINDS', 'YOU ACT', 'ENDING'],
  'act-02-01-01-explain-pos': ['D'],
  'act-02-01-02-explain-order': ['UTG', 'HJ', 'CO', 'BTN'],
  'act-02-02-01-explain-families': ['Pairs'],
  'act-02-03-01-explain-open': ['EARLY'],
  'act-02-04-01-explain-vs': ['FOLD'],
  'act-02-05-01-explain-bb': ['CHIPS→BB'],
  'act-02-07-01-explain-full': ['NINE', 'SAME', 'POSITION'],
};

void main() {
  late CourseCatalog catalog;
  setUpAll(() {
    catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  for (final entry in _explains.entries) {
    test('${entry.key} SoftPulse walks ${entry.value.join(' → ')}', () {
      final a = catalog.activityById(entry.key)!;
      expect(a.teachSpec, isNotNull);
      expect(a.teachSpec!['deal'], {'mode': 'none'});
      final cues = [
        for (final e in a.teachSpec!['cues'] as List<dynamic>)
          Map<String, dynamic>.from(e as Map),
      ];
      expect([for (final c in cues) c['target']], entry.value);
      expect([
        for (final c in cues) c['press'],
      ], List<int>.generate(entry.value.length, (i) => i + 1));
      expect(cues.every((c) => c['kind'] == 'soft_pulse'), isTrue);
      expect(a.teachSpec!.containsKey('pressHints'), isFalse);
    });
  }

  test('cue targets name Dart demo tile labels', () {
    expect([
      for (final a in PassiveActionsDemo.actions) a.$1,
    ], containsAll(_explains['act-01-03-01-explain-passive']!));
    expect([
      for (final a in AggressiveActionsDemo.actions) a.$1,
    ], containsAll(_explains['act-01-03-02-explain-aggro']!));
    expect([
      for (final s in StreetsTimelineDemo.streets) s.title,
    ], containsAll(_explains['act-01-04-01-explain-streets']!));
    expect([
      for (final p in OpenRangeDemo.points) p.label,
    ], containsAll(_explains['act-02-03-01-explain-open']!));
    expect([
      for (final r in VsOpenResponseDemo.responses) r.label,
    ], containsAll(_explains['act-02-04-01-explain-vs']!));
    expect([
      for (final p in BbStackDepthDemo.points) p.label,
    ], containsAll(_explains['act-02-05-01-explain-bb']!));
    expect([
      for (final p in FullRingDemo.points) p.label,
    ], containsAll(_explains['act-02-07-01-explain-full']!));
  });
}
