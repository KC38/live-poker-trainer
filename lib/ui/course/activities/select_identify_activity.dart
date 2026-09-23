/// Select / identify activity (positions, cards, classifications).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_best_five.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_choice_visuals.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_hand_examples.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Multiple-choice identify activity with optional guided highlight.
class SelectIdentifyActivity extends StatelessWidget {
  /// Creates the activity.
  const SelectIdentifyActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  @override
  Widget build(BuildContext context) {
    final presentation = resolveSelectIdentifyPresentation(activity);
    if (presentation == SelectIdentifyPresentation.tableRegionTap) {
      return _TableRegionTapActivity(
        key: ValueKey<String>(
          '${activity.id}-${controller.bindGeneration}',
        ),
        activity: activity,
        controller: controller,
        showGuidance: showGuidance,
      );
    }
    if (presentation == SelectIdentifyPresentation.handCategoryTap) {
      return _HandCategoryTapActivity(
        key: ValueKey<String>(
          '${activity.id}-${controller.bindGeneration}',
        ),
        activity: activity,
        controller: controller,
        showGuidance: showGuidance,
      );
    }
    if (presentation == SelectIdentifyPresentation.showdownTap) {
      return _ShowdownTapActivity(
        key: ValueKey<String>(
          '${activity.id}-${controller.bindGeneration}',
        ),
        activity: activity,
        controller: controller,
        showGuidance: showGuidance,
      );
    }
    if (presentation == SelectIdentifyPresentation.bestFiveCardTap) {
      return _BestFiveCardTapActivity(
        key: ValueKey<String>(
          '${activity.id}-${controller.bindGeneration}',
        ),
        activity: activity,
        controller: controller,
        showGuidance: showGuidance,
      );
    }

    final scene = resolveLessonTableScene(activity);
    final resolved = resolveLessonCoachPrompt(
      activity: activity,
      fallback: _coachFallback(presentation, scene != null),
    );
    final coachText = resolved.coach;
    final showPrompt = resolved.showPrompt;
    final showCoach = shouldShowLessonCoach(
      activity: activity,
      showGuidance: showGuidance,
      coach: coachText,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.draft.choiceId;
        final locked = controller.submitting || controller.lastResult != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showCoach) RexCoachLine(text: coachText),
            if (scene != null) ...[
              const SizedBox(height: 14),
              LessonTableContext(scene: scene),
            ],
            if (showPrompt) ...[
              const SizedBox(height: 14),
              Text(
                activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (presentation == SelectIdentifyPresentation.suitTapPicker)
              SuitTapPicker(
                key: ValueKey<String>(
                  '${activity.id}-${controller.bindGeneration}',
                ),
                activity: activity,
                controller: controller,
                locked: locked,
              )
            else if (presentation == SelectIdentifyPresentation.holeCards)
              _HoleCardFeltTray(
                activity: activity,
                selectedId: selected,
                locked: locked,
                showGuidance: showGuidance,
                onSelect: (id) => controller.selectChoice(id, autoSubmit: true),
              )
            else
              for (var i = 0; i < activity.choices.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildChoice(
                  presentation: presentation,
                  choice: activity.choices[i],
                  index: i,
                  selected: selected == activity.choices[i].id,
                  locked: locked,
                ),
              ],
          ],
        );
      },
    );
  }

  String _coachFallback(SelectIdentifyPresentation presentation, bool hasScene) {
    return switch (presentation) {
      SelectIdentifyPresentation.suitTapPicker =>
        'Tap every suit that belongs in a standard deck.',
      SelectIdentifyPresentation.holeCards =>
        'Look at the cards — pick the matching pair.',
      SelectIdentifyPresentation.suitSets =>
        'Read the suits, then pick the complete set.',
      SelectIdentifyPresentation.tableRegionTap =>
        'Tap the answer on the table.',
      SelectIdentifyPresentation.handCategoryTap =>
        'Read the board and your holes — tap the category you made.',
      SelectIdentifyPresentation.showdownTap =>
        'Look at both hands — tap who wins.',
      SelectIdentifyPresentation.bestFiveCardTap =>
        'Tap the five cards that play in your best hand.',
      SelectIdentifyPresentation.text =>
        hasScene
            ? 'Look at the table, then pick the answer that matches.'
            : 'Pick the best answer.',
    };
  }

  Widget _buildChoice({
    required SelectIdentifyPresentation presentation,
    required CourseChoice choice,
    required int index,
    required bool selected,
    required bool locked,
  }) {
    final highlight =
        showGuidance &&
        activity.stage == ActivityStage.guided &&
        index == 0 &&
        controller.draft.choiceId == null;
    final onPressed = locked
        ? null
        : () => controller.selectChoice(choice.id, autoSubmit: true);

    switch (presentation) {
      case SelectIdentifyPresentation.holeCards:
        return HoleCardChoiceButton(
          codes: parseCardCodes(choice.label),
          accessibilityText: choice.accessibilityText,
          selected: selected,
          highlighted: highlight,
          enabled: !locked,
          onPressed: onPressed,
        );
      case SelectIdentifyPresentation.suitSets:
        return SuitSetChoiceButton(
          tokens: parseSuitTokens(choice.label),
          label: choice.label,
          accessibilityText: choice.accessibilityText,
          selected: selected,
          highlighted: highlight,
          enabled: !locked,
          onPressed: onPressed,
        );
      case SelectIdentifyPresentation.suitTapPicker:
      case SelectIdentifyPresentation.tableRegionTap:
      case SelectIdentifyPresentation.handCategoryTap:
      case SelectIdentifyPresentation.showdownTap:
      case SelectIdentifyPresentation.bestFiveCardTap:
      case SelectIdentifyPresentation.text:
        return LessonChoiceButton(
          label: choice.label,
          accessibilityText: choice.accessibilityText,
          selected: selected,
          highlighted: highlight,
          enabled: !locked,
          onPressed: onPressed,
        );
    }
  }
}

