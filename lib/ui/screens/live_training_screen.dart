/// Live Training hub: table setup and Start training CTA.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/poker_constants.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/screens/poker_table_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

/// Live Training destination — full-hand simulator launcher and table setup.
class LiveTrainingScreen extends ConsumerStatefulWidget {
  /// Creates the Live Training hub.
  const LiveTrainingScreen({super.key});

  @override
  ConsumerState<LiveTrainingScreen> createState() => _LiveTrainingScreenState();
}

class _LiveTrainingScreenState extends ConsumerState<LiveTrainingScreen> {
  bool _setupExpanded = false;
  bool _launching = false;
  StreamSubscription<String>? _agentSub;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _agentSub = AgentCommands.stream.listen((cmd) {
        if (cmd == 'start') unawaited(_launchTraining());
      });
    }
  }

  @override
  void dispose() {
    unawaited(_agentSub?.cancel());
    super.dispose();
  }

  Future<void> _syncIdleBgm() async {
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

  /// Navigates immediately; the table kicks off deal + SFX once it is visible.
  Future<void> _launchTraining() async {
    if (_launching) return;
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null && user.isAnonymous) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create an account before Live Training.'),
        ),
      );
      return;
    }
    setState(() => _launching = true);

    final sound = ref.read(soundServiceProvider);

    // Kick off unlock/BGM fade from this gesture, but do not wait — prepare +
    // navigate must feel instantaneous. Table SFX still wait for kickoff.
    unawaited(sound.unlock());
    unawaited(sound.pauseHomeBgm());
    ref.read(gameControllerProvider.notifier).prepareTraining();

    if (!mounted) return;
    final settings = ref.read(settingsProvider);
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logTrainingLaunch(
            seatCount: settings.seatCount,
            stackDepthBb: settings.maxStackDepthBb,
            lineupMode: LineupMode.randomPool.name,
          ),
    );

    await Navigator.push(
      context,
      softFadeRoute(
        const PokerTableScreen(),
        name: AnalyticsScreens.pokerTable,
      ),
    );

    unawaited(_syncIdleBgm());
    if (mounted) {
      setState(() => _launching = false);
    }
  }

  String _setupSummary(GameSettingsModel s) {
    final blinds =
        '\$${s.smallBlind % 1 == 0 ? s.smallBlind.toInt() : s.smallBlind}/'
        '\$${s.bigBlind % 1 == 0 ? s.bigBlind.toInt() : s.bigBlind}';
    return '${s.seatCount} seats · $blinds · '
        '${s.maxStackDepthBb} BB max · Random lineup';
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Focus(
      autofocus: kDebugMode,
      child: CallbackShortcuts(
        bindings: {
          if (kDebugMode) ...{
            const SingleActivator(LogicalKeyboardKey.enter): _launchTraining,
            const SingleActivator(LogicalKeyboardKey.keyS): _launchTraining,
          },
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.55),
                radius: 1.15,
                colors: [Color(0xFF1A2E28), AppColors.bgMid, AppColors.bgDark],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/brand/logo_mark.png',
                            width: 76,
                            height: 76,
                            filterQuality: FilterQuality.medium,
                            errorBuilder:
                                (_, _, _) => const Icon(
                                  Icons.style,
                                  size: 56,
                                  color: AppColors.gold,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Live Training',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Full hands from the deal — live coaching each street.',
                            style: GoogleFonts.manrope(
                              color: AppColors.slate,
                              fontSize: 16,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Learn when to deviate — calm spots, clear coaching.',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: AppColors.slate.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _launching ? null : _launchTraining,
                              child:
                                  _launching
                                      ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: AppColors.bgDark,
                                        ),
                                      )
                                      : const Text('Start training'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _TableSetupSection(
                            expanded: _setupExpanded,
                            summary: _setupSummary(settings),
                            onToggle:
                                () => setState(
                                  () => _setupExpanded = !_setupExpanded,
                                ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _Label('Seats'),
                                _StepperTile(
                                  value: '${settings.seatCount}',
                                  onDec:
                                      () => notifier.setSeatCount(
                                        settings.seatCount - 1,
                                      ),
                                  onInc:
                                      () => notifier.setSeatCount(
                                        settings.seatCount + 1,
                                      ),
                                ),
                                const SizedBox(height: 18),
                                _Label('Blinds'),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final stake
                                        in PokerConstants.stakePresets)
                                      ChoiceChip(
                                        label: Text(
                                          '\$${stake.$1 % 1 == 0 ? stake.$1.toInt() : stake.$1}/'
                                          '\$${stake.$2 % 1 == 0 ? stake.$2.toInt() : stake.$2}',
                                        ),
                                        selected:
                                            settings.smallBlind == stake.$1 &&
                                            settings.bigBlind == stake.$2,
                                        onSelected:
                                            (_) => notifier.setBlinds(
                                              stake.$1,
                                              stake.$2,
                                            ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _Label('Maximum stack depth'),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final depth
                                        in PokerConstants.stackDepthPresets)
                                      ChoiceChip(
                                        label: Text('$depth BB'),
                                        selected:
                                            settings.maxStackDepthBb == depth,
                                        onSelected:
                                            (_) =>
                                                notifier.setMaxStackDepthBb(
                                                  depth,
                                                ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _Label('Lineup'),
                                Text(
                                  'A new ordered mix of bounded live-player '
                                  'profiles is generated for every hand.',
                                  style: GoogleFonts.manrope(
                                    color: AppColors.slate,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _TableSetupSection extends StatelessWidget {
  const _TableSetupSection({
    required this.expanded,
    required this.summary,
    required this.onToggle,
    required this.child,
  });

  final bool expanded;
  final String summary;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slateDark.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table setup',
                          style: GoogleFonts.cinzel(
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary,
                          style: GoogleFonts.manrope(
                            color: AppColors.slate,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 240),
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            // The section's own background sits between the settings tiles and
            // the page Material, which would swallow their ink; a transparent
            // Material here gives them a nearer surface to paint on.
            secondChild: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: child,
              ),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: AppColors.cream.withValues(alpha: 0.85),
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.value,
    required this.onDec,
    required this.onInc,
  });

  final String value;
  final VoidCallback onDec;
  final VoidCallback onInc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onDec,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.bgDark.withValues(alpha: 0.4),
          ),
          icon: const Icon(Icons.remove, color: AppColors.slate),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w800,
              color: AppColors.goldBright,
              fontSize: 22,
            ),
          ),
        ),
        IconButton(
          onPressed: onInc,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.bgDark.withValues(alpha: 0.4),
          ),
          icon: const Icon(Icons.add, color: AppColors.slate),
        ),
      ],
    );
  }
}
