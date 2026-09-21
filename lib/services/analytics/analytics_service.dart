/// Product analytics facade over Firebase Analytics.
///
/// All calls are best-effort: failures never throw into gameplay. Collection
/// can be disabled via [setCollectionEnabled] (Settings opt-out).
// ignore_for_file: prefer_initializing_formals
library;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Canonical screen names for [FirebaseAnalytics.logScreenView].
abstract final class AnalyticsScreens {
  /// Signed-out auth gate.
  static const auth = 'auth';

  /// Lesson-first welcome.
  static const welcome = 'welcome';

  /// Guest onboarding steps.
  static const onboarding = 'onboarding';

  /// Post-first-lesson save-progress prompt.
  static const saveProgress = 'save_progress';

  /// Home / course path.
  static const home = 'home';

  /// Live Training hub (table setup + launch).
  static const liveTraining = 'live_training';

  /// Progress / Profile tab.
  static const progress = 'progress';

  /// Settings.
  static const settings = 'settings';

  /// Live poker table.
  static const pokerTable = 'poker_table';
}

/// Thin wrapper around [FirebaseAnalytics] with a stable event vocabulary.
class AnalyticsService {
  /// Creates a service. Pass [analytics] in tests; omit in production.
  AnalyticsService({FirebaseAnalytics? analytics, bool enabled = true})
    : _analytics = analytics,
      _enabled = enabled;

  final FirebaseAnalytics? _analytics;
  bool _enabled;

  /// Whether events are currently accepted.
  bool get isEnabled => _enabled;

  /// Enables or disables Analytics collection on this device.
  Future<void> setCollectionEnabled(bool enabled) async {
    _enabled = enabled;
    try {
      await (_analytics ?? FirebaseAnalytics.instance)
          .setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('Analytics setCollectionEnabled failed: $e');
    }
  }

  /// Associates subsequent events with the signed-in Firebase uid.
  Future<void> setUserId(String? uid) async {
    if (!_enabled) return;
    try {
      await (_analytics ?? FirebaseAnalytics.instance).setUserId(id: uid);
    } catch (e) {
      debugPrint('Analytics setUserId failed: $e');
    }
  }

  /// Logs a screen view (also used by the navigator observer).
  Future<void> logScreenView(String screenName) async {
    await _log(() async {
      await (_analytics ?? FirebaseAnalytics.instance).logScreenView(
        screenName: screenName,
      );
    });
  }

  /// Email/password or Google sign-in.
  Future<void> logLogin({required String method}) async {
    await _log(() async {
      await (_analytics ?? FirebaseAnalytics.instance).logLogin(
        loginMethod: method,
      );
    });
  }

  /// New account registration.
  Future<void> logSignUp({required String method}) async {
    await _log(() async {
      await (_analytics ?? FirebaseAnalytics.instance).logSignUp(
        signUpMethod: method,
      );
    });
  }

  /// User signed out.
  Future<void> logLogout() async {
    await _event('logout');
  }

  /// User selected a shell tab ([IndexedStack] is not observed by Navigator).
  Future<void> logTabSelected({required String tab}) async {
    await _event('tab_selected', {'tab': tab});
  }

  /// User tapped Start Training (before navigation).
  Future<void> logTrainingLaunch({
    required int seatCount,
    required int stackDepthBb,
    required String lineupMode,
  }) async {
    await _event('training_launch', {
      'seat_count': seatCount,
      'stack_depth_bb': stackDepthBb,
      'lineup_mode': lineupMode,
    });
  }

  /// Server returned a situation and the hand was dealt.
  Future<void> logSituationFetched({
    required int seatCount,
    required int stackDepthBb,
    required bool continueTable,
  }) async {
    await _event('situation_fetched', {
      'seat_count': seatCount,
      'stack_depth_bb': stackDepthBb,
      'continue_table': continueTable ? 1 : 0,
    });
  }

  /// Situation fetch or deal failed.
  Future<void> logTrainingError({required String stage}) async {
    await _event('training_error', {'stage': stage});
  }

  /// Hero took a coached action.
  Future<void> logHeroDecision({
    required String street,
    required String actionType,
    required String verdict,
  }) async {
    await _event('hero_decision', {
      'street': street,
      'action_type': actionType,
      'verdict': verdict,
    });
  }

  /// Hand path was recorded to the server.
  Future<void> logHandCompleted({required num heroNetChips}) async {
    await _event('hand_completed', {
      'hero_net_chips_bucket': _chipBucket(heroNetChips.round()),
    });
  }

  /// Hand could not be saved.
  Future<void> logHandRecordFailed() async {
    await _event('hand_record_failed');
  }

  /// Progress screen became visible.
  Future<void> logProgressViewOpen() async {
    await _event('progress_view_open');
  }

  /// Progress screen left; [durationMs] is dwell time.
  Future<void> logProgressDwell({required int durationMs}) async {
    await _event('progress_dwell', {
      'duration_ms': durationMs.clamp(0, 3_600_000),
      'duration_bucket': _durationBucket(durationMs),
    });
  }

  /// Home course map became visible.
  Future<void> logHomeCourseView({required String status}) async {
    await _event('home_course_view', {'status': status});
  }

