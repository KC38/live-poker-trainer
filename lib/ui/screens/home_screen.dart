/// Home setup: seats, blinds, stack/rebuy, Practice / Cash Sim launch.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/poker_constants.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/ui/screens/poker_table_screen.dart';
import 'package:live_poker_trainer/ui/screens/settings_screen.dart';
import 'package:live_poker_trainer/ui/screens/stats_screen.dart';

/// Landing / table configuration screen.
class HomeScreen extends ConsumerWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  List<Widget> _customSeatPickers(
    GameSettingsModel settings,
    SettingsNotifier notifier,
  ) {
    final normalized = settings.withNormalizedCustomLineup();
    return [
      for (var i = 0; i < normalized.customArchetypes.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  'Seat ${i + 2}',
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: DropdownButtonFormField<PlayerArchetype>(
                  initialValue: normalized.customArchetypes[i],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  dropdownColor: AppColors.bgMid,
                  items: [
                    for (final arch in ArchetypeRoster.villainPool)
                      DropdownMenuItem(
                        value: arch,
                        child: Text(
                          '${arch.badge}  ${arch.label}',
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ),
                  ],
                  onChanged: (arch) {
                    if (arch != null) {
                      notifier.setCustomArchetypeAt(i, arch);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final unplayed = ref.watch(unplayedCountProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [AppColors.bgMid, AppColors.bgDark],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Exploitative\nPoker Lab',
                      style: GoogleFonts.cinzel(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                        height: 1.15,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const StatsScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.insights, color: AppColors.slate),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.settings, color: AppColors.slate),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Train exploitative lines vs live archetypes.',
                style: GoogleFonts.inter(color: AppColors.slate),
              ),
              const SizedBox(height: 8),
              unplayed.when(
                data: (c) => Text(
                  'Cached unplayed spots: $c',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppColors.slate,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              _SectionTitle('Table'),
              _StepperTile(
                label: 'Seats',
                value: '${settings.seatCount}',
                onDec: () => notifier.setSeatCount(settings.seatCount - 1),
                onInc: () => notifier.setSeatCount(settings.seatCount + 1),
              ),
              const SizedBox(height: 12),
              _SectionTitle('Blinds'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final stake in PokerConstants.stakePresets)
                    ChoiceChip(
                      label: Text(
                        '\$${stake.$1 % 1 == 0 ? stake.$1.toInt() : stake.$1}/\$${stake.$2 % 1 == 0 ? stake.$2.toInt() : stake.$2}',
                      ),
                      selected: settings.smallBlind == stake.$1 &&
                          settings.bigBlind == stake.$2,
                      onSelected: (_) => notifier.setBlinds(stake.$1, stake.$2),
                      selectedColor: AppColors.gold.withValues(alpha: 0.25),
                      labelStyle: GoogleFonts.jetBrainsMono(
                        color: AppColors.cream,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionTitle('Stack depth'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final depth in PokerConstants.stackDepthPresets)
                    ChoiceChip(
                      label: Text('$depth BB'),
                      selected: settings.stackDepthBb == depth,
                      onSelected: (_) => notifier.setStackDepthBb(depth),
                      selectedColor: AppColors.gold.withValues(alpha: 0.25),
                      labelStyle: GoogleFonts.jetBrainsMono(
                        color: AppColors.cream,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Auto-rebuy',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Top up when below ${settings.rebuyThresholdBb} BB',
                  style: GoogleFonts.inter(color: AppColors.slate, fontSize: 13),
                ),
                value: settings.autoRebuy,
                onChanged: notifier.setAutoRebuy,
              ),
              if (settings.autoRebuy)
                Row(
                  children: [
                    Text(
                      'Threshold BB',
                      style: GoogleFonts.inter(color: AppColors.slate),
                    ),
                    Expanded(
                      child: Slider(
                        value: settings.rebuyThresholdBb.toDouble(),
                        min: 20,
                        max: 100,
                        divisions: 16,
                        label: '${settings.rebuyThresholdBb}',
                        onChanged: (v) =>
                            notifier.setRebuyThresholdBb(v.round()),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              _SectionTitle('Lineup'),
              SegmentedButton<LineupMode>(
                segments: const [
                  ButtonSegment(
                    value: LineupMode.randomPool,
                    label: Text('Random Pool'),
                  ),
                  ButtonSegment(
                    value: LineupMode.custom,
                    label: Text('Custom'),
                  ),
                ],
                selected: {settings.lineupMode},
                onSelectionChanged: (s) => notifier.setLineupMode(s.first),
              ),
              if (settings.lineupMode == LineupMode.custom) ...[
                const SizedBox(height: 12),
                Text(
                  'Assign an archetype to each villain seat (Hero is always seat 1 / bottom).',
                  style: GoogleFonts.inter(color: AppColors.slate, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ..._customSeatPickers(settings, notifier),
              ],
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(gameControllerProvider.notifier).startPractice();
                  if (!context.mounted) return;
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const PokerTableScreen(),
                    ),
                  );
                },
                child: const Text('Practice Mode'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await ref.read(gameControllerProvider.notifier).startCashSim();
                  if (!context.mounted) return;
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const PokerTableScreen(),
                    ),
                  );
                },
                child: const Text('Cash Game Sim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.cinzel(
          fontWeight: FontWeight.w700,
          color: AppColors.goldMuted,
        ),
      ),
    );
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.label,
    required this.value,
    required this.onDec,
    required this.onInc,
  });

  final String label;
  final String value;
  final VoidCallback onDec;
  final VoidCallback onInc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        const Spacer(),
        IconButton(onPressed: onDec, icon: const Icon(Icons.remove_circle_outline)),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w800,
            color: AppColors.gold,
          ),
        ),
        IconButton(onPressed: onInc, icon: const Icon(Icons.add_circle_outline)),
      ],
    );
  }
}
