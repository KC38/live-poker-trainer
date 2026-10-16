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
import 'package:live_poker_trainer/ui/widgets/poker_table_bands.dart';

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

/// Ordered pot milestones from labels like `Pot 3 → 9 → 29`.
///
/// Used to recover a prior open when facing a 3-bet (LPT-1020).
List<double> parseLessonPotSteps(String potLabel) {
  final head = potLabel.split('·').first;
  final steps = <double>[];
  for (final match in RegExp(r'(\d+(?:\.\d+)?)').allMatches(head)) {
    final value = double.tryParse(match.group(1)!);
    if (value != null && value > 0) steps.add(value);
  }
  return steps;
}

bool _villainLineIsThreeBetOrReraise(String line) {
  return line.contains('3-bet') ||
      line.contains('3bet') ||
      line.contains('re-raise') ||
      line.contains('reraise');
}

/// Prior open size from a multi-step pot when facing a 3-bet.
///
/// `Pot 3 → 9 → 29` after blinds means the open grew the pot to 9, so the
/// opener put in `9 − blinds`. Returns null when the label is not a
/// 3-step (or longer) progression.
double? priorOpenFromPotSteps({
  required List<double> potSteps,
  required double smallBlind,
  required double bigBlind,
}) {
  if (potSteps.length < 3) return null;
  final afterOpen = potSteps[1];
  final inferred = afterOpen - smallBlind - bigBlind;
  if (inferred <= bigBlind) return null;
  return inferred;
}

/// Facing bet / raise-to amount from villain copy.
///
/// Handles `bets 5`, `opens to 6`, `3-bets to 20`, `Bets 18`, and
/// `check-raises to 12` (Respect Nit densify / peer check-raise lines).
double? parseFacingBetChips(String? villainLine) {
  if (villainLine == null || villainLine.isEmpty) return null;
  final lower = villainLine.toLowerCase();
  final checkRaiseTo = RegExp(
    r'check-?raises?\s+to\s+(\d+(?:\.\d+)?)',
  ).firstMatch(lower);
  if (checkRaiseTo != null) return double.tryParse(checkRaiseTo.group(1)!);
  final toMatch = RegExp(
    r'(?:open(?:s|ed)?|raise(?:s|d)?|3-?bet(?:s)?|re-?raise(?:s|d)?)\s+to\s+(\d+(?:\.\d+)?)',
  ).firstMatch(lower);
  if (toMatch != null) return double.tryParse(toMatch.group(1)!);
  final betMatch = RegExp(r'bets?\s+(\d+(?:\.\d+)?)').firstMatch(lower);
  if (betMatch != null) return double.tryParse(betMatch.group(1)!);
  return null;
}

/// Whether [villainLine] names a postflop bet / check-raise / barrel that
/// should paint street chips even when the copy has no `to N` amount.
bool villainLineImpliesPostflopFacingHeat(String? villainLine) {
  if (villainLine == null || villainLine.isEmpty) return false;
  final lower = villainLine.toLowerCase();
  if (lower.contains('check-raise') || lower.contains('check raise')) {
    return true;
  }
  if (lower.contains('barrel')) return true;
  if (RegExp(r'\bbets?\b').hasMatch(lower)) return true;
  // Bare "raise" / "raises" without "open" (preflop opens use other paths).
  if (RegExp(r'\braises?\b').hasMatch(lower) && !lower.contains('open')) {
    return true;
  }
  return false;
}

