/**
 * Live tree expansion must stream seat waits and a coaching phase.
 */

import {describe, expect, test} from "vitest";
import {
  createInitialLiveState,
  hashLiveState,
  legalLiveActions,
} from "./live_poker_engine";
import {generateTendencyProfile} from "./tendency_profiles";
import {expandLiveHeroAction, type PreparedLiveNode} from "./live_tree";
import {
  COACHING_SCHEMA_VERSION,
  LIVE_PAYLOAD_VERSION,
  type CoachingRubric,
  type LiveHandDefinition,
} from "./live_types";

function hand(): LiveHandDefinition {
  return {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "live-hand-v3.0",
    handId: "tree-hand",
    setupKey: "tree-setup",
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
        tendency: generateTendencyProfile("TAG", "tree"),
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
      promptTokenCount: 40,
      candidatesTokenCount: 8,
      thoughtsTokenCount: 4,
      totalTokenCount: 52,
    },
  }), {status: 200, headers: {"Content-Type": "application/json"}});
}

function rubricFor(legalActionIds: string[], stateHash: string): CoachingRubric {
  return {
    schemaVersion: COACHING_SCHEMA_VERSION,
    stateHash,
    generatedBy: "test",
    criticModel: "test",
    assessments: legalActionIds.map((actionId, index) => ({
      actionId,
      rating: index === 0 ? "recommended" as const : "reasonable" as const,
      confidence: "medium" as const,
      summary: "Test coaching.",
      playerTypeReason: "Visible TAG profile.",
      sizingNote: "",
      tendencyKeys: ["pfr"],
    })),
  };
}

describe("expandLiveHeroAction feed", () => {
  test("publishes waitingOnSeat while villains act, then coaching", async () => {
    const definition = hand();
    const state = createInitialLiveState(definition);
    const legal = legalLiveActions(definition, state);
    const call = legal.find((action) => action.kind === "CALL") ?? legal[0];
    const parent: PreparedLiveNode = {
      stateHash: hashLiveState(state, []),
      state,
      history: [],
      legalActions: legal,
      rubric: rubricFor(legal.map((action) => action.actionId), hashLiveState(state, [])),
    };

    const feed: Array<{
      status: string;
      waitingOnSeat: number | null;
      eventKinds: string[];
    }> = [];

    await expandLiveHeroAction({
      apiKey: "test",
      hand: definition,
      parent,
      actionId: call.actionId,
      onFeed: async (update) => {
        feed.push({
          status: update.status,
          waitingOnSeat: update.waitingOnSeat,
          eventKinds: update.events.map((event) => event.kind),
        });
      },
      fetchImpl: async (_url, init) => {
        const request = JSON.parse(String(init?.body ?? "{}")) as {
          contents?: Array<{parts?: Array<{text?: string}>}>;
        };
        const userText = request.contents?.[0]?.parts?.[0]?.text ?? "";
        const user = JSON.parse(userText) as {
          task?: string;
          facts?: {legalActions?: Array<{actionId: string}>};
          legalActions?: Array<{actionId: string}>;
        };
        if (user.task === "draft" || user.task === "critique") {
          const ids = (user.facts?.legalActions ?? []).map((action) => action.actionId);
          return geminiResponse({
            assessments: rubricFor(ids, "child").assessments,
          });
        }
        const legalIds = (user.legalActions ?? []).map((action) => action.actionId);
        const check = legalIds.find((id) => id.startsWith("CHECK")) ?? legalIds[0];
        return geminiResponse({actionId: check});
      },
    });

    expect(feed.length).toBeGreaterThanOrEqual(2);
    expect(feed[0]).toMatchObject({
      status: "acting",
      eventKinds: expect.arrayContaining([call.kind]),
    });
    expect(feed.some((update) =>
      update.status === "acting" && update.waitingOnSeat === 1
    )).toBe(true);
    const coaching = feed.filter((update) => update.status === "coaching");
    expect(coaching.length).toBeGreaterThanOrEqual(1);
    expect(coaching.every((update) => update.waitingOnSeat === null)).toBe(true);
  });
});
