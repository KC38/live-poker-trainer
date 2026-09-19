/// SettingsNotifier remote hydrate and post-sign-out reset.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SettingsNotifier notifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'seatCount': 9,
      'smallBlind': 2.0,
      'bigBlind': 5.0,
      'stackDepthBb': 200,
      'sfxEnabled': false,
      'musicEnabled': true,
      'lineupMode': 'randomPool',
    });
    prefs = await SharedPreferences.getInstance();
    notifier = SettingsNotifier(prefs);
  });

  tearDown(() {
    notifier.dispose();
  });

  test('applyRemotePreferences restores table setup and keeps audio', () async {
    expect(notifier.state.seatCount, 9);
    expect(notifier.state.sfxEnabled, isFalse);

    await notifier.applyRemotePreferences(
      const GameSettingsModel(
        seatCount: 6,
        smallBlind: 0.5,
        bigBlind: 1,
        stackDepthBb: 100,
        autoRebuy: true,
        rebuyThresholdBb: 40,
        lineupMode: LineupMode.custom,
        customArchetypes: [
          PlayerArchetype.maniac,
          PlayerArchetype.nit,
          PlayerArchetype.tag,
          PlayerArchetype.lag,
          PlayerArchetype.callingStation,
        ],
        sfxEnabled: true,
        musicEnabled: false,
      ),
    );

    expect(notifier.state.seatCount, 6);
    expect(notifier.state.smallBlind, 0.5);
    expect(notifier.state.bigBlind, 1);
    expect(notifier.state.stackDepthBb, 100);
    expect(notifier.state.autoRebuy, isTrue);
    expect(notifier.state.rebuyThresholdBb, 40);
    expect(notifier.state.lineupMode, LineupMode.custom);
    expect(notifier.state.customArchetypes.length, 5);
    // Audio stays device-local.
    expect(notifier.state.sfxEnabled, isFalse);
    expect(notifier.state.musicEnabled, isTrue);
    expect(prefs.getInt('seatCount'), 6);
    expect(prefs.getDouble('smallBlind'), 0.5);
  });

  test('resetSyncedToDefaults clears table setup but keeps audio', () async {
    await notifier.resetSyncedToDefaults();

    const defaults = GameSettingsModel();
    expect(notifier.state.seatCount, defaults.seatCount);
    expect(notifier.state.smallBlind, defaults.smallBlind);
    expect(notifier.state.bigBlind, defaults.bigBlind);
    expect(notifier.state.stackDepthBb, defaults.stackDepthBb);
    expect(notifier.state.lineupMode, defaults.lineupMode);
    expect(notifier.state.sfxEnabled, isFalse);
    expect(notifier.state.musicEnabled, isTrue);
  });
}
