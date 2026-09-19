/// Unit tests for [AnalyticsService] event vocabulary and opt-out.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';

void main() {
  test('disabled service skips events without throwing', () async {
    final analytics = AnalyticsService(enabled: false);
    await analytics.logScreenView(AnalyticsScreens.progress);
    await analytics.logProgressDwell(durationMs: 12_000);
    await analytics.logHeroDecision(
      street: 'flop',
      actionType: 'call',
      verdict: 'correct',
    );
    expect(analytics.isEnabled, isFalse);
  });

  test('setCollectionEnabled updates local flag', () async {
    final analytics = AnalyticsService(enabled: true);
    await analytics.setCollectionEnabled(false);
    expect(analytics.isEnabled, isFalse);
  });
}
