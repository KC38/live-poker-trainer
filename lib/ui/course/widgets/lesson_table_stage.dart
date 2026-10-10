/// Full poker table used as the lesson stage.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_soft_pulse_scope.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/poker_table_bands.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

/// Six-max ring for Button and blinds. Index 3 is the dealer.
const int lessonBlindsVillainCount = 5;

/// Felt index of the dealer button on [lessonBlindsVillainCount] villains.
const int lessonBlindsButtonIndex = 3;

/// Felt index of the small blind, one seat clockwise from the button.
const int lessonBlindsSmallBlindIndex = 4;

/// Felt index of the big blind, two seats clockwise from the button.
const int lessonBlindsBigBlindIndex = 5;

/// Felt index immediately counterclockwise from the button.
const int lessonBlindsRightOfButtonIndex = 2;

/// Hand drawn by [LessonTableStage].
///
/// Villains take the names Sam, Jo, Rio, Max, and Kai, then repeat. The first
/// opponent shows [villainCodes] only when that list has two cards.
/// [villainHoleCodes] can face-up several opponents at once (each entry two
/// codes, in seat order). A null [dealerIndex] leaves the hero on the button.
/// Otherwise the small blind and big blind sit one and two seats clockwise
/// from the button, unless [sbIndex] or [bbIndex] is set, and no seat glows
/// unless [activeSeatIndex] is set. [positionLabels] renames the ring EP, HJ,
/// CO, BTN, SB, BB. [seatNames] overrides those labels when set (action-order
/// steps use UTG in place of EP). The table plays [smallBlind]/[bigBlind] with
/// 100 big blind stacks. [villainArchetypes] gives the opponents, in seat
/// order, real player types. [postSmallBlind] / [postBigBlind] false leave
/// that blind unposted until a quiz reveals it.
/// Six-max seat names for action-order taps (UTG, not EP).
const List<String> lessonActionOrderSeatNames = [
  'UTG',
  'HJ',
  'CO',
  'BTN',
  'SB',
  'BB',
];

/// Six-max names when the hero (index 0, bottom seat) is on the button.
const List<String> lessonHeroOnButtonSeatNames = [
  'BTN',
  'SB',
  'BB',
  'UTG',
  'HJ',
  'CO',
];

/// UTG, clockwise from a hero-on-the-button six-max ring.
const int lessonHeroOnButtonUtgIndex = 3;

/// Felt index for a position label on the six-max action-order ring.
int? lessonActionOrderSeatIndex(String label) {
  switch (label.trim().toUpperCase()) {
    case 'UTG':
    case 'EP':
      return 0;
    case 'HJ':
      return 1;
    case 'CO':
      return 2;
    case 'BTN':
      return 3;
    case 'SB':
      return 4;
    case 'BB':
      return 5;
    default:
      return null;
  }
}

/// Seats that already folded on an action-order table, so remaining actors
/// are obvious.
///
/// Guided preflop: an open folded through UTG and HJ, then CO / BTN / SB act
/// (BB still to act). Scaffolded postflop: heads-up SB versus BTN.
List<int> lessonSeatOrderFoldedIndexes(String activityId) {
  switch (activityId) {
    case 'act-02-01-02-guided-pre':
      return const [0, 1];
    case 'act-02-01-02-scaffolded-post':
      return const [0, 1, 2, 5];
    default:
      return const [];
  }
}

GameState lessonTableStageGame({
  List<String> heroCodes = const ['Ah', 'Kd'],
  List<String> boardCodes = const [],
  List<String> villainCodes = const [],
  List<List<String>> villainHoleCodes = const [],
  int villainCount = 3,
  int? dealerIndex,
  int? sbIndex,
  int? bbIndex,
  int? activeSeatIndex,
  bool positionLabels = false,
  List<String>? seatNames,
  double smallBlind = lessonSmallBlind,
  double bigBlind = lessonBigBlind,
  List<PlayerArchetype>? villainArchetypes,
  bool postSmallBlind = true,
  bool postBigBlind = true,
  List<double>? streetBets,
  double? potTotal,
  String? heroActionLabel,
  String? villainActionLabel,

  /// Remaining chips for the hero seat. Null keeps the default band stack.
  double? heroStackChips,

  /// Remaining chips for every non-hero seat. Null keeps the default band stack.
  double? villainStackChips,

  /// Seat indexes that have folded (dimmed, no hole cards).
  List<int> foldedSeatIndexes = const [],

  /// Optional last-action badge per seat index (e.g. RAISE on the button).
  Map<int, String> seatActionLabels = const {},

  /// Seat ids that take [displayPot]. Empty leaves the pot in the middle.
  List<int> winnerIds = const [],
}) {
  final base = lessonBandGame(
    heroCodes: heroCodes,
    boardCodes: boardCodes,
    villainSeatCount: villainCount,
    smallBlind: smallBlind,
    bigBlind: bigBlind,
    dealerIndex: dealerIndex ?? 0,
    sbIndex: sbIndex,
    bbIndex: bbIndex,
    postSmallBlind: postSmallBlind,
    postBigBlind: postBigBlind,
  );
  const names = ['Sam', 'Jo', 'Rio', 'Max', 'Kai'];
  final holesByVillain = <int, List<String>>{
    for (var i = 0; i < villainHoleCodes.length; i++)
      if (villainHoleCodes[i].length >= 2) i: villainHoleCodes[i],
  };
  if (holesByVillain.isEmpty && villainCodes.length >= 2) {
    holesByVillain[0] = villainCodes;
  }
  var villain = 0;
  final players = <PlayerModel>[];
  for (final player in base.players) {
    if (player.isHero) {
      players.add(player);
      continue;
    }
    final holes = holesByVillain[villain];
    final types = villainArchetypes;
    players.add(
      player.copyWith(
        name: names[villain % names.length],
        archetype: types == null || types.isEmpty
            ? null
            : types[villain % types.length],
        holeCards: holes == null
            ? player.holeCards
            : [
                for (final code in holes.take(2)) CardModel.fromCode(code),
              ],
      ),
    );
    villain += 1;
  }
  const positions = ['EP', 'HJ', 'CO', 'BTN', 'SB', 'BB'];
  final labels = seatNames ?? (positionLabels ? positions : null);
  final seated = labels == null
      ? players
      : [
          for (var i = 0; i < players.length; i++)
            players[i].copyWith(name: labels[i % labels.length]),
        ];
  var named = base.copyWith(players: seated);
  if (streetBets != null || potTotal != null) {
    named = _applyLessonStageStreetMoney(
      named,
      streetBets: streetBets ?? const <double>[],
      potTotal: potTotal,
      heroActionLabel: heroActionLabel,
      villainActionLabel: villainActionLabel,
    );
  }
  if (heroStackChips != null || villainStackChips != null) {
    named = named.copyWith(
      players: [
        for (final player in named.players)
          player.isHero
              ? (heroStackChips == null
                  ? player
                  : player.copyWith(stack: heroStackChips))
              : (villainStackChips == null
                  ? player
                  : player.copyWith(stack: villainStackChips)),
      ],
    );
  }
  if (foldedSeatIndexes.isNotEmpty || seatActionLabels.isNotEmpty) {
    final folded = foldedSeatIndexes.toSet();
    named = named.copyWith(
      players: [
        for (var i = 0; i < named.players.length; i++)
          named.players[i].copyWith(
            folded: folded.contains(i) ? true : null,
            lastActionLabel:
                seatActionLabels[i] ??
                (folded.contains(i) ? 'FOLD' : null),
            clearLastAction:
                !seatActionLabels.containsKey(i) && !folded.contains(i),
          ),
      ],
    );
  }
  // Default GameState treats seat 0 as to-act, which gold-rings the You
  // name box. SoftPulse / Hint must not inherit that action-turn glow —
  // only [activeSeatIndex] lights a seat.
  named = named.copyWith(activePlayerIndex: activeSeatIndex ?? -1);
  if (winnerIds.isEmpty) return named;
  return awardLessonStagePot(named, winnerIds);
}

