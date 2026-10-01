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
import 'package:live_poker_trainer/engine/deck_evaluator.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Test hook: when set, hole-hand and suit-board deals use this RNG.
@visibleForTesting
Random? debugLessonCardDealRandom;

/// When true, dealt scene/action helpers skip suit remap.
@visibleForTesting
bool debugFreezeLessonSuitRemap = false;

/// Whether production remappers should permute suits.
bool get lessonSuitRemapEnabled => !debugFreezeLessonSuitRemap;

/// Attempt-scoped salt so replaying a lesson deals new faces.
///
/// Set from the course attempt id when a lesson starts; clear on dispose.
String lessonDealAttemptSalt = '';

/// RNG for a lesson attempt: explicit, test hook, or stable activity seed.
Random resolveLessonDealRandom({
  String? activityId,
  int generation = 0,
  Random? random,
  String? salt,
}) {
  if (random != null) return random;
  final hooked = debugLessonCardDealRandom;
  if (hooked != null) return hooked;
  if (activityId != null) {
    return Random(
      lessonDealSeed(
        activityId,
        generation,
        salt ?? lessonDealAttemptSalt,
      ),
    );
  }
  return Random();
}

/// FNV-1a seed from an activity id, generation, and optional attempt salt.
int lessonDealSeed(
  String activityId, [
  int generation = 0,
  String salt = '',
]) {
  var hash = 0x811c9dc5;
  final key =
      salt.isEmpty ? '$activityId#$generation' : '$activityId#$generation#$salt';
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}

/// Applies one random suit permutation to every code in [codes].
List<String> permuteCardSuits(List<String> codes, Random rng) {
  if (codes.isEmpty) return const [];
  final map = _freshSuitMap(rng);
  return [for (final code in codes) _applySuitMap(code, map)];
}

/// Remaps several code lists with the **same** suit permutation.
List<List<String>> permuteCardSuitGroups(
  List<List<String>> groups,
  Random rng,
) {
  final map = _freshSuitMap(rng);
  return [
    for (final codes in groups)
      [for (final code in codes) _applySuitMap(code, map)],
  ];
}

/// Applies one suit map to every code group (same permutation).
List<List<String>> applyCardSuitMap(
  List<List<String>> groups,
  Map<String, String> map,
) {
  return [
    for (final codes in groups)
      [for (final code in codes) _applySuitMap(code, map)],
  ];
}

Map<String, String> _freshSuitMap(Random rng) {
  final perm = List<String>.of(_suits)..shuffle(rng);
  return {for (var i = 0; i < _suits.length; i++) _suits[i]: perm[i]};
}

String _applySuitMap(String code, Map<String, String> map) {
  if (code.isEmpty) return code;
  final suit = code[code.length - 1];
  final mapped = map[suit];
  if (mapped == null) return code;
  return '${code.substring(0, code.length - 1)}$mapped';
}

/// Strategy-preserving starting-hand bucket for isomorphic preflop deals.
enum LessonStartingHandFamily {
  /// Pocket pairs QQ+.
  premiumPair,

  /// Pocket pairs 77–JJ.
  mediumPair,

  /// Pocket pairs 22–66.
  smallPair,

  /// Two distinct broadway ranks, same suit.
  suitedBroadway,

  /// Two distinct broadway ranks, different suits.
  offsuitBroadway,

  /// Ace plus a non-broadway kicker, same suit.
  suitedAce,

  /// Ace plus nine-or-worse offsuit.
  weakAceOffsuit,

  /// Consecutive ranks, same suit.
  suitedConnector,

  /// Consecutive ranks, different suits.
  offsuitConnector,

  /// Suited non-pair that is not broadway / ace / connector.
  suitedTrash,

  /// Low disconnected offsuit (gap ≥ 3, both ranks ≤ 9).
  junkOffsuit,

  /// Other suited non-pairs.
  suitedNonPair,

  /// Other offsuit non-pairs.
  offsuitNonPair,
}

