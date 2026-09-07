/// Street progression and table-wide game state.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Betting street.
enum Street {
  preflop,
  flop,
  turn,
  river,
  showdown;

  String get label => name.toUpperCase();

  Street? get next {
    return switch (this) {
      Street.preflop => Street.flop,
      Street.flop => Street.turn,
      Street.turn => Street.river,
      Street.river => Street.showdown,
      Street.showdown => null,
    };
  }
}

/// Play mode for the table session.
enum GameMode { practice, cashSim }

/// Snapshot of the current hand / table.
@immutable
class GameState {
  /// Creates a game state snapshot.
  const GameState({
    required this.players,
    required this.mode,
    this.community = const [],
    this.mainPot = 0,
    this.street = Street.preflop,
    this.dealerIndex = 0,
    this.sbIndex = 1,
    this.bbIndex = 2,
    this.activePlayerIndex = 0,
    this.highestBet = 0,
    this.minRaise = 0,
    this.smallBlind = 1,
    this.bigBlind = 2,
    this.lastAggressor,
    this.heroLine = const [],
    this.handCount = 0,
    this.activeScenario,
    this.heroInvestedThisHand = 0,
    this.isHandOver = false,
    this.waitingForHero = false,
    this.resultMessage,
    this.sidePots = const [],
  });

  final List<PlayerModel> players;
  final GameMode mode;
  final List<CardModel> community;
  final double mainPot;
  final Street street;
  final int dealerIndex;
  final int sbIndex;
  final int bbIndex;
  final int activePlayerIndex;
  final double highestBet;
  final double minRaise;
  final double smallBlind;
  final double bigBlind;
  final int? lastAggressor;
  final List<String> heroLine;
  final int handCount;
  final ScenarioModel? activeScenario;
  final double heroInvestedThisHand;
  final bool isHandOver;
  final bool waitingForHero;
  final String? resultMessage;
  final List<double> sidePots;

  PlayerModel get hero => players.firstWhere((p) => p.isHero);

  double get totalPot {
    final bets = players.fold<double>(0, (sum, p) => sum + p.currentBet);
    return mainPot + bets;
  }

  double callAmountFor(PlayerModel player) {
    final amount = highestBet - player.currentBet;
    return amount < 0 ? 0 : amount;
  }

  GameState copyWith({
    List<PlayerModel>? players,
    GameMode? mode,
    List<CardModel>? community,
    double? mainPot,
    Street? street,
    int? dealerIndex,
    int? sbIndex,
    int? bbIndex,
    int? activePlayerIndex,
    double? highestBet,
    double? minRaise,
    double? smallBlind,
    double? bigBlind,
    int? lastAggressor,
    bool clearLastAggressor = false,
    List<String>? heroLine,
    int? handCount,
    ScenarioModel? activeScenario,
    bool clearScenario = false,
    double? heroInvestedThisHand,
    bool? isHandOver,
    bool? waitingForHero,
    String? resultMessage,
    bool clearResult = false,
    List<double>? sidePots,
  }) {
    return GameState(
      players: players ?? this.players,
      mode: mode ?? this.mode,
      community: community ?? this.community,
      mainPot: mainPot ?? this.mainPot,
      street: street ?? this.street,
      dealerIndex: dealerIndex ?? this.dealerIndex,
      sbIndex: sbIndex ?? this.sbIndex,
      bbIndex: bbIndex ?? this.bbIndex,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      highestBet: highestBet ?? this.highestBet,
      minRaise: minRaise ?? this.minRaise,
      smallBlind: smallBlind ?? this.smallBlind,
      bigBlind: bigBlind ?? this.bigBlind,
      lastAggressor: clearLastAggressor
          ? null
          : (lastAggressor ?? this.lastAggressor),
      heroLine: heroLine ?? this.heroLine,
      handCount: handCount ?? this.handCount,
      activeScenario:
          clearScenario ? null : (activeScenario ?? this.activeScenario),
      heroInvestedThisHand: heroInvestedThisHand ?? this.heroInvestedThisHand,
      isHandOver: isHandOver ?? this.isHandOver,
      waitingForHero: waitingForHero ?? this.waitingForHero,
      resultMessage:
          clearResult ? null : (resultMessage ?? this.resultMessage),
      sidePots: sidePots ?? this.sidePots,
    );
  }
}
