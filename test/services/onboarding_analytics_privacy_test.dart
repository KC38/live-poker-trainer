/// Analytics vocabulary stays free of cards, credentials, and answer keys.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';

void main() {
  test('onboarding analytics screens avoid sensitive tokens', () {
    const names = [
      AnalyticsScreens.welcome,
      AnalyticsScreens.onboarding,
      AnalyticsScreens.saveProgress,
      AnalyticsScreens.auth,
      AnalyticsScreens.home,
    ];
    for (final name in names) {
      expect(name.toLowerCase(), isNot(contains('nonce')));
      expect(name.toLowerCase(), isNot(contains('password')));
      expect(name.toLowerCase(), isNot(contains('credential')));
      expect(name.toLowerCase(), isNot(contains('answer')));
      expect(name.toLowerCase(), isNot(contains('card')));
    }
  });
}