/// Classifies two hole codes into a [LessonStartingHandFamily].
LessonStartingHandFamily startingHandFamilyFromCodes(List<String> hero) {
  if (hero.length < 2) return LessonStartingHandFamily.offsuitNonPair;
  final a = CardModel.fromCode(hero[0]);
  final b = CardModel.fromCode(hero[1]);
  final high = a.rank >= b.rank ? a : b;
  final low = a.rank >= b.rank ? b : a;
  final suited = a.suit == b.suit;
  final gap = high.rank - low.rank;

  if (a.rank == b.rank) {
    if (a.rank >= 12) return LessonStartingHandFamily.premiumPair;
    if (a.rank >= 7) return LessonStartingHandFamily.mediumPair;
    return LessonStartingHandFamily.smallPair;
  }

  final bothBroadway = high.rank >= 10 && low.rank >= 10;
  if (bothBroadway) {
    return suited
        ? LessonStartingHandFamily.suitedBroadway
        : LessonStartingHandFamily.offsuitBroadway;
  }

  if (high.rank == 14) {
    if (suited) return LessonStartingHandFamily.suitedAce;
    return LessonStartingHandFamily.weakAceOffsuit;
  }

  if (gap == 1) {
    return suited
        ? LessonStartingHandFamily.suitedConnector
        : LessonStartingHandFamily.offsuitConnector;
  }

  if (suited) {
    if (high.rank <= 9) return LessonStartingHandFamily.suitedTrash;
    return LessonStartingHandFamily.suitedNonPair;
  }

  if (high.rank <= 9 && gap >= 3) {
    return LessonStartingHandFamily.junkOffsuit;
  }
  return LessonStartingHandFamily.offsuitNonPair;
}

/// Deals two hole cards in [family], avoiding [used] codes.
List<String> dealStartingHandFamily(
  LessonStartingHandFamily family,
  Random rng, {
  Set<String>? used,
}) {
  final blocked = used ?? <String>{};
  for (var attempt = 0; attempt < 80; attempt++) {
    final codes = switch (family) {
      LessonStartingHandFamily.premiumPair =>
        _dealPocketPairInRange(rng, minRank: 12, maxRank: 14),
      LessonStartingHandFamily.mediumPair =>
        _dealPocketPairInRange(rng, minRank: 7, maxRank: 11),
      LessonStartingHandFamily.smallPair =>
        _dealPocketPairInRange(rng, minRank: 2, maxRank: 6),
      LessonStartingHandFamily.suitedBroadway => _dealBroadway(rng, suited: true),
      LessonStartingHandFamily.offsuitBroadway =>
        _dealBroadway(rng, suited: false),
      LessonStartingHandFamily.suitedAce => _dealSuitedAceNonBroadway(rng),
      LessonStartingHandFamily.weakAceOffsuit =>
        _dealAceOffsuit(rng: rng, minKicker: 2, maxKicker: 9),
      LessonStartingHandFamily.suitedConnector =>
        _dealConnector(rng, suited: true),
      LessonStartingHandFamily.offsuitConnector =>
        _dealConnector(rng, suited: false),
      LessonStartingHandFamily.suitedTrash => _dealSuitedTrash(rng),
      LessonStartingHandFamily.junkOffsuit => _dealOffsuitTrash(rng),
      LessonStartingHandFamily.suitedNonPair => _dealSuitedNonPair(rng),
      LessonStartingHandFamily.offsuitNonPair => _dealOffsuitNonPair(rng),
    };
    if (codes.any(blocked.contains)) continue;
    if (startingHandFamilyFromCodes(codes) != family) continue;
    blocked.addAll(codes);
    return List<String>.unmodifiable(codes);
  }
  // Last resort: attribute deal that is closest, then accept.
  final fallbackKind = switch (family) {
    LessonStartingHandFamily.premiumPair ||
    LessonStartingHandFamily.mediumPair ||
    LessonStartingHandFamily.smallPair =>
      LessonHoleKind.pocketPair,
    LessonStartingHandFamily.suitedBroadway ||
    LessonStartingHandFamily.suitedAce ||
    LessonStartingHandFamily.suitedConnector ||
    LessonStartingHandFamily.suitedTrash ||
    LessonStartingHandFamily.suitedNonPair =>
      LessonHoleKind.suitedNonPair,
    LessonStartingHandFamily.offsuitBroadway => LessonHoleKind.broadway,
    LessonStartingHandFamily.junkOffsuit => LessonHoleKind.offsuitTrash,
    _ => LessonHoleKind.offsuitNonPair,
  };
  return dealHoleHand(fallbackKind, rng, used: blocked);
}

