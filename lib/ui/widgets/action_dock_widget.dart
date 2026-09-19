/// Bottom thumb-zone action dock — simple labels, sizing presets.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/engine/bet_sizing.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/engine/situation_action_keys.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/live_hand_model.dart';
import 'package:live_poker_trainer/models/situation_model.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';

/// Hero action controls anchored above the home indicator.
class ActionDockWidget extends ConsumerStatefulWidget {
  /// Creates the action dock.
  const ActionDockWidget({
    super.key,
    required this.game,
    required this.onAction,
    this.enabled = true,
    this.authoredEdges,
    this.liveActions,
    this.onLiveAction,
  });

  final GameState game;
  final ValueChanged<PokerAction> onAction;
  final bool enabled;

  /// Exact server-authored controls. `null` retains the generic action dock.
  final List<HeroActionEdge>? authoredEdges;

  /// Exact fixed legal actions from the live server.
  final List<LiveLegalActionModel>? liveActions;

  /// Handles a selected live action id.
  final ValueChanged<LiveLegalActionModel>? onLiveAction;

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

  /// Sensible default "raise to" for the slider / Raise button.
  ///
  /// Pot-fraction sizing collapses to the legal min on an unopened preflop
  /// (blinds-only pot), which teaches a 2× open. Prefer ~2.5× BB there; use
  /// two-thirds pot once there is a real pot to size against.
  double _defaultRaise() {
    final game = widget.game;
    final range = RaiseRange.forHero(game);
    if (!range.allowed) return range.max;
    final unopenedPreflop =
        game.street == Street.preflop &&
        game.highestBet <= game.bigBlind + Money.epsilon;
    if (unopenedPreflop) {
      return range.clamp(game.bigBlind * 2.5);
    }
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
    final canAct =
        widget.enabled &&
        game.waitingForHero &&
        !game.isHandOver &&
        !hero.folded;
    final authoredEdges = widget.authoredEdges;
    final liveActions = widget.liveActions;
    if (liveActions != null && liveActions.isNotEmpty) {
      return _LiveActionDock(
        actions: liveActions,
        enabled: canAct,
        onAction: widget.onLiveAction,
      );
    }
    if (authoredEdges != null && authoredEdges.isNotEmpty) {
      return _AuthoredActionDock(
        game: game,
        edges: authoredEdges,
        enabled: canAct,
        onAction: widget.onAction,
        chipMode: chipMode,
      );
    }

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

    void foldOrNoop() {
      if (!canAct || freeCheck) return;
      widget.onAction(const PokerAction(type: PokerActionType.fold));
    }

    void checkOrCall() {
      if (!canAct) return;
      widget.onAction(
        freeCheck
            ? const PokerAction(type: PokerActionType.check)
            : PokerAction(type: PokerActionType.call, amount: callAmt),
      );
    }

    void betOrRaise() {
      if (!canAct || !range.allowed) return;
      widget.onAction(
        PokerAction(
          type:
              range.isAllInOnly
                  ? PokerActionType.allIn
                  : (freeCheck ? PokerActionType.bet : PokerActionType.raise),
          amount: raiseAmount,
        ),
      );
    }

    // Debug-only keybinds so Simulator / web can be driven without
    // Accessibility-permission mouse taps (F fold, C call/check, R raise/bet).
    final dock = Container(
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
                // Presets scroll horizontally so a narrow phone (320pt)
                // never overflows the dock.
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
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
                              onTap:
                                  canAct && range.hasSpread
                                      ? () => setFraction(entry.$2)
                                      : null,
                            ),
                          ),
                        _SizeChip(
                          label: 'All-in',
                          onTap:
                              canAct && range.allowed
                                  ? () =>
                                      setState(() => _raiseAmount = range.max)
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  range.allowed
                      ? ChipFormat.chips(raiseAmount, game.bigBlind, chipMode)
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
                onChanged:
                    canAct
                        ? (v) => setState(
                          () => _raiseAmount = range.snapToBb(v, game.bigBlind),
                        )
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
                    color: freeCheck ? AppColors.slateDark : AppColors.danger,
                    enabled: canAct && !freeCheck,
                    onTap: foldOrNoop,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DockButton(
                    label:
                        freeCheck
                            ? 'Check'
                            : 'Call ${ChipFormat.chips(callAmt, game.bigBlind, chipMode)}',
                    color: AppColors.surfaceMuted,
                    enabled: canAct,
                    onTap: checkOrCall,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DockButton(
                    label:
                        range.isAllInOnly
                            ? 'All-in'
                            : (freeCheck ? 'Bet' : 'Raise'),
                    color: AppColors.gold,
                    foreground: AppColors.bgDark,
                    enabled: canAct && range.allowed,
                    onTap: betOrRaise,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final focusedDock =
        !kDebugMode
            ? dock
            : Focus(
              autofocus: true,
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.keyF): foldOrNoop,
                  const SingleActivator(LogicalKeyboardKey.keyC): checkOrCall,
                  const SingleActivator(LogicalKeyboardKey.keyR): betOrRaise,
                },
                child: dock,
              ),
            );

