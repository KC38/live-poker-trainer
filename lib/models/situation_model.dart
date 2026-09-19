/// Server-authored branching situation payload (payloadVersion 2).
///
/// Mirrors `functions/src/situation_types.ts` exactly.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Published payload version.
const int kSituationPayloadVersion = 2;

/// Setup pool mode.
enum SetupMode {
  random,
  custom;

  static SetupMode fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'custom':
        return SetupMode.custom;
      default:
        return SetupMode.random;
    }
  }

  String get wire => name;
}

/// Hero / scripted action kinds from the server.
enum SituationActionKind {
  fold,
  check,
  call,
  bet,
  raise,
  allIn,
  postSb,
  postBb,
  postAnte;

  static SituationActionKind fromString(String? raw) {
    switch ((raw ?? '').trim().toUpperCase().replaceAll('-', '_')) {
      case 'FOLD':
        return SituationActionKind.fold;
      case 'CHECK':
        return SituationActionKind.check;
      case 'CALL':
        return SituationActionKind.call;
      case 'BET':
        return SituationActionKind.bet;
      case 'RAISE':
        return SituationActionKind.raise;
      case 'ALL_IN':
        return SituationActionKind.allIn;
      case 'POST_SB':
        return SituationActionKind.postSb;
      case 'POST_BB':
        return SituationActionKind.postBb;
      case 'POST_ANTE':
        return SituationActionKind.postAnte;
      default:
        return SituationActionKind.check;
    }
  }

  String get wire => switch (this) {
    SituationActionKind.fold => 'FOLD',
    SituationActionKind.check => 'CHECK',
    SituationActionKind.call => 'CALL',
    SituationActionKind.bet => 'BET',
    SituationActionKind.raise => 'RAISE',
    SituationActionKind.allIn => 'ALL_IN',
    SituationActionKind.postSb => 'POST_SB',
    SituationActionKind.postBb => 'POST_BB',
    SituationActionKind.postAnte => 'POST_ANTE',
  };

  /// Human-readable label for coach / dock UI (e.g. `ALL-IN`).
  String get displayLabel => switch (this) {
    SituationActionKind.allIn => 'ALL-IN',
    _ => wire,
  };
}

/// Server-authored assessment for a hero action.
enum HeroActionVerdict {
  correct,
  incorrect,
  close;

  static HeroActionVerdict fromString(String raw) {
    return switch (raw.trim().toLowerCase()) {
      'correct' => HeroActionVerdict.correct,
      'incorrect' => HeroActionVerdict.incorrect,
      'close' => HeroActionVerdict.close,
      _ => throw FormatException('Invalid hero action verdict: $raw'),
    };
  }

  String get wire => name;
}

/// Terminal end reasons.
enum TerminalReason {
  fold,
  showdown,
  allInRunout;

  static TerminalReason fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'showdown':
        return TerminalReason.showdown;
      case 'all_in_runout':
        return TerminalReason.allInRunout;
      default:
        return TerminalReason.fold;
    }
  }

  String get wire => switch (this) {
    TerminalReason.fold => 'fold',
    TerminalReason.showdown => 'showdown',
    TerminalReason.allInRunout => 'all_in_runout',
  };
}

/// One seat in the ordered lineup.
@immutable
class SituationSeatLineup {
  /// Creates a lineup seat.
  const SituationSeatLineup({
    required this.seat,
    required this.archetype,
    required this.name,
    required this.startingStack,
  });

  final int seat;
  final String archetype;
  final String name;
  final double startingStack;

  bool get isHero => archetype.toUpperCase() == 'HERO';

  PlayerArchetype get playerArchetype => PlayerArchetype.fromLabel(archetype);

