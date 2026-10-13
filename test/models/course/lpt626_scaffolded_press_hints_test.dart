/// LPT-626: every scaffolded non-assessment step authors
/// `teachSpec.pressHints`, so Hint never falls back to `accessibilityText`
/// (which often spells out the answer).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';

const _scaffolded = <String>[
  'act-01-01-03-scaffolded-blinds',
  'act-01-01-03-unguided-when',
  'act-01-02-01-scaffolded-spot',
  'act-01-02-01-unguided-compare',
  'act-01-02-02-checkpoint-build',
  'act-01-02-02-scaffolded-kicker',
  'act-01-02-02-unguided-board',
  'act-01-03-01-scaffolded-check',
  'act-01-03-01-unguided-call',
  'act-01-03-02-scaffolded-raise',
  'act-01-03-02-unguided-allin',
  'act-01-04-01-scaffolded-order',
  'act-01-04-01-unguided-end',
  'act-01-05-01-scaffolded-showdown',
  'act-01-05-01-unguided-pot',
  'act-01-06-01-scaffolded-multi',
  'act-01-06-01-unguided-lab',
  'act-02-01-01-scaffolded-blinds',
  'act-02-01-01-unguided-co',
  'act-02-01-02-scaffolded-post',
  'act-02-01-02-unguided-wait',
  'act-02-02-01-scaffolded-broadway',
  'act-02-02-01-unguided-sc',
  'act-02-03-01-scaffolded-qq',
  'act-02-03-01-unguided-btn',
  'act-02-04-01-scaffolded-call',
  'act-02-04-01-unguided-3bet',
  'act-02-05-01-scaffolded-eff',
  'act-02-05-01-unguided-depth',
  'act-02-06-01-scaffolded-verbal',
  'act-02-06-01-unguided-protect',
  'act-02-07-01-scaffolded-vs',
  'act-02-07-01-unguided-lab',
  'act-03-01-01-scaffolded',
  'act-03-01-01-unguided',
  'act-03-02-01-scaffolded',
  'act-03-02-01-unguided',
  'act-03-03-01-scaffolded',
  'act-03-03-01-unguided',
  'act-03-04-01-scaffolded',
  'act-03-04-01-unguided',
  'act-03-05-01-scaffolded',
  'act-03-05-01-unguided',
  'act-03-06-01-scaffolded',
  'act-03-06-01-unguided',
  'act-03-07-01-scaffolded',
  'act-03-07-01-unguided',
  'act-03-08-01-scaffolded',
  'act-03-08-01-unguided',
  'act-04-01-01-scaffolded',
  'act-04-01-01-unguided',
  'act-04-02-01-scaffolded',
  'act-04-02-01-unguided',
  'act-04-03-01-scaffolded',
  'act-04-03-01-unguided',
  'act-04-04-01-scaffolded',
  'act-04-04-01-unguided',
  'act-04-05-01-scaffolded',
  'act-04-05-01-unguided',
  'act-04-06-01-scaffolded',
  'act-04-06-01-unguided',
  'act-04-06-02-scaffolded',
  'act-04-06-02-unguided',
  'act-04-06-03-scaffolded',
  'act-04-06-03-unguided',
  'act-04-07-01-scaffolded',
  'act-04-07-01-unguided',
  'act-04-07-02-unguided',
  'act-04-07-03-scaffolded',
  'act-04-07-03-unguided',
  'act-04-08-01-scaffolded',
  'act-04-08-01-unguided',
  'act-04-08-02-unguided',
  'act-04-08-03-scaffolded',
  'act-04-08-03-unguided',
  'act-04-09-01-scaffolded',
  'act-04-09-01-unguided',
  'act-04-10-01-scaffolded',
  'act-04-10-01-unguided',
  'act-05-01-01-scaffolded',
  'act-05-01-01-unguided',
  'act-05-02-01-scaffolded',
  'act-05-02-01-unguided',
  'act-05-03-01-scaffolded',
  'act-05-03-01-unguided',
  'act-05-04-01-scaffolded',
  'act-05-04-01-unguided',
  'act-05-05-01-scaffolded',
  'act-05-05-01-unguided',
  'act-05-06-01-scaffolded',
  'act-05-06-01-unguided',
  'act-05-07-01-scaffolded',
  'act-05-07-01-unguided',
  'act-05-08-01-scaffolded',
  'act-05-08-01-unguided',
  'act-05-09-01-scaffolded',
  'act-05-09-01-unguided',
  'act-06-01-01-scaffolded',
  'act-06-01-01-unguided',
  'act-06-02-01-scaffolded',
  'act-06-02-01-unguided',
  'act-06-03-01-scaffolded',
  'act-06-03-01-unguided',
  'act-06-04-01-scaffolded',
  'act-06-04-01-unguided',
  'act-06-05-01-scaffolded',
  'act-06-05-01-unguided',
  'act-06-06-01-scaffolded',
  'act-06-06-01-unguided',
  'act-06-07-01-scaffolded',
  'act-06-07-01-unguided',
  'act-06-08-01-scaffolded',
  'act-06-08-01-unguided',
  'act-06-09-01-scaffolded',
  'act-06-09-01-unguided',
  'act-06-10-01-scaffolded',
  'act-06-10-01-unguided',
  'act-06-11-01-scaffolded',
  'act-06-11-01-unguided',
  'act-06-11-02-scaffolded',
  'act-06-11-02-unguided',
  'act-06-11-03-scaffolded',
  'act-06-11-03-unguided',
  'act-06-12-01-scaffolded',
  'act-06-12-01-unguided',
  'act-06-12-02-scaffolded',
  'act-06-12-02-unguided',
  'act-06-12-03-scaffolded',
  'act-06-12-03-unguided',
  'act-06-13-01-scaffolded',
  'act-06-13-01-unguided',
  'act-07-01-01-scaffolded',
  'act-07-01-01-unguided',
  'act-07-02-01-scaffolded',
  'act-07-02-01-unguided',
  'act-07-03-01-scaffolded',
  'act-07-03-01-unguided',
  'act-07-04-01-scaffolded',
  'act-07-04-01-unguided',
  'act-07-05-01-scaffolded',
  'act-07-05-01-unguided',
  'act-07-06-01-scaffolded',
  'act-07-06-01-unguided',
  'act-07-07-01-scaffolded',
  'act-07-07-01-unguided',
  'act-07-08-01-scaffolded',
  'act-07-08-01-unguided',
  'act-07-09-01-scaffolded',
  'act-07-09-01-unguided',
  'act-07-11-01-scaffolded',
  'act-07-11-01-unguided',
];

