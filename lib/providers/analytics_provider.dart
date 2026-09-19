/// Analytics service, consent preference, and navigator observer providers.
// ignore_for_file: prefer_initializing_formals
library;

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_navigator_observer.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key for Analytics / Crashlytics collection opt-out.
const analyticsCollectionEnabledPrefKey = 'analytics_collection_enabled';

/// Production [AnalyticsService] (Firebase-backed).
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Navigator observer that logs named routes.
final analyticsNavigatorObserverProvider = Provider<AnalyticsNavigatorObserver>(
  (ref) {
    return AnalyticsNavigatorObserver(ref.watch(analyticsServiceProvider));
  },
);

/// Device-local Analytics + Crashlytics collection preference (default on).
class AnalyticsConsentNotifier extends StateNotifier<bool> {
  /// Creates a notifier. When [prefs] is null, changes stay in memory only.
  AnalyticsConsentNotifier({
    required AnalyticsService analytics,
    SharedPreferences? prefs,
    bool initial = true,
  }) : _analytics = analytics,
       _prefs = prefs,
       super(prefs?.getBool(analyticsCollectionEnabledPrefKey) ?? initial);

  final AnalyticsService _analytics;
  final SharedPreferences? _prefs;

  /// Updates the preference and applies it to Analytics / Crashlytics SDKs.
  Future<void> setEnabled(bool enabled) async {
    if (state == enabled) return;
    // Log while still enabled so an opt-out is captured once.
    if (!enabled && state) {
      unawaited(_analytics.logAnalyticsConsentChanged(enabled: false));
    }
    state = enabled;
    await _prefs?.setBool(analyticsCollectionEnabledPrefKey, enabled);
    await applyCollectionEnabled(enabled, analytics: _analytics);
    if (enabled) {
      unawaited(_analytics.logAnalyticsConsentChanged(enabled: true));
    }
  }
}

/// Applies collection flags to Analytics and Crashlytics.
Future<void> applyCollectionEnabled(
  bool enabled, {
  AnalyticsService? analytics,
}) async {
  final service = analytics ?? AnalyticsService();
  await service.setCollectionEnabled(enabled);
  if (kIsWeb) return;
  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
  } catch (e) {
    debugPrint('Crashlytics setCrashlyticsCollectionEnabled failed: $e');
  }
}

/// Whether Analytics / Crashlytics collection is enabled (default true).
final analyticsConsentProvider =
    StateNotifierProvider<AnalyticsConsentNotifier, bool>((ref) {
      final analytics = ref.watch(analyticsServiceProvider);
      final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
      return AnalyticsConsentNotifier(analytics: analytics, prefs: prefs);
    });
