/// Section-end ceremony — Rex, section title, one CONTINUE (LPT-793).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

/// Shown after [LessonResultScreen] when the finished lesson completes a
/// catalog section. One elevated CONTINUE returns to Home on the next
/// section (Duolingo Chess frame 128 / design-record Gamified learning).
class SectionCompleteScreen extends StatefulWidget {
  /// Creates the section-end ceremony.
  const SectionCompleteScreen({
    super.key,
    required this.sectionOrder,
    required this.sectionTitle,
    this.standalone = true,
  });

  /// Catalog section order (1-based), shown as "SECTION N".
  final int sectionOrder;

  /// Catalog section title.
  final String sectionTitle;

  /// When false, CONTINUE pops the embedded runner (Home / openlesson).
  /// When true, CONTINUE pops to the first route (onboarding push).
  final bool standalone;

  @override
  State<SectionCompleteScreen> createState() => _SectionCompleteScreenState();
}

class _SectionCompleteScreenState extends State<SectionCompleteScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _bounce;
  bool _continuing = false;

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

  void _onContinue() {
    if (_continuing) return;
    _continuing = true;
    final nav = Navigator.of(context);
    if (!nav.canPop()) return;
    if (!widget.standalone) {
      nav.pop();
      return;
    }
    nav.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
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
                  'Section Complete!',
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
                  'SECTION ${widget.sectionOrder}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.sectionTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(flex: 3),
                ElevatedButton(
                  onPressed: _continuing ? null : _onContinue,
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