/// Credits [winnerIds] with the center pot and marks the hand over.
///
/// Stacks rise immediately; [GameState.awardedPot] keeps the pot label on
/// the felt while [FeltTableView.awardingChips] flies each share to a seat.
GameState awardLessonStagePot(GameState base, List<int> winnerIds) {
  final pot = base.displayPot;
  final payouts = Money.splitPot(pot, winnerIds);
  return base.copyWith(
    players: [
      for (var i = 0; i < base.players.length; i++)
        base.players[i].copyWith(
          stack: Money.round(
            base.players[i].stack + (payouts[base.players[i].id] ?? 0),
          ),
          currentBet: 0,
        ),
    ],
    mainPot: 0,
    awardedPot: pot,
    isHandOver: true,
    winnerIds: List<int>.from(winnerIds),
    waitingForHero: false,
    activePlayerIndex: -1,
  );
}

/// Hero seat after a correct fold-win "Take pot" tap.
List<int> lessonPotAwardWinnerIds({
  required String activityId,
  required String? selectedId,
}) {
  if (selectedId == 'no-show' && activityId == 'act-01-05-01-guided-fold-win') {
    return const [0];
  }
  return const [];
}

/// Posts authored street bets and sets main pot from a display [potTotal].
GameState _applyLessonStageStreetMoney(
  GameState base, {
  required List<double> streetBets,
  double? potTotal,
  String? heroActionLabel,
  String? villainActionLabel,
}) {
  final n = base.players.length;
  final bets = [
    for (var i = 0; i < n; i++) i < streetBets.length ? streetBets[i] : 0.0,
  ];
  final streetSum = bets.fold<double>(0, (sum, b) => sum + b);
  final total = potTotal ?? (base.mainPot + streetSum);
  final mainPot = (total - streetSum).clamp(0, double.infinity).toDouble();
  final highest = bets.fold<double>(0, (m, b) => b > m ? b : m);
  final players = <PlayerModel>[
    for (var i = 0; i < n; i++)
      base.players[i].copyWith(
        currentBet: bets[i],
        stack: (base.players[i].stack + base.players[i].currentBet - bets[i])
            .clamp(0, double.infinity)
            .toDouble(),
        lastActionLabel: i == 0
            ? heroActionLabel
            : (i == 1 ? villainActionLabel : null),
        clearLastAction:
            (i == 0 && heroActionLabel == null) ||
            (i == 1 && villainActionLabel == null) ||
            i > 1,
      ),
  ];
  return base.copyWith(
    players: players,
    mainPot: mainPot,
    highestBet: highest,
  );
}

/// Player type a step names for its opponent, read from [texts] in order.
///
/// "Calling Station", "station", and "sticky" read as the Calling Station.
/// Nit, Maniac, TAG, and LAG read as themselves. A text that says "unknown"
/// names no type, because having no read is that step's point.
PlayerArchetype? lessonNamedVillainType(List<String?> texts) {
  for (final text in texts) {
    if (text == null || text.isEmpty) continue;
    final words = _words(text);
    if (words.contains('unknown')) return null;
    if (words.contains('station') || words.contains('sticky')) {
      return PlayerArchetype.callingStation;
    }
    if (words.contains('nit')) return PlayerArchetype.nit;
    if (words.contains('maniac')) return PlayerArchetype.maniac;
    if (words.contains('lag')) return PlayerArchetype.lag;
    if (words.contains('tag')) return PlayerArchetype.tag;
  }
  return null;
}

Set<String> _words(String text) {
  final words = <String>{};
  final word = StringBuffer();
  for (final unit in text.toLowerCase().codeUnits) {
    final letter = unit >= 0x61 && unit <= 0x7a;
    if (letter) {
      word.writeCharCode(unit);
    } else if (word.isNotEmpty) {
      words.add(word.toString());
      word.clear();
    }
  }
  if (word.isNotEmpty) words.add(word.toString());
  return words;
}

/// Where the stage draws its SoftPulse cues.
enum LessonTableCue {
  /// No cue.
  none,

  /// CuePulse + arrows on the hero's hole cards.
  hero,

  /// CuePulse + arrows on every dealt community card.
  board,
}

/// The oval, the pot, and every seat this step includes.
class LessonTableStage extends StatelessWidget {
  /// Creates a full-table stage.
  const LessonTableStage({
    super.key,
    this.heroCodes = const ['Ah', 'Kd'],
    this.boardCodes = const [],
    this.villainCodes = const [],
    this.villainHoleCodes = const [],
    this.villainCount = 3,
    this.heroFaceUp = false,
    this.cue = LessonTableCue.none,
    this.enabled = true,
    this.dealerIndex,
    this.sbIndex,
    this.bbIndex,
    this.activeSeatIndex,
    this.cueSeatIndex,
    this.onHeroTap,
    this.onVillainTap,
    this.onBoardTap,
    this.onBoardCardTap,
    this.onHeroCardTap,
    this.onSeatIndexTap,
    this.selectedBoardIndexes = const {},
    this.highlightBoardIndexes = const {},
    this.dimmedBoardIndexes = const {},
    this.boardOrderBadges = const {},
    this.selectedHeroIndexes = const {},
    this.selectedSeatIndexes = const {},
    this.highlightHeroIndexes = const {},
    this.dimmedHeroIndexes = const {},
    this.seatOrderBadges = const {},
    this.positionLabels = false,
    this.seatNames,
    this.smallBlind = lessonSmallBlind,
    this.bigBlind = lessonBigBlind,
    this.villainArchetypes,
    this.features,
    this.postSmallBlind = true,
    this.postBigBlind = true,
    this.streetBets,
    this.potTotal,
    this.heroActionLabel,
    this.villainActionLabel,
    this.heroStackChips,
    this.villainStackChips,
    this.foldedSeatIndexes = const [],
    this.seatActionLabels = const {},
    this.winnerIds = const [],
    this.awardingChips,
  });

  /// Hero hole cards. Hidden until [heroFaceUp] is true.
  final List<String> heroCodes;

  /// Community cards. Empty on a preflop step.
  final List<String> boardCodes;

  /// First opponent's hole cards, shown face up when this is two codes.
  final List<String> villainCodes;

  /// Face-up hole cards for several opponents, in seat order.
  final List<List<String>> villainHoleCodes;

  /// Other seats. The hero is always an extra seat.
  final int villainCount;

