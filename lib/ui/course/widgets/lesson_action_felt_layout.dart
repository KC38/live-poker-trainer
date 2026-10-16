/// Six-max and nine-max seating for poker-action teaching spots.
///
/// Action docks default to six-max so "folds to you" is visible. Spots whose
/// street label names `9-max` (full-ring / nine-handed lessons) resolve nine
/// seats. Only spots authored as heads-up keep the two-seat layout.
library;

import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';

/// Clockwise offsets from the dealer button on a six-max ring.
const Map<String, int> _sixMaxOffsetFromButton = {
  'BTN': 0,
  'SB': 1,
  'BB': 2,
  'UTG': 3,
  'HJ': 4,
  'CO': 5,
};

/// Clockwise offsets from the dealer button on a nine-max ring.
const Map<String, int> _nineMaxOffsetFromButton = {
  'BTN': 0,
  'SB': 1,
  'BB': 2,
  'UTG': 3,
  'UTG+1': 4,
  'MP': 5,
  'MP+1': 6,
  'HJ': 7,
  'CO': 8,
};

/// Preflop act order on six-max (left of the big blind through the blinds).
const List<String> _sixMaxPreflopOrder = [
  'UTG',
  'HJ',
  'CO',
  'BTN',
  'SB',
  'BB',
];

/// Preflop act order on nine-max.
const List<String> _nineMaxPreflopOrder = [
  'UTG',
  'UTG+1',
  'MP',
  'MP+1',
  'HJ',
  'CO',
  'BTN',
  'SB',
  'BB',
];

/// Opponents on a nine-max teaching felt (`9 - 1`).
const int lessonNineMaxVillainCount = 8;

/// Felt seating + fold state for a [LessonActionSpot].
class LessonActionFeltLayout {
  /// Creates a resolved layout.
  const LessonActionFeltLayout({
    required this.villainCount,
    required this.seatCount,
    this.dealerIndex,
    this.sbIndex,
    this.bbIndex,
    this.activeSeatIndex = 0,
    this.foldedSeatIndexes = const <int>[],
    this.seatActionLabels = const <int, String>{},
    this.villainSeatIndex = 1,
    this.callerSeatIndexes = const <int>[],
    this.headsUp = false,
  });

  /// Opponents on the felt (`seatCount - 1`).
  final int villainCount;

  /// Total seats including the hero.
  final int seatCount;

  /// Dealer seat. Null leaves [LessonTableStage] defaults.
  final int? dealerIndex;

  /// Small-blind seat when set with [dealerIndex].
  final int? sbIndex;

  /// Big-blind seat when set with [dealerIndex].
  final int? bbIndex;

  /// Seat that glows as its turn.
  final int? activeSeatIndex;

  /// Seats already folded (dimmed, FOLD badge).
  final List<int> foldedSeatIndexes;

  /// Extra last-action badges (e.g. RAISE on the opener).
  final Map<int, String> seatActionLabels;

  /// Seat that holds a facing bet / open for felt money.
  final int villainSeatIndex;

  /// Seats that called the open before the hero acts (LPT-1021).
  final List<int> callerSeatIndexes;

  /// True when this spot is authored as heads-up.
  final bool headsUp;
}

/// Whether [spot] is authored as a heads-up lesson (keep two seats).
bool lessonActionSpotIsHeadsUp(LessonActionSpot spot) {
  for (final text in <String?>[
    spot.streetLabel,
    spot.villainLine,
    spot.feltStatusLine,
  ]) {
    if (text == null || text.isEmpty) continue;
    final lower = text.toLowerCase();
    if (lower.contains('heads-up') || lower.contains('heads up')) {
      return true;
    }
  }
  return false;
}

/// Whether [spot] is authored as nine-max / full-ring (nine seats).
bool lessonActionSpotIsNineMax(LessonActionSpot spot) {
  for (final text in <String?>[
    spot.streetLabel,
    spot.villainLine,
    spot.feltStatusLine,
  ]) {
    if (text == null || text.isEmpty) continue;
    final lower = text.toLowerCase();
    if (lower.contains('9-max') ||
        lower.contains('nine-max') ||
        lower.contains('nine-handed') ||
        lower.contains('nine handed')) {
      return true;
    }
  }
  return false;
}

