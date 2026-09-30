/// Which parts of the poker table are drawn, so early lessons stay focused.
library;

import 'package:flutter/widgets.dart';

/// Switches for every optional layer of [FeltTableView].
///
/// Seats, the board, and the hero's cards always draw. Everything else is a
/// concept a lesson leaves out until the course teaches it.
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

  /// Every layer. Live Training and lessons past the last switch-on point.
  static const TableFeatures full = TableFeatures();

  /// Lesson that first teaches the button, the blinds, and the pot they
  /// start. Pucks, the blinds line, posted chips, and the pot switch on here.
  static const LessonPosition blindsLesson = (section: 1, unit: 1, lesson: 3);

  /// Lesson that first teaches fold, check, and call. Action badges start.
  static const LessonPosition actionsLesson = (section: 1, unit: 3, lesson: 1);

  /// Lesson that first needs a stack size (all-in). Stack amounts start.
  static const LessonPosition stacksLesson = (section: 1, unit: 3, lesson: 2);

  /// Lesson that names the streets. The street joins the pot pill.
  static const LessonPosition streetLesson = (section: 1, unit: 4, lesson: 1);

  /// Lesson that first reads player types. Types and VPIP/PFR start.
  static const LessonPosition playerTypesLesson = (
    section: 4,
    unit: 6,
    lesson: 1,
  );

  /// Layers a learner has been taught by [at].
  ///
  /// Each layer switches on at the lesson that teaches it and stays on for
  /// the rest of the course. Cards, seats, opponents' face-down cards, and
  /// the board slots are on from the first lesson.
  static TableFeatures forLesson(LessonPosition at) {
    bool from(LessonPosition start) => compareLessons(at, start) >= 0;
    final blinds = from(blindsLesson);
    final types = from(playerTypesLesson);
    return TableFeatures(
      pot: blinds,
      blinds: blinds,
      positions: blinds,
      bets: blinds,
      actions: from(actionsLesson),
      stacks: from(stacksLesson),
      street: from(streetLesson),
      playerTypes: types,
      stats: types,
    );
  }

  /// Layers for [lessonId] (`lesson-SS-UU-LL…`). An id that does not parse
  /// gets [full].
  static TableFeatures forLessonId(String lessonId) {
    final at = parseLessonPosition(lessonId);
    return at == null ? full : forLesson(at);
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

/// A lesson's place in the course, read from `lesson-SS-UU-LL`.
typedef LessonPosition = ({int section, int unit, int lesson});

/// Negative when [a] comes before [b] in the course.
int compareLessons(LessonPosition a, LessonPosition b) {
  if (a.section != b.section) return a.section - b.section;
  if (a.unit != b.unit) return a.unit - b.unit;
  return a.lesson - b.lesson;
}

/// Position of `lesson-SS-UU-LL…`, or null for any other id.
LessonPosition? parseLessonPosition(String lessonId) {
  const prefix = 'lesson-';
  if (!lessonId.startsWith(prefix)) return null;
  final parts = lessonId.substring(prefix.length).split('-');
  if (parts.length < 3) return null;
  final section = int.tryParse(parts[0]);
  final unit = int.tryParse(parts[1]);
  final lesson = int.tryParse(parts[2]);
  if (section == null || unit == null || lesson == null) return null;
  return (section: section, unit: unit, lesson: lesson);
}

/// Hands a [TableFeatures] preset to every table below it.
///
/// The lesson runner wraps each lesson in [TableFeatures.forLessonId]. A
/// table with no scope above it draws [TableFeatures.full].
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
