/// Locks the UI design record and the skills that cite it.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('design record keeps the table, theme, and asset contract', () {
    final text = File('docs/ui/design-record.md').readAsStringSync();
    expect(text, contains('## How a change is recorded'));
    expect(text, contains('## Theme'));
    expect(text, contains('## Poker table'));
    expect(text, contains('## Lesson tables'));
    expect(text, contains('## Asset inventory'));
    expect(text, contains('FeltTableView'));
    expect(text, contains('HeroRailWidget'));
    expect(text, contains('CoachShelfWidget'));
    expect(text, contains('ActionDockWidget'));
    expect(text, contains('LessonActionSpot'));
    expect(text, contains('LessonTableScene'));
    expect(text, contains('assets/brand/logo_mark.png'));
    expect(
      text,
      contains(
        'The Live Training hub shows `assets/brand/logo_mark.png` above the lock or the table entry.',
      ),
    );
    expect(text, contains('lounge_ambient.mp3'));
    expect(text, contains('## Gamified learning'));
    expect(
      text,
      contains(
        'A right answer shows Rex’s own face in a celebrating mood beside the short line. The calm portrait and the celebrating portrait are the same coach. The Asset inventory celebrate row uses that same face.',
      ),
    );
    expect(
      text,
      contains(
        'Rex’s own face, celebrating mood, the same coach as the calm portrait',
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

  test('ui walk cites the design record and the Flutter UI skill', () {
    final skill =
        File('.cursor/skills/ui-consistency-qa/SKILL.md').readAsStringSync();
    expect(skill, contains('docs/ui/design-record.md'));
    expect(skill, contains('flutter-ui-ux'));
    expect(skill, contains('7CB7DDCF-CBEA-414F-8A92-D490C7AAE35F'));
    expect(skill, contains('## Design record'));
    expect(skill, contains('duolingo-chess/PATTERNS.md'));
    expect(skill, contains('**Game loop.**'));
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
