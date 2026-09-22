/// Example made-hand visuals for Hand ranks lesson activities.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Demo cards + short caption for a hand-category teaching token.
class LessonHandExample {
  /// Creates an example.
  const LessonHandExample({
    required this.id,
    required this.title,
    required this.codes,
  });

  final String id;
  final String title;
  final List<String> codes;
}

/// Resolves a teaching example for a sequence/choice id or label.
LessonHandExample? resolveHandExample({
  required String id,
  String? label,
}) {
  switch (id) {
    case 'hr-high':
      return const LessonHandExample(
        id: 'hr-high',
        title: 'High card',
        codes: ['Ah', 'Kd', '9c', '7s', '3h'],
      );
    case 'hr-pair':
      return const LessonHandExample(
        id: 'hr-pair',
        title: 'One pair',
        codes: ['Qh', 'Qd', 'Jc', '8s', '4h'],
      );
    case 'hr-flush':
      return const LessonHandExample(
        id: 'hr-flush',
        title: 'Flush',
        codes: ['Ah', 'Kh', '8h', '5h', '2h'],
      );
    case 'cat-flush':
      return const LessonHandExample(
        id: 'cat-flush',
        title: 'Flush',
        codes: ['Ac', 'Kc', '9c', '4c', '7c'],
      );
    case 'cat-pair':
      return const LessonHandExample(
        id: 'cat-pair',
        title: 'One pair',
        codes: ['Kh', 'Kd', 'Qc', '8s', '3h'],
      );
    case 'cat-straight':
      return const LessonHandExample(
        id: 'cat-straight',
        title: 'Straight',
        codes: ['9h', '8d', '7c', '6s', '5h'],
      );
    case 'fh':
      return const LessonHandExample(
        id: 'fh',
        title: 'Full house',
        codes: ['Ah', 'Ad', 'As', 'Kd', 'Kc'],
      );
    case 'trips':
      return const LessonHandExample(
        id: 'trips',
        title: 'Three of a kind',
        codes: ['9h', '9d', '9c', 'As', '2s'],
      );
    case 'two':
      return const LessonHandExample(
        id: 'two',
        title: 'Two pair',
        codes: ['Jh', 'Jd', 'Tc', 'Td', '3s'],
      );
    case 'you-win':
      return const LessonHandExample(
        id: 'you-win',
        title: 'Your flush',
        codes: ['Ac', 'Kc', '9c', '4c', '2c'],
      );
    case 'they-win':
      return const LessonHandExample(
        id: 'they-win',
        title: 'Their straight',
        codes: ['9h', '8d', '7c', '6s', '5h'],
      );
    case 'you-kicker':
      return const LessonHandExample(
        id: 'you-kicker',
        title: 'You — kings, Q kicker',
        codes: ['Kh', 'Kd', 'Ah', 'Qd', '7c'],
      );
    case 'they-kicker':
      return const LessonHandExample(
        id: 'they-kicker',
        title: 'They — kings, J kicker',
        codes: ['Kh', 'Kd', 'As', 'Jd', '7c'],
      );
    case 'chop-kicker':
      return const LessonHandExample(
        id: 'chop-kicker',
        title: 'Chop the pot',
        codes: [],
      );
    case 'chop-broadway':
      return const LessonHandExample(
        id: 'chop-broadway',
        title: 'Chop — board plays',
        codes: ['Ac', 'Kc', 'Qc', 'Jc', 'Tc'],
      );
    case 'button-wins':
      return const LessonHandExample(
        id: 'button-wins',
        title: 'Button wins',
        codes: [],
      );
    case 'high-card-wins':
      return const LessonHandExample(
        id: 'high-card-wins',
        title: 'Higher hole card',
        codes: ['Ah', '2d'],
      );
    case 'split':
      return const LessonHandExample(
        id: 'split',
        title: 'Chop the pot',
        codes: [],
      );
  }

  final blob = '$id ${label ?? ''}'.toLowerCase();
  if (blob.contains('flush')) {
    return LessonHandExample(
      id: id,
      title: label ?? 'Flush',
      codes: const ['Ah', 'Kh', '8h', '5h', '2h'],
    );
  }
  if (blob.contains('full house')) {
    return LessonHandExample(
      id: id,
      title: label ?? 'Full house',
      codes: const ['Ah', 'Ad', 'As', 'Kd', 'Kc'],
    );
  }
  if (blob.contains('three of a kind') || blob.contains('trips')) {
    return LessonHandExample(
      id: id,
      title: label ?? 'Three of a kind',
      codes: const ['9h', '9d', '9c', 'As', '2s'],
    );
  }
  if (blob.contains('two pair')) {
    return LessonHandExample(
      id: id,
      title: label ?? 'Two pair',
      codes: const ['Ah', 'Ad', 'Kc', 'Kd', '3s'],
    );
  }
  if (blob.contains('pair')) {
    return LessonHandExample(
      id: id,
      title: label ?? 'One pair',
      codes: const ['Ah', 'Ad', 'Kc', '9s', '3h'],
    );
  }
  if (blob.contains('straight')) {
    return LessonHandExample(
      id: id,
      title: label ?? 'Straight',
      codes: const ['9h', '8d', '7c', '6s', '5h'],
    );
  }
  if (blob.contains('high')) {
    return LessonHandExample(
      id: id,
      title: label ?? 'High card',
      codes: const ['Ah', 'Kd', '9c', '7s', '3h'],
    );
  }
  return null;
}

