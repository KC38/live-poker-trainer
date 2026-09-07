/// Drift table definitions for diagnostics, AI request, and hand-history
/// logging (schema version 3).
///
/// Conventions shared by every table in this file:
///
/// * Timestamps are **UTC epoch milliseconds** stored in `INTEGER` columns
///   whose names end in `Ms`. Millisecond precision matters for latency and
///   replay pacing, and integers sort/index cheaply.
/// * `createdAtMs` is set once on insert; `updatedAtMs` is bumped on every
///   mutation so a debug export can show what changed after the fact.
/// * Rows link to the owning app launch through `sessionId` and to the hand
///   being played through `handId`, both plain integers (no FK enforcement so a
///   pruned parent never blocks a diagnostic insert).
/// * Secrets are never persisted: the Gemini API key is redacted before any
///   text lands in these tables.
library;

import 'package:drift/drift.dart';

/// One app launch. Everything else hangs off [id] via `session_id`.
@TableIndex(name: 'idx_app_sessions_started', columns: {#startedAtMs})
class AppSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Random id that stays stable for the lifetime of the process.
  TextColumn get sessionUuid => text().unique()();
  IntColumn get startedAtMs => integer()();

  /// Last lifecycle heartbeat (resume / pause / detach). Mobile OSes kill
  /// processes without notice, so this is the best "shutdown" estimate.
  IntColumn get lastSeenAtMs => integer()();

  /// Set when the app reported `detached` / `paused`; null while alive.
  IntColumn get endedAtMs => integer().nullable()();
  TextColumn get appVersion => text().withDefault(const Constant(''))();
  TextColumn get buildNumber => text().withDefault(const Constant(''))();

  /// `ios`, `android`, `web`, `macos`, …
  TextColumn get platform => text().withDefault(const Constant(''))();
  TextColumn get osVersion => text().withDefault(const Constant(''))();
  BoolColumn get isDebugBuild =>
      boolean().withDefault(const Constant(false))();

  /// Schema version that was live when the session started.
  IntColumn get schemaVersion => integer().withDefault(const Constant(0))();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
}

/// Every Gemini call: scenario JSON, coach text, speech, image.
@TableIndex(name: 'idx_ai_requests_session', columns: {#sessionId})
@TableIndex(name: 'idx_ai_requests_created', columns: {#createdAtMs})
@TableIndex(name: 'idx_ai_requests_model', columns: {#modelId})
@TableIndex(name: 'idx_ai_requests_kind', columns: {#requestKind})
class AiRequests extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().nullable()();
  IntColumn get handId => integer().nullable()();

  /// `scenario`, `coach`, `tts`, `image`.
  TextColumn get requestKind => text()();
  TextColumn get modelId => text()();

  /// SHA-256 of the system instruction (empty when none was sent).
  TextColumn get systemInstructionHash =>
      text().withDefault(const Constant(''))();

  /// SHA-256 of the user prompt as sent.
  TextColumn get promptHash => text()();

  /// Prompt text, truncated to `RetentionPolicy.maxInlineTextChars`.
  TextColumn get promptText => text()();

  /// Full prompt bytes (UTF-8) only when [promptText] had to be truncated.
  BlobColumn get promptFull => blob().nullable()();
  IntColumn get requestedAtMs => integer()();
  IntColumn get respondedAtMs => integer().nullable()();
  IntColumn get latencyMs => integer().nullable()();
  IntColumn get httpStatus => integer().nullable()();
  BoolColumn get success => boolean()();

  /// Redacted error / exception message.
  TextColumn get errorMessage => text().nullable()();
  IntColumn get promptTokens => integer().nullable()();
  IntColumn get responseTokens => integer().nullable()();
  IntColumn get totalTokens => integer().nullable()();

  /// Text response (truncated). For audio/image responses this holds the MIME
  /// type and byte length instead of the payload.
  TextColumn get responseText => text().nullable()();

  /// Size of a binary response (audio / image) in bytes.
  IntColumn get responseBytes => integer().nullable()();

  /// 1-based attempt counter (retries increment it).
  IntColumn get attempt => integer().withDefault(const Constant(1))();
  BoolColumn get fromCache => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtMs => integer()();
}

/// Metadata (and optionally bytes) for synthesized coach voice clips.
///
/// On native the WAV lives on disk at [filePath]; on platforms without a
/// writable support directory (web) the bytes are kept in [audioBlob].
@TableIndex(name: 'idx_voice_clips_last_access', columns: {#lastAccessedAtMs})
@TableIndex(name: 'idx_voice_clips_evicted', columns: {#evictedAtMs})
class VoiceClips extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `VoiceCache.keyFor(text, voice, model)`.
  TextColumn get cacheKey => text().unique()();
  TextColumn get spokenText => text()();
  TextColumn get voice => text()();
  TextColumn get modelId => text()();
  TextColumn get mimeType => text().withDefault(const Constant('audio/wav'))();
  IntColumn get byteSize => integer()();
  TextColumn get filePath => text().nullable()();
  BlobColumn get audioBlob => blob().nullable()();
  IntColumn get createdAtMs => integer()();
  IntColumn get lastAccessedAtMs => integer()();
  IntColumn get hitCount => integer().withDefault(const Constant(0))();
  IntColumn get expiresAtMs => integer()();
  IntColumn get evictedAtMs => integer().nullable()();

  /// `ttl`, `lru`, `clear`, `missing`.
  TextColumn get evictionReason => text().nullable()();
  IntColumn get updatedAtMs => integer()();
}

/// One dealt hand at the training table.
@TableIndex(name: 'idx_hands_session', columns: {#sessionId})
@TableIndex(name: 'idx_hands_started', columns: {#startedAtMs})
class Hands extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().nullable()();

  /// Engine hand counter within the table session.
  IntColumn get handNumber => integer()();
  IntColumn get startedAtMs => integer()();
  IntColumn get endedAtMs => integer().nullable()();

  /// `GameSettingsModel.toPrefsMap()` at deal time.
  TextColumn get settingsJson => text()();
  IntColumn get seatCount => integer()();
  RealColumn get smallBlind => real()();
  RealColumn get bigBlind => real()();
  IntColumn get stackDepthBb => integer()();
  IntColumn get dealerSeat => integer()();
  IntColumn get sbSeat => integer()();
  IntColumn get bbSeat => integer()();
  IntColumn get heroSeat => integer()();

  /// Per seat: id, name, archetype, starting stack.
  TextColumn get lineupJson => text()();

  /// Hero hole cards as space-separated codes (`As Kd`).
  TextColumn get heroCards => text().withDefault(const Constant(''))();
  TextColumn get boardFlop => text().withDefault(const Constant(''))();
  TextColumn get boardTurn => text().withDefault(const Constant(''))();
  TextColumn get boardRiver => text().withDefault(const Constant(''))();

  /// Street the hand ended on (`PREFLOP` … `SHOWDOWN`).
  TextColumn get finalStreet => text().nullable()();
  BoolColumn get wentToShowdown =>
      boolean().withDefault(const Constant(false))();
  TextColumn get resultMessage => text().nullable()();

  /// Seats that were awarded chips.
  TextColumn get winnerSeatsJson => text().withDefault(const Constant('[]'))();
  RealColumn get finalPot => real().withDefault(const Constant(0))();

  /// Hero stack change over the hand, in dollars and big blinds.
  RealColumn get heroNetDollars => real().withDefault(const Constant(0))();
  RealColumn get heroNetBb => real().withDefault(const Constant(0))();

  /// Sum of coach EV deltas for the hand.
  RealColumn get heroEvDeltaDollars => real().withDefault(const Constant(0))();
  RealColumn get heroEvDeltaBb => real().withDefault(const Constant(0))();

  /// Auto-rebuy top-ups applied before this deal: seat, from, to.
  TextColumn get rebuyEventsJson => text().withDefault(const Constant('[]'))();

  /// `HandRecorder.payloadVersion`, so readers can evolve the JSON columns.
  IntColumn get payloadVersion => integer().withDefault(const Constant(1))();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
}

/// Every action in a hand, blinds included, in order.
@TableIndex(name: 'idx_hand_actions_hand', columns: {#handId})
class HandActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get handId => integer()();
  IntColumn get sequence => integer()();
  IntColumn get seat => integer()();
  TextColumn get playerName => text()();
  TextColumn get archetype => text()();
  BoolColumn get isHero => boolean().withDefault(const Constant(false))();
  TextColumn get street => text()();

  /// `BLIND`, `FOLD`, `CHECK`, `CALL`, `BET`, `RAISE`, `ALL-IN`.
  TextColumn get actionType => text()();
  RealColumn get amount => real().withDefault(const Constant(0))();
  RealColumn get potBefore => real().withDefault(const Constant(0))();
  RealColumn get potAfter => real().withDefault(const Constant(0))();
  RealColumn get stackAfter => real().withDefault(const Constant(0))();
  IntColumn get atMs => integer()();
}

/// Coach verdict for one hero decision.
@TableIndex(name: 'idx_coach_decisions_hand', columns: {#handId})
@TableIndex(name: 'idx_coach_decisions_session', columns: {#sessionId})
@TableIndex(name: 'idx_coach_decisions_created', columns: {#createdAtMs})
class CoachDecisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get handId => integer().nullable()();
  IntColumn get sessionId => integer().nullable()();
  TextColumn get street => text()();
  TextColumn get heroAction => text()();
  RealColumn get heroAmount => real().withDefault(const Constant(0))();
  TextColumn get bestAction => text().nullable()();
  RealColumn get bestSizingBb => real().withDefault(const Constant(0))();

  /// `correct`, `incorrect`, `none`.
  TextColumn get verdict => text()();

  /// `CoachMismatch.name`.
  TextColumn get mismatch => text().withDefault(const Constant('none'))();
  RealColumn get evDeltaBb => real().withDefault(const Constant(0))();
  RealColumn get evDeltaDollars => real().withDefault(const Constant(0))();
  TextColumn get villainName => text().withDefault(const Constant(''))();
  TextColumn get villainArchetype => text().withDefault(const Constant(''))();

  /// Final advice shown to the player.
  TextColumn get adviceText => text()();

  /// `gemini` or `offline`.
  TextColumn get adviceSource => text().withDefault(const Constant('offline'))();

  /// Linked `ai_requests.id` for the coach text call, when one was made.
  IntColumn get aiRequestId => integer().nullable()();
  BoolColumn get voicePlayed => boolean().withDefault(const Constant(false))();
  BoolColumn get voiceFromCache =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get voiceUsedDevice =>
      boolean().withDefault(const Constant(false))();
  IntColumn get gradedAtMs => integer()();
  IntColumn get narratedAtMs => integer().nullable()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
}

/// One changed settings key.
@TableIndex(name: 'idx_settings_changes_changed', columns: {#changedAtMs})
class SettingsChanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().nullable()();
  TextColumn get settingKey => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  IntColumn get changedAtMs => integer()();
}

/// Caught exceptions and notable diagnostics.
@TableIndex(name: 'idx_diagnostic_events_created', columns: {#createdAtMs})
@TableIndex(name: 'idx_diagnostic_events_session', columns: {#sessionId})
@TableIndex(name: 'idx_diagnostic_events_context', columns: {#context})
class DiagnosticEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().nullable()();
  IntColumn get handId => integer().nullable()();

  /// `error`, `warning`, `info`.
  TextColumn get level => text().withDefault(const Constant('error'))();

  /// Where it happened, e.g. `GeminiService.coach`, `SoundService.playFile`.
  TextColumn get context => text()();
  TextColumn get message => text()();

  /// Truncated stack trace.
  TextColumn get stackTrace => text().nullable()();

  /// Free-form JSON for extra fields.
  TextColumn get extraJson => text().nullable()();
  IntColumn get createdAtMs => integer()();
}
