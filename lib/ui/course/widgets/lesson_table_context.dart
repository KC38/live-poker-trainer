/// Compact felt + cards context for lesson select/identify activities.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

/// Tappable regions on the lesson mini-table.
enum LessonTableRegion {
  /// Hero hole cards.
  hero,

  /// Community board.
  board,

  /// Face-down villain seat(s).
  villain,

  /// Folded/muck pile.
  muck,

  /// Dealer button / dealer role chip (privacy distractor).
  dealer,

  /// Dealer button seat on a blinds layout.
  button,

  /// Small blind seat.
  smallBlind,

  /// Big blind seat.
  bigBlind,

  /// Unlabeled / empty seat distractor.
  emptySeat,

  /// Early position / UTG on a six-max position layout.
  earlyPosition,

  /// Hijack seat.
  hijack,

  /// Cutoff seat (right before the button).
  cutoff,

  /// Checkpoint distractor: seat never matters.
  seatNeverMatters,

  /// Timing: blinds post before the deal.
  beforeDeal,

  /// Timing: after the flop.
  afterFlop,

  /// Timing: only at showdown.
  showdown,

  /// Street ends when bets are matched / action equalizes.
  streetActionMatched,

  /// Distractor: flop cards appear (deal starts the street).
  streetFlopDealt,

  /// Distractor: someone folds (others may still act).
  streetSomeoneFolds,

  /// Fold-win: take the pot without showing.
  potTakeQuiet,

  /// Fold-win distractor: must always show.
  potMustShow,

  /// Fold-win distractor: dealer reveals cards.
  potDealerShows,

  /// Contested river: showdown compares hands.
  potShowdown,

  /// Showdown distractor: last bettor wins without showing.
  potLastBettor,

  /// Showdown distractor: always chop.
  potChopDefault,

  /// Side pot: unmatched chips form a side pot.
  potSideForms,

  /// Side pot distractor: short stack wins later chips too.
  potWinAll,

  /// Side pot distractor: short stack hand is dead.
  potHandDead,

  /// Open-pot size: correct total (blinds + open).
  potChipsNine,

  /// Open-pot size distractor: forgot a blind.
  potChipsSeven,

  /// Open-pot size distractor: too large.
  potChipsTwelve,
}

/// How the mini-table is arranged.
enum LessonTableLayout {
  /// Hole cards + optional board / villains (Your two cards).
  holeCards,

  /// Six-max seats with button / blinds chips.
  blindsSeats,

  /// Six-max seats labeled EP / HJ / CO / BTN / SB / BB.
  positionLabels,

  /// Hand-phase timing tiles for when blinds post.
  blindsTiming,

  /// Timing tiles for when a betting street ends.
  streetEndPhases,

  /// Fold-win outcome tiles (take pot / must show / dealer shows).
  potFoldWinOutcomes,

  /// Showdown outcome tiles after a river call.
  potShowdownOutcomes,

  /// Side-pot outcome tiles when short all-in.
  potSideOutcomes,

  /// Open-to-6 pot size tiles (7 / 9 / 12 chips).
  potOpenSizeOutcomes,
}

/// Authored (or inferred) mini-table scene for a lesson activity.
class LessonTableScene {
  /// Creates a scene.
  const LessonTableScene({
    this.heroCodes = const <String>[],
    this.boardCodes = const <String>[],
    this.villainSeatCount = 1,
    this.highlight = LessonTableHighlight.none,
    this.caption,
    this.showMuck = false,
    this.showDealerChip = false,
    this.layout = LessonTableLayout.holeCards,
    this.seatCount = 6,
    this.buttonSeat = 5,
    this.numberSeats = false,
    this.showSeatNeverMatters = false,
  });

  /// Face-up hero hole cards (e.g. `Ah`, `Kd`).
  final List<String> heroCodes;

  /// Optional community cards in the middle.
  final List<String> boardCodes;

  /// How many other seats show face-down hole cards.
  final int villainSeatCount;

  /// Soft emphasis for guided teaching (pulse only — never a spoiler label).
  final LessonTableHighlight highlight;

  /// Optional short non-spoiling label under the hero rail (e.g. `You`).
  final String? caption;

  /// Show a small muck pile distractor.
  final bool showMuck;

  /// Show a dealer chip distractor (privacy questions).
  final bool showDealerChip;

  /// Table arrangement for this activity.
  final LessonTableLayout layout;

  /// Seats around the blinds layout (usually 6).
  final int seatCount;

  /// Seat index holding the dealer button (checkpoint uses 5).
  final int buttonSeat;

  /// Show absolute seat numbers (0..n-1) on the blinds layout.
  final bool numberSeats;

  /// Show a "Seat never matters" distractor under position labels.
  final bool showSeatNeverMatters;
}

/// Which region of the mini-table should read as the teaching target.
enum LessonTableHighlight {
  none,
  hero,
  board,
  button,
  smallBlind,
  bigBlind,
  earlyPosition,
  hijack,
  cutoff,
}

final _cardToken = RegExp(r'\b([2-9TJQKA][shdc])\b', caseSensitive: false);

