/**
 * Seeds and waits for the launch-default live hand pool.
 *
 * Usage:
 *   npx ts-node --transpile-only scripts/seed_live_default.ts \
 *     --project=live-poker-trainer --confirm-project=live-poker-trainer
 */

import {applicationDefault, initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {buildLiveSetupKey, DEFAULT_LIVE_SETUP} from "../src/live_setup";
import {LIVE_INITIAL_POOL_SIZE} from "../src/live_types";
import {MIN_LIVE_CLIENT_VERSION} from "../src/live_session";

const POLL_MS = 10_000;
const MAX_WAIT_MS = 60 * 60 * 1000;

async function main(argv = process.argv.slice(2)): Promise<void> {
  const project = value(argv, "--project=");
  const confirmation = value(argv, "--confirm-project=");
  if (!project || confirmation !== project) {
    throw new Error(
      "Exact --project and --confirm-project values are required.",
    );
  }
  initializeApp({credential: applicationDefault(), projectId: project});
  const db = getFirestore();
  const setupKey = buildLiveSetupKey(DEFAULT_LIVE_SETUP);
  const setupRef = db.collection("liveTableSetups").doc(setupKey);
  await db.doc("system/liveConfig").set({
    maintenance: true,
    minClientVersion: MIN_LIVE_CLIENT_VERSION,
    message: "Preparing the new live training pool.",
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(setupRef);
    if (!snapshot.exists) {
      tx.create(setupRef, {
        setupKey,
        setup: DEFAULT_LIVE_SETUP,
        handCount: 0,
        generation: {
          status: "queued",
          leaseId: null,
          leaseExpiresAtMs: null,
          requestedBatch: LIVE_INITIAL_POOL_SIZE,
          lastError: null,
        },
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }
    const generation = snapshot.data()?.generation ?? {};
    const activeLease =
      generation.status === "generating" &&
      Number(generation.leaseExpiresAtMs ?? 0) > Date.now();
    if (
      Number(snapshot.data()?.handCount ?? 0) < LIVE_INITIAL_POOL_SIZE &&
      !activeLease
    ) {
      tx.set(setupRef, {
        generation: {
          status: "queued",
          leaseId: null,
          leaseExpiresAtMs: null,
          requestedBatch:
            LIVE_INITIAL_POOL_SIZE - Number(snapshot.data()?.handCount ?? 0),
          lastError: null,
        },
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
    }
  });
  const started = Date.now();
  for (;;) {
    const snapshot = await setupRef.get();
    const count = Number(snapshot.data()?.handCount ?? 0);
    const status = String(snapshot.data()?.generation?.status ?? "missing");
    const leaseExpired =
      status === "generating" &&
      Number(snapshot.data()?.generation?.leaseExpiresAtMs ?? 0) <= Date.now();
    console.log(`default pool: ready=${count}, generation=${status}`);
    if (count >= LIVE_INITIAL_POOL_SIZE && status === "idle") {
      await db.doc("system/liveConfig").set({
        maintenance: false,
        minClientVersion: MIN_LIVE_CLIENT_VERSION,
        message: null,
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
      console.log(`Default pool ready for ${project}: ${setupKey}`);
      return;
    }
    if ((status === "idle" || leaseExpired) && count < LIVE_INITIAL_POOL_SIZE) {
      await setupRef.set({
        generation: {
          status: "queued",
          leaseId: null,
          leaseExpiresAtMs: null,
          requestedBatch: LIVE_INITIAL_POOL_SIZE - count,
          lastError: null,
        },
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
    }
    if (Date.now() - started > MAX_WAIT_MS) {
      throw new Error("Timed out waiting for ten warmed default hands.");
    }
    await new Promise((resolve) => setTimeout(resolve, POLL_MS));
  }
}

function value(args: readonly string[], prefix: string): string | undefined {
  return args.find((argument) => argument.startsWith(prefix))
    ?.slice(prefix.length)
    .trim();
}

void main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
