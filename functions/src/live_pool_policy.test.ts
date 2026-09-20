/**
 * Inventory and root-warming policy tests.
 */

import {describe, expect, test} from "vitest";
import {shouldRefillLiveUnseen} from "./live_pool";
import {selectWarmActionIds, type PreparedLiveNode} from "./live_tree";
import {
  COACHING_SCHEMA_VERSION,
  type CoachingActionAssessment,
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
});
