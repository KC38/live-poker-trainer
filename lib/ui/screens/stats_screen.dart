/// Legacy Progress route — aliases the consolidated [ProfileScreen].
///
/// Kept so any stale deep links / tests that still navigate to Stats land on
/// the same Progress destination (identity + metrics + Leak Finder).
library;

import 'package:live_poker_trainer/ui/screens/profile_screen.dart';

/// Compatibility alias for the consolidated Progress screen.
typedef StatsScreen = ProfileScreen;
