/// Winding lesson path with Duolingo-style sticky unit banners and circular nodes.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

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
    final shadow = Color.lerp(base, Colors.black, 0.28)!;
    final eyebrow = 'SECTION $sectionOrder, UNIT $unitOrder';

    return Semantics(
      button: onTap != null,
      label: '$eyebrow. $unitTitle',
      hint: onTap == null ? null : 'Open section list',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Ink(
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: shadow,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 14, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eyebrow,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              unitTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onTap != null)
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 28,
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -7,
                child: Center(
                  child: CustomPaint(
                    size: const Size(18, 8),
                    painter: _BannerNotchPainter(color: base),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Downward tab under the sticky unit banner (Duolingo path cue).
class _BannerNotchPainter extends CustomPainter {
  const _BannerNotchPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BannerNotchPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Vertical winding path of course nodes.
class CoursePathView extends StatelessWidget {
  /// Creates the path.
  const CoursePathView({
    super.key,
    required this.nodes,
    required this.onNodeTap,
    this.sectionOrders = const {},
    this.sectionKeys = const {},
    this.unitKeys = const {},
  });

  final List<CourseMapNode> nodes;
  final void Function(CourseMapNode node) onNodeTap;

  /// Catalog `order` for each [CourseMapNode.sectionId], used for node accents.
  final Map<String, int> sectionOrders;

  /// Scroll anchors for each section id.
  final Map<String, GlobalKey> sectionKeys;

  /// Scroll / visibility anchors for each unit id (sticky banner).
  final Map<String, GlobalKey> unitKeys;

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    String? lastSectionId;
    String? lastUnitId;
    var pathIndex = 0;
    var isFirstUnit = true;

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final sectionOrder = sectionOrders[node.sectionId] ?? 1;
      final bannerColor = unitBannerColorForSection(sectionOrder);

      if (node.sectionId != lastSectionId) {
        lastSectionId = node.sectionId;
        lastUnitId = null;
        children.add(
          KeyedSubtree(
            key: sectionKeys[node.sectionId],
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
            key: unitKeys[node.unitId],
            child: showDivider
                ? Padding(
                    padding: const EdgeInsets.only(top: 28, bottom: 18),
                    child: _UnitPathMarker(title: node.unitTitle),
                  )
                : const SizedBox(height: 4),
          ),
        );
      }

      children.add(
        _PathNodeRow(
          node: node,
          pathIndex: pathIndex,
          accent: bannerColor,
          showConnector: i < nodes.length - 1 &&
              nodes[i + 1].unitId == node.unitId,
          onTap: () => onNodeTap(node),
        ),
      );
      pathIndex += 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
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

class _PathNodeRow extends StatelessWidget {
  const _PathNodeRow({
    required this.node,
    required this.pathIndex,
    required this.accent,
    required this.showConnector,
    required this.onTap,
  });

  final CourseMapNode node;
  final int pathIndex;
  final Color accent;
  final bool showConnector;
  final VoidCallback onTap;

  /// Zig-zag: center, right, center, left, …
  double get _alignmentX {
    return switch (pathIndex % 4) {
      0 => 0.0,
      1 => 0.42,
      2 => 0.0,
      _ => -0.42,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bubble = _NodeCircle(node: node, accent: accent);
    final labeled = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (node.isNext) ...[
          _StartChip(color: accent),
          const SizedBox(height: 6),
        ],
        if (node.isNext)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RexMascot(
              size: 52,
              mood: node.state == CourseNodeState.active
                  ? RexMood.celebrate
                  : RexMood.calm,
            ),
          ),
        bubble,
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          child: Text(
            node.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: node.state == CourseNodeState.locked
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

    return Column(
      children: [
        Align(
          alignment: Alignment(_alignmentX, 0),
          child: Semantics(
            button: true,
            enabled: true,
            label: node.semanticsLabel,
            hint: node.state == CourseNodeState.locked ? node.lockReason : null,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
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
        if (showConnector)
          SizedBox(
            height: 22,
            width: double.infinity,
            child: CustomPaint(
              painter: _PathDotPainter(
                fromX: _alignmentX,
                toX: _nextAlignmentX,
                color: node.isNext
                    ? accent.withValues(alpha: 0.55)
                    : AppColors.slateDark,
              ),
            ),
          ),
      ],
    );
  }

  double get _nextAlignmentX {
    return switch ((pathIndex + 1) % 4) {
      0 => 0.0,
      1 => 0.42,
      2 => 0.0,
      _ => -0.42,
    };
  }
}

class _StartChip extends StatelessWidget {
  const _StartChip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'START',
        style: GoogleFonts.manrope(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _NodeCircle extends StatelessWidget {
  const _NodeCircle({
    required this.node,
    required this.accent,
  });

  final CourseMapNode node;
  final Color accent;

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

    return SizedBox(
      width: 72,
      height: 70,
      child: Stack(
        alignment: Alignment.topCenter,
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
