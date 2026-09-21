/// Multi-step learning onboarding (experience, stakes, goals, daily goal).
///
/// Answers are stored locally via SharedPreferences for the guest-first slice;
/// cloud sync lands with learner profile later.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/tokens/learning_tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pref key prefix for onboarding answers.
const String kOnboardingPrefPrefix = 'learning_onboarding_';

/// Completed-flag pref key.
const String kOnboardingCompletePrefKey = '${kOnboardingPrefPrefix}complete';

/// Answers collected during onboarding.
class OnboardingAnswers {
  /// Creates answers.
  const OnboardingAnswers({
    required this.experience,
    required this.stakes,
    required this.goals,
    required this.dailyGoalMinutes,
  });

  /// Self-reported experience band.
  final String experience;

  /// Typical stakes label.
  final String stakes;

  /// Primary learning goals (multi-select joined).
  final String goals;

  /// Daily practice target in minutes.
  final int dailyGoalMinutes;

  /// Wire / prefs map.
  Map<String, String> toPrefMap() => {
        '${kOnboardingPrefPrefix}experience': experience,
        '${kOnboardingPrefPrefix}stakes': stakes,
        '${kOnboardingPrefPrefix}goals': goals,
        '${kOnboardingPrefPrefix}daily_goal': '$dailyGoalMinutes',
      };
}

/// Simple multi-step onboarding form for the learning platform.
class OnboardingScreen extends StatefulWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key, this.onCompleted});

  /// Optional callback after local persistence succeeds.
  final ValueChanged<OnboardingAnswers>? onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String? _experience;
  String? _stakes;
  final Set<String> _goals = {};
  int _dailyGoal = 15;
  bool _saving = false;

  static const _experienceOptions = [
    'Brand new',
    'Some cash experience',
    'Regular player',
    'Serious grinder',
  ];

  static const _stakesOptions = [
    'Home game / micro',
    '1/2 – 1/3',
    '2/5+',
    'Not sure yet',
  ];

  static const _goalOptions = [
    'Stop leaking money',
    'Build a solid preflop plan',
    'Read live opponents',
    'Prepare for a trip',
  ];

  bool get _canContinue => switch (_step) {
        0 => _experience != null,
        1 => _stakes != null,
        2 => _goals.isNotEmpty,
        3 => true,
        _ => false,
      };

  Future<void> _finish() async {
    final answers = OnboardingAnswers(
      experience: _experience!,
      stakes: _stakes!,
      goals: _goals.join(', '),
      dailyGoalMinutes: _dailyGoal,
    );
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in answers.toPrefMap().entries) {
        await prefs.setString(entry.key, entry.value);
      }
      await prefs.setBool(kOnboardingCompletePrefKey, true);
      widget.onCompleted?.call(answers);
      if (!mounted) return;
      Navigator.of(context).maybePop(answers);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step += 1);
      return;
    }
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          'Quick setup',
          style: GoogleFonts.cinzel(color: AppColors.goldBright),
        ),
        backgroundColor: AppColors.bgMid,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LearningTokens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Step ${_step + 1} of 4',
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildStep()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: !_canContinue || _saving ? null : _next,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.bgDark,
                        ),
                      )
                    : Text(_step == 3 ? 'Save & continue' : 'Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _ChoiceStep(
          title: 'Your experience',
          subtitle: 'We’ll pitch lessons at the right altitude.',
          options: _experienceOptions,
          selected: _experience,
          onSelect: (v) => setState(() => _experience = v),
        ),
      1 => _ChoiceStep(
          title: 'Typical stakes',
          subtitle: 'Helps us pick examples that feel familiar.',
          options: _stakesOptions,
          selected: _stakes,
          onSelect: (v) => setState(() => _stakes = v),
        ),
      2 => _MultiChoiceStep(
          title: 'Your goals',
          subtitle: 'Pick one or more.',
          options: _goalOptions,
          selected: _goals,
          onToggle: (v) => setState(() {
            if (!_goals.add(v)) _goals.remove(v);
          }),
        ),
      _ => _DailyGoalStep(
          minutes: _dailyGoal,
          onChanged: (v) => setState(() => _dailyGoal = v),
        ),
    };
  }
}

class _ChoiceStep extends StatelessWidget {
  const _ChoiceStep({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          title,
          style: GoogleFonts.cinzel(
            color: AppColors.goldBright,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.manrope(color: AppColors.slate, height: 1.4),
        ),
        const SizedBox(height: LearningTokens.sectionGap),
        for (final option in options) ...[
          _OptionTile(
            label: option,
            selected: selected == option,
            onTap: () => onSelect(option),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _MultiChoiceStep extends StatelessWidget {
  const _MultiChoiceStep({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          title,
          style: GoogleFonts.cinzel(
            color: AppColors.goldBright,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.manrope(color: AppColors.slate, height: 1.4),
        ),
        const SizedBox(height: LearningTokens.sectionGap),
        for (final option in options) ...[
          _OptionTile(
            label: option,
            selected: selected.contains(option),
            onTap: () => onToggle(option),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _DailyGoalStep extends StatelessWidget {
  const _DailyGoalStep({required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily goal',
          style: GoogleFonts.cinzel(
            color: AppColors.goldBright,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How many minutes a day feels realistic?',
          style: GoogleFonts.manrope(color: AppColors.slate, height: 1.4),
        ),
        const SizedBox(height: LearningTokens.sectionGap),
        DecoratedBox(
          decoration: LearningTokens.panelDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '$minutes min',
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Slider(
                  value: minutes.toDouble(),
                  min: 5,
                  max: 45,
                  divisions: 8,
                  activeColor: AppColors.gold,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LearningTokens.panelRadius),
        child: Ink(
          decoration: LearningTokens.panelDecoration(
            color: selected
                ? AppColors.feltLight.withValues(alpha: 0.45)
                : AppColors.bgElevated,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: LearningTokens.minTapTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: selected ? AppColors.goldBright : AppColors.slate,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.manrope(
                        color: AppColors.cream,
                        fontSize: 15,
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
