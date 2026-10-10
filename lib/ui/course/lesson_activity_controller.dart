/// Local interaction state for one activity before/during server submit.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';

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
  ///
  /// [isReview] is true when this lesson was already completed. SoftPulse
  /// stays off until Hint, matching first-time teaching vs a replay.
  LessonActivityController({
    required CourseActivity activity,
    this.isReview = false,
  }) : _activity = activity;

  /// True when replaying a lesson the learner already finished.
  final bool isReview;

  CourseActivity _activity;
  ActivityDraft _draft = const ActivityDraft();
  SubmitCourseStepResult? _lastResult;
  ActivityDraft? _redoDraft;
  bool _submitting = false;
  bool _hintVisible = false;
  /// False while the felt is still dealing this activity's cards.
  bool _feltDealReady = true;
  /// Node key (`activityId#handStepIndex`) for which Hint was already used.
  String? _hintUsedNodeKey;
  /// Node key for the active multi-press SoftPulse sequence, if any.
  String? _sequentialCueNodeKey;
  /// True while [currentNodeKey] still has multi-press taps left.
  bool _sequentialPressesRemaining = false;
  /// SoftPulse wave is open: first press (or Hint re-grant) may glow.
  bool _sequentialSoftPulseWaveOpen = true;
  int _hintRequests = 0;
  String? _pendingIdempotencyKey;
  int _bindGeneration = 0;

  /// Face-down seat the learner just tapped, when seats have distinct labels.
  String? _tappedSeatLabel;

  /// Invoked when an activity selects an answer that should submit immediately
  /// (e.g. tapping a table region — teach-by-doing, no separate Check).
  VoidCallback? onAutoSubmit;

  CourseActivity get activity => _activity;
  ActivityDraft get draft => _draft;
  SubmitCourseStepResult? get lastResult => _lastResult;
  bool get submitting => _submitting;
  bool get hintVisible => _hintVisible;

  /// True when the felt has no in-flight deal (or this step has no felt).
  bool get feltDealReady => _feltDealReady;

  /// One lesson screen: activity id plus the active hand-street index.
  String get currentNodeKey => '${_activity.id}#${_draft.handStepIndex}';

  /// True after the learner taps Hint once on [currentNodeKey].
  ///
  /// Scoped per screen (activity + hand step), not for the whole lesson —
  /// advancing to the next activity or street re-enables Hint.
  bool get hintUsed => _hintUsedNodeKey == currentNodeKey;

  /// True while a multi-press node still has taps left.
  ///
  /// After [hintUsed], Hint re-enables only when the SoftPulse wave is closed
  /// (learner tapped the cued target) so the next press can be hinted again.
  bool get sequentialPressesRemaining =>
      _sequentialPressesRemaining && _sequentialCueNodeKey == currentNodeKey;

  /// Whether the Hint control should accept a tap right now.
  ///
  /// Multi-press SoftPulse: Hint is off while the current wave already shows
  /// the next target (teaching SoftPulse or a just-revealed Hint). Tapping
  /// that target closes the wave and re-enables Hint for the following press.
  /// Single-press nodes: Hint stays available until used once on this screen.
  bool get canRequestHint {
    if (!hintUsed) {
      if (sequentialPressesRemaining &&
          _sequentialSoftPulseWaveOpen &&
          showTargetCue) {
        return false;
      }
      return true;
    }
    return sequentialPressesRemaining && !_sequentialSoftPulseWaveOpen;
  }

  int get hintRequests => _hintRequests;
  String? get pendingIdempotencyKey => _pendingIdempotencyKey;

  /// Opponent seat label from the last felt tap, if the miss should name it.
  String? get tappedSeatLabel => _tappedSeatLabel;

  /// Bumps when [bindActivity] runs so activity widgets can remount cleanly.
  int get bindGeneration => _bindGeneration;

  /// Whether SoftPulse / tap cues should remain visible.
  ///
  /// Teaching stages keep their authored cues on a first run. Completed-
  /// lesson reviews and same-concept guided replays stay quiet until Hint
  /// (see [lessonFrameSoftPulseQuietByDefault]). Revealing a hint unlocks
  /// the same highlights on quieter stages (unguided / checkpoint /
  /// jump-test). Cues stay off while the felt is still dealing cards.
  ///
  /// Multi-press sequences SoftPulse only the current wave when Hint can
  /// re-open the next press. Teaching steps that already SoftPulse with
  /// Hint disabled keep the next-target cue on.
  bool get showTargetCue {
    final unlocked = _hintVisible ||
        (!lessonFrameSoftPulseQuietByDefault(activity, isReview: isReview) &&
            (activity.stage == ActivityStage.explain ||
                activity.stage == ActivityStage.guided ||
                activity.stage == ActivityStage.scaffolded));
    if (!unlocked) return false;
    if (!_feltDealReady) return false;
    // When cues are already on and Hint is disabled, keep SoftPulse on the
    // next press. Sequential wave-close is only for stages that can re-open
    // via Hint.
    if (!lessonFrameHintShownByDefault(activity, isReview: isReview) &&
        _sequentialCueNodeKey == currentNodeKey &&
        !_sequentialSoftPulseWaveOpen) {
      return false;
    }
    return true;
  }

  /// Reports how many presses remain in a multi-press SoftPulse sequence.
  ///
  /// Call from multi-press demos on build / after taps so Hint can re-open
  /// SoftPulse until [remainingPressCount] reaches zero. Does not consume
  /// SoftPulse.
  void notifySequentialPressProgress({required int remainingPressCount}) {
    final remaining = remainingPressCount > 0;
    var changed = false;
    if (remaining && _sequentialCueNodeKey != currentNodeKey) {
      _sequentialCueNodeKey = currentNodeKey;
      changed = true;
    }
    if (_sequentialPressesRemaining != remaining) {
      _sequentialPressesRemaining = remaining;
      changed = true;
    }
    if (!remaining && _hintVisible) {
      _hintVisible = false;
      changed = true;
    }
    if (!changed) return;
    // Defer so callers can finish the current build / setState.
    scheduleMicrotask(() {
      if (hasListeners) notifyListeners();
    });
  }

  /// Ends the current SoftPulse wave after the learner taps the cued target.
  ///
  /// Later presses stay quiet until [revealHint] / [toggleHint] re-opens the
  /// wave for one more press.
  void consumeSequentialSoftPulse() {
    if (!_sequentialSoftPulseWaveOpen) return;
    _sequentialSoftPulseWaveOpen = false;
    // Multi-press nodes must be marked before SoftPulse can stay off.
    _sequentialCueNodeKey ??= currentNodeKey;
    notifyListeners();
  }

  /// Felt deal progress — SoftPulse stays off until [ready] is true.
  void notifyFeltDealReady(bool ready) {
    if (_feltDealReady == ready) return;
    _feltDealReady = ready;
    scheduleMicrotask(() {
      if (hasListeners) notifyListeners();
    });
  }

  void bindActivity(CourseActivity next) {
    // Always reset local draft/feedback — including rebinding the same
    // activity id after a stale-activity resync or cold resume.
    _activity = next;
    _draft = const ActivityDraft();
    _lastResult = null;
    _submitting = false;
    _hintVisible = false;
    _feltDealReady = true;
    _hintUsedNodeKey = null;
    _sequentialCueNodeKey = null;
    _sequentialPressesRemaining = false;
    _sequentialSoftPulseWaveOpen = true;
    _pendingIdempotencyKey = null;
    _tappedSeatLabel = null;
    _bindGeneration += 1;
    notifyListeners();
  }

  void selectChoice(
    String choiceId, {
    bool autoSubmit = false,
    String? seatLabel,
  }) {
    if (_submitting || _lastResult != null) return;
    // Ignore stale taps from a just-replaced activity (e.g. Continue rebound
    // the controller to scaffolded while a guided SoftPulse onPressed still
    // fires with the previous choice id).
    // Authored multi-step hands keep choices on the active hand step, not
    // the top-level activity.choices list.
    final knownTopLevel = _activity.choices.any((c) => c.id == choiceId);
    final steps = _activity.handSteps;
    final knownHandStep =
        steps.isNotEmpty &&
        steps[_draft.handStepIndex.clamp(0, steps.length - 1)].choices.any(
          (c) => c.id == choiceId,
        );
    if (!knownTopLevel && !knownHandStep) {
      assert(() {
        debugPrint(
          'LessonActivityController: ignore unknown choiceId=$choiceId '
          'for activity=${_activity.id}',
        );
        return true;
      }());
      return;
    }
    assert(() {
      debugPrint(
        'LessonActivityController: selectChoice '
        'activity=${_activity.id} choiceId=$choiceId autoSubmit=$autoSubmit',
      );
      return true;
    }());
    _draft = _draft.copyWith(choiceId: choiceId);
    _tappedSeatLabel = seatLabel;
    notifyListeners();
    if (autoSubmit) {
      _selectionHaptic();
      onAutoSubmit?.call();
    }
  }

  void setOrderedIds(List<String> ids, {bool autoSubmit = false}) {
    if (_submitting || _lastResult != null) return;
    _draft = _draft.copyWith(orderedIds: List.unmodifiable(ids));
    notifyListeners();
    if (autoSubmit) {
      _selectionHaptic();
      onAutoSubmit?.call();
    }
  }

  void setNumericValue(double? value, {bool autoSubmit = false}) {
    if (_submitting || _lastResult != null) return;
    if (value == null) {
      _draft = _draft.copyWith(clearNumeric: true);
    } else {
      _draft = _draft.copyWith(numericValue: value);
    }
    notifyListeners();
    if (autoSubmit && value != null) {
      _selectionHaptic();
      onAutoSubmit?.call();
    }
  }

  void setHandStepIndex(int index) {
    _draft = _draft.copyWith(handStepIndex: index, clearChoice: true);
    notifyListeners();
  }

  /// True when undo can revert a local answer or clear a miss.
  bool get canUndo =>
      !_submitting &&
      _lastResult?.accepted != true &&
      (_draft.hasAnswer || _lastResult != null);

  /// True when redo can restore the draft [undoDraft] just cleared.
  bool get canRedo => _redoDraft != null && !_submitting && _lastResult == null;

  /// Undo local selection before a successful accepted advance.
  void undoDraft() {
    if (_submitting) return;
    if (_lastResult != null && _lastResult!.accepted) return;
    if (_lastResult == null && _draft.hasAnswer) {
      _redoDraft = _draft;
    } else {
      _redoDraft = null;
    }
    _draft = ActivityDraft(handStepIndex: _draft.handStepIndex);
    _lastResult = null;
    _tappedSeatLabel = null;
    notifyListeners();
  }

  /// Restores the draft cleared by the last [undoDraft].
  void redoDraft() {
    final saved = _redoDraft;
    if (saved == null || _submitting || _lastResult != null) return;
    _draft = saved;
    _redoDraft = null;
    notifyListeners();
  }

  /// Grades a miss on this device. Continue stays on the same step.
  void presentLocalMiss(SubmitCourseStepResult result) {
    if (_submitting || _lastResult != null) return;
    _lastResult = result;
    _redoDraft = null;
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  /// Shows or hides the hint in the speech bubble.
  void toggleHint() {
    _hintVisible = !_hintVisible;
    if (_hintVisible) {
      _hintUsedNodeKey = currentNodeKey;
      // Re-open SoftPulse for the current next press only.
      _sequentialSoftPulseWaveOpen = true;
      _hintRequests += 1;
    }
    notifyListeners();
  }

  /// Reveals the hint for the current lesson screen.
  ///
  /// On multi-press nodes Hint may be tapped again after the learner taps
  /// the cued target (wave closed) while presses remain; each reveal
  /// re-opens SoftPulse for the current next press only.
  void revealHint() {
    _hintVisible = true;
    _hintUsedNodeKey = currentNodeKey;
    _sequentialSoftPulseWaveOpen = true;
    _hintRequests += 1;
    notifyListeners();
  }

  /// Clear feedback and move to the next authored hand street in-place.
  void advanceToNextHandStep() {
    if (_submitting) return;
    _lastResult = null;
    _pendingIdempotencyKey = null;
    _hintVisible = false;
    _feltDealReady = true;
    _sequentialCueNodeKey = null;
    _sequentialPressesRemaining = false;
    _sequentialSoftPulseWaveOpen = true;
    // New hand street = new screen; Hint becomes available again because
    // [hintUsed] compares against [currentNodeKey].
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
    if (result.accepted) {
      _acceptedHaptic();
    }
    notifyListeners();
  }

  /// Subtle tick on felt-tap / choice auto-submit (not mid-build taps).
  void _selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  /// Light confirmation when an accepted grade lands — never on mistakes.
  void _acceptedHaptic() {
    HapticFeedback.lightImpact();
  }

  void failSubmit() {
    _submitting = false;
    notifyListeners();
  }

  void clearFeedbackForRetry() {
    if (_lastResult?.accepted == true) return;
    _lastResult = null;
    _tappedSeatLabel = null;
    // New attempt at this activity gets a fresh key next submit.
    _pendingIdempotencyKey = null;
    // Drop the missed answer so SoftPulse / felt selection can restore to
    // the teach target (e.g. big blind after tapping the dealer).
    _draft = ActivityDraft(handStepIndex: _draft.handStepIndex);
    notifyListeners();
  }

  /// Ensures one idempotency key per in-flight answer attempt.
  String ensureIdempotencyKey(String Function() mint) {
    return _pendingIdempotencyKey ??= mint();
  }
}
