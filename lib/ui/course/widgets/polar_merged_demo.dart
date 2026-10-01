import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';

/// Polar/merged explain: POLAR / MERGED / SIZE under the full poker table.
class LessonPolarMergedExplainTable extends StatefulWidget {
  /// Creates the explain stage.
  const LessonPolarMergedExplainTable({
    super.key,
    required this.onAllPointsTapped,
    this.enabled = true,
    this.showGuidance = true,
  });

  final VoidCallback? onAllPointsTapped;
  final bool enabled;
  final bool showGuidance;

  @override
  State<LessonPolarMergedExplainTable> createState() =>
      _LessonPolarMergedExplainTableState();
}

class _LessonPolarMergedExplainTableState
    extends State<LessonPolarMergedExplainTable> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= PolarMergedDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final teaching = widget.enabled && widget.onAllPointsTapped != null;
    return Column(
      key: const ValueKey<String>('polar-merged-table'),
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
          spacing: GlowHighlight.gutter,
          runSpacing: GlowHighlight.gutter,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < PolarMergedDemo.points.length; i++)
              SizedBox(
                width: 150,
                child: GlowHighlight(
                  active:
                      teaching &&
                      widget.showGuidance &&
                      !_tapped.contains(
                        PolarMergedDemo.points[i].label,
                      ) &&
                      PolarMergedDemo.points
                          .take(i)
                          .every((p) => _tapped.contains(p.label)),
                  child: _PolarTile(
                    label: PolarMergedDemo.points[i].label,
                    caption: PolarMergedDemo.points[i].caption,
                    color: PolarMergedDemo.points[i].color,
                    densify: false,
                    selected: _tapped.contains(
                      PolarMergedDemo.points[i].label,
                    ),
                    enabled: teaching,
                    onPressed:
                        teaching
                            ? () => _onTap(
                                  PolarMergedDemo.points[i].label,
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

/// Polar / merged / size tiles for polar-vs-merged explain demos.
class PolarMergedDemo extends StatefulWidget {
  /// Creates the demo.
  const PolarMergedDemo({
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
    (label: 'POLAR', caption: 'Nuts or air', color: AppColors.gold),
    (label: 'MERGED', caption: 'Medium-strong', color: AppColors.cream),
    (label: 'SIZE', caption: 'Size accordingly', color: AppColors.danger),
  ];

  @override
  State<PolarMergedDemo> createState() => _PolarMergedDemoState();
}

class _PolarMergedDemoState extends State<PolarMergedDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= PolarMergedDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in PolarMergedDemo.points) {
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
    // sparse green under POLAR / MERGED / SIZE).
    final feltHeight =
        widget.height ??
        (expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null);
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < PolarMergedDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: GlowHighlight.gutter),
          Expanded(
            child: GlowHighlight(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == PolarMergedDemo.points[i].label,
              child: _PolarTile(
                label: PolarMergedDemo.points[i].label,
                caption: PolarMergedDemo.points[i].caption,
                color: PolarMergedDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(PolarMergedDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(PolarMergedDemo.points[i].label)
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
                'Nuts/air vs medium-strong',
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
          'Polar vs merged',
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

class _PolarTile extends StatelessWidget {
  const _PolarTile({
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
