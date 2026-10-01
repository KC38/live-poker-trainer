import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';

/// Range-advantage explain: RANGE / NUT / ADVANTAGE under the full poker table.
class LessonRangeAdvantageExplainTable extends StatefulWidget {
  /// Creates the explain stage.
  const LessonRangeAdvantageExplainTable({
    super.key,
    required this.onAllPointsTapped,
    this.enabled = true,
    this.showGuidance = true,
  });

  final VoidCallback? onAllPointsTapped;
  final bool enabled;
  final bool showGuidance;

  @override
  State<LessonRangeAdvantageExplainTable> createState() =>
      _LessonRangeAdvantageExplainTableState();
}

class _LessonRangeAdvantageExplainTableState
    extends State<LessonRangeAdvantageExplainTable> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= RangeAdvantageDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final teaching = widget.enabled && widget.onAllPointsTapped != null;
    return Column(
      key: const ValueKey<String>('range-advantage-table'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LessonTableStage(
            heroCodes: const ['Ah', 'Kd'],
            boardCodes: const [],
            villainCount: 3,
            heroFaceUp: true,
            enabled: false,
            features: lessonPassiveActionsTableFeatures,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < RangeAdvantageDemo.points.length; i++)
              SizedBox(
                width: 150,
                child: GlowHighlight(
                  active:
                      teaching &&
                      widget.showGuidance &&
                      !_tapped.contains(
                        RangeAdvantageDemo.points[i].label,
                      ) &&
                      RangeAdvantageDemo.points
                          .take(i)
                          .every((p) => _tapped.contains(p.label)),
                  child: _RangeAdvantageTile(
                    label: RangeAdvantageDemo.points[i].label,
                    caption: RangeAdvantageDemo.points[i].caption,
                    color: RangeAdvantageDemo.points[i].color,
                    densify: false,
                    selected: _tapped.contains(
                      RangeAdvantageDemo.points[i].label,
                    ),
                    enabled: teaching,
                    onPressed:
                        teaching
                            ? () => _onTap(
                                  RangeAdvantageDemo.points[i].label,
                                )
                            : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Range / nut / advantage tiles for range-advantage explain demos.
class RangeAdvantageDemo extends StatefulWidget {
  /// Creates the demo.
  const RangeAdvantageDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
    this.height,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  /// Stage height when the lesson frame already owns the chrome.
  ///
  /// Null keeps the standalone teach shell at 58% of the screen.
  final double? height;

  static const points = <({String label, String caption, Color color})>[
    (label: 'RANGE', caption: 'Strong hands overall', color: AppColors.gold),
    (label: 'NUT', caption: 'More of the nuts', color: AppColors.cream),
    (label: 'ADVANTAGE', caption: 'Own the edge', color: AppColors.danger),
  ];

  @override
  State<RangeAdvantageDemo> createState() => _RangeAdvantageDemoState();
}

class _RangeAdvantageDemoState extends State<RangeAdvantageDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= RangeAdvantageDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in RangeAdvantageDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under RANGE / NUT / ADVANTAGE).
    final feltHeight =
        widget.height ??
        (expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null);
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < RangeAdvantageDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: GlowHighlight(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == RangeAdvantageDemo.points[i].label,
              child: _RangeAdvantageTile(
                label: RangeAdvantageDemo.points[i].label,
                caption: RangeAdvantageDemo.points[i].caption,
                color: RangeAdvantageDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(RangeAdvantageDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(RangeAdvantageDemo.points[i].label)
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-tile cue while teaching. Show a summary
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
                'More strong hands overall',
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
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Range & nut advantage',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
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

class _RangeAdvantageTile extends StatelessWidget {
  const _RangeAdvantageTile({
    required this.label,
    required this.caption,
    required this.color,
    this.densify = false,
    this.selected = false,
    this.enabled = false,
    this.onPressed,
  });

  final String label;
  final String caption;
  final Color color;
  final bool densify;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.gold : color.withValues(alpha: 0.9);
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: densify ? double.infinity : null,
      padding: EdgeInsets.symmetric(
        vertical: densify ? 24 : 12,
        horizontal: densify ? 10 : 6,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.28)
            : color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(densify ? 16 : 12),
        border: Border.all(color: borderColor, width: selected ? 2.5 : 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: densify ? 18 : 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: densify ? 10 : 4),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.cream.withValues(alpha: 0.9),
              fontSize: densify ? 13 : 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    final child = densify ? SizedBox.expand(child: card) : card;
    if (onPressed == null) return child;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(densify ? 16 : 12),
          child: child,
        ),
      ),
    );
  }
}
