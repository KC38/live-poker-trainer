/**
 * Cloud Functions for Live Poker Trainer.
 *
 * `ensureScenarioPool` generates Gemini scenarios into the shared Firestore
 * pool (`scenarios/{contentHash}`). Optimal EV stamping stays client-side.
 */
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {hashSetup} from "./content_hash";
import {generateScenarios} from "./gemini";

initializeApp();

/** Gemini API key — set via `firebase functions:secrets:set GEMINI_API_KEY`. */
const geminiApiKey = defineSecret("GEMINI_API_KEY");

/** Matches Flutter `ScenarioDao.payloadVersion` / `ScenarioPoolDoc`. */
const PAYLOAD_VERSION = 1;

/**
 * Ensures the shared scenario pool has fresh Gemini content.
 *
 * Auth required. Upserts `scenarios/{contentHash}` and skips duplicates.
 * Returns how many new docs were added (existing hashes are ignored).
 */
export const ensureScenarioPool = onCall(
  {
    region: "us-central1",
    secrets: [geminiApiKey],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Sign in required to refill the scenario pool.",
      );
    }

    const countRaw = request.data?.count;
    const count =
      typeof countRaw === "number" && Number.isFinite(countRaw)
        ? Math.min(Math.max(Math.trunc(countRaw), 1), 20)
        : 5;

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

    const generated = await generateScenarios({apiKey, count});
    const db = getFirestore();
    let added = 0;
    let skipped = 0;
    const hashes: string[] = [];

    for (const payload of generated.scenarios) {
      const contentHash = hashSetup(payload);
      hashes.push(contentHash);
      const ref = db.collection("scenarios").doc(contentHash);
      const existing = await ref.get();
      if (existing.exists) {
        skipped += 1;
        continue;
      }
      await ref.set({
        payload,
        source: "gemini",
        modelId: generated.modelId,
        generatedAt: FieldValue.serverTimestamp(),
        timesServed: 0,
        payloadVersion: PAYLOAD_VERSION,
      });
      added += 1;
    }

    logger.info("ensureScenarioPool completed", {
      uid: request.auth.uid,
      requestedCount: count,
      generated: generated.scenarios.length,
      added,
      skipped,
      errors: generated.errors.length,
    });

    return {
      ok: true,
      requestedCount: count,
      generated: generated.scenarios.length,
      added,
      skipped,
      modelId: generated.modelId,
      contentHashes: hashes,
      errors: generated.errors,
    };
  },
);
