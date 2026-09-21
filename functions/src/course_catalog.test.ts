import {execFileSync} from "node:child_process";
import {readFileSync} from "node:fs";
import {resolve} from "node:path";
import {describe, expect, it} from "vitest";
import {
  activityIdsInOrder,
  courseBank,
  lessonIdsInOrder,
  type CourseBank,
} from "./course_catalog";

const repoRoot = resolve(__dirname, "../..");

describe("course contract v2", () => {
  const bank = courseBank;
  const client = JSON.parse(
    readFileSync(resolve(repoRoot, "assets/course/v2/catalog.json"), "utf8"),
  ) as CourseBank;

  it("loads a valid private bank with seven sections", () => {
    expect(bank.scope).toBe("live_cash_nlh");
    expect(bank.coachId).toBe("rex");
    expect(bank.sections).toHaveLength(7);
    expect(bank.playerTypes).toHaveLength(5);
    expect(Object.keys(bank.gradingByActivityId).length).toBeGreaterThan(0);
    expect(Object.keys(bank.handLabsById).length).toBeGreaterThan(0);
    expect(bank.contentChecksum).toBeTruthy();
  });

  it("shares version, checksum, and id order with the client catalog", () => {
    expect(client.catalogVersion).toBe(bank.catalogVersion);
    expect(client.contentChecksum).toBe(bank.contentChecksum);
    expect(lessonIdsInOrder(client)).toEqual(lessonIdsInOrder(bank));
    expect(activityIdsInOrder(client)).toEqual(activityIdsInOrder(bank));
  });

  it("keeps private grading out of the client catalog", () => {
    const raw = readFileSync(
      resolve(repoRoot, "assets/course/v2/catalog.json"),
      "utf8",
    );
    for (const token of [
      '"grading"',
      '"feedback"',
      '"correctSequence"',
      '"lifeLossEligible"',
      '"villainCards"',
      '"reversalRead"',
      '"missGrading"',
    ]) {
      expect(raw.includes(token)).toBe(false);
    }
  });

  it("rejects deliberately invalid fixtures via the validator CLI", () => {
    const output = execFileSync(
      process.execPath,
      [resolve(repoRoot, "tools/course/validate_course.mjs"), "--validate-only"],
      {encoding: "utf8", cwd: repoRoot},
    );
    expect(output).toContain("validate_course: ok");
  });
});
