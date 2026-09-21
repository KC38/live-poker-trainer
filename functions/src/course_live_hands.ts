/**
 * Curated course / warm-up live hand definitions.
 *
 * Isolated from Gemini live pools: setup keys use the course-v1 prefix and
 * hands live under courseLiveSetups. Static coaching is authored here for
 * deterministic early warm-ups and hand labs.
 */

import {generateTendencyProfile} from "./tendency_profiles";
import {
  LIVE_PAYLOAD_VERSION,
  type CoachingActionAssessment,
  type LiveHandDefinition,
  type LiveTableSetup,
} from "./live_types";

/** Course setup key prefix — never shares live-v3|random pools. */
export const COURSE_SETUP_PREFIX = "course-v1";

export type CourseHandKind = "warm_up" | "hand_lab" | "calibration";

export interface CuratedCourseHand {
  kind: CourseHandKind;
  handLabSpecId?: string;
  /** Optional lesson that launches this hand from Home. */
  launchLessonId?: string;
  definition: LiveHandDefinition;
  /** Static assessments keyed by actionId once legal actions are known. */
  staticFeedback: Record<string, Omit<CoachingActionAssessment, "actionId">>;
  /** Bucket → preferred assessment when exact actionId is unknown at author time. */
  bucketFeedback: Record<string, Omit<CoachingActionAssessment, "actionId">>;
  maxDecisions: number;
  scaffolding: "full" | "reduced" | "none";
  rexPrompt: string;
}

function courseSetup(
  handId: string,
  seatCount: number,
  maxStackDepthBb: number,
): LiveTableSetup {
  return {
    mode: "course",
    seatCount,
    smallBlind: 1,
    bigBlind: 2,
    maxStackDepthBb,
    heroSeat: 0,
  };
}

function buildSetupKey(handId: string): string {
  return `${COURSE_SETUP_PREFIX}|hand|${handId}`;
}

function baseAssessment(
  rating: CoachingActionAssessment["rating"],
  summary: string,
  playerTypeReason = "Uses the visible profile.",
  sizingNote = "Fixed legal size.",
): Omit<CoachingActionAssessment, "actionId"> {
  return {
    rating,
    confidence: "high",
    summary,
    playerTypeReason,
    sizingNote,
    tendencyKeys: ["pfr"],
  };
}

/** Section 2 Rex-guided warm-up: BTN faces a steal. */
const WARMUP_BTN_STEAL: CuratedCourseHand = {
  kind: "warm_up",
  launchLessonId: undefined,
  maxDecisions: 2,
  scaffolding: "full",
  rexPrompt: "Warm-up: defend or fold with a plan. I'll keep hints short.",
  definition: {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "course-hand-v1",
    handId: "course-warmup-btn-steal",
    setupKey: buildSetupKey("course-warmup-btn-steal"),
    setup: courseSetup("course-warmup-btn-steal", 6, 100),
    buttonSeat: 0,
    seats: [
      {
        seat: 0,
        name: "Hero",
        archetype: "HERO",
        startingStack: 200,
        holeCards: ["Ah", "Td"],
      },
      {
        seat: 1,
        name: "Sam",
        archetype: "TAG",
        startingStack: 200,
        holeCards: ["7c", "2d"],
        tendency: generateTendencyProfile("TAG", "course-warmup-btn"),
      },
      {
        seat: 2,
        name: "Riley",
        archetype: "CALLING_STATION",
        startingStack: 200,
        holeCards: ["9h", "3c"],
        tendency: generateTendencyProfile(
          "CALLING_STATION",
          "course-warmup-btn",
        ),
      },
      {
        seat: 3,
        name: "Jordan",
        archetype: "NIT",
        startingStack: 200,
        holeCards: ["Kd", "5s"],
        tendency: generateTendencyProfile("NIT", "course-warmup-btn"),
      },
      {
        seat: 4,
        name: "Casey",
        archetype: "LAG",
        startingStack: 200,
        holeCards: ["Qc", "Jd"],
        tendency: generateTendencyProfile("LAG", "course-warmup-btn"),
      },
      {
        seat: 5,
        name: "Alex",
        archetype: "MANIAC",
        startingStack: 200,
        holeCards: ["8s", "8h"],
        tendency: generateTendencyProfile("MANIAC", "course-warmup-btn"),
      },
    ],
    runout: ["2c", "7d", "Jh", "9s", "3h"],
    source: "course_authored",
    modelId: "course-static",
  },
  staticFeedback: {},
  bucketFeedback: {
    FOLD: baseAssessment(
      "questionable",
      "ATo on the button is usually a defend — folding is too tight here.",
    ),
    CALL: baseAssessment(
      "reasonable",
      "Calling keeps ATo in position; fine versus a steal.",
    ),
    OPEN_3_BB: baseAssessment(
      "recommended",
      "Open for value/isolation when folded to you on the button.",
    ),
    OPEN_4_BB: baseAssessment(
      "strong",
      "A slightly larger open is fine versus sticky blinds.",
    ),
    OPEN_5_BB: baseAssessment(
      "reasonable",
      "Big opens work versus calling stations; don't make it huge every time.",
    ),
    ALL_IN: baseAssessment(
      "clear_mistake",
      "Shoving ATo preflop in a cash game is rarely the plan.",
    ),
  },
};

