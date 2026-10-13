/// Turn-map scaffolded deals a true gutshot that bricked (LPT-394).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';

int _enc(String code) => FastEvaluator.encode(CardModel.fromCode(code));

int _outs(List<String> hero, List<String> board) => HandClassifier.drawOuts(
  _enc(hero[0]),
  _enc(hero[1]),
  [for (final c in board) _enc(c)],
);

HandClass _class(List<String> hero, List<String> board) =>
    HandClassifier.classify(_enc(hero[0]), _enc(hero[1]), [
      for (final c in board) _enc(c),
    ]);

void main() {
  final activity = CourseActivity(
    id: 'act-07-02-01-scaffolded',
    order: 3,
    stage: ActivityStage.scaffolded,
    renderer: ActivityRenderer.selectIdentify,
    estimatedSeconds: 45,
    accessibilityText: 'Give up the gutshot when the brick turn is raised.',
    acceptedGrades: const [SoftGrade.recommended],
    prompt: 'You c-bet a gutshot. Turn bricks and they raise big. Map says?',
  );

  test('turn-map template is a true four-out gutshot (LPT-394)', () {
    final scene = resolveLessonTableScene(activity)!;
    expect(scene.heroCodes, ['Jh', '9d']);
    expect(scene.boardCodes, ['Ks', 'Tc', '2d', '3s']);
    expect(_outs(scene.heroCodes, scene.boardCodes), DrawOuts.weak);
    expect(_class(scene.heroCodes, scene.boardCodes), HandClass.weakDraw);
    expect(scene.caption, 'Gutshot · brick · raise');
  });

  test('turn-map remaps keep the gutshot (never air) (LPT-394)', () {
    for (var generation = 0; generation < 64; generation++) {
      final scene = dealtLessonTableScene(activity, generation: generation)!;
      expect(
        _outs(scene.heroCodes, scene.boardCodes),
        DrawOuts.weak,
        reason:
            'generation $generation must stay gutshot (4 outs): '
            '${scene.heroCodes} on ${scene.boardCodes}',
      );
      expect(
        _class(scene.heroCodes, scene.boardCodes),
        HandClass.weakDraw,
        reason:
            'generation $generation weakDraw: '
            '${scene.heroCodes} on ${scene.boardCodes}',
      );
    }
  });
}
