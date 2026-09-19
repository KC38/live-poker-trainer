/// [DiagnosticsSink] that forwards errors to Firebase Crashlytics.
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' hide DiagnosticLevel;
import 'package:live_poker_trainer/core/diagnostics/diagnostics_log.dart';

/// Persists [DiagnosticsLog] errors as non-fatal Crashlytics records.
class CrashlyticsDiagnosticsSink implements DiagnosticsSink {
  /// Creates a sink. Uses [FirebaseCrashlytics.instance] when [crashlytics]
  /// is omitted.
  CrashlyticsDiagnosticsSink({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics;

  final FirebaseCrashlytics? _crashlytics;

  @override
  Future<void> record(DiagnosticRecord event) async {
    if (kIsWeb) return;
    if (event.level != DiagnosticLevel.error) return;
    try {
      final crashlytics = _crashlytics ?? FirebaseCrashlytics.instance;
      final keys = <String, Object>{
        'context': event.context,
        if (event.handId != null) 'hand_id': event.handId!,
      };
      final extra = event.extra;
      if (extra != null) {
        for (final entry in extra.entries) {
          final value = entry.value;
          if (value is String || value is num || value is bool) {
            keys[entry.key] = value as Object;
          } else if (value != null) {
            keys[entry.key] = value.toString();
          }
        }
      }
      for (final entry in keys.entries) {
        await crashlytics.setCustomKey(entry.key, entry.value);
      }
      await crashlytics.recordError(
        event.message,
        event.stackTrace != null
            ? StackTrace.fromString(event.stackTrace!)
            : StackTrace.current,
        reason: event.context,
        fatal: false,
      );
    } catch (e) {
      debugPrint('CrashlyticsDiagnosticsSink failed: $e');
    }
  }
}
