/// Mini-table + action-dock visuals for Fold/Check/Call and Bet/Raise/All-in.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Felt context for a poker-action teaching spot.
class LessonActionSpot {
  /// Creates a spot.
  const LessonActionSpot({
    required this.heroCodes,
    this.boardCodes = const <String>[],
    this.potLabel = 'Pot',
    this.villainLine,
    this.streetLabel,
    this.stackLabel,
    this.facingBet = false,
    this.identifyUnavailable = false,
    this.openPot = false,
    this.feltStatusLine,
  });

  final List<String> heroCodes;
  final List<String> boardCodes;
  final String potLabel;
  final String? villainLine;
  final String? streetLabel;

  /// Short-stack all-in teaching (e.g. "Stack 12").
  final String? stackLabel;
  final bool facingBet;

  /// Checkpoint mode: tap the illegal action (Check facing a bet).
  final bool identifyUnavailable;

  /// Unchecked pot — betting (not raising) is the open action.
  final bool openPot;

  /// Optional override for the gold status line under the holes.
  final String? feltStatusLine;

  /// Chip stack parsed from [stackLabel] (e.g. "Stack 12" → 12).
  int? get heroStackAmount {
    final raw = stackLabel;
    if (raw == null || raw.isEmpty) return null;
    final match = RegExp(r'(\d+)').firstMatch(raw);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }
}

