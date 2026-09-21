/**
 * Isolation + engine parity for course live bridge.
 */

import {describe, expect, it} from "vitest";
import {
  assertSetupKeyIsolation,
  calibrationHistoryAllowsComplete,
  courseCompletionWrites,
  courseReturnNodeId,
  parseCourseTableSetup,
} from "./course_live_bridge";
import {
  CALIBRATION_LAUNCH_LESSON_ID,
  allCuratedCourseHands,
  calibrationResultNodeId,
  isCourseSetupKey,
  pickWarmUpHand,
} from "./course_live_hands";
import {buildLiveSetupKey, DEFAULT_LIVE_SETUP} from "./live_setup";
import {
  createInitialLiveState,
  legalLiveActions,
} from "./live_poker_engine";

describe("course live bridge isolation", () => {
  it("uses course-v1 keys distinct from live-v3 random pools", () => {
    const liveKey = buildLiveSetupKey(DEFAULT_LIVE_SETUP);
    for (const hand of allCuratedCourseHands()) {
      expect(isCourseSetupKey(hand.definition.setupKey)).toBe(true);
      expect(hand.definition.setup.mode).toBe("course");
      expect(hand.definition.source).toBe("course_authored");
      assertSetupKeyIsolation(liveKey, hand.definition.setupKey);
      expect(hand.definition.setupKey.startsWith("live-v3|")).toBe(false);
    }
  });

  it("never writes live progress collections on course completion", () => {
    expect(courseCompletionWrites()).toEqual({
      liveProgress: false,
      liveHandHistory: false,
      liveHandReceipts: false,
      courseLiveHistory: true,
    });
  });

  it("parses course tableSetup and rejects wrong mode helpers", () => {
    const parsed = parseCourseTableSetup({
      mode: "course",
      courseKind: "warm_up",
    });
    expect(parsed.mode).toBe("course");
    expect(parsed.courseKind).toBe("warm_up");
  });

  it("calibration return node is the lesson result, not the lesson id", () => {
    const lessonId = CALIBRATION_LAUNCH_LESSON_ID;
    expect(courseReturnNodeId({
      courseKind: "calibration",
      lessonId,
      returnNodeId: lessonId,
    })).toBe(calibrationResultNodeId(lessonId));
    expect(courseReturnNodeId({
      courseKind: "calibration",
      lessonId,
      returnNodeId: lessonId,
    })).not.toBe(lessonId);
    expect(calibrationHistoryAllowsComplete(null, lessonId)).toBe(false);
    expect(calibrationHistoryAllowsComplete(
      {kind: "warm_up", lessonId},
      lessonId,
    )).toBe(false);
    expect(calibrationHistoryAllowsComplete(
      {kind: "calibration", lessonId},
      lessonId,
    )).toBe(true);
  });

  it("engine accepts curated course hands (parity with live definitions)", () => {
    const curated = pickWarmUpHand();
    const state = createInitialLiveState(curated.definition);
    const legal = legalLiveActions(curated.definition, state);
    expect(state.status).toBe("playing");
    expect(legal.length).toBeGreaterThan(0);
    expect(
      legal.every((action) => typeof action.actionId === "string"),
    ).toBe(true);
  });
});
