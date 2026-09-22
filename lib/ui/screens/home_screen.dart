/// Home: course path, status, resume, and Rex coach.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/models/course_table_return.dart';
import 'package:live_poker_trainer/models/live_access.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/course_home_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/home/course_path_view.dart';
import 'package:live_poker_trainer/ui/home/course_resume_card.dart';
import 'package:live_poker_trainer/ui/home/course_status_bar.dart';
import 'package:live_poker_trainer/ui/home/rex_coach_card.dart';
import 'package:live_poker_trainer/ui/screens/lesson_result_screen.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/screens/poker_table_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

/// Home tab — interactive live-cash course path.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the Home course root.
  const HomeScreen({super.key});

  /// Section 7 capstone. Tapping it opens the calibration table, not activity 0.
  static const calibrationLessonId = 'lesson-07-11-01-live-warmup-prep';

  /// Result node resumed after the calibration hand. Not the lesson id.
  static const calibrationResultNodeId =
      'result:lesson-07-11-01-live-warmup-prep';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _loggedStatus;

  @override
  Widget build(BuildContext context) {
    final asyncHome = ref.watch(courseHomeProvider);

    ref.listen(courseHomeProvider, (prev, next) {
      final snap = next.asData?.value;
      if (snap == null) return;
      final status = snap.status.name;
      if (_loggedStatus == status) return;
      _loggedStatus = status;
      unawaited(
        ref.read(analyticsServiceProvider).logHomeCourseView(status: status),
      );
    });

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
          child: asyncHome.when(
            loading:
                () => const _HomeMessage(
                  title: 'Loading course',
                  body: 'Pulling your path from the server…',
                ),
            error:
                (error, _) => _HomeMessage(
                  title: 'Could not load course',
                  body: error.toString(),
                  actionLabel: 'Retry',
                  onAction:
                      () => ref.read(courseHomeProvider.notifier).refresh(),
                ),
            data:
                (snapshot) => _HomeBody(
                  snapshot: snapshot,
                  onRetry:
                      () => ref.read(courseHomeProvider.notifier).refresh(),
                  onNodeTap: (node) => _onNodeTap(snapshot, node),
                  onResume: () {
                    final resume = snapshot.resume;
                    if (resume == null) return;
                    unawaited(
                      ref
                          .read(analyticsServiceProvider)
                          .logHomeResume(lessonId: resume.lessonId),
                    );
                    _openLesson(resume.lessonId);
                  },
                ),
          ),
        ),
      ),
    );
  }

  void _onNodeTap(CourseHomeSnapshot snapshot, CourseMapNode node) {
    final analytics = ref.read(analyticsServiceProvider);
    if (node.state == CourseNodeState.locked) {
      unawaited(analytics.logHomeNodeLockedTap(lessonId: node.lessonId));
      final message = node.lockReason ?? 'Finish the previous lesson first.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    if (!snapshot.startsEnabled && node.state != CourseNodeState.active) {
      unawaited(analytics.logHomeNodeLockedTap(lessonId: node.lessonId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New course attempts are paused.')),
      );
      return;
    }
    unawaited(
      analytics.logHomeNodeOpen(
        lessonId: node.lessonId,
        nodeState: node.state.name,
      ),
    );
    _openLesson(node.lessonId);
  }

  void _openLesson(String lessonId) {
    if (lessonId == HomeScreen.calibrationLessonId) {
      unawaited(_openCalibrationWarmUp(lessonId));
      return;
    }
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => LessonRunnerScreen(lessonId: lessonId),
          ),
        )
        .then((_) {
          if (!mounted) return;
          unawaited(ref.read(courseHomeProvider.notifier).refresh());
        });
  }

  Future<void> _openCalibrationWarmUp(String lessonId) async {
    ref
        .read(gameControllerProvider.notifier)
        .prepareTraining(
          courseContext: const CourseLiveContext(
            courseHandId: '',
            kind: 'calibration',
            lessonId: HomeScreen.calibrationLessonId,
            returnNodeId: HomeScreen.calibrationResultNodeId,
            scaffolding: 'reduced',
            rexPrompt: 'Calibration: one clean plan, less scaffolding.',
          ),
        );
    if (!mounted) return;
    final pop = await Navigator.of(context).push<Object?>(
      softFadeRoute(
        const PokerTableScreen(),
        name: AnalyticsScreens.pokerTable,
      ),
    );
    if (!mounted) return;
    final exit = pop is CourseTableReturn ? pop : null;
    if (exit != null && exit.completed) {
      await _presentCalibrationResult(exit, lessonId);
    }
    if (!mounted) return;
    unawaited(ref.read(courseHomeProvider.notifier).refresh());
  }

  /// Finished hands land on the lesson result. Unfinished exits never call this.
  Future<void> _presentCalibrationResult(
    CourseTableReturn exit,
    String lessonId,
  ) async {
    final sessionId = exit.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The calibration hand was not saved, so the lesson stays incomplete.',
          ),
        ),
      );
      return;
    }
    final snapshot = ref.read(courseHomeProvider).asData?.value;
    final title = _titleForLesson(snapshot, lessonId);
    try {
      final result = await ref
          .read(courseServiceProvider)
          .completeCalibrationWarmUp(
            lessonId: lessonId,
            sessionId: sessionId,
            catalogVersion: snapshot?.catalogVersion,
          );
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder:
              (_) => LessonResultScreen(lessonTitle: title, result: result),
        ),
      );
    } on CourseServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } on Object catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the calibration lesson.')),
      );
    }
  }

  String _titleForLesson(CourseHomeSnapshot? snapshot, String lessonId) {
    final nodes = snapshot?.nodes ?? const <CourseMapNode>[];
    for (final node in nodes) {
      if (node.lessonId == lessonId) return node.title;
    }
    return 'Lesson';
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.snapshot,
    required this.onRetry,
    required this.onNodeTap,
    required this.onResume,
  });

  final CourseHomeSnapshot snapshot;
  final VoidCallback onRetry;
  final void Function(CourseMapNode node) onNodeTap;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    if (snapshot.status != CourseHomeLoadStatus.ready) {
      return _HomeMessage(
        title: _titleFor(snapshot.status),
        body:
            snapshot.errorMessage ??
            snapshot.rexLine ??
            'Course path unavailable.',
        actionLabel:
            snapshot.status == CourseHomeLoadStatus.disabled ? null : 'Retry',
        onAction:
            snapshot.status == CourseHomeLoadStatus.disabled ? null : onRetry,
        rexLine: snapshot.rexLine,
      );
    }

    final resumeLessonTitle = () {
      final resume = snapshot.resume;
      if (resume == null) return null;
      for (final node in snapshot.nodes) {
        if (node.lessonId == resume.lessonId) return node.title;
      }
      return resume.lessonId;
    }();

    return CustomScrollView(
      key: const PageStorageKey<String>('home_course_scroll'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text('Home', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 6),
              Text(
                'Your live cash path — one clear next step.',
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              CourseStatusBar(
                streak: snapshot.streak,
                lifetimeXp: snapshot.lifetimeXp,
                acceptedAccuracy: snapshot.acceptedAccuracy,
              ),
              if (snapshot.rexLine != null) ...[
                const SizedBox(height: 14),
                RexCoachCard(
                  line: snapshot.rexLine!,
                  onContinue:
                      snapshot.resume != null
                          ? onResume
                          : (snapshot.nextLessonId == null ||
                                  !snapshot.startsEnabled
                              ? null
                              : () {
                                final next = snapshot.nextNode;
                                if (next == null) return;
                                onNodeTap(next);
                              }),
                  continueLabel: snapshot.resume != null ? 'Resume' : 'Start',
                ),
              ],
              if (snapshot.resume != null && resumeLessonTitle != null) ...[
                const SizedBox(height: 12),
                CourseResumeCard(
                  resume: snapshot.resume!,
                  lessonTitle: resumeLessonTitle,
                  onResume: onResume,
                ),
              ],
              const SizedBox(height: 20),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverToBoxAdapter(
            child: CoursePathView(nodes: snapshot.nodes, onNodeTap: onNodeTap),
          ),
        ),
      ],
    );
  }

  static String _titleFor(CourseHomeLoadStatus status) {
    return switch (status) {
      CourseHomeLoadStatus.disabled => 'Course unavailable',
      CourseHomeLoadStatus.offline => 'You are offline',
      CourseHomeLoadStatus.staleCatalog => 'Update required',
      CourseHomeLoadStatus.empty => 'No lessons yet',
      CourseHomeLoadStatus.error => 'Could not load course',
      CourseHomeLoadStatus.loading => 'Loading course',
      CourseHomeLoadStatus.ready => 'Home',
    };
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.rexLine,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? rexLine;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.goldBright),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (rexLine != null && rexLine != body) ...[
              const SizedBox(height: 16),
              RexCoachCard(line: rexLine!),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bgDark,
                  minimumSize: const Size(160, 48),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