/** Hand lab bridge for BB defend (Section 1). */
const LAB_BB_DEFEND: CuratedCourseHand = {
  kind: "hand_lab",
  handLabSpecId: "lab-01-06-01-bb-defend",
  maxDecisions: 1,
  scaffolding: "full",
  rexPrompt: "BB defend lab — pick the clean action; engine checks legality.",
  definition: {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "course-hand-v1",
    handId: "course-lab-01-06-01-bb-defend",
    setupKey: buildSetupKey("course-lab-01-06-01-bb-defend"),
    setup: {
      mode: "course",
      seatCount: 6,
      smallBlind: 1,
      bigBlind: 2,
      maxStackDepthBb: 100,
      heroSeat: 0,
    },
    // Hero is BB (seat 0), button at seat 4 so CO/BTN act before SB/BB.
    buttonSeat: 4,
    seats: [
      {
        seat: 0,
        name: "Hero",
        archetype: "HERO",
        startingStack: 200,
        holeCards: ["Kh", "Ts"],
      },
      {
        seat: 1,
        name: "Sam",
        archetype: "TAG",
        startingStack: 200,
        holeCards: ["As", "Kd"],
        tendency: generateTendencyProfile("TAG", "lab-bb"),
      },
      {
        seat: 2,
        name: "Riley",
        archetype: "NIT",
        startingStack: 200,
        holeCards: ["7h", "2c"],
        tendency: generateTendencyProfile("NIT", "lab-bb"),
      },
      {
        seat: 3,
        name: "Jordan",
        archetype: "CALLING_STATION",
        startingStack: 200,
        holeCards: ["9d", "4s"],
        tendency: generateTendencyProfile("CALLING_STATION", "lab-bb"),
      },
      {
        seat: 4,
        name: "Casey",
        archetype: "LAG",
        startingStack: 200,
        holeCards: ["Qh", "Jd"],
        tendency: generateTendencyProfile("LAG", "lab-bb"),
      },
      {
        seat: 5,
        name: "Alex",
        archetype: "MANIAC",
        startingStack: 200,
        holeCards: ["3c", "3d"],
        tendency: generateTendencyProfile("MANIAC", "lab-bb"),
      },
    ],
    runout: ["2c", "7d", "Jh", "9s", "3h"],
    source: "course_authored",
    modelId: "course-static",
  },
  staticFeedback: {},
  bucketFeedback: {
    FOLD: baseAssessment(
      "clear_mistake",
      "KTo in the big blind should defend versus a steal more often.",
      "Versus a wide open, folding KTo is too tight.",
    ),
    CALL: baseAssessment(
      "recommended",
      "Calling keeps KTo in a defended BB pot.",
    ),
    RAISE_50: baseAssessment(
      "strong",
      "3-betting KTo as a mix is fine versus a button steal.",
    ),
    RAISE_100: baseAssessment(
      "reasonable",
      "Larger 3-bets work; keep sizes consistent.",
    ),
    RERAISE_3X: baseAssessment(
      "strong",
      "A standard 3-bet size is a clean defend.",
    ),
    RERAISE_4X: baseAssessment(
      "reasonable",
      "Fine versus sticky stealers.",
    ),
    ALL_IN: baseAssessment(
      "clear_mistake",
      "Shoving KTo here is not the lesson plan.",
    ),
  },
};

