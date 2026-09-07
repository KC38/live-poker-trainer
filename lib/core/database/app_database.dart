/// Drift database schema, connection, and DAO accessors.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/database/logging_tables.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';

part 'app_database.g.dart';

/// Cached Gemini scenarios (deduped by content hash).
///
/// Schema v3 added cache metadata (source, model, served counters, payload
/// version); see [AppDatabase.migration].
class Scenarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contentHash => text().unique()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// `gemini` or `offline`.
  TextColumn get source => text().withDefault(const Constant('gemini'))();
  TextColumn get modelId => text().withDefault(const Constant(''))();

  /// UTC epoch ms; null for rows written before schema v3.
  IntColumn get generatedAtMs => integer().nullable()();
  IntColumn get lastUpdatedAtMs => integer().nullable()();
  IntColumn get timesServed => integer().withDefault(const Constant(0))();
  IntColumn get lastServedAtMs => integer().nullable()();
  IntColumn get payloadVersion => integer().withDefault(const Constant(1))();
}

/// Marks scenarios as played for a user.
class PlayedScenarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  IntColumn get scenarioId => integer().references(Scenarios, #id)();
  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get wasCorrect => boolean().withDefault(const Constant(false))();
  RealColumn get evDeltaBb => real().withDefault(const Constant(0))();
  TextColumn get street => text().withDefault(const Constant(''))();
  TextColumn get archetype => text().withDefault(const Constant(''))();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {userId, scenarioId},
      ];
}

/// Rolling aggregate stats row (single-user local profile).
class UserStatsRows extends Table {
  TextColumn get userId => text()();
  IntColumn get totalSpots => integer().withDefault(const Constant(0))();
  IntColumn get correctSpots => integer().withDefault(const Constant(0))();
  RealColumn get netEvBb => real().withDefault(const Constant(0))();
  TextColumn get archetypeJson => text().withDefault(const Constant('{}'))();
  TextColumn get streetJson => text().withDefault(const Constant('{}'))();
  TextColumn get recentEvJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

/// Every INCORRECT live-coach verdict, classified into a stable mistake key.
///
/// `sessionId` / `handId` / `decisionId` are free-form text so they can be
/// linked to a future sessions / hand-history / coach-decision log without a
/// schema change (`decisionId` is nullable until such a log exists).
class Mistakes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant('local'))();
  TextColumn get sessionId => text()();
  TextColumn get handId => text()();
  TextColumn get decisionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get street => text()();
  TextColumn get villainArchetype => text()();
  TextColumn get heroAction => text()();
  RealColumn get heroAmount => real().withDefault(const Constant(0))();
  TextColumn get bestAction => text()();
  RealColumn get bestSizingBb => real().withDefault(const Constant(0))();
  RealColumn get evDeltaBb => real().withDefault(const Constant(0))();
  RealColumn get evDeltaDollars => real().withDefault(const Constant(0))();

  /// Fine-grained key, e.g. `river:nit:raise->call`.
  TextColumn get mistakeKey => text()();

  /// Spot without the hero action, e.g. `river:nit:call`.
  TextColumn get contextKey => text()();

  /// Most specific coarse tag id.
  TextColumn get primaryTag => text()();

  /// JSON list of every coarse tag id.
  TextColumn get coarseTagsJson => text().withDefault(const Constant('[]'))();

  /// Advice shown to the user (updated once the AI line arrives).
  TextColumn get adviceText => text().withDefault(const Constant(''))();
}

/// A CORRECT decision in a spot the user previously got wrong repeatedly.
class ImprovementEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant('local'))();
  TextColumn get sessionId => text()();
  TextColumn get handId => text()();
  TextColumn get decisionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// The mistake key credited with this fix.
  TextColumn get mistakeKey => text()();
  TextColumn get primaryTag => text()();
  TextColumn get street => text()();
  TextColumn get villainArchetype => text()();
  TextColumn get heroAction => text()();

  /// Consecutive fixes on this key since its last mistake, including this one.
  IntColumn get streak => integer().withDefault(const Constant(1))();
}

