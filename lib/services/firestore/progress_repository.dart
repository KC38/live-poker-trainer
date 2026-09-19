/// Reads user progress aggregates from Firestore.
///
/// Primary source: `users/{uid}/progress/main` (server-authored).
/// Falls back to empty stats when the doc is missing.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/hand_history_sample.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';

/// Progress surface backed by `users/{uid}/progress/main`.
class ProgressRepository {
  /// Creates a progress repository.
  ProgressRepository({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  FirebaseFirestore get _db => _override ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _progressDoc(String uid) =>
      _db.collection('users').doc(uid).collection('progress').doc('main');

  /// Coaching / EV aggregates from the progress doc.
  Future<UserStatsModel> loadStats(String uid) async {
    final snap = await _progressDoc(
      uid,
    ).get(const GetOptions(source: Source.server));
    if (!snap.exists || snap.data() == null) {
      return const UserStatsModel();
    }
    return UserStatsModel.fromFirestoreMap(snap.data()!);
  }

  /// Loads profiler inputs from server-authored hand-history documents.
  Future<List<HeroHandSample>> loadHandSamples(
    String uid, {
    int limit = 100,
  }) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('handHistory')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get(const GetOptions(source: Source.server));
    return [
      for (var index = 0; index < snap.docs.length; index++)
        _handSample(snap.docs[index], index),
    ];
  }

  static HeroHandSample _handSample(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    int index,
  ) {
    final data = doc.data();
    final createdAt = _dateTime(data['createdAt']);
    final rawActions = data['actions'];
    final actions =
        rawActions is List
            ? rawActions
                .map(_actionSample)
                .whereType<HandActionSample>()
                .toList()
            : <HandActionSample>[];
    final parsedId = int.tryParse(doc.id);
    return HeroHandSample(
      handId:
          parsedId ??
          Object.hash(doc.id, createdAt.microsecondsSinceEpoch, index),
      playedAt: createdAt,
      actions: List.unmodifiable(actions),
      heroSeat: _int(data['heroSeat']) ?? 0,
      wentToShowdown: data['wentToShowdown'] == true,
      heroWon: data['heroWon'] == true,
      heroNetBb: _double(data['heroNetBb']) ?? 0,
    );
  }

  static HandActionSample? _actionSample(Object? raw) {
    if (raw is! Map) return null;
    final kind = HandActionKind.tryParse('${raw['kind'] ?? ''}');
    final street = _street(raw['street']);
    final seat = _int(raw['seat']);
    if (kind == null || street == null || seat == null) return null;
    final isHero = raw['isHero'] == true;
    return HandActionSample(
      seat: seat,
      street: street,
      kind: kind,
      amountBb: _double(raw['amountBb']) ?? 0,
      isHero: isHero,
      archetype:
          isHero
              ? PlayerArchetype.hero
              : PlayerArchetype.fromLabel('${raw['archetype'] ?? 'TAG'}'),
    );
  }

  static Street? _street(Object? raw) {
    final value = '$raw'.trim().toLowerCase();
    for (final street in Street.values) {
      if (street.name.toLowerCase() == value ||
          street.label.toLowerCase() == value) {
        return street;
      }
    }
    return null;
  }

  static int? _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value');

  static double? _double(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value');

  static DateTime _dateTime(Object? value) => switch (value) {
    Timestamp timestamp => timestamp.toDate().toUtc(),
    DateTime dateTime => dateTime.toUtc(),
    String text =>
      DateTime.tryParse(text)?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    _ => DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  };
}
