/// Meet the TAG design-record must attribute the full-table explain correctly.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Meet the TAG owns Tight/Aggro/Model full-table wording', () {
    final text = File('docs/ui/design-record.md').readAsStringSync();
    expect(
      text.contains(
        'Meet the TAG uses the full poker table for every step: explain taps Tight, Aggro, and Model under the felt.',
      ),
      isTrue,
    );
    expect(
      text.contains(
        'Adjust versus TAG uses the full poker table for every step: explain taps Tight, Aggro, and Model under the felt.',
      ),
      isFalse,
    );
    expect(
      text.contains(
        'Meet the TAG uses the same frame and the full table: explain taps',
      ),
      isTrue,
    );
    expect(
      text.contains(
        'Adjust versus TAG uses the same frame: credit, tighter, and no',
      ),
      isTrue,
    );
  });
}
