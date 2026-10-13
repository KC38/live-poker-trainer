/**
 * Gap-scanner contracts the content agent uses every pass.
 *
 * Brace depth must keep switch arms that follow an inner block, and must
 * not pull arms from the next function. Gap filters decide which catalog
 * parents get a checklist row.
 */

import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import {dirname, resolve} from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

import {
  DENSIFY_HELPER_IDS,
  GUIDED_PULSE_TARGET_IDS,
  braceMatchedBody,
  gapDealVariants,
  gapExplainCues,
  gapNiceLadder,
  gapPressHints,
  gapTeachSpec,
  gapUnguidedSoftpulseMap,
  hasSoftPulseCue,
  scanAll,
  switchArmActivityIds,
  toMarkdown,
} from "./scan_content_gaps.mjs";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const SCANNER = resolve(ROOT, "tools/course/scan_content_gaps.mjs");

const NESTED_SWITCH = `
void ignore() {
  'act-before' => 'no',
}
String? selectIdentifyDensifiedCoachLine(String id) {
  if (false) { return null; }
  return switch (id) {
    'act-after-inner' => 'yes',
    'act-after-inner' => 'dup',
    'act-spaced'=> 'yes',
    'act-mention': 'colon',
    "act-double" => 'quotes',
  };
}
String? later() {
  'act-after-close' => 'no',
}
`;

test("brace-matched switch keeps arms after an inner block", () => {
  const ids = switchArmActivityIds(
    NESTED_SWITCH,
    "selectIdentifyDensifiedCoachLine",
  );
  assert.deepEqual([...ids].sort(), ["act-after-inner", "act-spaced"]);
  assert.equal(
    braceMatchedBody("selectIdentifyDensifiedCoachLine", "missing"),
    null,
  );
  assert.equal(
    braceMatchedBody("selectIdentifyDensifiedCoachLine = 1;", "selectIdentifyDensifiedCoachLine"),
    null,
  );
  assert.equal(
    switchArmActivityIds(
      "selectIdentifyDensifiedCoachLine() { 'act-open' => 'x',",
      "selectIdentifyDensifiedCoachLine",
    ).size,
    0,
  );
});

test("live Dart maps include deep arms and stop at the function close", () => {
  assert.ok(DENSIFY_HELPER_IDS.has("act-02-07-02-jump-family"));
  assert.ok(DENSIFY_HELPER_IDS.has("act-06-10-01-checkpoint"));
  assert.ok(GUIDED_PULSE_TARGET_IDS.has("act-01-03-01-guided-fold"));
  assert.equal(GUIDED_PULSE_TARGET_IDS.has("act-04-10-01-unguided"), true);
  // Next function in the same file. A match that runs past the close
  // would count this felt-first coach arm as a SoftPulse map arm.
  assert.equal(GUIDED_PULSE_TARGET_IDS.has("act-01-03-01-unguided-call"), false);
  assert.ok(DENSIFY_HELPER_IDS.size > 0);
  assert.ok(GUIDED_PULSE_TARGET_IDS.size > 0);
});

test("pressHints skips no-hint, roles, and steps that already have a hint", () => {
  const lesson = ["lesson-x", "X"];
  assert.equal(
    gapPressHints(...lesson, {
      id: "act-gap",
      stage: "guided",
      renderer: "select_identify",
    }),
    null,
  );
  assert.equal(
    gapPressHints(...lesson, {
      id: "act-role",
      stage: "scaffolded",
      renderer: "select_identify",
      assessmentRole: "checkpoint",
    }),
    null,
  );
  assert.equal(
    gapPressHints(...lesson, {
      id: "act-07-10-01-hand",
      stage: "scaffolded",
      renderer: "full_table_hand_lab",
    }),
    null,
  );
  assert.equal(
    gapPressHints(...lesson, {
      id: "act-text",
      stage: "scaffolded",
      renderer: "coach_dialogue",
    }),
    null,
  );
  const fixedDialogue = gapPressHints(...lesson, {
    id: "act-fixed-dialogue",
    stage: "scaffolded",
    renderer: "coach_dialogue",
    teachSpec: {deal: {mode: "fixed"}},
  });
  assert.equal(fixedDialogue && fixedDialogue.note, "pressHints missing or empty");
  assert.equal(
    gapPressHints(...lesson, {
      id: "act-empty",
      stage: "scaffolded",
      renderer: "select_identify",
      teachSpec: {pressHints: []},
    }).note,
    "pressHints missing or empty",
  );
  assert.equal(
    gapPressHints(...lesson, {
      id: "act-bad",
      stage: "scaffolded",
      renderer: "select_identify",
      teachSpec: {pressHints: "tap"},
    }).activityId,
    "act-bad",
  );
  assert.equal(
    gapPressHints(...lesson, {
      id: "act-ok",
      stage: "scaffolded",
      renderer: "select_identify",
      teachSpec: {pressHints: ["one"]},
    }),
    null,
  );
});

