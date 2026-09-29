/// Rex mascot slot: one face, two moods.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Mood of the Rex portrait. The prompt stays calm.
enum RexMood {
  /// Teaching prompt.
  calm,

  /// Right-answer beat.
  celebrate,
}

/// Rex portrait for the prompt (calm) and a right answer (celebrating).
class RexMascot extends StatelessWidget {
  /// Creates a Rex face. Defaults to the calm prompt portrait.
  const RexMascot({super.key, this.size = 36, this.mood = RexMood.calm});

  /// Asset path for the calm mood.
  static const asset = 'assets/brand/rex_calm.png';

  /// Asset path for the celebrating mood.
  static const celebrateAsset = 'assets/brand/rex_celebrate.png';

  /// Diameter of the circular portrait.
  final double size;

  /// Which portrait to show.
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
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.55),
            width: 1.2,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            _asset,
            width: size,
            height: size,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
