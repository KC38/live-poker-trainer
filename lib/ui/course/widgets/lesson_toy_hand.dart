/// Felt visuals for Play a full toy hand — blinds → act → ending.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';

/// Features for toy-hand explain on the full table.
TableFeatures get lessonToyHandTableFeatures => const TableFeatures(
  stacks: false,
  pot: true,
  street: false,
  blinds: true,
  positions: true,
  bets: false,
  actions: false,
  opponentCards: false,
  playerTypes: false,
  stats: false,
  boardSlots: false,
);

/// Full table: tap Blinds / You act / Ending under the felt.
class LessonToyHandExplainTable extends StatefulWidget {
  /// Creates the explain stage.
  const LessonToyHandExplainTable({
    super.key,
    required this.onAllStepsTapped,
    this.enabled = true,
    this.showGuidance = true,
  });

  final VoidCallback? onAllStepsTapped;
  final bool enabled;
  final bool showGuidance;

  static const steps = ['BLINDS', 'YOU ACT', 'ENDING'];

  @override
  State<LessonToyHandExplainTable> createState() =>
      _LessonToyHandExplainTableState();
}

class _LessonToyHandExplainTableState extends State<LessonToyHandExplainTable> {
  final Set<String> _tapped = <String>{};

  void _onTap(String title) {
    if (!widget.enabled || widget.onAllStepsTapped == null) return;
    setState(() => _tapped.add(title));
    if (_tapped.length >= LessonToyHandExplainTable.steps.length) {
      widget.onAllStepsTapped!();
    }
  }

