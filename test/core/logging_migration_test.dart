/// Schema migration to v3: legacy v1 / v2 databases gain the logging tables
/// and scenario metadata columns without losing existing rows.
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/database/diagnostics_dao.dart';
import 'package:live_poker_trainer/core/database/scenario_dao.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// The v1 schema exactly as shipped: three tables, no logging, no metadata.
const _v1Sql = '''
CREATE TABLE scenarios (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  content_hash TEXT NOT NULL UNIQUE,
  payload_json TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
);
CREATE TABLE played_scenarios (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  scenario_id INTEGER NOT NULL REFERENCES scenarios (id),
  played_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
  was_correct INTEGER NOT NULL DEFAULT 0 CHECK (was_correct IN (0, 1)),
  ev_delta_bb REAL NOT NULL DEFAULT 0.0,
  street TEXT NOT NULL DEFAULT '',
  archetype TEXT NOT NULL DEFAULT '',
  UNIQUE (user_id, scenario_id)
);
CREATE TABLE user_stats_rows (
  user_id TEXT NOT NULL,
  total_spots INTEGER NOT NULL DEFAULT 0,
  correct_spots INTEGER NOT NULL DEFAULT 0,
  net_ev_bb REAL NOT NULL DEFAULT 0.0,
  archetype_json TEXT NOT NULL DEFAULT '{}',
  street_json TEXT NOT NULL DEFAULT '{}',
  recent_ev_json TEXT NOT NULL DEFAULT '[]',
  PRIMARY KEY (user_id)
);
INSERT INTO scenarios (content_hash, payload_json) VALUES ('h1', '{"a":1}');
INSERT INTO played_scenarios (user_id, scenario_id, was_correct) VALUES ('local', 1, 1);
INSERT INTO user_stats_rows (user_id, total_spots, correct_spots) VALUES ('local', 5, 3);
''';

/// Opens an in-memory database pre-populated at [version].
NativeDatabase _legacyDb(int version) {
  return NativeDatabase.memory(
    setup: (raw) {
      raw.execute(_v1Sql);
      if (version >= 2) {
        // v2 added the mistake tracker tables; a minimal shape is enough for
        // the migration to treat them as already present.
        raw.execute('CREATE TABLE mistakes (id INTEGER PRIMARY KEY);');
        raw.execute('CREATE TABLE improvement_events (id INTEGER PRIMARY KEY);');
      }
      raw.execute('PRAGMA user_version = $version;');
    },
  );
}

Future<Set<String>> _tables(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
      .get();
  return rows.map((r) => r.read<String>('name')).toSet();
}

Future<Set<String>> _columns(AppDatabase db, String table) async {
  final rows = await db.customSelect('PRAGMA table_info("$table")').get();
  return rows.map((r) => r.read<String>('name')).toSet();
}

void main() {
  test('current schema version is 3', () {
    expect(AppDatabase.currentSchemaVersion, 3);
  });

  for (final from in [1, 2]) {
    test('v$from -> v3 adds logging tables and keeps rows', () async {
      final db = AppDatabase(_legacyDb(from));
      addTearDown(db.close);

      // Any query triggers the migration.
      final tables = await _tables(db);
      expect(
        tables,
        containsAll([
          'scenarios',
          'played_scenarios',
          'user_stats_rows',
          'mistakes',
          'improvement_events',
          'app_sessions',
          'ai_requests',
          'voice_clips',
          'hands',
          'hand_actions',
          'coach_decisions',
          'settings_changes',
          'diagnostic_events',
        ]),
      );

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), 3);

      // Scenario metadata columns were added in place; legacy rows survive
      // with sensible defaults.
      expect(
        await _columns(db, 'scenarios'),
        containsAll([
          'source',
          'model_id',
          'generated_at_ms',
          'last_updated_at_ms',
          'times_served',
          'last_served_at_ms',
          'payload_version',
        ]),
      );
      final legacy = await db.select(db.scenarios).get();
      expect(legacy.single.contentHash, 'h1');
      expect(legacy.single.source, 'gemini');
      expect(legacy.single.timesServed, 0);
      expect(legacy.single.generatedAtMs, isNull);

      final played = await db.select(db.playedScenarios).get();
      expect(played.single.wasCorrect, isTrue);
      final stats = await db.select(db.userStatsRows).get();
      expect(stats.single.totalSpots, 5);

      // Indexes exist and the new tables are writable.
      final indexes = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
          .get();
      final names = indexes.map((r) => r.read<String>('name')).toSet();
      expect(
        names,
        containsAll([
          'idx_ai_requests_session',
          'idx_ai_requests_created',
          'idx_ai_requests_model',
          'idx_hands_session',
          'idx_hand_actions_hand',
          'idx_coach_decisions_hand',
          'idx_diagnostic_events_created',
        ]),
      );
      final diagnostics = DiagnosticsDao(db);
      await diagnostics.startSession(sessionUuid: 'after-migration');
      expect(await diagnostics.recentSessions(), hasLength(1));
    });
  }

  test('fresh database creates everything at v3', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final tables = await _tables(db);
    expect(tables, contains('ai_requests'));
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 3);
  });

  test('ScenarioDao writes and updates cache metadata', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ScenarioDao(db);
    final scenario = ScenarioModel.fromGeminiJson(const {
      'table_size': 6,
      'hero_position': 'BTN',
      'hero_hand': 'As Kd',
      'board_cards': <String>[],
      'pot_size': 3.0,
      'villain_seat': 2,
      'villain_archetype': 'Nit',
      'previous_action_narrative': 'folds to hero',
      'villain_action': 'checks',
      'call_amount': 0.0,
      'min_raise': 4.0,
      'max_raise': 200.0,
      'optimal_exploit_action': 'RAISE',
      'optimal_sizing_bb': 2.5,
      'theoretical_ev_explanation': 'x',
      'exploit_reasoning': 'y',
    });

    final id = await dao.upsert(scenario, modelId: 'gemini-test');
    var row = (await db.select(db.scenarios).get()).single;
    expect(row.source, 'gemini');
    expect(row.modelId, 'gemini-test');
    expect(row.generatedAtMs, isNotNull);
    expect(row.payloadVersion, ScenarioDao.payloadVersion);

    // Re-upserting the same content bumps last_updated only.
    final again = await dao.upsert(scenario, source: 'offline');
    expect(again, id);
    row = (await db.select(db.scenarios).get()).single;
    expect(row.source, 'gemini');

    await dao.markServed(id);
    await dao.markServed(id);
    row = (await db.select(db.scenarios).get()).single;
    expect(row.timesServed, 2);
    expect(row.lastServedAtMs, isNotNull);
  });
}