/// Resolves a table scene for activities that reference the felt / hole cards.
///
/// Returns null when the activity is a pure text quiz (e.g. suit names).
LessonTableScene? resolveLessonTableScene(CourseActivity activity) {
  if (activity.renderer != ActivityRenderer.selectIdentify &&
      activity.renderer != ActivityRenderer.coachDialogue) {
    return null;
  }

  switch (activity.id) {
    case 'act-01-01-01-guided-find-holes':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 1,
        // Soft pulse only — no spoiler caption.
        highlight: LessonTableHighlight.hero,
        caption: 'You',
      );
    case 'act-01-01-01-scaffolded-private':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 2,
        highlight: LessonTableHighlight.none,
        caption: 'You',
        showDealerChip: true,
      );
    case 'act-01-01-01-unguided-mix':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'You',
        showMuck: true,
      );
    case 'act-01-01-01-checkpoint-table':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 3,
        highlight: LessonTableHighlight.none,
        caption: 'You',
      );
    case 'act-01-01-01-explain-hole-cards':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.hero,
        caption: 'You',
      );
    case 'act-01-01-02-unguided-suited':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kh'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.hero,
        caption: 'You',
      );
    case 'act-01-01-02-checkpoint-pair':
      return const LessonTableScene(
        heroCodes: ['9h', '9d'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.hero,
        caption: 'You',
      );
    case 'act-01-01-03-explain-button':
    case 'act-01-01-03-guided-button':
      return const LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
      );
    case 'act-01-01-03-scaffolded-blinds':
      return const LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.bigBlind,
        seatCount: 6,
        buttonSeat: 3,
      );
    case 'act-01-01-03-unguided-when':
      return const LessonTableScene(
        layout: LessonTableLayout.blindsTiming,
      );
    case 'act-01-01-03-checkpoint-layout':
      return const LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.smallBlind,
        seatCount: 6,
        buttonSeat: 5,
        numberSeats: true,
      );
    case 'act-02-01-01-explain-pos':
    case 'act-02-01-01-guided-btn':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'Six-max · tap who acts last postflop',
      );
    case 'act-02-01-01-scaffolded-blinds':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.smallBlind,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'Tap SB or BB — both post every hand',
      );
    case 'act-02-01-01-unguided-co':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.cutoff,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'Tap the seat right before the button',
      );
    case 'act-02-01-01-checkpoint-edge':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
        showSeatNeverMatters: true,
        caption: 'Same hand — EP vs BTN',
      );
    case 'act-01-04-01-unguided-end':
      return const LessonTableScene(
        layout: LessonTableLayout.streetEndPhases,
      );
    case 'act-01-04-01-checkpoint-postflop':
      return const LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'Postflop · tap who acts first',
      );
    case 'act-01-05-01-guided-fold-win':
      return const LessonTableScene(
        layout: LessonTableLayout.potFoldWinOutcomes,
        heroCodes: ['Ah', 'Kd'],
        showMuck: true,
        villainSeatCount: 0,
        caption: 'You bet · all fold',
      );
    case 'act-01-05-01-scaffolded-showdown':
      return const LessonTableScene(
        layout: LessonTableLayout.potShowdownOutcomes,
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', '7c', '2d', '9h', '3s'],
        villainSeatCount: 1,
        caption: 'River · called',
      );
    case 'act-01-05-01-checkpoint-side':
      return const LessonTableScene(
        layout: LessonTableLayout.potSideOutcomes,
        caption: 'You all-in short · others keep betting',
      );
    case 'act-01-05-01-unguided-pot':
      return const LessonTableScene(
        layout: LessonTableLayout.potOpenSizeOutcomes,
        caption: '1/2 · BTN opens 6 · blinds still to act',
      );
    case 'act-01-02-01-scaffolded-spot':
      return const LessonTableScene(
        heroCodes: ['Ac', '3d'],
        boardCodes: ['Kc', '9c', '4c', '7c', '2s'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'You',
      );
    case 'act-01-02-01-explain-ladder':
      return null;
    case 'act-01-02-02-explain-five':
      return null;
    case 'act-01-02-02-scaffolded-kicker':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Qd'],
        boardCodes: ['Kh', 'Kd', '7c', '3s', '2d'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'You (AQ)',
      );
    case 'act-01-02-02-unguided-board':
      return const LessonTableScene(
        heroCodes: ['2h', '2d'],
        boardCodes: ['Ac', 'Kc', 'Qc', 'Jc', 'Tc'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.board,
        caption: 'You',
      );
  }

  final hero = <String>[];
  final board = <String>[];
  for (final choice in activity.choices) {
    final codes = _cardToken
        .allMatches(choice.label)
        .map((m) => m.group(1)!)
        .toList(growable: false);
    if (codes.length >= 2 &&
        (choice.label.toLowerCase().contains('you') ||
            choice.label.toLowerCase().contains('front') ||
            choice.label.toLowerCase().contains('seat') ||
            choice.id.contains('hero') ||
            choice.id.contains('hole'))) {
      hero
        ..clear()
        ..addAll(codes.take(2));
    } else if (codes.length >= 3 &&
        (choice.label.toLowerCase().contains('middle') ||
            choice.label.toLowerCase().contains('flop') ||
            choice.label.toLowerCase().contains('board') ||
            choice.id.contains('flop') ||
            choice.id.contains('board'))) {
      board
        ..clear()
        ..addAll(codes.take(5));
    }
  }

  final prompt = (activity.prompt ?? activity.accessibilityText).toLowerCase();
  final wantsTable =
      prompt.contains('hole') ||
      prompt.contains('table') ||
      prompt.contains('community') ||
      prompt.contains('board') ||
      prompt.contains('seat') ||
      activity.objectives.any(
        (o) =>
            o.toLowerCase().contains('hole') ||
            o.toLowerCase().contains('community') ||
            o.toLowerCase().contains('table'),
      );

  if (!wantsTable && hero.isEmpty && board.isEmpty) return null;

  return LessonTableScene(
    heroCodes: hero.isEmpty ? const ['Ah', 'Kd'] : List.unmodifiable(hero),
    boardCodes: List.unmodifiable(board),
    villainSeatCount:
        prompt.contains('dealer') || prompt.contains('who can see')
            ? 2
            : (board.isEmpty ? 1 : 1),
    highlight:
        prompt.contains('community') || prompt.contains('board')
            ? LessonTableHighlight.board
            : LessonTableHighlight.hero,
    caption: 'You',
  );
}

