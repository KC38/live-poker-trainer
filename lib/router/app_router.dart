/// Declarative router scaffolding for the learning platform.
///
/// Not attached to [PokerLabApp] until `learningPlatformEnabled` is true.
/// Kept as a pure builder so tests can mount routes without flipping
/// production.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/ui/screens/app_shell.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';

/// Named routes reserved for the learning shell.
abstract final class AppRoutes {
  /// Legacy free-play home (flag off).
  static const String home = '/';

  /// Auth / save-progress.
  static const String auth = '/auth';

  /// Learning shell root.
  static const String shell = '/learn';
}

/// Builds a [Navigator]-compatible route map for learning scaffolding.
Map<String, WidgetBuilder> learningRouteBuilders() {
  return {
    AppRoutes.home: (_) => const HomeScreen(),
    AppRoutes.auth: (_) => const AuthScreen(),
    AppRoutes.shell: (_) => const AppShell(),
  };
}
