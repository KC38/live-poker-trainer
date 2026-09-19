/// SettingsNotifier remote hydrate, cloud-sync gate, and post-sign-out reset.
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
    expect(notifier.state.seatCount, const GameSettingsModel().seatCount);
    expect(notifier.state.sfxEnabled, isFalse);

    await notifier.applyRemotePreferences(
      const GameSettingsModel(
        seatCount: 6,
        smallBlind: 0.5,
        bigBlind: 1,
        maxStackDepthBb: 100,
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
    expect(notifier.state.maxStackDepthBb, 100);
    expect(notifier.state.lineupMode, LineupMode.custom);
    expect(notifier.state.customArchetypes.length, 5);
    // Audio stays device-local.
    expect(notifier.state.sfxEnabled, isFalse);
    expect(notifier.state.musicEnabled, isTrue);
    expect(prefs.getInt('seatCount'), isNull);
    expect(prefs.getDouble('smallBlind'), isNull);
    expect(prefs.getBool('sfxEnabled'), isFalse);
    expect(prefs.getBool('musicEnabled'), isTrue);
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

  test(
    'table-setup edits do not sync until cloud prefs have hydrated',
    () async {
      final synced = <GameSettingsModel>[];
      final gated = SettingsNotifier(
        prefs,
        syncRemote: (settings) async {
          synced.add(settings);
        },
      );
      addTearDown(gated.dispose);

      await gated.setSeatCount(6);
      expect(
        synced,
        isEmpty,
        reason: 'pre-hydrate edit must not clobber cloud',
      );

      await gated.applyRemotePreferences(
        const GameSettingsModel(seatCount: 9, stackDepthBb: 200),
      );
      gated.setCloudSyncEnabled(true);
      expect(gated.state.seatCount, 9);

      await gated.setSeatCount(8);
      expect(synced, hasLength(1));
      expect(synced.single.seatCount, 8);
      expect(synced.single.stackDepthBb, 200);
    },
  );

  test('resetSyncedToDefaults disables further cloud sync', () async {
    final synced = <GameSettingsModel>[];
    final gated = SettingsNotifier(
      prefs,
      syncRemote: (settings) async {
        synced.add(settings);
      },
    );
    addTearDown(gated.dispose);
    gated.setCloudSyncEnabled(true);

    await gated.setSeatCount(6);
    expect(synced, hasLength(1));

    await gated.resetSyncedToDefaults();
    await gated.setSeatCount(9);
    expect(synced, hasLength(1), reason: 'post-sign-out edits must stay local');
  });
}
