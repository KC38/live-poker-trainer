/// Practice tab — review, remediation, and free play (scaffold).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/tokens/learning_tokens.dart';

/// Adaptive practice hub placeholder.
class PracticeHubScreen extends StatelessWidget {
  /// Creates the Practice tab.
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(LearningTokens.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Practice',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.w700,
                color: AppColors.goldBright,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Due reviews, weak-skill drills, mistakes notebook, and free play.',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: LearningTokens.sectionGap),
            Expanded(
              child: DecoratedBox(
                decoration: LearningTokens.panelDecoration(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Free play will deep-link to the existing Home table '
                      'setup later. For this vertical slice, use Learn → '
                      'Start first lesson.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AppColors.cream,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