    return Opacity(
      opacity: canAct ? 1 : 0.45,
      child: IgnorePointer(ignoring: !canAct, child: focusedDock),
    );
  }
}

class _LiveActionDock extends StatelessWidget {
  const _LiveActionDock({
    required this.actions,
    required this.enabled,
    required this.onAction,
  });

  final List<LiveLegalActionModel> actions;
  final bool enabled;
  final ValueChanged<LiveLegalActionModel>? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.bgMid.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(color: AppColors.slateDark.withValues(alpha: 0.9)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in actions)
              SizedBox(
                width: _buttonWidth(context, actions.length),
                child: _DockButton(
                  label: action.label.toUpperCase(),
                  color: switch (action.kind) {
                    'FOLD' => AppColors.danger,
                    'CHECK' || 'CALL' => AppColors.surfaceMuted,
                    _ => AppColors.gold,
                  },
                  foreground:
                      action.kind == 'FOLD' ||
                              action.kind == 'CHECK' ||
                              action.kind == 'CALL'
                          ? null
                          : AppColors.bgDark,
                  enabled: enabled && onAction != null,
                  onTap: () => onAction?.call(action),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static double _buttonWidth(BuildContext context, int count) {
    final available = MediaQuery.sizeOf(context).width - 28;
    final columns = count <= 3 ? count : 3;
    return (available - (columns - 1) * 8) / columns;
  }
}

class _AuthoredActionDock extends StatelessWidget {
  const _AuthoredActionDock({
    required this.game,
    required this.edges,
    required this.enabled,
    required this.onAction,
    required this.chipMode,
  });

  final GameState game;
  final List<HeroActionEdge> edges;
  final bool enabled;
  final ValueChanged<PokerAction> onAction;
  final ChipDisplayMode chipMode;

  String _label(HeroActionEdge edge) {
    final action = switch (edge.kind) {
      SituationActionKind.fold => 'FOLD',
      SituationActionKind.check => 'CHECK',
      SituationActionKind.call => 'CALL',
      SituationActionKind.bet => 'BET',
      SituationActionKind.raise => 'RAISE',
      SituationActionKind.allIn => 'ALL-IN',
      _ => edge.kind.wire,
    };
    final amount = edge.amountTo;
    return amount == null
        ? action
        : '$action ${ChipFormat.chips(amount, game.bigBlind, chipMode)}';
  }

  Color _color(HeroActionEdge edge) {
    return switch (edge.kind) {
      SituationActionKind.fold => AppColors.danger,
      SituationActionKind.check ||
      SituationActionKind.call => AppColors.surfaceMuted,
      _ => AppColors.gold,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dock = Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.bgMid.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(color: AppColors.slateDark.withValues(alpha: 0.9)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < edges.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: _DockButton(
                  label: _label(edges[i]),
                  color: _color(edges[i]),
                  foreground:
                      _color(edges[i]) == AppColors.gold
                          ? AppColors.bgDark
                          : null,
                  enabled: enabled,
                  onTap:
                      () => onAction(
                        SituationActionKeys.pokerActionForEdge(game, edges[i]),
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: IgnorePointer(ignoring: !enabled, child: dock),
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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
