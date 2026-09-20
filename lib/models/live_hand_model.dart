/// Client-safe models for server-authoritative live training hands.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/tendency_profile_model.dart';

/// One fixed legal action supplied by the authoritative server.
@immutable
class LiveLegalActionModel {
  /// Creates a fixed live action.
  const LiveLegalActionModel({
    required this.actionId,
    required this.kind,
    required this.bucket,
    required this.label,
    this.amountTo,
  });

  final String actionId;
  final String kind;
  final String bucket;
  final String label;
  final double? amountTo;

  factory LiveLegalActionModel.fromJson(Map<String, dynamic> json) {
    return LiveLegalActionModel(
      actionId: json['actionId'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      bucket: json['bucket'] as String? ?? '',
      label: json['label'] as String? ?? '',
      amountTo: (json['amountTo'] as num?)?.toDouble(),
    );
  }
}

/// One authoritative action replayed on the table.
@immutable
class LiveActionEventModel {
  /// Creates a replay event.
  const LiveActionEventModel({
    required this.sequence,
    required this.seat,
    required this.street,
    required this.actionId,
    required this.kind,
    required this.bucket,
    this.amountTo,
  });

  final int sequence;
  final int seat;
  final String street;
  final String actionId;
  final String kind;
  final String bucket;
  final double? amountTo;

  factory LiveActionEventModel.fromJson(Map<String, dynamic> json) {
    return LiveActionEventModel(
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      seat: (json['seat'] as num?)?.toInt() ?? 0,
      street: json['street'] as String? ?? 'preflop',
      actionId: json['actionId'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      bucket: json['bucket'] as String? ?? '',
      amountTo: (json['amountTo'] as num?)?.toDouble(),
    );
  }
}

/// Qualitative exploit feedback for the selected Hero action.
@immutable
class LiveCoachingAssessment {
  /// Creates one coaching assessment.
  const LiveCoachingAssessment({
    required this.actionId,
    required this.rating,
    required this.confidence,
    required this.summary,
    required this.playerTypeReason,
    required this.sizingNote,
    required this.tendencyKeys,
    this.betterActionId,
    this.reversalRead,
  });

  final String actionId;
  final String rating;
  final String confidence;
  final String summary;
  final String playerTypeReason;
  final String sizingNote;
  final String? betterActionId;
  final String? reversalRead;
  final List<String> tendencyKeys;

  factory LiveCoachingAssessment.fromJson(Map<String, dynamic> json) {
    return LiveCoachingAssessment(
      actionId: json['actionId'] as String? ?? '',
      rating: json['rating'] as String? ?? 'reasonable',
      confidence: json['confidence'] as String? ?? 'low',
      summary: json['summary'] as String? ?? '',
      playerTypeReason: json['playerTypeReason'] as String? ?? '',
      sizingNote: json['sizingNote'] as String? ?? '',
      betterActionId: json['betterActionId'] as String?,
      reversalRead: json['reversalRead'] as String?,
      tendencyKeys: (json['tendencyKeys'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(growable: false),
    );
  }

  /// User-facing review assembled from the structured rubric.
  String get message => polishCoachCopy(
    [
      summary,
      playerTypeReason,
      sizingNote,
      if (reversalRead != null && reversalRead!.isNotEmpty)
        'This changes when: $reversalRead',
    ].where((line) => line.trim().isNotEmpty).join('\n\n'),
  );
}

/// Readable labels for tendency keys the model sometimes prints raw.
const _tendencyLabels = <String, String>{
  'foldToFlopBet': 'flop fold',
  'foldToTurnBet': 'turn fold',
  'foldToRiverBet': 'river fold',
  'bluffRiver': 'river bluff',
  'showdownCall': 'showdown call',
  'sizingTellStrength': 'sizing tell',
  'threeBet': '3-bet',
  'aggression': 'aggression',
  'vpip': 'VPIP',
  'pfr': 'PFR',
};

/// Turns stored coach prose into something a player can read.
///
/// Rubrics are generated once and reused, so this has to repair copy that is
/// already saved: chip amounts gain a `$`, and `51.7 bluffRiver` becomes
/// `51.7% river bluff`. Percentages that are already marked stay as they are.
String polishCoachCopy(String raw) {
  var text = raw;
  for (final entry in _tendencyLabels.entries) {
    final key = RegExp.escape(entry.key);
    text = text.replaceAllMapped(
      RegExp('(\\d+(?:\\.\\d+)?)\\s+$key\\b', caseSensitive: false),
      (match) => '${match[1]}% ${entry.value}',
    );
    text = text.replaceAll(
      RegExp('\\b$key\\b', caseSensitive: false),
      entry.value,
    );
  }
  for (final label in _tendencyLabels.values) {
    final escaped = RegExp.escape(label);
    // Complete number tokens only. "of 76.3%" must not become "of 76%.3%",
    // but "of 57.8." at the end of a sentence still needs the percent.
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)\\s+of\\s+(\\d+(?:\\.\\d+)?)(?!\\d)(?!\\.\\d)(?!\\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]} of ${match[2]}%',
    );
  }
  text = text.replaceAllMapped(
    RegExp(r'(?<![\d$])(\d+\.\d{2})(?!\d)(?!\s*%)'),
    (match) => '\$${match[1]}',
  );
  // Chip amounts before "pot" / "all-in", but not odds ratios like "8-to-1 pot
  // odds" and not the cents of an amount that is already marked.
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$.\-])(\d+(?:\.\d{1,2})?)\s+(all-in)\b',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]} ${match[2]}',
  );
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$.\-])(\d+(?:\.\d{1,2})?)\s+(pot)\b(?!\s+odds)',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]} ${match[2]}',
  );
  text = text.replaceAllMapped(
    RegExp(
      r'\b(remaining|final|calling|call|bet|raise|stack|pot of)\s+(\d+)\b(?!\s*%)',
      caseSensitive: false,
    ),
    (match) => '${match[1]} \$${match[2]}',
  );
  return text;
}

