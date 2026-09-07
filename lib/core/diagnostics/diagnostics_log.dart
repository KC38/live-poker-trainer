/// Process-wide sink for caught exceptions and notable events.
///
/// Services deep in the audio / network stack catch and swallow errors so play
/// never stalls. Instead of losing those, they call [DiagnosticsLog.error] and
/// the installed [DiagnosticsSink] (backed by `DiagnosticsDao`) persists them
/// off the UI thread. Every call is fire-and-forget and can never throw.
library;

import 'package:flutter/foundation.dart';

/// Severity of a diagnostic event.
enum DiagnosticLevel { error, warning, info }

/// One diagnostic record before persistence.
@immutable
class DiagnosticEvent {
  /// Creates a diagnostic event.
  const DiagnosticEvent({
    required this.level,
    required this.context,
    required this.message,
    this.stackTrace,
    this.extra,
    this.handId,
  });

  final DiagnosticLevel level;

  /// Where it happened, e.g. `GeminiService.coach`.
  final String context;
  final String message;
  final String? stackTrace;

  /// Free-form structured fields (JSON-encodable).
  final Map<String, Object?>? extra;
  final int? handId;
}

/// Destination for [DiagnosticEvent]s.
abstract class DiagnosticsSink {
  /// Persists [event]. Must not throw.
  Future<void> record(DiagnosticEvent event);
}

/// Static facade used by services that have no database handle.
class DiagnosticsLog {
  DiagnosticsLog._();

  static DiagnosticsSink? _sink;

  /// Optional hook for tests / debug overlays; receives every event.
  static void Function(DiagnosticEvent event)? listener;

  /// Redaction step applied to every message (removes API keys).
  static String Function(String text) redactor = (text) => text;

  /// Installs the persistence sink (pass null to detach).
  static void install(DiagnosticsSink? sink) => _sink = sink;

  /// Whether a sink is installed.
  static bool get isInstalled => _sink != null;

  /// Records a caught exception.
  static void error(
    String context,
    Object error, [
    StackTrace? stack,
    Map<String, Object?>? extra,
    int? handId,
  ]) {
    _emit(
      DiagnosticEvent(
        level: DiagnosticLevel.error,
        context: context,
        message: redactor('$error'),
        stackTrace: stack == null ? null : redactor('$stack'),
        extra: extra,
        handId: handId,
      ),
    );
  }

  /// Records a non-fatal warning.
  static void warning(
    String context,
    String message, {
    Map<String, Object?>? extra,
    int? handId,
  }) {
    _emit(
      DiagnosticEvent(
        level: DiagnosticLevel.warning,
        context: context,
        message: redactor(message),
        extra: extra,
        handId: handId,
      ),
    );
  }

  /// Records an informational event.
  static void info(
    String context,
    String message, {
    Map<String, Object?>? extra,
    int? handId,
  }) {
    _emit(
      DiagnosticEvent(
        level: DiagnosticLevel.info,
        context: context,
        message: redactor(message),
        extra: extra,
        handId: handId,
      ),
    );
  }

  static void _emit(DiagnosticEvent event) {
    try {
      listener?.call(event);
    } catch (_) {
      // Listeners are best-effort.
    }
    final sink = _sink;
    if (sink == null) return;
    try {
      // Detached future: persistence never blocks the caller.
      sink.record(event).catchError((Object e) {
        debugPrint('DiagnosticsLog sink failed: $e');
      });
    } catch (e) {
      debugPrint('DiagnosticsLog sink threw: $e');
    }
  }
}
