/// Locks the make-change skill contract: analyze/tests during implement,
/// simulator refresh only after a successful primary pull.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('make-change skill defers simulator refresh until after primary pull', () {
    final skill =
        File('.cursor/skills/make-change/SKILL.md').readAsStringSync();

    expect(skill, contains('### 2. Implement and verify'));
    expect(
      skill,
      contains(
        'Do not boot simulators, take screenshots, drive the UI, or call '
        '`simulator-refresh` during implement/verify.',
      ),
    );
    expect(
      skill,
      contains(
        'Verification in this step is analyze and tests only.',
      ),
    );
    expect(skill, contains(r'PRIMARY="$(tools/primary_checkout.sh)"'));
    expect(skill, contains('### 8. Deploy Cloud Functions (always)'));
    expect(
      skill,
      contains(
        '### 9. Refresh the iPhone 13 mini (successful primary pull only)',
      ),
    );
    expect(
      skill,
      contains(
        '.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh',
      ),
    );
    expect(skill, contains('#### When the primary pull fails'));
    expect(skill, contains('Skip step 9'));
    expect(skill, contains('Do **not** reset, stash,'));

    expect(skill, isNot(contains('agent_tap.py')));
    expect(skill, isNot(contains('xcrun simctl io')));
    expect(skill, isNot(contains('kill -USR2')));
    expect(skill, isNot(contains('flutter run -d')));
    expect(skill, isNot(contains('Validate on the iPhone 17')));
    expect(skill, isNot(contains('iphone17-main')));
    expect(skill, isNot(contains('F1AE4938')));
    expect(skill, isNot(contains('20ACECD5')));
  });

  test('primary_checkout resolves an existing home checkout', () {
    final result = Process.runSync(
      'bash',
      ['tools/primary_checkout.sh'],
      workingDirectory: Directory.current.path,
    );
    expect(result.exitCode, 0, reason: result.stderr.toString());
    final path = result.stdout.toString().trim();
    expect(path, isNotEmpty);
    expect(File('$path/pubspec.yaml').existsSync(), isTrue);
  });
}