/// Current server-projected hand state.
@immutable
class LiveHandViewModel {
  /// Creates a projected hand view.
  const LiveHandViewModel({
    required this.sessionId,
    required this.handId,
    required this.setupKey,
    required this.decisionId,
    required this.stateVersion,
    required this.smallBlind,
    required this.bigBlind,
    required this.street,
    required this.board,
    required this.pot,
    required this.buttonSeat,
    required this.heroSeat,
    required this.actorSeat,
    required this.status,
    required this.terminalReason,
    required this.seats,
    required this.legalActions,
    required this.winnerSeats,
    required this.pots,
  });

  final String sessionId;
  final String handId;
  final String setupKey;
  final String decisionId;
  final int stateVersion;
  final double smallBlind;
  final double bigBlind;
  final Street street;
  final List<CardModel> board;
  final double pot;
  final int buttonSeat;
  final int heroSeat;
  final int? actorSeat;
  final String status;
  final String? terminalReason;
  final List<LiveSeatViewModel> seats;
  final List<LiveLegalActionModel> legalActions;
  final List<int> winnerSeats;
  final List<LivePotViewModel> pots;

  List<double> get sidePots =>
      pots.map((pot) => pot.amount).toList(growable: false);

  bool get handOver => status != 'playing';

  factory LiveHandViewModel.fromJson(Map<String, dynamic> json) {
    final streetName = json['street'] as String? ?? 'preflop';
    return LiveHandViewModel(
      sessionId: json['sessionId'] as String? ?? '',
      handId: json['handId'] as String? ?? '',
      setupKey: json['setupKey'] as String? ?? '',
      decisionId: json['decisionId'] as String? ?? '',
      stateVersion: (json['stateVersion'] as num?)?.toInt() ?? 0,
      smallBlind: (json['smallBlind'] as num?)?.toDouble() ?? 1,
      bigBlind: (json['bigBlind'] as num?)?.toDouble() ?? 2,
      street: Street.values.firstWhere(
        (value) => value.name == streetName,
        orElse: () => Street.preflop,
      ),
      board: (json['board'] as List<dynamic>? ?? const [])
          .map((value) => CardModel.fromCode(value.toString()))
          .toList(growable: false),
      pot: (json['pot'] as num?)?.toDouble() ?? 0,
      buttonSeat: (json['buttonSeat'] as num?)?.toInt() ?? 0,
      heroSeat: (json['heroSeat'] as num?)?.toInt() ?? 0,
      actorSeat: (json['actorSeat'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'playing',
      terminalReason: json['terminalReason'] as String?,
      seats: _maps(
        json['seats'],
      ).map(LiveSeatViewModel.fromJson).toList(growable: false),
      legalActions: _maps(
        json['legalActions'],
      ).map(LiveLegalActionModel.fromJson).toList(growable: false),
      winnerSeats: (json['winnerSeats'] as List<dynamic>? ?? const [])
          .map((value) => (value as num).toInt())
          .toList(growable: false),
      pots: _maps(
        json['pots'],
      ).map(LivePotViewModel.fromJson).toList(growable: false),
    );
  }

  /// Converts the authoritative projection into the existing felt model.
  GameState toGameState({required int handCount}) {
    final players = seats
        .map(
          (seat) => PlayerModel(
            id: seat.seat,
            name: seat.name,
            archetype: PlayerArchetype.fromLabel(seat.archetype),
            stack: seat.stack,
            isHero: seat.seat == heroSeat,
            currentBet: seat.streetBet,
            folded: seat.folded,
            allIn: seat.allIn,
            holeCards: seat.holeCards,
            lastActionLabel: seat.lastAction,
            tendency: seat.tendency,
          ),
        )
        .toList(growable: false);
    final streetBets = players.fold<double>(
      0,
      (total, player) => total + player.currentBet,
    );
    final isHeadsUp = players.length == 2;
    final sb = isHeadsUp ? buttonSeat : (buttonSeat + 1) % players.length;
    final bb = (sb + 1) % players.length;
    final highest = players.fold<double>(
      0,
      (value, player) => player.currentBet > value ? player.currentBet : value,
    );
    final winnerPayouts = <int, double>{};
    for (final pot in pots) {
      final shares = Money.splitPot(pot.amount, pot.winnerSeats);
      for (final entry in shares.entries) {
        winnerPayouts[entry.key] = Money.round(
          (winnerPayouts[entry.key] ?? 0) + entry.value,
        );
      }
    }
    return GameState(
      players: players,
      mode: GameMode.training,
      community: board,
      mainPot: handOver ? 0 : (pot - streetBets).clamp(0, double.infinity),
      awardedPot: handOver ? pot : 0,
      street: street,
      dealerIndex: buttonSeat,
      sbIndex: sb,
      bbIndex: bb,
      activePlayerIndex: actorSeat ?? heroSeat,
      highestBet: highest,
      minRaise: bigBlind,
      smallBlind: smallBlind,
      bigBlind: bigBlind,
      handCount: handCount,
      isHandOver: handOver,
      waitingForHero:
          !handOver && actorSeat == heroSeat && legalActions.isNotEmpty,
      resultMessage:
          status == 'hero_folded'
              ? 'Hero folded'
              : handOver
              ? terminalReason == 'showdown'
                  ? 'Showdown'
                  : 'Hand won by fold'
              : null,
      winnerIds: winnerSeats,
      sidePots: sidePots,
      winnerPayouts: winnerPayouts,
      splitPotAward: pots.any((pot) => pot.winnerSeats.length > 1),
    );
  }
}

/// One authoritative main/side-pot result.
@immutable
class LivePotViewModel {
  const LivePotViewModel({
    required this.amount,
    required this.eligibleSeats,
    required this.winnerSeats,
  });

  final double amount;
  final List<int> eligibleSeats;
  final List<int> winnerSeats;

  factory LivePotViewModel.fromJson(Map<String, dynamic> json) {
    List<int> seats(String key) => (json[key] as List<dynamic>? ?? const [])
        .map((value) => (value as num).toInt())
        .toList(growable: false);
    return LivePotViewModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      eligibleSeats: seats('eligibleSeats'),
      winnerSeats: seats('winnerSeats'),
    );
  }
}

/// One client-visible seat.
@immutable
class LiveSeatViewModel {
  const LiveSeatViewModel({
    required this.seat,
    required this.name,
    required this.archetype,
    required this.stack,
    required this.streetBet,
    required this.folded,
    required this.allIn,
    required this.holeCards,
    this.lastAction,
    this.tendency,
  });