/// Hand-class isomorphic remap of hero / board / optional villain groups.
///
/// Preflop (board length &lt; 3): re-deal hero inside its starting-hand family,
/// then apply one shared suit permutation to every group.
///
/// Postflop: suit-permute board (and villains), then resample hero holes until
/// [HandClassifier] matches the authored class (capped retries → suit-only).
///
/// When [suitOnly] is true (multi-step / toy runouts), only suits change.
///
/// When any non-hero group holds cards (villain holes, best-five choice sets,
/// outs tiles), uses a structure-preserving rank shift + suit perm so kickers
/// and relative strength stay coherent with coach copy.
List<List<String>> isomorphicLessonCardGroups(
  List<List<String>> groups,
  Random rng, {
  bool suitOnly = false,
  bool coordinated = false,
}) {
  if (groups.isEmpty) return const [];
  if (!lessonSuitRemapEnabled) {
    return [for (final g in groups) List<String>.of(g)];
  }
  if (suitOnly) {
    return permuteCardSuitGroups(groups, rng);
  }

  final hero = groups[0];
  final board = groups.length > 1 ? groups[1] : const <String>[];
  final rest = groups.length > 2 ? groups.sublist(2) : const <List<String>>[];
  final hasSideCards = rest.any((g) => g.isNotEmpty);

  if (hero.length < 2) {
    return permuteCardSuitGroups(groups, rng);
  }

  // Multi-hand / choice-set spots: keep relative ranks (Q kicker > J kicker).
  if (coordinated || hasSideCards) {
    return structurePreservingLessonCardGroups(groups, rng) ??
        permuteCardSuitGroups(groups, rng);
  }

  if (board.length < 3) {
    return _isomorphicPreflopGroups(groups, rng);
  }
  return _isomorphicPostflopGroups(
    hero: hero,
    board: board,
    rest: rest,
    rng: rng,
  );
}

/// Order-preserving remap: shift every rank by one offset and permute suits.
///
/// Returns null when the rank span cannot shift into 2–A without collision.
List<List<String>>? structurePreservingLessonCardGroups(
  List<List<String>> groups,
  Random rng,
) {
  final all = [for (final g in groups) for (final c in g) c];
  if (all.isEmpty) {
    return [for (final g in groups) List<String>.of(g)];
  }
  final ranks = <int>{
    for (final code in all) CardModel.fromCode(code).rank,
  }.toList()
    ..sort();
  final minR = ranks.first;
  final maxR = ranks.last;
  final span = maxR - minR;
  if (span > 12) return null;
  final maxStart = 14 - span;
  final newStart = rng.nextInt(maxStart - 1) + 2;
  final delta = newStart - minR;
  final rankMap = {for (final r in ranks) r: r + delta};
  if (rankMap.values.any((r) => r < 2 || r > 14)) return null;

  final suitMap = _freshSuitMap(rng);
  List<String> mapCodes(List<String> codes) => [
        for (final code in codes)
          _code(
            rankMap[CardModel.fromCode(code).rank]!,
            suitMap[CardModel.fromCode(code).suit.code]!,
          ),
      ];

  final mapped = [for (final g in groups) mapCodes(g)];
  if (!_groupsHaveUniqueCards(mapped)) return null;
  return [
    for (final g in mapped) List<String>.unmodifiable(g),
  ];
}

/// Applies the same structure-preserving maps used for [template] groups onto
/// extra code lists (choice sets, playing sets, outs tiles).
List<String> structurePreserveCodesLike({
  required List<String> codes,
  required List<List<String>> templateGroups,
  required List<List<String>> mappedGroups,
}) {
  if (codes.isEmpty) return const [];
  final rankMap = <int, int>{};
  final suitMap = <String, String>{};
  for (var gi = 0; gi < templateGroups.length; gi++) {
    final before = templateGroups[gi];
    final after = mappedGroups[gi];
    for (var i = 0; i < before.length && i < after.length; i++) {
      final b = CardModel.fromCode(before[i]);
      final a = CardModel.fromCode(after[i]);
      rankMap[b.rank] = a.rank;
      suitMap[b.suit.code] = a.suit.code;
    }
  }
  return [
    for (final code in codes)
      _code(
        rankMap[CardModel.fromCode(code).rank] ?? CardModel.fromCode(code).rank,
        suitMap[CardModel.fromCode(code).suit.code] ??
            CardModel.fromCode(code).suit.code,
      ),
  ];
}

