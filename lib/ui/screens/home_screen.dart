/// Home: single Start training CTA, progressive disclosure for table setup.
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
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

/// Landing screen — teach-first, minimal choices above the fold.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _setupExpanded = false;

  Future<void> _launchTraining() async {
    await ref.read(gameControllerProvider.notifier).startTraining();
    if (!mounted) return;
    await Navigator.push(
      context,
      softFadeRoute(const PokerTableScreen()),
    );
  }

  List<Widget> _customSeatPickers(
    GameSettingsModel settings,
    SettingsNotifier notifier,
  ) {
    final normalized = settings.withNormalizedCustomLineup();
    return [
      for (var i = 0; i < normalized.customArchetypes.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 64,
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
                  decoration: const InputDecoration(isDense: true),
                  dropdownColor: AppColors.bgElevated,
                  items: [
                    for (final arch in ArchetypeRoster.villainPool)
                      DropdownMenuItem(
                        value: arch,
                        child: Text(
                          '${arch.badge}  ${arch.label}',
                          style: GoogleFonts.manrope(fontSize: 14),
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

  String _setupSummary(GameSettingsModel s) {
    final blinds =
        '\$${s.smallBlind % 1 == 0 ? s.smallBlind.toInt() : s.smallBlind}/'
        '\$${s.bigBlind % 1 == 0 ? s.bigBlind.toInt() : s.bigBlind}';
    final lineup =
        s.lineupMode == LineupMode.custom ? 'Custom lineup' : 'Random lineup';
    return '${s.seatCount} seats · $blinds · ${s.stackDepthBb} BB · $lineup';
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.15,
            colors: [
              Color(0xFF1A2E28),
              AppColors.bgMid,
              AppColors.bgDark,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    tooltip: 'Progress',
                    onPressed: () => Navigator.push(
                      context,
                      softFadeRoute(const StatsScreen()),
                    ),
                    icon: const Icon(Icons.insights_outlined, color: AppColors.slate),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () => Navigator.push(
                      context,
                      softFadeRoute(const SettingsScreen()),
                    ),
                    icon: const Icon(Icons.settings_outlined, color: AppColors.slate),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Generated brand mark (see tool/gen_app_art.py).
              Image.asset(
                'assets/brand/logo_mark.png',
                width: 76,
                height: 76,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.style,
                  size: 56,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Exploitative\nPoker Lab',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Learn when to deviate — calm spots, clear coaching.',
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Full hands from the deal · live coaching each street',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: AppColors.slate.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _launchTraining,
                  child: const Text('Start training'),
                ),
              ),
              const SizedBox(height: 28),
              _TableSetupSection(
                expanded: _setupExpanded,
                summary: _setupSummary(settings),
                onToggle: () => setState(() => _setupExpanded = !_setupExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Label('Seats'),
                    _StepperTile(
                      value: '${settings.seatCount}',
                      onDec: () => notifier.setSeatCount(settings.seatCount - 1),
                      onInc: () => notifier.setSeatCount(settings.seatCount + 1),
                    ),
                    const SizedBox(height: 18),
                    _Label('Blinds'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final stake in PokerConstants.stakePresets)
                          ChoiceChip(
                            label: Text(
                              '\$${stake.$1 % 1 == 0 ? stake.$1.toInt() : stake.$1}/'
                              '\$${stake.$2 % 1 == 0 ? stake.$2.toInt() : stake.$2}',
                            ),
                            selected: settings.smallBlind == stake.$1 &&
                                settings.bigBlind == stake.$2,
                            onSelected: (_) =>
                                notifier.setBlinds(stake.$1, stake.$2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Label('Stack depth'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final depth in PokerConstants.stackDepthPresets)
                          ChoiceChip(
                            label: Text('$depth BB'),
                            selected: settings.stackDepthBb == depth,
                            onSelected: (_) => notifier.setStackDepthBb(depth),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Auto-rebuy',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Top up below ${settings.rebuyThresholdBb} BB',
                        style: GoogleFonts.manrope(
                          color: AppColors.slate,
                          fontSize: 13,
                        ),
                      ),
                      value: settings.autoRebuy,
                      onChanged: notifier.setAutoRebuy,
                    ),
                    if (settings.autoRebuy)
                      Row(
                        children: [
                          Text(
                            'Threshold',
                            style: GoogleFonts.manrope(color: AppColors.slate),
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
                          Text(
                            '${settings.rebuyThresholdBb}',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    _Label('Lineup'),
                    SegmentedButton<LineupMode>(
                      segments: const [
                        ButtonSegment(
                          value: LineupMode.randomPool,
                          label: Text('Random'),
                        ),
                        ButtonSegment(
                          value: LineupMode.custom,
                          label: Text('Custom'),
                        ),
                      ],
                      selected: {settings.lineupMode},
                      onSelectionChanged: (s) =>
                          notifier.setLineupMode(s.first),
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? AppColors.bgDark
                              : AppColors.slate,
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? AppColors.gold
                              : AppColors.bgElevated,
                        ),
                      ),
                    ),
                    if (settings.lineupMode == LineupMode.custom) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Assign each villain seat. Hero stays at the bottom.',
                        style: GoogleFonts.manrope(
                          color: AppColors.slate,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._customSeatPickers(settings, notifier),
                    ],
                  ],
                ),
              ),
            ],
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
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
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