final _cardCode = RegExp(r'\b[2-9TJQKA][hdcs]\b');
final _handShorthand = RegExp(r'\b[2-9TJQKA]{2}[so]?\b');

void main() {
  late CourseCatalog catalog;
  setUpAll(() {
    catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  test('scaffolded steps author class-language pressHints (LPT-626)', () {
    expect(_scaffolded, hasLength(151));
    for (final id in _scaffolded) {
      final a = catalog.activityById(id);
      expect(a, isNotNull, reason: id);
      expect(a!.stage, ActivityStage.scaffolded, reason: id);
      final hints = a.teachSpec?['pressHints'] as List<dynamic>?;
      expect(hints, isNotNull, reason: '$id needs pressHints');
      expect(hints, isNotEmpty, reason: id);
      final first = hints!.first as Map<String, dynamic>;
      expect(first['press'], 1, reason: id);
      final text = (first['text'] as String).trim();
      expect(text, isNotEmpty, reason: id);
      expect(text.length, lessThanOrEqualTo(80), reason: id);
      expect(text, isNot(a.accessibilityText.trim()), reason: id);
      expect(_cardCode.hasMatch(text), isFalse, reason: '$id names a card');
      expect(
        _handShorthand.hasMatch(text),
        isFalse,
        reason: '$id names a hand',
      );
    }
  });

  test('Hint prefers the authored press-1 line (LPT-626)', () {
    final a = catalog.activityById('act-04-06-01-scaffolded')!;
    expect(
      lessonFrameHintFallback(a),
      'Calling down again and again says they rarely fold.',
    );
  });

  test('showdown-order Hint stays seat-aware over pressHints (LPT-626)', () {
    final a = catalog.activityById('act-01-02-01-scaffolded-spot')!;
    final hint = lessonFrameHintFallback(a);
    expect(hint, isNotNull);
    expect(hint, startsWith('Showdown — tap'));
  });
}