List<List<String>> _isomorphicPreflopGroups(
  List<List<String>> groups,
  Random rng,
) {
  final hero = groups[0];
  final family = startingHandFamilyFromCodes(hero);
  final blocked = <String>{
    for (final g in groups.skip(1))
      for (final code in g) code,
  };

  for (var attempt = 0; attempt < 48; attempt++) {
    final used = Set<String>.of(blocked);
    final newHero = dealStartingHandFamily(family, rng, used: used);
    final candidate = [newHero, ...groups.skip(1)];
    final remapped = permuteCardSuitGroups(candidate, rng);
    if (_groupsHaveUniqueCards(remapped)) {
      return [
        for (final g in remapped) List<String>.unmodifiable(g),
      ];
    }
  }
  return permuteCardSuitGroups(groups, rng);
}

List<List<String>> _isomorphicPostflopGroups({
  required List<String> hero,
  required List<String> board,
  required List<List<String>> rest,
  required Random rng,
}) {
  // Face-up villains encode relative showdown outcomes (kickers, chops, etc.).
  // Re-dealing hero ranks to "same HandClass" can invent a weaker/stronger
  // hole while feedback still names the authored kicker — suit-permute only.
  if (rest.any((g) => g.isNotEmpty)) {
    return permuteCardSuitGroups([hero, board, ...rest], rng);
  }

  final suitMap = _freshSuitMap(rng);
  final mappedBoard = [
    for (final code in board) _applySuitMap(code, suitMap),
  ];
  final mappedRest = [
    for (final g in rest)
      [for (final code in g) _applySuitMap(code, suitMap)],
  ];
  final targetClass = _handClassFor(hero, board);
  final targetOuts = _drawOutsFor(hero, board);
  final used = <String>{
    ...mappedBoard,
    for (final g in mappedRest)
      for (final code in g) code,
  };

  for (var attempt = 0; attempt < 120; attempt++) {
    final candidate = _dealRandomHoleAvoiding(rng, used);
    if (candidate == null) break;
    if (_handClassFor(candidate, mappedBoard) != targetClass) continue;
    // Keep flush-draw vs straight-draw vs combo distinct for teach spots.
    if (_drawOutsFor(candidate, mappedBoard) != targetOuts) continue;
    return [
      List<String>.unmodifiable(candidate),
      List<String>.unmodifiable(mappedBoard),
      for (final g in mappedRest) List<String>.unmodifiable(g),
    ];
  }

  final mappedHero = [
    for (final code in hero) _applySuitMap(code, suitMap),
  ];
  return [
    List<String>.unmodifiable(mappedHero),
    List<String>.unmodifiable(mappedBoard),
    for (final g in mappedRest) List<String>.unmodifiable(g),
  ];
}

HandClass _handClassFor(List<String> hero, List<String> board) {
  final encoded = _encodeHeroBoard(hero, board);
  return HandClassifier.classify(encoded.a, encoded.b, encoded.board);
}

int _drawOutsFor(List<String> hero, List<String> board) {
  final encoded = _encodeHeroBoard(hero, board);
  return HandClassifier.drawOuts(encoded.a, encoded.b, encoded.board);
}

({int a, int b, List<int> board}) _encodeHeroBoard(
  List<String> hero,
  List<String> board,
) {
  return (
    a: FastEvaluator.encode(CardModel.fromCode(hero[0])),
    b: FastEvaluator.encode(CardModel.fromCode(hero[1])),
    board: [
      for (final code in board) FastEvaluator.encode(CardModel.fromCode(code)),
    ],
  );
}

List<String>? _dealRandomHoleAvoiding(Random rng, Set<String> used) {
  final deck = <String>[
    for (final rank in PokerConstants.rankLabels.keys)
      for (final suit in _suits)
        if (!used.contains('${PokerConstants.rankLabels[rank]}$suit'))
          '${PokerConstants.rankLabels[rank]}$suit',
  ];
  if (deck.length < 2) return null;
  final i = rng.nextInt(deck.length);
  var j = rng.nextInt(deck.length);
  while (j == i) {
    j = rng.nextInt(deck.length);
  }
  final a = CardModel.fromCode(deck[i]);
  final b = CardModel.fromCode(deck[j]);
  if (a.rank >= b.rank) return [deck[i], deck[j]];
  return [deck[j], deck[i]];
}

