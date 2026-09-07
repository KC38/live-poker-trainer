/// Offline coach copy for repeated mistakes and acknowledged improvements.
///
/// Used as the Gemini fallback and as the prefix on the local line, so the
/// player always hears the repeat count / pattern by name even with no key.
library;

import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Repeat / improvement phrasing that rotates so back-to-back lines differ.
class LeakLines {
  LeakLines._();

  static int _rotation = 0;

  /// Resets rotation. Used by tests for determinism.
  static void resetRotation() => _rotation = 0;

  /// One clause naming the repeat, e.g.
  /// "That's the third time you've raised against a nit on the river when
  /// call was better". Returns an empty string when [repeat] is not a repeat.
  static String repeatPrefix(RepeatInfo repeat, {required String villainName}) {
    if (!repeat.isRepeat) return '';
    final p = repeat.pattern;
    final n = repeat.displayCount;
    final ordinal = _ordinal(n);
    final arch = _archNoun(p.archetype.label);
    final street = p.street.name;
    final did = _pastTense(p.taken);
    final better = p.best.name;

    if (repeat.isExactRepeat) {
      final session = repeat.sessionCount > 1 && repeat.sessionCount < n
          ? ' (${repeat.sessionCount} this session)'
          : repeat.sessionCount == n && n > 1
              ? ' this session'
              : '';
      final options = <String>[
        "That's the $ordinal time you've $did against a $arch on the "
            '$street when $better was better$session',
        'Same leak again — $did versus a $arch on the $street, '
            '$n times now$session',
        'Repeat #$n: $arch, $street, you $did where $better was the play'
            '$session',
        'This is becoming a pattern: $n times you have $did here against a '
            '$arch instead of the $better$session',
      ];
      return _pick(options, seed: p.key.hashCode);
    }

    final tag = p.primaryTag.label.toLowerCase();
    final options = <String>[
      'Same leak in a new spot — $tag, $n times now',
      "That's $n times for $tag, this time against $villainName on the $street",
      'Different street, same pattern: $tag ($n total)',
    ];
    return _pick(options, seed: p.key.hashCode);
  }

  /// Acknowledgement for a fixed leak, e.g. "Nice — last time you raised
  /// here; calling was the right adjustment."
  static String improvementPrefix(
    ImprovementInfo info, {
    required ExploitAction taken,
  }) {
    final used = _pastTense(info.lastWrongAction);
    final now = _gerund(taken);
    final streak = info.streak;
    final options = <String>[
      'Nice — last time you $used here; $now was the right adjustment',
      'That is the fix: you had $used this spot ${info.priorMistakes} times, '
          'and $now is exactly right',
      'Leak plugged — ${info.tag.label.toLowerCase()} used to cost you, '
          'and you just got it right',
      if (streak >= 2)
        '$streak in a row on a spot you used to miss — $now instead of '
            '${_gerund(info.lastWrongAction)} is sticking',
    ];
    return _pick(options, seed: info.matchedKey.hashCode + streak);
  }

  /// Compact shelf label, e.g. "Repeat ×3".
  static String repeatBadge(int count) => 'Repeat ×$count';

  /// Compact shelf label for an acknowledged fix.
  static String improvementBadge(int streak) =>
      streak >= 2 ? 'Improved ×$streak' : 'Improved';

  static String _pick(List<String> options, {required int seed}) {
    if (options.isEmpty) return '';
    _rotation++;
    return options[(seed.abs() + _rotation) % options.length];
  }

  static String _ordinal(int n) {
    const words = {
      1: 'first',
      2: 'second',
      3: 'third',
      4: 'fourth',
      5: 'fifth',
      6: 'sixth',
      7: 'seventh',
      8: 'eighth',
      9: 'ninth',
      10: 'tenth',
    };
    if (words.containsKey(n)) return words[n]!;
    final mod100 = n % 100;
    if (mod100 >= 11 && mod100 <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }

  static String _archNoun(String label) => switch (label) {
        'Calling Station' => 'station',
        'TAG' => 'TAG',
        'LAG' => 'LAG',
        _ => label.toLowerCase(),
      };

  static String _pastTense(ExploitAction a) => switch (a) {
        ExploitAction.fold => 'folded',
        ExploitAction.check => 'checked',
        ExploitAction.call => 'called',
        ExploitAction.raise => 'raised',
      };

  static String _gerund(ExploitAction a) => switch (a) {
        ExploitAction.fold => 'folding',
        ExploitAction.check => 'checking',
        ExploitAction.call => 'calling',
        ExploitAction.raise => 'raising',
      };
}
