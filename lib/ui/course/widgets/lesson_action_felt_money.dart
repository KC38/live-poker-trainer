/// Street-bet and pot chips for action-lesson felts.
///
/// Authored spots describe pot and facing bets in copy (`Pot 10`,
/// `Villain bets 5`, `Call 5`). The full [LessonTableStage] needs real
/// [GameState] street bets and pot math so the felt matches live poker:
/// a bet sits by the seat, and Call / Bet increases the displayed pot.
library;

import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

/// Resolved pot + per-seat street bets for a teaching spot.
class LessonActionFeltMoney {
  /// Creates resolved felt money.
  const LessonActionFeltMoney({
    required this.potTotal,
    required this.streetBets,
    this.villainActionLabel,
    this.heroActionLabel,
  });

  /// Display pot including street bets ([GameState.displayPot]).
  final double potTotal;

  /// Street contribution per seat (hero at 0, first villain at 1, …).
  final List<double> streetBets;

  /// Optional last-action badge on the betting villain.
  final String? villainActionLabel;

  /// Optional last-action badge on the hero after they put chips in.
  final String? heroActionLabel;
}

/// Current pot chips from labels like `Pot 10` or `Pot 3 → 9`.
///
/// Uses the last numeric token before an optional `·` annotation.
double? parseLessonPotChips(String potLabel) {
  final head = potLabel.split('·').first;
  final matches = RegExp(r'(\d+(?:\.\d+)?)').allMatches(head).toList();
  if (matches.isEmpty) return null;
  return double.tryParse(matches.last.group(1)!);
}

/// Facing bet / raise-to amount from villain copy.
///
/// Handles `bets 5`, `opens to 6`, `3-bets to 20`, `Bets 18`.
double? parseFacingBetChips(String? villainLine) {
  if (villainLine == null || villainLine.isEmpty) return null;
  final lower = villainLine.toLowerCase();
  final toMatch = RegExp(
    r'(?:open(?:s|ed)?|raise(?:s|d)?|3-?bet(?:s)?|re-?raise(?:s|d)?)\s+to\s+(\d+(?:\.\d+)?)',
  ).firstMatch(lower);
  if (toMatch != null) return double.tryParse(toMatch.group(1)!);
  final betMatch = RegExp(r'bets?\s+(\d+(?:\.\d+)?)').firstMatch(lower);
  if (betMatch != null) return double.tryParse(betMatch.group(1)!);
  return null;
}

/// Chip amount embedded in a choice label (`Call 5`, `Bet 5`, `Raise 15`).
///
/// Falls back to [CourseChoice.amountBb] as dollar chips when the label has
/// no number (lesson stakes are $1/$2 so 1 BB = $2 only when callers pass
/// [bigBlind]).
double? parseChoiceChipAmount(CourseChoice choice, {double bigBlind = 2}) {
  final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(choice.label);
  if (match != null) {
    return double.tryParse(match.group(1)!);
  }
  final bb = choice.amountBb;
  if (bb == null) return null;
  return bb * bigBlind;
}

bool _isAction(CourseChoice choice, String prefix) {
  final action = (choice.action ?? choice.label).toUpperCase();
  return action.startsWith(prefix);
}

/// First Call choice amount, when the dock names the price.
double? callAmountFromChoices(List<CourseChoice> choices) {
  for (final choice in choices) {
    if (!_isAction(choice, 'CALL')) continue;
    final amount = parseChoiceChipAmount(choice);
    if (amount != null) return amount;
  }
  return null;
}

