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
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_choice_visuals.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_feedback_sheet.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_progress_header.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';
import 'package:live_poker_trainer/ui/screens/lesson_result_screen.dart';

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
  String? _errorDetail;
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
    _activityController?.removeListener(_onActivityChanged);
    _activityController?.dispose();
    super.dispose();
  }

  void _onActivityChanged() {
    if (mounted) setState(() {});
  }

  void _bindActivityController(LessonActivityController next) {
    _activityController?.removeListener(_onActivityChanged);
    _activityController?.onAutoSubmit = null;
    _activityController?.dispose();
    _activityController = next;
    _activityController!.onAutoSubmit = () {
      if (!mounted) return;
      unawaited(_submit());
    };
    _activityController!.addListener(_onActivityChanged);
  }

  Future<void> _bootstrap() async {
    setState(() {
      _bootstrapping = true;
      _error = null;
      _errorDetail = null;
    });
    try {
      if (widget.courseService == null) {
        await ref
            .read(authControllerProvider.notifier)
            .ensureAnonymousSession();
      }
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
      final current = activities.firstWhere(
        (a) => a.id == started.resume.activityId,
        orElse: () => activities.first,
      );
      _bindActivityController(LessonActivityController(activity: current));
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
        _error = _friendlyStartError(error);
        _errorDetail = error.toString();
      });
    }
  }

  /// Short learner-facing copy for bootstrap failures (keeps raw detail aside).
  static String _friendlyStartError(Object error) {
    final raw = error.toString();
    final lower = raw.toLowerCase();
    if (lower.contains('api_key_invalid') ||
        lower.contains('api key not valid') ||
        lower.contains('api-key-not-valid')) {
      return 'Could not reach the course service. Firebase is misconfigured '
          'on this build (invalid API key).';
    }
    if (lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('unavailable')) {
      return 'Network issue starting the lesson. Check your connection and retry.';
    }
    if (lower.contains('permission-denied') || lower.contains('unauthenticated')) {
      return 'Sign-in failed before the lesson could start. Retry in a moment.';
    }
    // Prefer short CourseServiceException messages when present.
    final match = RegExp(r'CourseServiceException:\s*(.+)').firstMatch(raw);
    if (match != null) {
      return match.group(1)!.trim();
    }
    if (raw.length <= 160 && !raw.contains('UserInfo=')) {
      return raw;
    }
    return 'Something went wrong starting this lesson. Retry, or come back shortly.';
  }

  double get _progress {
    if (_activities.isEmpty || _attempt == null) return 0;
    // Prefer the visible activity so progress does not jump ahead while
    // soft-grade feedback is still on screen.
    final visibleId =
        _activityController?.activity.id ?? _attempt!.currentActivityId;
    final index = _activities.indexWhere((a) => a.id == visibleId);
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

    // Local cursor drifted from the attempt snapshot (e.g. after a partial
    // resume). Re-sync instead of sending a stale activityId.
    if (controller.activity.id != attempt.currentActivityId) {
      await _resyncToServerCursor();
      return;
    }

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
      final gradedIndex = _activities.indexWhere(
        (a) => a.id == controller.activity.id,
      );
      final advancedActivity = result.accepted &&
          (result.resume.activityId != controller.activity.id ||
              result.resume.activityIndex >= _activities.length);
      setState(() {
        _attempt = CourseAttemptSnapshot(
          attemptId: attempt.attemptId,
          lessonId: attempt.lessonId,
          catalogVersion: attempt.catalogVersion,
          status: result.remediationRequired ? 'remediation' : attempt.status,
          // Stay on the graded activity until Continue binds resume. Advancing
          // the local cursor early is what produced "Stale activity" after
          // restarts when Check fired again against the previous step.
          activityIndex: gradedIndex >= 0 ? gradedIndex : attempt.activityIndex,
          currentActivityId: controller.activity.id,
          livesRemaining: result.livesRemaining,
          livesMax: attempt.livesMax,
          acceptedCount:
              attempt.acceptedCount +
              (advancedActivity && !result.duplicate ? 1 : 0),
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
      if (_isStaleActivityError(error)) {
        await _resyncToServerCursor(
          notice: 'Caught up to your saved progress.',
        );
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
      setState(() {});
    }
  }

  bool _isStaleActivityError(Object error) {
    if (error is CourseServiceException) {
      final message = error.message.toLowerCase();
      return error.code == 'aborted' || message.contains('stale activity');
    }
    return '$error'.toLowerCase().contains('stale activity');
  }

  /// Re-reads the server resume pointer and rebinds the visible activity.
  Future<void> _resyncToServerCursor({String? notice}) async {
    final catalog = ref.read(courseCatalogProvider).asData?.value;
    final controller = _activityController;
    if (catalog == null || controller == null) return;
    try {
      final started = await _service.startLesson(
        lessonId: widget.lessonId,
        catalogVersion: catalog.catalogVersion,
        startRequestId: CourseService.newRequestKey('resync'),
      );
      if (!mounted) return;
      final activities =
          _activities.isEmpty
              ? catalog.activitiesForLesson(widget.lessonId)
              : _activities;
      final current = activities.firstWhere(
        (a) => a.id == started.resume.activityId,
        orElse: () => activities.first,
      );
      controller.bindActivity(current);
      setState(() {
        _activities = activities;
        _attempt = started.attempt;
        _error = null;
        _bootstrapping = false;
      });
      if (notice != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(notice)));
      }
    } catch (error) {
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

    // Multi-step: server stays on this activity until the last street.
    final steps = controller.activity.handSteps;
    final stepIdx = controller.draft.handStepIndex;
    final stayedOnActivity = result.resume.activityId == controller.activity.id;
    if (steps.length > 1 &&
        stepIdx < steps.length - 1 &&
        stayedOnActivity) {
      controller.advanceToNextHandStep();
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
    if (attempt == null || _completing) return;
    setState(() => _completing = true);
    try {
      final catalog = await ref.read(courseCatalogProvider.future);
      final complete = await _service
          .completeLesson(
            attemptId: attempt.attemptId,
            idempotencyKey: CourseService.newRequestKey('complete'),
            catalogVersion: catalog.catalogVersion,
          )
          .timeout(const Duration(seconds: 45));
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
        // AppRoot switches home to SaveProgressScreen via pendingSaveProgress.
        // Do not push a second SaveProgress route — it would stick on the
        // navigator after Continue learning clears the flag.
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
      final detail = _errorDetail;
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                      style: GoogleFonts.manrope(
                        color: AppColors.slate,
                        height: 1.4,
                        fontSize: 15,
                      ),
                    ),
                    if (detail != null &&
                        detail.isNotEmpty &&
                        detail != _error) ...[
                      const SizedBox(height: 16),
                      Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: const EdgeInsets.only(bottom: 8),
                          title: Text(
                            'Technical details',
                            style: GoogleFonts.manrope(
                              color: AppColors.goldMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          children: [
                            SelectableText(
                              detail,
                              style: GoogleFonts.manrope(
                                color: AppColors.slate.withValues(alpha: 0.85),
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                setState(() {
                  _bootstrapping = true;
                  _error = null;
                  _errorDetail = null;
                });
                _bootstrap();
              },
              child: const Text('Retry'),
            ),
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

    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.15;
    return Padding(
      // Tighter chrome so short explain/order steps sit up, not mid-void.
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
              LessonProgressHeader(
                // Prompt lives once in the activity body — avoid duplicating it.
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
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  // No artificial minHeight — short steps hug the top.
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
                            onFeltAcknowledge:
                                isTableRegionTapActivity(activity) &&
                                        activity.renderer ==
                                            ActivityRenderer.coachDialogue
                                    ? _submit
                                    : null,
                          ),
                          if (controller.hintVisible && hint != null) ...[
                            const SizedBox(height: 10),
                            RexCoachLine(text: hint.text, label: 'Hint'),
                          ],
                          if (controller.lastResult != null) ...[
                            const SizedBox(height: 12),
                            LessonFeedbackSheet(
                              result: controller.lastResult!,
                              betterChoiceLabel: _labelForChoice(
                                activity,
                                controller.lastResult!.betterChoiceId,
                              ),
                              // Sticky footer owns Continue / Try again so
                              // CTAs stay reachable on short viewports.
                              showActions: false,
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
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final result = controller.lastResult;
                  if (result != null) {
                    return _FeedbackFooter(
                      result: result,
                      completing: _completing,
                      onContinue: _continueAfterFeedback,
                      onRetry:
                          result.accepted
                              ? null
                              : () {
                                controller.clearFeedbackForRetry();
                                setState(() {});
                              },
                    );
                  }
                  final canSubmit = _canSubmit && !_completing;
                  final autoSubmit = isAutoSubmitSelectIdentify(activity) ||
                      isTableRegionTapActivity(activity) ||
                      activity.renderer == ActivityRenderer.orderSequence ||
                      activity.renderer == ActivityRenderer.compareRank ||
                      activity.renderer ==
                          ActivityRenderer.pokerActionSizing ||
                      activity.renderer ==
                          ActivityRenderer.authoredMultiStepHand ||
                      activity.renderer ==
                          ActivityRenderer.playerReadClassify ||
                      isLessonActionTableActivity(activity);
                  if (autoSubmit) {
                    // Teach-by-doing: taps auto-submit — no Check dock.
                    if (controller.submitting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox(height: 8);
                  }
                  return Row(
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
                          onPressed: canSubmit ? _submit : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.bgDark,
                            disabledBackgroundColor: AppColors.slateDark,
                            disabledForegroundColor: AppColors.slate,
                          ),
                          child: Text(
                            controller.submitting
                                ? 'Checking…'
                                : activity.renderer ==
                                    ActivityRenderer.coachDialogue
                                ? 'Continue'
                                : isLessonActionTableActivity(activity)
                                // Avoid colliding with dock CHECK / CHECK (off).
                                ? 'Lock in'
                                : 'Check',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
      ),
    );
  }

  String? _labelForChoice(CourseActivity activity, String? choiceId) {
    if (choiceId == null) return null;
    if (isTableRegionTapActivity(activity)) {
      final short = _tableChoiceShortLabel(choiceId);
      if (short != null) return short;
    }
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

String? _tableChoiceShortLabel(String choiceId) {
  return switch (choiceId) {
    'choice-hero-holes' ||
    'choice-only-you' ||
    'choice-checkpoint-holes' ||
    'choice-hero-again' => 'your hole cards',
    'choice-board' ||
    'choice-flop' ||
    'choice-checkpoint-board' => 'the board',
    'choice-villain' ||
    'choice-whole-table' ||
    'choice-checkpoint-all' => 'other seats',
    'choice-dealer-only' => 'the dealer',
    'choice-muck' => 'the muck',
    'btn-seat' => 'the button',
    'bb-seat' || 'bb-two' => 'the big blind',
    'sb-one' || 'sb-seat0' || 'sb-seat1' || 'sb-seat4' => 'the small blind',
    'empty-seat' => 'an empty seat',
    'before-deal' => 'before the deal',
    'after-flop' => 'after the flop',
    'only-showdown' => 'at showdown',
    _ => null,
  };
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

/// Sticky Continue / Try again actions so feedback CTAs never sit under the fold.
///
/// Grade color lives on [LessonFeedbackSheet]; the dock always uses gold so the
/// next-step affordance reads as brand Continue (not a second grade badge).
class _FeedbackFooter extends StatelessWidget {
  const _FeedbackFooter({
    required this.result,
    required this.onContinue,
    required this.completing,
    this.onRetry,
  });

  final SubmitCourseStepResult result;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;
  final bool completing;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.15;
    final accepted = result.accepted;
    final continueLabel = accepted ? 'Continue' : 'Got it';
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.slateDark.withValues(alpha: 0.85),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            if (onRetry != null && !accepted) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: completing ? null : onRetry,
                  child: const Text('Try again'),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Semantics(
                button: true,
                label: continueLabel,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: largeText ? 54 : 52),
                  child: FilledButton(
                    onPressed: completing ? null : onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bgDark,
                      disabledBackgroundColor: AppColors.slateDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        completing
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppColors.bgDark,
                              ),
                            )
                            : Text(
                              continueLabel,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
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
