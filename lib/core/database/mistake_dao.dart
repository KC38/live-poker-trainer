/// Mistake / improvement persistence and repeat detection over Drift.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Data-access helpers for the leak tracker.
class MistakeDao {
  /// Creates a DAO bound to [db].
  MistakeDao(this.db);

  final AppDatabase db;

  /// Persists one mistake and returns its row id plus repeat context.
  Future<({int id, RepeatInfo repeat})> recordMistake({
    String userId = Config.defaultUserId,
    required String sessionId,
    required String handId,
    String? decisionId,
    required MistakePattern pattern,
    required double heroAmount,
    required double bestSizingBb,
    required double evDeltaBb,
    required double evDeltaDollars,
    required String adviceText,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now();
    final key = pattern.key;

    final previous = await (db.select(db.mistakes)
          ..where((t) => t.userId.equals(userId) & t.mistakeKey.equals(key))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    final previousInSession =
        previous.where((r) => r.sessionId == sessionId).length;
    final tagCount = await _countTag(userId, pattern.primaryTag.id);

    final id = await db.into(db.mistakes).insert(
          MistakesCompanion.insert(
            userId: Value(userId),
            sessionId: sessionId,
            handId: handId,
            decisionId: Value(decisionId),
            createdAt: Value(ts),
            street: pattern.street.name,
            villainArchetype: pattern.archetype.label,
            heroAction: pattern.taken.name,
            heroAmount: Value(heroAmount),
            bestAction: pattern.best.name,
            bestSizingBb: Value(bestSizingBb),
            evDeltaBb: Value(evDeltaBb),
            evDeltaDollars: Value(evDeltaDollars),
            mistakeKey: key,
            contextKey: pattern.contextKey,
            primaryTag: pattern.primaryTag.id,
            coarseTagsJson:
                Value(jsonEncode(pattern.tags.map((t) => t.id).toList())),
            adviceText: Value(adviceText),
          ),
        );

    return (
      id: id,
      repeat: RepeatInfo(
        pattern: pattern,
        totalCount: previous.length + 1,
        sessionCount: previousInSession + 1,
        tagTotalCount: tagCount + 1,
        lastSeen: previous.isEmpty ? null : previous.first.createdAt,
      ),
    );
  }

  /// Replaces the stored advice once the AI line has arrived.
  Future<void> updateAdvice(int id, String adviceText) {
    return (db.update(db.mistakes)..where((t) => t.id.equals(id))).write(
      MistakesCompanion(adviceText: Value(adviceText)),
    );
  }

  /// Checks whether a CORRECT decision fixes a previously-repeated leak.
  ///
  /// A leak counts as "repeated" once the same fine key has been recorded at
  /// least [minRepeats] times. Matching prefers the exact spot (same street,
  /// archetype, best action) and falls back to the same archetype + best
  /// action on any street. Returns null when nothing matches.
  Future<ImprovementInfo?> findImprovement({
    String userId = Config.defaultUserId,
    required MistakePattern pattern,
    int minRepeats = 2,
  }) async {
    final rows = await (db.select(db.mistakes)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    if (rows.isEmpty) return null;

    final counts = <String, int>{};
    final latest = <String, Mistake>{};
    for (final r in rows) {
      counts[r.mistakeKey] = (counts[r.mistakeKey] ?? 0) + 1;
      latest.putIfAbsent(r.mistakeKey, () => r);
    }

    Mistake? match;
    var exact = false;
    for (final r in rows) {
      if ((counts[r.mistakeKey] ?? 0) < minRepeats) continue;
      if (r.contextKey == pattern.contextKey) {
        match = r;
        exact = true;
        break;
      }
    }
    if (match == null) {
      final coarse = pattern.coarseContextKey;
      for (final r in rows) {
        if ((counts[r.mistakeKey] ?? 0) < minRepeats) continue;
        final rowCoarse = r.contextKey.substring(r.contextKey.indexOf(':') + 1);
        if (rowCoarse == coarse) {
          match = r;
          break;
        }
      }
    }
    if (match == null) return null;

    final lastMistakeAt = latest[match.mistakeKey]!.createdAt;
    final streakCountExp = db.improvementEvents.id.count();
    final streakQuery = db.selectOnly(db.improvementEvents)
      ..addColumns([streakCountExp])
      ..where(db.improvementEvents.userId.equals(userId) &
          db.improvementEvents.mistakeKey.equals(match.mistakeKey) &
          db.improvementEvents.createdAt.isBiggerThanValue(lastMistakeAt));
    final priorStreak =
        (await streakQuery.getSingle()).read(streakCountExp) ?? 0;

    return ImprovementInfo(
      matchedKey: match.mistakeKey,
      tag: MistakeTag.fromId(match.primaryTag),
      priorMistakes: counts[match.mistakeKey] ?? 0,
      streak: priorStreak + 1,
      exactContext: exact,
      lastWrongAction: _action(match.heroAction),
    );
  }

  /// Persists an improvement event; returns its row id.
  Future<int> recordImprovement({
    String userId = Config.defaultUserId,
    required String sessionId,
    required String handId,
    String? decisionId,
    required ImprovementInfo improvement,
    required MistakePattern pattern,
    DateTime? now,
  }) {
    return db.into(db.improvementEvents).insert(
          ImprovementEventsCompanion.insert(
            userId: Value(userId),
            sessionId: sessionId,
            handId: handId,
            decisionId: Value(decisionId),
            createdAt: Value(now ?? DateTime.now()),
            mistakeKey: improvement.matchedKey,
            primaryTag: improvement.tag.id,
            street: pattern.street.name,
            villainArchetype: pattern.archetype.label,
            heroAction: pattern.taken.name,
            streak: Value(improvement.streak),
          ),
        );
  }

  /// All mistakes for [userId], newest first.
  Future<List<Mistake>> allMistakes({String userId = Config.defaultUserId}) {
    return (db.select(db.mistakes)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// All improvement events for [userId], newest first.
  Future<List<ImprovementEvent>> allImprovements({
    String userId = Config.defaultUserId,
  }) {
    return (db.select(db.improvementEvents)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Deletes every mistake and improvement for [userId].
  Future<void> clear({String userId = Config.defaultUserId}) async {
    await (db.delete(db.mistakes)..where((t) => t.userId.equals(userId))).go();
    await (db.delete(db.improvementEvents)
          ..where((t) => t.userId.equals(userId)))
        .go();
  }

  /// Leak-finder aggregates for the Stats screen.
  Future<MistakeStats> loadStats({
    String userId = Config.defaultUserId,
    int topLimit = 8,
  }) async {
    final mistakes = await allMistakes(userId: userId);
    final improvements = await allImprovements(userId: userId);
    if (mistakes.isEmpty) {
      return MistakeStats(totalImprovements: improvements.length);
    }

    final byKey = <String, List<Mistake>>{};
    final byArchetype = <String, int>{};
    final byStreet = <String, int>{};
    final byTag = <MistakeTag, int>{};
    for (final m in mistakes) {
      byKey.putIfAbsent(m.mistakeKey, () => []).add(m);
      byArchetype[m.villainArchetype] =
          (byArchetype[m.villainArchetype] ?? 0) + 1;
      byStreet[m.street] = (byStreet[m.street] ?? 0) + 1;
      final tag = MistakeTag.fromId(m.primaryTag);
      byTag[tag] = (byTag[tag] ?? 0) + 1;
    }

    final improvementsByKey = <String, List<ImprovementEvent>>{};
    for (final e in improvements) {
      improvementsByKey.putIfAbsent(e.mistakeKey, () => []).add(e);
    }

    final summaries = <MistakeSummary>[];
    for (final entry in byKey.entries) {
      final rows = entry.value; // newest first
      final newest = rows.first;
      final fixes = improvementsByKey[entry.key] ?? const [];
      final latestFix = fixes.isEmpty ? null : fixes.first;
      final lastWasFix =
          latestFix != null && latestFix.createdAt.isAfter(newest.createdAt);
      final streak =
          fixes.where((f) => f.createdAt.isAfter(newest.createdAt)).length;
      summaries.add(
        MistakeSummary(
          key: entry.key,
          tag: MistakeTag.fromId(newest.primaryTag),
          street: newest.street,
          archetype: newest.villainArchetype,
          taken: newest.heroAction,
          best: newest.bestAction,
          count: rows.length,
          lastSeen: newest.createdAt,
          improvements: fixes.length,
          currentStreak: lastWasFix ? streak : 0,
          lastEventWasImprovement: lastWasFix,
          evLostBb: rows.fold<double>(
            0,
            (sum, r) => sum + (r.evDeltaBb < 0 ? -r.evDeltaBb : 0),
          ),
        ),
      );
    }
    summaries.sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : b.lastSeen.compareTo(a.lastSeen);
    });

    return MistakeStats(
      totalMistakes: mistakes.length,
      totalImprovements: improvements.length,
      topMistakes: summaries.take(topLimit).toList(),
      byArchetype: byArchetype,
      byStreet: byStreet,
      byTag: byTag,
    );
  }

  Future<int> _countTag(String userId, String tagId) async {
    final countExp = db.mistakes.id.count();
    final q = db.selectOnly(db.mistakes)
      ..addColumns([countExp])
      ..where(
        db.mistakes.userId.equals(userId) & db.mistakes.primaryTag.equals(tagId),
      );
    return (await q.getSingle()).read(countExp) ?? 0;
  }

  static ExploitAction _action(String name) {
    for (final a in ExploitAction.values) {
      if (a.name == name) return a;
    }
    return ExploitAction.call;
  }
}
