import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {dirname, resolve} from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

import {
  hashContent,
  loadCourseJson,
  runInvalidFixtureSuite,
  validateAndGenerate,
} from "./validate_course.mjs";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "../..");

test("seed course validates and shares contentChecksum", () => {
  const course = loadCourseJson(resolve(ROOT, "content/course/v2/course.json"));
  const {errors, clientCatalog, serverBank} = validateAndGenerate(course);
  assert.equal(errors.length, 0, errors.join("\n"));
  assert.equal(clientCatalog.catalogVersion, serverBank.catalogVersion);
  assert.equal(clientCatalog.contentChecksum, serverBank.contentChecksum);
  assert.equal(clientCatalog.sections.length, 7);
  assert.ok(serverBank.handLabsById["lab-01-01-01-bb-defend-seed"]);
});

test("client catalog omits private grading keys", () => {
  const course = loadCourseJson(resolve(ROOT, "content/course/v2/course.json"));
  const {clientCatalog} = validateAndGenerate(course);
  const blob = JSON.stringify(clientCatalog);
  for (const key of [
    "grading",
    "correctSequence",
    "sequenceGrading",
    "handLabSpec",
    "betterChoiceId",
    "reversalRead",
    "missGrading",
  ]) {
    assert.equal(blob.includes(`"${key}"`), false, `leaked ${key}`);
  }
  assert.ok(blob.includes("handLabSpecId"));
});

test("generated assets match validator output", () => {
  const course = loadCourseJson(resolve(ROOT, "content/course/v2/course.json"));
  const {clientCatalog, serverBank} = validateAndGenerate(course);
  const clientOnDisk = JSON.parse(
    readFileSync(resolve(ROOT, "assets/course/v2/catalog.json"), "utf8"),
  );
  const serverOnDisk = JSON.parse(
    readFileSync(
      resolve(ROOT, "functions/src/generated/course_bank.json"),
      "utf8",
    ),
  );
  assert.equal(hashContent(clientOnDisk), hashContent(clientCatalog));
  assert.equal(hashContent(serverOnDisk), hashContent(serverBank));
});

test("invalid fixtures each fail validation", () => {
  const failures = runInvalidFixtureSuite();
  assert.deepEqual(failures, []);
});
