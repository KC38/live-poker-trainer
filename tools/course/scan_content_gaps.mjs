#!/usr/bin/env node
/**
 * Fast structural gap scan for /lesson-content-agent.
 *
 * Walks content/course/v2/course.json and prints JSON (or a markdown
 * checklist) of catalog-wide gaps so the agent can enrich Jira parents
 * without rediscovering each lesson by hand.
 *
 * Usage (repo root):
 *   node tools/course/scan_content_gaps.mjs
 *   node tools/course/scan_content_gaps.mjs --gap pressHints
 *   node tools/course/scan_content_gaps.mjs --markdown --gap deal-variants
 *   node tools/course/scan_content_gaps.mjs --counts
 */

import {readFileSync} from "node:fs";
import {dirname, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "../..");
const SOURCE_PATH = resolve(REPO_ROOT, "content/course/v2/course.json");
const SOFTPULSE_MAP_PATH = resolve(
  REPO_ROOT,
  "lib/ui/course/activities/poker_action_sizing_activity.dart",
);

/**
 * Activity ids with SoftPulse docks in `_guidedPulseTargetId`.
 * @returns {Set<string>}
 */
function loadGuidedPulseTargetIds() {
  try {
    const text = readFileSync(SOFTPULSE_MAP_PATH, "utf8");
    const match = text.match(
      /String\?\s+_guidedPulseTargetId\(CourseActivity activity\)\s*\{([\s\S]*?)\n\}/,
    );
    if (!match) {
      return new Set();
    }
    return new Set(
      [...match[1].matchAll(/'(act-[^']+)'\s*=>/g)].map((m) => m[1]),
    );
  } catch {
    return new Set();
  }
}

const GUIDED_PULSE_TARGET_IDS = loadGuidedPulseTargetIds();

const INTERACTIVE_RENDERERS = new Set([
  "select_identify",
  "order_sequence",
  "compare_rank",
  "numeric_pot_price",
  "poker_action_sizing",
  "player_read_classify",
  "authored_multi_step_hand",
  "full_table_hand_lab",
]);

/**
 * Capstone hand/explain ids that Dart `lessonFrameHintsDisabled` marks as
 * no-hint (`lib/ui/course/widgets/lesson_screen_layout.dart`). Keep in sync
 * when that set changes — they must not inflate pressHints catalog counts.
 */
const NO_HINT_ACTIVITY_IDS = new Set([
  "act-07-10-01-explain",
  "act-07-10-02-explain",
  "act-07-10-03-explain",
  "act-07-10-04-explain",
  "act-07-10-05-explain",
  "act-07-10-01-hand",
  "act-07-10-02-hand",
  "act-07-10-03-hand",
  "act-07-10-04-hand",
  "act-07-10-05-hand",
]);

/**
 * @typedef {{
 *   lessonId: string,
 *   lessonTitle: string,
 *   activityId: string,
 *   stage: string,
 *   assessmentRole: string|null,
 *   renderer: string,
 *   note: string,
 * }} GapRow
 */

/**
 * @param {unknown} course
 * @yields {{lessonId: string, lessonTitle: string, activity: Record<string, unknown>}}
 */
function* walkActivities(course) {
  const sections = /** @type {Array<Record<string, unknown>>} */ (
    /** @type {Record<string, unknown>} */ (course).sections || []
  );
  for (const section of sections) {
    const units = /** @type {Array<Record<string, unknown>>} */ (
      section.units || []
    );
    for (const unit of units) {
      const lessons = /** @type {Array<Record<string, unknown>>} */ (
        unit.lessons || []
      );
      for (const lesson of lessons) {
        const lessonId = String(lesson.id || "");
        const lessonTitle = String(lesson.title || lessonId);
        const activities = /** @type {Array<Record<string, unknown>>} */ (
          lesson.activities || []
        );
        for (const activity of activities) {
          yield {lessonId, lessonTitle, activity};
        }
      }
    }
  }
}

/**
 * @param {Record<string, unknown>} activity
 * @returns {boolean}
 */
function isInteractive(activity) {
  const renderer = String(activity.renderer || "");
  if (INTERACTIVE_RENDERERS.has(renderer)) {
    return true;
  }
  // coach_dialogue with a table deal still needs teachSpec cues.
  const teach = /** @type {Record<string, unknown>|undefined} */ (
    activity.teachSpec
  );
  const deal = /** @type {Record<string, unknown>|undefined} */ (
    teach && teach.deal
  );
  const mode = deal && String(deal.mode || "");
  return mode === "fixed" || mode === "random_in_class";
}

/**
 * @param {Record<string, unknown>} activity
 * @returns {GapRow|null}
 */