/// Resolves a teaching spot for Section 1 action lessons.
LessonActionSpot? resolveLessonActionSpot(CourseActivity activity) {
  switch (activity.id) {
    case 'act-01-03-01-guided-fold':
      return const LessonActionSpot(
        heroCodes: ['7h', '2d'],
        potLabel: 'Pot 3',
        villainLine: 'UTG opens to 6',
        streetLabel: 'Preflop · Button',
        facingBet: true,
      );
    case 'act-01-03-01-scaffolded-check':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', '7c', '2d'],
        potLabel: 'Pot 10',
        villainLine: 'Checked to you',
        streetLabel: 'Flop',
        facingBet: false,
      );
    case 'act-01-03-01-unguided-call':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['9c', '8s', '2h'],
        potLabel: 'Pot 10',
        villainLine: 'Villain bets 5',
        streetLabel: 'Flop',
        facingBet: true,
      );
    case 'act-01-03-01-checkpoint-legal':
      return const LessonActionSpot(
        heroCodes: ['Ac', 'Kd'],
        boardCodes: ['Qh', '9c', '3s'],
        potLabel: 'Pot 12',
        villainLine: 'Villain bets 6',
        streetLabel: 'Flop',
        facingBet: true,
        identifyUnavailable: true,
      );
    case 'act-01-03-02-guided-bet':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Qd'],
        boardCodes: ['As', '7c', '2d'],
        potLabel: 'Pot 10',
        villainLine: 'Checked to you',
        streetLabel: 'Flop · Top pair',
        facingBet: false,
        openPot: true,
      );
    case 'act-01-03-02-scaffolded-raise':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Kd'],
        boardCodes: ['Qc', '9s', '3h'],
        potLabel: 'Pot 10',
        villainLine: 'Villain bets 5',
        streetLabel: 'Flop',
        facingBet: true,
      );
    case 'act-01-03-02-unguided-allin':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Jc'],
        boardCodes: ['Td', '8s', '2c'],
        potLabel: 'Pot 30',
        villainLine: 'Villain bets 20',
        streetLabel: 'Flop',
        stackLabel: 'Stack 12',
        facingBet: true,
      );
    case 'act-01-03-02-checkpoint-names':
      return const LessonActionSpot(
        heroCodes: ['Ad', '9c'],
        boardCodes: ['Kh', '7s', '2d'],
        potLabel: 'Pot 8',
        villainLine: 'Checked to you',
        streetLabel: 'Flop',
        facingBet: false,
        openPot: true,
      );
    case 'act-01-06-01-unguided-lab':
      return const LessonActionSpot(
        heroCodes: ['Ah', '7d'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'BTN opens to 6',
        streetLabel: 'Preflop · Big blind',
        facingBet: true,
        feltStatusLine: '4 more chips to call the open',
      );
    case 'act-01-06-02-jump-legal':
      return const LessonActionSpot(
        heroCodes: ['Qh', 'Jd'],
        boardCodes: ['Td', '8s', '2c'],
        potLabel: 'Pot 12',
        villainLine: 'Villain bets 8',
        streetLabel: 'Flop',
        facingBet: true,
        identifyUnavailable: true,
      );
    case 'act-02-07-01-guided-ep':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Jh'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · UTG · 9-max',
        facingBet: false,
        openPot: true,
      );
    case 'act-02-07-01-scaffolded-vs':
      return const LessonActionSpot(
        heroCodes: ['2h', '2d'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'UTG opens to 6',
        streetLabel: 'Preflop · Button · 9-max',
        facingBet: true,
      );
    case 'act-02-07-01-unguided-lab':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Qd'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'CO opens to 6',
        streetLabel: 'Preflop · Button · 9-max',
        facingBet: true,
      );
    case 'act-02-07-02-jump-open':
      return const LessonActionSpot(
        heroCodes: ['7h', '2d'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · UTG · 9-max',
        facingBet: false,
        openPot: true,
        // Correct action is Fold — do not imply "open the pot".
        feltStatusLine: 'First in — trash folds',
      );
    case 'act-02-03-01-guided-utg':
      return const LessonActionSpot(
        heroCodes: ['7h', '2d'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · UTG · 1/2',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'First in — trash folds',
      );
    case 'act-02-03-01-scaffolded-qq':
      return const LessonActionSpot(
        heroCodes: ['Qh', 'Qd'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · UTG · 1/2',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'First in — open the pot',
      );
    case 'act-02-03-01-unguided-btn':
      return const LessonActionSpot(
        heroCodes: ['Kh', '9h'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · Button · 1/2',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'First in — button can open wider',
      );
    case 'act-02-03-01-checkpoint-hj':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Td'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · Hijack · 1/2',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'First in — mid-late open',
      );
    case 'act-02-04-01-guided-fold':
      return const LessonActionSpot(
        heroCodes: ['Jh', '3d'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'UTG opens to 6',
        streetLabel: 'Preflop · Big blind · 1/2',
        facingBet: true,
        feltStatusLine: 'Facing an open — junk folds',
      );
    case 'act-02-04-01-scaffolded-call':
      return const LessonActionSpot(
        heroCodes: ['8h', '7h'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'CO opens to 6',
        streetLabel: 'Preflop · Button · 1/2',
        facingBet: true,
        feltStatusLine: 'Suited connector in position',
      );
    case 'act-02-04-01-unguided-3bet':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Kd'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'BTN opens to 6',
        streetLabel: 'Preflop · Small blind · 1/2',
        facingBet: true,
        feltStatusLine: 'Premium vs a button open',
      );
    case 'act-02-04-01-checkpoint-aq':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Qh'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'HJ opens to 6',
        streetLabel: 'Preflop · Cutoff · 1/2',
        facingBet: true,
        feltStatusLine: 'Strong suited broadway',
      );
    case 'act-02-07-02-jump-vs':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Ad'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'Open to 6',
        streetLabel: 'Preflop · Big blind · 9-max',
        facingBet: true,
      );
    case 'act-03-04-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', '7c', '2d'],
        potLabel: 'Pot 10',
        villainLine: 'Checked to you',
        streetLabel: 'Flop · Heads-up · TPTK',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you — value bet',
      );
    case 'act-03-04-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Qd'],
        boardCodes: ['As', '7d', '2c'],
        potLabel: 'Pot 13',
        villainLine: 'BB checks',
        streetLabel: 'Flop · BTN aggressor',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Dry ace — you opened',
      );
    case 'act-03-04-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['7h', '7d'],
        boardCodes: ['7c', 'Kd', '2s'],
        potLabel: 'Pot 24',
        villainLine: 'Villain bets 12',
        streetLabel: 'Flop · Multiway · Set',
        facingBet: true,
        feltStatusLine: 'Set multiway — build the pot',
      );
    case 'act-03-04-01-checkpoint':
      return const LessonActionSpot(
        heroCodes: ['5h', '2d'],
        boardCodes: ['Ah', '7c', '2s'],
        potLabel: 'Pot 30',
        villainLine: 'Bet · raise ahead',
        streetLabel: 'Flop · Multiway · Bottom pair',
        facingBet: true,
        feltStatusLine: 'Heat multiway — weak one pair',
      );
    case 'act-03-05-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', '7d', '2c', '3h'],
        potLabel: 'Pot 20',
        villainLine: 'Called flop c-bet',
        streetLabel: 'Turn · Brick · TPTK',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Brick turn — still ahead',
      );
    case 'act-03-05-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        boardCodes: ['Kh', '7h', '2c', '3h'],
        potLabel: 'Pot 18',
        villainLine: 'Checked to you',
        streetLabel: 'Turn · Flush completes',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Draw hit — delayed value',
      );
    case 'act-03-06-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', 'Kc', '7d', '2h', '3c'],
        potLabel: 'Pot 28',
        villainLine: 'Checked to you',
        streetLabel: 'River · Brick · Top two',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Brick river — get paid',
      );
    case 'act-03-06-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['9h', '8h'],
        boardCodes: ['Kh', '7h', '2c', '3d', 'Ah'],
        potLabel: 'Pot 40',
        villainLine: 'Checked to you',
        streetLabel: 'River · Flush completes · Missed',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Flush hits — tell that story',
      );
    case 'act-03-06-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Ah', '4d'],
        boardCodes: ['As', '9c', '7d', '2h', '3c'],
        potLabel: 'Pot 50',
        villainLine: 'Jams all-in',
        streetLabel: 'River · Quiet line · Weak TPTK',
        facingBet: true,
        feltStatusLine: 'Huge jam — weak kicker',
      );
    case 'act-03-07-01-guided':
      return const LessonActionSpot(
        heroCodes: ['7h', '9d'],
        boardCodes: ['Kc', '7s', '2d'],
        potLabel: 'Pot 16',
        villainLine: 'Checked to you · 4-way',
        streetLabel: 'Flop · Multiway · Second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Four ways — not auto-value',
      );
    case 'act-03-07-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Ah', 'Kh', '9h'],
        potLabel: 'Pot 22',
        villainLine: 'Three callers behind',
        streetLabel: 'Flop · Wet · Missed',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Crowd left — no bluff',
      );
    case 'act-03-08-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Ah', '4d'],
        boardCodes: ['As', '9c', '7d'],
        potLabel: 'Pot 40',
        villainLine: 'Raise · reraise multiway',
        streetLabel: 'Flop · Weak TPTK · Heat',
        facingBet: true,
        feltStatusLine: 'Weak kicker — do not stack',
      );
    case 'act-03-08-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['As', '7c', '2d'],
        potLabel: 'Pot 12',
        villainLine: 'Bets 18',
        streetLabel: 'Flop · Gutshot only',
        facingBet: true,
        feltStatusLine: 'Four outs · terrible price',
      );
    case 'act-03-08-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['9h', '8d'],
        boardCodes: ['Kc', '7s', '2d'],
        potLabel: 'Pot 24',
        villainLine: 'Someone bets · 4-way',
        streetLabel: 'Flop · Air · Crowd',
        facingBet: true,
        feltStatusLine: 'No pair, no draw — fold',
      );
    case 'act-03-08-02-jump-mw':
      return const LessonActionSpot(
        heroCodes: ['9h', '8d'],
        boardCodes: ['Ah', 'Kh', '7h'],
        potLabel: 'Pot 20',
        villainLine: 'Someone bets · 4-way',
        streetLabel: 'Flop · Air · Wet',
        facingBet: true,
        feltStatusLine: 'Crowd — fold air',
      );
    case 'act-03-08-02-jump-river':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', 'Kc', '7d', '2h', '3c'],
        potLabel: 'Pot 28',
        villainLine: 'Checked to you',
        streetLabel: 'River · Brick · Top two',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Brick river — get paid',
      );
    case 'act-04-02-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Qh', 'Qd'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'CO opens to 6',
        streetLabel: 'Preflop · Button · QQ',
        facingBet: true,
        feltStatusLine: 'Queens — 3-bet value',
      );
    case 'act-04-02-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['7h', '2d'],
        potLabel: 'Pot 3 → 9 → 29',
        villainLine: 'BB 3-bets to 20',
        streetLabel: 'Preflop · BTN · 72o',
        facingBet: true,
        feltStatusLine: 'Trash vs 3-bet — fold',
      );
    case 'act-04-02-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        potLabel: 'Pot 3 → 9 → 21',
        villainLine: 'UTG opens · 2 callers',
        streetLabel: 'Preflop · BB · AKo',
        facingBet: true,
        feltStatusLine: 'Multiway — squeeze AK',
      );
    case 'act-04-02-01-checkpoint':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Kd'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'Open to 6',
        streetLabel: 'Preflop · Value 3-bet · KK',
        facingBet: true,
        feltStatusLine: 'Pick a live 3-bet size',
      );
    case 'act-04-03-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Qd', '9c'],
        boardCodes: ['Kh', '7h', '2c', '3h'],
        potLabel: 'Pot 18',
        villainLine: 'Called your flop bluff',
        streetLabel: 'Turn · four hearts · air',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Flush card — shut down',
      );
    case 'act-04-03-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', '9s', '3h'],
        potLabel: 'Pot 24 · 3-way',
        villainLine: 'Two callers · deep stacks',
        streetLabel: 'Flop · medium strength',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Keep the pot controlled',
      );
    case 'act-04-04-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', '7c', '2d'],
        potLabel: 'Pot 20',
        villainLine: 'Checked to you',
        streetLabel: 'Flop · dry · top pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Pick a value size',
      );
    case 'act-04-04-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['9h', '8h'],
        boardCodes: ['Kd', '7c', '2s', '3d', 'Ah'],
        potLabel: 'Pot 40',
        villainLine: 'Checked to you',
        streetLabel: 'River · scare Ace · missed draw',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Sell polar pressure',
      );
    case 'act-04-04-01-checkpoint':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Ad'],
        boardCodes: ['Kc', '9s', '3h'],
        potLabel: 'Pot 30',
        villainLine: 'Checked to you',
        streetLabel: 'Flop · strong value',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Tap the worst value size',
      );
    case 'act-04-05-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Kd'],
        boardCodes: ['Kc', '7s', '2d'],
        potLabel: 'Pot ~60 · SPR ~1',
        villainLine: '3-bet pot · short SPR',
        streetLabel: 'Flop · top set',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Low SPR — get it in',
      );
    case 'act-04-05-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Qc', '9s', '3h'],
        potLabel: 'Pot 12 · SPR 20',
        villainLine: 'Multiway · deep stacks',
        streetLabel: 'Flop · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'High SPR — keep it small',
      );
    case 'act-04-05-01-checkpoint':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', '7c', '2d', '9h'],
        potLabel: 'Pot 40 · SPR ~1.4',
        stackLabel: 'Stacks left 55',
        villainLine: 'Opponent jams all-in',
        streetLabel: 'Turn · commitment spot',
        facingBet: true,
        feltStatusLine: 'Weigh SPR before you put it in',
      );
    case 'act-04-06-03-guided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 28',
        villainLine: 'Sticky caller · checked to you',
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Stations call thin value',
      );
    case 'act-04-06-03-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['8h', '7h'],
        boardCodes: ['Kc', '2s', '2d', '9c', '3d'],
        potLabel: 'Pot 24',
        villainLine: 'Same sticky seat · brick river',
        streetLabel: 'River · missed draw',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'No fold equity vs stations',
      );
    case 'act-04-06-03-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 28',
        villainLine: 'Unknown · no samples yet',
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'No sticky read — stay cautious',
      );
    case 'act-04-07-03-guided':
      return const LessonActionSpot(
        heroCodes: ['Kh', '9d'],
        potLabel: 'Pot 1.5',
        villainLine: 'Nit in BB · folds often',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Steal wider vs nits',
      );
    case 'act-04-07-03-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Qc', '9s', '3h'],
        potLabel: 'Pot 12',
        villainLine: 'Nit check-raises your c-bet',
        streetLabel: 'Flop · middle pair',
        facingBet: true,
        feltStatusLine: 'Nit heat is usually strong',
      );
    case 'act-04-07-03-unguided':
      return const LessonActionSpot(
        heroCodes: ['Kh', '9d'],
        potLabel: 'Pot 1.5',
        villainLine: 'Unknown BB · no samples',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'No nit read — stay tighter',
      );
    case 'act-04-08-03-guided':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9d'],
        boardCodes: ['As', '7c', '2d', 'Th', '3c'],
        potLabel: 'Pot 42',
        villainLine: 'Maniac barrels river',
        streetLabel: 'River · top pair weak kicker',
        facingBet: true,
        feltStatusLine: 'Maniac bets too wide',
      );
    case 'act-04-08-03-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', 'Kc', '2d', '9h', '3c'],
        potLabel: 'Pot 28',
        villainLine: 'Maniac checks to you',
        streetLabel: 'River · top two',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'They call light — bet value',
      );
    case 'act-04-08-03-unguided':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9d'],
        boardCodes: ['As', '7c', '2d', 'Th', '3c'],
        potLabel: 'Pot 42',
        villainLine: 'Unknown · no maniac samples',
        streetLabel: 'River · top pair weak kicker',
        facingBet: true,
        feltStatusLine: 'No maniac read — fold more',
      );
    case 'act-04-10-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 28',
        villainLine: 'Calling Station · checked to you',
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Stations call thin value',
      );
    case 'act-04-10-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 36',
        villainLine: 'Nit just check-raised',
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Nit heat is usually strong',
      );
    case 'act-04-10-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 42',
        villainLine: 'Maniac barrels river',
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Maniac bets too wide',
      );
    case 'act-04-10-01-checkpoint':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Td'],
        potLabel: 'Pot 1.5',
        villainLine: 'Nit in BB · folds often',
        streetLabel: 'Preflop · Button · 200bb',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Deep BTN vs nit — steal wider',
      );
    case 'act-04-10-02-jump-3bet':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Kd'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'CO opens to 6',
        streetLabel: 'Preflop · Button · KK',
        facingBet: true,
        feltStatusLine: 'Kings — 3-bet value',
      );
    case 'act-04-10-02-jump-size':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', '7c', '2d'],
        potLabel: 'Pot 20',
        villainLine: 'Checked to you',
        streetLabel: 'Flop · top pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Value language — half pot',
      );
    case 'act-05-01-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['7h', '6h'],
        potLabel: 'Pot 7.5',
        villainLine: 'BTN open · BB + MP call',
        streetLabel: 'Preflop · SB · 76s',
        facingBet: true,
        feltStatusLine: 'OOP multiway — fold medium connectors',
      );
    case 'act-05-01-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['9h', '9d'],
        boardCodes: ['9s', '8c', '7h'],
        potLabel: 'Pot 24',
        villainLine: 'Three callers · wet board',
        streetLabel: 'Flop · top set',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Multiway sets — bet thick',
      );
    case 'act-05-02-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9d'],
        boardCodes: ['As', '8h', '7h'],
        potLabel: 'Pot 40',
        villainLine: 'Huge check-raise · wet flop',
        streetLabel: 'Flop · top pair weak · 250bb',
        facingBet: true,
        feltStatusLine: 'Deep + wet + heat — fold light TP',
      );
    case 'act-05-03-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '7s', '2h'],
        potLabel: 'Pot 28',
        villainLine: 'Calling Station bets 6',
        streetLabel: 'Flop · gutshot + overs · 200bb',
        facingBet: true,
        feltStatusLine: 'Station pays — call for implied',
      );
    case 'act-05-03-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Jd'],
        boardCodes: ['As', 'Th', '8h'],
        potLabel: 'Pot 36',
        villainLine: 'Nit check-raises huge',
        streetLabel: 'Flop · KJo · A-high wet',
        facingBet: true,
        feltStatusLine: 'Reverse implied — fold second-best',
      );
    case 'act-05-03-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['7h', '6h'],
        boardCodes: ['Kh', '9h', '2c'],
        potLabel: 'Pot 44',
        villainLine: 'Four-way · bet into you',
        streetLabel: 'Flop · non-nut FD multiway',
        facingBet: true,
        feltStatusLine: 'Dominated draw — fold the leak',
      );
    case 'act-05-04-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 32',
        villainLine: 'Calling Station checked twice',
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Station pays — bet thin value',
      );
    case 'act-05-04-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 48',
        villainLine: 'Maniac barrels river',
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Wide barrels — call the catch',
      );
    case 'act-05-04-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 32',
        villainLine: 'Nit checked to you',
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Nit overfolds — check back',
      );
    case 'act-05-05-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['9h', '8d'],
        boardCodes: ['Kc', '9s', '3h'],
        potLabel: 'Pot 14',
        villainLine: 'PFR checks flop',
        streetLabel: 'Flop · middle pair · BB',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Capped range — probe small',
      );
    case 'act-05-06-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['7h', '6h'],
        boardCodes: ['Kh', '9h', '2c', '3d'],
        potLabel: 'Pot 40',
        villainLine: 'Bombs turn after flop call',
        streetLabel: 'Turn · flush draw · brick',
        facingBet: true,
        feltStatusLine: 'Re-price — fold the bomb',
      );
    case 'act-05-08-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 6',
        villainLine: 'Just stacked you · next hand',
        streetLabel: 'Next hand · steaming',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Steaming — fold and reset',
      );
    case 'act-05-09-02-cp-value':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 32',
        villainLine: 'Calling Station checked twice',
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Station pays — bet thin value',
      );
    case 'act-05-09-02-cp-catch':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 48',
        villainLine: 'Maniac barrels river',
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Wide barrels — call the catch',
      );
    case 'act-06-01-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Kc', '7s', '2d'],
        potLabel: 'Pot 12',
        villainLine: 'BB called pre · checks',
        streetLabel: 'Flop · K72r · PFR',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Range + nut lean — c-bet',
      );
    case 'act-06-03-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 42',
        villainLine: 'Checked turn · capped',
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Cap on river — bet thin',
      );
    case 'act-06-04-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', '9s', '3h', '2d', '7c'],
        potLabel: 'Pot 36',
        villainLine: 'Calling station · checked',
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Station river — bet medium',
      );
    case 'act-06-05-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['As', 'Kd'],
        boardCodes: ['Ah', '7c', '2d', '9s'],
        potLabel: 'Pot 20',
        villainLine: 'Checked after half-pot flop',
        streetLabel: 'Turn · geometric size',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Half-pot flop → pot-ish turn',
      );
    case 'act-06-07-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['9h', '7d'],
        boardCodes: ['Kc', 'Qh', 'Jd', '2c', 'Ts'],
        potLabel: 'Pot 48',
        villainLine: 'Bombs river · no blockers',
        streetLabel: 'River · third pair',
        facingBet: true,
        feltStatusLine: 'Clear trash — fold',
      );
    case 'act-06-08-01-guided':
      return const LessonActionSpot(
        heroCodes: ['7h', '7d'],
        boardCodes: ['7c', 'Kd', '2s'],
        potLabel: 'Pot 12',
        villainLine: 'Checked to you',
        streetLabel: 'Flop · set of sevens',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Mix strong — check sometimes',
      );
    case 'act-06-09-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Qd'],
        boardCodes: ['8c', '3h', '2s'],
        potLabel: 'Pot 22',
        villainLine: 'Checked to you · 180bb deep',
        streetLabel: 'Flop · AQo miss after 3-bet',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Deep 3-bet — small c-bet or give-up',
      );
    case 'act-06-10-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9d'],
        boardCodes: ['As', '7c', '2h', 'Kd', '3c'],
        potLabel: 'Pot 54',
        villainLine: 'Triple barrels · solid unknown',
        streetLabel: 'River · top pair weak kicker',
        facingBet: true,
        feltStatusLine: 'No maniac read — hard fold',
      );
    case 'act-06-11-03-guided':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Qc', '9s', '3h'],
        potLabel: 'Pot 14',
        villainLine: 'TAG check-raises your c-bet',
        streetLabel: 'Flop · second pair',
        facingBet: true,
        feltStatusLine: 'TAG heat is usually strong',
      );
    case 'act-06-11-03-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Kh', '9d'],
        potLabel: 'Pot 1.5',
        villainLine: 'TAG in BB · defends well',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Steal tighter than vs nits',
      );
    case 'act-06-11-03-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 28',
        villainLine: 'TAG · rarely calls light',
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Thin value needs their calls',
      );
    case 'act-06-12-03-guided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', '9s', '3h', '2d', '7c'],
        potLabel: 'Pot 42',
        villainLine: 'LAG barrels river',
        streetLabel: 'River · second pair good kicker',
        facingBet: true,
        feltStatusLine: 'LAG pressure is wide',
      );
    case 'act-06-12-03-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['As', 'Ad'],
        boardCodes: ['Ac', '7s', '2h'],
        potLabel: 'Pot 14',
        villainLine: 'LAG in pot · wide range',
        streetLabel: 'Flop · top set',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Trap more vs LAG pressure',
      );
    case 'act-07-03-01-guided':
      return const LessonActionSpot(
        heroCodes: ['As', 'Ad'],
        boardCodes: ['Ac', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 48',
        villainLine: 'Calling Station · checked to you',
        streetLabel: 'River · top set',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Station pays thick value',
      );
    case 'act-06-13-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 28',
        villainLine: 'Calling Station · checked to you',
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Same cards — Station calls thin',
      );
    case 'act-06-13-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 36',
        villainLine: 'Nit just check-raised',
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Same cards — Nit heat is strong',
      );
    case 'act-06-13-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 42',
        villainLine: 'LAG barrels river',
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Same cards — LAG pressure is wide',
      );
    case 'act-07-07-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Kc', '8s', '3h'],
        potLabel: 'Pot 18',
        villainLine: 'Calling Station · checked to you',
        streetLabel: 'Flop · top pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Same cards — Station pays value',
      );
    case 'act-07-07-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Kc', '8s', '3h'],
        potLabel: 'Pot 36',
        villainLine: 'TAG just check-raised',
        streetLabel: 'Flop · top pair',
        facingBet: true,
        feltStatusLine: 'Same cards — TAG heat is strong',
      );
    case 'act-07-07-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Kc', '8s', '3h', '2d'],
        potLabel: 'Pot 42',
        villainLine: 'LAG barrels turn',
        streetLabel: 'Turn · top pair',
        facingBet: true,
        feltStatusLine: 'Same cards — LAG pressure is wide',
      );
    case 'act-07-08-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Ts', '9h', '8c', '2d'],
        potLabel: 'Pot 48',
        villainLine: 'Maniac overbets turn',
        streetLabel: 'Turn · second pair · wet',
        facingBet: true,
        feltStatusLine: 'Wet board — maniac overbets wide',
      );
    case 'act-07-08-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['9h', '8d'],
        boardCodes: ['Ac', '7s', '2d', 'Kd'],
        potLabel: 'Pot 22',
        villainLine: 'Nit bets tiny on turn',
        streetLabel: 'Turn · air · dry',
        facingBet: true,
        feltStatusLine: 'Dry board — tiny nit bets are weak',
      );
    case 'act-07-08-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 54',
        villainLine: 'TAG pots river after strong line',
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Strong TAG line — fold second pair',
      );
  }
  return null;
}

