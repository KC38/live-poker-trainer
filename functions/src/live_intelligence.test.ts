/**
 * Information-boundary tests for live Gemini calls.
 */

import {describe, expect, test} from "vitest";
import {
  chooseVillainAction,
  generateCoachingRubric,
} from "./live_intelligence";
import {
  createInitialLiveState,
  legalLiveActions,
} from "./live_poker_engine";
import {
  LIVE_PAYLOAD_VERSION,
  type LiveHandDefinition,
} from "./live_types";
import {generateTendencyProfile} from "./tendency_profiles";

function hand(): LiveHandDefinition {
  return {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "live-hand-v3.0",
    handId: "intel-hand",
    setupKey: "intel-setup",
    setup: {
      mode: "random",
      seatCount: 2,
      smallBlind: 1,
      bigBlind: 2,
      maxStackDepthBb: 200,
      heroSeat: 0,
    },
    buttonSeat: 0,
    seats: [
      {
        seat: 0,
        name: "Hero",
        archetype: "HERO",
        startingStack: 400,
        holeCards: ["Ah", "Qd"],
      },
      {
        seat: 1,
        name: "Alex",
        archetype: "TAG",
        startingStack: 400,
        holeCards: ["Ks", "Kh"],
        tendency: generateTendencyProfile("TAG", "intel"),
      },
    ],
    runout: ["2c", "3d", "4h", "8s", "9c"],
    source: "gemini",
    modelId: "test",
  };
}

function geminiResponse(value: unknown): Response {
  return new Response(JSON.stringify({
    candidates: [{content: {parts: [{text: JSON.stringify(value)}]}}],
    usageMetadata: {
      promptTokenCount: 50,
      candidatesTokenCount: 10,
      thoughtsTokenCount: 5,
      totalTokenCount: 65,
    },
  }), {status: 200, headers: {"Content-Type": "application/json"}});
}

describe("live intelligence boundaries", () => {
  test("villain prompt sees own cards but not Hero cards or runout", async () => {
    const definition = hand();
    const state = createInitialLiveState(definition);
    state.actorSeat = 1;
    const legal = legalLiveActions(definition, state);
    let body = "";
    const actionId = await chooseVillainAction({
      apiKey: "test",
      hand: definition,
      state,
      legalActions: legal,
      publicHistory: [],
      fetchImpl: async (_url, init) => {
        body = String(init?.body ?? "");
        return geminiResponse({actionId: legal[0].actionId});
      },
    });
    expect(actionId.actionId).toBe(legal[0].actionId);
    expect(actionId.usage.byPurpose.villain.modelRequestCount).toBe(1);
    expect(body).toContain("Ks");
    expect(body).toContain("Kh");
    expect(body).not.toContain("Ah");
    expect(body).not.toContain("Qd");
    expect(body).not.toContain("2c");
  });

  test("coach prompt sees Hero cards but never villain cards or future runout", async () => {
    const definition = hand();
    const state = createInitialLiveState(definition);
    const legal = legalLiveActions(definition, state);
    const bodies: string[] = [];
    const assessments = legal.map((action, index) => ({
      actionId: action.actionId,
      rating: index === 0 ? "recommended" : "reasonable",
      confidence: "medium",
      summary: "Uses public state and modeled ranges.",
      playerTypeReason: "The visible TAG profile is relevant.",
      sizingNote: "This is a fixed legal size.",
      tendencyKeys: ["pfr"],
    }));
    const rubric = await generateCoachingRubric({
      apiKey: "test",
      hand: definition,
      state,
      legalActions: legal,
      publicHistory: [],
      fetchImpl: async (_url, init) => {
        bodies.push(String(init?.body ?? ""));
        return geminiResponse({assessments});
      },
    });
    expect(rubric.rubric.assessments).toHaveLength(legal.length);
    expect(rubric.usage.byPurpose.coach_draft.modelRequestCount).toBe(1);
    expect(rubric.usage.byPurpose.coach_critique.modelRequestCount).toBe(1);
    expect(bodies).toHaveLength(2);
    for (const body of bodies) {
      expect(body).toContain("Ah");
      expect(body).toContain("Qd");
      expect(body).not.toContain("Ks");
      expect(body).not.toContain("Kh");
      expect(body).not.toContain("2c");
    }
  });
});
