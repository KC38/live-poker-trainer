/// Learn tab — Sections 0–4, streak, Table Ready, and preflop progress.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/curriculum/curriculum_models.dart';
import 'package:live_poker_trainer/models/curriculum/learning_snapshot.dart';
import 'package:live_poker_trainer/models/curriculum/path_progress.dart';
import 'package:live_poker_trainer/providers/learning_provider.dart';
import 'package:live_poker_trainer/ui/screens/learning/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/tokens/learning_tokens.dart';

/// Guided learning path for the table-ready sections.
class LearnPathScreen extends ConsumerWidget {
  /// Creates the Learn tab.
  const LearnPathScreen({super.key});

  Future<void> _openLesson(
    BuildContext context,
    WidgetRef ref,
    String lessonId,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonRunnerScreen(lessonId: lessonId),
      ),
    );
    ref.invalidate(learningStateProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(curriculumCatalogProvider);
    final stateAsync = ref.watch(learningStateProvider);
    final snapshot = stateAsync.maybeWhen(
      data: (value) => value,
      orElse: () => LearningSnapshot.empty,
    );

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
                    errorBuilder:
                        (_, _, _) => const SizedBox(width: 64, height: 64),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    snapshot.preflopPassed
                        ? 'Preflop foundation is in. Review the spots you still miss.'
                        : snapshot.tableReadyPassed
                        ? 'Table Ready. Preflop is unlocked: opens, limpers, blinds, and reraises.'
                        : 'Meridian’s table-ready path: rules, procedure, and the math under live cash.',
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
              'XP ${snapshot.xp} · Streak ${snapshot.streak} · '
              'Table Ready ${snapshot.tableReadyCompleted}/${snapshot.tableReadyTotal} · '
              'Preflop ${snapshot.preflopCompleted}/${snapshot.preflopTotal}',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
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
            const SizedBox(height: 12),
            Expanded(
              child: catalogAsync.when(
                loading:
                    () => const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                error:
                    (error, _) => Text(
                      'Catalog unavailable.\n$error',
                      style: GoogleFonts.manrope(color: AppColors.danger),
                    ),
                data:
                    (catalog) => ListView(
                      children: [
                        for (final section in catalog.sections.where(
                          (section) =>
                              section.order <= kVisiblePathMaxSectionOrder,
                        )) ...[
                          Text(
                            section.title,
                            style: GoogleFonts.manrope(
                              color: AppColors.cream,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final unit in section.units) ...[
                            Text(
                              unit.title,
                              style: GoogleFonts.manrope(
                                color: AppColors.slate,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            for (final lesson in unit.lessons)
                              _LessonTile(
                                lesson: lesson,
                                unlocked: isPathLessonUnlocked(
                                  catalog: catalog,
                                  snapshot: snapshot,
                                  lessonId: lesson.id,
                                ),
                                completed: snapshot.completedLessonIds.contains(
                                  lesson.id,
                                ),
                                onOpen:
                                    () => _openLesson(context, ref, lesson.id),
                              ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.unlocked,
    required this.completed,
    required this.onOpen,
  });

  final CurriculumLesson lesson;
  final bool unlocked;
  final bool completed;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final label =
        completed
            ? 'Done'
            : unlocked
            ? 'Start'
            : 'Locked';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(LearningTokens.panelRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(LearningTokens.panelRadius),
          onTap: unlocked ? onOpen : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lesson.title,
                    style: GoogleFonts.manrope(
                      color: unlocked ? AppColors.cream : AppColors.slate,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    color: completed ? AppColors.success : AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
