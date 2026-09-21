/// Coach demonstration / dialogue activity.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/models/card_model.dart';

/// Show-stage activity: Rex speaks and the UI demonstrates hole cards.
class CoachDialogueActivity extends StatelessWidget {
  /// Creates the activity.
  const CoachDialogueActivity({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RexCoachLine.fromActivity(activity),
        const SizedBox(height: 20),
        Semantics(
          label: 'Demonstration hole cards ace of hearts and king of diamonds',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MiniCard(
                card: CardModel.fromCode('Ah'),
                size: MiniCardSize.hero,
              ),
              const SizedBox(width: 10),
              MiniCard(
                card: CardModel.fromCode('Kd'),
                size: MiniCardSize.hero,
              ),
            ],
          ),
        ),
        if (showGuidance) ...[
          const SizedBox(height: 16),
          const RexCoachLine(
            text: 'Tap Continue when you have looked at your two cards.',
            label: 'Rex',
          ),
        ],
      ],
    );
  }
}
