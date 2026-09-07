/// Main gameplay table screen with felt, coach shelf, and action dock.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/ui/widgets/action_dock_widget.dart';
import 'package:live_poker_trainer/ui/widgets/coach_shelf_widget.dart';
import 'package:live_poker_trainer/ui/widgets/ev_audit_modal.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';

/// Smartphone / tablet optimized poker table.
class PokerTableScreen extends ConsumerStatefulWidget {
  /// Creates the poker table screen.
  const PokerTableScreen({super.key});

  @override
  ConsumerState<PokerTableScreen> createState() => _PokerTableScreenState();
}

class _PokerTableScreenState extends ConsumerState<PokerTableScreen> {
  bool _auditShown = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameControllerProvider);
    final settings = ref.watch(settingsProvider);
    final game = session.game;

    ref.listen<TableSession>(gameControllerProvider, (prev, next) {
      if (next.showEvAudit &&
          next.game != null &&
          next.coach.hasVerdict &&
          !_auditShown) {
        _auditShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          EvAuditModal.show(
            context,
            game: next.game!,
            feedback: next.coach,
            onNext: () {
              _auditShown = false;
              ref.read(gameControllerProvider.notifier).startPractice();
            },
          ).whenComplete(() {
            _auditShown = false;
            ref.read(gameControllerProvider.notifier).dismissEvAudit();
          });
        });
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.bgMid, AppColors.bgDark],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.slate),
                    ),
                    Expanded(
                      child: Text(
                        game?.mode == GameMode.practice
                            ? 'Practice'
                            : 'Cash Sim',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    if (game != null && game.isHandOver)
                      TextButton(
                        onPressed: () {
                          _auditShown = false;
                          final mode = game.mode;
                          if (mode == GameMode.practice) {
                            ref
                                .read(gameControllerProvider.notifier)
                                .startPractice();
                          } else {
                            ref
                                .read(gameControllerProvider.notifier)
                                .startCashSim(continueTable: true);
                          }
                        },
                        child: Text(
                          'Next',
                          style: GoogleFonts.inter(color: AppColors.gold),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              if (session.loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (game == null)
                Expanded(
                  child: Center(
                    child: Text(
                      session.error ?? 'No hand loaded',
                      style: GoogleFonts.inter(color: AppColors.slate),
                    ),
                  ),
                )
              else ...[
                if (game.resultMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      game.resultMessage!,
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      if (wide) {
                        return Row(
                          children: [
                            Expanded(flex: 3, child: FeltTableView(game: game)),
                            SizedBox(
                              width: 320,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: CoachShelfWidget(
                                  feedback: session.coach,
                                  ttsEnabled: settings.ttsEnabled,
                                  onMuteToggle: () => ref
                                      .read(settingsProvider.notifier)
                                      .setTts(!settings.ttsEnabled),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return FeltTableView(game: game);
                    },
                  ),
                ),
                if (MediaQuery.sizeOf(context).width < 900)
                  CoachShelfWidget(
                    feedback: session.coach,
                    ttsEnabled: settings.ttsEnabled,
                    onMuteToggle: () => ref
                        .read(settingsProvider.notifier)
                        .setTts(!settings.ttsEnabled),
                  ),
                if (game.waitingForHero && !game.isHandOver)
                  ActionDockWidget(
                    game: game,
                    enabled: !session.loading,
                    onAction: (action) => ref
                        .read(gameControllerProvider.notifier)
                        .heroAct(action),
                  )
                else
                  const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
