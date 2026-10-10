/// Fail-closed parsing for Live Training access and course table setup.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/live_access.dart';

void main() {
  group('LiveAccessSnapshot.fromJson', () {
    test('null and unknown tiers stay locked', () {
      final missing = LiveAccessSnapshot.fromJson(null);
      expect(missing.tier, LiveAccessTier.locked);
      expect(missing.unrestrictedAccess, isFalse);
      expect(missing.warmUpAvailable, isFalse);
      expect(missing.source, 'none');

      final unknown = LiveAccessSnapshot.fromJson({
        'tier': 'admin',
        'source': 'spoof',
        'unrestrictedAccess': 'true',
        'warmUpAvailable': 'true',
      });
      expect(unknown.tier, LiveAccessTier.locked);
      expect(unknown.source, 'spoof');
      expect(unknown.unrestrictedAccess, isFalse);
      expect(unknown.warmUpAvailable, isFalse);
    });

    test('a tier string cannot grant the launch gate by itself', () {
      final spoofed = LiveAccessSnapshot.fromJson({
        'tier': 'unrestricted',
        'source': 'client',
      });
      expect(spoofed.tier, LiveAccessTier.unrestricted);
      expect(spoofed.unrestrictedAccess, isFalse);
      expect(spoofed.warmUpAvailable, isTrue);

      final granted = LiveAccessSnapshot.fromJson({
        'tier': 'warm_up',
        'unrestrictedAccess': true,
        'warmUpAvailable': false,
        'nextLessonId': 'lesson-04',
        'rolloutCutoffMs': 1700000000000,
      });
      expect(granted.tier, LiveAccessTier.warmUp);
      expect(granted.unrestrictedAccess, isTrue);
      expect(granted.warmUpAvailable, isTrue);
      expect(granted.nextLessonId, 'lesson-04');
      expect(granted.rolloutCutoffMs, 1700000000000);
    });
  });

  group('CourseLiveContext', () {
    test('omits blank ids and defaults a missing payload to warm-up', () {
      final missing = CourseLiveContext.fromJson(null);
      expect(missing.kind, 'warm_up');
      expect(missing.maxDecisions, 1);
      expect(missing.toStartTableSetup(courseKind: 'warm_up'), {
        'mode': 'course',
        'courseKind': 'warm_up',
      });

      final parsed = CourseLiveContext.fromJson({
        'courseHandId': 'course-lab',
        'handLabSpecId': 'lab-1',
        'attemptId': 'attempt',
        'activityId': 'act',
        'lessonId': 'lesson',
        'returnNodeId': 'node',
        'kind': 'hand_lab',
        'maxDecisions': 2,
      });
      expect(parsed.toStartTableSetup(courseKind: 'hand_lab'), {
        'mode': 'course',
        'courseKind': 'hand_lab',
        'courseHandId': 'course-lab',
        'handLabSpecId': 'lab-1',
        'attemptId': 'attempt',
        'activityId': 'act',
        'lessonId': 'lesson',
        'returnNodeId': 'node',
      });
      expect(parsed.maxDecisions, 2);
    });
  });

  test('locked copy names Baseline jump check on Home', () {
    expect(
      liveTrainingLockedMessage(),
      'Live Training is advanced. Finish Baseline jump check on Home '
      'to unlock a coached warm-up.',
    );
    expect(liveTrainingLockedMessage(), contains(kLiveWarmUpUnlockLessonTitle));
    expect(liveTrainingLockedMessage(), isNot(contains('Section 2')));
    expect(
      liveTrainingLockedSnack(),
      'Live Training unlocks after Baseline jump check. '
      'Continue on Home.',
    );
    expect(liveTrainingLockedSnack(), isNot(contains('Section 2')));
  });
}