/** Full-ring button lab (Section 2). */
const LAB_BTN_VS_CO: CuratedCourseHand = {
  kind: "hand_lab",
  handLabSpecId: "lab-02-07-01-full-ring-btn",
  maxDecisions: 1,
  scaffolding: "full",
  rexPrompt: "Button vs CO open — call or 3-bet with KQo.",
  definition: {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "course-hand-v1",
    handId: "course-lab-02-07-01-full-ring-btn",
    setupKey: buildSetupKey("course-lab-02-07-01-full-ring-btn"),
    setup: {
      mode: "course",
      seatCount: 9,
      smallBlind: 1,
      bigBlind: 2,
      maxStackDepthBb: 100,
      heroSeat: 0,
    },
    buttonSeat: 0,
    seats: [
      {
        seat: 0,
        name: "Hero",
        archetype: "HERO",
        startingStack: 200,
        holeCards: ["Kh", "Qd"],
      },
      ...[1, 2, 3, 4, 5, 6, 7, 8].map((seat) => ({
        seat,
        name: `Seat ${seat}`,
        archetype: (seat === 6 ? "TAG" : "NIT") as
          "TAG" | "NIT" | "CALLING_STATION" | "LAG" | "MANIAC",
        startingStack: 200,
        holeCards: (
          [
            ["2c", "3d"],
            ["4c", "5d"],
            ["6c", "7d"],
            ["8c", "9d"],
            ["Tc", "2d"],
            ["Jc", "3h"],
            ["As", "Kd"],
            ["4h", "5h"],
          ][seat - 1]
        ) as [string, string],
        tendency: generateTendencyProfile(
          seat === 6 ? "TAG" : "NIT",
          "lab-btn",
        ),
      })),
    ],
    runout: ["2c", "7d", "Jh", "9s", "3h"],
    source: "course_authored",
    modelId: "course-static",
  },
  staticFeedback: {},
  bucketFeedback: {
    FOLD: baseAssessment(
      "clear_mistake",
      "KQo on the button calls or 3-bets; folding is too tight.",
    ),
    CALL: baseAssessment(
      "reasonable",
      "Calling keeps KQo in position.",
    ),
    RERAISE_3X: baseAssessment(
      "recommended",
      "Strong offsuit broadway — value 3-bet is clean.",
    ),
    RERAISE_4X: baseAssessment(
      "strong",
      "A bit larger is fine versus sticky callers.",
    ),
    ALL_IN: baseAssessment(
      "clear_mistake",
      "Shoving KQo cold is not the lab plan.",
    ),
  },
};

/** BTN vs Nit lab (Section 4). */
const LAB_BTN_VS_NIT: CuratedCourseHand = {
  kind: "hand_lab",
  handLabSpecId: "lab-04-10-01-btn-vs-nit",
  maxDecisions: 1,
  scaffolding: "reduced",
  rexPrompt: "Nit in the blinds — widen value and skip thin bluffs.",
  definition: {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "course-hand-v1",
    handId: "course-lab-04-10-01-btn-vs-nit",
    setupKey: buildSetupKey("course-lab-04-10-01-btn-vs-nit"),
    setup: courseSetup("course-lab-04-10-01-btn-vs-nit", 6, 100),
    buttonSeat: 0,
    seats: [
      {
        seat: 0,
        name: "Hero",
        archetype: "HERO",
        startingStack: 200,
        holeCards: ["Ac", "Qc"],
      },
      {
        seat: 1,
        name: "Nit SB",
        archetype: "NIT",
        startingStack: 200,
        holeCards: ["7h", "2d"],
        tendency: generateTendencyProfile("NIT", "lab-nit"),
      },
      {
        seat: 2,
        name: "Nit BB",
        archetype: "NIT",
        startingStack: 200,
        holeCards: ["9s", "4c"],
        tendency: generateTendencyProfile("NIT", "lab-nit-bb"),
      },
      {
        seat: 3,
        name: "Sam",
        archetype: "TAG",
        startingStack: 200,
        holeCards: ["Kd", "5h"],
        tendency: generateTendencyProfile("TAG", "lab-nit"),
      },
      {
        seat: 4,
        name: "Riley",
        archetype: "CALLING_STATION",
        startingStack: 200,
        holeCards: ["Jh", "3c"],
        tendency: generateTendencyProfile("CALLING_STATION", "lab-nit"),
      },
      {
        seat: 5,
        name: "Jordan",
        archetype: "LAG",
        startingStack: 200,
        holeCards: ["8d", "8c"],
        tendency: generateTendencyProfile("LAG", "lab-nit"),
      },
    ],
    runout: ["2c", "7d", "Jh", "9s", "3h"],
    source: "course_authored",
    modelId: "course-static",
  },
  staticFeedback: {},
  bucketFeedback: {
    FOLD: baseAssessment(
      "clear_mistake",
      "AQs on the button opens versus nits.",
    ),
    OPEN_3_BB: baseAssessment(
      "recommended",
      "Standard open; nits fold too often from the blinds.",
    ),
    OPEN_4_BB: baseAssessment(
      "strong",
      "Slightly larger is fine when blinds are sticky nits.",
    ),
    ALL_IN: baseAssessment(
      "clear_mistake",
      "No need to jam AQs preflop here.",
    ),
  },
};

