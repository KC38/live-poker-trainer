#!/usr/bin/env node
/**
 * Validate canonical live-cash NLH course source and generate catalogs.
 *
 * Usage (repo root):
 *   node tools/course/validate_course.mjs           # validate + write
 *   node tools/course/validate_course.mjs --write    # same
 *   node tools/course/validate_course.mjs --check    # validate; fail if outputs drift
 *   node tools/course/validate_course.mjs --validate-only
 *   node tools/course/validate_course.mjs --fixture path/to.json
 */

import {createHash} from "node:crypto";
import {
  existsSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "../..");
const SOURCE_PATH = resolve(REPO_ROOT, "content/course/v2/course.json");
const CLIENT_OUT = resolve(REPO_ROOT, "assets/course/v2/catalog.json");
const SERVER_OUT = resolve(
  REPO_ROOT,
  "functions/src/generated/course_bank.json",
);
const INVALID_FIXTURE_DIR = resolve(
  REPO_ROOT,
  "content/course/v2/fixtures/invalid",
);

const SOFT_GRADES = new Set([
  "recommended",
  "strong",
  "reasonable",
  "questionable",
  "clear_mistake",
]);
const STAGES = new Set([
  "explain",
  "guided",
  "scaffolded",
  "unguided",
  "checkpoint",
  "jump_test",
]);
const RENDERERS = new Set([
  "coach_dialogue",
  "select_identify",
  "order_sequence",
  "compare_rank",
  "numeric_pot_price",
  "poker_action_sizing",
  "player_read_classify",
  "authored_multi_step_hand",
  "full_table_hand_lab",
]);
const PLAYER_TYPES = new Set([
  "calling_station",
  "nit",
  "maniac",
  "tag",
  "lag",
]);

/** Banned live-cash-scope phrases (case-insensitive whole-word-ish). */
const BANNED_PATTERNS = [
  {re: /\btournament(s)?\b/i, label: "tournaments"},
  {re: /\bMTT\b/, label: "tournaments"},
  {re: /\bSNG\b/, label: "tournaments"},
  {re: /\bSit\s*&\s*Go\b/i, label: "tournaments"},
  {re: /\bHUD\b/, label: "online/HUD"},
  {re: /\bonline[-\s]?poker\b/i, label: "online/HUD"},
  {re: /\bPLO\b/, label: "PLO/Omaha"},
  {re: /\bOmaha\b/i, label: "PLO/Omaha"},
  {re: /\bOmaha[- ]?8\b/i, label: "PLO/Omaha"},
  {re: /\bStud\b/i, label: "other variants"},
  {re: /\bRazz\b/i, label: "other variants"},
  {re: /\bShort\s*Deck\b/i, label: "other variants"},
  {re: /\brake\b/i, label: "rake"},
];

const PRIVATE_KEYS = new Set([
  "grading",
  "correctSequence",
  "sequenceGrading",
  "handLabSpec",
  "betterChoiceId",
  "reversalRead",
  "acceptedMin",
  "acceptedMax",
  "missGrading",
  "villainCards",
]);

/**
 * @param {unknown} value
 * @return {unknown}
 */
export function sortedJsonValue(value) {
  if (value === null || typeof value !== "object") {
    return value;
  }
  if (Array.isArray(value)) {
    return value.map(sortedJsonValue);
  }
  const obj = /** @type {Record<string, unknown>} */ (value);
  const out = {};
  for (const key of Object.keys(obj).sort()) {
    out[key] = sortedJsonValue(obj[key]);
  }
  return out;
}

/**
 * @param {unknown} value
 * @return {string}
 */
export function hashContent(value) {
  return createHash("sha256")
    .update(JSON.stringify(sortedJsonValue(value)), "utf8")
    .digest("hex");
}

/**
 * @param {string} text
 * @param {string[]} errors
 * @param {string} path
 */
function scanBannedText(text, errors, path) {
  if (typeof text !== "string" || !text.trim()) {
    return;
  }
  for (const {re, label} of BANNED_PATTERNS) {
    if (re.test(text)) {
      errors.push(`${path}: banned ${label} content in "${text.slice(0, 80)}"`);
    }
  }
}

/**
 * @param {unknown} node
 * @param {string[]} errors
 * @param {string} path
 */
