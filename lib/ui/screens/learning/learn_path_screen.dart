/// Learn tab — guided curriculum path with section-0 catalog preview.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/curriculum/lesson_exercises.dart';
import 'package:live_poker_trainer/providers/learning_provider.dart';
import 'package:live_poker_trainer/ui/screens/learning/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/tokens/learning_tokens.dart';

/// Guided learning path with catalog-backed section 0 units.
class LearnPathScreen extends ConsumerWidget {
  /// Creates the Learn tab.
  const LearnPathScreen({super.key});

  void _startFirstLesson(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LessonRunnerScreen(lessonId: kFirstLessonId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(curriculumCatalogProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(LearningTokens.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Learn',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.w700,
                color: AppColors.goldBright,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/media/characters/meridian/idle_listen.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 64,
                      height: 64,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Meridian guides short lessons on live cash fundamentals.',
                    style: GoogleFonts.manrope(
                      color: AppColors.slate,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Guided live-cash path: 13 sections, 61 units, 183 lessons.',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: LearningTokens.sectionGap),
            Expanded(
              child: catalogAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
                error: (e, _) => DecoratedBox(
                  decoration: LearningTokens.panelDecoration(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Catalog unavailable.\n$e',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          color: AppColors.danger,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                data: (catalog) {
                  final section = catalog.sections.isEmpty
                      ? null
                      : catalog.sections.first;
                  if (section == null) {
                    return const Center(child: Text('Catalog is empty.'));
                  }
                  return ListView(
                    children: [
                      Text(
                        section.title,
                        style: GoogleFonts.manrope(
                          color: AppColors.cream,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (section.summary.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          section.summary,
                          style: GoogleFonts.manrope(
                            color: AppColors.slate,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      for (final unit in section.units) ...[
                        DecoratedBox(
                          decoration: LearningTokens.panelDecoration(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Text(
                              unit.title,
                              style: GoogleFonts.manrope(
                                color: AppColors.cream,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _startFirstLesson(context),
              child: const Text('Start first lesson'),
            ),
          ],
        ),
      ),
    );
  }
}