/// Hero position token from [streetLabel], when present.
String? parseLessonActionHeroPosition(String? streetLabel) {
  if (streetLabel == null || streetLabel.isEmpty) return null;
  final lower = streetLabel.toLowerCase();
  if (lower.contains('hijack') || RegExp(r'\bhj\b').hasMatch(lower)) {
    return 'HJ';
  }
  if (lower.contains('cutoff') || RegExp(r'\bco\b').hasMatch(lower)) {
    return 'CO';
  }
  if (lower.contains('button') || RegExp(r'\bbtn\b').hasMatch(lower)) {
    return 'BTN';
  }
  if (lower.contains('small blind') || RegExp(r'\bsb\b').hasMatch(lower)) {
    return 'SB';
  }
  if (lower.contains('big blind') || RegExp(r'\bbb\b').hasMatch(lower)) {
    return 'BB';
  }
  if (lower.contains('utg') ||
      lower.contains('early position') ||
      RegExp(r'\bep\b').hasMatch(lower)) {
    return 'UTG';
  }
  return null;
}

/// Count of callers named in [villainLine] (`2 callers`, `two callers`,
/// `BB + MP call`).
///
/// Used so squeeze-style densify keeps those seats live with CALL badges
/// instead of folding everyone between the opener and the hero (LPT-1021).
/// Named callers (`BB + MP call`) are counted too (LPT-1024).
int? parseLessonCallerCount(String? villainLine) {
  if (villainLine == null || villainLine.isEmpty) return null;
  final lower = villainLine.toLowerCase();
  final digit = RegExp(r'(\d+)\s+callers?').firstMatch(lower);
  if (digit != null) return int.tryParse(digit.group(1)!);
  const words = <String, int>{
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
  };
  for (final entry in words.entries) {
    if (RegExp('${entry.key}\\s+callers?').hasMatch(lower)) {
      return entry.value;
    }
  }
  final named = parseLessonNamedCallerPositions(villainLine);
  if (named.isNotEmpty) return named.length;
  return null;
}

/// Position tokens named as callers in [villainLine] (`BB + MP call`).
///
/// Tighten-speculative densify authors callers by seat rather than
/// `N callers` between opener and hero (LPT-1024). Excludes the opener.
List<String> parseLessonNamedCallerPositions(String? villainLine) {
  if (villainLine == null || villainLine.isEmpty) return const <String>[];
  final lower = villainLine.toLowerCase();
  if (!RegExp(r'\bcalls?\b').hasMatch(lower)) return const <String>[];
  // Prefer the segment after `·` / `;` that contains "call".
  final segments = lower.split(RegExp(r'[·;|]'));
  final callSegment = segments.firstWhere(
    (s) => RegExp(r'\bcalls?\b').hasMatch(s),
    orElse: () => lower,
  );
  final opener = parseLessonActionVillainPosition(villainLine);
  const tokens = <String>[
    'utg+1',
    'mp+1',
    'utg',
    'mp',
    'hj',
    'co',
    'btn',
    'sb',
    'bb',
  ];
  final found = <String>[];
  for (final token in tokens) {
    if (!RegExp('\\b${RegExp.escape(token)}\\b').hasMatch(callSegment)) {
      continue;
    }
    final pos = token.toUpperCase();
    if (opener != null && pos == opener) continue;
    found.add(pos);
  }
  return List<String>.unmodifiable(found);
}