function walkBanned(node, errors, path) {
  if (typeof node === "string") {
    scanBannedText(node, errors, path);
    return;
  }
  if (Array.isArray(node)) {
    node.forEach((item, i) => walkBanned(item, errors, `${path}[${i}]`));
    return;
  }
  if (node && typeof node === "object") {
    for (const [key, value] of Object.entries(node)) {
      walkBanned(value, errors, `${path}.${key}`);
    }
  }
}

/**
 * @param {unknown} node
 * @param {string[]} errors
 * @param {string} path
 */
function assertNoPrivateKeys(node, errors, path) {
  if (Array.isArray(node)) {
    node.forEach((item, i) => assertNoPrivateKeys(item, errors, `${path}[${i}]`));
    return;
  }
  if (node && typeof node === "object") {
    for (const [key, value] of Object.entries(node)) {
      if (PRIVATE_KEYS.has(key)) {
        errors.push(`${path}.${key}: private grading metadata leaked into client catalog`);
      }
      assertNoPrivateKeys(value, errors, `${path}.${key}`);
    }
  }
}

/**
 * @param {Record<string, unknown>} activity
 * @param {string[]} errors
 * @param {string} path
 * @return {Record<string, unknown>}
 */
function stripActivityPrivate(activity, errors, path) {
  const out = {...activity};
  if (Array.isArray(out.choices)) {
    out.choices = out.choices.map((choice, i) => {
      const c = /** @type {Record<string, unknown>} */ ({...choice});
      if (!c.grading) {
        errors.push(`${path}.choices[${i}]: missing private grading in source`);
      }
      delete c.grading;
      return c;
    });
  }
  if (out.correctSequence !== undefined) {
    delete out.correctSequence;
  }
  if (out.sequenceGrading !== undefined) {
    delete out.sequenceGrading;
  }
  if (out.numericPrompt && typeof out.numericPrompt === "object") {
    const np = {
      .../** @type {Record<string, unknown>} */ (out.numericPrompt),
    };
    const publicNp = {
      question: np.question,
      unit: np.unit,
    };
    out.numericPrompt = publicNp;
  }
  if (Array.isArray(out.handSteps)) {
    out.handSteps = out.handSteps.map((step, si) => {
      const s = /** @type {Record<string, unknown>} */ ({...step});
      if (Array.isArray(s.choices)) {
        s.choices = s.choices.map((choice, ci) => {
          const c = /** @type {Record<string, unknown>} */ ({...choice});
          if (!c.grading) {
            errors.push(
              `${path}.handSteps[${si}].choices[${ci}]: missing private grading`,
            );
          }
          delete c.grading;
          return c;
        });
      }
      return s;
    });
  }
  if (out.handLabSpec && typeof out.handLabSpec === "object") {
    const lab = /** @type {Record<string, unknown>} */ (out.handLabSpec);
    if (typeof lab.id !== "string") {
      errors.push(`${path}.handLabSpec: missing id`);
    } else {
      out.handLabSpecId = lab.id;
    }
    delete out.handLabSpec;
  } else if (out.renderer === "full_table_hand_lab") {
    errors.push(`${path}: full_table_hand_lab requires handLabSpec`);
  }
  return out;
}

/**
 * @param {Record<string, unknown>} course
 * @param {string[]} errors
 */
function validateShape(course, errors) {
  if (course.scope !== "live_cash_nlh") {
    errors.push('course.scope must be "live_cash_nlh"');
  }
  if (course.coachId !== "rex") {
    errors.push('course.coachId must be "rex"');
  }
  if (!Array.isArray(course.playerTypes) || course.playerTypes.length !== 5) {
    errors.push("course.playerTypes must contain exactly 5 entries");
  }
  if (!Array.isArray(course.sections) || course.sections.length !== 7) {
    errors.push("course.sections must contain exactly 7 sections");
  }
}

/**
 * @param {Record<string, unknown>} course
 * @return {{errors: string[], clientCatalog: object, serverBank: object}}
 */
