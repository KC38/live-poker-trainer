/**
 * Inventory and root-warming policy tests.
 */

import {Timestamp} from "firebase-admin/firestore";
import {describe, expect, test} from "vitest";
import {
  actionDocId,
  isQueuedLiveGeneration,
  isQueuedLiveGenerationJob,
  liveLeaseExpired,
  preparedNodeFromData,
  shouldRefillLiveUnseen,
} from "./live_pool";
import {selectWarmActionIds, type PreparedLiveNode} from "./live_tree";
import {
  COACHING_SCHEMA_VERSION,
  type CoachingActionAssessment,
  type LiveActionBucket,
  type LiveActionKind,
  type LiveLegalAction,
} from "./live_types";

const actions: LiveLegalAction[] = [
  {actionId: "FOLD", kind: "FOLD", bucket: "FOLD", label: "Fold"},
  {actionId: "CALL:600", kind: "CALL", bucket: "CALL", amountTo: 6, label: "Call"},
  {
    actionId: "RERAISE_3X:1800",
    kind: "RAISE",
    bucket: "RERAISE_3X",
    amountTo: 18,
    label: "Raise to $18",
  },
  {
    actionId: "RERAISE_4X:2400",
    kind: "RAISE",
    bucket: "RERAISE_4X",
    amountTo: 24,
    label: "Raise to $24",
  },
  {
    actionId: "ALL_IN:40000",
    kind: "ALL_IN",
    bucket: "ALL_IN",
    amountTo: 400,
    label: "All-in",
  },
];

function assessment(
  actionId: string,
  rating: CoachingActionAssessment["rating"],
): CoachingActionAssessment {
  return {
    actionId,
    rating,
    confidence: "medium",
    summary: "Test",
    playerTypeReason: "Test",
    sizingNote: "Test",
    tendencyKeys: ["pfr"],
  };
}

describe("live pool policy", () => {
  test("queues ten more at five unseen but not six", () => {
    expect(shouldRefillLiveUnseen(6)).toBe(false);
    expect(shouldRefillLiveUnseen(5)).toBe(true);
    expect(shouldRefillLiveUnseen(0)).toBe(true);
  });

  test("warms passive, recommended, and standard aggressive branches", () => {
    const node = {
      stateHash: "root",
      state: {} as PreparedLiveNode["state"],
      history: [],
      legalActions: actions,
      rubric: {
        schemaVersion: COACHING_SCHEMA_VERSION,
        stateHash: "root",
        generatedBy: "test",
        criticModel: "test",
        assessments: [
          assessment("FOLD", "reasonable"),
          assessment("CALL:600", "reasonable"),
          assessment("RERAISE_3X:1800", "recommended"),
          assessment("RERAISE_4X:2400", "strong"),
          assessment("ALL_IN:40000", "questionable"),
        ],
      },
    } satisfies PreparedLiveNode;
    expect(selectWarmActionIds(node)).toEqual([
      "CALL:600",
      "RERAISE_3X:1800",
      "RERAISE_4X:2400",
    ]);
  });

  test("never warms a fold, even when the rubric recommends it", () => {
    expect(selectWarmActionIds(warmNode([
      legal("FOLD", "FOLD", "FOLD"),
    ], [["FOLD", "recommended"]]))).toEqual([]);

    expect(selectWarmActionIds(warmNode([
      legal("FOLD", "FOLD", "FOLD"),
      legal("CALL:600", "CALL", "CALL"),
      legal("BET_67:1200", "BET", "BET_67"),
    ], [["NOPE", "recommended"]]))).toEqual([
      "CALL:600",
      "BET_67:1200",
    ]);
  });

  test("does not duplicate the passive line and stops at three branches", () => {
    expect(selectWarmActionIds(warmNode([
      legal("FOLD", "FOLD", "FOLD"),
      legal("CHECK", "CHECK", "CHECK"),
      legal("BET_33:400", "BET", "BET_33"),
      legal("RAISE_50:900", "RAISE", "RAISE_50"),
    ], [["CHECK", "recommended"]]))).toEqual([
      "CHECK",
      "RAISE_50:900",
      "BET_33:400",
    ]);

    expect(selectWarmActionIds(warmNode([
      legal("CHECK", "CHECK", "CHECK"),
      legal("BET_67:800", "BET", "BET_67"),
      legal("OPEN_4_BB:800", "RAISE", "OPEN_4_BB"),
      legal("RERAISE_4X:1600", "RAISE", "RERAISE_4X"),
      legal("ALL_IN:4000", "ALL_IN", "ALL_IN"),
    ]))).toEqual([
      "CHECK",
      "BET_67:800",
      "OPEN_4_BB:800",
    ]);

    expect(selectWarmActionIds(warmNode([
      legal("CHECK", "CHECK", "CHECK"),
      legal("CHECK", "CHECK", "CHECK"),
      legal("BET_67:800", "BET", "BET_67"),
    ]))).toEqual(["CHECK", "BET_67:800"]);
  });
});