bool _groupsHaveUniqueCards(List<List<String>> groups) {
  final all = [for (final g in groups) for (final c in g) c];
  return all.toSet().length == all.length;
}

/// Seeded Fisher–Yates shuffle of [choices] for within-step presentation.
List<CourseChoice> shuffledLessonChoices(
  List<CourseChoice> choices, {
  String? activityId,
  int generation = 0,
  Random? random,
}) {
  if (choices.length <= 1) return List<CourseChoice>.of(choices);
  final rng = resolveLessonDealRandom(
    activityId: activityId == null ? null : '$activityId#choices',
    generation: generation,
    random: random,
  );
  final out = List<CourseChoice>.of(choices);
  for (var i = out.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = out[i];
    out[i] = out[j];
    out[j] = tmp;
  }
  return out;
}

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

/// Suit board for Suits and ranks, optionally with a middle star distractor.
List<String> dealSuitLessonBoard({
  required bool withStarDistractor,
  Random? random,
}) {
  final rng = random ?? debugLessonCardDealRandom ?? Random();
  final real = List<String>.of(dealOneOfEachSuitBoard(random: rng));
  if (!withStarDistractor) {
    return List<String>.unmodifiable(real);
  }
  final usedRanks = {
    for (final code in real) code.substring(0, code.length - 1),
  };
  const rankLabels = [
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'T',
    'J',
    'Q',
    'K',
    'A',
  ];
  final free = [for (final r in rankLabels) if (!usedRanks.contains(r)) r];
  final starRank = free.isEmpty ? '5' : free[rng.nextInt(free.length)];
  real.insert(real.length ~/ 2, '$starRank*');
  return List<String>.unmodifiable(real);
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

List<String> _dealSuitedAceNonBroadway(Random rng) {
  final suit = _suits[rng.nextInt(_suits.length)];
  final kicker = rng.nextInt(8) + 2; // 2–9
  return [_code(14, suit), _code(kicker, suit)];
}

List<String> _dealAceOffsuit({
  required Random rng,
  required int minKicker,
  required int maxKicker,
}) {
  final span = maxKicker - minKicker + 1;
  final kicker = rng.nextInt(span) + minKicker;
  final suits = _twoDistinctSuits(rng);
  return [_code(14, suits[0]), _code(kicker, suits[1])];
}

List<String> _dealPocketPairInRange(
  Random rng, {
  required int minRank,
  required int maxRank,
}) {
  final span = maxRank - minRank + 1;
  final rank = rng.nextInt(span) + minRank;
  final suits = _twoDistinctSuits(rng);
  return [_code(rank, suits[0]), _code(rank, suits[1])];
}

List<String> _dealBroadway(Random rng, {bool suited = false}) {
  final ranks = _broadwayRanks.toList(growable: true)..shuffle(rng);
  final r0 = ranks[0];
  final r1 = ranks[1];
  if (suited) {
    final suit = _suits[rng.nextInt(_suits.length)];
    return [_code(r0, suit), _code(r1, suit)];
  }
  final suits = _twoDistinctSuits(rng);
  return [_code(r0, suits[0]), _code(r1, suits[1])];
}

List<String> _dealConnector(Random rng, {required bool suited}) {
  // Low of the connector: 2–Q so high stays ≤ A.
  // Prefer non-broadway connectors so family classify stays connector.
  final low = rng.nextInt(8) + 2; // 2–9 → high 3–T
  final high = low + 1;
  if (suited) {
    final suit = _suits[rng.nextInt(_suits.length)];
    return [_code(high, suit), _code(low, suit)];
  }
  final suits = _twoDistinctSuits(rng);
  return [_code(high, suits[0]), _code(low, suits[1])];
}

List<String> _dealSuitedTrash(Random rng) {
  for (var attempt = 0; attempt < 32; attempt++) {
    final a = rng.nextInt(8) + 2; // 2–9
    final b = rng.nextInt(8) + 2;
    if (a == b) continue;
    if ((a - b).abs() < 2) continue; // not connector
    final suit = _suits[rng.nextInt(_suits.length)];
    final high = a >= b ? a : b;
    final low = a >= b ? b : a;
    return [_code(high, suit), _code(low, suit)];
  }
  return const ['8h', '2h'];
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

/// Cards for a Hand ranks showdown-order step (seat strength order preserved).
@immutable
class ShowdownOrderDeal {
  /// Creates a dealt showdown layout.
  const ShowdownOrderDeal({
    required this.boardCodes,
    required this.heroCodes,
    required this.villainHoleCodes,
    required this.seatIds,
    required this.correctOrder,
  });

  final List<String> boardCodes;
  final List<String> heroCodes;
  final List<List<String>> villainHoleCodes;
  final List<String> seatIds;
  final List<String> correctOrder;
}

/// Randomized Hand ranks showdown layout for [activityId], or null if unknown.
///
/// Role ids stay authored (`you` / `sam` / `jo` = strength tiers) and
/// [correctOrder] is unchanged for server grading. Card faces vary, and which
/// physical seat holds each role is shuffled.
ShowdownOrderDeal? dealShowdownOrderCards(
  String activityId, {
  Random? random,
}) {
  final rng = random ?? debugLessonCardDealRandom ?? Random();
  final dealt = switch (activityId) {
    'act-01-02-01-explain-ladder' ||
    'act-01-02-01-guided-ladder' =>
      _dealHighPairFlushWeakToStrong(rng),
    'act-01-02-01-scaffolded-spot' => _dealPairStraightFlushWeakToStrong(rng),
    'act-01-02-01-unguided-compare' => _dealFullTripsTwoPairStrongToWeak(rng),
    'act-01-02-01-checkpoint-winner' => _dealFlushStraightHighStrongToWeak(rng),
    _ => null,
  };
  if (dealt == null) return null;
  return _shuffleShowdownSeatRoles(dealt, rng);
}

/// Shuffles which seat (You/Sam/Jo) holds each strength role.
ShowdownOrderDeal _shuffleShowdownSeatRoles(
  ShowdownOrderDeal deal,
  Random rng,
) {
  final hands = <List<String>>[
    deal.heroCodes,
    deal.villainHoleCodes[0],
    deal.villainHoleCodes[1],
  ];
  final roles = List<String>.of(deal.seatIds);
  final order = [0, 1, 2]..shuffle(rng);
  return ShowdownOrderDeal(
    boardCodes: deal.boardCodes,
    heroCodes: List<String>.unmodifiable(hands[order[0]]),
    villainHoleCodes: List<List<String>>.unmodifiable([
      List<String>.unmodifiable(hands[order[1]]),
      List<String>.unmodifiable(hands[order[2]]),
    ]),
    seatIds: List<String>.unmodifiable([
      roles[order[0]],
      roles[order[1]],
      roles[order[2]],
    ]),
    correctOrder: deal.correctOrder,
  );
}

ShowdownOrderDeal _dealFullTripsTwoPairStrongToWeak(Random rng) {
  for (var attempt = 0; attempt < 80; attempt++) {
    final ranks = List<int>.generate(13, (i) => i + 2)..shuffle(rng);
    final trip = ranks[0];
    final pair = ranks[1];
    final k1 = ranks[2];
    final k2 = ranks[3];
    final k3 = ranks[4];
    final suits = List<String>.of(_suits)..shuffle(rng);
    final board = [
      _code(trip, suits[0]),
      _code(trip, suits[1]),
      _code(pair, suits[2]),
      _code(k1, suits[3]),
      _code(k2, suits[0]),
    ];
    final hero = [_code(trip, suits[2]), _code(pair, suits[1])];
    final sam = [_code(trip, suits[3]), _code(k3, suits[0])];
    final jo = [_code(pair, suits[0]), _code(k1, suits[1])];
    if (!_uniqueCards([...board, ...hero, ...sam, ...jo])) continue;
    if (!_namesMatch(
      board: board,
      hero: hero,
      sam: sam,
      jo: jo,
      expected: const ['Full House', 'Three of a Kind', 'Two Pair'],
    )) {
      continue;
    }
    return ShowdownOrderDeal(
      boardCodes: List<String>.unmodifiable(board),
      heroCodes: List<String>.unmodifiable(hero),
      villainHoleCodes: List<List<String>>.unmodifiable([
        List<String>.unmodifiable(sam),
        List<String>.unmodifiable(jo),
      ]),
      seatIds: const ['you', 'sam', 'jo'],
      correctOrder: const ['you', 'sam', 'jo'],
    );
  }
  return const ShowdownOrderDeal(
    boardCodes: ['Qh', 'Qd', '9c', '4s', '2d'],
    heroCodes: ['Qs', '9h'],
    villainHoleCodes: [
      ['Qc', 'Jh'],
      ['9d', '4h'],
    ],
    seatIds: ['you', 'sam', 'jo'],
    correctOrder: ['you', 'sam', 'jo'],
  );
}

ShowdownOrderDeal _dealFlushStraightHighStrongToWeak(Random rng) {
  // Structure-preserving remap of the authored template so straights survive.
  const templateBoard = ['9c', '8h', '7d', '4c', '2c'];
  const templateHero = ['Ac', 'Kc'];
  const templateSam = ['6s', '5h'];
  const templateJo = ['Ah', 'Kd'];
  for (var attempt = 0; attempt < 40; attempt++) {
    final remapped = _remapSpotCards(
      board: templateBoard,
      hero: templateHero,
      sam: templateSam,
      jo: templateJo,
      rng: rng,
      preserveStraightGaps: true,
    );
    if (remapped == null) continue;
    if (!_namesMatch(
      board: remapped.board,
      hero: remapped.hero,
      sam: remapped.sam,
      jo: remapped.jo,
      expected: const ['Flush', 'Straight', 'High Card'],
    )) {
      continue;
    }
    return ShowdownOrderDeal(
      boardCodes: List<String>.unmodifiable(remapped.board),
      heroCodes: List<String>.unmodifiable(remapped.hero),
      villainHoleCodes: List<List<String>>.unmodifiable([
        List<String>.unmodifiable(remapped.sam),
        List<String>.unmodifiable(remapped.jo),
      ]),
      seatIds: const ['you', 'sam', 'jo'],
      correctOrder: const ['you', 'sam', 'jo'],
    );
  }
  return const ShowdownOrderDeal(
    boardCodes: ['9c', '8h', '7d', '4c', '2c'],
    heroCodes: ['Ac', 'Kc'],
    villainHoleCodes: [
      ['6s', '5h'],
      ['Ah', 'Kd'],
    ],
    seatIds: ['you', 'sam', 'jo'],
    correctOrder: ['you', 'sam', 'jo'],
  );
}

ShowdownOrderDeal _dealHighPairFlushWeakToStrong(Random rng) {
  const templateBoard = ['9c', '7c', '3c', '2h', '5d'];
  const templateHero = ['Ah', 'Kd'];
  const templateSam = ['9h', '8s'];
  const templateJo = ['Ac', 'Kc'];
  for (var attempt = 0; attempt < 40; attempt++) {
    final remapped = _remapSpotCards(
      board: templateBoard,
      hero: templateHero,
      sam: templateSam,
      jo: templateJo,
      rng: rng,
      preserveStraightGaps: false,
    );
    if (remapped == null) continue;
    if (!_namesMatch(
      board: remapped.board,
      hero: remapped.hero,
      sam: remapped.sam,
      jo: remapped.jo,
      expected: const ['High Card', 'One Pair', 'Flush'],
    )) {
      continue;
    }
    return ShowdownOrderDeal(
      boardCodes: List<String>.unmodifiable(remapped.board),
      heroCodes: List<String>.unmodifiable(remapped.hero),
      villainHoleCodes: List<List<String>>.unmodifiable([
        List<String>.unmodifiable(remapped.sam),
        List<String>.unmodifiable(remapped.jo),
      ]),
      seatIds: const ['you', 'sam', 'jo'],
      correctOrder: const ['you', 'sam', 'jo'],
    );
  }
  return const ShowdownOrderDeal(
    boardCodes: ['9c', '7c', '3c', '2h', '5d'],
    heroCodes: ['Ah', 'Kd'],
    villainHoleCodes: [
      ['9h', '8s'],
      ['Ac', 'Kc'],
    ],
    seatIds: ['you', 'sam', 'jo'],
    correctOrder: ['you', 'sam', 'jo'],
  );
}

ShowdownOrderDeal _dealPairStraightFlushWeakToStrong(Random rng) {
  const templateBoard = ['Tc', '8c', '6d', '5h', '2c'];
  const templateHero = ['Ah', 'Td'];
  const templateSam = ['9s', '7d'];
  const templateJo = ['Ac', 'Kc'];
  for (var attempt = 0; attempt < 40; attempt++) {
    final remapped = _remapSpotCards(
      board: templateBoard,
      hero: templateHero,
      sam: templateSam,
      jo: templateJo,
      rng: rng,
      preserveStraightGaps: true,
    );
    if (remapped == null) continue;
    if (!_namesMatch(
      board: remapped.board,
      hero: remapped.hero,
      sam: remapped.sam,
      jo: remapped.jo,
      expected: const ['One Pair', 'Straight', 'Flush'],
    )) {
      continue;
    }
    return ShowdownOrderDeal(
      boardCodes: List<String>.unmodifiable(remapped.board),
      heroCodes: List<String>.unmodifiable(remapped.hero),
      villainHoleCodes: List<List<String>>.unmodifiable([
        List<String>.unmodifiable(remapped.sam),
        List<String>.unmodifiable(remapped.jo),
      ]),
      seatIds: const ['you', 'sam', 'jo'],
      correctOrder: const ['you', 'sam', 'jo'],
    );
  }
  return const ShowdownOrderDeal(
    boardCodes: ['Tc', '8c', '6d', '5h', '2c'],
    heroCodes: ['Ah', 'Td'],
    villainHoleCodes: [
      ['9s', '7d'],
      ['Ac', 'Kc'],
    ],
    seatIds: ['you', 'sam', 'jo'],
    correctOrder: ['you', 'sam', 'jo'],
  );
}

({
  List<String> board,
  List<String> hero,
  List<String> sam,
  List<String> jo,
})? _remapSpotCards({
  required List<String> board,
  required List<String> hero,
  required List<String> sam,
  required List<String> jo,
  required Random rng,
  required bool preserveStraightGaps,
}) {
  final all = [...board, ...hero, ...sam, ...jo];
  final ranks = <int>{
    for (final code in all) CardModel.fromCode(code).rank,
  }.toList()
    ..sort();
  final suitPerm = List<String>.of(_suits)..shuffle(rng);
  final suitMap = <String, String>{
    for (var i = 0; i < _suits.length; i++) _suits[i]: suitPerm[i],
  };

  late final Map<int, int> rankMap;
  if (preserveStraightGaps) {
    // Shift the whole rank set by a random offset while keeping relative gaps.
    final minR = ranks.first;
    final maxR = ranks.last;
    final span = maxR - minR;
    if (span > 12) return null;
    final maxStart = 14 - span;
    final newStart = rng.nextInt(maxStart - 1) + 2; // 2..(maxStart)
    final delta = newStart - minR;
    rankMap = {for (final r in ranks) r: r + delta};
    if (rankMap.values.any((r) => r < 2 || r > 14)) return null;
  } else {
    final targets = List<int>.generate(13, (i) => i + 2)..shuffle(rng);
    rankMap = {
      for (var i = 0; i < ranks.length; i++) ranks[i]: targets[i],
    };
  }

  List<String> mapCodes(List<String> codes) => [
        for (final code in codes)
          _code(
            rankMap[CardModel.fromCode(code).rank]!,
            suitMap[CardModel.fromCode(code).suit.code]!,
          ),
      ];

  final mappedBoard = mapCodes(board);
  final mappedHero = mapCodes(hero);
  final mappedSam = mapCodes(sam);
  final mappedJo = mapCodes(jo);
  if (!_uniqueCards([...mappedBoard, ...mappedHero, ...mappedSam, ...mappedJo])) {
    return null;
  }
  return (
    board: mappedBoard,
    hero: mappedHero,
    sam: mappedSam,
    jo: mappedJo,
  );
}

bool _uniqueCards(List<String> codes) => codes.toSet().length == codes.length;

bool _namesMatch({
  required List<String> board,
  required List<String> hero,
  required List<String> sam,
  required List<String> jo,
  required List<String> expected,
}) {
  String name(List<String> holes) {
    final cards = [
      for (final code in [...holes, ...board]) CardModel.fromCode(code),
    ];
    return DeckEvaluator.evaluate7Cards(cards).rankName;
  }

  return name(hero) == expected[0] &&
      name(sam) == expected[1] &&
      name(jo) == expected[2];
}

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
