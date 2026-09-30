/// Shared teach-felt height: screen fraction clamped to the lesson stage.
library;

import 'package:flutter/widgets.dart';

/// Max fraction of screen height densified teach felts request.
///
/// When Nice! / Continue shrinks the [LessonScreenLayout] stage below this
/// fraction of the real screen, clamp (or rewrite MediaQuery height) so the
/// felt never asks for more than the stage can give.
const double kTeachFeltHeightFactor = 0.58;

/// Returns [preferred] unless the parent max height is shorter.
double clampTeachFeltHeight(
  BoxConstraints constraints, {
  required double preferred,
}) {
  if (constraints.hasBoundedHeight &&
      constraints.maxHeight.isFinite &&
      constraints.maxHeight < preferred) {
    return constraints.maxHeight;
  }
  return preferred;
}

/// MediaQuery height so `height * [factor]` still fits in [stageMaxHeight].
double teachStageMediaHeight({
  required double screenHeight,
  required double stageMaxHeight,
  double factor = kTeachFeltHeightFactor,
}) {
  if (!stageMaxHeight.isFinite || stageMaxHeight <= 0 || factor <= 0) {
    return screenHeight;
  }
  final capped = stageMaxHeight / factor;
  return capped < screenHeight ? capped : screenHeight;
}
