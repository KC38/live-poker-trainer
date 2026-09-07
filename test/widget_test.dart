import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/main.dart';

void main() {
  testWidgets('App boots with title text', (WidgetTester tester) async {
    await tester.pumpWidget(const PokerLabApp());
    expect(find.text('Exploitative Poker Lab'), findsOneWidget);
  });
}
