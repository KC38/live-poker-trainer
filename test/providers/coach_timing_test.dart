/// Coach tip ↔ grade handoff: one primary shelf message at a time.
library;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/anthropic_service.dart';

class _SilentAnthropic extends AnthropicService {
  @override
  Future<CoachTextResult> coach({
    required String prompt,
    int? handId,
  }) async {
    return const CoachTextResult(text: '');
  }
}

CardModel _c(String code) => CardModel.fromCode(code);

GameState _preflopSpot({
  required double heroBet,
  required double villainBet,
  required bool waitingForHero,
  Street street = Street.preflop,
}) {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 400 - heroBet,
        isHero: true,
        currentBet: heroBet,
        holeCards: [_c('As'), _c('Kh')],
      ),
      PlayerModel(
        id: 1,
        name: 'Sammy',
        archetype: PlayerArchetype.lag,
        stack: 400 - villainBet,
        currentBet: villainBet,
        holeCards: [_c('2c'), _c('7d')],
      ),
    ],
    mode: GameMode.training,
    street: street,
    highestBet: villainBet > heroBet ? villainBet : heroBet,
    minRaise: 2,
    smallBlind: 1,
    bigBlind: 2,
    mainPot: heroBet + villainBet,
    lastAggressor: villainBet > heroBet ? 1 : (heroBet > 2 ? 0 : null),
    waitingForHero: waitingForHero,
  );
}

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWith((ref) {
        final db = AppDatabase(NativeDatabase.memory());
        ref.onDispose(db.close);
        return db;
      }),
      soundServiceProvider.overrideWithValue(SoundService.silent()),
      anthropicServiceProvider.overrideWithValue(_SilentAnthropic()),
    ],
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ReplayPace.testScale = 0;
  });

  tearDown(() {
    ReplayPace.testScale = 1;
  });

  group('LiveCoach.preActionFeedback', () {
    test('tip replaces empty coach without inventing a verdict', () {
      final spot = _preflopSpot(
        heroBet: 0,
        villainBet: 2,
        waitingForHero: true,
      );
      final tip = LiveCoach.preActionFeedback(
        state: spot,
        prior: const CoachFeedback(),
      );
      expect(tip.hasVerdict, isFalse);
      expect(tip.isLiveGrade, isFalse);
      expect(tip.isPreActionTip, isTrue);
      expect(tip.message.toLowerCase(), contains('call'));
      expect(tip.message.toLowerCase(), isNot(contains('correct')));
    });

    test('second decision same street shelves prior grade under one tip', () {
      const priorGrade = CoachFeedback(
        verdict: CoachVerdict.correct,
        message: 'Raise is right preflop vs Sammy.',
        optimalAction: ExploitAction.raise,
        optimalSizingBb: 6,
        heroAction: 'RAISE',
        heroSizingBb: 6,
        evDeltaBb: 0.4,
        decisionStreet: Street.preflop,
      );
      final facingThreeBet = _preflopSpot(
        heroBet: 6,
        villainBet: 18,
        waitingForHero: true,
      );
      final next = LiveCoach.preActionFeedback(
        state: facingThreeBet,
        prior: priorGrade,
      );

      expect(next.isHistorical, isTrue);
      expect(next.isLiveGrade, isFalse);
      expect(next.hasVerdict, isTrue);
      expect(next.decisionStreet, Street.preflop);
      expect(next.message, isNot(contains('Raise is right')));
      expect(next.message.toLowerCase(), anyOf(contains('facing'), contains('call')));
      // One primary body — tip only; grade prose is cleared.
      expect(next.message.contains('\n'), isFalse);
    });

    test('street advance keeps Previous scope when tip is published', () {
      final prior = const CoachFeedback(
        verdict: CoachVerdict.incorrect,
        message: 'Too loose preflop.',
        decisionStreet: Street.preflop,
        optimalAction: ExploitAction.fold,
        heroAction: 'CALL',
        evDeltaBb: -0.5,
      ).asHistorical();
      final flopSpot = GameState(
        players: [
          PlayerModel(
            id: 0,
            name: 'Hero',
            archetype: PlayerArchetype.hero,
            stack: 380,
            isHero: true,
            holeCards: [_c('As'), _c('Kh')],
          ),
          PlayerModel(
            id: 1,
            name: 'Sammy',
            archetype: PlayerArchetype.lag,
            stack: 370,
            currentBet: 10,
            holeCards: [_c('2c'), _c('7d')],
          ),
        ],
        mode: GameMode.training,
        community: [_c('Ah'), _c('7d'), _c('2c')],
        mainPot: 20,
        street: Street.flop,
        highestBet: 10,
        minRaise: 2,
        smallBlind: 1,
        bigBlind: 2,
        lastAggressor: 1,
        waitingForHero: true,
      );
      final tip = LiveCoach.preActionFeedback(
        state: flopSpot,
        prior: prior,
      );
      expect(tip.isHistorical, isTrue);
      expect(tip.decisionStreet, Street.preflop);
      expect(tip.message.toLowerCase(), isNot(contains('too loose')));
    });
  });

  group('GameController tip → grade', () {
    test('pre-action tip becomes a live grade after hero acts', () async {
      final container = _container();
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);

      await controller.startTraining();
      await _flush();

      var guard = 0;
      while (!controller.state.heroCanAct &&
          !(controller.state.game?.isHandOver ?? true) &&
          guard < 60) {
        await _flush();
        guard++;
      }
      if (!controller.state.heroCanAct) return;

      final before = controller.state.coach;
      expect(before.isLiveGrade, isFalse);
      expect(before.message, isNotEmpty);

      final game = controller.state.game!;
      final callAmt = game.callAmountFor(game.hero);
      final action = callAmt <= 0
          ? const PokerAction(type: PokerActionType.check)
          : PokerAction(type: PokerActionType.call, amount: callAmt);

      await controller.heroAct(action);
      await _flush();

      final after = controller.state.coach;
      // Immediately after acting (or after replay returns), either a live grade
      // for that act or a shelved grade + tip for the next decision — never two
      // live tips stacked in one message.
      if (after.isLiveGrade) {
        expect(after.hasVerdict, isTrue);
        expect(after.message, isNot(equals(before.message)));
      } else {
        expect(after.isHistorical || !after.hasVerdict, isTrue);
        expect(after.message.contains(before.message) && before.message.isNotEmpty,
            isFalse);
      }
    });
  });
}
