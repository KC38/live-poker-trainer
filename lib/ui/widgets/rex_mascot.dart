/// Rex mascot slot: one full-body coach, two moods.
library;

import 'package:flutter/material.dart';

/// Mood of the Rex drawing. The prompt stays calm.
enum RexMood {
  /// Teaching prompt.
  calm,

  /// Right-answer beat.
  celebrate,
}

/// Full-body Rex for the prompt (calm) and a right answer (celebrating).
class RexMascot extends StatelessWidget {
  /// Creates Rex. Defaults to the calm standing drawing.
  const RexMascot({super.key, this.size = 36, this.mood = RexMood.calm});

  /// Asset path for the calm mood.
  static const asset = 'assets/brand/mascot_idle.png';

  /// Asset path for the celebrating mood.
  static const celebrateAsset = 'assets/brand/mascot_celebrate.png';

  /// Width of the figure. Height follows the full-body drawing.
  final double size;

  /// Which drawing to show.
  final RexMood mood;

  String get _asset {
    return switch (mood) {
      RexMood.calm => asset,
      RexMood.celebrate => celebrateAsset,
    };
  }

  String get _label {
    return switch (mood) {
      RexMood.calm => 'Rex, calm',
      RexMood.celebrate => 'Rex, celebrating',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      image: true,
      label: _label,
      child: _CelebrateEntrance(
        enabled: mood == RexMood.celebrate,
        child: SizedBox(
          width: size,
          height: size * 1.5,
          child: Image.asset(
            _asset,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}

/// Short rise-in for a right answer. It finishes, so tests can settle.
class _CelebrateEntrance extends StatelessWidget {
  const _CelebrateEntrance({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  static const duration = Duration(milliseconds: 420);

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.86, end: 1),
      duration: duration,
      curve: Curves.easeOutBack,
      child: child,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
    );
  }
}
