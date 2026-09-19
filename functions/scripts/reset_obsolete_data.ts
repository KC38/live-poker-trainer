/**
 * Admin reset for obsolete Firestore training data.
 *
 * Dry-run by default. An explicit target project is always required.
 *
 * Preserves Firebase Auth and users/{uid} identity/preferences fields.
 * Purges scenarios, tableSetups, and obsolete per-user training subcollections.
 *
 * Usage (from functions/):
 *   npm run reset:dry -- --project=my-staging-project
 *   npx ts-node --transpile-only scripts/reset_obsolete_data.ts \
 *     --project=my-staging-project --execute \
 *     --confirm-project=my-staging-project
 */

import {initializeApp, applicationDefault} from "firebase-admin/app";
import {
  FieldValue,
  getFirestore,
  type CollectionReference,
  type DocumentSnapshot,
  type Firestore,
  type Query,
} from "firebase-admin/firestore";

const PRODUCTION_PROJECT = "live-poker-trainer";
const PAGE_SIZE = 400;
const PREVIEW_LIMIT = 20;

interface Counter {
  scanned: number;
  deleted: number;
}

/** Validated command-line arguments for the reset. */
export interface ResetArguments {
  projectId: string;
  execute: boolean;
  allowProductionReset: boolean;
}

/**
 * Parses and validates reset arguments without accessing process state.
 *
 * Execute mode requires an exact project confirmation. Production additionally
 * requires the deliberately verbose production-reset flag.
 */
export function parseResetArguments(argv: readonly string[]): ResetArguments {
  let projectId: string | undefined;
  let confirmProject: string | undefined;
  let execute = false;
  let allowProductionReset = false;

  for (const argument of argv) {
    if (argument === "--execute") {
      execute = true;
    } else if (argument === "--allow-production-reset") {
      allowProductionReset = true;
    } else if (argument.startsWith("--project=")) {
      projectId = parseValue(argument, "--project=");
    } else if (argument.startsWith("--confirm-project=")) {
      confirmProject = parseValue(argument, "--confirm-project=");
    } else {
      throw new Error(`Unknown argument: ${argument}`);
    }
  }

  if (projectId === undefined) {
    throw new Error("Missing required --project=<id>.");
  }
  if (execute && confirmProject !== projectId) {
    throw new Error(
      "--execute requires --confirm-project=<id> matching --project exactly.",
    );
  }
  if (
    execute &&
    projectId === PRODUCTION_PROJECT &&
    !allowProductionReset
  ) {
    throw new Error(
      "Production reset requires --allow-production-reset.",
    );
  }

  return {projectId, execute, allowProductionReset};
}

function parseValue(argument: string, prefix: string): string {
  const value = argument.slice(prefix.length).trim();
  if (value.length === 0) {
    throw new Error(`${prefix}<id> must not be empty.`);
  }
  return value;
}

/**
 * Entry point.
 */
export async function main(argv = process.argv.slice(2)): Promise<void> {
  const options = parseResetArguments(argv);
  initializeApp({
    credential: applicationDefault(),
    projectId: options.projectId,
  });
  const db = getFirestore();

  console.log(
    options.execute
      ? `EXECUTE mode — deleting obsolete data in ${options.projectId}`
      : `DRY-RUN mode — target project: ${options.projectId}; no writes will occur`,
  );

  const summary: Record<string, Counter> = {};

  summary.scenarios = await purgeCollection(
    db.collection("scenarios"),
    options.execute,
  );
  // Collection-group deletion catches orphaned situation docs whose setup
  // parent was deleted by an earlier partial reset.
  summary.situations = await purgeQuery(
    db.collectionGroup("situations"),
    options.execute,
  );
  summary.tableSetups = await purgeCollection(
    db.collection("tableSetups"),
    options.execute,
  );

  // Collection-group queries also remove data under missing user-parent docs
  // (for example, a deleted smoke-test Auth user).
  for (const name of [
    "playedScenarios",
    "mistakes",
    "situationReceipts",
    "handHistory",
    "progress",
    "serverLimits",
  ]) {
    summary[name] = await purgeQuery(
      db.collectionGroup(name),
      options.execute,
    );
  }

  summary.userStatsCleared = await clearUserStats(db, options.execute);
  summary.situationPoolLimits = await clearPoolLimits(
    db,
    options.execute,
  );

  console.log("\nSummary:");
  for (const [key, counter] of Object.entries(summary)) {
    console.log(
      `  ${key}: scanned=${counter.scanned} ` +
        `${options.execute ? "deleted" : "wouldDelete"}=${counter.deleted}`,
    );
  }
  console.log(
    options.execute
      ? "\nDone."
      : `\nDry-run complete for ${options.projectId}. ` +
        "Use explicit execute and matching confirmation flags to apply.",
  );
}

