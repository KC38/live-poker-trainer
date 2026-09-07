/// WAV header helpers for Gemini PCM / L16 coach audio.
library;

import 'dart:typed_data';

/// Parsed Gemini (or other) audio payload ready for [audioplayers].
class PlayableAudio {
  /// Creates playable audio bytes with an optional MIME hint.
  const PlayableAudio({
    required this.bytes,
    this.mimeType = 'audio/wav',
  });

  final Uint8List bytes;
  final String mimeType;
}

/// Converts raw PCM / L16 Gemini audio into a standard WAV container.
class WavCodec {
  WavCodec._();

  /// Default Gemini TTS / Live output: 16-bit LE PCM mono @ 24 kHz.
  static const int defaultPcmSampleRate = 24000;
  static const int defaultBitsPerSample = 16;
  static const int defaultChannels = 1;

  /// Returns true when [bytes] already look like a RIFF/WAVE file.
  static bool isWav(Uint8List bytes) {
    if (bytes.length < 12) return false;
    return bytes[0] == 0x52 && // R
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x46 && // F
        bytes[8] == 0x57 && // W
        bytes[9] == 0x41 && // A
        bytes[10] == 0x56 && // V
        bytes[11] == 0x45; // E
  }

  /// Returns true when [bytes] look like an MP3 frame / ID3 tag.
  static bool isMp3(Uint8List bytes) {
    if (bytes.length < 3) return false;
    if (bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) {
      return true; // ID3
    }
    return bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
  }

  /// Parses sample rate from mime strings like `audio/pcm;rate=24000`
  /// or `audio/L16;codec=pcm;rate=24000`.
  static int sampleRateFromMime(String? mimeType, {int fallback = defaultPcmSampleRate}) {
    if (mimeType == null || mimeType.isEmpty) return fallback;
    final match = RegExp(r'rate\s*=\s*(\d+)', caseSensitive: false)
        .firstMatch(mimeType);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? fallback;
    }
    return fallback;
  }

  /// Whether [mimeType] indicates raw PCM / L16 that needs a WAV wrapper.
  static bool isRawPcmMime(String? mimeType) {
    if (mimeType == null || mimeType.isEmpty) return true;
    final lower = mimeType.toLowerCase();
    if (lower.contains('wav') ||
        lower.contains('mpeg') ||
        lower.contains('mp3') ||
        lower.contains('ogg') ||
        lower.contains('webm') ||
        lower.contains('m4a') ||
        lower.contains('aac') ||
        lower.contains('flac')) {
      return false;
    }
    return lower.contains('pcm') ||
        lower.contains('l16') ||
        lower.contains('audio/raw') ||
        lower == 'audio/l16';
  }

  /// Wraps little-endian PCM samples in a 44-byte WAV header.
  static Uint8List pcmToWav(
    Uint8List pcm, {
    int sampleRate = defaultPcmSampleRate,
    int channels = defaultChannels,
    int bitsPerSample = defaultBitsPerSample,
  }) {
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;
    final dataSize = pcm.length;
    final fileSize = 36 + dataSize;
    final header = ByteData(44);

    void writeString(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        header.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    header.setUint32(4, fileSize, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // PCM fmt chunk size
    header.setUint16(20, 1, Endian.little); // audio format = PCM
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    writeString(36, 'data');
    header.setUint32(40, dataSize, Endian.little);

    final out = Uint8List(44 + dataSize);
    out.setRange(0, 44, header.buffer.asUint8List());
    out.setRange(44, out.length, pcm);
    return out;
  }

  /// Ensures [bytes] are playable by audioplayers across platforms.
  ///
  /// Gemini coach AUDIO is usually raw 16-bit PCM @ 24 kHz. Already-WAV/MP3
  /// payloads are returned unchanged.
  static PlayableAudio ensurePlayable(
    Uint8List bytes, {
    String? mimeType,
  }) {
    if (bytes.isEmpty) {
      return PlayableAudio(bytes: bytes, mimeType: mimeType ?? 'audio/wav');
    }
    if (isWav(bytes)) {
      return PlayableAudio(bytes: bytes, mimeType: 'audio/wav');
    }
    if (isMp3(bytes) || (mimeType?.toLowerCase().contains('mp3') ?? false)) {
      return PlayableAudio(bytes: bytes, mimeType: 'audio/mpeg');
    }
    if (isRawPcmMime(mimeType) || mimeType == null || mimeType.isEmpty) {
      final rate = sampleRateFromMime(mimeType);
      return PlayableAudio(
        bytes: pcmToWav(bytes, sampleRate: rate),
        mimeType: 'audio/wav',
      );
    }
    // Unknown container — attempt WAV wrap as last resort for short PCM-like blobs.
    if (!mimeType.toLowerCase().contains('audio/')) {
      return PlayableAudio(
        bytes: pcmToWav(bytes),
        mimeType: 'audio/wav',
      );
    }
    return PlayableAudio(bytes: bytes, mimeType: mimeType);
  }
}
