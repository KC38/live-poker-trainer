/// Fade/scale-in for a card that just landed on the felt, with deal SFX.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';

/// Plays the deal SFX once when this card first appears, then eases it in.
class DealtCardReveal extends StatefulWidget {
  /// Wraps a table card (face or back) that was just dealt.
  const DealtCardReveal({
    super.key,
    required this.child,
    this.playSound = true,
  });

  /// The card face or back.
  final Widget child;

  /// False for a showdown flip that is not a new deal.
  final bool playSound;

  @override
  State<DealtCardReveal> createState() => _DealtCardRevealState();
}

class _DealtCardRevealState extends State<DealtCardReveal> {
  double _progress = 0;
  var _soundPlayed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _playDealOnce();
      setState(() => _progress = 1);
    });
  }

  void _playDealOnce() {
    if (_soundPlayed || !widget.playSound) return;
    _soundPlayed = true;
    try {
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(soundServiceProvider).dealStaggered();
    } on Object {
      // Seat/board layout tests often pump without a [ProviderScope].
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: _progress,
      child: AnimatedScale(
        scale: 0.82 + 0.18 * _progress,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
