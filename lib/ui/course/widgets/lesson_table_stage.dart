/// Full poker table used as the lesson stage.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/poker_table_bands.dart';

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
    this.villainCount = 3,
    this.heroFaceUp = false,
    this.cue = LessonTableCue.none,
    this.enabled = true,
    this.onHeroTap,
    this.onVillainTap,
    this.onBoardTap,
  });

  /// Hero hole cards. Hidden until [heroFaceUp] is true.
  final List<String> heroCodes;

  /// Community cards. Empty on a preflop step.
  final List<String> boardCodes;

  /// Other seats. The hero is always an extra seat.
  final int villainCount;

  /// When false, the hero's cards are two backs.
  final bool heroFaceUp;

  /// Arrow target.
  final LessonTableCue cue;

  /// Taps are ignored when false.
  final bool enabled;

  /// Learner tapped their own cards.
  final VoidCallback? onHeroTap;

  /// Learner tapped another seat. [index] is that player's index in the hand.
  final ValueChanged<int>? onVillainTap;

  /// Learner tapped the community cards.
  final VoidCallback? onBoardTap;

  GameState get _game {
    final base = lessonBandGame(
      heroCodes: heroCodes,
      boardCodes: boardCodes,
      villainSeatCount: villainCount,
    );
    const names = ['Sam', 'Jo', 'Rio', 'Max'];
    var villain = 0;
    final players = [
      for (final player in base.players)
        if (player.isHero)
          player
        else
          player.copyWith(name: names[villain++ % names.length]),
    ];
    return base.copyWith(players: players);
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 360.0;
        return SizedBox(
          key: const ValueKey<String>('lesson-table-stage'),
          height: height,
          child: FeltTableView(
            game: game,
            chipDisplayMode: ChipDisplayMode.dollars,
            includeHero: true,
            showHoleCardBacks: true,
            heroCardsFaceUp: heroFaceUp,
            highlightHero: cue == LessonTableCue.hero && !heroFaceUp,
            highlightBoard: cue == LessonTableCue.board,
            onBoardTap:
                !enabled || onBoardTap == null
                    ? null
                    : () {
                      HapticFeedback.selectionClick();
                      onBoardTap!();
                    },
            onSeatTap:
                !enabled
                    ? null
                    : (PlayerModel player) {
                      HapticFeedback.selectionClick();
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