test("deal variants flag only a fixed deal with no variant list", () => {
  const lesson = ["lesson-x", "X"];
  const base = {id: "act-deal", renderer: "select_identify", stage: "guided"};
  assert.equal(gapDealVariants(...lesson, base), null);
  assert.equal(
    gapDealVariants(...lesson, {...base, teachSpec: {deal: {mode: "none"}}}),
    null,
  );
  assert.equal(
    gapDealVariants(...lesson, {
      ...base,
      teachSpec: {deal: {mode: "random_in_class"}},
    }),
    null,
  );
  assert.equal(
    gapDealVariants(...lesson, {
      ...base,
      teachSpec: {deal: {mode: "fixed", variants: [{id: "a"}]}},
    }),
    null,
  );
  for (const deal of [{mode: "fixed"}, {mode: "fixed", variants: "one"}]) {
    const row = gapDealVariants(...lesson, {...base, teachSpec: {deal}});
    assert.equal(row.note, "fixed deal with no deal.variants");
  }
});

test("teachSpec gap is interactive steps with no object teachSpec", () => {
  const lesson = ["lesson-x", "X"];
  assert.equal(
    gapTeachSpec(...lesson, {id: "act-text", renderer: "prose", stage: "guided"}),
    null,
  );
  assert.equal(
    gapTeachSpec(...lesson, {
      id: "act-ok",
      renderer: "order_sequence",
      stage: "guided",
      teachSpec: {deal: {mode: "none"}},
    }),
    null,
  );
  for (const teachSpec of [undefined, null, "notes"]) {
    const row = gapTeachSpec(...lesson, {
      id: "act-miss",
      renderer: "order_sequence",
      stage: "guided",
      teachSpec,
    });
    assert.equal(row.note, "interactive step missing teachSpec");
  }
});

test("explain cues and Nice! ladder follow SoftPulse shape", () => {
  const lesson = ["lesson-x", "X"];
  assert.equal(hasSoftPulseCue(null), false);
  assert.equal(hasSoftPulseCue(1), false);
  assert.equal(hasSoftPulseCue("soft_pulse"), false);
  assert.equal(hasSoftPulseCue({kind: "label"}), false);
  assert.equal(
    hasSoftPulseCue({cues: [{parts: [{kind: "soft_pulse"}]}]}),
    true,
  );
  assert.equal(
    gapExplainCues(...lesson, {
      id: "act-other",
      renderer: "select_identify",
      stage: "guided",
    }),
    null,
  );
  assert.equal(
    gapExplainCues(...lesson, {
      id: "act-scaf",
      renderer: "coach_dialogue",
      stage: "scaffolded",
    }),
    null,
  );
  assert.equal(
    gapExplainCues(...lesson, {
      id: "act-missing",
      renderer: "coach_dialogue",
      stage: "guided",
    }).note,
    "guided coach_dialogue missing teachSpec/cues",
  );
  assert.equal(
    gapExplainCues(...lesson, {
      id: "act-empty",
      renderer: "coach_dialogue",
      stage: "guided",
      teachSpec: {cues: []},
    }).note,
    "guided coach_dialogue teachSpec.cues empty",
  );
  assert.equal(
    gapExplainCues(...lesson, {
      id: "act-cued",
      renderer: "coach_dialogue",
      stage: "guided",
      teachSpec: {cues: [{kind: "soft_pulse"}]},
    }),
    null,
  );
  assert.equal(
    gapNiceLadder(...lesson, {
      id: "act-plain",
      renderer: "coach_dialogue",
      stage: "guided",
      teachSpec: {cues: [{kind: "label"}]},
    }),
    null,
  );
  const ladder = gapNiceLadder(...lesson, {
    id: "act-nice",
    renderer: "coach_dialogue",
    stage: "guided",
    teachSpec: {cues: [{parts: [{kind: "soft_pulse"}]}]},
  });
  assert.match(ladder.note, /Nice! ladder/);
  assert.equal(
    gapNiceLadder(...lesson, {
      id: "act-graded",
      renderer: "coach_dialogue",
      stage: "guided",
      explainGrading: {pass: "Nice!"},
      teachSpec: {kind: "soft_pulse"},
    }),
    null,
  );
});

