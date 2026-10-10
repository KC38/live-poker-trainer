/// Guest welcome, coach intro, experience, goal, motivation, post-lesson
/// streak/quest/gem beats, and start screens.
///
/// Agent handbook: `docs/agents/03-client.md` and `docs/agents/04-course.md`.
/// Validation path: `fresh-guest-recommended` in `docs/agent-paths.md`.
///
/// Progress bar + Rex bubble — no "Step x of 4" title rows (rejected).
/// Changing experience/goal must change the recommended lesson.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/course_flags_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/widgets/brand_logo.dart';
import 'package:live_poker_trainer/ui/widgets/poker_table_bands.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

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
          const Spacer(flex: 2),
          const Align(child: BrandLogo(size: 72)),
          const SizedBox(height: 20),
          const Align(child: RexMascot(size: 148)),
          const SizedBox(height: 28),
          Text(
            'Exploitative\nPoker Lab',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Spacer(flex: 3),
          FilledButton(
            onPressed: () {
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(step: 'get_started'),
              );
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CoachIntroScreen(pageIndex: 0),
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
class ExperienceChoiceScreen extends ConsumerStatefulWidget {
  /// Creates the experience screen.
  const ExperienceChoiceScreen({super.key});

  @override
  ConsumerState<ExperienceChoiceScreen> createState() =>
      _ExperienceChoiceScreenState();
}

class _ExperienceChoiceScreenState
    extends ConsumerState<ExperienceChoiceScreen> {
  ExperienceBand? _selected;

  @override
  Widget build(BuildContext context) {
    final draftSelected =
        ref.watch(onboardingControllerProvider).experienceBand;
    final selected = _selected ?? draftSelected;
    return _OnboardingScaffold(
      progress: _onboardingProgress(1),
      onBack: () {
        unawaited(
          ref
              .read(onboardingControllerProvider.notifier)
              .setStep(OnboardingStep.welcome),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _OnboardingCoachPrompt(speech: 'Where are you starting?'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final band in ExperienceBand.values) ...[
                  _ChoiceTile(
                    label: band.label,
                    icon: _experienceIcon(band),
                    selected: selected == band,
                    onTap: () => setState(() => _selected = band),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          _ContinueBar(
            enabled: selected != null,
            onPressed: () async {
              final band = selected;
              if (band == null) return;
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
        ],
      ),
    );
  }
}

/// Daily study goal picker.
class DailyGoalScreen extends ConsumerStatefulWidget {
  /// Creates the daily goal screen.
  const DailyGoalScreen({super.key});

  @override
  ConsumerState<DailyGoalScreen> createState() => _DailyGoalScreenState();
}

class _DailyGoalScreenState extends ConsumerState<DailyGoalScreen> {
  int? _selectedMinutes;

  @override
  Widget build(BuildContext context) {
    final draftMinutes =
        ref.watch(onboardingControllerProvider).dailyGoalMinutes;
    final selectedMinutes = _selectedMinutes ?? draftMinutes;
    return _OnboardingScaffold(
      progress: _onboardingProgress(2),
      onBack: () {
        unawaited(
          ref
              .read(onboardingControllerProvider.notifier)
              .setStep(OnboardingStep.experience),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _OnboardingCoachPrompt(speech: 'How much time per day?'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final minutes in kDailyGoalChoices) ...[
                  _ChoiceTile(
                    label: '$minutes minutes',
                    trailingLabel: dailyGoalIntensityLabel(minutes),
                    selected: selectedMinutes == minutes,
                    onTap: () => setState(() => _selectedMinutes = minutes),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          _ContinueBar(
            enabled: selectedMinutes != null,
            onPressed: () async {
              final minutes = selectedMinutes;
              if (minutes == null) return;
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(step: 'daily_goal'),
              );
              await ref
                  .read(onboardingControllerProvider.notifier)
                  .setDailyGoal(minutes);
              if (!context.mounted) return;
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
              // AppRoot remounts onto MotivationHookScreen (or Your start when
              // a jump test is offered). Do not push a second copy — the
              // welcome stack is a different navigator and would cover it.
            },
          ),
        ],
      ),
    );
  }
}

/// Duolingo-style Rex coach lines shown right after Get started.
///
/// One route advances both lines in place so only one CONTINUE is live.
/// Stacking a second [CoachIntroScreen] left a buried CONTINUE that label
/// taps (and the agent driver) could re-fire, never reaching Experience.
class CoachIntroScreen extends ConsumerStatefulWidget {
  /// Creates the coach intro. [pageIndex] is the starting line (0 or 1).
  const CoachIntroScreen({super.key, this.pageIndex = 0});

  /// Zero-based starting line in the two-line coach sequence.
  final int pageIndex;

  static const _lines = <String>[
    "Hi — I'm Rex, your coach.",
    "Let's find where you should start.",
  ];

  @override
  ConsumerState<CoachIntroScreen> createState() => _CoachIntroScreenState();
}

class _CoachIntroScreenState extends ConsumerState<CoachIntroScreen> {
  late int _pageIndex;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.pageIndex.clamp(0, CoachIntroScreen._lines.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final line = CoachIntroScreen._lines[_pageIndex];
    final isLast = _pageIndex >= CoachIntroScreen._lines.length - 1;
    return _RexMotivationScaffold(
      speech: line,
      onContinue: () async {
        unawaited(
          ref.read(analyticsServiceProvider).logOnboardingStep(
                step: isLast ? 'coach_intro_2' : 'coach_intro_1',
              ),
        );
        if (!context.mounted) return;
        if (isLast) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ExperienceChoiceScreen(),
            ),
          );
          return;
        }
        setState(() => _pageIndex += 1);
      },
    );
  }
}

/// First post-onboarding Rex motivation beat (Duolingo-style).
class MotivationHookScreen extends ConsumerWidget {
  /// Creates the first motivation screen.
  const MotivationHookScreen({super.key});

  static const speech = 'It can be hard to stay motivated...';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RexMotivationScaffold(
      speech: speech,
      progress: _onboardingProgress(3),
      onBack: () {
        unawaited(
          ref
              .read(onboardingControllerProvider.notifier)
              .setStep(OnboardingStep.dailyGoal),
        );
      },
      onContinue: () async {
        unawaited(
          ref
              .read(analyticsServiceProvider)
              .logOnboardingStep(step: 'motivation_hook'),
        );
        await ref
            .read(onboardingControllerProvider.notifier)
            .advanceMotivationHook();
      },
    );
  }
}

/// Second motivation beat; Continue starts the first lesson with no CTA gate.
class MotivationPitchScreen extends ConsumerWidget {
  /// Creates the second motivation screen.
  const MotivationPitchScreen({super.key});

  static const speech =
      '...so Exploitative Poker Lab is designed to be fun like a game!';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final lessonId = draft.recommendedLessonId ?? kFirstCourseLessonId;
    return _RexMotivationScaffold(
      speech: speech,
      progress: _onboardingProgress(4),
      onBack: () {
        unawaited(
          ref
              .read(onboardingControllerProvider.notifier)
              .setStep(OnboardingStep.motivationHook),
        );
      },
      onContinue: () async {
        unawaited(
          ref
              .read(analyticsServiceProvider)
              .logOnboardingStep(step: 'motivation_pitch'),
        );
        await ref
            .read(onboardingControllerProvider.notifier)
            .markEnteringFirstLesson();
        if (!context.mounted) return;
        // Push (not replace) so LessonResult CONTINUE can pop back to a
        // real first route if AppRoot has not remounted yet.
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LessonRunnerScreen(
              lessonId: lessonId,
              embeddedInShell: false,
            ),
          ),
        );
      },
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
      progress: _onboardingProgress(3),
      onBack: () {
        unawaited(
          ref
              .read(onboardingControllerProvider.notifier)
              .setStep(OnboardingStep.dailyGoal),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              text:
                  'These two are yours alone. You will tap them in the lesson.',
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TableFeaturesScope(
                features: TableFeatures.forLessonId(
                  recommendation.startLessonId,
                ),
                child: PokerTableBands(
                  game: lessonBandGame(
                    heroCodes: const ['Ah', 'Kd'],
                    boardCodes: const ['Qs', 'Jh', '2c'],
                    villainSeatCount: 1,
                  ),
                  // Preview only. Your seat is not a lesson answer.
                  feedback: const CoachFeedback(
                    message:
                        'Qs Jh 2c on the flop. Your cards sit at the bottom of the table.',
                  ),
                ),
              ),
            ),
          ] else
            const Spacer(),
          FilledButton(
            onPressed: () async {
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(
                      step: recommendation.jumpTestOffered
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
              // Push (not replace) so LessonResult CONTINUE can pop back to a
              // real first route if AppRoot has not remounted yet.
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LessonRunnerScreen(
                    lessonId: recommendation.startLessonId,
                    embeddedInShell: false,
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
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LessonRunnerScreen(
                      lessonId: kFirstCourseLessonId,
                      embeddedInShell: false,
                    ),
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

/// Flame + weekday streak celebration after the first lesson.
class DayStreakScreen extends ConsumerWidget {
  /// Creates the day-streak celebration screen.
  const DayStreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final streak = (draft.lastStreak ?? 1).clamp(1, 9999);
    return _OnboardingScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 96,
                          color: AppColors.warning,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$streak',
                          style: GoogleFonts.manrope(
                            color: AppColors.warning,
                            fontSize: 72,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        Text(
                          streak == 1 ? 'day streak' : 'day streak',
                          style: GoogleFonts.manrope(
                            color: AppColors.warning,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _WeekdayStreakCard(streakDays: streak),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          FilledButton(
            onPressed: () {
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(step: 'day_streak'),
              );
              unawaited(
                ref.read(onboardingControllerProvider.notifier).advanceDayStreak(),
              );
            },
            style: _primaryButton,
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }
}

/// Choose a multi-day streak commitment (Good → Unstoppable).
class StreakGoalScreen extends ConsumerStatefulWidget {
  /// Creates the streak-goal picker.
  const StreakGoalScreen({super.key});

  @override
  ConsumerState<StreakGoalScreen> createState() => _StreakGoalScreenState();
}

class _StreakGoalScreenState extends ConsumerState<StreakGoalScreen> {
  int? _selectedDays;

  @override
  Widget build(BuildContext context) {
    final draftDays = ref.watch(onboardingControllerProvider).streakGoalDays;
    final selected = _selectedDays ?? draftDays;
    final speech = selected == null
        ? "Let's commit to learning with a Streak Goal!"
        : "You'll be 5x more likely to complete the course!";
    return _OnboardingScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OnboardingCoachPrompt(speech: speech),
          const SizedBox(height: 12),
          Center(
            child: _StreakGoalCalendarBadge(days: selected ?? 7),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final days in kStreakGoalChoices) ...[
                  _ChoiceTile(
                    label: '$days day streak',
                    trailingLabel: streakGoalIntensityLabel(days),
                    selected: selected == days,
                    onTap: () => setState(() => _selectedDays = days),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          _ContinueBar(
            enabled: selected != null,
            label: 'I CAN DO IT!',
            onPressed: () async {
              final days = selected;
              if (days == null) return;
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(step: 'streak_goal'),
              );
              await ref
                  .read(onboardingControllerProvider.notifier)
                  .setStreakGoal(days);
            },
          ),
        ],
      ),
    );
  }
}

/// Daily quest complete card; Continue opens the gem reward.
class DailyQuestsCompleteScreen extends ConsumerWidget {
  /// Creates the daily-quests complete screen.
  const DailyQuestsCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final earned = (draft.lastXpAwarded ?? kDailyQuestXpTarget)
        .clamp(kDailyQuestXpTarget, 9999);
    final progressXp = earned >= kDailyQuestXpTarget
        ? kDailyQuestXpTarget
        : earned;
    return _OnboardingScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),
          Text(
            'All Daily Quests complete!',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.goldBright,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 28),
          _DailyQuestCard(
            title: 'Earn $kDailyQuestXpTarget XP',
            current: progressXp,
            target: kDailyQuestXpTarget,
          ),
          const Spacer(flex: 3),
          FilledButton(
            onPressed: () {
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(step: 'daily_quests'),
              );
              unawaited(
                ref
                    .read(onboardingControllerProvider.notifier)
                    .advanceDailyQuests(),
              );
            },
            style: _primaryButton,
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }
}

/// Gem wallet reveal after the daily-quest chest.
class GemsRewardScreen extends ConsumerWidget {
  /// Creates the gems reward screen.
  const GemsRewardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final awarded = draft.lastGemsAwarded ?? kDailyQuestGemReward;
    return _OnboardingScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),
          const _OpenGemChest(),
          const SizedBox(height: 28),
          Text(
            'You earned $awarded gems!',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Nice job reaching your daily goal!',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const Spacer(flex: 3),
          FilledButton(
            onPressed: () {
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .logOnboardingStep(step: 'gems_reward'),
              );
              unawaited(
                ref
                    .read(onboardingControllerProvider.notifier)
                    .advanceGemsReward(),
              );
            },
            style: _primaryButton,
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }
}

/// Post-lesson celebration + create-account CTA (brand theme).
class SaveProgressScreen extends ConsumerWidget {
  /// Creates the save-progress screen.
  const SaveProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final lessonTitle = draft.lastLessonTitle ?? 'Lesson complete';
    final theme = Theme.of(context);
    return Scaffold(
      body: DecoratedBox(
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
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final mascotSize =
                          (constraints.maxHeight * 0.28).clamp(112.0, 168.0);
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SaveProgressHero(
                                mascotSize: mascotSize,
                                xpAwarded: draft.lastXpAwarded,
                                streak: draft.lastStreak,
                                lessonTitle: lessonTitle,
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'Time to create a profile!',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: AppColors.cream,
                                  fontSize: 28,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Create a profile to save your progress '
                                'and continue learning. Guest progress can '
                                'be lost if this session is cleared.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  color: AppColors.slate,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    unawaited(
                      ref.read(analyticsServiceProvider).logAccountConversion(
                            method: 'save_progress',
                            outcome: 'started',
                          ),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AuthScreen(
                          saveProgressMode: true,
                          initialRegisterMode: true,
                        ),
                      ),
                    );
                  },
                  style: _primaryButton,
                  child: const Text('CREATE A PROFILE'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    unawaited(
                      ref
                          .read(onboardingControllerProvider.notifier)
                          .continueLearningAsGuest(),
                    );
                  },
                  style: _secondaryButton,
                  child: const Text('LATER'),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AuthScreen(
                          saveProgressMode: true,
                          initialRegisterMode: false,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'I already have an account',
                    style: GoogleFonts.manrope(
                      color: AppColors.goldBright,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
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

class _WeekdayStreakCard extends StatelessWidget {
  const _WeekdayStreakCard({required this.streakDays});

  final int streakDays;

  static const _labels = <String>['M', 'Tu', 'W', 'Th', 'F'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Monday=1 … Friday=5. Weekend maps to Friday so the card still reads.
    final todayIndex = (today.weekday.clamp(1, 5) - 1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slateDark),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _labels[i],
                        style: GoogleFonts.manrope(
                          color: i == todayIndex
                              ? AppColors.warning
                              : AppColors.slate,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StreakDayDot(
                        filled: i == todayIndex && streakDays > 0,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.slateDark),
          const SizedBox(height: 14),
          Text(
            'Practicing daily grows your streak, but skipping a day resets it!',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakDayDot extends StatelessWidget {
  const _StreakDayDot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.warning : Colors.transparent,
        border: Border.all(
          color: filled ? AppColors.warning : AppColors.slateDark,
          width: 2,
        ),
      ),
      child: filled
          ? const Icon(Icons.check, size: 18, color: AppColors.bgDark)
          : null,
    );
  }
}

class _StreakGoalCalendarBadge extends StatelessWidget {
  const _StreakGoalCalendarBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 24,
            child: RexMascot(size: 88, mood: RexMood.celebrate),
          ),
          Positioned(
            right: 36,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.warning,
                  size: 28,
                ),
                Container(
                  width: 64,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$days',
                            style: GoogleFonts.manrope(
                              color: AppColors.danger,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuestCard extends StatelessWidget {
  const _DailyQuestCard({
    required this.title,
    required this.current,
    required this.target,
  });

  final String title;
  final int current;
  final int target;

  @override
  Widget build(BuildContext context) {
    final ratio = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slateDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.bolt_rounded,
            color: AppColors.goldBright,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            LinearProgressIndicator(
                              value: ratio,
                              minHeight: 22,
                              backgroundColor: AppColors.slateDark,
                              color: AppColors.goldBright,
                            ),
                            Text(
                              '$current / $target',
                              style: GoogleFonts.jetBrainsMono(
                                color: AppColors.bgDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.inventory_2_rounded,
                      color: AppColors.gold,
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenGemChest extends StatelessWidget {
  const _OpenGemChest();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5A2B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Align(
              alignment: Alignment(0, 0.35),
              child: Icon(
                Icons.lock_open_rounded,
                color: AppColors.goldBright,
                size: 28,
              ),
            ),
          ),
          const Positioned(
            top: 18,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond, color: Color(0xFF5EC8FF), size: 36),
                SizedBox(width: 4),
                Icon(Icons.diamond, color: Color(0xFF7AD4FF), size: 44),
                SizedBox(width: 4),
                Icon(Icons.diamond, color: Color(0xFF5EC8FF), size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Celebrating Rex with a phone prop, confetti, and XP / streak chips.
class _SaveProgressHero extends StatelessWidget {
  const _SaveProgressHero({
    required this.mascotSize,
    required this.lessonTitle,
    this.xpAwarded,
    this.streak,
  });

  final double mascotSize;
  final String lessonTitle;
  final int? xpAwarded;
  final int? streak;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: mascotSize * 1.55,
          width: mascotSize * 1.55,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                top: 8,
                left: 10,
                child: _ConfettiDot(color: AppColors.danger, size: 10),
              ),
              const Positioned(
                top: 0,
                right: 18,
                child: _ConfettiDot(color: AppColors.goldBright, size: 8),
              ),
              const Positioned(
                top: 36,
                right: 4,
                child: _ConfettiDot(color: AppColors.diamonds, size: 9),
              ),
              const Positioned(
                bottom: 28,
                left: 4,
                child: _ConfettiDot(color: AppColors.success, size: 8),
              ),
              Positioned(
                top: 4,
                right: mascotSize * 0.08,
                child: const _ProgressPhone(),
              ),
              RexMascot(size: mascotSize, mood: RexMood.celebrate),
              Positioned(
                bottom: 0,
                left: mascotSize * 0.18,
                right: mascotSize * 0.18,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.cream.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Nice work',
          style: GoogleFonts.manrope(
            color: AppColors.goldBright,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lessonTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: AppColors.cream,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (xpAwarded != null) ...[
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _SaveProgressStatChip(
                icon: Icons.bolt_rounded,
                label: '+$xpAwarded XP',
                color: AppColors.goldBright,
              ),
              _SaveProgressStatChip(
                icon: Icons.local_fire_department_rounded,
                label: 'streak ${streak ?? 0}',
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProgressPhone extends StatelessWidget {
  const _ProgressPhone();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.18,
      child: Container(
        width: 44,
        height: 72,
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.goldMuted, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.bgDark.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _ConfettiDot(color: AppColors.hearts, size: 7),
                _ConfettiDot(color: AppColors.gold, size: 7),
                _ConfettiDot(color: AppColors.diamonds, size: 7),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              width: 18,
              decoration: BoxDecoration(
                color: AppColors.slateDark,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  const _ConfettiDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SaveProgressStatChip extends StatelessWidget {
  const _SaveProgressStatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.slateDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Experience → daily goal → motivation (or jump-test start).
const int kOnboardingProgressSteps = 4;

double _onboardingProgress(int stepIndex) {
  assert(stepIndex >= 1 && stepIndex <= kOnboardingProgressSteps);
  return stepIndex / kOnboardingProgressSteps;
}

class _RexMotivationScaffold extends StatelessWidget {
  const _RexMotivationScaffold({
    required this.speech,
    required this.onContinue,
    this.progress,
    this.onBack,
  });

  final String speech;
  final Future<void> Function() onContinue;
  final double? progress;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showBack = canPop || onBack != null;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                child: _OnboardingTopBar(
                  progress: progress,
                  showBack: showBack,
                  onBack: () {
                    if (canPop) {
                      Navigator.of(context).pop();
                      return;
                    }
                    onBack?.call();
                  },
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // RexMascot height is size * 1.5; budget height first.
                    final mascotSize =
                        ((constraints.maxHeight * 0.42) / 1.5)
                            .clamp(96.0, 168.0);
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _MotivationSpeechBubble(text: speech),
                                const SizedBox(height: 20),
                                RexMascot(size: mascotSize),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.slateDark),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: FilledButton(
                  onPressed: () => unawaited(onContinue()),
                  style: _primaryButton,
                  child: const Text('CONTINUE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded bubble with a downward pointer aimed at Rex.
class _MotivationSpeechBubble extends StatelessWidget {
  const _MotivationSpeechBubble({required this.text});

  final String text;

  static const double _radius = 16;
  static const double _tailWidth = 18;
  static const double _tailHeight = 10;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rex says: $text',
      child: CustomPaint(
        painter: const _MotivationBubblePainter(
          fill: AppColors.bgElevated,
          border: AppColors.slateDark,
          radius: _radius,
          tailWidth: _tailWidth,
          tailHeight: _tailHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16 + _tailHeight),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MotivationBubblePainter extends CustomPainter {
  const _MotivationBubblePainter({
    required this.fill,
    required this.border,
    required this.radius,
    required this.tailWidth,
    required this.tailHeight,
  });

  final Color fill;
  final Color border;
  final double radius;
  final double tailWidth;
  final double tailHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height - tailHeight,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(body);
    final tipX = size.width / 2;
    final tipY = size.height;
    path.moveTo(tipX - tailWidth / 2, size.height - tailHeight - 0.5);
    path.lineTo(tipX, tipY);
    path.lineTo(tipX + tailWidth / 2, size.height - tailHeight - 0.5);
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _MotivationBubblePainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.border != border ||
        oldDelegate.radius != radius ||
        oldDelegate.tailWidth != tailWidth ||
        oldDelegate.tailHeight != tailHeight;
  }
}

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold({
    required this.child,
    this.progress,
    this.onBack,
  });

  final Widget child;

  /// Fraction complete across the guest questionnaire (null hides the bar).
  final double? progress;

  /// Used when this screen is the root, so [Navigator.canPop] is false.
  ///
  /// Pushed screens still pop. Your start is a new navigator and uses this
  /// to rewind the stored step instead of opening Home.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showBack = canPop || onBack != null;
    final progressValue = progress;
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
                if (progressValue != null || showBack)
                  _OnboardingTopBar(
                    progress: progressValue,
                    showBack: showBack,
                    onBack: () {
                      if (canPop) {
                        Navigator.of(context).pop();
                        return;
                      }
                      onBack?.call();
                    },
                  ),
                if (progressValue != null || showBack) const SizedBox(height: 16),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.showBack,
    required this.onBack,
    this.progress,
  });

  final double? progress;
  final bool showBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final progressValue = progress;
    return Row(
      children: [
        if (showBack)
          IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back,
              semanticLabel: 'Back',
              color: AppColors.cream,
            ),
          )
        else
          const SizedBox(width: 48),
        if (progressValue != null) ...[
          const SizedBox(width: 4),
          Expanded(
            child: Semantics(
              label:
                  'Onboarding progress ${(progressValue * 100).round()} percent',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progressValue.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.slateDark,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ] else
          const Spacer(),
      ],
    );
  }
}

/// Leading icon for each experience band (Duolingo-style choice row).
IconData _experienceIcon(ExperienceBand band) {
  return switch (band) {
    ExperienceBand.neverPlayed => Icons.person_outline,
    ExperienceBand.rulesKnown => Icons.home_outlined,
    ExperienceBand.firstCasino => Icons.casino_outlined,
    ExperienceBand.regularLive => Icons.style_outlined,
  };
}

class _OnboardingCoachPrompt extends StatelessWidget {
  const _OnboardingCoachPrompt({required this.speech});

  final String speech;

  static const double _mascotSize = 72;
  static const double _tailWidth = 10;
  static const double _tailHeight = 14;
  static const double _tailCenterY = 30;
  static const double _radius = 16;
  static const double _minHeight = _tailCenterY + _tailHeight / 2 + _radius + 12;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        label: 'Rex says: $speech',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RexMascot(size: _mascotSize),
            const SizedBox(width: 4),
            Expanded(
              child: CustomPaint(
                painter: const _OnboardingSpeechBubblePainter(
                  fill: AppColors.bgElevated,
                  border: AppColors.slateDark,
                  tailCenterY: _tailCenterY,
                  tailWidth: _tailWidth,
                  tailHeight: _tailHeight,
                  radius: _radius,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _minHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _tailWidth + 12,
                      12,
                      12,
                      12,
                    ),
                    child: Text(
                      speech,
                      style: GoogleFonts.manrope(
                        color: AppColors.cream,
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
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

class _OnboardingSpeechBubblePainter extends CustomPainter {
  const _OnboardingSpeechBubblePainter({
    required this.fill,
    required this.border,
    required this.tailCenterY,
    required this.tailWidth,
    required this.tailHeight,
    required this.radius,
  });

  final Color fill;
  final Color border;
  final double tailCenterY;
  final double tailWidth;
  final double tailHeight;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _path(Size size) {
    final left = tailWidth;
    final right = size.width;
    final bottom = size.height;
    final half = tailHeight / 2;
    final tipY = tailCenterY;
    final tailTop = tipY - half;
    final tailBot = tipY + half;
    final r = Radius.circular(radius);

    return Path()
      ..moveTo(left + radius, 0)
      ..lineTo(right - radius, 0)
      ..arcToPoint(Offset(right, radius), radius: r)
      ..lineTo(right, bottom - radius)
      ..arcToPoint(Offset(right - radius, bottom), radius: r)
      ..lineTo(left + radius, bottom)
      ..arcToPoint(Offset(left, bottom - radius), radius: r)
      ..lineTo(left, tailBot)
      ..lineTo(0, tipY)
      ..lineTo(left, tailTop)
      ..lineTo(left, radius)
      ..arcToPoint(Offset(left + radius, 0), radius: r)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _OnboardingSpeechBubblePainter oldDelegate) =>
      false;
}

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({
    required this.enabled,
    required this.onPressed,
    this.label = 'Continue',
  });

  final bool enabled;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, color: AppColors.slateDark),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: enabled ? onPressed : null,
          style: _primaryButton,
          child: Text(label),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.trailingLabel,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final IconData? icon;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? AppColors.gold : AppColors.slate;
    final trailingColor = selected ? AppColors.cream : AppColors.slate;
    return Material(
      color: AppColors.bgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.gold : AppColors.slateDark,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 26, color: iconColor),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingLabel != null && trailingLabel!.isNotEmpty)
                Text(
                  trailingLabel!,
                  style: GoogleFonts.manrope(
                    color: trailingColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final _primaryButton = FilledButton.styleFrom(
  backgroundColor: AppColors.gold,
  foregroundColor: AppColors.bgDark,
  textStyle: GoogleFonts.manrope(
    fontWeight: FontWeight.w800,
    fontSize: 16,
    letterSpacing: 0.2,
  ),
  minimumSize: const Size.fromHeight(54),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
);

final _secondaryButton = OutlinedButton.styleFrom(
  foregroundColor: AppColors.goldBright,
  textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15),
  minimumSize: const Size.fromHeight(50),
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  side: const BorderSide(color: AppColors.goldMuted, width: 1.2),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
);
