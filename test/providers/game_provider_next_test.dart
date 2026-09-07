/// Early Next after fold: skip remaining replay and deal the next hand.
library;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
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

GameState _headsUp({
  required bool heroFolded,
  required bool handOver,
}) {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 200,
        isHero: true,
        folded: heroFolded,
        holeCards: [CardModel.fromCode('As'), CardModel.fromCode('Kh')],
      ),
      PlayerModel(
        id: 1,
        name: 'Villain',
        archetype: PlayerArchetype.tag,
        stack: 200,
        holeCards: [CardModel.fromCode('2c'), CardModel.fromCode('7d')],
      ),
    ],
    mode: GameMode.training,
    street: handOver ? Street.showdown : Street.flop,
    waitingForHero: !heroFolded && !handOver,
    isHandOver: handOver,
    resultMessage: handOver ? 'Villain wins' : null,
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

Future<void> _flushMicrotasks() async {
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

  test('after fold Next is available without highlight; hand over highlights',
      () {
    final folded = TableSession(
      replaying: true,
      game: _headsUp(heroFolded: true, handOver: false),
    );
    expect(folded.heroDoneForHand, isTrue);
    expect(folded.highlightNext, isFalse);
    expect(folded.heroCanAct, isFalse);

    final over = TableSession(
      game: _headsUp(heroFolded: false, handOver: true),
    );
    expect(over.heroDoneForHand, isTrue);
    expect(over.highlightNext, isTrue);
  });

  test('early nextHand after fold deals a new hand without waiting for showdown',
      () async {
    final container = _container();
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);

    await controller.startTraining();
    await _flushMicrotasks();

    var guard = 0;
    while (!controller.state.heroCanAct &&
        !(controller.state.game?.isHandOver ?? true) &&
        guard < 40) {
      await _flushMicrotasks();
      guard++;
    }

    // Rare: blinds already folded everyone out — deal again until hero acts.
    guard = 0;
    while (!controller.state.heroCanAct && guard < 8) {
      await controller.startTraining(continueTable: true);
      await _flushMicrotasks();
      var inner = 0;
      while (!controller.state.heroCanAct &&
          !(controller.state.game?.isHandOver ?? true) &&
          inner < 40) {
        await _flushMicrotasks();
        inner++;
      }
      guard++;
    }

    expect(
      controller.state.heroCanAct,
      isTrue,
      reason: 'need a live hero decision to fold',
    );

    final handBefore = controller.state.game!.handCount;
    final foldFuture = controller.heroAct(
      const PokerAction(type: PokerActionType.fold),
    );

    var foldGuard = 0;
    while (!(controller.state.game?.hero.folded ?? false) && foldGuard < 80) {
      await _flushMicrotasks();
      foldGuard++;
    }

    expect(controller.state.game!.hero.folded, isTrue);
    expect(controller.state.heroDoneForHand, isTrue);
    expect(
      controller.state.highlightNext,
      controller.state.game!.isHandOver,
      reason: 'quiet until natural completion unless fold ended the hand',
    );

    // Skip the rest of the paced showdown / street replay immediately.
    final nextFuture = controller.nextHand();
    await foldFuture;
    await nextFuture;
    await _flushMicrotasks();

    // Wait for the deal replay to publish the new hand.
    var dealGuard = 0;
    while ((controller.state.game?.handCount ?? handBefore) <= handBefore &&
        dealGuard < 80) {
      await _flushMicrotasks();
      dealGuard++;
    }

    final after = controller.state.game;
    expect(after, isNotNull);
    expect(
      after!.handCount,
      greaterThan(handBefore),
      reason: 'early Next must deal the next training hand',
    );
    expect(after.hero.folded, isFalse);
    expect(controller.state.replaying, isFalse);
  });

  test('nextHand refuses to skip while hero still has decisions', () async {
    final container = _container();
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);

    await controller.startTraining();
    await _flushMicrotasks();

    var guard = 0;
    while (!controller.state.heroCanAct &&
        !(controller.state.game?.isHandOver ?? true) &&
        guard < 40) {
      await _flushMicrotasks();
      guard++;
    }
    if (!controller.state.heroCanAct) return;

    final handBefore = controller.state.game!.handCount;
    await controller.nextHand();
    await _flushMicrotasks();

    expect(controller.state.game!.handCount, handBefore);
    expect(controller.state.heroCanAct, isTrue);
  });
}
