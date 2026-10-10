/// Six-max seating for poker-action teaching spots.
///
/// Action docks default to a full ring so "folds to you" is visible. Only
/// spots authored as heads-up keep the two-seat layout.
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

/// Preflop act order left of the big blind through the blinds.
const List<String> _preflopOrder = ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'];

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

/// Seat index for [position] when [dealerIndex] is the button.
int lessonSixMaxSeatIndex({
  required String position,
  required int dealerIndex,
}) {
  final offset = _sixMaxOffsetFromButton[position];
  if (offset == null) return 0;
  return (dealerIndex + offset) % 6;
}

/// Seats that folded before [heroPosition] on an open pot.
List<int> lessonSixMaxOpenFoldIndexes({
  required String heroPosition,
  required int dealerIndex,
}) {
  final heroOrder = _preflopOrder.indexOf(heroPosition);
  if (heroOrder <= 0) return const <int>[];
  return [
    for (var i = 0; i < heroOrder; i++)
      lessonSixMaxSeatIndex(
        position: _preflopOrder[i],
        dealerIndex: dealerIndex,
      ),
  ];
}

/// Seats that folded after [openerPosition] before the hero acts.
List<int> lessonSixMaxFoldsBetween({
  required String openerPosition,
  required String heroPosition,
  required int dealerIndex,
}) {
  final start = _preflopOrder.indexOf(openerPosition);
  final end = _preflopOrder.indexOf(heroPosition);
  if (start < 0 || end < 0 || end <= start + 1) return const <int>[];
  return [
    for (var i = start + 1; i < end; i++)
      lessonSixMaxSeatIndex(
        position: _preflopOrder[i],
        dealerIndex: dealerIndex,
      ),
  ];
}

/// Resolves six-max vs heads-up seating for an action teaching [spot].
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
  final dealer = lessonSixMaxDealerIndexForHero(heroPos);
  final sb = lessonSixMaxSeatIndex(position: 'SB', dealerIndex: dealer);
  final bb = lessonSixMaxSeatIndex(position: 'BB', dealerIndex: dealer);

  if (preflop) {
    if (spot.openPot || _foldsToYou(spot.villainLine)) {
      final folded = lessonSixMaxOpenFoldIndexes(
        heroPosition: heroPos,
        dealerIndex: dealer,
      );
      return LessonActionFeltLayout(
        villainCount: lessonBlindsVillainCount,
        seatCount: 6,
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
      final openerSeat = lessonSixMaxSeatIndex(
        position: opener,
        dealerIndex: dealer,
      );
      final folded = lessonSixMaxFoldsBetween(
        openerPosition: opener,
        heroPosition: heroPos,
        dealerIndex: dealer,
      );
      final raiseLabel =
          (spot.villainLine?.toLowerCase().contains('open') ?? false) ||
                  (spot.villainLine?.toLowerCase().contains('raise') ??
                      false) ||
                  (spot.villainLine?.toLowerCase().contains('3-bet') ?? false)
              ? 'RAISE'
              : 'BET';
      return LessonActionFeltLayout(
        villainCount: lessonBlindsVillainCount,
        seatCount: 6,
        dealerIndex: dealer,
        sbIndex: sb,
        bbIndex: bb,
        activeSeatIndex: 0,
        foldedSeatIndexes: folded,
        seatActionLabels: {openerSeat: raiseLabel},
        villainSeatIndex: openerSeat,
      );
    }

    // Preflop without a named open/facing line — full ring, hero to act.
    return LessonActionFeltLayout(
      villainCount: lessonBlindsVillainCount,
      seatCount: 6,
      dealerIndex: dealer,
      sbIndex: sb,
      bbIndex: bb,
      activeSeatIndex: 0,
      villainSeatIndex: bb == 0 ? sb : bb,
    );
  }

  // Postflop: full ring with one villain still in (unless heads-up above).
  final villainPos =
      parseLessonActionVillainPosition(spot.villainLine) ?? 'BB';
  final villainSeat = lessonSixMaxSeatIndex(
    position: villainPos,
    dealerIndex: dealer,
  );
  final folded = [
    for (var i = 1; i < 6; i++)
      if (i != villainSeat) i,
  ];
  return LessonActionFeltLayout(
    villainCount: lessonBlindsVillainCount,
    seatCount: 6,
    dealerIndex: dealer,
    sbIndex: sb,
    bbIndex: bb,
    activeSeatIndex: 0,
    foldedSeatIndexes: folded,
    villainSeatIndex: villainSeat,
  );
}

bool _foldsToYou(String? villainLine) {
  if (villainLine == null || villainLine.isEmpty) return false;
  final lower = villainLine.toLowerCase();
  return lower.contains('folds to you') || lower.contains('fold to you');
}
