/**
 * Cloud Functions for server-authoritative v3 live poker training.
 *
 * The v2 fetch/progress/pool exports are intentionally removed so old clients
 * cannot recreate deleted graph situations after the mandatory upgrade reset.
 */

import {initializeApp} from "firebase-admin/app";
import {logger} from "firebase-functions";
import {defineSecret} from "firebase-functions/params";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {
  isQueuedLiveGeneration,
  isQueuedLiveGenerationJob,
  processLiveGenerationJob,
  recoverExpiredLiveGenerationLeases,
  refillQueuedLiveSetup,
} from "./live_pool";
import {
  completeCourseLessonForUser,
  getCourseStateForUser,
  initializeCourseProfileForUser,
  startCourseLessonForUser,
  submitCourseStepForUser,
} from "./course_session";
import {
  cleanupExpiredCourseTransfers,
  issueAnonymousProgressTransferForUser,
  redeemAnonymousProgressTransferForUser,
} from "./course_transfer";
import {
  resumeLiveHandForUser,
  startLiveHandForUser,
  submitLiveActionForUser,
  undoLiveActionForUser,
} from "./live_session";
import {resolveLiveAccessForUser} from "./live_access";
import {completeCalibrationWarmUpForUser} from "./course_live_bridge";

initializeApp();

const geminiApiKey = defineSecret("GEMINI_API_KEY");

function requireApiKey(): string {
  const key =
    geminiApiKey.value()?.trim() ||
    process.env.GEMINI_API_KEY?.trim() ||
    "";
  if (!key) {
    throw new HttpsError(
      "failed-precondition",
      "GEMINI_API_KEY secret is not configured.",
    );
  }
  return key;
}

/** Allocates an unseen, pre-warmed hand and creates an online session. */
export const startLiveHand = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "512MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid);
    rejectAnonymousLive(request.auth);
    try {
      return await startLiveHandForUser({uid, raw: request.data});
    } catch (error) {
      throw callableError("startLiveHand", error);
    }
  },
);

/** Applies one idempotent Hero command and returns its shared continuation. */
export const submitLiveAction = onCall(
  {
    region: "us-central1",
    secrets: [geminiApiKey],
    timeoutSeconds: 300,
    memory: "1GiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid);
    rejectAnonymousLive(request.auth);
    try {
      return await submitLiveActionForUser({
        uid,
        raw: request.data,
        apiKey: requireApiKey(),
      });
    } catch (error) {
      throw callableError("submitLiveAction", error);
    }
  },
);

/** Restores the latest authoritative view after a network interruption. */
export const resumeLiveHand = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "512MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid);
    rejectAnonymousLive(request.auth);
    try {
      const sessionId = String(request.data?.sessionId ?? "").trim();
      const clientVersion = String(request.data?.clientVersion ?? "").trim();
      if (!sessionId || !clientVersion) {
        throw new HttpsError(
          "invalid-argument",
          "sessionId and clientVersion are required.",
        );
      }
      return await resumeLiveHandForUser({uid, sessionId, clientVersion});
    } catch (error) {
      throw callableError("resumeLiveHand", error);
    }
  },
);

/** Rewinds one Hero decision so coach review can try another branch. */
export const undoLiveAction = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "512MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid);
    rejectAnonymousLive(request.auth);
    try {
      return await undoLiveActionForUser({uid, raw: request.data});
    } catch (error) {
      throw callableError("undoLiveAction", error);
    }
  },
);

/** Creates users/{uid}/course/main when missing. */
export const initializeCourseProfile = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid, "Sign in required for course.");
    try {
      return await initializeCourseProfileForUser({
        uid,
        raw: request.data,
        isAnonymous: request.auth?.token?.firebase?.sign_in_provider ===
          "anonymous",
      });
    } catch (error) {
      throw callableError("initializeCourseProfile", error);
    }
  },
);

/** Starts or resumes one lesson attempt. */
export const startCourseLesson = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid, "Sign in required for course.");
    try {
      return await startCourseLessonForUser({
        uid,
        raw: request.data,
        isAnonymous: request.auth?.token?.firebase?.sign_in_provider ===
          "anonymous",
      });
    } catch (error) {
      throw callableError("startCourseLesson", error);
    }
  },
);

/** Grades one activity response without trusting client grades. */
export const submitCourseStep = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid, "Sign in required for course.");
    try {
      return await submitCourseStepForUser({
        uid,
        raw: request.data,
        isAnonymous: request.auth?.token?.firebase?.sign_in_provider ===
          "anonymous",
      });
    } catch (error) {
      throw callableError("submitCourseStep", error);
    }
  },
);

/** Completes a finished lesson attempt and may grant Live entitlement. */
export const completeCourseLesson = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid, "Sign in required for course.");
    try {
      return await completeCourseLessonForUser({
        uid,
        raw: request.data,
        isAnonymous: request.auth?.token?.firebase?.sign_in_provider ===
          "anonymous",
      });
    } catch (error) {
      throw callableError("completeCourseLesson", error);
    }
  },
);