/// Mini-table spot for one authored multi-step hand decision.
LessonActionSpot? resolveToyHandStepSpot({
  required String activityId,
  required String stepId,
}) {
  if (activityId == 'act-07-10-01-hand') {
    switch (stepId) {
      case 'step-flop':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Qd'],
          boardCodes: ['Kc', '7s', '2h'],
          potLabel: 'Pot 6.5',
          villainLine: 'BB called BTN open',
          streetLabel: 'Flop · K72r · AQ',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'SRP flop — start the map',
        );
      case 'step-turn':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Qd'],
          boardCodes: ['Kc', '7s', '2h', '2d'],
          potLabel: 'Pot 18.5',
          villainLine: 'Called flop c-bet',
          streetLabel: 'Turn · K722 · AQ',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Paired blank — update the map',
        );
      case 'step-river':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Qd'],
          boardCodes: ['Kc', '7s', '2h', '2d', '9c'],
          potLabel: 'Pot 46.5',
          villainLine: 'Called turn barrel',
          streetLabel: 'River · K7229 · ace-high',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'No story — finish clean',
        );
    }
    return null;
  }
  if (activityId == 'act-07-10-02-hand') {
    switch (stepId) {
      case 'step-3b-flop':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Qd'],
          boardCodes: ['Qs', '8h', '3d'],
          potLabel: 'Pot 22',
          villainLine: 'TAG called your 3-bet',
          streetLabel: 'Flop · Q83tt · AQ',
          facingBet: false,
          openPot: true,
          feltStatusLine: '3-bet flop — value with TPTK',
        );
      case 'step-3b-turn':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Qd'],
          boardCodes: ['Qs', '8h', '3d', '2d'],
          potLabel: 'Pot 42',
          villainLine: 'Called flop c-bet',
          streetLabel: 'Turn · Q832 · AQ',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Blank — continue value or kill',
        );
      case 'step-3b-river':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Qd'],
          boardCodes: ['Qs', '8h', '3d', '2d', '7c'],
          potLabel: 'Pot 86',
          villainLine: 'TAG check-raises huge',
          streetLabel: 'River · Q8327 · TPTK',
          facingBet: true,
          feltStatusLine: 'Huge raise — close without ego',
        );
    }
    return null;
  }
  if (activityId == 'act-07-10-03-hand') {
    switch (stepId) {
      case 'step-mw-flop':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Qh'],
          boardCodes: ['Jh', '8h', '2c'],
          potLabel: 'Pot 28',
          villainLine: 'Four-way · bet into you',
          streetLabel: 'Flop · Jh8h2c · AQs',
          facingBet: true,
          feltStatusLine: 'Nut flush draw — call deep',
        );
      case 'step-mw-turn':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Qh'],
          boardCodes: ['Jh', '8h', '2c', '3d'],
          potLabel: 'Pot 48',
          villainLine: 'Checked to you · two behind',
          streetLabel: 'Turn · Jh8h2c3d · AQs',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Still drawing — semi-bluff ok',
        );
      case 'step-mw-river':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Qh'],
          boardCodes: ['Jh', '8h', '2c', '3d', '9c'],
          potLabel: 'Pot 84',
          villainLine: 'Two players behind',
          streetLabel: 'River · miss · ace-high',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Missed — no light multiway bluff',
        );
    }
    return null;
  }
  if (activityId == 'act-07-10-04-hand') {
    switch (stepId) {
      case 'step-limp-flop':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Kh'],
          boardCodes: ['Kd', '9c', '4h'],
          potLabel: 'Pot 8',
          villainLine: 'Four-way limp · checked to you',
          streetLabel: 'Flop · Kd9c4h · AK',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Top pair limped — bet value',
        );
      case 'step-limp-turn':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Kh'],
          boardCodes: ['Kd', '9c', '4h', '2s'],
          potLabel: 'Pot 24',
          villainLine: 'Called by two',
          streetLabel: 'Turn · Kd9c4h2s · AK',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Blank — continue value',
        );
      case 'step-limp-river':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Kh'],
          boardCodes: ['Kd', '9c', '4h', '2s', '8d'],
          potLabel: 'Pot 60',
          villainLine: 'Both call again',
          streetLabel: 'River · Kd9c4h2s8d · TPTK',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Thin value — not a blast bluff',
        );
    }
    return null;
  }
  if (activityId == 'act-07-10-05-hand') {
    switch (stepId) {
      case 'step-4b-flop':
        return const LessonActionSpot(
          heroCodes: ['Kh', 'Kd'],
          boardCodes: ['Qs', '8h', '3d'],
          potLabel: 'Pot 40',
          villainLine: 'Called your 4-bet',
          streetLabel: 'Flop · Q83r · KK',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Short SPR — start commit',
        );
      case 'step-4b-turn':
        return const LessonActionSpot(
          heroCodes: ['Kh', 'Kd'],
          boardCodes: ['Qs', '8h', '3d', '2d'],
          potLabel: 'Pot 64',
          villainLine: 'Called flop c-bet',
          streetLabel: 'Turn · Q832 · KK',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Blank — continue / commit',
        );
      case 'step-4b-river':
        return const LessonActionSpot(
          heroCodes: ['Kh', 'Kd'],
          boardCodes: ['Qs', '8h', '3d', '2d', 'Ad'],
          potLabel: 'Pot 120',
          villainLine: 'Opponent jams',
          streetLabel: 'River · Q832A · KK',
          facingBet: true,
          feltStatusLine: 'Ace jam — fold ego',
        );
    }
    return null;
  }
  if (activityId == 'act-04-03-01-guided') {
    switch (stepId) {
      case 'step-flop-tp':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Kd'],
          boardCodes: ['As', '7c', '2d'],
          potLabel: 'Pot 12',
          villainLine: 'Checked to you',
          streetLabel: 'Flop · A72 rainbow · TPTK',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Start the value plan',
        );
      case 'step-turn-tp':
        return const LessonActionSpot(
          heroCodes: ['Ah', 'Kd'],
          boardCodes: ['As', '7c', '2d', '3h'],
          potLabel: 'Pot 20',
          villainLine: 'Called flop · brick turn',
          streetLabel: 'Turn · A723 · TPTK',
          facingBet: false,
          openPot: true,
          feltStatusLine: 'Second barrel for value',
        );
    }
    return null;
  }
  if (!activityId.startsWith('act-01-06-0')) return null;
  switch (stepId) {
    case 'step-01-06-pre':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'First in — open the pot',
      );
    case 'step-01-06-flop':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        potLabel: 'Pot 9',
        villainLine: 'Blinds fold',
        streetLabel: 'Hand over',
        facingBet: false,
        feltStatusLine: 'Uncontested — stack the chips',
      );
    case 'step-01-06-bb-defend':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        potLabel: 'Pot 13',
        villainLine: 'BB calls your open',
        streetLabel: 'Preflop · Heading to flop',
        facingBet: false,
        feltStatusLine: 'Call keeps the hand alive',
      );
    case 'step-01-06-flop-cbet':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        boardCodes: ['As', '7c', '2d'],
        potLabel: 'Pot 13',
        villainLine: 'BB checks',
        streetLabel: 'Flop · A72 rainbow',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Top pair — bet for value',
      );
    case 'step-01-06-cp-open':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Qd'],
        potLabel: 'Pot 3',
        villainLine: 'CO folds',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'First in — open the pot',
      );
    case 'step-01-06-cp-end':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Qd'],
        potLabel: 'Pot 9',
        villainLine: 'Both blinds fold',
        streetLabel: 'Hand over',
        facingBet: false,
        feltStatusLine: 'Uncontested — stack the chips',
      );
    case 'j-hand-open':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Th'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'First in — open the pot',
      );
    case 'j-hand-end':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Th'],
        potLabel: 'Pot 9',
        villainLine: 'Blinds fold',
        streetLabel: 'Hand over',
        facingBet: false,
        feltStatusLine: 'Uncontested — stack the chips',
      );
  }
  return null;
}

