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
        // Jump: structural only — not “trash folds” / “open the pot”.
        feltStatusLine: 'First in · your action',
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
        // Rex names the spot — no gold spoiler echoing hand strength.
      );
    case 'act-02-04-01-checkpoint-aq':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Qh'],
        potLabel: 'Pot 3 → 9',
        villainLine: 'HJ opens to 6',
        streetLabel: 'Preflop · Cutoff · 1/2',
        facingBet: true,
        // Checkpoint: cards + villain line teach; no strength spoiler.
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
        // Structural — Rex owns TPTK / value SoftPulse cue.
        streetLabel: 'Flop · Heads-up',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you',
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
        // Structural — Rex owns “Set multiway”; don’t spoil Raise.
        streetLabel: 'Flop · Multiway',
        facingBet: true,
        feltStatusLine: 'Facing a bet',
      );
    case 'act-03-04-01-checkpoint':
      return const LessonActionSpot(
        heroCodes: ['5h', '2d'],
        boardCodes: ['Ah', '7c', '2s'],
        potLabel: 'Pot 30',
        villainLine: 'Bet · raise ahead',
        // Structural — don’t tip Fold with “weak one pair.”
        streetLabel: 'Flop · Multiway',
        facingBet: true,
        feltStatusLine: 'Facing raise · multiway',
      );
    case 'act-03-05-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', '7d', '2c', '3h'],
        potLabel: 'Pot 20',
        villainLine: 'Called flop c-bet',
        // Structural — Rex owns brick / barrel SoftPulse cue.
        streetLabel: 'Turn · your holes',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Called flop c-bet',
      );
    case 'act-03-05-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        boardCodes: ['Kh', '7h', '2c', '3h'],
        potLabel: 'Pot 18',
        villainLine: 'Checked to you',
        // Structural — don’t tip delayed value on the felt.
        streetLabel: 'Turn · hearts',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you',
      );
    case 'act-03-06-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', 'Kc', '7d', '2h', '3c'],
        potLabel: 'Pot 28',
        villainLine: 'Checked to you',
        // Structural — Rex owns brick / value SoftPulse cue.
        streetLabel: 'River · brick',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you',
      );
    case 'act-03-06-01-scaffolded':
      // Offsuit non-hearts: hero missed the flush; river paints the story.
      return const LessonActionSpot(
        heroCodes: ['9s', '8s'],
        boardCodes: ['Kh', '7h', '2c', '3d', 'Ah'],
        potLabel: 'Pot 40',
        villainLine: 'Checked to you',
        // Structural — don’t tip Missed / bluff on the felt.
        streetLabel: 'River · flush completes',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you',
      );
    case 'act-03-06-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Ah', '4d'],
        boardCodes: ['As', '9c', '7d', '2h', '3c'],
        potLabel: 'Pot 50',
        villainLine: 'Jams all-in',
        // Structural — don’t tip Weak TPTK / fold on the felt.
        streetLabel: 'River · quiet line',
        facingBet: true,
        feltStatusLine: 'Jams all-in',
      );
    case 'act-03-07-01-guided':
      return const LessonActionSpot(
        heroCodes: ['7h', '9d'],
        boardCodes: ['Kc', '7s', '2d'],
        potLabel: 'Pot 16',
        villainLine: 'Checked to you · 4-way',
        // Structural — don’t tip Check / not auto-value on the felt.
        streetLabel: 'Flop · Multiway · Second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you · 4-way',
      );
    case 'act-03-07-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Ah', 'Kh', '9h'],
        potLabel: 'Pot 22',
        villainLine: 'Three callers behind',
        // Structural — don’t tip no-bluff on the felt.
        streetLabel: 'Flop · Wet · Missed',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Three callers behind',
      );
    case 'act-03-08-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Ah', '4d'],
        boardCodes: ['As', '9c', '7d'],
        potLabel: 'Pot 40',
        villainLine: 'Raise · reraise multiway',
        // Structural — don’t tip Fold / weak kicker on the felt.
        streetLabel: 'Flop · Weak TPTK · Heat',
        facingBet: true,
        feltStatusLine: 'Facing raise · multiway',
      );
    case 'act-03-08-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['As', '7c', '2d'],
        potLabel: 'Pot 12',
        villainLine: 'Bets 18',
        // Structural — don’t tip Fold / terrible price on the felt.
        streetLabel: 'Flop · Gutshot only',
        facingBet: true,
        feltStatusLine: 'Facing a bet',
      );
    case 'act-03-08-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['9h', '8d'],
        boardCodes: ['Kc', '7s', '2d'],
        potLabel: 'Pot 24',
        villainLine: 'Someone bets · 4-way',
        // Structural — don’t tip Fold on the felt.
        streetLabel: 'Flop · Air · Crowd',
        facingBet: true,
        feltStatusLine: 'Facing a bet · 4-way',
      );
    case 'act-03-08-02-jump-mw':
      return const LessonActionSpot(
        heroCodes: ['9h', '8d'],
        boardCodes: ['Ah', 'Kh', '7h'],
        potLabel: 'Pot 20',
        villainLine: 'Someone bets · 4-way',
        // Structural — don’t tip Fold air on the felt.
        streetLabel: 'Flop · Air · Wet',
        facingBet: true,
        feltStatusLine: 'Facing a bet · 4-way',
      );
    case 'act-03-08-02-jump-river':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', 'Kc', '7d', '2h', '3c'],
        potLabel: 'Pot 28',
        villainLine: 'Checked to you',
        // Structural — don’t tip value / Top two on the felt.
        streetLabel: 'River · brick',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you',
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
        feltStatusLine: 'Multiway — AKo in BB',
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
        feltStatusLine: 'One-chip value is a mistake',
      );
    case 'act-04-05-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Kd'],
        boardCodes: ['Kc', '7s', '2d'],
        potLabel: 'Pot ~60 · SPR ~1',
        villainLine: '3-bet pot · short SPR',
        // Structural — Rex owns commit SoftPulse cue; don’t gold-tip get-it-in.
        streetLabel: 'Flop · top set',
        facingBet: false,
        openPot: true,
        feltStatusLine: '3-bet pot · short SPR',
      );
    case 'act-04-05-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Qc', '9s', '3h'],
        potLabel: 'Pot 12 · SPR 20',
        villainLine: 'Multiway · deep stacks',
        // Structural — don’t tip Keep pot small on the felt.
        streetLabel: 'Flop · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Multiway · deep stacks',
      );
    case 'act-04-05-01-checkpoint':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', '7c', '2d', '9h'],
        potLabel: 'Pot 40 · SPR ~1.4',
        stackLabel: 'Stacks left 55',
        villainLine: 'Opponent jams all-in',
        // Structural — don’t tip Weigh SPR first on the felt.
        streetLabel: 'Turn · facing jam',
        facingBet: true,
        feltStatusLine: 'Opponent jams all-in',
      );
    case 'act-04-06-03-guided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 28',
        villainLine: 'Sticky caller · checked to you',
        // Structural — Rex + SoftPulse own thin-value teaching.
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Sticky caller · checked to you',
      );
    case 'act-04-06-03-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['8h', '7h'],
        boardCodes: ['Kc', '2s', '2d', '9c', '3d'],
        potLabel: 'Pot 24',
        villainLine: 'Same sticky seat · brick river',
        // Structural — don’t tip Give up on the felt.
        streetLabel: 'River · missed draw',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Same sticky seat · brick river',
      );
    case 'act-04-06-03-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 28',
        villainLine: 'Unknown · no samples yet',
        // Structural — don’t tip Keep it cautious on the felt.
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Unknown · no samples yet',
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
        // Structural — SoftPulse + Rex own Call / implied cue.
        streetLabel: 'Flop · gutshot + overs · 200bb',
        facingBet: true,
        feltStatusLine: 'Facing a bet',
      );
    case 'act-05-03-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Jd'],
        boardCodes: ['As', 'Th', '8h'],
        potLabel: 'Pot 36',
        villainLine: 'Nit check-raises huge',
        // Structural — SoftPulse + Rex own Fold / reverse-implied cue.
        streetLabel: 'Flop · KJo · A-high wet',
        facingBet: true,
        feltStatusLine: 'Facing a bet',
      );
    case 'act-05-03-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['7h', '6h'],
        boardCodes: ['Kh', '9h', '2c'],
        potLabel: 'Pot 44',
        villainLine: 'Four-way · bet into you',
        // Structural — don’t tip Fold on the felt.
        streetLabel: 'Flop · non-nut FD multiway',
        facingBet: true,
        feltStatusLine: 'Facing a bet · 4-way',
      );
    case 'act-05-04-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 32',
        villainLine: 'Calling Station checked twice',
        // Structural — Rex owns thin-value SoftPulse cue.
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you',
      );
    case 'act-05-04-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 48',
        villainLine: 'Maniac barrels river',
        // Structural — don’t tip Call / catch on the felt.
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Facing a bet',
      );
    case 'act-05-04-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 32',
        villainLine: 'Nit checked to you',
        // Structural — don’t tip Check back on the felt.
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you',
      );
    case 'act-05-05-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['9h', '8d'],
        boardCodes: ['Kc', '9s', '3h'],
        potLabel: 'Pot 14',
        villainLine: 'PFR checks flop',
        // Structural — SoftPulse + Rex own Probe small.
        streetLabel: 'Flop · middle pair · BB',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you',
      );
    case 'act-05-06-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['7h', '6h'],
        boardCodes: ['Kh', '9h', '2c', '3d'],
        potLabel: 'Pot 40',
        villainLine: 'Bombs turn after flop call',
        // Structural — SoftPulse + Rex own Fold.
        streetLabel: 'Turn · flush draw · brick',
        facingBet: true,
        feltStatusLine: 'Facing a bet',
      );
    case 'act-05-08-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 6',
        villainLine: 'Just stacked you · next hand',
        // Structural — don’t tip Fold on the felt.
        streetLabel: 'Next hand · steaming',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Next hand · after a cooler',
      );
    case 'act-05-09-02-cp-value':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 32',
        villainLine: 'Calling Station checked twice',
        // Structural — Rex + SoftPulse own thin-value teaching.
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked to you',
      );
    case 'act-05-09-02-cp-catch':
      return const LessonActionSpot(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '9s', '4h', '2d', '7c'],
        potLabel: 'Pot 48',
        villainLine: 'Maniac barrels river',
        // Structural — don’t tip Call / catch on the felt.
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Facing a bet',
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
        // Structural — Rex + SoftPulse own thin-value teaching.
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Checked turn · capped',
      );
    case 'act-06-04-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', '9s', '3h', '2d', '7c'],
        potLabel: 'Pot 36',
        villainLine: 'Calling station · checked',
        // Structural — Rex + SoftPulse own merged-size teaching.
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Calling station · checked',
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
        // Structural — Rex + SoftPulse own Fold cue.
        feltStatusLine: 'Bombs river · no blockers',
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
        // Structural — Rex + SoftPulse own Check mix cue.
        feltStatusLine: 'Checked to you · set',
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
        // Structural — Rex + SoftPulse own small c-bet cue.
        feltStatusLine: 'Checked to you · 180bb deep',
      );
    case 'act-06-10-01-guided':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9d'],
        boardCodes: ['As', '7c', '2h', 'Kd', '3c'],
        potLabel: 'Pot 54',
        villainLine: 'Triple barrels · solid unknown',
        streetLabel: 'River · top pair weak kicker',
        facingBet: true,
        // Structural — Rex + SoftPulse own Fold cue.
        feltStatusLine: 'Triple barrels · solid unknown',
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
        // Pair the board 9s — JhTd was ace-high, not second pair.
        heroCodes: ['Jh', '9d'],
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
        // Structural — Rex + SoftPulse own thin-value teaching.
        streetLabel: 'River · second pair',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Same cards — Station checked',
      );
    case 'act-06-13-01-scaffolded':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 36',
        villainLine: 'Nit just check-raised',
        // Structural — don’t tip Fold on the felt.
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Same cards — Nit check-raised',
      );
    case 'act-06-13-01-unguided':
      return const LessonActionSpot(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['Qc', 'Ts', '3h', '2d', '7c'],
        potLabel: 'Pot 42',
        villainLine: 'LAG barrels river',
        // Structural — don’t tip Call on the felt.
        streetLabel: 'River · second pair',
        facingBet: true,
        feltStatusLine: 'Same cards — LAG barrels',
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
        // SoftPulse owns RAISE — felt stays structural under coachOwnsCue.
        feltStatusLine: 'Folds to you · Button',
      );
    case 'step-01-06-flop':
      return const LessonActionSpot(
        heroCodes: ['Ah', '9h'],
        potLabel: 'Pot 9',
        villainLine: 'Blinds fold',
        streetLabel: 'Hand over',
        facingBet: false,
        // SoftPulse / Rex own take-pot — keep felt structural.
        feltStatusLine: 'Hand over · blinds folded',
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
        // SoftPulse owns BET 6 — don’t gold-tip value bet on the felt.
        feltStatusLine: 'Checked to you on A72',
      );
    case 'step-01-06-cp-open':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Qd'],
        potLabel: 'Pot 3',
        villainLine: 'CO folds',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
        // SoftPulse-quiet checkpoint — structural only, no open spoiler.
        feltStatusLine: 'Folds to you · Button',
      );
    case 'step-01-06-cp-end':
      return const LessonActionSpot(
        heroCodes: ['Kh', 'Qd'],
        potLabel: 'Pot 9',
        villainLine: 'Both blinds fold',
        streetLabel: 'Hand over',
        facingBet: false,
        // SoftPulse-quiet checkpoint — Rex owns the question; felt stays quiet.
        feltStatusLine: 'Hand over · blinds folded',
      );
    case 'j-hand-open':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Th'],
        potLabel: 'Pot 3',
        villainLine: 'Folds to you',
        streetLabel: 'Preflop · Button',
        facingBet: false,
        openPot: true,
        feltStatusLine: 'Folds to you · Button',
      );
    case 'j-hand-end':
      return const LessonActionSpot(
        heroCodes: ['Ah', 'Th'],
        potLabel: 'Pot 9',
        villainLine: 'Blinds fold',
        streetLabel: 'Hand over',
        facingBet: false,
        feltStatusLine: 'Hand over · blinds folded',
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
    // SoftPulse + Rex own the next-button cue while teaching.
    return 'Fold · Check · Call — your three passives';
  }

  @override
  Widget build(BuildContext context) {
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under FOLD / CHECK / CALL).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    String? next;
    for (final action in PassiveActionsDemo.actions) {
      if (!_tapped.contains(action.$1)) {
        next = action.$1;
        break;
      }
    }
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < PassiveActionsDemo.actions.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
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
                densify: expandTeach,
                selected: _tapped.contains(PassiveActionsDemo.actions[i].$1),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(PassiveActionsDemo.actions[i].$1)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-button cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive; // SoftPulse+Rex own cue; no Nice! echo
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
              ),
              child: Text(
                _statusCue,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Your three passive buttons',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // SoftPulse + Rex own the next-button cue while teaching.
    return 'Bet · Raise · All-in — your three aggressives';
  }

  @override
  Widget build(BuildContext context) {
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under BET / RAISE / ALL-IN).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    String? next;
    for (final action in AggressiveActionsDemo.actions) {
      if (!_tapped.contains(action.$1)) {
        next = action.$1;
        break;
      }
    }
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < AggressiveActionsDemo.actions.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  !_tapped.contains(AggressiveActionsDemo.actions[i].$1) &&
                  AggressiveActionsDemo.actions
                      .take(i)
                      .every((a) => _tapped.contains(a.$1)),
              child: _DemoActionCard(
                label: AggressiveActionsDemo.actions[i].$1,
                caption: AggressiveActionsDemo.actions[i].$2,
                color: AggressiveActionsDemo.actions[i].$3,
                densify: expandTeach,
                selected: _tapped.contains(
                  AggressiveActionsDemo.actions[i].$1,
                ),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(AggressiveActionsDemo.actions[i].$1)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-button cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive; // SoftPulse+Rex own cue; no Nice! echo
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
              ),
              child: Text(
                _statusCue,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Your three aggressive buttons',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // SoftPulse + Rex own the cue; captions teach strong / wider / ~3x.
    (label: 'EARLY', caption: 'Strong only', color: AppColors.danger),
    (label: 'BUTTON', caption: 'Wider', color: AppColors.gold),
    (label: 'LIVE 3x', caption: '~3x @ 1/2', color: AppColors.cream),
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
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under EARLY / BUTTON / LIVE 3x).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < OpenRangeDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
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
                densify: expandTeach,
                selected: _tapped.contains(OpenRangeDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(OpenRangeDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    final showCue = !widget.interactive;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Early tight · button wider · live opens ~3x',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Who opens — and how wide',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural response labels — Rex owns weak/playable/strong.
    (label: 'FOLD', caption: 'Give up', color: AppColors.slate),
    (label: 'CALL', caption: 'Match open', color: AppColors.cream),
    (label: '3-BET', caption: 'Reopen', color: AppColors.gold),
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
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under FOLD / CALL / 3-BET).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < VsOpenResponseDemo.responses.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
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
                densify: expandTeach,
                selected: _tapped.contains(
                  VsOpenResponseDemo.responses[i].label,
                ),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(VsOpenResponseDemo.responses[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    final showCue = !widget.interactive;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Weak fold · playable call · strong 3-bet',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Facing an open',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural captions — Rex owns “shorter sets the ceiling.”
    (label: 'CHIPS→BB', caption: '200 @ 1/2 = 100bb', color: AppColors.cream),
    (label: 'SHORTER', caption: 'Min of the two', color: AppColors.gold),
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
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under CHIPS→BB / SHORTER / DEPTH).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < BbStackDepthDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
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
                densify: expandTeach,
                selected: _tapped.contains(BbStackDepthDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(BbStackDepthDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    final showCue = !widget.interactive;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Count in BB · shorter stack caps the pot',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Stack depth in big blinds',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched 2×2 tiles (minHeight alone
    // leaves sparse green under WATCH / SAY / COVER / WAIT).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;

    Widget habitTile(int index) {
      final habit = TableHabitsDemo.habits[index];
      return Expanded(
        child: _DemoSoftPulse(
          active:
              widget.interactive &&
              widget.enabled &&
              next?.label == habit.label,
          child: _DemoActionCard(
            label: habit.label,
            caption: habit.caption,
            color: habit.color,
            densify: expandTeach,
            selected: _tapped.contains(habit.label),
            enabled: widget.interactive && widget.enabled,
            onPressed:
                widget.interactive ? () => _onTap(habit.label) : null,
          ),
        ),
      );
    }

    Widget habitRow(int row) {
      return Row(
        crossAxisAlignment: expandTeach
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          habitTile(row * 2),
          SizedBox(width: expandTeach ? 12 : 8),
          habitTile(row * 2 + 1),
        ],
      );
    }

    final tiles = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      children: [
        expandTeach ? Expanded(child: habitRow(0)) : habitRow(0),
        SizedBox(height: expandTeach ? 12 : 8),
        expandTeach ? Expanded(child: habitRow(1)) : habitRow(1),
      ],
    );
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    final showCue = !widget.interactive;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Watch · say · cover · wait your turn',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expandTeach
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.start,
      children: [
        Text(
          'Live-table habits',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: tiles,
                ),
              )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — not “Still runs the show” echoing Rex / Nice!.
    (label: 'POSITION', caption: 'Seat edge', color: AppColors.gold),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in FullRingDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under NINE / SAME / POSITION).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < FullRingDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == FullRingDemo.points[i].label,
              child: _DemoActionCard(
                label: FullRingDemo.points[i].label,
                caption: FullRingDemo.points[i].caption,
                color: FullRingDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(FullRingDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(FullRingDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    final showCue = !widget.interactive;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Nine seats · same rules · position still matters',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Full ring, same game',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “Words count live” (verbal binding is later).
    (label: 'WHO ACTS', caption: 'Whose turn', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in TableReadDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched 2×2 tiles (minHeight alone
    // leaves sparse green under POT / STACKS / BUTTON / WHO ACTS).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;

    Widget pointTile(int index) {
      final point = TableReadDemo.points[index];
      return Expanded(
        child: _DemoSoftPulse(
          active:
              widget.interactive &&
              widget.enabled &&
              next?.label == point.label,
          child: _DemoActionCard(
            label: point.label,
            caption: point.caption,
            color: point.color,
            densify: expandTeach,
            selected: _tapped.contains(point.label),
            enabled: widget.interactive && widget.enabled,
            onPressed:
                widget.interactive ? () => _onTap(point.label) : null,
          ),
        ),
      );
    }

    Widget pointRow(int row) {
      return Row(
        crossAxisAlignment: expandTeach
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          pointTile(row * 2),
          SizedBox(width: expandTeach ? 12 : 8),
          pointTile(row * 2 + 1),
        ],
      );
    }

    final tiles = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      children: [
        expandTeach ? Expanded(child: pointRow(0)) : pointRow(0),
        SizedBox(height: expandTeach ? 12 : 8),
        expandTeach ? Expanded(child: pointRow(1)) : pointRow(1),
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Pot · stacks · button · who acts',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expandTeach
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.start,
      children: [
        Text(
          // SoftPulse + Rex own the teach verb — felt title is structural.
          'Four table reads',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: tiles,
                ),
              )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “showdown value” (don’t expand SDV on the tile).
    (label: 'SDV', caption: 'Weak made', color: AppColors.slate),
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

  ({String label, String caption, Color color})? get _nextLabel {
    for (final label in FlopLabelDemo.labels) {
      if (!_tapped.contains(label.label)) return label;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextLabel;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched 2×2 tiles (minHeight alone
    // leaves sparse green under MADE / DRAW / SDV / AIR).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;

    Widget labelTile(int index) {
      final item = FlopLabelDemo.labels[index];
      return Expanded(
        child: _DemoSoftPulse(
          active:
              widget.interactive &&
              widget.enabled &&
              next?.label == item.label,
          child: _DemoActionCard(
            label: item.label,
            caption: item.caption,
            color: item.color,
            densify: expandTeach,
            selected: _tapped.contains(item.label),
            enabled: widget.interactive && widget.enabled,
            onPressed:
                widget.interactive ? () => _onTap(item.label) : null,
          ),
        ),
      );
    }

    Widget labelRow(int row) {
      return Row(
        crossAxisAlignment: expandTeach
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          labelTile(row * 2),
          SizedBox(width: expandTeach ? 12 : 8),
          labelTile(row * 2 + 1),
        ],
      );
    }

    final tiles = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      children: [
        expandTeach ? Expanded(child: labelRow(0)) : labelRow(0),
        SizedBox(height: expandTeach ? 12 : 8),
        expandTeach ? Expanded(child: labelRow(1)) : labelRow(1),
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t expand SDV into Rex’s phrase.
                'Made · draw · SDV · air',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expandTeach
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.start,
      children: [
        Text(
          // SoftPulse + Rex own the teach verb — felt title is structural.
          'Four flop classes',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: tiles,
                ),
              )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “Clean outs help / second-best / Price the call.”
    (label: 'CLEAN', caption: 'Best-hand outs', color: AppColors.gold),
    (label: 'DIRTY', caption: 'Trap improve', color: AppColors.danger),
    (label: 'PRICE', caption: 'Pot odds', color: AppColors.cream),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in OutsPriceDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under CLEAN / DIRTY / PRICE).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < OutsPriceDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == OutsPriceDemo.points[i].label,
              child: _DemoActionCard(
                label: OutsPriceDemo.points[i].label,
                caption: OutsPriceDemo.points[i].caption,
                color: OutsPriceDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(OutsPriceDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(OutsPriceDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t paraphrase Rex’s teach line.
                'Clean · dirty · price',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Outs and call price',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “check back” (don’t echo it on the CHECK tile).
    (label: 'CHECK', caption: 'Pass the street', color: AppColors.slate),
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

  ({String label, String caption, Color color})? get _nextLine {
    for (final line in FlopLinesDemo.lines) {
      if (!_tapped.contains(line.label)) return line;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextLine;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched 2×3 tiles (minHeight alone
    // leaves sparse green under VALUE / C-BET / CHECK / CALL / FOLD / RAISE).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;

    Widget lineTile(int index) {
      final line = FlopLinesDemo.lines[index];
      return Expanded(
        child: _DemoSoftPulse(
          active:
              widget.interactive &&
              widget.enabled &&
              next?.label == line.label,
          child: _DemoActionCard(
            label: line.label,
            caption: line.caption,
            color: line.color,
            densify: expandTeach,
            selected: _tapped.contains(line.label),
            enabled: widget.interactive && widget.enabled,
            onPressed:
                widget.interactive ? () => _onTap(line.label) : null,
          ),
        ),
      );
    }

    Widget lineRow(int row) {
      return Row(
        crossAxisAlignment: expandTeach
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          for (var col = 0; col < 3; col++) ...[
            if (col > 0) SizedBox(width: expandTeach ? 12 : 8),
            lineTile(row * 3 + col),
          ],
        ],
      );
    }

    final tiles = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      children: [
        expandTeach ? Expanded(child: lineRow(0)) : lineRow(0),
        SizedBox(height: expandTeach ? 12 : 8),
        expandTeach ? Expanded(child: lineRow(1)) : lineRow(1),
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Value · c-bet · check · call · fold · raise',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expandTeach
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.start,
      children: [
        Text(
          // SoftPulse + Rex own the teach verb — felt title is structural.
          'Six flop lines',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: tiles,
                ),
              )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    (label: 'BRICK', caption: 'Blank runout', color: AppColors.slate),
    // Structural — Rex owns “change the story” / “with intent.”
    (label: 'CHANGE', caption: 'Board shifts', color: AppColors.cream),
    (label: 'BARREL', caption: 'Fire again', color: AppColors.gold),
    (label: 'DELAY', caption: 'Hold fire', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in TurnStoryDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched 2×2 tiles (minHeight alone
    // leaves sparse green under BRICK / CHANGE / BARREL / DELAY).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;

    Widget pointTile(int index) {
      final point = TurnStoryDemo.points[index];
      return Expanded(
        child: _DemoSoftPulse(
          active:
              widget.interactive &&
              widget.enabled &&
              next?.label == point.label,
          child: _DemoActionCard(
            label: point.label,
            caption: point.caption,
            color: point.color,
            densify: expandTeach,
            selected: _tapped.contains(point.label),
            enabled: widget.interactive && widget.enabled,
            onPressed:
                widget.interactive ? () => _onTap(point.label) : null,
          ),
        ),
      );
    }

    Widget pointRow(int row) {
      return Row(
        crossAxisAlignment: expandTeach
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          pointTile(row * 2),
          SizedBox(width: expandTeach ? 12 : 8),
          pointTile(row * 2 + 1),
        ],
      );
    }

    final tiles = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      children: [
        expandTeach ? Expanded(child: pointRow(0)) : pointRow(0),
        SizedBox(height: expandTeach ? 12 : 8),
        expandTeach ? Expanded(child: pointRow(1)) : pointRow(1),
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s “with intent.”
                'Brick · change · barrel · delay',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expandTeach
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns brick/change story in the dock.
          'Four turn moves',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: tiles,
                ),
              )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “bluff-catch” / “no mystery floats.”
    (label: 'CATCH', caption: 'Snap off air', color: AppColors.slate),
    (label: 'FOLD', caption: 'Quit weak', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in RiverBinaryDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched 2×2 tiles (minHeight alone
    // leaves sparse green under VALUE / BLUFF / CATCH / FOLD).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;

    Widget pointTile(int index) {
      final point = RiverBinaryDemo.points[index];
      return Expanded(
        child: _DemoSoftPulse(
          active:
              widget.interactive &&
              widget.enabled &&
              next?.label == point.label,
          child: _DemoActionCard(
            label: point.label,
            caption: point.caption,
            color: point.color,
            densify: expandTeach,
            selected: _tapped.contains(point.label),
            enabled: widget.interactive && widget.enabled,
            onPressed:
                widget.interactive ? () => _onTap(point.label) : null,
          ),
        ),
      );
    }

    Widget pointRow(int row) {
      return Row(
        crossAxisAlignment: expandTeach
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          pointTile(row * 2),
          SizedBox(width: expandTeach ? 12 : 8),
          pointTile(row * 2 + 1),
        ],
      );
    }

    final tiles = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      children: [
        expandTeach ? Expanded(child: pointRow(0)) : pointRow(0),
        SizedBox(height: expandTeach ? 12 : 8),
        expandTeach ? Expanded(child: pointRow(1)) : pointRow(1),
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s “bluff-catch.”
                'Value · bluff · catch · fold',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expandTeach
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns "River is binary" in the dock.
          'Four river jobs',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: tiles,
                ),
              )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “stronger value” / “fewer bluffs” / “not second-best.”
    (label: 'STRONGER', caption: 'Tighten value', color: AppColors.gold),
    (label: 'FEWER', caption: 'Cut air', color: AppColors.slate),
    (label: 'NUTS', caption: 'Chase the top', color: AppColors.cream),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in MultiwayPlanDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under STRONGER / FEWER / NUTS).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < MultiwayPlanDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == MultiwayPlanDemo.points[i].label,
              child: _DemoActionCard(
                label: MultiwayPlanDemo.points[i].label,
                caption: MultiwayPlanDemo.points[i].caption,
                color: MultiwayPlanDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(MultiwayPlanDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(MultiwayPlanDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s “chase nuts.”
                'Stronger · fewer · nuts',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns multiway copy in the dock.
          'Multiway adjustments',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “worship” / “chase bad prices” / “call too passive.”
    (label: 'TOP PAIR', caption: 'Overplay pairs', color: AppColors.gold),
    (label: 'PRICES', caption: 'Ignore odds', color: AppColors.cream),
    (label: 'PASSIVE', caption: 'Never raise', color: AppColors.slate),
    (label: 'CROWDS', caption: 'Spew multiway', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextLeak {
    for (final leak in CommonLeaksDemo.leaks) {
      if (!_tapped.contains(leak.label)) return leak;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextLeak;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched 2×2 tiles (minHeight alone
    // leaves sparse green under TOP PAIR / PRICES / PASSIVE / CROWDS).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;

    Widget leakTile(int index) {
      final leak = CommonLeaksDemo.leaks[index];
      return Expanded(
        child: _DemoSoftPulse(
          active:
              widget.interactive &&
              widget.enabled &&
              next?.label == leak.label,
          child: _DemoActionCard(
            label: leak.label,
            caption: leak.caption,
            color: leak.color,
            densify: expandTeach,
            selected: _tapped.contains(leak.label),
            enabled: widget.interactive && widget.enabled,
            onPressed:
                widget.interactive ? () => _onTap(leak.label) : null,
          ),
        ),
      );
    }

    Widget leakRow(int row) {
      return Row(
        crossAxisAlignment: expandTeach
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          leakTile(row * 2),
          SizedBox(width: expandTeach ? 12 : 8),
          leakTile(row * 2 + 1),
        ],
      );
    }

    final tiles = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      children: [
        expandTeach ? Expanded(child: leakRow(0)) : leakRow(0),
        SizedBox(height: expandTeach ? 12 : 8),
        expandTeach ? Expanded(child: leakRow(1)) : leakRow(1),
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s leak list.
                'Top pair · prices · passive · crowds',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expandTeach
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns leak copy in the dock.
          'Common live leaks',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: tiles,
                ),
              )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “never know one hand” / “know a range” / “update.”
    (label: 'ONE HAND', caption: 'Single combo', color: AppColors.danger),
    (label: 'RANGE', caption: 'Possible set', color: AppColors.gold),
    (label: 'UPDATE', caption: 'Revise on action', color: AppColors.cream),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in RangeUpdateDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under ONE HAND / RANGE / UPDATE).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < RangeUpdateDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == RangeUpdateDemo.points[i].label,
              child: _DemoActionCard(
                label: RangeUpdateDemo.points[i].label,
                caption: RangeUpdateDemo.points[i].caption,
                color: RangeUpdateDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(RangeUpdateDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(RangeUpdateDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s “never know.”
                'One hand · range · update',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns range copy in the dock.
          'Three range moves',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “define ranges” / “punish multiway.”
    (label: '3-BET', caption: 'Reopen the pot', color: AppColors.gold),
    (label: 'RANGES', caption: 'Shape both sides', color: AppColors.cream),
    (
      label: 'SQUEEZE',
      caption: 'Isolate the open',
      color: AppColors.danger,
    ),
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
    // Structural — Rex owns “what do I do on turn and river?”
    (label: 'FLOP', caption: 'Start the line', color: AppColors.gold),
    (label: 'TURN', caption: 'Next street ready', color: AppColors.cream),
    (label: 'RIVER', caption: 'Close the line', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in ThreeBetSqueezeDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under 3-BET / RANGES / SQUEEZE).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < ThreeBetSqueezeDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == ThreeBetSqueezeDemo.points[i].label,
              child: _DemoActionCard(
                label: ThreeBetSqueezeDemo.points[i].label,
                caption: ThreeBetSqueezeDemo.points[i].caption,
                color: ThreeBetSqueezeDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(ThreeBetSqueezeDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(ThreeBetSqueezeDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s “define / punish.”
                '3-bet · ranges · squeeze',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns 3-bet / squeeze copy in the dock.
          'Three pot reopeners',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in MultiStreetPlanDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under FLOP / TURN / RIVER).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < MultiStreetPlanDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == MultiStreetPlanDemo.points[i].label,
              child: _DemoActionCard(
                label: MultiStreetPlanDemo.points[i].label,
                caption: MultiStreetPlanDemo.points[i].caption,
                color: MultiStreetPlanDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(MultiStreetPlanDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(MultiStreetPlanDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s “what do I do.”
                'Flop · turn · river',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns multi-street copy in the dock.
          'Plan every street',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}


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
    // Structural — Rex owns “looks like value / pressure.”
    (label: 'VALUE', caption: 'Get paid honestly', color: AppColors.gold),
    (
      label: 'PRESSURE',
      caption: 'Force folds',
      color: AppColors.danger,
    ),
    (label: 'SIZE', caption: 'Pick the story', color: AppColors.cream),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in SizingLanguageDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles under SIZE / VALUE /
    // PRESSURE (minHeight alone leaves sparse green).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < SizingLanguageDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == SizingLanguageDemo.points[i].label,
              child: _DemoActionCard(
                label: SizingLanguageDemo.points[i].label,
                caption: SizingLanguageDemo.points[i].caption,
                color: SizingLanguageDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(SizingLanguageDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(SizingLanguageDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s “looks like.”
                'Value · pressure · size',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns "Size is language" in the dock.
          'Three size stories',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “low: commit / high: maneuver.”
    (label: 'SPR', caption: 'Stack ÷ pot', color: AppColors.gold),
    (label: 'LOW', caption: 'Near stack-off', color: AppColors.danger),
    (label: 'HIGH', caption: 'Room to play', color: AppColors.cream),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in SprDepthDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under SPR / LOW / HIGH).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < SprDepthDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == SprDepthDemo.points[i].label,
              child: _DemoActionCard(
                label: SprDepthDemo.points[i].label,
                caption: SprDepthDemo.points[i].caption,
                color: SprDepthDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(SprDepthDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(SprDepthDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s commit/maneuver.
                'SPR · low · high',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Stack-to-pot ratio',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “who enters / calls / folds” and “count samples.”
    (label: 'ENTERS', caption: 'Pots joined', color: AppColors.gold),
    (label: 'CALLS', caption: 'Sticks to bets', color: AppColors.cream),
    (label: 'FOLDS', caption: 'Leaves pots', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in PlayerObserveDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under ENTERS / CALLS / FOLDS).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < PlayerObserveDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == PlayerObserveDemo.points[i].label,
              child: _DemoActionCard(
                label: PlayerObserveDemo.points[i].label,
                caption: PlayerObserveDemo.points[i].caption,
                color: PlayerObserveDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(PlayerObserveDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(PlayerObserveDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
        // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s “count samples.”
                'Enters · calls · folds',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // SoftPulse + Rex own the teach verb — felt title is structural.
          'Observation notes',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “working model / high participation / low folding.”
    (label: 'STATION', caption: 'Temp tag', color: AppColors.gold),
    (label: 'HIGH', caption: 'Often in pots', color: AppColors.cream),
    (label: 'LOW', caption: 'Sticks to heat', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in CallingStationDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under STATION / HIGH / LOW).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < CallingStationDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == CallingStationDemo.points[i].label,
              child: _DemoActionCard(
                label: CallingStationDemo.points[i].label,
                caption: CallingStationDemo.points[i].caption,
                color: CallingStationDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(CallingStationDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(CallingStationDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
        // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s participation line.
                'Station · high · low',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Calling Station',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “thicker value / fewer pure bluffs / cite calling.”
    (label: 'VALUE', caption: 'Get paid more', color: AppColors.gold),
    (label: 'BLUFFS', caption: 'Cut thin air', color: AppColors.danger),
    (label: 'CITE', caption: 'Name the sample', color: AppColors.cream),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in VsStationDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under VALUE / BLUFFS / CITE).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < VsStationDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == VsStationDemo.points[i].label,
              child: _DemoActionCard(
                label: VsStationDemo.points[i].label,
                caption: VsStationDemo.points[i].caption,
                color: VsStationDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(VsStationDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(VsStationDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
        // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s thicker/fewer line.
                'Value · bluffs · cite',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns versus-station teach in the dock.
          'Three station plans',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “almost never enter / when they do / mean it.”
    (label: 'RARE', caption: 'Seldom in pots', color: AppColors.slate),
    (label: 'ENTER', caption: 'Mark the join', color: AppColors.cream),
    (label: 'MEAN IT', caption: 'Credit strength', color: AppColors.gold),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in TightSeatsDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under RARE / ENTER / MEAN IT).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < TightSeatsDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == TightSeatsDemo.points[i].label,
              child: _DemoActionCard(
                label: TightSeatsDemo.points[i].label,
                caption: TightSeatsDemo.points[i].caption,
                color: TightSeatsDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(TightSeatsDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(TightSeatsDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Rare · enter · mean it',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Tight seats',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “narrow entry / respect heavy action.”
    (label: 'NIT', caption: 'Working label', color: AppColors.gold),
    (label: 'NARROW', caption: 'Seldom in pots', color: AppColors.cream),
    (
      label: 'RESPECT',
      caption: 'Credit big bets',
      color: AppColors.danger,
    ),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in NitModelDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under NIT / NARROW / RESPECT).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < NitModelDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == NitModelDemo.points[i].label,
              child: _DemoActionCard(
                label: NitModelDemo.points[i].label,
                caption: NitModelDemo.points[i].caption,
                color: NitModelDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(NitModelDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(NitModelDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Nit · narrow · respect',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Nit model',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “steal blinds more / credit when they explode.”
    (label: 'STEAL', caption: 'Widen opens', color: AppColors.gold),
    (label: 'CREDIT', caption: 'Fold to heat', color: AppColors.cream),
    (label: 'EXPLODE', caption: 'Big bets mean it', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in VsNitsDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under STEAL / CREDIT / EXPLODE).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < VsNitsDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == VsNitsDemo.points[i].label,
              child: _DemoActionCard(
                label: VsNitsDemo.points[i].label,
                caption: VsNitsDemo.points[i].caption,
                color: VsNitsDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(VsNitsDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(VsNitsDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Steal · credit · explode',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns versus-nit teach in the dock.
          'Three nit plans',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “raise and barrel / count calmly.”
    (label: 'RAISE', caption: 'Opens loud', color: AppColors.gold),
    (label: 'BARREL', caption: 'Fires streets', color: AppColors.danger),
    (label: 'COUNT', caption: 'Track frequency', color: AppColors.cream),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in ExtremeEntryDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under RAISE / BARREL / COUNT).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < ExtremeEntryDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == ExtremeEntryDemo.points[i].label,
              child: _DemoActionCard(
                label: ExtremeEntryDemo.points[i].label,
                caption: ExtremeEntryDemo.points[i].caption,
                color: ExtremeEntryDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(ExtremeEntryDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(ExtremeEntryDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Raise · barrel · count',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns maniac entry teach in the dock.
          'Three aggressor marks',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “extreme entry / aggression / model not insult.”
    (label: 'MANIAC', caption: 'Working label', color: AppColors.gold),
    (label: 'ENTRY', caption: 'Often in pots', color: AppColors.cream),
    (label: 'AGGRO', caption: 'Pressure style', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in ManiacModelDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under MANIAC / ENTRY / AGGRO).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < ManiacModelDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == ManiacModelDemo.points[i].label,
              child: _DemoActionCard(
                label: ManiacModelDemo.points[i].label,
                caption: ManiacModelDemo.points[i].caption,
                color: ManiacModelDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(ManiacModelDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(ManiacModelDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Maniac · entry · aggro',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Maniac model',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “call wider / hang themselves / no ego.”
    (label: 'WIDER', caption: 'Expand calling', color: AppColors.gold),
    (label: 'HANG', caption: 'Skip hero folds', color: AppColors.cream),
    (label: 'EGO', caption: 'Skip revenge', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in VsManiacsDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under WIDER / HANG / EGO).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < VsManiacsDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == VsManiacsDemo.points[i].label,
              child: _DemoActionCard(
                label: VsManiacsDemo.points[i].label,
                caption: VsManiacsDemo.points[i].caption,
                color: VsManiacsDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(VsManiacsDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(VsManiacsDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Wider · hang · ego',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns versus-maniac teach in the dock.
          'Three maniac plans',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “respect raises / no light bluff-raises.”
    (label: 'CREDIT', caption: 'Believe their heat', color: AppColors.gold),
    (label: 'TIGHTER', caption: 'Narrow steals', color: AppColors.cream),
    (label: 'NO LIGHT', caption: 'Skip fancy XR', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in VsTagsDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under CREDIT / TIGHTER / NO LIGHT).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < VsTagsDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == VsTagsDemo.points[i].label,
              child: _DemoActionCard(
                label: VsTagsDemo.points[i].label,
                caption: VsTagsDemo.points[i].caption,
                color: VsTagsDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(VsTagsDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(VsTagsDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Credit · tighter · no light',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns versus-TAG teach in the dock.
          'Three TAG plans',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “trap more / call wider / invent fewer fancy.”
    (label: 'CALL', caption: 'Widen defense', color: AppColors.gold),
    (label: 'TRAP', caption: 'Slow-play value', color: AppColors.cream),
    (label: 'FANCY LESS', caption: 'Skip hero bluffs', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in VsLagsDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under CALL / TRAP / FANCY LESS).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < VsLagsDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == VsLagsDemo.points[i].label,
              child: _DemoActionCard(
                label: VsLagsDemo.points[i].label,
                caption: VsLagsDemo.points[i].caption,
                color: VsLagsDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(VsLagsDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(VsLagsDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Call · trap · fancy less',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns versus-LAG teach in the dock.
          'Three LAG plans',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “observation ≠ certainty / samples / showdowns.”
    (label: 'OBSERVE', caption: 'Watch first', color: AppColors.gold),
    (label: 'SAMPLES', caption: 'Build the count', color: AppColors.cream),
    (label: 'SHOWDOWNS', caption: 'Cards speak', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in ObservationCertaintyDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under OBSERVE / SAMPLES / SHOWDOWNS).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < ObservationCertaintyDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == ObservationCertaintyDemo.points[i].label,
              child: _DemoActionCard(
                label: ObservationCertaintyDemo.points[i].label,
                caption: ObservationCertaintyDemo.points[i].caption,
                color: ObservationCertaintyDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(
                  ObservationCertaintyDemo.points[i].label,
                ),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(ObservationCertaintyDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Observe · samples · showdowns',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns “Observation ≠ certainty” in the dock.
          'Three confidence checks',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “same cards / different seats / evidence.”
    (label: 'CARDS', caption: 'Equal holdings', color: AppColors.gold),
    (label: 'SEATS', caption: 'Type differs', color: AppColors.cream),
    (
      label: 'EVIDENCE',
      caption: 'Prove before exploit',
      color: AppColors.danger,
    ),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in ExploitEvidenceDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under CARDS / SEATS / EVIDENCE).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < ExploitEvidenceDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == ExploitEvidenceDemo.points[i].label,
              child: _DemoActionCard(
                label: ExploitEvidenceDemo.points[i].label,
                caption: ExploitEvidenceDemo.points[i].caption,
                color: ExploitEvidenceDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(ExploitEvidenceDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(ExploitEvidenceDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Cards · seats · evidence',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Exploits need evidence',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “nutted up / air down / domination hurts.”
    (label: 'NUTTED', caption: 'Prefer strong', color: AppColors.gold),
    (label: 'AIR', caption: 'Cut speculative', color: AppColors.cream),
    (
      label: 'DOMINATION',
      caption: 'Second-best dies',
      color: AppColors.danger,
    ),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in MultiwayNutsDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under NUTTED / AIR / DOMINATION).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < MultiwayNutsDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == MultiwayNutsDemo.points[i].label,
              child: _DemoActionCard(
                label: MultiwayNutsDemo.points[i].label,
                caption: MultiwayNutsDemo.points[i].caption,
                color: MultiwayNutsDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(MultiwayNutsDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(MultiwayNutsDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Nutted · air · domination',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Multiway nut preference',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns "more room to realize / more room to lose."
    (label: 'DEEP', caption: 'Wider trees', color: AppColors.gold),
    (label: 'REALIZE', caption: 'Implied grow', color: AppColors.cream),
    (label: 'STACK', caption: 'Risk grows too', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in DeepStacksDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under DEEP / REALIZE / STACK).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < DeepStacksDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == DeepStacksDemo.points[i].label,
              child: _DemoActionCard(
                label: DeepStacksDemo.points[i].label,
                caption: DeepStacksDemo.points[i].caption,
                color: DeepStacksDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(DeepStacksDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(DeepStacksDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Deep · realize · stack',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Deep stack play',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “future money / future losses / second-best.”
    (label: 'IMPLIED', caption: 'They pay later', color: AppColors.gold),
    (label: 'REVERSE', caption: 'You pay later', color: AppColors.cream),
    (label: 'SECOND', caption: 'Trap improves', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in ImpliedOddsDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under IMPLIED / REVERSE / SECOND).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < ImpliedOddsDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == ImpliedOddsDemo.points[i].label,
              child: _DemoActionCard(
                label: ImpliedOddsDemo.points[i].label,
                caption: ImpliedOddsDemo.points[i].caption,
                color: ImpliedOddsDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(ImpliedOddsDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(ImpliedOddsDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Implied · reverse · second',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns “Implied odds” teach in the dock.
          'Three odds stories',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “needs calls” / “bluff-catches” / “wide barrels.”
    (label: 'THIN', caption: 'Extract light', color: AppColors.gold),
    (label: 'CATCH', caption: 'Hero call', color: AppColors.cream),
    (label: 'BARRELS', caption: 'Fire multi-street', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in ThinValueDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under THIN / CATCH / BARRELS).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < ThinValueDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == ThinValueDemo.points[i].label,
              child: _DemoActionCard(
                label: ThinValueDemo.points[i].label,
                caption: ThinValueDemo.points[i].caption,
                color: ThinValueDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(ThinValueDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(ThinValueDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                // Match SoftPulse titles — don’t echo Rex’s “needs calls.”
                'Thin · catch · barrels',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns thin-value / barrels copy in the dock.
          'Thin value & catches',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “lines mean ranges / each updates the story.”
    (label: 'X/R', caption: 'Raise after check', color: AppColors.gold),
    (label: 'PROBE', caption: 'Bet into check', color: AppColors.cream),
    (label: 'DELAY', caption: 'Hold fire first', color: AppColors.slate),
    (label: 'DONK', caption: 'Lead the raiser', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in LineStoriesDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched 2×2 tiles (minHeight alone
    // leaves sparse green under X/R / PROBE / DELAY / DONK).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;

    Widget pointTile(int index) {
      final point = LineStoriesDemo.points[index];
      return Expanded(
        child: _DemoSoftPulse(
          active:
              widget.interactive &&
              widget.enabled &&
              next?.label == point.label,
          child: _DemoActionCard(
            label: point.label,
            caption: point.caption,
            color: point.color,
            densify: expandTeach,
            selected: _tapped.contains(point.label),
            enabled: widget.interactive && widget.enabled,
            onPressed:
                widget.interactive ? () => _onTap(point.label) : null,
          ),
        ),
      );
    }

    Widget pointRow(int row) {
      return Row(
        crossAxisAlignment: expandTeach
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          pointTile(row * 2),
          SizedBox(width: expandTeach ? 12 : 6),
          pointTile(row * 2 + 1),
        ],
      );
    }

    final tiles = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      children: [
        expandTeach ? Expanded(child: pointRow(0)) : pointRow(0),
        SizedBox(height: expandTeach ? 12 : 8),
        expandTeach ? Expanded(child: pointRow(1)) : pointRow(1),
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'X/R · probe · delay · donk',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expandTeach
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns “Lines mean ranges” in the dock.
          'Four line updates',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: tiles,
                ),
              )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “each action rewrites / keep updating.”
    (label: 'ACTION', caption: 'Bets move ranges', color: AppColors.gold),
    (label: 'REWRITE', caption: 'Revise the set', color: AppColors.cream),
    (label: 'UPDATE', caption: 'Stay current', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in RangeRewriteDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under ACTION / REWRITE / UPDATE).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < RangeRewriteDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == RangeRewriteDemo.points[i].label,
              child: _DemoActionCard(
                label: RangeRewriteDemo.points[i].label,
                caption: RangeRewriteDemo.points[i].caption,
                color: RangeRewriteDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(RangeRewriteDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(RangeRewriteDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Action · rewrite · update',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Ranges keep moving',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “clues / soft evidence / small updates.”
    (label: 'TIMING', caption: 'How fast they act', color: AppColors.gold),
    (label: 'SIZING', caption: 'How much they bet', color: AppColors.cream),
    (label: 'CLUES', caption: 'Nudge the model', color: AppColors.danger),
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in TimingCluesDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under TIMING / SIZING / CLUES).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < TimingCluesDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == TimingCluesDemo.points[i].label,
              child: _DemoActionCard(
                label: TimingCluesDemo.points[i].label,
                caption: TimingCluesDemo.points[i].caption,
                color: TimingCluesDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(TimingCluesDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(TimingCluesDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Timing · sizing · clues',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns clues / mind-reading teach in the dock.
          'Three soft clues',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
    // Structural — Rex owns “stuck / tilted / gears — update.”
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

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in TablesChangeDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under STUCK / TILTED / GEARS).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < TablesChangeDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DemoSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == TablesChangeDemo.points[i].label,
              child: _DemoActionCard(
                label: TablesChangeDemo.points[i].label,
                caption: TablesChangeDemo.points[i].caption,
                color: TablesChangeDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(TablesChangeDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(TablesChangeDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Stuck · tilted · gears',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          // Structural label — Rex owns “Tables change” in the dock.
          'Three table gears',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
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
      child: body,
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
        // Match streets/path SoftPulse intensity — weak glow washed out on
        // danger-tinted EARLY tiles (open-fold SoftPulse looked "static").
        final glow = 0.4 + (_pulse.value * 0.55);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.95),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: glow * 0.65),
                blurRadius: 12 + (10 * _pulse.value),
                spreadRadius: 1 + (2 * _pulse.value),
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
    this.densify = false,
    this.selected = false,
    this.enabled = false,
    this.onPressed,
  });

  final String label;
  final String caption;
  final Color color;
  final bool densify;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.gold
        : color.withValues(alpha: 0.9);
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: densify ? double.infinity : null,
      padding: EdgeInsets.symmetric(
        vertical: densify ? 24 : 12,
        horizontal: densify ? 10 : 6,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.28)
            : color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(densify ? 16 : 12),
        border: Border.all(color: borderColor, width: selected ? 2.5 : 1),
      ),
      child: densify
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      color: AppColors.cream,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      // SoftPulse densify tints are light — slate on cream/gold
                      // reads as muddy grey; cream keeps captions legible.
                      color: AppColors.cream.withValues(alpha: 0.82),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
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
    final child = densify ? SizedBox.expand(child: card) : card;
    if (onPressed == null) return child;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(densify ? 16 : 12),
          child: child,
        ),
      ),
    );
  }
}

/// Mini felt showing pot, optional villain bet, board, and hero holes.
class LessonActionTable extends StatelessWidget {
  /// Creates the table.
  ///
  /// When [coachOwnsCue] is true (Rex + SoftPulse already cue the dock),
  /// hide gold felt status lines — including authored [LessonActionSpot.feltStatusLine]
  /// that would triple-cue the same move.
  const LessonActionTable({
    super.key,
    required this.spot,
    this.coachOwnsCue = false,
  });

  final LessonActionSpot spot;

  /// SoftPulse + Rex own the next-action cue — suppress felt gold status.
  final bool coachOwnsCue;

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

    const cardSize = MiniCardSize.hero;

    Widget statusLine(String text, {Color color = AppColors.gold}) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    // Tall-phone teach: fill Rex→dock when parent expands; else ~55% shell
    // so we never leave a navy void under a center-shrunk mini felt.
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded =
            constraints.hasBoundedHeight &&
            constraints.maxHeight.isFinite &&
            constraints.maxHeight > 120;
        final feltHeight =
            bounded
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height * 0.55;
        // Spacers need spare vertical room; short test shells pack tight.
        final breathe = feltHeight >= 420;
        final cardScale = breathe ? 1.4 : 1.0;

        Widget? sceneStatus() {
          // SoftPulse + Rex already name the move — no third gold line
          // (authored or auto-generated).
          if (coachOwnsCue) return null;
          if (spot.feltStatusLine != null) {
            return statusLine(spot.feltStatusLine!);
          }
          if (spot.facingBet) return statusLine('A bet faces you');
          if (spot.openPot) {
            return statusLine(
              // Preflop first-in is an open-raise; postflop open is a bet.
              spot.streetLabel?.toLowerCase().contains('preflop') == true
                  ? 'First in — open the pot'
                  : 'Pot is open to a bet',
            );
          }
          if (spot.streetLabel?.toLowerCase().contains('hand over') == true) {
            return statusLine('Hand over · blinds folded');
          }
          return statusLine('No bet to match', color: AppColors.slate);
        }

        final header = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (spot.streetLabel != null)
              Text(
                spot.streetLabel!,
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: breathe ? 15 : 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (spot.streetLabel != null && spot.villainLine != null)
              SizedBox(height: breathe ? 12 : 10),
            if (spot.villainLine != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: breathe ? 14 : 12,
                  vertical: breathe ? 10 : 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  spot.villainLine!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: breathe ? 15 : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            SizedBox(height: breathe ? 14 : 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _PotChip(label: spot.potLabel),
                if (spot.stackLabel != null) _PotChip(label: spot.stackLabel!),
              ],
            ),
          ],
        );

        final cards = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (board.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < board.length; i++) ...[
                    if (i > 0) SizedBox(width: breathe ? 8 : 6),
                    MiniCard(
                      card: board[i],
                      size: cardSize,
                      scale: cardScale,
                    ),
                  ],
                ],
              ),
            if (board.isNotEmpty && hero.isNotEmpty)
              SizedBox(height: breathe ? 16 : 14),
            if (hero.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You',
                    style: GoogleFonts.manrope(
                      color: AppColors.cream,
                      fontSize: breathe ? 13 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: breathe ? 8 : 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < hero.length; i++) ...[
                        if (i > 0) SizedBox(width: breathe ? 10 : 8),
                        MiniCard(
                          card: hero[i],
                          size: cardSize,
                          scale: cardScale,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
          ],
        );

        final status = sceneStatus();

        final packed = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            const SizedBox(height: 16),
            cards,
            if (status != null) ...[
              const SizedBox(height: 14),
              status,
            ],
          ],
        );

        return Container(
          width: double.infinity,
          height: bounded ? feltHeight : null,
          constraints:
              bounded
                  ? null
                  : BoxConstraints(minHeight: feltHeight),
          padding: EdgeInsets.fromLTRB(
            12,
            breathe ? 18 : 14,
            12,
            breathe ? 18 : 14,
          ),
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
          // Tall teach: pin header / cards / status to the felt edges so
          // spare height sits *between* clusters — not as empty green
          // Spacers above and below a centered scene.
          child:
              breathe
                  ? Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      header,
                      cards,
                      if (status != null) status,
                    ],
                  )
                  : packed,
        );
      },
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
                        (_isCall(choice) && !facingBet && !_isLimp(choice)) ||
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
    if (action.startsWith('FOLD'))
      return AppColors.danger.withValues(alpha: 0.4);
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
    final preferAuthoredLabel =
        authoredWords.length >= 2 &&
        authoredWords.first != 'CHECK' &&
        authoredWords.first != 'FOLD';
    // Long teaching labels only: "Raise as a bluff candidate" → RAISE BLUFF.
    // Keep short sizing chrome intact ("RAISE TO 6").
    const fillers = {'AS', 'A', 'AN', 'THE', 'TO', 'OF', 'FOR', 'ON', 'IN'};
    final compactAuthored = () {
      if (authoredWords.length <= 3) return authored;
      final kept =
          authoredWords.where((w) => !fillers.contains(w)).toList(growable: false);
      if (kept.isEmpty) return authored;
      if (kept.length <= 2) return kept.join(' ');
      return kept.take(2).join(' ');
    }();
    final short = unavailableLook
        ? switch (action.split(' ').first) {
            'CALL' => 'CALL (off)',
            'BET' => 'BET (off)',
            'RAISE' => 'RAISE (off)',
            _ => 'CHECK (off)',
          }
        : preferAuthoredLabel
        ? compactAuthored
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
                  ? compactAuthored
                  : 'CALL',
            'RAISE' =>
              authored.startsWith('RAISE') ? compactAuthored : 'RAISE',
            'BET' => authored.startsWith('BET') ? compactAuthored : 'BET',
            _ => compactAuthored,
          };
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label:
          choice.accessibilityText ??
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
              border: Border.all(color: _border, width: selected ? 2.2 : 1.4),
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
                decoration: unavailableLook ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.slate,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
