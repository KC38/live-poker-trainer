/**
 * Unit tests for Duolingo-style course heart replenishment.
 */

import {describe, expect, it} from "vitest";
import {
  AD_HEART_COOLDOWN_MS,
  AD_HEART_DAILY_MAX,
  adHeartAvailability,
  applyPassiveHeartRefill,
  assertClientHeartRefillMethod,
  DEFAULT_LESSON_LIVES,
  GEMS_FULL_HEART_REFILL,
  grantHearts,
  HEART_REFILL_INTERVAL_MS,
  heartStateFromData,
  practiceHeartGrantFromCompletion,
  profileLivesFromData,
  scheduleHeartRefillAfterLoss,
} from "./course_hearts";

describe("profileLivesFromData", () => {
  it("defaults missing hearts to a full five-heart set", () => {
    expect(profileLivesFromData(undefined)).toEqual({
      livesRemaining: 5,
      livesMax: 5,
    });
    expect(profileLivesFromData({})).toEqual({
      livesRemaining: 5,
      livesMax: 5,
    });
  });

  it("migrates a full legacy three-heart profile to five", () => {
    expect(profileLivesFromData({livesRemaining: 3, livesMax: 3})).toEqual({
      livesRemaining: 5,
      livesMax: 5,
    });
  });

  it("keeps a partial legacy count when bumping the ceiling", () => {
    expect(profileLivesFromData({livesRemaining: 1, livesMax: 3})).toEqual({
      livesRemaining: 1,
      livesMax: 5,
    });
  });

  it("falls back when the ceiling is not a positive number", () => {
    for (const livesMax of [Number.NaN, 0, -2, "nope"]) {
      expect(profileLivesFromData({livesMax, livesRemaining: 2})).toEqual({
        livesRemaining: 2,
        livesMax: DEFAULT_LESSON_LIVES,
      });
    }
  });

  it("floors a higher ceiling and clamps remaining into it", () => {
    expect(profileLivesFromData({
      livesMax: 7.9,
      livesRemaining: 9.2,
    })).toEqual({
      livesRemaining: 7,
      livesMax: 7,
    });
    expect(profileLivesFromData({livesMax: 8, livesRemaining: -4})).toEqual({
      livesRemaining: 0,
      livesMax: 8,
    });
    expect(profileLivesFromData({
      livesMax: 5,
      livesRemaining: 2.9,
    })).toEqual({
      livesRemaining: 2,
      livesMax: 5,
    });
  });

  it("uses the ceiling when remaining is not a number", () => {
    expect(profileLivesFromData({
      livesMax: 6,
      livesRemaining: Number.NaN,
    })).toEqual({
      livesRemaining: 6,
      livesMax: 6,
    });
  });

  it("migrates a full fractional legacy ceiling up to five", () => {
    expect(profileLivesFromData({livesMax: 4.9, livesRemaining: 4})).toEqual({
      livesRemaining: DEFAULT_LESSON_LIVES,
      livesMax: DEFAULT_LESSON_LIVES,
    });
  });
});