/// Whether this activity should render sequence items as hand examples.
bool isHandExampleSequenceActivity(CourseActivity activity) {
  if (activity.id.startsWith('act-01-02-01-') ||
      activity.id == 'act-01-06-02-jump-ranks') {
    return true;
  }
  if (activity.sequenceItems.isEmpty) return false;
  return activity.sequenceItems.every(
    (item) => resolveHandExample(id: item.id, label: item.label) != null,
  );
}

/// Compact five-card hand tile used for tap-to-order / category pick.
class HandExampleTile extends StatelessWidget {
  /// Creates a hand example tile.
  const HandExampleTile({
    super.key,
    required this.example,
    required this.selected,
    required this.enabled,
    this.badge,
    this.onPressed,
    this.compact = false,
  });

  final LessonHandExample example;
  final bool selected;
  final bool enabled;
  final String? badge;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cards = <CardModel>[];
    for (final code in example.codes) {
      try {
        cards.add(CardModel.fromCode(code));
      } catch (_) {
        // Skip bad demo codes.
      }
    }
    final border =
        selected
            ? AppColors.gold
            : AppColors.slateDark.withValues(alpha: 0.85);
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: EdgeInsets.fromLTRB(
        compact ? 8 : 10,
        compact ? 8 : 10,
        compact ? 8 : 10,
        compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.feltLight.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: selected ? 2.2 : 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badge != null) ...[
                Text(
                  badge!,
                  style: GoogleFonts.manrope(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
              ],
          Text(
            example.title,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w800,
            ),
          ),
            ],
          ),
          if (cards.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) SizedBox(width: compact ? 2 : 3),
                  MiniCard(
                    card: cards[i],
                    size: compact ? MiniCardSize.tiny : MiniCardSize.small,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );

    if (onPressed == null) return child;
    return Semantics(
      button: true,
      selected: selected,
      label: example.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: child,
        ),
      ),
    );
  }
}

/// Vertical ladder of example hands for the explain step.
class HandRankLadderDemo extends StatelessWidget {
  /// Creates the ladder demo.
  const HandRankLadderDemo({super.key});

  static const _rungs = <LessonHandExample>[
    LessonHandExample(
      id: 'demo-high',
      title: 'High card',
      codes: ['Ah', 'Kd', '9c', '7s', '3h'],
    ),
    LessonHandExample(
      id: 'demo-pair',
      title: 'One pair',
      codes: ['Qh', 'Qd', 'Jc', '8s', '4h'],
    ),
    LessonHandExample(
      id: 'demo-flush',
      title: 'Flush',
      codes: ['Ah', 'Kh', '8h', '5h', '2h'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.feltLight, AppColors.feltDark],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
        ),
        child: Column(
          children: [
            Text(
              'Weakest → strongest',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _rungs.length; i++) ...[
              if (i > 0) ...[
                const SizedBox(height: 6),
                Icon(
                  Icons.arrow_downward_rounded,
                  color: AppColors.gold.withValues(alpha: 0.75),
                  size: 18,
                ),
                const SizedBox(height: 6),
              ],
              HandExampleTile(
                example: _rungs[i],
                selected: false,
                enabled: false,
                compact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
