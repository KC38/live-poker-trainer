#!/usr/bin/env node
/**
 * Validate the canonical curriculum catalog at content/curriculum/v1/catalog.json.
 *
 * Usage (from repo root):
 *   node tools/curriculum/validate_catalog.mjs
 *
 * Exits non-zero on failure.
 */

import {readFileSync} from "node:fs";
import {dirname, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const EXPECTED_SECTIONS = 13;
const EXPECTED_UNITS = 61;
const EXPECTED_LESSONS = 183;
const LESSONS_PER_UNIT = 3;

const __dirname = dirname(fileURLToPath(import.meta.url));
const catalogPath = resolve(
  __dirname,
  "../../content/curriculum/v1/catalog.json",
);

function fail(message) {
  console.error(`validate_catalog: ${message}`);
  process.exit(1);
}

let raw;
try {
  raw = readFileSync(catalogPath, "utf8");
} catch (error) {
  fail(`unable to read ${catalogPath}: ${error.message}`);
}

let catalog;
try {
  catalog = JSON.parse(raw);
} catch (error) {
  fail(`invalid JSON in ${catalogPath}: ${error.message}`);
}

const errors = [];
const ids = new Map();

function pushUnique(id, kind) {
  if (!id || typeof id !== "string") {
    errors.push(`${kind} missing id`);
    return;
  }
  const existing = ids.get(id);
  if (existing) {
    errors.push(`Duplicate ${kind} id "${id}" (also used as ${existing})`);
    return;
  }
  ids.set(id, kind);
}

if (!catalog || typeof catalog !== "object") {
  fail("catalog root must be an object");
}

const sections = catalog.sections;
if (!Array.isArray(sections)) {
  fail("catalog.sections must be an array");
}

let unitCount = 0;
let lessonCount = 0;

for (const objective of catalog.objectives ?? []) {
  pushUnique(objective?.id, "objective");
}
for (const gate of catalog.milestoneGates ?? []) {
  pushUnique(gate?.id, "milestoneGate");
}

for (const section of sections) {
  pushUnique(section?.id, "section");
  const units = section?.units;
  if (!Array.isArray(units)) {
    errors.push(`section "${section?.id}" missing units array`);
    continue;
  }
  for (const unit of units) {
    pushUnique(unit?.id, "unit");
    unitCount += 1;
    const lessons = unit?.lessons;
    if (!Array.isArray(lessons) || lessons.length !== LESSONS_PER_UNIT) {
      errors.push(
        `unit "${unit?.id}" must have exactly ${LESSONS_PER_UNIT} lessons ` +
          `(found ${lessons?.length ?? 0})`,
      );
    }
    const variantUnit =
      /variant/i.test(unit?.id ?? "") || /variant/i.test(unit?.title ?? "");
    for (const lesson of lessons ?? []) {
      pushUnique(lesson?.id, "lesson");
      lessonCount += 1;
      if (
        variantUnit &&
        lesson?.simulationClaims !== "conceptual_only"
      ) {
        errors.push(
          `variant lesson "${lesson?.id}" must declare simulationClaims ` +
            `"conceptual_only"`,
        );
      }
    }
  }
}

if (sections.length !== EXPECTED_SECTIONS) {
  errors.push(
    `expected ${EXPECTED_SECTIONS} sections, found ${sections.length}`,
  );
}
if (unitCount !== EXPECTED_UNITS) {
  errors.push(`expected ${EXPECTED_UNITS} units, found ${unitCount}`);
}
if (lessonCount !== EXPECTED_LESSONS) {
  errors.push(`expected ${EXPECTED_LESSONS} lessons, found ${lessonCount}`);
}

if (errors.length > 0) {
  console.error("validate_catalog: failed");
  for (const error of errors) {
    console.error(`- ${error}`);
  }
  process.exit(1);
}

console.log(
  `validate_catalog: ok (${EXPECTED_SECTIONS} sections, ` +
    `${EXPECTED_UNITS} units, ${EXPECTED_LESSONS} lessons)`,
);
