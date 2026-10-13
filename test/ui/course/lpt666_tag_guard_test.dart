// LPT-666: ADVANTAGE SoftPulse must not trip TAG early-name contract.
// Proof lives in tools/course/validate_course.test.mjs (node --test).
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ADVANTAGE does not contain TAG as a word token (LPT-666)', () {
    final blob = 'ADVANTAGE';
    expect(RegExp(r'\bTAG\b').hasMatch(blob), isFalse);
    expect(blob.contains('TAG'), isTrue); // documents the old false positive
  });
}
