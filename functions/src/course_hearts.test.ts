/**
 * Unit tests for Duolingo-style course heart replenishment.
 */

import {describe, expect, it} from "vitest";
import {
  AD_HEART_DAILY_MAX,
  applyPassiveHeartRefill,
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
      isPracticeOrReplay: true,
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
      isPracticeOrReplay: true,
    })).toBeNull();
  });

  it("exposes ad daily cap constant", () => {
    expect(AD_HEART_DAILY_MAX).toBe(5);
  });
});

describe("adHeartAvailability", () => {
  it("counts remaining claims for today and cooldown", async () => {
    const {adHeartAvailability, AD_HEART_COOLDOWN_MS} =
      await import("./course_hearts");
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