export function validateAndGenerate(course) {
  const errors = [];
  validateShape(course, errors);
  walkBanned(course, errors, "course");

  /** @type {Map<string, string>} */
  const ids = new Map();
  /** @type {Map<string, {order: number, prereqs: string[], remediation: string[], playerTypeRefs: string[], introduces: string[]}>} */
  const lessons = new Map();
  /** @type {Map<string, number>} */
  const lessonOrderIndex = new Map();
  let lessonOrdinal = 0;

  /**
   * @param {string} id
   * @param {string} kind
   * @param {string} path
   */
  function claimId(id, kind, path) {
    if (typeof id !== "string" || !/^[a-z][a-z0-9_-]{1,63}$/.test(id)) {
      errors.push(`${path}: invalid id "${id}"`);
      return;
    }
    const existing = ids.get(id);
    if (existing) {
      errors.push(`${path}: duplicate id "${id}" (also ${existing})`);
      return;
    }
    ids.set(id, kind);
  }

  const playerTypeIntroLesson = new Map();
  for (const [i, pt] of (course.playerTypes ?? []).entries()) {
    const p = /** @type {Record<string, unknown>} */ (pt);
    const path = `playerTypes[${i}]`;
    if (!PLAYER_TYPES.has(/** @type {string} */ (p.id))) {
      errors.push(`${path}: unknown player type id`);
    }
    claimId(/** @type {string} */ (p.id), "playerType", path);
    if (typeof p.introducedByLessonId === "string") {
      playerTypeIntroLesson.set(p.id, p.introducedByLessonId);
    } else {
      errors.push(`${path}: missing introducedByLessonId`);
    }
  }

  const clientSections = [];
  const serverSections = [];
  /** @type {Record<string, unknown>} */
  const gradingByActivityId = {};
  /** @type {Record<string, unknown>} */
  const handLabsById = {};

  for (const [si, section] of (course.sections ?? []).entries()) {
    const sec = /** @type {Record<string, unknown>} */ (section);
    const secPath = `sections[${si}]`;
    claimId(/** @type {string} */ (sec.id), "section", secPath);
    if (!Array.isArray(sec.units) || sec.units.length < 1) {
      errors.push(`${secPath}: must include at least one unit`);
      continue;
    }
    const clientUnits = [];
    const serverUnits = [];
    for (const [ui, unit] of sec.units.entries()) {
      const u = /** @type {Record<string, unknown>} */ (unit);
      const unitPath = `${secPath}.units[${ui}]`;
      claimId(/** @type {string} */ (u.id), "unit", unitPath);
      const clientLessons = [];
      const serverLessons = [];
      for (const [li, lesson] of (u.lessons ?? []).entries()) {
        const les = /** @type {Record<string, unknown>} */ (lesson);
        const lessonPath = `${unitPath}.lessons[${li}]`;
        const lessonId = /** @type {string} */ (les.id);
        claimId(lessonId, "lesson", lessonPath);
        lessonOrdinal += 1;
        lessonOrderIndex.set(lessonId, lessonOrdinal);
        const prereqs = Array.isArray(les.prerequisites)
          ? les.prerequisites.map(String)
          : [];
        const remediation = Array.isArray(les.remediationLessonIds)
          ? les.remediationLessonIds.map(String)
          : [];
        if (remediation.length < 1) {
          errors.push(`${lessonPath}: remediationLessonIds must be non-empty`);
        }
        const playerTypeRefs = Array.isArray(les.playerTypeRefs)
          ? les.playerTypeRefs.map(String)
          : [];
        const introduces = Array.isArray(les.introducesPlayerTypes)
          ? les.introducesPlayerTypes.map(String)
          : [];
        lessons.set(lessonId, {
          order: lessonOrdinal,
          prereqs,
          remediation,
          playerTypeRefs,
          introduces,
        });

        const clientActivities = [];
        const serverActivities = [];
        for (const [ai, activity] of (les.activities ?? []).entries()) {
          const act = /** @type {Record<string, unknown>} */ (activity);
          const actPath = `${lessonPath}.activities[${ai}]`;
          const actId = /** @type {string} */ (act.id);
          claimId(actId, "activity", actPath);
          if (!STAGES.has(/** @type {string} */ (act.stage))) {
            errors.push(`${actPath}: unknown stage`);
          }
          if (!RENDERERS.has(/** @type {string} */ (act.renderer))) {
            errors.push(`${actPath}: unknown activity renderer`);
          }
          if (!Array.isArray(act.acceptedGrades) || act.acceptedGrades.length < 1) {
            errors.push(`${actPath}: acceptedGrades required`);
          } else {
            for (const g of act.acceptedGrades) {
              if (!SOFT_GRADES.has(/** @type {string} */ (g))) {
                errors.push(`${actPath}: unknown grade "${g}"`);
              }
            }
          }
          if (typeof act.lifeLossEligible !== "boolean") {
            errors.push(`${actPath}: lifeLossEligible must be boolean`);
          }
          if (
            (act.stage === "guided" || act.stage === "scaffolded") &&
            act.lifeLossEligible === true
          ) {
            // life loss only allowed via clear_mistake on non-guided stages;
            // guided/scaffolded may never be life-loss eligible.
            errors.push(
              `${actPath}: life loss is not allowed on guided/scaffolded activities`,
            );
          }

          // Collect private grading bank entry.
          /** @type {Record<string, unknown>} */
          const privatePayload = {
            activityId: actId,
            stage: act.stage,
            renderer: act.renderer,
            acceptedGrades: act.acceptedGrades,
            lifeLossEligible: act.lifeLossEligible,
          };
          if (Array.isArray(act.choices)) {
            privatePayload.choiceGrading = Object.fromEntries(
              act.choices.map((choice) => {
                const c = /** @type {Record<string, unknown>} */ (choice);
                return [c.id, c.grading];
              }),
            );
            for (const choice of act.choices) {
              const c = /** @type {Record<string, unknown>} */ (choice);
              const grading = /** @type {Record<string, unknown>|undefined} */ (
                c.grading
              );
              if (
                grading &&
                grading.grade === "clear_mistake" &&
                (act.stage === "guided" || act.stage === "scaffolded") &&
                act.lifeLossEligible === true
              ) {
                errors.push(
                  `${actPath}: clear_mistake life loss forbidden on ${act.stage}`,
                );
              }
            }
          }
          if (act.correctSequence !== undefined) {
            privatePayload.correctSequence = act.correctSequence;
          }
          if (act.sequenceGrading !== undefined) {
            privatePayload.sequenceGrading = act.sequenceGrading;
          }
          if (act.numericPrompt && typeof act.numericPrompt === "object") {
            const np = /** @type {Record<string, unknown>} */ (act.numericPrompt);
            privatePayload.numericPrompt = {
              acceptedMin: np.acceptedMin,
              acceptedMax: np.acceptedMax,
              grading: np.grading,
              missGrading: np.missGrading,
            };
          }
          if (Array.isArray(act.handSteps)) {
            privatePayload.handSteps = act.handSteps.map((step) => {
              const s = /** @type {Record<string, unknown>} */ (step);
              return {
                id: s.id,
                choiceGrading: Object.fromEntries(
                  (/** @type {unknown[]} */ (s.choices) ?? []).map((choice) => {
                    const c = /** @type {Record<string, unknown>} */ (choice);
                    return [c.id, c.grading];
                  }),
                ),
              };
            });
          }
          if (act.handLabSpec && typeof act.handLabSpec === "object") {
            const lab = /** @type {Record<string, unknown>} */ (act.handLabSpec);
            const labId = /** @type {string} */ (lab.id);
            claimId(labId, "handLab", `${actPath}.handLabSpec`);
            handLabsById[labId] = lab;
            privatePayload.handLabSpecId = labId;
          } else if (act.renderer === "full_table_hand_lab") {
            errors.push(`${actPath}: hand lab missing authoritative server specification`);
          }

          gradingByActivityId[actId] = privatePayload;

          const clientAct = stripActivityPrivate({...act}, errors, actPath);
          clientActivities.push(clientAct);
          serverActivities.push({...act});
        }

        clientLessons.push({
          id: les.id,
          order: les.order,
          title: les.title,
          summary: les.summary,
          objectives: les.objectives,
          prerequisites: les.prerequisites,
          remediationLessonIds: les.remediationLessonIds,
          estimatedMinutes: les.estimatedMinutes,
          difficultyBand: les.difficultyBand,
          playerTypeRefs: les.playerTypeRefs ?? [],
          introducesPlayerTypes: les.introducesPlayerTypes ?? [],
          activities: clientActivities,
        });
        serverLessons.push({
          ...les,
          activities: serverActivities,
        });
      }
      clientUnits.push({
        id: u.id,
        order: u.order,
        title: u.title,
        summary: u.summary,
        lessons: clientLessons,
      });
      serverUnits.push({
        id: u.id,
        order: u.order,
        title: u.title,
        summary: u.summary,
        lessons: serverLessons,
      });
    }
    clientSections.push({
      id: sec.id,
      order: sec.order,
      title: sec.title,
      summary: sec.summary,
      experienceBand: sec.experienceBand,
      units: clientUnits,
    });
    serverSections.push({
      id: sec.id,
      order: sec.order,
      title: sec.title,
      summary: sec.summary,
      experienceBand: sec.experienceBand,
      units: serverUnits,
    });
  }

  // Prerequisite / remediation / reachability / cycles.
  for (const [lessonId, meta] of lessons.entries()) {
    for (const pre of meta.prereqs) {
      if (!lessons.has(pre)) {
        errors.push(`lesson "${lessonId}": broken prerequisite "${pre}"`);
        continue;
      }
      if ((lessonOrderIndex.get(pre) ?? 0) >= (lessonOrderIndex.get(lessonId) ?? 0)) {
        errors.push(
          `lesson "${lessonId}": prerequisite "${pre}" must appear earlier in course order`,
        );
      }
    }
    for (const rem of meta.remediation) {
      if (!lessons.has(rem)) {
        errors.push(`lesson "${lessonId}": missing remediation "${rem}"`);
      }
    }
  }

  // Cycle detection on prerequisite graph.
  /** @type {Map<string, string>} */
  const visitState = new Map();
  /**
   * @param {string} id
   * @param {string[]} stack
   */
  function dfs(id, stack) {
    const state = visitState.get(id);
    if (state === "visiting") {
      errors.push(`prerequisite cycle involving ${[...stack, id].join(" -> ")}`);
      return;
    }
    if (state === "done") {
      return;
    }
    visitState.set(id, "visiting");
    const meta = lessons.get(id);
    for (const pre of meta?.prereqs ?? []) {
      if (lessons.has(pre)) {
        dfs(pre, [...stack, id]);
      }
    }
    visitState.set(id, "done");
  }
  for (const id of lessons.keys()) {
    dfs(id, []);
  }

  // Unreachable lessons: anything other than roots must be reachable via prereq edges from roots.
  // Course entry roots: lessons with no prerequisites. Prefer section-1 roots
  // when present so later islands without a path from the start are unreachable.
  const allRoots = [...lessons.entries()]
    .filter(([, meta]) => meta.prereqs.length === 0)
    .map(([id]) => id);
  const sectionOneLessonIds = new Set();
  const firstSection = (course.sections ?? [])[0];
  if (firstSection && typeof firstSection === "object") {
    for (const unit of /** @type {unknown[]} */ (
      /** @type {Record<string, unknown>} */ (firstSection).units
    ) ?? []) {
      const u = /** @type {Record<string, unknown>} */ (unit);
      for (const lesson of /** @type {unknown[]} */ (u.lessons) ?? []) {
        const les = /** @type {Record<string, unknown>} */ (lesson);
        sectionOneLessonIds.add(String(les.id));
      }
    }
  }
  const roots = allRoots.filter((id) => sectionOneLessonIds.has(id));
  const entryRoots = roots.length > 0 ? roots : allRoots;
  if (entryRoots.length === 0 && lessons.size > 0) {
    errors.push("no root lessons (every lesson has prerequisites)");
  }
  const reachable = new Set();
  /** @type {Map<string, string[]>} */
  const dependents = new Map();
  for (const [id, meta] of lessons.entries()) {
    for (const pre of meta.prereqs) {
      const list = dependents.get(pre) ?? [];
      list.push(id);
      dependents.set(pre, list);
    }
  }
  const queue = [...entryRoots];
  while (queue.length) {
    const id = queue.shift();
    if (!id || reachable.has(id)) {
      continue;
    }
    reachable.add(id);
    for (const next of dependents.get(id) ?? []) {
      queue.push(next);
    }
  }
  for (const id of lessons.keys()) {
    if (!reachable.has(id)) {
      errors.push(`lesson "${id}" is unreachable from root lessons`);
    }
  }

  // Player type introduction before use.
  /** @type {Map<string, number>} */
  const introducedAt = new Map();
  for (const [lessonId, meta] of lessons.entries()) {
    for (const pt of meta.introduces) {
      if (!PLAYER_TYPES.has(pt)) {
        errors.push(`lesson "${lessonId}": unknown introduced player type "${pt}"`);
      }
      const existing = introducedAt.get(pt);
      const ord = lessonOrderIndex.get(lessonId) ?? 0;
      if (existing === undefined || ord < existing) {
        introducedAt.set(pt, ord);
      }
    }
  }
  for (const [pt, introLessonId] of playerTypeIntroLesson.entries()) {
    if (!lessons.has(introLessonId)) {
      errors.push(
        `player type "${pt}" introducedByLessonId "${introLessonId}" does not exist`,
      );
      continue;
    }
    const meta = lessons.get(introLessonId);
    if (!meta?.introduces.includes(pt)) {
      errors.push(
        `lesson "${introLessonId}" must list introducesPlayerTypes containing "${pt}"`,
      );
    }
  }
  for (const [lessonId, meta] of lessons.entries()) {
    const ord = lessonOrderIndex.get(lessonId) ?? 0;
    for (const pt of meta.playerTypeRefs) {
      const introOrd = introducedAt.get(pt);
      if (introOrd === undefined) {
        errors.push(`lesson "${lessonId}": player type "${pt}" never introduced`);
      } else if (ord < introOrd) {
        errors.push(
          `lesson "${lessonId}": player type "${pt}" used before introduction`,
        );
      }
    }
    for (const act of []) {
      void act;
    }
  }
  // Also check activity-level playerTypeRefs against introduction order.
  for (const section of course.sections ?? []) {
    const sec = /** @type {Record<string, unknown>} */ (section);
    for (const unit of /** @type {unknown[]} */ (sec.units) ?? []) {
      const u = /** @type {Record<string, unknown>} */ (unit);
      for (const lesson of /** @type {unknown[]} */ (u.lessons) ?? []) {
        const les = /** @type {Record<string, unknown>} */ (lesson);
        const lessonId = String(les.id);
        const ord = lessonOrderIndex.get(lessonId) ?? 0;
        for (const activity of /** @type {unknown[]} */ (les.activities) ?? []) {
          const act = /** @type {Record<string, unknown>} */ (activity);
          for (const pt of /** @type {unknown[]} */ (act.playerTypeRefs) ?? []) {
            const introOrd = introducedAt.get(String(pt));
            if (introOrd === undefined || ord < introOrd) {
              errors.push(
                `activity "${act.id}": player type "${pt}" used before introduction`,
              );
            }
          }
        }
      }
    }
  }

  const checksumSeed = {
    catalogVersion: course.catalogVersion,
    scope: course.scope,
    playerTypes: course.playerTypes,
    sections: clientSections,
    gradingActivityIds: Object.keys(gradingByActivityId).sort(),
    handLabIds: Object.keys(handLabsById).sort(),
  };
  const contentChecksum = hashContent(checksumSeed);

  const clientCatalog = {
    catalogVersion: course.catalogVersion,
    minClientVersion: course.minClientVersion,
    scope: course.scope,
    coachId: course.coachId,
    contentChecksum,
    playerTypes: (course.playerTypes ?? []).map((pt) => {
      const p = /** @type {Record<string, unknown>} */ (pt);
      return {
        id: p.id,
        label: p.label,
        introducedByLessonId: p.introducedByLessonId,
        summary: p.summary,
      };
    }),
    sections: clientSections,
  };

  const serverBank = {
    catalogVersion: course.catalogVersion,
    minClientVersion: course.minClientVersion,
    scope: course.scope,
    coachId: course.coachId,
    contentChecksum,
    playerTypes: course.playerTypes,
    sections: serverSections,
    gradingByActivityId,
    handLabsById,
  };

  assertNoPrivateKeys(clientCatalog, errors, "clientCatalog");

  if (clientCatalog.contentChecksum !== serverBank.contentChecksum) {
    errors.push("client/server contentChecksum mismatch");
  }

  return {errors, clientCatalog, serverBank};
}

