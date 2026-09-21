/// Select / identify activity (positions, cards, classifications).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_choice_visuals.dart';
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
      // Footer Undo clears a mapped answer — reset tiles only when the
      // current taps still encode a complete choice (not mid-edit).
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
    // Incomplete / non-matching — clear draft so Check stays disabled.
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
