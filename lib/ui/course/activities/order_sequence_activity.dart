/// Arrange action-order / sequence activity.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Drag-free tap-to-order sequence builder with undo.
class OrderSequenceActivity extends StatelessWidget {
  /// Creates the activity.
  const OrderSequenceActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final ordered = controller.draft.orderedIds;
        final locked = controller.submitting || controller.lastResult != null;
        final remaining = activity.sequenceItems
            .where((item) => !ordered.contains(item.id))
            .toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showGuidance)
              const RexCoachLine(
                text: 'Tap seats in the order they act.',
              ),
            if (activity.prompt != null) ...[
              const SizedBox(height: 12),
              Text(
                activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Semantics(
              label: 'Current order: ${ordered.isEmpty ? 'empty' : ordered.join(', ')}',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < ordered.length; i++)
                    Chip(
                      label: Text('${i + 1}. ${_labelFor(ordered[i])}'),
                      backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in remaining)
                  ActionChip(
                    onPressed: locked
                        ? null
                        : () => controller.setOrderedIds([...ordered, item.id]),
                    label: Text(item.label),
                  ),
              ],
            ),
            if (ordered.isNotEmpty && !locked) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    final next = [...ordered]..removeLast();
                    controller.setOrderedIds(next);
                  },
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Undo last'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _labelFor(String id) {
    for (final item in activity.sequenceItems) {
      if (item.id == id) return item.label;
    }
    return id;
  }
}
