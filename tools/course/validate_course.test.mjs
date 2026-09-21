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


test("wave two sections expose postflop units, types, and jump tests", () => {
  const course = loadCourseJson(resolve(ROOT, "content/course/v2/course.json"));
  const {errors, clientCatalog, serverBank} = validateAndGenerate(course);
  assert.equal(errors.length, 0, errors.join("\n"));
  const sec3 = clientCatalog.sections[2];
  const sec4 = clientCatalog.sections[3];
  assert.equal(sec3.id, "sec-03-first-casino");
  assert.equal(sec4.id, "sec-04-regular-live");
  assert.equal(sec3.units.length, 8);
  assert.equal(sec4.units.length, 10);
  assert.ok(
    sec3.units.some((u) =>
      u.lessons.some((l) => l.id === "lesson-03-08-02-section-three-jump-test"),
    ),
  );
  assert.ok(
    sec4.units.some((u) =>
      u.lessons.some((l) => l.id === "lesson-04-10-02-section-four-jump-test"),
    ),
  );
  const sec3Blob = JSON.stringify(sec3);
  for (const label of ["Calling Station", "Nit", "Maniac", "TAG", "LAG"]) {
    assert.equal(sec3Blob.includes(label), false, `sec3 leaked ${label}`);
  }
  for (const id of [
    "lesson-04-06-02-meet-calling-station",
    "lesson-04-07-02-meet-nit",
    "lesson-04-08-02-meet-maniac",
  ]) {
    assert.ok(clientCatalog.sections.flatMap((s) =>
      s.units.flatMap((u) => u.lessons)).some((l) => l.id === id), id);
  }
  assert.ok(serverBank.handLabsById["lab-04-10-01-btn-vs-nit"]);
  assert.equal(serverBank.handLabsById["lab-04-10-01-btn-vs-nit"].tableSize, 9);
  const jump = course.sections[3].units
    .flatMap((u) => u.lessons)
    .find((l) => l.id === "lesson-04-10-02-section-four-jump-test");
  assert.ok(jump);
  assert.ok(jump.activities.every((a) => a.stage === "jump_test"));
});

test("wave three sections expose advanced units, TAG/LAG, and capstones", () => {
  const course = loadCourseJson(resolve(ROOT, "content/course/v2/course.json"));
  const {errors, clientCatalog} = validateAndGenerate(course);
  assert.equal(errors.length, 0, errors.join("\n"));
  const sec5 = clientCatalog.sections[4];
  const sec6 = clientCatalog.sections[5];
  const sec7 = clientCatalog.sections[6];
  assert.equal(sec5.id, "sec-05-winning-12");
  assert.equal(sec6.id, "sec-06-advanced-live");
  assert.equal(sec7.id, "sec-07-full-hand-integration");
  assert.equal(sec5.units.length, 9);
  assert.equal(sec6.units.length, 13);
  assert.equal(sec7.units.length, 12);
  const sec5Blob = JSON.stringify(sec5);
  for (const label of ["TAG", "LAG"]) {
    assert.equal(sec5Blob.includes(label), false, `sec5 leaked ${label}`);
  }
  for (const id of [
    "lesson-06-11-02-meet-tag",
    "lesson-06-12-02-meet-lag",
    "lesson-07-10-01-capstone-srp",
    "lesson-07-10-02-capstone-3bet",
    "lesson-07-10-03-capstone-multiway-deep",
    "lesson-07-12-01-five-type-final",
  ]) {
    assert.ok(
      clientCatalog.sections
        .flatMap((s) => s.units.flatMap((u) => u.lessons))
        .some((l) => l.id === id),
      id,
    );
  }
  const tag = course.playerTypes.find((p) => p.id === "tag");
  const lag = course.playerTypes.find((p) => p.id === "lag");
  assert.equal(tag?.introducedByLessonId, "lesson-06-11-02-meet-tag");
  assert.equal(lag?.introducedByLessonId, "lesson-06-12-02-meet-lag");
  const finalLesson = course.sections[6].units
    .flatMap((u) => u.lessons)
    .find((l) => l.id === "lesson-07-12-01-five-type-final");
  assert.ok(finalLesson);
  assert.deepEqual(
    [...finalLesson.playerTypeRefs].sort(),
    ["calling_station", "lag", "maniac", "nit", "tag"],
  );
});

test("invalid fixtures each fail validation", () => {
  const failures = runInvalidFixtureSuite();
  assert.deepEqual(failures, []);
});