/// Maps a table region tap onto an authored choice id.
String? mapTableRegionToChoiceId({
  required String activityId,
  required LessonTableRegion region,
  required List<CourseChoice> choices,
  int? seatIndex,
}) {
  final ids = {for (final c in choices) c.id};
  String? pick(String id) => ids.contains(id) ? id : null;

  switch (activityId) {
    case 'act-01-01-01-guided-find-holes':
      return switch (region) {
        LessonTableRegion.hero => pick('choice-hero-holes'),
        LessonTableRegion.board => pick('choice-board'),
        LessonTableRegion.villain => pick('choice-villain'),
        _ => null,
      };
    case 'act-01-01-01-scaffolded-private':
      // Tap what only you can see / who sees your holes.
      return switch (region) {
        LessonTableRegion.hero => pick('choice-only-you'),
        LessonTableRegion.villain || LessonTableRegion.board =>
          pick('choice-whole-table'),
        LessonTableRegion.dealer => pick('choice-dealer-only'),
        _ => null,
      };
    case 'act-01-01-01-unguided-mix':
      return switch (region) {
        LessonTableRegion.board => pick('choice-flop'),
        LessonTableRegion.hero => pick('choice-hero-again'),
        LessonTableRegion.muck || LessonTableRegion.villain =>
          pick('choice-muck'),
        _ => null,
      };
    case 'act-01-01-01-checkpoint-table':
      return switch (region) {
        LessonTableRegion.hero => pick('choice-checkpoint-holes'),
        LessonTableRegion.board => pick('choice-checkpoint-board'),
        // Tapping other face-up-looking areas / villains ≈ "everything I see".
        LessonTableRegion.villain => pick('choice-checkpoint-all'),
        _ => null,
      };
    case 'act-01-01-03-guided-button':
      return switch (region) {
        LessonTableRegion.button => pick('btn-seat'),
        LessonTableRegion.bigBlind => pick('bb-seat'),
        LessonTableRegion.emptySeat => pick('empty-seat'),
        _ => null,
      };
    case 'act-01-01-03-scaffolded-blinds':
      return switch (region) {
        LessonTableRegion.bigBlind => pick('bb-two'),
        LessonTableRegion.smallBlind => pick('sb-one'),
        LessonTableRegion.button => pick('btn-posts'),
        _ => null,
      };
    case 'act-01-01-03-unguided-when':
      return switch (region) {
        LessonTableRegion.beforeDeal => pick('before-deal'),
        LessonTableRegion.afterFlop => pick('after-flop'),
        LessonTableRegion.showdown => pick('only-showdown'),
        _ => null,
      };
    case 'act-01-01-03-checkpoint-layout':
      // Button is seat 5: SB = 0, BB = 1, right-of-button = 4.
      if (seatIndex == null) return null;
      return switch (seatIndex) {
        0 => pick('sb-seat0'),
        4 => pick('sb-seat4'),
        1 => pick('sb-seat1'),
        _ => null,
      };
    case 'act-01-04-01-unguided-end':
      return switch (region) {
        LessonTableRegion.streetActionMatched => pick('matched'),
        LessonTableRegion.streetFlopDealt => pick('three-cards'),
        LessonTableRegion.streetSomeoneFolds => pick('someone-folds'),
        _ => null,
      };
    case 'act-01-04-01-checkpoint-postflop':
      return switch (region) {
        LessonTableRegion.smallBlind => pick('sb-first'),
        LessonTableRegion.button => pick('btn-first'),
        LessonTableRegion.bigBlind => pick('bb-first-always'),
        _ => null,
      };
    case 'act-01-05-01-guided-fold-win':
      return switch (region) {
        LessonTableRegion.potTakeQuiet => pick('no-show'),
        LessonTableRegion.potMustShow => pick('must-show'),
        LessonTableRegion.potDealerShows => pick('dealer-shows'),
        _ => null,
      };
    case 'act-01-05-01-scaffolded-showdown':
      return switch (region) {
        LessonTableRegion.potShowdown => pick('showdown'),
        LessonTableRegion.potLastBettor => pick('last-bet-wins'),
        LessonTableRegion.potChopDefault => pick('chop-default'),
        _ => null,
      };
    case 'act-01-05-01-checkpoint-side':
      return switch (region) {
        LessonTableRegion.potSideForms => pick('side-exists'),
        LessonTableRegion.potWinAll => pick('you-win-all'),
        LessonTableRegion.potHandDead => pick('hand-void'),
        _ => null,
      };
    case 'act-01-05-01-unguided-pot':
      return switch (region) {
        LessonTableRegion.potChipsNine => pick('pot-9'),
        LessonTableRegion.potChipsSeven => pick('pot-7'),
        LessonTableRegion.potChipsTwelve => pick('pot-12'),
        _ => null,
      };
    case 'act-02-01-01-guided-btn':
      return switch (region) {
        LessonTableRegion.button => pick('pos-btn'),
        LessonTableRegion.bigBlind => pick('pos-bb'),
        LessonTableRegion.earlyPosition => pick('pos-ep'),
        _ => null,
      };
    case 'act-02-01-01-scaffolded-blinds':
      return switch (region) {
        LessonTableRegion.smallBlind || LessonTableRegion.bigBlind =>
          pick('sb-bb'),
        LessonTableRegion.button => pick('btn-bb'),
        LessonTableRegion.earlyPosition ||
        LessonTableRegion.hijack ||
        LessonTableRegion.cutoff =>
          pick('ep-only'),
        _ => null,
      };
    case 'act-02-01-01-unguided-co':
      return switch (region) {
        LessonTableRegion.cutoff => pick('label-co'),
        LessonTableRegion.hijack => pick('label-hj'),
        LessonTableRegion.earlyPosition => pick('label-ep'),
        _ => null,
      };
    case 'act-02-01-01-checkpoint-edge':
      return switch (region) {
        LessonTableRegion.button => pick('prefer-btn'),
        LessonTableRegion.earlyPosition => pick('prefer-ep'),
        LessonTableRegion.seatNeverMatters => pick('same-always'),
        _ => null,
      };
  }
  return null;
}

