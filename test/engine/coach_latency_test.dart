/// The coach runs inline on the UI thread, so grading has to stay cheap.
///
/// The equity engine is deliberately synchronous. Grading happens once per
/// hero action, after an awaited sound effect and before a deliberately paced
/// villain replay — it is one-shot work between animations, not per-frame
/// work, so the bar is the threshold where a person notices a delay rather
/// than a single frame. Moving it to an isolate would buy a few milliseconds
/// and cost the provider, the tests, and every caller an async hop.
///
/// The budget is asserted rather than assumed so that a change which makes
/// grading genuinely expensive shows up as a decision to make, not as a slow
/// app. If this starts failing, move the grade off the UI thread; do not
/// raise the number.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';

CardModel _c(String code) => CardModel.fromCode(code);

/// Ceiling for a single grade. Comfortably inside the ~100ms at which a
/// response stops feeling immediate, with room for slower devices than CI.
const int _gradeBudgetMs = 40;

GameState _spot({
  required Street street,
  required List<CardModel> board,
  required int villainCount,
}) {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 400,
        isHero: true,
        holeCards: [_c('9d'), _c('8d')],
      ),
      for (var i = 0; i < villainCount; i++)
        PlayerModel(
          id: i + 1,
          name: 'V$i',
          archetype: ArchetypeRoster.villainPool[i % 5],
          stack: 400,
          currentBet: i == 0 ? 24 : 0,
          hasActedThisRound: i == 0,
        ),
    ],
    mode: GameMode.training,
    street: street,
    community: board,
    mainPot: 40,
    dealerIndex: villainCount,
    sbIndex: 1,
    bbIndex: 0,
    highestBet: 24,
    bigBlind: 2,
    lastAggressor: 1,
    waitingForHero: true,
  );
}

int _timeGrade(GameState state) {
  const action = PokerAction(type: PokerActionType.call, amount: 24);
  // Warm the JIT so the measurement reflects steady-state cost.
  LiveCoach.grade(state: state, action: action);
  final sw = Stopwatch()..start();
  LiveCoach.grade(state: state, action: action);
  sw.stop();
  return sw.elapsedMilliseconds;
}

void main() {
  final cases = <String, GameState>{
    'preflop heads-up': _spot(
      street: Street.preflop,
      board: const [],
      villainCount: 1,
    ),
    'flop heads-up': _spot(
      street: Street.flop,
      board: [_c('Qd'), _c('3s'), _c('5c')],
      villainCount: 1,
    ),
    'turn heads-up (enumerated)': _spot(
      street: Street.turn,
      board: [_c('Qd'), _c('3s'), _c('5c'), _c('7h')],
      villainCount: 1,
    ),
    'river heads-up (enumerated)': _spot(
      street: Street.river,
      board: [_c('Qd'), _c('3s'), _c('5c'), _c('7h'), _c('Kd')],
      villainCount: 1,
    ),
    'flop five-handed': _spot(
      street: Street.flop,
      board: [_c('Qd'), _c('3s'), _c('5c')],
      villainCount: 5,
    ),
  };

  cases.forEach((name, state) {
    test('$name grades without a visible pause', () {
      final ms = _timeGrade(state);
      expect(
        ms,
        lessThanOrEqualTo(_gradeBudgetMs),
        reason: '$name took ${ms}ms; if grading is now genuinely this '
            'expensive, move it off the UI thread rather than raising the '
            'budget',
      );
    });
  });
}
