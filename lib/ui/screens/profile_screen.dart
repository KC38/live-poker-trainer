/// Progress ("You"): identity, style metrics, coaching record, charts.
///
/// One Home destination for profile + coaching stats. Every rate carries the
/// sample it came from. Style is withheld below [StyleThresholds.minHands].
library;

import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/engine/hero_profiler.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';
import 'package:live_poker_trainer/models/course/course_progress.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_progress_provider.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/screens/settings_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/profile_avatar.dart';
import 'package:live_poker_trainer/ui/widgets/profile_identity_sheet.dart';

/// Consolidated Progress / You screen (profile + coaching stats).
class ProfileScreen extends ConsumerStatefulWidget {
  /// Creates the progress screen.
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final DateTime _enteredAt;
  AnalyticsService? _analytics;

  @override
  void initState() {
    super.initState();
    _enteredAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _analytics = ref.read(analyticsServiceProvider);
      unawaited(_analytics!.logProgressViewOpen());
    });
  }

  @override
  void dispose() {
    final durationMs = DateTime.now().difference(_enteredAt).inMilliseconds;
    final analytics = _analytics;
    if (analytics != null) {
      unawaited(analytics.logProgressDwell(durationMs: durationMs));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(heroProfileControllerProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        // Tab root: no back when Profile is not pushed above another route.
        automaticallyImplyLeading: canPop,
        leading:
            canPop
                ? IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AppColors.slate,
                  ),
                )
                : null,
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed:
                () => Navigator.push(
                  context,
                  softFadeRoute(
                    const SettingsScreen(),
                    name: AnalyticsScreens.settings,
                  ),
                ),
            icon: const Icon(Icons.settings_outlined, color: AppColors.slate),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
            radius: 1.2,
            colors: [AppColors.bgMid, AppColors.bgDark],
          ),
        ),
        child: profileAsync.when(
          loading:
              () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
          error: (e, _) => _ErrorState(message: '$e'),
          data:
              (profile) => _ProfileBody(
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
      onRefresh: () async {
        await controller.refreshMetrics();
        ref.invalidate(userStatsProvider);
        ref.invalidate(courseProgressProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          _ProfileHeader(profile: profile),
          const SizedBox(height: 26),
          const _SectionTitle('Course'),
          const SizedBox(height: 4),
          Text(
            'Lesson progress. Separate from Live Training coaching.',
            style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 12.5),
          ),
          const SizedBox(height: 10),
          const _CourseProgressSection(),
          const SizedBox(height: 26),
          const _SectionTitle('Live Training'),
          const SizedBox(height: 4),
          Text(
            'Coaching record, results, and style from full-hand play.',
            style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 12.5),
          ),
          if (!metrics.style.isKnown) ...[
            const SizedBox(height: 14),
            _NeedsMoreHands(style: metrics.style),
          ],
          if (coachingStats != null && coachingStats!.totalSpots > 0) ...[
            const SizedBox(height: 16),
            const _SectionTitle('Coaching record'),
            const SizedBox(height: 10),
            _CoachingRecord(stats: coachingStats!),
          ],
          const SizedBox(height: 26),
          _TrendCard(metrics: metrics, coachingStats: coachingStats),
          if (coachingStats != null) ...[
            const SizedBox(height: 26),
            _CoachingBreakdown(stats: coachingStats!),
          ],
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
              if (tendency.hasEnoughData) _ArchetypeRow(tendency: tendency),
          ],
          const SizedBox(height: 26),
          const _SectionTitle('Settings'),
          const SizedBox(height: 10),
          const _SettingsAndSignOut(),
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
                      label:
                          style.isKnown ? style.style.label : 'Style forming',
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
    final points =
        useVpip
            ? [
              for (var i = 0; i < vpipTrend.length; i++)
                FlSpot(i.toDouble(), vpipTrend[i].vpipPct),
            ]
            : [
              for (var i = 0; i < evTrend.length; i++)
                FlSpot(i.toDouble(), evTrend[i]),
            ];

    final title = useVpip ? 'Hands played over time' : 'Recent results';
    final caption =
        useVpip
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
          child:
              points.length < 2
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
                color:
                    sample.reliableValue == null
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
            value:
                sample.hasEnoughData
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
              style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 13),
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
                  color:
                      tendency.netBb >= 0
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
        child:
            total <= 0
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
              label: 'Strong decisions',
              detail: '${stats.correctSpots} of ${stats.totalSpots} reviewed',
            ),
          ),
          Container(width: 1, height: 46, color: AppColors.slateDark),
          Expanded(
            child: _Figure(
              value:
                  '${stats.netEvBb >= 0 ? '+' : ''}'
                  '${stats.netEvBb.toStringAsFixed(1)}',
              label: 'Net result (BB)',
              detail: 'across completed hands',
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

/// Accuracy by archetype / street, previously on the standalone Stats screen.
class _CoachingBreakdown extends StatelessWidget {
  const _CoachingBreakdown({required this.stats});

  final UserStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('By archetype'),
        const SizedBox(height: 8),
        if (stats.archetypeAccuracy.isEmpty)
          Text(
            'No archetype data yet.',
            style: GoogleFonts.manrope(color: AppColors.slate, height: 1.4),
          )
        else
          for (final entry in stats.archetypeAccuracy.entries)
            _BreakdownRow(
              label: entry.key,
              detail: '${entry.value.correct}/${entry.value.played} correct',
              trailing: '${entry.value.accuracyPct.toStringAsFixed(0)}%',
            ),
        const SizedBox(height: 20),
        const _SectionTitle('By street'),
        const SizedBox(height: 8),
        if (stats.streetAccuracy.isEmpty)
          Text(
            'No street data yet.',
            style: GoogleFonts.manrope(color: AppColors.slate, height: 1.4),
          )
        else
          for (final entry in stats.streetAccuracy.entries)
            _BreakdownRow(
              label: entry.key,
              trailing: '${entry.value.accuracyPct.toStringAsFixed(0)}%',
            ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
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

class _CourseProgressSection extends ConsumerWidget {
  const _CourseProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(courseProgressProvider);
    return progress.when(
      loading:
          () => const _Panel(child: _EmptyHint('Loading course progress…')),
      error:
          (_, _) => const _Panel(
            child: _EmptyHint(
              'Course progress is unavailable. Live Training is unchanged.',
            ),
          ),
      data: (course) => _CourseProgressCard(progress: course),
    );
  }
}

class _CourseProgressCard extends StatelessWidget {
  const _CourseProgressCard({required this.progress});

  final CourseProgress progress;

  @override
  Widget build(BuildContext context) {
    if (!progress.loaded) {
      return const _Panel(
        child: _EmptyHint(
          'Course progress is unavailable. Live Training is unchanged.',
        ),
      );
    }
    final accuracy = (progress.acceptedAccuracy * 100).clamp(0, 100);
    final mastery = (progress.mastery * 100).clamp(0, 100);
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CourseMetricRow(
            leftValue: '${progress.lifetimeXp}',
            leftLabel: 'Course XP',
            rightValue: '${progress.currentStreak}',
            rightLabel: 'Day streak',
          ),
          const SizedBox(height: 14),
          _CourseMetricRow(
            leftValue: '${accuracy.toStringAsFixed(0)}%',
            leftLabel: 'Accepted accuracy',
            rightValue: '${mastery.toStringAsFixed(0)}%',
            rightLabel: 'Mastery',
          ),
          const SizedBox(height: 14),
          Text(
            progress.currentSectionTitle ?? 'Section not started',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            progress.reviewsDue == 0
                ? 'No reviews due'
                : '${progress.reviewsDue} reviews due',
            style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 12.5),
          ),
          if (!progress.available) ...[
            const SizedBox(height: 12),
            Text(
              'Course entry is off. Saved progress stays here; Live Training is unchanged.',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12.5,
              ),
            ),
          ],
          if (progress.legacyLifetimeXp != null) ...[
            const SizedBox(height: 12),
            Text(
              'Legacy academy XP ${progress.legacyLifetimeXp}',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12.5,
              ),
            ),
            Text(
              'Old catalog XP only. It does not unlock lessons.',
              style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _CourseMetricRow extends StatelessWidget {
  const _CourseMetricRow({
    required this.leftValue,
    required this.leftLabel,
    required this.rightValue,
    required this.rightLabel,
  });

  final String leftValue;
  final String leftLabel;
  final String rightValue;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Figure(value: leftValue, label: leftLabel, detail: 'Course'),
        ),
        Container(width: 1, height: 46, color: AppColors.slateDark),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _Figure(
              value: rightValue,
              label: rightLabel,
              detail: 'Course',
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsAndSignOut extends ConsumerWidget {
  const _SettingsAndSignOut();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  softFadeRoute(
                    const SettingsScreen(),
                    name: AnalyticsScreens.settings,
                  ),
                ),
            child: const Text('Settings'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
