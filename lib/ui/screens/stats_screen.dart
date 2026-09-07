/// Stats dashboard with EV and accuracy charts.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/ui/widgets/leak_finder_section.dart';

/// Progress / leak-finder screen.
class StatsScreen extends ConsumerWidget {
  /// Creates the stats screen.
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final leaksAsync = ref.watch(mistakeStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [AppColors.bgMid, AppColors.bgDark],
          ),
        ),
        child: statsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (e, _) => Center(
            child: Text('$e', style: GoogleFonts.manrope(color: AppColors.slate)),
          ),
          data: (stats) {
            final spots = stats.recentEvDeltas;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _MetricBlock(
                  title: 'Accuracy',
                  value: '${stats.accuracyPct.toStringAsFixed(1)}%',
                  subtitle: '${stats.correctSpots} of ${stats.totalSpots} spots',
                ),
                const SizedBox(height: 12),
                _MetricBlock(
                  title: 'Net EV Δ',
                  value:
                      '${stats.netEvBb >= 0 ? '+' : ''}${stats.netEvBb.toStringAsFixed(2)} BB',
                  subtitle: 'Lifetime practice',
                ),
                const SizedBox(height: 28),
                leaksAsync.when(
                  loading: () => const SizedBox(
                    height: 48,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  error: (e, _) => _EmptyHint('Leak Finder unavailable: $e'),
                  data: (leaks) => LeakFinderSection(stats: leaks),
                ),
                const SizedBox(height: 28),
                Text(
                  'Recent EV Δ',
                  style: GoogleFonts.cinzel(
                    color: AppColors.goldMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 168,
                  child: spots.isEmpty
                      ? _EmptyHint(
                          'Play a few practice spots — your EV curve shows up here.',
                        )
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (var i = 0; i < spots.length; i++)
                                    FlSpot(i.toDouble(), spots[i]),
                                ],
                                isCurved: true,
                                color: AppColors.gold,
                                barWidth: 2.5,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.gold.withValues(alpha: 0.08),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 28),
                Text(
                  'By archetype',
                  style: GoogleFonts.cinzel(
                    color: AppColors.goldMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                if (stats.archetypeAccuracy.isEmpty)
                  const _EmptyHint('No archetype data yet.')
                else
                  for (final entry in stats.archetypeAccuracy.entries)
                    _RowStat(
                      label: entry.key,
                      detail:
                          '${entry.value.correct}/${entry.value.played} correct',
                      trailing:
                          '${entry.value.accuracyPct.toStringAsFixed(0)}%',
                    ),
                const SizedBox(height: 20),
                Text(
                  'By street',
                  style: GoogleFonts.cinzel(
                    color: AppColors.goldMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                if (stats.streetAccuracy.isEmpty)
                  const _EmptyHint('No street data yet.')
                else
                  for (final entry in stats.streetAccuracy.entries)
                    _RowStat(
                      label: entry.key,
                      trailing:
                          '${entry.value.accuracyPct.toStringAsFixed(0)}%',
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slateDark.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.goldBright,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RowStat extends StatelessWidget {
  const _RowStat({
    required this.label,
    required this.trailing,
    this.detail,
  });

  final String label;
  final String trailing;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: GoogleFonts.manrope(
                      color: AppColors.slate,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            trailing,
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.manrope(color: AppColors.slate, height: 1.4),
      ),
    );
  }
}