function gapPressHints(lessonId, lessonTitle, activity) {
  if (String(activity.stage || "") !== "scaffolded") {
    return null;
  }
  if (activity.assessmentRole) {
    return null;
  }
  if (NO_HINT_ACTIVITY_IDS.has(String(activity.id || ""))) {
    return null;
  }
  if (!isInteractive(activity)) {
    return null;
  }
  const teach = /** @type {Record<string, unknown>|undefined} */ (
    activity.teachSpec
  );
  const hints = teach && teach.pressHints;
  const len = Array.isArray(hints) ? hints.length : 0;
  if (len >= 1) {
    return null;
  }
  return {
    lessonId,
    lessonTitle,
    activityId: String(activity.id || ""),
    stage: String(activity.stage || ""),
    assessmentRole: activity.assessmentRole
      ? String(activity.assessmentRole)
      : null,
    renderer: String(activity.renderer || ""),
    note: "pressHints missing or empty",
  };
}

/**
 * @param {Record<string, unknown>} activity
 * @returns {GapRow|null}
 */
function gapDealVariants(lessonId, lessonTitle, activity) {
  if (!isInteractive(activity)) {
    return null;
  }
  const teach = /** @type {Record<string, unknown>|undefined} */ (
    activity.teachSpec
  );
  if (!teach) {
    return null;
  }
  const deal = /** @type {Record<string, unknown>|undefined} */ (teach.deal);
  if (!deal || String(deal.mode || "") !== "fixed") {
    return null;
  }
  const variants = deal.variants;
  const len = Array.isArray(variants) ? variants.length : 0;
  if (len >= 1) {
    return null;
  }
  return {
    lessonId,
    lessonTitle,
    activityId: String(activity.id || ""),
    stage: String(activity.stage || ""),
    assessmentRole: activity.assessmentRole
      ? String(activity.assessmentRole)
      : null,
    renderer: String(activity.renderer || ""),
    note: "fixed deal with no deal.variants",
  };
}

/**
 * @param {Record<string, unknown>} activity
 * @returns {GapRow|null}
 */
function gapTeachSpec(lessonId, lessonTitle, activity) {
  if (!isInteractive(activity)) {
    return null;
  }
  if (activity.teachSpec && typeof activity.teachSpec === "object") {
    return null;
  }
  return {
    lessonId,
    lessonTitle,
    activityId: String(activity.id || ""),
    stage: String(activity.stage || ""),
    assessmentRole: activity.assessmentRole
      ? String(activity.assessmentRole)
      : null,
    renderer: String(activity.renderer || ""),
    note: "interactive step missing teachSpec",
  };
}

/**
 * SoftPulse explain / guided coach_dialogue without cues.
 * @param {Record<string, unknown>} activity
 * @returns {GapRow|null}
 */
function gapExplainCues(lessonId, lessonTitle, activity) {
  if (String(activity.renderer || "") !== "coach_dialogue") {
    return null;
  }
  if (String(activity.stage || "") !== "guided") {
    return null;
  }
  const teach = /** @type {Record<string, unknown>|undefined} */ (
    activity.teachSpec
  );
  if (!teach) {
    return {
      lessonId,
      lessonTitle,
      activityId: String(activity.id || ""),
      stage: "guided",
      assessmentRole: null,
      renderer: "coach_dialogue",
      note: "guided coach_dialogue missing teachSpec/cues",
    };
  }
  const cues = teach.cues;
  const len = Array.isArray(cues) ? cues.length : 0;
  if (len >= 1) {
    return null;
  }
  return {
    lessonId,
    lessonTitle,
    activityId: String(activity.id || ""),
    stage: "guided",
    assessmentRole: null,
    renderer: "coach_dialogue",
    note: "guided coach_dialogue teachSpec.cues empty",
  };
}

/**
 * SoftPulse explains that already have cues but lack activity-level
 * `explainGrading` (Nice! / Oops ladder — catalog LPT-624).
 * @param {unknown} node
 * @returns {boolean}
 */
function hasSoftPulseCue(node) {
  if (node == null) {
    return false;
  }
  if (Array.isArray(node)) {
    return node.some(hasSoftPulseCue);
  }
  if (typeof node !== "object") {
    return false;
  }
  const obj = /** @type {Record<string, unknown>} */ (node);
  if (obj.kind === "soft_pulse") {
    return true;
  }
  return Object.values(obj).some(hasSoftPulseCue);
}

/**
 * @param {Record<string, unknown>} activity
 * @returns {GapRow|null}
 */
function gapNiceLadder(lessonId, lessonTitle, activity) {
  if (String(activity.renderer || "") !== "coach_dialogue") {
    return null;
  }
  const teach = /** @type {Record<string, unknown>|undefined} */ (
    activity.teachSpec
  );
  if (!teach || !hasSoftPulseCue(teach)) {
    return null;
  }
  if (activity.explainGrading) {
    return null;
  }
  return {
    lessonId,
    lessonTitle,
    activityId: String(activity.id || ""),
    stage: String(activity.stage || ""),
    assessmentRole: activity.assessmentRole
      ? String(activity.assessmentRole)
      : null,
    renderer: "coach_dialogue",
    note: "SoftPulse explain missing activity-level explainGrading (Nice! ladder)",
  };
}

