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
/// `BB + MP call`, `4-way`).
///
/// Used so squeeze-style densify keeps those seats live with CALL badges
/// instead of folding everyone between the opener and the hero (LPT-1021).
/// Named callers (`BB + MP call`) are counted too (LPT-1024). Postflop
/// densify that only says `Three callers` / `4-way` uses the same count so
/// the ring keeps that many villains live instead of folding to one seat
/// (LPT-1025).
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
  // "Checked to you · 4-way" → three other live seats (players − hero).
  final way = RegExp(r'(\d+)\s*-?\s*way\b').firstMatch(lower);
  if (way != null) {
    final players = int.tryParse(way.group(1)!);
    if (players != null && players >= 2) return players - 1;
  }
  // "Four-way · bet into you" (word form) — same as digit 4-way (LPT-1025 class).
  const wayWords = <String, int>{
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
  };
  for (final entry in wayWords.entries) {
    if (RegExp('${entry.key}-?way\\b').hasMatch(lower)) {
      return entry.value - 1;
    }
  }
  // "two behind" / "Two players behind" / "Called by two" — capstone
  // multiway lines that are not "N callers" or "N-way" (LPT-1025 class).
  int? countToken(String raw) {
    final parsed = int.tryParse(raw);
    if (parsed != null) return parsed;
    return words[raw];
  }

  final behind = RegExp(
    r'\b(\d+|one|two|three|four|five)\s+(?:players?\s+)?behind\b',
  ).firstMatch(lower);
  if (behind != null) {
    final n = countToken(behind.group(1)!);
    if (n != null && n > 0) return n;
  }
  final calledBy = RegExp(
    r'\bcalled by\s+(\d+|one|two|three|four|five)\b',
  ).firstMatch(lower);
  if (calledBy != null) {
    final n = countToken(calledBy.group(1)!);
    if (n != null && n > 0) return n;
  }
  // Soft fallbacks run last so "Three callers · multiway" and
  // "4-way sticky caller" keep the explicit count. "sticky seat" is
  // not a caller — the missed-draw river stays the one-villain ring.
  // "Sticky caller · checked to you" — one live villain (not heads-up fold).
  if (RegExp(r'\bsticky\s+callers?\b').hasMatch(lower)) return 1;
  // Bare "multiway" / "Raise · reraise multiway" with no N-way count —
  // keep two villains live (LPT-1025 class soft lines).
  if (RegExp(r'\bmultiway\b').hasMatch(lower)) return 2;
  final named = parseLessonNamedCallerPositions(villainLine);
  if (named.isNotEmpty) return named.length;
  return null;
}

/// Villain seats kept live for a postflop multiway densify ask.
///
/// Prefers SB then BB (common multiway callers), then remaining seats in
/// index order — never hero seat 0.
List<int> lessonPostflopMultiwayCallerSeats({
  required int callerCount,
  required int seatCount,
  required int sbIndex,
  required int bbIndex,
}) {
  if (callerCount <= 0) return const <int>[];
  final preferred = <int>[
    if (sbIndex != 0) sbIndex,
    if (bbIndex != 0 && bbIndex != sbIndex) bbIndex,
    for (var i = 1; i < seatCount; i++)
      if (i != sbIndex && i != bbIndex) i,
  ];
  return preferred.take(callerCount).toList(growable: false);
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
  // `MP opens to 6 · CO + BTN call`: the actor is in the first segment;
  // later segments name callers.
  final segments = villainLine.split('·');
  if (segments.length > 1) {
    final first = _parsePositionToken(segments.first);
    if (first != null) return first;
  }
  return _parsePositionToken(villainLine);
}

