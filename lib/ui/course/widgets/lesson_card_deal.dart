/// Constrained random hole / board deals for attribute-based lesson steps.
///
/// Keeps the teaching concept (suited, pocket pair, one-of-each-suit, …) while
/// varying ranks, suits, and seat placement so learners cannot memorize a
/// fixed layout. Deals are drawn once per widget mount; pass a seeded
/// [Random] in tests for reproducibility.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/poker_constants.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Test hook: when set, hole-hand and suit-board deals use this RNG.
@visibleForTesting
Random? debugLessonCardDealRandom;

/// Starting-hand attribute used when dealing two hole cards.
enum LessonHoleKind {
  /// Two cards, same suit, different ranks.
  suitedNonPair,

  /// Two cards, different suits, different ranks.
  offsuitNonPair,

  /// Matching ranks, different suits.
  pocketPair,

  /// Ace plus a non-ace, same suit.
  suitedAce,

  /// Two distinct broadway ranks (T–A), different suits.
  broadway,

  /// Consecutive ranks, same suit.
  suitedConnector,

  /// Consecutive ranks, different suits.
  offsuitConnector,

  /// Low disconnected offsuit (gap ≥ 3, both ranks ≤ 9).
  offsuitTrash,
}

/// Three face-up hole hands on the suits/ranks table, with grading ids.
@immutable
class HoleHandSeatDeal {
  /// Creates a dealt seat plan.
  const HoleHandSeatDeal({
    required this.heroCodes,
    required this.villainHoleCodes,
    required this.correctSeatIndex,
    required this.choiceIdsBySeat,
  });

  /// Hero (seat 0) hole codes.
  final List<String> heroCodes;

  /// Face-up villain holes in seat order (Sam, Jo, …).
  final List<List<String>> villainHoleCodes;

  /// Seat index of the correct answer (0 = hero).
  final int correctSeatIndex;

  /// Authored choice id for seats 0..n-1.
  final List<String> choiceIdsBySeat;

  /// Choice id for [seat], or null when out of range.
  String? choiceIdForSeat(int seat) {
    if (seat < 0 || seat >= choiceIdsBySeat.length) return null;
    return choiceIdsBySeat[seat];
  }
}

/// One attribute role for a three-seat hole-hand identify step.
@immutable
class HoleHandSeatRole {
  /// Creates a role mapped to an authored choice id.
  const HoleHandSeatRole({
    required this.kind,
    required this.choiceId,
    required this.correct,
  });

  /// How to deal the two cards.
  final LessonHoleKind kind;

  /// Authored grading choice id (stable across card values).
  final String choiceId;

  /// Whether this role is the correct tap target.
  final bool correct;
}

/// Returns a randomized seat plan for suits/ranks hole-hand identify steps.
HoleHandSeatDeal? dealHoleHandSeatPlan(
  CourseActivity activity, {
  Random? random,
}) {
  final roles = switch (activity.id) {
    'act-01-01-02-unguided-suited' => const [
      HoleHandSeatRole(
        kind: LessonHoleKind.suitedNonPair,
        choiceId: 'suited-ah-kh',
        correct: true,
      ),
      HoleHandSeatRole(
        kind: LessonHoleKind.offsuitNonPair,
        choiceId: 'offsuit-ah-kd',
        correct: false,
      ),
      HoleHandSeatRole(
        kind: LessonHoleKind.pocketPair,
        choiceId: 'pair-77',
        correct: false,
      ),
    ],
    'act-01-01-02-checkpoint-pair' => const [
      HoleHandSeatRole(
        kind: LessonHoleKind.pocketPair,
        choiceId: 'pocket-pair',
        correct: true,
      ),
      HoleHandSeatRole(
        kind: LessonHoleKind.suitedNonPair,
        choiceId: 'suited-nine',
        correct: false,
      ),
      HoleHandSeatRole(
        kind: LessonHoleKind.offsuitNonPair,
        choiceId: 'two-high',
        correct: false,
      ),
    ],
    _ => null,
  };
  if (roles == null) return null;
  return dealHoleHandSeatRoles(roles, random: random);
}

/// Deals [roles] onto three seats (hero + two villains), shuffling placement.
HoleHandSeatDeal dealHoleHandSeatRoles(
  List<HoleHandSeatRole> roles, {
  Random? random,
}) {
  assert(roles.length == 3, 'hole-hand seat deals expect three roles');
  final rng = random ?? debugLessonCardDealRandom ?? Random();
  final used = <String>{};
  final dealt = <({List<String> codes, String choiceId, bool correct})>[
    for (final role in roles)
      (
        codes: dealHoleHand(role.kind, rng, used: used),
        choiceId: role.choiceId,
        correct: role.correct,
      ),
  ];
  for (var i = dealt.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = dealt[i];
    dealt[i] = dealt[j];
    dealt[j] = tmp;
  }
  final correctSeatIndex = dealt.indexWhere((row) => row.correct);
  assert(correctSeatIndex >= 0, 'deal must include one correct role');
  return HoleHandSeatDeal(
    heroCodes: List<String>.unmodifiable(dealt[0].codes),
    villainHoleCodes: List<List<String>>.unmodifiable([
      List<String>.unmodifiable(dealt[1].codes),
      List<String>.unmodifiable(dealt[2].codes),
    ]),
    correctSeatIndex: correctSeatIndex,
    choiceIdsBySeat: List<String>.unmodifiable([
      for (final row in dealt) row.choiceId,
    ]),
  );
}