test("unguided SoftPulse map ignores mapped arms and other renderers", () => {
  const lesson = ["lesson-x", "X"];
  assert.equal(
    gapUnguidedSoftpulseMap(...lesson, {
      id: "act-99-00-00-unguided",
      renderer: "select_identify",
      stage: "scaffolded",
    }),
    null,
  );
  assert.equal(
    gapUnguidedSoftpulseMap(...lesson, {
      id: "act-01-03-01-guided-fold",
      renderer: "poker_action_sizing",
      stage: "guided",
    }),
    null,
  );
  assert.equal(
    gapUnguidedSoftpulseMap(...lesson, {
      id: "act-04-10-01-unguided",
      renderer: "poker_action_sizing",
      stage: "scaffolded",
    }),
    null,
  );
  for (const id of ["act-99-00-00-unguided", "act-99-00-00-scaffolded-qq"]) {
    const row = gapUnguidedSoftpulseMap(...lesson, {
      id,
      renderer: "poker_action_sizing",
      stage: "scaffolded",
    });
    assert.equal(row.activityId, id);
    assert.equal(row.note, "SoftPulse map arm missing (_guidedPulseTargetId)");
  }
});

test("scanAll walks nested lessons and leaves empty courses empty", () => {
  const empty = scanAll({});
  for (const rows of Object.values(empty)) {
    assert.deepEqual(rows, []);
  }
  const found = scanAll({
    sections: [
      {
        units: [
          {
            lessons: [
              {
                id: "lesson-1",
                activities: [
                  {
                    id: "act-gap-hint",
                    stage: "scaffolded",
                    renderer: "select_identify",
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  });
  assert.deepEqual(
    found.pressHints.map((row) => row.activityId),
    ["act-gap-hint"],
  );
  assert.equal(found.pressHints[0].lessonTitle, "lesson-1");
  assert.equal(found["deal-variants"].length, 0);
  const md = toMarkdown("pressHints", found.pressHints);
  assert.match(md, /\| lesson-1 \| act-gap-hint \| scaffolded\/— \|/);
});

test("--counts reports live arm sizes and rejects an unknown gap", () => {
  const counts = spawnSync(process.execPath, [SCANNER, "--counts"], {
    cwd: ROOT,
    encoding: "utf8",
  });
  assert.equal(counts.status, 0, counts.stderr);
  const body = JSON.parse(counts.stdout);
  assert.equal(body.densifyHelperArms, DENSIFY_HELPER_IDS.size);
  assert.equal(body.softpulseMapArms, GUIDED_PULSE_TARGET_IDS.size);
  assert.equal(body.catalogParents.teachSpec, null);
  assert.equal(typeof body.counts.pressHints, "number");
  assert.equal(typeof body.counts["unguided-softpulse-map"], "number");

  const one = spawnSync(
    process.execPath,
    [SCANNER, "--gap", "pressHints", "--counts"],
    {cwd: ROOT, encoding: "utf8"},
  );
  assert.equal(one.status, 0, one.stderr);
  const oneBody = JSON.parse(one.stdout);
  assert.deepEqual(Object.keys(oneBody.counts), ["pressHints"]);

  const unknown = spawnSync(
    process.execPath,
    [SCANNER, "--gap", "not-a-gap", "--counts"],
    {cwd: ROOT, encoding: "utf8"},
  );
  assert.equal(unknown.status, 2);
  assert.match(unknown.stderr, /Unknown --gap not-a-gap/);
});
