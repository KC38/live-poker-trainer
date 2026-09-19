/// Street progression and table-wide game state.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/situation_model.dart';

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
///
/// Training is the unified full-hand cash-style path with live coaching.
/// Legacy [practice] / [cashSim] values remain for persisted snapshots only.
enum GameMode { training, practice, cashSim }

/// Snapshot of the current hand / table.
@immutable
class GameState {
  /// Creates a game state snapshot.
  const GameState({
    required this.players,
    required this.mode,
    this.community = const [],
    this.mainPot = 0,
    this.awardedPot = 0,
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
    this.activeSituation,
    this.heroInvestedThisHand = 0,
    this.isHandOver = false,
    this.waitingForHero = false,
    this.resultMessage,
    this.winnerIds = const [],
    this.sidePots = const [],
    this.winnerPayouts = const {},
    this.splitPotAward = false,
  });

  final List<PlayerModel> players;
  final GameMode mode;
  final List<CardModel> community;
  final double mainPot;

  /// Pot awarded at hand end (kept for the SHOWDOWN label after stacks update).
  final double awardedPot;
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
  final SituationModel? activeSituation;
  final double heroInvestedThisHand;
  final bool isHandOver;
  final bool waitingForHero;
  final String? resultMessage;

  /// Seat ids that took the pot (one winner, or multiple for a split).
  ///
  /// Odd cents are assigned by ascending seat id, independent of list order.
  final List<int> winnerIds;
  final List<double> sidePots;
  final Map<int, double> winnerPayouts;
  final bool splitPotAward;

  PlayerModel get hero => players.firstWhere((p) => p.isHero);

  /// Poker position label for [seatIndex] (BTN / SB / BB / UTG / …).
  ///
  /// Seats are counted clockwise from the button. Returns `SEAT` when the
  /// index is out of range.
  String positionLabel(int seatIndex) {
    final n = players.length;
    if (n == 0 || seatIndex < 0 || seatIndex >= n) return 'SEAT';
    if (seatIndex == dealerIndex) return 'BTN';
    if (seatIndex == sbIndex) return 'SB';
    if (seatIndex == bbIndex) return 'BB';
    // Offset from the seat after BB (UTG).
    final utg = (bbIndex + 1) % n;
    var offset = (seatIndex - utg) % n;
    if (offset < 0) offset += n;
    const early = ['UTG', 'UTG+1', 'MP', 'MP+1', 'HJ', 'CO'];
    if (offset < early.length) return early[offset];
    return 'MP';
  }

  double get totalPot {
    final bets = players.fold<double>(0, (sum, p) => sum + p.currentBet);
    return Money.round(mainPot + bets);
  }

  /// Amount shown in the felt center: live pot, or the awarded pot at hand end.
  double get displayPot {
    if (isHandOver && awardedPot > Money.epsilon) return awardedPot;
    return totalPot;
  }

  /// Whether the pot was split between two or more winners.
  bool get isSplitPot =>
      splitPotAward || (winnerPayouts.isEmpty && winnerIds.length > 1);

  /// Chips credited to [winnerId] from [awardedPot].
  double awardShareFor(int winnerId) {
    if (winnerPayouts.isNotEmpty) return winnerPayouts[winnerId] ?? 0;
    if (winnerIds.isEmpty || awardedPot <= Money.epsilon) return 0;
    return Money.splitPot(awardedPot, winnerIds)[winnerId] ?? 0;
  }

  /// Chips [player] must add to match [highestBet], capped at their stack.
  double callAmountFor(PlayerModel player) {
    final owed = Money.roundNonNegative(highestBet - player.currentBet);
    return owed > player.stack ? Money.roundNonNegative(player.stack) : owed;
  }

  GameState copyWith({
    List<PlayerModel>? players,
    GameMode? mode,
    List<CardModel>? community,
    double? mainPot,
    double? awardedPot,
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
    SituationModel? activeSituation,
    bool clearSituation = false,
    double? heroInvestedThisHand,
    bool? isHandOver,
    bool? waitingForHero,
    String? resultMessage,
    bool clearResult = false,
    List<int>? winnerIds,
    List<double>? sidePots,
    Map<int, double>? winnerPayouts,
    bool? splitPotAward,
  }) {
    return GameState(
      players: players ?? this.players,
      mode: mode ?? this.mode,
      community: community ?? this.community,
      mainPot: mainPot ?? this.mainPot,
      awardedPot: awardedPot ?? this.awardedPot,
      street: street ?? this.street,
      dealerIndex: dealerIndex ?? this.dealerIndex,
      sbIndex: sbIndex ?? this.sbIndex,
      bbIndex: bbIndex ?? this.bbIndex,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      highestBet: highestBet ?? this.highestBet,
      minRaise: minRaise ?? this.minRaise,
      smallBlind: smallBlind ?? this.smallBlind,
      bigBlind: bigBlind ?? this.bigBlind,
      lastAggressor:
          clearLastAggressor ? null : (lastAggressor ?? this.lastAggressor),
      heroLine: heroLine ?? this.heroLine,
      handCount: handCount ?? this.handCount,
      activeSituation:
          clearSituation ? null : (activeSituation ?? this.activeSituation),
      heroInvestedThisHand: heroInvestedThisHand ?? this.heroInvestedThisHand,
      isHandOver: isHandOver ?? this.isHandOver,
      waitingForHero: waitingForHero ?? this.waitingForHero,
      resultMessage: clearResult ? null : (resultMessage ?? this.resultMessage),
      winnerIds: winnerIds ?? this.winnerIds,
      sidePots: sidePots ?? this.sidePots,
      winnerPayouts: winnerPayouts ?? this.winnerPayouts,
      splitPotAward: splitPotAward ?? this.splitPotAward,
    );
  }
}
