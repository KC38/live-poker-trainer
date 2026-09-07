/// Prefs round-trip for the Settings music toggle.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';

void main() {
  test('musicEnabled defaults on and survives prefs round-trip', () {
    const base = GameSettingsModel();
    expect(base.musicEnabled, isTrue);

    final off = base.copyWith(musicEnabled: false);
    final restored = GameSettingsModel.fromPrefs(off.toPrefsMap());
    expect(restored.musicEnabled, isFalse);

    final missingKey = Map<String, Object?>.from(base.toPrefsMap())
      ..remove('musicEnabled');
    expect(GameSettingsModel.fromPrefs(missingKey).musicEnabled, isTrue);
  });
}