/// Whether this activity should render the mini-table action dock.
bool isLessonActionTableActivity(CourseActivity activity) {
  final id = activity.id;
  if (id.startsWith('act-01-06-01-') &&
      (activity.renderer == ActivityRenderer.authoredMultiStepHand ||
          activity.renderer == ActivityRenderer.fullTableHandLab)) {
    return true;
  }
  if (id == 'act-01-06-02-jump-hand' &&
      activity.renderer == ActivityRenderer.authoredMultiStepHand) {
    return true;
  }
  if (id == 'act-04-03-01-guided' &&
      activity.renderer == ActivityRenderer.authoredMultiStepHand) {
    return true;
  }
  if (id == 'act-07-10-01-hand' &&
      activity.renderer == ActivityRenderer.authoredMultiStepHand) {
    return true;
  }
  if (id == 'act-07-10-02-hand' &&
      activity.renderer == ActivityRenderer.authoredMultiStepHand) {
    return true;
  }
  if (id == 'act-07-10-03-hand' &&
      activity.renderer == ActivityRenderer.authoredMultiStepHand) {
    return true;
  }
  if (id == 'act-07-10-04-hand' &&
      activity.renderer == ActivityRenderer.authoredMultiStepHand) {
    return true;
  }
  if (id == 'act-07-10-05-hand' &&
      activity.renderer == ActivityRenderer.authoredMultiStepHand) {
    return true;
  }
  if (id == 'act-01-06-02-jump-legal' &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-02-07-01-') &&
      (activity.renderer == ActivityRenderer.pokerActionSizing ||
          activity.renderer == ActivityRenderer.fullTableHandLab)) {
    return true;
  }
  if (id.startsWith('act-02-03-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-02-04-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-02-07-02-jump-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-03-04-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-03-05-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-03-06-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-03-07-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-03-08-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-03-08-02-jump-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-04-02-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id == 'act-04-03-01-scaffolded' &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id == 'act-04-03-01-unguided' &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-04-04-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-04-05-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-04-06-03-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-04-07-03-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-04-08-03-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-04-10-01-') &&
      (activity.renderer == ActivityRenderer.pokerActionSizing ||
          activity.renderer == ActivityRenderer.fullTableHandLab)) {
    return true;
  }
  if (id.startsWith('act-04-10-02-jump-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-05-01-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-05-02-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-05-03-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-05-04-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-05-05-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-05-06-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-05-08-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-05-09-02-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-01-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-03-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-04-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-05-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-07-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-08-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-09-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-10-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-11-03-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-12-03-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-07-03-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-06-13-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-07-07-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  if (id.startsWith('act-07-08-01-') &&
      activity.renderer == ActivityRenderer.pokerActionSizing) {
    return true;
  }
  return (id.startsWith('act-01-03-01-') || id.startsWith('act-01-03-02-')) &&
      activity.renderer == ActivityRenderer.pokerActionSizing;
}

/// Explain-step demo: Fold / Check / Call meanings on a mini felt.
class PassiveActionsDemo extends StatefulWidget {
  /// Creates the demo.
  const PassiveActionsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllActionsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllActionsTapped;

  static const actions = <(String, String, Color)>[
    ('FOLD', 'Give up', AppColors.danger),
    ('CHECK', 'Pass free', AppColors.surfaceMuted),
    ('CALL', 'Match bet', AppColors.surfaceMuted),
  ];

  @override
  State<PassiveActionsDemo> createState() => _PassiveActionsDemoState();
}

class _PassiveActionsDemoState extends State<PassiveActionsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllActionsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= PassiveActionsDemo.actions.length) {
      widget.onAllActionsTapped!();
    }
  }

  String get _statusCue {
    final remaining = PassiveActionsDemo.actions
        .where((a) => !_tapped.contains(a.$1))
        .map((a) => a.$1[0] + a.$1.substring(1).toLowerCase())
        .toList();
    if (remaining.isEmpty || !widget.interactive) {
      return 'Fold · Check · Call — your three passives';
    }
    if (remaining.length == 3) {
      return 'Tap Fold, Check, and Call';
    }
    if (remaining.length == 1) {
      return 'Tap ${remaining.first}';
    }
    return 'Tap ${remaining.join(' and ')}';
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.feltBorder.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your three passive buttons',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < PassiveActionsDemo.actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoSoftPulse(
                    active:
                        widget.interactive &&
                        widget.enabled &&
                        !_tapped.contains(PassiveActionsDemo.actions[i].$1) &&
                        // Pulse only the next untapped button in order.
                        PassiveActionsDemo.actions
                                .take(i)
                                .every((a) => _tapped.contains(a.$1)),
                    child: _DemoActionCard(
                      label: PassiveActionsDemo.actions[i].$1,
                      caption: PassiveActionsDemo.actions[i].$2,
                      color: PassiveActionsDemo.actions[i].$3,
                      selected:
                          _tapped.contains(PassiveActionsDemo.actions[i].$1),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () => _onTap(PassiveActionsDemo.actions[i].$1)
                              : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.feltDark.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              _statusCue,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Explain-step demo: Bet / Raise / All-in meanings on a mini felt.
class AggressiveActionsDemo extends StatefulWidget {
  /// Creates the demo.
  const AggressiveActionsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllActionsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllActionsTapped;

  static const actions = <(String, String, Color)>[
    ('BET', 'Open pot', AppColors.gold),
    ('RAISE', 'Reopen bet', AppColors.gold),
    ('ALL-IN', 'Stack-capped', AppColors.danger),
  ];

  @override
  State<AggressiveActionsDemo> createState() => _AggressiveActionsDemoState();
}

class _AggressiveActionsDemoState extends State<AggressiveActionsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllActionsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= AggressiveActionsDemo.actions.length) {
      widget.onAllActionsTapped!();
    }
  }

  String get _statusCue {
    final remaining = AggressiveActionsDemo.actions
        .where((a) => !_tapped.contains(a.$1))
        .map((a) {
          final raw = a.$1;
          if (raw == 'ALL-IN') return 'All-in';
          return raw[0] + raw.substring(1).toLowerCase();
        })
        .toList();
    if (remaining.isEmpty || !widget.interactive) {
      return 'Bet · Raise · All-in — your three aggressives';
    }
    if (remaining.length == 3) {
      return 'Tap Bet, Raise, and All-in';
    }
    if (remaining.length == 1) {
      return 'Tap ${remaining.first}';
    }
    return 'Tap ${remaining.join(' and ')}';
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.feltBorder.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your three aggressive buttons',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < AggressiveActionsDemo.actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoSoftPulse(
                    active:
                        widget.interactive &&
                        widget.enabled &&
                        !_tapped.contains(
                          AggressiveActionsDemo.actions[i].$1,
                        ) &&
                        AggressiveActionsDemo.actions
                            .take(i)
                            .every((a) => _tapped.contains(a.$1)),
                    child: _DemoActionCard(
                      label: AggressiveActionsDemo.actions[i].$1,
                      caption: AggressiveActionsDemo.actions[i].$2,
                      color: AggressiveActionsDemo.actions[i].$3,
                      selected: _tapped.contains(
                        AggressiveActionsDemo.actions[i].$1,
                      ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () =>
                                  _onTap(AggressiveActionsDemo.actions[i].$1)
                              : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.feltDark.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              _statusCue,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Explain-step demo: early vs button opens and a live ~3x size.
class OpenRangeDemo extends StatefulWidget {
  /// Creates the demo.
  const OpenRangeDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'EARLY', caption: 'Strong only', color: AppColors.danger),
    (label: 'BUTTON', caption: 'Wider', color: AppColors.gold),
    (label: 'LIVE 3x', caption: 'Open to 6 @ 1/2', color: AppColors.cream),
  ];

  @override
  State<OpenRangeDemo> createState() => _OpenRangeDemoState();
}

class _OpenRangeDemoState extends State<OpenRangeDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= OpenRangeDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in OpenRangeDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Who opens — and how wide',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < OpenRangeDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoSoftPulse(
                    active:
                        widget.interactive &&
                        widget.enabled &&
                        next?.label == OpenRangeDemo.points[i].label,
                    child: _DemoActionCard(
                      label: OpenRangeDemo.points[i].label,
                      caption: OpenRangeDemo.points[i].caption,
                      color: OpenRangeDemo.points[i].color,
                      selected:
                          _tapped.contains(OpenRangeDemo.points[i].label),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () => _onTap(OpenRangeDemo.points[i].label)
                              : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? (next == null
                    ? 'Early tight · button wider · live opens ~3x'
                    : 'Tap ${next.label} next')
                : 'Early tight · button wider · live opens ~3x',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: fold / call / 3-bet responses versus an open.
class VsOpenResponseDemo extends StatefulWidget {
  /// Creates the demo.
  const VsOpenResponseDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllResponsesTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllResponsesTapped;

  static const responses = <({String label, String caption, Color color})>[
    (label: 'FOLD', caption: 'Weak hands', color: AppColors.slate),
    (label: 'CALL', caption: 'Playable', color: AppColors.cream),
    (label: '3-BET', caption: 'Strong / polar', color: AppColors.gold),
  ];

  @override
  State<VsOpenResponseDemo> createState() => _VsOpenResponseDemoState();
}

class _VsOpenResponseDemoState extends State<VsOpenResponseDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllResponsesTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= VsOpenResponseDemo.responses.length) {
      widget.onAllResponsesTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextResponse {
    for (final response in VsOpenResponseDemo.responses) {
      if (!_tapped.contains(response.label)) return response;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextResponse;
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Facing an open',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < VsOpenResponseDemo.responses.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoSoftPulse(
                    active:
                        widget.interactive &&
                        widget.enabled &&
                        next?.label == VsOpenResponseDemo.responses[i].label,
                    child: _DemoActionCard(
                      label: VsOpenResponseDemo.responses[i].label,
                      caption: VsOpenResponseDemo.responses[i].caption,
                      color: VsOpenResponseDemo.responses[i].color,
                      selected:
                          _tapped.contains(
                            VsOpenResponseDemo.responses[i].label,
                          ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () => _onTap(
                                VsOpenResponseDemo.responses[i].label,
                              )
                              : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? (next == null
                    ? 'Weak fold · playable call · strong 3-bet'
                    : 'Tap ${next.label} next')
                : 'Weak fold · playable call · strong 3-bet',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: count stacks in BB; shorter stack sets the ceiling.
class BbStackDepthDemo extends StatefulWidget {
  /// Creates the demo.
  const BbStackDepthDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'CHIPS→BB', caption: '200 @ 1/2 = 100bb', color: AppColors.cream),
    (label: 'SHORTER', caption: 'Sets the ceiling', color: AppColors.gold),
    (label: 'DEPTH', caption: '50bb ≠ 200bb', color: AppColors.slate),
  ];

  @override
  State<BbStackDepthDemo> createState() => _BbStackDepthDemoState();
}

class _BbStackDepthDemoState extends State<BbStackDepthDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= BbStackDepthDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in BbStackDepthDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Stack depth in big blinds',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < BbStackDepthDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoSoftPulse(
                    active:
                        widget.interactive &&
                        widget.enabled &&
                        next?.label == BbStackDepthDemo.points[i].label,
                    child: _DemoActionCard(
                      label: BbStackDepthDemo.points[i].label,
                      caption: BbStackDepthDemo.points[i].caption,
                      color: BbStackDepthDemo.points[i].color,
                      selected:
                          _tapped.contains(BbStackDepthDemo.points[i].label),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () =>
                                  _onTap(BbStackDepthDemo.points[i].label)
                              : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? (next == null
                    ? 'Count in BB · shorter stack caps the pot'
                    : 'Tap ${next.label} next')
                : 'Count in BB · shorter stack caps the pot',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: live-table habits (watch, say, cover, wait).
class TableHabitsDemo extends StatefulWidget {
  /// Creates the demo.
  const TableHabitsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllHabitsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllHabitsTapped;

  static const habits = <({String label, String caption, Color color})>[
    (label: 'WATCH', caption: 'Follow the action', color: AppColors.cream),
    (label: 'SAY', caption: 'Announce clearly', color: AppColors.gold),
    (label: 'COVER', caption: 'Protect hole cards', color: AppColors.slate),
    (label: 'WAIT', caption: 'Act in turn', color: AppColors.danger),
  ];

  @override
  State<TableHabitsDemo> createState() => _TableHabitsDemoState();
}

class _TableHabitsDemoState extends State<TableHabitsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllHabitsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= TableHabitsDemo.habits.length) {
      widget.onAllHabitsTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextHabit {
    for (final habit in TableHabitsDemo.habits) {
      if (!_tapped.contains(habit.label)) return habit;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextHabit;
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Live-table habits',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _DemoSoftPulse(
                      active:
                          widget.interactive &&
                          widget.enabled &&
                          next?.label ==
                              TableHabitsDemo.habits[row * 2 + col].label,
                      child: _DemoActionCard(
                        label: TableHabitsDemo.habits[row * 2 + col].label,
                        caption:
                            TableHabitsDemo.habits[row * 2 + col].caption,
                        color: TableHabitsDemo.habits[row * 2 + col].color,
                        selected: _tapped.contains(
                          TableHabitsDemo.habits[row * 2 + col].label,
                        ),
                        enabled: widget.interactive && widget.enabled,
                        onPressed:
                            widget.interactive
                                ? () => _onTap(
                                  TableHabitsDemo.habits[row * 2 + col].label,
                                )
                                : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? (next == null
                    ? 'Watch · say · cover · wait your turn'
                    : 'Tap ${next.label} next')
                : 'Watch · say · cover · wait your turn',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: nine-max uses the same rules; position still matters.
class FullRingDemo extends StatefulWidget {
  /// Creates the demo.
  const FullRingDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'NINE', caption: 'Full-ring seats', color: AppColors.cream),
    (label: 'SAME', caption: 'Rules unchanged', color: AppColors.slate),
    (label: 'POSITION', caption: 'Still runs the show', color: AppColors.gold),
  ];

  @override
  State<FullRingDemo> createState() => _FullRingDemoState();
}

class _FullRingDemoState extends State<FullRingDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= FullRingDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Full ring, same game',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < FullRingDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: FullRingDemo.points[i].label,
                    caption: FullRingDemo.points[i].caption,
                    color: FullRingDemo.points[i].color,
                    selected: _tapped.contains(FullRingDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(FullRingDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? 'Tap Nine, Same, and Position'
                : 'Nine seats · same rules · position still matters',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: read pot, stacks, button, and who acts before cards.
class TableReadDemo extends StatefulWidget {
  /// Creates the demo.
  const TableReadDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'POT', caption: 'Size the prize', color: AppColors.gold),
    (label: 'STACKS', caption: 'Depth in BB', color: AppColors.cream),
    (label: 'BUTTON', caption: 'Who has position', color: AppColors.slate),
    (label: 'WHO ACTS', caption: 'Words count live', color: AppColors.danger),
  ];

  @override
  State<TableReadDemo> createState() => _TableReadDemoState();
}

class _TableReadDemoState extends State<TableReadDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= TableReadDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Read the table before cards',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _DemoActionCard(
                      label: TableReadDemo.points[row * 2 + col].label,
                      caption: TableReadDemo.points[row * 2 + col].caption,
                      color: TableReadDemo.points[row * 2 + col].color,
                      selected: _tapped.contains(
                        TableReadDemo.points[row * 2 + col].label,
                      ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () => _onTap(
                                TableReadDemo.points[row * 2 + col].label,
                              )
                              : null,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? 'Tap Pot, Stacks, Button, and Who Acts'
                : 'Pot · stacks · button · who acts',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: label the flop as made, draw, SDV, or air.
class FlopLabelDemo extends StatefulWidget {
  /// Creates the demo.
  const FlopLabelDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllLabelsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllLabelsTapped;

  static const labels = <({String label, String caption, Color color})>[
    (label: 'MADE', caption: 'Already strong', color: AppColors.gold),
    (label: 'DRAW', caption: 'Need a card', color: AppColors.cream),
    (label: 'SDV', caption: 'Showdown value', color: AppColors.slate),
    (label: 'AIR', caption: 'Nothing yet', color: AppColors.danger),
  ];

  @override
  State<FlopLabelDemo> createState() => _FlopLabelDemoState();
}

class _FlopLabelDemoState extends State<FlopLabelDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllLabelsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= FlopLabelDemo.labels.length) {
      widget.onAllLabelsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Label the flop before you bet',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _DemoActionCard(
                      label: FlopLabelDemo.labels[row * 2 + col].label,
                      caption: FlopLabelDemo.labels[row * 2 + col].caption,
                      color: FlopLabelDemo.labels[row * 2 + col].color,
                      selected: _tapped.contains(
                        FlopLabelDemo.labels[row * 2 + col].label,
                      ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () => _onTap(
                                FlopLabelDemo.labels[row * 2 + col].label,
                              )
                              : null,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? 'Tap Made, Draw, SDV, and Air'
                : 'Made · draw · showdown value · air',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: clean outs, dirty outs, and pricing the call.
class OutsPriceDemo extends StatefulWidget {
  /// Creates the demo.
  const OutsPriceDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'CLEAN', caption: 'Outs that help', color: AppColors.gold),
    (label: 'DIRTY', caption: 'Second-best risk', color: AppColors.danger),
    (label: 'PRICE', caption: 'Is the call worth it?', color: AppColors.cream),
  ];

  @override
  State<OutsPriceDemo> createState() => _OutsPriceDemoState();
}

class _OutsPriceDemoState extends State<OutsPriceDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= OutsPriceDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Outs and call price',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < OutsPriceDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: OutsPriceDemo.points[i].label,
                    caption: OutsPriceDemo.points[i].caption,
                    color: OutsPriceDemo.points[i].color,
                    selected: _tapped.contains(OutsPriceDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(OutsPriceDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? 'Tap Clean, Dirty, and Price'
                : 'Clean outs · dirty outs · price the call',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: flop line menu (value through raise) — one plan.
class FlopLinesDemo extends StatefulWidget {
  /// Creates the demo.
  const FlopLinesDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllLinesTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllLinesTapped;

  static const lines = <({String label, String caption, Color color})>[
    (label: 'VALUE', caption: 'Get paid', color: AppColors.gold),
    (label: 'C-BET', caption: 'Continue story', color: AppColors.cream),
    (label: 'CHECK', caption: 'Check back', color: AppColors.slate),
    (label: 'CALL', caption: 'Realize equity', color: AppColors.cream),
    (label: 'FOLD', caption: 'Give up', color: AppColors.danger),
    (label: 'RAISE', caption: 'Apply pressure', color: AppColors.gold),
  ];

  @override
  State<FlopLinesDemo> createState() => _FlopLinesDemoState();
}

class _FlopLinesDemoState extends State<FlopLinesDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllLinesTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= FlopLinesDemo.lines.length) {
      widget.onAllLinesTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Flop lines — pick one plan',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var col = 0; col < 3; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _DemoActionCard(
                      label: FlopLinesDemo.lines[row * 3 + col].label,
                      caption: FlopLinesDemo.lines[row * 3 + col].caption,
                      color: FlopLinesDemo.lines[row * 3 + col].color,
                      selected: _tapped.contains(
                        FlopLinesDemo.lines[row * 3 + col].label,
                      ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () => _onTap(
                                FlopLinesDemo.lines[row * 3 + col].label,
                              )
                              : null,
                    ),
                  ),
                ],
              ],
            ),
          ],
          // Interactive: Rex / coach status already says tap each once —
          // avoid a duplicate cue under the grid.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Value · c-bet · check · call · fold · raise',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: turn brick vs change; barrel or delay with intent.
class TurnStoryDemo extends StatefulWidget {
  /// Creates the demo.
  const TurnStoryDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'BRICK', caption: 'Story unchanged', color: AppColors.slate),
    (label: 'CHANGE', caption: 'New story', color: AppColors.cream),
    (label: 'BARREL', caption: 'Fire again', color: AppColors.gold),
    (label: 'DELAY', caption: 'Intentional pause', color: AppColors.danger),
  ];

  @override
  State<TurnStoryDemo> createState() => _TurnStoryDemoState();
}

class _TurnStoryDemoState extends State<TurnStoryDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= TurnStoryDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Turn: brick or change the story',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _DemoActionCard(
                      label: TurnStoryDemo.points[row * 2 + col].label,
                      caption: TurnStoryDemo.points[row * 2 + col].caption,
                      color: TurnStoryDemo.points[row * 2 + col].color,
                      selected: _tapped.contains(
                        TurnStoryDemo.points[row * 2 + col].label,
                      ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () => _onTap(
                                TurnStoryDemo.points[row * 2 + col].label,
                              )
                              : null,
                    ),
                  ),
                ],
              ],
            ),
          ],
          // Interactive: Rex already cues the four taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Brick · change · barrel · delay with intent',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: river is binary — value, bluff, catch, or fold.
