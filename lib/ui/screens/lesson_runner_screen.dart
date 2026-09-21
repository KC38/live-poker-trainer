/// Interactive lesson runner with resume, soft-grade feedback, and registry.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/course/activity_registry.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_feedback_sheet.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_progress_header.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';
import 'package:live_poker_trainer/ui/screens/lesson_result_screen.dart';
import 'package:live_poker_trainer/ui/screens/onboarding_screens.dart';

/// Runs one catalog lesson through Plan 03 course callables.
class LessonRunnerScreen extends ConsumerStatefulWidget {
  /// Creates a runner for [lessonId].
  const LessonRunnerScreen({
    super.key,
    required this.lessonId,
    this.embeddedInShell = false,
    this.courseService,
    this.startRequestId,
  });

  /// Lesson to start or resume.
  final String lessonId;

  /// When true, keeps shell chrome; when false this is a standalone route.
  final bool embeddedInShell;

  /// Optional injectable service (tests).
  final CourseService? courseService;

  /// Optional stable start key (tests / resume).
  final String? startRequestId;

  @override
  ConsumerState<LessonRunnerScreen> createState() => _LessonRunnerScreenState();
}

class _LessonRunnerScreenState extends ConsumerState<LessonRunnerScreen> {
  LessonActivityController? _activityController;
  CourseAttemptSnapshot? _attempt;
  CourseLesson? _lesson;
  List<CourseActivity> _activities = const [];
  String? _error;
  bool _bootstrapping = true;
  bool _completing = false;
  int _acceptedStreak = 0;
  late final String _startRequestId;

  CourseService get _service =>
      widget.courseService ?? ref.read(courseServiceProvider);

