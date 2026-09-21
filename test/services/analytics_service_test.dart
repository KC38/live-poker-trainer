/// Unit tests for [AnalyticsService] event vocabulary and opt-out.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';

void main() {
  test('disabled service skips events without throwing', () async {
    final analytics = AnalyticsService(enabled: false);
    await analytics.logScreenView(AnalyticsScreens.progress);
    await analytics.logTabSelected(tab: AnalyticsScreens.liveTraining);
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

  test('course analytics parameters drop private keys and keep lesson ids', () {
    final safe = AnalyticsService.sanitizeParams({
      'lesson_id': 'lesson-01-01-01-your-two-cards',
      'grade': 'clear_mistake',
      'hole_cards': 'AsKh',
      'prompt': 'What do you do?',
      'answer_map': 'secret',
    });
    expect(safe['lesson_id'], 'lesson-01-01-01-your-two-cards');
    expect(safe.containsKey('hole_cards'), isFalse);
    expect(safe.containsKey('prompt'), isFalse);
    expect(safe.containsKey('answer_map'), isFalse);
  });
}
