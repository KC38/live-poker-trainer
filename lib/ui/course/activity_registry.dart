/// Maps catalog renderers to activity widgets with explicit unsupported fallback.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/authored_multi_step_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/compare_rank_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/full_table_hand_lab_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/numeric_pot_price_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/order_sequence_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/player_read_classify_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/poker_action_sizing_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/unsupported_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';

/// Builds the interactive body for one catalog activity.
class ActivityRegistry {
  /// Creates a registry. Unknown/future renderers resolve to [UnsupportedActivity].
  const ActivityRegistry();

  /// True when [renderer] has a dedicated widget (not the unsupported fallback).
  bool isSupported(ActivityRenderer renderer) {
    return switch (renderer) {
      ActivityRenderer.coachDialogue ||
      ActivityRenderer.selectIdentify ||
      ActivityRenderer.orderSequence ||
      ActivityRenderer.compareRank ||
      ActivityRenderer.numericPotPrice ||
      ActivityRenderer.pokerActionSizing ||
      ActivityRenderer.playerReadClassify ||
      ActivityRenderer.authoredMultiStepHand ||
      ActivityRenderer.fullTableHandLab => true,
    };
  }

  /// Resolves every catalog activity. Never throws for an unknown renderer.
  Widget build({
    required CourseActivity activity,
    required LessonActivityController controller,
    required bool showGuidance,
  }) {
    try {
      return switch (activity.renderer) {
        ActivityRenderer.coachDialogue => CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: showGuidance,
        ),
        ActivityRenderer.selectIdentify => SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: showGuidance,
        ),
        ActivityRenderer.orderSequence => OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: showGuidance,
        ),
        ActivityRenderer.compareRank => CompareRankActivity(
          activity: activity,
          controller: controller,
          showGuidance: showGuidance,
        ),
        ActivityRenderer.numericPotPrice => NumericPotPriceActivity(
          activity: activity,
          controller: controller,
          showGuidance: showGuidance,
        ),
        ActivityRenderer.pokerActionSizing => PokerActionSizingActivity(
          activity: activity,
          controller: controller,
          showGuidance: showGuidance,
        ),
        ActivityRenderer.playerReadClassify => PlayerReadClassifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: showGuidance,
        ),
        ActivityRenderer.authoredMultiStepHand => AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: showGuidance,
        ),
        ActivityRenderer.fullTableHandLab => FullTableHandLabActivity(
          activity: activity,
          controller: controller,
          showGuidance: showGuidance,
        ),
      };
    } catch (error, stack) {
      debugPrint('ActivityRegistry build failed: $error\n$stack');
      return UnsupportedActivity(
        activity: activity,
        controller: controller,
        reason: 'This activity could not be rendered.',
      );
    }
  }
}

/// Shared registry instance.
const activityRegistry = ActivityRegistry();

/// Verifies every activity in [catalog] has a supported registry entry.
List<String> unsupportedActivityIds(CourseCatalog catalog) {
  final missing = <String>[];
  for (final section in catalog.sections) {
    for (final unit in section.units) {
      for (final lesson in unit.lessons) {
        for (final activity in lesson.activities) {
          if (!activityRegistry.isSupported(activity.renderer)) {
            missing.add(activity.id);
          }
        }
      }
    }
  }
  return missing;
}