  /// When false, the hero's cards are two backs.
  final bool heroFaceUp;

  /// Arrow target.
  final LessonTableCue cue;

  /// Taps are ignored when false.
  final bool enabled;

  /// Dealer seat. Null keeps the hero on the button.
  final int? dealerIndex;

  /// Small-blind seat. Used with [dealerIndex].
  final int? sbIndex;

  /// Big-blind seat. Used with [dealerIndex].
  final int? bbIndex;

  /// Seat that glows. Null glows nobody when [dealerIndex] is set.
  final int? activeSeatIndex;

  /// Seat the step asks the learner to tap: a gold ring and a bouncing arrow.
  final int? cueSeatIndex;

  /// Learner tapped their own cards.
  final VoidCallback? onHeroTap;

  /// Learner tapped another seat. [index] is that player's index in the hand.
  final ValueChanged<int>? onVillainTap;

  /// Learner tapped the community cards.
  final VoidCallback? onBoardTap;

  /// Learner tapped one board card by index.
  final ValueChanged<int>? onBoardCardTap;

  /// Learner tapped one hero hole card by index.
  final ValueChanged<int>? onHeroCardTap;

  /// Learner tapped a seat. The value is that seat's index in the hand.
  final ValueChanged<int>? onSeatIndexTap;

  /// Board indexes with a cyan learner-selection ring.
  final Set<int> selectedBoardIndexes;

  /// Board indexes that bounce a cue arrow.
  final Set<int> highlightBoardIndexes;

  /// Board indexes faded as leftovers.
  final Set<int> dimmedBoardIndexes;

  /// 1-based order badge drawn on a selected board card.
  final Map<int, int> boardOrderBadges;

  /// Hero hole indexes with a cyan learner-selection ring.
  final Set<int> selectedHeroIndexes;

  /// Seat indexes with a cyan learner-selection ring.
  final Set<int> selectedSeatIndexes;

  /// Hero hole indexes that cue the next tap.
  final Set<int> highlightHeroIndexes;

  /// Hero hole indexes faded as leftovers.
  final Set<int> dimmedHeroIndexes;

  /// 1-based order badge drawn on a seat during showdown ranking.
  final Map<int, int> seatOrderBadges;

  /// Rename the six-max ring EP, HJ, CO, BTN, SB, BB.
  final bool positionLabels;

  /// Override seat display names when set (e.g. UTG instead of EP).
  ///
  /// Implies labeled seats even when [positionLabels] is false.
  final List<String>? seatNames;

  /// Stakes this step plays. `Blinds $1/$2 NLH` unless the step teaches
  /// another level.
  final double smallBlind;

  /// See [smallBlind].
  final double bigBlind;

  /// Opponent player types, in seat order. Without them every opponent is a
  /// plain player: no type tag, no VPIP/PFR, whatever the section.
  final List<PlayerArchetype>? villainArchetypes;

  /// Layers this step draws. Null takes the section preset from
  /// [TableFeaturesScope].
  final TableFeatures? features;

  /// When false, the small blind seat has no chips out yet (reveal-on-tap
  /// quizzes). The SB seat index and SoftPulse target stay the same.
  final bool postSmallBlind;

  /// When false, the big blind seat has no chips out yet (reveal-on-tap
  /// quizzes). The BB seat index and SoftPulse target stay the same.
  final bool postBigBlind;

  /// Per-seat street bets (hero at 0). Null keeps [lessonBandGame] defaults.
  final List<double>? streetBets;

  /// Display pot including [streetBets]. Null keeps the band default pot.
  final double? potTotal;

  /// Last-action badge on the hero after a Call / Bet / Raise.
  final String? heroActionLabel;

  /// Last-action badge on the first villain when a bet faces the hero.
  final String? villainActionLabel;

  /// Remaining chips drawn on the hero seat. Null keeps the default band stack.
  final double? heroStackChips;

  /// Remaining chips drawn on each villain seat. Null keeps the default band
  /// stack.
  final double? villainStackChips;

  /// Seat indexes that have folded (dimmed, no hole cards).
  final List<int> foldedSeatIndexes;

  /// Optional last-action badge per seat index.
  final Map<int, String> seatActionLabels;

  /// Seat ids that win the pot. Non-empty credits stacks and shows WINS.
  final List<int> winnerIds;

  /// When set, overrides flying the pot to [winnerIds]. Null flies whenever
  /// [winnerIds] is not empty.
  final bool? awardingChips;

  GameState get _game => lessonTableStageGame(
    heroCodes: heroCodes,
    boardCodes: boardCodes,
    villainCodes: villainCodes,
    villainHoleCodes: villainHoleCodes,
    villainCount: villainCount,
    dealerIndex: dealerIndex,
    sbIndex: sbIndex,
    bbIndex: bbIndex,
    activeSeatIndex: activeSeatIndex,
    positionLabels: positionLabels,
    seatNames: seatNames,
    smallBlind: smallBlind,
    bigBlind: bigBlind,
    villainArchetypes: villainArchetypes,
    postSmallBlind: postSmallBlind,
    postBigBlind: postBigBlind,
    streetBets: streetBets,
    potTotal: potTotal,
    heroActionLabel: heroActionLabel,
    villainActionLabel: villainActionLabel,
    heroStackChips: heroStackChips,
    villainStackChips: villainStackChips,
    foldedSeatIndexes: foldedSeatIndexes,
    seatActionLabels: seatActionLabels,
    winnerIds: winnerIds,
  );

