/// LPT-1029: local Oops heart spend mirrors server evaluateLifeAndAcceptance.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';

void main() {
  test('localMissSpendsHeart is free only on guided SoftPulse teaching', () {
    expect(localMissSpendsHeart(ActivityStage.guided), isFalse);
    // Scaffolded covers checkpoint / jump_test / transfer paid misses.
    expect(localMissSpendsHeart(ActivityStage.scaffolded), isTrue);
  });
}
