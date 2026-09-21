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

  /// Analytics opt-in/out toggle changed.
  Future<void> logAnalyticsConsentChanged({required bool enabled}) async {
    // Always attempt once so opt-out itself is observable when still enabled.
    await _event('analytics_consent_changed', {'enabled': enabled ? 1 : 0});
  }

  Future<void> _event(String name, [Map<String, Object>? params]) async {
    await _log(() async {
      await (_analytics ?? FirebaseAnalytics.instance).logEvent(
        name: name,
        parameters: params,
      );
    });
  }

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