/// Opener / bettor position from [villainLine], when named.
String? parseLessonActionVillainPosition(String? villainLine) {
  if (villainLine == null || villainLine.isEmpty) return null;
  final lower = villainLine.toLowerCase();
  if (lower.contains('hijack') || RegExp(r'\bhj\b').hasMatch(lower)) {
    return 'HJ';
  }
  if (lower.contains('cutoff') || RegExp(r'\bco\b').hasMatch(lower)) {
    return 'CO';
  }
  if (lower.contains('button') || RegExp(r'\bbtn\b').hasMatch(lower)) {
    return 'BTN';
  }
  if (lower.contains('small blind') || RegExp(r'\bsb\b').hasMatch(lower)) {
    return 'SB';
  }
  if (lower.contains('big blind') || RegExp(r'\bbb\b').hasMatch(lower)) {
    return 'BB';
  }
  // Prefer UTG+1 before bare UTG so "UTG+1 opens" does not collapse to UTG.
  if (lower.contains('utg+1') || lower.contains('utg +1')) {
    return 'UTG+1';
  }
  if (lower.contains('mp+1') || lower.contains('mp +1')) {
    return 'MP+1';
  }
  if (RegExp(r'\bmp\b').hasMatch(lower)) {
    return 'MP';
  }
  if (lower.contains('utg') || RegExp(r'\bep\b').hasMatch(lower)) {
    return 'UTG';
  }
  return null;
}

/// Dealer seat so the hero (index 0) sits in [heroPosition] on six-max.
int lessonSixMaxDealerIndexForHero(String heroPosition) {
  final offset = _sixMaxOffsetFromButton[heroPosition];
  if (offset == null) return 0;
  // heroSeat = (dealer + offset) % 6 == 0 → dealer = (6 - offset) % 6
  return (6 - offset) % 6;
}

/// Maps nine-max-only labels onto six-max seats (MP → HJ, UTG+1 → UTG).
String lessonSixMaxPositionAlias(String position) {
  switch (position) {
    case 'MP':
    case 'MP+1':
      return 'HJ';
    case 'UTG+1':
      return 'UTG';
    default:
      return position;
  }
}

/// Seat index for [position] when [dealerIndex] is the button (six-max).
int lessonSixMaxSeatIndex({
  required String position,
  required int dealerIndex,
}) {
  final offset = _sixMaxOffsetFromButton[lessonSixMaxPositionAlias(position)];
  if (offset == null) return 0;
  return (dealerIndex + offset) % 6;
}

/// Seats that folded before [heroPosition] on an open pot (six-max).
List<int> lessonSixMaxOpenFoldIndexes({
  required String heroPosition,
  required int dealerIndex,
}) {
  final heroOrder = _sixMaxPreflopOrder.indexOf(heroPosition);
  if (heroOrder <= 0) return const <int>[];
  return [
    for (var i = 0; i < heroOrder; i++)
      lessonSixMaxSeatIndex(
        position: _sixMaxPreflopOrder[i],
        dealerIndex: dealerIndex,
      ),
  ];
}

/// Seats that folded after [openerPosition] before the hero acts (six-max).
List<int> lessonSixMaxFoldsBetween({
  required String openerPosition,
  required String heroPosition,
  required int dealerIndex,
}) {
  final start = _sixMaxPreflopOrder.indexOf(openerPosition);
  final end = _sixMaxPreflopOrder.indexOf(heroPosition);
  if (start < 0 || end < 0 || end <= start + 1) return const <int>[];
  return [
    for (var i = start + 1; i < end; i++)
      lessonSixMaxSeatIndex(
        position: _sixMaxPreflopOrder[i],
        dealerIndex: dealerIndex,
      ),
  ];
}

/// Dealer seat so the hero (index 0) sits in [heroPosition] on nine-max.
int lessonNineMaxDealerIndexForHero(String heroPosition) {
  final offset = _nineMaxOffsetFromButton[heroPosition];
  if (offset == null) return 0;
  return (9 - offset) % 9;
}

/// Seat index for [position] when [dealerIndex] is the button (nine-max).
int lessonNineMaxSeatIndex({
  required String position,
  required int dealerIndex,
}) {
  final offset = _nineMaxOffsetFromButton[position];
  if (offset == null) return 0;
  return (dealerIndex + offset) % 9;
}

