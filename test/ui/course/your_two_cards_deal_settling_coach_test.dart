/// Your two cards densify mid-deal coach omits quiz footer (LPT-1026).
///
/// Felt-tap select_identify defaults `lessonTapInstruction` to
/// "Tap the best answer." — that must not append during
/// [lessonFrameDealSettlingSpeech] while the flop is still landing.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';

const _ids = <String>[
  'act-01-01-01-scaffolded-private',
  'act-01-01-01-unguided-mix',
  'act-01-01-01-checkpoint-table',
];

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final id in _ids) {
    test('$id deal-settling speech is Watch the deal without quiz footer', () {
      final activity = catalog.activityById(id);
      expect(activity, isNotNull, reason: id);
      final settling = lessonFrameDealSettlingSpeech(activity!);
      expect(settling.toLowerCase(), contains('watch the deal'));
      expect(settling.toLowerCase(), isNot(contains('best answer')));
      expect(settling, equals('Watch the deal.'));
    });
  }

  test('poker_action densify settling still keeps dock tap instruction', () {
    final activity = catalog.activityById('act-04-07-03-guided');
    expect(activity, isNotNull);
    final settling = lessonFrameDealSettlingSpeech(activity!);
    expect(settling.toLowerCase(), contains('watch the deal'));
    expect(settling.toLowerCase(), contains('tap'));
    expect(settling.toLowerCase(), isNot(contains('best answer')));
  });
}
