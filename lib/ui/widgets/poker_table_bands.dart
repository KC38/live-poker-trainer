/// Poker table column shared by Your start and lesson hands.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/action_dock_widget.dart';
import 'package:live_poker_trainer/ui/widgets/coach_shelf_widget.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';

/// Small blind a lesson table posts unless the step sets its own stakes.
const double lessonSmallBlind = 1;

/// Big blind a lesson table posts unless the step sets its own stakes.
const double lessonBigBlind = 2;

/// Builds a hand the poker table can draw.
///
/// [villainSeatCount] seats sit on the ring with face-down cards. Stacks
/// start at [stackBb] big blinds. The button is [dealerIndex]. The small
/// and big blind default to the next seats clockwise; heads-up, the button
/// is the small blind. Preflop, both blinds are posted as bets in front of
/// their seats; a table with only the hero has them in the pot. From the
/// flop on, the pot holds five big blinds.
///
/// Set [postSmallBlind] / [postBigBlind] false to leave that blind unposted
/// (quiz steps that ask the learner to tap who posts, then animate the chips
/// in on a hit — SB then BB when both start hidden).
GameState lessonBandGame({
  List<String> heroCodes = const ['Ah', 'Kd'],
  List<String> boardCodes = const [],
  int villainSeatCount = 0,
  bool waitingForHero = false,
  double smallBlind = lessonSmallBlind,
  double bigBlind = lessonBigBlind,
  double stackBb = 100,
  int dealerIndex = 0,
  int? sbIndex,
  int? bbIndex,
  bool postSmallBlind = true,
  bool postBigBlind = true,
}) {
  final board = [for (final code in boardCodes) CardModel.fromCode(code)];
  final street = switch (board.length) {
    0 => Street.preflop,
    1 || 2 || 3 => Street.flop,
    4 => Street.turn,
    _ => Street.river,
  };
  final seats = 1 + villainSeatCount;
  final sb = sbIndex ?? (seats <= 2 ? dealerIndex : (dealerIndex + 1) % seats);
  final bb =
      bbIndex ??
      (seats == 1
          ? dealerIndex
          : seats == 2
          ? (dealerIndex + 1) % seats
          : (dealerIndex + 2) % seats);
  final preflop = street == Street.preflop;
  final stack = stackBb * bigBlind;
  double posted(int seat) {
    if (!preflop || sb == bb) return 0;
    if (seat == sb) return postSmallBlind ? smallBlind : 0;
    if (seat == bb) return postBigBlind ? bigBlind : 0;
    return 0;
  }

  final players = <PlayerModel>[
    PlayerModel(
      id: 0,
      name: 'You',
      archetype: PlayerArchetype.hero,
      stack: stack - posted(0),
      currentBet: posted(0),
      isHero: true,
      holeCards: [for (final code in heroCodes) CardModel.fromCode(code)],
    ),
    for (var i = 1; i < seats; i++)
      PlayerModel(
        id: i,
        name: 'Alex',
        archetype: PlayerArchetype.tag,
        stack: stack - posted(i),
        currentBet: posted(i),
      ),
  ];
  final heroOnlyBlinds =
      preflop && sb == bb
          ? ((postBigBlind ? bigBlind : 0.0) +
              (postSmallBlind ? smallBlind : 0.0))
          : 0.0;
  final highest = !preflop
      ? 0.0
      : postBigBlind
          ? bigBlind
          : postSmallBlind
              ? smallBlind
              : 0.0;
  return GameState(
    players: players,
    mode: GameMode.training,
    community: board,
    street: street,
    mainPot: !preflop ? 5 * bigBlind : heroOnlyBlinds,
    highestBet: highest,
    minRaise: bigBlind,
    smallBlind: smallBlind,
    bigBlind: bigBlind,
    dealerIndex: dealerIndex,
    sbIndex: sb,
    bbIndex: bb,
    waitingForHero: waitingForHero,
  );
}

/// Felt, coach shelf, and an action dock only on a decision.
///
/// The felt is flexible inside a bounded height so the column can sit in a
/// scroll view. The hero sits on the felt, like every other table.
class PokerTableBands extends StatelessWidget {
  /// Creates the band column.
  const PokerTableBands({
    super.key,
    required this.game,
    required this.feedback,
    this.chipDisplayMode = ChipDisplayMode.dollars,
    this.onHeroTap,
    this.heroTapLabel,
    this.onAction,
    this.heightFactor = 0.58,
  });

  /// Hand drawn on the felt.
  final GameState game;

  /// Coach shelf copy. A none-verdict still shows the Coach header.
  final CoachFeedback feedback;

  /// Currency mode for stacks and the pot.
  final ChipDisplayMode chipDisplayMode;

  /// Acknowledges a tap on the hero seat or the coach shelf.
  final VoidCallback? onHeroTap;

  /// Button name for [onHeroTap]. Omit when the hand is only a preview.
  final String? heroTapLabel;

  /// Hero decision. The dock is omitted when this is null or the hand is
  /// not waiting on the hero.
  final ValueChanged<PokerAction>? onAction;

  /// Fraction of the screen used as the column height.
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wanted = MediaQuery.sizeOf(context).height * heightFactor;
        // A bounded parent (Your start, above Start lesson) wins so the
        // shelf stays inside the column and the button sits below.
        final height =
            constraints.maxHeight.isFinite && constraints.maxHeight < wanted
                ? constraints.maxHeight
                : wanted;
        return _column(height);
      },
    );
  }

  Widget _column(double height) {
    final shelf = CoachShelfWidget(
      feedback: feedback,
      bigBlind: game.bigBlind,
      chipDisplayMode: chipDisplayMode,
    );
    final felt = FeltTableView(
      game: game,
      chipDisplayMode: chipDisplayMode,
      onSeatTap:
          onHeroTap == null
              ? null
              : (player) {
                if (player.isHero) onHeroTap!();
              },
    );
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child:
                onHeroTap == null
                    ? felt
                    : Semantics(button: true, label: heroTapLabel, child: felt),
          ),
          if (onHeroTap == null)
            shelf
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onHeroTap,
              child: shelf,
            ),
          if (game.waitingForHero && onAction != null)
            ActionDockWidget(game: game, onAction: onAction!),
        ],
      ),
    );
  }
}
