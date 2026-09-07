/// Drift database and DAO for the hero profile (identity + cached summary).
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/database/profile_tables.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';

part 'profile_database.g.dart';

/// Profile store: display name, avatar, metric snapshot, cached AI summary.
@DriftDatabase(tables: [HeroProfiles, ProfileSnapshots])
class ProfileDatabase extends _$ProfileDatabase {
  /// Opens the platform-appropriate connection, or uses [executor] in tests.
  ProfileDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );

  static QueryExecutor _open() {
    return driftDatabase(
      name: 'poker_profile',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Identity
  // ---------------------------------------------------------------------------

  /// Loads the hero's identity, falling back to the defaults when no row has
  /// been written yet. Never inserts, so a read stays side-effect free.
  Future<HeroIdentity> readIdentity({
    String userId = Config.defaultUserId,
  }) async {
    final row = await _profileRow(userId);
    if (row == null) return const HeroIdentity();
    return HeroIdentity(
      displayName: row.displayName,
      avatar: AvatarRef.parse(row.avatarRef),
    );
  }

  /// Watches the hero's identity.
  Stream<HeroIdentity> watchIdentity({
    String userId = Config.defaultUserId,
  }) {
    return (select(heroProfiles)..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull()
        .map(
          (row) => row == null
              ? const HeroIdentity()
              : HeroIdentity(
                  displayName: row.displayName,
                  avatar: AvatarRef.parse(row.avatarRef),
                ),
        );
  }

  /// Writes the display name, sanitized to a storable length.
  Future<HeroIdentity> saveDisplayName(
    String rawName, {
    String userId = Config.defaultUserId,
  }) async {
    final name = HeroIdentity.sanitizeName(rawName);
    final current = await readIdentity(userId: userId);
    await _upsertProfile(
      userId: userId,
      displayName: name,
      avatarRef: current.avatar.storageValue,
    );
    return current.copyWith(displayName: name);
  }

  /// Writes the avatar reference.
  Future<HeroIdentity> saveAvatar(
    AvatarRef avatar, {
    String userId = Config.defaultUserId,
  }) async {
    final current = await readIdentity(userId: userId);
    await _upsertProfile(
      userId: userId,
      displayName: current.displayName,
      avatarRef: avatar.storageValue,
    );
    return current.copyWith(avatar: avatar);
  }

  Future<HeroProfile?> _profileRow(String userId) {
    return (select(heroProfiles)..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> _upsertProfile({
    required String userId,
    required String displayName,
    required String avatarRef,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final existing = await _profileRow(userId);
    await into(heroProfiles).insertOnConflictUpdate(
      HeroProfilesCompanion(
        userId: Value(userId),
        displayName: Value(displayName),
        avatarRef: Value(avatarRef),
        createdAtMs: Value(existing?.createdAtMs ?? now),
        updatedAtMs: Value(now),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Metric snapshot + cached summary
  // ---------------------------------------------------------------------------

  /// Reads the cached metric snapshot, or null when nothing was ever computed.
  ///
  /// Street/archetype tendencies and the trend are not persisted, so the
  /// returned [HeroMetrics] carries samples, style, and leaks only. Callers
  /// use it to paint the first frame and then replace it with a fresh compute.
  Future<HeroMetrics?> readSnapshot({
    String userId = Config.defaultUserId,
  }) async {
    final row = await _snapshotRow(userId);
    if (row == null) return null;
    return _decodeSnapshot(row);
  }

  /// Persists [metrics] as the current snapshot, leaving any cached summary in
  /// place (the summary has its own refresh policy).
  Future<void> saveSnapshot(
    HeroMetrics metrics, {
    String userId = Config.defaultUserId,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final existing = await _snapshotRow(userId);
    await into(profileSnapshots).insertOnConflictUpdate(
      ProfileSnapshotsCompanion(
        userId: Value(userId),
        handsPlayed: Value(metrics.handsPlayed),
        styleId: Value(metrics.style.style.name),
        styleLabel: Value(metrics.style.style.label),
        styleConfidence: Value(metrics.style.confidence.name),
        styleExplanation: Value(metrics.style.explanation),
        metricsJson: Value(jsonEncode(metrics.toJson())),
        summaryText: Value(existing?.summaryText ?? ''),
        summaryLeaksJson: Value(existing?.summaryLeaksJson ?? '[]'),
        summaryAdjustmentsJson:
            Value(existing?.summaryAdjustmentsJson ?? '[]'),
        summarySource: Value(existing?.summarySource ?? ''),
        summaryModelId: Value(existing?.summaryModelId ?? ''),
        summaryHandsPlayed: Value(existing?.summaryHandsPlayed ?? 0),
        summaryStyleId: Value(existing?.summaryStyleId ?? ''),
        summaryGeneratedAtMs: Value(existing?.summaryGeneratedAtMs),
        computedAtMs: Value(now),
        updatedAtMs: Value(now),
      ),
    );
  }

  /// Reads the cached coach summary, or null when none has been generated.
  Future<ProfileCoachSummary?> readSummary({
    String userId = Config.defaultUserId,
  }) async {
    final row = await _snapshotRow(userId);
    if (row == null) return null;
    if (row.summaryText.trim().isEmpty || row.summaryGeneratedAtMs == null) {
      return null;
    }
    return ProfileCoachSummary.fromStorage(
      styleSummary: row.summaryText,
      leaksJson: row.summaryLeaksJson,
      adjustmentsJson: row.summaryAdjustmentsJson,
      source: row.summarySource,
      modelId: row.summaryModelId,
      handsPlayedAt: row.summaryHandsPlayed,
      styleId: row.summaryStyleId,
      generatedAtMs: row.summaryGeneratedAtMs!,
    );
  }

  /// Caches [summary]. Creates the snapshot row if a summary somehow arrives
  /// before the first metric compute.
  Future<void> saveSummary(
    ProfileCoachSummary summary, {
    String userId = Config.defaultUserId,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final existing = await _snapshotRow(userId);
    await into(profileSnapshots).insertOnConflictUpdate(
      ProfileSnapshotsCompanion(
        userId: Value(userId),
        handsPlayed: Value(existing?.handsPlayed ?? summary.handsPlayedAt),
        styleId: Value(existing?.styleId ?? summary.styleId),
        styleLabel: Value(existing?.styleLabel ?? ''),
        styleConfidence: Value(existing?.styleConfidence ?? 'insufficient'),
        styleExplanation: Value(existing?.styleExplanation ?? ''),
        metricsJson: Value(existing?.metricsJson ?? '{}'),
        summaryText: Value(summary.styleSummary),
        summaryLeaksJson: Value(summary.leaksJson),
        summaryAdjustmentsJson: Value(summary.adjustmentsJson),
        summarySource: Value(summary.source),
        summaryModelId: Value(summary.modelId),
        summaryHandsPlayed: Value(summary.handsPlayedAt),
        summaryStyleId: Value(summary.styleId),
        summaryGeneratedAtMs: Value(
          summary.generatedAt.toUtc().millisecondsSinceEpoch,
        ),
        computedAtMs: Value(existing?.computedAtMs ?? now),
        updatedAtMs: Value(now),
      ),
    );
  }

  /// Drops the profile and its snapshot (used by "reset profile").
  Future<void> clearProfile({String userId = Config.defaultUserId}) async {
    await (delete(heroProfiles)..where((t) => t.userId.equals(userId))).go();
    await (delete(profileSnapshots)..where((t) => t.userId.equals(userId)))
        .go();
  }

  Future<ProfileSnapshot?> _snapshotRow(String userId) {
    return (select(profileSnapshots)..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  HeroMetrics _decodeSnapshot(ProfileSnapshot row) {
    Map<String, dynamic> decoded;
    try {
      final raw = jsonDecode(row.metricsJson);
      decoded = raw is Map ? Map<String, dynamic>.from(raw) : {};
    } catch (_) {
      decoded = {};
    }
    final metrics = HeroMetrics.fromJson(decoded);
    return HeroMetrics(
      handsPlayed: row.handsPlayed,
      samples: metrics.samples,
      style: StyleReadout(
        style: PlayingStyle.values.firstWhere(
          (s) => s.name == row.styleId,
          orElse: () => PlayingStyle.forming,
        ),
        confidence: StyleConfidence.values.firstWhere(
          (c) => c.name == row.styleConfidence,
          orElse: () => StyleConfidence.insufficient,
        ),
        explanation: row.styleExplanation,
        handsPlayed: row.handsPlayed,
      ),
      leaks: metrics.leaks,
      netBb: metrics.netBb,
      showdowns: metrics.showdowns,
      computedAt: DateTime.fromMillisecondsSinceEpoch(
        row.computedAtMs,
        isUtc: true,
      ),
    );
  }
}
