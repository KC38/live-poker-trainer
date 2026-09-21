/// Compare / rank hands activity (reuses sequence ordering UI).
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/order_sequence_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';

/// Rank items strongest → weakest via the sequence builder.
class CompareRankActivity extends StatelessWidget {
  /// Creates the activity.
  const CompareRankActivity({
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
    return OrderSequenceActivity(
      activity: activity,
      controller: controller,
      showGuidance: showGuidance,
    );
  }
}
