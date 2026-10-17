/// Constrains nested AppShell tab roots so they cannot paint into the nav.
///
/// Agent handbook: `docs/agents/03-client.md`.
///
/// [AppShell]'s [IndexedStack] often gives tab children a loose max height.
/// A nested [Scaffold] then sizes to the full screen and paints into
/// [ShellBottomNav] on first paint (LPT-1015 Profile on iPhone 13 mini).
/// Wrap each tab root with this widget.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/ui/widgets/shell_bottom_nav.dart';

/// Sizes [child] to the shell body (screen minus nav + home indicator).
class ShellTabBody extends StatelessWidget {
  /// Creates a shell-tab body constraint wrapper.
  const ShellTabBody({super.key, required this.child});

  /// Tab root (usually a [Scaffold]).
  final Widget child;

  /// Resolve width/height for a nested tab under [constraints] + [media].
  static Size resolveSize(BoxConstraints constraints, MediaQueryData media) {
    final navExtent = ShellBottomNav.barHeight + media.padding.bottom;
    final maxH = constraints.maxHeight;
    final height =
        maxH.isFinite && maxH < media.size.height - 1
            ? maxH
            : media.size.height - navExtent;
    final width =
        constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : media.size.width;
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final size = resolveSize(constraints, media);
        return MediaQuery(
          data: media.copyWith(size: size),
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: child,
          ),
        );
      },
    );
  }
}
