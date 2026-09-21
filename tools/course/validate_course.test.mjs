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
  assert.ok(serverBank.handLabsById["lab-01-06-01-bb-defend"]);
  assert.ok(serverBank.handLabsById["lab-02-07-01-full-ring-btn"]);
  assert.equal(clientCatalog.catalogVersion, "2.0.0");
  assert.ok(
    clientCatalog.sections[0].units[0].lessons[0].id ===
      "lesson-01-01-01-your-two-cards",
  );
  assert.equal(clientCatalog.sections[0].units.length, 6);
  assert.equal(clientCatalog.sections[1].units.length, 7);
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

test("wave one sections expose full unit trees and jump tests", () => {
  const course = loadCourseJson(resolve(ROOT, "content/course/v2/course.json"));
  const {errors, clientCatalog, serverBank} = validateAndGenerate(course);
  assert.equal(errors.length, 0, errors.join("\n"));
  const sec1 = clientCatalog.sections[0];
  const sec2 = clientCatalog.sections[1];
  assert.equal(sec1.id, "sec-01-never-played");
  assert.equal(sec2.id, "sec-02-rules-known");
  assert.equal(sec1.units.length, 6);
  assert.equal(sec2.units.length, 7);
  assert.ok(
    sec1.units.some((u) =>
      u.lessons.some((l) => l.id === "lesson-01-06-02-section-one-jump"),
    ),
  );
  assert.ok(
    sec2.units.some((u) =>
      u.lessons.some((l) => l.id === "lesson-02-07-02-section-two-jump"),
    ),
  );
  const fullRing = serverBank.handLabsById["lab-02-07-01-full-ring-btn"];
  assert.equal(fullRing.tableSize, 9);
  // No player-type labels in sections 1–2.
  const early = JSON.stringify([sec1, sec2]);
  for (const label of [
    "Calling Station",
    "Nit",
    "Maniac",
    "TAG",
    "LAG",
  ]) {
    assert.equal(early.includes(label), false, `leaked ${label}`);
  }
});

test("invalid fixtures each fail validation", () => {
  const failures = runInvalidFixtureSuite();
  assert.deepEqual(failures, []);
});
