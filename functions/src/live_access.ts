/**
 * Live Training access gates: anonymous rejection helpers, grandfathering,
 * Section 2 warm-up readiness, and unrestricted entitlement checks.
 *
 * Enforced in Live callables (not only Flutter). Course progress never grants
 * unrestricted access here — Section 4 jump writes the entitlement via course
 * completion (Plan 03).
 */

import {getAuth} from "firebase-admin/auth";
import {
  FieldValue,
  getFirestore,
  type Firestore,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";

/** Access tiers surfaced to clients and enforced on start. */
export type LiveAccessTier = "locked" | "warm_up" | "unrestricted";

export type LiveAccessSource =
  | "grandfathered"
  | "section4_jump"
  | "admin"
  | "anonymous_transfer"
  | "section2_checkpoint"
  | "none";

export interface LiveAccessSnapshot {
  tier: LiveAccessTier;
  source: LiveAccessSource;
  unrestrictedAccess: boolean;
  warmUpAvailable: boolean;
  /** ISO cutoff used for grandfathering when present. */
  rolloutCutoffMs: number | null;
  accountCreatedAtMs: number | null;
  nextLessonId: string | null;
}

/** Section 2 jump that unlocks Rex-guided warm-ups (not unrestricted Live). */
export const LIVE_WARMUP_UNLOCK_LESSON_ID =
  "lesson-02-07-02-section-two-jump";

/** Default cutoff: accounts created before this are grandfathered. */
export const DEFAULT_LIVE_ROLLOUT_CUTOFF_MS =
  Date.parse("2026-09-21T00:00:00.000Z");

export interface LiveAccessDeps {
  db?: Firestore;
  /** Injectable for emulator/unit tests. */
  getUserCreatedAtMs?: (uid: string) => Promise<number | null>;
  nowMs?: number;
}

/** Reads server-controlled rollout cutoff from system/liveConfig. */
export async function loadLiveRolloutCutoffMs(
  db: Firestore,
): Promise<number> {
  const snap = await db.doc("system/liveConfig").get();
  const raw = snap.data()?.rolloutCutoffMs;
  if (typeof raw === "number" && Number.isFinite(raw) && raw > 0) {
    return raw;
  }
  if (typeof raw === "string" && raw.trim()) {
    const parsed = Date.parse(raw);
    if (Number.isFinite(parsed)) return parsed;
  }
  return DEFAULT_LIVE_ROLLOUT_CUTOFF_MS;
}

/** Auth metadata creation time in ms, or null when unavailable. */
export async function defaultGetUserCreatedAtMs(
  uid: string,
): Promise<number | null> {
  try {
    const user = await getAuth().getUser(uid);
    const created = user.metadata?.creationTime;
    if (!created) return null;
    const ms = Date.parse(created);
    return Number.isFinite(ms) ? ms : null;
  } catch {
    return null;
  }
}

/**
 * Resolves Live access for a linked user. May persist a grandfathered
 * entitlement when creation time is before the configured cutoff.
 */
export async function resolveLiveAccessForUser(
  uid: string,
  deps: LiveAccessDeps = {},
): Promise<LiveAccessSnapshot> {
  const db = deps.db ?? getFirestore();
  const getCreated =
    deps.getUserCreatedAtMs ?? defaultGetUserCreatedAtMs;
  const nowMs = deps.nowMs ?? Date.now();
  const cutoffMs = await loadLiveRolloutCutoffMs(db);
  const createdAtMs = await getCreated(uid);

  const entitlementRef = db
    .collection("users")
    .doc(uid)
    .collection("entitlements")
    .doc("liveTraining");
  const profileRef = db.collection("users").doc(uid).collection("course")
    .doc("main");
  const [entitlementSnap, profileSnap] = await Promise.all([
    entitlementRef.get(),
    profileRef.get(),
  ]);

  const entitlement = entitlementSnap.data();
  if (entitlement?.unrestrictedAccess === true) {
    const source = normalizeSource(entitlement.source);
    return {
      tier: "unrestricted",
      source,
      unrestrictedAccess: true,
      warmUpAvailable: true,
      rolloutCutoffMs: cutoffMs,
      accountCreatedAtMs: createdAtMs,
      nextLessonId: null,
    };
  }

  if (
    createdAtMs != null &&
    createdAtMs < cutoffMs
  ) {
    await entitlementRef.set({
      unrestrictedAccess: true,
      source: "grandfathered",
      grantedAtMs: nowMs,
      grantedByLessonId: null,
      rolloutCutoffMs: cutoffMs,
      accountCreatedAtMs: createdAtMs,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    return {
      tier: "unrestricted",
      source: "grandfathered",
      unrestrictedAccess: true,
      warmUpAvailable: true,
      rolloutCutoffMs: cutoffMs,
      accountCreatedAtMs: createdAtMs,
      nextLessonId: null,
    };
  }

  const completed = Array.isArray(profileSnap.data()?.completedLessonIds) ?
    (profileSnap.data()!.completedLessonIds as string[]) :
    [];
  const warmUpAvailable = completed.includes(LIVE_WARMUP_UNLOCK_LESSON_ID);
  if (warmUpAvailable) {
    return {
      tier: "warm_up",
      source: "section2_checkpoint",
      unrestrictedAccess: false,
      warmUpAvailable: true,
      rolloutCutoffMs: cutoffMs,
      accountCreatedAtMs: createdAtMs,
      nextLessonId: null,
    };
  }

  return {
    tier: "locked",
    source: "none",
    unrestrictedAccess: false,
    warmUpAvailable: false,
    rolloutCutoffMs: cutoffMs,
    accountCreatedAtMs: createdAtMs,
    nextLessonId: profileSnap.data()?.recommendedLessonId ?
      String(profileSnap.data()!.recommendedLessonId) :
      profileSnap.data()?.currentLessonId ?
      String(profileSnap.data()!.currentLessonId) :
      "lesson-01-01-01-table-layout",
  };
}

/** Random Live Training requires unrestricted (or grandfathered) access. */
export async function assertUnrestrictedLiveAccess(
  uid: string,
  deps: LiveAccessDeps = {},
): Promise<LiveAccessSnapshot> {
  const access = await resolveLiveAccessForUser(uid, deps);
  if (!access.unrestrictedAccess) {
    throw new HttpsError(
      "permission-denied",
      access.tier === "warm_up" ?
        "Finish the Section 4 jump test (or placement) to unlock unrestricted Live Training. Warm-ups stay available from Home." :
        "Live Training unlocks after the Section 2 checkpoint. Continue on Home.",
    );
  }
  return access;
}

/** Course warm-up / hand-lab sessions need warm_up or unrestricted. */
export async function assertCourseLiveAccess(
  uid: string,
  deps: LiveAccessDeps = {},
): Promise<LiveAccessSnapshot> {
  const access = await resolveLiveAccessForUser(uid, deps);
  if (!access.warmUpAvailable && !access.unrestrictedAccess) {
    throw new HttpsError(
      "permission-denied",
      "Coached warm-ups unlock after the Section 2 checkpoint. Continue on Home.",
    );
  }
  return access;
}

function normalizeSource(raw: unknown): LiveAccessSource {
  if (
    raw === "grandfathered" ||
    raw === "section4_jump" ||
    raw === "admin" ||
    raw === "anonymous_transfer" ||
    raw === "section2_checkpoint"
  ) {
    return raw;
  }
  return "none";
}