/**
 * @param {string} path
 * @return {Record<string, unknown>}
 */
export function loadCourseJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

/**
 * Run deliberately invalid fixtures and ensure each fails.
 * @return {string[]}
 */
export function runInvalidFixtureSuite() {
  const failures = [];
  if (!existsSync(INVALID_FIXTURE_DIR)) {
    return [`missing invalid fixture dir ${INVALID_FIXTURE_DIR}`];
  }
  const files = readdirSync(INVALID_FIXTURE_DIR).filter((f) => f.endsWith(".json"));
  if (files.length === 0) {
    return ["no invalid fixtures found"];
  }
  for (const file of files) {
    const full = join(INVALID_FIXTURE_DIR, file);
    const course = loadCourseJson(full);
    const {errors} = validateAndGenerate(course);
    if (errors.length === 0) {
      failures.push(`fixture ${file} unexpectedly passed validation`);
    }
  }
  return failures;
}

/**
 * @param {{mode: "write"|"check"|"validate-only", sourcePath?: string}} options
 */
export function runCli(options) {
  const sourcePath = options.sourcePath ?? SOURCE_PATH;
  const course = loadCourseJson(sourcePath);
  const {errors, clientCatalog, serverBank} = validateAndGenerate(course);

  if (errors.length > 0) {
    console.error("validate_course: failed");
    for (const error of errors) {
      console.error(`- ${error}`);
    }
    process.exitCode = 1;
    return {ok: false, errors};
  }

  const fixtureFailures = options.sourcePath ? [] : runInvalidFixtureSuite();
  if (fixtureFailures.length > 0) {
    console.error("validate_course: invalid fixture suite failed");
    for (const error of fixtureFailures) {
      console.error(`- ${error}`);
    }
    process.exitCode = 1;
    return {ok: false, errors: fixtureFailures};
  }

  const clientText = `${JSON.stringify(clientCatalog, null, 2)}\n`;
  const serverText = `${JSON.stringify(serverBank, null, 2)}\n`;

  if (options.mode === "validate-only") {
    console.log(
      `validate_course: ok (version ${clientCatalog.catalogVersion}, contentChecksum ${clientCatalog.contentChecksum.slice(0, 12)}…)`,
    );
    return {ok: true, errors: [], clientCatalog, serverBank};
  }

  if (options.mode === "check") {
    const drift = [];
    if (!existsSync(CLIENT_OUT) || readFileSync(CLIENT_OUT, "utf8") !== clientText) {
      drift.push("assets/course/v2/catalog.json is out of date");
    }
    if (!existsSync(SERVER_OUT) || readFileSync(SERVER_OUT, "utf8") !== serverText) {
      drift.push("functions/src/generated/course_bank.json is out of date");
    }
    if (drift.length) {
      console.error("validate_course: generation drift");
      for (const d of drift) {
        console.error(`- ${d}`);
      }
      process.exitCode = 1;
      return {ok: false, errors: drift};
    }
    console.log("validate_course: check ok (generated catalogs in sync)");
    return {ok: true, errors: [], clientCatalog, serverBank};
  }

  mkdirSync(dirname(CLIENT_OUT), {recursive: true});
  mkdirSync(dirname(SERVER_OUT), {recursive: true});
  writeFileSync(CLIENT_OUT, clientText, "utf8");
  writeFileSync(SERVER_OUT, serverText, "utf8");
  console.log(
    `validate_course: wrote client+server catalogs (version ${clientCatalog.catalogVersion}, contentChecksum ${clientCatalog.contentChecksum.slice(0, 12)}…)`,
  );
  return {ok: true, errors: [], clientCatalog, serverBank};
}

function parseArgs(argv) {
  const args = new Set(argv);
  let mode = "write";
  if (args.has("--check")) {
    mode = "check";
  } else if (args.has("--validate-only")) {
    mode = "validate-only";
  } else if (args.has("--write") || args.size === 0) {
    mode = "write";
  }
  const fixtureIdx = argv.indexOf("--fixture");
  const sourcePath =
    fixtureIdx >= 0 && argv[fixtureIdx + 1]
      ? resolve(argv[fixtureIdx + 1])
      : undefined;
  return {mode, sourcePath};
}

const isMain = process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  runCli(parseArgs(process.argv.slice(2)));
}

// Silence unused import for intentional public surface in tests.
void rmSync;
