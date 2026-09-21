/// Identify a player read / type.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';

/// Player-type classification uses the select/identify shell.
class PlayerReadClassifyActivity extends StatelessWidget {
  /// Creates the activity.
  const PlayerReadClassifyActivity({
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
    return SelectIdentifyActivity(
      activity: activity,
      controller: controller,
      showGuidance: showGuidance,
    );
  }
}
