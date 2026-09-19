/// Server-synced gameplay settings plus device-local audio preferences.
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
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

/// Settings controller with device persistence for audio only.
class SettingsNotifier extends StateNotifier<GameSettingsModel> {
  /// Creates a notifier from [prefs].
  SettingsNotifier(this._prefs, {this.soundSync, this.syncRemote})
    : super(_load(_prefs)) {
    // Drop obsolete client-key and gameplay preference rows from older builds.
    if (_prefs.containsKey(_legacyGeminiKeyOverridePref)) {
      _prefs.remove(_legacyGeminiKeyOverridePref);
    }
    for (final key in const GameSettingsModel().toPrefsMap().keys) {
      if (!GameSettingsModel.audioPrefKeys.contains(key) &&
          _prefs.containsKey(key)) {
        _prefs.remove(key);
      }
    }
    _applySideEffects();
  }

  final SharedPreferences _prefs;
  final SoundServiceSync? soundSync;

  /// Pushes non-audio preferences to Firestore when signed in.
  final Future<void> Function(GameSettingsModel settings)? syncRemote;

  /// When false, [update] must not push gameplay prefs (hydrate still pending).
  bool _cloudSyncEnabled = false;

  static GameSettingsModel _load(SharedPreferences prefs) {
    return GameSettingsModel.fromPrefs({
      for (final key in GameSettingsModel.audioPrefKeys) key: prefs.get(key),
    });
  }

  Future<void> update(GameSettingsModel next) async {
    final before = state.toPrefsMap();
    state = next;
    final map = next.toPrefsMap();
    for (final key in GameSettingsModel.audioPrefKeys) {
      final entry = MapEntry(key, map[key]);
      final v = entry.value;
      if (v is bool) {
        await _prefs.setBool(entry.key, v);
      }
    }
    _applySideEffects();
    if (_cloudSyncEnabled && _nonAudioChanged(before, map)) {
      final sync = syncRemote;
      if (sync != null) {
        unawaited(sync(next).catchError((Object _) {}));
      }
    }
  }

  /// Allows [syncRemote] after cloud prefs for the current user are applied.
  ///
  /// Cold start / sign-in must keep this false until [applyRemotePreferences]
  /// so a table-setup edit cannot replace Firestore with in-memory defaults.
  void setCloudSyncEnabled(bool enabled) {
    _cloudSyncEnabled = enabled;
  }

  /// Applies gameplay prefs from Firestore; audio stays local.
  Future<void> applyRemotePreferences(GameSettingsModel remote) async {
    final merged = state.mergeRemotePreferences(remote);
    if (merged.toPrefsMap().toString() == state.toPrefsMap().toString()) {
      return;
    }
    // Gameplay settings stay in memory; only audio is device-persisted.
    state = merged;
    _applySideEffects();
  }

  /// Resets table-setup / gameplay prefs to defaults after sign-out.
  ///
  /// Keeps device-local audio. Does not push to Firestore (caller must sign
  /// out first so [syncRemote] sees no uid).
  Future<void> resetSyncedToDefaults() async {
    setCloudSyncEnabled(false);
    final defaults = GameSettingsModel(
      sfxEnabled: state.sfxEnabled,
      musicEnabled: state.musicEnabled,
    );
    await update(defaults);
  }

  static bool _nonAudioChanged(
    Map<String, Object?> before,
    Map<String, Object?> after,
  ) {
    for (final entry in after.entries) {
      if (GameSettingsModel.audioPrefKeys.contains(entry.key)) continue;
      if (before[entry.key] != entry.value) return true;
    }
    return false;
  }

  Future<void> setSfx(bool value) => update(state.copyWith(sfxEnabled: value));

  Future<void> setMusic(bool value) =>
      update(state.copyWith(musicEnabled: value));

  Future<void> setChipDisplayMode(ChipDisplayMode mode) =>
      update(state.copyWith(chipDisplayMode: mode));

  Future<void> setSeatCount(int value) =>
      update(state.copyWith(seatCount: value.clamp(2, 9)));

  Future<void> setMaxStackDepthBb(int value) =>
      update(state.copyWith(maxStackDepthBb: value));

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
  Future<void> setCustomArchetypeAt(
    int villainIndex,
    PlayerArchetype archetype,
  ) async {
    final normalized = state.withNormalizedCustomLineup();
    if (villainIndex < 0 ||
        villainIndex >= normalized.customArchetypes.length) {
      return;
    }
    final next = List<PlayerArchetype>.from(normalized.customArchetypes);
    next[villainIndex] = archetype;
    await update(normalized.copyWith(customArchetypes: next));
  }

  void _applySideEffects() {
    soundSync?.call(state.sfxEnabled, state.musicEnabled);
  }
}

/// Callback to push SFX/music flags into [SoundService].
typedef SoundServiceSync = void Function(bool sfx, bool music);

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, GameSettingsModel>((ref) {
      final asyncPrefs = ref.watch(sharedPreferencesProvider);
      void soundSync(bool sfx, bool music) {
        final sound = ref.read(soundServiceProvider);
        sound.sfxEnabled = sfx;
        sound.setMusicEnabled(music);
      }

      Future<void> syncRemote(GameSettingsModel settings) async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;
        await ref
            .read(userRepositoryProvider)
            .syncPreferences(uid: uid, settings: settings);
      }

      return asyncPrefs.maybeWhen(
        data:
            (prefs) => SettingsNotifier(
              prefs,
              soundSync: soundSync,
              syncRemote: syncRemote,
            ),
        orElse:
            () => SettingsNotifier(
              _MemoryPrefs(),
              soundSync: soundSync,
              syncRemote: syncRemote,
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
