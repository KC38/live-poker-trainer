/// Stats dashboard with EV and accuracy charts.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';

/// Progress / leak-finder screen.
class StatsScreen extends ConsumerWidget {
  /// Creates the stats screen.
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats & Leaks')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (stats) {
          final spots = stats.recentEvDeltas;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _MetricCard(
                title: 'Exploitative Accuracy',
                value: '${stats.accuracyPct.toStringAsFixed(1)}%',
                subtitle: '${stats.correctSpots}/${stats.totalSpots} spots',
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'Net EV Δ',
                value:
                    '${stats.netEvBb >= 0 ? '+' : ''}${stats.netEvBb.toStringAsFixed(2)} BB',
                subtitle: 'Lifetime practice EV',
              ),
              const SizedBox(height: 20),
              Text(
                'Recent EV Δ',
                style: GoogleFonts.cinzel(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: spots.isEmpty
                    ? Center(
                        child: Text(
                          'Play practice spots to populate the chart.',
                          style: GoogleFonts.inter(color: AppColors.slate),
                        ),
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
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                'By Archetype',
                style: GoogleFonts.cinzel(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (stats.archetypeAccuracy.isEmpty)
                Text(
                  'No archetype data yet.',
                  style: GoogleFonts.inter(color: AppColors.slate),
                )
              else
                for (final entry in stats.archetypeAccuracy.entries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.key),
                    subtitle: Text(
                      '${entry.value.correct}/${entry.value.played} correct',
                    ),
                    trailing: Text(
                      '${entry.value.accuracyPct.toStringAsFixed(0)}%',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              Text(
                'By Street',
                style: GoogleFonts.cinzel(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (stats.streetAccuracy.isEmpty)
                Text(
                  'No street data yet.',
                  style: GoogleFonts.inter(color: AppColors.slate),
                )
              else
                for (final entry in stats.streetAccuracy.entries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.key),
                    trailing: Text(
                      '${entry.value.accuracyPct.toStringAsFixed(0)}%',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slateDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(color: AppColors.slate, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(color: AppColors.slate, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
