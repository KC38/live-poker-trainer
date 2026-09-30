/// Guest welcome, experience, goal, Rex intro, and recommended-start screens.
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
      title: 'Your experience',
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
          Text(
            'We use this to recommend a start — it never unlocks content alone.',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 14,
              height: 1.4,
            ),
          ),
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
      title: 'Daily goal',
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
          Text(
            'A small daily habit beats occasional cramming.',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 14,
              height: 1.4,
            ),
          ),
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
      title: 'Meet Rex',
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
          Text(
            'One short sentence at a time. No lectures — just the next decision.',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 15,
              height: 1.45,
            ),
          ),
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
              // AppRoot remounts onto RecommendedStartScreen for this step.
              // Do not push a second copy — the welcome stack is a different
              // navigator and would cover Your start.
            },
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
                  builder: (_) => const AuthScreen(
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
                  builder: (_) => const AuthScreen(
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
  const _OnboardingScaffold({
    required this.child,
    this.title,
    this.onBack,
  });

  final Widget child;
  final String? title;

  /// Used when this screen is the root, so [Navigator.canPop] is false.
  ///
  /// Pushed screens still pop. Your start is a new navigator and uses this
  /// to rewind the stored step instead of opening Home.
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showBack)
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () {
                          if (canPop) {
                            Navigator.of(context).pop();
                            return;
                          }
                          onBack?.call();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          semanticLabel: 'Back',
                          color: AppColors.cream,
                        ),
                      ),
                    ],
                  ),
                if (showBack) const SizedBox(height: 8),
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
