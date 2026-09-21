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
    final coachText = _coachText(presentation, scene != null);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.draft.choiceId;
        final locked = controller.submitting || controller.lastResult != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (activity.primaryCoachLine != null || showGuidance)
              RexCoachLine(text: coachText),
            if (scene != null) ...[
              const SizedBox(height: 14),
              LessonTableContext(scene: scene),
            ],
            if (activity.prompt != null) ...[
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

  String _coachText(SelectIdentifyPresentation presentation, bool hasScene) {
    final authored = activity.primaryCoachLine?.text;
    if (authored != null) return authored;
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
    final onPressed =
        locked ? null : () => controller.selectChoice(choice.id);

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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RexCoachLine(text: _coachText),
            if (widget.activity.prompt != null) ...[
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
                          widget.controller.selectChoice(mapped);
                        },
              ),
            ],
            const SizedBox(height: 12),
            Text(
              selected == null
                  ? 'Tap a region on the table.'
                  : 'Ready — Check when it looks right.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
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

  String get _coachText {
    final authored = activity.primaryCoachLine?.text;
    if (authored != null) return authored;
    return 'Board and holes are live — tap the category you made.';
  }

  @override
  Widget build(BuildContext context) {
    final scene = resolveLessonTableScene(activity);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final locked = controller.submitting || controller.lastResult != null;
        final selected = controller.draft.choiceId;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RexCoachLine(text: _coachText),
            if (activity.prompt != null) ...[
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
                        locked ? null : () => controller.selectChoice(choice.id),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            Text(
              selected == null
                  ? 'Tap the hand category you made.'
                  : 'Ready — Check when it looks right.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
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

  String get _coachText {
    final authored = activity.primaryCoachLine?.text;
    if (authored != null) return authored;
    if (activity.id == 'act-01-02-02-scaffolded-kicker') {
      return 'Same pair — tap who wins on kickers.';
    }
    if (activity.id == 'act-01-02-02-unguided-board') {
      return 'Board is broadway clubs — tap the showdown result.';
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RexCoachLine(text: _coachText),
            if (activity.prompt != null) ...[
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
                            : () => controller.selectChoice(choice.id),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            Text(
              selected == null
                  ? 'Tap the result that wins the pot.'
                  : 'Ready — Check when it looks right.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
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

  String get _coachText {
    final authored = activity.primaryCoachLine?.text;
    if (authored != null) return authored;
    return 'Only five cards count — tap the ones that play.';
  }

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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RexCoachLine(text: _coachText),
            if (activity.prompt != null) ...[
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
    if (mapped != null) {
      widget.controller.selectChoice(mapped);
      return;
    }
    if (widget.controller.draft.choiceId != null) {
      widget.controller.undoDraft();
    }
  }

  String _statusLine() {
    if (_selected.isEmpty) return 'Tap suits to build your answer.';
    final mapped = mapSuitTapSelectionToChoiceId(
      selected: _selected,
      choices: widget.activity.choices,
    );
    if (mapped != null) return 'Ready — Check when it looks right.';
    return 'Keep tapping — include every real suit.';
  }

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 12),
        Text(
          _statusLine(),
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
