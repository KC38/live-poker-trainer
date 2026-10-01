/// Full poker table used as the lesson stage.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
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
/// CO, BTN, SB, BB. The table plays [smallBlind]/[bigBlind] with 100 big blind
/// stacks. [villainArchetypes] gives the opponents, in seat order, real player
/// types. [postBigBlind] false leaves the BB unposted until a quiz reveals it.
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
  double smallBlind = lessonSmallBlind,
  double bigBlind = lessonBigBlind,
  List<PlayerArchetype>? villainArchetypes,
  bool postBigBlind = true,
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
  final seated = positionLabels
      ? [
          for (var i = 0; i < players.length; i++)
            players[i].copyWith(name: positions[i % positions.length]),
        ]
      : players;
  final named = base.copyWith(players: seated);
  if (dealerIndex == null) return named;
  return named.copyWith(activePlayerIndex: activeSeatIndex ?? -1);
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
    this.highlightHeroIndexes = const {},
    this.dimmedHeroIndexes = const {},
    this.seatOrderBadges = const {},
    this.positionLabels = false,
    this.smallBlind = lessonSmallBlind,
    this.bigBlind = lessonBigBlind,
    this.villainArchetypes,
    this.features,
    this.postBigBlind = true,
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

  /// Board indexes with a selected gold ring.
  final Set<int> selectedBoardIndexes;

  /// Board indexes that bounce a cue arrow.
  final Set<int> highlightBoardIndexes;

  /// Board indexes faded as leftovers.
  final Set<int> dimmedBoardIndexes;

  /// 1-based order badge drawn on a selected board card.
  final Map<int, int> boardOrderBadges;

  /// Hero hole indexes with a selected gold ring.
  final Set<int> selectedHeroIndexes;

  /// Hero hole indexes that cue the next tap.
  final Set<int> highlightHeroIndexes;

  /// Hero hole indexes faded as leftovers.
  final Set<int> dimmedHeroIndexes;

  /// 1-based order badge drawn on a seat during showdown ranking.
  final Map<int, int> seatOrderBadges;

  /// Rename the six-max ring EP, HJ, CO, BTN, SB, BB.
  final bool positionLabels;

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

  /// When false, the big blind seat has no chips out yet (reveal-on-tap
  /// quizzes). The BB seat index and SoftPulse target stay the same.
  final bool postBigBlind;

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
    smallBlind: smallBlind,
    bigBlind: bigBlind,
    villainArchetypes: villainArchetypes,
    postBigBlind: postBigBlind,
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
            chipDisplayMode: ChipDisplayMode.dollars,
            features: table,
            showHoleCardBacks: true,
            heroCardsFaceUp: heroFaceUp,
            faceUpPlayerIds: faceUp,
            // Face-up holes still need CueArrows + CuePulse — the old
            // `&& !heroFaceUp` gate hid every "tap your cards" cue in the
            // lesson frame (guided find-holes, etc.).
            // Board region cues expand to every dealt card the same way —
            // a lone centered arrow over five slots lands on the rightmost
            // flop card and skips CuePulse.
            highlightHero: cue == LessonTableCue.hero,
            highlightBoard: cue == LessonTableCue.board &&
                highlightBoardIndexes.isEmpty &&
                boardCodes.isEmpty,
            selectedBoardIndexes: selectedBoardIndexes,
            highlightBoardIndexes:
                highlightBoardIndexes.isNotEmpty
                    ? highlightBoardIndexes
                    : (cue == LessonTableCue.board
                        ? {for (var i = 0; i < boardCodes.length; i++) i}
                        : const <int>{}),
            dimmedBoardIndexes: dimmedBoardIndexes,
            boardOrderBadges: boardOrderBadges,
            selectedHeroIndexes: selectedHeroIndexes,
            highlightHeroIndexes:
                highlightHeroIndexes.isNotEmpty
                    ? highlightHeroIndexes
                    : (cue == LessonTableCue.hero && heroFaceUp
                        ? const {0, 1}
                        : const <int>{}),
            dimmedHeroIndexes: dimmedHeroIndexes,
            seatOrderBadges: seatOrderBadges,
            cueSeatIndex: cueSeatIndex,
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
    return LessonTableStage(
      villainCount: 3,
      heroFaceUp: revealed,
      cue: revealed ? LessonTableCue.none : LessonTableCue.hero,
      enabled: widget.enabled && !_faceUp,
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
    setState(() => _step += 1);
    if (_step >= _order.length) widget.onComplete!.call();
  }

  @override
  Widget build(BuildContext context) {
    final teaching = widget.enabled && _step < _order.length;
    return LessonTableStage(
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
      activeSeatIndex: teaching ? _order[_step] : null,
      cueSeatIndex: teaching ? _order[_step] : null,
      enabled: teaching,
      onSeatIndexTap: _tap,
    );
  }
}

/// Preflop order: EP, then HJ, then the button. A wrong seat is a miss.
class LessonPreflopOrderTable extends StatefulWidget {
  /// Creates the order stage.
  const LessonPreflopOrderTable({
    super.key,
    required this.onComplete,
    this.onMiss,
    this.enabled = true,
  });

  /// The learner tapped EP, HJ, and the button in that order.
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
  static const _order = <int>[0, 1, lessonBlindsButtonIndex];

  int _step = 0;

