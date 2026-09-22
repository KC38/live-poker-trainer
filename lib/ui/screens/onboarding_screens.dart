/// Guest welcome, experience, goal, Rex intro, and recommended-start screens.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/course_flags_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
import 'package:live_poker_trainer/ui/screens/first_lesson_launch_screen.dart';

/// Signed-out value proposition with Get started / I already have an account.
class WelcomeScreen extends ConsumerWidget {
  /// Creates the welcome screen.
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _OnboardingScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'Exploitative\nPoker Lab',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 14),
          Text(
            'Learn live cash No-Limit Hold\'em by doing — one short lesson at a time.',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () {
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(step: 'get_started'),
              );
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ExperienceChoiceScreen(),
                ),
              );
            },
            style: _primaryButton,
            child: const Text('Get started'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(step: 'existing_account'),
              );
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
              );
            },
            style: _secondaryButton,
            child: const Text('I already have an account'),
          ),
        ],
      ),
    );
  }
}

/// Experience band picker.
class ExperienceChoiceScreen extends ConsumerWidget {
  /// Creates the experience screen.
  const ExperienceChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _OnboardingScaffold(
      title: 'Your experience',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Where are you starting?',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We use this to recommend a start — it never unlocks content alone.',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          for (final band in ExperienceBand.values) ...[
            _ChoiceTile(
              label: band.label,
              onTap: () async {
                unawaited(
                  ref
                      .read(analyticsServiceProvider)
                      .logOnboardingStep(step: 'experience'),
                );
                await ref
                    .read(onboardingControllerProvider.notifier)
                    .setExperience(band);
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DailyGoalScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// Daily study goal picker.
class DailyGoalScreen extends ConsumerWidget {
  /// Creates the daily goal screen.
  const DailyGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _OnboardingScaffold(
      title: 'Daily goal',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How much time per day?',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A small daily habit beats occasional cramming.',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          for (final minutes in kDailyGoalChoices) ...[
            _ChoiceTile(
              label: '$minutes minutes',
              onTap: () async {
                unawaited(
                  ref
                      .read(analyticsServiceProvider)
                      .logOnboardingStep(step: 'daily_goal'),
                );
                await ref
                    .read(onboardingControllerProvider.notifier)
                    .setDailyGoal(minutes);
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RexIntroScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// Rex coach introduction.
class RexIntroScreen extends ConsumerWidget {
  /// Creates the Rex intro screen.
  const RexIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _OnboardingScaffold(
      title: 'Meet Rex',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Rex',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your live-reg coach',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'One short sentence at a time. No lectures — just the next decision.',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () async {
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(step: 'rex_intro'),
              );
              final draft = ref.read(onboardingControllerProvider);
              final band = draft.experienceBand ?? ExperienceBand.neverPlayed;
              final catalog = await ref.read(courseCatalogProvider.future);
              final flags = await ref.read(courseFlagsProvider.future);
              final recommendation = resolveOnboardingRecommendation(
                band: band,
                catalog: catalog,
                flags: flags,
              );
              await ref
                  .read(onboardingControllerProvider.notifier)
                  .setRecommendation(
                    lessonId: recommendation.startLessonId,
                    jumpTestOffered: recommendation.jumpTestOffered,
                  );
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder:
                      (_) => RecommendedStartScreen(
                        recommendation: recommendation,
                      ),
                ),
              );
            },
            style: _primaryButton,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

/// Recommended first lesson / optional jump test.
class RecommendedStartScreen extends ConsumerWidget {
  /// Creates the recommended start screen.
  const RecommendedStartScreen({super.key, required this.recommendation});

  final OnboardingRecommendation recommendation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref
        .watch(courseCatalogProvider)
        .maybeWhen(
          data: (catalog) => catalog.lessonById(recommendation.startLessonId),
          orElse: () => null,
        );
    return _OnboardingScaffold(
      title: 'Your start',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            recommendation.jumpTestOffered
                ? 'Optional jump test'
                : 'Recommended first lesson',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lesson?.title ?? 'Your two cards',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.jumpTestOffered
                ? 'You asked for Regular. A published jump test is available — it never unlocks content by itself.'
                : recommendation.experienceBand == ExperienceBand.regularLive
                ? 'Regular players will get a jump test when it publishes. For now, start with the first interactive lesson.'
                : 'A short interactive lesson. Progress is temporary until you create an account.',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          if (!recommendation.jumpTestOffered) ...[
            const SizedBox(height: 22),
            const RexCoachLine(
              text: 'These two are yours alone. Tap them on the felt next.',
            ),
            const SizedBox(height: 14),
            const LessonTableContext(
              scene: LessonTableScene(
                heroCodes: ['Ah', 'Kd'],
                boardCodes: ['Qs', 'Jh', '2c'],
                villainSeatCount: 1,
                highlight: LessonTableHighlight.hero,
                caption: 'You',
              ),
              showSoftPulse: true,
              enabled: false,
            ),
          ],
          const Spacer(),
          FilledButton(
            onPressed: () async {
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(
                      step:
                          recommendation.jumpTestOffered
                              ? 'jump_test_offer'
                              : 'start_lesson',
                    ),
              );
              if (recommendation.jumpTestOffered) {
                unawaited(
                  ref
                      .read(analyticsServiceProvider)
                      .logJumpTest(
                        lessonId: recommendation.startLessonId,
                        result: 'offered',
                      ),
                );
              }
              await ref
                  .read(onboardingControllerProvider.notifier)
                  .markEnteringFirstLesson();
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder:
                      (_) => FirstLessonLaunchScreen(
                        lessonId: recommendation.startLessonId,
                      ),
                ),
              );
            },
            style: _primaryButton,
            child: Text(
              recommendation.jumpTestOffered
                  ? 'Start jump test'
                  : 'Start lesson',
            ),
          ),
          if (recommendation.jumpTestOffered) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await ref
                    .read(onboardingControllerProvider.notifier)
                    .setRecommendation(
                      lessonId: kFirstCourseLessonId,
                      jumpTestOffered: false,
                    );
                await ref
                    .read(onboardingControllerProvider.notifier)
                    .markEnteringFirstLesson();
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FirstLessonLaunchScreen(),
                  ),
                );
              },
              child: const Text('Start from the beginning instead'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Post-lesson celebration + create-account CTA.
class SaveProgressScreen extends ConsumerWidget {
  /// Creates the save-progress screen.
  const SaveProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    return _OnboardingScaffold(
      title: 'Nice work',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            draft.lastLessonTitle ?? 'Lesson complete',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          if (draft.lastXpAwarded != null)
            Text(
              '+${draft.lastXpAwarded} XP · streak ${draft.lastStreak ?? 0}',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 18),
          Text(
            'Create an account to save your progress. Guest progress can be lost if this session is cleared.',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () {
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logAccountConversion(
                      method: 'save_progress',
                      outcome: 'started',
                    ),
              );
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder:
                      (_) => const AuthScreen(
                        saveProgressMode: true,
                        initialRegisterMode: true,
                      ),
                ),
              );
            },
            style: _primaryButton,
            child: const Text('Create an account to save your progress'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder:
                      (_) => const AuthScreen(
                        saveProgressMode: true,
                        initialRegisterMode: false,
                      ),
                ),
              );
            },
            child: const Text('I already have an account'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              unawaited(
                ref
                    .read(onboardingControllerProvider.notifier)
                    .continueLearningAsGuest(),
              );
            },
            child: const Text('Continue learning'),
          ),
        ],
      ),
    );
  }
}

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: GoogleFonts.manrope(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                if (title != null) const SizedBox(height: 18),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

final _primaryButton = FilledButton.styleFrom(
  backgroundColor: AppColors.gold,
  foregroundColor: AppColors.bgDark,
  minimumSize: const Size.fromHeight(52),
);

final _secondaryButton = OutlinedButton.styleFrom(
  foregroundColor: AppColors.cream,
  minimumSize: const Size.fromHeight(52),
  side: const BorderSide(color: AppColors.slate),
);