  @override
  Widget build(BuildContext context) {
    final game = _game;
    final preset = features ?? TableFeaturesScope.of(context);
    final table = villainArchetypes == null
        ? preset.copyWith(playerTypes: false, stats: false)
        : preset;
    final faceUp = <int>{if (heroFaceUp) 0};
    if (villainHoleCodes.isNotEmpty) {
      for (var i = 0; i < villainHoleCodes.length; i++) {
        if (villainHoleCodes[i].length >= 2 && i + 1 < game.players.length) {
          faceUp.add(game.players[i + 1].id);
        }
      }
    } else if (villainCodes.length >= 2) {
      faceUp.add(1);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 360.0;
        return SizedBox(
          key: const ValueKey<String>('lesson-table-stage'),
          height: height,
          child: FeltTableView(
            game: game,
            // Hand identity only. Board length is the deal *target* — putting
            // community codes here restarted holes and every street whenever
            // a lesson button grew the board (PREFLOP → FLOP → TURN → RIVER).
            dealKey:
                'lesson-${heroCodes.join()}-${villainCodes.join()}'
                '-${[
                  for (final holes in villainHoleCodes) holes.join(),
                ].join('|')}'
                '-v$villainCount-d${dealerIndex ?? 0}',
            chipDisplayMode: ChipDisplayMode.dollars,
            awardingChips: awardingChips ?? winnerIds.isNotEmpty,
            features: table,
            showHoleCardBacks: true,
            heroCardsFaceUp: heroFaceUp,
            faceUpPlayerIds: faceUp,
            // Hole-card Hint / SoftPulse rings each hole card, never the
            // You name box. Board region cues still wrap the whole row;
            // per-card board taps SoftPulse each dealt card.
            highlightHero: cue == LessonTableCue.hero,
            highlightBoard: cue == LessonTableCue.board &&
                highlightBoardIndexes.isEmpty &&
                onBoardCardTap == null,
            selectedBoardIndexes: selectedBoardIndexes,
            highlightBoardIndexes:
                highlightBoardIndexes.isNotEmpty
                    ? highlightBoardIndexes
                    : (cue == LessonTableCue.board && onBoardCardTap != null
                        ? {for (var i = 0; i < boardCodes.length; i++) i}
                        : const <int>{}),
            dimmedBoardIndexes: dimmedBoardIndexes,
            boardOrderBadges: boardOrderBadges,
            selectedHeroIndexes: selectedHeroIndexes,
            selectedSeatIndexes: selectedSeatIndexes,
            highlightHeroIndexes:
                highlightHeroIndexes.isNotEmpty
                    ? highlightHeroIndexes
                    : (cue == LessonTableCue.hero ? const {0, 1} : const <int>{}),
            dimmedHeroIndexes: dimmedHeroIndexes,
            seatOrderBadges: seatOrderBadges,
            cueSeatIndex: cueSeatIndex,
            onDealReady: (ready) =>
                reportLessonFeltDealReady(context, ready: ready),
            onBoardTap: !enabled || onBoardTap == null || onBoardCardTap != null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onBoardTap!();
                  },
            onBoardCardTap: !enabled || onBoardCardTap == null
                ? null
                : (index) {
                    HapticFeedback.selectionClick();
                    onBoardCardTap!(index);
                  },
            onHeroCardTap: !enabled || onHeroCardTap == null
                ? null
                : (index) {
                    HapticFeedback.selectionClick();
                    onHeroCardTap!(index);
                  },
            onSeatTap: !enabled
                ? null
                : (PlayerModel player) {
                    if (player.isHero && onHeroCardTap != null) return;
                    HapticFeedback.selectionClick();
                    if (onSeatIndexTap != null) {
                      final index = game.players.indexWhere(
                        (seat) => seat.id == player.id,
                      );
                      if (index >= 0) onSeatIndexTap!(index);
                      return;
                    }
                    if (player.isHero) {
                      onHeroTap?.call();
                      return;
                    }
                    onVillainTap?.call(player.id);
                  },
          ),
        );
      },
    );
  }
}

/// First step of Your two cards: cards start face down, a tap peeks.
class LessonPeekTable extends StatefulWidget {
  /// Creates the peek stage.
  const LessonPeekTable({
    super.key,
    required this.onPeek,
    required this.onMiss,
    this.enabled = true,
  });

  /// Hero cards were tapped. The caller grades the step.
  final VoidCallback onPeek;

  /// Another seat was tapped.
  final VoidCallback onMiss;

  /// Taps are ignored when false.
  final bool enabled;

  @override
  State<LessonPeekTable> createState() => _LessonPeekTableState();
}

class _LessonPeekTableState extends State<LessonPeekTable> {
  bool _faceUp = false;

  @override
  Widget build(BuildContext context) {
    // Keep faces up after a successful peek even if this state remounts while
    // locked (answer dock / MediaQuery clamp). Locked means the peek graded.
    final revealed = _faceUp || !widget.enabled;
    // No empty board slot outlines: this step has no community cards.
    final features = TableFeaturesScope.of(
      context,
    ).copyWith(boardSlots: false);
    return LessonTableStage(
      villainCount: 3,
      heroFaceUp: revealed,
      cue: revealed ? LessonTableCue.none : LessonTableCue.hero,
      enabled: widget.enabled && !_faceUp,
      features: features,
      onHeroTap: () {
        setState(() => _faceUp = true);
        widget.onPeek();
      },
      onVillainTap: (_) => widget.onMiss(),
    );
  }
}

/// Button, then small blind, then big blind. A wrong seat is a miss.
class LessonBlindsClockwiseTable extends StatefulWidget {
  /// Creates the clockwise blinds stage.
  const LessonBlindsClockwiseTable({
    super.key,
    required this.onComplete,
    this.onMiss,
    this.enabled = true,
  });

  /// The learner tapped the button, the small blind, and the big blind.
  final VoidCallback? onComplete;

  /// A seat other than the next required one was tapped.
  final VoidCallback? onMiss;

  /// Taps are ignored when false.
  final bool enabled;

  @override
  State<LessonBlindsClockwiseTable> createState() =>
      _LessonBlindsClockwiseTableState();
}

class _LessonBlindsClockwiseTableState
    extends State<LessonBlindsClockwiseTable> {
  static const _order = <int>[
    lessonBlindsButtonIndex,
    lessonBlindsSmallBlindIndex,
    lessonBlindsBigBlindIndex,
  ];

  int _step = 0;

  void _tap(int index) {
    if (!widget.enabled || widget.onComplete == null) return;
    if (_step >= _order.length) return;
    if (index != _order[_step]) {
      widget.onMiss?.call();
      return;
    }
    consumeLessonSequentialSoftPulse(context);
    setState(() => _step += 1);
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: _order.length - _step,
    );
    if (_step >= _order.length) widget.onComplete!.call();
  }

  @override
  Widget build(BuildContext context) {
    final teaching = widget.enabled && _step < _order.length;
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: teaching ? _order.length - _step : 0,
    );
    final showCue = teaching && LessonSoftPulseScope.isAllowed(context);
    // No empty board slot outlines: this explain step has no community cards.
    final features = TableFeaturesScope.of(
      context,
    ).copyWith(boardSlots: false);
    return LessonTableStage(
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
      selectedSeatIndexes: {for (var i = 0; i < _step; i++) _order[i]},
      cueSeatIndex: showCue ? _order[_step] : null,
      enabled: teaching,
      features: features,
      onSeatIndexTap: _tap,
    );
  }
}

/// Preflop order: UTG, HJ, CO, then the button. A wrong seat is a miss.
class LessonPreflopOrderTable extends StatefulWidget {
  /// Creates the order stage.
  const LessonPreflopOrderTable({
    super.key,
    required this.onComplete,
    this.onMiss,
    this.enabled = true,
  });

  /// The learner tapped UTG, HJ, CO, and the button in that order.
  final VoidCallback? onComplete;

  /// A seat other than the next required one was tapped.
  final VoidCallback? onMiss;

  /// Taps are ignored when false.
  final bool enabled;

  @override
  State<LessonPreflopOrderTable> createState() =>
      _LessonPreflopOrderTableState();
}

class _LessonPreflopOrderTableState extends State<LessonPreflopOrderTable> {
  static const _order = <int>[
    0,
    1,
    lessonBlindsRightOfButtonIndex,
    lessonBlindsButtonIndex,
  ];

  int _step = 0;

  void _tap(int index) {
    if (!widget.enabled || widget.onComplete == null) return;
    if (_step >= _order.length) return;
    if (index != _order[_step]) {
      widget.onMiss?.call();
      return;
    }
    consumeLessonSequentialSoftPulse(context);
    setState(() => _step += 1);
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: _order.length - _step,
    );
    if (_step >= _order.length) widget.onComplete!.call();
  }

  @override
  Widget build(BuildContext context) {
    final teaching = widget.enabled && _step < _order.length;
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: teaching ? _order.length - _step : 0,
    );
    final showCue = teaching && LessonSoftPulseScope.isAllowed(context);
    return LessonTableStage(
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
      seatNames: lessonActionOrderSeatNames,
      selectedSeatIndexes: {for (var i = 0; i < _step; i++) _order[i]},
      cueSeatIndex: showCue ? _order[_step] : null,
      enabled: teaching,
      onSeatIndexTap: _tap,
    );
  }
}

