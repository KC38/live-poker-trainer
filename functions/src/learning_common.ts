/**
 * Shared helpers for learning-platform callables.
 */

import {
  getFirestore,
  type Firestore,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {
  FEATURE_FLAGS_DOC_PATH,
  readLearningFeatureFlags,
  type FeatureFlagsDocReader,
} from "./feature_flags";
import type {LearningFeatureFlags} from "./curriculum_types";

export function firestoreFlagReader(db: Firestore): FeatureFlagsDocReader {
  return async (path: string) => {
    const snapshot = await db.doc(path).get();
    if (!snapshot.exists) return null;
    return snapshot.data() as Record<string, unknown>;
  };
}

export async function assertLearningPlatformEnabled(
  readDoc: FeatureFlagsDocReader,
): Promise<LearningFeatureFlags> {
  const flags = await readLearningFeatureFlags(readDoc);
  if (!flags.learningPlatformEnabled) {
    throw new HttpsError(
      "failed-precondition",
      "Learning platform is not enabled.",
    );
  }
  return flags;
}

export function learningMainRef(db: Firestore, uid: string) {
  return db.collection("users").doc(uid).collection("learning").doc("main");
}

export function learningAttemptRef(
  db: Firestore,
  uid: string,
  attemptId: string,
) {
  return db
    .collection("users")
    .doc(uid)
    .collection("learningAttempts")
    .doc(attemptId);
}

export function record(raw: unknown, field: string): Record<string, unknown> {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new HttpsError("invalid-argument", `${field} must be an object.`);
  }
  return raw as Record<string, unknown>;
}

export function nonEmpty(value: unknown, field: string): string {
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  return value.trim();
}

/** Idempotency / attempt keys: URL-safe, 8–100 chars (matches live sessions). */
export function safeIdempotencyKey(value: unknown, field: string): string {
  const key = nonEmpty(value, field);
  if (!/^[A-Za-z0-9_-]{8,100}$/.test(key)) {
    throw new HttpsError(
      "invalid-argument",
      `${field} must be 8-100 URL-safe characters.`,
    );
  }
  return key;
}

export function defaultDb(db?: Firestore): Firestore {
  return db ?? getFirestore();
}

export {FEATURE_FLAGS_DOC_PATH};