class RiverBinaryDemo extends StatefulWidget {
  /// Creates the demo.
  const RiverBinaryDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'VALUE', caption: 'Get paid', color: AppColors.gold),
    (label: 'BLUFF', caption: 'Make them fold', color: AppColors.cream),
    (label: 'CATCH', caption: 'Bluff-catch', color: AppColors.slate),
    (label: 'FOLD', caption: 'No mystery float', color: AppColors.danger),
  ];

  @override
  State<RiverBinaryDemo> createState() => _RiverBinaryDemoState();
}

class _RiverBinaryDemoState extends State<RiverBinaryDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= RiverBinaryDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'River is binary',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _DemoActionCard(
                      label: RiverBinaryDemo.points[row * 2 + col].label,
                      caption: RiverBinaryDemo.points[row * 2 + col].caption,
                      color: RiverBinaryDemo.points[row * 2 + col].color,
                      selected: _tapped.contains(
                        RiverBinaryDemo.points[row * 2 + col].label,
                      ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () => _onTap(
                                RiverBinaryDemo.points[row * 2 + col].label,
                              )
                              : null,
                    ),
                  ),
                ],
              ],
            ),
          ],
          // Interactive: Rex already cues the four taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Value · bluff · bluff-catch · fold',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}



/// Explain-step demo: multiway adjustments (stronger / fewer bluffs / nuts).
class MultiwayPlanDemo extends StatefulWidget {
  /// Creates the demo.
  const MultiwayPlanDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'STRONGER', caption: 'Value up', color: AppColors.gold),
    (label: 'FEWER', caption: 'Bluffs down', color: AppColors.slate),
    (label: 'NUTS', caption: 'Not second-best', color: AppColors.cream),
  ];

  @override
  State<MultiwayPlanDemo> createState() => _MultiwayPlanDemoState();
}

