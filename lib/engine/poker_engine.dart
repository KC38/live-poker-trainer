/// Core NLH engine: streets, pot math, archetype AI, free-check rule.
library;

import 'dart:math';

import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/engine/deck_evaluator.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Hero / villain action kinds.
enum PokerActionType { fold, check, call, bet, raise, allIn }

/// A resolved player action.
class PokerAction {
  /// Creates an action.
  const PokerAction({
    required this.type,
    this.amount = 0,
  });

  final PokerActionType type;

  /// Absolute chip amount put in for bet/raise (total bet on street), or call chips.
  final double amount;

  String get label {
    switch (type) {
      case PokerActionType.fold:
        return 'FOLD';
      case PokerActionType.check:
        return 'CHECK';
      case PokerActionType.call:
        return 'CALL';
      case PokerActionType.bet:
        return 'BET';
      case PokerActionType.raise:
        return 'RAISE';
      case PokerActionType.allIn:
        return 'ALL-IN';
    }
  }
}

/// One resolved step of a hand, so the UI can replay play at human pace.
enum TableEventKind {
  /// A villain checked, called, folded, bet, or raised.
  villainAction,

  /// The street's bets are ready to slide into the pot.
  collectPot,

  /// New board cards were dealt for [TableEvent.street].
  dealStreet,

  /// The hand finished (fold-out or showdown).
  handOver,
}

/// A single replayable step produced by [PokerEngine.nextEvent].
class TableEvent {
  /// Creates a table event.
  const TableEvent({
    required this.kind,
    required this.state,
    this.seatIndex,
    this.action,
    this.street,
  });

  final TableEventKind kind;

  /// Snapshot after the step was applied.
  final GameState state;

  /// Seat that acted, for [TableEventKind.villainAction].
  final int? seatIndex;

  /// Action taken, for [TableEventKind.villainAction].
  final PokerAction? action;

  /// Street reached, for [TableEventKind.dealStreet].
  final Street? street;
}

/// Mutable poker table engine producing immutable [GameState] snapshots.
class PokerEngine {
  /// Creates an engine with [settings] and optional [random].
  PokerEngine({
    required this._settings,
    Random? random,
  }) : _random = random ?? Random();

  GameSettingsModel _settings;
  final Random _random;
  late GameState _state;
  List<CardModel> _deck = [];

  /// True once a [TableEventKind.collectPot] step has been emitted for the
  /// current betting round but the street has not advanced yet.
  bool _collectEmitted = false;

  GameState get state => _state;
  GameSettingsModel get settings => _settings;

  /// Updates settings (stack depth / rebuy / blinds).
  void updateSettings(GameSettingsModel settings) {
    _settings = settings;
  }

  /// Builds a default lineup for [seatCount].
  static List<PlayerModel> buildLineup({
    required GameSettingsModel settings,
    Random? random,
  }) {
    final rng = random ?? Random();
    final stack = settings.startingStack;
    final usedNames = <String>{'Hero'};
    final players = <PlayerModel>[
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: stack,
        isHero: true,
      ),
    ];

