/// Main gameplay table — strict vertical bands so nothing ever overlaps.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/action_dock_widget.dart';
import 'package:live_poker_trainer/ui/widgets/archetype_legend_sheet.dart';
import 'package:live_poker_trainer/ui/widgets/coach_shelf_widget.dart';
import 'package:live_poker_trainer/ui/widgets/ev_audit_modal.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/hero_rail_widget.dart';

/// Smartphone-first poker table with teaching-forward chrome.
///
/// The screen is a strict [Column] of non-overlapping bands:
/// header → felt (flexible) → hero rail → coach shelf → action dock. The felt
/// gets whatever is left over, so a tall coach shelf can shrink the felt but
/// can never draw on top of the hero's hole cards.
///
/// After a hand ends, coaching stays in the shelf — no auto Hand Review sheet.
/// The header **Next** control becomes the clear CTA to deal again.
///
/// Hand kickoff (deal + SFX + replay) waits until this route has finished
/// presenting so audio never plays over the Home landing page.
class PokerTableScreen extends ConsumerStatefulWidget {
  /// Creates the poker table screen.
  const PokerTableScreen({super.key});

  @override
  ConsumerState<PokerTableScreen> createState() => _PokerTableScreenState();
}

class _PokerTableScreenState extends ConsumerState<PokerTableScreen> {
  /// Breakpoint above which the coach moves into its own side column.
  static const double _wideBreakpoint = 900;

  bool _kickoffStarted = false;
  bool _kickoffCancelled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _kickOffHandWhenVisible();
    });
  }

  @override
  void dispose() {
    _kickoffCancelled = true;
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
      seated: game.players
          .where((p) => !p.isHero)
          .map((p) => p.archetype)
          .toList(),
    );
  }

  void _openOptionalReview(TableSession session) {
    final game = session.game;
    if (game == null || !session.coach.hasVerdict) return;
    EvAuditModal.show(
      context,
      game: game,
      feedback: session.coach,
      chipDisplayMode: ref.read(settingsProvider).chipDisplayMode,
      onNext: () {
        ref.read(gameControllerProvider.notifier).nextHand();
      },
    ).whenComplete(() {
      ref.read(gameControllerProvider.notifier).dismissEvAudit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameControllerProvider);
    final settings = ref.watch(settingsProvider);
    final game = session.game;
    final handOver = game != null && game.isHandOver;

    // The felt shows currency only; hand review and stats keep the user's
    // full chip-display choice.
    final tableChipMode = settings.chipDisplayMode.tableMode;

    return Scaffold(
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
              // Cap the coach band so it can never starve the felt.
              final coachMaxHeight =
                  (constraints.maxHeight * 0.26).clamp(96.0, 190.0);

              final coach = CoachShelfWidget(
                feedback: session.coach,
                bigBlind: game?.bigBlind ?? 2,
                chipDisplayMode: settings.chipDisplayMode,
                ttsEnabled: settings.ttsEnabled,
                replaying: session.replaying,
                maxHeight: wide ? null : coachMaxHeight,
                onMuteToggle: () => ref
                    .read(settingsProvider.notifier)
                    .setTts(!settings.ttsEnabled),
              );

              return Column(
                children: [
                  _TableHeader(
                    game: game,
                    onBack: () => Navigator.pop(context),
                    onLegend: game == null ? null : () => _openLegend(game),
                    onReview: handOver && session.coach.hasVerdict
                        ? () => _openOptionalReview(session)
                        : null,
                    onNext: handOver
                        ? () =>
                            ref.read(gameControllerProvider.notifier).nextHand()
                        : null,
                  ),
                  if (session.loading)
                    const Expanded(child: _DealingIndicator())
                  else if (game == null)
                    Expanded(
                      child: _EmptyTable(
                        message: session.error ?? 'No hand loaded',
                        onBack: () => Navigator.pop(context),
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
                                    collectingChips: session.collectingChips,
                                  ),
                                ),
                                HeroRailWidget(
                                  game: game,
                                  chipDisplayMode: tableChipMode,
                                  isThinking: session.replaying,
                                ),
                                ActionDockWidget(
                                  game: game,
                                  enabled: session.heroCanAct,
                                  onAction: (action) => ref
                                      .read(gameControllerProvider.notifier)
                                      .heroAct(action),
                                ),
                              ],
                            ),
                          ),
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
                      ),
                    ),
                    HeroRailWidget(
                      game: game,
                      chipDisplayMode: tableChipMode,
                      isThinking: session.replaying,
                    ),
                    coach,
                    ActionDockWidget(
                      game: game,
                      enabled: session.heroCanAct,
                      onAction: (action) => ref
                          .read(gameControllerProvider.notifier)
                          .heroAct(action),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.game,
    required this.onBack,
    required this.onLegend,
    required this.onReview,
    required this.onNext,
  });

  final GameState? game;
  final VoidCallback onBack;
  final VoidCallback? onLegend;
  final VoidCallback? onReview;
  final VoidCallback? onNext;

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
          if (onNext != null) ...[
            if (onReview != null)
              TextButton(
                onPressed: onReview,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.slate,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Review',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            _NextHandCta(onPressed: onNext!),
          ] else
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

/// Gold filled **Next** control with a soft pulse so hand-over is unmistakable.
class _NextHandCta extends StatefulWidget {
  const _NextHandCta({required this.onPressed});

  final VoidCallback onPressed;

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
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next',
                  style: GoogleFonts.manrope(
                    color: AppColors.bgDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.bgDark,
                ),
              ],
            ),
          ),
        ),
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
            'Dealing…',
            style: GoogleFonts.manrope(color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}

class _EmptyTable extends StatelessWidget {
  const _EmptyTable({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

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
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
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
