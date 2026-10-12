/**
 * Migrates course content to the two-stage model (guided | scaffolded).
 *
 * Mapping:
 *   explain     → guided
 *   guided      → guided
 *   scaffolded  → scaffolded
 *   unguided    → scaffolded
 *   checkpoint  → scaffolded + assessmentRole: checkpoint
 *   jump_test   → scaffolded + assessmentRole: jump_test
 *
 * Assessment roles disable authored hints (Hint chrome stays off).
 *
 * Usage (from repo root or tools/course):
 *   node tools/course/migrate_two_stages.mjs
 *   node tools/course/migrate_two_stages.mjs --waves
 */

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "../..");
const COURSE_JSON = path.join(ROOT, "content/course/v2/course.json");
const WAVE_FILES = [
  "tools/course/wave_one_foundations.mjs",
  "tools/course/wave_two_live_competence.mjs",
  "tools/course/wave_three_advanced_play.mjs",
];

/**
 * @param {string} stage
 * @return {{stage: string, assessmentRole?: string}}
 */
export function mapLegacyStage(stage) {
  switch (stage) {
  case "explain":
  case "guided":
    return {stage: "guided"};
  case "scaffolded":
  case "unguided":
    return {stage: "scaffolded"};
  case "checkpoint":
    return {stage: "scaffolded", assessmentRole: "checkpoint"};
  case "jump_test":
    return {stage: "scaffolded", assessmentRole: "jump_test"};
  default:
    return {stage};
  }
}

/**
 * @param {Record<string, unknown>} activity
 * @return {Record<string, unknown>}
 */
export function migrateActivity(activity) {
  const mapped = mapLegacyStage(String(activity.stage ?? ""));
  const out = {...activity, stage: mapped.stage};
  if (mapped.assessmentRole) {
    out.assessmentRole = mapped.assessmentRole;
  } else {
    delete out.assessmentRole;
  }
  // Assessment steps: no Hint — strip authored hint media.
  if (mapped.assessmentRole && Array.isArray(out.coachMedia)) {
    out.coachMedia = out.coachMedia.filter(
        (m) => !(m && typeof m === "object" && m.kind === "hint"),
    );
    if (out.coachMedia.length === 0) delete out.coachMedia;
  }
  if (
    mapped.assessmentRole &&
    out.teachSpec &&
    typeof out.teachSpec === "object"
  ) {
    const teach = /** @type {Record<string, unknown>} */ ({...out.teachSpec});
    delete teach.pressHints;
    out.teachSpec = teach;
  }
  return out;
}

/**
 * @param {Record<string, unknown>} course
 * @return {{course: Record<string, unknown>, counts: Record<string, number>}}
 */
export function migrateCourse(course) {
  const counts = {
    guided: 0,
    scaffolded: 0,
    checkpoint: 0,
    jump_test: 0,
  };
  const sections = Array.isArray(course.sections) ? course.sections : [];
  const nextSections = sections.map((sec) => {
    const units = Array.isArray(sec.units) ? sec.units : [];
    return {
      ...sec,
      units: units.map((unit) => {
        const lessons = Array.isArray(unit.lessons) ? unit.lessons : [];
        return {
          ...unit,
          lessons: lessons.map((lesson) => {
            const activities = Array.isArray(lesson.activities) ?
              lesson.activities :
              [];
            return {
              ...lesson,
              activities: activities.map((act) => {
                const migrated = migrateActivity(
                    /** @type {Record<string, unknown>} */ (act),
                );
                counts[/** @type {string} */ (migrated.stage)] =
                  (counts[/** @type {string} */ (migrated.stage)] || 0) + 1;
                if (migrated.assessmentRole === "checkpoint") {
                  counts.checkpoint += 1;
                }
                if (migrated.assessmentRole === "jump_test") {
                  counts.jump_test += 1;
                }
                return migrated;
              }),
            };
          }),
        };
      }),
    };
  });
  return {course: {...course, sections: nextSections}, counts};
}

/**
 * Mechanical stage rewrite for wave authoring sources.
 * @param {string} source
 * @return {string}
 */
export function migrateWaveSource(source) {
  let out = source;
  out = out.replace(/stage:\s*"explain"/g, 'stage: "guided"');
  out = out.replace(/stage:\s*"unguided"/g, 'stage: "scaffolded"');
  out = out.replace(
      /stage:\s*"checkpoint"/g,
      'stage: "scaffolded", assessmentRole: "checkpoint"',
  );
  out = out.replace(
      /stage:\s*"jump_test"/g,
      'stage: "scaffolded", assessmentRole: "jump_test"',
  );
  return out;
}

function main() {
  const args = new Set(process.argv.slice(2));
  const raw = JSON.parse(fs.readFileSync(COURSE_JSON, "utf8"));
  const {course, counts} = migrateCourse(raw);
  fs.writeFileSync(COURSE_JSON, `${JSON.stringify(course, null, 2)}\n`);
  console.log("migrated course.json", counts);

  if (args.has("--waves")) {
    for (const rel of WAVE_FILES) {
      const abs = path.join(ROOT, rel);
      const before = fs.readFileSync(abs, "utf8");
      const after = migrateWaveSource(before);
      if (after !== before) {
        fs.writeFileSync(abs, after);
        console.log(`migrated ${rel}`);
      } else {
        console.log(`unchanged ${rel}`);
      }
    }
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main();
}
