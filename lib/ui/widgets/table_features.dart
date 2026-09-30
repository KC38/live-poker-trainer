/// Which parts of the poker table are drawn, so early lessons stay focused.
library;

import 'package:flutter/widgets.dart';

/// Switches for every optional layer of [FeltTableView].
///
/// Seats, the board, and the hero's cards always draw. Everything else is a
/// concept a lesson can leave out until the course teaches it.
@immutable
class TableFeatures {
  /// Creates a feature set. Every layer is on unless turned off.
  const TableFeatures({
    this.stacks = true,
    this.pot = true,
    this.street = true,
    this.blinds = true,
    this.positions = true,
    this.bets = true,
    this.actions = true,
    this.opponentCards = true,
    this.playerTypes = true,
    this.stats = true,
    this.boardSlots = true,
  });

  /// Stack amount inside each seat box.
  final bool stacks;

  /// Pot pill above the board.
  final bool pot;

  /// Street name in front of the pot (`FLOP · POT $10`).
  final bool street;

  /// `Blinds $1/$2 NLH` under the board.
  final bool blinds;

  /// Dealer, small-blind, and big-blind pucks.
  final bool positions;

  /// Chips a seat has put in on this street.
  final bool bets;

  /// Last-action badges such as RAISE or CALL.
  final bool actions;

  /// Face-down cards over the seats still in the hand.
  final bool opponentCards;

  /// Seat icon colored by player type, and the type tag.
  final bool playerTypes;

  /// VPIP/PFR line in each seat box.
  final bool stats;

  /// Empty outlines where the rest of the board will be dealt.
  final bool boardSlots;

  /// Every layer. Live Training and later lessons.
  static const TableFeatures full = TableFeatures();

  /// Sections 1–3: the table without player-type reads.
  ///
  /// Player types and VPIP/PFR are taught from Section 4, so earlier lessons
  /// draw every seat as a plain player.
  static const TableFeatures fundamentals = TableFeatures(
    playerTypes: false,
    stats: false,
  );

  /// First course section that teaches player types.
  static const int playerTypesSection = 4;

  /// Preset for course section [order] (1-based).
  static TableFeatures forSection(int order) =>
      order < playerTypesSection ? fundamentals : full;

  /// Preset for [lessonId], read from its `lesson-SS-` section prefix.
  ///
  /// An id without that prefix gets [full].
  static TableFeatures forLessonId(String lessonId) {
    const prefix = 'lesson-';
    if (!lessonId.startsWith(prefix)) return full;
    final rest = lessonId.substring(prefix.length);
    final end = rest.indexOf('-');
    final order = int.tryParse(end < 0 ? rest : rest.substring(0, end));
    return order == null ? full : forSection(order);
  }

  /// Copy with the given layers changed.
  TableFeatures copyWith({
    bool? stacks,
    bool? pot,
    bool? street,
    bool? blinds,
    bool? positions,
    bool? bets,
    bool? actions,
    bool? opponentCards,
    bool? playerTypes,
    bool? stats,
    bool? boardSlots,
  }) {
    return TableFeatures(
      stacks: stacks ?? this.stacks,
      pot: pot ?? this.pot,
      street: street ?? this.street,
      blinds: blinds ?? this.blinds,
      positions: positions ?? this.positions,
      bets: bets ?? this.bets,
      actions: actions ?? this.actions,
      opponentCards: opponentCards ?? this.opponentCards,
      playerTypes: playerTypes ?? this.playerTypes,
      stats: stats ?? this.stats,
      boardSlots: boardSlots ?? this.boardSlots,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TableFeatures &&
      other.stacks == stacks &&
      other.pot == pot &&
      other.street == street &&
      other.blinds == blinds &&
      other.positions == positions &&
      other.bets == bets &&
      other.actions == actions &&
      other.opponentCards == opponentCards &&
      other.playerTypes == playerTypes &&
      other.stats == stats &&
      other.boardSlots == boardSlots;

  @override
  int get hashCode => Object.hash(
    stacks,
    pot,
    street,
    blinds,
    positions,
    bets,
    actions,
    opponentCards,
    playerTypes,
    stats,
    boardSlots,
  );
}

/// Hands a [TableFeatures] preset to every table below it.
///
/// The lesson runner wraps each lesson in its section's preset. A table with
/// no scope above it draws [TableFeatures.full].
class TableFeaturesScope extends InheritedWidget {
  /// Creates the scope.
  const TableFeaturesScope({
    super.key,
    required this.features,
    required super.child,
  });

  /// Preset for the tables below.
  final TableFeatures features;

  /// Nearest preset, or [TableFeatures.full].
  static TableFeatures of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<TableFeaturesScope>()
          ?.features ??
      TableFeatures.full;

  @override
  bool updateShouldNotify(TableFeaturesScope oldWidget) =>
      oldWidget.features != features;
}
