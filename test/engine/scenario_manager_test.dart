/// Offline fallback path for [ScenarioManager] when auth / Firestore is absent.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/scenario_manager.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/services/firestore/played_scenarios_repo.dart';
import 'package:live_poker_trainer/services/firestore/scenario_pool_repo.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';

void main() {
  test('nextScenario returns EV-stamped offline template when uid is null',
      () async {
    final manager = ScenarioManager(
      pool: ScenarioPoolRepo(),
      played: PlayedScenariosRepo(),
      users: UserRepository(),
      uid: () => null,
    );

    final a = await manager.nextScenario();
    final b = await manager.nextScenario();

    expect(a.heroHand, isNotEmpty);
    expect(a.contentHash, isNotEmpty);
    // Rotation advances across calls.
    expect(a.contentHash, isNot(b.contentHash));
  });

  test('offline templates rotate across streets and playable spots', () async {
    final manager = ScenarioManager(
      pool: ScenarioPoolRepo(),
      played: PlayedScenariosRepo(),
      users: UserRepository(),
      uid: () => null,
    );

    final streets = <String>{};
    final boards = <int>{};
    for (var i = 0; i < 8; i++) {
      final s = await manager.nextScenario();
      streets.add(s.street);
      boards.add(s.boardCards.length);
    }

    expect(streets, contains('PREFLOP'));
    expect(boards.any((n) => n >= 3), isTrue,
        reason: 'offline pool should include postflop boards');
  });

  test('engagementScore prefers postflop / strong hands over junk folds', () {
    final junkFold = ScenarioModel.fromGeminiJson(const {
      'table_size': 6,
      'hero_position': 'UTG',
      'hero_hand': ['7c', '2d'],
      'board_cards': <String>[],
      'pot_size': 15,
      'villain_seat': 1,
      'villain_archetype': 'TAG',
      'previous_action_narrative': 'Facing a raise.',
      'villain_action': 'RAISE',
      'call_amount': 10,
      'min_raise': 20,
      'max_raise': 200,
    });
    final stationValue = ScenarioModel.fromGeminiJson(const {
      'table_size': 6,
      'hero_position': 'CO',
      'hero_hand': ['Ah', 'Ad'],
      'board_cards': ['As', '8c', '2d'],
      'pot_size': 24,
      'villain_seat': 3,
      'villain_archetype': 'Calling Station',
      'previous_action_narrative': 'Checked to hero.',
      'villain_action': 'CHECK',
      'call_amount': 0,
      'min_raise': 2,
      'max_raise': 200,
    });

    expect(
      ScenarioManager.engagementScore(stationValue),
      greaterThan(ScenarioManager.engagementScore(junkFold)),
    );
  });
}