class _MultiwayPlanDemoState extends State<MultiwayPlanDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= MultiwayPlanDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Multiway adjustments',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < MultiwayPlanDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: MultiwayPlanDemo.points[i].label,
                    caption: MultiwayPlanDemo.points[i].caption,
                    color: MultiwayPlanDemo.points[i].color,
                    selected:
                        _tapped.contains(MultiwayPlanDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(MultiwayPlanDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Stronger value · fewer bluffs · chase nuts',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: four common live leaks to recognize and avoid.
class CommonLeaksDemo extends StatefulWidget {
  /// Creates the demo.
  const CommonLeaksDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllLeaksTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllLeaksTapped;

  static const leaks = <({String label, String caption, Color color})>[
    (label: 'TOP PAIR', caption: 'Worshipping one pair', color: AppColors.gold),
    (label: 'PRICES', caption: 'Chase bad prices', color: AppColors.cream),
    (label: 'PASSIVE', caption: 'Call too soft', color: AppColors.slate),
    (label: 'CROWDS', caption: 'Bluff multiway', color: AppColors.danger),
  ];

  @override
  State<CommonLeaksDemo> createState() => _CommonLeaksDemoState();
}

class _CommonLeaksDemoState extends State<CommonLeaksDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllLeaksTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= CommonLeaksDemo.leaks.length) {
      widget.onAllLeaksTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Common live leaks',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _DemoActionCard(
                      label: CommonLeaksDemo.leaks[row * 2 + col].label,
                      caption: CommonLeaksDemo.leaks[row * 2 + col].caption,
                      color: CommonLeaksDemo.leaks[row * 2 + col].color,
                      selected: _tapped.contains(
                        CommonLeaksDemo.leaks[row * 2 + col].label,
                      ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed:
                          widget.interactive
                              ? () => _onTap(
                                CommonLeaksDemo.leaks[row * 2 + col].label,
                              )
                              : null,
                    ),
                  ),
                ],
              ],
            ),
          ],
          // Interactive: Rex already cues tap-each — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Top pair · bad prices · passive calls · bluff crowds',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: think in ranges, then update — not one hand.
class RangeUpdateDemo extends StatefulWidget {
  /// Creates the demo.
  const RangeUpdateDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'ONE HAND', caption: 'You never know it', color: AppColors.danger),
    (label: 'RANGE', caption: 'What they can have', color: AppColors.gold),
    (label: 'UPDATE', caption: 'Each action revises', color: AppColors.cream),
  ];

  @override
  State<RangeUpdateDemo> createState() => _RangeUpdateDemoState();
}

class _RangeUpdateDemoState extends State<RangeUpdateDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= RangeUpdateDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Ranges, not one hand',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < RangeUpdateDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: RangeUpdateDemo.points[i].label,
                    caption: RangeUpdateDemo.points[i].caption,
                    color: RangeUpdateDemo.points[i].color,
                    selected: _tapped.contains(RangeUpdateDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(RangeUpdateDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Never one hand · know a range · then update',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Explain-step demo: 3-bets define ranges; squeezes punish multiway flats.
class ThreeBetSqueezeDemo extends StatefulWidget {
  /// Creates the demo.
  const ThreeBetSqueezeDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: '3-BET', caption: 'Reopen the pot', color: AppColors.gold),
    (label: 'RANGES', caption: 'Defines both sides', color: AppColors.cream),
    (label: 'SQUEEZE', caption: 'Punish multiway flats', color: AppColors.danger),
  ];

  @override
  State<ThreeBetSqueezeDemo> createState() => _ThreeBetSqueezeDemoState();
}

/// Flop / turn / river plan tiles for multi-street explain demos.
class MultiStreetPlanDemo extends StatefulWidget {
  /// Creates the demo.
  const MultiStreetPlanDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'FLOP', caption: 'Choose with a plan', color: AppColors.gold),
    (label: 'TURN', caption: 'Know your next bet', color: AppColors.cream),
    (label: 'RIVER', caption: 'Finish the story', color: AppColors.danger),
  ];

  @override
  State<MultiStreetPlanDemo> createState() => _MultiStreetPlanDemoState();
}

class _ThreeBetSqueezeDemoState extends State<ThreeBetSqueezeDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= ThreeBetSqueezeDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            '3-bets and squeezes',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < ThreeBetSqueezeDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: ThreeBetSqueezeDemo.points[i].label,
                    caption: ThreeBetSqueezeDemo.points[i].caption,
                    color: ThreeBetSqueezeDemo.points[i].color,
                    selected: _tapped.contains(
                      ThreeBetSqueezeDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(ThreeBetSqueezeDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              '3-bets define ranges · squeezes punish flats',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

class _MultiStreetPlanDemoState extends State<MultiStreetPlanDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= MultiStreetPlanDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Plan every street',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < MultiStreetPlanDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: MultiStreetPlanDemo.points[i].label,
                    caption: MultiStreetPlanDemo.points[i].caption,
                    color: MultiStreetPlanDemo.points[i].color,
                    selected: _tapped.contains(
                      MultiStreetPlanDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () =>
                                _onTap(MultiStreetPlanDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Flop choice answers turn and river',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Value / pressure / size tiles for sizing-language explain demos.
class SizingLanguageDemo extends StatefulWidget {
  /// Creates the demo.
  const SizingLanguageDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'VALUE', caption: 'Looks like value', color: AppColors.gold),
    (label: 'PRESSURE', caption: 'Looks like pressure', color: AppColors.danger),
    (label: 'SIZE', caption: 'Says which story', color: AppColors.cream),
  ];

  @override
  State<SizingLanguageDemo> createState() => _SizingLanguageDemoState();
}

class _SizingLanguageDemoState extends State<SizingLanguageDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= SizingLanguageDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Size is language',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < SizingLanguageDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: SizingLanguageDemo.points[i].label,
                    caption: SizingLanguageDemo.points[i].caption,
                    color: SizingLanguageDemo.points[i].color,
                    selected: _tapped.contains(
                      SizingLanguageDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(SizingLanguageDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Value looks like value · pressure looks like pressure',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// SPR / low / high tiles for stack-to-pot explain demos.
class SprDepthDemo extends StatefulWidget {
  /// Creates the demo.
  const SprDepthDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'SPR', caption: 'Stack ÷ pot', color: AppColors.gold),
    (label: 'LOW', caption: 'Commit', color: AppColors.danger),
    (label: 'HIGH', caption: 'Maneuver', color: AppColors.cream),
  ];

  @override
  State<SprDepthDemo> createState() => _SprDepthDemoState();
}

class _SprDepthDemoState extends State<SprDepthDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= SprDepthDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Stack-to-pot ratio',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < SprDepthDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: SprDepthDemo.points[i].label,
                    caption: SprDepthDemo.points[i].caption,
                    color: SprDepthDemo.points[i].color,
                    selected: _tapped.contains(SprDepthDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(SprDepthDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Low SPR: commit · High SPR: maneuver',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Enters / calls / folds tiles for player-observe explain demos.
class PlayerObserveDemo extends StatefulWidget {
  /// Creates the demo.
  const PlayerObserveDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'ENTERS', caption: 'Who plays pots', color: AppColors.gold),
    (label: 'CALLS', caption: 'Who sticks around', color: AppColors.cream),
    (label: 'FOLDS', caption: 'Who gives up', color: AppColors.danger),
  ];

  @override
  State<PlayerObserveDemo> createState() => _PlayerObserveDemoState();
}

class _PlayerObserveDemoState extends State<PlayerObserveDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= PlayerObserveDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Watch before you label',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < PlayerObserveDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: PlayerObserveDemo.points[i].label,
                    caption: PlayerObserveDemo.points[i].caption,
                    color: PlayerObserveDemo.points[i].color,
                    selected: _tapped.contains(
                      PlayerObserveDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(PlayerObserveDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Count samples before you tag',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Station / high / low tiles for Calling Station explain demos.
class CallingStationDemo extends StatefulWidget {
  /// Creates the demo.
  const CallingStationDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'STATION', caption: 'Working model', color: AppColors.gold),
    (label: 'HIGH', caption: 'Plays many pots', color: AppColors.cream),
    (label: 'LOW', caption: 'Rarely folds', color: AppColors.danger),
  ];

  @override
  State<CallingStationDemo> createState() => _CallingStationDemoState();
}

class _CallingStationDemoState extends State<CallingStationDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= CallingStationDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Calling Station',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < CallingStationDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: CallingStationDemo.points[i].label,
                    caption: CallingStationDemo.points[i].caption,
                    color: CallingStationDemo.points[i].color,
                    selected: _tapped.contains(
                      CallingStationDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(CallingStationDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'High participation · low folding',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Value / bluffs / cite tiles for versus-station explain demos.
class VsStationDemo extends StatefulWidget {
  /// Creates the demo.
  const VsStationDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'VALUE', caption: 'Thicker value', color: AppColors.gold),
    (label: 'BLUFFS', caption: 'Fewer pure bluffs', color: AppColors.danger),
    (label: 'CITE', caption: 'Their calling', color: AppColors.cream),
  ];

  @override
  State<VsStationDemo> createState() => _VsStationDemoState();
}

class _VsStationDemoState extends State<VsStationDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= VsStationDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Versus Calling Stations',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < VsStationDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: VsStationDemo.points[i].label,
                    caption: VsStationDemo.points[i].caption,
                    color: VsStationDemo.points[i].color,
                    selected: _tapped.contains(VsStationDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(VsStationDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? 'Tap Value, Bluffs, and Cite'
                : 'Value wider · bluff less · cite calling',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}



/// Explain-step demo: tight seats rarely enter; when they do, they mean it.
class TightSeatsDemo extends StatefulWidget {
  /// Creates the demo.
  const TightSeatsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'RARE', caption: 'Almost never enter', color: AppColors.slate),
    (label: 'ENTER', caption: 'When they do', color: AppColors.cream),
    (label: 'MEAN IT', caption: 'Note both', color: AppColors.gold),
  ];

  @override
  State<TightSeatsDemo> createState() => _TightSeatsDemoState();
}

class _TightSeatsDemoState extends State<TightSeatsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= TightSeatsDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Tight seats',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < TightSeatsDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: TightSeatsDemo.points[i].label,
                    caption: TightSeatsDemo.points[i].caption,
                    color: TightSeatsDemo.points[i].color,
                    selected: _tapped.contains(
                      TightSeatsDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(TightSeatsDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Rare entries · when they do, they mean it',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Nit / narrow / respect tiles for Nit-model explain demos.
class NitModelDemo extends StatefulWidget {
  /// Creates the demo.
  const NitModelDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'NIT', caption: 'Working label', color: AppColors.gold),
    (label: 'NARROW', caption: 'Rarely enters', color: AppColors.cream),
    (label: 'RESPECT', caption: 'Heavy action means it', color: AppColors.danger),
  ];

  @override
  State<NitModelDemo> createState() => _NitModelDemoState();
}

class _NitModelDemoState extends State<NitModelDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= NitModelDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Nit model',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < NitModelDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: NitModelDemo.points[i].label,
                    caption: NitModelDemo.points[i].caption,
                    color: NitModelDemo.points[i].color,
                    selected: _tapped.contains(NitModelDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(NitModelDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Narrow entry · respect heavy action',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Steal / credit / explode tiles for versus-nits explain demos.
class VsNitsDemo extends StatefulWidget {
  /// Creates the demo.
  const VsNitsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'STEAL', caption: 'Blinds more often', color: AppColors.gold),
    (label: 'CREDIT', caption: 'When they fire', color: AppColors.cream),
    (label: 'EXPLODE', caption: 'Believe the heat', color: AppColors.danger),
  ];

  @override
  State<VsNitsDemo> createState() => _VsNitsDemoState();
}

class _VsNitsDemoState extends State<VsNitsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= VsNitsDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Versus Nits',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < VsNitsDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: VsNitsDemo.points[i].label,
                    caption: VsNitsDemo.points[i].caption,
                    color: VsNitsDemo.points[i].color,
                    selected: _tapped.contains(VsNitsDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(VsNitsDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Steal more · give credit when they explode',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Raise / barrel / count tiles for extreme-entry explain demos.
class ExtremeEntryDemo extends StatefulWidget {
  /// Creates the demo.
  const ExtremeEntryDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'RAISE', caption: 'Enters with aggression', color: AppColors.gold),
    (label: 'BARREL', caption: 'Keeps firing streets', color: AppColors.danger),
    (label: 'COUNT', caption: 'Sample calmly', color: AppColors.cream),
  ];

  @override
  State<ExtremeEntryDemo> createState() => _ExtremeEntryDemoState();
}

class _ExtremeEntryDemoState extends State<ExtremeEntryDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= ExtremeEntryDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Extreme entry',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < ExtremeEntryDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: ExtremeEntryDemo.points[i].label,
                    caption: ExtremeEntryDemo.points[i].caption,
                    color: ExtremeEntryDemo.points[i].color,
                    selected: _tapped.contains(
                      ExtremeEntryDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(ExtremeEntryDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Raise and barrel · count calmly',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Maniac / entry / aggro tiles for Maniac-model explain demos.
class ManiacModelDemo extends StatefulWidget {
  /// Creates the demo.
  const ManiacModelDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'MANIAC', caption: 'Working model', color: AppColors.gold),
    (label: 'ENTRY', caption: 'Extreme frequency', color: AppColors.cream),
    (label: 'AGGRO', caption: 'Not an insult', color: AppColors.danger),
  ];

  @override
  State<ManiacModelDemo> createState() => _ManiacModelDemoState();
}

class _ManiacModelDemoState extends State<ManiacModelDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= ManiacModelDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Maniac model',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < ManiacModelDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: ManiacModelDemo.points[i].label,
                    caption: ManiacModelDemo.points[i].caption,
                    color: ManiacModelDemo.points[i].color,
                    selected: _tapped.contains(ManiacModelDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(ManiacModelDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Extreme entry · aggression · a model',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Wider / hang / ego tiles for versus-maniacs explain demos.
class VsManiacsDemo extends StatefulWidget {
  /// Creates the demo.
  const VsManiacsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'WIDER', caption: 'Call for value', color: AppColors.gold),
    (label: 'HANG', caption: 'Let them fire', color: AppColors.cream),
    (label: 'EGO', caption: 'Leave it home', color: AppColors.danger),
  ];

  @override
  State<VsManiacsDemo> createState() => _VsManiacsDemoState();
}

class _VsManiacsDemoState extends State<VsManiacsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= VsManiacsDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Versus Maniacs',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < VsManiacsDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: VsManiacsDemo.points[i].label,
                    caption: VsManiacsDemo.points[i].caption,
                    color: VsManiacsDemo.points[i].color,
                    selected: _tapped.contains(VsManiacsDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(VsManiacsDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Call wider · let them hang · no ego',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Versus TAG: respect heat, steal less than vs nits, no light rebluffs.
class VsTagsDemo extends StatefulWidget {
  /// Creates the demo.
  const VsTagsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'CREDIT', caption: 'Respect raises', color: AppColors.gold),
    (label: 'TIGHTER', caption: 'Steal less vs TAG', color: AppColors.cream),
    (label: 'NO LIGHT', caption: 'Skip rebluff XR', color: AppColors.danger),
  ];

  @override
  State<VsTagsDemo> createState() => _VsTagsDemoState();
}

class _VsTagsDemoState extends State<VsTagsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= VsTagsDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Versus TAGs',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < VsTagsDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: VsTagsDemo.points[i].label,
                    caption: VsTagsDemo.points[i].caption,
                    color: VsTagsDemo.points[i].color,
                    selected: _tapped.contains(VsTagsDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(VsTagsDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues Credit / Tighter / No light.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Respect heat · steal less · no light XR',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Versus LAG: trap more, call wider, invent fewer fancy bluffs.
class VsLagsDemo extends StatefulWidget {
  /// Creates the demo.
  const VsLagsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'CALL', caption: 'Call wider', color: AppColors.gold),
    (label: 'TRAP', caption: 'Trap more', color: AppColors.cream),
    (label: 'FANCY LESS', caption: 'Invent less', color: AppColors.danger),
  ];

  @override
  State<VsLagsDemo> createState() => _VsLagsDemoState();
}

class _VsLagsDemoState extends State<VsLagsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= VsLagsDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Versus LAGs',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < VsLagsDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: VsLagsDemo.points[i].label,
                    caption: VsLagsDemo.points[i].caption,
                    color: VsLagsDemo.points[i].color,
                    selected: _tapped.contains(VsLagsDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(VsLagsDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues Call / Trap / Fancy less.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Trap more · call wider · fancy less',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Observe / samples / showdowns tiles for certainty explain demos.
class ObservationCertaintyDemo extends StatefulWidget {
  /// Creates the demo.
  const ObservationCertaintyDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'OBSERVE', caption: 'Not certainty yet', color: AppColors.gold),
    (label: 'SAMPLES', caption: 'Confidence grows', color: AppColors.cream),
    (label: 'SHOWDOWNS', caption: 'Hard evidence', color: AppColors.danger),
  ];

  @override
  State<ObservationCertaintyDemo> createState() =>
      _ObservationCertaintyDemoState();
}

class _ObservationCertaintyDemoState extends State<ObservationCertaintyDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= ObservationCertaintyDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Observation ≠ certainty',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0;
                  i < ObservationCertaintyDemo.points.length;
                  i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: ObservationCertaintyDemo.points[i].label,
                    caption: ObservationCertaintyDemo.points[i].caption,
                    color: ObservationCertaintyDemo.points[i].color,
                    selected: _tapped.contains(
                      ObservationCertaintyDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(
                              ObservationCertaintyDemo.points[i].label,
                            )
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Samples and showdowns grow confidence',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Cards / seats / evidence tiles for exploit-evidence explain demos.
class ExploitEvidenceDemo extends StatefulWidget {
  /// Creates the demo.
  const ExploitEvidenceDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'CARDS', caption: 'Same holdings', color: AppColors.gold),
    (label: 'SEATS', caption: 'Different types', color: AppColors.cream),
    (label: 'EVIDENCE', caption: 'Exploits need proof', color: AppColors.danger),
  ];

  @override
  State<ExploitEvidenceDemo> createState() => _ExploitEvidenceDemoState();
}

