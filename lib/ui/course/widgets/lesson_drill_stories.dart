/// Drill stories by activity id — see [parseLessonDrillStory] for the format.
///
/// Every choice / number drill whose copy, hint, or answers describe a
/// situation plays that situation here. `lesson_scene_story_contract_test`
/// fails when copy names an action, street, board feature, size, seat, or
/// player type the story does not show, or restates a number the felt
/// already shows.
library;

import 'package:live_poker_trainer/ui/course/widgets/lesson_drill_story.dart';

/// Story lines, keyed by activity id.
const Map<String, String> lessonDrillStorySources = {
  'act-02-05-01-checkpoint-200': 'blinds 2/5 | stacks You=1000,*=1000 | pre:',
  'act-02-05-01-guided-convert': 'stacks You=200 | pre:',
  'act-02-05-01-scaffolded-eff': 'bb | stacks You=150,CO=60 | focus CO | pre:',
  'act-02-07-02-jump-stack': 'bb | stacks You=120,CO=55 | focus CO | pre:',
  'act-03-01-01-checkpoint':
      'bb | stacks You=140,BB=55 | pot 18 | live BB | focus BB | flop Kd7c2s:',
  'act-03-01-01-guided': 'hidepot | pre: UTG raise 6, You call, BB call',
  'act-03-03-01-scaffolded': 'hero BB | pot 20 | live BTN | focus BTN | flop Kd7c2s: You check, BTN bet 10',
  'act-03-07-01-checkpoint': 'focus CO | pre: CO limp',
  'act-03-08-02-jump-table':
      'bb | stacks You=40,BB=100 | pot 16 | live BB | focus BB | flop Qh8d3c:',
  'act-04-01-01-guided': 'focus UTG | pre: UTG raise 6',
  'act-04-01-01-scaffolded':
      'hero CO | focus BB | pre: You fold, BTN raise 5, BB 3bet 18, BTN call',
  'act-04-05-01-guided':
      'bb | stacks *=80 | pot 20 | live BB | focus BB | flop Ts6d2c:',
  'act-04-06-01-guided': 'focus HJ | pre: UTG raise 6, HJ call',
  'act-04-06-02-guided': 'focus BB | show BB 8h7h | pre: You raise 5, SB fold, BB call | flop Kd8c4h: BB check, You bet 6, BB call | turn 2s: BB check, You bet 15, BB call | river 9d: BB check, You bet 30, BB call',
  'act-04-06-02-unguided': 'focus CO | pre: CO limp, You raise 8, SB fold, BB fold, CO call | flop Qs9h4d: CO check, You bet 10, CO call | turn 2c: CO check, You bet 24, CO call',
  'act-04-06-03-checkpoint': 'type BB=station | focus BB | pre:',
  'act-04-07-01-checkpoint': 'focus UTG | pre: UTG raise 6',
  'act-04-07-01-guided': 'focus UTG | pre: UTG fold',
  'act-04-07-01-scaffolded': 'focus UTG | pre: UTG raise 6, You call, SB fold, BB fold | flop Kh9d4s: UTG bet 9, You call | turn 3c: UTG bet 22',
  'act-04-07-02-checkpoint': 'type UTG=nit | focus UTG | pre:',
  'act-04-07-02-guided': 'focus BB | pre: You raise 5, SB fold, BB 3bet 22',
  'act-04-07-02-unguided': 'focus BB | pre: You raise 5, SB fold, BB call | flop Jh7c3d: BB check, You bet 6, BB call | turn 2s: BB check, You bet 14, BB call | river 9c: BB check, You bet 30, BB raise 95',
  'act-04-07-03-checkpoint': 'type BB=nit | focus BB | pre: You raise 5, SB fold, BB call | flop Qd8s3h: BB check, You bet 6, BB raise 22',
  'act-04-08-01-checkpoint': 'focus CO | pre: CO raise 5',
  'act-04-08-01-guided': 'focus CO | pre: UTG raise 6, CO 3bet 20',
  'act-04-08-01-scaffolded': 'focus CO | show CO 9h7h | pre: CO raise 5, You call, SB fold, BB fold | flop Kc8d3s: CO bet 7, You call | turn 5h: CO bet 16, You call | river 2d: CO bet 35, You call',
  'act-04-08-02-guided': 'focus CO | pre: CO raise 5, You call, SB fold, BB fold | flop Qh7d2c: CO bet 7, You call | turn 4s: CO bet 16, You call | river 9h: CO bet 40',
  'act-04-08-02-unguided': 'focus BB | pre: You raise 5, SB fold, BB 3bet 18, You call | flop Td6s2h: BB bet 12, You call | turn 8c: BB bet 28, You call | river 3d: BB bet 60',
  'act-04-08-03-checkpoint': 'type CO=maniac | focus CO | pre: CO raise 8',
  'act-04-09-01-scaffolded': 'focus BB | pre: You raise 5, SB fold, BB call',
  'act-04-09-01-unguided': 'type BB=station | focus BB | pre: You raise 5, SB fold, BB call | flop 9c6d2h: BB check, You bet 6, BB fold',
  'act-04-10-02-jump-maniac': 'holes KsQd | type BB=maniac | focus BB | pre: You raise 5, SB fold, BB call | flop Kh7c3d: BB bet 8, You call | turn 2s: BB bet 20',
  'act-04-10-02-jump-nit': 'type BB=nit | focus BB | pre: You raise 5, SB fold, BB call | flop Kh8d4c: BB check, You bet 6, BB raise 30',
  'act-04-10-02-jump-range': 'focus UTG | pre: UTG raise 6',
  'act-04-10-02-jump-spr':
      'bb | stacks *=60 | pot 15 | live BB | focus BB | flop Kd8s3c:',
  'act-04-10-02-jump-station': 'type BB=station | focus BB | pre: You raise 5, SB fold, BB call | flop Jd8c4s: BB check, You bet 6, BB call | turn 2h: BB check, You bet 14, BB call | river 6c: BB check',
  'act-05-02-01-guided':
      'bb | stacks *=200 | holes 5s5d | focus CO | pre: CO raise 2.5',
  'act-05-05-01-checkpoint': 'focus BB | pre: You raise 5, SB fold, BB call | flop Kd7s2c: BB check, You check | turn 4h: BB check',
  'act-05-05-01-guided': 'type BB=nit | focus BB | pre: You raise 5, SB fold, BB call | flop Qs9d4h: BB check, You bet 6, BB raise 22',
  'act-05-05-01-unguided':
      'focus BB | pre: You raise 5, SB fold, BB call | flop Ah7c2d: BB bet 10',
  'act-05-06-01-checkpoint': 'focus BB | pre: You raise 5, SB fold, BB call | flop Ts7s3d: BB check, You bet 6, BB raise 20, You call | turn 2c: BB bet 30, You call | river Kd: BB allin 145',
  'act-05-06-01-guided': 'hero BB | focus BTN | pre: BTN raise 5, SB fold, You call | flop Jd8c3s: You check, BTN bet 7, You call | turn 2h: You check, BTN check',
  'act-05-07-01-guided': 'focus BB | pre: You raise 5, SB fold, BB call | flop 9h6c2d: BB check, You check | turn Js: BB check, You check | river 3c: BB check, You bet 8, BB allin 195',
  'act-05-07-01-scaffolded':
      'focus BB | pot 60 | live BB | flop Ks9h4d: BB bet 10',
  'act-05-08-01-guided': 'focus UTG | pre: UTG raise 8',
  'act-05-08-01-scaffolded': 'focus BB | pre: You raise 5, SB fold, BB call | flop Qc8h4s: BB check, You bet 6, BB call | turn 2d: BB check, You check | river 6s: BB bet 20',
  'act-05-09-02-cp-multi': 'pre: UTG raise 6, HJ call, You call, SB fold, BB call | flop 9s7s4d: BB check, UTG check, HJ check',
  'act-05-09-02-cp-tell': 'focus BB | pre: You raise 5, SB fold, BB call | flop Ts8d3c: BB check, You bet 6, BB allin 195',
  'act-06-01-01-guided':
      'focus BB | pre: You raise 5, SB fold, BB call | flop Ad7c2h: BB check',
  'act-06-01-01-scaffolded':
      'focus BB | pre: You raise 5, SB fold, BB call | flop 7d7c4h: BB check',
  'act-06-02-01-scaffolded': 'hero BB | holes 9h8h | focus BTN | pre: BTN raise 5, SB fold, You call | flop Kc9d4s: You check, BTN bet 6, You call | turn 2h: You check, BTN bet 15',
  'act-06-02-01-unguided': 'hero BB | holes AsTs | focus BTN | pre: BTN raise 5, SB fold, You call | flop Ks8s3d: You check, BTN bet 6, You raise 22',
  'act-06-03-01-guided': 'hero BB | focus BTN | pre: BTN raise 5, SB fold, You call | flop Qh9c4d: You check, BTN bet 7, You call | turn 2s: You check, BTN check',
  'act-06-03-01-unguided': 'focus BB | pre: You raise 5, SB fold, BB call | flop Jh8h2c: BB check, You bet 6, BB raise 22, You call | turn 5d: BB bet 35, You call | river Ac: BB allin 138',
  'act-06-04-01-guided': 'focus BB | pre: You raise 5, SB fold, BB call | flop Kd8c4s: BB check, You check | turn 2h: BB check, You check | river 7d: BB bet 18',
  'act-06-05-01-guided': 'pre: You raise 5, SB fold, BB call | flop Qc8d5h: BB check, You bet 6, BB call | turn 2s: BB check, You check | river Kh: BB check',
  'act-06-06-01-scaffolded': 'focus BB | pre: You raise 5, SB fold, BB call | flop Qh9h3c: BB check, You bet 6, BB call | turn 5d: BB check, You check | river 2h: BB bet 30',
  'act-06-07-01-guided': 'focus BB | pre: You raise 5, SB fold, BB call | flop Js8d4c: BB check, You bet 6, BB call | turn 2s: BB check, You check | river 9h: BB bet 15',
  'act-06-08-01-scaffolded': 'type BB=station | focus BB | pre:',
  'act-06-09-01-checkpoint': 'bb | focus BB | pre: You raise 2.5, SB fold, BB 3bet 11, You call | flop Qd7c2s: BB check',
  'act-06-09-01-guided': 'bb | holes AhKc | focus BB | pre: You raise 2.5, SB fold, BB 3bet 11, You 4bet 24, BB call | flop Kd8s3c: BB check',
  'act-06-09-01-unguided': 'focus BB | pre: You raise 5, SB fold, BB 3bet 18',
  'act-06-11-01-guided': 'focus BB | pre: You raise 5, SB fold, BB 3bet 18, You call | flop Kh7d2c: BB bet 12',
  'act-06-11-01-scaffolded': 'focus CO | pre: CO raise 5, You call, SB fold, BB fold | flop Qs8d3h: CO bet 7, You call | turn 2c: CO check',
  'act-06-11-02-checkpoint': 'type CO=tag | focus CO | pre:',
  'act-06-11-02-guided': 'focus BB | pre: You raise 5, SB fold, BB 3bet 18',
  'act-06-11-02-scaffolded': 'type CO=tag,BB=maniac | pre:',
  'act-06-11-02-unguided': 'focus CO | pre: CO raise 5, You call, SB fold, BB fold | flop Ks7d3c: CO bet 6',
  'act-06-11-03-checkpoint': 'type CO=tag | focus CO | pre: CO raise 5',
  'act-06-12-01-guided': 'focus CO | pre: CO raise 5, You call, SB fold, BB fold | flop 9d6c2s: CO bet 7, You call | turn Kh: CO bet 16',
  'act-06-12-01-scaffolded': 'type BB=maniac | focus CO | pre: CO raise 5',
  'act-06-12-01-unguided': 'focus HJ | pre: HJ raise 5',
  'act-06-12-02-checkpoint': 'type CO=lag | focus CO | pre:',
  'act-06-12-02-guided': 'focus CO | pre: CO raise 5, You call, SB fold, BB fold | flop 8h5c2d: CO bet 7, You call | turn Js: CO bet 16',
  'act-06-12-02-scaffolded':
      'type CO=lag,BB=station | pre: CO raise 5, You call, SB fold, BB call',
  'act-06-12-02-unguided': 'focus CO | pre: CO raise 5, You call, SB fold, BB fold | flop 7c4d3h: CO bet 7, You call | turn Qd: CO bet 16',
  'act-06-12-03-checkpoint': 'type CO=lag | focus CO | pre: CO raise 5',
  'act-06-12-03-unguided':
      'type BB=lag | focus BB | pre: You raise 5, SB fold, BB call',
  'act-06-13-01-checkpoint': 'focus CO | pre: CO raise 5, You call, SB fold, BB fold | flop Kd9h4c: CO bet 7, You call | turn 2s: CO bet 17',
  'act-06-13-02-cp-adv': 'hero BB | focus CO | pre: CO raise 5, BTN fold, SB fold, You call | flop Ac8d3s: You check',
  'act-06-13-02-cp-cap': 'hero BB | focus BTN | pre: BTN raise 5, SB fold, You call | flop Kc7h3d: You check, BTN bet 6, You call | turn 9s: You check, BTN check | river 2c:',
  'act-06-13-02-cp-polar': 'focus BB | pre: You raise 5, SB fold, BB call | flop Jc7d3h: BB check, You check | turn 4s: BB check, You check | river Qd: BB bet 20',
  'act-06-13-02-cp-tag': 'focus CO | pre: CO raise 5, You call, SB fold, BB fold | flop Ah9c5d: CO bet 7, You call | turn 3s: CO bet 17',
  'act-07-01-01-guided': 'holes AdQc | focus CO | pre: CO raise 5, You 3bet 16, SB fold, BB fold, CO call | flop 8h7h2c: CO check',
  'act-07-01-01-scaffolded': 'holes KdTc | focus BB | pre: You raise 5, SB fold, BB call | flop KsTd2h: BB check',
  'act-07-02-01-checkpoint': 'pre: You raise 5, SB fold, BB call | flop Qd8c3h: BB check, You bet 6, BB call | turn 2s: BB check',
  'act-07-02-01-unguided':
      'pre: You raise 5, SB fold, BB call | flop 9c7d3s: BB check',
  'act-07-03-01-checkpoint': 'pre: You raise 5, SB fold, BB call | flop Th6c3d: BB check, You bet 6, BB call | turn 4h: BB check, You check | river 8s: BB check',
  'act-07-03-01-unguided': 'holes 6h5h | pre: You raise 5, SB fold, BB call | flop KdQc8s: BB check, You check | turn 2d: BB check, You check | river Jc: BB check',
  'act-07-04-01-guided': 'pre: UTG limp, HJ limp, You limp, SB call, BB check | flop 9h7c4d: SB check, BB check, UTG check, HJ check',
  'act-07-04-01-scaffolded':
      'focus BB | pre: You raise 5, SB fold, BB call | flop Ks8d4h: BB check',
  'act-07-04-01-unguided': 'bb | focus BB | pre: You raise 2.5, SB fold, BB 3bet 11, You 4bet 24, BB call | flop Qs7d2c: BB check',
  'act-07-05-01-guided': 'pre: UTG raise 6, HJ call, You call, SB fold, BB call | flop Kh9d4c: BB check, UTG check, HJ check, You check | turn 7s: BB check, UTG check, HJ check, You check | river 2d: BB check, UTG check, HJ check',
  'act-07-05-01-scaffolded':
      'type BB=nit | focus BB | pre: You raise 5, SB fold',
  'act-07-06-01-guided': 'bb | stacks *=35 | holes AhKd | focus BB | pre: You raise 2.5, SB fold, BB call | flop Ks9c4d: BB check',
  'act-07-06-01-scaffolded':
      'bb | stacks *=250 | holes 5c5d | focus CO | pre: CO raise 3',
  'act-07-06-01-unguided': 'bb | stacks You=200,CO=40 | focus CO | pre:',
  'act-07-09-01-scaffolded': 'focus BB | pre: You raise 5, SB fold',
  'act-07-12-01-cs': 'type BB=station | focus BB | pre: You raise 5, SB fold, BB call | flop Td7c3s: BB check, You bet 6, BB call | turn 2h: BB check, You bet 14, BB call | river 5c: BB check',
  'act-07-12-01-lag': 'type CO=lag | focus CO | pre: CO raise 5, You call, SB fold, BB fold | flop 8c6d2h: CO bet 6, You call | turn Kd: CO bet 16',
  'act-07-12-01-maniac': 'type BB=maniac | focus BB | pre: You raise 5, SB fold, BB call | flop 9s6h2c: BB bet 8, You call | turn Qd: BB bet 20, You call | river 3h: BB bet 45',
  'act-07-12-01-nit': 'type BB=nit | focus BB | pre: You raise 5, SB fold, BB call | flop Kc8h4d: BB check, You bet 6, BB raise 30',
  'act-07-12-01-retire': 'type BB=station | focus BB | pre: You raise 5, SB fold, BB 3bet 18, You call | flop Jh9c4d: BB bet 12, You call | turn 2s: BB check, You check | river 7c: BB check, You bet 30, BB fold',
  'act-07-12-01-tag': 'type CO=tag | focus CO | pre: CO raise 5, You call, SB fold, BB fold | flop Kh8d3s: CO bet 6, You call | turn 2c: CO bet 15',
};

final Map<String, LessonDrillStory> _parsed = {};

/// Parsed story for [activityId], or null when the drill has none.
LessonDrillStory? lessonDrillStoryFor(String activityId) {
  final source = lessonDrillStorySources[activityId];
  if (source == null) return null;
  return _parsed[activityId] ??= parseLessonDrillStory(source);
}
