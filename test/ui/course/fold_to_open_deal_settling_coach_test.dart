/// Fold weak hands densify coach waits for the open to paint (LPT-1019).
///
/// Catalog prompts name `UTG opens to 6` before street money reveals. Mid-deal
/// frame speech must not keep that amount lead; after the open paints, idle
/// densify may name it.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';

const _id = 'act-02-04-01-guided-fold';

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  test('dealSettlingLeadNamesStreetMoney catches opens / raises / bets', () {
    expect(dealSettlingLeadNamesStreetMoney('UTG opens to 6'), isTrue);
    expect(dealSettlingLeadNamesStreetMoney('BTN opens to 6'), isTrue);
    expect(dealSettlingLeadNamesStreetMoney('Villain bets 5'), isTrue);
    expect(dealSettlingLeadNamesStreetMoney('CO 3-bets to 18'), isTrue);
    expect(dealSettlingLeadNamesStreetMoney('Nit in BB'), isFalse);
    expect(dealSettlingLeadNamesStreetMoney(''), isFalse);
  });

  test('$_id deal-settling speech drops open amount lead', () {
    final activity = catalog.activityById(_id);
    expect(activity, isNotNull, reason: _id);
    final settling = lessonFrameDealSettlingSpeech(activity!);
    expect(settling.toLowerCase(), contains('watch the deal'));
    expect(settling.toLowerCase(), isNot(contains('opens to')));
    expect(settling.toLowerCase(), isNot(contains('utg')));
    expect(settling, isNot(contains(RegExp(r'\b6\b'))));
    expect(settling.toLowerCase(), contains('tap'));
  });

  test('steal-more settling still keeps Nit lead without hole combos', () {
    final activity = catalog.activityById('act-04-07-03-guided');
    expect(activity, isNotNull);
    final settling = lessonFrameDealSettlingSpeech(activity!);
    expect(settling.toLowerCase(), contains('nit'));
    expect(settling.toLowerCase(), contains('watch the deal'));
    expect(settling.toLowerCase(), isNot(contains('you have')));
  });
}
