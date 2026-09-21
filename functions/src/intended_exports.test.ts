/**
 * Deployed callable names. v2 situation fetch/progress/pool exports stay gone.
 */

import {readFileSync} from "node:fs";
import {resolve} from "node:path";
import {describe, expect, it} from "vitest";

const INTENDED = [
  "startLiveHand",
  "submitLiveAction",
  "resumeLiveHand",
  "undoLiveAction",
  "initializeCourseProfile",
  "startCourseLesson",
  "submitCourseStep",
  "completeCourseLesson",
  "completeCalibrationWarmUp",
  "getLiveAccess",
  "getCourseState",
  "issueAnonymousProgressTransfer",
  "redeemAnonymousProgressTransfer",
  "refillLiveHandPool",
  "processLiveHandGenerationJob",
  "recoverLiveGenerationLeases",
  "cleanupExpiredCourseTransfersJob",
];

const FORBIDDEN = [
  "fetchSituation",
  "recordProgress",
  "generateSituation",
  "refillSituationPool",
];

describe("functions exports", () => {
  const source = readFileSync(resolve(__dirname, "index.ts"), "utf8");

  it("exports only the intended callables and triggers", () => {
    const exported = [...source.matchAll(/export const (\w+) =/g)].map(
      (match) => match[1],
    );
    expect(exported).toEqual(INTENDED);
  });

  it("does not export the removed v2 situation stack", () => {
    for (const name of FORBIDDEN) {
      expect(source).not.toContain(`export const ${name}`);
    }
  });
});
