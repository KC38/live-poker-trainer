/// Contract between [GeminiService] and the AI request log.
///
/// The service knows nothing about Drift; it emits one [AiRequestLogEntry]
/// per HTTP attempt and the installed [AiRequestLogger] (backed by
/// `DiagnosticsDao`) persists it. Keys are redacted before this point.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// What a Gemini call was for.
enum AiRequestKind {
  scenario,
  coach,
  tts,
  image;

  /// Stable string stored in the database.
  String get dbValue => name;
}

/// Token counts from `usageMetadata`, when the API returned them.
@immutable
class AiTokenUsage {
  /// Creates a token usage record.
  const AiTokenUsage({this.prompt, this.response, this.total});

  final int? prompt;
  final int? response;
  final int? total;

  /// Parses the Gemini `usageMetadata` object; null when absent.
  static AiTokenUsage? fromResponse(Map<String, dynamic> response) {
    final meta = response['usageMetadata'];
    if (meta is! Map) return null;
    int? read(String key) {
      final v = meta[key];
      return v is num ? v.toInt() : null;
    }

    return AiTokenUsage(
      prompt: read('promptTokenCount'),
      response: read('candidatesTokenCount'),
      total: read('totalTokenCount'),
    );
  }
}

/// One attempt of one Gemini request.
@immutable
class AiRequestLogEntry {
  /// Creates a log entry.
  const AiRequestLogEntry({
    required this.kind,
    required this.modelId,
    required this.prompt,
    required this.systemInstruction,
    required this.requestedAt,
    required this.respondedAt,
    required this.success,
    this.httpStatus,
    this.errorMessage,
    this.usage,
    this.responseText,
    this.responseBytes,
    this.attempt = 1,
    this.fromCache = false,
    this.handId,
  });

  final AiRequestKind kind;
  final String modelId;

  /// User prompt text exactly as sent.
  final String prompt;

  /// System instruction text, empty when none.
  final String systemInstruction;
  final DateTime requestedAt;
  final DateTime respondedAt;
  final bool success;
  final int? httpStatus;
  final String? errorMessage;
  final AiTokenUsage? usage;

  /// Text response, or a `mime (n bytes)` summary for binary responses.
  final String? responseText;
  final int? responseBytes;
  final int attempt;
  final bool fromCache;
  final int? handId;

  /// Wall-clock latency of this attempt.
  int get latencyMs => respondedAt.difference(requestedAt).inMilliseconds;

  /// SHA-256 of [prompt].
  String get promptHash => sha256Hex(prompt);

  /// SHA-256 of [systemInstruction], empty when there was none.
  String get systemInstructionHash =>
      systemInstruction.isEmpty ? '' : sha256Hex(systemInstruction);

  /// Hex SHA-256 of [text].
  static String sha256Hex(String text) =>
      sha256.convert(utf8.encode(text)).toString();
}

/// Destination for [AiRequestLogEntry]s.
abstract class AiRequestLogger {
  /// Persists [entry] and returns its row id (null when not stored).
  Future<int?> logRequest(AiRequestLogEntry entry);
}
