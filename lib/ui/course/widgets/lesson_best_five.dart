/// Best-five / kicker teaching visuals and tap-five-of-seven mapping.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_soft_pulse_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';

/// Features for Best five table demos: seats, cards, board, no blinds.
TableFeatures get lessonBestFiveTableFeatures => const TableFeatures(
  stacks: false,
  pot: false,
  street: false,
  blinds: false,
  positions: false,
  bets: false,
  actions: false,
  opponentCards: false,
  playerTypes: false,
  stats: false,
  boardSlots: false,
);

/// Hole + board codes for a best-five spot, plus choice → five-card sets.
class BestFiveSpot {
  /// Creates a spot.
  const BestFiveSpot({
    required this.heroCodes,
    required this.boardCodes,
    required this.choiceSets,
    this.hint = 'Tap exactly five cards that play.',
  });

  final List<String> heroCodes;
  final List<String> boardCodes;

  /// Choice id → five card codes (order-insensitive).
  final Map<String, List<String>> choiceSets;
  final String hint;

  List<String> get allCodes => [...heroCodes, ...boardCodes];

  /// Copy with remapped codes and choice sets.
  BestFiveSpot copyWithCodes({
    List<String>? heroCodes,
    List<String>? boardCodes,
    Map<String, List<String>>? choiceSets,
  }) {
    return BestFiveSpot(
      heroCodes: heroCodes ?? this.heroCodes,
      boardCodes: boardCodes ?? this.boardCodes,
      choiceSets: choiceSets ?? this.choiceSets,
      hint: hint,
    );
  }
}

/// Resolves a best-five tap spot for known activities.
BestFiveSpot? resolveBestFiveSpot(CourseActivity activity) {
  switch (activity.id) {
    case 'act-01-02-02-guided-seven':
      return const BestFiveSpot(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', '7c', '2d', '9h', '3s'],
        choiceSets: {
          'best-pair-k': ['Ah', 'As', 'Kd', '9h', '7c'],
          'weak-kickers': ['Ah', 'As', '9h', '7c', '3s'],
          'ignore-ace': ['Kd', '9h', '7c', '3s', '2d'],
        },
        hint: 'Tap the five cards that make your best hand.',
      );
    case 'act-01-02-02-checkpoint-build':
      return const BestFiveSpot(
        heroCodes: ['8h', '8d'],
        boardCodes: ['8c', 'Kd', 'Ks', '2h', '2c'],
        choiceSets: {
          'fh-eights': ['8h', '8d', '8c', 'Kd', 'Ks'],
          'two-pair-only': ['8h', '8d', 'Kd', 'Ks', '2h'],
          'fh-deuces': ['8h', '8d', '8c', '2h', '2c'],
        },
        hint: 'Tap the five cards for your strongest hand.',
      );
  }
  return null;
}

/// Authored best-five spot with structure-preserving isomorphic cards.
BestFiveSpot? dealtBestFiveSpot(
  CourseActivity activity, {
  int generation = 0,
  Random? random,
}) {
  final spot = resolveBestFiveSpot(activity);
  if (spot == null) return null;
  if (!lessonSuitRemapEnabled) return spot;
  final rng = resolveLessonDealRandom(
    activityId: activity.id,
    generation: generation,
    random: random,
  );
  final template = [spot.heroCodes, spot.boardCodes];
  final remapped = isomorphicLessonCardGroups(
    template,
    rng,
    coordinated: true,
  );
  final choiceSets = <String, List<String>>{
    for (final entry in spot.choiceSets.entries)
      entry.key: structurePreserveCodesLike(
        codes: entry.value,
        templateGroups: template,
        mappedGroups: remapped,
      ),
  };
  return spot.copyWithCodes(
    heroCodes: remapped[0],
    boardCodes: remapped[1],
    choiceSets: choiceSets,
  );
}

/// Maps a five-card selection onto an authored choice id.
String? mapBestFiveSelectionToChoiceId({
  required Set<String> selected,
  required BestFiveSpot spot,
  required List<CourseChoice> choices,
}) {
  if (selected.length != 5) return null;
  final ids = {for (final c in choices) c.id};
  final normalized = selected.map((c) => c.toLowerCase()).toSet();
  for (final entry in spot.choiceSets.entries) {
    if (!ids.contains(entry.key)) continue;
    final target = entry.value.map((c) => c.toLowerCase()).toSet();
    if (target.length == 5 && target.containsAll(normalized)) {
      return entry.key;
    }
  }
  return null;
}

