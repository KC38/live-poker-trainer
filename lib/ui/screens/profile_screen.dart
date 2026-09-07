/// Player profile: identity, playing style, poker stats, and coach review.
///
/// The screen is deliberately teach-first. Every rate carries the sample it
/// came from, taps through to a plain-English explanation of what it measures
/// and what a healthy number looks like, and shows an em dash with a "needs N
/// more" hint rather than a misleading figure. The style label is withheld
/// entirely below [StyleThresholds.minHands] hands.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/engine/hero_profiler.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/ui/screens/stats_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/profile_avatar.dart';
import 'package:live_poker_trainer/ui/widgets/profile_identity_sheet.dart';

/// The player's own profile.
class ProfileScreen extends ConsumerWidget {
  /// Creates the profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(heroProfileControllerProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Player profile')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
            radius: 1.2,
            colors: [AppColors.bgMid, AppColors.bgDark],
          ),
        ),
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (e, _) => _ErrorState(message: '$e'),
          data: (profile) => _ProfileBody(
            profile: profile,
            coachingStats: statsAsync.valueOrNull,
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile, required this.coachingStats});

  final HeroProfileView profile;
  final UserStatsModel? coachingStats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = profile.metrics;
    final controller = ref.read(heroProfileControllerProvider.notifier);

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.bgElevated,
      onRefresh: controller.refreshMetrics,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          _ProfileHeader(profile: profile),
          if (!metrics.style.isKnown) ...[
            const SizedBox(height: 14),
            _NeedsMoreHands(style: metrics.style),
          ],
          const SizedBox(height: 22),
          _CoachReviewCard(profile: profile),
          const SizedBox(height: 26),
          _TrendCard(metrics: metrics, coachingStats: coachingStats),
          const SizedBox(height: 26),
          const _SectionTitle('Your numbers'),
          const SizedBox(height: 4),
          Text(
            'Tap any stat to learn what it measures.',
            style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          _MetricGrid(metrics: metrics),
          if (metrics.streetTendencies.any((s) => s.hasEnoughData)) ...[
            const SizedBox(height: 26),
            const _SectionTitle('Street by street'),
            const SizedBox(height: 10),
            for (final street in metrics.streetTendencies)
              if (street.hasEnoughData) _StreetRow(street: street),
          ],
          if (metrics.archetypeTendencies.any((a) => a.hasEnoughData)) ...[
            const SizedBox(height: 26),
            const _SectionTitle('Against each player type'),
            const SizedBox(height: 10),
            for (final tendency in metrics.archetypeTendencies)
              if (tendency.hasEnoughData)
                _ArchetypeRow(tendency: tendency),
          ],
          if (coachingStats != null && coachingStats!.totalSpots > 0) ...[
            const SizedBox(height: 26),
            const _SectionTitle('Coaching record'),
            const SizedBox(height: 10),
            _CoachingRecord(stats: coachingStats!),
          ],
          const SizedBox(height: 26),
          const _LeakFinderLink(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Header
// -----------------------------------------------------------------------------

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.profile});

  final HeroProfileView profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = profile.identity;
    final style = profile.metrics.style;
    final accent = style.style.color.color;

    return _Panel(
      child: Row(
        children: [
          ProfileAvatar(identity: identity, size: 76),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  identity.seatName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldBright,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Pill(
                      label: style.isKnown
                          ? style.style.label
                          : 'Style forming',
                      color: accent,
                    ),
                    Text(
                      style.confidence.label,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _handsLabel(profile.metrics),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit name and picture',
            onPressed: () => ProfileIdentitySheet.show(context, identity),
            icon: const Icon(Icons.edit_outlined, color: AppColors.slate),
          ),
        ],
      ),
    );
  }

  static String _handsLabel(HeroMetrics metrics) {
    final hands = metrics.handsPlayed;
    final vpipPfr = metrics.vpipPfrLabel;
    final base = '$hands ${hands == 1 ? 'hand' : 'hands'} logged';
    return vpipPfr == null ? base : '$base · $vpipPfr';
  }
}

class _NeedsMoreHands extends StatelessWidget {
  const _NeedsMoreHands({required this.style});

