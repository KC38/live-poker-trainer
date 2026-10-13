/// Capstone 3-bet flop is labelled rainbow, matching its suits (LPT-405).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

Set<String> _suits(List<String> codes) => {for (final c in codes) c[1]};

void main() {
  test('step-3b-flop label says Q83r and the flop is rainbow (LPT-405)', () {
    final spot = resolveToyHandStepSpot(
      activityId: 'act-07-10-02-hand',
      stepId: 'step-3b-flop',
    )!;
    expect(spot.boardCodes, ['Qs', '8h', '3d']);
    expect(spot.streetLabel, 'Flop · Q83r · AQ');
    expect(_suits(spot.boardCodes), hasLength(3));
  });

  test('suit-permuted attempts keep a rainbow flop (LPT-405)', () {
    for (var generation = 0; generation < 32; generation++) {
      final spot = dealtToyHandStepSpot(
        activityId: 'act-07-10-02-hand',
        stepId: 'step-3b-flop',
        generation: generation,
      )!;
      expect(
        _suits(spot.boardCodes),
        hasLength(3),
        reason: 'gen $generation: ${spot.boardCodes}',
      );
    }
  });
}
