/// Reads the hero's hand history out of the shared app database.
///
/// The hand log (`hands` / `hand_actions`) is owned by the gameplay-logging
/// layer, not by the profile. To stay decoupled from that schema's migration
/// timeline this reader:
///
/// * checks `sqlite_master` and `PRAGMA table_info` before querying, so a
///   database without the log yields an empty history instead of an exception;
/// * selects only the handful of columns profiling needs; and
/// * normalizes everything into [HeroHandSample], the profiler's pure input.
///
/// When the log is missing the profile shows its "needs more hands" state,
/// which is exactly the right answer: no hands have been recorded yet.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/hand_history_sample.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Loads [HeroHandSample]s from the shared hand log.
class HandHistorySource {
  /// Creates a source bound to [db].
  HandHistorySource(this.db);

  final AppDatabase db;

  /// Hands read by default. Metric rates stabilize long before this, and it
  /// keeps the profile responsive on a long-lived local database.
  static const int defaultLimit = 600;

  static const String _handsTable = 'hands';
  static const String _actionsTable = 'hand_actions';

  static const Set<String> _requiredHandColumns = {
    'id',
    'started_at_ms',
    'hero_seat',
    'big_blind',
    'went_to_showdown',
    'hero_net_bb',
  };

  static const Set<String> _requiredActionColumns = {
    'hand_id',
    'sequence',
    'seat',
    'archetype',
    'is_hero',
    'street',
    'action_type',
    'amount',
  };

  Set<String>? _cachedHandColumns;
  bool? _cachedAvailability;

  /// Whether the hand log exists and has the columns profiling needs.
  Future<bool> isAvailable() async {
    final cached = _cachedAvailability;
    if (cached != null) return cached;
    try {
      final handColumns = await _columnsOf(_handsTable);
      final actionColumns = await _columnsOf(_actionsTable);
      _cachedHandColumns = handColumns;
      final ok = _requiredHandColumns.every(handColumns.contains) &&
          _requiredActionColumns.every(actionColumns.contains);
      return _cachedAvailability = ok;
    } catch (_) {
      return _cachedAvailability = false;
    }
  }

  /// Forgets the cached schema probe (call after a migration).
  void invalidateSchemaCache() {
    _cachedAvailability = null;
    _cachedHandColumns = null;
  }

  /// The most recent [limit] hands, oldest first.
  Future<List<HeroHandSample>> recentHands({
    int limit = defaultLimit,
  }) async {
    if (!await isAvailable()) return const [];
    try {
      final hands = await _readHands(limit);
      if (hands.isEmpty) return const [];
      final actions = await _readActions({
        for (final entry in hands.entries) entry.key: entry.value.bigBlind,
      });
      final samples = <HeroHandSample>[];
      for (final entry in hands.entries) {
        final head = entry.value;
        samples.add(
          HeroHandSample(
            handId: entry.key,
            playedAt: head.playedAt,
            heroSeat: head.heroSeat,
            wentToShowdown: head.wentToShowdown,
            heroWon: head.heroWon,
            heroNetBb: head.heroNetBb,
            actions: actions[entry.key] ?? const [],
          ),
        );
      }
      samples.sort((a, b) => a.handId.compareTo(b.handId));
      return samples;
    } catch (_) {
      // A log written by a newer schema is not worth crashing the profile for.
      return const [];
    }
  }