/// Whether this activity is answered by tapping the mini-table.
bool isTableRegionTapActivity(CourseActivity activity) {
  if (activity.renderer == ActivityRenderer.coachDialogue) {
    // Interactive explains: tap the demo instead of Continue.
    return activity.id == 'act-01-01-01-explain-hole-cards' ||
        activity.id == 'act-01-01-02-explain-suits' ||
        activity.id == 'act-01-01-03-explain-button' ||
        activity.id == 'act-02-01-01-explain-pos' ||
        activity.id == 'act-01-02-01-explain-ladder' ||
        activity.id == 'act-01-02-02-explain-five' ||
        activity.id == 'act-01-03-01-explain-passive' ||
        activity.id == 'act-01-03-02-explain-aggro' ||
        activity.id == 'act-01-04-01-explain-streets' ||
        activity.id == 'act-01-05-01-explain-win' ||
        activity.id == 'act-01-06-01-explain-run' ||
        activity.id == 'act-02-01-02-explain-order' ||
        activity.id == 'act-02-02-01-explain-families' ||
        activity.id == 'act-02-03-01-explain-open' ||
        activity.id == 'act-02-04-01-explain-vs' ||
        activity.id == 'act-02-05-01-explain-bb' ||
        activity.id == 'act-02-06-01-explain-habits' ||
        activity.id == 'act-02-07-01-explain-full' ||
        activity.id == 'act-03-01-01-explain' ||
        activity.id == 'act-03-02-01-explain' ||
        activity.id == 'act-03-03-01-explain' ||
        activity.id == 'act-03-04-01-explain' ||
        activity.id == 'act-03-05-01-explain' ||
        activity.id == 'act-03-06-01-explain' ||
        activity.id == 'act-03-07-01-explain' ||
        activity.id == 'act-03-08-01-explain' ||
        activity.id == 'act-04-01-01-explain' ||
        activity.id == 'act-04-02-01-explain' ||
        activity.id == 'act-04-03-01-explain' ||
        activity.id == 'act-04-04-01-explain' ||
        activity.id == 'act-04-05-01-explain' ||
        activity.id == 'act-04-06-01-explain' ||
        activity.id == 'act-04-06-02-explain' ||
        activity.id == 'act-04-06-03-explain' ||
        activity.id == 'act-04-07-01-explain' ||
        activity.id == 'act-04-07-02-explain' ||
        activity.id == 'act-04-07-03-explain' ||
        activity.id == 'act-04-08-01-explain' ||
        activity.id == 'act-04-08-02-explain' ||
        activity.id == 'act-04-08-03-explain' ||
        activity.id == 'act-04-09-01-explain' ||
        activity.id == 'act-04-10-01-explain' ||
        activity.id == 'act-05-01-01-explain' ||
        activity.id == 'act-05-02-01-explain' ||
        activity.id == 'act-05-03-01-explain' ||
        activity.id == 'act-05-04-01-explain' ||
        activity.id == 'act-05-05-01-explain';
  }
  if (activity.renderer != ActivityRenderer.selectIdentify) return false;
  return activity.id.startsWith('act-01-01-01-') ||
      activity.id.startsWith('act-01-01-03-') ||
      activity.id.startsWith('act-01-04-01-') ||
      activity.id.startsWith('act-01-05-01-') ||
      activity.id.startsWith('act-02-01-01-');
}

/// Small-blind seat index clockwise from the button.
int blindsSmallBlindSeat({required int buttonSeat, required int seatCount}) {
  return (buttonSeat + 1) % seatCount;
}

/// Big-blind seat index clockwise from the button.
int blindsBigBlindSeat({required int buttonSeat, required int seatCount}) {
  return (buttonSeat + 2) % seatCount;
}

/// Early-position / UTG seat index clockwise from the button (six-max).
int positionEarlySeat({required int buttonSeat, required int seatCount}) {
  return (buttonSeat + 3) % seatCount;
}

/// Hijack seat index clockwise from the button (six-max).
int positionHijackSeat({required int buttonSeat, required int seatCount}) {
  return (buttonSeat + 4) % seatCount;
}

/// Cutoff seat index clockwise from the button (six-max).
int positionCutoffSeat({required int buttonSeat, required int seatCount}) {
  return (buttonSeat + 5) % seatCount;
}

/// Role for a seat on a blinds teaching layout.
LessonTableRegion blindsRoleForSeat({
  required int seatIndex,
  required int buttonSeat,
  required int seatCount,
}) {
  if (seatIndex == buttonSeat) return LessonTableRegion.button;
  if (seatIndex ==
      blindsSmallBlindSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.smallBlind;
  }
  if (seatIndex ==
      blindsBigBlindSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.bigBlind;
  }
  return LessonTableRegion.emptySeat;
}

/// Role for a seat on a six-max position-labels layout.
LessonTableRegion positionRoleForSeat({
  required int seatIndex,
  required int buttonSeat,
  required int seatCount,
}) {
  if (seatIndex == buttonSeat) return LessonTableRegion.button;
  if (seatIndex ==
      blindsSmallBlindSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.smallBlind;
  }
  if (seatIndex ==
      blindsBigBlindSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.bigBlind;
  }
  if (seatIndex ==
      positionEarlySeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.earlyPosition;
  }
  if (seatIndex ==
      positionHijackSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.hijack;
  }
  if (seatIndex ==
      positionCutoffSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.cutoff;
  }
  return LessonTableRegion.emptySeat;
}

/// A tappable answer target on the lesson mini-table.
class LessonTableTapTarget {
  /// Creates a tap target.
  const LessonTableTapTarget(this.region, {this.seatIndex});

  final LessonTableRegion region;

  /// Absolute seat index when [region] is a blinds seat.
  final int? seatIndex;
}

/// Felt strip with hero holes, optional board, and face-down seats.
class LessonTableContext extends StatelessWidget {
  /// Creates the table context chrome.
  const LessonTableContext({
    super.key,
    required this.scene,
    this.selectedRegion,
    this.selectedSeatIndex,
    this.onRegionTap,
    this.enabled = true,
    this.showSoftPulse = false,
  });

  final LessonTableScene scene;

  /// Currently selected region (gold border).
  final LessonTableRegion? selectedRegion;

  /// Currently selected seat on a blinds layout.
  final int? selectedSeatIndex;

  /// When set, table regions are tappable answers.
  final ValueChanged<LessonTableTapTarget>? onRegionTap;

  final bool enabled;

  /// Guided soft pulse on [scene.highlight] when nothing is selected yet.
  final bool showSoftPulse;

  bool get _interactive => onRegionTap != null;

