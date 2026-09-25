/// Example made-hand visuals for Hand ranks lesson activities.
library;

import 'dart:math';

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
        // Match the board-chop spot's holes — never invent an Ace.
        title: 'Higher hole card',
        codes: ['2h', '2d'],
      );
    case 'j2-sa':
      return const LessonHandExample(
        id: 'j2-sa',
        title: 'Suited ace',
        codes: ['Ah', '9h'],
      );
    case 'j2-pair':
      return const LessonHandExample(
        id: 'j2-pair',
        title: 'Pocket pair',
        codes: ['8h', '8c'],
      );
    case 'j2-trash':
      return const LessonHandExample(
        id: 'j2-trash',
        title: 'Offsuit trash',
        codes: ['7c', '2d'],
      );
    case 'hf-pair':
      return const LessonHandExample(
        id: 'hf-pair',
        title: 'Pocket pair',
        codes: ['8h', '8c'],
      );
    case 'hf-broadway':
      return const LessonHandExample(
        id: 'hf-broadway',
        title: 'Broadway',
        codes: ['As', 'Kd'],
      );
    case 'hf-suited-ace':
      return const LessonHandExample(
        id: 'hf-suited-ace',
        title: 'Suited ace',
        codes: ['Ah', '9h'],
      );
    case 'hf-sc':
      return const LessonHandExample(
        id: 'hf-sc',
        title: 'Suited connector',
        codes: ['7h', '6h'],
      );
    case 'hf-offsuit-conn':
      return const LessonHandExample(
        id: 'hf-offsuit-conn',
        title: 'Offsuit connector',
        codes: ['7h', '6d'],
      );
    case 'hf-trash':
      return const LessonHandExample(
        id: 'hf-trash',
        title: 'Offsuit trash',
        codes: ['7c', '2d'],
      );
    case 'made-tp':
      return const LessonHandExample(
        id: 'made-tp',
        title: 'Made — top pair',
        codes: [],
      );
    case 'draw-tp':
      return const LessonHandExample(
        id: 'draw-tp',
        title: 'Draw only',
        codes: [],
      );
    case 'air-tp':
      return const LessonHandExample(
        id: 'air-tp',
        title: 'Air',
        codes: [],
      );
    case 'nfd':
      return const LessonHandExample(
        id: 'nfd',
        title: 'Draw — nut flush',
        codes: [],
      );
    case 'made-aj':
      return const LessonHandExample(
        id: 'made-aj',
        title: 'Made — top pair',
        codes: [],
      );
    case 'sdv':
      return const LessonHandExample(
        id: 'sdv',
        title: 'Showdown value',
        codes: [],
      );
    case 'air':
      return const LessonHandExample(
        id: 'air',
        title: 'Air',
        codes: [],
      );
    case 'sdv-54':
      return const LessonHandExample(
        id: 'sdv-54',
        title: 'Showdown value',
        codes: [],
      );
    case 'made-54':
      return const LessonHandExample(
        id: 'made-54',
        title: 'Made hand',
        codes: [],
      );
    case 'oesd':
      return const LessonHandExample(
        id: 'oesd',
        title: 'Draw — open-ender',
        codes: [],
      );
    case 'made-jt':
      return const LessonHandExample(
        id: 'made-jt',
        title: 'Made — top pair',
        codes: [],
      );
    case 'air-j8':
      return const LessonHandExample(
        id: 'air-j8',
        title: 'Pure air',
        codes: [],
      );
    case 'outs-3':
      // Ah is in hero's hand — remaining aces are the clean outs.
      return const LessonHandExample(
        id: 'outs-3',
        title: 'Remaining aces',
        codes: ['As', 'Ad', 'Ac'],
      );
    case 'outs-6':
      // Spoiler trap: queens are dirty (pair under king-high).
      return const LessonHandExample(
        id: 'outs-6',
        title: 'Aces + queens',
        codes: ['As', 'Ad', 'Qs', 'Qd'],
      );
    case 'outs-0':
      return const LessonHandExample(
        id: 'outs-0',
        title: 'No clean outs',
        codes: [],
      );
    case 'call-draw':
      return const LessonHandExample(
        id: 'call-draw',
        title: 'Call — priced in',
        codes: [],
      );
    case 'fold-draw':
      return const LessonHandExample(
        id: 'fold-draw',
        title: 'Fold — no made hand',
        codes: [],
      );
    case 'raise-auto':
      return const LessonHandExample(
        id: 'raise-auto',
        title: 'Raise every draw',
        codes: [],
      );
    case 'implied-yes':
      return const LessonHandExample(
        id: 'implied-yes',
        title: 'Implied — they pay when you hit',
        codes: [],
      );
    case 'implied-no':
      return const LessonHandExample(
        id: 'implied-no',
        title: 'Depth never changes price',
        codes: [],
      );
    case 'fold-nfd':
      return const LessonHandExample(
        id: 'fold-nfd',
        title: 'Fold every nut draw',
        codes: [],
      );
    case 'brick':
      return const LessonHandExample(
        id: 'brick',
        title: 'Brick — rarely helps',
        codes: [],
      );
    case 'scare':
      return const LessonHandExample(
        id: 'scare',
        title: 'Major scare card',
        codes: [],
      );
    case 'always-change':
      return const LessonHandExample(
        id: 'always-change',
        title: 'Every turn changes all',
        codes: [],
      );
    case 'give-up':
      return const LessonHandExample(
        id: 'give-up',
        title: 'Give up — card hurts air',
        codes: [],
      );
    case 'auto-jam':
      return const LessonHandExample(
        id: 'auto-jam',
        title: 'Always jam larger',
        codes: [],
      );
    case 'ignore':
      return const LessonHandExample(
        id: 'ignore',
        title: 'Treat every turn as brick',
        codes: [],
      );
    case 'role-catch':
      return const LessonHandExample(
        id: 'role-catch',
        title: 'Bluff-catch or fold',
        codes: [],
      );
    case 'role-value':
      return const LessonHandExample(
        id: 'role-value',
        title: 'Always thin-value shove',
        codes: [],
      );
    case 'role-air':
      return const LessonHandExample(
        id: 'role-air',
        title: 'Pure bluff with one pair',
        codes: [],
      );
    case 'sc':
      return const LessonHandExample(
        id: 'sc',
        title: 'Suited connector · IP',
        codes: ['7h', '6h'],
      );
    case 'kto':
      return const LessonHandExample(
        id: 'kto',
        title: 'KTo · out of position',
        codes: ['Kd', 'Tc'],
      );
    case 'q6o':
      return const LessonHandExample(
        id: 'q6o',
        title: 'Q6o · any seat',
        codes: ['Qh', '6d'],
      );
    case 'obs-many':
      return const LessonHandExample(
        id: 'obs-many',
        title: 'Note — they play many',
        codes: [],
      );
    case 'obs-ignore':
      return const LessonHandExample(
        id: 'obs-ignore',
        title: 'Ignore seat history',
        codes: [],
      );
    case 'obs-label':
      return const LessonHandExample(
        id: 'obs-label',
        title: 'Insult their personality',
        codes: [],
      );
    case 'notes':
      return const LessonHandExample(
        id: 'notes',
        title: 'A raises a lot · B plays few',
        codes: [],
      );
    case 'guess':
      return const LessonHandExample(
        id: 'guess',
        title: 'Invent life stories',
        codes: [],
      );
    case 'same':
      return const LessonHandExample(
        id: 'same',
        title: 'Treat every seat the same',
        codes: [],
      );
    case 'j3-track':
      return const LessonHandExample(
        id: 'j3-track',
        title: 'Pot + effective 40bb',
        codes: [],
      );
    case 'j3-ignore':
      return const LessonHandExample(
        id: 'j3-ignore',
        title: 'Only hole cards',
        codes: [],
      );
    case 'j3-chat':
      return const LessonHandExample(
        id: 'j3-chat',
        title: 'Only table talk',
        codes: [],
      );
    case 'j3-draw':
      return const LessonHandExample(
        id: 'j3-draw',
        title: 'Draw — OESD + flush',
        codes: [],
      );
    case 'j3-made':
      return const LessonHandExample(
        id: 'j3-made',
        title: 'Made two pair',
        codes: [],
      );
    case 'j3-air':
      return const LessonHandExample(
        id: 'j3-air',
        title: 'Air',
        codes: [],
      );
    case 'j3-foldprice':
      return const LessonHandExample(
        id: 'j3-foldprice',
        title: 'Fold — price is wrong',
        codes: [],
      );
    case 'j3-callprice':
      return const LessonHandExample(
        id: 'j3-callprice',
        title: 'Call any draw',
        codes: [],
      );
    case 'strong-narrow':
      return const LessonHandExample(
        id: 'strong-narrow',
        title: 'Stronger, narrower range',
        codes: [],
      );
    case 'any-two':
      return const LessonHandExample(
        id: 'any-two',
        title: 'Any two cards',
        codes: [],
      );
    case 'exact-ak':
      return const LessonHandExample(
        id: 'exact-ak',
        title: 'Exactly Ace-King',
        codes: [],
      );
    case 'bb-stronger':
      return const LessonHandExample(
        id: 'bb-stronger',
        title: 'BB 3-bet is stronger',
        codes: [],
      );
    case 'btn-stronger':
      return const LessonHandExample(
        id: 'btn-stronger',
        title: 'BTN call is stronger',
        codes: [],
      );
    case 'equal':
      return const LessonHandExample(
        id: 'equal',
        title: 'Identical ranges',
        codes: [],
      );
    case 'too-exact':
      return const LessonHandExample(
        id: 'too-exact',
        title: 'Too exact — keep a range',
        codes: [],
      );
    case 'fine-exact':
      return const LessonHandExample(
        id: 'fine-exact',
        title: 'Exact hands are knowable',
        codes: [],
      );
    case 'ignore-action':
      return const LessonHandExample(
        id: 'ignore-action',
        title: 'Ignore the betting pattern',
        codes: [],
      );
    case 'read-drives':
      return const LessonHandExample(
        id: 'read-drives',
        title: 'Advice follows the range',
        codes: [],
      );
    case 'always-same':
      return const LessonHandExample(
        id: 'always-same',
        title: 'Always the same forever',
        codes: [],
      );
    case 'random':
      return const LessonHandExample(
        id: 'random',
        title: 'Pick randomly',
        codes: [],
      );
    case 'squeeze':
      return const LessonHandExample(
        id: 'squeeze',
        title: '3-bet / squeeze for value',
        codes: [],
      );
    case 'limp-more':
      return const LessonHandExample(
        id: 'limp-more',
        title: 'Limp behind',
        codes: [],
      );
    case 'fold-ak':
      return const LessonHandExample(
        id: 'fold-ak',
        title: 'Fold AK',
        codes: [],
      );
    case 'branches':
      return const LessonHandExample(
        id: 'branches',
        title: 'Brick → barrel · flush → abort',
        codes: [],
      );
    case 'vibes':
      return const LessonHandExample(
        id: 'vibes',
        title: 'Wait for vibes each street',
        codes: [],
      );
    case 'one-street':
      return const LessonHandExample(
        id: 'one-street',
        title: 'Only this street, always',
        codes: [],
      );
    case 'soft':
      return const LessonHandExample(
        id: 'soft',
        title: 'Nearby sizes both soft-grade',
        codes: [],
      );
    case 'one-only':
      return const LessonHandExample(
        id: 'one-only',
        title: 'Only one chip count is correct',
        codes: [],
      );
    case 'random-size':
      return const LessonHandExample(
        id: 'random-size',
        title: 'Even 1-chip bets are fine',
        codes: [],
      );
    case 'before':
      return const LessonHandExample(
        id: 'before',
        title: 'Before you put the rest in',
        codes: [],
      );
    case 'never':
      return const LessonHandExample(
        id: 'never',
        title: 'Never — only hole cards matter',
        codes: [],
      );
    case 'showdown-only':
      return const LessonHandExample(
        id: 'showdown-only',
        title: 'Only at showdown',
        codes: [],
      );
    case 'high-part':
      return const LessonHandExample(
        id: 'high-part',
        title: 'High participation',
        codes: [],
      );
    case 'low-part':
      return const LessonHandExample(
        id: 'low-part',
        title: 'Low participation',
        codes: [],
      );
    case 'label-now':
      return const LessonHandExample(
        id: 'label-now',
        title: 'Label archetype now',
        codes: [],
      );
    case 'sticky':
      return const LessonHandExample(
        id: 'sticky',
        title: 'Sticky calls — low folding',
        codes: [],
      );
    case 'folds-alot':
      return const LessonHandExample(
        id: 'folds-alot',
        title: 'They fold too much',
        codes: [],
      );
    case 'low-conf':
      return const LessonHandExample(
        id: 'low-conf',
        title: 'Low confidence — need samples',
        codes: [],
      );
    case 'sure':
      return const LessonHandExample(
        id: 'sure',
        title: 'Certain forever',
        codes: [],
      );
    case 'bundle':
      return const LessonHandExample(
        id: 'bundle',
        title: 'Many hands · rarely folds',
        codes: [],
      );
    case 'insult':
      return const LessonHandExample(
        id: 'insult',
        title: 'They are a bad person',
        codes: [],
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
    this.expand = false,
  });

  final LessonHandExample example;
  final bool selected;
  final bool enabled;
  final String? badge;
  final VoidCallback? onPressed;
  final bool compact;

  /// Stretch to parent width (full-bleed palette / order slots).
  final bool expand;

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
      width: expand ? double.infinity : null,
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
        crossAxisAlignment:
            expand ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
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
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
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
class HandRankLadderDemo extends StatefulWidget {
  /// Creates the ladder demo.
  const HandRankLadderDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllRungsTapped,
  });

  /// When true, rungs are tappable teach-by-doing targets.
  final bool interactive;

  /// Whether taps are accepted (false while submitting / after grade).
  final bool enabled;

  /// Fires once every rung has been tapped.
  final VoidCallback? onAllRungsTapped;

  static const rungs = <LessonHandExample>[
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
    // Rex names "Flush beats straight" — SoftPulse must show that rung.
    LessonHandExample(
      id: 'demo-straight',
      title: 'Straight',
      codes: ['9h', '8d', '7c', '6s', '5h'],
    ),
    LessonHandExample(
      id: 'demo-flush',
      title: 'Flush',
      codes: ['Ah', 'Kh', '8h', '5h', '2h'],
    ),
  ];

  @override
  State<HandRankLadderDemo> createState() => _HandRankLadderDemoState();
}