describe("applyPassiveHeartRefill", () => {
  const base = heartStateFromData({
    livesRemaining: 3,
    livesMax: 5,
    livesNextRefillAtMs: 1_000,
    gems: 0,
  });

  it("restores one heart per elapsed interval", () => {
    const result = applyPassiveHeartRefill(
      base,
      1_000 + HEART_REFILL_INTERVAL_MS * 2 + 1,
    );
    expect(result.livesRemaining).toBe(5);
    expect(result.heartsRestored).toBe(2);
    expect(result.livesNextRefillAtMs).toBeNull();
  });

  it("starts a timer when below max with no schedule", () => {
    const result = applyPassiveHeartRefill(
      {...base, livesNextRefillAtMs: null},
      5_000,
    );
    expect(result.livesRemaining).toBe(3);
    expect(result.livesNextRefillAtMs).toBe(5_000 + HEART_REFILL_INTERVAL_MS);
  });

  it("clears the timer when already full", () => {
    const result = applyPassiveHeartRefill(
      {...base, livesRemaining: 5, livesNextRefillAtMs: 99},
      1_000,
    );
    expect(result.livesNextRefillAtMs).toBeNull();
    expect(result.heartsRestored).toBe(0);
  });

  it("does not grant a heart before the scheduled instant", () => {
    const result = applyPassiveHeartRefill(base, 999);
    expect(result.livesRemaining).toBe(3);
    expect(result.heartsRestored).toBe(0);
    expect(result.livesNextRefillAtMs).toBe(1_000);
    expect(result.changed).toBe(false);
  });

  it("grants one heart per crossed refill and leaves the next timer ahead", () => {
    const result = applyPassiveHeartRefill(
      {...base, livesRemaining: 0},
      1_000 + HEART_REFILL_INTERVAL_MS * 2 - 1,
    );
    expect(result.heartsRestored).toBe(2);
    expect(result.livesRemaining).toBe(2);
    expect(result.livesNextRefillAtMs).toBe(
      1_000 + HEART_REFILL_INTERVAL_MS * 2,
    );
  });
});

describe("heartStateFromData", () => {
  it("drops unsafe refill timers, gem balances, and ad counters", () => {
    const state = heartStateFromData({
      livesRemaining: 2,
      livesMax: 5,
      livesNextRefillAtMs: 0,
      gems: Number.NaN,
      heartsAdClaimsLocalDate: 12,
      heartsAdClaimsToday: -3,
      lastHeartAdClaimAtMs: -1,
    });
    expect(state.livesNextRefillAtMs).toBeNull();
    expect(state.gems).toBe(0);
    expect(state.heartsAdClaimsLocalDate).toBeNull();
    expect(state.heartsAdClaimsToday).toBe(0);
    expect(state.lastHeartAdClaimAtMs).toBeNull();

    expect(heartStateFromData({
      livesRemaining: 1,
      livesMax: 5,
      gems: -4.2,
      livesNextRefillAtMs: -5,
    }).gems).toBe(0);
  });

  it("floors finite gem, timer, and ad-claim values", () => {
    const state = heartStateFromData({
      livesRemaining: 1,
      livesMax: 5,
      livesNextRefillAtMs: 1500.9,
      gems: 3.9,
      heartsAdClaimsLocalDate: "2026-10-01",
      heartsAdClaimsToday: 2.8,
      lastHeartAdClaimAtMs: 100.7,
    });
    expect(state.livesNextRefillAtMs).toBe(1500);
    expect(state.gems).toBe(3);
    expect(state.heartsAdClaimsToday).toBe(2);
    expect(state.lastHeartAdClaimAtMs).toBe(100);
    expect(state.heartsAdClaimsLocalDate).toBe("2026-10-01");
  });
});

describe("scheduleHeartRefillAfterLoss", () => {
  it("schedules from now when no timer is running", () => {
    expect(scheduleHeartRefillAfterLoss({
      livesRemaining: 4,
      livesMax: 5,
      livesNextRefillAtMs: null,
      nowMs: 10,
    })).toBe(10 + HEART_REFILL_INTERVAL_MS);
  });

  it("keeps a future timer", () => {
    expect(scheduleHeartRefillAfterLoss({
      livesRemaining: 4,
      livesMax: 5,
      livesNextRefillAtMs: 50_000,
      nowMs: 10,
    })).toBe(50_000);
  });

  it("clears the timer when hearts are already full", () => {
    expect(scheduleHeartRefillAfterLoss({
      livesRemaining: 5,
      livesMax: 5,
      livesNextRefillAtMs: 99,
      nowMs: 10,
    })).toBeNull();
  });

  it("reschedules a timer that is already due", () => {
    expect(scheduleHeartRefillAfterLoss({
      livesRemaining: 2,
      livesMax: 5,
      livesNextRefillAtMs: 10,
      nowMs: 10,
    })).toBe(10 + HEART_REFILL_INTERVAL_MS);
  });
});

