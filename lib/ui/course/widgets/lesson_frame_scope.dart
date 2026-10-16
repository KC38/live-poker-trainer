/// Inherited marker for a step already inside the lesson frame.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';

/// Activity bodies hide their own coach line so the bubble is the only copy.
class LessonFrameScope extends InheritedWidget {
  /// Creates a scope. [onLocalMiss] grades a tap without a server round-trip.
  const LessonFrameScope({
    super.key,
    required this.onLocalMiss,
    this.activityController,
    this.playBlocked = false,
    required super.child,
  });

  /// Shows the wrong dock for [feedback].
  final void Function(String feedback) onLocalMiss;

  /// Shared activity controller for SoftPulse / Hint coordination.
  final LessonActivityController? activityController;

  /// True while the hearts gate (or another runner block) freezes play.
  ///
  /// Densify [LessonActionDock] must stay disabled when this is set — not only
  /// SoftPulse / Hint (LPT-1017). AbsorbPointer alone still left dock chrome
  /// looking live while coach invited a tap.
  final bool playBlocked;

  /// The surrounding frame, if this step is inside one.
  static LessonFrameScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LessonFrameScope>();
  }

  /// Whether densify docks / auto-submit must stay inert.
  static bool playIsBlocked(BuildContext context) {
    return maybeOf(context)?.playBlocked ?? false;
  }

  @override
  bool updateShouldNotify(LessonFrameScope oldWidget) =>
      activityController != oldWidget.activityController ||
      playBlocked != oldWidget.playBlocked;
}

/// Tells the frame how many multi-press taps remain.
///
/// Pass a positive count while SoftPulse targets remain; pass `0` when the
/// sequence is finished. Hint re-enables only after
/// [consumeLessonSequentialSoftPulse] closes the current wave. SoftPulse
/// itself is gated by [LessonActivityController.showTargetCue].
void reportLessonSequentialPressProgress(
  BuildContext context, {
  required int remainingPressCount,
}) {
  LessonFrameScope.maybeOf(context)
      ?.activityController
      ?.notifySequentialPressProgress(
        remainingPressCount: remainingPressCount,
      );
}

/// Ends the SoftPulse wave after the learner taps the cued target.
///
/// Later presses stay quiet until Hint re-opens a one-press SoftPulse wave.
void consumeLessonSequentialSoftPulse(BuildContext context) {
  LessonFrameScope.maybeOf(context)
      ?.activityController
      ?.consumeSequentialSoftPulse();
}

/// Felt deal completeness — SoftPulse stays off until [ready].
void reportLessonFeltDealReady(BuildContext context, {required bool ready}) {
  LessonFrameScope.maybeOf(context)
      ?.activityController
      ?.notifyFeltDealReady(ready);
}