class _HandRankLadderDemoState extends State<HandRankLadderDemo> {
  final Set<String> _tapped = <String>{};

  void _onRungTap(LessonHandExample rung) {
    if (!widget.enabled || widget.onAllRungsTapped == null) return;
    setState(() => _tapped.add(rung.id));
    if (_tapped.length >= HandRankLadderDemo.rungs.length) {
      widget.onAllRungsTapped!();
    }
  }

  LessonHandExample? get _nextRung {
    for (final rung in HandRankLadderDemo.rungs) {
      if (!_tapped.contains(rung.id)) return rung;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextRung;
    // Keep densify after the last rung while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + FittedBox rungs (minHeight alone leaves
    // sparse green under High card → pair → straight → Flush).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;

    Widget rungAt(int i) {
      return _SoftPulseTarget(
        active:
            widget.interactive &&
            widget.enabled &&
            next?.id == HandRankLadderDemo.rungs[i].id,
        child: HandExampleTile(
          example: HandRankLadderDemo.rungs[i],
          selected: _tapped.contains(HandRankLadderDemo.rungs[i].id),
          enabled: widget.interactive && widget.enabled,
          compact: true,
          onPressed:
              widget.interactive
                  ? () => _onRungTap(HandRankLadderDemo.rungs[i])
                  : null,
        ),
      );
    }

    final rungs = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < HandRankLadderDemo.rungs.length; i++) ...[
          if (i > 0) ...[
            SizedBox(height: expandTeach ? 8 : 6),
            Icon(
              Icons.arrow_downward_rounded,
              color: AppColors.gold.withValues(alpha: 0.75),
              size: expandTeach ? 20 : 18,
            ),
            SizedBox(height: expandTeach ? 8 : 6),
          ],
          // Intrinsic card tiles — FittedBox parent scales when densified.
          rungAt(i),
        ],
      ],
    );
    // SoftPulse + Rex own the next-rung cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
              ),
              child: Text(
                'High card → pair → straight → flush',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 15 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Weakest → strongest',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                // Pack densified rungs, then contain-scale into the felt —
                // fills tall-phone green (scaleDown left a void).
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: max(
                      MediaQuery.sizeOf(context).width - 48,
                      400,
                    ),
                    child: rungs,
                  ),
                ),
              ),
            )
            : rungs,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 14),
          cue,
        ],
      ],
    );
    final child = Container(
      key: const ValueKey('hand-ladder-felt'),
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.feltBorder.withValues(alpha: 0.85),
        ),
      ),
      child: body,
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Explain-step demo: tap starting-hand family tiles (pairs → connectors).
class HandFamiliesDemo extends StatefulWidget {
  /// Creates the demo.
  const HandFamiliesDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllFamiliesTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllFamiliesTapped;