/// Full table: tap seats in authored action order (preflop or postflop).
class LessonSeatOrderSequenceTable extends StatelessWidget {
  /// Creates the seat-order stage.
  const LessonSeatOrderSequenceTable({
    super.key,
    required this.sequenceItems,
    required this.orderedIds,
    required this.onPick,
    this.activityId = '',
    this.boardCodes = const [],
    this.enabled = true,
    this.showGuidance = true,
  });

  final List<({String id, String label})> sequenceItems;
  final List<String> orderedIds;
  final ValueChanged<String> onPick;

  /// Course activity id; used to mark early folds on late-seat quizzes.
  final String activityId;
  final List<String> boardCodes;
  final bool enabled;
  final bool showGuidance;

  int? _seatIndexForId(String id) {
    for (final item in sequenceItems) {
      if (item.id != id) continue;
      return lessonActionOrderSeatIndex(item.label);
    }
    return null;
  }

  String? _idForSeatIndex(int index) {
    for (final item in sequenceItems) {
      if (lessonActionOrderSeatIndex(item.label) == index) return item.id;
    }
    return null;
  }

  void _tap(BuildContext context, int seatIndex) {
    if (!enabled) return;
    final id = _idForSeatIndex(seatIndex);
    if (id == null || orderedIds.contains(id)) return;
    consumeLessonSequentialSoftPulse(context);
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: sequenceItems.length - orderedIds.length - 1,
    );
    onPick(id);
  }

  @override
  Widget build(BuildContext context) {
    final badges = <int, int>{};
    for (var order = 0; order < orderedIds.length; order++) {
      final seat = _seatIndexForId(orderedIds[order]);
      if (seat != null) badges[seat] = order + 1;
    }
    final remaining = sequenceItems.length - orderedIds.length;
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: remaining,
    );
    int? nextSeat;
    if (showGuidance &&
        LessonSoftPulseScope.isAllowed(context) &&
        enabled &&
        remaining > 0) {
      nextSeat = _seatIndexForId(sequenceItems[orderedIds.length].id);
    }
    return LessonTableStage(
      key: const ValueKey<String>('seat-order-table'),
      heroCodes: const ['Ah', 'Kd'],
      boardCodes: boardCodes,
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
      seatNames: lessonActionOrderSeatNames,
      foldedSeatIndexes: lessonSeatOrderFoldedIndexes(activityId),
      seatOrderBadges: badges,
      selectedSeatIndexes: {
        for (final id in orderedIds)
          if (_seatIndexForId(id) != null) _seatIndexForId(id)!,
      },
      cueSeatIndex: nextSeat,
      enabled: enabled,
      onSeatIndexTap: (index) => _tap(context, index),
    );
  }
}

/// One face-up board card per suit. Used by Suits and ranks.
///
/// Prefer [dealOneOfEachSuitBoard] at mount time so ranks vary per attempt.
/// This constant remains as a documented default / fallback example.
const List<String> lessonSuitBoardCodes = ['Ah', 'Kd', '7c', '2s'];

/// Suit for each board index (hearts, diamonds, clubs, spades).
const List<String> lessonSuitBoardSuitLetters = ['h', 'd', 'c', 's'];

/// Fake rank distractor for the Suits and ranks order step.
const String lessonRankOrderDistractorCode = 'Hs';

/// Features for early Suits and ranks steps: seats, cards, board only.
TableFeatures get lessonSuitsRanksTableFeatures => const TableFeatures(
  stacks: false,
  pot: false,
  street: false,
  blinds: false,
  positions: false,
  bets: false,
  actions: false,
  opponentCards: true,
  playerTypes: false,
  stats: false,
  boardSlots: false,
);

/// Maps a board-card index to a suit letter.
///
/// When [withStarDistractor] is true, index 2 is the star decoy (null).
String? lessonSuitLetterForBoardIndex(
  int index, {
  bool withStarDistractor = false,
}) {
  final letters = withStarDistractor
      ? const <String?>['h', 'd', null, 'c', 's']
      : lessonSuitBoardSuitLetters;
  if (index < 0 || index >= letters.length) return null;
  return letters[index];
}

/// Full table: tap each suit on the board. Completes when all four are in.
class LessonSuitBoardTable extends StatefulWidget {
  /// Creates the suit board stage.
  const LessonSuitBoardTable({
    super.key,
    required this.onAllSuitsSelected,
    this.onMiss,
    this.enabled = true,
    this.showGuidance = true,
    this.selectedSuitLetters = const {},
    this.syncSelection = false,
    this.withStarDistractor = false,
  });

  /// All four real suits are selected.
  final VoidCallback? onAllSuitsSelected;

  /// A seat or the star distractor was tapped.
  final VoidCallback? onMiss;

  /// Taps are ignored when false.
  final bool enabled;

  /// SoftPulse the next untapped suit.
  final bool showGuidance;

  /// External selection (guided grade draft). Empty starts fresh.
  final Set<String> selectedSuitLetters;

  /// When true, [selectedSuitLetters] owns the selection.
  final bool syncSelection;

  /// Place a star fifth-suit wrong card in the middle of the board.
  final bool withStarDistractor;

  @override
  State<LessonSuitBoardTable> createState() => _LessonSuitBoardTableState();
}

class _LessonSuitBoardTableState extends State<LessonSuitBoardTable> {
  final Set<String> _selected = <String>{};
  late final List<String> _boardCodes;
  late final List<String> _heroCodes;
  late final List<String?> _suitLetters;

  @override
  void initState() {
    super.initState();
    final rng = resolveLessonDealRandom();
    _boardCodes = dealSuitLessonBoard(
      withStarDistractor: widget.withStarDistractor,
      random: rng,
    );
    final used = <String>{
      for (final code in _boardCodes)
        if (!code.endsWith('*')) code,
    };
    _heroCodes = dealStartingHandFamily(
      LessonStartingHandFamily
          .values[rng.nextInt(LessonStartingHandFamily.values.length)],
      rng,
      used: used,
    );
    _suitLetters = widget.withStarDistractor
        ? const <String?>['h', 'd', null, 'c', 's']
        : lessonSuitBoardSuitLetters;
    _selected.addAll(widget.selectedSuitLetters);
  }

