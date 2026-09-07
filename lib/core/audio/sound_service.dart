/// SFX and coach TTS playback via audioplayers + flutter_tts fallback.
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:live_poker_trainer/core/audio/wav_codec.dart';

/// Result of attempting coach voice playback.
class CoachVoicePlayback {
  /// Creates a playback result.
  const CoachVoicePlayback({
    required this.spoke,
    this.note,
  });

  final bool spoke;
  final String? note;
}

/// Bundled table sound effects and coach voice (Gemini audio or device TTS).
class SoundService {
  /// Creates a sound service.
  SoundService();

  final AudioPlayer _sfx = AudioPlayer();
  final AudioPlayer _voice = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool sfxEnabled = true;
  bool ttsEnabled = true;
  bool _unlocked = !kIsWeb;
  bool _ttsReady = false;
  bool _audioContextConfigured = false;

  /// Call after a user gesture to unlock audio (required on web; helpful on iOS).
  Future<void> unlock() async {
    _unlocked = true;
    await _ensureAudioContext();
    await _ensureTts();
  }

  Future<void> _ensureAudioContext() async {
    if (_audioContextConfigured) return;
    try {
      final ctx = AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.assistanceAccessibility,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      );
      await AudioPlayer.global.setAudioContext(ctx);
      await _sfx.setAudioContext(ctx);
      await _voice.setAudioContext(ctx);
      _audioContextConfigured = true;
    } catch (_) {
      // Platform may not support AudioContext configuration.
    }
  }

  Future<void> _ensureTts() async {
    if (_ttsReady) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _ttsReady = true;
    } catch (_) {
      // Device TTS unavailable — Gemini audio path may still work.
    }
  }

  /// Plays a short table SFX if enabled.
  Future<void> playSfx(SfxKind kind) async {
    if (!sfxEnabled || !_unlocked) return;
    try {
      await _ensureAudioContext();
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

  /// Plays Gemini coach audio, wrapping raw PCM/L16 as WAV when needed.
  Future<bool> playCoachAudio(
    Uint8List bytes, {
    String? mimeType,
  }) async {
    if (!ttsEnabled || !_unlocked || bytes.isEmpty) return false;
    await _ensureAudioContext();
    final playable = WavCodec.ensurePlayable(bytes, mimeType: mimeType);
    try {
      await _tts.stop();
      await _voice.stop();
      await _voice.setReleaseMode(ReleaseMode.stop);
      await _voice.play(
        BytesSource(playable.bytes, mimeType: playable.mimeType),
      );
      return true;
    } catch (_) {
      try {
        await _voice.play(BytesSource(playable.bytes));
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  /// Speaks [text] via device TTS (offline fallback).
  Future<bool> speakText(String text) async {
    if (!ttsEnabled || !_unlocked) return false;
    final cleaned = text.trim();
    if (cleaned.isEmpty) return false;
    await _ensureTts();
    try {
      await _voice.stop();
      await _tts.stop();
      final result = await _tts.speak(cleaned);
      return result == 1 || result == true;
    } catch (_) {
      return false;
    }
  }

  /// Plays Gemini audio when present; otherwise falls back to device TTS.
  Future<CoachVoicePlayback> playCoachVoice({
    required String text,
    Uint8List? audioBytes,
    String? audioMimeType,
    bool hasApiKey = true,
  }) async {
    if (!ttsEnabled) {
      return const CoachVoicePlayback(
        spoke: false,
        note: 'Coach voice is muted in Settings.',
      );
    }
    if (!_unlocked) {
      return const CoachVoicePlayback(
        spoke: false,
        note: 'Tap Play once to unlock coach voice.',
      );
    }

    if (audioBytes != null && audioBytes.isNotEmpty) {
      final ok = await playCoachAudio(audioBytes, mimeType: audioMimeType);
      if (ok) return const CoachVoicePlayback(spoke: true);
    }

    final spoke = await speakText(text);
    if (spoke) {
      return CoachVoicePlayback(
        spoke: true,
        note: hasApiKey
            ? null
            : 'Using device voice — add a Gemini API key for coach AUDIO.',
      );
    }

    if (!hasApiKey) {
      return const CoachVoicePlayback(
        spoke: false,
        note: 'Enable Coach voice + add a Gemini API key for spoken feedback.',
      );
    }
    return const CoachVoicePlayback(
      spoke: false,
      note: 'Coach voice failed to play on this device.',
    );
  }

  Future<void> stopVoice() async {
    await _voice.stop();
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Releases players.
  Future<void> dispose() async {
    await _sfx.dispose();
    await _voice.dispose();
    try {
      await _tts.stop();
    } catch (_) {}
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
