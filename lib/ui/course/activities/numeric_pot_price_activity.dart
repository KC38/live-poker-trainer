/// Pot / price / outs numeric entry activity.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final locked =
        widget.controller.submitting || widget.controller.lastResult != null;
    final unit = widget.activity.numericUnit ?? 'chips';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showGuidance)
          const RexCoachLine(
            text: 'Type the amount in chips — match the bet to call.',
          ),
        const SizedBox(height: 12),
        Text(
          widget.activity.numericQuestion ??
              widget.activity.prompt ??
              'Enter the amount',
          style: GoogleFonts.manrope(
            color: AppColors.cream,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
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
      ],
    );
  }
}