/// Whether the tap set is ready to Check (exactly five cards, mapped).
bool bestFiveSelectionIsReady({
  required Set<String> selected,
  required BestFiveSpot spot,
  required List<CourseChoice> choices,
}) {
  return mapBestFiveSelectionToChoiceId(
        selected: selected,
        spot: spot,
        choices: choices,
      ) !=
      null;
}

/// Dealt layout for the explain / demo best-five seven-card teach.
@immutable
class BestFiveExplainDeal {
  /// Creates a dealt explain layout.
  const BestFiveExplainDeal({
    required this.hero,
    required this.board,
    required this.playing,
    required this.playOrder,
  });

  final List<String> hero;
  final List<String> board;
  final Set<String> playing;
  final List<String> playOrder;
}

/// Structure-preserving deal of the Ah/Kd + As72 9h 3s best-five teach.
BestFiveExplainDeal dealBestFiveExplainLayout({
  String activityId = 'act-01-02-02-explain-five',
  int generation = 0,
  Random? random,
}) {
  const templateHero = ['Ah', 'Kd'];
  const templateBoard = ['As', '7c', '2d', '9h', '3s'];
  const templatePlaying = ['Ah', 'As', 'Kd', '9h', '7c'];
  const templatePlayOrder = ['Ah', 'Kd', 'As', '7c', '9h'];
  if (!lessonSuitRemapEnabled) {
    return const BestFiveExplainDeal(
      hero: templateHero,
      board: templateBoard,
      playing: {...templatePlaying},
      playOrder: templatePlayOrder,
    );
  }
  final rng = resolveLessonDealRandom(
    activityId: activityId,
    generation: generation,
    random: random,
  );
  final template = [templateHero, templateBoard];
  final remapped = isomorphicLessonCardGroups(
    template,
    rng,
    coordinated: true,
  );
  final playing = structurePreserveCodesLike(
    codes: templatePlaying,
    templateGroups: template,
    mappedGroups: remapped,
  );
  final playOrder = structurePreserveCodesLike(
    codes: templatePlayOrder,
    templateGroups: template,
    mappedGroups: remapped,
  );
  return BestFiveExplainDeal(
    hero: remapped[0],
    board: remapped[1],
    playing: playing.toSet(),
    playOrder: playOrder,
  );
}

/// Full table: tap each playing card on hero holes + board.
class LessonBestFiveExplainTable extends StatefulWidget {
  /// Creates the explain stage.
  const LessonBestFiveExplainTable({
    super.key,
    required this.onAllPlayingTapped,
    this.enabled = true,
    this.showGuidance = true,
    this.generation = 0,
  });

  /// Every playing card has been tapped.
  final VoidCallback? onAllPlayingTapped;

  final bool enabled;
  final bool showGuidance;
  final int generation;

  @override
  State<LessonBestFiveExplainTable> createState() =>
      _LessonBestFiveExplainTableState();
}

