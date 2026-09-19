/// Tests for coach action-label sizing helpers.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';

void main() {
  group('ChipFormat.isSizedAction', () {
    test('treats ALL_IN as sized after underscore normalization', () {
      expect(ChipFormat.isSizedAction('ALL-IN'), isTrue);
      expect(ChipFormat.isSizedAction('ALL_IN'), isTrue);
      expect(ChipFormat.isSizedAction('RAISE'), isTrue);
      expect(ChipFormat.isSizedAction('BET'), isTrue);
      expect(ChipFormat.isSizedAction('CALL'), isFalse);
      expect(ChipFormat.isSizedAction('FOLD'), isFalse);
    });
  });

  group('ChipFormat.optimalLine', () {
    test('appends size for ALL_IN labels from authored keys', () {
      expect(
        ChipFormat.optimalLine(
          actionLabel: 'ALL-IN',
          sizingBb: 100,
          bigBlind: 2,
          mode: ChipDisplayMode.dollars,
        ),
        'ALL-IN · \$200',
      );
      expect(
        ChipFormat.optimalLine(
          actionLabel: 'CALL',
          sizingBb: 7,
          bigBlind: 2,
          mode: ChipDisplayMode.dollars,
        ),
        'CALL',
      );
    });
  });
}
