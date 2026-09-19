/**
 * Cloud Functions for Live Poker Trainer — server-authored situations.
 *
 * Callables (auth required):
 * - fetchSituation
 * - recordSituationProgress
 *
 * Background:
 * - refillSituationPool (Firestore trigger)
 * - prewarmCommonSituationPoolsJob (scheduler)
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {defineSecret} from "firebase-functions/params";
import {initializeApp} from "firebase-admin/app";
import {logger} from "firebase-functions";
import {fetchSituationForUser} from "./fetch_situation";
import {recordSituationProgressForUser} from "./record_progress";
import {
  isQueuedGeneration,
  refillQueuedSetup,
} from "./refill_situation_pool";
import {prewarmCommonSituationPools} from "./prewarm_common_setups";

initializeApp();

/** Gemini API key — set via `firebase functions:secrets:set GEMINI_API_KEY`. */
const geminiApiKey = defineSecret("GEMINI_API_KEY");

function requireApiKey(): string {
  const apiKey =
    geminiApiKey.value()?.trim() ||
    process.env.GEMINI_API_KEY?.trim() ||
    "";
  if (!apiKey) {
    throw new HttpsError(
      "failed-precondition",
      "GEMINI_API_KEY secret is not configured on Functions.",
    );
  }
  return apiKey;
}

/**
 * Returns exactly one unseen branching situation for the caller's table setup.
 *
 * Creates a receipt atomically so abandoned hands are never re-served.
 * Queues an asynchronous pool refill when inventory is empty or low.
 */
export const fetchSituation = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "512MiB",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Sign in required to fetch a situation.",
      );
    }

    const tableSetup = request.data?.tableSetup ?? request.data?.setup;
    if (!tableSetup) {
      throw new HttpsError(
        "invalid-argument",
        "tableSetup is required.",
      );
    }

    try {
      const result = await fetchSituationForUser({
        uid: request.auth.uid,
        rawSetup: tableSetup,
      });

      logger.info("fetchSituation ok", {
        uid: request.auth.uid,
        setupKey: result.setupKey,
        situationId: result.situationId,
        refillTriggered: result.refillTriggered,
      });

      return {
        ok: true,
        situationId: result.situationId,
        setupKey: result.setupKey,
        payload: result.payload,
        refillTriggered: result.refillTriggered,
      };
    } catch (err) {
      if (err instanceof HttpsError) throw err;
      const message = err instanceof Error ? err.message : String(err);
      logger.error("fetchSituation failed", {error: message});
      throw new HttpsError("internal", message);
    }
  },
);

/**
 * Generates queued situation batches outside the latency-sensitive callable.
 */
export const refillSituationPool = onDocumentWritten(
  {
    document: "tableSetups/{setupKey}",
    region: "us-central1",
    secrets: [geminiApiKey],
    timeoutSeconds: 540,
    memory: "1GiB",
    maxInstances: 2,
  },
  async (event) => {
    const afterData = event.data?.after.exists
      ? event.data.after.data()
      : undefined;
    if (!isQueuedGeneration(afterData)) return;
    const result = await refillQueuedSetup({
      setupKey: event.params.setupKey,
      afterData,
      apiKey: requireApiKey(),
    });
    if (result) {
      logger.info("refillSituationPool completed", {
        setupKey: event.params.setupKey,
        added: result.added,
        skipped: result.skipped,
        errorCount: result.errors.length,
        leaseHeldByOther: result.leaseHeldByOther,
      });
    }
  },
);

/**
 * Keeps popular Random Pool setups warm by queueing refills when low.
 */
export const prewarmCommonSituationPoolsJob = onSchedule(
  {
    schedule: "every 30 minutes",
    region: "us-central1",
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async (_event) => {
    const results = await prewarmCommonSituationPools();
    const queued = results.filter((r) => r.queued).length;
    logger.info("prewarmCommonSituationPools completed", {
      checked: results.length,
      queued,
    });
  },
);

/**
 * Records a completed (or abandoned-with-path) situation for progress stats.
 *
 * Validates the path against the allocated situation before updating aggregates.
 */
export const recordSituationProgress = onCall(
  {
    region: "us-central1",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Sign in required to record progress.",
      );
    }

    try {
      const result = await recordSituationProgressForUser({
        uid: request.auth.uid,
        raw: request.data,
      });
      return result;
    } catch (err) {
      if (err instanceof HttpsError) throw err;
      const message = err instanceof Error ? err.message : String(err);
      logger.error("recordSituationProgress failed", {error: message});
      throw new HttpsError("internal", message);
    }
  },
);
