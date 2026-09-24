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

  /// Visual left→right among the five that play (hero row, then board).
  static const _playOrder = ['Ah', 'Kd', 'As', '7c', '9h'];

  String? get _nextCode {
    for (final code in _playOrder) {
      if (!_tapped.contains(code)) return code;
    }
    return null;
  }

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
    // Keep densify after the last card while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final next = _nextCode;
    // Width-capped FittedBox.contain left tiny cards in green void — scale
    // hero/board rows and spaceEvenly so the densified felt fills vertically.
    final heroScale = expandTeach ? 1.85 : 1.0;
    final boardScale = expandTeach ? 1.4 : 1.0;
    final cueLabel = () {
      if (!widget.interactive) return 'Highlighted = the five that count';
      if (next == null) return 'Five play · two leftovers';
      try {
        return 'Tap ${CardModel.fromCode(next).display}';
      } catch (_) {
        return 'Tap $next';
      }
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
            playing: BestFiveDemo.playing,
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

    final cue = Text(
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
            codes: BestFiveDemo.hero,
            cardScale: 1.0,
          ),
          const SizedBox(height: 12),
          labeledRow(
            label: 'Board',
            codes: BestFiveDemo.board,
            cardScale: 1.0,
          ),
          const SizedBox(height: 12),
        ] else
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Tall Pro felt: big cards + spaceEvenly fill. Short test
                // viewports: keep compact + scaleDown so we never overflow.
                final roomy = constraints.maxHeight >= 300;
                final hScale = roomy ? heroScale : 1.15;
                final bScale = roomy ? boardScale : 1.0;
                final spread = Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    labeledRow(
                      label: 'You',
                      codes: BestFiveDemo.hero,
                      cardScale: hScale,
                    ),
                    labeledRow(
                      label: 'Board',
                      codes: BestFiveDemo.board,
                      cardScale: bScale,
                    ),
                  ],
                );
                if (roomy) return spread;
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width - 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        labeledRow(
                          label: 'You',
                          codes: BestFiveDemo.hero,
                          cardScale: hScale,
                        ),
                        const SizedBox(height: 16),
                        labeledRow(
                          label: 'Board',
                          codes: BestFiveDemo.board,
                          cardScale: bScale,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        cue,
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
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      alignment: WrapAlignment.center,
      children: [
        for (final code in codes)
          _SoftPulseTarget(
            active:
                interactive &&
                enabled &&
                playing.contains(code) &&
                code == nextCode,
            child: SelectableBestFiveCard(
              code: code,
              selected:
                  interactive ? tapped.contains(code) : playing.contains(code),
              highlighted:
                  interactive &&
                  enabled &&
                  playing.contains(code) &&
                  code == nextCode,
              enabled: interactive && enabled && playing.contains(code),
              dimmed: !playing.contains(code),
              size: cardSize,
              scale: cardScale,
              onPressed:
                  interactive && playing.contains(code)
                      ? () => onCardTap(code)
                      : null,
            ),
          ),
      ],
    );
  }
}

class _SoftPulseTarget extends StatefulWidget {
  const _SoftPulseTarget({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_SoftPulseTarget> createState() => _SoftPulseTargetState();
}

class _SoftPulseTargetState extends State<_SoftPulseTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.active) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _SoftPulseTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.active && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = 0.4 + (_pulse.value * 0.55);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: glow * 0.55),
                blurRadius: 14 + (_pulse.value * 10),
                spreadRadius: 1 + (_pulse.value * 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
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
    final border =
        selected
            ? AppColors.gold
            : highlighted
            ? AppColors.gold.withValues(alpha: 0.75)
            : AppColors.slateDark.withValues(alpha: 0.7);
    final radius = size == MiniCardSize.hero ? 10.0 : 8.0;
    final pad = (size == MiniCardSize.hero ? 4.0 : 3.0) * scale.clamp(1.0, 1.4);
    final child = AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      opacity: dimmed && !selected ? 0.38 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius * scale.clamp(1.0, 1.3)),
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
                  width: size.dimensions.width * scale,
                  height: size.dimensions.height * scale,
                )
                : MiniCard(card: card, size: size, scale: scale),
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
          borderRadius: BorderRadius.circular(radius),
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
    // Teach picker: fill tall-phone felt like BestFiveDemo SoftPulse.
    final densify = true;
    final feltHeight =
        densify ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final heroScale = densify ? 1.85 : 1.0;
    final boardScale = densify ? 1.4 : 1.0;

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
          Wrap(
            spacing: gap,
            runSpacing: gap,
            alignment: WrapAlignment.center,
            children: [
              for (final code in codes)
                SelectableBestFiveCard(
                  key: ValueKey<String>('best-five-$code'),
                  code: code,
                  selected: _selected.contains(code),
                  enabled: !widget.locked,
                  size: MiniCardSize.hero,
                  scale: cardScale,
                  onPressed: () => _toggle(code),
                ),
            ],
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final roomy = constraints.maxHeight >= 300;
                final hScale = roomy ? heroScale : 1.15;
                final bScale = roomy ? boardScale : 1.0;
                final cards = Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    labeledRow(
                      label: 'You',
                      codes: spot.heroCodes,
                      cardScale: hScale,
                      gap: roomy ? 14 : 10,
                    ),
                    labeledRow(
                      label: 'BOARD · shared',
                      codes: spot.boardCodes,
                      cardScale: bScale,
                      gap: roomy ? 10 : 8,
                    ),
                  ],
                );
                if (roomy) return cards;
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width - 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        labeledRow(
                          label: 'You',
                          codes: spot.heroCodes,
                          cardScale: hScale,
                          gap: 10,
                        ),
                        const SizedBox(height: 16),
                        labeledRow(
                          label: 'BOARD · shared',
                          codes: spot.boardCodes,
                          cardScale: bScale,
                          gap: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          statusLine(),
        ],
      ),
    );
  }
}
