/// Winding lesson path with section/unit banners and node states.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';

/// Vertical winding path of course nodes.
class CoursePathView extends StatelessWidget {
  /// Creates the path.
  const CoursePathView({
    super.key,
    required this.nodes,
    required this.onNodeTap,
  });

  final List<CourseMapNode> nodes;
  final void Function(CourseMapNode node) onNodeTap;

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    String? lastSectionId;
    String? lastUnitId;

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.sectionId != lastSectionId) {
        lastSectionId = node.sectionId;
        lastUnitId = null;
        children.add(
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 22, bottom: 8),
            child: Text(
              node.sectionTitle,
              style: GoogleFonts.cinzel(
                color: AppColors.goldBright,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }
      if (node.unitId != lastUnitId) {
        lastUnitId = node.unitId;
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: Text(
              node.unitTitle.toUpperCase(),
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
        );
      }

      final alignLeft = i.isEven;
      children.add(
        _PathNodeRow(
          node: node,
          alignLeft: alignLeft,
          showConnector: i < nodes.length - 1,
          onTap: () => onNodeTap(node),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _PathNodeRow extends StatelessWidget {
  const _PathNodeRow({
    required this.node,
    required this.alignLeft,
    required this.showConnector,
    required this.onTap,
  });

  final CourseMapNode node;
  final bool alignLeft;
  final bool showConnector;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bubble = _NodeBubble(node: node, onTap: onTap);
    return Column(
      children: [
        Row(
          children: [
            if (!alignLeft) const Spacer(flex: 2),
            Expanded(flex: 5, child: bubble),
            if (alignLeft) const Spacer(flex: 2),
          ],
        ),
        if (showConnector)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: CustomPaint(
              size: const Size(double.infinity, 28),
              painter: _PathConnectorPainter(
                toLeft: !alignLeft,
                emphasized: node.isNext,
              ),
            ),
          ),
      ],
    );
  }
}

class _NodeBubble extends StatelessWidget {
  const _NodeBubble({required this.node, required this.onTap});

  final CourseMapNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(node.state);
    final icon = _iconFor(node.kind);
    final locked = node.state == CourseNodeState.locked;

    return Semantics(
      button: true,
      enabled: true,
      label: node.semanticsLabel,
      hint: locked ? node.lockReason : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: node.isNext ? AppColors.gold : colors.border,
                width: node.isNext ? 2 : 1,
              ),
              boxShadow: node.isNext
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.iconBackground,
                  ),
                  child: Icon(icon, color: colors.icon, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (node.isNext)
                        Text(
                          'NEXT',
                          style: GoogleFonts.manrope(
                            color: AppColors.goldBright,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      Text(
                        node.title,
                        style: GoogleFonts.manrope(
                          color: colors.title,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        locked
                            ? (node.lockReason ?? 'Locked')
                            : _stateCaption(node),
                        style: GoogleFonts.manrope(
                          color: AppColors.slate,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _stateCaption(CourseMapNode node) {
    return switch (node.state) {
      CourseNodeState.available => _kindCaption(node.kind),
      CourseNodeState.active => 'In progress',
      CourseNodeState.completed => 'Completed',
      CourseNodeState.mastered => 'Mastered',
      CourseNodeState.reviewDue => 'Review due',
      CourseNodeState.locked => 'Locked',
    };
  }

  static String _kindCaption(CourseNodeKind kind) {
    return switch (kind) {
      CourseNodeKind.lesson => 'Lesson',
      CourseNodeKind.practice => 'Practice',
      CourseNodeKind.checkpoint => 'Checkpoint',
      CourseNodeKind.reward => 'Reward',
      CourseNodeKind.jumpTest => 'Jump test',
      CourseNodeKind.handLab => 'Hand lab',
    };
  }

  static IconData _iconFor(CourseNodeKind kind) {
    return switch (kind) {
      CourseNodeKind.lesson => Icons.menu_book_outlined,
      CourseNodeKind.practice => Icons.fitness_center_outlined,
      CourseNodeKind.checkpoint => Icons.flag_outlined,
      CourseNodeKind.reward => Icons.emoji_events_outlined,
      CourseNodeKind.jumpTest => Icons.bolt_outlined,
      CourseNodeKind.handLab => Icons.table_restaurant_outlined,
    };
  }

  static ({
    Color background,
    Color border,
    Color icon,
    Color iconBackground,
    Color title,
  }) _colorsFor(CourseNodeState state) {
    return switch (state) {
      CourseNodeState.locked => (
          background: AppColors.bgElevated.withValues(alpha: 0.35),
          border: AppColors.slateDark,
          icon: AppColors.slate,
          iconBackground: AppColors.slateDark.withValues(alpha: 0.55),
          title: AppColors.slate,
        ),
      CourseNodeState.available => (
          background: AppColors.bgElevated.withValues(alpha: 0.72),
          border: AppColors.slateDark,
          icon: AppColors.cream,
          iconBackground: AppColors.feltLight.withValues(alpha: 0.55),
          title: AppColors.cream,
        ),
      CourseNodeState.active => (
          background: AppColors.feltDark.withValues(alpha: 0.65),
          border: AppColors.gold,
          icon: AppColors.goldBright,
          iconBackground: AppColors.gold.withValues(alpha: 0.2),
          title: AppColors.cream,
        ),
      CourseNodeState.completed => (
          background: AppColors.bgElevated.withValues(alpha: 0.6),
          border: AppColors.success.withValues(alpha: 0.45),
          icon: AppColors.success,
          iconBackground: AppColors.success.withValues(alpha: 0.15),
          title: AppColors.cream,
        ),
      CourseNodeState.mastered => (
          background: AppColors.bgElevated.withValues(alpha: 0.7),
          border: AppColors.gold.withValues(alpha: 0.55),
          icon: AppColors.goldBright,
          iconBackground: AppColors.gold.withValues(alpha: 0.18),
          title: AppColors.cream,
        ),
      CourseNodeState.reviewDue => (
          background: AppColors.warning.withValues(alpha: 0.12),
          border: AppColors.warning.withValues(alpha: 0.55),
          icon: AppColors.warning,
          iconBackground: AppColors.warning.withValues(alpha: 0.18),
          title: AppColors.cream,
        ),
    };
  }
}

class _PathConnectorPainter extends CustomPainter {
  _PathConnectorPainter({required this.toLeft, required this.emphasized});

  final bool toLeft;
  final bool emphasized;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = emphasized
          ? AppColors.gold.withValues(alpha: 0.55)
          : AppColors.slateDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * (toLeft ? 0.72 : 0.28), 0);
    final end = Offset(size.width * (toLeft ? 0.28 : 0.72), size.height);
    final control = Offset(size.width * 0.5, size.height * 0.5);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathConnectorPainter oldDelegate) {
    return oldDelegate.toLeft != toLeft ||
        oldDelegate.emphasized != emphasized;
  }
}
