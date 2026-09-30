/// Lesson completion summary — celebratory, clutter-free close.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

/// Shown after [completeCourseLesson] succeeds.
class LessonResultScreen extends StatefulWidget {
  /// Creates the result screen.
  const LessonResultScreen({
    super.key,
    required this.lessonTitle,
    required this.result,
    this.standalone = true,
  });

  final String lessonTitle;
  final CompleteCourseLessonResult result;

  final bool standalone;

  @override
  State<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _bounce.dispose();
    super.dispose();
  }

  String get _accuracyLabel {
    final pct = (widget.result.acceptedAccuracy * 100).round();
    if (pct >= 90) return 'AMAZING';
    if (pct >= 70) return 'GREAT';
    return 'NICE';
  }

  void _onContinue() {
    final nav = Navigator.of(context);
    if (!widget.standalone) {
      nav.pop();
      return;
    }
    // Guest onboarding used to [pushReplacement] the runner over `/`, leaving
    // this screen as the sole route so [popUntil](isFirst) was a no-op. Entry
    // now uses [Navigator.push], and [PokerLabApp] remounts on saveProgress.
    if (!nav.canPop()) return;
    nav.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final accuracyPct =
        (result.acceptedAccuracy * 100).clamp(0, 100).round();
    final bounce = CurvedAnimation(
      parent: _bounce,
      curve: Curves.elasticOut,
    );

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: AnimatedBuilder(
            animation: _enter,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(_enter.value);
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 16),
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                ScaleTransition(
                  scale: Tween<double>(begin: 0.72, end: 1).animate(bounce),
                  child: const Center(
                    child: RexMascot(size: 168, mood: RexMood.celebrate),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Lesson Complete!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.goldBright,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.lessonTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _ResultStatCard(
                        header: 'TOTAL XP',
                        headerColor: AppColors.gold,
                        borderColor: AppColors.gold.withValues(alpha: 0.55),
                        icon: Icons.bolt_rounded,
                        iconColor: AppColors.goldBright,
                        value: '${result.xpAwarded}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResultStatCard(
                        header: _accuracyLabel,
                        headerColor: AppColors.success,
                        borderColor:
                            AppColors.success.withValues(alpha: 0.55),
                        icon: Icons.gps_fixed_rounded,
                        iconColor: AppColors.success,
                        value: '$accuracyPct%',
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                ElevatedButton(
                  onPressed: _onContinue,
                  child: const Text('CONTINUE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Duo-style result tile: colored header strip over a dark body.
class _ResultStatCard extends StatelessWidget {
  const _ResultStatCard({
    required this.header,
    required this.headerColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  final String header;
  final Color headerColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: headerColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                header,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.bgDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 26),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
