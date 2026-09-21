/// Home: course path root (placeholder until Plan 06).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Home tab — interactive live-cash course path (placeholder).
class HomeScreen extends ConsumerWidget {
  /// Creates the Home course root.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.15,
            colors: [Color(0xFF1A2E28), AppColors.bgMid, AppColors.bgDark],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/brand/logo_mark.png',
                        width: 64,
                        height: 64,
                        filterQuality: FilterQuality.medium,
                        errorBuilder:
                            (_, _, _) => const Icon(
                              Icons.style,
                              size: 48,
                              color: AppColors.gold,
                            ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Home',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your live cash course lives here. Interactive lessons '
                        'arrive in a later update.',
                        style: GoogleFonts.manrope(
                          color: AppColors.slate,
                          fontSize: 16,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        decoration: BoxDecoration(
                          color: AppColors.bgElevated.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.slateDark.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Text(
                          'Meanwhile, open Live Training for full-hand practice '
                          'with live coaching.',
                          style: GoogleFonts.manrope(
                            color: AppColors.cream.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