/** Completes the Section 7 calibration lesson after its live hand. */
export const completeCalibrationWarmUp = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid, "Sign in required for course.");
    try {
      return await completeCalibrationWarmUpForUser({
        uid,
        raw: request.data,
        isAnonymous: request.auth?.token?.firebase?.sign_in_provider ===
          "anonymous",
      });
    } catch (error) {
      throw callableError("completeCalibrationWarmUp", error);
    }
  },
);

/** Returns Live Training access tier (warm-up / unrestricted / locked). */
export const getLiveAccess = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid);
    rejectAnonymousLive(request.auth);
    try {
      const access = await resolveLiveAccessForUser(uid);
      return {ok: true, ...access};
    } catch (error) {
      throw callableError("getLiveAccess", error);
    }
  },
);

/** Returns aggregate course progress, resume pointer, and flags. */
export const getCourseState = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid, "Sign in required for course.");
    try {
      return await getCourseStateForUser({
        uid,
        raw: request.data,
        isAnonymous: request.auth?.token?.firebase?.sign_in_provider ===
          "anonymous",
      });
    } catch (error) {
      throw callableError("getCourseState", error);
    }
  },
);

/** Issues a short-lived transfer receipt while still anonymous. */
export const issueAnonymousProgressTransfer = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid, "Sign in required for transfer.");
    try {
      return await issueAnonymousProgressTransferForUser({
        uid,
        raw: request.data,
        isAnonymous: request.auth?.token?.firebase?.sign_in_provider ===
          "anonymous",
      });
    } catch (error) {
      throw callableError("issueAnonymousProgressTransfer", error);
    }
  },
);

/** Redeems a transfer into the authenticated permanent account. */
export const redeemAnonymousProgressTransfer = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "512MiB",
  },
  async (request) => {
    const uid = requireAuth(request.auth?.uid, "Sign in required for transfer.");
    try {
      return await redeemAnonymousProgressTransferForUser({
        uid,
        raw: request.data,
        isAnonymous: request.auth?.token?.firebase?.sign_in_provider ===
          "anonymous",
        clientEntitlementClaim: request.data?.entitlement,
      });
    } catch (error) {
      throw callableError("redeemAnonymousProgressTransfer", error);
    }
  },
);

/** Fans one setup refill request into independent warmed-hand jobs. */
export const refillLiveHandPool = onDocumentWritten(
  {
    document: "liveTableSetups/{setupKey}",
    region: "us-central1",
    timeoutSeconds: 120,
    memory: "512MiB",
    maxInstances: 2,
  },
  async (event) => {
    const after = event.data?.after.exists ? event.data.after.data() : undefined;
    if (!isQueuedLiveGeneration(after)) return;
    const result = await refillQueuedLiveSetup({
      setupKey: event.params.setupKey,
    });
    logger.info("refillLiveHandPool completed", {
      setupKey: event.params.setupKey,
      ...result,
    });
  },
);

/** Generates, validates, coaches, and warms one hand. */
export const processLiveHandGenerationJob = onDocumentWritten(
  {
    document: "liveGenerationJobs/{jobId}",
    region: "us-central1",
    secrets: [geminiApiKey],
    timeoutSeconds: 540,
    memory: "1GiB",
    maxInstances: 10,
  },
  async (event) => {
    const after = event.data?.after.exists ? event.data.after.data() : undefined;
    if (!isQueuedLiveGenerationJob(after)) return;
    const result = await processLiveGenerationJob({
      jobId: event.params.jobId,
      apiKey: requireApiKey(),
    });
    logger.info("processLiveHandGenerationJob completed", {
      jobId: event.params.jobId,
      ...result,
    });
  },
);

/** Recovers setup waves after a worker crash or event-delivery failure. */
export const recoverLiveGenerationLeases = onSchedule(
  {
    schedule: "every 5 minutes",
    region: "us-central1",
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async () => {
    const recovered = await recoverExpiredLiveGenerationLeases();
    if (recovered > 0) {
      logger.warn("Recovered expired live generation leases", {recovered});
    }
  },
);

/** Deletes expired transfer receipts and tombstoned anonymous course data. */
export const cleanupExpiredCourseTransfersJob = onSchedule(
  {
    schedule: "every 24 hours",
    region: "us-central1",
    timeoutSeconds: 300,
    memory: "256MiB",
  },
  async () => {
    const result = await cleanupExpiredCourseTransfers();
    if (result.receiptsDeleted > 0 || result.profilesDeleted > 0) {
      logger.info("cleanupExpiredCourseTransfers completed", result);
    }
  },
);

function requireAuth(
  uid: string | undefined,
  message = "Sign in required for live training.",
): string {
  if (!uid) {
    throw new HttpsError("unauthenticated", message);
  }
  return uid;
}

function rejectAnonymousLive(
  auth: {token?: {firebase?: {sign_in_provider?: string}}} | undefined,
): void {
  if (auth?.token?.firebase?.sign_in_provider === "anonymous") {
    throw new HttpsError(
      "permission-denied",
      "Create an account before Live Training.",
    );
  }
}

function callableError(name: string, error: unknown): HttpsError {
  if (error instanceof HttpsError) return error;
  const message = error instanceof Error ? error.message : String(error);
  logger.error(`${name} failed`, {error: message});
  return new HttpsError("internal", "Request failed. Retry shortly.");
}