class _ExploitEvidenceDemoState extends State<ExploitEvidenceDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= ExploitEvidenceDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Exploits need evidence',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < ExploitEvidenceDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: ExploitEvidenceDemo.points[i].label,
                    caption: ExploitEvidenceDemo.points[i].caption,
                    color: ExploitEvidenceDemo.points[i].color,
                    selected: _tapped.contains(
                      ExploitEvidenceDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () =>
                                _onTap(ExploitEvidenceDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Same cards · different seats · evidence',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Nutted / air / domination tiles for multiway-nuts explain demos.
class MultiwayNutsDemo extends StatefulWidget {
  /// Creates the demo.
  const MultiwayNutsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'NUTTED', caption: 'Hands go up', color: AppColors.gold),
    (label: 'AIR', caption: 'Hands go down', color: AppColors.cream),
    (label: 'DOMINATION', caption: 'Hurts more multiway', color: AppColors.danger),
  ];

  @override
  State<MultiwayNutsDemo> createState() => _MultiwayNutsDemoState();
}

class _MultiwayNutsDemoState extends State<MultiwayNutsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= MultiwayNutsDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Multiway nut preference',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < MultiwayNutsDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: MultiwayNutsDemo.points[i].label,
                    caption: MultiwayNutsDemo.points[i].caption,
                    color: MultiwayNutsDemo.points[i].color,
                    selected: _tapped.contains(MultiwayNutsDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(MultiwayNutsDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Nutted up · air down · domination hurts',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Deep / realize / stack tiles for deep-stacks explain demos.
class DeepStacksDemo extends StatefulWidget {
  /// Creates the demo.
  const DeepStacksDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'DEEP', caption: 'More room to play', color: AppColors.gold),
    (label: 'REALIZE', caption: 'Implied odds grow', color: AppColors.cream),
    (label: 'STACK', caption: 'More room to lose', color: AppColors.danger),
  ];

  @override
  State<DeepStacksDemo> createState() => _DeepStacksDemoState();
}

class _DeepStacksDemoState extends State<DeepStacksDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= DeepStacksDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Deep stack play',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < DeepStacksDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: DeepStacksDemo.points[i].label,
                    caption: DeepStacksDemo.points[i].caption,
                    color: DeepStacksDemo.points[i].color,
                    selected: _tapped.contains(DeepStacksDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(DeepStacksDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'More room to realize · and to lose',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


/// Implied / reverse / second tiles for implied-odds explain demos.
class ImpliedOddsDemo extends StatefulWidget {
  /// Creates the demo.
  const ImpliedOddsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'IMPLIED', caption: 'Future money', color: AppColors.gold),
    (label: 'REVERSE', caption: 'Future losses', color: AppColors.cream),
    (label: 'SECOND', caption: 'Second-best sting', color: AppColors.danger),
  ];

  @override
  State<ImpliedOddsDemo> createState() => _ImpliedOddsDemoState();
}

class _ImpliedOddsDemoState extends State<ImpliedOddsDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= ImpliedOddsDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Implied Odds',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < ImpliedOddsDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: ImpliedOddsDemo.points[i].label,
                    caption: ImpliedOddsDemo.points[i].caption,
                    color: ImpliedOddsDemo.points[i].color,
                    selected: _tapped.contains(ImpliedOddsDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(ImpliedOddsDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Future money · reverse when second-best',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Thin / catch / barrels tiles for thin-value explain demos.
class ThinValueDemo extends StatefulWidget {
  /// Creates the demo.
  const ThinValueDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'THIN', caption: 'Needs calls', color: AppColors.gold),
    (label: 'CATCH', caption: 'Bluff-catches', color: AppColors.cream),
    (label: 'BARRELS', caption: 'Need wide barrels', color: AppColors.danger),
  ];

  @override
  State<ThinValueDemo> createState() => _ThinValueDemoState();
}

class _ThinValueDemoState extends State<ThinValueDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= ThinValueDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Thin value & catches',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < ThinValueDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: ThinValueDemo.points[i].label,
                    caption: ThinValueDemo.points[i].caption,
                    color: ThinValueDemo.points[i].color,
                    selected: _tapped.contains(ThinValueDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(ThinValueDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Thin value needs calls · catches need barrels',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// X/R / probe / delay / donk tiles for line-stories explain demos.
class LineStoriesDemo extends StatefulWidget {
  /// Creates the demo.
  const LineStoriesDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'X/R', caption: 'Check-raise story', color: AppColors.gold),
    (label: 'PROBE', caption: 'Bet into checker', color: AppColors.cream),
    (label: 'DELAY', caption: 'Hold the aggression', color: AppColors.slate),
    (label: 'DONK', caption: 'Lead into raiser', color: AppColors.danger),
  ];

  @override
  State<LineStoriesDemo> createState() => _LineStoriesDemoState();
}

class _LineStoriesDemoState extends State<LineStoriesDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= LineStoriesDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Lines mean ranges',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < LineStoriesDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _DemoActionCard(
                    label: LineStoriesDemo.points[i].label,
                    caption: LineStoriesDemo.points[i].caption,
                    color: LineStoriesDemo.points[i].color,
                    selected: _tapped.contains(LineStoriesDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(LineStoriesDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the four taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Each line updates the story',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Action / rewrite / update tiles for range-rewrite explain demos.
class RangeRewriteDemo extends StatefulWidget {
  /// Creates the demo.
  const RangeRewriteDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'ACTION', caption: 'Every bet rewrites', color: AppColors.gold),
    (label: 'REWRITE', caption: 'Range changes', color: AppColors.cream),
    (label: 'UPDATE', caption: 'Keep doing it', color: AppColors.danger),
  ];

  @override
  State<RangeRewriteDemo> createState() => _RangeRewriteDemoState();
}