  @override
  void didUpdateWidget(covariant LessonSuitBoardTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.syncSelection &&
        !_setEquals(_selected, widget.selectedSuitLetters)) {
      setState(() {
        _selected
          ..clear()
          ..addAll(widget.selectedSuitLetters);
      });
    }
  }

  bool _setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  void _tapCard(int index) {
    if (!widget.enabled || widget.onAllSuitsSelected == null) return;
    final suit = lessonSuitLetterForBoardIndex(
      index,
      withStarDistractor: widget.withStarDistractor,
    );
    if (suit == null) {
      widget.onMiss?.call();
      return;
    }
    final bool wasNext = !_selected.contains(suit) && widget.showGuidance;
    setState(() {
      if (!_selected.add(suit)) _selected.remove(suit);
    });
    if (wasNext) {
      consumeLessonSequentialSoftPulse(context);
    }
    final remaining = const {'h', 'd', 'c', 's'}
        .where((s) => !_selected.contains(s))
        .length;
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: remaining,
    );
    if (_selected.length >= 4 &&
        _selected.containsAll(const {'h', 'd', 'c', 's'})) {
      widget.onAllSuitsSelected!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndexes = <int>{
      for (var i = 0; i < _boardCodes.length; i++)
        if (_suitLetters[i] != null && _selected.contains(_suitLetters[i])) i,
    };
    int? nextIndex;
    if (widget.showGuidance && widget.enabled) {
      for (var i = 0; i < _suitLetters.length; i++) {
        final suit = _suitLetters[i];
        if (suit != null && !_selected.contains(suit)) {
          nextIndex = i;
          break;
        }
      }
    }
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: nextIndex == null ? 0 : 1,
    );
    return LessonTableStage(
      heroCodes: _heroCodes,
      boardCodes: _boardCodes,
      villainCount: 3,
      heroFaceUp: false,
      enabled: widget.enabled,
      features: lessonSuitsRanksTableFeatures,
      selectedBoardIndexes: selectedIndexes,
      highlightBoardIndexes: {if (nextIndex != null) nextIndex},
      onBoardCardTap: _tapCard,
      onHeroTap: widget.onMiss,
      onVillainTap: (_) => widget.onMiss?.call(),
    );
  }
}

