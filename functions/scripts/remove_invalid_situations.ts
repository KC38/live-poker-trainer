/**
 * Removes stored Firestore situations that fail the current validator.
 *
 * Dry-run by default. Execution requires exact project confirmation, and the
 * production project additionally requires an explicit production flag.
 * User receipts and hand history are intentionally preserved.
 *
 * Usage (from functions/):
 *   npx ts-node --transpile-only scripts/remove_invalid_situations.ts \
 *     --project=live-poker-trainer
 *   npx ts-node --transpile-only scripts/remove_invalid_situations.ts \
 *     --project=live-poker-trainer --execute \
 *     --confirm-project=live-poker-trainer --allow-production-cleanup
 */

import {applicationDefault, initializeApp} from "firebase-admin/app";
import {
  FieldValue,
  getFirestore,
  type DocumentReference,
  type Firestore,
  type QueryDocumentSnapshot,
} from "firebase-admin/firestore";
import {
  validateSituation,
  type ValidationIssue,
} from "../src/validate_situation";

const PRODUCTION_PROJECT = "live-poker-trainer";
const DELETE_BATCH_SIZE = 450;
const PREVIEW_LIMIT = 30;

/** Validated command-line options for invalid-situation cleanup. */
export interface CleanupArguments {
  projectId: string;
  execute: boolean;
  allowProductionCleanup: boolean;
}

/** Summary emitted after a dry-run or execution. */
export interface CleanupSummary {
  setupsScanned: number;
  situationsScanned: number;
  invalidSituations: number;
  deletedSituations: number;
  setupsRecounted: number;
}

/** Parses cleanup arguments without accessing process state. */
export function parseCleanupArguments(
  argv: readonly string[],
): CleanupArguments {
  let projectId: string | undefined;
  let confirmProject: string | undefined;
  let execute = false;
  let allowProductionCleanup = false;

  for (const argument of argv) {
    if (argument === "--execute") {
      execute = true;
    } else if (argument === "--allow-production-cleanup") {
      allowProductionCleanup = true;
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
    !allowProductionCleanup
  ) {
    throw new Error(
      "Production cleanup requires --allow-production-cleanup.",
    );
  }

  return {projectId, execute, allowProductionCleanup};
}

/** Safely validates an untrusted stored payload. */
export function situationValidationIssues(payload: unknown): ValidationIssue[] {
  try {
    return validateSituation(payload).issues;
  } catch (error) {
    return [{
      code: "validator_exception",
      message: error instanceof Error ? error.message : String(error),
    }];
  }
}

/** Runs the cleanup against a Firestore database. */
export async function removeInvalidSituations(
  db: Firestore,
  execute: boolean,
): Promise<CleanupSummary> {
  const summary: CleanupSummary = {
    setupsScanned: 0,
    situationsScanned: 0,
    invalidSituations: 0,
    deletedSituations: 0,
    setupsRecounted: 0,
  };
  let previewed = 0;

  const setupSnapshot = await db.collection("tableSetups").get();
  summary.setupsScanned = setupSnapshot.size;

  for (const setup of setupSnapshot.docs) {
    const situations = await setup.ref.collection("situations").get();
    summary.situationsScanned += situations.size;
    const invalid = situations.docs.filter(
      (document) =>
        situationValidationIssues(document.data().payload).length > 0,
    );
    summary.invalidSituations += invalid.length;

    for (const document of invalid) {
      if (previewed >= PREVIEW_LIMIT) break;
      const issues = situationValidationIssues(document.data().payload);
      const detail = issues
        .slice(0, 3)
        .map((issue) => `${issue.code}: ${issue.message}`)
        .join("; ");
      console.log(`  ${execute ? "deleting" : "would delete"} ` +
        `${document.ref.path} (${detail})`);
      previewed += 1;
    }

    if (!execute || invalid.length === 0) continue;

    await deleteDocuments(db, invalid);
    summary.deletedSituations += invalid.length;
    await recountSetup(db, setup.ref);
    summary.setupsRecounted += 1;
  }

  if (summary.invalidSituations > previewed) {
    console.log(
      `  ... ${summary.invalidSituations - previewed} additional invalid ` +
        "situations",
    );
  }
  return summary;
}

async function deleteDocuments(
  db: Firestore,
  documents: QueryDocumentSnapshot[],
): Promise<void> {
  for (let offset = 0; offset < documents.length; offset += DELETE_BATCH_SIZE) {
    const batch = db.batch();
    for (const document of documents.slice(
      offset,
      offset + DELETE_BATCH_SIZE,
    )) {
      batch.delete(document.ref);
    }
    await batch.commit();
  }
}

async function recountSetup(
  db: Firestore,
  setupRef: DocumentReference,
): Promise<void> {
  await db.runTransaction(async (transaction) => {
    const remaining = await transaction.get(
      setupRef.collection("situations"),
    );
    const neverServedCount = remaining.docs.filter(
      (document) => Number(document.data().timesServed ?? 0) === 0,
    ).length;
    transaction.set(
      setupRef,
      {
        situationCount: remaining.size,
        neverServedCount,
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
  });
}

function parseValue(argument: string, prefix: string): string {
  const value = argument.slice(prefix.length).trim();
  if (value.length === 0) {
    throw new Error(`${prefix}<id> must not be empty.`);
  }
  return value;
}

/** CLI entry point. */
export async function main(argv = process.argv.slice(2)): Promise<void> {
  const options = parseCleanupArguments(argv);
  initializeApp({
    credential: applicationDefault(),
    projectId: options.projectId,
  });
  const db = getFirestore();

  console.log(
    options.execute
      ? `EXECUTE mode — deleting invalid situations in ${options.projectId}`
      : `DRY-RUN mode — target project: ${options.projectId}; ` +
        "no writes will occur",
  );
  const summary = await removeInvalidSituations(db, options.execute);
  console.log("\nSummary:");
  console.log(`  setups scanned: ${summary.setupsScanned}`);
  console.log(`  situations scanned: ${summary.situationsScanned}`);
  console.log(`  invalid situations: ${summary.invalidSituations}`);
  console.log(`  situations ${options.execute ? "deleted" : "to delete"}: ` +
    `${options.execute ? summary.deletedSituations : summary.invalidSituations}`);
  console.log(`  setup counters recounted: ${summary.setupsRecounted}`);
  console.log(options.execute ? "\nDone." : "\nDry-run complete.");
}

if (require.main === module) {
  void main().catch((error: unknown) => {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  });
}
