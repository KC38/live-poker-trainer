/// Main gameplay table — strict vertical bands so nothing ever overlaps.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/action_dock_widget.dart';
import 'package:live_poker_trainer/ui/widgets/archetype_legend_sheet.dart';
import 'package:live_poker_trainer/ui/widgets/coach_shelf_widget.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/hero_rail_widget.dart';
import 'package:live_poker_trainer/ui/widgets/tendency_profile_sheet.dart';

/// Smartphone-first poker table with teaching-forward chrome.
///
/// The screen is a strict [Column] of non-overlapping bands:
/// header → felt (flexible) → hero rail → coach shelf → action dock. The felt
/// gets whatever is left over, so a tall coach shelf can shrink the felt but
/// can never draw on top of the hero's hole cards.
///
/// When the hero has no decision to make — villains acting, hero folded, hand
/// over — the dock band is not dimmed, it is removed. The freed height is
/// handed to the coach shelf (taller cap, auto-opened review copy) and to the
/// felt and hero rail, which animate into it rather than jumping.
///
/// After a hand ends, coaching stays in the shelf — no auto Hand Review sheet.
/// The header **Next** control deals again: quiet while the hero is done early
/// (e.g. folded) so they can skip the rest of the replay; gold + pulse only
/// once [GameState.isHandOver] after the hand finishes naturally.
///
/// Hand kickoff (deal + SFX + replay) waits until this route has finished
/// presenting so audio never plays over the Home landing page.
class PokerTableScreen extends ConsumerStatefulWidget {
  /// Creates the poker table screen.
  const PokerTableScreen({super.key});

  @override
  ConsumerState<PokerTableScreen> createState() => _PokerTableScreenState();
}

/// Shared timing for every band that resizes when the dock hides or returns.
const Duration _bandTransition = Duration(milliseconds: 280);

class _PokerTableScreenState extends ConsumerState<PokerTableScreen> {
  /// Breakpoint above which the coach moves into its own side column.
  static const double _wideBreakpoint = 900;

  /// Coach band cap while the dock is on screen, as a share of the viewport.
  static const double _coachShareWithDock = 0.26;

  /// Coach band cap once the dock's space has been reclaimed.
  static const double _coachShareWithoutDock = 0.38;

