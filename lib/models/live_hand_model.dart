/// Client-safe models for server-authoritative live training hands.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/tendency_profile_model.dart';

/// One fixed legal action supplied by the authoritative server.
@immutable
class LiveLegalActionModel {
  /// Creates a fixed live action.
  const LiveLegalActionModel({
    required this.actionId,
    required this.kind,
    required this.bucket,
    required this.label,
    this.amountTo,
  });

  final String actionId;
  final String kind;
  final String bucket;
  final String label;
  final double? amountTo;

  factory LiveLegalActionModel.fromJson(Map<String, dynamic> json) {
    return LiveLegalActionModel(
      actionId: json['actionId'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      bucket: json['bucket'] as String? ?? '',
      label: json['label'] as String? ?? '',
      amountTo: (json['amountTo'] as num?)?.toDouble(),
    );
  }
}

/// One authoritative action replayed on the table.
@immutable
class LiveActionEventModel {
  /// Creates a replay event.
  const LiveActionEventModel({
    required this.sequence,
    required this.seat,
    required this.street,
    required this.actionId,
    required this.kind,
    required this.bucket,
    this.amountTo,
  });

  final int sequence;
  final int seat;
  final String street;
  final String actionId;
  final String kind;
  final String bucket;
  final double? amountTo;

  factory LiveActionEventModel.fromJson(Map<String, dynamic> json) {
    return LiveActionEventModel(
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      seat: (json['seat'] as num?)?.toInt() ?? 0,
      street: json['street'] as String? ?? 'preflop',
      actionId: json['actionId'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      bucket: json['bucket'] as String? ?? '',
      amountTo: (json['amountTo'] as num?)?.toDouble(),
    );
  }
}

/// Qualitative exploit feedback for the selected Hero action.
@immutable
class LiveCoachingAssessment {
  /// Creates one coaching assessment.
  const LiveCoachingAssessment({
    required this.actionId,
    required this.rating,
    required this.confidence,
    required this.summary,
    required this.playerTypeReason,
    required this.sizingNote,
    required this.tendencyKeys,
    this.betterActionId,
    this.reversalRead,
  });

  final String actionId;
  final String rating;
  final String confidence;
  final String summary;
  final String playerTypeReason;
  final String sizingNote;
  final String? betterActionId;
  final String? reversalRead;
  final List<String> tendencyKeys;