  @override
  void initState() {
    super.initState();
    _startRequestId =
        widget.startRequestId ?? CourseService.newRequestKey('start');
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _activityController?.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _bootstrapping = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).ensureAnonymousSession();
      final catalog = await ref.read(courseCatalogProvider.future);
      final lesson = catalog.lessonById(widget.lessonId);
      if (lesson == null) {
        throw CourseServiceException(
          'Unknown lesson ${widget.lessonId}',
          code: 'not-found',
        );
      }
      final draft = ref.read(onboardingControllerProvider);
      await _service.initializeProfile(
        catalogVersion: catalog.catalogVersion,
        experienceBand: draft.experienceBand?.wireValue,
        dailyGoalMinutes: draft.dailyGoalMinutes,
        recommendedLessonId: draft.recommendedLessonId ?? widget.lessonId,
      );
      final started = await _service.startLesson(
        lessonId: widget.lessonId,
        catalogVersion: catalog.catalogVersion,
        startRequestId: _startRequestId,
      );
      final activities = catalog.activitiesForLesson(widget.lessonId);
      _activityController?.dispose();
      _activityController = LessonActivityController(
        activity: activities.firstWhere(
          (a) => a.id == started.resume.activityId,
          orElse: () => activities.first,
        ),
      );
      if (!mounted) return;
      setState(() {
        _lesson = lesson;
        _activities = activities;
        _attempt = started.attempt;
        _bootstrapping = false;
      });
      if (!started.duplicate) {
        unawaited(
          ref
              .read(analyticsServiceProvider)
              .logLesson(lessonId: widget.lessonId, phase: 'started'),
        );
      }
      if (started.attempt.isReadyToComplete(activities.length)) {
        await _completeLesson();
        return;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bootstrapping = false;
        _error = error.toString();
      });
    }
  }

  double get _progress {
    if (_activities.isEmpty || _attempt == null) return 0;
    final index = _activities.indexWhere(
      (a) => a.id == _attempt!.currentActivityId,
    );
    if (index < 0) return 0;
    return (index +
            (_activityController?.lastResult?.accepted == true ? 1 : 0)) /
        _activities.length;
  }

  bool get _canSubmit {
    final c = _activityController;
    if (c == null || c.submitting || c.lastResult != null) return false;
    final activity = c.activity;
    if (activity.renderer == ActivityRenderer.coachDialogue ||
        activity.stage == ActivityStage.explain) {
      return true;
    }
    if (activity.renderer == ActivityRenderer.orderSequence ||
        activity.renderer == ActivityRenderer.compareRank) {
      return c.draft.orderedIds.length == activity.sequenceItems.length &&
          activity.sequenceItems.isNotEmpty;
    }
    if (activity.renderer == ActivityRenderer.numericPotPrice) {
      return c.draft.numericValue != null;
    }
    return c.draft.choiceId != null;
  }

  Future<void> _submit() async {
    final controller = _activityController;
    final attempt = _attempt;
    final catalog = ref.read(courseCatalogProvider).asData?.value;
    if (controller == null || attempt == null || catalog == null) return;
    if (!_canSubmit) return;

    final key = controller.ensureIdempotencyKey(
      () => CourseService.newRequestKey('step'),
    );
    controller.beginSubmit(key);
    setState(() {});

    try {
      final result = await _service.submitStep(
        attemptId: attempt.attemptId,
        activityId: controller.activity.id,
        idempotencyKey: key,
        catalogVersion: catalog.catalogVersion,
        choiceId: controller.draft.choiceId,
        orderedIds:
            controller.draft.orderedIds.isEmpty
                ? null
                : controller.draft.orderedIds,
        numericValue: controller.draft.numericValue,
      );
      if (!mounted) return;
      controller.finishSubmit(result);
      setState(() {
        _attempt = CourseAttemptSnapshot(
          attemptId: attempt.attemptId,
          lessonId: attempt.lessonId,
          catalogVersion: attempt.catalogVersion,
          status: result.remediationRequired ? 'remediation' : attempt.status,
          activityIndex: result.resume.activityIndex,
          currentActivityId: result.resume.activityId,
          livesRemaining: result.livesRemaining,
          livesMax: attempt.livesMax,
          acceptedCount:
              attempt.acceptedCount +
              (result.accepted && !result.duplicate ? 1 : 0),
          scoredCount: attempt.scoredCount,
          stepCount: attempt.stepCount + (result.duplicate ? 0 : 1),
          jumpTestPassed: attempt.jumpTestPassed,
        );
        if (result.accepted) {
          _acceptedStreak += 1;
        } else if (!result.duplicate) {
          _acceptedStreak = 0;
        }
      });
      unawaited(_playFeedbackSound(result));
      if (!result.duplicate) {
        final analytics = ref.read(analyticsServiceProvider);
        final stage = _stageWire(controller.activity.stage);
        final grade = _gradeWire(result.grade);
        unawaited(
          analytics.logGradeBand(
            lessonId: attempt.lessonId,
            activityId: result.activityId,
            grade: grade,
            stage: stage,
          ),
        );
        if (result.lifeLost) {
          unawaited(
            analytics.logLifeLost(
              lessonId: attempt.lessonId,
              activityId: result.activityId,
              livesRemaining: result.livesRemaining,
            ),
          );
        }
        if (result.remediationRequired) {
          unawaited(
            analytics.logRemediation(
              lessonId: attempt.lessonId,
              activityId: result.activityId,
              kind: 'life_loop',
            ),
          );
        }
        if (controller.activity.stage == ActivityStage.jumpTest) {
          unawaited(
            analytics.logJumpTest(
              lessonId: attempt.lessonId,
              result: result.accepted ? 'passed' : 'failed',
            ),
          );
        }
      }
    } catch (error) {
      controller.failSubmit();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
      setState(() {});
    }
  }

  Future<void> _playFeedbackSound(SubmitCourseStepResult result) async {
    final sound = ref.read(soundServiceProvider);
    await sound.unlock();
    if (result.accepted) {
      await sound.chip();
    } else if (result.grade == SoftGrade.clearMistake) {
      await sound.fold();
    } else {
      await sound.knock();
    }
  }

  Future<void> _continueAfterFeedback() async {
    final controller = _activityController;
    final result = controller?.lastResult;
    final attempt = _attempt;
    if (controller == null || result == null || attempt == null) return;

    if (!result.accepted) {
      controller.clearFeedbackForRetry();
      setState(() {});
      return;
    }

    final isLast =
        _activities.isNotEmpty && controller.activity.id == _activities.last.id;
    if (isLast) {
      await _completeLesson();
      return;
    }

    final next = _activities.firstWhere(
      (a) => a.id == result.resume.activityId,
      orElse: () {
        final idx = _activities.indexWhere(
          (a) => a.id == controller.activity.id,
        );
        return _activities[(idx + 1).clamp(0, _activities.length - 1)];
      },
    );
    controller.bindActivity(next);
    setState(() {
      _attempt = CourseAttemptSnapshot(
        attemptId: attempt.attemptId,
        lessonId: attempt.lessonId,
        catalogVersion: attempt.catalogVersion,
        status: attempt.status,
        activityIndex: result.resume.activityIndex,
        currentActivityId: next.id,
        livesRemaining: result.livesRemaining,
        livesMax: attempt.livesMax,
        acceptedCount: attempt.acceptedCount,
        scoredCount: attempt.scoredCount,
        stepCount: attempt.stepCount,
        jumpTestPassed: attempt.jumpTestPassed,
      );
    });
  }

  Future<void> _completeLesson() async {
    final attempt = _attempt;
    final catalog = ref.read(courseCatalogProvider).asData?.value;
    if (attempt == null || catalog == null || _completing) return;
    setState(() => _completing = true);
    try {
      final complete = await _service.completeLesson(
        attemptId: attempt.attemptId,
        idempotencyKey: CourseService.newRequestKey('complete'),
        catalogVersion: catalog.catalogVersion,
      );
      if (!mounted) return;
      unawaited(ref.read(soundServiceProvider).win());
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logLesson(lessonId: complete.lessonId, phase: 'completed'),
      );
      final isAnonymous =
          ref.read(authServiceProvider).currentUser?.isAnonymous == true;
      if (isAnonymous && !widget.embeddedInShell) {
        await ref
            .read(onboardingControllerProvider.notifier)
            .markFirstLessonComplete(
              lessonTitle: _lesson?.title ?? 'Lesson',
              result: complete,
            );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const SaveProgressScreen()),
          (route) => false,
        );
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder:
              (_) => LessonResultScreen(
                lessonTitle: _lesson?.title ?? 'Lesson',
                result: complete,
                standalone: !widget.embeddedInShell,
              ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _completing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(
          _lesson?.title ?? 'Lesson',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _buildBody() {
    if (_bootstrapping) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Could not start the lesson',
              style: GoogleFonts.manrope(
                color: AppColors.cream,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.manrope(color: AppColors.slate, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _bootstrap, child: const Text('Retry')),
          ],
        ),
      );
    }

    final controller = _activityController!;
    final activity = controller.activity;
    final attempt = _attempt!;
    final showGuidance = controller.showTargetCue;
    final hint =
        activity.hintMedia.isNotEmpty ? activity.hintMedia.first : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.15;
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            children: [
              LessonProgressHeader(
                title: activity.prompt ?? activity.accessibilityText,
                progress: _progress,
                livesRemaining: attempt.livesRemaining,
                livesMax: attempt.livesMax,
                acceptedStreak: _acceptedStreak,
                hintEnabled: hint != null && !controller.hintVisible,
                onHint:
                    hint == null
                        ? null
                        : () {
                          controller.revealHint();
                          setState(() {});
                          final attempt = _attempt;
                          if (attempt == null) return;
                          unawaited(
                            ref
                                .read(analyticsServiceProvider)
                                .logRemediation(
                                  lessonId: attempt.lessonId,
                                  activityId: controller.activity.id,
                                  kind: 'hint',
                                ),
                          );
                        },
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight * 0.35,
                    ),
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            activityRegistry.build(
                              activity: activity,
                              controller: controller,
                              showGuidance: showGuidance,
                            ),
                            if (controller.hintVisible && hint != null) ...[
                              const SizedBox(height: 14),
                              RexCoachLine(text: hint.text, label: 'Hint'),
                            ],
                            if (controller.lastResult != null) ...[
                              const SizedBox(height: 18),
                              LessonFeedbackSheet(
                                result: controller.lastResult!,
                                betterChoiceLabel: _labelForChoice(
                                  activity,
                                  controller.lastResult!.betterChoiceId,
                                ),
                                onContinue: _continueAfterFeedback,
                                onRetry:
                                    controller.lastResult!.accepted
                                        ? null
                                        : () {
                                          controller.clearFeedbackForRetry();
                                          setState(() {});
                                        },
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (controller.lastResult == null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (controller.draft.hasAnswer)
                      TextButton(
                        onPressed:
                            controller.submitting
                                ? null
                                : () {
                                  controller.undoDraft();
                                  setState(() {});
                                },
                        child: const Text('Undo'),
                      ),
                    const Spacer(),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: largeText ? 160 : 140,
                        minHeight: 48,
                      ),
                      child: FilledButton(
                        onPressed: _canSubmit && !_completing ? _submit : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.bgDark,
                        ),
                        child: Text(
                          controller.submitting
                              ? 'Checking…'
                              : activity.renderer ==
                                  ActivityRenderer.coachDialogue
                              ? 'Continue'
                              : 'Check',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String? _labelForChoice(CourseActivity activity, String? choiceId) {
    if (choiceId == null) return null;
    for (final choice in activity.choices) {
      if (choice.id == choiceId) return choice.label;
    }
    for (final step in activity.handSteps) {
      for (final choice in step.choices) {
        if (choice.id == choiceId) return choice.label;
      }
    }
    return choiceId;
  }
}

String _gradeWire(SoftGrade grade) {
  return switch (grade) {
    SoftGrade.recommended => 'recommended',
    SoftGrade.strong => 'strong',
    SoftGrade.reasonable => 'reasonable',
    SoftGrade.questionable => 'questionable',
    SoftGrade.clearMistake => 'clear_mistake',
  };
}

String _stageWire(ActivityStage stage) {
  return switch (stage) {
    ActivityStage.explain => 'explain',
    ActivityStage.guided => 'guided',
    ActivityStage.scaffolded => 'scaffolded',
    ActivityStage.unguided => 'unguided',
    ActivityStage.checkpoint => 'checkpoint',
    ActivityStage.jumpTest => 'jump_test',
  };
}
