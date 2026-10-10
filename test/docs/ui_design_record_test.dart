/// Locks the UI design record, the UI design agent, and the simulator lock.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final record = File('docs/ui/design-record.md').readAsStringSync();

  test('design record keeps the stakeholder brief and the contract sections', () {
    for (final heading in [
      '## What the stakeholders are asking for',
      '### Rejected on purpose',
      '## How a change is recorded',
      '## Surfaces',
      '## Theme',
      '## Poker table',
      '### The deal',
      '## Lesson screen layout',
      '### Cues',
      '## Lesson tables',
      '### Lesson content',
      '## Home',
      '## Gamified learning',
      '## Asset inventory',
      '## Known gaps',
      '## Lesson ledger',
    ]) {
      expect(record, contains(heading), reason: heading);
    }
    expect(record, contains('iPhone 13 mini'));
    expect(record, contains('Teach by doing.'));
    expect(record, contains('duolingo-chess/PATTERNS.md'));
    expect(record, contains('/ui-design-agent'));
    expect(record, isNot(contains('/implement-open-jira')));
  });

  test('design record keeps the table, theme, and asset contract', () {
    expect(
      record,
      contains(
        'A layout change that can overflow at phone width names the Lesson tables sentence it will write, and the same change includes a widget test that fails on overflow.',
      ),
    );
    expect(
      record,
      contains(
        'Scaling the row down with `FittedBox` is not a substitute for that rule.',
      ),
    );
    expect(record, contains('Button and blinds (LPT-36)'));
    expect(
      record,
      contains(
        'Playing cards use one face everywhere: `TableCard` (corner rank, one centered suit). `MiniCard` and `CardBack` are size presets over `TableCard` / `TableCardBack` for densified lesson trays — they must not invent a second face.',
      ),
    );
    expect(
      record,
      contains(
        'A phase column on a teaching felt stacks its playing cards vertically. A horizontal row of `MiniCard` or `CardBack` widgets is not used inside an `Expanded` phase column.',
      ),
    );
    for (final name in [
      'FeltTableView',
      'HeroRailWidget',
      'CoachShelfWidget',
      'ActionDockWidget',
      'LessonActionSpot',
      'LessonTableScene',
      'GlowHighlight',
      'CardDealPace',
      'assets/brand/logo_mark.svg',
      'lounge_ambient.wav',
    ]) {
      expect(record, contains(name), reason: name);
    }
    expect(
      record,
      contains(
        'The Live Training hub shows `assets/brand/logo_mark.svg` above the lock or the table entry.',
      ),
    );
    expect(
      record,
      contains(
        'A right answer shows the same coach in a celebrating mood beside the short line. The calm drawing and the celebrating drawing are the same coach. The Asset inventory celebrate row uses that same coach.',
      ),
    );
    expect(
      record,
      contains(
        'the same coach, celebrating mood, the same coach as the calm drawing',
      ),
    );
    expect(
      record,
      contains(
        'The locked Live Training hub names the Home lesson that unlocks it. It does not say Section 2.',
      ),
    );
  });

  test('design record does not bring back what stakeholders removed', () {
    expect(record, isNot(contains('`CueArrows` in')));
    expect(record, isNot(contains('Rex stands on the marked next-lesson node')));
    expect(record, isNot(contains('START chip and Rex on it')));
  });

  test('lesson ledger names each lesson once with its explain taps', () {
    expect(
      record,
      contains('| Meet the TAG | Tight, Aggro, Model | label quizzes |'),
    );
    expect(
      record,
      contains('| Adjust versus TAG | Credit, Tighter, No light | respect check |'),
    );
    final ledger = record.substring(record.indexOf('## Lesson ledger'));
    final rows = RegExp(r'^\| ([^|]+) \|', multiLine: true)
        .allMatches(ledger)
        .map((m) => m.group(1)!.trim())
        .where((name) => name != 'Lesson' && !name.startsWith('---'))
        .toList();
    expect(rows.length, greaterThan(80));
    expect(rows.toSet().length, rows.length, reason: 'duplicate ledger rows');
  });

  test('ui-design-agent command holds the lock and ships one ticket per run', () {
    expect(File('.cursor/commands/implement-open-jira.md').existsSync(), isFalse);
    final command =
        File('.cursor/commands/ui-design-agent.md').readAsStringSync();
    final learnings =
        File('.cursor/commands/ui-design-agent-learnings.md').readAsStringSync();
    for (final needle in [
      'docs/ui/design-record.md',
      'ui-design-agent-learnings.md',
      'PATTERNS.md',
      'flutter-ui-ux',
      'lesson-screen-layout.mdc',
      'make-change',
      'tools/sim_lock.py claim --owner ui-design-agent',
      'SIM_BUSY',
      'SIM_NOT_READY',
      'python3 tools/sim_lock.py release',
      'labels = ui-agent',
      'python3 tools/jira.py check',
      'JIRA_UNAVAILABLE',
      'needs-human',
      'Changes requested (attempt N)',
      'Stop after three failed attempts.',
      'Validate before closing',
      'ui-agent-coverage.jsonl',
      'tools/iphone_13_mini_udid.sh',
      'Never launch a',
      'Update learnings before you leave',
      'go to step 10 with result',
      'sim-not-ready',
      'learnings: unchanged',
      'Lesson content',
      'Card randomization',
      'Hints (one at a time)',
      'Cues (one target, one system)',
      'Coach text and mood',
      'Hearts (lose and restore)',
      'SoftPulse',
      'exactly one',
      'At most **one** gold SoftPulse',
      'Screenshots — current issue',
      '-issue.png',
      '-validated.png',
      'Required validated proof',
      'Never transition to Done if the close comment lacks a validated',
    ]) {
      expect(command, contains(needle), reason: needle);
    }
    for (final needle in [
      '## How to update (step 10)',
      '## Never again',
      '## Prefer',
      '## Ops (simulator, CLI, Jira)',
      '## Product judgment',
      '## Recent run notes',
      'at most **40** bullets',
      'python3 tools/jira.py',
      'SIM_NOT_READY',
      'card randomization',
      'SoftPulse',
      'heart count',
      'multiturn',
      '-validated.png',
      'current-issue screenshot',
    ]) {
      expect(learnings, contains(needle), reason: needle);
    }
    expect(record, contains('### Lesson content'));
    expect(record, contains('Lesson content regressions'));
    expect(record, contains('Hint (one at a time)'));
    expect(record, contains('Cues (one system, one gold)'));
    expect(record, contains('At most one gold SoftPulse target'));
    expect(
      record,
      contains('including a multi-press / multi-turn step after the last'),
    );
    expect(
      File('.cursor/skills/new-user-qa/SKILL.md').existsSync(),
      isFalse,
    );
    expect(
      File('.cursor/skills/ui-consistency-qa/SKILL.md').existsSync(),
      isFalse,
    );
    expect(
      File('docs/ui/references/duolingo-chess/frames/001.png').existsSync(),
      isTrue,
    );
    expect(
      File('docs/ui/references/duolingo-chess/frames/130.png').existsSync(),
      isTrue,
    );
  });

  test('simulator lock rule applies to every agent', () {
    final rule =
        File('.cursor/rules/simulator-lock.mdc').readAsStringSync();
    expect(rule, contains('alwaysApply: true'));
    expect(rule, contains('Busy means stop.'));
    expect(rule, contains('python3 tools/sim_lock.py claim'));
    expect(rule, contains('python3 tools/sim_lock.py release'));
    final refresh = File(
      '.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh',
    ).readAsStringSync();
    expect(refresh, contains('tools/sim_lock.py'));
    expect(File('tools/sim_lock.py').existsSync(), isTrue);
    expect(File('tools/ui_design_agent_loop.sh').existsSync(), isTrue);
  });

  test('Flutter UI skill keeps the composition and motion rules', () {
    final skill =
        File('.cursor/skills/flutter-ui-ux/SKILL.md').readAsStringSync();
    expect(skill, contains('Widget Composition'));
    expect(skill, contains('AnimatedBuilder'));
    expect(skill, contains('references/widget-patterns.md'));
    expect(skill, contains('references/animation-patterns.md'));
    expect(skill, contains('references/theme-templates.md'));
    expect(skill, contains('references/performance-optimization.md'));
    for (final name in [
      'widget-patterns.md',
      'animation-patterns.md',
      'theme-templates.md',
      'performance-optimization.md',
    ]) {
      expect(
        File('.cursor/skills/flutter-ui-ux/references/$name').existsSync(),
        isTrue,
        reason: name,
      );
    }
  });
}