  final int seat;
  final String name;
  final String archetype;
  final double stack;
  final double streetBet;
  final bool folded;
  final bool allIn;
  final String? lastAction;
  final List<CardModel> holeCards;
  final TendencyProfileModel? tendency;

  factory LiveSeatViewModel.fromJson(Map<String, dynamic> json) {
    final tendencyRaw = json['tendency'];
    return LiveSeatViewModel(
      seat: (json['seat'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      archetype: json['archetype'] as String? ?? 'TAG',
      stack: (json['stack'] as num?)?.toDouble() ?? 0,
      streetBet: (json['streetBet'] as num?)?.toDouble() ?? 0,
      folded: json['folded'] as bool? ?? false,
      allIn: json['allIn'] as bool? ?? false,
      lastAction: json['lastAction'] as String?,
      holeCards: (json['holeCards'] as List<dynamic>? ?? const [])
          .map((value) => CardModel.fromCode(value.toString()))
          .toList(growable: false),
      tendency:
          tendencyRaw is Map
              ? TendencyProfileModel.fromJson(
                tendencyRaw.map((key, value) => MapEntry('$key', value)),
              )
              : null,
    );
  }
}

/// Response from start/resume.
@immutable
class LiveHandStartResult {
  const LiveHandStartResult({required this.view, required this.events});

  final LiveHandViewModel view;
  final List<LiveActionEventModel> events;

  factory LiveHandStartResult.fromJson(Map<String, dynamic> json) {
    return LiveHandStartResult(
      view: LiveHandViewModel.fromJson(_map(json['view'])),
      events: _maps(
        json['events'],
      ).map(LiveActionEventModel.fromJson).toList(growable: false),
    );
  }
}

/// Response from one Hero action.
@immutable
class LiveActionResult {
  const LiveActionResult({
    required this.view,
    required this.events,
    required this.coaching,
    required this.replayed,
  });

  final LiveHandViewModel view;
  final List<LiveActionEventModel> events;
  final LiveCoachingAssessment coaching;
  final bool replayed;

  factory LiveActionResult.fromJson(Map<String, dynamic> json) {
    return LiveActionResult(
      view: LiveHandViewModel.fromJson(_map(json['view'])),
      events: _maps(
        json['events'],
      ).map(LiveActionEventModel.fromJson).toList(growable: false),
      coaching: LiveCoachingAssessment.fromJson(_map(json['coaching'])),
      replayed: json['replayed'] as bool? ?? false,
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _maps(dynamic value) {
  if (value is! List) return const [];
  return value.map(_map).toList(growable: false);
}
