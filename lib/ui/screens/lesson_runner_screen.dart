/// Interactive lesson runner with resume, soft-grade feedback, and registry.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/course_home_provider.dart';
import 'package:live_poker_trainer/providers/course_progress_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/course/activity_registry.dart';
import 'package:live_poker_trainer/ui/course/kicker_showdown.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/heart_refill_sheet.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_choice_visuals.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_feedback_sheet.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_progress_header.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';
import 'package:live_poker_trainer/ui/screens/lesson_result_screen.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

/// Runs one catalog lesson through Plan 03 course callables.
class LessonRunnerScreen extends ConsumerStatefulWidget {
  /// Creates a runner for [lessonId].
  const LessonRunnerScreen({
    super.key,
    required this.lessonId,
    this.embeddedInShell = false,
    this.allowZeroHeartsPractice = false,
    this.courseService,
    this.startRequestId,
    this.bootstrapTimeout = const Duration(seconds: 45),
  });

  /// Lesson to start or resume.
  final String lessonId;

  /// When true, keeps shell chrome; when false this is a standalone route.
  final bool embeddedInShell;

  /// When true, play is allowed at zero hearts so Practice can earn one back.
  ///
  /// Only set this from the heart-refill "Practice" action. Map opens and
  /// mid-lesson continue always gate at zero hearts.
  final bool allowZeroHeartsPractice;

  /// Optional injectable service (tests).
  final CourseService? courseService;

  /// Optional stable start key (tests / resume).
  final String? startRequestId;

  /// Caps auth + startLesson so a hung handoff never leaves an empty spinner.
  final Duration bootstrapTimeout;

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

  /// True while Continue is swapping to the next activity — keeps feedback
  /// chrome (no blank dock / full-screen spinner flash).
  bool _advancingActivity = false;
  int _acceptedStreak = 0;

  /// Accepted-step XP granted in this session. Added to the completion bonus
  /// so Nice work and the result screen show the lesson total.
  int _stepXpAwarded = 0;

  /// Inline catch-up notice under the progress header (never a felt SnackBar).
  String? _resumeNotice;
  Timer? _resumeNoticeTimer;
  late final String _startRequestId;

  /// Guards against stacking multiple heart-refill sheets.
  bool _heartRefillSheetOpen = false;

  /// True while a mid-lesson heart refill callable is in flight.
  bool _heartRefillBusy = false;

  /// Bumps the empty-heart chrome pulse when play is blocked.
  int _heartsNudgeTick = 0;

  /// Fires when a passive heart should reach an open zero-heart lesson.
  Timer? _heartResyncTimer;