  Future<Set<String>> _columnsOf(String table) async {
    final exists = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          variables: [Variable<String>(table)],
        )
        .get();
    if (exists.isEmpty) return const {};
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return {
      for (final row in rows)
        if (row.data['name'] case final String name) name,
    };
  }

  Future<Map<int, _HandHead>> _readHands(int limit) async {
    final hasWinners =
        _cachedHandColumns?.contains('winner_seats_json') ?? false;
    final winners = hasWinners ? ', winner_seats_json' : '';
    final rows = await db
        .customSelect(
          'SELECT id, started_at_ms, hero_seat, big_blind, '
          'went_to_showdown, hero_net_bb$winners '
          'FROM $_handsTable ORDER BY id DESC LIMIT ?',
          variables: [Variable<int>(limit)],
        )
        .get();

    final heads = <int, _HandHead>{};
    for (final row in rows) {
      final data = row.data;
      final id = _asInt(data['id']);
      if (id == null) continue;
      final heroSeat = _asInt(data['hero_seat']) ?? 0;
      final netBb = _asDouble(data['hero_net_bb']) ?? 0;
      heads[id] = _HandHead(
        playedAt: DateTime.fromMillisecondsSinceEpoch(
          _asInt(data['started_at_ms']) ?? 0,
          isUtc: true,
        ),
        heroSeat: heroSeat,
        bigBlind: _asDouble(data['big_blind']) ?? 1,
        wentToShowdown: _asBool(data['went_to_showdown']),
        heroNetBb: netBb,
        heroWon: hasWinners
            ? _winnersContain(data['winner_seats_json'], heroSeat) ??
                netBb > 0
            : netBb > 0,
      );
    }
    return heads;
  }

  /// Reads actions for [bigBlinds] keys, converting chip amounts to big
  /// blinds using each hand's own stake.
  Future<Map<int, List<HandActionSample>>> _readActions(
    Map<int, double> bigBlinds,
  ) async {
    final handIds = bigBlinds.keys.toList(growable: false);
    if (handIds.isEmpty) return const {};
    final placeholders = List.filled(handIds.length, '?').join(', ');
    final rows = await db
        .customSelect(
          'SELECT hand_id, seat, archetype, is_hero, street, action_type, '
          'amount FROM $_actionsTable WHERE hand_id IN ($placeholders) '
          'ORDER BY hand_id ASC, sequence ASC',
          variables: [for (final id in handIds) Variable<int>(id)],
        )
        .get();

    final byHand = <int, List<HandActionSample>>{};
    for (final row in rows) {
      final data = row.data;
      final handId = _asInt(data['hand_id']);
      if (handId == null) continue;
      final kind = HandActionKind.tryParse('${data['action_type'] ?? ''}');
      final street = _parseStreet('${data['street'] ?? ''}');
      if (kind == null || street == null) continue;
      final isHero = _asBool(data['is_hero']);
      final bigBlind = bigBlinds[handId] ?? 1;
      final amount = _asDouble(data['amount']) ?? 0;
      byHand.putIfAbsent(handId, () => []).add(
            HandActionSample(
              seat: _asInt(data['seat']) ?? 0,
              street: street,
              kind: kind,
              isHero: isHero,
              archetype: isHero
                  ? PlayerArchetype.hero
                  : PlayerArchetype.fromLabel('${data['archetype'] ?? ''}'),
              amountBb: bigBlind > 0 ? amount / bigBlind : amount,
            ),
          );
    }
    return byHand;
  }

  static Street? _parseStreet(String raw) {
    final key = raw.trim().toLowerCase();
    for (final street in Street.values) {
      if (street.name == key) return street;
    }
    return null;
  }

  /// True/false when the winner list could be parsed, null when it could not.
  static bool? _winnersContain(Object? raw, int seat) {
    if (raw is! String || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.any((e) => _asInt(e) == seat);
    } catch (_) {
      return null;
    }
  }

  static int? _asInt(Object? value) => switch (value) {
        final int v => v,
        final num v => v.toInt(),
        final String v => int.tryParse(v),
        _ => null,
      };

  static double? _asDouble(Object? value) => switch (value) {
        final num v => v.toDouble(),
        final String v => double.tryParse(v),
        _ => null,
      };

  static bool _asBool(Object? value) => switch (value) {
        final bool v => v,
        final num v => v != 0,
        final String v => v == '1' || v.toLowerCase() == 'true',
        _ => false,
      };
}

/// Hand-level columns needed to build a [HeroHandSample].
class _HandHead {
  const _HandHead({
    required this.playedAt,
    required this.heroSeat,
    required this.bigBlind,
    required this.wentToShowdown,
    required this.heroNetBb,
    required this.heroWon,
  });

  final DateTime playedAt;
  final int heroSeat;
  final double bigBlind;
  final bool wentToShowdown;
  final double heroNetBb;
  final bool heroWon;
}
