/// Felt-style last-action pill shared by villain seats and the hero rail.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Pops a seat's most recent action so the replay reads as live play.
class ActionBadge extends StatefulWidget {
  /// Creates an action badge for [label] (e.g. CHECK, CALL, RAISE).
  const ActionBadge({super.key, required this.label});

  /// Raw action label from the engine / live view.
  final String label;

  /// Normalizes server and client labels to a short uppercase pill.
  static String displayLabel(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.toUpperCase().replaceAll('_', '-');
  }

  /// Text style used by the painted pill.
  static TextStyle textStyle() => GoogleFonts.jetBrainsMono(
    fontSize: 8.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
    color: AppColors.bgDark,
  );

  /// Pill size for [label], measured the way it paints.
  static Size sizeFor(String label) {
    final text = TextPainter(
      text: TextSpan(text: displayLabel(label), style: textStyle()),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return Size(text.width + 12, text.height + 2);
  }

  /// True when [label] is a check (no chips — belongs on the bet spot).
  static bool isCheck(String? label) {
    if (label == null) return false;
    return displayLabel(label) == 'CHECK';
  }

  @override
  State<ActionBadge> createState() => _ActionBadgeState();
}

class _ActionBadgeState extends State<ActionBadge> {
  double _scale = 0.7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _scale = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = ActionBadge.displayLabel(widget.label);
    final color = switch (label) {
      'FOLD' => AppColors.slate,
      // CHECK used to share FOLD's slate and disappeared into the felt;
      // cream keeps a passive action readable without looking aggressive.
      'CHECK' => AppColors.cream,
      'BLIND' => AppColors.goldMuted,
      'CALL' || 'CALL ALL-IN' => AppColors.warning,
      _ => AppColors.danger,
    };
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: ActionBadge.textStyle(),
          ),
        ),
      ),
    );
  }
}