class _TableRegionTapActivity extends StatefulWidget {
  const _TableRegionTapActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  @override
  State<_TableRegionTapActivity> createState() =>
      _TableRegionTapActivityState();
}

class _TableRegionTapActivityState extends State<_TableRegionTapActivity> {
  LessonTableRegion? _selectedRegion;
  int? _selectedSeatIndex;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void didUpdateWidget(covariant _TableRegionTapActivity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
      _selectedRegion = null;
      _selectedSeatIndex = null;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    if (widget.controller.draft.choiceId == null &&
        (_selectedRegion != null || _selectedSeatIndex != null)) {
      setState(() {
        _selectedRegion = null;
        _selectedSeatIndex = null;
      });
    }
  }

  String get _coachText {
    final authored = widget.activity.primaryCoachLine?.text;
    if (authored != null) return authored;
    return switch (widget.activity.id) {
      'act-01-01-01-guided-find-holes' =>
        'Your private cards are on the felt. Find them.',
      'act-01-01-01-scaffolded-private' =>
        'Nobody else can peek at your holes.',
      'act-01-01-01-unguided-mix' =>
        'Everyone shares the cards in the middle.',
      'act-01-01-01-checkpoint-table' =>
        'Ownership stays split — board is shared.',
      'act-01-01-03-guided-button' =>
        'Find the dealer button on the felt.',
      'act-01-01-03-scaffolded-blinds' =>
        'Blinds sit left of the button. Tap the big blind.',
      'act-01-01-03-unguided-when' =>
        'When do those forced bets go in?',
      'act-01-01-03-checkpoint-layout' =>
        'Button is marked. Tap the small blind seat.',
      'act-02-01-01-guided-btn' =>
        'Tap who acts last postflop.',
      'act-02-01-01-scaffolded-blinds' =>
        'Tap a seat that posts a forced bet every hand.',
      'act-02-01-01-unguided-co' =>
        'Tap the seat right before the button.',
      'act-02-01-01-checkpoint-edge' =>
        'Same cards — later seats play stronger.',
      'act-01-04-01-unguided-end' =>
        'Betting is live. Tap when this street is done.',
      'act-01-04-01-checkpoint-postflop' =>
        'Postflop — tap who acts first.',
      'act-01-05-01-guided-fold-win' =>
          'Everyone folded. Tap how you take the pot.',
      'act-01-05-01-scaffolded-showdown' =>
          'River is called. Tap what happens next.',
      'act-01-05-01-unguided-pot' =>
          'Open to 6 at 1/2. Tap the pot before blinds act.',
      'act-01-05-01-checkpoint-side' =>
          'You are short all-in. Tap what is true.',
      'act-01-02-02-unguided-board' =>
          'Both checked down — tap who takes the pot.',
      'act-02-07-01-checkpoint-habit' =>
          'Cards uncovered and action left — tap the safe habit.',
      'act-02-07-02-jump-pos' =>
          'Tap the seat right before the button.',
      'act-02-07-02-jump-stack' =>
          'Effective stack is the shorter one — tap it.',
      'act-03-01-01-guided' =>
          'Blinds plus three 6s — tap the pot total.',
      'act-03-01-01-scaffolded' =>
          'Preflop — tap who acts first (left of the BB).',
      'act-03-01-01-unguided' =>
          'You said raise. Tap what counts at a live table.',
      'act-03-01-01-checkpoint' =>
          'Shorter stack caps the matchup — tap what matters with the pot.',
      'act-03-03-01-scaffolded' =>
          'Pot 20, bet 10 — tap how many chips to call.',
      'act-03-03-01-unguided' =>
          'Getting 3:1 with real outs — tap what you do.',
      _ => 'Tap the answer on the table.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scene = resolveLessonTableScene(widget.activity);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final locked =
            widget.controller.submitting ||
            widget.controller.lastResult != null;
        final selected = widget.controller.draft.choiceId;
        final coach = _coachText;
        final prompt = widget.activity.prompt?.trim();
        // Felt + Rex already teach — skip near-duplicate prompt dumps on
        // street / pot / position felt quizzes (and hide Rex under Nice!).
        final feltFirstSelect =
            widget.activity.id.startsWith('act-01-04-01-') ||
            widget.activity.id.startsWith('act-01-05-01-') ||
            widget.activity.id.startsWith('act-02-01-01-') ||
            widget.activity.id == 'act-02-07-01-checkpoint-habit' ||
            widget.activity.id == 'act-02-07-02-jump-pos' ||
            widget.activity.id == 'act-02-07-02-jump-stack' ||
            widget.activity.id == 'act-03-01-01-guided' ||
            widget.activity.id == 'act-03-01-01-scaffolded' ||
            widget.activity.id == 'act-03-01-01-unguided' ||
            widget.activity.id == 'act-03-01-01-checkpoint' ||
            widget.activity.id == 'act-03-03-01-scaffolded' ||
            widget.activity.id == 'act-03-03-01-unguided';
        final showPrompt =
            !feltFirstSelect &&
            prompt != null &&
            prompt.isNotEmpty &&
            prompt.toLowerCase() != coach.trim().toLowerCase();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!locked) RexCoachLine(text: coach),
            if (showPrompt) ...[
              const SizedBox(height: 14),
              Text(
                widget.activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
            if (scene != null) ...[
              const SizedBox(height: 14),
              LessonTableContext(
                scene: scene,
                selectedRegion: _selectedRegion,
                selectedSeatIndex: _selectedSeatIndex,
                showSoftPulse:
                    widget.showGuidance &&
                    selected == null &&
                    widget.activity.stage == ActivityStage.guided,
                enabled: !locked,
                onRegionTap:
                    locked
                        ? null
                        : (target) {
                          final mapped = mapTableRegionToChoiceId(
                            activityId: widget.activity.id,
                            region: target.region,
                            seatIndex: target.seatIndex,
                            choices: widget.activity.choices,
                          );
                          if (mapped == null) return;
                          setState(() {
                            _selectedRegion = target.region;
                            _selectedSeatIndex = target.seatIndex;
                          });
                          widget.controller.selectChoice(mapped, autoSubmit: true);
                        },
              ),
            ],
            if (!locked &&
                (widget.controller.submitting ||
                    widget.controller.lastResult == null)) ...[
              const SizedBox(height: 12),
              Text(
                widget.controller.submitting
                    ? 'Checking…'
                    : feltFirstSelect
                    ? 'Tap on the felt.'
                    : 'Tap the answer on the table.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HandCategoryTapActivity extends StatelessWidget {
  const _HandCategoryTapActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  String get _coachFallback => switch (activity.id) {
        'act-02-07-02-jump-family' =>
          'Look at your holes — tap the family they belong to.',
        'act-03-02-01-guided' =>
          'Board pairs your king — tap the flop class.',
        'act-03-02-01-scaffolded' =>
          'Two hearts on board with the nut heart — tap the class.',
        'act-03-02-01-unguided' =>
          'No pair, almost no draw multiway — tap the class.',
        'act-03-02-01-checkpoint' =>
          'Eight or queen completes — tap the class.',
        'act-03-03-01-guided' =>
          'King-high board. Tap how many clean outs you have.',
        _ => 'Look at the board and your holes — tap what you made.',
      };

  @override
  Widget build(BuildContext context) {
    final scene = resolveLessonTableScene(activity);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final locked = controller.submitting || controller.lastResult != null;
        final selected = controller.draft.choiceId;
        // Felt already shows the cards — never dump board/hole codes into Rex.
        final resolved =
            scene != null
                ? (
                  coach: _coachFallback,
                  showPrompt: false,
                )
                : resolveLessonCoachPrompt(
                  activity: activity,
                  fallback: _coachFallback,
                );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RexCoachLine(text: resolved.coach),
            if (resolved.showPrompt) ...[
              const SizedBox(height: 14),
              Text(
                activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
            if (scene != null) ...[
              const SizedBox(height: 14),
              LessonTableContext(scene: scene),
            ],
            const SizedBox(height: 14),
            for (var i = 0; i < activity.choices.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Builder(
                builder: (context) {
                  final choice = activity.choices[i];
                  final example =
                      resolveHandExample(id: choice.id, label: choice.label) ??
                      LessonHandExample(
                        id: choice.id,
                        title: choice.label,
                        codes: const [],
                      );
                  return HandExampleTile(
                    example: example,
                    selected: selected == choice.id,
                    enabled: !locked,
                    compact: true,
                    onPressed:
                        locked
                            ? null
                            : () => controller.selectChoice(
                              choice.id,
                              autoSubmit: true,
                            ),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final status = () {
                  if (controller.lastResult != null) return '';
                  if (controller.submitting) return 'Checking…';
                  if (selected == null) {
                    return activity.id == 'act-02-07-02-jump-family'
                        ? 'Tap the starting-hand family.'
                        : activity.id.startsWith('act-03-02-01-')
                        ? 'Tap the flop class.'
                        : activity.id == 'act-03-03-01-guided'
                        ? 'Tap your clean-out count.'
                        : 'Tap the hand category you made.';
                  }
                  return 'Checking…';
                }();
                if (status.isEmpty) return const SizedBox.shrink();
                return Text(
                  status,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ShowdownTapActivity extends StatelessWidget {
  const _ShowdownTapActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  String get _coachFallback {
    if (activity.id == 'act-01-02-02-scaffolded-kicker') {
      return 'Same pair — tap who wins on kickers.';
    }
    if (activity.id == 'act-01-02-02-unguided-board') {
      return 'Both checked down — tap who takes the pot.';
    }
    return 'Look at both hands — tap who wins.';
  }

  @override
  Widget build(BuildContext context) {
    final scene = resolveLessonTableScene(activity);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final locked = controller.submitting || controller.lastResult != null;
        final selected = controller.draft.choiceId;
        // Felt already shows the cards — never dump board/hole codes into Rex.
        final resolved =
            scene != null
                ? (coach: _coachFallback, showPrompt: false)
                : resolveLessonCoachPrompt(
                  activity: activity,
                  fallback: _coachFallback,
                );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RexCoachLine(text: resolved.coach),
            if (scene == null && resolved.showPrompt) ...[
              const SizedBox(height: 14),
              Text(
                activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
            if (scene != null) ...[
              const SizedBox(height: 12),
              LessonTableContext(scene: scene),
            ],
            const SizedBox(height: 12),
            for (var i = 0; i < activity.choices.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final choice = activity.choices[i];
                  final example =
                      resolveHandExample(id: choice.id, label: choice.label) ??
                      LessonHandExample(
                        id: choice.id,
                        title: choice.label,
                        codes: const [],
                      );
                  return HandExampleTile(
                    example: example,
                    selected: selected == choice.id,
                    enabled: !locked,
                    compact: true,
                    onPressed:
                        locked
                            ? null
                            : () => controller.selectChoice(
                              choice.id,
                              autoSubmit: true,
                            ),
                  );
                },
              ),
            ],
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final status = () {
                  if (controller.lastResult != null) return '';
                  if (controller.submitting) return 'Checking…';
                  if (selected == null) {
                    return 'Tap the result that wins the pot.';
                  }
                  return 'Checking…';
                }();
                if (status.isEmpty) return const SizedBox.shrink();
                return Text(
                  status,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _BestFiveCardTapActivity extends StatelessWidget {
  const _BestFiveCardTapActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  String get _coachFallback =>
      'Only five cards count — tap the ones that play.';

  @override
  Widget build(BuildContext context) {
    final spot = resolveBestFiveSpot(activity);
    if (spot == null) {
      return Text(
        'Missing best-five spot for ${activity.id}',
        style: GoogleFonts.manrope(color: AppColors.cream),
      );
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final locked = controller.submitting || controller.lastResult != null;
        // Cards are on the picker — never dump hole/board codes into Rex.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RexCoachLine(text: _coachFallback),
            const SizedBox(height: 14),
            BestFiveCardPicker(
              key: ValueKey<String>(
                '${activity.id}-${controller.bindGeneration}',
              ),
              activity: activity,
              controller: controller,
              spot: spot,
              locked: locked,
            ),
          ],
        );
      },
    );
  }
}

/// Felt suit picker that maps tap sets onto authored choice ids.
class SuitTapPicker extends StatefulWidget {
  /// Creates the suit tap picker.
  const SuitTapPicker({
    super.key,
    required this.activity,
    required this.controller,
    required this.locked,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool locked;

  @override
  State<SuitTapPicker> createState() => _SuitTapPickerState();
}

class _SuitTapPickerState extends State<SuitTapPicker> {
  static const _palette = <LessonSuitToken>[
    LessonSuitToken.hearts,
    LessonSuitToken.diamonds,
    LessonSuitToken.clubs,
    LessonSuitToken.spades,
    LessonSuitToken.stars,
  ];

  final Set<LessonSuitToken> _selected = <LessonSuitToken>{};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncFromController);
    _hydrateFromChoice(widget.controller.draft.choiceId);
  }

  @override
  void didUpdateWidget(covariant SuitTapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncFromController);
      widget.controller.addListener(_syncFromController);
      _hydrateFromChoice(widget.controller.draft.choiceId);
      return;
    }
    // Same controller, new activity (resume / advance): drop provisional taps.
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
      // Undo after a Check-ready set: drop tiles. Keep provisional 1–2 taps.
      final mapped = mapSuitTapSelectionToChoiceId(
        selected: _selected,
        choices: widget.activity.choices,
      );
      if (mapped != null && _selected.isNotEmpty && !widget.locked) {
        setState(_selected.clear);
      }
      return;
    }
    final fromChoice = _tokensForChoice(choiceId);
    if (fromChoice.isNotEmpty &&
        !_setEquals(fromChoice, _selected) &&
        mapSuitTapSelectionToChoiceId(
              selected: _selected,
              choices: widget.activity.choices,
            ) !=
            choiceId) {
      setState(() {
        _selected
          ..clear()
          ..addAll(fromChoice);
      });
    }
  }

  void _hydrateFromChoice(String? choiceId) {
    _selected
      ..clear()
      ..addAll(_tokensForChoice(choiceId));
  }

  Set<LessonSuitToken> _tokensForChoice(String? choiceId) {
    if (choiceId == null) return <LessonSuitToken>{};
    for (final choice in widget.activity.choices) {
      if (choice.id == choiceId) {
        return parseSuitTokens(choice.label).toSet();
      }
    }
    return <LessonSuitToken>{};
  }

  bool _setEquals(Set<LessonSuitToken> a, Set<LessonSuitToken> b) {
    return a.length == b.length && a.containsAll(b);
  }

  void _toggle(LessonSuitToken token) {
    if (widget.locked) return;
    setState(() {
      if (!_selected.add(token)) {
        _selected.remove(token);
      }
    });
    final mapped = mapSuitTapSelectionToChoiceId(
      selected: _selected,
      choices: widget.activity.choices,
    );
    if (mapped == null) {
      if (widget.controller.draft.choiceId != null) {
        widget.controller.undoDraft();
      }
      return;
    }
    // Auto-submit only once all four real suits are in — never on a
    // partial "missing" set that still needs another tap.
    final hasAllReal = _selected.containsAll(const {
      LessonSuitToken.hearts,
      LessonSuitToken.diamonds,
      LessonSuitToken.clubs,
      LessonSuitToken.spades,
    });
    widget.controller.selectChoice(mapped, autoSubmit: hasAllReal);
  }

  String _statusLine() {
    if (widget.controller.lastResult != null) return '';
    if (widget.controller.submitting) return 'Checking…';
    if (_selected.isEmpty) return 'Tap suits to build your answer.';
    final hasAllReal = _selected.containsAll(const {
      LessonSuitToken.hearts,
      LessonSuitToken.diamonds,
      LessonSuitToken.clubs,
      LessonSuitToken.spades,
    });
    if (hasAllReal) return 'Checking…';
    final realCount = _selected.where((t) => t.isReal).length;
    return '$realCount of 4 real suits — skip decoys.';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final status = _statusLine();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              decoration: BoxDecoration(
                color: AppColors.feltLight.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.feltBorder.withValues(alpha: 0.55),
                ),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final token in _palette)
                    SuitTapTile(
                      token: token,
                      selected: _selected.contains(token),
                      enabled: !widget.locked,
                      onPressed: () => _toggle(token),
                    ),
                ],
              ),
            ),
            if (status.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                status,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Felt tray of hole-card choices — teach-by-tapping card faces, not prose.
class _HoleCardFeltTray extends StatelessWidget {
  const _HoleCardFeltTray({
    required this.activity,
    required this.selectedId,
    required this.locked,
    required this.showGuidance,
    required this.onSelect,
  });

  final CourseActivity activity;
  final String? selectedId;
  final bool locked;
  final bool showGuidance;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TAP A HAND',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.cream.withValues(alpha: 0.72),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < activity.choices.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            HoleCardChoiceButton(
              codes: parseCardCodes(activity.choices[i].label),
              accessibilityText: activity.choices[i].accessibilityText,
              selected: selectedId == activity.choices[i].id,
              highlighted:
                  showGuidance &&
                  activity.stage == ActivityStage.guided &&
                  i == 0 &&
                  selectedId == null,
              enabled: !locked,
              onPressed:
                  locked ? null : () => onSelect(activity.choices[i].id),
            ),
          ],
        ],
      ),
    );
  }
}
