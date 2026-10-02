/// SoftPulse allow/deny flag for the current lesson frame wave.
library;

import 'package:flutter/material.dart';

/// Tells SoftPulse widgets whether the current Hint wave may glow.
///
/// Multi-press teach steps SoftPulse only the first press (or a Hint
/// re-open). [LessonActivityController.showTargetCue] drives [allowed].
class LessonSoftPulseScope extends InheritedWidget {
  /// Creates a SoftPulse allow scope.
  const LessonSoftPulseScope({
    super.key,
    required this.allowed,
    required super.child,
  });

  /// When false, [GlowHighlight] SoftPulse rings stay off inside this frame.
  final bool allowed;

  /// Whether SoftPulse may show. Defaults to true outside a lesson frame.
  static bool isAllowed(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<LessonSoftPulseScope>()
            ?.allowed ??
        true;
  }

  @override
  bool updateShouldNotify(LessonSoftPulseScope oldWidget) =>
      allowed != oldWidget.allowed;
}
