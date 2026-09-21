/// Local interaction state for one activity before/during server submit.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

/// Draft answer the learner is composing.
class ActivityDraft {
  /// Creates an empty draft.
  const ActivityDraft({
    this.choiceId,
    this.orderedIds = const <String>[],
    this.numericValue,
    this.handStepIndex = 0,
  });

  final String? choiceId;
  final List<String> orderedIds;
  final double? numericValue;
  final int handStepIndex;

  ActivityDraft copyWith({
    String? choiceId,
    List<String>? orderedIds,
    double? numericValue,
    int? handStepIndex,
    bool clearChoice = false,
    bool clearNumeric = false,
  }) {
    return ActivityDraft(
      choiceId: clearChoice ? null : (choiceId ?? this.choiceId),
      orderedIds: orderedIds ?? this.orderedIds,
      numericValue: clearNumeric ? null : (numericValue ?? this.numericValue),
      handStepIndex: handStepIndex ?? this.handStepIndex,
    );
  }

  bool get hasAnswer =>
      choiceId != null || orderedIds.isNotEmpty || numericValue != null;
}

/// Controller shared by activity widgets and the lesson runner.
class LessonActivityController extends ChangeNotifier {
  /// Creates a controller for [activity].
  LessonActivityController({required CourseActivity activity})
    : _activity = activity;

  CourseActivity _activity;
  ActivityDraft _draft = const ActivityDraft();
  SubmitCourseStepResult? _lastResult;
  bool _submitting = false;
  bool _hintVisible = false;
  int _hintRequests = 0;
  String? _pendingIdempotencyKey;
  int _bindGeneration = 0;

  CourseActivity get activity => _activity;
  ActivityDraft get draft => _draft;
  SubmitCourseStepResult? get lastResult => _lastResult;
  bool get submitting => _submitting;
  bool get hintVisible => _hintVisible;
  int get hintRequests => _hintRequests;
  String? get pendingIdempotencyKey => _pendingIdempotencyKey;

  /// Bumps when [bindActivity] runs so activity widgets can remount cleanly.
  int get bindGeneration => _bindGeneration;

  /// Whether guided/scaffolded cues should remain visible.
  bool get showTargetCue =>
      activity.stage == ActivityStage.explain ||
      activity.stage == ActivityStage.guided ||
      activity.stage == ActivityStage.scaffolded;

  void bindActivity(CourseActivity next) {
    // Always reset local draft/feedback — including rebinding the same
    // activity id after a stale-activity resync or cold resume.
    _activity = next;
    _draft = const ActivityDraft();
    _lastResult = null;
    _submitting = false;
    _hintVisible = false;
    _pendingIdempotencyKey = null;
    _bindGeneration += 1;
    notifyListeners();
  }

  void selectChoice(String choiceId) {
    if (_submitting || _lastResult != null) return;
    _draft = _draft.copyWith(choiceId: choiceId);
    notifyListeners();
  }

  void setOrderedIds(List<String> ids) {
    if (_submitting || _lastResult != null) return;
    _draft = _draft.copyWith(orderedIds: List.unmodifiable(ids));
    notifyListeners();
  }

  void setNumericValue(double? value) {
    if (_submitting || _lastResult != null) return;
    if (value == null) {
      _draft = _draft.copyWith(clearNumeric: true);
    } else {
      _draft = _draft.copyWith(numericValue: value);
    }
    notifyListeners();
  }

  void setHandStepIndex(int index) {
    _draft = _draft.copyWith(
      handStepIndex: index,
      clearChoice: true,
    );
    notifyListeners();
  }

  /// Undo local selection before a successful accepted advance.
  void undoDraft() {
    if (_submitting) return;
    if (_lastResult != null && _lastResult!.accepted) return;
    _draft = ActivityDraft(handStepIndex: _draft.handStepIndex);
    _lastResult = null;
    notifyListeners();
  }

  void revealHint() {
    _hintVisible = true;
    _hintRequests += 1;
    notifyListeners();
  }

  /// Clear feedback and move to the next authored hand street in-place.
  void advanceToNextHandStep() {
    if (_submitting) return;
    _lastResult = null;
    _pendingIdempotencyKey = null;
    _hintVisible = false;
    _draft = ActivityDraft(handStepIndex: _draft.handStepIndex + 1);
    notifyListeners();
  }

  void beginSubmit(String idempotencyKey) {
    _pendingIdempotencyKey = idempotencyKey;
    _submitting = true;
    notifyListeners();
  }

  void finishSubmit(SubmitCourseStepResult result) {
    _lastResult = result;
    _submitting = false;
    // Keep the same idempotency key so retries cannot double-submit.
    notifyListeners();
  }

  void failSubmit() {
    _submitting = false;
    notifyListeners();
  }

  void clearFeedbackForRetry() {
    if (_lastResult?.accepted == true) return;
    _lastResult = null;
    // New attempt at this activity gets a fresh key next submit.
    _pendingIdempotencyKey = null;
    notifyListeners();
  }

  /// Ensures one idempotency key per in-flight answer attempt.
  String ensureIdempotencyKey(String Function() mint) {
    return _pendingIdempotencyKey ??= mint();
  }
}
