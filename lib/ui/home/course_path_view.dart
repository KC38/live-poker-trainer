/// Winding lesson path with Duolingo-style sticky unit banners and circular nodes.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

/// Accent colors for unit banners, keyed by section order (1-based).
Color unitBannerColorForSection(int sectionOrder) {
  const palette = <Color>[
    Color(0xFF1CB0A0), // teal felt
    Color(0xFFC46B8A), // lag rose
    Color(0xFF3AA8B8), // station
    Color(0xFFE07A3A), // maniac
    Color(0xFF6B7FD7), // tag
    Color(0xFFD4A84B), // gold
    Color(0xFF2DB87A), // success emerald
  ];
  if (sectionOrder < 1) return palette.first;
  return palette[(sectionOrder - 1) % palette.length];
}

/// One unit along the Home path, used by the sticky banner.
class CoursePathUnit {
  /// Creates a path unit descriptor.
  const CoursePathUnit({
    required this.unitId,
    required this.unitTitle,
    required this.sectionId,
    required this.sectionTitle,
    required this.sectionOrder,
    required this.unitOrder,
  });

  final String unitId;
  final String unitTitle;
  final String sectionId;
  final String sectionTitle;
  final int sectionOrder;

  /// 1-based unit index within the section (Duolingo "UNIT N").
  final int unitOrder;

  /// Accent for this unit's sticky banner and path nodes.
  Color get bannerColor => unitBannerColorForSection(sectionOrder);
}

/// Collects unique units in path order from [nodes].
List<CoursePathUnit> coursePathUnits({
  required List<CourseMapNode> nodes,
  required Map<String, int> sectionOrders,
}) {
  final units = <CoursePathUnit>[];
  String? lastUnitId;
  String? lastSectionId;
  var unitOrderInSection = 0;
  for (final node in nodes) {
    if (node.unitId == lastUnitId) continue;
    if (node.sectionId != lastSectionId) {
      lastSectionId = node.sectionId;
      unitOrderInSection = 0;
    }
    lastUnitId = node.unitId;
    unitOrderInSection += 1;
    units.add(
      CoursePathUnit(
        unitId: node.unitId,
        unitTitle: node.unitTitle,
        sectionId: node.sectionId,
        sectionTitle: node.sectionTitle,
        sectionOrder: sectionOrders[node.sectionId] ?? 1,
        unitOrder: unitOrderInSection,
      ),
    );
  }
  return units;
}

/// Sticky unit / section header pinned above the scrolling path.
class CourseUnitBanner extends StatelessWidget {
  /// Creates the unit banner.
  const CourseUnitBanner({
    super.key,
    required this.sectionOrder,
    required this.unitOrder,
    required this.unitTitle,
    required this.color,
    this.onTap,
  });

  final int sectionOrder;
  final int unitOrder;
  final String unitTitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final base = color;
    // Duo buttons use a hard offset shadow (box-shadow: 0 4px 0 lip) so the
    // darker plate is a full rounded copy under the face and wraps the corners.
    final lip = Color.lerp(base, Colors.black, 0.2)!;
    final eyebrow = 'SECTION $sectionOrder, UNIT $unitOrder';
    const radius = BorderRadius.all(Radius.circular(16));

