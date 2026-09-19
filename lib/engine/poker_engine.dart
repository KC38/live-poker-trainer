/// Core NLH engine: streets, pot math, VillainModel-driven AI, free-check rule.
library;

import 'dart:math';

import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/engine/deck_evaluator.dart';
import 'package:live_poker_trainer/engine/villain_ai.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/situation_model.dart';

/// Hero / villain action kinds.
enum PokerActionType { fold, check, call, bet, raise, allIn }

/// A resolved player action.
class PokerAction {
  /// Creates an action.
  const PokerAction({required this.type, this.amount = 0});

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
  ///
  /// Pass [random] only for deterministic tests. Production deals must use the
  /// default generator so consecutive hands never share a frozen seed.
  PokerEngine({required GameSettingsModel settings, Random? random})
    // The public argument remains `settings`; an initializing formal would
    // make the named parameter private and unusable outside this library.
    // ignore: prefer_initializing_formals
    : _settings = settings,
      _random = random ?? Random(),
      _deterministic = random != null;

  GameSettingsModel _settings;
  final Random _random;

  /// True when the caller injected a seeded [Random] (tests only).
  final bool _deterministic;

  late GameState _state;
  List<CardModel> _deck = [];

  /// Fingerprint of the previous deal's hole cards (all seats), used to refuse
  /// accidental clone deals when the RNG is recycled or restirred poorly.
  String? _lastDealFingerprint;

  /// True once a [TableEventKind.collectPot] step has been emitted for the
  /// current betting round but the street has not advanced yet.
  bool _collectEmitted = false;

  /// Scripted villain actions from the situation graph (path / interstitial).
  final List<_QueuedSituationAction> _scriptQueue = [];

  /// Active branching situation for the current hand (null for free cash deals).
  SituationModel? _situation;

  /// Current graph node id while playing a situation.
  String? _situationNodeId;

  /// Last hero action key chosen at the current node (for progress logging).
  String? lastHeroActionKey;

  /// Hero node ids visited this hand (for [recordSituationProgress]).
  final List<String> pathNodeIds = [];

  /// Action keys chosen at each hero node (parallel to [pathNodeIds]).
  final List<String> chosenActionKeys = [];

  /// Terminal node reached, if any.
  String? terminalNodeId;

  /// Hero net chips from the terminal node.
  double? terminalHeroNetChips;

  /// Pending next node after a scripted node's actions finish.
  String? _pendingAfterScript;

  SituationModel? get situation => _situation;
  String? get situationNodeId => _situationNodeId;

  SituationNode? get currentSituationNode {
    final sit = _situation;
    final id = _situationNodeId;
    if (sit == null || id == null) return null;
    return sit.node(id);
  }

  HeroDecisionNode? get currentHeroNode {
    final n = currentSituationNode;
    return n is HeroDecisionNode ? n : null;
  }

  GameState get state => _state;
  GameSettingsModel get settings => _settings;

  /// Stable id for the hole-card layout of [state]'s current deal.
  static String dealFingerprint(GameState state) {
    final parts = <String>[
      for (final p in state.players) p.holeCards.map((c) => c.code).join(','),
    ];
    return parts.join('|');
  }

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
        arch =
            idx < settings.customArchetypes.length
                ? settings.customArchetypes[idx]
                : settings.customArchetypes[idx %
                    settings.customArchetypes.length];
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
        PlayerModel(id: i, name: name, archetype: arch, stack: stack),
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
    // Use the engine's own generator so a seeded engine deals a reproducible
    // lineup as well as a reproducible deck.
    var players =
        existingPlayers ?? buildLineup(settings: _settings, random: _random);
    players = _applyAutoRebuy(players);