class _LessonBestFiveExplainTableState
    extends State<LessonBestFiveExplainTable> {
  final Set<String> _tapped = <String>{};
  late final BestFiveExplainDeal _deal;

  @override
  void initState() {
    super.initState();
    _deal = dealBestFiveExplainLayout(generation: widget.generation);
  }

  String? get _nextCode {
    for (final code in _deal.playOrder) {
      if (!_tapped.contains(code)) return code;
    }
    return null;
  }

  void _tapCode(String code) {
    if (!widget.enabled || widget.onAllPlayingTapped == null) return;
    if (!_deal.playing.contains(code)) return;
    if (_tapped.contains(code)) return;
    final bool wasNext = _nextCode == code;
    setState(() => _tapped.add(code));
    if (wasNext) {
      consumeLessonSequentialSoftPulse(context);
    }
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: _deal.playing.length - _tapped.length,
    );
    if (_tapped.containsAll(_deal.playing)) {
      widget.onAllPlayingTapped!();
    }
  }

  void _tapHero(int index) {
    if (index < 0 || index >= _deal.hero.length) return;
    _tapCode(_deal.hero[index]);
  }

  void _tapBoard(int index) {
    if (index < 0 || index >= _deal.board.length) return;
    _tapCode(_deal.board[index]);
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextCode;
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: next == null ? 0 : 1,
    );
    final selectedHero = <int>{
      for (var i = 0; i < _deal.hero.length; i++)
        if (_tapped.contains(_deal.hero[i])) i,
    };
    final selectedBoard = <int>{
      for (var i = 0; i < _deal.board.length; i++)
        if (_tapped.contains(_deal.board[i])) i,
    };
    final dimmedHero = <int>{
      for (var i = 0; i < _deal.hero.length; i++)
        if (!_deal.playing.contains(_deal.hero[i])) i,
    };
    final dimmedBoard = <int>{
      for (var i = 0; i < _deal.board.length; i++)
        if (!_deal.playing.contains(_deal.board[i])) i,
    };
    final highlightHero = <int>{};
    final highlightBoard = <int>{};
    if (widget.showGuidance && widget.enabled && next != null) {
      // Ring every remaining hole that plays — individually — so Hint
      // never wraps the You name box as one player-area cue.
      for (var i = 0; i < _deal.hero.length; i++) {
        if (_deal.playing.contains(_deal.hero[i]) &&
            !_tapped.contains(_deal.hero[i])) {
          highlightHero.add(i);
        }
      }
      if (highlightHero.isEmpty) {
        final boardIdx = _deal.board.indexOf(next);
        if (boardIdx >= 0) highlightBoard.add(boardIdx);
      }
    }
    return LessonTableStage(
      key: const ValueKey<String>('best-five-table'),
      heroCodes: _deal.hero,
      boardCodes: _deal.board,
      villainCount: 2,
      heroFaceUp: true,
      enabled: widget.enabled && widget.onAllPlayingTapped != null,
      features: lessonBestFiveTableFeatures,
      selectedHeroIndexes: selectedHero,
      selectedBoardIndexes: selectedBoard,
      highlightHeroIndexes: highlightHero,
      highlightBoardIndexes: highlightBoard,
      dimmedHeroIndexes: dimmedHero,
      dimmedBoardIndexes: dimmedBoard,
      onHeroCardTap: _tapHero,
      onBoardCardTap: _tapBoard,
    );
  }
}

/// Full table: tap five of seven cards to assemble the best hand.
class LessonBestFivePickerTable extends StatefulWidget {
  /// Creates the picker stage.
  const LessonBestFivePickerTable({
    super.key,
    required this.activity,
    required this.controller,
    required this.spot,
    required this.locked,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final BestFiveSpot spot;
  final bool locked;

  @override
  State<LessonBestFivePickerTable> createState() =>
      _LessonBestFivePickerTableState();
}

class _LessonBestFivePickerTableState extends State<LessonBestFivePickerTable> {
  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncFromController);
    _hydrateFromChoice(widget.controller.draft.choiceId);
  }