  @override
  Widget build(BuildContext context) {
    return switch (scene.layout) {
      LessonTableLayout.blindsSeats => _buildBlindsSeats(),
      LessonTableLayout.positionLabels => _buildPositionLabels(),
      LessonTableLayout.blindsTiming => _buildBlindsTiming(),
      LessonTableLayout.streetEndPhases => _buildStreetEndPhases(),
      LessonTableLayout.potFoldWinOutcomes => _buildPotFoldWinOutcomes(),
      LessonTableLayout.potShowdownOutcomes => _buildPotShowdownOutcomes(),
      LessonTableLayout.potSideOutcomes => _buildPotSideOutcomes(),
      LessonTableLayout.potOpenSizeOutcomes => _buildPotOpenSizeOutcomes(),
      LessonTableLayout.holeCards => _buildHoleCards(),
    };
  }

  Widget _feltShell({required Widget child, required String semanticsLabel}) {
    return Semantics(
      label: semanticsLabel,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.feltLight, AppColors.feltDark],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.feltBorder.withValues(alpha: 0.85),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildBlindsSeats() {
    final n = scene.seatCount;
    final button = scene.buttonSeat % n;
    final sb = blindsSmallBlindSeat(buttonSeat: button, seatCount: n);
    final bb = blindsBigBlindSeat(buttonSeat: button, seatCount: n);
    final bottomRow = <int>[button, sb, bb];
    final topRow = <int>[
      for (var i = 0; i < n; i++)
        if (!bottomRow.contains(i)) i,
    ];

    LessonTableRegion roleOf(int seat) => blindsRoleForSeat(
      seatIndex: seat,
      buttonSeat: button,
      seatCount: n,
    );

    bool pulseRole(LessonTableRegion role) {
      if (!showSoftPulse ||
          selectedRegion != null ||
          selectedSeatIndex != null) {
        return false;
      }
      return switch (scene.highlight) {
        LessonTableHighlight.button => role == LessonTableRegion.button,
        LessonTableHighlight.smallBlind =>
          role == LessonTableRegion.smallBlind,
        LessonTableHighlight.bigBlind => role == LessonTableRegion.bigBlind,
        _ => false,
      };
    }

    Widget seatChip(int seat) {
      final role = roleOf(seat);
      final selected =
          selectedSeatIndex == seat ||
          (selectedSeatIndex == null && selectedRegion == role);
      return _BlindsSeatChip(
        seatIndex: seat,
        role: role,
        numberSeats: scene.numberSeats,
        selected: selected,
        highlighted: pulseRole(role),
        enabled: enabled && _interactive,
        onTap:
            _interactive
                ? () => onRegionTap!(
                  LessonTableTapTarget(role, seatIndex: seat),
                )
                : null,
      );
    }

    return _feltShell(
      semanticsLabel:
          _interactive
              ? 'Interactive poker table with button and blinds'
              : 'Poker table showing dealer button and blinds',
      child: Column(
        children: [
          if (topRow.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [for (final s in topRow) seatChip(s)],
            ),
          const SizedBox(height: 8),
          Text(
            scene.caption ??
                (scene.numberSeats
                    ? 'Button is seat $button · tap the small blind'
                    : 'Clockwise: button → small blind → big blind'),
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [for (final s in bottomRow) seatChip(s)],
          ),
        ],
      ),
    );
  }

  Widget _buildPositionLabels() {
    final n = scene.seatCount;
    final button = scene.buttonSeat % n;
    final sb = blindsSmallBlindSeat(buttonSeat: button, seatCount: n);
    final bb = blindsBigBlindSeat(buttonSeat: button, seatCount: n);
    final ep = positionEarlySeat(buttonSeat: button, seatCount: n);
    final hj = positionHijackSeat(buttonSeat: button, seatCount: n);
    final co = positionCutoffSeat(buttonSeat: button, seatCount: n);
    // Clockwise visual: late seats on the bottom rail, early seats on top.
    final bottomRow = <int>[co, button, sb];
    final topRow = <int>[bb, ep, hj];

    LessonTableRegion roleOf(int seat) => positionRoleForSeat(
          seatIndex: seat,
          buttonSeat: button,
          seatCount: n,
        );

    bool pulseRole(LessonTableRegion role) {
      if (!showSoftPulse ||
          selectedRegion != null ||
          selectedSeatIndex != null) {
        return false;
      }
      return switch (scene.highlight) {
        LessonTableHighlight.button => role == LessonTableRegion.button,
        LessonTableHighlight.smallBlind =>
          role == LessonTableRegion.smallBlind ||
              role == LessonTableRegion.bigBlind,
        LessonTableHighlight.bigBlind => role == LessonTableRegion.bigBlind,
        LessonTableHighlight.earlyPosition =>
          role == LessonTableRegion.earlyPosition,
        LessonTableHighlight.hijack => role == LessonTableRegion.hijack,
        LessonTableHighlight.cutoff => role == LessonTableRegion.cutoff,
        _ => false,
      };
    }

    Widget seatChip(int seat) {
      final role = roleOf(seat);
      final selected =
          selectedSeatIndex == seat ||
          (selectedSeatIndex == null && selectedRegion == role);
      return _PositionSeatChip(
        role: role,
        selected: selected,
        highlighted: pulseRole(role),
        enabled: enabled && _interactive,
        onTap: _interactive
            ? () => onRegionTap!(
                  LessonTableTapTarget(role, seatIndex: seat),
                )
            : null,
      );
    }

    return _feltShell(
      semanticsLabel: _interactive
          ? 'Interactive six-max table with position labels'
          : 'Six-max table showing EP, HJ, CO, button, and blinds',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [for (final s in topRow) seatChip(s)],
          ),
          const SizedBox(height: 6),
          Text(
            scene.caption ?? 'EP · HJ · CO · BTN · SB · BB',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [for (final s in bottomRow) seatChip(s)],
          ),
          if (scene.showSeatNeverMatters) ...[
            const SizedBox(height: 8),
            _TappableRegion(
              label: 'Seat never matters',
              selected: selectedRegion == LessonTableRegion.seatNeverMatters,
              highlighted: false,
              enabled: enabled && _interactive,
              onTap: _interactive
                  ? () => onRegionTap!(
                        const LessonTableTapTarget(
                          LessonTableRegion.seatNeverMatters,
                        ),
                      )
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  'Seat never matters',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBlindsTiming() {
    Widget phase({
      required LessonTableRegion region,
      required String title,
      required String detail,
      required Widget visual,
    }) {
      final selected = selectedRegion == region;
      return Expanded(
        child: _TappableRegion(
          label: title,
          selected: selected,
          enabled: enabled && _interactive,
          onTap:
              _interactive
                  ? () => onRegionTap!(LessonTableTapTarget(region))
                  : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
            child: Column(
              children: [
                visual,
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _feltShell(
      semanticsLabel:
          _interactive
              ? 'Interactive hand timing — when blinds post'
              : 'Hand timing phases',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          phase(
            region: LessonTableRegion.beforeDeal,
            title: 'Before deal',
            detail: 'Blinds in',
            visual: const _BlindChipStack(amount: 2),
          ),
          const SizedBox(width: 6),
          phase(
            region: LessonTableRegion.afterFlop,
            title: 'After flop',
            detail: 'Board out',
            visual: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final code in const ['Qs', 'Jh', '2c']) ...[
                  MiniCard(
                    card: CardModel.fromCode(code),
                    size: MiniCardSize.tiny,
                  ),
                  const SizedBox(width: 2),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          phase(
            region: LessonTableRegion.showdown,
            title: 'Showdown',
            detail: 'Cards up',
            visual: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CardBack(size: MiniCardSize.tiny),
                SizedBox(width: 2),
                CardBack(size: MiniCardSize.tiny),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreetEndPhases() {
    Widget phase({
      required LessonTableRegion region,
      required String title,
      required String detail,
      required Widget visual,
    }) {
      final selected = selectedRegion == region;
      return Expanded(
        child: _TappableRegion(
          label: title,
          selected: selected,
          enabled: enabled && _interactive,
          onTap:
              _interactive
                  ? () => onRegionTap!(LessonTableTapTarget(region))
                  : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
            child: Column(
              children: [
                visual,
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _feltShell(
      semanticsLabel:
          _interactive
              ? 'Interactive street timing — when betting ends'
              : 'Street end phases',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          phase(
            region: LessonTableRegion.streetActionMatched,
            title: 'Bets matched',
            detail: 'Action equal',
            visual: const _BlindChipStack(amount: 3),
          ),
          const SizedBox(width: 6),
          phase(
            region: LessonTableRegion.streetFlopDealt,
            title: 'Flop appears',
            detail: 'Deal only',
            visual: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final code in const ['Qs', 'Jh', '2c']) ...[
                  MiniCard(
                    card: CardModel.fromCode(code),
                    size: MiniCardSize.tiny,
                  ),
                  const SizedBox(width: 2),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          phase(
            region: LessonTableRegion.streetSomeoneFolds,
            title: 'Someone folds',
            detail: 'Others act',
            visual: const Icon(
              Icons.person_off_outlined,
              color: AppColors.slate,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPotFoldWinOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive fold-win — tap how you take the pot',
      semanticsStatic: 'Fold-win outcomes',
      caption: scene.caption ?? 'You bet · everyone folds',
      phases: [
        (
          region: LessonTableRegion.potTakeQuiet,
          title: 'Take pot',
          detail: 'No show',
          visual: const Icon(
            Icons.savings_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.potMustShow,
          title: 'Must show',
          detail: 'Always',
          visual: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final code in const ['Ah', 'Kd']) ...[
                MiniCard(
                  card: CardModel.fromCode(code),
                  size: MiniCardSize.tiny,
                ),
                const SizedBox(width: 2),
              ],
            ],
          ),
        ),
        (
          region: LessonTableRegion.potDealerShows,
          title: 'Dealer shows',
          detail: 'Forced',
          visual: const Icon(
            Icons.visibility_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPotShowdownOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive showdown — tap what happens next',
      semanticsStatic: 'Showdown outcomes',
      caption: scene.caption ?? 'River · called',
      phases: [
        (
          region: LessonTableRegion.potShowdown,
          title: 'Showdown',
          detail: 'Best five',
          visual: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final code in const ['Ah', 'Qs']) ...[
                MiniCard(
                  card: CardModel.fromCode(code),
                  size: MiniCardSize.tiny,
                ),
                const SizedBox(width: 2),
              ],
            ],
          ),
        ),
        (
          region: LessonTableRegion.potLastBettor,
          title: 'Last bettor',
          detail: 'No show',
          visual: const Icon(
            Icons.gavel_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.potChopDefault,
          title: 'Always chop',
          detail: 'Split',
          visual: const Icon(
            Icons.call_split,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPotSideOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive side pot — tap what is true',
      semanticsStatic: 'Side pot outcomes',
      caption: scene.caption ?? 'You all-in short · others keep betting',
      phases: [
        (
          region: LessonTableRegion.potSideForms,
          title: 'Side pot',
          detail: 'Unmatched',
          visual: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PotChipDot(label: 'M', gold: true),
              SizedBox(width: 4),
              _PotChipDot(label: 'S', gold: false),
            ],
          ),
        ),
        (
          region: LessonTableRegion.potWinAll,
          title: 'Win all',
          detail: 'Later chips',
          visual: const Icon(
            Icons.all_inclusive,
            color: AppColors.slate,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.potHandDead,
          title: 'Hand dead',
          detail: 'Short out',
          visual: const Icon(
            Icons.block,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPotOpenSizeOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive pot size — tap the chip total',
      semanticsStatic: 'Open pot size outcomes',
      caption: scene.caption ?? '1/2 · BTN opens 6',
      phases: [
        (
          region: LessonTableRegion.potChipsSeven,
          title: '7 chips',
          detail: 'Miss a blind',
          visual: const _PotChipDot(label: '7', gold: false),
        ),
        (
          region: LessonTableRegion.potChipsNine,
          title: '9 chips',
          detail: '1+2+6',
          visual: const _PotChipDot(label: '9', gold: true),
        ),
        (
          region: LessonTableRegion.potChipsTwelve,
          title: '12 chips',
          detail: 'Too big',
          visual: const _PotChipDot(label: '12', gold: false),
        ),
      ],
    );
  }

  Widget _buildOutcomePhases({
    required String semanticsInteractive,
    required String semanticsStatic,
    required String caption,
    required List<
      ({
        LessonTableRegion region,
        String title,
        String detail,
        Widget visual,
      })
    >
    phases,
  }) {
    Widget phase({
      required LessonTableRegion region,
      required String title,
      required String detail,
      required Widget visual,
    }) {
      final selected = selectedRegion == region;
      return Expanded(
        child: _TappableRegion(
          label: title,
          selected: selected,
          enabled: enabled && _interactive,
          onTap:
              _interactive
                  ? () => onRegionTap!(LessonTableTapTarget(region))
                  : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Column(
              children: [
                visual,
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _feltShell(
      semanticsLabel: _interactive ? semanticsInteractive : semanticsStatic,
      child: Column(
        children: [
          Text(
            caption,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < phases.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                phase(
                  region: phases[i].region,
                  title: phases[i].title,
                  detail: phases[i].detail,
                  visual: phases[i].visual,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoleCards() {
    final hero = scene.heroCodes
        .map(CardModel.fromCode)
        .toList(growable: false);
    final board = scene.boardCodes
        .map(CardModel.fromCode)
        .toList(growable: false);
    final pulseHero =
        showSoftPulse &&
        selectedRegion == null &&
        scene.highlight == LessonTableHighlight.hero;
    final pulseBoard =
        showSoftPulse &&
        selectedRegion == null &&
        scene.highlight == LessonTableHighlight.board;

    return _feltShell(
      semanticsLabel: _semanticsLabel(hero, board),
      child: Column(
        children: [
          if (scene.villainSeatCount > 0 || scene.showDealerChip) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < scene.villainSeatCount; i++)
                  _TappableRegion(
                    label: 'Other seat face-down cards',
                    selected: selectedRegion == LessonTableRegion.villain,
                    enabled: enabled && _interactive,
                    onTap:
                        _interactive
                            ? () => onRegionTap!(
                              const LessonTableTapTarget(
                                LessonTableRegion.villain,
                              ),
                            )
                            : null,
                    child: const _FaceDownPair(),
                  ),
                if (scene.showDealerChip)
                  _TappableRegion(
                    label: 'Dealer',
                    selected: selectedRegion == LessonTableRegion.dealer,
                    enabled: enabled && _interactive,
                    onTap:
                        _interactive
                            ? () => onRegionTap!(
                              const LessonTableTapTarget(
                                LessonTableRegion.dealer,
                              ),
                            )
                            : null,
                    child: const _DealerChip(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (board.isNotEmpty) ...[
            _TappableRegion(
              label: 'Board ${board.map((c) => c.display).join(' ')}',
              selected: selectedRegion == LessonTableRegion.board,
              highlighted: pulseBoard,
              enabled: enabled && _interactive,
              onTap:
                  _interactive
                      ? () => onRegionTap!(
                        const LessonTableTapTarget(LessonTableRegion.board),
                      )
                      : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < board.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      MiniCard(card: board[i], size: MiniCardSize.small),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          _TappableRegion(
            label: 'Your hole cards ${hero.map((c) => c.display).join(' ')}',
            selected: selectedRegion == LessonTableRegion.hero,
            highlighted: pulseHero,
            enabled: enabled && _interactive,
            onTap:
                _interactive
                    ? () => onRegionTap!(
                      const LessonTableTapTarget(LessonTableRegion.hero),
                    )
                    : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                children: [
                  Text(
                    scene.caption ?? 'You',
                    style: GoogleFonts.manrope(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < hero.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        MiniCard(card: hero[i], size: MiniCardSize.hero),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (scene.showMuck) ...[
            const SizedBox(height: 8),
            _TappableRegion(
              label: 'Muck pile',
              selected: selectedRegion == LessonTableRegion.muck,
              enabled: enabled && _interactive,
              onTap:
                  _interactive
                      ? () => onRegionTap!(
                        const LessonTableTapTarget(LessonTableRegion.muck),
                      )
                      : null,
              child: const _MuckPile(),
            ),
          ],
        ],
      ),
    );
  }

  String _semanticsLabel(List<CardModel> hero, List<CardModel> board) {
    if (_interactive) {
      return 'Interactive poker table';
    }
    final heroText = hero.map((c) => c.display).join(' ');
    final parts = <String>['Your hole cards $heroText'];
    if (board.isNotEmpty) {
      parts.add('Board ${board.map((c) => c.display).join(' ')}');
    }
    if (scene.villainSeatCount > 0) {
      parts.add(
        '${scene.villainSeatCount} other '
        '${scene.villainSeatCount == 1 ? 'seat has' : 'seats have'} '
        'face-down hole cards',
      );
    }
    return parts.join('. ');
  }
}

class _TappableRegion extends StatefulWidget {
  const _TappableRegion({
    required this.label,
    required this.child,
    required this.selected,
    required this.enabled,
    this.highlighted = false,
    this.onTap,
  });

  final String label;
  final Widget child;
  final bool selected;
  final bool enabled;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  State<_TappableRegion> createState() => _TappableRegionState();
}

class _TappableRegionState extends State<_TappableRegion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _TappableRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlighted != widget.highlighted ||
        oldWidget.selected != widget.selected) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    final shouldPulse = widget.highlighted && !widget.selected;
    if (shouldPulse) {
      if (!_pulse.isAnimating) {
        _pulse.repeat(reverse: true);
      }
    } else {
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
    // Keep InkWell's child tree stable across pulse ticks. Glow paints in an
    // IgnorePointer overlay so the soft pulse never steals / cancels taps.
    final staticBorder = widget.selected
        ? AppColors.gold
        : widget.highlighted
        ? AppColors.gold.withValues(alpha: 0.55)
        : Colors.transparent;
    final staticFill = widget.selected
        ? AppColors.gold.withValues(alpha: 0.22)
        : widget.highlighted
        ? AppColors.gold.withValues(alpha: 0.1)
        : Colors.transparent;

    final framed = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: staticFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: staticBorder,
              width: widget.selected ? 2.4 : 1.8,
            ),
          ),
          child: widget.child,
        ),
        if (widget.highlighted && !widget.selected)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  final glow = 0.35 + (_pulse.value * 0.45);
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: glow),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.22 * glow),
                          blurRadius: 12 + (8 * _pulse.value),
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );

    if (widget.onTap == null) return framed;

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: framed,
        ),
      ),
    );
  }
}

class _PositionSeatChip extends StatelessWidget {
  const _PositionSeatChip({
    required this.role,
    required this.selected,
    required this.highlighted,
    required this.enabled,
    required this.onTap,
  });

  final LessonTableRegion role;
  final bool selected;
  final bool highlighted;
  final bool enabled;
  final VoidCallback? onTap;

  String get _code => switch (role) {
        LessonTableRegion.button => 'BTN',
        LessonTableRegion.smallBlind => 'SB',
        LessonTableRegion.bigBlind => 'BB',
        LessonTableRegion.earlyPosition => 'EP',
        LessonTableRegion.hijack => 'HJ',
        LessonTableRegion.cutoff => 'CO',
        _ => '?',
      };

  String get _subtitle => switch (role) {
        LessonTableRegion.button => 'Dealer',
        LessonTableRegion.smallBlind => 'Posts 1',
        LessonTableRegion.bigBlind => 'Posts 2',
        LessonTableRegion.earlyPosition => 'UTG',
        LessonTableRegion.hijack => 'Mid',
        LessonTableRegion.cutoff => 'Late',
        _ => '',
      };

  String get _a11y => switch (role) {
        LessonTableRegion.button => 'Button seat',
        LessonTableRegion.smallBlind => 'Small blind seat',
        LessonTableRegion.bigBlind => 'Big blind seat',
        LessonTableRegion.earlyPosition => 'Early position seat',
        LessonTableRegion.hijack => 'Hijack seat',
        LessonTableRegion.cutoff => 'Cutoff seat',
        _ => 'Seat',
      };

  @override
  Widget build(BuildContext context) {
    return _TappableRegion(
      label: _a11y,
      selected: selected,
      highlighted: highlighted,
      enabled: enabled,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Column(
          children: [
            Text(
              _code,
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _subtitle,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlindsSeatChip extends StatelessWidget {
  const _BlindsSeatChip({
    required this.seatIndex,
    required this.role,
    required this.numberSeats,
    required this.selected,
    required this.highlighted,
    required this.enabled,
    required this.onTap,
  });

  final int seatIndex;
  final LessonTableRegion role;
  final bool numberSeats;
  final bool selected;
  final bool highlighted;
  final bool enabled;
  final VoidCallback? onTap;

  String get _title {
    if (numberSeats) return 'Seat $seatIndex';
    return switch (role) {
      LessonTableRegion.button => 'Button',
      LessonTableRegion.smallBlind => 'Small blind',
      LessonTableRegion.bigBlind => 'Big blind',
      _ => 'Seat',
    };
  }

  String get _a11y {
    final roleLabel = switch (role) {
      LessonTableRegion.button => 'dealer button',
      LessonTableRegion.smallBlind => 'small blind posting 1',
      LessonTableRegion.bigBlind => 'big blind posting 2',
      _ => 'empty seat',
    };
    return numberSeats ? 'Seat $seatIndex, $roleLabel' : roleLabel;
  }

  @override
  Widget build(BuildContext context) {
    return _TappableRegion(
      label: _a11y,
      selected: selected,
      highlighted: highlighted,
      enabled: enabled,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
        child: Column(
          children: [
            Text(
              _title,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            switch (role) {
              LessonTableRegion.button => const _DealerChipBadge(),
              LessonTableRegion.smallBlind => const _BlindChipStack(amount: 1),
              LessonTableRegion.bigBlind => const _BlindChipStack(amount: 2),
              _ => const _EmptySeatMark(),
            },
            if (numberSeats && role != LessonTableRegion.emptySeat) ...[
              const SizedBox(height: 4),
              Text(
                switch (role) {
                  LessonTableRegion.button => 'D',
                  LessonTableRegion.smallBlind => 'SB',
                  LessonTableRegion.bigBlind => 'BB',
                  _ => '',
                },
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DealerChipBadge extends StatelessWidget {
  const _DealerChipBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cream,
        border: Border.all(color: AppColors.bgDark, width: 2),
      ),
      child: Text(
        'D',
        style: GoogleFonts.manrope(
          color: AppColors.bgDark,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _BlindChipStack extends StatelessWidget {
  const _BlindChipStack({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < amount; i++)
            Positioned(
              top: (amount - 1 - i) * 4.0,
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == amount - 1 ? AppColors.gold : AppColors.goldMuted,
                  border: Border.all(color: AppColors.bgDark, width: 1.5),
                ),
                child: Text(
                  '$amount',
                  style: GoogleFonts.manrope(
                    color: AppColors.bgDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PotChipDot extends StatelessWidget {
  const _PotChipDot({required this.label, required this.gold});

  final String label;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final color = gold ? AppColors.gold : AppColors.slate;
    return Container(
      width: label.length > 1 ? 32 : 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.3),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptySeatMark extends StatelessWidget {
  const _EmptySeatMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.feltDark.withValues(alpha: 0.55),
        border: Border.all(
          color: AppColors.slateDark.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Text(
        '·',
        style: GoogleFonts.manrope(
          color: AppColors.slate,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _FaceDownPair extends StatelessWidget {
  const _FaceDownPair();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Hidden',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardBack(size: MiniCardSize.tiny),
            SizedBox(width: 3),
            CardBack(size: MiniCardSize.tiny),
          ],
        ),
      ],
    );
  }
}

class _DealerChip extends StatelessWidget {
  const _DealerChip();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Dealer',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const _DealerChipBadge(),
      ],
    );
  }
}

class _MuckPile extends StatelessWidget {
  const _MuckPile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: -0.18,
            child: const CardBack(size: MiniCardSize.tiny),
          ),
          Transform.translate(
            offset: const Offset(-8, 2),
            child: Transform.rotate(
              angle: 0.12,
              child: const CardBack(size: MiniCardSize.tiny),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Muck',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