    final n = players.length;
    final dealer = dealerIndex ?? (_stateOrDefaultDealer(n));
    final sb = _smallBlindSeat(dealer, n);
    final bb = _bigBlindSeat(dealer, n);

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
    _clearSituationPlay();
    final handCount = _tryHandCount() + 1;
    players = _dealUniqueHoles(
      players,
      previousFingerprint: _lastDealFingerprint,
    );

    players = _postBlind(players, sb, _settings.smallBlind);
    players = _postBlind(players, bb, _settings.bigBlind);

    final highest = _settings.bigBlind;
    final firstToAct = (bb + 1) % n;
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
      // Blind posts are not voluntary aggression — leave null until a
      // real bet/raise so the coach never calls the BB the "aggressor".
      lastAggressor: null,
      heroLine: const [],
      handCount: handCount,
      heroInvestedThisHand: heroBet,
      waitingForHero: players[firstToAct].isHero,
      isHandOver: false,
      // Never carry a prior hand's result / situation into the new deal.
      resultMessage: null,
      activeSituation: null,
      winnerIds: const [],
      awardedPot: 0,
    );
    _lastDealFingerprint = dealFingerprint(_state);

    if (resolve && !_state.waitingForHero) {
      runToHeroOrEnd();
    }
    return _state;
  }

  /// Shuffles and deals hole cards, reshuffling when the layout matches
  /// [previousFingerprint] so "Next hand" can never clone the prior deal.
  List<PlayerModel> _dealUniqueHoles(
    List<PlayerModel> players, {
    String? previousFingerprint,
  }) {
    const maxAttempts = 8;
    var dealt = players;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (!_deterministic && attempt > 0) {
        // Stir extra entropy for production engines only; seeded test RNGs
        // must stay on a single sequence for reproducibility.
        _random.nextInt(1 << 20);
      }
      final shuffleRng =
          _deterministic ? _random : Random(_random.nextInt(1 << 32));
      _deck = DeckEvaluator.buildShuffledDeck(shuffleRng);
      dealt = [
        for (final p in players)
          p.copyWith(holeCards: [_deck.removeLast(), _deck.removeLast()]),
      ];
      final fingerprint = [
        for (final p in dealt) p.holeCards.map((c) => c.code).join(','),
      ].join('|');
      if (previousFingerprint == null || fingerprint != previousFingerprint) {
        return dealt;
      }
    }
    return dealt;
  }

  /// Alias for [startHand] (legacy cash-sim entry point).
  GameState startCashHand({
    List<PlayerModel>? existingPlayers,
    int? dealerIndex,
  }) => startHand(existingPlayers: existingPlayers, dealerIndex: dealerIndex);

  int _stateOrDefaultDealer(int n) {
    try {
      return (_state.dealerIndex + 1) % n;
    } catch (_) {
      return 0;
    }
  }

  static int _smallBlindSeat(int dealer, int seatCount) =>
      seatCount == 2 ? dealer : (dealer + 1) % seatCount;

  static int _bigBlindSeat(int dealer, int seatCount) =>
      seatCount == 2
          ? (dealer + 1) % seatCount
          : (dealer + 2) % seatCount;

  int _tryHandCount() {
    try {
      return _state.handCount;
    } catch (_) {
      return 0;
    }
  }

  /// Deals a server-authored branching situation from its root node.
  ///
  /// Enters the root (often a scripted blind-post node). [nextEvent] plays
  /// scripted seats, then waits at the first hero decision.
  GameState dealSituationHand(
    SituationModel situation, {
    List<PlayerModel>? existingPlayers,
  }) {
    _clearSituationPlay();
    _situation = situation;

    final stackBb =
        situation.bigBlind > 0
            ? (situation.startingStack / situation.bigBlind).round()
            : 100;
    _settings = _settings.copyWith(
      seatCount: situation.seatCount.clamp(2, 9),
      smallBlind: situation.smallBlind,
      bigBlind: situation.bigBlind,
      stackDepthBb: stackBb.clamp(20, 500),
    );

    final players = _buildSituationLineup(
      situation,
      existingPlayers: existingPlayers,
    );
    final n = players.length;
    final dealer = situation.buttonSeat.clamp(0, n - 1);

    _collectEmitted = false;
    _state = GameState(
      players: players,
      mode: GameMode.training,
      community: const [],
      mainPot: 0,
      street: Street.preflop,
      dealerIndex: dealer,
      sbIndex: _smallBlindSeat(dealer, n),
      bbIndex: _bigBlindSeat(dealer, n),
      activePlayerIndex: situation.heroSeat.clamp(0, n - 1),
      highestBet: 0,
      minRaise: situation.bigBlind,
      smallBlind: situation.smallBlind,
      bigBlind: situation.bigBlind,
      lastAggressor: null,
      heroLine: const [],
      handCount: _tryHandCount() + 1,
      activeSituation: situation,
      heroInvestedThisHand: 0,
      waitingForHero: false,
      isHandOver: false,
      resultMessage: null,
      winnerIds: const [],
      awardedPot: 0,
    );

    _enterSituationNode(situation.rootNodeId);
    _lastDealFingerprint = dealFingerprint(_state);
    return _state;
  }

  /// Applies a hero edge choice: records progress keys, animates the action,
  /// then enters [HeroActionEdge.nextNodeId].
  HeroActionEdge? applySituationHeroChoice({
    required HeroActionEdge edge,
    required PokerAction action,
  }) {
    final node = currentHeroNode;
    if (node == null) return null;

    lastHeroActionKey = edge.actionKey;
    pathNodeIds.add(node.id);
    chosenActionKeys.add(edge.actionKey);

    _scriptQueue.clear();
    final heroIdx = _state.players.indexWhere((p) => p.isHero);
    _state = _applyAction(_state, heroIdx, action, isHero: true);

    _enterSituationNode(edge.nextNodeId);
    return edge;
  }

  /// After a scripted queue drains, advance to the pending next node.
  void syncSituationNodeAfterScript() {
    if (_scriptQueue.isNotEmpty) return;
    final next = _pendingAfterScript;
    if (next == null || next.isEmpty) return;
    _pendingAfterScript = null;
    _enterSituationNode(next);
  }

  void _enterSituationNode(String nodeId) {
    final sit = _situation;
    if (sit == null) return;
    final node = sit.node(nodeId);
    if (node == null) {
      throw StateError('Unknown situation node $nodeId');
    }
    _situationNodeId = nodeId;

    switch (node) {
      case ScriptedNode(:final actions, :final nextNodeId):
        _snapTableFromNode(
          street: node.street,
          pot: node.pot,
          stacks: node.stacks,
          streetBets: node.streetBets,
          board: node.board,
          foldedSeats: node.foldedSeats,
          toAct: actions.isNotEmpty ? actions.first.seat : sit.heroSeat,
          minRaiseTo: _state.bigBlind,
          waitingForHero: false,
        );
        _scriptQueue
          ..clear()
          ..addAll([
            for (final a in actions)
              _QueuedSituationAction(seat: a.seat, action: a),
          ]);
        _pendingAfterScript = nextNodeId;
        if (_scriptQueue.isEmpty) {
          syncSituationNodeAfterScript();
        }
      case HeroDecisionNode(
        :final pot,
        :final stacks,
        :final streetBets,
        :final board,
        :final foldedSeats,
        :final toAct,
        :final minRaiseTo,
      ):
        _pendingAfterScript = null;
        _scriptQueue.clear();
        _snapTableFromNode(
          street: node.street,
          pot: pot,
          stacks: stacks,
          streetBets: streetBets,
          board: board,
          foldedSeats: foldedSeats,
          toAct: toAct,
          minRaiseTo: minRaiseTo > 0 ? minRaiseTo : _state.bigBlind,
          waitingForHero: true,
        );
      case TerminalNode(
        :final pot,
        :final board,
        :final stacks,
        :final winnerSeats,
        :final summary,
        :final reason,
        :final foldedSeats,
      ):
        _pendingAfterScript = null;
        _scriptQueue.clear();
        terminalNodeId = node.id;
        final heroSeat = sit.heroSeat.clamp(0, _state.players.length - 1);
        final payouts = Money.splitPot(pot, winnerSeats);
        final players = [
          for (var i = 0; i < _state.players.length; i++)
            _state.players[i].copyWith(
              stack: Money.round(stacks[i] + (payouts[i] ?? 0)),
              currentBet: 0,
              folded: foldedSeats.contains(i),
              allIn: false,
              hasActedThisRound: false,
              clearLastAction: true,
            ),
        ];
        final heroStartingStack =
            sit.lineup
                .firstWhere((seat) => seat.seat == heroSeat)
                .startingStack;
        terminalHeroNetChips = players[heroSeat].stack - heroStartingStack;
        _state = _state.copyWith(
          players: players,
          community: List<CardModel>.from(board),
          mainPot: 0,
          street: node.street == Street.showdown ? Street.river : node.street,
          isHandOver: true,
          waitingForHero: false,
          awardedPot: pot,
          winnerIds: List<int>.from(winnerSeats),
          resultMessage:
              summary?.isNotEmpty == true
                  ? summary
                  : 'Hand over (${reason.wire})',
        );
    }
  }

  void _snapTableFromNode({
    required Street street,
    required double pot,
    required List<double> stacks,
    required List<double> streetBets,
    required List<CardModel> board,
    required List<int> foldedSeats,
    required int toAct,
    required double minRaiseTo,
    required bool waitingForHero,
  }) {
    final n = _state.players.length;
    final players = [
      for (var i = 0; i < n; i++)
        _state.players[i].copyWith(
          stack: i < stacks.length ? stacks[i] : _state.players[i].stack,
          currentBet: i < streetBets.length ? streetBets[i] : 0,
          folded: foldedSeats.contains(i),
          allIn:
              (i < stacks.length ? stacks[i] : 0) <= Money.epsilon &&
              (i < streetBets.length ? streetBets[i] : 0) <= Money.epsilon,
          hasActedThisRound: false,
          holeCards: _state.players[i].holeCards,
          clearLastAction: true,
        ),
    ];
    final highest = players.fold<double>(
      0,
      (m, p) => p.currentBet > m ? p.currentBet : m,
    );
    final dealer = _situation!.buttonSeat.clamp(0, n - 1);
    final heroSeat = _situation!.heroSeat.clamp(0, n - 1);
    _state = _state.copyWith(
      players: players,
      community: List<CardModel>.from(board),
      mainPot: Money.roundNonNegative(
        pot - players.fold<double>(0, (s, p) => s + p.currentBet),
      ).clamp(0, double.infinity),
      street: street == Street.showdown ? Street.river : street,
      dealerIndex: dealer,
      sbIndex: _smallBlindSeat(dealer, n),
      bbIndex: _bigBlindSeat(dealer, n),
      highestBet: highest,
      minRaise: Money.roundNonNegative(
        minRaiseTo - highest,
      ).clamp(_state.bigBlind, double.infinity),
      activePlayerIndex: toAct.clamp(0, n - 1),
      waitingForHero: waitingForHero,
      isHandOver: false,
      clearResult: true,
      heroInvestedThisHand: players[heroSeat].currentBet,
    );
  }

  void _clearSituationPlay() {
    _scriptQueue.clear();
    _situation = null;
    _situationNodeId = null;
    lastHeroActionKey = null;
    pathNodeIds.clear();
    chosenActionKeys.clear();
    terminalNodeId = null;
    terminalHeroNetChips = null;
    _pendingAfterScript = null;
  }

  List<PlayerModel> _buildSituationLineup(
    SituationModel situation, {
    List<PlayerModel>? existingPlayers,
  }) {
    final seatCount = situation.seatCount.clamp(2, 9);
    final settings = _settings.copyWith(seatCount: seatCount);
    var players = buildLineup(settings: settings, random: _random);

    if (existingPlayers != null && existingPlayers.isNotEmpty) {
      players = [
        for (var i = 0; i < players.length; i++)
          players[i].copyWith(
            stack:
                i < existingPlayers.length
                    ? existingPlayers[i].stack
                    : players[i].stack,
          ),
      ];
    }

    final bySeat = {for (final s in situation.lineup) s.seat: s};
    final holesBySeat = {
      for (final entry in situation.holeCards) entry.seat: entry.cards,
    };
    final usedNames = <String>{'Hero'};
    final heroSeat = situation.heroSeat.clamp(0, players.length - 1);
    final renamed = <PlayerModel>[];
    for (var i = 0; i < players.length; i++) {
      final seatInfo = bySeat[i];
      final start = seatInfo?.startingStack ?? situation.startingStack;
      if (i == heroSeat) {
        renamed.add(
          players[i].copyWith(
            stack: start,
            holeCards: holesBySeat[i] ?? situation.heroHand,
            name:
                (seatInfo?.name.isNotEmpty ?? false)
                    ? seatInfo!.name
                    : players[i].name,
            archetype: PlayerArchetype.hero,
          ),
        );
        continue;
      }
      final arch = seatInfo?.playerArchetype ?? players[i].archetype;
      final name =
          (seatInfo?.name.isNotEmpty ?? false)
              ? seatInfo!.name
              : ArchetypeRoster.uniqueName(arch, usedNames);
      usedNames.add(name);
      renamed.add(
        players[i].copyWith(
          stack: start,
          archetype: arch,
          name: name,
          holeCards: holesBySeat[i] ?? const [],
        ),
      );
    }
    players = renamed;

    final dead = {
      for (final entry in situation.holeCards)
        for (final card in entry.cards) card.code,
    };
    for (final r in situation.runouts) {
      for (final c in r.cards) {
        dead.add(c.code);
      }
    }
    _deck = [
      for (final c in DeckEvaluator.buildShuffledDeck(_random))
        if (!dead.contains(c.code)) c,
    ];
    return players;
  }

  PokerAction? _scriptedActionFor(GameState state, int seat) {
    if (_scriptQueue.isEmpty) return null;
    final next = _scriptQueue.first;
    if (next.seat != seat) {
      if (!_canStillAct(state.players[seat])) return null;
      final call = state.callAmountFor(state.players[seat]);
      if (call > Money.epsilon) {
        return const PokerAction(type: PokerActionType.fold);
      }
      return const PokerAction(type: PokerActionType.check);
    }
    _scriptQueue.removeAt(0);
    return _pokerActionFromScripted(state, next.action);
  }

  PokerAction _pokerActionFromScripted(GameState state, ScriptedAction action) {
    final seat = action.seat.clamp(0, state.players.length - 1);
    final player = state.players[seat];
    final callAmt = state.callAmountFor(player);
    final allInTo = Money.round(player.stack + player.currentBet);
    final amountTo = action.amountTo;

    switch (action.kind) {
      case SituationActionKind.fold:
        return const PokerAction(type: PokerActionType.fold);
      case SituationActionKind.check:
        return const PokerAction(type: PokerActionType.check);
      case SituationActionKind.call:
        return PokerAction(type: PokerActionType.call, amount: callAmt);
      case SituationActionKind.postSb:
      case SituationActionKind.postBb:
      case SituationActionKind.postAnte:
      case SituationActionKind.bet:
      case SituationActionKind.raise:
      case SituationActionKind.allIn:
        final raiseTo = amountTo ?? allInTo;
        if (raiseTo >= allInTo - Money.epsilon) {
          return PokerAction(type: PokerActionType.allIn, amount: allInTo);
        }
        if (action.kind == SituationActionKind.postSb ||
            action.kind == SituationActionKind.postBb ||
            action.kind == SituationActionKind.postAnte) {
          // Treat blind posts as raising the street commitment.
          return PokerAction(type: PokerActionType.bet, amount: raiseTo);
        }
        if (raiseTo <= state.highestBet + Money.epsilon) {
          if (callAmt <= Money.epsilon) {
            return const PokerAction(type: PokerActionType.check);
          }
          return PokerAction(type: PokerActionType.call, amount: callAmt);
        }
        final isBet = state.highestBet <= Money.epsilon;
        return PokerAction(
          type: isBet ? PokerActionType.bet : PokerActionType.raise,
          amount: raiseTo,
        );
    }
  }

  /// Soft grade — situations use edge coaching strings, not local EV.
  ({bool correct, double sizingErrorBb}) gradeHeroAction(PokerAction action) {
    return (correct: true, sizingErrorBb: 0);
  }

  /// Applies a hero action without playing out the villains.
  ///
  /// Pair with [nextEvent] to replay the rest of the street step by step.
  /// Situation hands should prefer [applySituationHeroChoice].
  GameState submitHeroAction(PokerAction action) {
    var state = _state;
    if (!state.waitingForHero || state.isHandOver) return state;
    if (state.hero.folded) return state;

    _scriptQueue.clear();

    final heroIdx = state.players.indexWhere((p) => p.isHero);
    _state = _applyAction(state, heroIdx, action, isHero: true);
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

      // Situation hands follow the authored script queue; do not auto-advance
      // streets via AI until the queue / pending node is consumed.
      if (_situation != null &&
          _scriptQueue.isEmpty &&
          _pendingAfterScript != null) {
        syncSituationNodeAfterScript();
        s = _state;
        if (s.isHandOver) {
          return TableEvent(kind: TableEventKind.handOver, state: s);
        }
        if (s.waitingForHero) return null;
        continue;
      }

      if (_situation == null && _isRoundComplete(s)) {
        final hasBets = s.players.any((p) => p.currentBet > Money.epsilon);
        if (hasBets && !_collectEmitted) {
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

      final idx =
          _situation != null && _scriptQueue.isNotEmpty
              ? _scriptQueue.first.seat.clamp(0, s.players.length - 1)
              : s.activePlayerIndex;
      final player = s.players[idx];
      if (!_canStillAct(player)) {
        s = _advanceToNextPlayer(s);
        _state = s;
        continue;
      }
      if (player.isHero && _scriptQueue.isEmpty) {
        s = s.copyWith(waitingForHero: true);
        _state = s;
        return null;
      }

      final isForcedPost =
          _scriptQueue.isNotEmpty &&
          _scriptQueue.first.seat == idx &&
          _isForcedPost(_scriptQueue.first.action.kind);
      final decision = _villainDecision(s, idx);
      s = _applyAction(s, idx, decision, isForcedPost: isForcedPost);
      if (_situation != null && _scriptQueue.isNotEmpty) {
        s = s.copyWith(
          activePlayerIndex: _scriptQueue.first.seat.clamp(
            0,
            s.players.length - 1,
          ),
          waitingForHero: false,
        );
      }
      _state = s;
      if (_scriptQueue.isEmpty && _situation != null) {
        syncSituationNodeAfterScript();
        s = _state;
      }
      return TableEvent(
        kind:
            s.isHandOver
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

  /// Lowest legal "raise to" for [player], or their all-in when short.
  static double _minRaiseTo(GameState state, PlayerModel player) {
    final allIn = Money.round(player.stack + player.currentBet);
    final increment = max(state.minRaise, state.bigBlind);
    final floor = Money.round(state.highestBet + increment);
    if (floor >= allIn - Money.epsilon) return allIn;
    return floor;
  }

  /// Maps a [VillainAi] sample onto a legal [PokerAction].
  ///
  /// Postflop lines come from [VillainModel] frequencies (same tables the coach
  /// uses when narrowing ranges). See [VillainAi] for the RNG contract.
  PokerAction _villainDecision(GameState state, int playerIdx) {
    final scripted = _scriptedActionFor(state, playerIdx);
    if (scripted != null) return scripted;

    // While a situation script is active, never fall through to AI.
    if (_situation != null && _scriptQueue.isNotEmpty) {
      final call = state.callAmountFor(state.players[playerIdx]);
      if (call > Money.epsilon) {
        return const PokerAction(type: PokerActionType.fold);
      }
      return const PokerAction(type: PokerActionType.check);
    }

    // Branching situations stay on the authored tree — no free AI after hero.
    if (_situation != null) {
      final call = state.callAmountFor(state.players[playerIdx]);
      if (call > Money.epsilon) {
        return const PokerAction(type: PokerActionType.fold);
      }
      return const PokerAction(type: PokerActionType.check);
    }

    final choice = VillainAi.decide(state, playerIdx, _random);
    return switch (choice.line) {
      VillainLine.fold => const PokerAction(type: PokerActionType.fold),
      VillainLine.check => const PokerAction(type: PokerActionType.check),
      VillainLine.call => PokerAction(
        type: PokerActionType.call,
        amount: choice.callAmount,
      ),
      VillainLine.raise => PokerAction(
        type: PokerActionType.raise,
        amount: choice.raiseTo,
      ),
    };
  }

  GameState _applyAction(
    GameState state,
    int playerIdx,
    PokerAction action, {
    bool isHero = false,
    bool isForcedPost = false,
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
          setPlayer(
            player.copyWith(hasActedThisRound: true, lastActionLabel: 'CHECK'),
          );
          break;
        }
        setPlayer(
          player.copyWith(
            folded: true,
            hasActedThisRound: true,
            lastActionLabel: 'FOLD',
          ),
        );
        break;
      case PokerActionType.check:
        setPlayer(
          player.copyWith(hasActedThisRound: true, lastActionLabel: 'CHECK'),
        );
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
        final allInTo = Money.round(player.stack + player.currentBet);
        var target =
            action.type == PokerActionType.allIn
                ? allInTo
                : Money.round(action.amount);
        // Non-shove aggression must meet a full min-raise; undersized "raises"
        // from a stale slider or buggy AI would otherwise reopen the street.
        if (!isForcedPost &&
            action.type != PokerActionType.allIn &&
            target > highest + Money.epsilon &&
            target < _minRaiseTo(state, player) - Money.epsilon) {
          target = _minRaiseTo(state, player);
        }
        target = Money.clamp(target, 0, allInTo);
        final toAdd = Money.roundNonNegative(
          min(target - player.currentBet, player.stack),
        );
        final priorHighest = highest;
        setPlayer(
          _postChips(
            player,
            toAdd,
            label:
                action.type == PokerActionType.allIn
                    ? 'ALL-IN'
                    : (priorHighest <= Money.epsilon ? 'BET' : 'RAISE'),
          ),
        );
        if (isForcedPost) {
          highest = max(highest, player.currentBet);
          setPlayer(player.copyWith(hasActedThisRound: false));
        } else if (player.currentBet > highest + Money.epsilon) {
          final raiseSize = Money.round(player.currentBet - highest);
          final fullMin = max(state.minRaise, state.bigBlind);
          // Incomplete (short all-in) raises still pull chips in and update
          // the price, but only a full min-raise reopens action for players
          // who already matched the prior bet — otherwise preflop wars of
          // +1bb "raises" never end.
          final reopens = !player.allIn || raiseSize + Money.epsilon >= fullMin;
          if (reopens) {
            minRaise = Money.round(raiseSize);
          }
          highest = player.currentBet;
          lastAggressor = playerIdx;
          if (reopens) {
            players = [
              for (var i = 0; i < players.length; i++)
                if (i == playerIdx)
                  players[i]
                else if (!players[i].folded)
                  players[i].copyWith(hasActedThisRound: false)
                else
                  players[i],
            ];
          } else {
            // Short all-in: anyone who has not matched the new price must
            // still respond, even if they had already acted at the old price.
            players = [
              for (var i = 0; i < players.length; i++)
                if (i == playerIdx)
                  players[i]
                else if (!players[i].folded &&
                    !Money.same(players[i].currentBet, highest))
                  players[i].copyWith(hasActedThisRound: false)
                else
                  players[i],
            ];
          }
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
        awardedPot: pot,
        isHandOver: true,
        waitingForHero: false,
        resultMessage: '${winner.name} wins ${ChipFormat.dollars(pot)}',
        winnerIds: [winner.id],
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

  static bool _isForcedPost(SituationActionKind kind) {
    return kind == SituationActionKind.postAnte ||
        kind == SituationActionKind.postSb ||
        kind == SituationActionKind.postBb;
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
    // Blind posts are forced ante-style chips, not a voluntary action.
    // Leaving hasActedThisRound true here skipped the BB (and SB) option
    // whenever everyone limped / completed to a matched price.
    final posted = _postChips(updated[idx], amount, label: 'BLIND');
    updated[idx] = posted.copyWith(hasActedThisRound: false);
    return updated;
  }

  bool _isRoundComplete(GameState state) {
    final active = state.players.where((p) => !p.folded).toList();
    if (active.length <= 1) return true;
    final canAct = active.where(_canStillAct).toList();
    // Fewer than two players with chips behind: no side-pot betting is
    // possible. Once everyone who can still put money in has matched the
    // price (including the all-zero case on a fresh street after an all-in),
    // the round is closed and remaining board cards should just run out.
    if (canAct.length < 2) {
      return canAct.every((p) => Money.same(p.currentBet, state.highestBet));
    }
    for (final p in canAct) {
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
        state.copyWith(
          players: players,
          mainPot: mainPot,
          community: community,
        ),
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
    final canActCount = players.where(_canStillAct).length;
    // All-in pot (or single stack behind): do not open a betting round —
    // [nextEvent] will keep dealing streets through to showdown.
    final bettingOpen = canActCount >= 2;
    return state.copyWith(
      players: players,
      mainPot: mainPot,
      community: community,
      street: nextStreet,
      highestBet: 0,
      minRaise: state.bigBlind,
      clearLastAggressor: true,
      activePlayerIndex: first,
      waitingForHero: bettingOpen && firstPlayer.isHero && !firstPlayer.folded,
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
      final score =
          cards.length >= 5 ? DeckEvaluator.evaluate7Cards(cards).score : 0;
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
    final winnerIds = winners.map((w) => w.id).toSet();
    final payouts = Money.splitPot(pot, winnerIds);
    final players = [
      for (final p in state.players)
        if (winnerIds.contains(p.id))
          p.copyWith(
            stack: Money.round(p.stack + (payouts[p.id] ?? 0)),
            currentBet: 0,
          )
        else
          p.copyWith(currentBet: 0),
    ];

    final names = winners.map((w) => w.name).join(' & ');
    final split = winners.length > 1;
    return state.copyWith(
      players: players,
      mainPot: 0,
      awardedPot: pot,
      street: Street.showdown,
      isHandOver: true,
      waitingForHero: false,
      resultMessage:
          split
              ? '$names split ${ChipFormat.dollars(pot)}'
              : '$names wins ${ChipFormat.dollars(pot)}',
      winnerIds: winners.map((w) => w.id).toList(growable: false),
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

/// One pending scripted action from a situation scripted node.
class _QueuedSituationAction {
  const _QueuedSituationAction({required this.seat, required this.action});

  final int seat;
  final ScriptedAction action;
}
