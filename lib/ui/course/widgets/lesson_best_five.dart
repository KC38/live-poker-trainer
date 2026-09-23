/// Best-five / kicker teaching visuals and tap-five-of-seven mapping.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

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

/// Explain-step demo: seven cards with five highlighted as "these play".
class BestFiveDemo extends StatefulWidget {
  /// Creates the demo.
  const BestFiveDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPlayingTapped,
  });

  /// When true, the five playing cards are teach-by-doing tap targets.
  final bool interactive;

  /// Whether taps are accepted.
  final bool enabled;

  /// Fires once every playing card has been tapped.
  final VoidCallback? onAllPlayingTapped;

  static const hero = ['Ah', 'Kd'];
  static const board = ['As', '7c', '2d', '9h', '3s'];
  static const playing = {'Ah', 'As', 'Kd', '9h', '7c'};

  @override
  State<BestFiveDemo> createState() => _BestFiveDemoState();
}

class _BestFiveDemoState extends State<BestFiveDemo> {
  final Set<String> _tapped = <String>{};

  void _onCardTap(String code) {
    if (!widget.enabled || widget.onAllPlayingTapped == null) return;
    if (!BestFiveDemo.playing.contains(code)) return;
    setState(() => _tapped.add(code));
    if (_tapped.containsAll(BestFiveDemo.playing)) {
      widget.onAllPlayingTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
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
          Text(
            'Seven available · five play',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          _DemoRow(
            codes: BestFiveDemo.hero,
            playing: BestFiveDemo.playing,
            tapped: _tapped,
            interactive: widget.interactive,
            enabled: widget.enabled,
            onCardTap: _onCardTap,
          ),
          const SizedBox(height: 12),
          Text(
            'Board',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          _DemoRow(
            codes: BestFiveDemo.board,
            playing: BestFiveDemo.playing,
            tapped: _tapped,
            interactive: widget.interactive,
            enabled: widget.enabled,
            onCardTap: _onCardTap,
          ),
          const SizedBox(height: 12),
          Text(
            widget.interactive
                ? 'Tap each highlighted card — those five count'
                : 'Highlighted = the five that count',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
    required this.interactive,
    required this.enabled,
    required this.onCardTap,
  });

  final List<String> codes;
  final Set<String> playing;
  final Set<String> tapped;
  final bool interactive;
  final bool enabled;
  final ValueChanged<String> onCardTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final code in codes)
          SelectableBestFiveCard(
            code: code,
            selected: interactive ? tapped.contains(code) : playing.contains(code),
            highlighted:
                interactive &&
                playing.contains(code) &&
                !tapped.contains(code),
            enabled: interactive && enabled && playing.contains(code),
            dimmed: !playing.contains(code),
            onPressed:
                interactive && playing.contains(code)
                    ? () => onCardTap(code)
                    : null,
          ),
      ],
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
    this.onPressed,
  });

  final String code;
  final bool selected;
  final bool enabled;
  final bool highlighted;
  final bool dimmed;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    CardModel? card;
    try {
      card = CardModel.fromCode(code);
    } catch (_) {
      card = null;
    }
    final border =
        selected
            ? AppColors.gold
            : highlighted
            ? AppColors.gold.withValues(alpha: 0.75)
            : AppColors.slateDark.withValues(alpha: 0.7);
    final child = AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      opacity: dimmed && !selected ? 0.38 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: border,
            width: selected ? 2.4 : highlighted ? 2 : 1,
          ),
          color:
              selected
                  ? AppColors.gold.withValues(alpha: 0.18)
                  : highlighted
                  ? AppColors.gold.withValues(alpha: 0.1)
                  : Colors.transparent,
        ),
        child:
            card == null
                ? SizedBox(
                  width: MiniCardSize.small.dimensions.width,
                  height: MiniCardSize.small.dimensions.height,
                )
                : MiniCard(card: card, size: MiniCardSize.small),
      ),
    );
    if (onPressed == null) return child;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Card $code',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: child,
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
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final BestFiveSpot spot;
  final bool locked;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'You',
          style: GoogleFonts.manrope(
            color: AppColors.cream,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final code in spot.heroCodes)
              SelectableBestFiveCard(
                key: ValueKey<String>('best-five-$code'),
                code: code,
                selected: _selected.contains(code),
                enabled: !widget.locked,
                onPressed: () => _toggle(code),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Board',
          style: GoogleFonts.manrope(
            color: AppColors.cream,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final code in spot.boardCodes)
              SelectableBestFiveCard(
                key: ValueKey<String>('best-five-$code'),
                code: code,
                selected: _selected.contains(code),
                enabled: !widget.locked,
                onPressed: () => _toggle(code),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.controller.submitting
              ? 'Checking…'
              : _selected.length == 5
              ? (mapBestFiveSelectionToChoiceId(
                      selected: _selected,
                      spot: spot,
                      choices: widget.activity.choices,
                    ) !=
                    null
                  ? 'Checking…'
                  : 'Five tapped — try a stronger five.')
              : '${_selected.length}/5 selected — ${spot.hint}',
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