  factory LiveCoachingAssessment.fromJson(Map<String, dynamic> json) {
    return LiveCoachingAssessment(
      actionId: json['actionId'] as String? ?? '',
      rating: json['rating'] as String? ?? 'reasonable',
      confidence: json['confidence'] as String? ?? 'low',
      summary: json['summary'] as String? ?? '',
      playerTypeReason: json['playerTypeReason'] as String? ?? '',
      sizingNote: json['sizingNote'] as String? ?? '',
      betterActionId: json['betterActionId'] as String?,
      reversalRead: json['reversalRead'] as String?,
      tendencyKeys: (json['tendencyKeys'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(growable: false),
    );
  }

  /// User-facing review assembled from the structured rubric.
  String get message => polishCoachCopy(
    [
      summary,
      playerTypeReason,
      sizingNote,
      if (reversalRead != null && reversalRead!.isNotEmpty)
        'This changes when: $reversalRead',
    ].where((line) => line.trim().isNotEmpty).join('\n\n'),
  );
}

/// Readable labels for tendency keys the model sometimes prints raw.
const _tendencyLabels = <String, String>{
  'foldToFlopBet': 'flop fold',
  'foldToTurnBet': 'turn fold',
  'foldToRiverBet': 'river fold',
  'bluffRiver': 'river bluff',
  'showdownCall': 'showdown call',
  'sizingTellStrength': 'sizing tell',
  'threeBet': '3-bet',
  'aggression': 'aggression',
  'vpip': 'VPIP',
  'pfr': 'PFR',
};

/// Turns stored coach prose into something a player can read.
///
/// Rubrics are generated once and reused, so this has to repair copy that is
/// already saved: chip amounts gain a `$`, and `51.7 bluffRiver` becomes
/// `51.7% river bluff`. Percentages that are already marked stay as they are.
String polishCoachCopy(String raw) {
  var text = raw;
  for (final entry in _tendencyLabels.entries) {
    final key = RegExp.escape(entry.key);
    // Skip chip sizes: "$30 threeBet" must not become "$30% 3-bet"
    // (and must not match the trailing "0" of "$30").
    text = text.replaceAllMapped(
      RegExp(
        '(?<![\\d\$])(\\d+(?:\\.\\d+)?)\\s+$key\\b',
        caseSensitive: false,
      ),
      (match) => '${match[1]}% ${entry.value}',
    );
    text = text.replaceAll(
      RegExp('\\b$key\\b', caseSensitive: false),
      entry.value,
    );
  }
  // Model prose often says "three-bet" instead of the canonical "3-bet" label.
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$])(\d+(?:\.\d+)?)(?!\s*%)\s+three[\s-]?bets?\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]}% 3-bet',
  );
  text = text.replaceAll(
    RegExp(r'\bthree[\s-]bets?\b', caseSensitive: false),
    '3-bet',
  );
  // Bare "3bet"/"3bets" (batch 0228) → canonical "3-bet".
  text = text.replaceAll(
    RegExp(r'\b3bets?\b', caseSensitive: false),
    '3-bet',
  );
  // "wide 3-betting (20.7) tendencies" (batch 0207) → "3-bet (20.7%)".
  text = text.replaceAllMapped(
    RegExp(
      r'\b3[\s-]?bettings?\s*\((\d+(?:\.\d+)?)\)(?!\s*%)',
      caseSensitive: false,
    ),
    (match) => '3-bet (${match[1]}%)',
  );
  // Bare rate paren before "tendency/tendencies".
  text = text.replaceAllMapped(
    RegExp(
      r'\((\d+(?:\.\d+)?)\)(?!\s*%)\s+(tendenc(?:y|ies)\b)',
      caseSensitive: false,
    ),
    (match) => '(${match[1]}%) ${match[2]}',
  );
  // "42.3 river bluffing" → "42.3% river bluff".
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$])(\d+(?:\.\d+)?)(?!\s*%)\s+river\s+bluffing\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]}% river bluff',
  );
  text = text.replaceAll(
    RegExp(r'\briver\s+bluffing\b', caseSensitive: false),
    'river bluff',
  );
  // Number before display label: "51.5 river bluff frequency" / "81.5 aggression".
  // (The key pass only catches camelCase like "51.5 bluffRiver".)
  // Skip "$30 3-bet" chip sizes (live: became "$30% 3-bet").
  for (final label in _tendencyLabels.values.toSet()) {
    final escaped = RegExp.escape(label);
    text = text.replaceAllMapped(
      RegExp(
        '(?<![\\d\$])(\\d+(?:\\.\\d+)?)(?!\\s*%)\\s+$escaped\\b',
        caseSensitive: false,
      ),
      (match) => '${match[1]}% $label',
    );
  }
  // "60.1% bluffRiver bluff far too often" → "river bluff bluff" after the
  // key rewrite; keep the verb by inserting "and".
  text = text.replaceAllMapped(
    RegExp(
      r'\b(river bluff)\s+(bluff(?:s|ing)?)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} and ${match[2]}',
  );
  text = text.replaceAllMapped(
    RegExp(
      r'\b(showdown call)\s+(calls?|calling)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} and ${match[2]}',
  );
  text = text.replaceAllMapped(
    RegExp(
      r'\b((?:flop|turn|river) fold)\s+(folds?|folding)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} and ${match[2]}',
  );
  // Adjective form the model sometimes uses: "aggressive (77.4)" →
  // "aggression (77.4%)" so the rate gets a percent like other tendencies.
  text = text.replaceAllMapped(
    RegExp(
      r'\baggressive\s*\((\d+(?:\.\d+)?)\)(?!\s*%)',
      caseSensitive: false,
    ),
    (match) => 'aggression (${match[1]}%)',
  );
  for (final label in _tendencyLabels.values) {
    final escaped = RegExp.escape(label);
    // Optional noun after the label: frequency / rate / stat / rating / range.
    // "range" covers live "wide 3-bet range (12.9)" (batch 0299 H3).
    const noun =
        r'(?:\s+(?:frequency|rate|stat|rating|range|score|tendenc(?:y|ies)))?';
    // Complete number tokens only. "of 76.3%" must not become "of 76%.3%",
    // but "of 57.8." at the end of a sentence still needs the percent.
    // Also "aggression rating of 85.6" (live coach prose).
    // Also "river bluff tendency (58.3)" (batch 0237).
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)($noun)\\s+of\\s+(\\d+(?:\\.\\d+)?)(?!\\d)(?!\\.\\d)(?!\\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]}${match[2]} of ${match[3]}%',
    );
    // Bare "showdown call 50.7" / "aggression rating 85.6" (no "of").
    // Skip OCR-split "frequency 63.1)" — that is repaired by the paren pass.
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)($noun)\\s+(\\d+(?:\\.\\d+)?)(?!\\d)(?!\\.\\d)(?!\\s*%)(?![xX)])',
        caseSensitive: false,
      ),
      (match) => '${match[1]}${match[2]} ${match[3]}%',
    );
    // Colon rates: "showdown call: 67.9".
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)\\s*:\\s*(\\d+(?:\\.\\d+)?)(?!\\d)(?!\\.\\d)(?!\\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]}: ${match[2]}%',
    );
    // Parenthetical rates: "aggression (86.4)" / "VPIP (70.2)", and the
    // common "river bluff frequency (63.1)" / "3-bet stat (15.1)" /
    // "aggression rating (85.6)" forms with an extra noun.
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)($noun)\\s*\\((\\d+(?:\\.\\d+)?)\\)'
        r'(?!\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]}${match[2]} (${match[3]}%)',
    );
    // OCR-split close paren only: "river bluff frequency 63.1)".
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)($noun)\\s+(\\d+(?:\\.\\d+)?)\\)'
        r'(?!\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]}${match[2]} (${match[3]}%)',
    );
    // "aggression above 77" / "VPIP under 20".
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)\\s+(above|below|over|under)\\s+'
        r'(\d+(?:\.\d+)?)(?!\d)(?!\.\d)(?!\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]} ${match[2]} ${match[3]}%',
    );
    // "showdown call up to 77.4" (batch 0226).
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)($noun)\\s+up\\s+to\\s+'
        r'(\d+(?:\.\d+)?)(?!\d)(?!\.\d)(?!\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]}${match[2]} up to ${match[3]}%',
    );
    // Comparison rates: "VPIP > 48" / "showdown call › 65" (batch 0163).
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)\\s*([<>≤≥‹›])\\s*'
        r'(\d+(?:\.\d+)?)(?!\d)(?!\.\d)(?!\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]} ${match[2]} ${match[3]}%',
    );
    // "aggression at 87.7 and 92.9".
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)\\s+at\\s+(\\d+(?:\\.\\d+)?)(?!\\s*%)\\s+and\\s+'
        r'(\d+(?:\.\d+)?)(?!\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]} at ${match[2]}% and ${match[3]}%',
    );
    // Single rate: "aggression at 59.5" / "VPIP at 40".
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)\\s+at\\s+(\\d+(?:\\.\\d+)?)(?!\\d)(?!\\.\\d)(?!\\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]} at ${match[2]}%',
    );
  }
  // Nested tendency parens from model prose (batch 0197):
  // "Alex (3-bet (9.4%) and Cole (3-bet (9.9%)" →
  // "Alex (3-bet 9.4%) and Cole (3-bet 9.9%)".
  // Leave standalone "3-bet (25.3%)" alone.
  for (final label in _tendencyLabels.values.toSet()) {
    final escaped = RegExp.escape(label);
    const noun =
        r'(?:\s+(?:frequency|rate|stat|rating|range|score|tendenc(?:y|ies)))?';
    text = text.replaceAllMapped(
      RegExp(
        '\\(\\s*($escaped)($noun)\\s*\\((\\d+(?:\\.\\d+)?)%\\s*\\)',
        caseSensitive: false,
      ),
      (match) => '(${match[1]}${match[2]} ${match[3]}%)',
    );
    // Name + label nest (batch 0229):
    // "active (Dale VPIP (46.6%), leaving" →
    // "active (Dale VPIP 46.6%), leaving".
    text = text.replaceAllMapped(
      RegExp(
        '\\(\\s*([A-Z][a-z]{2,})\\s+($escaped)($noun)\\s*'
        '\\((\\d+(?:\\.\\d+)?)%\\s*\\)',
      ),
      (match) => '(${match[1]} ${match[2]}${match[3]} ${match[4]}%)',
    );
  }
  // Mid-list nested tendency rates inside an open paren (batch 0198/0203/0205):
  // "Maniac (aggression 78.3%, VPIP (51.3%) who" →
  // "Maniac (aggression 78.3%, VPIP 51.3%) who".
  // "Paul (VPIP 40.7%, showdown call (62.6%) and Alex's" →
  // "Paul (VPIP 40.7%, showdown call 62.6%) and Alex's".
  // "profile (VPIP 10.8%, 3-bet (3.8%) alongside" →
  // "profile (VPIP 10.8%, 3-bet 3.8%) alongside".
  // Only when the rate-paren is wrongly ending mid-clause
  // (`who` / `and Name` / lowercase continuer / `.` / `;` / `, leaving`),
  // not list items like "PFR (26%), and …".
  // Standalone "3-bet (25.3%)" / "aggression (77%) and Carl" (depth 0)
  // stays intact.
  {
    final labelAlt =
        _tendencyLabels.values.map(RegExp.escape).toSet().join('|');
    final nestedMid = RegExp(
      '($labelAlt)((?:\\s+(?:frequency|rate|stat|rating|range|score|tendenc(?:y|ies)))?)\\s*'
      r'\((\d+(?:\.\d+)?)%\s*\)',
      caseSensitive: false,
    );
    text = text.replaceAllMapped(nestedMid, (match) {
      final before = match.input.substring(0, match.start);
      var depth = 0;
      for (var i = 0; i < before.length; i++) {
        final ch = before[i];
        if (ch == '(') {
          depth++;
        } else if (ch == ')') {
          depth--;
        }
      }
      if (depth <= 0) {
        return match[0]!;
      }
      final after = match.input.substring(match.end);
      final wronglyCloses = RegExp(
            r'^\s+(?:who|that|which|while|when|making)\b',
            caseSensitive: false,
          ).hasMatch(after) ||
          // "showdown call (62.6%) and Alex's"
          RegExp(r'^\s+and\s+[A-Z]').hasMatch(after) ||
          // "3-bet (3.8%) alongside multiway …"
          RegExp(r'^\s+[a-z]').hasMatch(after) ||
          // "VPIP (46.6%), leaving …" (batch 0229) — not list ", and …"
          RegExp(r'^\s*,\s+(?!and\b)[a-z]').hasMatch(after) ||
          // "river bluff (62.6%); raising …" (batch 0224)
          RegExp(r'^\s*[.!?;]').hasMatch(after);
      if (!wronglyCloses) {
        return match[0]!;
      }
      if (depth == 1) {
        return '${match[1]}${match[2]} ${match[3]}%)';
      }
      return '${match[1]}${match[2]} ${match[3]}%';
    });
  }
  // Bare "frequency (63.1)" / "bluff frequency (63.1)" when no tendency
  // label precedes the noun.
  text = text.replaceAllMapped(
    RegExp(
      r'\b((?:bluff\s+)?frequency)\s*\((\d+(?:\.\d+)?)\)(?!\s*%)',
      caseSensitive: false,
    ),
    (match) => '${match[1]} (${match[2]}%)',
  );
  text = text.replaceAllMapped(
    RegExp(
      r'\b((?:bluff\s+)?frequency)\s+(\d+(?:\.\d+)?)\)(?!\s*%)',
      caseSensitive: false,
    ),
    (match) => '${match[1]} (${match[2]}%)',
  );
  // "81.4 and 67.3%" — first rate missing its percent.
  // Skip SPR ratios: "SPR of 0.1 and 13.9% modeled equity" must not become
  // "SPR of 0.1% and 13.9%".
  text = text.replaceAllMapped(
    RegExp(r'(\d+(?:\.\d+)?)(?!\s*%)\s+and\s+(\d+(?:\.\d+)?%)'),
    (match) {
      final before = match.input.substring(0, match.start).toLowerCase();
      if (RegExp(r'spr\s+of\s+~?\s*$').hasMatch(before)) {
        return match[0]!;
      }
      return '${match[1]}% and ${match[2]}';
    },
  );
  // Two-decimal chip amounts (e.g. 33.33), but not pot multipliers like
  // "0.37x pot" and not SPR ratios like "SPR of 0.04" / "SPR near 1.15"
  // (batch 0346 H6 — `1.15` must not become `$1.15`).
  text = text.replaceAllMapped(
    RegExp(r'(?<![\d$])([1-9]\d*\.\d{2})(?!\d)(?!\s*%)(?![xX])'),
    (match) {
      final before = match.input.substring(0, match.start).toLowerCase();
      if (RegExp(
        r'spr\s+(?:of|near|around|at|under|over|=|:)?\s*~?\s*$',
      ).hasMatch(before)) {
        return match[0]!;
      }
      return '\$${match[1]}';
    },
  );
  // Chip amounts before "pot" / "all-in", but not odds ratios like "8-to-1 pot
  // odds", pot fractions like "2/3 pot", and not the cents of an amount that is
  // already marked. Also skip thousands groups: "1,036 pot" must not become
  // "1,$036 pot" (batch 0297 H6) — comma is excluded from the lookbehind.
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$.,\-/])(\d+(?:\.\d{1,2})?)\s+(all-in)\b',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]} ${match[2]}',
  );
  // Whole thousands amounts before pot: "1,036 pot" → "$1,036 pot".
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$])(\d{1,3}(?:,\d{3})+)\s+(pot)\b(?!\s+odds)',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]} ${match[2]}',
  );
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$.,\-/])(\d+(?:\.\d{1,2})?)\s+(pot)\b(?!\s+odds)',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]} ${match[2]}',
  );
  // Repair mangled "$1,$036" from older builds / already-broken model text.
  text = text.replaceAllMapped(
    RegExp(r'\$(\d{1,3}),\$(\d{3})\b'),
    (match) => '\$${match[1]},${match[2]}',
  );
  // "698 total pot" / "a 698 total pot".
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$.,\-/])([1-9]\d*)(?!\.\d)(?!\s*%)\s+(total pot)\b',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]} ${match[2]}',
  );
  // "262 stack" / "125 bb stack" — amount before the noun, not after.
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$.,\-/])([1-9]\d*)(?!\.\d)(?!\s*%)\s+bb\s+stack\b',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]} bb stack',
  );
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$.,\-/])(\d+(?:\.\d{1,2})?)\s+(stack)\b',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]} ${match[2]}',
  );
  // "stack of 157".
  text = text.replaceAllMapped(
    RegExp(
      r'\b(stack of)\s+(?!\$)([1-9]\d*)(?!\.\d)(?!\s*%)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} \$${match[2]}',
  );
  // "Facing a 59 call into" — chip count before call, not "call 50.7%" rates.
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$.,\-/])([1-9]\d*)\s+(call)\b(?!\s*\d)(?!\s*%)(?!\s*\.)',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]} ${match[2]}',
  );
  // "only 163 remaining into" — amount before remaining.
  text = text.replaceAllMapped(
    RegExp(
      r'\b((?:only|just)\s+)?(?<!\$)([1-9]\d*)(?!\.\d)(?!\s*%)\s+(remaining)\b',
      caseSensitive: false,
    ),
    (match) {
      final lead = match[1] ?? '';
      return '$lead\$${match[2]} ${match[3]}';
    },
  );
  // Whole chip counts after verbs, but not the integer prefix of a rate like
  // "call 50.7%" / "call 50.7", and not a bare zero ("Risking 0").
  text = text.replaceAllMapped(
    RegExp(
      r'\b(remaining|final|calling|call|bet|raise|stack|pot of|risk|risking|'
      r'win|requires?|need(?:s|ing)?)\s+'
      r'([1-9]\d*)(?!\.\d)(?!\s*%)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} \$${match[2]}',
  );
  // "Risking only 40 chips" / "requiring only 111 chips".
  text = text.replaceAllMapped(
    RegExp(
      r'\b(risking|requiring)\s+only\s+(?!\$)([1-9]\d*)(?!\.\d)(?!\s*%)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} only \$${match[2]}',
  );
  // "preserves 302 chips" / "saves 80 chips".
  text = text.replaceAllMapped(
    RegExp(
      r'\b(preserves?|saves?)\s+(?!\$)([1-9]\d*)(?!\.\d)(?!\s*%)\s+(chips?)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} \$${match[2]} ${match[3]}',
  );
  // "Fred's 38 chips".
  text = text.replaceAllMapped(
    RegExp(r"\b([A-Za-z]+)'s\s+(?!\$)([1-9]\d*)(?!\.\d)(?!\s*%)\s+(chips?)\b"),
    (match) => "${match[1]}'s \$${match[2]} ${match[3]}",
  );
  // "call $118 into 358" — bare pot after into (2+ digit chips, not "into 4").
  text = text.replaceAllMapped(
    RegExp(
      r'\binto\s+(?!\$)(?!a\s)([1-9]\d+)(?!\.\d)(?!\s*%)(?!\s*-)',
      caseSensitive: false,
    ),
    (match) => 'into \$${match[1]}',
  );
  // "leaving just 73 behind" — skip amounts that already have $.
  // Also skip SPR fractional digits: "SPR 0.7 behind" must not become
  // "SPR 0.$7 behind" (batch 0289 H7). `\b` matches between "." and "7".
  text = text.replaceAllMapped(
    RegExp(
      r'\b((?:just|only)\s+)?(?<![\d$.,])([1-9]\d*)(?!\.\d)(?!\s*%)\s+(behind)\b',
      caseSensitive: false,
    ),
    (match) {
      final lead = match[1] ?? '';
      return '$lead\$${match[2]} ${match[3]}';
    },
  );
  // "only 10 chips behind".
  text = text.replaceAllMapped(
    RegExp(
      r'\b((?:just|only)\s+)?(?<![\d$.,])([1-9]\d*)(?!\.\d)(?!\s*%)\s+'
      r'(chips?)\s+(behind)\b',
      caseSensitive: false,
    ),
    (match) {
      final lead = match[1] ?? '';
      return '$lead\$${match[2]} ${match[3]} ${match[4]}';
    },
  );
  // "requiring only 111 chips to win" (no "behind").
  text = text.replaceAllMapped(
    RegExp(
      r'\b((?:just|only)\s+)(?<!\$)([1-9]\d*)(?!\.\d)(?!\s*%)\s+(chips?)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]}\$${match[2]} ${match[3]}',
  );
  // "244-chip stack" after "remaining 244" was dollarized mid-token.
  text = text.replaceAllMapped(
    RegExp(r'\$?([1-9]\d*)-chip\s+stack\b', caseSensitive: false),
    (match) => '\$${match[1]}-chip stack',
  );
  // "570-chip pot".
  text = text.replaceAllMapped(
    RegExp(r'\$?([1-9]\d*)-chip\s+pot\b', caseSensitive: false),
    (match) => '\$${match[1]}-chip pot',
  );
  // "81 chip pot" / "81 chips pot" (batch 0347 H1).
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$])([1-9]\d*)(?!\.\d)(?!\s*%)\s+chips?\s+pot\b',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]}-chip pot',
  );
  // "120-chip effective shove" / "120-chip shove" / "69-chip call"
  // (batch 0339 H4).
  text = text.replaceAllMapped(
    RegExp(
      r'\$?([1-9]\d*)-chip\s+(effective\s+)?(shove|bet|call)\b',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]}-chip ${match[2] ?? ''}${match[3]}',
  );
  // "72 chip stack" / "72 chips stack".
  text = text.replaceAllMapped(
    RegExp(
      r'(?<![\d$])([1-9]\d*)(?!\.\d)(?!\s*%)\s+chips?\s+stack\b',
      caseSensitive: false,
    ),
    (match) => '\$${match[1]} chip stack',
  );
  // "retains 164 chips" / "keeps 80 chips" /
  // "Committing 102 chips into …" (batch 0314 H2) /
  // "Paying 2400 chips …" (batch 0333 H6).
  text = text.replaceAllMapped(
    RegExp(
      r'\b(retains?|keeps?|commits?|committing|risks?|risking|invests?|investing|'
      r'pays?|paying|puts?|putting)\s+'
      r'(?!\$)([1-9]\d*)(?!\.\d)(?!\s*%)\s+(chips?)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} \$${match[2]} ${match[3]}',
  );
  // "against a 45 bet" / "a 151 shove" — 2+ digit chip bets (not "a 3 bet").
  text = text.replaceAllMapped(
    RegExp(
      r'\b(a|an|the)\s+(?!\$)([1-9]\d+)(?!\.\d)(?!\s*%)\s+(bet|shove)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} \$${match[2]} ${match[3]}',
  );
  // "A flat call of 30" / "a call of 48" / "bet of 60" (batch 0304 H8).
  text = text.replaceAllMapped(
    RegExp(
      r'\b((?:flat\s+)?(?:call|bet|raise))\s+of\s+(?!\$)([1-9]\d*)(?!\.\d)(?!\s*%)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} of \$${match[2]}',
  );
  // "calling a cold 4-bet cold" (batch 0309 H8) — drop the trailing "cold".
  text = text.replaceAllMapped(
    RegExp(
      r'\b(cold\s+\d+-bet)\s+cold\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]}',
  );
  // "for 155 more" / "for 42 chips" / "for 137 into a $732 pot" /
  // "Calling all-in for 246 with …" (batch 0311 H5).
  text = text.replaceAllMapped(
    RegExp(
      r'\b(for)\s+(?!\$)([1-9]\d*)(?!\.\d)(?!\s*%)\s+(more|chips?|into|with)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} \$${match[2]} ${match[3]}',
  );
  // "exceeds 800" / "exceeding 1000 chips" when describing a pot
  // (batch 0321 H5).
  text = text.replaceAllMapped(
    RegExp(
      r'\b(exceeds?|exceeding)\s+(?!\$)([1-9]\d{2,})(?!\.\d)(?!\s*%)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} \$${match[2]}',
  );
  // "total pot over 1194" (batch 0342 H8).
  text = text.replaceAllMapped(
    RegExp(
      r'\b(pot\s+over)\s+(?!\$)([1-9]\d{2,})(?!\.\d)(?!\s*%)\b',
      caseSensitive: false,
    ),
    (match) => '${match[1]} \$${match[2]}',
  );
  // Strip accidental $ on SPR ratios: "SPR near $1.15" (batch 0346 H6).
  text = text.replaceAllMapped(
    RegExp(
      r'\b(SPR\s+(?:of|near|around|at|under|over|=|:)\s*~?\s*)\$(\d+(?:\.\d+)?)',
      caseSensitive: false,
    ),
    (match) => '${match[1]}${match[2]}',
  );
  // "65%-74" percent ranges missing the trailing mark.
  text = text.replaceAllMapped(
    RegExp(r'(\d+(?:\.\d+)?%)-(\d+(?:\.\d+)?)(?!\s*%)'),
    (match) => '${match[1]}-${match[2]}%',
  );
  // "65.5-79.1%" percent ranges missing the leading mark.
  text = text.replaceAllMapped(
    RegExp(r'(\d+(?:\.\d+)?)(?!\s*%)-(\d+(?:\.\d+)?%)'),
    (match) => '${match[1]}%-${match[2]}',
  );
  // Bare tendency ranges: "showdown call 65-74" / "(65.5-79.1)".
  // Avoid odds ("8-to-1") and SPR-style decimals by requiring an integer
  // pair after a known rate label, or a parenthetical pair.
  for (final label in _tendencyLabels.values) {
    final escaped = RegExp.escape(label);
    text = text.replaceAllMapped(
      RegExp(
        '($escaped)\\s+(\\d{1,2}(?:\\.\\d+)?)(?!\\s*%)-'
        r'(\d{1,2}(?:\.\d+)?)(?!\s*%)',
        caseSensitive: false,
      ),
      (match) => '${match[1]} ${match[2]}%-${match[3]}%',
    );
  }
  text = text.replaceAllMapped(
    RegExp(r'\((\d{1,2}(?:\.\d+)?)(?!\s*%)-(\d{1,2}(?:\.\d+)?)(?!\s*%)\)'),
    (match) => '(${match[1]}%-${match[2]}%)',
  );
  // Paired rates in parentheses: "aggression (65.8 and 69.7)".
  text = text.replaceAllMapped(
    RegExp(r'\((\d+(?:\.\d+)?)(?!\s*%)\s+and\s+(\d+(?:\.\d+)?)(?!\s*%)\)'),
    (match) => '(${match[1]}% and ${match[2]}%)',
  );
  // Comma-paired rates: "VPIP (50.8, 45.1)" (batch 0210).
  text = text.replaceAllMapped(
    RegExp(
      r'\((\d{1,2}(?:\.\d+)?)(?!\s*%)\s*,\s*(\d{1,2}(?:\.\d+)?)(?!\s*%)\)',
    ),
    (match) => '(${match[1]}%, ${match[2]}%)',
  );
  // Named rate lists: "(Dale 77.4, Fred 71.7)".
  text = text.replaceAllMapped(
    RegExp(
      r'\(([A-Za-z][A-Za-z.]+)\s+(\d{1,2}(?:\.\d+)?)(?!\s*%)\s*,\s*'
      r'([A-Za-z][A-Za-z.]+)\s+(\d{1,2}(?:\.\d+)?)(?!\s*%)\)',
    ),
    (match) => '(${match[1]} ${match[2]}%, ${match[3]} ${match[4]}%)',
  );
  // Named rate list continuations after a percented rate (batch 0222):
  // "(Chaos aggression 93.9%, Rex 65.4, Jade 69.7)" →
  // "(Chaos aggression 93.9%, Rex 65.4%, Jade 69.7%)".
  // Require a complete number token (`(?!\.\d)`) so "71.7%" is not
  // rewritten as "71%.7%".
  {
    final namedContinuation = RegExp(
      r'(%),\s*([A-Z][a-z]{2,})\s+(\d{1,2}(?:\.\d+)?)(?!\d)(?!\.\d)(?!\s*%)',
    );
    var prev = '';
    while (prev != text) {
      prev = text;
      text = text.replaceAllMapped(
        namedContinuation,
        (match) => '${match[1]}, ${match[2]} ${match[3]}%',
      );
    }
  }
  // "Rex (53.8) and Jade (52.6)" named paren rates.
  text = text.replaceAllMapped(
    RegExp(
      r'\b([A-Z][a-z]{2,})\s+\((\d{1,2}(?:\.\d+)?)\)(?!\s*%)\s+and\s+'
      r'([A-Z][a-z]{2,})\s+\((\d{1,2}(?:\.\d+)?)\)(?!\s*%)',
    ),
    (match) => '${match[1]} (${match[2]}%) and ${match[3]} (${match[4]}%)',
  );
  // Unclosed profile rate lists (batch 0226):
  // "Sammy (LAG, aggression 70.3% generate" →
  // "Sammy (LAG, aggression 70.3%) generate".
  {
    final labelAlt =
        _tendencyLabels.values.map(RegExp.escape).toSet().join('|');
    text = text.replaceAllMapped(
      RegExp(
        '($labelAlt)\\s+(\\d+(?:\\.\\d+)?)%(?!\\s*[),;])\\s+(?=[a-z])',
        caseSensitive: false,
      ),
      (match) {
        final before = match.input.substring(0, match.start);
        var depth = 0;
        for (var i = 0; i < before.length; i++) {
          final ch = before[i];
          if (ch == '(') {
            depth++;
          } else if (ch == ')') {
            depth--;
          }
        }
        if (depth <= 0) {
          return match[0]!;
        }
        return '${match[1]} ${match[2]}%) ';
      },
    );
  }
  // Named profile rate closed with a comma instead of ")" (batch 0311 H6):
  // "station (Paul: showdown call 74.9%, flatting keeps" →
  // "station (Paul: showdown call 74.9%), flatting keeps".
  {
    final labelAlt =
        _tendencyLabels.values.map(RegExp.escape).toSet().join('|');
    text = text.replaceAllMapped(
      RegExp(
        '\\(([A-Z][a-z]{2,}):\\s*($labelAlt)\\s+'
        r'(\d+(?:\.\d+)?)%\s*,\s+(?=[a-z])',
        caseSensitive: false,
      ),
      (match) => '(${match[1]}: ${match[2]} ${match[3]}%), ',
    );
  }
  // Model typo "maneuverabillity" (batch 0287) → "maneuverability".
  text = text.replaceAll(
    RegExp(r'\bmaneuverabillity\b', caseSensitive: false),
    'maneuverability',
  );
  return text;
}

/// Current server-projected hand state.
@immutable
class LiveHandViewModel {
  /// Creates a projected hand view.
  const LiveHandViewModel({
    required this.sessionId,
    required this.handId,
    required this.setupKey,
    required this.decisionId,
    required this.stateVersion,
    required this.smallBlind,
    required this.bigBlind,
    required this.street,
    required this.board,
    required this.pot,
    required this.buttonSeat,
    required this.heroSeat,
    required this.actorSeat,
    required this.status,
    required this.terminalReason,
    required this.seats,
    required this.legalActions,
    required this.winnerSeats,
    required this.pots,
  });

  final String sessionId;
  final String handId;
  final String setupKey;
  final String decisionId;
  final int stateVersion;
  final double smallBlind;
  final double bigBlind;
  final Street street;
  final List<CardModel> board;
  final double pot;
  final int buttonSeat;
  final int heroSeat;
  final int? actorSeat;
  final String status;
  final String? terminalReason;
  final List<LiveSeatViewModel> seats;
  final List<LiveLegalActionModel> legalActions;
  final List<int> winnerSeats;
  final List<LivePotViewModel> pots;

  List<double> get sidePots =>
      pots.map((pot) => pot.amount).toList(growable: false);

  bool get handOver => status != 'playing';

  factory LiveHandViewModel.fromJson(Map<String, dynamic> json) {
    final streetName = json['street'] as String? ?? 'preflop';
    return LiveHandViewModel(
      sessionId: json['sessionId'] as String? ?? '',
      handId: json['handId'] as String? ?? '',
      setupKey: json['setupKey'] as String? ?? '',
      decisionId: json['decisionId'] as String? ?? '',
      stateVersion: (json['stateVersion'] as num?)?.toInt() ?? 0,
      smallBlind: (json['smallBlind'] as num?)?.toDouble() ?? 1,
      bigBlind: (json['bigBlind'] as num?)?.toDouble() ?? 2,
      street: Street.values.firstWhere(
        (value) => value.name == streetName,
        orElse: () => Street.preflop,
      ),
      board: (json['board'] as List<dynamic>? ?? const [])
          .map((value) => CardModel.fromCode(value.toString()))
          .toList(growable: false),
      pot: (json['pot'] as num?)?.toDouble() ?? 0,
      buttonSeat: (json['buttonSeat'] as num?)?.toInt() ?? 0,
      heroSeat: (json['heroSeat'] as num?)?.toInt() ?? 0,
      actorSeat: (json['actorSeat'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'playing',
      terminalReason: json['terminalReason'] as String?,
      seats: _maps(
        json['seats'],
      ).map(LiveSeatViewModel.fromJson).toList(growable: false),
      legalActions: _maps(
        json['legalActions'],
      ).map(LiveLegalActionModel.fromJson).toList(growable: false),
      winnerSeats: (json['winnerSeats'] as List<dynamic>? ?? const [])
          .map((value) => (value as num).toInt())
          .toList(growable: false),
      pots: _maps(
        json['pots'],
      ).map(LivePotViewModel.fromJson).toList(growable: false),
    );
  }

  /// Converts the authoritative projection into the existing felt model.
  GameState toGameState({required int handCount}) {
    final players = seats
        .map(
          (seat) => PlayerModel(
            id: seat.seat,
            name: seat.name,
            archetype: PlayerArchetype.fromLabel(seat.archetype),
            stack: seat.stack,
            isHero: seat.seat == heroSeat,
            currentBet: seat.streetBet,
            folded: seat.folded,
            allIn: seat.allIn,
            holeCards: seat.holeCards,
            lastActionLabel: seat.lastAction,
            tendency: seat.tendency,
          ),
        )
        .toList(growable: false);
    final streetBets = players.fold<double>(
      0,
      (total, player) => total + player.currentBet,
    );
    final isHeadsUp = players.length == 2;
    final sb = isHeadsUp ? buttonSeat : (buttonSeat + 1) % players.length;
    final bb = (sb + 1) % players.length;
    final highest = players.fold<double>(
      0,
      (value, player) => player.currentBet > value ? player.currentBet : value,
    );
    final winnerPayouts = <int, double>{};
    for (final pot in pots) {
      final shares = Money.splitPot(pot.amount, pot.winnerSeats);
      for (final entry in shares.entries) {
        winnerPayouts[entry.key] = Money.round(
          (winnerPayouts[entry.key] ?? 0) + entry.value,
        );
      }
    }
    return GameState(
      players: players,
      mode: GameMode.training,
      community: board,
      mainPot: handOver ? 0 : (pot - streetBets).clamp(0, double.infinity),
      awardedPot: handOver ? pot : 0,
      street: street,
      dealerIndex: buttonSeat,
      sbIndex: sb,
      bbIndex: bb,
      activePlayerIndex: actorSeat ?? heroSeat,
      highestBet: highest,
      minRaise: bigBlind,
      smallBlind: smallBlind,
      bigBlind: bigBlind,
      handCount: handCount,
      isHandOver: handOver,
      waitingForHero:
          !handOver && actorSeat == heroSeat && legalActions.isNotEmpty,
      resultMessage:
          status == 'hero_folded'
              ? 'Hero folded'
              : handOver
              ? terminalReason == 'showdown'
                  ? 'Showdown'
                  : 'Hand won by fold'
              : null,
      winnerIds: winnerSeats,
      sidePots: sidePots,
      winnerPayouts: winnerPayouts,
      splitPotAward: pots.any((pot) => pot.winnerSeats.length > 1),
    );
  }
}

/// One authoritative main/side-pot result.
@immutable
class LivePotViewModel {
  const LivePotViewModel({
    required this.amount,
    required this.eligibleSeats,
    required this.winnerSeats,
  });

  final double amount;
  final List<int> eligibleSeats;
  final List<int> winnerSeats;

  factory LivePotViewModel.fromJson(Map<String, dynamic> json) {
    List<int> seats(String key) => (json[key] as List<dynamic>? ?? const [])
        .map((value) => (value as num).toInt())
        .toList(growable: false);
    return LivePotViewModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      eligibleSeats: seats('eligibleSeats'),
      winnerSeats: seats('winnerSeats'),
    );
  }
}

/// One client-visible seat.
@immutable
class LiveSeatViewModel {
  const LiveSeatViewModel({
    required this.seat,
    required this.name,
    required this.archetype,
    required this.stack,
    required this.streetBet,
    required this.folded,
    required this.allIn,
    required this.holeCards,
    this.lastAction,
    this.tendency,
  });

  final int seat;
  final String name;
  final String archetype;
  final double stack;
  final double streetBet;
  final bool folded;
  final bool allIn;
  final String? lastAction;
  final List<CardModel> holeCards;
  final TendencyProfileModel? tendency;

  factory LiveSeatViewModel.fromJson(Map<String, dynamic> json) {
    final tendencyRaw = json['tendency'];
    return LiveSeatViewModel(
      seat: (json['seat'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      archetype: json['archetype'] as String? ?? 'TAG',
      stack: (json['stack'] as num?)?.toDouble() ?? 0,
      streetBet: (json['streetBet'] as num?)?.toDouble() ?? 0,
      folded: json['folded'] as bool? ?? false,
      allIn: json['allIn'] as bool? ?? false,
      lastAction: json['lastAction'] as String?,
      holeCards: (json['holeCards'] as List<dynamic>? ?? const [])
          .map((value) => CardModel.fromCode(value.toString()))
          .toList(growable: false),
      tendency:
          tendencyRaw is Map
              ? TendencyProfileModel.fromJson(
                tendencyRaw.map((key, value) => MapEntry('$key', value)),
              )
              : null,
    );
  }
}

/// Response from start/resume.
@immutable
class LiveHandStartResult {
  const LiveHandStartResult({
    required this.view,
    required this.events,
    this.sessionMode = 'live',
    this.courseContext,
  });

  final LiveHandViewModel view;
  final List<LiveActionEventModel> events;
  final String sessionMode;
  final Map<String, dynamic>? courseContext;

  factory LiveHandStartResult.fromJson(Map<String, dynamic> json) {
    final context = json['courseContext'];
    return LiveHandStartResult(
      view: LiveHandViewModel.fromJson(_map(json['view'])),
      events: _maps(
        json['events'],
      ).map(LiveActionEventModel.fromJson).toList(growable: false),
      sessionMode: json['sessionMode'] as String? ?? 'live',
      courseContext:
          context is Map ? Map<String, dynamic>.from(context) : null,
    );
  }
}

/// Response from one Hero action.
@immutable
class LiveActionResult {
  const LiveActionResult({
    required this.view,
    required this.events,
    required this.coaching,
    required this.replayed,
  });

  final LiveHandViewModel view;
  final List<LiveActionEventModel> events;
  final LiveCoachingAssessment coaching;
  final bool replayed;

  factory LiveActionResult.fromJson(Map<String, dynamic> json) {
    return LiveActionResult(
      view: LiveHandViewModel.fromJson(_map(json['view'])),
      events: _maps(
        json['events'],
      ).map(LiveActionEventModel.fromJson).toList(growable: false),
      coaching: LiveCoachingAssessment.fromJson(_map(json['coaching'])),
      replayed: json['replayed'] as bool? ?? false,
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _maps(dynamic value) {
  if (value is! List) return const [];
  return value.map(_map).toList(growable: false);
}
