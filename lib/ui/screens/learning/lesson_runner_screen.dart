/// Renders static multiple-choice exercises for a lesson vertical slice.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/curriculum/lesson_exercises.dart';
import 'package:live_poker_trainer/providers/learning_provider.dart';
import 'package:live_poker_trainer/services/learning/learning_service.dart';
import 'package:live_poker_trainer/ui/screens/learning/lesson_result_screen.dart';
import 'package:live_poker_trainer/ui/tokens/learning_tokens.dart';

/// Interactive multiple-choice lesson runner.
class LessonRunnerScreen extends ConsumerStatefulWidget {
  /// Creates the runner for [lessonId].
  ///
  /// When [exercises] is null, prefers `startLesson` callable, then the
  /// bundled asset (answer keys stripped for display).
  const LessonRunnerScreen({
    super.key,
    required this.lessonId,
    this.exercises,
  });

  /// Curriculum lesson id.
  final String lessonId;

  /// Optional injected payload (tests / previews).
  final LessonExercisesPayload? exercises;

  @override
  ConsumerState<LessonRunnerScreen> createState() => _LessonRunnerScreenState();
}

class _LessonRunnerScreenState extends ConsumerState<LessonRunnerScreen> {
  LessonExercisesPayload? _payload;
  Object? _loadError;
  int _index = 0;
  final Map<String, String> _answers = {};
  String? _selectedChoiceId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercises != null) {
      // Keep correctChoiceId for offline/test grading of injected payloads.
      _payload = widget.exercises;
    } else {
      _loadPayload();
    }
  }

  Future<void> _loadPayload() async {
    try {
      final service = ref.read(learningServiceProvider);
      try {
        final started = await service.startLesson(lessonId: widget.lessonId);
        if (!mounted) return;
        setState(() {
          _payload = LessonExercisesPayload.fromStartLesson(started);
        });
        return;
      } on LearningServiceException {
        // Fall through to bundled asset (flags off / offline / tests).
      }

      if (widget.lessonId == kFirstLessonId) {
        final raw = await rootBundle.loadString(kFirstLessonExercisesAssetPath);
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          if (!mounted) return;
          setState(() {
            _payload = LessonExercisesPayload.fromJson(decoded).publicView;
          });
          return;
        }
      }
      if (!mounted) return;
      setState(() {
        _loadError = 'No exercises available for ${widget.lessonId}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e);
    }
  }

  Future<void> _submitChoice() async {
    final payload = _payload;
    final choiceId = _selectedChoiceId;
    if (payload == null || choiceId == null || _submitting) return;
    final question = payload.questions[_index];
    _answers[question.id] = choiceId;

    if (_index < payload.questions.length - 1) {
      setState(() {
        _index += 1;
        _selectedChoiceId = null;
      });
      return;
    }

    setState(() => _submitting = true);
    var correct = 0;
    var total = payload.questions.length;
    var xpAwarded = 0;
    var streak = 0;
    var usedServer = false;

    final attemptId = payload.attemptId;
    if (attemptId != null && attemptId.isNotEmpty) {
      try {
        final service = ref.read(learningServiceProvider);
        final result = await service.completeLesson(
          lessonId: payload.lessonId,
          payload: {
            'attemptId': attemptId,
            'idempotencyKey': attemptId,
            // IANA timezone collected in onboarding later; UTC is valid today.
            'timezone': 'UTC',
            'answers': _answers,
          },
        );
        usedServer = true;
        final score = result['score'];
        if (score is Map) {
          correct = (score['correctCount'] as num?)?.toInt() ?? 0;
          total = (score['totalCount'] as num?)?.toInt() ?? total;
        }
        final progress = result['progress'];
        if (progress is Map) {
          xpAwarded = (progress['xp'] as num?)?.toInt() ?? 0;
          streak = (progress['streak'] as num?)?.toInt() ?? 0;
        }
      } on LearningServiceException {
        correct = await _localCorrectCount(payload);
      }
    } else {
      correct = await _localCorrectCount(payload);
    }

    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LessonResultScreen(
          lessonId: payload.lessonId,
          title: payload.title,
          correctCount: correct,
          totalCount: total,
          xpTotal: usedServer ? xpAwarded : null,
          streak: usedServer ? streak : null,
        ),
      ),
    );
  }

  Future<int> _localCorrectCount(LessonExercisesPayload payload) async {
    // Prefer keys already present (injected test payloads).
    if (payload.questions.any((q) => q.correctChoiceId != null)) {
      var correct = 0;
      for (final q in payload.questions) {
        final selected = _answers[q.id];
        if (selected != null && selected == q.correctChoiceId) {
          correct += 1;
        }
      }
      return correct;
    }
    try {
      final raw = await rootBundle.loadString(kFirstLessonExercisesAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return 0;
      final full = LessonExercisesPayload.fromJson(decoded);
      var correct = 0;
      for (final q in full.questions) {
        final selected = _answers[q.id];
        if (selected != null &&
            q.correctChoiceId != null &&
            selected == q.correctChoiceId) {
          correct += 1;
        }
      }
      return correct;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = _payload;
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(title: const Text('Lesson')),
        body: Center(
          child: Text(
            '$_loadError',
            style: GoogleFonts.manrope(color: AppColors.danger),
          ),
        ),
      );
    }
    if (payload == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    final question = payload.questions[_index];
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          payload.title,
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
                'Question ${_index + 1} of ${payload.questions.length}',
                style: GoogleFonts.manrope(color: AppColors.slate, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                question.prompt,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 17,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: LearningTokens.sectionGap),
              Expanded(
                child: ListView(
                  children: [
                    for (final choice in question.choices) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: _selectedChoiceId == choice.id
                              ? AppColors.feltLight
                              : AppColors.bgElevated,
                          borderRadius: BorderRadius.circular(
                            LearningTokens.panelRadius,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              LearningTokens.panelRadius,
                            ),
                            onTap: _submitting
                                ? null
                                : () => setState(
                                      () => _selectedChoiceId = choice.id,
                                    ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                choice.text,
                                style: GoogleFonts.manrope(
                                  color: AppColors.cream,
                                  fontSize: 15,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _selectedChoiceId == null || _submitting
                    ? null
                    : _submitChoice,
                child: Text(
                  _index >= payload.questions.length - 1
                      ? (_submitting ? 'Submitting…' : 'Finish')
                      : 'Next',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