/// Builds felt money for [spot], optionally applying the learner's [selected]
/// Call / Bet / Raise / All-in so the pot and seat pills update live.
///
/// [villainSeatIndex] is the facing bettor / opener seat (default 1). On a
/// six-max ring that is often not the seat immediately after the hero.
LessonActionFeltMoney resolveLessonActionFeltMoney({
  required LessonActionSpot spot,
  required List<CourseChoice> choices,
  CourseChoice? selected,
  int seatCount = 2,
  int villainSeatIndex = 1,
}) {
  final seats = seatCount < 1 ? 1 : seatCount;
  final villainSeat =
      villainSeatIndex < 0
          ? 0
          : (villainSeatIndex >= seats ? (seats > 1 ? 1 : 0) : villainSeatIndex);
  final bets = List<double>.filled(seats, 0);
  final facing =
      spot.facingBet
          ? (parseFacingBetChips(spot.villainLine) ??
              callAmountFromChoices(choices) ??
              0)
          : 0.0;

  var heroBet = 0.0;
  if (spot.facingBet && facing > 0) {
    final callAmt = callAmountFromChoices(choices);
    // Call 4 vs open-to 6 ⇒ hero already has 2 in (e.g. big blind).
    if (callAmt != null && callAmt > 0 && callAmt < facing) {
      heroBet = facing - callAmt;
    }
  }
  if (facing > 0 && villainSeat != 0) {
    bets[villainSeat] = facing;
  }
  bets[0] = heroBet;

  final labeledPot = parseLessonPotChips(spot.potLabel);
  final streetSum = bets.fold<double>(0, (sum, b) => sum + b);
  var potTotal = labeledPot ?? streetSum;
  // `Pot 3` + `opens to 6` is collected blinds only — add street bets.
  if (labeledPot != null && labeledPot + 1e-9 < streetSum) {
    potTotal = labeledPot + streetSum;
  }

  String? villainLabel;
  if (facing > 0) {
    villainLabel = 'BET';
    final line = spot.villainLine?.toLowerCase() ?? '';
    if (line.contains('raise') ||
        line.contains('3-bet') ||
        line.contains('3bet') ||
        line.contains('open')) {
      villainLabel = 'RAISE';
    }
  }

  String? heroLabel;
  if (selected != null) {
    final action = (selected.action ?? selected.label).toUpperCase();
    final amount = parseChoiceChipAmount(selected);
    if (action.startsWith('CALL') && facing > 0) {
      final add = amount ?? (facing - bets[0]).clamp(0, double.infinity);
      bets[0] = bets[0] + add;
      potTotal = potTotal + add;
      heroLabel = 'CALL';
    } else if (action.startsWith('BET') && amount != null) {
      final prev = bets[0];
      bets[0] = amount;
      potTotal = potTotal + (bets[0] - prev);
      heroLabel = 'BET';
    } else if (action.startsWith('RAISE') && amount != null) {
      final prev = bets[0];
      // Prefer raise-to when the size is at least the facing bet.
      bets[0] = amount >= facing && facing > 0 ? amount : facing + amount;
      potTotal = potTotal + (bets[0] - prev);
      heroLabel = 'RAISE';
    } else if (action.startsWith('ALL') && amount != null) {
      final prev = bets[0];
      bets[0] = prev + amount;
      potTotal = potTotal + amount;
      heroLabel = 'ALL-IN';
    }
  }

  return LessonActionFeltMoney(
    potTotal: potTotal,
    streetBets: List<double>.unmodifiable(bets),
    villainActionLabel: villainLabel,
    heroActionLabel: heroLabel,
  );
}

/// Applies [money] onto a lesson [base] hand (main pot = total − street bets).
GameState applyLessonActionFeltMoney(
  GameState base,
  LessonActionFeltMoney money,
) {
  final n = base.players.length;
  final bets = [
    for (var i = 0; i < n; i++)
      i < money.streetBets.length ? money.streetBets[i] : 0.0,
  ];
  final streetSum = bets.fold<double>(0, (sum, b) => sum + b);
  final mainPot =
      (money.potTotal - streetSum).clamp(0, double.infinity).toDouble();
  final highest = bets.fold<double>(0, (m, b) => b > m ? b : m);
  var labeledVillain = 1;
  for (var i = 1; i < bets.length; i++) {
    if (bets[i] > 0) {
      labeledVillain = i;
      break;
    }
  }
  final players = <PlayerModel>[
    for (var i = 0; i < n; i++)
      base.players[i].copyWith(
        currentBet: bets[i],
        // Keep stacks coherent when we invent street bets on a static stage.
        stack: (base.players[i].stack + base.players[i].currentBet - bets[i])
            .clamp(0, double.infinity)
            .toDouble(),
        lastActionLabel: i == 0
            ? money.heroActionLabel
            : (i == labeledVillain ? money.villainActionLabel : null),
        clearLastAction:
            (i == 0 && money.heroActionLabel == null) ||
            (i == labeledVillain && money.villainActionLabel == null) ||
            (i != 0 && i != labeledVillain),
      ),
  ];
  return base.copyWith(
    players: players,
    mainPot: mainPot,
    highestBet: highest,
  );
}

/// Pot chip label after money resolution (`Pot 15`).
String lessonActionPotChipLabel(LessonActionFeltMoney money) {
  final value = money.potTotal;
  if (value == value.roundToDouble()) {
    return 'Pot ${value.round()}';
  }
  return 'Pot $value';
}
