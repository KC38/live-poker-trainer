/// Unit tests for teach-felt height clamping helpers.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/teach_felt_height.dart';

void main() {
  test('clampTeachFeltHeight keeps preferred when stage is taller', () {
    const preferred = 400.0;
    final height = clampTeachFeltHeight(
      const BoxConstraints(maxHeight: 500),
      preferred: preferred,
    );
    expect(height, preferred);
  });

  test('clampTeachFeltHeight shrinks to the stage max', () {
    final height = clampTeachFeltHeight(
      const BoxConstraints(maxHeight: 350),
      preferred: 400,
    );
    expect(height, 350);
  });

  test('teachStageMediaHeight leaves full screen when stage fits 0.58', () {
    // Stage 500 can hold 0.58 * 812 ≈ 471.
    expect(
      teachStageMediaHeight(screenHeight: 812, stageMaxHeight: 500),
      812,
    );
  });

  test('teachStageMediaHeight caps when the answer dock shrinks the stage', () {
    // Stage 410 cannot hold 0.58 * 812 ≈ 471 — rewrite so 0.58 * media = 410.
    expect(
      teachStageMediaHeight(screenHeight: 812, stageMaxHeight: 410),
      moreOrLessEquals(410 / kTeachFeltHeightFactor, epsilon: 0.01),
    );
  });
}
