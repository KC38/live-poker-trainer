/// Learn tab — guided curriculum path (scaffold).
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/ui/screens/app_shell.dart';

/// Guided learning path placeholder.
class LearnPathScreen extends StatelessWidget {
  /// Creates the Learn tab.
  const LearnPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearningPlaceholderBody(
      title: 'Learn',
      subtitle:
          'Guided live-cash path: 13 sections, 61 units, 183 lessons.',
    );
  }
}
