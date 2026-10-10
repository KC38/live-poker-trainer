/// Locks the agent handbook, maintenance rule, and README entry point.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final handbookDir = Directory('docs/agents');
  final index = File('docs/agents/README.md').readAsStringSync();
  final rule =
      File('.cursor/rules/agent-docs-maintenance.mdc').readAsStringSync();
  final readme = File('README.md').readAsStringSync();

  test('agent handbook index links every section file', () {
    expect(index, contains('# Agent handbook'));
    expect(index, contains('## Read order (new agent)'));
    expect(index, contains('## Hard rules (never skip)'));
    expect(index, contains('agent-docs-maintenance.mdc'));

    for (final name in [
      '01-product-goal.md',
      '02-repo-map.md',
      '03-client.md',
      '04-course.md',
      '05-live-training.md',
      '06-ui-and-preferences.md',
      '07-reusable-components.md',
      '08-backend.md',
      '09-agent-workflow.md',
    ]) {
      expect(File('docs/agents/$name').existsSync(), isTrue, reason: name);
      expect(index, contains(name), reason: 'index links $name');
    }
  });

  test('handbook sections keep their primary headings', () {
    final expected = <String, List<String>>{
      '01-product-goal.md': [
        '# 01 — Product goal',
        '## Two product surfaces (do not merge)',
        '## Design north star',
      ],
      '02-repo-map.md': [
        '# 02 — Repo map',
        '## Flutter (`lib/`)',
        '## Backend (`functions/src/`)',
      ],
      '03-client.md': [
        '# 03 — Flutter client',
        '## Root routing',
        '## Settings preferences',
      ],
      '04-course.md': [
        '# 04 — Course system',
        '## Shared lesson frame (mandatory for new/edited steps)',
        '## Hearts economy',
      ],
      '05-live-training.md': [
        '# 05 — Live Training',
        '## Trust boundary (never violate)',
        '## Fixed actions (product preference)',
      ],
      '06-ui-and-preferences.md': [
        '# 06 — UI and preferences',
        '## Interaction preferences (owner)',
        'Teach by doing',
      ],
      '07-reusable-components.md': [
        '# 07 — Reusable components',
        'FeltTableView',
        'LessonScreenLayout',
      ],
      '08-backend.md': [
        '# 08 — Backend (Cloud Functions + Firestore)',
        '## Mental model',
        'GEMINI_API_KEY',
      ],
      '09-agent-workflow.md': [
        '# 09 — Working as an agent',
        '## Default change flow',
        '## Documentation duty',
      ],
    };

    for (final entry in expected.entries) {
      final body = File('docs/agents/${entry.key}').readAsStringSync();
      for (final needle in entry.value) {
        expect(body, contains(needle), reason: '${entry.key} → $needle');
      }
    }
  });

  test('maintenance rule always applies and names the handbook', () {
    expect(rule, contains('alwaysApply: true'));
    expect(rule, contains('docs/agents/README.md'));
    expect(rule, contains('Keep agent docs and comments current'));
    expect(rule, contains('What to update'));
    expect(rule, contains('07-reusable-components.md'));
  });

  test('root README points agents at the handbook', () {
    expect(readme, contains('docs/agents/README.md'));
    expect(readme, contains('agent-docs-maintenance.mdc'));
  });

  test('handbook directory has no unexpected top-level files', () {
    final names = handbookDir
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    expect(names, contains('README.md'));
    expect(names.length, greaterThanOrEqualTo(10));
  });
}
