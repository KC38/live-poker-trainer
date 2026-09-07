/// SFX and coach TTS playback via audioplayers.
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Bundled table sound effects and optional Gemini audio playback.
class SoundService {
  /// Creates a sound service.
  SoundService();

  final AudioPlayer _sfx = AudioPlayer();
  final AudioPlayer _voice = AudioPlayer();

  bool sfxEnabled = true;
  bool ttsEnabled = true;
  bool _unlocked = !kIsWeb;

  /// Call after a user gesture on web to unlock audio.
  Future<void> unlock() async {
    _unlocked = true;
  }

  /// Plays a short table SFX if enabled.
  Future<void> playSfx(SfxKind kind) async {
    if (!sfxEnabled || !_unlocked) return;
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('sounds/${kind.fileName}'));
    } catch (_) {
      // Ignore missing assets / autoplay blocks.
    }
  }

  Future<void> card() => playSfx(SfxKind.card);
  Future<void> chip() => playSfx(SfxKind.chip);
  Future<void> knock() => playSfx(SfxKind.knock);
  Future<void> fold() => playSfx(SfxKind.fold);

  /// Plays Gemini inline audio bytes when TTS is enabled.
  Future<void> playCoachAudio(Uint8List bytes) async {
    if (!ttsEnabled || !_unlocked || bytes.isEmpty) return;
    try {
      await _voice.stop();
      // Gemini AUDIO is typically raw PCM or WAV in inline data.
      await _voice.play(BytesSource(bytes));
    } catch (_) {
      // Fallback: ignore decode failures.
    }
  }

  Future<void> stopVoice() => _voice.stop();

  /// Releases players.
  Future<void> dispose() async {
    await _sfx.dispose();
    await _voice.dispose();
  }
}

/// Bundled SFX asset kinds.
enum SfxKind {
  card('card.wav'),
  chip('chip.wav'),
  knock('knock.wav'),
  fold('fold.wav');

  const SfxKind(this.fileName);
  final String fileName;
}