    final pool = List<PlayerArchetype>.from(ArchetypeRoster.villainPool);
    // Shuffle pool so random lineups vary and reduce early duplicates.
    pool.shuffle(rng);
    for (var i = 1; i < settings.seatCount; i++) {
      PlayerArchetype arch;
      if (settings.lineupMode == LineupMode.custom &&
          settings.customArchetypes.isNotEmpty) {
        final idx = i - 1;
        arch = idx < settings.customArchetypes.length
            ? settings.customArchetypes[idx]
            : settings.customArchetypes[
                idx % settings.customArchetypes.length];
      } else {
        arch = pool[(i - 1) % pool.length];
        // Occasionally remix so large tables still feel varied.
        if (i > pool.length && rng.nextBool()) {
          arch = pool[rng.nextInt(pool.length)];
        }
      }
      final name = ArchetypeRoster.uniqueName(arch, usedNames);
      usedNames.add(name);
      players.add(
        PlayerModel(
          id: i,
          name: name,
          archetype: arch,
          stack: stack,
        ),
      );
    }
    return players;
  }

  /// Starts a full cash-style training hand from preflop.
  ///
  /// With [resolve] true the preflop villain action is played out immediately.
  /// The table screen passes `false` and drives [nextEvent] on a timer so the
  /// action replays one seat at a time.
  GameState startHand({
    List<PlayerModel>? existingPlayers,
    int? dealerIndex,
    bool resolve = true,
  }) {
    var players = existingPlayers ?? buildLineup(settings: _settings);
    players = _applyAutoRebuy(players);

    final n = players.length;
    final dealer = dealerIndex ?? (_stateOrDefaultDealer(n));
    final sb = (dealer + 1) % n;
    final bb = (dealer + 2) % n;

    players = [
      for (final p in players)
        p.copyWith(
          currentBet: 0,
          folded: false,
          allIn: false,
          holeCards: const [],
          hasActedThisRound: false,
          clearLastAction: true,
        ),
    ];

    _collectEmitted = false;
    _deck = DeckEvaluator.buildShuffledDeck(_random);
    players = [
      for (final p in players)
        p.copyWith(holeCards: [_deck.removeLast(), _deck.removeLast()]),
    ];

    players = _postBlind(players, sb, _settings.smallBlind);
    players = _postBlind(players, bb, _settings.bigBlind);

    final highest = _settings.bigBlind;
    final firstToAct = (bb + 1) % n;
    final handCount = _tryHandCount() + 1;
    final heroBet = players.firstWhere((p) => p.isHero).currentBet;

    _state = GameState(
      players: players,
      mode: GameMode.training,
      community: const [],
      mainPot: 0,
      street: Street.preflop,
      dealerIndex: dealer,
      sbIndex: sb,
      bbIndex: bb,
      activePlayerIndex: firstToAct,
      highestBet: highest,
      minRaise: _settings.bigBlind,
      smallBlind: _settings.smallBlind,
      bigBlind: _settings.bigBlind,
      lastAggressor: bb,
      heroLine: const [],
      handCount: handCount,
      heroInvestedThisHand: heroBet,
      waitingForHero: players[firstToAct].isHero,
    );

    if (resolve && !_state.waitingForHero) {
      runToHeroOrEnd();
    }
    return _state;
  }

  /// Alias for [startHand] (legacy cash-sim entry point).
  GameState startCashHand({
    List<PlayerModel>? existingPlayers,
    int? dealerIndex,
  }) =>
      startHand(existingPlayers: existingPlayers, dealerIndex: dealerIndex);

  int _stateOrDefaultDealer(int n) {
    try {
      return (_state.dealerIndex + 1) % n;
    } catch (_) {
      return 0;
    }
  }

  int _tryHandCount() {
    try {
      return _state.handCount;
    } catch (_) {
      return 0;
    }
  }

  /// Injects a practice scenario onto the table.
  GameState startPracticeScenario(ScenarioModel scenario) {
    final seatCount = scenario.tableSize.clamp(2, 9);
    final settings = _settings.copyWith(seatCount: seatCount);
    var players = buildLineup(settings: settings, random: _random);
    players = _applyAutoRebuy(players);

    // Hero at seat 0 with scenario hole cards.
    players = [
      for (var i = 0; i < players.length; i++)
        if (i == 0)
          players[i].copyWith(holeCards: scenario.heroHand)
        else if (i == scenario.villainSeat.clamp(1, players.length - 1))
          players[i].copyWith(
            archetype: scenario.villainArchetype,
            name: ArchetypeRoster.defaultNames[scenario.villainArchetype] ??
                scenario.villainArchetype.label,
          )
        else
          players[i],
    ];

    final street = switch (scenario.boardCards.length) {
      0 => Street.preflop,
      3 => Street.flop,
      4 => Street.turn,
      _ => Street.river,
    };

    final callAmt = scenario.callAmount;
    final villainSeat = scenario.villainSeat.clamp(1, players.length - 1);

    // Model villain as having bet; hero to act facing callAmt.
    if (callAmt > 0) {
      players = [
        for (var i = 0; i < players.length; i++)
          if (i == villainSeat)
            players[i].copyWith(
              currentBet: callAmt,
              stack: (players[i].stack - callAmt).clamp(0, double.infinity),
            )
          else
            players[i],
      ];
    }

    _state = GameState(
      players: players,
      mode: GameMode.practice,
      community: scenario.boardCards,
      mainPot: scenario.potSize,
      street: street,
      dealerIndex: 0,
      sbIndex: 1 % players.length,
      bbIndex: 2 % players.length,
      activePlayerIndex: 0,
      highestBet: callAmt,
      minRaise: scenario.minRaise,
      smallBlind: _settings.smallBlind,
      bigBlind: _settings.bigBlind,
      lastAggressor: callAmt > 0 ? villainSeat : null,
      heroLine: const [],
      handCount: _tryHandCount() + 1,
      activeScenario: scenario,
      heroInvestedThisHand: 0,
      waitingForHero: true,
      isHandOver: false,
    );
    return _state;
  }

  /// Applies a hero action without playing out the villains.
  ///
  /// Pair with [nextEvent] to replay the rest of the street step by step.
  GameState submitHeroAction(PokerAction action) {
    var state = _state;
    if (!state.waitingForHero || state.isHandOver) return state;
    if (state.hero.folded) return state;

    final heroIdx = state.players.indexWhere((p) => p.isHero);
    state = _applyAction(state, heroIdx, action, isHero: true);
    _state = state.isHandOver ? state : state.copyWith(waitingForHero: false);
    return _state;
  }

  /// Applies a hero action and resolves the rest of the hand immediately.
  GameState applyHeroAction(PokerAction action) {
    final before = _state;
    final after = submitHeroAction(action);
    if (identical(after, before) || after.isHandOver) return after;
    return runToHeroOrEnd();
  }

  /// Produces the next replayable step, or `null` when the hand is over or it
  /// is the hero's turn.
  TableEvent? nextEvent() {
    var s = _state;
    if (s.isHandOver) return null;

    var guard = 0;
    while (guard < 96) {
      guard++;
      if (s.waitingForHero) {
        _state = s;
        return null;
      }

      if (_isRoundComplete(s)) {
        final hasBets =
            s.players.any((p) => p.currentBet > Money.epsilon);
        if (hasBets && !_collectEmitted) {
          // Let the UI slide the street's chips into the pot first.
          _collectEmitted = true;
          _state = s;
          return TableEvent(kind: TableEventKind.collectPot, state: s);
        }
        _collectEmitted = false;
        final previousStreet = s.street;
        s = _advanceStreet(s);
        _state = s;
        if (s.isHandOver) {
          return TableEvent(kind: TableEventKind.handOver, state: s);
        }
        if (s.street != previousStreet) {
          return TableEvent(
            kind: TableEventKind.dealStreet,
            state: s,
            street: s.street,
          );
        }
        continue;
      }

      final idx = s.activePlayerIndex;
      final player = s.players[idx];
      if (!_canStillAct(player)) {
        s = _advanceToNextPlayer(s);
        continue;
      }
      if (player.isHero) {
        s = s.copyWith(waitingForHero: true);
        _state = s;
        return null;
      }

      final decision = _villainDecision(s, idx);
      s = _applyAction(s, idx, decision);
      _state = s;
      return TableEvent(
        kind: s.isHandOver
            ? TableEventKind.handOver
            : TableEventKind.villainAction,
        state: s,
        seatIndex: idx,
        action: decision,
      );
    }

    _state = s;
    return null;
  }

  /// Drains [nextEvent] until the hero must act or the hand ends.
  GameState runToHeroOrEnd() {
    var guard = 0;
    while (guard < 512 && nextEvent() != null) {
      guard++;
    }
    return _state;
  }

  /// Grades hero action against practice optimal line.
  ({bool correct, double sizingErrorBb}) gradeHeroAction(PokerAction action) {
    final scenario = _state.activeScenario;
    if (scenario == null) {
      return (correct: true, sizingErrorBb: 0);
    }

    final optimal = scenario.optimalExploitAction;
    final mapped = switch (action.type) {
      PokerActionType.fold => ExploitAction.fold,
      PokerActionType.check => ExploitAction.check,
      PokerActionType.call => ExploitAction.call,
      PokerActionType.bet ||
      PokerActionType.raise ||
      PokerActionType.allIn =>
        ExploitAction.raise,
    };

    // Treat CHECK as matching CALL when call is free / optimal is check-ish.
    var actionMatch = mapped == optimal;
    if (!actionMatch &&
        optimal == ExploitAction.call &&
        mapped == ExploitAction.check &&
        scenario.callAmount <= 0) {
      actionMatch = true;
    }
    if (!actionMatch &&
        optimal == ExploitAction.check &&
        mapped == ExploitAction.call &&
        scenario.callAmount <= 0) {
      actionMatch = true;
    }

    var sizingError = 0.0;
    if (optimal == ExploitAction.raise &&
        (mapped == ExploitAction.raise) &&
        scenario.optimalSizingBb > 0) {
      final bb = _state.bigBlind;
      final sizingBb = action.amount / bb;
      sizingError = (sizingBb - scenario.optimalSizingBb).abs();
      // Allow ±40% band around optimal sizing.
      final band = scenario.optimalSizingBb * 0.4;
      if (sizingError > max(band, 1.0)) {
        actionMatch = false;
      } else {
        actionMatch = true;
      }
    }

    return (correct: actionMatch, sizingErrorBb: sizingError);
  }

  /// Rounds a desired "raise to" amount and caps it at the villain's all-in.
  static double _legalRaiseTarget(
    GameState state,
    PlayerModel villain,
    double desired,
  ) {
    final allIn = Money.round(villain.stack + villain.currentBet);
    final floor = Money.round(state.highestBet + state.bigBlind);
    return Money.clamp(Money.round(desired), min(floor, allIn), allIn);
  }

  PokerAction _villainDecision(GameState state, int playerIdx) {
    final v = state.players[playerIdx];
    final callAmount = state.callAmountFor(v);
    final pot = state.totalPot;
    final cards = [...v.holeCards, ...state.community];
    final handStrength = cards.length >= 5
        ? DeckEvaluator.evaluate7Cards(cards).score
        : 0;
    final arch = v.archetype;

    // Free check rule: never fold when checking is free.
    if (callAmount <= Money.epsilon) {
      if (state.street == Street.preflop) {
        return const PokerAction(type: PokerActionType.check);
      }
      double probe(double fraction) => _legalRaiseTarget(
            state,
            v,
            max(state.bigBlind, pot * fraction),
          );
      if (arch == PlayerArchetype.maniac && _random.nextDouble() < 0.65) {
        return PokerAction(type: PokerActionType.raise, amount: probe(0.75));
      }
      if (arch == PlayerArchetype.nit &&
          handStrength >= 1000000 &&
          _random.nextDouble() < 0.6) {
        return PokerAction(type: PokerActionType.raise, amount: probe(0.5));
      }
      if (handStrength >= 2000000) {
        return PokerAction(type: PokerActionType.raise, amount: probe(0.65));
      }
      return const PokerAction(type: PokerActionType.check);
    }

    final potWithoutCall = max(1.0, pot - callAmount);
    final betRatio = callAmount / potWithoutCall;

    if (state.street == Street.preflop) {
      final high = max(v.holeCards[0].rank, v.holeCards[1].rank);
      final isPair = v.holeCards[0].rank == v.holeCards[1].rank;
      final isSuited = v.holeCards[0].suit == v.holeCards[1].suit;

      switch (arch) {
        case PlayerArchetype.maniac:
        case PlayerArchetype.lag:
          if (_random.nextDouble() < 0.4 && callAmount < v.stack) {
            final target = _legalRaiseTarget(
              state,
              v,
              state.highestBet + state.bigBlind * 3,
            );
            return PokerAction(type: PokerActionType.raise, amount: target);
          }
          return PokerAction(type: PokerActionType.call, amount: callAmount);
        case PlayerArchetype.nit:
          final premium =
              (isPair && v.holeCards[0].rank >= 10) || (high == 14 && isSuited);
          return premium
              ? PokerAction(type: PokerActionType.call, amount: callAmount)
              : const PokerAction(type: PokerActionType.fold);
        case PlayerArchetype.callingStation:
          final play = callAmount <= state.bigBlind * 3 || isPair || isSuited;
          return play
              ? PokerAction(type: PokerActionType.call, amount: callAmount)
              : const PokerAction(type: PokerActionType.fold);
        default:
          final playable = isPair || (high >= 11 && v.holeCards[1].rank >= 9);
          return playable
              ? PokerAction(type: PokerActionType.call, amount: callAmount)
              : const PokerAction(type: PokerActionType.fold);
      }
    }

    switch (arch) {
      case PlayerArchetype.nit:
        final call = handStrength >= 2000000 ||
            (handStrength >= 1000000 && betRatio < 0.55);
        return call
            ? PokerAction(type: PokerActionType.call, amount: callAmount)
            : const PokerAction(type: PokerActionType.fold);
      case PlayerArchetype.callingStation:
        final call =
            handStrength >= 1000000 || betRatio < 0.4;
        return call
            ? PokerAction(type: PokerActionType.call, amount: callAmount)
            : const PokerAction(type: PokerActionType.fold);
      case PlayerArchetype.maniac:
      case PlayerArchetype.lag:
        if (_random.nextDouble() < 0.35 && v.stack > callAmount * 2) {
          final target = _legalRaiseTarget(
            state,
            v,
            state.highestBet + pot * 0.8,
          );
          return PokerAction(type: PokerActionType.raise, amount: target);
        }
        return PokerAction(type: PokerActionType.call, amount: callAmount);
      default:
        return handStrength >= 1000000
            ? PokerAction(type: PokerActionType.call, amount: callAmount)
            : const PokerAction(type: PokerActionType.fold);
    }
  }

  GameState _applyAction(
    GameState state,
    int playerIdx,
    PokerAction action, {
    bool isHero = false,
  }) {
    var players = List<PlayerModel>.from(state.players);
    var player = players[playerIdx];
    var highest = state.highestBet;
    var minRaise = state.minRaise;
    int? lastAggressor = state.lastAggressor;
    var heroInvested = state.heroInvestedThisHand;
    var heroLine = List<String>.from(state.heroLine);
    var mainPot = state.mainPot;
    var isHandOver = false;
    String? resultMessage;

    void setPlayer(PlayerModel p) {
      players[playerIdx] = p;
      player = p;
    }

    switch (action.type) {
      case PokerActionType.fold:
        // Free-check rule for non-hero: never fold when check is free.
        if (!isHero && state.callAmountFor(player) <= 0) {
          setPlayer(player.copyWith(
            hasActedThisRound: true,
            lastActionLabel: 'CHECK',
          ));
          break;
        }
        setPlayer(player.copyWith(
          folded: true,
          hasActedThisRound: true,
          lastActionLabel: 'FOLD',
        ));
        break;
      case PokerActionType.check:
        setPlayer(player.copyWith(
          hasActedThisRound: true,
          lastActionLabel: 'CHECK',
        ));
        break;
      case PokerActionType.call:
        final callAmt = Money.roundNonNegative(
          min(state.callAmountFor(player), player.stack),
        );
        setPlayer(_postChips(player, callAmt, label: 'CALL'));
        if (isHero) heroInvested = Money.round(heroInvested + callAmt);
        break;
      case PokerActionType.bet:
      case PokerActionType.raise:
      case PokerActionType.allIn:
        final target = action.type == PokerActionType.allIn
            ? Money.round(player.stack + player.currentBet)
            : Money.round(action.amount);
        final toAdd = Money.roundNonNegative(
          min(target - player.currentBet, player.stack),
        );
        setPlayer(_postChips(
          player,
          toAdd,
          label: action.type == PokerActionType.allIn ? 'ALL-IN' : 'RAISE',
        ));
        if (player.currentBet > highest + Money.epsilon) {
          minRaise = Money.round(player.currentBet - highest);
          highest = player.currentBet;
          lastAggressor = playerIdx;
          // Reset acted flags for others still in.
          players = [
            for (var i = 0; i < players.length; i++)
              if (i == playerIdx)
                players[i]
              else if (!players[i].folded)
                players[i].copyWith(hasActedThisRound: false)
              else
                players[i],
          ];
        }
        if (isHero) heroInvested = Money.round(heroInvested + toAdd);
        break;
    }

    if (isHero) {
      heroLine = [...heroLine, '${state.street.label}:${action.label}'];
    }

    // Everyone folded?
    final alive = players.where((p) => !p.folded).toList();
    if (alive.length == 1) {
      final winner = alive.first;
      final pot = Money.round(
        mainPot + players.fold<double>(0, (s, p) => s + p.currentBet),
      );
      players = [
        for (final p in players)
          if (p.id == winner.id)
            p.copyWith(stack: Money.round(p.stack + pot), currentBet: 0)
          else
            p.copyWith(currentBet: 0),
      ];
      return state.copyWith(
        players: players,
        mainPot: 0,
        isHandOver: true,
        waitingForHero: false,
        resultMessage: '${winner.name} wins ${ChipFormat.dollars(pot)}',
        heroLine: heroLine,
        heroInvestedThisHand: heroInvested,
        highestBet: 0,
      );
    }

    var next = state.copyWith(
      players: players,
      highestBet: highest,
      minRaise: minRaise,
      lastAggressor: lastAggressor,
      heroLine: heroLine,
      heroInvestedThisHand: heroInvested,
      mainPot: mainPot,
      isHandOver: isHandOver,
      resultMessage: resultMessage,
    );
    next = _advanceToNextPlayer(next);
    return next;
  }

  PlayerModel _postChips(PlayerModel player, double amount, {String? label}) {
    final pay = Money.roundNonNegative(min(amount, player.stack));
    final newStack = Money.roundNonNegative(player.stack - pay);
    return player.copyWith(
      stack: newStack,
      currentBet: Money.round(player.currentBet + pay),
      allIn: newStack <= Money.epsilon,
      hasActedThisRound: true,
      lastActionLabel: label,
    );
  }

  List<PlayerModel> _postBlind(
    List<PlayerModel> players,
    int idx,
    double amount,
  ) {
    final updated = List<PlayerModel>.from(players);
    updated[idx] = _postChips(updated[idx], amount, label: 'BLIND');
    return updated;
  }

  bool _isRoundComplete(GameState state) {
    final active = state.players.where((p) => !p.folded).toList();
    if (active.length <= 1) return true;
    for (final p in active) {
      if (!_canStillAct(p)) continue;
      if (!p.hasActedThisRound) return false;
      // Cent-tolerant compare: exact `!=` on doubles could spin the villain
      // loop forever on floating point dust.
      if (!Money.same(p.currentBet, state.highestBet)) return false;
    }
    return true;
  }

  /// Whether [player] still has chips behind to act with.
  static bool _canStillAct(PlayerModel player) =>
      !player.folded && player.stack > Money.epsilon;

  GameState _advanceToNextPlayer(GameState state) {
    if (_isRoundComplete(state)) {
      // Stop here: [nextEvent] advances the street so the UI can animate the
      // chips into the pot before board cards appear.
      return state.copyWith(waitingForHero: false);
    }
    final n = state.players.length;
    var next = (state.activePlayerIndex + 1) % n;
    var guard = 0;
    while (guard < n) {
      final p = state.players[next];
      if (_canStillAct(p)) {
        return state.copyWith(
          activePlayerIndex: next,
          waitingForHero: p.isHero,
        );
      }
      // All-in or folded players skip.
      next = (next + 1) % n;
      guard++;
    }
    return _advanceStreet(state);
  }

  GameState _advanceStreet(GameState state) {
    // Collect bets into pot.
    final collected = Money.round(
      state.players.fold<double>(0, (s, p) => s + p.currentBet),
    );
    final players = [
      for (final p in state.players)
        p.copyWith(
          currentBet: 0,
          hasActedThisRound: false,
          clearLastAction: true,
        ),
    ];
    final mainPot = Money.round(state.mainPot + collected);
    final community = List<CardModel>.from(state.community);
    final nextStreet = state.street.next;

    if (nextStreet == null || nextStreet == Street.showdown) {
      return _showdown(
        state.copyWith(players: players, mainPot: mainPot, community: community),
      );
    }

    // Deal board cards for the next street.
    final need = switch (nextStreet) {
      Street.flop => 3,
      Street.turn || Street.river => 1,
      _ => 0,
    };
    for (var i = 0; i < need; i++) {
      if (_deck.isNotEmpty) community.add(_deck.removeLast());
    }

    final first = _firstToActPostflop(state.copyWith(players: players));
    final firstPlayer = players[first];
    return state.copyWith(
      players: players,
      mainPot: mainPot,
      community: community,
      street: nextStreet,
      highestBet: 0,
      minRaise: state.bigBlind,
      clearLastAggressor: true,
      activePlayerIndex: first,
      waitingForHero: firstPlayer.isHero && !firstPlayer.folded,
    );
  }

  int _firstToActPostflop(GameState state) {
    final n = state.players.length;
    var idx = (state.dealerIndex + 1) % n;
    for (var i = 0; i < n; i++) {
      // Prefer players who can still act; all-in seats are skipped later.
      if (_canStillAct(state.players[idx])) return idx;
      idx = (idx + 1) % n;
    }
    // Fallback: first non-folded player.
    idx = (state.dealerIndex + 1) % n;
    for (var i = 0; i < n; i++) {
      if (!state.players[idx].folded) return idx;
      idx = (idx + 1) % n;
    }
    return state.dealerIndex;
  }

  GameState _showdown(GameState state) {
    final contenders = state.players.where((p) => !p.folded).toList();
    var bestScore = -1;
    final winners = <PlayerModel>[];
    for (final p in contenders) {
      final cards = [...p.holeCards, ...state.community];
      final score = cards.length >= 5
          ? DeckEvaluator.evaluate7Cards(cards).score
          : 0;
      if (score > bestScore) {
        bestScore = score;
        winners
          ..clear()
          ..add(p);
      } else if (score == bestScore) {
        winners.add(p);
      }
    }

    final pot = Money.round(state.mainPot);
    // Split to the cent, then award the odd cents to the first winner so no
    // chips are created or destroyed.
    final share = winners.isEmpty ? 0.0 : Money.round(pot / winners.length);
    final oddCents =
        winners.isEmpty ? 0.0 : Money.round(pot - share * winners.length);
    final firstWinnerId = winners.isEmpty ? null : winners.first.id;
    final winnerIds = winners.map((w) => w.id).toSet();
    final players = [
      for (final p in state.players)
        if (winnerIds.contains(p.id))
          p.copyWith(
            stack: Money.round(
              p.stack + share + (p.id == firstWinnerId ? oddCents : 0),
            ),
            currentBet: 0,
          )
        else
          p.copyWith(currentBet: 0),
    ];

    final names = winners.map((w) => w.name).join(' & ');
    return state.copyWith(
      players: players,
      mainPot: 0,
      street: Street.showdown,
      isHandOver: true,
      waitingForHero: false,
      resultMessage: '$names win ${ChipFormat.dollars(pot)}',
    );
  }

  List<PlayerModel> _applyAutoRebuy(List<PlayerModel> players) {
    if (!_settings.autoRebuy) return players;
    final threshold = _settings.rebuyThresholdBb * _settings.bigBlind;
    final target = _settings.startingStack;
    return [
      for (final p in players)
        if (p.stack < threshold) p.copyWith(stack: target) else p,
    ];
  }
}
