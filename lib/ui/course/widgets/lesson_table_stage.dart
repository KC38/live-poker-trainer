/// Full poker table used as the lesson stage.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
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
/// types.
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

/// Where the stage draws its arrows.
enum LessonTableCue {
  /// No arrow.
  none,

  /// Arrows on the hero's hole cards.
  hero,

  /// Arrow on the community cards.
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
    this.onHeroTap,
    this.onVillainTap,
    this.onBoardTap,
    this.onBoardCardTap,
    this.onSeatIndexTap,
    this.selectedBoardIndexes = const {},
    this.highlightBoardIndexes = const {},
    this.boardOrderBadges = const {},
    this.positionLabels = false,
    this.smallBlind = lessonSmallBlind,
    this.bigBlind = lessonBigBlind,
    this.villainArchetypes,
    this.features,
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

  /// Learner tapped their own cards.
  final VoidCallback? onHeroTap;

  /// Learner tapped another seat. [index] is that player's index in the hand.
  final ValueChanged<int>? onVillainTap;

  /// Learner tapped the community cards.
  final VoidCallback? onBoardTap;

  /// Learner tapped one board card by index.
  final ValueChanged<int>? onBoardCardTap;

  /// Learner tapped a seat. The value is that seat's index in the hand.
  final ValueChanged<int>? onSeatIndexTap;

  /// Board indexes with a selected gold ring.
  final Set<int> selectedBoardIndexes;

  /// Board indexes that bounce a cue arrow.
  final Set<int> highlightBoardIndexes;

  /// 1-based order badge drawn on a selected board card.
  final Map<int, int> boardOrderBadges;

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
            highlightHero: cue == LessonTableCue.hero && !heroFaceUp,
            highlightBoard: cue == LessonTableCue.board &&
                highlightBoardIndexes.isEmpty,
            selectedBoardIndexes: selectedBoardIndexes,
            highlightBoardIndexes: highlightBoardIndexes,
            boardOrderBadges: boardOrderBadges,
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
            onSeatTap: !enabled
                ? null
                : (PlayerModel player) {
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
    return LessonTableStage(
      villainCount: 3,
      heroFaceUp: _faceUp,
      cue: LessonTableCue.hero,
      enabled: widget.enabled && !_faceUp,
      onHeroTap: () {
        setState(() => _faceUp = true);
        widget.onPeek();
      },
      onVillainTap: (_) => widget.onMiss(),
    );
  }
}

/// Button, then small blind, then big blind. A wrong seat does not count.
class LessonBlindsClockwiseTable extends StatefulWidget {
  /// Creates the clockwise blinds stage.
  const LessonBlindsClockwiseTable({
    super.key,
    required this.onComplete,
    this.enabled = true,
  });

  /// The learner tapped the button, the small blind, and the big blind.
  final VoidCallback? onComplete;

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
    if (_step >= _order.length || index != _order[_step]) return;
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
      enabled: teaching,
      onSeatIndexTap: _tap,
    );
  }
}

/// Preflop order: EP, then HJ, then the button. A wrong seat does not count.
class LessonPreflopOrderTable extends StatefulWidget {
  /// Creates the order stage.
  const LessonPreflopOrderTable({
    super.key,
    required this.onComplete,
    this.enabled = true,
  });

  /// The learner tapped EP, HJ, and the button in that order.
  final VoidCallback? onComplete;

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
    if (_step >= _order.length || index != _order[_step]) return;
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
      enabled: teaching,
      onSeatIndexTap: _tap,
    );
  }
}

/// One face-up board card per suit. Used by Suits and ranks.
const List<String> lessonSuitBoardCodes = ['Ah', 'Kd', '7c', '2s'];

/// Suit for each [lessonSuitBoardCodes] index.
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

/// Maps a board-card index on [lessonSuitBoardCodes] to a suit letter.
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

  @override
  void initState() {
    super.initState();
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
      for (var i = 0; i < lessonSuitBoardCodes.length; i++)
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
      boardCodes: lessonSuitBoardCodes,
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
      activeSeatIndex:
          showGuidance && correctSeatIndex > 0 ? correctSeatIndex : null,
      onSeatIndexTap: enabled ? onSeatChoice : null,
    );
  }
}