/// Application Drift database (native SQLite + web WASM).
///
/// Schema history:
/// * v1 — `scenarios`, `played_scenarios`, `user_stats_rows`.
/// * v2 — `mistakes`, `improvement_events`.
/// * v3 — diagnostics / logging tables from `logging_tables.dart`
///   (`app_sessions`, `ai_requests`, `voice_clips`, `hands`, `hand_actions`,
///   `coach_decisions`, `settings_changes`, `diagnostic_events`) plus cache
///   metadata columns on `scenarios`. Existing rows are preserved.
@DriftDatabase(
  tables: [
    Scenarios,
    PlayedScenarios,
    UserStatsRows,
    Mistakes,
    ImprovementEvents,
    AppSessions,
    AiRequests,
    VoiceClips,
    Hands,
    HandActions,
    CoachDecisions,
    SettingsChanges,
    DiagnosticEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the platform-appropriate database connection.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  /// Current schema version. Bump together with [migration].
  static const int currentSchemaVersion = 3;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(mistakes);
            await m.createTable(improvementEvents);
          }
          if (from < 3) {
            await _upgradeLoggingToV3(m);
          }
        },
      );

  /// v2 → v3: logging tables, their indexes, and scenario cache metadata.
  ///
  /// `createTable` / `createIndex` emit `IF NOT EXISTS`, so re-running after a
  /// partially applied upgrade is safe. Column adds are guarded by reading the
  /// live table info because SQLite has no `ADD COLUMN IF NOT EXISTS`.
  Future<void> _upgradeLoggingToV3(Migrator m) async {
    for (final table in <TableInfo>[
      appSessions,
      aiRequests,
      voiceClips,
      hands,
      handActions,
      coachDecisions,
      settingsChanges,
      diagnosticEvents,
    ]) {
      await m.createTable(table);
    }
    for (final index in allSchemaEntities.whereType<Index>()) {
      await m.createIndex(index);
    }
    final rows =
        await customSelect('PRAGMA table_info("${scenarios.actualTableName}")')
            .get();
    final existing = rows.map((r) => r.read<String>('name')).toSet();
    for (final column in <GeneratedColumn>[
      scenarios.source,
      scenarios.modelId,
      scenarios.generatedAtMs,
      scenarios.lastUpdatedAtMs,
      scenarios.timesServed,
      scenarios.lastServedAtMs,
      scenarios.payloadVersion,
    ]) {
      if (!existing.contains(column.$name)) {
        await m.addColumn(scenarios, column);
      }
    }
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'poker_lab',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  // --- Scenario DAO ---

  /// Inserts a scenario if its content hash is new. Returns the row id.
  Future<int> upsertScenario(ScenarioModel scenario) async {
    final existing = await (select(scenarios)
          ..where((t) => t.contentHash.equals(scenario.contentHash)))
        .getSingleOrNull();
    if (existing != null) {
      return existing.id;
    }
    return into(scenarios).insert(
      ScenariosCompanion.insert(
        contentHash: scenario.contentHash,
        payloadJson: jsonEncode(scenario.toJson()),
      ),
    );
  }

  /// Unplayed scenarios for [userId].
  Future<List<ScenarioModel>> getUnplayedScenarios({
    String userId = Config.defaultUserId,
    int limit = 20,
  }) async {
    final playedIds = selectOnly(playedScenarios)
      ..addColumns([playedScenarios.scenarioId])
      ..where(playedScenarios.userId.equals(userId));

    final rows = await (select(scenarios)
          ..where((t) => t.id.isNotInQuery(playedIds))
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(limit))
        .get();

    return rows.map(_scenarioFromRow).toList();
  }

  /// Count of unplayed scenarios (prefetch trigger).
  Future<int> countUnplayed({String userId = Config.defaultUserId}) async {
    final playedIds = selectOnly(playedScenarios)
      ..addColumns([playedScenarios.scenarioId])
      ..where(playedScenarios.userId.equals(userId));

    final countExp = scenarios.id.count();
    final query = selectOnly(scenarios)
      ..addColumns([countExp])
      ..where(scenarios.id.isNotInQuery(playedIds));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  /// Marks a scenario played and records grading metadata.
  Future<void> markScenarioPlayed({
    required int scenarioId,
    String userId = Config.defaultUserId,
    required bool wasCorrect,
    required double evDeltaBb,
    required String street,
    required String archetype,
  }) async {
    await into(playedScenarios).insert(
      PlayedScenariosCompanion.insert(
        userId: userId,
        scenarioId: scenarioId,
        wasCorrect: Value(wasCorrect),
        evDeltaBb: Value(evDeltaBb),
        street: Value(street),
        archetype: Value(archetype),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  ScenarioModel _scenarioFromRow(Scenario row) {
    final map = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    return ScenarioModel.fromGeminiJson(map).copyWith(id: row.id);
  }

  // --- User stats DAO ---

  /// Loads aggregated stats for [userId], creating an empty row if needed.
  Future<UserStatsModel> getUserStats({
    String userId = Config.defaultUserId,
  }) async {
    final row = await (select(userStatsRows)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
    if (row == null) {
      await into(userStatsRows).insert(
        UserStatsRowsCompanion.insert(userId: userId),
      );
      return const UserStatsModel();
    }
    return _statsFromRow(row);
  }

  /// Applies a practice result into aggregate stats.
  Future<UserStatsModel> recordPracticeResult({
    String userId = Config.defaultUserId,
    required bool wasCorrect,
    required double evDeltaBb,
    required String street,
    required String archetype,
  }) async {
    final current = await getUserStats(userId: userId);
    final arch = Map<String, ArchetypeStat>.from(current.archetypeAccuracy);
    final prevArch = arch[archetype] ?? ArchetypeStat(archetype: archetype);
    arch[archetype] = prevArch.copyWith(
      played: prevArch.played + 1,
      correct: prevArch.correct + (wasCorrect ? 1 : 0),
      evBb: prevArch.evBb + evDeltaBb,
    );

    final streets = Map<String, StreetStat>.from(current.streetAccuracy);
    final prevStreet = streets[street] ?? StreetStat(street: street);
    streets[street] = prevStreet.copyWith(
      played: prevStreet.played + 1,
      correct: prevStreet.correct + (wasCorrect ? 1 : 0),
    );

    final recent = [...current.recentEvDeltas, evDeltaBb];
    if (recent.length > 40) {
      recent.removeRange(0, recent.length - 40);
    }

    final updated = current.copyWith(
      totalSpots: current.totalSpots + 1,
      correctSpots: current.correctSpots + (wasCorrect ? 1 : 0),
      netEvBb: current.netEvBb + evDeltaBb,
      archetypeAccuracy: arch,
      streetAccuracy: streets,
      recentEvDeltas: recent,
    );

    await into(userStatsRows).insertOnConflictUpdate(
      UserStatsRowsCompanion(
        userId: Value(userId),
        totalSpots: Value(updated.totalSpots),
        correctSpots: Value(updated.correctSpots),
        netEvBb: Value(updated.netEvBb),
        archetypeJson: Value(_encodeArchetypes(updated.archetypeAccuracy)),
        streetJson: Value(_encodeStreets(updated.streetAccuracy)),
        recentEvJson: Value(jsonEncode(updated.recentEvDeltas)),
      ),
    );
    return updated;
  }

  UserStatsModel _statsFromRow(UserStatsRow row) {
    final archRaw = jsonDecode(row.archetypeJson) as Map<String, dynamic>;
    final streetRaw = jsonDecode(row.streetJson) as Map<String, dynamic>;
    final recentRaw = jsonDecode(row.recentEvJson) as List<dynamic>;
    return UserStatsModel(
      totalSpots: row.totalSpots,
      correctSpots: row.correctSpots,
      netEvBb: row.netEvBb,
      archetypeAccuracy: archRaw.map(
        (k, v) {
          final m = Map<String, dynamic>.from(v as Map);
          return MapEntry(
            k,
            ArchetypeStat(
              archetype: k,
              played: m['played'] as int? ?? 0,
              correct: m['correct'] as int? ?? 0,
              evBb: (m['evBb'] as num?)?.toDouble() ?? 0,
            ),
          );
        },
      ),
      streetAccuracy: streetRaw.map(
        (k, v) {
          final m = Map<String, dynamic>.from(v as Map);
          return MapEntry(
            k,
            StreetStat(
              street: k,
              played: m['played'] as int? ?? 0,
              correct: m['correct'] as int? ?? 0,
            ),
          );
        },
      ),
      recentEvDeltas: recentRaw.map((e) => (e as num).toDouble()).toList(),
    );
  }

  String _encodeArchetypes(Map<String, ArchetypeStat> map) {
    return jsonEncode({
      for (final e in map.entries)
        e.key: {
          'played': e.value.played,
          'correct': e.value.correct,
          'evBb': e.value.evBb,
        },
    });
  }

  String _encodeStreets(Map<String, StreetStat> map) {
    return jsonEncode({
      for (final e in map.entries)
        e.key: {
          'played': e.value.played,
          'correct': e.value.correct,
        },
    });
  }
}