  factory SituationSeatLineup.fromJson(Map<String, dynamic> json) {
    return SituationSeatLineup(
      seat: _asInt(_pick(json, const ['seat']), 0),
      archetype: _pickString(json, const ['archetype']) ?? 'TAG',
      name: _pickString(json, const ['name']) ?? '',
      startingStack: _asDouble(
        _pick(json, const ['startingStack', 'starting_stack']),
        0,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'seat': seat,
    'archetype': archetype,
    'name': name,
    'startingStack': startingStack,
  };
}

/// Fixed runout cards for a street.
@immutable
class StreetRunout {
  /// Creates a runout.
  const StreetRunout({required this.street, required this.cards});

  final Street street;
  final List<CardModel> cards;

  factory StreetRunout.fromJson(Map<String, dynamic> json) {
    return StreetRunout(
      street: _parseStreet(_pickString(json, const ['street'])),
      cards: _parseCards(_pick(json, const ['cards'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'street': street.label.toLowerCase(),
    'cards': cards.map((c) => c.code).toList(),
  };
}

/// Authored private cards for one seat.
@immutable
class SituationHoleCards {
  /// Creates an authored private-card entry.
  const SituationHoleCards({required this.seat, required this.cards});

  final int seat;
  final List<CardModel> cards;

  factory SituationHoleCards.fromJson(Map<String, dynamic> json) {
    return SituationHoleCards(
      seat: _asInt(_pick(json, const ['seat']), 0),
      cards: _parseCards(_pick(json, const ['cards'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'seat': seat,
    'cards': cards.map((card) => card.code).toList(),
  };
}

/// Edge from a hero decision node.
@immutable
class HeroActionEdge {
  /// Creates an edge.
  const HeroActionEdge({
    required this.actionKey,
    required this.kind,
    required this.coaching,
    required this.verdict,
    required this.evDeltaBb,
    required this.optimalActionKey,
    required this.nextNodeId,
    this.amountTo,
    this.sizingBucket,
  });

  final String actionKey;
  final SituationActionKind kind;

  /// Total chips committed on this street after the action ("raise to").
  final double? amountTo;
  final String? sizingBucket;

  /// General coaching for taking this action.
  final String coaching;

  /// Server-authored assessment of this action.
  final HeroActionVerdict verdict;

  /// EV relative to the best action, measured in big blinds.
  final double evDeltaBb;

  /// Key of a correct action in the same hero node.
  final String optimalActionKey;

  final String nextNodeId;

  factory HeroActionEdge.fromJson(Map<String, dynamic> json) {
    return HeroActionEdge(
      actionKey: _requireString(json, const ['actionKey', 'action_key']),
      kind: SituationActionKind.fromString(_pickString(json, const ['kind'])),
      amountTo: _pickDouble(json, const ['amountTo', 'amount_to']),
      sizingBucket: _pickString(json, const ['sizingBucket', 'sizing_bucket']),
      coaching: _requireString(json, const ['coaching']),
      verdict: HeroActionVerdict.fromString(
        _requireString(json, const ['verdict']),
      ),
      evDeltaBb: _requireDouble(json, const ['evDeltaBb', 'ev_delta_bb']),
      optimalActionKey: _requireString(json, const [
        'optimalActionKey',
        'optimal_action_key',
      ]),
      nextNodeId: _requireString(json, const ['nextNodeId', 'next_node_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'actionKey': actionKey,
    'kind': kind.wire,
    if (amountTo != null) 'amountTo': amountTo,
    if (sizingBucket != null) 'sizingBucket': sizingBucket,
    'coaching': coaching,
    'verdict': verdict.wire,
    'evDeltaBb': evDeltaBb,
    'optimalActionKey': optimalActionKey,
    'nextNodeId': nextNodeId,
  };
}

/// Scripted villain (or blind) action between hero nodes.
@immutable
class ScriptedAction {
  /// Creates a scripted action.
  const ScriptedAction({
    required this.seat,
    required this.kind,
    this.amountTo,
    this.label,
  });

  final int seat;
  final SituationActionKind kind;
  final double? amountTo;
  final String? label;

  factory ScriptedAction.fromJson(Map<String, dynamic> json) {
    return ScriptedAction(
      seat: _asInt(_pick(json, const ['seat']), 0),
      kind: SituationActionKind.fromString(_pickString(json, const ['kind'])),
      amountTo: _pickDouble(json, const ['amountTo', 'amount_to']),
      label: _pickString(json, const ['label']),
    );
  }

  Map<String, dynamic> toJson() => {
    'seat': seat,
    'kind': kind.wire,
    if (amountTo != null) 'amountTo': amountTo,
    if (label != null) 'label': label,
  };
}

/// Discriminator for situation graph nodes.
enum SituationNodeType { hero, scripted, terminal }

/// Shared fields for all situation nodes.
@immutable
sealed class SituationNode {
  /// Creates a node base.
  const SituationNode({required this.id, required this.street});

  final String id;
  final Street street;

  SituationNodeType get type;

  factory SituationNode.fromJson(Map<String, dynamic> json) {
    final typeRaw =
        (_pickString(json, const ['type', 'kind']) ?? 'hero').toLowerCase();
    return switch (typeRaw) {
      'scripted' => ScriptedNode.fromJson(json),
      'terminal' => TerminalNode.fromJson(json),
      _ => HeroDecisionNode.fromJson(json),
    };
  }

  Map<String, dynamic> toJson();
}

/// Hero decision node with curated action edges.
@immutable
class HeroDecisionNode extends SituationNode {
  /// Creates a hero node.
  const HeroDecisionNode({
    required super.id,
    required super.street,
    required this.pot,
    required this.stacks,
    required this.streetBets,
    required this.board,
    required this.foldedSeats,
    required this.toAct,
    required this.callAmount,
    required this.minRaiseTo,
    required this.actions,
  });

  final double pot;
  final List<double> stacks;
  final List<double> streetBets;
  final List<CardModel> board;
  final List<int> foldedSeats;
  final int toAct;
  final double callAmount;
  final double minRaiseTo;
  final List<HeroActionEdge> actions;

  @override
  SituationNodeType get type => SituationNodeType.hero;

  factory HeroDecisionNode.fromJson(Map<String, dynamic> json) {
    final actionsRaw = _pick(json, const ['actions']);
    return HeroDecisionNode(
      id: _pickString(json, const ['id']) ?? '',
      street: _parseStreet(_pickString(json, const ['street'])),
      pot: _asDouble(_pick(json, const ['pot']), 0),
      stacks: _parseNumList(_pick(json, const ['stacks'])),
      streetBets: _parseNumList(
        _pick(json, const ['streetBets', 'street_bets']),
      ),
      board: _parseCards(_pick(json, const ['board'])),
      foldedSeats: _requireIntList(json, const ['foldedSeats', 'folded_seats']),
      toAct: _asInt(_pick(json, const ['toAct', 'to_act']), 0),
      callAmount: _asDouble(
        _pick(json, const ['callAmount', 'call_amount']),
        0,
      ),
      minRaiseTo: _asDouble(
        _pick(json, const ['minRaiseTo', 'min_raise_to']),
        0,
      ),
      actions: _parseHeroEdges(actionsRaw),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'hero',
    'id': id,
    'street': street.label.toLowerCase(),
    'pot': pot,
    'stacks': stacks,
    'streetBets': streetBets,
    'board': board.map((c) => c.code).toList(),
    'foldedSeats': foldedSeats,
    'toAct': toAct,
    'callAmount': callAmount,
    'minRaiseTo': minRaiseTo,
    'actions': actions.map((a) => a.toJson()).toList(),
  };

  /// Finds an edge by [actionKey] (case-insensitive).
  HeroActionEdge? edgeForKey(String actionKey) {
    final upper = actionKey.toUpperCase();
    for (final a in actions) {
      if (a.actionKey.toUpperCase() == upper) return a;
    }
    return null;
  }
}

/// Scripted interstitial node.
@immutable
class ScriptedNode extends SituationNode {
  /// Creates a scripted node.
  const ScriptedNode({
    required super.id,
    required super.street,
    required this.pot,
    required this.stacks,
    required this.streetBets,
    required this.board,
    required this.foldedSeats,
    required this.actions,
    required this.nextNodeId,
  });

  final double pot;
  final List<double> stacks;
  final List<double> streetBets;
  final List<CardModel> board;
  final List<int> foldedSeats;
  final List<ScriptedAction> actions;
  final String nextNodeId;

  @override
  SituationNodeType get type => SituationNodeType.scripted;

  factory ScriptedNode.fromJson(Map<String, dynamic> json) {
    return ScriptedNode(
      id: _pickString(json, const ['id']) ?? '',
      street: _parseStreet(_pickString(json, const ['street'])),
      pot: _asDouble(_pick(json, const ['pot']), 0),
      stacks: _parseNumList(_pick(json, const ['stacks'])),
      streetBets: _parseNumList(
        _pick(json, const ['streetBets', 'street_bets']),
      ),
      board: _parseCards(_pick(json, const ['board'])),
      foldedSeats: _requireIntList(json, const ['foldedSeats', 'folded_seats']),
      actions: _parseScriptedActions(_pick(json, const ['actions'])),
      nextNodeId: _pickString(json, const ['nextNodeId', 'next_node_id']) ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'scripted',
    'id': id,
    'street': street.label.toLowerCase(),
    'pot': pot,
    'stacks': stacks,
    'streetBets': streetBets,
    'board': board.map((c) => c.code).toList(),
    'foldedSeats': foldedSeats,
    'actions': actions.map((a) => a.toJson()).toList(),
    'nextNodeId': nextNodeId,
  };
}

/// Terminal leaf node.
@immutable
class TerminalNode extends SituationNode {
  /// Creates a terminal node.
  const TerminalNode({
    required super.id,
    required super.street,
    required this.reason,
    required this.board,
    required this.foldedSeats,
    required this.stacks,
    required this.pot,
    required this.winnerSeats,
    required this.heroNetChips,
    this.summary,
  });

  final TerminalReason reason;
  final List<CardModel> board;
  final List<int> foldedSeats;
  final List<double> stacks;
  final double pot;
  final List<int> winnerSeats;
  final double heroNetChips;
  final String? summary;

  @override
  SituationNodeType get type => SituationNodeType.terminal;

  factory TerminalNode.fromJson(Map<String, dynamic> json) {
    return TerminalNode(
      id: _pickString(json, const ['id']) ?? '',
      street: _parseStreet(_pickString(json, const ['street'])),
      reason: TerminalReason.fromString(_pickString(json, const ['reason'])),
      board: _parseCards(_pick(json, const ['board'])),
      foldedSeats: _requireIntList(json, const ['foldedSeats', 'folded_seats']),
      stacks: _requireNumList(json, const ['stacks']),
      pot: _requireDouble(json, const ['pot']),
      winnerSeats: _requireIntList(json, const ['winnerSeats', 'winner_seats']),
      heroNetChips: _requireDouble(json, const [
        'heroNetChips',
        'hero_net_chips',
      ]),
      summary: _pickString(json, const ['summary']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'terminal',
    'id': id,
    'reason': reason.wire,
    'street': street.label.toLowerCase(),
    'board': board.map((c) => c.code).toList(),
    'foldedSeats': foldedSeats,
    'stacks': stacks,
    'pot': pot,
    'winnerSeats': winnerSeats,
    'heroNetChips': heroNetChips,
    if (summary != null) 'summary': summary,
  };
}

/// Full branching situation payload from `fetchSituation`.
@immutable
class SituationModel {
  /// Creates a situation payload.
  const SituationModel({
    required this.payloadVersion,
    required this.schemaVersion,
    required this.setupKey,
    required this.setupMode,
    required this.seatCount,
    required this.smallBlind,
    required this.bigBlind,
    required this.ante,
    required this.startingStack,
    required this.buttonSeat,
    required this.heroSeat,
    required this.lineup,
    required this.holeCards,
    required this.heroHand,
    required this.runouts,
    required this.rootNodeId,
    required this.nodes,
    this.title,
    this.situationId,
  });

  final int payloadVersion;
  final String schemaVersion;
  final String setupKey;
  final SetupMode setupMode;
  final int seatCount;
  final double smallBlind;
  final double bigBlind;
  final double ante;
  final double startingStack;
  final int buttonSeat;
  final int heroSeat;
  final List<SituationSeatLineup> lineup;
  final List<SituationHoleCards> holeCards;
  final List<CardModel> heroHand;
  final List<StreetRunout> runouts;
  final String rootNodeId;
  final Map<String, SituationNode> nodes;
  final String? title;

  /// Wrapper id from the callable (not inside payload).
  final String? situationId;

  SituationNode? get rootNode => nodes[rootNodeId];

  SituationNode? node(String id) => nodes[id];

  String get name => title ?? 'Situation';

  factory SituationModel.fromJson(
    Map<String, dynamic> json, {
    String? situationId,
  }) {
    final nodesRaw = _asMap(_pick(json, const ['nodes'])) ?? {};
    final nodes = <String, SituationNode>{};
    for (final e in nodesRaw.entries) {
      final map = _asMap(e.value);
      if (map == null) continue;
      final withId = Map<String, dynamic>.from(map);
      withId.putIfAbsent('id', () => e.key);
      final node = SituationNode.fromJson(withId);
      nodes[node.id.isEmpty ? e.key : node.id] = node;
    }

    final lineupRaw = _pick(json, const ['lineup']);
    final lineup = <SituationSeatLineup>[];
    if (lineupRaw is List) {
      for (final item in lineupRaw) {
        final map = _asMap(item);
        if (map != null) lineup.add(SituationSeatLineup.fromJson(map));
      }
    }

    final runoutsRaw = _pick(json, const ['runouts']);
    final runouts = <StreetRunout>[];
    if (runoutsRaw is List) {
      for (final item in runoutsRaw) {
        final map = _asMap(item);
        if (map != null) runouts.add(StreetRunout.fromJson(map));
      }
    }

    final holeCardsRaw = _pick(json, const ['holeCards', 'hole_cards']);
    final holeCards = <SituationHoleCards>[];
    if (holeCardsRaw is List) {
      for (final item in holeCardsRaw) {
        final map = _asMap(item);
        if (map != null) holeCards.add(SituationHoleCards.fromJson(map));
      }
    }

    final hand = _parseCards(_pick(json, const ['heroHand', 'hero_hand']));

    return SituationModel(
      payloadVersion: _asInt(
        _pick(json, const ['payloadVersion', 'payload_version']),
        kSituationPayloadVersion,
      ),
      schemaVersion:
          _pickString(json, const ['schemaVersion', 'schema_version']) ?? '',
      setupKey: _pickString(json, const ['setupKey', 'setup_key']) ?? '',
      setupMode: SetupMode.fromString(
        _pickString(json, const ['setupMode', 'setup_mode']),
      ),
      seatCount: _asInt(
        _pick(json, const ['seatCount', 'seat_count']),
        lineup.isNotEmpty ? lineup.length : 6,
      ),
      smallBlind: _asDouble(
        _pick(json, const ['smallBlind', 'small_blind']),
        1,
      ),
      bigBlind: _asDouble(_pick(json, const ['bigBlind', 'big_blind']), 2),
      ante: _asDouble(_pick(json, const ['ante']), 0),
      startingStack: _asDouble(
        _pick(json, const ['startingStack', 'starting_stack']),
        200,
      ),
      buttonSeat: _asInt(
        _pick(json, const ['buttonSeat', 'button_seat', 'dealerSeat']),
        0,
      ),
      heroSeat: _asInt(_pick(json, const ['heroSeat', 'hero_seat']), 0),
      lineup: lineup,
      holeCards: holeCards,
      heroHand: hand,
      runouts: runouts,
      rootNodeId: _pickString(json, const ['rootNodeId', 'root_node_id']) ?? '',
      nodes: nodes,
      title: _pickString(json, const ['title', 'name']),
      situationId:
          situationId ??
          _pickString(json, const ['situationId', 'situation_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'schemaVersion': schemaVersion,
    'setupKey': setupKey,
    'setupMode': setupMode.wire,
    'seatCount': seatCount,
    'smallBlind': smallBlind,
    'bigBlind': bigBlind,
    'ante': ante,
    'startingStack': startingStack,
    'buttonSeat': buttonSeat,
    'heroSeat': heroSeat,
    'lineup': lineup.map((s) => s.toJson()).toList(),
    'holeCards': holeCards.map((entry) => entry.toJson()).toList(),
    'heroHand': heroHand.map((c) => c.code).toList(),
    'runouts': runouts.map((r) => r.toJson()).toList(),
    'rootNodeId': rootNodeId,
    'nodes': {for (final e in nodes.entries) e.key: e.value.toJson()},
    if (title != null) 'title': title,
  };

  SituationModel copyWith({String? situationId, String? setupKey}) {
    return SituationModel(
      payloadVersion: payloadVersion,
      schemaVersion: schemaVersion,
      setupKey: setupKey ?? this.setupKey,
      setupMode: setupMode,
      seatCount: seatCount,
      smallBlind: smallBlind,
      bigBlind: bigBlind,
      ante: ante,
      startingStack: startingStack,
      buttonSeat: buttonSeat,
      heroSeat: heroSeat,
      lineup: lineup,
      holeCards: holeCards,
      heroHand: heroHand,
      runouts: runouts,
      rootNodeId: rootNodeId,
      nodes: nodes,
      title: title,
      situationId: situationId ?? this.situationId,
    );
  }
}

/// Result of `fetchSituation`.
@immutable
class FetchedSituation {
  /// Creates a fetch result.
  const FetchedSituation({
    required this.situationId,
    required this.setupKey,
    required this.situation,
    this.refillTriggered = false,
  });

  final String situationId;
  final String setupKey;
  final SituationModel situation;
  final bool refillTriggered;

  factory FetchedSituation.fromCallable(Map<String, dynamic> data) {
    final situationId =
        _pickString(data, const ['situationId', 'situation_id']) ?? '';
    final setupKey = _pickString(data, const ['setupKey', 'setup_key']) ?? '';
    final payload = _asMap(_pick(data, const ['payload'])) ?? data;
    final situation = SituationModel.fromJson(
      payload,
      situationId: situationId.isEmpty ? null : situationId,
    );
    return FetchedSituation(
      situationId:
          situationId.isNotEmpty ? situationId : (situation.situationId ?? ''),
      setupKey: setupKey.isNotEmpty ? setupKey : situation.setupKey,
      situation: situation.copyWith(
        situationId: situationId.isNotEmpty ? situationId : null,
        setupKey: setupKey.isNotEmpty ? setupKey : null,
      ),
      refillTriggered: _asBool(
        _pick(data, const ['refillTriggered', 'refill_triggered']),
        false,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// JSON helpers
// -----------------------------------------------------------------------------

dynamic _pick(Map<dynamic, dynamic>? map, List<String> keys) {
  if (map == null) return null;
  for (final key in keys) {
    if (map.containsKey(key)) return map[key];
  }
  return null;
}

String? _pickString(Map<dynamic, dynamic>? map, List<String> keys) {
  final v = _pick(map, keys);
  if (v == null) return null;
  final s = '$v'.trim();
  return s.isEmpty ? null : s;
}

double? _pickDouble(Map<dynamic, dynamic>? map, List<String> keys) {
  final v = _pick(map, keys);
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse('$v');
}

String _requireString(Map<dynamic, dynamic> map, List<String> keys) {
  final value = _pickString(map, keys);
  if (value == null) {
    throw FormatException('Missing required field ${keys.first}');
  }
  return value;
}

double _requireDouble(Map<dynamic, dynamic> map, List<String> keys) {
  final value = _pickDouble(map, keys);
  if (value == null || !value.isFinite) {
    throw FormatException('Invalid required number ${keys.first}');
  }
  return value;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((k, v) => MapEntry('$k', v));
  }
  return null;
}

int _asInt(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

double _asDouble(dynamic value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

bool _asBool(dynamic value, bool fallback) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = '$value'.toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

Street _parseStreet(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'flop':
      return Street.flop;
    case 'turn':
      return Street.turn;
    case 'river':
      return Street.river;
    case 'showdown':
      return Street.showdown;
    default:
      return Street.preflop;
  }
}

List<CardModel> _parseCards(dynamic raw) {
  if (raw is! List) return const [];
  final out = <CardModel>[];
  for (final item in raw) {
    try {
      if (item is String) {
        out.add(CardModel.fromCode(item));
      } else if (item is Map) {
        out.add(CardModel.fromJson(Map<String, dynamic>.from(item)));
      }
    } catch (_) {}
  }
  return out;
}

List<double> _parseNumList(dynamic raw) {
  if (raw is! List) return const [];
  return [for (final item in raw) _asDouble(item, 0)];
}

List<double> _requireNumList(Map<dynamic, dynamic> map, List<String> keys) {
  final raw = _pick(map, keys);
  if (raw is! List) {
    throw FormatException('Missing required field ${keys.first}');
  }
  final values = <double>[];
  for (final item in raw) {
    if (item is! num || !item.isFinite) {
      throw FormatException('Invalid required number in ${keys.first}');
    }
    values.add(item.toDouble());
  }
  return values;
}

List<int> _requireIntList(Map<dynamic, dynamic> map, List<String> keys) {
  final raw = _pick(map, keys);
  if (raw is! List) {
    throw FormatException('Missing required field ${keys.first}');
  }
  final values = <int>[];
  for (final item in raw) {
    if (item is int) {
      values.add(item);
    } else if (item is num && item.isFinite && item == item.roundToDouble()) {
      values.add(item.toInt());
    } else {
      throw FormatException('Invalid required integer in ${keys.first}');
    }
  }
  return values;
}

List<HeroActionEdge> _parseHeroEdges(dynamic raw) {
  if (raw is! List) return const [];
  final out = <HeroActionEdge>[];
  for (final item in raw) {
    final map = _asMap(item);
    if (map != null) out.add(HeroActionEdge.fromJson(map));
  }
  return out;
}

List<ScriptedAction> _parseScriptedActions(dynamic raw) {
  if (raw is! List) return const [];
  final out = <ScriptedAction>[];
  for (final item in raw) {
    final map = _asMap(item);
    if (map != null) out.add(ScriptedAction.fromJson(map));
  }
  return out;
}
