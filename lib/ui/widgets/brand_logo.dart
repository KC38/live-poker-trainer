/// Scalable brand mark for Exploitative Poker Lab.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Gold spade mark from [asset], drawn with a transparent background.
class BrandLogo extends StatelessWidget {
  /// Creates a square brand logo of [size] logical pixels.
  const BrandLogo({super.key, this.size = 64});

  /// SVG source of truth for the mark (also used to rasterize app icons).
  static const String asset = 'assets/brand/logo_mark.svg';

  /// Width and height of the rendered mark.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      semanticsLabel: 'Exploitative Poker Lab',
      placeholderBuilder: (context) => Icon(
        Icons.style,
        size: size * 0.78,
        color: AppColors.gold,
      ),
    );
  }
}
