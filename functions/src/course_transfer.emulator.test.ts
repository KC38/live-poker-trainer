/**
 * Emulator tests for issue/redeem transfer authorization and idempotency.
 */

import {deleteApp, getApp, getApps, initializeApp} from "firebase-admin/app";
import {getFirestore, type Firestore} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {afterAll, afterEach, beforeAll, describe, expect, test} from "vitest";
import {
  cleanupExpiredCourseTransfers,
  issueAnonymousProgressTransferForUser,
  redeemAnonymousProgressTransferForUser,
  TRANSFER_RECEIPT_TTL_MS,
} from "./course_transfer";

const PROJECT_ID = "live-poker-trainer-rules-test";
const APP_NAME = "course-transfer-emulator-tests";
let db: Firestore;

beforeAll(() => {
  const existing = getApps().find((app) => app.name === APP_NAME);
  const app = existing ?? initializeApp({projectId: PROJECT_ID}, APP_NAME);
  db = getFirestore(app);
});

afterEach(async () => {
  const host = process.env.FIRESTORE_EMULATOR_HOST;
  if (!host) throw new Error("FIRESTORE_EMULATOR_HOST is required");
  await fetch(
    `http://${host}/emulator/v1/projects/${PROJECT_ID}` +
      "/databases/(default)/documents",
    {method: "DELETE"},
  );
});

afterAll(async () => {
  if (getApps().some((app) => app.name === APP_NAME)) {
    await deleteApp(getApp(APP_NAME));
  }
});

describe("anonymous progress transfer", () => {
  test("issue requires anonymous auth", async () => {
    await expect(
      issueAnonymousProgressTransferForUser({
        uid: "linked",
        isAnonymous: false,
        db,
      }),
    ).rejects.toBeInstanceOf(HttpsError);
  });

  test("redeem requires non-anonymous destination", async () => {
    const issued = await issueAnonymousProgressTransferForUser({
      uid: "anon-1",
      isAnonymous: true,
      db,
    });
    await expect(
      redeemAnonymousProgressTransferForUser({
        uid: "anon-2",
        isAnonymous: true,
        raw: {receiptId: issued.receiptId, nonce: issued.nonce},
        db,
      }),
    ).rejects.toMatchObject({code: "failed-precondition"});
  });

  test("nonce mismatch is denied", async () => {
    const issued = await issueAnonymousProgressTransferForUser({
      uid: "anon-1",
      isAnonymous: true,
      db,
    });
    await expect(
      redeemAnonymousProgressTransferForUser({
        uid: "dest-1",
        isAnonymous: false,
        raw: {receiptId: issued.receiptId, nonce: "wrong"},
        db,
      }),
    ).rejects.toMatchObject({code: "permission-denied"});
  });

  test("expired receipts cannot redeem", async () => {
    const nowMs = 1_000_000;
    const issued = await issueAnonymousProgressTransferForUser({
      uid: "anon-1",
      isAnonymous: true,
      db,
      nowMs,
    });
    await expect(
      redeemAnonymousProgressTransferForUser({
        uid: "dest-1",
        isAnonymous: false,
        raw: {receiptId: issued.receiptId, nonce: issued.nonce},
        db,
        nowMs: nowMs + TRANSFER_RECEIPT_TTL_MS + 1,
      }),
    ).rejects.toMatchObject({code: "deadline-exceeded"});
  });

  test("merges progress and entitlement exactly once", async () => {
    await db.doc("users/anon-1/course/main").set({
      catalogVersion: "2.0.0",
      lifetimeXp: 35,
      completedLessonIds: ["lesson-01-01-01-your-two-cards"],
      masteryByLessonId: {"lesson-01-01-01-your-two-cards": 0.8},
      currentStreak: 1,
      longestStreak: 1,
      acceptedAnswers: 3,
      totalScoredAnswers: 3,
      experienceBand: "never_played",
      dailyGoalMinutes: 10,
    });
    await db.doc("users/anon-1/entitlements/liveTraining").set({
      unrestrictedAccess: true,
      source: "section4_jump",
      grantedAtMs: 50,
    });
    await db.doc("users/dest-1/course/main").set({
      catalogVersion: "2.0.0",
      lifetimeXp: 10,
      completedLessonIds: [],
      masteryByLessonId: {},
      currentStreak: 0,
      longestStreak: 0,
      acceptedAnswers: 0,
      totalScoredAnswers: 0,
    });

    const issued = await issueAnonymousProgressTransferForUser({
      uid: "anon-1",
      isAnonymous: true,
      raw: {catalogVersion: "2.0.0"},
      db,
      nowMs: 2_000_000,
    });
    const first = await redeemAnonymousProgressTransferForUser({
      uid: "dest-1",
      isAnonymous: false,
      raw: {
        receiptId: issued.receiptId,
        nonce: issued.nonce,
        entitlement: {unrestrictedAccess: true, forged: true},
      },
      clientEntitlementClaim: {unrestrictedAccess: true},
      db,
      nowMs: 2_000_100,
    });
    expect(first.duplicate).toBe(false);
    expect(first.mergedLessonCount).toBe(1);
    expect(first.liveTrainingTransferred).toBe(true);

    const destProfile = await db.doc("users/dest-1/course/main").get();
    expect(destProfile.data()?.lifetimeXp).toBe(45);
    expect(destProfile.data()?.completedLessonIds).toContain(
      "lesson-01-01-01-your-two-cards",
    );
    const destEntitlement =
      await db.doc("users/dest-1/entitlements/liveTraining").get();
    expect(destEntitlement.data()?.unrestrictedAccess).toBe(true);
    expect(destEntitlement.data()?.source).toBe("anonymous_transfer");
    expect(destEntitlement.data()?.originalEntitlementSource).toBe(
      "section4_jump",
    );

    const sourceProfile = await db.doc("users/anon-1/course/main").get();
    expect(sourceProfile.data()?.tombstoned).toBe(true);

    const second = await redeemAnonymousProgressTransferForUser({
      uid: "dest-1",
      isAnonymous: false,
      raw: {receiptId: issued.receiptId, nonce: issued.nonce},
      db,
      nowMs: 2_000_200,
    });
    expect(second.duplicate).toBe(true);
    const destAgain = await db.doc("users/dest-1/course/main").get();
    expect(destAgain.data()?.lifetimeXp).toBe(45);
  });

  test("cleanup deletes expired receipts and tombstones", async () => {
    const nowMs = 5_000_000;
    await db.doc("courseTransferReceipts/r1").set({
      expireAt: new Date(nowMs - 1),
      status: "expired",
    });
    await db.doc("courseTombstones/anon-old").set({
      sourceUid: "anon-old",
      expireAt: new Date(nowMs - 1),
    });
    await db.doc("users/anon-old/course/main").set({tombstoned: true});
    const result = await cleanupExpiredCourseTransfers({db, nowMs});
    expect(result.receiptsDeleted).toBeGreaterThanOrEqual(1);
    expect(result.profilesDeleted).toBeGreaterThanOrEqual(1);
    const receipt = await db.doc("courseTransferReceipts/r1").get();
    expect(receipt.exists).toBe(false);
    const tombstone = await db.doc("courseTombstones/anon-old").get();
    expect(tombstone.exists).toBe(false);
  });
});
