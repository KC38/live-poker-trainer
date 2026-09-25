/// Lesson completion summary — celebratory, teach-forward close.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  String get _rexCheer {
    final masteryPct = (widget.result.mastery * 100).round();
    if (masteryPct >= 90) {
      return 'Clean work. That skill sticks.';
    }
    if (widget.result.streak >= 2) {
      return 'Streak alive — keep the reps going.';
    }
    return 'Locked in. Ready for the next seat.';
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
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF12201A),
              AppColors.bgDark,
              AppColors.bgDark,
            ],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: AnimatedBuilder(
              animation: _enter,
              builder: (context, child) {
                final t = Curves.easeOutCubic.transform(_enter.value);
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, (1 - t) * 18),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'LESSON COMPLETE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.feltLight.withValues(alpha: 0.9),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.85),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.28),
                            blurRadius: 22,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        'R',
                        style: GoogleFonts.manrope(
                          color: AppColors.goldBright,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.lessonTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: AppColors.cream,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.slateDark.withValues(alpha: 0.9),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rex',
                          style: GoogleFonts.manrope(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _rexCheer,
                            style: GoogleFonts.manrope(
                              color: AppColors.cream,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _StatCard(
                    icon: Icons.bolt_rounded,
                    iconColor: AppColors.goldBright,
                    label: 'XP earned',
                    value: '+${result.xpAwarded}',
                  ),
                  _StatCard(
                    icon: Icons.workspace_premium_outlined,
                    iconColor: AppColors.success,
                    label: 'Mastery',
                    value:
                        '${(result.mastery * 100).clamp(0, 100).round()}%',
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFE07A3A),
                    label: 'Study streak',
                    value: '${result.streak}',
                  ),
                  _StatCard(
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.gold,
                    label: 'Accepted accuracy',
                    value:
                        '${(result.acceptedAccuracy * 100).clamp(0, 100).round()}%',
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bgDark,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'CONTINUE',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.slateDark.withValues(alpha: 0.85)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.manrope(
                color: AppColors.cream,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
