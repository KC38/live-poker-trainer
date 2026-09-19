/**
 * Admin reset for obsolete Firestore training data.
 *
 * Dry-run by default. An explicit target project is always required.
 *
 * Preserves Firebase Auth plus users/{uid} identity/avatar fields.
 * Purges every v2/v3 training artifact and resets gameplay preferences to the
 * v3 launch default ($1/$2, six seats, 200 BB maximum, random lineup).
 *
 * Usage (from functions/):
 *   npm run reset:dry -- --project=my-staging-project
 *   npx ts-node --transpile-only scripts/reset_obsolete_data.ts \
 *     --project=my-staging-project --execute \
 *     --confirm-project=my-staging-project
 */

import {initializeApp, applicationDefault} from "firebase-admin/app";
import {
  FieldPath,
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
    (doc) => doc.ref.path.startsWith("tableSetups/"),
  );
  summary.generationRuns = await purgeQuery(
    db.collectionGroup("generationRuns"),
    options.execute,
    (doc) => doc.ref.path.startsWith("tableSetups/"),
  );
  for (const name of ["actions", "nodes", "hands"]) {
    summary[name] = await purgeQuery(
      db.collectionGroup(name),
      options.execute,
      (doc) => doc.ref.path.startsWith("liveTableSetups/"),
    );
  }
  summary.tableSetups = await purgeCollection(
    db.collection("tableSetups"),
    options.execute,
  );
  summary.liveTableSetups = await purgeCollection(
    db.collection("liveTableSetups"),
    options.execute,
  );
  summary.liveGenerationJobs = await purgeCollection(
    db.collection("liveGenerationJobs"),
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
    "decisions",
    "liveSessions",
    "liveStartRequests",
    "liveOpenSession",
    "liveHandReceipts",
    "liveHandHistory",
    "liveProgress",
  ]) {
    summary[name] = await purgeQuery(
      db.collectionGroup(name),
      options.execute,
      (doc) =>
        doc.ref.path.startsWith("users/") &&
        (name !== "decisions" || doc.ref.path.includes("/liveSessions/")),
    );
  }

  summary.usersReset = await resetUsers(db, options.execute);
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
  include: (doc: DocumentSnapshot) => boolean = () => true,
): Promise<Counter> {
  const counter: Counter = {scanned: 0, deleted: 0};
  let cursor: DocumentSnapshot | undefined;
  let previewed = 0;
  const ordered = query.orderBy(FieldPath.documentId());

  for (;;) {
    const pageQuery = cursor === undefined
      ? ordered.limit(PAGE_SIZE)
      : ordered.startAfter(cursor).limit(PAGE_SIZE);
    const snap = await pageQuery.get();
    if (snap.empty) break;

    counter.scanned += snap.size;
    const matches = snap.docs.filter(include);
    counter.deleted += matches.length;
    if (execute) {
      if (matches.length > 0) {
        const batch = matches[0].ref.firestore.batch();
        for (const doc of matches) batch.delete(doc.ref);
        await batch.commit();
      }
    } else {
      for (const doc of matches) {
        if (previewed < PREVIEW_LIMIT) {
          console.log(`  would delete ${doc.ref.path}`);
          previewed += 1;
        }
      }
    }
    cursor = snap.docs[snap.docs.length - 1];

    if (snap.size < PAGE_SIZE) break;
  }
  if (!execute && counter.deleted > previewed) {
    console.log(`  ... ${counter.deleted - previewed} additional matches`);
  }
  return counter;
}

async function resetUsers(
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

    counter.deleted += snap.size;
    if (execute && snap.size > 0) {
      const batch = db.batch();
      for (const doc of snap.docs) {
        batch.update(doc.ref, {
          stats: FieldValue.delete(),
          preferences: {
            smallBlind: 1,
            bigBlind: 2,
            seatCount: 6,
            maxStackDepthBb: 200,
            chipDisplayMode: "both",
            lineupMode: "randomPool",
            customArchetypes: "",
          },
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } else if (!execute) {
      for (const doc of snap.docs) {
        console.log(`  would reset training data on ${doc.ref.path}`);
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