  int? get _nextIndex {
    for (var i = 0; i < LessonToyHandExplainTable.steps.length; i++) {
      if (!_tapped.contains(LessonToyHandExplainTable.steps[i])) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final teaching = widget.enabled && widget.onAllStepsTapped != null;
    final next = _nextIndex;
    final stepIndex = next ?? LessonToyHandExplainTable.steps.length - 1;
    final board = switch (stepIndex) {
      0 => const <String>[],
      1 => const <String>[],
      _ => const ['Qs', '7c', '2d'],
    };
    return Column(
      key: const ValueKey<String>('toy-hand-table'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LessonTableStage(
            heroCodes: const ['Ah', 'Kd'],
            boardCodes: board,
            villainCount: lessonBlindsVillainCount,
            dealerIndex: lessonBlindsButtonIndex,
            sbIndex: lessonBlindsSmallBlindIndex,
            bbIndex: lessonBlindsBigBlindIndex,
            heroFaceUp: stepIndex >= 1,
            enabled: false,
            features: lessonToyHandTableFeatures,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: GlowHighlight.gutter,
          runSpacing: GlowHighlight.gutter,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < LessonToyHandExplainTable.steps.length; i++)
              GlowHighlight(
                active: teaching && widget.showGuidance && next == i,
                child: _UnderFeltBeatChip(
                  label: LessonToyHandExplainTable.steps[i],
                  selected: _tapped.contains(LessonToyHandExplainTable.steps[i]),
                  enabled: teaching,
                  onPressed:
                      teaching
                          ? () => _onTap(LessonToyHandExplainTable.steps[i])
                          : null,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _UnderFeltBeatChip extends StatelessWidget {
  const _UnderFeltBeatChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final border =
        selected ? AppColors.gold : AppColors.feltBorder.withValues(alpha: 0.7);
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.bgDark.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: selected ? 2 : 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: AppColors.cream,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    if (onPressed == null) return child;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}

/// Explain-step demo: one short hand from blinds to a finish.
class ToyHandRunDemo extends StatefulWidget {
  /// Creates the demo.
  const ToyHandRunDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllStepsTapped,
    this.height,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllStepsTapped;

  /// Stage height when the lesson frame already owns the chrome.
  ///
  /// Null keeps the standalone teach shell at 58% of the screen.
  final double? height;

  @override
  State<ToyHandRunDemo> createState() => _ToyHandRunDemoState();
}

class _ToyHandRunDemoState extends State<ToyHandRunDemo> {
  final Set<String> _tapped = <String>{};
  static const _titles = ['BLINDS', 'YOU ACT', 'ENDING'];

  void _onTap(String title) {
    if (!widget.enabled || widget.onAllStepsTapped == null) return;
    setState(() => _tapped.add(title));
    if (_tapped.length >= _titles.length) {
      widget.onAllStepsTapped!();
    }
  }

  int? get _nextIndex {
    for (var i = 0; i < _titles.length; i++) {
      if (!_tapped.contains(_titles[i])) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextIndex;
    // Keep densify after the last step while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    final feltHeight =
        widget.height ??
        (expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null);
    final lanes = <(String, String, Widget)>[
      (
        'BLINDS',
        'SB and BB post — pot starts',
        const _BlindDots(),
      ),
      (
        'YOU ACT',
        'Open, call, or fold on a street',
        const _HeroMini(),
      ),
      (
        'ENDING',
        'Folds win it — or keep going',
        const _PotEndChip(),
      ),
    ];

    Widget laneAt(int i) {
      return GlowHighlight(
        active:
            widget.interactive && widget.enabled && next == i,
        child: _RunLane(
          step: i + 1,
          title: lanes[i].$1,
          detail: lanes[i].$2,
          visual: lanes[i].$3,
          selected: _tapped.contains(lanes[i].$1),
          enabled: widget.interactive && widget.enabled,
          densify: expandTeach,
          onPressed:
              widget.interactive ? () => _onTap(lanes[i].$1) : null,
        ),
      );
    }

    final runLanes = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var i = 0; i < lanes.length; i++) ...[
          if (i > 0) SizedBox(height: expandTeach ? 10 : 8),
          if (expandTeach) Expanded(child: laneAt(i)) else laneAt(i),
        ],
      ],
    );
    // SoftPulse + Rex own the next-step cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                widget.interactive
                    ? 'Blinds · You act · Ending'
                    : 'Blinds post, you act, then finish',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.start
              : MainAxisAlignment.start,
      children: [
        Text(
          'One short hand',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 12),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: runLanes,
              ),
            )
            : runLanes,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 12),
          cue,
        ],
      ],
    );
    final child = Container(
      key: const ValueKey('toy-hand-felt'),
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

class _RunLane extends StatelessWidget {
  const _RunLane({
    required this.step,
    required this.title,
    required this.detail,
    required this.visual,
    this.selected = false,
    this.enabled = false,
    this.densify = false,
    this.onPressed,
  });

  final int step;
  final String title;
  final String detail;
  final Widget visual;
  final bool selected;
  final bool enabled;
  final bool densify;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final border =
        selected ? AppColors.gold : AppColors.feltBorder.withValues(alpha: 0.7);
    final pad = densify ? 16.0 : 10.0;
    final titleSize = densify ? 16.0 : 13.0;
    final detailSize = densify ? 13.0 : 11.0;
    final stepSize = densify ? 32.0 : 26.0;
    final lane = Container(
      width: densify ? double.infinity : null,
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad),
      alignment: densify ? Alignment.centerLeft : null,
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.feltDark.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: selected ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: stepSize,
            height: stepSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.22),
              border: Border.all(color: AppColors.gold, width: 1.4),
            ),
            child: Text(
              '$step',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: densify ? 14 : 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: densify ? 14 : 10),
          Expanded(
            child: densify
                ? LayoutBuilder(
                  builder: (context, constraints) {
                    final column = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.manrope(
                            color: AppColors.cream,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          detail,
                          style: GoogleFonts.manrope(
                            color: AppColors.slate,
                            fontSize: detailSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                    if (constraints.maxHeight < 48) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: column,
                        ),
                      );
                    }
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: column,
                    );
                  },
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        color: AppColors.cream,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      detail,
                      style: GoogleFonts.manrope(
                        color: AppColors.slate,
                        fontSize: detailSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
          ),
          SizedBox(width: GlowHighlight.gutter),
          densify ? Transform.scale(scale: 1.35, child: visual) : visual,
        ],
      ),
    );
    if (onPressed == null) return lane;
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: lane,
        ),
      ),
    );
  }
}

class _BlindDots extends StatelessWidget {
  const _BlindDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _chip('1'),
        const SizedBox(width: 4),
        _chip('2'),
      ],
    );
  }

  Widget _chip(String amount) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold.withValues(alpha: 0.3),
        border: Border.all(color: AppColors.gold, width: 1.3),
      ),
      child: Text(
        amount,
        style: GoogleFonts.manrope(
          color: AppColors.gold,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeroMini extends StatelessWidget {
  const _HeroMini();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final code in const ['Ah', '9h']) ...[
          MiniCard(card: CardModel.fromCode(code), size: MiniCardSize.tiny),
          const SizedBox(width: 2),
        ],
      ],
    );
  }
}

class _PotEndChip extends StatelessWidget {
  const _PotEndChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.75)),
      ),
      child: Text(
        'POT',
        style: GoogleFonts.manrope(
          color: AppColors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
