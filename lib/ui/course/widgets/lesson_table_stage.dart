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
/// opponent shows [villainCodes] only when that list has two cards. A null
/// [dealerIndex] leaves the hero on the button. Otherwise the small blind and
/// big blind sit one and two seats clockwise from the button, unless
/// [sbIndex] or [bbIndex] is set, and no seat glows unless [activeSeatIndex]
/// is set. [positionLabels] renames the ring EP, HJ, CO, BTN, SB, BB.
/// The table plays [smallBlind]/[bigBlind] with 100 big blind stacks.
/// [villainArchetypes] gives the opponents, in seat order, real player types.
GameState lessonTableStageGame({
  List<String> heroCodes = const ['Ah', 'Kd'],
  List<String> boardCodes = const [],
  List<String> villainCodes = const [],
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
  var villain = 0;
  final players = <PlayerModel>[];
  for (final player in base.players) {
    if (player.isHero) {
      players.add(player);
      continue;
    }
    final showHoles = villain == 0 && villainCodes.length >= 2;
    final types = villainArchetypes;
    players.add(
      player.copyWith(
        name: names[villain % names.length],
        archetype: types == null || types.isEmpty
            ? null
            : types[villain % types.length],
        holeCards: showHoles
            ? [
                for (final code in villainCodes.take(2))
                  CardModel.fromCode(code),
              ]
            : player.holeCards,
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
    this.onSeatIndexTap,
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

  /// Learner tapped a seat. The value is that seat's index in the hand.
  final ValueChanged<int>? onSeatIndexTap;

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
            faceUpPlayerIds: {
              if (heroFaceUp) 0,
              if (villainCodes.length >= 2) 1,
            },
            highlightHero: cue == LessonTableCue.hero && !heroFaceUp,
            highlightBoard: cue == LessonTableCue.board,
            onBoardTap: !enabled || onBoardTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onBoardTap!();
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
