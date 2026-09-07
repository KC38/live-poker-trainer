/// Stats-screen "Leak Finder": repeated mistakes, trends, and fixes.
///
/// Teach-first layout: a short summary line, the top repeated leaks as plain
/// rows (count, last seen, trend), then one compact bar chart each for the
/// archetype and street breakdown.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';

/// Leak Finder block for the Stats screen.
class LeakFinderSection extends StatelessWidget {
  /// Creates the section.
  const LeakFinderSection({super.key, required this.stats, this.now});

  final MistakeStats stats;

  /// Reference time for "last seen" labels (defaults to now; fixed in tests).
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final now = this.now ?? DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Leak Finder'),
        const SizedBox(height: 6),
        Text(
          stats.isEmpty
              ? 'Every INCORRECT decision is filed under a pattern. Repeats '
                  'and fixes show up here.'
              : '${stats.totalMistakes} '
                  '${stats.totalMistakes == 1 ? 'mistake' : 'mistakes'} '
                  'across ${stats.topMistakes.length} '
                  '${stats.topMistakes.length == 1 ? 'pattern' : 'patterns'}'
                  '  ·  ${stats.totalImprovements} '
                  '${stats.totalImprovements == 1 ? 'fix' : 'fixes'} '
                  'acknowledged',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        if (stats.isEmpty)
          const _EmptyHint('No leaks recorded yet — keep playing.')
        else ...[
          for (final leak in stats.topMistakes)
            _LeakRow(leak: leak, now: now),
          const SizedBox(height: 22),
          _SubTitle('Mistakes by archetype'),
          const SizedBox(height: 10),
          _CountBars(
            counts: stats.byArchetype,
            colorFor: _archetypeColor,
          ),
          const SizedBox(height: 22),
          _SubTitle('Mistakes by street'),
          const SizedBox(height: 10),
          _CountBars(
            counts: _orderedStreets(stats.byStreet),
            colorFor: (_) => AppColors.gold,
          ),
        ],
      ],
    );
  }

  static Map<String, int> _orderedStreets(Map<String, int> raw) {
    const order = ['preflop', 'flop', 'turn', 'river'];
    final out = <String, int>{};
    for (final s in order) {
      if (raw.containsKey(s)) out[s] = raw[s]!;
    }
    for (final e in raw.entries) {
      out.putIfAbsent(e.key, () => e.value);
    }
    return out;
  }

  static Color _archetypeColor(String label) => switch (label) {
        'Maniac' => AppColors.maniac,
        'Nit' => AppColors.nit,
        'Calling Station' => AppColors.station,
        'TAG' => AppColors.tag,
        'LAG' => AppColors.lag,
        _ => AppColors.gold,
      };
}

/// One repeated-leak row: title, tag, count, last seen, trend.
class _LeakRow extends StatelessWidget {
  const _LeakRow({required this.leak, required this.now});

  final MistakeSummary leak;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final trend = leak.trend;
    final (trendLabel, trendColor, trendIcon) = switch (trend) {
      MistakeTrend.improving => (
          leak.currentStreak >= 2
              ? 'Improving ×${leak.currentStreak}'
              : 'Improving',
          AppColors.success,
          Icons.trending_up_rounded,
        ),
      MistakeTrend.recurring => (
          'Recurring',
          AppColors.warning,
          Icons.replay_rounded,
        ),
      MistakeTrend.isolated => (
          'Once',
          AppColors.slate,
          Icons.remove_rounded,
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slateDark.withValues(alpha: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leak.title,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                    fontSize: 13.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${leak.tag.label}  ·  last ${_ago(leak.lastSeen, now)}'
                  '${leak.improvements > 0 ? '  ·  fixed ${leak.improvements}×' : ''}',
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(trendIcon, size: 13, color: trendColor),
                    const SizedBox(width: 4),
                    Text(
                      trendLabel,
                      style: GoogleFonts.jetBrainsMono(
                        color: trendColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '×${leak.count}',
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.goldBright,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              Text(
                '-${leak.evLostBb.toStringAsFixed(1)} BB',
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.danger,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _ago(DateTime when, DateTime now) {
    final d = now.difference(when);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays == 1) return 'yesterday';
    return '${d.inDays}d ago';
  }
}

/// Horizontal-label bar chart of counts per category.
class _CountBars extends StatelessWidget {
  const _CountBars({required this.counts, required this.colorFor});

  final Map<String, int> counts;
  final Color Function(String) colorFor;

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) return const _EmptyHint('No data yet.');
    final entries = counts.entries.toList();
    final maxY = entries.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    return SizedBox(
      height: 132,
      child: BarChart(
        BarChartData(
          maxY: (maxY + 1).toDouble(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= entries.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _short(entries[i].key),
                      style: GoogleFonts.manrope(
                        color: AppColors.slate,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                showingTooltipIndicators: const [0],
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value.toDouble(),
                    width: 18,
                    color: colorFor(entries[i].key),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
          ],
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 2,
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                rod.toY.toInt().toString(),
                GoogleFonts.jetBrainsMono(
                  color: AppColors.cream,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _short(String label) => switch (label) {
        'Calling Station' => 'Station',
        'preflop' => 'Pre',
        'flop' => 'Flop',
        'turn' => 'Turn',
        'river' => 'River',
        _ => label,
      };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.cinzel(
        color: AppColors.goldMuted,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        color: AppColors.cream,
        fontWeight: FontWeight.w600,
        fontSize: 13,
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
