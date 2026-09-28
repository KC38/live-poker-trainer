/// Rex mascot slot: one face, one mood.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Calm Rex portrait used wherever the mascot slot appears.
class RexMascot extends StatelessWidget {
  /// Creates the calm Rex face.
  const RexMascot({super.key, this.size = 36});

  /// Asset path for the calm mood.
  static const asset = 'assets/brand/rex_calm.png';

  /// Diameter of the circular portrait.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Rex, calm',
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
            asset,
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
