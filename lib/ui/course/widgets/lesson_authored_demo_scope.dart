import 'package:flutter/widgets.dart';

/// Authored SoftPulse cue targets for the coach_dialogue explain on screen.
///
/// Curriculum splits (lessonSplitMap) reuse a pre-split explain on the first
/// child lesson. Its dedicated felt demo still lists every tile of the old
/// ladder, so the leftover tiles taught the successors' concepts too
/// (curriculum residual tickets LPT-676..LPT-750). Content now authors only
/// the first child's presses; this scope carries those targets down to the
/// demo so it shows and counts just those tiles.
class LessonAuthoredDemoScope extends InheritedWidget {
  /// Creates the scope.
  const LessonAuthoredDemoScope({
    super.key,
    required this.targets,
    required super.child,
  });

  /// soft_pulse cue targets in press order.
  final List<String> targets;

  /// The nearest scope's targets, or empty when none is installed.
  static List<String> targetsOf(BuildContext context) =>
      context
          .getInheritedWidgetOfExactType<LessonAuthoredDemoScope>()
          ?.targets ??
      const <String>[];

  @override
  bool updateShouldNotify(LessonAuthoredDemoScope oldWidget) {
    if (oldWidget.targets.length != targets.length) return true;
    for (var i = 0; i < targets.length; i++) {
      if (oldWidget.targets[i] != targets[i]) return true;
    }
    return false;
  }
}

String _norm(String s) => s.trim().toUpperCase();

/// The demo [points] this step's authored cues name, in demo order.
///
/// Returns [points] unchanged unless every authored target names a tile
/// (case-insensitive) and the cues cover a strict, non-empty subset, so demos
/// built without a teachSpec (widget tests, standalone previews) keep the full
/// ladder.
List<T> lessonAuthoredDemoPoints<T>(
  BuildContext context,
  List<T> points,
  String Function(T point) labelOf,
) {
  final targets = LessonAuthoredDemoScope.targetsOf(context);
  return lessonAuthoredDemoSubset(targets, points, labelOf);
}

/// Pure form of [lessonAuthoredDemoPoints] for tests and non-widget callers.
List<T> lessonAuthoredDemoSubset<T>(
  List<String> targets,
  List<T> points,
  String Function(T point) labelOf,
) {
  if (targets.isEmpty || points.isEmpty) return points;
  final wanted = {for (final t in targets) _norm(t)};
  final labels = {for (final p in points) _norm(labelOf(p))};
  if (!wanted.every(labels.contains)) return points;
  final kept = [
    for (final p in points)
      if (wanted.contains(_norm(labelOf(p)))) p,
  ];
  if (kept.isEmpty || kept.length >= points.length) return points;
  return kept;
}
