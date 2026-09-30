/// Signed-in root: Home, Live Training, and Profile tabs.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/screens/live_training_screen.dart';
import 'package:live_poker_trainer/ui/screens/profile_screen.dart';
import 'package:live_poker_trainer/ui/widgets/shell_bottom_nav.dart';

/// Three-tab shell. Poker table pushes above this navigator.
class AppShell extends ConsumerStatefulWidget {
  /// Creates the signed-in app shell.
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;
  final ValueNotifier<int> _homeFocusRequests = ValueNotifier<int>(0);

  static const _tabs = <({
    String label,
    String screen,
    String asset,
  })>[
    (
      label: 'Home',
      screen: AnalyticsScreens.home,
      asset: 'assets/brand/nav_home.svg',
    ),
    (
      label: 'Live Training',
      screen: AnalyticsScreens.liveTraining,
      asset: 'assets/brand/nav_live.svg',
    ),
    (
      label: 'Profile',
      screen: AnalyticsScreens.progress,
      asset: 'assets/brand/nav_profile.svg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncShellBgm());
  }

  @override
  void dispose() {
    _homeFocusRequests.dispose();
    super.dispose();
  }

  Future<void> _syncShellBgm() async {
    if (!mounted) return;
    final settings = ref.read(settingsProvider);
    final sound = ref.read(soundServiceProvider);
    await sound.unlock();
    if (!mounted) return;
    if (settings.musicEnabled) {
      await sound.startHomeBgm();
    } else {
      await sound.stopHomeBgm();
    }
  }

  void _selectTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    // Home always scrolls back to the next / in-progress lesson — including
    // when the user is already on Home and re-taps the tab after scrolling.
    if (index == 0) {
      _homeFocusRequests.value++;
    }
    if (index == _index) return;
    setState(() => _index = index);
    final screen = _tabs[index].screen;
    unawaited(ref.read(analyticsServiceProvider).logScreenView(screen));
    unawaited(
      ref.read(analyticsServiceProvider).logTabSelected(tab: screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsProvider, (prev, next) {
      if (prev?.musicEnabled == next.musicEnabled) return;
      unawaited(_syncShellBgm());
    });

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(focusRequests: _homeFocusRequests),
          LiveTrainingScreen(onOpenHome: () => _selectTab(0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: ShellBottomNav(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        tabs: [
          for (final tab in _tabs)
            ShellNavTab(label: tab.label, asset: tab.asset),
        ],
      ),
    );
  }
}