  @override
  void didUpdateWidget(covariant LessonBestFivePickerTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncFromController);
      widget.controller.addListener(_syncFromController);
      _hydrateFromChoice(widget.controller.draft.choiceId);
      return;
    }
    if (oldWidget.activity.id != widget.activity.id) {
      _hydrateFromChoice(widget.controller.draft.choiceId);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    super.dispose();
  }

  void _syncFromController() {
    final choiceId = widget.controller.draft.choiceId;
    if (choiceId == null) {
      final mapped = mapBestFiveSelectionToChoiceId(
        selected: _selected,
        spot: widget.spot,
        choices: widget.activity.choices,
      );
      if (mapped != null && _selected.isNotEmpty && !widget.locked) {
        setState(_selected.clear);
      }
      return;
    }
    final fromChoice = _codesForChoice(choiceId);
    if (fromChoice.isNotEmpty && !_setEquals(fromChoice, _selected)) {
      final mapped = mapBestFiveSelectionToChoiceId(
        selected: _selected,
        spot: widget.spot,
        choices: widget.activity.choices,
      );
      if (mapped != choiceId) {
        setState(() {
          _selected
            ..clear()
            ..addAll(fromChoice);
        });
      }
    }
  }

  void _hydrateFromChoice(String? choiceId) {
    _selected
      ..clear()
      ..addAll(_codesForChoice(choiceId));
  }

  Set<String> _codesForChoice(String? choiceId) {
    if (choiceId == null) return {};
    final codes = widget.spot.choiceSets[choiceId];
    if (codes == null) return {};
    return codes.toSet();
  }

  void _toggle(String code) {
    if (widget.locked) return;
    setState(() {
      if (_selected.contains(code)) {
        _selected.remove(code);
      } else if (_selected.length < 5) {
        _selected.add(code);
      }
    });
    final mapped = mapBestFiveSelectionToChoiceId(
      selected: _selected,
      spot: widget.spot,
      choices: widget.activity.choices,
    );
    if (mapped != null) {
      widget.controller.selectChoice(mapped, autoSubmit: true);
    } else if (widget.controller.draft.choiceId != null) {
      widget.controller.undoDraft();
    }
  }

  void _tapHero(int index) {
    if (index < 0 || index >= widget.spot.heroCodes.length) return;
    _toggle(widget.spot.heroCodes[index]);
  }

  void _tapBoard(int index) {
    if (index < 0 || index >= widget.spot.boardCodes.length) return;
    _toggle(widget.spot.boardCodes[index]);
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    for (final x in a) {
      if (!b.contains(x)) return false;
    }
    return true;
  }

  String _statusLine() {
    if (widget.controller.lastResult != null) return '';
    if (widget.controller.submitting) return 'Checking…';
    if (_selected.length == 5) {
      return mapBestFiveSelectionToChoiceId(
                selected: _selected,
                spot: widget.spot,
                choices: widget.activity.choices,
              ) !=
              null
          ? 'Checking…'
          : 'Five tapped — try a stronger five.';
    }
    return '${_selected.length}/5 selected';
  }

  Set<String> _coachCodes() {
    final result = widget.controller.lastResult;
    if (result == null) return {};
    final id = result.accepted
        ? (result.betterChoiceId ?? widget.controller.draft.choiceId)
        : result.betterChoiceId;
    if (id == null) return {};
    return widget.spot.choiceSets[id]?.toSet() ?? {};
  }

  Set<int> _indexesIn(List<String> source, Set<String> codes) {
    return {
      for (var i = 0; i < source.length; i++)
        if (codes.contains(source[i])) i,
    };
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    final selectedHero = <int>{
      for (var i = 0; i < spot.heroCodes.length; i++)
        if (_selected.contains(spot.heroCodes[i])) i,
    };
    final selectedBoard = <int>{
      for (var i = 0; i < spot.boardCodes.length; i++)
        if (_selected.contains(spot.boardCodes[i])) i,
    };
    final coach = _coachCodes();
    final highlightHero = _indexesIn(spot.heroCodes, coach);
    final highlightBoard = _indexesIn(spot.boardCodes, coach);
    final status = _statusLine();
    Widget table = LessonTableStage(
      key: const ValueKey<String>('best-five-picker-table'),
      heroCodes: spot.heroCodes,
      boardCodes: spot.boardCodes,
      villainCount: 2,
      heroFaceUp: true,
      enabled: !widget.locked,
      features: lessonBestFiveTableFeatures,
      selectedHeroIndexes: selectedHero,
      selectedBoardIndexes: selectedBoard,
      highlightHeroIndexes: highlightHero,
      highlightBoardIndexes: highlightBoard,
      onHeroCardTap: widget.locked ? null : _tapHero,
      onBoardCardTap: widget.locked ? null : _tapBoard,
    );
    if (widget.controller.lastResult != null) {
      table = LessonSoftPulseScope(allowed: true, child: table);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: table),
        if (status.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

/// Explain-step demo: seven cards with five highlighted as "these play".
class BestFiveDemo extends StatefulWidget {
  /// Creates the demo.
  const BestFiveDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPlayingTapped,
    this.height,
    this.generation = 0,
  });

  /// When true, the five playing cards are teach-by-doing tap targets.
  final bool interactive;

  /// Whether taps are accepted.
  final bool enabled;

  /// Fires once every playing card has been tapped.
  final VoidCallback? onAllPlayingTapped;

  /// Stage height when the lesson frame already owns the chrome.
  ///
  /// Null keeps the standalone teach shell at 58% of the screen.
  final double? height;

  /// Deal generation (attempt salt is applied via [lessonDealAttemptSalt]).
  final int generation;

  /// Authored template (tests / callers that need the unmapped layout).
  static const hero = ['Ah', 'Kd'];
  static const board = ['As', '7c', '2d', '9h', '3s'];
  static const playing = {'Ah', 'As', 'Kd', '9h', '7c'};

  @override
  State<BestFiveDemo> createState() => _BestFiveDemoState();
}

