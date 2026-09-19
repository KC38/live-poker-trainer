/**
 * Contract tests for deal-only Gemini generation.
 */

import {describe, expect, test} from "vitest";
import {generateLiveHandDefinition} from "./live_hand_generation";
import {DEFAULT_LIVE_SETUP, buildLiveSetupKey} from "./live_setup";

function response(deal: unknown): Response {
  return new Response(JSON.stringify({
    candidates: [{
      content: {
        parts: [{text: JSON.stringify(deal)}],
      },
    }],
  }), {
    status: 200,
    headers: {"Content-Type": "application/json"},
  });
}

const deal = {
  buttonSeat: 4,
  stacks: [
    {seat: 0, startingStack: 400},
    {seat: 1, startingStack: 180},
    {seat: 2, startingStack: 260},
    {seat: 3, startingStack: 80},
    {seat: 4, startingStack: 320},
    {seat: 5, startingStack: 400},
  ],
  holeCards: [
    {seat: 0, cards: ["Ah", "Qd"]},
    {seat: 1, cards: ["Ks", "Kh"]},
    {seat: 2, cards: ["Jc", "Tc"]},
    {seat: 3, cards: ["9s", "9h"]},
    {seat: 4, cards: ["7c", "6c"]},
    {seat: 5, cards: ["Ad", "Kd"]},
  ],
  runout: ["2s", "3d", "4h", "8d", "Qc"],
};

describe("live hand generation", () => {
  test("Gemini authors only immutable deal fields", async () => {
    let requestBody = "";
    const hand = await generateLiveHandDefinition({
      apiKey: "test-key",
      setup: DEFAULT_LIVE_SETUP,
      setupKey: buildLiveSetupKey(DEFAULT_LIVE_SETUP),
      variationSeed: "deal-contract",
      fetchImpl: async (_url, init) => {
        requestBody = String(init?.body ?? "");
        return response(deal);
      },
    });

    expect(hand.buttonSeat).toBe(4);
    expect(hand.seats).toHaveLength(6);
    expect(hand.seats[0].archetype).toBe("HERO");
    expect(hand.seats.slice(1).every((seat) => seat.tendency)).toBe(true);
    expect(hand.runout).toEqual(deal.runout);
    expect(requestBody).toContain("orderedLineup");
    const request = JSON.parse(requestBody) as {
      generationConfig: {
        responseJsonSchema: {properties: Record<string, unknown>};
      };
    };
    expect(
      Object.keys(request.generationConfig.responseJsonSchema.properties),
    ).toEqual(["buttonSeat", "stacks", "holeCards", "runout"]);
  });

  test("rejects duplicate cards instead of publishing the deal", async () => {
    const duplicate = {
      ...deal,
      runout: ["Ah", "3d", "4h", "8d", "Qc"],
    };
    await expect(generateLiveHandDefinition({
      apiKey: "test-key",
      setup: DEFAULT_LIVE_SETUP,
      setupKey: buildLiveSetupKey(DEFAULT_LIVE_SETUP),
      variationSeed: "duplicate",
      fetchImpl: async () => response(duplicate),
    })).rejects.toThrow("globally unique");
  });
});
