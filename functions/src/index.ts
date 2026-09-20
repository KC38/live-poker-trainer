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
  resumeLiveHandForUser,
  startLiveHandForUser,
  submitLiveActionForUser,
  undoLiveActionForUser,
} from "./live_session";

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
    try {
      return await undoLiveActionForUser({uid, raw: request.data});
    } catch (error) {
      throw callableError("undoLiveAction", error);
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

function requireAuth(uid: string | undefined): string {
  if (!uid) {
    throw new HttpsError(
      "unauthenticated",
      "Sign in required for live training.",
    );
  }
  return uid;
}

function callableError(name: string, error: unknown): HttpsError {
  if (error instanceof HttpsError) return error;
  const message = error instanceof Error ? error.message : String(error);
  logger.error(`${name} failed`, {error: message});
  return new HttpsError("internal", "Live training failed. Retry shortly.");
}
