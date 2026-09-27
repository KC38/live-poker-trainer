/**
 * Isolation + engine parity for course live bridge.
 */

import {describe, expect, it} from "vitest";
import {HttpsError} from "firebase-functions/v2/https";
import {
  assertSetupKeyIsolation,
  calibrationHistoryAllowsComplete,
  courseCompletionWrites,
  courseReturnNodeId,
  isCourseModeRequest,
  parseCourseTableSetup,
} from "./course_live_bridge";
import {
  CALIBRATION_LAUNCH_LESSON_ID,
  allCuratedCourseHands,
  calibrationResultNodeId,
  curatedCourseHandById,
  curatedCourseHandForLab,
  isCourseSetupKey,
  pickCalibrationHand,
  pickWarmUpHand,
} from "./course_live_hands";
import {validateLiveHandDefinition} from "./live_hand_generation";
import {buildLiveSetupKey, DEFAULT_LIVE_SETUP} from "./live_setup";
import {
  applyLiveAction,
  createInitialLiveState,
  legalLiveActions,
  liveHeroToAct,
} from "./live_poker_engine";
import type {LiveHandDefinition, LiveHandState, LiveLegalAction} from "./live_types";

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

  it("every curated hand is a valid deal that reaches a Hero decision", () => {
    const hands = allCuratedCourseHands();
    expect(hands.length).toBeGreaterThanOrEqual(5);
    const ids = new Set(hands.map((hand) => hand.definition.handId));
    expect(ids.size).toBe(hands.length);

    for (const curated of hands) {
      const hand = curated.definition;
      expect(validateLiveHandDefinition(hand), hand.handId).toEqual([]);
      expect(curatedCourseHandById(hand.handId)).toBe(curated);
      const state = advanceVillainsToHero(hand);
      expect(state.status, hand.handId).toBe("playing");
      expect(liveHeroToAct(hand, state), hand.handId).toBe(true);
      expect(legalLiveActions(hand, state).length, hand.handId).toBeGreaterThan(0);
    }
  });

  it("resolves labs by spec id and wraps picker seeds", () => {
    expect(curatedCourseHandById("missing")).toBeUndefined();
    expect(curatedCourseHandForLab("no-such-lab")).toBeUndefined();
    expect(
      curatedCourseHandForLab("lab-01-06-01-bb-defend")?.definition.handId,
    ).toBe("course-lab-01-06-01-bb-defend");
    expect(
      curatedCourseHandForLab("lab-04-10-01-btn-vs-nit")?.kind,
    ).toBe("hand_lab");
    expect(pickWarmUpHand(-3).kind).toBe("warm_up");
    expect(pickWarmUpHand(-3).definition.handId).toBe(
      pickWarmUpHand(0).definition.handId,
    );
    expect(pickCalibrationHand(4).kind).toBe("calibration");
    expect(pickCalibrationHand(-1).definition.handId).toBe(
      pickCalibrationHand(0).definition.handId,
    );
  });

  it("rejects non-course setups and blank course ids", () => {
    expect(isCourseSetupKey("course-v1|hand|x")).toBe(true);
    expect(isCourseSetupKey("course-v1")).toBe(false);
    expect(isCourseSetupKey("course-v1-evil|hand")).toBe(false);
    expect(isCourseSetupKey("live-v3|random|s6")).toBe(false);

    expect(isCourseModeRequest({mode: "course"})).toBe(true);
    expect(isCourseModeRequest({mode: "random"})).toBe(false);
    expect(isCourseModeRequest({mode: "COURSE"})).toBe(false);
    expect(isCourseModeRequest(null)).toBe(false);
    expect(isCourseModeRequest([])).toBe(false);

    const rejects: Array<[unknown, RegExp]> = [
      [null, /tableSetup must be an object/],
      [[], /tableSetup must be an object/],
      [{mode: "random"}, /Expected course tableSetup\.mode/],
      [{mode: "course", courseKind: "tournament"}, /Invalid courseKind/],
    ];
    for (const [raw, message] of rejects) {
      expect(() => parseCourseTableSetup(raw)).toThrow(HttpsError);
      expect(() => parseCourseTableSetup(raw)).toThrow(message);
    }

    expect(parseCourseTableSetup({
      mode: "course",
      courseKind: "hand_lab",
      courseHandId: "  course-lab  ",
      handLabSpecId: " ",
      attemptId: " attempt ",
      lessonId: "",
    })).toEqual({
      mode: "course",
      courseKind: "hand_lab",
      courseHandId: "course-lab",
      handLabSpecId: undefined,
      attemptId: "attempt",
      activityId: undefined,
      lessonId: undefined,
      returnNodeId: undefined,
    });
  });

  it("forces the calibration result node and refuses a mismatched history", () => {
    const lessonId = CALIBRATION_LAUNCH_LESSON_ID;
    expect(courseReturnNodeId({
      courseKind: "warm_up",
      lessonId,
      returnNodeId: "activity-0",
    })).toBe(calibrationResultNodeId(lessonId));
    expect(courseReturnNodeId({
      courseKind: "hand_lab",
      lessonId: "lesson-other",
      returnNodeId: "node-9",
    })).toBe("node-9");
    expect(courseReturnNodeId({courseKind: "warm_up"})).toBeUndefined();

    expect(calibrationHistoryAllowsComplete(
      {kind: "calibration", lessonId: "lesson-other"},
      "lesson-other",
    )).toBe(false);
    expect(calibrationHistoryAllowsComplete(
      {kind: "calibration", lessonId},
      "lesson-other",
    )).toBe(false);
    expect(calibrationHistoryAllowsComplete(
      {kind: "calibration", lessonId: ""},
      lessonId,
    )).toBe(false);
  });
});

/**
 * Same villain priority as the course bridge: check, then call, then fold.
 * A curated hand that ends before Hero acts cannot be served.
 */
function advanceVillainsToHero(hand: LiveHandDefinition): LiveHandState {
  let state = createInitialLiveState(hand);
  for (let step = 0; step < 30; step++) {
    if (
      state.status !== "playing" ||
      typeof state.actorSeat !== "number" ||
      liveHeroToAct(hand, state)
    ) {
      return state;
    }
    const legal = legalLiveActions(hand, state);
    const pick = pickVillainAction(legal);
    if (!pick) return state;
    state = applyLiveAction({
      hand,
      state,
      actionId: pick.actionId,
    }).state;
  }
  return state;
}

function pickVillainAction(
  legal: LiveLegalAction[],
): LiveLegalAction | undefined {
  return legal.find((action) => action.kind === "CHECK") ??
    legal.find((action) => action.kind === "CALL") ??
    legal.find((action) => action.kind === "FOLD") ??
    legal[0];
}