  final StyleReadout style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldMuted.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.hourglass_bottom_rounded,
            size: 18,
            color: AppColors.goldBright,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              style.explanation,
              style: GoogleFonts.manrope(
                color: AppColors.cream,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// AI review
// -----------------------------------------------------------------------------

class _CoachReviewCard extends ConsumerWidget {
  const _CoachReviewCard({required this.profile});

  final HeroProfileView profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = profile.summary;
    final controller = ref.read(heroProfileControllerProvider.notifier);

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.goldBright,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Coach review',
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldMuted,
                  ),
                ),
              ),
              if (profile.summaryRefreshing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.goldBright,
                  ),
                )
              else
                IconButton(
                  tooltip: 'Get a fresh review',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => controller.refreshSummary(force: true),
                  icon: const Icon(
                    Icons.refresh,
                    size: 18,
                    color: AppColors.slate,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (summary == null)
            Text(
              'Your review appears once a few hands are logged.',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 13.5,
                height: 1.45,
              ),
            )
          else ...[
            Text(
              summary.styleSummary,
              style: GoogleFonts.manrope(
                color: AppColors.cream,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (summary.leaks.isNotEmpty) ...[
              const SizedBox(height: 16),
              _ReviewList(
                title: 'Biggest leaks',
                lines: summary.leaks,
                color: AppColors.warning,
              ),
            ],
            if (summary.adjustments.isNotEmpty) ...[
              const SizedBox(height: 14),
              _ReviewList(
                title: 'Do this next session',
                lines: summary.adjustments,
                color: AppColors.success,
              ),
            ],
            const SizedBox(height: 14),
            Text(
              summary.isFromAi
                  ? 'AI review · ${summary.handsPlayedAt} hands'
                  : 'Offline read from your stats',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9.5,
                color: AppColors.slate.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({
    required this.title,
    required this.lines,
    required this.color,
  });

  final String title;
  final List<String> lines;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 9),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    line,
                    style: GoogleFonts.manrope(
                      color: AppColors.cream.withValues(alpha: 0.92),
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Trend
// -----------------------------------------------------------------------------

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.metrics, required this.coachingStats});

  final HeroMetrics metrics;
  final UserStatsModel? coachingStats;

  @override
  Widget build(BuildContext context) {
    final vpipTrend = metrics.trend;
    final evTrend = coachingStats?.recentEvDeltas ?? const <double>[];

    final useVpip = vpipTrend.length >= 2;
    final points = useVpip
        ? [
            for (var i = 0; i < vpipTrend.length; i++)
              FlSpot(i.toDouble(), vpipTrend[i].vpipPct),
          ]
        : [
            for (var i = 0; i < evTrend.length; i++)
              FlSpot(i.toDouble(), evTrend[i]),
          ];

    final title = useVpip ? 'Hands played over time' : 'Recent EV Δ';
    final caption = useVpip
        ? 'Rolling VPIP over your last ${HeroProfiler.trendWindow} hands. A '
            'flattening line means your preflop discipline is settling.'
        : 'Coached decisions, in big blinds won or lost versus the best line.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title),
        const SizedBox(height: 4),
        Text(
          caption,
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 12.5,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 150,
          child: points.length < 2
              ? _EmptyHint(
                  useVpip
                      ? 'Keep playing — your trend line starts here.'
                      : 'Play a few coached hands and your trend shows up '
                          'here.',
                )
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: points,
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
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Stats
// -----------------------------------------------------------------------------

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final HeroMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 3 : 2;
        const spacing = 12.0;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final id in HeroMetricId.values)
              SizedBox(
                width: tileWidth,
                child: _MetricTile(sample: metrics.sample(id)),
              ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.sample});

  final MetricSample sample;

  @override
  Widget build(BuildContext context) {
    final id = sample.id;
    final color = switch (sample.verdict) {
      MetricVerdict.healthy => AppColors.success,
      MetricVerdict.low => AppColors.warning,
      MetricVerdict.high => AppColors.danger,
      MetricVerdict.unknown => AppColors.slate,
    };

    return InkWell(
      onTap: () => _MetricExplainer.show(context, sample),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.slateDark.withValues(alpha: 0.85),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  id.shortLabel,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: AppColors.gold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.info_outline,
                  size: 12,
                  color: AppColors.slate.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              sample.display,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: sample.reliableValue == null
                    ? AppColors.slate
                    : AppColors.cream,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              id.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.cream.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sample.hasEnoughData
                  ? sample.sampleLabel
                  : 'needs ${sample.opportunitiesNeeded} more',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Explains one metric: what it is, the sample, and the healthy band.
class _MetricExplainer extends StatelessWidget {
  const _MetricExplainer({required this.sample});

  final MetricSample sample;

  static Future<void> show(BuildContext context, MetricSample sample) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _MetricExplainer(sample: sample),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = sample.id;
    final band = switch (id.format) {
      MetricFormat.percent =>
        '${id.healthyLow.toStringAsFixed(0)}–'
            '${id.healthyHigh.toStringAsFixed(0)}%',
      MetricFormat.ratio =>
        '${id.healthyLow.toStringAsFixed(1)}–'
            '${id.healthyHigh.toStringAsFixed(1)}',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${id.label} (${id.shortLabel})',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.goldBright,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            id.helper,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          _KeyValue(label: 'Healthy range', value: band),
          _KeyValue(
            label: 'Yours',
            value: sample.hasEnoughData
                ? '${sample.display} (${sample.sampleLabel})'
                : 'Not shown yet — needs '
                    '${sample.opportunitiesNeeded} more '
                    '${id.format == MetricFormat.ratio ? 'decisions' : 'spots'}',
          ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.cream,
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreetRow extends StatelessWidget {
  const _StreetRow({required this.street});

  final StreetTendency street;

  @override
  Widget build(BuildContext context) {
    final note = street.note;
    final label = street.street.name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label[0].toUpperCase() + label.substring(1),
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                  ),
                ),
              ),
              if (note != null) _Pill(label: note, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 6),
          _MixBar(
            aggressive: street.aggressionPct,
            calls: street.callPct,
            folds: street.foldPct,
          ),
          const SizedBox(height: 5),
          Text(
            'bet/raise ${street.aggressionPct.toStringAsFixed(0)}% · '
            'call ${street.callPct.toStringAsFixed(0)}% · '
            'fold ${street.foldPct.toStringAsFixed(0)}% '
            'over ${street.decisions} decisions',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9.5,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchetypeRow extends StatelessWidget {
  const _ArchetypeRow({required this.tendency});

  final ArchetypeTendency tendency;

  @override
  Widget build(BuildContext context) {
    final note = tendency.note;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tendency.archetype.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'vs ${tendency.archetype.label}',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                  ),
                ),
              ),
              Text(
                '${tendency.netBb >= 0 ? '+' : ''}'
                '${tendency.netBb.toStringAsFixed(1)} BB',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: tendency.netBb >= 0
                      ? AppColors.success
                      : AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _MixBar(
            aggressive: tendency.aggressionPct,
            calls: tendency.callPct,
            folds: tendency.foldPct,
          ),
          if (note != null) ...[
            const SizedBox(height: 7),
            Text(
              note,
              style: GoogleFonts.manrope(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.slate,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Three-segment bar showing the aggressive / call / fold mix.
class _MixBar extends StatelessWidget {
  const _MixBar({
    required this.aggressive,
    required this.calls,
    required this.folds,
  });

  final double aggressive;
  final double calls;
  final double folds;

  @override
  Widget build(BuildContext context) {
    final segments = <(double, Color)>[
      (aggressive, AppColors.danger),
      (calls, AppColors.warning),
      (folds, AppColors.slate),
    ];
    final total = segments.fold<double>(0, (sum, s) => sum + s.$1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 7,
        child: total <= 0
            ? const ColoredBox(color: AppColors.slateDark)
            : Row(
                children: [
                  for (final segment in segments)
                    if (segment.$1 > 0)
                      Expanded(
                        flex: (segment.$1 * 100).round(),
                        child: ColoredBox(color: segment.$2),
                      ),
                ],
              ),
      ),
    );
  }
}

class _CoachingRecord extends StatelessWidget {
  const _CoachingRecord({required this.stats});

  final UserStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          Expanded(
            child: _Figure(
              value: '${stats.accuracyPct.toStringAsFixed(0)}%',
              label: 'Coach agreement',
              detail: '${stats.correctSpots} of ${stats.totalSpots} spots',
            ),
          ),
          Container(width: 1, height: 46, color: AppColors.slateDark),
          Expanded(
            child: _Figure(
              value: '${stats.netEvBb >= 0 ? '+' : ''}'
                  '${stats.netEvBb.toStringAsFixed(1)}',
              label: 'Net EV (BB)',
              detail: 'versus the best line',
            ),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.value,
    required this.label,
    required this.detail,
  });

  final String value;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.goldBright,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.cream,
          ),
        ),
        Text(
          detail,
          style: GoogleFonts.manrope(fontSize: 11, color: AppColors.slate),
        ),
      ],
    );
  }
}

class _LeakFinderLink extends ConsumerWidget {
  const _LeakFinderLink();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaks = ref.watch(mistakeStatsProvider).valueOrNull;
    final top = leaks == null || leaks.topMistakes.isEmpty
        ? null
        : leaks.topMistakes.first;

    return InkWell(
      onTap: () => Navigator.push(context, softFadeRoute(const StatsScreen())),
      borderRadius: BorderRadius.circular(16),
      child: _Panel(
        child: Row(
          children: [
            const Icon(
              Icons.travel_explore_outlined,
              color: AppColors.goldBright,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leak finder',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    top == null
                        ? 'Your repeated mistakes and fixes, in one place.'
                        : 'Top pattern: ${top.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      height: 1.35,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.slate,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shared chrome
// -----------------------------------------------------------------------------

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slateDark.withValues(alpha: 0.85)),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.75)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: color,
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

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.manrope(color: AppColors.slate, height: 1.4),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(color: AppColors.slate),
        ),
      ),
    );
  }
}
