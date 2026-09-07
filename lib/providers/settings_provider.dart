/// Persisted gameplay and audio settings via SharedPreferences.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

/// Legacy SharedPreferences key for a removed Settings API-key override.
const _legacyGeminiKeyOverridePref = 'geminiKeyOverride';

/// Settings controller with disk persistence.
class SettingsNotifier extends StateNotifier<GameSettingsModel> {
  /// Creates a notifier from [prefs].
  SettingsNotifier(this._prefs, {SoundServiceSync? soundSync, this.onChanged})
      : _soundSync = soundSync,
        super(_load(_prefs)) {
    // Drop any previously saved device key override; keys come from
    // `.env` / `--dart-define` only now.
    if (_prefs.containsKey(_legacyGeminiKeyOverridePref)) {
      _prefs.remove(_legacyGeminiKeyOverridePref);
    }
    _applySideEffects();
  }

  final SharedPreferences _prefs;
  final SoundServiceSync? _soundSync;

  /// Invoked with the previous and next prefs maps after every [update]
  /// (used to persist a settings-change audit trail). Must not throw.
  final SettingsChanged? onChanged;

  static GameSettingsModel _load(SharedPreferences prefs) {
    return GameSettingsModel.fromPrefs({
      for (final key in prefs.getKeys()) key: prefs.get(key),
    });
  }

  Future<void> update(GameSettingsModel next) async {
    final before = state.toPrefsMap();
    state = next;
    final map = next.toPrefsMap();
    onChanged?.call(before, map);
    for (final entry in map.entries) {
      final v = entry.value;
      if (v is bool) {
        await _prefs.setBool(entry.key, v);
      } else if (v is int) {
        await _prefs.setInt(entry.key, v);
      } else if (v is double) {
        await _prefs.setDouble(entry.key, v);
      } else if (v is String) {
        await _prefs.setString(entry.key, v);
      }
    }
    _applySideEffects();
  }

  Future<void> setSfx(bool value) => update(state.copyWith(sfxEnabled: value));

  Future<void> setMusic(bool value) =>
      update(state.copyWith(musicEnabled: value));

  Future<void> setChipDisplayMode(ChipDisplayMode mode) =>
      update(state.copyWith(chipDisplayMode: mode));

  Future<void> setAutoRebuy(bool value) =>
      update(state.copyWith(autoRebuy: value));

  Future<void> setSeatCount(int value) =>
      update(state.copyWith(seatCount: value.clamp(2, 9)));

  Future<void> setStackDepthBb(int value) =>
      update(state.copyWith(stackDepthBb: value));

  Future<void> setRebuyThresholdBb(int value) =>
      update(state.copyWith(rebuyThresholdBb: value));

  Future<void> setBlinds(double sb, double bb) =>
      update(state.copyWith(smallBlind: sb, bigBlind: bb));

  Future<void> setLineupMode(LineupMode mode) async {
    var next = state.copyWith(lineupMode: mode);
    if (mode == LineupMode.custom) {
      next = next.withNormalizedCustomLineup();
    }
    await update(next);
  }

  /// Sets archetype for villain seat index `0..villainSeatCount-1` (table seats 1+).
  Future<void> setCustomArchetypeAt(int villainIndex, PlayerArchetype archetype) async {
    final normalized = state.withNormalizedCustomLineup();
    if (villainIndex < 0 || villainIndex >= normalized.customArchetypes.length) {
      return;
    }
    final next = List<PlayerArchetype>.from(normalized.customArchetypes);
    next[villainIndex] = archetype;
    await update(normalized.copyWith(customArchetypes: next));
  }

  void _applySideEffects() {
    _soundSync?.call(state.sfxEnabled, state.musicEnabled);
  }
}

/// Callback to push SFX/music flags into [SoundService].
typedef SoundServiceSync = void Function(bool sfx, bool music);

/// Callback receiving the settings maps before and after an update.
typedef SettingsChanged = void Function(
  Map<String, Object?> before,
  Map<String, Object?> after,
);

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, GameSettingsModel>((ref) {
  final asyncPrefs = ref.watch(sharedPreferencesProvider);
  void soundSync(bool sfx, bool music) {
    final sound = ref.read(soundServiceProvider);
    sound.sfxEnabled = sfx;
    sound.setMusicEnabled(music);
  }

  void audit(Map<String, Object?> before, Map<String, Object?> after) {
    unawaited(
      ref
          .read(diagnosticsDaoProvider)
          .logSettingsDiff(before, after)
          .catchError((Object _) => 0),
    );
  }

  return asyncPrefs.maybeWhen(
    data: (prefs) =>
        SettingsNotifier(prefs, soundSync: soundSync, onChanged: audit),
    orElse: () => SettingsNotifier(
      _MemoryPrefs(),
      soundSync: soundSync,
      onChanged: audit,
    ),
  );
});

/// Minimal in-memory prefs used until real SharedPreferences resolves.
class _MemoryPrefs implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  Object? get(String key) => _data[key];

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<void> reload() async {}

  @override
  Future<bool> commit() async => true;

  @override
  bool containsKey(String key) => _data.containsKey(key);
}