  bool _kickoffStarted = false;
  bool _kickoffCancelled = false;
  StreamSubscription<String>? _agentSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _kickOffHandWhenVisible();
    });
    if (kDebugMode) {
      _agentSub = AgentCommands.stream.listen((cmd) {
        if (cmd == 'back' && mounted) Navigator.of(context).maybePop();
      });
    }
  }

  @override
  void dispose() {
    _kickoffCancelled = true;
    unawaited(_agentSub?.cancel());
    super.dispose();
  }

  /// Starts the first hand only after the enter transition completes.
  Future<void> _kickOffHandWhenVisible() async {
    if (_kickoffStarted || _kickoffCancelled) return;
    _kickoffStarted = true;

    await waitForRoutePresentation(context);
    if (!mounted || _kickoffCancelled) return;

    // Home already called [prepareTraining]; deal + SFX begin here.
    await ref.read(gameControllerProvider.notifier).startTraining();
  }

  void _openLegend(GameState game) {
    ArchetypeLegendSheet.show(
      context,
      seated:
          game.players.where((p) => !p.isHero).map((p) => p.archetype).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameControllerProvider);
    final settings = ref.watch(settingsProvider);
    final game = session.game;
    final handOver = game != null && game.isHandOver;
    final showNext = session.heroDoneForHand;
    final highlightNext = session.highlightNext;

    // The felt shows currency only; hand review and stats keep the user's
    // full chip-display choice.
    final tableChipMode = settings.chipDisplayMode.tableMode;

    return Focus(
      autofocus: kDebugMode,
      child: CallbackShortcuts(
        bindings: {
          if (kDebugMode && showNext)
            const SingleActivator(LogicalKeyboardKey.keyN):
                () => ref.read(gameControllerProvider.notifier).nextHand(),
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.1,
                colors: [AppColors.bgMid, AppColors.bgDark],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= _wideBreakpoint;
                  // Greyed-out controls are dead weight: drop the dock whenever
                  // the hero cannot act and give its band to the other rows.
                  final dockVisible = session.heroCanAct;

                  final showCoachAdvice = session.coach.hasAdvice;
                  final showCoachPrep =
                      session.awaitingCoach && !showCoachAdvice;
                  final showCoach = showCoachAdvice || showCoachPrep;
                  // A fresh decision has no coach shelf, so replay otherwise
                  // looks frozen: the dock is gone and only "ACTION…" remains.
                  final showResolving =
                      session.replaying && !showCoach;

                  // Cap the coach band so it can never starve the felt, and let
                  // that cap grow into the space the dock gave up.
                  final coachMaxHeight =
                      dockVisible
                          ? (constraints.maxHeight * _coachShareWithDock).clamp(
                            96.0,
                            190.0,
                          )
                          : (constraints.maxHeight * _coachShareWithoutDock)
                              .clamp(120.0, 280.0);

                  CoachShelfWidget buildCoach(double? maxHeight) {
                    final handDone = session.heroDoneForHand;
                    return CoachShelfWidget(
                      feedback: session.coach,
                      bigBlind: game?.bigBlind ?? 2,
                      chipDisplayMode: settings.chipDisplayMode,
                      replaying: session.replaying,
                      preparing: showCoachPrep,
                      maxHeight: maxHeight,
                      dismissLabel: handDone ? 'Next hand' : 'Continue',
                      onDismiss:
                          showCoachAdvice
                              ? () {
                                final controller = ref.read(
                                  gameControllerProvider.notifier,
                                );
                                if (handDone) {
                                  controller.nextHand();
                                } else {
                                  controller.dismissCoach();
                                }
                              }
                              : null,
                    );
                  }

                  // Grow the cap over the same beat as the dock collapse so the
                  // shelf expands instead of snapping to its new size.
                  final Widget? coach =
                      !showCoach
                          ? null
                          : wide
                          ? buildCoach(null)
                          : TweenAnimationBuilder<double>(
                            tween: Tween<double>(end: coachMaxHeight),
                            duration: _bandTransition,
                            curve: Curves.easeOutCubic,
                            builder: (context, cap, _) => buildCoach(cap),
                          );

                  return Column(
                    children: [
                      _TableHeader(
                        game: game,
                        onBack: () async {
                          if (context.mounted) Navigator.pop(context);
                        },
                        onLegend: game == null ? null : () => _openLegend(game),
                        onNext:
                            showNext
                                ? () =>
                                    ref
                                        .read(gameControllerProvider.notifier)
                                        .nextHand()
                                : null,
                        highlightNext: highlightNext,
                      ),
                      if (session.error != null && game != null)
                        _ServerErrorBanner(
                          message: session.error!,
                          onRetry: () {
                            final controller = ref.read(
                              gameControllerProvider.notifier,
                            );
                            if (game.isHandOver) {
                              controller.nextHand();
                            } else {
                              controller.resumeCurrentHand();
                            }
                          },
                        ),
                      if (session.loading)
                        const Expanded(child: _DealingIndicator())
                      else if (game == null)
                        Expanded(
                          child: _EmptyTable(
                            message: session.error ?? 'No hand loaded',
                            onBack: () => Navigator.pop(context),
                            onRetry:
                                () =>
                                    ref
                                        .read(gameControllerProvider.notifier)
                                        .startTraining(),
                          ),
                        )
                      else if (wide)
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: FeltTableView(
                                        game: game,
                                        chipDisplayMode: tableChipMode,
                                        collectingChips:
                                            session.collectingChips,
                                        awardingChips: session.awardingChips,
                                        review: handOver,
                                        waitingOnSeat: session.waitingOnSeat,
                                        onPlayerTap:
                                            (player) =>
                                                TendencyProfileSheet.show(
                                                  context,
                                                  player,
                                                ),
                                      ),
                                    ),
                                    HeroRailWidget(
                                      game: game,
                                      chipDisplayMode: tableChipMode,
                                      isThinking: session.replaying,
                                      canAct: session.heroCanAct,
                                      review: handOver,
                                      isWinner:
                                          handOver &&
                                          game.winnerIds.contains(game.hero.id),
                                    ),
                                    if (showResolving)
                                      const _TableActingBanner(),
                                    _ActionDockSlot(
                                      visible: dockVisible,
                                      child: ActionDockWidget(
                                        game: game,
                                        enabled: dockVisible,
                                        liveActions: session.liveActions,
                                        authoredEdges:
                                            session.authoredHeroEdges,
                                        onLiveAction:
                                            (action) => ref
                                                .read(
                                                  gameControllerProvider
                                                      .notifier,
                                                )
                                                .heroActLive(action),
                                        onAction:
                                            (action) => ref
                                                .read(
                                                  gameControllerProvider
                                                      .notifier,
                                                )
                                                .heroAct(action),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (coach != null)
                                SizedBox(
                                  width: 320,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: coach,
                                  ),
                                ),
                            ],
                          ),
                        )
                      else ...[
                        Expanded(
                          child: FeltTableView(
                            game: game,
                            chipDisplayMode: tableChipMode,
                            collectingChips: session.collectingChips,
                            awardingChips: session.awardingChips,
                            review: handOver,
                            waitingOnSeat: session.waitingOnSeat,
                            onPlayerTap:
                                (player) =>
                                    TendencyProfileSheet.show(context, player),
                          ),
                        ),
                        HeroRailWidget(
                          game: game,
                          chipDisplayMode: tableChipMode,
                          isThinking: session.replaying,
                          canAct: session.heroCanAct,
                          review: handOver,
                          isWinner:
                              handOver && game.winnerIds.contains(game.hero.id),
                        ),
                        if (showResolving) const _TableActingBanner(),
                        // Null-aware collection elements are not enabled by
                        // the current Flutter language version.
                        // ignore: use_null_aware_elements
                        if (coach != null) coach,
                        _ActionDockSlot(
                          visible: dockVisible,
                          child: ActionDockWidget(
                            game: game,
                            enabled: dockVisible,
                            liveActions: session.liveActions,
                            authoredEdges: session.authoredHeroEdges,
                            onLiveAction:
                                (action) => ref
                                    .read(gameControllerProvider.notifier)
                                    .heroActLive(action),
                            onAction:
                                (action) => ref
                                    .read(gameControllerProvider.notifier)
                                    .heroAct(action),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServerErrorBanner extends StatelessWidget {
  const _ServerErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      color: AppColors.danger.withValues(alpha: 0.16),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.danger,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: AppColors.cream,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Bottom band that carries the action dock only while the hero can act.
///
/// Collapsing the band — rather than dimming the controls — is what frees
/// height for the coach shelf and the felt. The dock slides down behind a
/// clip and fades as the band shrinks, then leaves the tree entirely so no
/// dead buttons remain visible or hit-testable.
class _ActionDockSlot extends StatefulWidget {
  const _ActionDockSlot({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  State<_ActionDockSlot> createState() => _ActionDockSlotState();
}

class _ActionDockSlotState extends State<_ActionDockSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _bandTransition,
    value: widget.visible ? 1 : 0,
  );

  late final CurvedAnimation _reveal = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void didUpdateWidget(covariant _ActionDockSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The dock owns the home-indicator gutter via its own SafeArea; keep that
    // gutter behind once it is gone so the coach never sits under the inset.
    final gutter = MediaQuery.paddingOf(context).bottom;
    return AnimatedBuilder(
      animation: _reveal,
      builder: (context, child) {
        final t = _reveal.value;
        if (t == 0) {
          return SizedBox(width: double.infinity, height: gutter);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: t,
                child: Opacity(opacity: t, child: child),
              ),
            ),
            SizedBox(height: gutter * (1 - t)),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.game,
    required this.onBack,
    required this.onLegend,
    required this.onNext,
    this.highlightNext = false,
  });

  final GameState? game;
  final Future<void> Function() onBack;
  final VoidCallback? onLegend;
  final VoidCallback? onNext;
  final bool highlightNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.slate,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Training',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldBright,
                    fontSize: 17,
                  ),
                ),
                if (game?.resultMessage != null)
                  Text(
                    game!.resultMessage!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.warning,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          if (onNext != null)
            _NextHandCta(onPressed: onNext!, emphasized: highlightNext)
          else
            IconButton(
              tooltip: 'Player types',
              onPressed: onLegend,
              icon: const Icon(
                Icons.groups_2_outlined,
                size: 20,
                color: AppColors.slate,
              ),
            ),
        ],
      ),
    );
  }
}

/// Header **Next** — quiet skip while hero is done early; gold pulse when the
/// hand has fully finished.
class _NextHandCta extends StatefulWidget {
  const _NextHandCta({required this.onPressed, this.emphasized = false});

  final VoidCallback onPressed;
  final bool emphasized;

  @override
  State<_NextHandCta> createState() => _NextHandCtaState();
}

class _NextHandCtaState extends State<_NextHandCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _NextHandCta oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emphasized != widget.emphasized) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    if (widget.emphasized) {
      if (!_pulse.isAnimating) {
        _pulse.repeat(reverse: true);
      }
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = Text(
      'Next',
      style: GoogleFonts.manrope(
        color: widget.emphasized ? AppColors.bgDark : AppColors.slate,
        fontWeight: FontWeight.w800,
        fontSize: 14,
        letterSpacing: 0.2,
      ),
    );
    final arrow = Icon(
      Icons.arrow_forward_rounded,
      size: 16,
      color: widget.emphasized ? AppColors.bgDark : AppColors.slate,
    );
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [label, const SizedBox(width: 4), arrow],
      ),
    );

    if (!widget.emphasized) {
      return KeyedSubtree(
        key: const ValueKey<String>('next_cta_quiet'),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.slate.withValues(alpha: 0.45),
                ),
              ),
              child: body,
            ),
          ),
        ),
      );
    }

    return KeyedSubtree(
      key: const ValueKey<String>('next_cta_emphasized'),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_pulse.value);
          final glow = 0.28 + (0.42 * t);
          final scale = 1.0 + (0.035 * t);
          return Transform.scale(
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: glow),
                    blurRadius: 14 + (8 * t),
                    spreadRadius: 0.5 + t,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Material(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(22),
            child: body,
          ),
        ),
      ),
    );
  }
}

/// Shown while villains and coaching resolve and the shelf is still empty.
class _TableActingBanner extends StatelessWidget {
  const _TableActingBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'TABLE ACTING…',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _DealingIndicator extends StatelessWidget {
  const _DealingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Preparing hand…',
            style: GoogleFonts.manrope(color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}

class _EmptyTable extends StatelessWidget {
  const _EmptyTable({
    required this.message,
    required this.onBack,
    this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.style_outlined,
              size: 40,
              color: AppColors.slate.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 15),
            ),
            const SizedBox(height: 20),
            if (onRetry != null) ...[
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
              const SizedBox(height: 10),
            ],
            OutlinedButton(
              onPressed: onBack,
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}