  static const families = <LessonHandExample>[
    LessonHandExample(
      id: 'fam-pairs',
      title: 'Pairs',
      codes: ['8h', '8c'],
    ),
    LessonHandExample(
      id: 'fam-broadway',
      title: 'Broadways',
      codes: ['As', 'Kd'],
    ),
    LessonHandExample(
      id: 'fam-suited-aces',
      title: 'Suited aces',
      codes: ['Ah', '9h'],
    ),
    LessonHandExample(
      id: 'fam-connectors',
      title: 'Connectors',
      codes: ['7h', '6h'],
    ),
  ];

  @override
  State<HandFamiliesDemo> createState() => _HandFamiliesDemoState();
}

class _HandFamiliesDemoState extends State<HandFamiliesDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(LessonHandExample family) {
    if (!widget.enabled || widget.onAllFamiliesTapped == null) return;
    setState(() => _tapped.add(family.id));
    if (_tapped.length >= HandFamiliesDemo.families.length) {
      widget.onAllFamiliesTapped!();
    }
  }

  LessonHandExample? get _nextFamily {
    for (final family in HandFamiliesDemo.families) {
      if (!_tapped.contains(family.id)) return family;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextFamily;
    // Keep densify after the last family while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;

    Widget familyAt(int i) {
      return _SoftPulseTarget(
        active:
            widget.interactive &&
            widget.enabled &&
            next?.id == HandFamiliesDemo.families[i].id,
        child: HandExampleTile(
          example: HandFamiliesDemo.families[i],
          selected: _tapped.contains(HandFamiliesDemo.families[i].id),
          enabled: widget.interactive && widget.enabled,
          compact: true,
          onPressed:
              widget.interactive
                  ? () => _onTap(HandFamiliesDemo.families[i])
                  : null,
        ),
      );
    }

    final families = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < HandFamiliesDemo.families.length; i++) ...[
          if (i > 0) SizedBox(height: expandTeach ? 10 : 8),
          // Intrinsic card tiles — FittedBox parent scales when densified.
          familyAt(i),
        ],
      ],
    );
    // SoftPulse + Rex own the next-family cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Pairs · broadways · suited aces · connectors',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'Starting-hand families',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 12),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                // Pack densified families, then contain-scale into the felt —
                // fills tall-phone green (scaleDown left a void).
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: max(
                      MediaQuery.sizeOf(context).width - 48,
                      400,
                    ),
                    child: families,
                  ),
                ),
              ),
            )
            : families,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 12),
          cue,
        ],
      ],
    );
    final child = Container(
      key: const ValueKey('hand-families-felt'),
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.feltBorder.withValues(alpha: 0.85),
        ),
      ),
      child: body,
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Soft gold pulse around the next family tile.
class _SoftPulseTarget extends StatefulWidget {
  const _SoftPulseTarget({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_SoftPulseTarget> createState() => _SoftPulseTargetState();
}

class _SoftPulseTargetState extends State<_SoftPulseTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.active) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _SoftPulseTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.active && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = 0.4 + (_pulse.value * 0.55);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: glow * 0.65),
                blurRadius: 12 + (10 * _pulse.value),
                spreadRadius: 1 + (2 * _pulse.value),
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

