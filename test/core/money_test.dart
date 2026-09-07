/// Tests for cent-exact chip math and crash-safe range clamping.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/money.dart';

void main() {
  group('Money.round', () {
    test('removes binary floating point dust', () {
      expect(Money.round(450.99999999999994), 451.0);
      expect(Money.round(0.1 + 0.2), 0.3);
      expect(Money.round(1 / 3), 0.33);
    });

    test('normalizes negative zero and non-finite input', () {
      expect(Money.round(-0.0), 0.0);
      expect(Money.round(double.nan), 0.0);
      expect(Money.round(double.infinity), 0.0);
    });

    test('roundNonNegative floors at zero', () {
      expect(Money.roundNonNegative(-0.004), 0.0);
      expect(Money.roundNonNegative(-12.5), 0.0);
      expect(Money.roundNonNegative(12.344), 12.34);
    });
  });

  group('Money.clamp', () {
    test('behaves like num.clamp for a valid range', () {
      expect(Money.clamp(5, 0, 10), 5);
      expect(Money.clamp(-1, 0, 10), 0);
      expect(Money.clamp(99, 0, 10), 10);
    });

    test('returns the lower bound instead of throwing on an inverted range', () {
      // num.clamp(451.0, 400.0) throws ArgumentError: Invalid argument(s): 451.0
      expect(() => (300.0).clamp(451.0, 400.0), throwsArgumentError);
      expect(Money.clamp(300, 451, 400), 451);
    });

    test('survives non-finite input', () {
      expect(Money.clamp(double.nan, 4, 10), 4);
      expect(Money.clamp(5, double.nan, double.nan), 0);
    });
  });

  group('Money comparisons', () {
    test('same is cent tolerant', () {
      expect(Money.same(10.0, 10.0000001), isTrue);
      expect(Money.same(10.0, 10.02), isFalse);
    });

    test('atLeast is cent tolerant', () {
      expect(Money.atLeast(9.999999, 10), isTrue);
      expect(Money.atLeast(9.9, 10), isFalse);
    });
  });
}