class _BestFiveDemoState extends State<BestFiveDemo> {
  final Set<String> _tapped = <String>{};
  late final BestFiveExplainDeal _deal;

  @override
  void initState() {
    super.initState();
    _deal = dealBestFiveExplainLayout(generation: widget.generation);
  }

  String? get _nextCode {
    for (final code in _deal.playOrder) {
      if (!_tapped.contains(code)) return code;
    }
    return null;
  }

  void _onCardTap(String code) {
    if (!widget.enabled || widget.onAllPlayingTapped == null) return;
    if (!_deal.playing.contains(code)) return;
    final bool wasNext = _nextCode == code;
    setState(() => _tapped.add(code));
    if (wasNext) {
      consumeLessonSequentialSoftPulse(context);
    }
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: _deal.playing.length - _tapped.length,
    );
    if (_tapped.containsAll(_deal.playing)) {
      widget.onAllPlayingTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep densify after the last card while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    final feltHeight =
        widget.height ??
        (expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null);
    final next = _nextCode;
    reportLessonSequentialPressProgress(
      context,
      remainingPressCount: next == null ? 0 : 1,
    );
    // Width-capped FittedBox.contain left tiny cards in green void — scale
    // hero/board rows and spaceEvenly so the densified felt fills vertically.
    // Board stays ≤~1.2 so five hero cards fit one row on Pro width.
    final heroScale = expandTeach ? 1.85 : 1.0;
    final boardScale = expandTeach ? 1.35 : 1.0;
    // SoftPulse + Rex own the next-card cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cueLabel = () {
      if (!widget.interactive) return 'Highlighted = the five that count';
      return 'Five play · two leftovers';
    }();

    Widget labeledRow({
      required String label,
      required List<String> codes,
      required double cardScale,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: expandTeach ? 14 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: expandTeach ? 12 : 6),
          _DemoRow(
            codes: codes,
            playing: _deal.playing,
            tapped: _tapped,
            nextCode: next,
            interactive: widget.interactive,
            enabled: widget.enabled,
            cardSize: expandTeach ? MiniCardSize.hero : MiniCardSize.small,
            cardScale: cardScale,
            onCardTap: _onCardTap,
          ),
        ],
      );
    }

    final cue =
        !showCue
            ? null
            : Text(
              cueLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: expandTeach ? 16 : 12,
                fontWeight: FontWeight.w700,
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Seven available · five play',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) ...[
          const SizedBox(height: 12),
          labeledRow(
            label: 'You',
            codes: _deal.hero,
            cardScale: 1.0,
          ),
          const SizedBox(height: 12),
          labeledRow(
            label: 'Board',
            codes: _deal.board,
            cardScale: 1.0,
          ),
          const SizedBox(height: 12),
        ] else
          Expanded(
            child: FittedBox(
              // Pack rails tight, then contain scales UP to fill densified
              // height — spaceEvenly left empty green between You/Board.
              fit: BoxFit.contain,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  labeledRow(
                    label: 'You',
                    codes: _deal.hero,
                    cardScale: heroScale,
                  ),
                  const SizedBox(height: 14),
                  labeledRow(
                    label: 'Board',
                    codes: _deal.board,
                    cardScale: boardScale,
                  ),
                ],
              ),
            ),
          ),
        if (cue != null) cue,
      ],
    );
    final child = Container(
      key: const ValueKey('best-five-felt'),
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.feltBorder.withValues(alpha: 0.85),
        ),
      ),
      child: body,
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

class _DemoRow extends StatelessWidget {
  const _DemoRow({
    required this.codes,
    required this.playing,
    required this.tapped,
    required this.nextCode,
    required this.interactive,
    required this.enabled,
    required this.cardSize,
    required this.cardScale,
    required this.onCardTap,
  });

