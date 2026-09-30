/// Guest welcome, experience, goal, Rex intro, motivation, and start screens.
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
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RexIntroScreen(),
                ),
              );
            },
          ),
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
    final isNew =
        ref.watch(onboardingControllerProvider).experienceBand ==
        ExperienceBand.neverPlayed;
    final role = isNew ? 'Your coach' : 'Your live-reg coach';
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
          _OnboardingCoachPrompt(speech: role),
          const Spacer(),
          _ContinueBar(
            enabled: true,
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

/// First post-onboarding Rex motivation beat (Duolingo-style).
class MotivationHookScreen extends ConsumerWidget {
  /// Creates the first motivation screen.
  const MotivationHookScreen({super.key});

  static const speech = 'It can be hard to stay motivated...';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RexMotivationScaffold(
      speech: speech,
      progress: _onboardingProgress(4),
      onBack: () {
        unawaited(
          ref
              .read(onboardingControllerProvider.notifier)
              .setStep(OnboardingStep.rexIntro),
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
      progress: _onboardingProgress(5),
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
      progress: _onboardingProgress(4),
      onBack: () {
        unawaited(
          ref
              .read(onboardingControllerProvider.notifier)
              .setStep(OnboardingStep.rexIntro),
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

/// Post-lesson celebration + create-account CTA (Duolingo create-profile layout).
class SaveProgressScreen extends ConsumerWidget {
  /// Creates the save-progress screen.
  const SaveProgressScreen({super.key});

  static const Color _canvas = Color(0xFF131F24);
  static const Color _hare = Color(0xFFAFAFAF);
  static const Color _sky = Color(0xFF1CB0F6);
  static const Color _skyLedge = Color(0xFF1899D6);
  static const Color _ghostBorder = Color(0xFF37464F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);
    final lessonTitle = draft.lastLessonTitle ?? 'Lesson complete';
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
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
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Create a profile to save your progress '
                              'and continue learning. Guest progress can '
                              'be lost if this session is cleared.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                color: _hare,
                                fontSize: 17,
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
              _DuoSlabButton(
                label: 'CREATE A PROFILE',
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
                      builder: (_) => const AuthScreen(
                        saveProgressMode: true,
                        initialRegisterMode: true,
                      ),
                    ),
                  );
                },
                face: _sky,
                ledge: _skyLedge,
                foreground: _canvas,
              ),
              const SizedBox(height: 12),
              _DuoSlabButton(
                label: 'LATER',
                onPressed: () {
                  unawaited(
                    ref
                        .read(onboardingControllerProvider.notifier)
                        .continueLearningAsGuest(),
                  );
                },
                face: _canvas,
                ledge: _ghostBorder,
                foreground: _hare,
                border: _ghostBorder,
              ),
              const SizedBox(height: 8),
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
                  style: GoogleFonts.nunito(
                    color: _sky,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                child: _ConfettiDot(color: Color(0xFFFF4B4B), size: 10),
              ),
              const Positioned(
                top: 0,
                right: 18,
                child: _ConfettiDot(color: Color(0xFFFFC800), size: 8),
              ),
              const Positioned(
                top: 36,
                right: 4,
                child: _ConfettiDot(color: Color(0xFF1CB0F6), size: 9),
              ),
              const Positioned(
                bottom: 28,
                left: 4,
                child: _ConfettiDot(color: Color(0xFF58CC02), size: 8),
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
                    color: Colors.white.withValues(alpha: 0.85),
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
          style: GoogleFonts.nunito(
            color: const Color(0xFFFFC800),
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lessonTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: Colors.white,
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
              _StatChip(
                icon: Icons.bolt_rounded,
                label: '+$xpAwarded XP',
                color: const Color(0xFFFFC800),
              ),
              _StatChip(
                icon: Icons.local_fire_department_rounded,
                label: 'streak ${streak ?? 0}',
                color: const Color(0xFFFF9600),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _ConfettiDot(color: Color(0xFFFF4B4B), size: 7),
                _ConfettiDot(color: Color(0xFFFFC800), size: 7),
                _ConfettiDot(color: Color(0xFF1CB0F6), size: 7),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF58CC02),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              width: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
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

class _StatChip extends StatelessWidget {
  const _StatChip({
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
          color: const Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF37464F)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Duolingo-style 3D slab button with a solid bottom ledge.
class _DuoSlabButton extends StatefulWidget {
  const _DuoSlabButton({
    required this.label,
    required this.onPressed,
    required this.face,
    required this.ledge,
    required this.foreground,
    this.border,
  });

  final String label;
  final VoidCallback onPressed;
  final Color face;
  final Color ledge;
  final Color foreground;
  final Color? border;

  @override
  State<_DuoSlabButton> createState() => _DuoSlabButtonState();
}

class _DuoSlabButtonState extends State<_DuoSlabButton> {
  static const double _ledge = 4;
  static const double _radius = 16;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.border;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed();
        },
        child: SizedBox(
          height: 54 + _ledge,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: _ledge,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.ledge,
                    borderRadius: BorderRadius.circular(_radius),
                    border: border == null
                        ? null
                        : Border.all(color: border, width: 2),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 60),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                top: _pressed ? _ledge : 0,
                bottom: _pressed ? 0 : _ledge,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.face,
                    borderRadius: BorderRadius.circular(_radius),
                    border: border == null
                        ? null
                        : Border.all(color: border, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: widget.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Experience → daily goal → Meet Rex → motivation (or jump-test start).
const int kOnboardingProgressSteps = 5;

double _onboardingProgress(int stepIndex) {
  assert(stepIndex >= 1 && stepIndex <= kOnboardingProgressSteps);
  return stepIndex / kOnboardingProgressSteps;
}

class _RexMotivationScaffold extends StatelessWidget {
  const _RexMotivationScaffold({
    required this.speech,
    required this.onContinue,
    required this.progress,
    this.onBack,
  });

  final String speech;
  final Future<void> Function() onContinue;
  final double progress;
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
  });

  final bool enabled;
  final VoidCallback onPressed;

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
          child: const Text('Continue'),
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
