/// Speech bubble that explains why Hint is off on this step.
///
/// The Hint button stays tappable when hints are intentionally disabled
/// (checkpoints, jump tests, steps whose cue already shows, no-hint steps):
/// a tap gives a light haptic and a short, friendly reason anchored to the
/// button. The bubble paints in the overlay (no layout shift) and goes away
/// after [LessonHintOffBubble.visibleFor] or on a tap anywhere else.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Wraps a tool button; [builder] gets the callback that shows [reason].
class LessonHintOffBubble extends StatefulWidget {
  /// Creates the bubble anchor.
  const LessonHintOffBubble({
    super.key,
    required this.reason,
    required this.builder,
  });

  /// Why Hint is off. Null: nothing to explain (the builder gets null).
  final String? reason;

  /// Builds the button; `showReason` is null when [reason] is null.
  final Widget Function(BuildContext context, VoidCallback? showReason) builder;

  /// How long the bubble stays up.
  static const Duration visibleFor = Duration(milliseconds: 2600);

  /// Key on the bubble (tests, screenshots).
  static const Key bubbleKey = ValueKey<String>('lesson-hint-off-bubble');

  @override
  State<LessonHintOffBubble> createState() => _LessonHintOffBubbleState();
}

class _LessonHintOffBubbleState extends State<LessonHintOffBubble> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  Timer? _timer;
  String? _shown;

  @override
  void didUpdateWidget(LessonHintOffBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new step (or Hint turning on) retires a stale reason.
    if (widget.reason != oldWidget.reason) _hide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show() {
    final reason = widget.reason;
    if (reason == null) return;
    unawaited(HapticFeedback.selectionClick());
    _timer?.cancel();
    _timer = Timer(LessonHintOffBubble.visibleFor, _hide);
    setState(() => _shown = reason);
    _portal.show();
  }

  void _hide() {
    _timer?.cancel();
    _timer = null;
    if (!mounted) return;
    if (_portal.isShowing) _portal.hide();
    if (_shown != null) setState(() => _shown = null);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) {
          final text = _shown;
          if (text == null) return const SizedBox.shrink();
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.bottomRight,
            offset: const Offset(0, -8),
            child: Align(
              alignment: Alignment.bottomRight,
              child: TapRegion(
                onTapOutside: (_) => _hide(),
                child: GestureDetector(
                  onTap: _hide,
                  child: _Bubble(text: text),
                ),
              ),
            ),
          );
        },
        child: widget.builder(context, widget.reason == null ? null : _show),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // Never wider than the phone minus the frame's side padding.
    final maxWidth = (MediaQuery.sizeOf(context).width - 32).clamp(
      160.0,
      260.0,
    );
    return Semantics(
      key: LessonHintOffBubble.bubbleKey,
      container: true,
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Material(
                color: AppColors.bgElevated,
                elevation: 6,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.7),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
                  child: Text(
                    text,
                    style: GoogleFonts.manrope(
                      color: AppColors.cream,
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: CustomPaint(
                size: const Size(16, 8),
                painter: _TailPainter(
                  fill: AppColors.bgElevated,
                  stroke: AppColors.gold.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  _TailPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, -1)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, -1);
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) =>
      old.fill != fill || old.stroke != stroke;
}
