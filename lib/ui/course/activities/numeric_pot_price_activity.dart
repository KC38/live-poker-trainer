/// Pot / price / outs numeric entry activity.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Numeric pot/price/outs entry with unit label.
class NumericPotPriceActivity extends StatefulWidget {
  /// Creates the activity.
  const NumericPotPriceActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  @override
  State<NumericPotPriceActivity> createState() =>
      _NumericPotPriceActivityState();
}

class _NumericPotPriceActivityState extends State<NumericPotPriceActivity> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    final existing = widget.controller.draft.numericValue;
    _text = TextEditingController(
      text: existing == null ? '' : _format(existing),
    );
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toString();
  }

  String _coachFor(CourseActivity activity) {
    return switch (activity.id) {
      'act-02-05-01-guided-convert' =>
        '200 chips at 1/2 — type the stack in big blinds.',
      'act-02-05-01-checkpoint-200' =>
        '1000 chips at 2/5 — type the buy-in in big blinds.',
      'act-04-10-02-jump-spr' =>
        'Stack 60bb, pot 15bb — type the SPR.',
      _ => 'Type the amount in chips — match the bet to call.',
    };
  }

  LessonActionSpot? _spotFor(CourseActivity activity) {
    return switch (activity.id) {
      'act-02-05-01-guided-convert' => const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        potLabel: 'Blinds 1/2',
        stackLabel: '200 chips',
        villainLine: 'Big blinds = chips ÷ BB',
        streetLabel: 'Stack depth · convert',
        facingBet: false,
        feltStatusLine: '200 ÷ 2 = ? bb',
      ),
      'act-02-05-01-checkpoint-200' => const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        potLabel: 'Blinds 2/5',
        stackLabel: '1000 chips',
        villainLine: 'Big blinds = chips ÷ BB',
        streetLabel: 'Buy-in · convert',
        facingBet: false,
        feltStatusLine: '1000 ÷ 5 = ? bb',
      ),
      'act-04-10-02-jump-spr' => const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        potLabel: 'Pot 15bb',
        stackLabel: 'Stack 60bb',
        villainLine: 'Effective stack vs pot',
        streetLabel: 'Jump · SPR check',
        facingBet: false,
        feltStatusLine: 'SPR = 60 ÷ 15',
      ),
      _ => null,
    };
  }

  String _entryHintFor(CourseActivity activity) {
    return switch (activity.id) {
      'act-02-05-01-guided-convert' || 'act-02-05-01-checkpoint-200' =>
        'Type big blinds, then Check.',
      'act-04-10-02-jump-spr' =>
        'Type SPR, then Check.',
      _ => 'Type the amount, then Check.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final locked =
        widget.controller.submitting || widget.controller.lastResult != null;
    final unit = widget.activity.numericUnit ?? 'chips';
    final spot = _spotFor(widget.activity);
    final coach = _coachFor(widget.activity);
    final showCoach = widget.showGuidance && !locked;
    final question =
        widget.activity.numericQuestion ??
        widget.activity.prompt ??
        'Enter the amount';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showCoach) RexCoachLine(text: coach),
        if (spot != null) ...[
          const SizedBox(height: 12),
          LessonActionTable(spot: spot),
        ] else ...[
          const SizedBox(height: 12),
          Text(
            question,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 14),
        Semantics(
          textField: true,
          label: 'Answer in $unit',
          child: TextField(
            controller: _text,
            enabled: !locked,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            // ignore: deprecated_member_use
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.cream,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              suffixText: unit,
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (raw) {
              final parsed = double.tryParse(raw.trim());
              widget.controller.setNumericValue(parsed);
            },
            onSubmitted: (raw) {
              if (locked) return;
              final parsed = double.tryParse(raw.trim());
              if (parsed == null) return;
              widget.controller.setNumericValue(parsed, autoSubmit: true);
            },
          ),
        ),
        if (spot != null && !locked)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _entryHintFor(widget.activity),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
