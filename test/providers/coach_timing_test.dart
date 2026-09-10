/// Coach shelf stays on post-action grades; no pre-action tip overwrite.
library;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
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

  group('GameController post-action coach only', () {
    test('deal leaves the shelf empty until hero acts', () async {
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

      expect(controller.state.coach.hasAdvice, isFalse);
      expect(controller.state.coach.message, isEmpty);
      expect(controller.state.coach.hasVerdict, isFalse);
    });

    test('hero action publishes a live grade that survives the next wait',
        () async {
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

      final game = controller.state.game!;
      final callAmt = game.callAmountFor(game.hero);
      final action = callAmt <= 0
          ? const PokerAction(type: PokerActionType.check)
          : PokerAction(type: PokerActionType.call, amount: callAmt);

      await controller.heroAct(action);
      await _flush();

      final after = controller.state.coach;
      expect(after.hasAdvice, isTrue);
      // Either still the live grade for that act, or shelved as historical
      // after a street advance — never replaced by a pre-action tip.
      expect(after.message, isNotEmpty);
      if (after.hasVerdict) {
        expect(
          after.isLiveGrade || after.isHistorical,
          isTrue,
        );
      }
    });
  });
}
