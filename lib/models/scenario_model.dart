/// AI-generated practice scenario payload.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Optimal exploit action labels from Gemini scenarios.
enum ExploitAction {
  fold,
  call,
  raise,
  check;

  static ExploitAction fromString(String raw) {
    return switch (raw.trim().toUpperCase()) {
      'FOLD' => ExploitAction.fold,
      'CALL' => ExploitAction.call,
      'RAISE' || 'BET' => ExploitAction.raise,
      'CHECK' => ExploitAction.check,
      _ => ExploitAction.call,
    };
  }

  String get label => name.toUpperCase();
}

/// Structured tough-spot scenario used in Practice mode.
@immutable
class ScenarioModel {
  /// Creates a scenario model.
  const ScenarioModel({
    this.id,
    required this.contentHash,
    required this.tableSize,
    required this.heroPosition,
    required this.heroHand,
    required this.boardCards,
    required this.potSize,
    required this.villainSeat,
    required this.villainArchetype,
    required this.previousActionNarrative,
    required this.villainAction,
    required this.callAmount,
    required this.minRaise,
    required this.maxRaise,
    required this.optimalExploitAction,
    required this.optimalSizingBb,
    required this.theoreticalEvExplanation,
    required this.exploitReasoning,
    this.name,
    this.street = 'FLOP',
    this.rawJson = const {},
  });

  final int? id;
  final String contentHash;
  final int tableSize;
  final String heroPosition;
  final List<CardModel> heroHand;
  final List<CardModel> boardCards;
  final double potSize;
  final int villainSeat;
  final PlayerArchetype villainArchetype;
  final String previousActionNarrative;
  final String villainAction;
  final double callAmount;
  final double minRaise;
  final double maxRaise;
  final ExploitAction optimalExploitAction;
  final double optimalSizingBb;
  final String theoreticalEvExplanation;
  final String exploitReasoning;
  final String? name;
  final String street;
  final Map<String, dynamic> rawJson;

  factory ScenarioModel.fromGeminiJson(Map<String, dynamic> json) {
    final heroHand = _parseCards(json['hero_hand']);
    final board = _parseCards(json['board_cards']);
    final normalized = Map<String, dynamic>.from(json);
    final hash = hashContent(normalized);
    return ScenarioModel(
      contentHash: hash,
      tableSize: _asInt(json['table_size'], 6),
      heroPosition: '${json['hero_position'] ?? 'BTN'}',
      heroHand: heroHand,
      boardCards: board,
      potSize: _asDouble(json['pot_size'], 20),
      villainSeat: _asInt(json['villain_seat'], 1),
      villainArchetype: PlayerArchetype.fromLabel(
        '${json['villain_archetype'] ?? 'TAG'}',
      ),
      previousActionNarrative: '${json['previous_action_narrative'] ?? ''}',
      villainAction: '${json['villain_action'] ?? ''}',
      callAmount: _asDouble(json['call_amount'], 0),
      minRaise: _asDouble(json['min_raise'], 2),
      maxRaise: _asDouble(json['max_raise'], 200),
      optimalExploitAction: ExploitAction.fromString(
        '${json['optimal_exploit_action'] ?? 'CALL'}',
      ),
      optimalSizingBb: _asDouble(json['optimal_sizing_bb'], 0),
      theoreticalEvExplanation: '${json['theoretical_ev_explanation'] ?? ''}',
      exploitReasoning: '${json['exploit_reasoning'] ?? ''}',
      name: json['name']?.toString(),
      street: _inferStreet(board),
      rawJson: normalized,
    );
  }

  static String hashContent(Map<String, dynamic> json) {
    final encoded = jsonEncode(_sorted(json));
    return sha256.convert(utf8.encode(encoded)).toString();
  }

  static dynamic _sorted(dynamic value) {
    if (value is Map) {
      final keys = value.keys.map((k) => '$k').toList()..sort();
      return {for (final k in keys) k: _sorted(value[k])};
    }
    if (value is List) {
      return value.map(_sorted).toList();
    }
    return value;
  }

  static List<CardModel> _parseCards(dynamic raw) {
    if (raw == null) return [];
    if (raw is String) {
      return raw
          .split(RegExp(r'[\s,]+'))
          .where((s) => s.isNotEmpty)
          .map(CardModel.fromCode)
          .toList();
    }
    if (raw is List) {
      return raw.map((item) {
        if (item is String) return CardModel.fromCode(item);
        if (item is Map<String, dynamic>) return CardModel.fromJson(item);
        if (item is Map) {
          return CardModel.fromJson(Map<String, dynamic>.from(item));
        }
        return CardModel.fromCode('$item');
      }).toList();
    }
    return [];
  }

  static String _inferStreet(List<CardModel> board) {
    return switch (board.length) {
      0 => 'PREFLOP',
      3 => 'FLOP',
      4 => 'TURN',
      _ => 'RIVER',
    };
  }

  static int _asInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? fallback;
  }

  static double _asDouble(dynamic v, double fallback) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? fallback;
  }

  Map<String, dynamic> toJson() => rawJson.isNotEmpty
      ? rawJson
      : {
          'table_size': tableSize,
          'hero_position': heroPosition,
          'hero_hand': heroHand.map((c) => c.code).toList(),
          'board_cards': boardCards.map((c) => c.code).toList(),
          'pot_size': potSize,
          'villain_seat': villainSeat,
          'villain_archetype': villainArchetype.label,
          'previous_action_narrative': previousActionNarrative,
          'villain_action': villainAction,
          'call_amount': callAmount,
          'min_raise': minRaise,
          'max_raise': maxRaise,
          'optimal_exploit_action': optimalExploitAction.label,
          'optimal_sizing_bb': optimalSizingBb,
          'theoretical_ev_explanation': theoreticalEvExplanation,
          'exploit_reasoning': exploitReasoning,
          'name': name,
          'street': street,
        };

  ScenarioModel copyWith({int? id}) => ScenarioModel(
        id: id ?? this.id,
        contentHash: contentHash,
        tableSize: tableSize,
        heroPosition: heroPosition,
        heroHand: heroHand,
        boardCards: boardCards,
        potSize: potSize,
        villainSeat: villainSeat,
        villainArchetype: villainArchetype,
        previousActionNarrative: previousActionNarrative,
        villainAction: villainAction,
        callAmount: callAmount,
        minRaise: minRaise,
        maxRaise: maxRaise,
        optimalExploitAction: optimalExploitAction,
        optimalSizingBb: optimalSizingBb,
        theoreticalEvExplanation: theoreticalEvExplanation,
        exploitReasoning: exploitReasoning,
        name: name,
        street: street,
        rawJson: rawJson,
      );
}
