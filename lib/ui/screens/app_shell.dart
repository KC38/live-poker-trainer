/// Four-tab learning shell (Learn / Practice / Progress / You).
///
/// Scaffold only — not wired into [main.dart] until
/// `learningPlatformEnabled` is true. Existing auth → Home flow stays default.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/screens/learning/learn_path_screen.dart';
import 'package:live_poker_trainer/ui/screens/learning/practice_hub_screen.dart';
import 'package:live_poker_trainer/ui/screens/learning/progress_overview_screen.dart';
import 'package:live_poker_trainer/ui/screens/learning/you_screen.dart';
import 'package:live_poker_trainer/ui/tokens/learning_tokens.dart';

/// Persistent bottom-nav shell for the learning platform.
class AppShell extends StatefulWidget {
  /// Creates the shell; [initialIndex] selects the starting tab.
  const AppShell({super.key, this.initialIndex = 0});

  /// Initial tab index (0 Learn … 3 You).
  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;

  static const _tabs = <_ShellTab>[
    _ShellTab(label: 'Learn', icon: Icons.school_outlined),
    _ShellTab(label: 'Practice', icon: Icons.casino_outlined),
    _ShellTab(label: 'Progress', icon: Icons.insights_outlined),
    _ShellTab(label: 'You', icon: Icons.person_outline),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: IndexedStack(
        index: _index,
        children: const [
          LearnPathScreen(),
          PracticeHubScreen(),
          ProgressOverviewScreen(),
          YouScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: LearningTokens.minTapTarget + 16,
        backgroundColor: AppColors.bgMid,
        indicatorColor: AppColors.feltLight.withValues(alpha: 0.55),
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon, color: AppColors.slate),
              selectedIcon: Icon(tab.icon, color: AppColors.goldBright),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Shared placeholder body used while screens are scaffolded.
class LearningPlaceholderBody extends StatelessWidget {
  /// Creates a titled placeholder.
  const LearningPlaceholderBody({
    super.key,
    required this.title,
    required this.subtitle,
  });

  /// Screen title.
  final String title;

  /// Supporting copy.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(LearningTokens.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.w700,
                color: AppColors.goldBright,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: LearningTokens.sectionGap),
            Expanded(
              child: DecoratedBox(
                decoration: LearningTokens.panelDecoration(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Scaffolded behind feature flags. '
                      'Production free-play Home remains the default.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AppColors.cream,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