describe("grantHearts and practice", () => {
  it("fills to max for a gem-style refill", () => {
    const state = heartStateFromData({
      livesRemaining: 1,
      livesMax: 5,
      gems: GEMS_FULL_HEART_REFILL,
    });
    const result = grantHearts({state, amount: 0, nowMs: 1, fillToMax: true});
    expect(result.livesRemaining).toBe(5);
    expect(result.heartsRestored).toBe(4);
    expect(result.livesNextRefillAtMs).toBeNull();
  });

  it("awards one practice heart when eligible", () => {
    const state = heartStateFromData({livesRemaining: 2, livesMax: 5});
    const grant = practiceHeartGrantFromCompletion({
      state,
      nowMs: 1,
      restoreHeartOnComplete: true,
    });
    expect(grant?.heartsRestored).toBe(1);
    expect(grant?.livesRemaining).toBe(3);
  });

  it("skips practice grant when full", () => {
    const state = heartStateFromData({
      livesRemaining: DEFAULT_LESSON_LIVES,
      livesMax: DEFAULT_LESSON_LIVES,
    });
    expect(practiceHeartGrantFromCompletion({
      state,
      nowMs: 1,
      restoreHeartOnComplete: true,
    })).toBeNull();
  });

  it("exposes ad daily cap constant", () => {
    expect(AD_HEART_DAILY_MAX).toBe(5);
  });

  it("refuses a client practice refill that never finished a lesson", () => {
    expect(() => assertClientHeartRefillMethod("practice")).toThrow(
      expect.objectContaining({
        code: "failed-precondition",
        message: expect.stringContaining("Practice lesson"),
      }),
    );
    expect(() => assertClientHeartRefillMethod("gems")).not.toThrow();
    expect(() => assertClientHeartRefillMethod("ad")).not.toThrow();
  });

  it("does not grant a heart for a voluntary review or first-run", () => {
    const state = heartStateFromData({livesRemaining: 0, livesMax: 5});
    expect(practiceHeartGrantFromCompletion({
      state,
      nowMs: 1,
      restoreHeartOnComplete: false,
    })).toBeNull();
  });

  it("ignores a negative amount and keeps a future timer", () => {
    const state = heartStateFromData({
      livesRemaining: 2,
      livesMax: 5,
      livesNextRefillAtMs: 9_000,
    });
    const negative = grantHearts({state, amount: -3, nowMs: 1});
    expect(negative.livesRemaining).toBe(2);
    expect(negative.heartsRestored).toBe(0);
    expect(negative.livesNextRefillAtMs).toBe(9_000);
    expect(negative.changed).toBe(false);

    const fractional = grantHearts({state, amount: 1.9, nowMs: 1});
    expect(fractional.livesRemaining).toBe(3);
    expect(fractional.heartsRestored).toBe(1);
    expect(fractional.livesNextRefillAtMs).toBe(9_000);
  });

  it("clamps a large grant to the ceiling and clears the timer", () => {
    const state = heartStateFromData({
      livesRemaining: 4,
      livesMax: 5,
      livesNextRefillAtMs: 9_000,
    });
    const result = grantHearts({state, amount: 10, nowMs: 1});
    expect(result.livesRemaining).toBe(5);
    expect(result.heartsRestored).toBe(1);
    expect(result.livesNextRefillAtMs).toBeNull();
  });

  it("starts a timer when a partial grant has none", () => {
    const state = heartStateFromData({livesRemaining: 1, livesMax: 5});
    const result = grantHearts({state, amount: 1, nowMs: 40});
    expect(result.livesRemaining).toBe(2);
    expect(result.heartsRestored).toBe(1);
    expect(result.livesNextRefillAtMs).toBe(40 + HEART_REFILL_INTERVAL_MS);
  });

  it("raises a legacy ceiling without inventing hearts", () => {
    const result = grantHearts({
      state: {
        livesRemaining: 3,
        livesMax: 3,
        livesNextRefillAtMs: null,
        gems: 0,
        heartsAdClaimsLocalDate: null,
        heartsAdClaimsToday: 0,
        lastHeartAdClaimAtMs: null,
      },
      amount: 0,
      nowMs: 10,
    });
    expect(result.livesMax).toBe(DEFAULT_LESSON_LIVES);
    expect(result.livesRemaining).toBe(3);
    expect(result.heartsRestored).toBe(0);
    expect(result.livesNextRefillAtMs).toBe(10 + HEART_REFILL_INTERVAL_MS);
    expect(result.changed).toBe(true);
  });
});

