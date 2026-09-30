/// Duolingo-style bottom tab bar with custom illustrated SVG art.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// One destination in [ShellBottomNav].
class ShellNavTab {
  /// Creates a tab with accessibility [label] and SVG [asset] path.
  const ShellNavTab({
    required this.label,
    required this.asset,
  });

  /// Spoken / semantic label (icons are unlabeled visually).
  final String label;

  /// Illustrated SVG under `assets/brand/`.
  final String asset;
}

/// Custom illustrated bottom bar — colorful art, active cyan ring, no labels.
class ShellBottomNav extends StatelessWidget {
  /// Creates the shell bottom navigation bar.
  const ShellBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.tabs,
  });

  /// Currently selected tab index.
  final int selectedIndex;

  /// Called when the user taps a tab.
  final ValueChanged<int> onDestinationSelected;

  /// Tab metadata (label + SVG asset).
  final List<ShellNavTab> tabs;

  static const double _iconSize = 36;
  static const double _slotSize = 52;
  static const double _barHeight = 64;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: AppColors.bgElevated,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.slateDark, width: 1),
          ),
        ),
        child: SizedBox(
          height: _barHeight + bottomInset,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      tab: tabs[i],
                      selected: i == selectedIndex,
                      onTap: () => onDestinationSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final ShellNavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.gold.withValues(alpha: 0.12),
        highlightColor: AppColors.gold.withValues(alpha: 0.06),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: ShellBottomNav._slotSize,
            height: ShellBottomNav._slotSize,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.surfaceMuted
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.navRing : Colors.transparent,
                width: 3,
              ),
            ),
            alignment: Alignment.center,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: selected ? 1 : 0.78,
              child: ExcludeSemantics(
                child: SvgPicture.asset(
                  tab.asset,
                  width: ShellBottomNav._iconSize,
                  height: ShellBottomNav._iconSize,
                  placeholderBuilder: (_) => Icon(
                    Icons.circle,
                    size: ShellBottomNav._iconSize * 0.7,
                    color: AppColors.slate,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
