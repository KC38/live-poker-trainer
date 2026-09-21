/// Signed-in root: Home, Live Training, and Profile tabs.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/screens/live_training_screen.dart';
import 'package:live_poker_trainer/ui/screens/profile_screen.dart';

/// Three-tab shell. Poker table pushes above this navigator.
class AppShell extends ConsumerStatefulWidget {
  /// Creates the signed-in app shell.
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _tabs = <({
    String label,
    String screen,
    IconData icon,
    IconData selectedIcon,
  })>[
    (
      label: 'Home',
      screen: AnalyticsScreens.home,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    (
      label: 'Live Training',
      screen: AnalyticsScreens.liveTraining,
      icon: Icons.style_outlined,
      selectedIcon: Icons.style,
    ),
    (
      label: 'Profile',
      screen: AnalyticsScreens.progress,
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncShellBgm());
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
    if (index == _index || index < 0 || index >= _tabs.length) return;
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
          const HomeScreen(),
          LiveTrainingScreen(onOpenHome: () => _selectTab(0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        backgroundColor: AppColors.bgElevated,
        indicatorColor: AppColors.gold.withValues(alpha: 0.22),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon, color: AppColors.slate),
              selectedIcon: Icon(tab.selectedIcon, color: AppColors.gold),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
