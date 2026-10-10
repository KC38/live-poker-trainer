/// Luxury dark-felt color palette for the Exploitative Poker Lab.
///
/// Agent handbook: `docs/agents/06-ui-and-preferences.md`.
///
/// Navy charcoal + emerald felt + gold + cream. [navRing] / [selectionGlow]
/// are the Duolingo-style cyan accents — keep gold for coach cues and cyan
/// for nav/selection so they stay distinct.
library;

import 'package:flutter/material.dart';

/// Brand and UI colors (emerald felt, gold accents, navy charcoal, 2-color deck).
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
  /// Active bottom-nav ring (Duolingo-style cyan on dark navy).
  static const Color navRing = Color(0xFF49C0F8);
  /// Learner tap selection on felt cards (distinct from gold coach cues).
  static const Color selectionGlow = Color(0xFF5EC8F8);
  static const Color danger = Color(0xFFE05252);
  static const Color success = Color(0xFF2DB87A);
  static const Color warning = Color(0xFFE5A84B);

  // Standard 2-color deck: black (clubs/spades), red (hearts/diamonds)
  static const Color spades = Color(0xFF0F172A);
  static const Color hearts = Color(0xFFDC2626);
  static const Color diamonds = Color(0xFFDC2626);
  static const Color clubs = Color(0xFF0F172A);

  // Archetypes — restrained, readable on dark
  static const Color maniac = Color(0xFFE07A3A);
  static const Color nit = Color(0xFF7A8A9A);
  static const Color station = Color(0xFF3AA8B8);
  static const Color tag = Color(0xFF6B7FD7);
  static const Color lag = Color(0xFFC46B8A);
  static const Color hero = Color(0xFFD4A84B);
}