  final List<String> codes;
  final Set<String> playing;
  final Set<String> tapped;
  final String? nextCode;
  final bool interactive;
  final bool enabled;
  final MiniCardSize cardSize;
  final double cardScale;
  final ValueChanged<String> onCardTap;

  @override
  Widget build(BuildContext context) {
    final gap = cardSize == MiniCardSize.hero ? 10.0 * cardScale.clamp(1.0, 1.5) : 6.0;
    // Row (not Wrap) — five board cards must stay one street, never 4+1.
    // FittedBox.scaleDown keeps the street on-screen when scale is ambitious.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < codes.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            SelectableBestFiveCard(
                key: ValueKey<String>('best-five-${codes[i]}'),
                code: codes[i],
                selected:
                    interactive
                        ? tapped.contains(codes[i])
                        : playing.contains(codes[i]),
                highlighted:
                    interactive &&
                    enabled &&
                    playing.contains(codes[i]) &&
                    codes[i] == nextCode,
                enabled: interactive && enabled && playing.contains(codes[i]),
                dimmed: !playing.contains(codes[i]),
                size: cardSize,
                scale: cardScale,
                onPressed:
                    interactive && playing.contains(codes[i])
                        ? () => onCardTap(codes[i])
                        : null,
              ),
          ],
        ],
      ),
    );
  }
}

/// Tappable mini-card used by best-five activities.
class SelectableBestFiveCard extends StatelessWidget {
  /// Creates a tappable best-five card.
  const SelectableBestFiveCard({
    super.key,
    required this.code,
    required this.selected,
    required this.enabled,
    this.highlighted = false,
    this.dimmed = false,
    this.size = MiniCardSize.small,
    this.scale = 1,
    this.onPressed,
  });

  final String code;
  final bool selected;
  final bool enabled;
  final bool highlighted;
  final bool dimmed;
  final MiniCardSize size;
  final double scale;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    CardModel? card;
    try {
      card = CardModel.fromCode(code);
    } catch (_) {
      card = null;
    }
    final radius = size.dimensions.width * scale * 0.12;
    final face =
        card == null
            ? SizedBox(
              width: size.dimensions.width * scale,
              height: size.dimensions.height * scale,
            )
            : MiniCard(
              card: card,
              size: size,
              scale: scale,
              dimmed: dimmed,
            );
    final glowed = LessonTargetGlow(
      selected: selected,
      highlighted: highlighted,
      reserveLayout: false,
      borderRadius: radius,
      scale: scale,
      child: face,
    );
    if (onPressed == null) return glowed;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Card $code',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(radius),
          child: glowed,
        ),
      ),
    );
  }
}

/// Felt picker: tap five of seven cards to assemble the best hand.
class BestFiveCardPicker extends StatefulWidget {
  /// Creates the picker.
  const BestFiveCardPicker({
    super.key,
    required this.activity,
    required this.controller,
    required this.spot,
    required this.locked,
    this.height,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final BestFiveSpot spot;
  final bool locked;

  /// Stage height when the lesson frame already owns the chrome.
  final double? height;

  @override
  State<BestFiveCardPicker> createState() => _BestFiveCardPickerState();
}

class _BestFiveCardPickerState extends State<BestFiveCardPicker> {
  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncFromController);
    _hydrateFromChoice(widget.controller.draft.choiceId);
  }

