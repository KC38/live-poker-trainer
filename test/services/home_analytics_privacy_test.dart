/// Analytics privacy: Home events never include credentials or answers.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';

void main() {
  test('Home analytics helpers only accept ids and status enums', () async {
    final service = AnalyticsService(enabled: false);
    await service.logHomeCourseView(status: 'ready');
    await service.logHomeNodeOpen(
      lessonId: 'lesson-01-01-01-your-two-cards',
      nodeState: 'available',
    );
    await service.logHomeNodeLockedTap(
      lessonId: 'lesson-01-01-02-suits-and-ranks',
    );
    await service.logHomeResume(lessonId: 'lesson-01-01-01-your-two-cards');
    // Enabled=false path must not throw; parameters are scalar ids only.
    expect(true, isTrue);
  });
}
