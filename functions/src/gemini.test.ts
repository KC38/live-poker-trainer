/**
 * Unit tests for the Gemini REST structured-output contract.
 */

import { describe, expect, it } from "vitest";
import {
  GEMINI_GENERATION_CONFIG,
  GEMINI_INITIAL_GENERATION_CONFIG,
  SITUATION_RESPONSE_JSON_SCHEMA,
  normalizePayload,
} from "./gemini";

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
    expect(heroNode.properties.actions.maxItems).toBe(4);
    expect(SITUATION_RESPONSE_JSON_SCHEMA.properties.nodes.maxProperties).toBe(
      20,
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
});
