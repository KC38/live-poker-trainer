/// Size / age bounds for the high-volume diagnostics tables.
///
/// Pruning runs on session start (`DiagnosticsDao.prune`) and is cheap: each
/// bound is one `DELETE … WHERE id NOT IN (SELECT id … ORDER BY id DESC LIMIT
/// n)` or an indexed `created_at_ms <` scan.
library;

import 'package:flutter/foundation.dart';

/// Retention limits for logged data. All values are inclusive upper bounds.
@immutable
class RetentionPolicy {
  /// Creates a retention policy.
  const RetentionPolicy({
    this.maxAiRequests = 2000,
    this.maxAiRequestAge = const Duration(days: 30),
    this.maxDiagnosticEvents = 2000,
    this.maxDiagnosticEventAge = const Duration(days: 30),
    this.maxSettingsChanges = 1000,
    this.maxHands = 3000,
    this.maxCoachDecisions = 10000,
    this.maxSessions = 500,
    this.evictedVoiceClipAge = const Duration(days: 7),
    this.maxInlineTextChars = 4000,
    this.maxStackTraceChars = 4000,
  });

  /// Newest N `ai_requests` rows to keep.
  final int maxAiRequests;

  /// `ai_requests` older than this are dropped regardless of count.
  final Duration maxAiRequestAge;

  /// Newest N `diagnostic_events` rows to keep.
  final int maxDiagnosticEvents;

  /// `diagnostic_events` older than this are dropped regardless of count.
  final Duration maxDiagnosticEventAge;

  /// Newest N `settings_changes` rows to keep.
  final int maxSettingsChanges;

  /// Newest N `hands` to keep (their `hand_actions` go with them).
  final int maxHands;

  /// Newest N `coach_decisions` rows to keep.
  final int maxCoachDecisions;

  /// Newest N `app_sessions` rows to keep.
  final int maxSessions;

  /// Evicted `voice_clips` rows older than this are deleted.
  final Duration evictedVoiceClipAge;

  /// Prompt / response text longer than this is truncated inline; the full
  /// prompt is kept in a blob column.
  final int maxInlineTextChars;

  /// Stack traces are cut to this many characters.
  final int maxStackTraceChars;

  /// Production defaults.
  static const RetentionPolicy standard = RetentionPolicy();

  /// Tight bounds for tests.
  static const RetentionPolicy tiny = RetentionPolicy(
    maxAiRequests: 3,
    maxDiagnosticEvents: 3,
    maxSettingsChanges: 3,
    maxHands: 2,
    maxCoachDecisions: 3,
    maxSessions: 2,
    maxInlineTextChars: 32,
    maxStackTraceChars: 64,
  );

  /// Cuts [text] to [maxInlineTextChars], appending an ellipsis marker.
  String truncate(String text) => _cut(text, maxInlineTextChars);

  /// Cuts a stack trace to [maxStackTraceChars].
  String truncateStack(String text) => _cut(text, maxStackTraceChars);

  static String _cut(String text, int max) {
    if (text.length <= max) return text;
    if (max <= 1) return text.substring(0, max);
    return '${text.substring(0, max - 1)}…';
  }
}