  /// User opened a course path node.
  Future<void> logHomeNodeOpen({
    required String lessonId,
    required String nodeState,
  }) async {
    await _event('home_node_open', {
      'lesson_id': lessonId,
      'node_state': nodeState,
    });
  }

  /// User tapped a locked course node.
  Future<void> logHomeNodeLockedTap({required String lessonId}) async {
    await _event('home_node_locked_tap', {'lesson_id': lessonId});
  }

  /// User resumed an interrupted course attempt from Home.
  Future<void> logHomeResume({required String lessonId}) async {
    await _event('home_resume', {'lesson_id': lessonId});
  }

  /// Analytics opt-in/out toggle changed.
  Future<void> logAnalyticsConsentChanged({required bool enabled}) async {
    // Always attempt once so opt-out itself is observable when still enabled.
    await _event('analytics_consent_changed', {'enabled': enabled ? 1 : 0});
  }

  /// Closed-set onboarding step (not free text or experience labels).
  Future<void> logOnboardingStep({required String step}) async {
    await _event('onboarding_step', {'step': step});
  }

  /// Lesson start or completion. [lessonId] is a public catalog id.
  Future<void> logLesson({
    required String lessonId,
    required String phase,
    int? durationMs,
  }) async {
    await _event('lesson', {
      'lesson_id': lessonId,
      'phase': phase,
      if (durationMs != null) 'duration_ms': durationMs.clamp(0, 3_600_000),
    });
  }

  /// Soft-grade band for a public activity. Never includes the choice text.
  Future<void> logGradeBand({
    required String lessonId,
    required String activityId,
    required String grade,
    required String stage,
  }) async {
    await _event('grade_band', {
      'lesson_id': lessonId,
      'activity_id': activityId,
      'grade': grade,
      'stage': stage,
    });
  }

  /// A scored clear mistake cost a life.
  Future<void> logLifeLost({
    required String lessonId,
    required String activityId,
    required int livesRemaining,
  }) async {
    await _event('life_lost', {
      'lesson_id': lessonId,
      'activity_id': activityId,
      'lives_remaining': livesRemaining.clamp(0, 20),
    });
  }

  /// Hint opened or a zero-life remediation loop started.
  Future<void> logRemediation({
    required String lessonId,
    required String activityId,
    required String kind,
  }) async {
    await _event('remediation', {
      'lesson_id': lessonId,
      'activity_id': activityId,
      'kind': kind,
    });
  }

  /// Jump-test outcome. [result] is `passed` or `failed`.
  Future<void> logJumpTest({
    required String lessonId,
    required String result,
  }) async {
    await _event('jump_test', {'lesson_id': lessonId, 'result': result});
  }

  /// Coached warm-up launched from Live Training.
  Future<void> logWarmUp({required String kind}) async {
    await _event('warm_up', {'kind': kind});
  }

  /// Anonymous session became a permanent account.
  Future<void> logAccountConversion({
    required String method,
    required String outcome,
  }) async {
    await _event('account_conversion', {'method': method, 'outcome': outcome});
  }

  /// Guest progress merge into a permanent account.
  Future<void> logProgressMerge({required String outcome}) async {
    await _event('progress_merge', {'outcome': outcome});
  }

  /// Best-effort named event without free-form PII payloads.
  Future<void> logEventSafe(String name, [Map<String, Object>? params]) async {
    await _event(name, params == null ? null : _safeParams(params));
  }

  Future<void> _event(String name, [Map<String, Object>? params]) async {
    await _log(() async {
      await (_analytics ?? FirebaseAnalytics.instance).logEvent(
        name: name,
        parameters: params == null ? null : _safeParams(params),
      );
    });
  }

  /// Drops parameter names that could carry cards, prompts, or free text.
  static Map<String, Object> _safeParams(Map<String, Object> params) {
    final safe = <String, Object>{};
    for (final entry in params.entries) {
      if (_forbiddenParam(entry.key.toLowerCase())) continue;
      safe[entry.key] = entry.value;
    }
    return safe;
  }

  static bool _forbiddenParam(String value) {
    const needles = [
      'hole',
      'card',
      'prompt',
      'answer',
      'grading',
      'free_text',
      'freetext',
      'password',
      'nonce',
      'credential',
    ];
    for (final needle in needles) {
      if (value.contains(needle)) return true;
    }
    return false;
  }

  /// Test seam for the privacy filter. Public course ids stay in values.
  @visibleForTesting
  static Map<String, Object> sanitizeParams(Map<String, Object> params) =>
      _safeParams(params);

  Future<void> _log(Future<void> Function() body) async {
    if (!_enabled) return;
    try {
      await body();
    } catch (e) {
      debugPrint('Analytics event failed: $e');
    }
  }

  static String _chipBucket(int chips) {
    if (chips <= -200) return 'loss_200_plus';
    if (chips <= -50) return 'loss_50_199';
    if (chips < 0) return 'loss_1_49';
    if (chips == 0) return 'even';
    if (chips < 50) return 'win_1_49';
    if (chips < 200) return 'win_50_199';
    return 'win_200_plus';
  }

  static String _durationBucket(int ms) {
    if (ms < 5_000) return 'under_5s';
    if (ms < 15_000) return '5_15s';
    if (ms < 60_000) return '15_60s';
    if (ms < 180_000) return '1_3m';
    return 'over_3m';
  }
}