async function purgeCollection(
  col: CollectionReference,
  execute: boolean,
): Promise<Counter> {
  return purgeQuery(col, execute);
}

async function purgeQuery(
  query: Query,
  execute: boolean,
): Promise<Counter> {
  const counter: Counter = {scanned: 0, deleted: 0};
  let cursor: DocumentSnapshot | undefined;
  let previewed = 0;

  for (;;) {
    const pageQuery = execute || cursor === undefined
      ? query.limit(PAGE_SIZE)
      : query.startAfter(cursor).limit(PAGE_SIZE);
    const snap = await pageQuery.get();
    if (snap.empty) break;

    counter.scanned += snap.size;
    counter.deleted += snap.size;
    if (execute) {
      const batch = snap.docs[0].ref.firestore.batch();
      for (const doc of snap.docs) batch.delete(doc.ref);
      await batch.commit();
    } else {
      for (const doc of snap.docs) {
        if (previewed < PREVIEW_LIMIT) {
          console.log(`  would delete ${doc.ref.path}`);
          previewed += 1;
        }
      }
      cursor = snap.docs[snap.docs.length - 1];
    }

    if (snap.size < PAGE_SIZE) break;
  }
  if (!execute && counter.deleted > previewed) {
    console.log(`  ... ${counter.deleted - previewed} additional matches`);
  }
  return counter;
}

async function clearUserStats(
  db: Firestore,
  execute: boolean,
): Promise<Counter> {
  const counter: Counter = {scanned: 0, deleted: 0};
  let cursor: DocumentSnapshot | undefined;

  for (;;) {
    const query = cursor === undefined
      ? db.collection("users").limit(PAGE_SIZE)
      : db.collection("users").startAfter(cursor).limit(PAGE_SIZE);
    const snap = await query.get();
    if (snap.empty) break;
    counter.scanned += snap.size;

    const matching = snap.docs.filter(
      (doc) => doc.data().stats !== undefined,
    );
    counter.deleted += matching.length;
    if (execute && matching.length > 0) {
      const batch = db.batch();
      for (const doc of matching) {
        batch.update(doc.ref, {
          stats: FieldValue.delete(),
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } else if (!execute) {
      for (const doc of matching) {
        console.log(`  would clear stats on ${doc.ref.path}`);
      }
    }

    cursor = snap.docs[snap.docs.length - 1];
    if (snap.size < PAGE_SIZE) break;
  }
  return counter;
}

async function clearPoolLimits(
  db: Firestore,
  execute: boolean,
): Promise<Counter> {
  const ref = db.doc("system/situationPoolLimits");
  const snap = await ref.get();
  if (!snap.exists) return {scanned: 1, deleted: 0};

  if (execute) {
    await ref.delete();
  } else {
    console.log(`  would delete ${ref.path}`);
  }
  return {scanned: 1, deleted: 1};
}

if (require.main === module) {
  void main().catch((err: unknown) => {
    console.error(err instanceof Error ? err.message : err);
    process.exitCode = 1;
  });
}
