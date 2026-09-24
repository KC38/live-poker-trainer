/**
 * Unit tests for live-training table setup parsing and pool keys.
 */

import {describe, expect, it} from "vitest";
import {HttpsError} from "firebase-functions/v2/https";
import {buildLiveSetupKey, parseLiveTableSetup} from "./live_setup";

const valid = {
  mode: "random",
  seatCount: 6,
  smallBlind: 1,
  bigBlind: 2,
  maxStackDepthBb: 200,
};

describe("parseLiveTableSetup", () => {
  it("accepts a supported random preset and pins hero to seat 0", () => {
    const setup = parseLiveTableSetup({...valid, heroSeat: 4});
    expect(setup).toEqual({
      mode: "random",
      seatCount: 6,
      smallBlind: 1,
      bigBlind: 2,
      maxStackDepthBb: 200,
      heroSeat: 0,
    });
    expect(buildLiveSetupKey(setup)).toBe(
      "live-v3|random|s6|max200bb|sb1|bb2",
    );
  });

  it("defaults mode to random and accepts the stackDepthBb alias", () => {
    const setup = parseLiveTableSetup({
      seatCount: 9,
      smallBlind: 0.5,
      bigBlind: 1,
      stackDepthBb: 50,
    });
    expect(setup.mode).toBe("random");
    expect(setup.maxStackDepthBb).toBe(50);
    expect(buildLiveSetupKey(setup)).toBe(
      "live-v3|random|s9|max50bb|sb0.5|bb1",
    );
  });

  it("rejects course mode, bad shapes, and unsupported presets", () => {
    const rejects: Array<[unknown, RegExp]> = [
      [null, /tableSetup must be an object/],
      [[], /tableSetup must be an object/],
      [{...valid, mode: "course"}, /course live bridge/],
      [{...valid, mode: "custom"}, /Only random lineups/],
      [{...valid, seatCount: 1}, /seatCount must be 2\.\.9/],
      [{...valid, seatCount: 10}, /seatCount must be 2\.\.9/],
      [{...valid, seatCount: 6.5}, /seatCount must be an integer/],
      [{...valid, bigBlind: 0.5, smallBlind: 1}, /bigBlind must be at least/],
      [{...valid, bigBlind: 3}, /supported app preset/],
      [{...valid, smallBlind: 0}, /smallBlind must be positive/],
      [{...valid, smallBlind: 1.001}, /at most two decimals/],
      [{...valid, maxStackDepthBb: 40}, /supported app preset/],
      [{...valid, maxStackDepthBb: 10}, /must be 20\.\.500/],
      [{...valid, maxStackDepthBb: 600}, /must be 20\.\.500/],
      [{...valid, maxStackDepthBb: undefined, stackDepthBb: undefined},
        /maxStackDepthBb must be an integer/],
    ];
    for (const [raw, message] of rejects) {
      expect(() => parseLiveTableSetup(raw)).toThrow(HttpsError);
      expect(() => parseLiveTableSetup(raw)).toThrow(message);
    }
  });
});