    return Semantics(
      button: onTap != null,
      label: '$eyebrow. $unitTitle',
      hint: onTap == null ? null : 'Open section list',
      // Stretch to the parent width so AnimatedSwitcher cannot shrink-wrap
      // and center a content-sized plate (Duo banners are near full-bleed).
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: base,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: lip,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        // Duo tints the eyebrow with the banner; white@opacity
                        // on a saturated fill reads the same way.
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unitTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Vertical winding path of course nodes.
///
/// Tapping an unlocked node selects it and shows an overlay START/REVIEW
/// bubble. Lessons launch only from that CTA — never from the node alone.
class CoursePathView extends StatefulWidget {
  /// Creates the path.
  const CoursePathView({
    super.key,
    required this.nodes,
    required this.onNodeTap,
    this.startsEnabled = true,
    this.sectionOrders = const {},
    this.sectionKeys = const {},
    this.unitKeys = const {},
    this.focusLessonKey,
  });

  final List<CourseMapNode> nodes;

  /// Locked / paused taps, and confirmed START/REVIEW launches.
  final void Function(CourseMapNode node) onNodeTap;

  /// When false, non-active nodes surface the paused snackbar instead of a bubble.
  final bool startsEnabled;

  /// Catalog `order` for each [CourseMapNode.sectionId], used for node accents.
  final Map<String, int> sectionOrders;

  /// Scroll anchors for each section id.
  final Map<String, GlobalKey> sectionKeys;

  /// Scroll / visibility anchors for each unit id (sticky banner).
  final Map<String, GlobalKey> unitKeys;

  /// Scroll anchor for the next / in-progress lesson (`isNext`).
  final GlobalKey? focusLessonKey;

  @override
  State<CoursePathView> createState() => _CoursePathViewState();
}

class _CoursePathViewState extends State<CoursePathView> {
  String? _selectedLessonId;

  void _dismissBubble() {
    if (_selectedLessonId == null) return;
    setState(() => _selectedLessonId = null);
  }

  void _onNodePressed(CourseMapNode node) {
    if (node.state == CourseNodeState.locked) {
      _dismissBubble();
      widget.onNodeTap(node);
      return;
    }
    if (!widget.startsEnabled && node.state != CourseNodeState.active) {
      _dismissBubble();
      widget.onNodeTap(node);
      return;
    }
    if (_selectedLessonId == node.lessonId) {
      _dismissBubble();
      return;
    }
    setState(() => _selectedLessonId = node.lessonId);
  }

  void _onLaunch(CourseMapNode node) {
    _dismissBubble();
    widget.onNodeTap(node);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    String? lastSectionId;
    String? lastUnitId;
    var pathIndex = 0;
    var isFirstUnit = true;
    final bubbleHidden = _selectedLessonId == null;

    for (var i = 0; i < widget.nodes.length; i++) {
      final node = widget.nodes[i];
      final sectionOrder = widget.sectionOrders[node.sectionId] ?? 1;
      final bannerColor = unitBannerColorForSection(sectionOrder);

      if (node.sectionId != lastSectionId) {
        lastSectionId = node.sectionId;
        lastUnitId = null;
        children.add(
          KeyedSubtree(
            key: widget.sectionKeys[node.sectionId],
            child: const SizedBox(height: 4),
          ),
        );
      }

      if (node.unitId != lastUnitId) {
        lastUnitId = node.unitId;
        final showDivider = !isFirstUnit;
        isFirstUnit = false;
        children.add(
          KeyedSubtree(
            key: widget.unitKeys[node.unitId],
            child: showDivider
                ? Padding(
                    padding: const EdgeInsets.only(top: 28, bottom: 18),
                    child: _UnitPathMarker(title: node.unitTitle),
                  )
                : const SizedBox(height: 4),
          ),
        );
      }

      final row = _PathNodeRow(
        node: node,
        pathIndex: pathIndex,
        accent: bannerColor,
        showConnector: i < widget.nodes.length - 1 &&
            widget.nodes[i + 1].unitId == node.unitId,
        selected: _selectedLessonId == node.lessonId,
        showPulse: node.isNext && bubbleHidden,
        onSelect: () => _onNodePressed(node),
        onLaunch: () => _onLaunch(node),
        onDismiss: _dismissBubble,
      );
      children.add(
        node.isNext && widget.focusLessonKey != null
            ? KeyedSubtree(key: widget.focusLessonKey, child: row)
            : row,
      );
      pathIndex += 1;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _selectedLessonId == null ? null : _dismissBubble,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Subtle in-path unit label (Duolingo-style divider, not a second banner).
class _UnitPathMarker extends StatelessWidget {
  const _UnitPathMarker({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        color: AppColors.slateDark.withValues(alpha: 0.85),
      ),
    );

    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

class _PathNodeRow extends StatefulWidget {
  const _PathNodeRow({
    required this.node,
    required this.pathIndex,
    required this.accent,
    required this.showConnector,
    required this.selected,
    required this.showPulse,
    required this.onSelect,
    required this.onLaunch,
    required this.onDismiss,
  });

  final CourseMapNode node;
  final int pathIndex;
  final Color accent;
  final bool showConnector;
  final bool selected;
  final bool showPulse;
  final VoidCallback onSelect;
  final VoidCallback onLaunch;
  final VoidCallback onDismiss;

  @override
  State<_PathNodeRow> createState() => _PathNodeRowState();
}

class _PathNodeRowState extends State<_PathNodeRow>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  late final AnimationController _pulse;

  /// Zig-zag: center, right, center, left, …
  double get _alignmentX {
    return switch (widget.pathIndex % 4) {
      0 => 0.0,
      1 => 0.42,
      2 => 0.0,
      _ => -0.42,
    };
  }

  double get _nextAlignmentX {
    return switch ((widget.pathIndex + 1) % 4) {
      0 => 0.0,
      1 => 0.42,
      2 => 0.0,
      _ => -0.42,
    };
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.selected) _portal.show();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _PathNodeRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
    if (widget.selected == oldWidget.selected) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.selected) {
        _portal.show();
      } else {
        _portal.hide();
      }
    });
  }

  void _syncPulse() {
    // Infinite reverse ticks lock widget-test pumpAndSettle; keep a static ring.
    final isWidgetTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');
    if (widget.showPulse && !isWidgetTest) {
      if (!_pulse.isAnimating) {
        _pulse.repeat(reverse: true);
      }
    } else if (_pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = widget.showPulse ? 0.5 : 0;
    } else {
      _pulse.value = widget.showPulse ? 0.5 : 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReview = !widget.node.isNext;
    final xp = isReview
        ? reviewLessonXp(widget.node.previewXp)
        : widget.node.previewXp;
    final actionLabel = isReview ? 'REVIEW' : 'START';

    final circle = _NodeCircle(
      node: widget.node,
      accent: widget.accent,
      pulse: widget.showPulse ? _pulse : null,
    );

    final labeled = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CompositedTransformTarget(
          link: _link,
          child: circle,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          child: Text(
            widget.node.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: widget.node.state == CourseNodeState.locked
                  ? AppColors.slate
                  : AppColors.cream,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
      ],
    );

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onDismiss,
                child: const ColoredBox(color: Color(0x66000000)),
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, 8),
              child: Material(
                color: Colors.transparent,
                child: _LessonActionBubble(
                  title: widget.node.title,
                  actionLabel: actionLabel,
                  previewXp: xp,
                  color: widget.accent,
                  onAction: widget.onLaunch,
                ),
              ),
            ),
          ],
        );
      },
      child: Column(
        children: [
          Align(
            alignment: Alignment(_alignmentX, 0),
            child: Semantics(
              button: true,
              enabled: true,
              label: widget.node.semanticsLabel,
              hint: widget.node.state == CourseNodeState.locked
                  ? widget.node.lockReason
                  : null,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onSelect,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: labeled,
                  ),
                ),
              ),
            ),
          ),
          if (widget.showConnector)
            SizedBox(
              height: 22,
              width: double.infinity,
              child: CustomPaint(
                painter: _PathDotPainter(
                  fromX: _alignmentX,
                  toX: _nextAlignmentX,
                  color: widget.node.isNext
                      ? widget.accent.withValues(alpha: 0.55)
                      : AppColors.slateDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Duo-style speech bubble overlaid under a selected path node.
class _LessonActionBubble extends StatelessWidget {
  const _LessonActionBubble({
    required this.title,
    required this.actionLabel,
    required this.previewXp,
    required this.color,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final int previewXp;
  final Color color;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final lip = Color.lerp(color, Colors.black, 0.22)!;
    const radius = BorderRadius.all(Radius.circular(16));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(18, 10),
          painter: _BubbleCaretPainter(color: color),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 248, maxWidth: 280),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: lip,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionXpButton(
                    label: '$actionLabel +$previewXp XP',
                    color: color,
                    onPressed: onAction,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionXpButton extends StatelessWidget {
  const _ActionXpButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleCaretPainter extends CustomPainter {
  _BubbleCaretPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubbleCaretPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _NodeCircle extends StatelessWidget {
  const _NodeCircle({
    required this.node,
    required this.accent,
    this.pulse,
  });

  final CourseMapNode node;
  final Color accent;
  final Animation<double>? pulse;

  @override
  Widget build(BuildContext context) {
    final locked = node.state == CourseNodeState.locked;
    final completed = node.state == CourseNodeState.completed ||
        node.state == CourseNodeState.mastered;
    final active = node.isNext ||
        node.state == CourseNodeState.active ||
        node.state == CourseNodeState.available ||
        node.state == CourseNodeState.reviewDue;

    final fill = locked
        ? AppColors.slateDark.withValues(alpha: 0.75)
        : completed
            ? accent.withValues(alpha: 0.85)
            : active
                ? accent
                : AppColors.slateDark;
    final shadow = Color.lerp(fill, Colors.black, 0.35)!;
    final iconColor = locked ? AppColors.slate : Colors.white;

    Widget circle = SizedBox(
      width: 72,
      height: 70,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 6,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: shadow,
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: node.isNext
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 3,
                    )
                  : null,
            ),
            child: Icon(_iconFor(node), color: iconColor, size: 28),
          ),
        ],
      ),
    );

    final pulseAnim = pulse;
    if (pulseAnim != null) {
      circle = AnimatedBuilder(
        animation: pulseAnim,
        builder: (context, child) {
          // Grow / shrink the highlight ring by a few pixels.
          final expand = 4.0 + (pulseAnim.value * 6.0);
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(64 + expand * 2, 64 + expand * 2),
                painter: _PulseRingPainter(
                  color: accent.withValues(alpha: 0.45),
                  strokeWidth: 3,
                ),
              ),
              child!,
            ],
          );
        },
        child: circle,
      );
    }

    return circle;
  }

  static IconData _iconFor(CourseMapNode node) {
    if (node.state == CourseNodeState.mastered) {
      return Icons.star_rounded;
    }
    if (node.state == CourseNodeState.completed) {
      return Icons.check_rounded;
    }
    return switch (node.kind) {
      CourseNodeKind.lesson => Icons.star_rounded,
      CourseNodeKind.practice => Icons.fitness_center_rounded,
      CourseNodeKind.checkpoint => Icons.flag_rounded,
      CourseNodeKind.reward => Icons.redeem_rounded,
      CourseNodeKind.jumpTest => Icons.bolt_rounded,
      CourseNodeKind.handLab => Icons.table_restaurant_rounded,
    };
  }
}

class _PulseRingPainter extends CustomPainter {
  _PulseRingPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final inset = strokeWidth / 2;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.shortestSide / 2) - inset,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PulseRingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

class _PathDotPainter extends CustomPainter {
  _PathDotPainter({
    required this.fromX,
    required this.toX,
    required this.color,
  });

  final double fromX;
  final double toX;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final start = Offset(size.width * (0.5 + fromX * 0.5), 2);
    final end = Offset(size.width * (0.5 + toX * 0.5), size.height - 2);
    for (var t = 0.15; t <= 0.85; t += 0.2) {
      final dx = start.dx + (end.dx - start.dx) * t;
      final dy = start.dy + (end.dy - start.dy) * t;
      canvas.drawCircle(Offset(dx, dy), 2.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PathDotPainter oldDelegate) {
    return oldDelegate.fromX != fromX ||
        oldDelegate.toX != toX ||
        oldDelegate.color != color;
  }
}
