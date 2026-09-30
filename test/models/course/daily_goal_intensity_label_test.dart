/// Unit tests for daily goal intensity trailing labels.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';

void main() {
  test('maps each daily goal choice to a Duolingo-style intensity label', () {
    expect(dailyGoalIntensityLabel(5), 'Casual');
    expect(dailyGoalIntensityLabel(10), 'Regular');
    expect(dailyGoalIntensityLabel(15), 'Serious');
    expect(dailyGoalIntensityLabel(20), 'Intense');
  });

  test('returns empty string for unknown minute values', () {
    expect(dailyGoalIntensityLabel(0), isEmpty);
    expect(dailyGoalIntensityLabel(30), isEmpty);
  });

  test('every kDailyGoalChoices entry has a non-empty intensity label', () {
    for (final minutes in kDailyGoalChoices) {
      expect(dailyGoalIntensityLabel(minutes), isNotEmpty);
    }
  });
}