describe("live generation gates", () => {
  test("a lease is expired at the deadline, including a missing one", () => {
    expect(liveLeaseExpired(1_000, 1_000)).toBe(true);
    expect(liveLeaseExpired(1_001, 1_000)).toBe(false);
    expect(liveLeaseExpired(0, 1_000)).toBe(true);
    expect(liveLeaseExpired(null, 1_000)).toBe(true);
    expect(liveLeaseExpired(undefined, 1_000)).toBe(true);
    expect(liveLeaseExpired(Timestamp.fromMillis(1_000), 1_000)).toBe(true);
    expect(liveLeaseExpired(Timestamp.fromMillis(1_001), 1_000)).toBe(false);
    // Non-finite expiry does not compare as due, so recovery will not clear it.
    expect(liveLeaseExpired(Number.NaN, 1_000)).toBe(false);
  });

  test("only a queued setup or job is eligible to run", () => {
    expect(isQueuedLiveGeneration(undefined)).toBe(false);
    expect(isQueuedLiveGeneration({})).toBe(false);
    expect(isQueuedLiveGeneration({generation: {status: "generating"}})).toBe(false);
    expect(isQueuedLiveGeneration({generation: {status: "queued"}})).toBe(true);
    expect(isQueuedLiveGenerationJob(undefined)).toBe(false);
    expect(isQueuedLiveGenerationJob({status: "running"})).toBe(false);
    expect(isQueuedLiveGenerationJob({status: "queued"})).toBe(true);
  });

  test("prepared nodes reject incomplete writes and default a missing rubric", () => {
    expect(() => preparedNodeFromData({})).toThrow(/invalid prepared node data/);
    expect(() => preparedNodeFromData({
      stateHash: 1,
      state: {street: "flop"},
      history: [],
      legalActions: [],
    })).toThrow(/invalid prepared node data/);
    expect(() => preparedNodeFromData({
      stateHash: "root",
      state: null,
      history: [],
      legalActions: [],
    })).toThrow(/invalid prepared node data/);
    expect(() => preparedNodeFromData({
      stateHash: "root",
      state: {street: "flop"},
      history: "not-a-list",
      legalActions: [],
    })).toThrow(/invalid prepared node data/);

    const node = preparedNodeFromData({
      stateHash: "root",
      state: {street: "flop"},
      history: [],
      legalActions: [{actionId: "CHECK", kind: "CHECK"}],
    });
    expect(node.stateHash).toBe("root");
    expect(node.history).toEqual([]);
    expect(node.legalActions).toHaveLength(1);
    expect(node.rubric).toBeNull();
  });

  test("action ids become Firestore-safe document ids", () => {
    expect(actionDocId("CALL:600")).toBe(
      Buffer.from("CALL:600").toString("base64url"),
    );
    const encoded = actionDocId("a/b+c=");
    expect(encoded).not.toMatch(/[+/]/);
    expect(actionDocId("a/b+c=")).not.toBe(actionDocId("a/b+c"));
  });
});

function legal(
  actionId: string,
  kind: LiveActionKind,
  bucket: LiveActionBucket,
): LiveLegalAction {
  return {actionId, kind, bucket, label: actionId};
}

function warmNode(
  legalActions: LiveLegalAction[],
  ratings?: Array<[string, CoachingActionAssessment["rating"]]>,
): PreparedLiveNode {
  return {
    stateHash: "root",
    state: {} as PreparedLiveNode["state"],
    history: [],
    legalActions,
    rubric: ratings == null ? null : {
      schemaVersion: COACHING_SCHEMA_VERSION,
      stateHash: "root",
      generatedBy: "test",
      criticModel: "test",
      assessments: ratings.map(([actionId, rating]) => assessment(actionId, rating)),
    },
  };
}
