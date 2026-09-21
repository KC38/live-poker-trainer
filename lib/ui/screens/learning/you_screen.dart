/// You tab — identity, settings, accessibility, account (scaffold).
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/ui/screens/app_shell.dart';

/// Profile and settings placeholder for the learning shell.
class YouScreen extends StatelessWidget {
  /// Creates the You tab.
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearningPlaceholderBody(
      title: 'You',
      subtitle:
          'Identity, audio, accessibility, reminders, and account save.',
    );
  }
}