class _RangeRewriteDemoState extends State<RangeRewriteDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= RangeRewriteDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Ranges keep moving',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < RangeRewriteDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: RangeRewriteDemo.points[i].label,
                    caption: RangeRewriteDemo.points[i].caption,
                    color: RangeRewriteDemo.points[i].color,
                    selected: _tapped.contains(RangeRewriteDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(RangeRewriteDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Each action rewrites the range',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Timing / sizing / clues tiles for timing-clues explain demos.
class TimingCluesDemo extends StatefulWidget {
  /// Creates the demo.
  const TimingCluesDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'TIMING', caption: 'Soft evidence', color: AppColors.gold),
    (label: 'SIZING', caption: 'Soft evidence', color: AppColors.cream),
    (label: 'CLUES', caption: 'Not mind-reading', color: AppColors.danger),
  ];

  @override
  State<TimingCluesDemo> createState() => _TimingCluesDemoState();
}

class _TimingCluesDemoState extends State<TimingCluesDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= TimingCluesDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Clues, not mind-reading',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < TimingCluesDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: TimingCluesDemo.points[i].label,
                    caption: TimingCluesDemo.points[i].caption,
                    color: TimingCluesDemo.points[i].color,
                    selected: _tapped.contains(TimingCluesDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(TimingCluesDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Small updates only',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Stuck / tilted / gears tiles for tables-change explain demos.
class TablesChangeDemo extends StatefulWidget {
  /// Creates the demo.
  const TablesChangeDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'STUCK', caption: 'Same old gear', color: AppColors.gold),
    (label: 'TILTED', caption: 'Emotion leak', color: AppColors.cream),
    (label: 'GEARS', caption: 'Shifting play', color: AppColors.danger),
  ];

  @override
  State<TablesChangeDemo> createState() => _TablesChangeDemoState();
}

class _TablesChangeDemoState extends State<TablesChangeDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= TablesChangeDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Tables change',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < TablesChangeDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DemoActionCard(
                    label: TablesChangeDemo.points[i].label,
                    caption: TablesChangeDemo.points[i].caption,
                    color: TablesChangeDemo.points[i].color,
                    selected: _tapped.contains(TablesChangeDemo.points[i].label),
                    enabled: widget.interactive && widget.enabled,
                    onPressed:
                        widget.interactive
                            ? () => _onTap(TablesChangeDemo.points[i].label)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues the three taps — no duplicate footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Update when the table shifts',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


class _DemoSoftPulse extends StatefulWidget {
  const _DemoSoftPulse({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_DemoSoftPulse> createState() => _DemoSoftPulseState();
}

class _DemoSoftPulseState extends State<_DemoSoftPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.active) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _DemoSoftPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.active && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = 0.22 + (_pulse.value * 0.38);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: glow * 0.55),
                blurRadius: 10 + (_pulse.value * 6),
                spreadRadius: 0.4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _DemoActionCard extends StatelessWidget {
  const _DemoActionCard({
    required this.label,
    required this.caption,
    required this.color,
    this.selected = false,
    this.enabled = false,
    this.onPressed,
  });

  final String label;
  final String caption;
  final Color color;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.gold : color.withValues(alpha: 0.9);
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.28)
                : color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: selected ? 2 : 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (onPressed == null) return child;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}

/// Mini felt showing pot, optional villain bet, board, and hero holes.
class LessonActionTable extends StatelessWidget {
  /// Creates the table.
  const LessonActionTable({super.key, required this.spot});

  final LessonActionSpot spot;

  @override
  Widget build(BuildContext context) {
    final hero = <CardModel>[];
    for (final code in spot.heroCodes) {
      try {
        hero.add(CardModel.fromCode(code));
      } catch (_) {}
    }
    final board = <CardModel>[];
    for (final code in spot.boardCodes) {
      try {
        board.add(CardModel.fromCode(code));
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          if (spot.streetLabel != null)
            Text(
              spot.streetLabel!,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (spot.villainLine != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgDark.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                spot.villainLine!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _PotChip(label: spot.potLabel),
              if (spot.stackLabel != null) _PotChip(label: spot.stackLabel!),
            ],
          ),
          if (board.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < board.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  MiniCard(card: board[i], size: MiniCardSize.small),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'You',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < hero.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                MiniCard(card: hero[i], size: MiniCardSize.small),
              ],
            ],
          ),
          if (spot.feltStatusLine != null) ...[
            const SizedBox(height: 8),
            Text(
              spot.feltStatusLine!,
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else if (spot.facingBet) ...[
            const SizedBox(height: 8),
            Text(
              'A bet faces you',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else if (spot.openPot) ...[
            const SizedBox(height: 8),
            Text(
              // Preflop first-in is an open-raise; postflop open is a bet.
              spot.streetLabel?.toLowerCase().contains('preflop') == true
                  ? 'First in — open the pot'
                  : 'Pot is open to a bet',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else if (spot.streetLabel?.toLowerCase().contains('hand over') ==
              true) ...[
            const SizedBox(height: 8),
            Text(
              'Uncontested — stack the chips',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'No bet to match',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PotChip extends StatelessWidget {
  const _PotChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
              border: Border.all(color: AppColors.bgDark, width: 1.2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live-style action dock buttons for course choices.
class LessonActionDock extends StatelessWidget {
  /// Creates the dock.
  const LessonActionDock({
    super.key,
    required this.choices,
    required this.selectedId,
    required this.enabled,
    required this.onSelect,
    this.identifyUnavailable = false,
    this.facingBet = false,
    this.heroStackAmount,
    this.pulseChoiceId,
  });

  final List<CourseChoice> choices;
  final String? selectedId;
  final bool enabled;
  final ValueChanged<String> onSelect;
  final bool identifyUnavailable;

  /// When true, Check/Bet are illegal live — show (off) chrome for those.
  /// Ignored for [identifyUnavailable] quizzes so the illegal action is not
  /// spoiled before the learner taps.
  final bool facingBet;

  /// Hero chips remaining; Call amounts above this get (off) chrome.
  final int? heroStackAmount;

  /// Soft-pulse this choice id (guided teach-by-doing cue). Null = no pulse.
  final String? pulseChoiceId;

  static bool _isCheck(CourseChoice c) {
    final action = (c.action ?? c.label).toUpperCase();
    return action.startsWith('CHECK') || c.id.contains('check');
  }

  static bool _isCall(CourseChoice c) {
    final action = (c.action ?? c.label).toUpperCase();
    return action.startsWith('CALL') || c.id.contains('call');
  }

  static bool _isBet(CourseChoice c) {
    final action = (c.action ?? c.label).toUpperCase();
    // Action only — ids like raise-no-bet contain "bet".
    return action.startsWith('BET');
  }

  static bool _isRaise(CourseChoice c) {
    final action = (c.action ?? c.label).toUpperCase();
    return action.startsWith('RAISE');
  }

  static bool _isLimp(CourseChoice c) {
    final label = c.label.trim().toUpperCase();
    return label.startsWith('LIMP') || c.id.contains('limp');
  }

  static int? _chipAmountFromChoice(CourseChoice c) {
    final match = RegExp(r'(\d+)').firstMatch(c.label);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static bool _callExceedsStack(CourseChoice c, int? stack) {
    if (stack == null || !_isCall(c) || _isLimp(c)) return false;
    final amount = _chipAmountFromChoice(c);
    return amount != null && amount > stack;
  }

  @override
  Widget build(BuildContext context) {
    final hasBetChoice = choices.any(_isBet);
    return Row(
      children: [
        for (var i = 0; i < choices.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Builder(
              builder: (context) {
                final choice = choices[i];
                // Live dock chrome: Check/Bet off vs a bet; Call off with
                // nothing to match (except limps); Raise off only when the
                // open action is Bet (postflop), not a preflop open-raise.
                // Identify-unavailable quizzes keep every button looking live
                // so the learner must reason which action is illegal.
                // Short-stack Call amounts above remaining chips look off —
                // All-in is the live way to put the stack in.
                final unavailableLook =
                    !identifyUnavailable &&
                    ((_isCheck(choice) && facingBet) ||
                        (_isCall(choice) &&
                            !facingBet &&
                            !_isLimp(choice)) ||
                        _callExceedsStack(choice, heroStackAmount) ||
                        (_isBet(choice) && facingBet) ||
                        (_isRaise(choice) && !facingBet && hasBetChoice));
                return _DemoSoftPulse(
                  active:
                      enabled &&
                      pulseChoiceId != null &&
                      choice.id == pulseChoiceId &&
                      selectedId == null,
                  child: _DockButton(
                    choice: choice,
                    selected: selectedId == choice.id,
                    enabled: enabled,
                    unavailableLook: unavailableLook,
                    onPressed: () => onSelect(choice.id),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.choice,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    this.unavailableLook = false,
  });

  final CourseChoice choice;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;
  final bool unavailableLook;

  Color get _fill {
    final action = (choice.action ?? choice.label).toUpperCase();
    if (unavailableLook) {
      return AppColors.slateDark.withValues(alpha: 0.55);
    }
    if (action.startsWith('FOLD')) return AppColors.danger.withValues(alpha: 0.4);
    if (action.startsWith('ALL')) {
      return AppColors.danger.withValues(alpha: 0.45);
    }
    if (action.startsWith('RAISE') || action.startsWith('BET')) {
      return AppColors.gold.withValues(alpha: 0.28);
    }
    return AppColors.surfaceMuted.withValues(alpha: 0.55);
  }

  Color get _border {
    if (selected) return AppColors.gold;
    if (unavailableLook) return AppColors.slate;
    final action = (choice.action ?? choice.label).toUpperCase();
    if (action.startsWith('FOLD') || action.startsWith('ALL')) {
      return AppColors.danger;
    }
    if (action.startsWith('RAISE') || action.startsWith('BET')) {
      return AppColors.gold;
    }
    return AppColors.feltBorder;
  }

  @override
  Widget build(BuildContext context) {
    final action = (choice.action ?? choice.label).toUpperCase();
    final authored = choice.label.trim().toUpperCase();
    final authoredWords = authored.split(RegExp(r'\s+'));
    // Prefer multi-word teaching labels (Raise to 6, See flop, Jam 100bb).
    // Keep Check/Fold chrome short even when content adds a caption word.
    final preferAuthoredLabel = authoredWords.length >= 2 &&
        authoredWords.first != 'CHECK' &&
        authoredWords.first != 'FOLD';
    final short =
        unavailableLook
            ? switch (action.split(' ').first) {
              'CALL' => 'CALL (off)',
              'BET' => 'BET (off)',
              'RAISE' => 'RAISE (off)',
              _ => 'CHECK (off)',
            }
            : preferAuthoredLabel
            ? authored
            : action.startsWith('ALL')
            ? (authored.contains('12') ? 'ALL-IN 12' : 'ALL-IN')
            : switch (action.split(' ').first) {
              'FOLD' => 'FOLD',
              'CHECK' => 'CHECK',
              // Keep limp chrome explicit — CALL alone hides the teachable
              // mistake of limping first-in.
              'CALL' =>
                authored.startsWith('LIMP')
                    ? authored
                    : authored.startsWith('CALL')
                    ? authored
                    : 'CALL',
              'RAISE' => authored.startsWith('RAISE') ? authored : 'RAISE',
              'BET' => authored.startsWith('BET') ? authored : 'BET',
              _ => authored,
            };
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: choice.accessibilityText ??
          [if (choice.action != null) choice.action!, choice.label].join(' '),
      child: Material(
        color: _fill,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _border,
                width: selected ? 2.2 : 1.4,
              ),
            ),
            child: Text(
              short,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: unavailableLook ? AppColors.slate : AppColors.cream,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                height: 1.15,
                decoration:
                    unavailableLook ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.slate,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
