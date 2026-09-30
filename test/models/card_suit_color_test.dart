/// Suit ink follows a standard 2-color deck.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';

void main() {
  test('clubs and spades use black ink', () {
    expect(Suit.clubs.color, AppColors.spades);
    expect(Suit.spades.color, AppColors.spades);
    expect(AppColors.clubs, AppColors.spades);
  });

  test('hearts and diamonds use red ink', () {
    expect(Suit.hearts.color, AppColors.hearts);
    expect(Suit.diamonds.color, AppColors.hearts);
    expect(AppColors.diamonds, AppColors.hearts);
  });

  test('card codes inherit traditional suit colors', () {
    expect(CardModel.fromCode('As').suit.color, AppColors.spades);
    expect(CardModel.fromCode('7c').suit.color, AppColors.spades);
    expect(CardModel.fromCode('Kh').suit.color, AppColors.hearts);
    expect(CardModel.fromCode('Td').suit.color, AppColors.hearts);
  });
}
