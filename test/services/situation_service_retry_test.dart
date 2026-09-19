/// Tests for situation-pool polling retry policy.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/services/firestore/situation_service.dart';

void main() {
  test('retries only the explicit pool-generating unavailable response', () {
    expect(
      shouldRetryPoolGeneration(
        code: 'unavailable',
        message: poolGeneratingUnavailableMessage,
      ),
      isTrue,
    );
    expect(
      shouldRetryPoolGeneration(
        code: 'unavailable',
        message: 'Network connection unavailable.',
      ),
      isFalse,
    );
    expect(
      shouldRetryPoolGeneration(
        code: 'deadline-exceeded',
        message: poolGeneratingUnavailableMessage,
      ),
      isFalse,
    );
  });

  test('uses one-two-four-five second capped exponential backoff', () {
    expect(List.generate(6, poolGenerationRetryDelay), const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 5),
      Duration(seconds: 5),
      Duration(seconds: 5),
    ]);
  });

  test('permits retries through a nine-minute bounded window', () {
    const maximumWait = Duration(minutes: 9);

    expect(
      canRetryPoolGeneration(
        elapsed: const Duration(minutes: 8, seconds: 55),
        nextDelay: const Duration(seconds: 5),
        maximumWait: maximumWait,
      ),
      isTrue,
    );
    expect(
      canRetryPoolGeneration(
        elapsed: const Duration(minutes: 8, seconds: 56),
        nextDelay: const Duration(seconds: 5),
        maximumWait: maximumWait,
      ),
      isFalse,
    );
  });
}
