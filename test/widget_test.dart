import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('buildPokerTheme returns dark Material 3 theme', () {
    final theme = buildPokerTheme();
    expect(theme.brightness, Brightness.dark);
    expect(theme.useMaterial3, isTrue);
  });
}
