// LPT-353: Suits and ranks SoftPulse explain authors teachSpec (deal none + cues).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';

void main() {
  test('act-01-01-02-explain-suits SoftPulse walks hearts → diamonds → clubs → spades (LPT-353)', () {
    final catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final a = catalog.activityById('act-01-01-02-explain-suits')!;
    expect(a.teachSpec!['deal'], {'mode': 'none'});
    final cues = [
      for (final e in a.teachSpec!['cues'] as List<dynamic>)
        Map<String, dynamic>.from(e as Map),
    ];
    expect(
      [for (final c in cues) c['target']],
      ['hearts', 'diamonds', 'clubs', 'spades'],
    );
    expect([for (final c in cues) c['press']], [1, 2, 3, 4]);
    expect(cues.every((c) => c['kind'] == 'soft_pulse'), isTrue);
    expect(a.teachSpec!.containsKey('pressHints'), isFalse);
  });
}
