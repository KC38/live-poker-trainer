/// LPT-1030: SoftPulse-quiet densify stage Semantics must not name Working
/// model (coach spoil was LPT-817; a11y label still spoiled via agent tree).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('label-model densify Semantics stay SoftPulse-quiet (LPT-1030)', () {
    final source = File(
      'lib/ui/course/widgets/lesson_table_context.dart',
    ).readAsStringSync();
    expect(
      source,
      isNot(contains('tap working model or permanent verdict')),
    );
    expect(source, isNot(contains('tap working model or insult')));
    expect(
      'Interactive label model — tap a verdict'.allMatches(source).length,
      greaterThanOrEqualTo(3),
    );
  });
}