/// Seats that folded before [heroPosition] on an open pot (nine-max).
List<int> lessonNineMaxOpenFoldIndexes({
  required String heroPosition,
  required int dealerIndex,
}) {
  final heroOrder = _nineMaxPreflopOrder.indexOf(heroPosition);
  if (heroOrder <= 0) return const <int>[];
  return [
    for (var i = 0; i < heroOrder; i++)
      lessonNineMaxSeatIndex(
        position: _nineMaxPreflopOrder[i],
        dealerIndex: dealerIndex,
      ),
  ];
}

/// Seats that folded after [openerPosition] before the hero acts (nine-max).
List<int> lessonNineMaxFoldsBetween({
  required String openerPosition,
  required String heroPosition,
  required int dealerIndex,
}) {
  final start = _nineMaxPreflopOrder.indexOf(openerPosition);
  final end = _nineMaxPreflopOrder.indexOf(heroPosition);
  if (start < 0 || end < 0 || end <= start + 1) return const <int>[];
  return [
    for (var i = start + 1; i < end; i++)
      lessonNineMaxSeatIndex(
        position: _nineMaxPreflopOrder[i],
        dealerIndex: dealerIndex,
      ),
  ];
}

String _raiseOrBetLabel(String? villainLine) {
  final lower = villainLine?.toLowerCase() ?? '';
  if (lower.contains('open') ||
      lower.contains('raise') ||
      lower.contains('3-bet')) {
    return 'RAISE';
  }
  return 'BET';
}

