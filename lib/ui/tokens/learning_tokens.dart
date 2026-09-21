/// Shared spacing, radii, and layout tokens for learning UI.
///
/// Extracted so Learn/Practice/Progress/You can share layout without forking
/// the felt/gold theme in [app_theme.dart].
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Layout constants for the learning shell and lesson surfaces.
abstract final class LearningTokens {
  /// Minimum interactive target size.
  static const double minTapTarget = 48;

  /// Standard page horizontal padding.
  static const double pagePadding = 20;

  /// Section vertical gap.
  static const double sectionGap = 24;

  /// Card / panel corner radius.
  static const double panelRadius = 16;

  /// Path node diameter.
  static const double pathNodeSize = 56;

  /// Breakpoint shared with the felt table layout.
  static const double wideBreakpoint = 900;

  /// Panel decoration matching Home elevated panels.
  static BoxDecoration panelDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.bgElevated,
      borderRadius: BorderRadius.circular(panelRadius),
      border: Border.all(color: AppColors.slateDark.withValues(alpha: 0.7)),
    );
  }
}