/**
 * Unguided (and scaffolded-qq) poker_action_sizing steps missing a
 * `_guidedPulseTargetId` SoftPulse map arm — catalog LPT-625.
 * @param {Record<string, unknown>} activity
 * @returns {GapRow|null}
 */
function gapUnguidedSoftpulseMap(lessonId, lessonTitle, activity) {
  if (String(activity.renderer || "") !== "poker_action_sizing") {
    return null;
  }
  const activityId = String(activity.id || "");
  const wantsMap =
    activityId.includes("unguided") || activityId.includes("scaffolded-qq");
  if (!wantsMap) {
    return null;
  }
  if (GUIDED_PULSE_TARGET_IDS.has(activityId)) {
    return null;
  }
  return {
    lessonId,
    lessonTitle,
    activityId,
    stage: String(activity.stage || ""),
    assessmentRole: activity.assessmentRole
      ? String(activity.assessmentRole)
      : null,
    renderer: "poker_action_sizing",
    note: "SoftPulse map arm missing (_guidedPulseTargetId)",
  };
}

const SCANNERS = {
  pressHints: gapPressHints,
  "deal-variants": gapDealVariants,
  teachSpec: gapTeachSpec,
  "explain-teachSpec": gapExplainCues,
  "nice-ladder": gapNiceLadder,
  "unguided-softpulse-map": gapUnguidedSoftpulseMap,
};

/** Open `(catalog)` parents — keep in sync when filing/closing parents. */
const CATALOG_PARENTS = {
  pressHints: "LPT-626",
  "deal-variants": "LPT-627",
  "explain-teachSpec": "LPT-635",
  // teachSpec Highs are still per-lesson; no single catalog parent yet
  teachSpec: null,
  "nice-ladder": "LPT-624",
  "unguided-softpulse-map": "LPT-625",
  // Related structural parents (not produced by this scanner’s gaps):
  "densify-tap": "LPT-628",
};

/**
 * @param {unknown} course
 * @returns {Record<string, GapRow[]>}
 */
function scanAll(course) {
  /** @type {Record<string, GapRow[]>} */
  const out = {};
  for (const key of Object.keys(SCANNERS)) {
    out[key] = [];
  }
  for (const {lessonId, lessonTitle, activity} of walkActivities(course)) {
    for (const [key, fn] of Object.entries(SCANNERS)) {
      const row = fn(lessonId, lessonTitle, activity);
      if (row) {
        out[key].push(row);
      }
    }
  }
  return out;
}

/**
 * @param {string} gap
 * @param {GapRow[]} rows
 * @returns {string}
 */
function toMarkdown(gap, rows) {
  const lines = [
    `## ${gap} (${rows.length})`,
    "",
    "| Lesson id | Activity id | Stage / role | Notes |",
    "| --- | --- | --- | --- |",
  ];
  for (const row of rows) {
    const role = row.assessmentRole || "—";
    lines.push(
      `| ${row.lessonId} | ${row.activityId} | ${row.stage}/${role} | ${row.note} |`,
    );
  }
  return `${lines.join("\n")}\n`;
}

function main() {
  const args = process.argv.slice(2);
  const markdown = args.includes("--markdown");
  const countsOnly = args.includes("--counts");
  const gapIdx = args.indexOf("--gap");
  const onlyGap = gapIdx >= 0 ? args[gapIdx + 1] : null;

  const course = JSON.parse(readFileSync(SOURCE_PATH, "utf8"));
  const all = scanAll(course);

  if (onlyGap) {
    if (!SCANNERS[onlyGap]) {
      console.error(
        `Unknown --gap ${onlyGap}. Choose: ${Object.keys(SCANNERS).join(", ")}`,
      );
      process.exit(2);
    }
  }

  /** @type {Record<string, GapRow[]>} */
  const selected = onlyGap ? {[onlyGap]: all[onlyGap]} : all;

  if (countsOnly) {
    const counts = Object.fromEntries(
      Object.entries(selected).map(([k, rows]) => [k, rows.length]),
    );
    process.stdout.write(
      `${JSON.stringify(
        {
          counts,
          catalogParents: CATALOG_PARENTS,
          softpulseMapArms: GUIDED_PULSE_TARGET_IDS.size,
        },
        null,
        2,
      )}\n`,
    );
    return;
  }

  if (markdown) {
    for (const [gap, rows] of Object.entries(selected)) {
      const parent = CATALOG_PARENTS[gap];
      if (parent) {
        process.stdout.write(`<!-- catalog parent: ${parent} — edit this ticket -->\n`);
      }
      process.stdout.write(toMarkdown(gap, rows));
      process.stdout.write("\n");
    }
    return;
  }

  process.stdout.write(`${JSON.stringify(selected, null, 2)}\n`);
}

main();