describe("adHeartAvailability", () => {
  it("counts remaining claims for today and cooldown", () => {
    const nowMs = 1_000_000;
    const state = heartStateFromData({
      livesRemaining: 2,
      livesMax: 5,
      heartsAdClaimsLocalDate: "2026-09-30",
      heartsAdClaimsToday: 1,
      lastHeartAdClaimAtMs: nowMs - 1_000,
    });
    expect(adHeartAvailability({
      state,
      localDate: "2026-09-30",
      nowMs,
    })).toEqual({
      adClaimsRemainingToday: 4,
      nextAdClaimAtMs: nowMs - 1_000 + AD_HEART_COOLDOWN_MS,
    });
    expect(adHeartAvailability({
      state,
      localDate: "2026-09-30",
      nowMs: nowMs - 1_000 + AD_HEART_COOLDOWN_MS + 1,
    })).toEqual({
      adClaimsRemainingToday: 4,
      nextAdClaimAtMs: null,
    });
  });

  it("resets the daily count on a new local date and still honors cooldown", () => {
    const nowMs = 1_000_000;
    const state = heartStateFromData({
      livesRemaining: 2,
      livesMax: 5,
      heartsAdClaimsLocalDate: "2026-09-30",
      heartsAdClaimsToday: AD_HEART_DAILY_MAX,
      lastHeartAdClaimAtMs: nowMs - 1_000,
    });
    expect(adHeartAvailability({
      state,
      localDate: "2026-10-01",
      nowMs,
    })).toEqual({
      adClaimsRemainingToday: AD_HEART_DAILY_MAX,
      nextAdClaimAtMs: nowMs - 1_000 + AD_HEART_COOLDOWN_MS,
    });
  });

  it("reports zero claims left at the daily cap", () => {
    const state = heartStateFromData({
      livesRemaining: 2,
      livesMax: 5,
      heartsAdClaimsLocalDate: "2026-10-01",
      heartsAdClaimsToday: AD_HEART_DAILY_MAX,
    });
    expect(adHeartAvailability({
      state,
      localDate: "2026-10-01",
      nowMs: 50,
    })).toEqual({
      adClaimsRemainingToday: 0,
      nextAdClaimAtMs: null,
    });
  });
});

describe("openAttemptRefFromProfile", () => {
  it("returns null without a resume attempt id", async () => {
    const {openAttemptRefFromProfile} = await import("./course_hearts");
    const db = {
      collection: () => ({
        doc: () => ({
          collection: () => ({
            doc: (id: string) => ({path: `users/u/courseAttempts/${id}`}),
          }),
        }),
      }),
    } as unknown as import("firebase-admin/firestore").Firestore;
    expect(openAttemptRefFromProfile({
      db,
      uid: "u",
      profileData: {},
    })).toBeNull();
    expect(openAttemptRefFromProfile({
      db,
      uid: "u",
      profileData: {resume: {attemptId: "  "}},
    })).toBeNull();
  });

  it("points at the resume attempt document", async () => {
    const {openAttemptRefFromProfile} = await import("./course_hearts");
    const db = {
      collection: () => ({
        doc: () => ({
          collection: () => ({
            doc: (id: string) => ({id, path: `users/u/courseAttempts/${id}`}),
          }),
        }),
      }),
    } as unknown as import("firebase-admin/firestore").Firestore;
    const ref = openAttemptRefFromProfile({
      db,
      uid: "u",
      profileData: {resume: {attemptId: "attempt-9"}},
    });
    expect(ref?.id).toBe("attempt-9");
  });
});
