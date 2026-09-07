/// Luxury dark-felt theme — Cinzel display, Manrope UI, JetBrains Mono data.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Builds the app [ThemeData].
ThemeData buildPokerTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      onPrimary: AppColors.bgDark,
      secondary: AppColors.feltLight,
      onSecondary: AppColors.cream,
      surface: AppColors.bgMid,
      onSurface: AppColors.cream,
      error: AppColors.danger,
      onError: AppColors.cream,
      outline: AppColors.slateDark,
    ),
  );

  final manrope = GoogleFonts.manropeTextTheme(base.textTheme).apply(
    bodyColor: AppColors.cream,
    displayColor: AppColors.cream,
  );

  return base.copyWith(
    textTheme: manrope.copyWith(
      displayLarge: GoogleFonts.cinzel(
        fontWeight: FontWeight.w700,
        color: AppColors.goldBright,
        fontSize: 34,
        letterSpacing: 0.4,
        height: 1.15,
      ),
      displayMedium: GoogleFonts.cinzel(
        fontWeight: FontWeight.w700,
        color: AppColors.goldBright,
        fontSize: 26,
        letterSpacing: 0.3,
      ),
      headlineMedium: GoogleFonts.cinzel(
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
        fontSize: 20,
      ),
      titleLarge: GoogleFonts.cinzel(
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
        fontSize: 18,
      ),
      titleMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: AppColors.cream,
        fontSize: 16,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w500,
        color: AppColors.cream,
        fontSize: 16,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w500,
        color: AppColors.slate,
        fontSize: 14,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        fontSize: 13,
      ),
      bodySmall: GoogleFonts.jetBrainsMono(
        fontWeight: FontWeight.w600,
        color: AppColors.slate,
        fontSize: 11,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.slate),
      titleTextStyle: GoogleFonts.cinzel(
        fontWeight: FontWeight.w600,
        color: AppColors.goldBright,
        fontSize: 18,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgElevated,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.slateDark, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.bgDark,
        disabledBackgroundColor: AppColors.slateDark,
        disabledForegroundColor: AppColors.slate,
        elevation: 0,
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
        minimumSize: const Size.fromHeight(54),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.goldBright,
        side: const BorderSide(color: AppColors.goldMuted, width: 1.2),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.gold,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slateDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slateDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.goldMuted),
      ),
      labelStyle: GoogleFonts.manrope(color: AppColors.slate),
      hintStyle: GoogleFonts.manrope(color: AppColors.slate.withValues(alpha: 0.7)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.gold
            : AppColors.slate,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.gold.withValues(alpha: 0.3)
            : AppColors.slateDark,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.gold,
      thumbColor: AppColors.gold,
      inactiveTrackColor: AppColors.slateDark,
      overlayColor: AppColors.gold.withValues(alpha: 0.12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.bgElevated,
      selectedColor: AppColors.gold.withValues(alpha: 0.18),
      disabledColor: AppColors.slateDark,
      labelStyle: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
      ),
      secondaryLabelStyle: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
      ),
      side: const BorderSide(color: AppColors.slateDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
    dividerColor: AppColors.slateDark,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.bgElevated,
      contentTextStyle: GoogleFonts.manrope(color: AppColors.cream),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

/// Soft fade route used for primary mode launches.
Route<T> softFadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, _, _) => page,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