/// Deals two hole cards matching [kind], avoiding [used] card codes.
List<String> dealHoleHand(
  LessonHoleKind kind,
  Random rng, {
  Set<String>? used,
}) {
  final blocked = used ?? <String>{};
  for (var attempt = 0; attempt < 64; attempt++) {
    final codes = switch (kind) {
      LessonHoleKind.suitedNonPair => _dealSuitedNonPair(rng),
      LessonHoleKind.offsuitNonPair => _dealOffsuitNonPair(rng),
      LessonHoleKind.pocketPair => _dealPocketPair(rng),
      LessonHoleKind.suitedAce => _dealSuitedAce(rng),
      LessonHoleKind.broadway => _dealBroadway(rng),
      LessonHoleKind.suitedConnector => _dealConnector(rng, suited: true),
      LessonHoleKind.offsuitConnector => _dealConnector(rng, suited: false),
      LessonHoleKind.offsuitTrash => _dealOffsuitTrash(rng),
    };
    if (codes.any(blocked.contains)) continue;
    blocked.addAll(codes);
    return List<String>.unmodifiable(codes);
  }
  throw StateError('Could not deal $kind without repeating cards');
}

/// Four board cards, one of each suit in h/d/c/s index order, distinct ranks.
List<String> dealOneOfEachSuitBoard({Random? random}) {
  final rng = random ?? debugLessonCardDealRandom ?? Random();
  const suits = ['h', 'd', 'c', 's'];
  final ranks = List<int>.generate(13, (i) => i + 2)..shuffle(rng);
  return List<String>.unmodifiable([
    for (var i = 0; i < suits.length; i++)
      '${PokerConstants.rankLabels[ranks[i]]}${suits[i]}',
  ]);
}

List<String> _dealSuitedNonPair(Random rng) {
  final suit = _suits[rng.nextInt(_suits.length)];
  final ranks = _twoDistinctRanks(rng);
  return [_code(ranks[0], suit), _code(ranks[1], suit)];
}

List<String> _dealOffsuitNonPair(Random rng) {
  final ranks = _twoDistinctRanks(rng);
  final suits = _twoDistinctSuits(rng);
  return [_code(ranks[0], suits[0]), _code(ranks[1], suits[1])];
}

List<String> _dealPocketPair(Random rng) {
  final rank = rng.nextInt(13) + 2;
  final suits = _twoDistinctSuits(rng);
  return [_code(rank, suits[0]), _code(rank, suits[1])];
}

List<String> _dealSuitedAce(Random rng) {
  final suit = _suits[rng.nextInt(_suits.length)];
  final kicker = rng.nextInt(12) + 2; // 2–K
  return [_code(14, suit), _code(kicker, suit)];
}

List<String> _dealBroadway(Random rng) {
  final ranks = _broadwayRanks.toList(growable: true)..shuffle(rng);
  final suits = _twoDistinctSuits(rng);
  return [_code(ranks[0], suits[0]), _code(ranks[1], suits[1])];
}

List<String> _dealConnector(Random rng, {required bool suited}) {
  // Low of the connector: 2–Q so high stays ≤ A.
  final low = rng.nextInt(12) + 2;
  final high = low + 1;
  if (suited) {
    final suit = _suits[rng.nextInt(_suits.length)];
    return [_code(high, suit), _code(low, suit)];
  }
  final suits = _twoDistinctSuits(rng);
  return [_code(high, suits[0]), _code(low, suits[1])];
}

List<String> _dealOffsuitTrash(Random rng) {
  for (var attempt = 0; attempt < 32; attempt++) {
    final a = rng.nextInt(8) + 2; // 2–9
    final b = rng.nextInt(8) + 2;
    if (a == b) continue;
    if ((a - b).abs() < 3) continue;
    final suits = _twoDistinctSuits(rng);
    return [_code(a, suits[0]), _code(b, suits[1])];
  }
  return const ['7c', '2d'];
}

List<int> _twoDistinctRanks(Random rng) {
  final first = rng.nextInt(13) + 2;
  var second = rng.nextInt(13) + 2;
  while (second == first) {
    second = rng.nextInt(13) + 2;
  }
  // Higher rank first for a stable display convention.
  if (first >= second) return [first, second];
  return [second, first];
}

List<String> _twoDistinctSuits(Random rng) {
  final first = _suits[rng.nextInt(_suits.length)];
  var second = _suits[rng.nextInt(_suits.length)];
  while (second == first) {
    second = _suits[rng.nextInt(_suits.length)];
  }
  return [first, second];
}

String _code(int rank, String suit) =>
    '${PokerConstants.rankLabels[rank]}$suit';

const List<String> _suits = ['h', 'd', 'c', 's'];
const List<int> _broadwayRanks = [10, 11, 12, 13, 14];

/// Two tiny hole cards dealt once for a hand-family teaching tile.
class DealtMiniPair extends StatefulWidget {
  /// Creates a randomized mini pair for [kind].
  const DealtMiniPair({super.key, required this.kind});

  /// Attribute to deal.
  final LessonHoleKind kind;

  @override
  State<DealtMiniPair> createState() => _DealtMiniPairState();
}

class _DealtMiniPairState extends State<DealtMiniPair> {
  late final List<String> _codes;

  @override
  void initState() {
    super.initState();
    _codes = dealHoleHand(
      widget.kind,
      debugLessonCardDealRandom ?? Random(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        MiniCard(
          card: CardModel.fromCode(_codes[0]),
          size: MiniCardSize.tiny,
        ),
        const SizedBox(width: 2),
        MiniCard(
          card: CardModel.fromCode(_codes[1]),
          size: MiniCardSize.tiny,
        ),
      ],
    );
  }
}
