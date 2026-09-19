/**
 * Unit tests for setup key canonicalization.
 */

import {describe, expect, it} from "vitest";
import {
  buildSetupKey,
  normalizeArchetype,
  parseTableSetupInput,
} from "./setup_key";

describe("setup_key", () => {
  it("builds normalized random pool keys", () => {
    const setup = parseTableSetupInput({
      mode: "random",
      seatCount: 6,
      smallBlind: 1,
      bigBlind: 2,
      startingStack: 200,
    });
    expect(buildSetupKey(setup)).toBe(
      "random|s6|stack200|sb1|bb2|ante0",
    );
  });

  it("includes ante when present", () => {
    const setup = parseTableSetupInput({
      mode: "random",
      seatCount: 6,
      smallBlind: 1,
      bigBlind: 2,
      ante: 0.5,
      startingStack: 200,
    });
    expect(buildSetupKey(setup)).toBe(
      "random|s6|stack200|sb1|bb2|ante0.5",
    );
  });

  it("builds exact custom keys with ordered archetypes", () => {
    const setup = parseTableSetupInput({
      mode: "custom",
      seatCount: 3,
      smallBlind: 1,
      bigBlind: 2,
      startingStack: 100,
      buttonSeat: 0,
      heroSeat: 1,
      lineup: [
        {seat: 0, archetype: "TAG"},
        {seat: 1, archetype: "HERO"},
        {seat: 2, archetype: "maniac"},
      ],
    });
    expect(buildSetupKey(setup)).toBe(
      "custom|s3|stack100|sb1|bb2|ante0|btn0|hero1|lineupTAG,HERO,MANIAC",
    );
  });

  it("rejects custom lineup without exactly one hero", () => {
    expect(() =>
      parseTableSetupInput({
        mode: "custom",
        seatCount: 2,
        smallBlind: 1,
        bigBlind: 2,
        startingStack: 100,
        buttonSeat: 0,
        heroSeat: 0,
        lineup: [
          {seat: 0, archetype: "TAG"},
          {seat: 1, archetype: "NIT"},
        ],
      }),
    ).toThrow(/HERO/);
  });

  it("normalizes archetype aliases", () => {
    expect(normalizeArchetype("calling station")).toBe("CALLING_STATION");
    expect(normalizeArchetype("YOU")).toBe("HERO");
  });

  it("canonicalizes all money fields to cents", () => {
    const setup = parseTableSetupInput({
      mode: "random",
      seatCount: 6,
      smallBlind: 0.1,
      bigBlind: 0.2,
      ante: 0.05,
      startingStack: 4,
    });
    expect(setup).toMatchObject({
      smallBlind: 0.1,
      bigBlind: 0.2,
      ante: 0.05,
      startingStack: 4,
    });
    expect(buildSetupKey(setup)).toBe(
      "random|s6|stack4|sb0.1|bb0.2|ante0.05",
    );
  });

  it.each([
    ["smallBlind", {smallBlind: 0}],
    ["smallBlind", {smallBlind: 500.01}],
    ["bigBlind", {bigBlind: 0.01}],
    ["bigBlind", {bigBlind: 1000.01}],
    ["bigBlind", {smallBlind: 3, bigBlind: 2}],
    ["ante", {ante: 2.01}],
    ["startingStack", {startingStack: 39.99}],
    ["startingStack", {startingStack: 1000.01}],
    ["2 decimal", {smallBlind: 1.001}],
    ["finite", {bigBlind: Number.POSITIVE_INFINITY}],
  ])("rejects invalid %s bounds", (_label, override) => {
    expect(() => parseTableSetupInput({
      mode: "random",
      seatCount: 6,
      smallBlind: 1,
      bigBlind: 2,
      ante: 0,
      startingStack: 100,
      ...override,
    })).toThrow();
  });

  it("accepts inclusive 20 and 500 big-blind stack bounds", () => {
    for (const startingStack of [40, 1000]) {
      expect(parseTableSetupInput({
        mode: "random",
        seatCount: 6,
        smallBlind: 1,
        bigBlind: 2,
        startingStack,
      }).startingStack).toBe(startingStack);
    }
  });
});