  @override
  void didUpdateWidget(covariant BestFiveCardPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncFromController);
      widget.controller.addListener(_syncFromController);
      _hydrateFromChoice(widget.controller.draft.choiceId);
      return;
    }
    if (oldWidget.activity.id != widget.activity.id) {
      _hydrateFromChoice(widget.controller.draft.choiceId);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    super.dispose();
  }

  void _syncFromController() {
    final choiceId = widget.controller.draft.choiceId;
    if (choiceId == null) {
      final mapped = mapBestFiveSelectionToChoiceId(
        selected: _selected,
        spot: widget.spot,
        choices: widget.activity.choices,
      );
      if (mapped != null && _selected.isNotEmpty && !widget.locked) {
        setState(_selected.clear);
      }
      return;
    }
    final fromChoice = _codesForChoice(choiceId);
    if (fromChoice.isNotEmpty && !_setEquals(fromChoice, _selected)) {
      final mapped = mapBestFiveSelectionToChoiceId(
        selected: _selected,
        spot: widget.spot,
        choices: widget.activity.choices,
      );
      if (mapped != choiceId) {
        setState(() {
          _selected
            ..clear()
            ..addAll(fromChoice);
        });
      }
    }
  }

  void _hydrateFromChoice(String? choiceId) {
    _selected
      ..clear()
      ..addAll(_codesForChoice(choiceId));
  }

  Set<String> _codesForChoice(String? choiceId) {
    if (choiceId == null) return {};
    final codes = widget.spot.choiceSets[choiceId];
    if (codes == null) return {};
    return codes.toSet();
  }

  void _toggle(String code) {
    if (widget.locked) return;
    setState(() {
      if (_selected.contains(code)) {
        _selected.remove(code);
      } else if (_selected.length < 5) {
        _selected.add(code);
      }
    });
    final mapped = mapBestFiveSelectionToChoiceId(
      selected: _selected,
      spot: widget.spot,
      choices: widget.activity.choices,
    );
    if (mapped != null) {
      widget.controller.selectChoice(mapped, autoSubmit: true);
    } else if (widget.controller.draft.choiceId != null) {
      widget.controller.undoDraft();
    }
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    for (final x in a) {
      if (!b.contains(x)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    // Teach picker: fill tall-phone felt like BestFiveDemo SoftPulse.
    final densify = true;
    final feltHeight =
        widget.height ??
        (densify ? MediaQuery.sizeOf(context).height * 0.58 : null);
    final heroScale = densify ? 1.85 : 1.0;
    // Board must stay readable as five-across — slightly under hero scale.
    final boardScale = densify ? 1.35 : 1.0;

    Widget statusLine() {
      final status = () {
        if (widget.controller.lastResult != null) return '';
        if (widget.controller.submitting) return 'Checking…';
        if (_selected.length == 5) {
          return mapBestFiveSelectionToChoiceId(
                    selected: _selected,
                    spot: spot,
                    choices: widget.activity.choices,
                  ) !=
                  null
              ? 'Checking…'
              : 'Five tapped — try a stronger five.';
        }
        // Rex already says tap the ones that play — keep a quiet count.
        return '${_selected.length}/5 selected';
      }();
      if (status.isEmpty) return const SizedBox.shrink();
      return Text(
        status,
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(
          color: AppColors.slate,
          fontSize: densify ? 15 : 13,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    Widget labeledRow({
      required String label,
      required List<String> codes,
      required double cardScale,
      required double gap,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color:
                  label.startsWith('BOARD')
                      ? AppColors.cream.withValues(alpha: 0.7)
                      : AppColors.cream,
              fontSize: densify ? (label.startsWith('BOARD') ? 12 : 14) : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: label.startsWith('BOARD') ? 0.7 : 0,
            ),
          ),
          SizedBox(height: densify ? 12 : 8),
          // Row keeps five board cards on one street; scaleDown if width-tight.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < codes.length; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  SelectableBestFiveCard(
                    key: ValueKey<String>('best-five-${codes[i]}'),
                    code: codes[i],
                    selected: _selected.contains(codes[i]),
                    enabled: !widget.locked,
                    size: MiniCardSize.hero,
                    scale: cardScale,
                    onPressed: () => _toggle(codes[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      key: const ValueKey('best-five-picker-felt'),
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        densify ? 18 : 14,
        12,
        densify ? 18 : 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.feltBorder.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: FittedBox(
              // Pack You + Board, then contain scales UP to fill densified
              // height (spaceEvenly left sparse green voids on Pro).
              fit: BoxFit.contain,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  labeledRow(
                    label: 'You',
                    codes: spot.heroCodes,
                    cardScale: heroScale,
                    gap: 14,
                  ),
                  const SizedBox(height: 14),
                  labeledRow(
                    label: 'BOARD · shared',
                    codes: spot.boardCodes,
                    cardScale: boardScale,
                    gap: 10,
                  ),
                ],
              ),
            ),
          ),
          statusLine(),
        ],
      ),
    );
  }
}