  /// True while a passive-heart startLesson resync is in flight.
  bool _heartResyncInFlight = false;

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
    _heartResyncTimer?.cancel();
    _resumeNoticeTimer?.cancel();
    _activityController?.removeListener(_onActivityChanged);
    _activityController?.dispose();
    lessonDealAttemptSalt = '';
    super.dispose();
  }

  void _setDealSalt(String attemptId) {
    lessonDealAttemptSalt = attemptId;
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
    Object? failure;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await _bootstrapBody().timeout(widget.bootstrapTimeout);
        return;
      } on TimeoutException {
        if (!mounted) return;
        setState(() {
          _bootstrapping = false;
          _error =
              'Starting this lesson is taking too long. Check your connection '
              'and retry.';
          _errorDetail = 'TimeoutException after ${widget.bootstrapTimeout}';
        });
        return;
      } catch (error) {
        failure = error;
        // The first anonymous Firestore read can be denied before the token
        // is attached. One more start is what Retry did, without the player.
        final denied = error.toString().toLowerCase().contains(
          'permission-denied',
        );
        if (attempt == 0 && denied) continue;
        break;
      }
    }
    if (!mounted || failure == null) return;
    final error = failure;
    setState(() {
      _bootstrapping = false;
      _error = _friendlyStartError(error);
      _errorDetail = error.toString();
    });
  }

  void _retryBootstrap() {
    setState(() {
      _bootstrapping = true;
      _error = null;
      _errorDetail = null;
    });
    _bootstrap();
  }

  /// The catalog lesson that must be finished before this start can succeed.
  CourseLesson? _previousLesson() {
    final detail = _errorDetail?.toLowerCase() ?? '';
    if (!detail.contains('failed-precondition')) return null;
    final catalog = ref.read(courseCatalogProvider).asData?.value;
    if (catalog == null) return null;
    final lesson = catalog.lessonById(widget.lessonId);
    if (lesson == null || lesson.prerequisites.isEmpty) return null;
    return catalog.lessonById(lesson.prerequisites.first);
  }

  Future<void> _bootstrapBody() async {
    if (widget.courseService == null) {
      await ref.read(authControllerProvider.notifier).ensureAnonymousSession();
    }
    final catalog = await ref.read(courseCatalogProvider.future);
    final lesson = catalog.lessonById(widget.lessonId);
    if (lesson == null) {
      throw CourseServiceException(
        'Unknown lesson ${widget.lessonId}',
        code: 'not-found',
      );
    }
    // Prefix openlesson ids resolve in the catalog; the backend only knows
    // the canonical full lesson id.
    final lessonId = lesson.id;
    final draft = ref.read(onboardingControllerProvider);
    await _service.initializeProfile(
      catalogVersion: catalog.catalogVersion,
      experienceBand: draft.experienceBand?.wireValue,
      dailyGoalMinutes: draft.dailyGoalMinutes,
      streakGoalDays: draft.streakGoalDays,
      recommendedLessonId: draft.recommendedLessonId ?? lessonId,
    );
    final started = await _service.startLesson(
      lessonId: lessonId,
      catalogVersion: catalog.catalogVersion,
      startRequestId: _startRequestId,
    );
    final activities = catalog.activitiesForLesson(lessonId);
    final current = activities.firstWhere(
      (a) => a.id == started.resume.activityId,
      orElse: () => activities.first,
    );
    _bindActivityController(LessonActivityController(activity: current));
    _setDealSalt(started.attempt.attemptId);
    unawaited(ref.read(soundServiceProvider).unlock());
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
            .logLesson(lessonId: lessonId, phase: 'started'),
      );
    }
    if (started.attempt.isReadyToComplete(activities.length)) {
      await _completeLesson();
      return;
    }
    if (_heartsGateActive) {
      _armPassiveHeartResync();
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
    if (lower.contains('permission-denied')) {
      return 'Missing or insufficient permissions.';
    }
    if (lower.contains('unauthenticated')) {
      return 'Sign-in failed before the lesson could start. Retry in a moment.';
    }
    // toString is CourseServiceException($code): $message. The code must
    // stay in Technical details, not in the learner sentence.
    final match = RegExp(r'CourseServiceException(?:\([^)]*\))?:\s*(.+)')
        .firstMatch(raw);
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
    if (_heartsGateActive) return false;
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

  /// Zero-heart lessons pause until a refill, unless opened as Practice.
  bool get _heartsGateActive {
    final attempt = _attempt;
    if (attempt == null) return false;
    if (attempt.livesRemaining > 0) return false;
    if (widget.allowZeroHeartsPractice) return false;
    return true;
  }

  /// Schedules one server resync for when the next passive heart is due.
  ///
  /// The attempt document does not accrue hearts on its own. [startLesson]
  /// copies the profile wallet, including a heart that just came due, back
  /// onto the open attempt so the in-place gate can lift.
  void _armPassiveHeartResync({int? livesNextRefillAtMs}) {
    _heartResyncTimer?.cancel();
    _heartResyncTimer = null;
    if (!_heartsGateActive) return;
    var atMs = livesNextRefillAtMs;
    if (atMs == null && ref.exists(courseHomeProvider)) {
      atMs = ref.read(courseHomeProvider).asData?.value.livesNextRefillAtMs;
    }
    if (atMs == null) return;
    final delayMs = atMs - DateTime.now().millisecondsSinceEpoch;
    _heartResyncTimer = Timer(
      Duration(milliseconds: delayMs <= 0 ? 0 : delayMs),
      () {
        unawaited(_resyncHeartsFromServer());
      },
    );
  }

  /// Pulls profile hearts onto the open attempt after a passive refill.
  Future<void> _resyncHeartsFromServer() async {
    if (!mounted || _heartResyncInFlight || !_heartsGateActive) return;
    final lessonId = _lesson?.id ?? widget.lessonId;
    final catalog = ref.read(courseCatalogProvider).asData?.value;
    if (catalog == null) return;
    _heartResyncInFlight = true;
    try {
      final started = await _service.startLesson(
        lessonId: lessonId,
        catalogVersion: catalog.catalogVersion,
        startRequestId: CourseService.newRequestKey('heart_sync'),
      );
      if (!mounted) return;
      final restored = started.attempt.livesRemaining;
      if (restored <= 0) return;
      final attempt = _attempt;
      if (attempt == null) return;
      setState(() {
        _attempt = CourseAttemptSnapshot(
          attemptId: attempt.attemptId,
          lessonId: attempt.lessonId,
          catalogVersion: attempt.catalogVersion,
          status: attempt.status == 'remediation'
              ? 'in_progress'
              : attempt.status,
          activityIndex: attempt.activityIndex,
          currentActivityId: attempt.currentActivityId,
          livesRemaining: restored,
          livesMax: started.attempt.livesMax,
          acceptedCount: attempt.acceptedCount,
          scoredCount: attempt.scoredCount,
          stepCount: attempt.stepCount,
          jumpTestPassed: attempt.jumpTestPassed,
        );
      });
      _heartResyncTimer?.cancel();
      _heartResyncTimer = null;
    } catch (_) {
      // The gate stays up. The next refill action or a fresh open retries.
    } finally {
      _heartResyncInFlight = false;
    }
  }

  /// Keeps a ready Home wallet aligned with the graded step.
  void _syncReadyHomeHearts(SubmitCourseStepResult result) {
    if (!ref.exists(courseHomeProvider)) return;
    final home = ref.read(courseHomeProvider).asData?.value;
    if (home == null || home.status != CourseHomeLoadStatus.ready) return;
    ref
        .read(courseHomeProvider.notifier)
        .applyStepHeartWallet(
          livesRemaining: result.livesRemaining,
          livesMax: home.livesMax,
          livesNextRefillAtMs: result.livesNextRefillAtMs,
        );
  }

  Future<void> _submit() async {
    final controller = _activityController;
    final attempt = _attempt;
    // Felt-tap explains hide the Check dock — never silent-no-op while the
    // catalog provider is mid-reload (same class of bug as #228 complete).
    if (controller == null || attempt == null) return;
    if (_heartsGateActive) {
      _nudgeEmptyHearts();
      return;
    }
    if (!_canSubmit) return;

    // Local cursor drifted from the attempt snapshot (e.g. after a partial
    // resume). Re-sync instead of sending a stale activityId.
    if (controller.activity.id != attempt.currentActivityId) {
      await _resyncToServerCursor();
      return;
    }

    final CourseCatalog catalog;
    try {
      catalog = await ref.read(courseCatalogProvider.future);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson content is still loading. Try again.'),
        ),
      );
      return;
    }
    if (!mounted) return;

    final key = controller.ensureIdempotencyKey(
      () => CourseService.newRequestKey('step'),
    );
    controller.beginSubmit(key);
    setState(() {});

    assert(() {
      debugPrint(
        'LessonRunner: submit activity=${controller.activity.id} '
        'choiceId=${controller.draft.choiceId}',
      );
      return true;
    }());

    try {
      final result = await _service.submitStep(
        attemptId: attempt.attemptId,
        activityId: controller.activity.id,
        idempotencyKey: key,
        catalogVersion: catalog.catalogVersion,
        choiceId: controller.draft.choiceId,
        orderedIds: controller.draft.orderedIds.isEmpty
            ? null
            : controller.draft.orderedIds,
        numericValue: controller.draft.numericValue,
      );
      if (!mounted) return;
      final displayResult = () {
        if (controller.activity.id != kickerShowdownActivityId) {
          return result;
        }
        final scene = dealtLessonTableScene(
          controller.activity,
          generation: controller.bindGeneration,
        );
        if (scene == null) return result;
        return rewriteKickerShowdownResult(
          result: result,
          heroCodes: scene.heroCodes,
          boardCodes: scene.boardCodes,
          villainCodes: scene.villainCodes,
        );
      }();
      controller.finishSubmit(displayResult);
      final gradedIndex = _activities.indexWhere(
        (a) => a.id == controller.activity.id,
      );
      final advancedActivity =
          result.accepted &&
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
        if (!result.duplicate) {
          _stepXpAwarded += result.xpAwarded;
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
      if (result.livesRemaining > 0) {
        _heartResyncTimer?.cancel();
        _heartResyncTimer = null;
      }
      _syncReadyHomeHearts(result);
      if (result.remediationRequired || result.livesRemaining <= 0) {
        _armPassiveHeartResync(livesNextRefillAtMs: result.livesNextRefillAtMs);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _nudgeEmptyHearts();
        });
      }
    } catch (error) {
      controller.failSubmit();
      if (!mounted) return;
      if (_isStaleActivityError(error)) {
        // Only banner when the server cursor actually jumps — silent when the
        // mid-lesson resync lands on the same step (common race / double-tap).
        await _resyncToServerCursor(
          noticeIfCursorJumped: 'Caught up to your saved progress.',
        );
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
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
  Future<void> _resyncToServerCursor({String? noticeIfCursorJumped}) async {
    final controller = _activityController;
    if (controller == null) return;
    final priorActivityId = controller.activity.id;
    final CourseCatalog catalog;
    try {
      catalog = await ref.read(courseCatalogProvider.future);
    } catch (_) {
      return;
    }
    if (!mounted) return;
    try {
      final lessonId = _lesson?.id ?? catalog.lessonById(widget.lessonId)?.id;
      if (lessonId == null) return;
      final started = await _service.startLesson(
        lessonId: lessonId,
        catalogVersion: catalog.catalogVersion,
        startRequestId: CourseService.newRequestKey('resync'),
      );
      if (!mounted) return;
      final activities = _activities.isEmpty
          ? catalog.activitiesForLesson(lessonId)
          : _activities;
      final current = activities.firstWhere(
        (a) => a.id == started.resume.activityId,
        orElse: () => activities.first,
      );
      final jumped = current.id != priorActivityId;
      controller.bindActivity(current);
      _setDealSalt(started.attempt.attemptId);
      setState(() {
        _activities = activities;
        _attempt = started.attempt;
        _error = null;
        _bootstrapping = false;
      });
      if (jumped && noticeIfCursorJumped != null && mounted) {
        _showNonBlockingNotice(noticeIfCursorJumped);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
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

  /// Inline banner under the progress header — never covers suit/order taps.
  void _showNonBlockingNotice(String notice) {
    ScaffoldMessenger.of(context).clearSnackBars();
    _resumeNoticeTimer?.cancel();
    setState(() => _resumeNotice = notice);
    _resumeNoticeTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _resumeNotice = null);
    });
  }

  Future<void> _continueAfterFeedback() async {
    final controller = _activityController;
    final result = controller?.lastResult;
    final attempt = _attempt;
    if (controller == null ||
        result == null ||
        attempt == null ||
        _advancingActivity ||
        _completing) {
      return;
    }

    if (!result.accepted) {
      if (_heartsGateActive) {
        _nudgeEmptyHearts();
        return;
      }
      controller.clearFeedbackForRetry();
      setState(() {});
      return;
    }

    // Multi-step: server stays on this activity until the last street.
    final steps = controller.activity.handSteps;
    final stepIdx = controller.draft.handStepIndex;
    final stayedOnActivity = result.resume.activityId == controller.activity.id;
    if (steps.length > 1 && stepIdx < steps.length - 1 && stayedOnActivity) {
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

    // Keep current activity + feedback dock painted for one frame while
    // Continue shows a lightweight spinner — never blank the body with a
    // full-screen loader.
    setState(() => _advancingActivity = true);
    final resume = result.resume;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final live = _activityController;
      if (live == null) {
        // Never leave Continue spinning if the controller was cleared.
        setState(() => _advancingActivity = false);
        return;
      }
      live.bindActivity(next);
      setState(() {
        _advancingActivity = false;
        _attempt = CourseAttemptSnapshot(
          attemptId: attempt.attemptId,
          lessonId: attempt.lessonId,
          catalogVersion: attempt.catalogVersion,
          status: attempt.status,
          activityIndex: resume.activityIndex,
          currentActivityId: next.id,
          livesRemaining: result.livesRemaining,
          livesMax: attempt.livesMax,
          acceptedCount: attempt.acceptedCount,
          scoredCount: attempt.scoredCount,
          stepCount: attempt.stepCount,
          jumpTestPassed: attempt.jumpTestPassed,
        );
      });
    });
  }

  Future<void> _completeLesson() async {
    final attempt = _attempt;
    if (attempt == null || _completing) return;
    setState(() => _completing = true);
    try {
      final complete = await () async {
        final catalog = await ref.read(courseCatalogProvider.future);
        return _service.completeLesson(
          attemptId: attempt.attemptId,
          idempotencyKey: CourseService.newRequestKey('complete'),
          catalogVersion: catalog.catalogVersion,
        );
      }().timeout(const Duration(seconds: 45));
      if (!mounted) return;
      final shown = CompleteCourseLessonResult(
        attemptId: complete.attemptId,
        lessonId: complete.lessonId,
        xpAwarded: displayedLessonXp(
          stepXpAwarded: _stepXpAwarded,
          completionBonus: complete.xpAwarded,
          lessonXpFromServer: complete.lessonXpAwarded,
        ),
        lessonXpAwarded: complete.lessonXpAwarded,
        mastery: complete.mastery,
        streak: complete.streak,
        acceptedAccuracy: complete.acceptedAccuracy,
        liveTrainingGranted: complete.liveTrainingGranted,
        duplicate: complete.duplicate,
        resume: complete.resume,
      );
      unawaited(ref.read(soundServiceProvider).win());
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logLesson(lessonId: complete.lessonId, phase: 'completed'),
      );
      final isAnonymous = ref.read(authServiceProvider).isAnonymous;
      final onboarding = ref.read(onboardingControllerProvider);
      // Home and Profile read cached course state. Completion does not
      // invalidate them, so a guest who just finished still saw NEXT on
      // this lesson. Refresh copies that are already alive; a Home that
      // mounts after this fetches on first build.
      ref.invalidate(courseProgressProvider);
      if (ref.exists(courseHomeProvider)) {
        unawaited(ref.read(courseHomeProvider.notifier).refresh());
      }
      // Only the first guest lesson (onboarding / launch, not Home) should
      // flip pendingSaveProgress. Re-entering that path from later map
      // lessons left Continue spinning when AppRoot did not unmount us.
      // Step is the gate: a stale firstLessonCompleted flag must not skip
      // the account prompt when this launch is still the onboarding lesson.
      final onboardingLaunch =
          onboarding.step == OnboardingStep.firstLesson ||
          onboarding.step == OnboardingStep.recommendedStart;
      if (isAnonymous &&
          !widget.embeddedInShell &&
          onboarding.step != OnboardingStep.done &&
          (onboardingLaunch || !onboarding.firstLessonCompleted)) {
        await ref
            .read(onboardingControllerProvider.notifier)
            .markFirstLessonComplete(
              lessonTitle: _lesson?.title ?? 'Lesson',
              result: shown,
            )
            .timeout(const Duration(seconds: 8));
        // AppRoot remounts onto the post-lesson streak celebration. If this
        // route is still mounted, the prompt did not replace us — do not open
        // the lesson-complete screen, whose CONTINUE pops onto a stale Home.
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        if (mounted) {
          setState(() => _completing = false);
        }
        return;
      }
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LessonResultScreen(
            lessonTitle: _lesson?.title ?? 'Lesson',
            result: shown,
            standalone: !widget.embeddedInShell,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _completing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  bool get _usesLessonFrame =>
      isLessonScreenFrameLesson(_lesson?.id ?? widget.lessonId);

  void _reportLocalMiss(String feedback) {
    final controller = _activityController;
    final attempt = _attempt;
    if (controller == null || attempt == null) return;
    controller.presentLocalMiss(
      SubmitCourseStepResult(
        attemptId: attempt.attemptId,
        activityId: controller.activity.id,
        grade: SoftGrade.clearMistake,
        feedback: feedback,
        accepted: false,
        lifeLost: false,
        livesRemaining: attempt.livesRemaining,
        xpAwarded: 0,
        remediationRequired: false,
        resume: CourseResumePointer(
          attemptId: attempt.attemptId,
          lessonId: attempt.lessonId,
          activityId: controller.activity.id,
          activityIndex: attempt.activityIndex,
        ),
        duplicate: false,
      ),
    );
  }

  String _frameSpeech(LessonActivityController controller) {
    if (controller.hintVisible) {
      final authored = controller.activity.hintMedia.isNotEmpty
          ? controller.activity.hintMedia.first.text
          : null;
      final hint = (authored == null || authored.trim().isEmpty)
          ? lessonFrameHintFallback(controller.activity)
          : authored;
      if (hint != null && hint.trim().isNotEmpty) return hint;
    }
    return lessonFrameSpeech(
      controller.activity,
      handStepIndex: controller.draft.handStepIndex,
      bindGeneration: controller.bindGeneration,
    );
  }

  bool _frameCanHint(CourseActivity activity) {
    if (lessonFrameHintsDisabled(activity)) return false;
    if (activity.hintMedia.isNotEmpty) return true;
    return lessonFrameHintFallback(activity) != null;
  }

  void _closeLesson() {
    Navigator.of(context).maybePop();
  }

  /// Subtle chrome pulse — no refill sheet unless the learner taps hearts.
  void _nudgeEmptyHearts() {
    if (!mounted || !_heartsGateActive) return;
    setState(() => _heartsNudgeTick += 1);
  }

  /// Opens the refill sheet in place while the lesson stays mounted.
  Future<void> _promptHeartRefill() async {
    if (!mounted || _heartRefillSheetOpen || !_heartsGateActive) return;
    _heartRefillSheetOpen = true;
    try {
      final home = ref.read(courseHomeProvider).asData?.value;
      final attempt = _attempt;
      final action = await showHeartRefillSheet(
        context: context,
        livesRemaining: attempt?.livesRemaining ?? home?.hearts ?? 0,
        livesMax: attempt?.livesMax ?? home?.livesMax ?? 5,
        gems: home?.gems ?? 0,
        livesNextRefillAtMs: home?.livesNextRefillAtMs,
        adClaimsRemainingToday: home?.adClaimsRemainingToday ?? 5,
        nextAdClaimAtMs: home?.nextAdClaimAtMs,
        busy: _heartRefillBusy,
      );
      if (!mounted || action == null) return;
      await _applyHeartRefillAction(action, retryBootstrapOnSuccess: false);
    } finally {
      _heartRefillSheetOpen = false;
    }
  }

  /// Applies gems / ad / practice from the refill sheet.
  Future<void> _applyHeartRefillAction(
    HeartRefillAction action, {
    required bool retryBootstrapOnSuccess,
  }) async {
    switch (action) {
      case HeartRefillAction.practice:
        if (!_heartsGateActive) return;
        if (mounted) Navigator.of(context).maybePop();
        return;
      case HeartRefillAction.ad:
        if (!_heartsGateActive) return;
        setState(() => _heartRefillBusy = true);
        try {
          final result = await watchAdAndClaimHeart(
            context: context,
            service: _service,
          );
          if (!mounted) return;
          _onHeartRefillSucceeded(
            result,
            retryBootstrap: retryBootstrapOnSuccess,
          );
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$error')));
        } finally {
          if (mounted) setState(() => _heartRefillBusy = false);
        }
      case HeartRefillAction.gems:
        if (!_heartsGateActive) return;
        setState(() => _heartRefillBusy = true);
        try {
          final result = await _service.refillHearts(
            method: 'gems',
            idempotencyKey: CourseService.newRequestKey('heart_gems'),
          );
          if (!mounted) return;
          _onHeartRefillSucceeded(
            result,
            retryBootstrap: retryBootstrapOnSuccess,
          );
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$error')));
        } finally {
          if (mounted) setState(() => _heartRefillBusy = false);
        }
    }
  }

  void _onHeartRefillSucceeded(
    RefillCourseHeartsResult result, {
    required bool retryBootstrap,
  }) {
    _heartResyncTimer?.cancel();
    _heartResyncTimer = null;
    final home = ref.read(courseHomeProvider.notifier);
    home.applyHeartRefill(result);
    unawaited(home.refresh());
    final attempt = _attempt;
    if (attempt != null && result.livesRemaining > 0) {
      setState(() {
        _attempt = CourseAttemptSnapshot(
          attemptId: attempt.attemptId,
          lessonId: attempt.lessonId,
          catalogVersion: attempt.catalogVersion,
          status: 'in_progress',
          activityIndex: attempt.activityIndex,
          currentActivityId: attempt.currentActivityId,
          livesRemaining: result.livesRemaining,
          livesMax: result.livesMax,
          acceptedCount: attempt.acceptedCount,
          scoredCount: attempt.scoredCount,
          stepCount: attempt.stepCount,
          jumpTestPassed: attempt.jumpTestPassed,
        );
      });
      _activityController?.clearFeedbackForRetry();
    }
    if (retryBootstrap) {
      _retryBootstrap();
    }
    if (!mounted) return;
    final message = heartRefillSuccessSnackBarMessage(result);
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Hearts for the lesson chrome while bootstrapping or after an error.
  ///
  /// Prefer the open attempt, then Home profile — never invent a full bar of
  /// five while the real count (e.g. 4) is already known on Home.
  (int remaining, int max) _frameLivesWhilePending() {
    final attempt = _attempt;
    if (attempt != null) {
      return (attempt.livesRemaining, attempt.livesMax);
    }
    final homeAsync = ref.watch(courseHomeProvider);
    final home = homeAsync.asData?.value ?? homeAsync.valueOrNull;
    if (home != null) {
      final max = home.livesMax > 0 ? home.livesMax : 5;
      return (home.hearts.clamp(0, max), max);
    }
    return (5, 5);
  }

  Widget _buildLessonFrameBody() {
    final onClose = _closeLesson;
    if (_bootstrapping || _error != null) {
      final (livesRemaining, livesMax) = _frameLivesWhilePending();
      return LessonScreenLayout(
        progress: 0,
        livesRemaining: livesRemaining,
        livesMax: livesMax,
        onClose: onClose,
        speech: '',
        expression: LessonMascotExpression.thinking,
        onUndo: () {},
        onRedo: () {},
        onHint: () {},
        canUndo: false,
        canRedo: false,
        canHint: false,
        stage: _error != null
            ? _buildBody()
            : const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
      );
    }

    final controller = _activityController!;
    final attempt = _attempt!;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final activity = controller.activity;
        final result = controller.lastResult;
        final expression = switch (result?.accepted) {
          null => LessonMascotExpression.thinking,
          true => LessonMascotExpression.happy,
          false => LessonMascotExpression.wrong,
        };
        return LessonScreenLayout(
          progress: _progress,
          livesRemaining: attempt.livesRemaining,
          livesMax: attempt.livesMax,
          onClose: onClose,
          notice: _resumeNotice,
          speech: _frameSpeech(controller),
          expression: expression,
          canUndo: !_heartsGateActive && controller.canUndo,
          canRedo: !_heartsGateActive && controller.canRedo,
          canHint:
              !_heartsGateActive &&
              _frameCanHint(activity) &&
              !controller.hintUsed,
          onUndo: controller.undoDraft,
          onRedo: controller.redoDraft,
          onHint: () {
            if (_heartsGateActive || controller.hintUsed) return;
            controller.revealHint();
            unawaited(
              ref
                  .read(analyticsServiceProvider)
                  .logRemediation(
                    lessonId: attempt.lessonId,
                    activityId: activity.id,
                    kind: 'hint',
                  ),
            );
          },
          result: result,
          recovery: result == null || result.accepted
              ? null
              : _labelForChoice(
                  activity,
                  result.betterChoiceId ??
                      (result.accepted
                          ? null
                          : _heroRecoveryChoiceId(activity)),
                ),
          onContinue: result == null ? null : _continueAfterFeedback,
          continueLabel: 'Continue',
          onRestoreHearts: _heartsGateActive ? _promptHeartRefill : null,
          onBlockedPlay: _heartsGateActive ? _nudgeEmptyHearts : null,
          emptyHeartsNudgeTick: _heartsNudgeTick,
          answerBusy: _completing || _advancingActivity || _heartRefillBusy,
          stage: LessonFrameScope(
            onLocalMiss: _reportLocalMiss,
            child: activityRegistry.build(
              activity: activity,
              controller: controller,
              showGuidance: controller.showTargetCue,
              onFeltAcknowledge:
                  isTableRegionTapActivity(activity) &&
                      activity.renderer == ActivityRenderer.coachDialogue
                  ? _submit
                  : null,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableFeaturesScope(
      features: TableFeatures.forLessonId(_lesson?.id ?? widget.lessonId),
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    if (_usesLessonFrame) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        // bottom: false so LessonAnswerDock paints edge-to-edge into the
        // home-indicator inset (Duolingo-style full-bleed feedback bar).
        body: SafeArea(bottom: false, child: _buildLessonFrameBody()),
      );
    }
    final body = _buildBody();
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(
          _lesson?.title ?? 'Lesson',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.15,
          ),
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
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
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
            if (_previousLesson() case final previous?) ...[
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LessonRunnerScreen(
                        lessonId: previous.id,
                        embeddedInShell: widget.embeddedInShell,
                        courseService: widget.courseService,
                      ),
                    ),
                  );
                },
                child: Text('Open ${previous.title}'),
              ),
              const SizedBox(height: 12),
            ],
            if (_error!.toLowerCase().contains('out of hearts')) ...[
              FilledButton(
                onPressed: () async {
                  final home = ref.read(courseHomeProvider).asData?.value;
                  final action = await showHeartRefillSheet(
                    context: context,
                    livesRemaining: home?.hearts ?? 0,
                    livesMax: home?.livesMax ?? 5,
                    gems: home?.gems ?? 0,
                    livesNextRefillAtMs: home?.livesNextRefillAtMs,
                    adClaimsRemainingToday: home?.adClaimsRemainingToday ?? 5,
                    nextAdClaimAtMs: home?.nextAdClaimAtMs,
                  );
                  if (!mounted || action == null) return;
                  await _applyHeartRefillAction(
                    action,
                    retryBootstrapOnSuccess: true,
                  );
                },
                child: const Text('Restore hearts'),
              ),
              const SizedBox(height: 12),
            ],
            _errorDetail?.toLowerCase().contains('failed-precondition') == true
                ? OutlinedButton(
                    onPressed: _retryBootstrap,
                    child: const Text('Retry'),
                  )
                : FilledButton(
                    onPressed: _retryBootstrap,
                    child: const Text('Retry'),
                  ),
          ],
        ),
      );
    }

    final controller = _activityController!;
    final activity = controller.activity;
    final attempt = _attempt!;
    final hasHint = _frameCanHint(activity);

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
            hintEnabled: hasHint && !controller.hintUsed,
            onHint: !hasHint
                ? null
                : () {
                    if (controller.hintUsed) return;
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
          if (_resumeNotice != null) ...[
            const SizedBox(height: 6),
            _ResumeCatchUpBanner(
              text: _resumeNotice!,
              onDismiss: () {
                _resumeNoticeTimer?.cancel();
                setState(() => _resumeNotice = null);
              },
            ),
          ],
          const SizedBox(height: 4),
          Expanded(
            child: Builder(
              builder: (context) {
                // Teach docks: fill Rex→footer with felt (no scroll void).
                // SoftPulse explains keep scroll so fixed felts hug the top.
                final fillFelt = isLessonActionTableActivity(activity);
                final feltAck =
                    isTableRegionTapActivity(activity) &&
                        activity.renderer == ActivityRenderer.coachDialogue
                    ? _submit
                    : null;
                final body = AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final activityPane = AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      layoutBuilder: fillFelt
                          ? (currentChild, previousChildren) {
                              return Stack(
                                fit: StackFit.expand,
                                alignment: Alignment.topCenter,
                                children: <Widget>[
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            }
                          : AnimatedSwitcher.defaultLayoutBuilder,
                      child: KeyedSubtree(
                        key: ValueKey<String>(activity.id),
                        child: activityRegistry.build(
                          activity: activity,
                          controller: controller,
                          // Re-read inside AnimatedBuilder so Hint toggles SoftPulse.
                          showGuidance: controller.showTargetCue,
                          onFeltAcknowledge: feltAck,
                        ),
                      ),
                    );
                    final lockedPane = _heartsGateActive
                        ? AbsorbPointer(child: activityPane)
                        : activityPane;
                    final hintText = activity.hintMedia.isNotEmpty
                        ? activity.hintMedia.first.text
                        : lessonFrameHintFallback(activity);
                    final hintLine =
                        controller.hintVisible &&
                            hintText != null &&
                            hintText.trim().isNotEmpty
                        ? <Widget>[
                            const SizedBox(height: 10),
                            RexCoachLine(text: hintText, label: 'Hint'),
                          ]
                        : const <Widget>[];
                    if (!fillFelt) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [lockedPane, ...hintLine],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: lockedPane),
                        ...hintLine,
                      ],
                    );
                  },
                );
                if (!fillFelt) {
                  return SingleChildScrollView(child: body);
                }
                return body;
              },
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final result = controller.lastResult;
              if (result != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    LessonFeedbackSheet(
                      result: result,
                      seatLabel: result.accepted
                          ? null
                          : controller.tappedSeatLabel,
                      betterChoiceLabel: _labelForChoice(
                        activity,
                        result.betterChoiceId ??
                            (result.accepted
                                ? null
                                : _heroRecoveryChoiceId(activity)),
                      ),
                      // Docked with Continue / Try again so the sheet
                      // and CTAs hug — no empty Expanded gap.
                      showActions: false,
                      onContinue: _continueAfterFeedback,
                      onRetry: result.accepted || _heartsGateActive
                          ? null
                          : () {
                              controller.clearFeedbackForRetry();
                              setState(() {});
                            },
                    ),
                    const SizedBox(height: 10),
                    _FeedbackFooter(
                      result: result,
                      completing:
                          _completing || _advancingActivity || _heartRefillBusy,
                      continueLabel: 'Continue',
                      onContinue: _continueAfterFeedback,
                      onRetry: result.accepted || _heartsGateActive
                          ? null
                          : () {
                              controller.clearFeedbackForRetry();
                              setState(() {});
                            },
                    ),
                  ],
                );
              }
              // Prefer live controller activity so advance never uses a
              // stale auto-submit / Undo decision for one frame.
              final liveActivity = controller.activity;
              final canSubmit = _canSubmit && !_completing;
              final autoSubmit =
                  isAutoSubmitSelectIdentify(liveActivity) ||
                  isTableRegionTapActivity(liveActivity) ||
                  liveActivity.renderer == ActivityRenderer.orderSequence ||
                  liveActivity.renderer == ActivityRenderer.compareRank ||
                  liveActivity.renderer == ActivityRenderer.pokerActionSizing ||
                  liveActivity.renderer == ActivityRenderer.fullTableHandLab ||
                  liveActivity.renderer ==
                      ActivityRenderer.authoredMultiStepHand ||
                  liveActivity.renderer ==
                      ActivityRenderer.playerReadClassify ||
                  isLessonActionTableActivity(liveActivity);
              if (autoSubmit) {
                // Teach-by-doing: taps auto-submit — no Check / Undo dock.
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
                      onPressed: controller.submitting
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
                            : liveActivity.renderer ==
                                  ActivityRenderer.coachDialogue
                            ? 'Continue'
                            : isLessonActionTableActivity(liveActivity)
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
    final recovery = tableChoiceRecoveryLabel(choiceId);
    // Hero-card misses name the You seat even when this activity is not in
    // the table-region id list. Other short labels stay on that list.
    if (recovery == 'You' ||
        (recovery != null && isTableRegionTapActivity(activity))) {
      return recovery;
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

  /// Hero-card choice on this activity, when a miss did not name one.
  String? _heroRecoveryChoiceId(CourseActivity activity) {
    for (final id in const [
      'choice-hero-holes',
      'choice-checkpoint-holes',
      'choice-only-you',
      'choice-hero-again',
    ]) {
      for (final choice in activity.choices) {
        if (choice.id == id) return id;
      }
    }
    return null;
  }
}

/// Felt label for a table-region choice, used on the miss recovery line.
///
/// Hero-card choices use You, the seat caption on the felt. A phrase that
/// is not on screen, such as "your hole cards", is not a recovery target.
@visibleForTesting
String? tableChoiceRecoveryLabel(String choiceId) {
  return switch (choiceId) {
    'choice-hero-holes' ||
    'choice-only-you' ||
    'choice-checkpoint-holes' ||
    'choice-hero-again' => 'You',
    'choice-board' || 'choice-flop' || 'choice-checkpoint-board' => 'the board',
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
    'chop-broadway' => 'chop — board plays',
    'button-wins' => 'button wins',
    'high-card-wins' => 'higher hole card',
    'you-kicker' => 'You win — better kicker',
    'they-kicker' => 'They win — their kicker',
    'chop-kicker' => 'Chop',
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

/// Inline catch-up chrome under [LessonProgressHeader] — keeps felt taps free.
class _ResumeCatchUpBanner extends StatelessWidget {
  const _ResumeCatchUpBanner({required this.text, required this.onDismiss});

  final String text;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.slateDark.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          children: [
            Icon(
              Icons.bookmark_added_outlined,
              size: 16,
              color: AppColors.gold,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 16),
              color: AppColors.slate,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Dismiss',
            ),
          ],
        ),
      ),
    );
  }
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
    this.continueLabel = 'Continue',
  });

  final SubmitCourseStepResult result;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;
  final bool completing;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    final accepted = result.accepted;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.slateDark.withValues(alpha: 0.85)),
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
                  constraints: const BoxConstraints(minHeight: 54),
                  child: FilledButton(
                    onPressed: completing ? null : onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bgDark,
                      // Keep gold while completing — slateDark + bgDark spinner
                      // read as an empty disabled bar (stuck Continue).
                      disabledBackgroundColor: AppColors.gold.withValues(
                        alpha: 0.72,
                      ),
                      disabledForegroundColor: AppColors.bgDark,
                      textStyle: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                      minimumSize: const Size.fromHeight(54),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: completing
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
                              fontSize: 16,
                              letterSpacing: 0.2,
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
