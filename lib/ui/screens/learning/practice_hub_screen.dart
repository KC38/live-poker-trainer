/// Practice tab — review, remediation, and free play (scaffold).
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/ui/screens/app_shell.dart';

/// Adaptive practice hub placeholder.
class PracticeHubScreen extends StatelessWidget {
  /// Creates the Practice tab.
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearningPlaceholderBody(
      title: 'Practice',
      subtitle:
          'Due reviews, weak-skill drills, mistakes notebook, and free play.',
    );
  }
}