/** Section 7 calibration warm-up — reduced scaffolding. */
const CALIBRATION_SRP: CuratedCourseHand = {
  kind: "calibration",
  launchLessonId: "lesson-07-11-01-live-warmup-prep",
  maxDecisions: 3,
  scaffolding: "reduced",
  rexPrompt: "Calibration: one clean plan, less scaffolding. Trust your reads.",
  definition: {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "course-hand-v1",
    handId: "course-calibration-srp",
    setupKey: buildSetupKey("course-calibration-srp"),
    setup: courseSetup("course-calibration-srp", 6, 200),
    buttonSeat: 0,
    seats: [
      {
        seat: 0,
        name: "Hero",
        archetype: "HERO",
        startingStack: 400,
        holeCards: ["As", "Js"],
      },
      {
        seat: 1,
        name: "Sam",
        archetype: "TAG",
        startingStack: 400,
        holeCards: ["Kd", "9c"],
        tendency: generateTendencyProfile("TAG", "cal-srp"),
      },
      {
        seat: 2,
        name: "Riley",
        archetype: "CALLING_STATION",
        startingStack: 400,
        holeCards: ["7h", "7d"],
        tendency: generateTendencyProfile("CALLING_STATION", "cal-srp"),
      },
      {
        seat: 3,
        name: "Jordan",
        archetype: "NIT",
        startingStack: 400,
        holeCards: ["Qc", "2s"],
        tendency: generateTendencyProfile("NIT", "cal-srp"),
      },
      {
        seat: 4,
        name: "Casey",
        archetype: "LAG",
        startingStack: 400,
        holeCards: ["Th", "9h"],
        tendency: generateTendencyProfile("LAG", "cal-srp"),
      },
      {
        seat: 5,
        name: "Alex",
        archetype: "MANIAC",
        startingStack: 400,
        holeCards: ["5c", "5d"],
        tendency: generateTendencyProfile("MANIAC", "cal-srp"),
      },
    ],
    runout: ["Ah", "8c", "3d", "2h", "Kd"],
    source: "course_authored",
    modelId: "course-static",
  },
  staticFeedback: {},
  bucketFeedback: {
    FOLD: baseAssessment(
      "clear_mistake",
      "AJs on the button opens in a calibration SRP.",
    ),
    OPEN_3_BB: baseAssessment(
      "recommended",
      "Standard open — build the single-raised pot.",
    ),
    OPEN_4_BB: baseAssessment(
      "strong",
      "Slightly larger is fine; stay consistent next streets.",
    ),
    ALL_IN: baseAssessment(
      "clear_mistake",
      "Calibration is about streets, not a preflop shove.",
    ),
  },
};

const CURATED_BY_ID: Record<string, CuratedCourseHand> = {
  [WARMUP_BTN_STEAL.definition.handId]: WARMUP_BTN_STEAL,
  [LAB_BB_DEFEND.definition.handId]: LAB_BB_DEFEND,
  [LAB_BTN_VS_CO.definition.handId]: LAB_BTN_VS_CO,
  [LAB_BTN_VS_NIT.definition.handId]: LAB_BTN_VS_NIT,
  [CALIBRATION_SRP.definition.handId]: CALIBRATION_SRP,
};

const BY_LAB_SPEC: Record<string, CuratedCourseHand> = {
  "lab-01-06-01-bb-defend": LAB_BB_DEFEND,
  "lab-02-07-01-full-ring-btn": LAB_BTN_VS_CO,
  "lab-04-10-01-btn-vs-nit": LAB_BTN_VS_NIT,
};

const WARMUP_POOL = [WARMUP_BTN_STEAL];
const CALIBRATION_POOL = [CALIBRATION_SRP];

/** All curated course hands (tests + seeding). */
export function allCuratedCourseHands(): CuratedCourseHand[] {
  return Object.values(CURATED_BY_ID);
}

export function curatedCourseHandById(
  handId: string,
): CuratedCourseHand | undefined {
  return CURATED_BY_ID[handId];
}

export function curatedCourseHandForLab(
  handLabSpecId: string,
): CuratedCourseHand | undefined {
  return BY_LAB_SPEC[handLabSpecId];
}

export function pickWarmUpHand(seed = 0): CuratedCourseHand {
  return WARMUP_POOL[Math.abs(seed) % WARMUP_POOL.length];
}

export function pickCalibrationHand(seed = 0): CuratedCourseHand {
  return CALIBRATION_POOL[Math.abs(seed) % CALIBRATION_POOL.length];
}

export function isCourseSetupKey(setupKey: string): boolean {
  return setupKey.startsWith(`${COURSE_SETUP_PREFIX}|`);
}
