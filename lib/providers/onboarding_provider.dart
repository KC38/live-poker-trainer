/// Local onboarding draft + root-route helpers for lesson-first guests.
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'onboarding_draft_v1';

/// Loads and persists the guest onboarding draft.
class OnboardingController extends StateNotifier<OnboardingDraft> {
  /// Creates the controller.
  OnboardingController(this._prefs) : super(const OnboardingDraft()) {
    _hydrate();
  }

  final SharedPreferences? _prefs;

  void _hydrate() {
    final raw = _prefs?.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        state = OnboardingDraft.fromPrefs(map);
      } else if (map is Map) {
        state = OnboardingDraft.fromPrefs(Map<String, Object?>.from(map));
      }
    } catch (_) {
      // Ignore corrupt drafts.
    }
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_prefsKey, jsonEncode(state.toPrefs()));
  }

  Future<void> setStep(OnboardingStep step) async {
    state = state.copyWith(step: step);
    await _persist();
  }

  Future<void> setExperience(ExperienceBand band) async {
    state = state.copyWith(
      experienceBand: band,
      step: OnboardingStep.dailyGoal,
    );
    await _persist();
  }

  Future<void> setDailyGoal(int minutes) async {
    state = state.copyWith(
      dailyGoalMinutes: minutes,
      step: OnboardingStep.rexIntro,
    );
    await _persist();
  }

  Future<void> setRecommendation({
    required String lessonId,
    required bool jumpTestOffered,
  }) async {
    state = state.copyWith(
      recommendedLessonId: lessonId,
      jumpTestOffered: jumpTestOffered,
      step: OnboardingStep.recommendedStart,
    );
    await _persist();
  }

  Future<void> markEnteringFirstLesson() async {
    state = state.copyWith(step: OnboardingStep.firstLesson);
    await _persist();
  }

  Future<void> markFirstLessonComplete({
    required String lessonTitle,
    required CompleteCourseLessonResult result,
  }) async {
    state = state.copyWith(
      step: OnboardingStep.saveProgress,
      firstLessonCompleted: true,
      pendingSaveProgress: true,
      lastLessonTitle: lessonTitle,
      lastXpAwarded: result.xpAwarded,
      lastMastery: result.mastery,
      lastStreak: result.streak,
    );
    await _persist();
  }

  Future<void> clearAfterLinked() async {
    state = const OnboardingDraft(step: OnboardingStep.done);
    await _prefs?.remove(_prefsKey);
  }

  Future<void> resetToWelcome() async {
    state = const OnboardingDraft();
    await _prefs?.remove(_prefsKey);
  }
}

/// Onboarding draft provider.
final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingDraft>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
  return OnboardingController(prefs);
});
