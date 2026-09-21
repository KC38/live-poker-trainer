/// Practice tab — next path lesson, then weak-objective review.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/curriculum/learning_snapshot.dart';
import 'package:live_poker_trainer/models/curriculum/path_progress.dart';
import 'package:live_poker_trainer/providers/learning_provider.dart';
import 'package:live_poker_trainer/ui/screens/learning/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/tokens/learning_tokens.dart';

/// Adaptive practice hub.
class PracticeHubScreen extends ConsumerWidget {
  /// Creates the Practice tab.
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(curriculumCatalogProvider);
    final snapshot = ref
        .watch(learningStateProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => LearningSnapshot.empty,
        );
    final next = catalogAsync.maybeWhen(
      data:
          (catalog) => nextPracticeLesson(catalog: catalog, snapshot: snapshot),
      orElse: () => null,
    );
    final reviewing =
        next != null && snapshot.completedLessonIds.contains(next.id);

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
            if (next != null) ...[
              Text(
                reviewing ? 'Review a weak spot' : 'Next lesson',
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LessonRunnerScreen(lessonId: next.id),
                      ),
                    );
                    ref.invalidate(learningStateProvider);
                  },
                  child: Text(next.title),
                ),
              ),
              const SizedBox(height: LearningTokens.sectionGap),
            ],
            Expanded(
              child: DecoratedBox(
                decoration: LearningTokens.panelDecoration(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Free play will deep-link to the existing Home table '
                      'setup later. Until then, Practice follows the Learn path '
                      'and sends you back to an objective below 80% mastery.',
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
