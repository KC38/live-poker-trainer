/// Tests that successful heart refills do not show confirmation snackbars.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/widgets/heart_refill_sheet.dart';

void main() {
  RefillCourseHeartsResult result({
    required String method,
    int heartsRestored = 1,
    int livesRemaining = 3,
    int livesMax = 5,
  }) {
    return RefillCourseHeartsResult(
      method: method,
      livesRemaining: livesRemaining,
      livesMax: livesMax,
      heartsRestored: heartsRestored,
      gems: 100,
      gemsSpent: 0,
      duplicate: false,
    );
  }

  test('suppresses Heart restored x/max toast after an ad claim', () {
    expect(
      heartRefillSuccessSnackBarMessage(
        result(method: 'ad', livesRemaining: 2, livesMax: 5),
      ),
      isNull,
    );
  });

  test('suppresses Hearts refilled toast after a gem refill', () {
    expect(
      heartRefillSuccessSnackBarMessage(
        result(
          method: 'gems',
          heartsRestored: 5,
          livesRemaining: 5,
          livesMax: 5,
        ),
      ),
      isNull,
    );
  });

  test('suppresses toast when the server reports zero hearts restored', () {
    expect(
      heartRefillSuccessSnackBarMessage(
        result(method: 'ad', heartsRestored: 0),
      ),
      isNull,
    );
  });
}