String? _parsePositionToken(String text) {
  final lower = text.toLowerCase();
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

/// Preflop act order for the ring ([nineMax] or six-max).
List<String> lessonPreflopOrder({required bool nineMax}) =>
    nineMax ? _nineMaxPreflopOrder : _sixMaxPreflopOrder;

/// Seat index for [position] on a six- or nine-max ring.
int lessonRingSeatIndex({
  required String position,
  required int dealerIndex,
  required bool nineMax,
}) =>
    nineMax
        ? lessonNineMaxSeatIndex(position: position, dealerIndex: dealerIndex)
        : lessonSixMaxSeatIndex(position: position, dealerIndex: dealerIndex);

/// Seats whose preflop turn came before the hero's decision.
///
/// Seats ahead of the hero in act order always acted. When the facing
/// action comes from a seat that acts after the hero ([actorPosition] later
/// in the order, e.g. BB 3-bets the hero's BTN open) the action has gone all
/// the way round, so every other seat acted too. Never includes the hero.
List<int> lessonPreflopSeatsActedBeforeHero({
  required String heroPosition,
  required int dealerIndex,
  required bool nineMax,
  String? actorPosition,
}) {
  final order = lessonPreflopOrder(nineMax: nineMax);
  String norm(String p) => nineMax ? p : lessonSixMaxPositionAlias(p);
  final heroOrder = order.indexOf(norm(heroPosition));
  if (heroOrder < 0) return const <int>[];
  final actorOrder =
      actorPosition == null ? -1 : order.indexOf(norm(actorPosition));
  final wrapped = actorOrder > heroOrder;
  final seats = <int>[];
  for (var i = 0; i < order.length; i++) {
    if (i == heroOrder) continue;
    if (!wrapped && i > heroOrder) continue;
    final seat = lessonRingSeatIndex(
      position: order[i],
      dealerIndex: dealerIndex,
      nineMax: nineMax,
    );
    if (seat != 0 && !seats.contains(seat)) seats.add(seat);
  }
  return seats;
}

/// Villain position named in [villainLine] that is not the hero's seat.
///
/// `BB called BTN open` with the hero on BTN must resolve the BB, not the
/// hero's own BTN token. Falls back to [fallback] (BB, or BTN when the hero
/// is the BB) so the live villain is never drawn in the hero's chair.
String lessonVillainPositionExcludingHero(
  String? villainLine, {
  required String heroPosition,
}) {
  final fallback = heroPosition == 'BB' ? 'BTN' : 'BB';
  final primary = parseLessonActionVillainPosition(villainLine);
  if (primary != null && primary != heroPosition) return primary;
  if (villainLine == null || villainLine.isEmpty) return fallback;
  final lower = villainLine.toLowerCase();
  const tokens = <String, String>{
    'utg+1': 'UTG+1',
    'mp+1': 'MP+1',
    'utg': 'UTG',
    'mp': 'MP',
    'hj': 'HJ',
    'hijack': 'HJ',
    'co': 'CO',
    'cutoff': 'CO',
    'btn': 'BTN',
    'button': 'BTN',
    'sb': 'SB',
    'small blind': 'SB',
    'bb': 'BB',
    'big blind': 'BB',
  };
  var bestIndex = -1;
  String? best;
  for (final entry in tokens.entries) {
    final match = RegExp(
      '(^|[^a-z0-9+])${RegExp.escape(entry.key)}(?![a-z0-9+])',
    ).firstMatch(lower);
    if (match == null || entry.value == heroPosition) continue;
    final at = match.start;
    if (bestIndex < 0 || at < bestIndex) {
      bestIndex = at;
      best = entry.value;
    }
  }
  return best ?? fallback;
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
      // "MP opens to 6 · CO + BTN call" — named callers are resolved by seat
      // (LPT-1024); seats that acted before the hero and are not named fold.
      final namedCallerPositions = parseLessonNamedCallerPositions(
        spot.villainLine,
      );
      final List<int> callers;
      List<int> folded;
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
        // Seats that acted before the hero and are not named fold below;
        // seats still to act after the hero (e.g. the BB behind an SB hero)
        // keep their blind and stay live.
        folded = <int>[];
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
      // Every seat whose turn came before the hero's decision shows an
      // action: seats ahead of the opener fold too (CO opens → UTG/HJ fold),
      // and when the raise comes from behind the hero (BB 3-bets the BTN
      // open) the whole ring has acted. No seat is silently skipped.
      final live = <int>{0, openerSeat, ...callers};
      final acted = lessonPreflopSeatsActedBeforeHero(
        heroPosition: heroPos,
        dealerIndex: dealer,
        nineMax: nineMax,
        actorPosition: opener,
      );
      folded = [
        ...folded,
        for (final seat in acted)
          if (!live.contains(seat) && !folded.contains(seat)) seat,
      ]..sort();
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

    // Preflop without a facing bet: the hero opened (or is to act). Seats
    // ahead of the hero folded. `Blinds fold` / `Hand over` lines fold the
    // blinds too; `BB calls your open` keeps the caller live and folds the
    // seats between the hero and the caller.
    final lower = spot.villainLine?.toLowerCase() ?? '';
    final blindsFold =
        lower.contains('blinds fold') || lower.contains('both blinds fold');
    final callsOpen =
        lower.contains('calls your open') ||
        lower.contains('called your open') ||
        (lower.contains('call') && lower.contains('open'));
    final callerPos =
        callsOpen
            ? lessonVillainPositionExcludingHero(
              spot.villainLine,
              heroPosition: heroPos,
            )
            : null;
    final callerSeat =
        callerPos == null
            ? null
            : lessonRingSeatIndex(
              position: callerPos,
              dealerIndex: dealer,
              nineMax: nineMax,
            );
    final acted = lessonPreflopSeatsActedBeforeHero(
      heroPosition: heroPos,
      dealerIndex: dealer,
      nineMax: nineMax,
      // A caller / folding blinds acted after the hero: whole ring acted.
      actorPosition: blindsFold ? 'BB' : callerPos,
    );
    final defaultFolded = [
      for (final seat in acted)
        if (seat != callerSeat) seat,
    ]..sort();
    return LessonActionFeltLayout(
      villainCount: villainCount,
      seatCount: seatCount,
      dealerIndex: dealer,
      sbIndex: sb,
      bbIndex: bb,
      activeSeatIndex: 0,
      foldedSeatIndexes: defaultFolded,
      villainSeatIndex: callerSeat ?? (bb == 0 ? sb : bb),
    );
  }

  // Postflop multiway: "Three callers · wet board" / "Checked to you · 4-way"
  // must keep that many villains live — the default one-villain ring folds
  // everyone else and contradicts the coach (LPT-1025).
  final postflopCallers = parseLessonCallerCount(spot.villainLine) ?? 0;
  if (postflopCallers > 0) {
    final callers = lessonPostflopMultiwayCallerSeats(
      callerCount: postflopCallers,
      seatCount: seatCount,
      sbIndex: sb,
      bbIndex: bb,
    );
    final live = <int>{0, ...callers};
    final folded = [
      for (var i = 1; i < seatCount; i++)
        if (!live.contains(i)) i,
    ];
    return LessonActionFeltLayout(
      villainCount: villainCount,
      seatCount: seatCount,
      dealerIndex: dealer,
      sbIndex: sb,
      bbIndex: bb,
      activeSeatIndex: 0,
      foldedSeatIndexes: folded,
      villainSeatIndex: callers.isNotEmpty ? callers.first : bb,
      callerSeatIndexes: callers,
    );
  }

  // Postflop: ring with one villain still in (unless heads-up above).
  final villainPos = lessonVillainPositionExcludingHero(
    spot.villainLine,
    heroPosition: heroPos,
  );
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
