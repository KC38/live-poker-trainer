/// Luxury dark-felt color palette for the Exploitative Poker Lab.
library;

import 'package:flutter/material.dart';

/// Brand and UI colors (emerald felt, gold accents, navy charcoal, 4-color deck).
class AppColors {
  AppColors._();

  // Atmosphere — navy charcoal, not flat black
  static const Color bgDark = Color(0xFF0A0E16);
  static const Color bgMid = Color(0xFF141C2B);
  static const Color bgElevated = Color(0xFF1A2436);
  static const Color surfaceMuted = Color(0xFF1E2A3D);

  // Felt
  static const Color feltDark = Color(0xFF053528);
  static const Color feltLight = Color(0xFF0C4A35);
  static const Color feltRim = Color(0xFF1F1408);
  static const Color feltBorder = Color(0xFF6B4A22);

  // Accents
  static const Color gold = Color(0xFFD4A84B);
  static const Color goldBright = Color(0xFFE8C878);
  static const Color goldMuted = Color(0xFFA67C2E);
  static const Color slate = Color(0xFF8B9BB0);
  static const Color slateDark = Color(0xFF2A3548);
  static const Color cream = Color(0xFFF4F1EA);
  static const Color danger = Color(0xFFE05252);
  static const Color success = Color(0xFF2DB87A);
  static const Color warning = Color(0xFFE5A84B);

  // 4-color deck
  static const Color spades = Color(0xFF0F172A);
  static const Color hearts = Color(0xFFDC2626);
  static const Color diamonds = Color(0xFF2563EB);
  static const Color clubs = Color(0xFF16A34A);

  // Archetypes — restrained, readable on dark
  static const Color maniac = Color(0xFFE07A3A);
  static const Color nit = Color(0xFF7A8A9A);
  static const Color station = Color(0xFF3AA8B8);
  static const Color tag = Color(0xFF6B7FD7);
  static const Color lag = Color(0xFFC46B8A);
  static const Color hero = Color(0xFFD4A84B);
}