/// Board codes for a rank-order step, shuffled by [activityId].
///
/// When [distractorCode] is set (e.g. `Hs`), it is inserted in the middle
/// after the real ranks are shuffled.
List<String> lessonRankOrderBoardCodes({
  required String activityId,
  required List<String> rankLabels,
  String? distractorCode,
}) {
  final suitCycle = ['h', 'd', 'c', 's'];
  final items = [
    for (var i = 0; i < rankLabels.length; i++)
      '${rankLabels[i].toUpperCase()}${suitCycle[i % suitCycle.length]}',
  ];
  // Stable shuffle so mid-answer rebuilds keep the same board.
  var hash = 0x811c9dc5;
  for (final unit in activityId.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  final out = List<String>.of(items);
  for (var i = out.length - 1; i > 0; i--) {
    hash = (hash * 1664525 + 1013904223) & 0xffffffff;
    final j = hash % (i + 1);
    final tmp = out[i];
    out[i] = out[j];
    out[j] = tmp;
  }
  if (out.length > 1 && _sameStringOrder(out, items)) {
    final tmp = out[0];
    out[0] = out[1];
    out[1] = tmp;
  }
  if (distractorCode != null && distractorCode.isNotEmpty) {
    out.insert(out.length ~/ 2, distractorCode);
  }
  return List<String>.unmodifiable(out);
}

bool _sameStringOrder(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Full table: tap board ranks low → high (or any order, then grade).
class LessonRankOrderTable extends StatefulWidget {
  /// Creates the rank-order stage.
  const LessonRankOrderTable({
    super.key,
    required this.activityId,
    required this.sequenceItems,
    required this.orderedIds,
    required this.onPick,
    this.onMiss,
    this.enabled = true,
    this.showGuidance = true,
    this.distractorCode,
    this.generation = 0,
  });

  final String activityId;
  final List<({String id, String label})> sequenceItems;
  final List<String> orderedIds;
  final ValueChanged<String> onPick;

  /// Tapped a distractor or non-rank board card.
  final VoidCallback? onMiss;

  final bool enabled;
  final bool showGuidance;

  /// Optional fake-rank code inserted in the middle (e.g. `Hs`).
  final String? distractorCode;

  /// Attempt generation salt for fresh ranks on retry.
  final int generation;

  @override
  State<LessonRankOrderTable> createState() => _LessonRankOrderTableState();
}

class _LessonRankOrderTableState extends State<LessonRankOrderTable> {
  late final RankOrderDeal _deal;

  @override
  void initState() {
    super.initState();
    _deal = dealRankOrderSpot(
      authoredItems: widget.sequenceItems,
      activityId: widget.activityId,
      generation: widget.generation,
      distractorCode: widget.distractorCode,
    );
  }

  List<String> get _board => _deal.boardCodes;

  String? _idForBoardIndex(int index) {
    if (index < 0 || index >= _board.length) return null;
    final code = _board[index];
    if (widget.distractorCode != null && code == widget.distractorCode) {
      return null;
    }
    final rank = code[0];
    for (final item in _deal.sequenceItems) {
      if (item.label.toUpperCase() == rank) return item.id;
    }
    return null;
  }

  void _tap(int index) {
    if (!widget.enabled) return;
    final id = _idForBoardIndex(index);
    if (id == null) {
      widget.onMiss?.call();
      return;
    }
    if (widget.orderedIds.contains(id)) return;
    widget.onPick(id);
  }

  @override
  Widget build(BuildContext context) {
    final selected = <int>{};
    final badges = <int, int>{};
    for (var order = 0; order < widget.orderedIds.length; order++) {
      final id = widget.orderedIds[order];
      for (var i = 0; i < _board.length; i++) {
        if (_idForBoardIndex(i) == id) {
          selected.add(i);
          badges[i] = order + 1;
        }
      }
    }
    int? nextIndex;
    if (widget.showGuidance &&
        widget.enabled &&
        widget.orderedIds.length < _deal.sequenceItems.length) {
      final nextId = _deal.sequenceItems[widget.orderedIds.length].id;
      for (var i = 0; i < _board.length; i++) {
        if (_idForBoardIndex(i) == nextId) {
          nextIndex = i;
          break;
        }
      }
    }
    return LessonTableStage(
      heroCodes: _deal.heroCodes,
      boardCodes: _board,
      villainCount: 3,
      heroFaceUp: false,
      enabled: widget.enabled,
      features: lessonSuitsRanksTableFeatures,
      selectedBoardIndexes: selected,
      highlightBoardIndexes: {if (nextIndex != null) nextIndex},
      boardOrderBadges: badges,
      onBoardCardTap: _tap,
    );
  }
}

/// Full table: tap the seat whose face-up holes match the answer.
class LessonHoleHandTable extends StatelessWidget {
  /// Creates the hole-hand choice stage.
  const LessonHoleHandTable({
    super.key,
    required this.heroCodes,
    required this.villainHoleCodes,
    required this.onSeatChoice,
    this.enabled = true,
    this.showGuidance = false,
    this.correctSeatIndex = 0,
  });

  /// Hero holes (seat 0).
  final List<String> heroCodes;

  /// Face-up holes for Sam, Jo, … in seat order.
  final List<List<String>> villainHoleCodes;

  /// Seat index in the hand (0 = hero).
  final ValueChanged<int> onSeatChoice;

  final bool enabled;
  final bool showGuidance;
  final int correctSeatIndex;

  @override
  Widget build(BuildContext context) {
    return LessonTableStage(
      heroCodes: heroCodes,
      villainHoleCodes: villainHoleCodes,
      villainCount: villainHoleCodes.length,
      heroFaceUp: true,
      enabled: enabled,
      features: lessonSuitsRanksTableFeatures.copyWith(opponentCards: true),
      cue: showGuidance && correctSeatIndex == 0
          ? LessonTableCue.hero
          : LessonTableCue.none,
      cueSeatIndex:
          showGuidance && correctSeatIndex > 0 ? correctSeatIndex : null,
      onSeatIndexTap: enabled ? onSeatChoice : null,
    );
  }
}

/// Split a five-card made-hand example into hero holes and board.
({List<String> heroCodes, List<String> boardCodes}) lessonMadeHandCodes(
  List<String> codes,
) {
  if (codes.length <= 2) {
    return (heroCodes: List<String>.of(codes), boardCodes: const []);
  }
  return (
    heroCodes: codes.take(2).toList(growable: false),
    boardCodes: codes.skip(2).take(5).toList(growable: false),
  );
}

/// Features for Hand ranks made-hand demos: seats, cards, board, no blinds.
TableFeatures get lessonHandRanksTableFeatures => const TableFeatures(
  stacks: false,
  pot: false,
  street: false,
  blinds: false,
  positions: false,
  bets: false,
  actions: false,
  opponentCards: true,
  playerTypes: false,
  stats: false,
  boardSlots: false,
);

/// One Hand ranks showdown: shared board, face-up seats, tap order by strength.
class LessonShowdownOrderSpot {
  /// Creates a showdown ranking spot.
  const LessonShowdownOrderSpot({
    required this.boardCodes,
    required this.heroCodes,
    required this.villainHoleCodes,
    required this.seatIds,
    required this.correctOrder,
  });

  final List<String> boardCodes;
  final List<String> heroCodes;

  /// Face-up holes for Sam, Jo, … in seat order.
  final List<List<String>> villainHoleCodes;

  /// Sequence item id per seat index (0 = hero).
  final List<String> seatIds;

  /// Correct tap order of [seatIds].
  final List<String> correctOrder;
}

/// Shared board spots for Hand ranks showdown ordering.
///
/// Prefer [dealtHandRanksShowdownSpot] at mount time so faces vary per attempt.
LessonShowdownOrderSpot? handRanksShowdownSpot(String activityId) {
  switch (activityId) {
    case 'act-01-02-01-explain-ladder':
    case 'act-01-02-01-guided-ladder':
      // Weak → strong: You high card, Sam pair, Jo flush.
      return const LessonShowdownOrderSpot(
        boardCodes: ['9c', '7c', '3c', '2h', '5d'],
        heroCodes: ['Ah', 'Kd'],
        villainHoleCodes: [
          ['9h', '8s'],
          ['Ac', 'Kc'],
        ],
        seatIds: ['you', 'sam', 'jo'],
        correctOrder: ['you', 'sam', 'jo'],
      );
    case 'act-01-02-01-scaffolded-spot':
      // Weak → strong: You pair, Sam straight, Jo flush.
      return const LessonShowdownOrderSpot(
        boardCodes: ['Tc', '8c', '6d', '5h', '2c'],
        heroCodes: ['Ah', 'Td'],
        villainHoleCodes: [
          ['9s', '7d'],
          ['Ac', 'Kc'],
        ],
        seatIds: ['you', 'sam', 'jo'],
        correctOrder: ['you', 'sam', 'jo'],
      );
    case 'act-01-02-01-unguided-compare':
      // Strong → weak: You full house, Sam trips, Jo two pair.
      return const LessonShowdownOrderSpot(
        boardCodes: ['Qh', 'Qd', '9c', '4s', '2d'],
        heroCodes: ['Qs', '9h'],
        villainHoleCodes: [
          ['Qc', 'Jh'],
          ['9d', '4h'],
        ],
        seatIds: ['you', 'sam', 'jo'],
        correctOrder: ['you', 'sam', 'jo'],
      );
    case 'act-01-02-01-checkpoint-winner':
      // Strong → weak: You flush, Sam straight, Jo high card.
      return const LessonShowdownOrderSpot(
        boardCodes: ['9c', '8h', '7d', '4c', '2c'],
        heroCodes: ['Ac', 'Kc'],
        villainHoleCodes: [
          ['6s', '5h'],
          ['Ah', 'Kd'],
        ],
        seatIds: ['you', 'sam', 'jo'],
        correctOrder: ['you', 'sam', 'jo'],
      );
    default:
      return null;
  }
}

/// Fresh showdown layout for [activityId] (cards vary; seat order preserved).
LessonShowdownOrderSpot? dealtHandRanksShowdownSpot(
  String activityId, {
  int generation = 0,
  Random? random,
}) {
  final deal = dealShowdownOrderCards(
    activityId,
    generation: generation,
    random: random,
  );
  if (deal == null) return handRanksShowdownSpot(activityId);
  return LessonShowdownOrderSpot(
    boardCodes: deal.boardCodes,
    heroCodes: deal.heroCodes,
    villainHoleCodes: deal.villainHoleCodes,
    seatIds: deal.seatIds,
    correctOrder: deal.correctOrder,
  );
}

/// Whether this activity orders face-up showdown seats by hand strength.
bool isShowdownOrderSequenceActivity(String activityId) {
  return handRanksShowdownSpot(activityId) != null &&
      activityId != 'act-01-02-01-explain-ladder';
}

/// Deals a fresh showdown layout once per mount, then hosts the order table.
class RandomizedLessonShowdownOrderTable extends StatefulWidget {
  /// Creates a randomized showdown-order stage.
  const RandomizedLessonShowdownOrderTable({
    super.key,
    required this.activityId,
    required this.orderedIds,
    required this.onPick,
    this.enabled = true,
    this.showGuidance = true,
    this.strictOrder = false,
    this.onMiss,
    this.generation = 0,
  });

  final String activityId;
  final int generation;
  final List<String> orderedIds;
  final ValueChanged<String> onPick;
  final bool enabled;
  final bool showGuidance;
  final bool strictOrder;
  final VoidCallback? onMiss;

  @override
  State<RandomizedLessonShowdownOrderTable> createState() =>
      _RandomizedLessonShowdownOrderTableState();
}

class _RandomizedLessonShowdownOrderTableState
    extends State<RandomizedLessonShowdownOrderTable> {
  late final LessonShowdownOrderSpot _spot;

  @override
  void initState() {
    super.initState();
    _spot = dealtHandRanksShowdownSpot(
          widget.activityId,
          generation: widget.generation,
        ) ??
        handRanksShowdownSpot(widget.activityId)!;
  }

  @override
  Widget build(BuildContext context) {
    return LessonShowdownOrderTable(
      spot: _spot,
      orderedIds: widget.orderedIds,
      onPick: widget.onPick,
      enabled: widget.enabled,
      showGuidance: widget.showGuidance,
      strictOrder: widget.strictOrder,
      onMiss: widget.onMiss,
    );
  }
}

/// Full table: tap face-up showdown seats in hand-strength order.
class LessonShowdownOrderTable extends StatelessWidget {
  /// Creates the showdown order stage.
  const LessonShowdownOrderTable({
    super.key,
    required this.spot,
    required this.orderedIds,
    required this.onPick,
    this.enabled = true,
    this.showGuidance = true,
    this.strictOrder = false,
    this.onMiss,
  });

  final LessonShowdownOrderSpot spot;
  final List<String> orderedIds;
  final ValueChanged<String> onPick;
  final bool enabled;
  final bool showGuidance;

  /// When true, only the next correct seat is accepted; others call [onMiss].
  final bool strictOrder;
  final VoidCallback? onMiss;

  int? _seatIndexForId(String id) {
    for (var i = 0; i < spot.seatIds.length; i++) {
      if (spot.seatIds[i] == id) return i;
    }
    return null;
  }

  String? _idForSeatIndex(int index) {
    if (index < 0 || index >= spot.seatIds.length) return null;
    return spot.seatIds[index];
  }

  void _tap(BuildContext context, int seatIndex) {
    if (!enabled) return;
    final id = _idForSeatIndex(seatIndex);
    if (id == null || orderedIds.contains(id)) return;
    if (strictOrder) {
      final nextIndex = orderedIds.length;
      if (nextIndex >= spot.correctOrder.length ||
          id != spot.correctOrder[nextIndex]) {
        onMiss?.call();
        return;
      }
    }
    consumeLessonSequentialSoftPulse(context);
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: spot.correctOrder.length - orderedIds.length - 1,
    );
    onPick(id);
  }

  @override
  Widget build(BuildContext context) {
    final badges = <int, int>{};
    for (var order = 0; order < orderedIds.length; order++) {
      final seat = _seatIndexForId(orderedIds[order]);
      if (seat != null) badges[seat] = order + 1;
    }
    final remaining = spot.correctOrder.length - orderedIds.length;
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: remaining,
    );
    int? nextSeat;
    if (showGuidance &&
        LessonSoftPulseScope.isAllowed(context) &&
        enabled &&
        remaining > 0) {
      nextSeat = _seatIndexForId(spot.correctOrder[orderedIds.length]);
    }
    return LessonTableStage(
      key: const ValueKey<String>('showdown-order-felt'),
      heroCodes: spot.heroCodes,
      boardCodes: spot.boardCodes,
      villainHoleCodes: spot.villainHoleCodes,
      villainCount: spot.villainHoleCodes.length,
      heroFaceUp: true,
      enabled: enabled,
      features: lessonHandRanksTableFeatures,
      seatOrderBadges: badges,
      selectedSeatIndexes: {
        for (final id in orderedIds)
          if (_seatIndexForId(id) != null) _seatIndexForId(id)!,
      },
      cue: nextSeat == 0 ? LessonTableCue.hero : LessonTableCue.none,
      cueSeatIndex: nextSeat != null && nextSeat > 0 ? nextSeat : null,
      onSeatIndexTap: (index) => _tap(context, index),
    );
  }
}

