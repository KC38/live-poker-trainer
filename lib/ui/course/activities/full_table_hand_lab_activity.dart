/// Lesson-scoped full-table hand lab decision (public choices only).
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/poker_action_sizing_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Minimal hand-lab shell: felt framing + authored decision choices.
///
/// Full scripted lab playback is Plan 10; here we grade the public decision
/// through the existing course callables without starting Live Training.
class FullTableHandLabActivity extends StatelessWidget {
  /// Creates the activity.
  const FullTableHandLabActivity({
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
    if (activity.choices.isEmpty) {
      return UnsupportedHandLabNotice(activity: activity);
    }
    // Toy-hand / action lessons: reuse the mini-table dock (no nested felt box).
    if (isLessonActionTableActivity(activity) &&
        resolveLessonActionSpot(activity) != null) {
      return PokerActionSizingActivity(
        activity: activity,
        controller: controller,
        showGuidance: showGuidance,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showGuidance)
          const RexCoachLine(
            text: 'Hand lab — tap the action you would take live.',
          ),
        const SizedBox(height: 12),
        PokerActionSizingActivity(
          activity: activity,
          controller: controller,
          showGuidance: false,
        ),
      ],
    );
  }
}

/// Recoverable empty hand-lab state (no crash).
class UnsupportedHandLabNotice extends StatelessWidget {
  /// Creates the notice.
  const UnsupportedHandLabNotice({super.key, required this.activity});

  final CourseActivity activity;

  @override
  Widget build(BuildContext context) {
    return RexCoachLine(
      text:
          'Hand lab "${activity.handLabSpecId ?? activity.id}" is not playable '
          'in this build. Skip is not available — leave and resume later.',
    );
  }
}