LessonActionFeltLayout _resolveRingLayout({
  required LessonActionSpot spot,
  required bool nineMax,
  required String heroPos,
  required bool preflop,
}) {
  final seatCount = nineMax ? 9 : 6;
  final villainCount =
      nineMax ? lessonNineMaxVillainCount : lessonBlindsVillainCount;
  final dealer =
      nineMax
          ? lessonNineMaxDealerIndexForHero(heroPos)
          : lessonSixMaxDealerIndexForHero(heroPos);
  final sb =
      nineMax
          ? lessonNineMaxSeatIndex(position: 'SB', dealerIndex: dealer)
          : lessonSixMaxSeatIndex(position: 'SB', dealerIndex: dealer);
  final bb =
      nineMax
          ? lessonNineMaxSeatIndex(position: 'BB', dealerIndex: dealer)
          : lessonSixMaxSeatIndex(position: 'BB', dealerIndex: dealer);

  if (preflop) {
    if (spot.openPot || _foldsToYou(spot.villainLine)) {
      final folded =
          nineMax
              ? lessonNineMaxOpenFoldIndexes(
                heroPosition: heroPos,
                dealerIndex: dealer,
              )
              : lessonSixMaxOpenFoldIndexes(
                heroPosition: heroPos,
                dealerIndex: dealer,
              );
      return LessonActionFeltLayout(
        villainCount: villainCount,
        seatCount: seatCount,
        dealerIndex: dealer,
        sbIndex: sb,
        bbIndex: bb,
        activeSeatIndex: 0,
        foldedSeatIndexes: folded,
        villainSeatIndex: bb == 0 ? sb : bb,
      );
    }

    if (spot.facingBet) {
      final opener =
          parseLessonActionVillainPosition(spot.villainLine) ?? 'UTG';
      final openerSeat =
          nineMax
              ? lessonNineMaxSeatIndex(position: opener, dealerIndex: dealer)
              : lessonSixMaxSeatIndex(position: opener, dealerIndex: dealer);
      final between =
          nineMax
              ? lessonNineMaxFoldsBetween(
                openerPosition: opener,
                heroPosition: heroPos,
                dealerIndex: dealer,
              )
              : lessonSixMaxFoldsBetween(
                openerPosition: opener,
                heroPosition: heroPos,
                dealerIndex: dealer,
              );
      // "UTG opens · 2 callers" — keep the first N seats after the opener as
      // live CALL seats; fold the rest (BTN/SB) so dead money stays (LPT-1021).
      // "BTN open · BB + MP call" — named callers are not between BTN and SB
      // (BB acts after SB); resolve those seats and fold everyone else
      // (LPT-1024).
      final namedCallerPositions = parseLessonNamedCallerPositions(
        spot.villainLine,
      );
      final List<int> callers;
      final List<int> folded;
      if (namedCallerPositions.isNotEmpty) {
        final namedSeats = <int>[
          for (final pos in namedCallerPositions)
            nineMax
                ? lessonNineMaxSeatIndex(position: pos, dealerIndex: dealer)
                : lessonSixMaxSeatIndex(position: pos, dealerIndex: dealer),
        ];
        callers = [
          for (final seat in namedSeats)
            if (seat != 0 && seat != openerSeat) seat,
        ];
        final live = <int>{0, openerSeat, ...callers};
        folded = [
          for (var i = 1; i < seatCount; i++)
            if (!live.contains(i)) i,
        ];
      } else {
        final callerCount = parseLessonCallerCount(spot.villainLine) ?? 0;
        callers =
            callerCount <= 0
                ? const <int>[]
                : between.take(callerCount).toList(growable: false);
        folded =
            callerCount <= 0
                ? between
                : between.skip(callerCount).toList(growable: false);
      }
      final labels = <int, String>{
        openerSeat: _raiseOrBetLabel(spot.villainLine),
        for (final seat in callers) seat: 'CALL',
      };
      return LessonActionFeltLayout(
        villainCount: villainCount,
        seatCount: seatCount,
        dealerIndex: dealer,
        sbIndex: sb,
        bbIndex: bb,
        activeSeatIndex: 0,
        foldedSeatIndexes: folded,
        seatActionLabels: labels,
        villainSeatIndex: openerSeat,
        callerSeatIndexes: callers,
      );
    }

    // Preflop without a named open/facing line — ring, hero to act.
    return LessonActionFeltLayout(
      villainCount: villainCount,
      seatCount: seatCount,
      dealerIndex: dealer,
      sbIndex: sb,
      bbIndex: bb,
      activeSeatIndex: 0,
      villainSeatIndex: bb == 0 ? sb : bb,
    );
  }

  // Postflop: ring with one villain still in (unless heads-up above).
  final villainPos =
      parseLessonActionVillainPosition(spot.villainLine) ?? 'BB';
  final villainSeat =
      nineMax
          ? lessonNineMaxSeatIndex(position: villainPos, dealerIndex: dealer)
          : lessonSixMaxSeatIndex(position: villainPos, dealerIndex: dealer);
  final folded = [
    for (var i = 1; i < seatCount; i++)
      if (i != villainSeat) i,
  ];
  return LessonActionFeltLayout(
    villainCount: villainCount,
    seatCount: seatCount,
    dealerIndex: dealer,
    sbIndex: sb,
    bbIndex: bb,
    activeSeatIndex: 0,
    foldedSeatIndexes: folded,
    villainSeatIndex: villainSeat,
  );
}

/// Resolves six-max, nine-max, or heads-up seating for an action teaching
/// [spot].
LessonActionFeltLayout resolveLessonActionFeltLayout(LessonActionSpot spot) {
  if (lessonActionSpotIsHeadsUp(spot)) {
    return const LessonActionFeltLayout(
      villainCount: 1,
      seatCount: 2,
      villainSeatIndex: 1,
      headsUp: true,
      activeSeatIndex: 0,
    );
  }

  final preflop = spot.boardCodes.isEmpty;
  final heroPos =
      parseLessonActionHeroPosition(spot.streetLabel) ??
      (preflop ? 'BTN' : 'BTN');
  return _resolveRingLayout(
    spot: spot,
    nineMax: lessonActionSpotIsNineMax(spot),
    heroPos: heroPos,
    preflop: preflop,
  );
}

bool _foldsToYou(String? villainLine) {
  if (villainLine == null || villainLine.isEmpty) return false;
  final lower = villainLine.toLowerCase();
  return lower.contains('folds to you') || lower.contains('fold to you');
}