/// Explain: tap showdown seats weak → strong; a wrong seat is a miss.
class LessonShowdownOrderExplainTable extends StatefulWidget {
  /// Creates the explain stage.
  const LessonShowdownOrderExplainTable({
    super.key,
    required this.activityId,
    required this.onComplete,
    this.onMiss,
    this.enabled = true,
    this.showGuidance = true,
    this.generation = 0,
  });

  /// Activity whose showdown pattern should be dealt.
  final String activityId;
  final VoidCallback? onComplete;
  final VoidCallback? onMiss;
  final bool enabled;
  final bool showGuidance;
  final int generation;

  @override
  State<LessonShowdownOrderExplainTable> createState() =>
      _LessonShowdownOrderExplainTableState();
}

class _LessonShowdownOrderExplainTableState
    extends State<LessonShowdownOrderExplainTable> {
  final List<String> _ordered = <String>[];
  late final LessonShowdownOrderSpot _spot;

  @override
  void initState() {
    super.initState();
    _spot = dealtHandRanksShowdownSpot(
          widget.activityId,
          generation: widget.generation,
        ) ??
        handRanksShowdownSpot(widget.activityId)!;
  }

  void _pick(String id) {
    if (!widget.enabled || widget.onComplete == null) return;
    setState(() => _ordered.add(id));
    if (_ordered.length >= _spot.correctOrder.length) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final teaching = widget.enabled && _ordered.length < _spot.correctOrder.length;
    return LessonShowdownOrderTable(
      spot: _spot,
      orderedIds: _ordered,
      enabled: teaching,
      showGuidance: widget.showGuidance,
      strictOrder: true,
      onMiss: widget.onMiss,
      onPick: _pick,
    );
  }
}

/// Full table showing one made hand (two holes + board).
class LessonMadeHandTable extends StatelessWidget {
  /// Creates the made-hand stage.
  const LessonMadeHandTable({
    super.key,
    required this.codes,
    this.enabled = true,
    this.cueHero = false,
    this.onTap,
    this.villainCount = 2,
  });

  /// Five-card example: first two are holes, the rest are the board.
  final List<String> codes;

  final bool enabled;
  final bool cueHero;
  final VoidCallback? onTap;
  final int villainCount;

  @override
  Widget build(BuildContext context) {
    final split = lessonMadeHandCodes(codes);
    return LessonTableStage(
      heroCodes: split.heroCodes.isEmpty ? const ['Ah', 'Kd'] : split.heroCodes,
      boardCodes: split.boardCodes,
      villainCount: villainCount,
      heroFaceUp: true,
      enabled: enabled && onTap != null,
      cue: cueHero ? LessonTableCue.hero : LessonTableCue.none,
      features: lessonHandRanksTableFeatures,
      onHeroTap: onTap,
      onBoardTap: onTap,
    );
  }
}

/// Explain ladder: tap through made hands weak → strong on the full table.
///
/// Prefer [LessonShowdownOrderExplainTable] for Hand ranks. Kept for tests and
/// any residual ladder demos.
class LessonHandLadderExplainTable extends StatefulWidget {
  /// Creates the ladder explain stage.
  const LessonHandLadderExplainTable({
    super.key,
    required this.rungs,
    required this.onComplete,
    this.enabled = true,
    this.showGuidance = true,
  });

  /// Made-hand rungs in weak → strong order.
  final List<({String id, String title, List<String> codes})> rungs;

  /// Every rung has been tapped.
  final VoidCallback? onComplete;

  final bool enabled;
  final bool showGuidance;

  @override
  State<LessonHandLadderExplainTable> createState() =>
      _LessonHandLadderExplainTableState();
}

class _LessonHandLadderExplainTableState
    extends State<LessonHandLadderExplainTable> {
  int _step = 0;

  void _advance() {
    if (!widget.enabled || widget.onComplete == null) return;
    if (_step >= widget.rungs.length) return;
    setState(() => _step += 1);
    if (_step >= widget.rungs.length) widget.onComplete!();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rungs.isEmpty) return const SizedBox.shrink();
    final index = _step.clamp(0, widget.rungs.length - 1);
    final rung = widget.rungs[index];
    final teaching = widget.enabled && _step < widget.rungs.length;
    return LessonMadeHandTable(
      key: ValueKey<String>('ladder-${rung.id}-$_step'),
      codes: rung.codes,
      enabled: teaching,
      cueHero: widget.showGuidance && teaching,
      onTap: teaching ? _advance : null,
    );
  }
}
