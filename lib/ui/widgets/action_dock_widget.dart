/// Bottom thumb-zone action dock — simple labels, sizing presets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/engine/bet_sizing.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';

/// Hero action controls anchored above the home indicator.
class ActionDockWidget extends ConsumerStatefulWidget {
  /// Creates the action dock.
  const ActionDockWidget({
    super.key,
    required this.game,
    required this.onAction,
    this.enabled = true,
  });

  final GameState game;
  final ValueChanged<PokerAction> onAction;
  final bool enabled;

  @override
  ConsumerState<ActionDockWidget> createState() => _ActionDockWidgetState();
}

class _ActionDockWidgetState extends ConsumerState<ActionDockWidget> {
  double _raiseAmount = 0;

  @override
  void didUpdateWidget(covariant ActionDockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game.handCount != widget.game.handCount ||
        oldWidget.game.highestBet != widget.game.highestBet ||
        oldWidget.game.street != widget.game.street) {
      _raiseAmount = _defaultRaise();
    }
  }

  @override
  void initState() {
    super.initState();
    _raiseAmount = _defaultRaise();
  }

  double _defaultRaise() {
    final game = widget.game;
    final range = RaiseRange.forHero(game);
    if (!range.allowed) return range.max;
    return range.forFraction(
      0.66,
      pot: game.totalPot,
      heroBet: game.hero.currentBet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final hero = game.hero;
    final chipMode = ref.watch(settingsProvider).chipDisplayMode.tableMode;
    final canAct = widget.enabled &&
        game.waitingForHero &&
        !game.isHandOver &&
        !hero.folded;
    final callAmt = game.callAmountFor(hero);
    final freeCheck = callAmt <= Money.epsilon;
    final range = RaiseRange.forHero(game);
    final pot = game.totalPot;
    final raiseAmount = range.clamp(_raiseAmount);

    void setFraction(double frac) {
      setState(() {
        _raiseAmount = range.forFraction(
          frac,
          pot: pot,
          heroBet: hero.currentBet,
        );
      });
    }

    return Opacity(
      opacity: canAct ? 1 : 0.45,
      child: IgnorePointer(
        ignoring: !canAct,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: AppColors.bgMid.withValues(alpha: 0.98),
            border: Border(
              top: BorderSide(color: AppColors.slateDark.withValues(alpha: 0.9)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    for (final entry in [
                      ('⅓', 1 / 3),
                      ('½', 0.5),
                      ('¾', 0.75),
                      ('Pot', 1.0),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _SizeChip(
                          label: entry.$1,
                          onTap: canAct && range.hasSpread
                              ? () => setFraction(entry.$2)
                              : null,
                        ),
                      ),
                    _SizeChip(
                      label: 'All-in',
                      onTap: canAct && range.allowed
                          ? () => setState(() => _raiseAmount = range.max)
                          : null,
                    ),
                    const Spacer(),
                    Text(
                      range.allowed
                          ? ChipFormat.chips(
                              raiseAmount,
                              game.bigBlind,
                              chipMode,
                            )
                          : '—',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                if (range.hasSpread)
                  Slider(
                    value: raiseAmount,
                    min: range.min,
                    max: range.max,
                    onChanged: canAct
                        ? (v) => setState(() => _raiseAmount = Money.round(v))
                        : null,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      range.isAllInOnly
                          ? 'Short stack — all-in is the only raise'
                          : 'No raise available at this price',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _DockButton(
                        label: freeCheck ? '—' : 'Fold',
                        color:
                            freeCheck ? AppColors.slateDark : AppColors.danger,
                        enabled: canAct && !freeCheck,
                        onTap: () => widget.onAction(
                          const PokerAction(type: PokerActionType.fold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DockButton(
                        label: freeCheck
                            ? 'Check'
                            : 'Call ${ChipFormat.chips(callAmt, game.bigBlind, chipMode)}',
                        color: AppColors.surfaceMuted,
                        enabled: canAct,
                        onTap: () => widget.onAction(
                          freeCheck
                              ? const PokerAction(type: PokerActionType.check)
                              : PokerAction(
                                  type: PokerActionType.call,
                                  amount: callAmt,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DockButton(
                        label: range.isAllInOnly
                            ? 'All-in'
                            : (freeCheck ? 'Bet' : 'Raise'),
                        color: AppColors.gold,
                        foreground: AppColors.bgDark,
                        enabled: canAct && range.allowed,
                        onTap: () => widget.onAction(
                          PokerAction(
                            type: range.isAllInOnly
                                ? PokerActionType.allIn
                                : (freeCheck
                                    ? PokerActionType.bet
                                    : PokerActionType.raise),
                            amount: raiseAmount,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.slateDark),
            color: AppColors.bgDark.withValues(alpha: 0.55),
          ),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.goldMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
    this.foreground,
  });

  final String label;
  final Color color;
  final Color? foreground;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground ?? AppColors.cream,
          disabledBackgroundColor: AppColors.slateDark,
          disabledForegroundColor: AppColors.slate,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
