/// Locks the UI design record and the command/skills that cite it.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('design record keeps the table, theme, and asset contract', () {
    final text = File('docs/ui/design-record.md').readAsStringSync();
    expect(text, contains('## How a change is recorded'));
    expect(
      text,
      contains(
        'A layout change that can overflow at phone width names the Lesson tables sentence it will write, and the same change includes a widget test that fails on overflow.',
      ),
    );
    expect(
      text,
      contains(
        'Scaling the row down with `FittedBox` is not a substitute for that rule.',
      ),
    );
    expect(text, contains('Button and blinds (LPT-36)'));
    expect(text, contains('## Theme'));
    expect(text, contains('## Poker table'));
    expect(text, contains('## Lesson tables'));
    expect(
      text,
      contains(
        'A phase column on a teaching felt stacks its playing cards vertically. A horizontal row of `MiniCard` or `CardBack` widgets is not used inside an `Expanded` phase column.',
      ),
    );
    expect(text, contains('## Asset inventory'));
    expect(text, contains('FeltTableView'));
    expect(text, contains('HeroRailWidget'));
    expect(text, contains('CoachShelfWidget'));
    expect(text, contains('ActionDockWidget'));
    expect(text, contains('LessonActionSpot'));
    expect(text, contains('LessonTableScene'));
    expect(text, contains('assets/brand/logo_mark.svg'));
    expect(
      text,
      contains(
        'The Live Training hub shows `assets/brand/logo_mark.svg` above the lock or the table entry.',
      ),
    );
    expect(text, contains('lounge_ambient.wav'));
    expect(text, contains('## Lesson screen layout'));
    expect(text, contains('## Gamified learning'));
    expect(
      text,
      contains(
        'A right answer shows the same coach in a celebrating mood beside the short line. The calm drawing and the celebrating drawing are the same coach. The Asset inventory celebrate row uses that same coach.',
      ),
    );
    expect(
      text,
      contains(
        'the same coach, celebrating mood, the same coach as the calm drawing',
      ),
    );
    expect(
      text,
      contains(
        'The locked Live Training hub names the Home lesson that unlocks it. It does not say Section 2.',
      ),
    );
    expect(text, contains('duolingo-chess/PATTERNS.md'));
  });

  test('implement-open-jira command cites the design record and overflow rule', () {
    final command =
        File('.cursor/commands/implement-open-jira.md').readAsStringSync();
    expect(command, contains('docs/ui/design-record.md'));
    expect(command, contains('flutter-ui-ux'));
    expect(command, contains('fails on overflow'));
    expect(command, contains('Button and blinds (LPT-36)'));
    expect(command, contains('lesson-screen-layout.mdc'));
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
