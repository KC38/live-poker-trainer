/// Lesson score summary after the runner finishes.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/tokens/learning_tokens.dart';

/// Shows correct/total and a continue CTA back to the Learn path.
class LessonResultScreen extends StatelessWidget {
  /// Creates the result screen.
  const LessonResultScreen({
    super.key,
    required this.lessonId,
    required this.title,
    required this.correctCount,
    required this.totalCount,
    this.xpTotal,
    this.streak,
    this.onContinue,
  });

  /// Completed lesson id.
  final String lessonId;

  /// Lesson display title.
  final String title;

  /// Number of correct answers.
  final int correctCount;

  /// Total questions.
  final int totalCount;

  /// Optional total XP from server progress.
  final int? xpTotal;

  /// Optional streak from server progress.
  final int? streak;

  /// Optional continue handler (defaults to popping to the first route).
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final scoreLabel =
        totalCount == 0 ? '0 / 0' : '$correctCount / $totalCount';
    final pct =
        totalCount == 0 ? 0 : ((correctCount / totalCount) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          'Lesson complete',
          style: GoogleFonts.cinzel(color: AppColors.goldBright),
        ),
        backgroundColor: AppColors.bgMid,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LearningTokens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: LearningTokens.sectionGap),
              DecoratedBox(
                decoration: LearningTokens.panelDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        scoreLabel,
                        key: const Key('lesson_score_label'),
                        style: GoogleFonts.cinzel(
                          color: AppColors.goldBright,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$pct% correct',
                        key: const Key('lesson_score_pct'),
                        style: GoogleFonts.manrope(
                          color: AppColors.slate,
                          fontSize: 15,
                        ),
                      ),
                      if (xpTotal != null || streak != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          [
                            if (xpTotal != null) 'XP $xpTotal',
                            if (streak != null) 'Streak $streak',
                          ].join(' · '),
                          style: GoogleFonts.manrope(
                            color: AppColors.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onContinue ??
                    () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
