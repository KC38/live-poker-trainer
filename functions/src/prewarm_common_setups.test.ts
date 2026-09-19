/**
 * Unit tests for common Random Pool pre-warm helpers.
 */

import {describe, expect, it, vi} from "vitest";
import {
  commonRandomSetups,
  prewarmCommonSituationPools,
} from "./prewarm_common_setups";
import {buildSetupKey} from "./setup_key";
import {NEVER_SERVED_LOW_WATER} from "./situation_types";

describe("commonRandomSetups", () => {
  it("covers popular seat/stack combinations at 1/2 blinds", () => {
    const setups = commonRandomSetups();
    expect(setups).toHaveLength(4);
    for (const setup of setups) {
      expect(setup.mode).toBe("random");
      expect(setup.smallBlind).toBe(1);
      expect(setup.bigBlind).toBe(2);
      expect(setup.ante).toBe(0);
      expect([6, 9]).toContain(setup.seatCount);
      expect([200, 400]).toContain(setup.startingStack);
    }
    const keys = new Set(setups.map((s) => buildSetupKey(s)));
    expect(keys.size).toBe(4);
  });
});

describe("prewarmCommonSituationPools", () => {
  it("queues refill only when inventory is empty or at low water", async () => {
    const ensureSetup = vi.fn(async () => undefined);
    const queueRefill = vi.fn(async () => true);
    const get = vi.fn()
      .mockResolvedValueOnce({
        data: () => ({situationCount: 0, neverServedCount: 0}),
      })
      .mockResolvedValueOnce({
        data: () => ({
          situationCount: 10,
          neverServedCount: NEVER_SERVED_LOW_WATER,
        }),
      })
      .mockResolvedValueOnce({
        data: () => ({
          situationCount: 10,
          neverServedCount: NEVER_SERVED_LOW_WATER + 1,
        }),
      })
      .mockResolvedValueOnce({
        data: () => ({
          situationCount: 8,
          neverServedCount: NEVER_SERVED_LOW_WATER + 2,
        }),
      });

    const db = {
      collection: () => ({
        doc: () => ({
          get,
          collection: () => ({doc: () => ({})}),
        }),
      }),
    };

    const setups = commonRandomSetups();
    const results = await prewarmCommonSituationPools({
      db: db as never,
      setups,
      ensureSetup: ensureSetup as never,
      queueRefill: queueRefill as never,
    });

    expect(ensureSetup).toHaveBeenCalledTimes(4);
    expect(queueRefill).toHaveBeenCalledTimes(2);
    expect(results.map((r) => r.queued)).toEqual([
      true,
      true,
      false,
      false,
    ]);
  });
});
