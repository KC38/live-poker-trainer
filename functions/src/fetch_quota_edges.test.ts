/**
 * Edge-case tests for deal-to-prep quota conversion.
 */

import {describe, expect, it, vi} from "vitest";
import {
  convertDealReservationToPreparingPoll,
  isPreparingPollState,
  PREPARING_POLLS_PER_HOUR,
} from "./fetch_situation";
import type {Firestore} from "firebase-admin/firestore";

function quotaDb(
  initial: Record<string, unknown>,
): {db: Firestore; state: Record<string, unknown>} {
  const state = {...initial};
  const ref = {};
  const tx = {
    get: vi.fn().mockImplementation(async () => ({data: () => ({...state})})),
    set: vi.fn((_ref, value) => {
      Object.assign(state, value);
    }),
  };
  const doc = vi.fn(() => ({
    collection: vi.fn(() => ({doc: vi.fn(() => ref)})),
  }));
  const db = {
    collection: vi.fn(() => ({doc})),
    runTransaction: vi.fn((callback) => callback(tx)),
  } as unknown as Firestore;
  return {db, state};
}

describe("convertDealReservationToPreparingPoll", () => {
  it("does not convert a deal slot when preparing-poll quota is exhausted", async () => {
    const nowMs = Date.UTC(2026, 8, 18, 12, 30);
    const hourStart = Date.UTC(2026, 8, 18, 12);
    const quota = quotaDb({
      requestWindowStartMs: hourStart,
      requestCount: 40,
      pollWindowStartMs: hourStart,
      pollCount: PREPARING_POLLS_PER_HOUR,
      setupDay: "2026-09-18",
      setupKeys: ["known"],
    });

    await expect(convertDealReservationToPreparingPoll({
      db: quota.db,
      uid: "u",
      nowMs,
    })).rejects.toMatchObject({
      code: "resource-exhausted",
      message: expect.stringContaining("Preparing poll limit reached"),
    });

    expect(quota.state.requestCount).toBe(40);
    expect(quota.state.pollCount).toBe(PREPARING_POLLS_PER_HOUR);
  });
});

describe("isPreparingPollState empty-doc edge", () => {
  it("treats an existing empty setup with no generation status as prep", () => {
    expect(isPreparingPollState({
      exists: true,
      situationCount: 0,
    })).toBe(true);
  });
});