  void _tap(int index) {
    if (!widget.enabled || widget.onComplete == null) return;
    if (_step >= _order.length) return;
    if (index != _order[_step]) {
      widget.onMiss?.call();
      return;
    }
    setState(() => _step += 1);
    if (_step >= _order.length) widget.onComplete!.call();
  }

  @override
  Widget build(BuildContext context) {
    final teaching = widget.enabled && _step < _order.length;
    return LessonTableStage(
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
      positionLabels: true,
      activeSeatIndex: teaching ? _order[_step] : null,
      cueSeatIndex: teaching ? _order[_step] : null,
      enabled: teaching,
      onSeatIndexTap: _tap,
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

/// Maps a board-card index on a one-of-each-suit board to a suit letter.
String? lessonSuitLetterForBoardIndex(int index) {
  if (index < 0 || index >= lessonSuitBoardSuitLetters.length) return null;
  return lessonSuitBoardSuitLetters[index];
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
  });

  /// All four real suits are selected.
  final VoidCallback? onAllSuitsSelected;

  /// A seat was tapped instead of a board card.
  final VoidCallback? onMiss;

  /// Taps are ignored when false.
  final bool enabled;

  /// SoftPulse the next untapped suit.
  final bool showGuidance;

  /// External selection (guided grade draft). Empty starts fresh.
  final Set<String> selectedSuitLetters;

  /// When true, [selectedSuitLetters] owns the selection.
  final bool syncSelection;

  @override
  State<LessonSuitBoardTable> createState() => _LessonSuitBoardTableState();
}

class _LessonSuitBoardTableState extends State<LessonSuitBoardTable> {
  final Set<String> _selected = <String>{};
  late final List<String> _boardCodes;

  @override
  void initState() {
    super.initState();
    _boardCodes = dealOneOfEachSuitBoard();
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
    final suit = lessonSuitLetterForBoardIndex(index);
    if (suit == null) return;
    setState(() {
      if (!_selected.add(suit)) _selected.remove(suit);
    });
    if (_selected.length >= 4 &&
        _selected.containsAll(const {'h', 'd', 'c', 's'})) {
      widget.onAllSuitsSelected!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndexes = <int>{
      for (var i = 0; i < _boardCodes.length; i++)
        if (_selected.contains(lessonSuitBoardSuitLetters[i])) i,
    };
    int? nextIndex;
    if (widget.showGuidance && widget.enabled) {
      for (var i = 0; i < lessonSuitBoardSuitLetters.length; i++) {
        if (!_selected.contains(lessonSuitBoardSuitLetters[i])) {
          nextIndex = i;
          break;
        }
      }
    }
    return LessonTableStage(
      heroCodes: const ['Ah', 'Kd'],
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
List<String> lessonRankOrderBoardCodes({
  required String activityId,
  required List<String> rankLabels,
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
    this.enabled = true,
    this.showGuidance = true,
  });

  final String activityId;
  final List<({String id, String label})> sequenceItems;
  final List<String> orderedIds;
  final ValueChanged<String> onPick;
  final bool enabled;
  final bool showGuidance;

  @override
  State<LessonRankOrderTable> createState() => _LessonRankOrderTableState();
}

class _LessonRankOrderTableState extends State<LessonRankOrderTable> {
  late final List<String> _board;

  @override
  void initState() {
    super.initState();
    _board = lessonRankOrderBoardCodes(
      activityId: widget.activityId,
      rankLabels: [
        for (final item in widget.sequenceItems) item.label,
      ],
    );
  }

  String? _idForBoardIndex(int index) {
    if (index < 0 || index >= _board.length) return null;
    final rank = _board[index][0];
    for (final item in widget.sequenceItems) {
      if (item.label.toUpperCase() == rank) return item.id;
    }
    return null;
  }

  void _tap(int index) {
    if (!widget.enabled) return;
    final id = _idForBoardIndex(index);
    if (id == null || widget.orderedIds.contains(id)) return;
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
        widget.orderedIds.length < widget.sequenceItems.length) {
      final nextId = widget.sequenceItems[widget.orderedIds.length].id;
      for (var i = 0; i < _board.length; i++) {
        if (_idForBoardIndex(i) == nextId) {
          nextIndex = i;
          break;
        }
      }
    }
    return LessonTableStage(
      heroCodes: const ['Ah', 'Kd'],
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
  Random? random,
}) {
  final deal = dealShowdownOrderCards(activityId, random: random);
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
  });

  final String activityId;
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
    _spot = dealtHandRanksShowdownSpot(widget.activityId) ??
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

  void _tap(int seatIndex) {
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
    onPick(id);
  }

  @override
  Widget build(BuildContext context) {
    final badges = <int, int>{};
    for (var order = 0; order < orderedIds.length; order++) {
      final seat = _seatIndexForId(orderedIds[order]);
      if (seat != null) badges[seat] = order + 1;
    }
    int? nextSeat;
    if (showGuidance &&
        enabled &&
        orderedIds.length < spot.correctOrder.length) {
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
      cue: nextSeat == 0 ? LessonTableCue.hero : LessonTableCue.none,
      cueSeatIndex: nextSeat != null && nextSeat > 0 ? nextSeat : null,
      onSeatIndexTap: _tap,
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
  });

  /// Activity whose showdown pattern should be dealt.
  final String activityId;
  final VoidCallback? onComplete;
  final VoidCallback? onMiss;
  final bool enabled;
  final bool showGuidance;

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
    _spot = dealtHandRanksShowdownSpot(widget.activityId) ??
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
