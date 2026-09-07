/// Luxury dark-felt theme with Cinzel / Inter / JetBrains Mono.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Builds the app [ThemeData].
ThemeData buildPokerTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      surface: AppColors.bgMid,
    ),
  );

  final inter = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: AppColors.cream,
    displayColor: AppColors.cream,
  );

  return base.copyWith(
    textTheme: inter.copyWith(
      displayLarge: GoogleFonts.cinzel(
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        fontSize: 36,
      ),
      displayMedium: GoogleFonts.cinzel(
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        fontSize: 28,
      ),
      headlineMedium: GoogleFonts.cinzel(
        fontWeight: FontWeight.w700,
        color: AppColors.cream,
        fontSize: 22,
      ),
      titleLarge: GoogleFonts.cinzel(
        fontWeight: FontWeight.w700,
        color: AppColors.cream,
      ),
      labelLarge: GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
      ),
      bodySmall: GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w600,
        color: AppColors.slate,
        fontSize: 12,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.cinzel(
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        fontSize: 20,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgMid.withValues(alpha: 0.85),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.bgDark,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: const BorderSide(color: AppColors.goldMuted),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.gold
            : AppColors.slate,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.gold.withValues(alpha: 0.35)
            : AppColors.slateDark,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.gold,
      thumbColor: AppColors.gold,
      inactiveTrackColor: AppColors.slateDark,
    ),
    dividerColor: AppColors.slateDark,
  );
}
