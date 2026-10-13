// LPT-628 remaining densify-tap arms (17) reach selectIdentifyDensifiedCoachLine.
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _lines = <String, String>{
  'act-01-01-03-checkpoint-layout':
      'The button has the D chip. Tap the small blind, one seat to its left.',
  'act-01-02-02-scaffolded-kicker': 'Same pair on the board. Tap your cards if your kicker wins, their cards if theirs wins, or Chop if you tie.',
  'act-01-02-02-unguided-board': 'Both checked down. Tap the board if both play it, or a player\'s cards if you think their holes win.',
  'act-01-05-01-unguided-pot': 'BTN opens — tap the pot before blinds act.',
  'act-04-07-02-guided':
      'Seat plays ~8% of hands and 3-bets rarely but large. Label — tap Nit.',
  'act-04-07-02-unguided':
      'Seat folds forever, then check-raises a triple barrel. Label — tap Nit.',
  'act-04-08-02-guided':
      'Seat open-raises 60% and triple-barrels light. Label — tap Maniac.',
  'act-04-08-02-unguided':
      'Seat 3-bets light and never gives up rivers. Label — tap Maniac.',
  'act-04-09-01-unguided': 'Former \'station\' starts folding three streets. Next step — tap Update/retire the Calling Station model.',
  'act-04-10-02-jump-station': 'Sticky caller three streets. Label + exploit direction — tap Calling Station — thicker value, fewer bluffs.',
  'act-04-10-02-jump-nit': 'Tiny range, huge check-raise. Label + line — tap Nit — respect the raise; steal more elsewhere.',
  'act-04-10-02-jump-maniac': 'Seat barrels forever. You have top pair. Label + line — tap Maniac — widen bluff-catch; avoid ego raises.',
  'act-07-12-01-cs': 'Sticky calls three streets. Label + exploit — tap Calling Station — thicker value, fewer bluffs.',
  'act-07-12-01-nit': 'Tiny range, huge check-raise. Label + line — tap Nit — respect heat; steal elsewhere.',
  'act-07-12-01-maniac': 'Endless barrels, never folds. Label + line — tap Maniac — widen catches; avoid ego raises.',
  'act-07-12-01-tag': 'Selective entry, disciplined barrels. Label + vs raise — tap TAG — respect raises; steal less than vs nits.',
  'act-07-12-01-lag': 'Wide entry, sustained pressure, some folds. Label + line — tap LAG — trap more; call wider; fancy less.',
};

void main() {
  for (final MapEntry(key: id, value: line) in _lines.entries) {
    test('$id densify helper arm (LPT-628 remain)', () {
      expect(selectIdentifyDensifiedCoachLine(id), line);
      expect(line.toLowerCase(), isNot(contains('tap the best answer')));
    });
  }
}
