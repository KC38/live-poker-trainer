/// Outs teach-by-doing: SoftPulse the remaining clean-ace cards.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_best_five.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Felt picker: tap the three remaining aces (clean outs) on the king-high flop.
///
/// Dirty queens and a "none" tile remain as traps — matching authored choices
/// `outs-3` / `outs-6` / `outs-0` without a text MCQ strip.
class OutsCleanAcesPicker extends StatefulWidget {
  /// Creates the outs ace picker.
  const OutsCleanAcesPicker({
    super.key,
    required this.activity,
    required this.controller,
    required this.locked,
    this.showGuidance = true,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool locked;
  final bool showGuidance;

  /// Spot cards — hero already holds Ah.
  static const heroCodes = ['Ah', 'Qh'];
  static const boardCodes = ['Kc', '8h', '2d'];

  /// SoftPulse order for the three clean outs.
  static const cleanOrder = ['As', 'Ad', 'Ac'];

  /// Dirty distractors (pair under king-high).
  static const dirtyCodes = ['Qs', 'Qd'];

  @override
  State<OutsCleanAcesPicker> createState() => _OutsCleanAcesPickerState();
}

class _OutsCleanAcesPickerState extends State<OutsCleanAcesPicker> {
  final Set<String> _tappedClean = <String>{};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void didUpdateWidget(covariant OutsCleanAcesPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
      _tappedClean.clear();
    }
    if (oldWidget.activity.id != widget.activity.id) {
      _tappedClean.clear();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    // Try again clears draft — restore SoftPulse from the first ace.
    if (widget.controller.draft.choiceId == null && _tappedClean.isNotEmpty) {
      setState(_tappedClean.clear);
    }
  }

  String? get _nextClean {
    for (final code in OutsCleanAcesPicker.cleanOrder) {
      if (!_tappedClean.contains(code)) return code;
    }
    return null;
  }

  void _onCleanTap(String code) {
    if (widget.locked) return;
    if (!OutsCleanAcesPicker.cleanOrder.contains(code)) return;
    if (_tappedClean.contains(code)) return;
    setState(() => _tappedClean.add(code));
    if (_tappedClean.length >= OutsCleanAcesPicker.cleanOrder.length) {
      _submit('outs-3');
    }
  }

  void _onDirtyTap() {
    if (widget.locked) return;
    _submit('outs-6');
  }

  void _onNoneTap() {
    if (widget.locked) return;
    _submit('outs-0');
  }

  void _submit(String choiceId) {
    final known = widget.activity.choices.any((c) => c.id == choiceId);
    if (!known) return;
    widget.controller.selectChoice(choiceId, autoSubmit: true);
  }

  @override
  Widget build(BuildContext context) {
    final feltHeight = MediaQuery.sizeOf(context).height * 0.58;
    final next = _nextClean;
    final guide = widget.showGuidance && !widget.locked;

    Widget spotRow({
      required String label,
      required List<String> codes,
      required MiniCardSize size,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < codes.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  MiniCard(
                    card: CardModel.fromCode(codes[i]),
                    size: size,
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    Widget outsRow() {
      final codes = [
        ...OutsCleanAcesPicker.cleanOrder,
        ...OutsCleanAcesPicker.dirtyCodes,
      ];
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < codes.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Builder(
                builder: (context) {
                  final code = codes[i];
                  final isClean =
                      OutsCleanAcesPicker.cleanOrder.contains(code);
                  final selected = _tappedClean.contains(code);
                  final isNext = guide && isClean && code == next;
                  return _SoftPulseTarget(
                    active: isNext,
                    child: SelectableBestFiveCard(
                      key: ValueKey<String>('outs-ace-$code'),
                      code: code,
                      selected: selected,
                      highlighted: isNext,
                      enabled: !widget.locked,
                      size: MiniCardSize.small,
                      scale: 1.6,
                      onPressed:
                          widget.locked
                              ? null
                              : () {
                                if (isClean) {
                                  _onCleanTap(code);
                                } else {
                                  _onDirtyTap();
                                }
                              },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      );
    }

    final noneTile = Semantics(
      button: true,
      label: 'No clean outs',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.locked ? null : _onNoneTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.slateDark.withValues(alpha: 0.75),
              ),
              color: AppColors.feltDark.withValues(alpha: 0.45),
            ),
            child: Text(
              'No clean outs',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );

    final teach = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        spotRow(
          label: 'BOARD · shared',
          codes: OutsCleanAcesPicker.boardCodes,
          size: MiniCardSize.small,
        ),
        const SizedBox(height: 8),
        Text(
          'Flop · clean outs?',
          style: GoogleFonts.manrope(
            color: AppColors.gold.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        spotRow(
          label: 'You',
          codes: OutsCleanAcesPicker.heroCodes,
          size: MiniCardSize.small,
        ),
        const SizedBox(height: 12),
        Text(
          'Select every clean out',
          style: GoogleFonts.manrope(
            color: AppColors.cream,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        outsRow(),
        const SizedBox(height: 12),
        noneTile,
      ],
    );

    return Container(
      key: const ValueKey('outs-clean-aces-felt'),
      width: double.infinity,
      height: feltHeight,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
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
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width - 48,
            child: teach,
          ),
        ),
      ),
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
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = widget.active ? _pulse.value : 0.0;
        return Transform.scale(
          scale: 1 + (0.035 * t),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  widget.active
                      ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(
                            alpha: 0.18 + 0.22 * t,
                          ),
                          blurRadius: 10 + 8 * t,
                          spreadRadius: 0.5 + t,
                        ),
                      ]
                      : null,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