/// Whether resolved money should paint onto [LessonTableStage].
///
/// Authored spots often set `potLabel` without `facingBet` (BB called the
/// open, blinds folded, flop after the call). Those still need the labeled
/// pot — otherwise the full table falls back to blinds-only / street defaults
/// (LPT-97).
///
/// A preflop "Pot 3" / folds-to-you line has no street bets yet. Applying
/// that zero-bet list pulls the posted SB/BB chips into the center and
/// refunds their stacks. Leave those spots on the default posted blinds.
bool shouldApplyLessonActionFeltMoney({
  required LessonActionSpot spot,
  required LessonActionFeltMoney money,
}) {
  if (spot.facingBet) return true;
  if (money.heroActionLabel != null) return true;
  if (money.streetBets.any((b) => b > 0)) return true;
  if (spot.boardCodes.isEmpty) return false;
  return parseLessonPotChips(spot.potLabel) != null;
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
///
/// Pass [sbIndex] / [bbIndex] from [resolveLessonActionFeltLayout] on preflop
/// facing-bet densify so posted blinds stay on-seat when street money paints
/// an open — otherwise `_applyLessonStageStreetMoney` zeroes every other
/// seat's `currentBet` and sweeps SB/BB into the center pot (LPT-1016).
///
/// Pass [callerSeatIndexes] for multiway opens (`UTG opens · 2 callers`) so
/// caller street bets match the pot progression when the line has no
/// `opens to N` amount (LPT-1021).
///
/// Postflop `facingBet` lines that name a check-raise / barrel / bet without
/// a chip amount (and without a Call-N choice) infer a pot-sized street bet
/// from `potLabel` so RAISE/BET paints (LPT-1022).
LessonActionFeltMoney resolveLessonActionFeltMoney({
  required LessonActionSpot spot,
  required List<CourseChoice> choices,
  CourseChoice? selected,
  int seatCount = 2,
  int villainSeatIndex = 1,
  List<int> callerSeatIndexes = const <int>[],
  int? sbIndex,
  int? bbIndex,
  double smallBlind = lessonSmallBlind,
  double bigBlind = lessonBigBlind,
}) {
  final seats = seatCount < 1 ? 1 : seatCount;
  final villainSeat =
      villainSeatIndex < 0
          ? 0
          : (villainSeatIndex >= seats ? (seats > 1 ? 1 : 0) : villainSeatIndex);
  final bets = List<double>.filled(seats, 0);
  final labeledPot = parseLessonPotChips(spot.potLabel);
  final line = spot.villainLine?.toLowerCase() ?? '';
  var facing =
      spot.facingBet
          ? (parseFacingBetChips(spot.villainLine) ??
              callAmountFromChoices(choices) ??
              0)
          : 0.0;
  // Squeeze densify: `UTG opens · 2 callers` has no `opens to N`. Recover the
  // open-to from `Pot 3 → 9 → 21` (after-open pot − blinds) (LPT-1021).
  if (spot.facingBet &&
      facing <= 0 &&
      spot.boardCodes.isEmpty &&
      callerSeatIndexes.isNotEmpty) {
    final inferred = priorOpenFromPotSteps(
      potSteps: parseLessonPotSteps(spot.potLabel),
      smallBlind: smallBlind,
      bigBlind: bigBlind,
    );
    if (inferred != null) facing = inferred;
  }
  // Postflop check-raise / barrel / bet lines often omit `to N` and use a
  // bare Call choice (`Hero-call forever`). Infer a pot-sized (or 2× for
  // "huge") street bet so RAISE/BET paints and coach copy stays honest
  // (Respect Nit densify LPT-1022; TAG check-raise peers).
  if (spot.facingBet &&
      facing <= 0 &&
      spot.boardCodes.isNotEmpty &&
      labeledPot != null &&
      labeledPot > 0 &&
      villainLineImpliesPostflopFacingHeat(spot.villainLine)) {
    facing = line.contains('huge') ? labeledPot * 2 : labeledPot;
  }

  var heroBet = 0.0;
  var heroPriorOpen = false;
  if (spot.facingBet && facing > 0) {
    final callAmt = callAmountFromChoices(choices);
    // Call 4 vs open-to 6 ⇒ hero already has 2 in (e.g. big blind).
    if (callAmt != null && callAmt > 0 && callAmt < facing) {
      heroBet = facing - callAmt;
    }
    // Facing a 3-bet after the hero opened: bare `Call` has no chip amount,
    // so callAmt stays null and heroBet would stay 0 — recover the open from
    // `Pot 3 → 9 → 29` (open ≈ after-open pot − blinds) (LPT-1020).
    if (heroBet == 0 &&
        spot.boardCodes.isEmpty &&
        _villainLineIsThreeBetOrReraise(line)) {
      final inferred = priorOpenFromPotSteps(
        potSteps: parseLessonPotSteps(spot.potLabel),
        smallBlind: smallBlind,
        bigBlind: bigBlind,
      );
      if (inferred != null && inferred < facing) {
        heroBet = inferred;
        heroPriorOpen = true;
      }
    }
  }
  if (facing > 0 && villainSeat != 0) {
    bets[villainSeat] = facing;
  }
  if (facing > 0) {
    for (final seat in callerSeatIndexes) {
      if (seat <= 0 || seat >= seats || seat == villainSeat) continue;
      bets[seat] = facing;
    }
  }
  bets[0] = heroBet;

  // Preflop facing opens: keep SB/BB posts visible on their seats. Applying
  // only the opener's raise-to would replace posted blinds with 0 and leave
  // coach copy naming "small blind" with no SB puck/chips (LPT-1016).
  if (spot.facingBet && spot.boardCodes.isEmpty) {
    void keepBlind(int? seat, double amount) {
      if (seat == null || seat < 0 || seat >= seats) return;
      if (bets[seat] < amount) bets[seat] = amount;
    }

    keepBlind(sbIndex, smallBlind);
    keepBlind(bbIndex, bigBlind);
  }

  String? villainLabel;
  String? heroLabel;
  if (heroPriorOpen) {
    heroLabel = 'RAISE';
  }

  // Completed preflop lines (not facingBet): put the open/call on the felt.
  // BB calls your open → Pot 13 with matched $6 street bets (LPT-97).
  // Blinds fold after an open → Pot 9 with the hero's raise still out.
  if (!spot.facingBet && spot.boardCodes.isEmpty && labeledPot != null) {
    final callsOpen =
        line.contains('calls your open') ||
        line.contains('called your open') ||
        (line.contains('calls') && line.contains('open'));
    final blindsFold =
        line.contains('blinds fold') || line.contains('both blinds fold');
    if (callsOpen && villainSeat != 0) {
      final openTo =
          parseFacingBetChips(spot.villainLine) ?? (labeledPot - 1) / 2;
      if (openTo > 0) {
        bets[0] = openTo;
        bets[villainSeat] = openTo;
        heroLabel = 'RAISE';
        villainLabel = 'CALL';
      }
    } else if (blindsFold) {
      final openTo = parseFacingBetChips(spot.villainLine) ?? (labeledPot - 3);
      if (openTo > 0) {
        bets[0] = openTo;
        heroLabel = 'RAISE';
      }
    }
  }

  final streetSum = bets.fold<double>(0, (sum, b) => sum + b);
  var potTotal = labeledPot ?? streetSum;
  // `Pot 3` + `opens to 6` is collected blinds only — add street bets.
  if (labeledPot != null && labeledPot + 1e-9 < streetSum) {
    potTotal = labeledPot + streetSum;
  }

  if (facing > 0) {
    villainLabel = 'BET';
    if (line.contains('raise') ||
        line.contains('3-bet') ||
        line.contains('3bet') ||
        line.contains('open')) {
      villainLabel = 'RAISE';
    }
  }

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
