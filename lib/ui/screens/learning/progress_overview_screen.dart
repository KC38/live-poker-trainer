/// Progress tab — mastery, streaks, assessments, leak finder (scaffold).
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/ui/screens/app_shell.dart';

/// Progress and mastery overview placeholder.
class ProgressOverviewScreen extends StatelessWidget {
  /// Creates the Progress tab.
  const ProgressOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearningPlaceholderBody(
      title: 'Progress',
      subtitle:
          'Section mastery, milestone gates, streaks, and leak diagnosis.',
    );
  }
}
