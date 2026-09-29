/// Inherited marker for a step already inside the lesson frame.
library;

import 'package:flutter/material.dart';

/// Activity bodies hide their own coach line so the bubble is the only copy.
class LessonFrameScope extends InheritedWidget {
  /// Creates a scope. [onLocalMiss] grades a tap without a server round-trip.
  const LessonFrameScope({
    super.key,
    required this.onLocalMiss,
    required super.child,
  });

  /// Shows the wrong dock for [feedback].
  final void Function(String feedback) onLocalMiss;

  /// The surrounding frame, if this step is inside one.
  static LessonFrameScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LessonFrameScope>();
  }

  @override
  bool updateShouldNotify(LessonFrameScope oldWidget) => false;
}
