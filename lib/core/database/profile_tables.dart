/// Drift tables for the hero's own profile: identity, computed metric
/// snapshot, and the cached AI style summary.
///
/// These live in their own Drift database (`poker_profile`) rather than in
/// [AppDatabase]. Two reasons:
///
/// * the profile is a *single row* of slowly changing user data, while the app
///   database is a high-churn log of scenarios, hands, and diagnostics; and
/// * it keeps the profile schema independent of the hand-logging schema, which
///   is being built out in parallel — neither has to migrate for the other.
///
/// Timestamps are UTC epoch milliseconds, matching the convention used by the
/// rest of the database layer.
library;

import 'package:drift/drift.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';

/// The hero's editable identity. One row per local user id.
class HeroProfiles extends Table {
  TextColumn get userId => text()();

  /// Shown at the hero seat and in the profile header.
  TextColumn get displayName => text().withDefault(
        const Constant(HeroIdentity.defaultDisplayName),
      )();

  /// [AvatarRef.storageValue]: `builtin:<id>`, `file:<path>`, or empty.
  TextColumn get avatarRef => text().withDefault(const Constant(''))();

  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

/// Latest computed metrics plus the cached coach summary. One row per user;
/// each recompute replaces it.
class ProfileSnapshots extends Table {
  TextColumn get userId => text()();

  /// Hands behind [metricsJson].
  IntColumn get handsPlayed => integer().withDefault(const Constant(0))();

  /// `PlayingStyle.name`.
  TextColumn get styleId =>
      text().withDefault(const Constant('forming'))();

  /// Human-readable style label at compute time (`Loose-Passive`).
  TextColumn get styleLabel => text().withDefault(const Constant(''))();

  /// `StyleConfidence.name`.
  TextColumn get styleConfidence =>
      text().withDefault(const Constant('insufficient'))();

  /// Why this style was assigned, in the player's own numbers.
  TextColumn get styleExplanation =>
      text().withDefault(const Constant(''))();

  /// `HeroMetrics.toJson()`.
  TextColumn get metricsJson => text().withDefault(const Constant('{}'))();

  // --- Cached AI summary ---

  /// Style paragraph shown in the AI feedback card.
  TextColumn get summaryText => text().withDefault(const Constant(''))();

  /// JSON list of leak lines.
  TextColumn get summaryLeaksJson =>
      text().withDefault(const Constant('[]'))();

  /// JSON list of concrete adjustments.
  TextColumn get summaryAdjustmentsJson =>
      text().withDefault(const Constant('[]'))();

  /// `gemini` or `offline`; empty when no summary has been written.
  TextColumn get summarySource => text().withDefault(const Constant(''))();

  /// Model that produced [summaryText] (empty for offline copy).
  TextColumn get summaryModelId => text().withDefault(const Constant(''))();

  /// Hands played when the summary was written — the refresh trigger.
  IntColumn get summaryHandsPlayed =>
      integer().withDefault(const Constant(0))();

  /// `PlayingStyle.name` when the summary was written.
  TextColumn get summaryStyleId => text().withDefault(const Constant(''))();

  IntColumn get summaryGeneratedAtMs => integer().nullable()();

  IntColumn get computedAtMs => integer()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}
