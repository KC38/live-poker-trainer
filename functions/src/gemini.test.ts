/**
 * Unit tests for the Gemini REST structured-output contract.
 */

import { describe, expect, it, vi } from "vitest";
import {
  GEMINI_GENERATION_CONFIG,
  GEMINI_INITIAL_GENERATION_CONFIG,
  SITUATION_RESPONSE_JSON_SCHEMA,
  generateValidatedSituation,
  normalizePayload,
} from "./gemini";
import {minimalFoldSituation} from "./test_fixtures";

describe("Gemini generation config", () => {
  it("uses REST thinkingConfig and no sampling controls", () => {
    expect(GEMINI_GENERATION_CONFIG.thinkingConfig).toEqual({
      thinkingLevel: "medium",
    });
    expect(GEMINI_GENERATION_CONFIG.responseMimeType).toBe("application/json");
    expect(GEMINI_GENERATION_CONFIG).not.toHaveProperty("thinking_level");
    expect(GEMINI_GENERATION_CONFIG).not.toHaveProperty("temperature");
    expect(GEMINI_GENERATION_CONFIG).not.toHaveProperty("topP");
    expect(GEMINI_GENERATION_CONFIG).not.toHaveProperty("topK");
    expect(GEMINI_INITIAL_GENERATION_CONFIG.thinkingConfig).toEqual({
      thinkingLevel: "low",
    });
  });

  it("requires structured coaching fields on every hero edge", () => {
    const nodeUnion =
      SITUATION_RESPONSE_JSON_SCHEMA.properties.nodes.additionalProperties;
    const heroNode = nodeUnion.anyOf[0];
    const required = heroNode.properties.actions.items.required;

    expect(required).toEqual(
      expect.arrayContaining([
        "coaching",
        "verdict",
        "evDeltaBb",
        "optimalActionKey",
      ]),
    );
    expect(SITUATION_RESPONSE_JSON_SCHEMA.additionalProperties).toBe(false);
    expect(heroNode.properties.actions.minItems).toBe(2);
    expect(heroNode.properties.actions.maxItems).toBe(2);
    expect(SITUATION_RESPONSE_JSON_SCHEMA.properties.nodes.maxProperties).toBe(
      16,
    );
  });

  it("requires authoritative terminal payout fields", () => {
    const nodeUnion =
      SITUATION_RESPONSE_JSON_SCHEMA.properties.nodes.additionalProperties;
    const terminalNode = nodeUnion.anyOf[2];

    expect(terminalNode.required).toEqual(
      expect.arrayContaining(["stacks", "winnerSeats", "pot", "heroNetChips"]),
    );
    expect(terminalNode.properties.winnerSeats.minItems).toBe(1);
  });

  it("requires hole cards and folded snapshots", () => {
    expect(SITUATION_RESPONSE_JSON_SCHEMA.required).toContain("holeCards");
    const nodeUnion =
      SITUATION_RESPONSE_JSON_SCHEMA.properties.nodes.additionalProperties;
    for (const node of nodeUnion.anyOf) {
      expect(node.required).toContain("foldedSeats");
    }
  });

  it("documents the canonical root and forced-post ledger in the schema", () => {
    const rootDescription =
      SITUATION_RESPONSE_JSON_SCHEMA.properties.rootNodeId.description;
    const nodeUnion =
      SITUATION_RESPONSE_JSON_SCHEMA.properties.nodes.additionalProperties;
    const scriptedDescription = nodeUnion.anyOf[1].description;

    expect(rootDescription).toContain("canonical preflop scripted");
    expect(rootDescription).toContain("ante/SB/BB ledger");
    expect(scriptedDescription).toContain("forced-post action prefix");
  });

  it.each(["random", "custom"] as const)(
    "overrides %s lineup stacks with the canonical setup stack",
    (mode) => {
      const setup = {
        mode,
        seatCount: 2,
        smallBlind: 1,
        bigBlind: 2,
        startingStack: 200,
        ...(mode === "custom"
          ? {
              buttonSeat: 0,
              heroSeat: 0,
              lineup: [
                { seat: 0, archetype: "HERO" },
                { seat: 1, archetype: "TAG" },
              ],
            }
          : {}),
      };
      const normalized = normalizePayload(
        {
          lineup: [
            { seat: 0, archetype: "HERO", name: "Hero", startingStack: 999 },
            { seat: 1, archetype: "TAG", name: "Villain", startingStack: 1 },
          ],
        },
        setup,
        "key",
      );
      expect(normalized.lineup.map((seat) => seat.startingStack)).toEqual([
        200, 200,
      ]);
    },
  );

  it("normalizes common ten-card and casing variants before validation", () => {
    const payload = minimalFoldSituation();
    payload.heroHand = ["10H", "kd"];
    payload.holeCards[0].cards = ["10H", "kd"];

    const normalized = normalizePayload(
      payload,
      {
        mode: "random",
        seatCount: 2,
        smallBlind: 1,
        bigBlind: 2,
        ante: 0,
        startingStack: 200,
      },
      payload.setupKey,
    );

    expect(normalized.heroHand).toEqual(["Th", "Kd"]);
    expect(normalized.holeCards[0].cards).toEqual(["Th", "Kd"]);
  });

  it("repairs one candidate with exact feedback instead of regenerating", async () => {
    const invalid = structuredClone(minimalFoldSituation());
    const open = invalid.nodes.open;
    if (open.type !== "hero") throw new Error("expected hero node");
    open.actions = open.actions.filter(
      (action) => action.kind !== "CALL" && action.kind !== "ALL_IN",
    );
    const corrected = minimalFoldSituation();
    const responses = [invalid, invalid, corrected];
    const fetchImpl = vi.fn(async () => {
      const payload = responses.shift();
      return new Response(JSON.stringify({
        candidates: [{content: {parts: [{text: JSON.stringify(payload)}]}}],
        usageMetadata: {
          promptTokenCount: 100,
          candidatesTokenCount: 200,
          thoughtsTokenCount: 300,
          totalTokenCount: 600,
        },
      }), {status: 200});
    });

    const result = await generateValidatedSituation({
      apiKey: "secret",
      setup: {
        mode: "random",
        seatCount: 2,
        smallBlind: 1,
        bigBlind: 2,
        ante: 0,
        startingStack: 200,
      },
      fetchImpl: fetchImpl as typeof fetch,
      maxAttempts: 2,
    });

    expect(fetchImpl).toHaveBeenCalledTimes(3);
    const correctionBody = JSON.parse(
      String(fetchImpl.mock.calls[1][1]?.body),
    ) as {contents: Array<{parts: Array<{text: string}>}>};
    expect(correctionBody.contents[0].parts[0].text).toContain(
      "[coverage] node=open: facing a bet requires CALL or ALL_IN",
    );
    const repairBody = JSON.parse(
      String(fetchImpl.mock.calls[2][1]?.body),
    ) as {contents: Array<{parts: Array<{text: string}>}>};
    expect(repairBody.contents[0].parts[0].text).toContain(
      "[coverage] node=open: facing a bet requires CALL or ALL_IN",
    );
    expect(repairBody.contents[0].parts[0].text).not.toContain(
      "Batch variation seed:",
    );
    expect(result.validationFailureCount).toBeGreaterThanOrEqual(1);
    expect(result.usage).toMatchObject({
      modelRequestCount: 3,
      promptTokenCount: 300,
      candidatesTokenCount: 600,
      thoughtsTokenCount: 900,
      totalTokenCount: 1800,
    });
  });
});
