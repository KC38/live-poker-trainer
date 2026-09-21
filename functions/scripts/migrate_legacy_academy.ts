/**
 * Dry-run-by-default migration for reverted academy learning data.
 *
 * Preserves Auth, identity, avatar, preferences, audio, and Live Training.
 * Compatible lifetime XP is written only as labeled legacy metadata.
 * Old lesson ids are never copied onto course completions.
 *
 * Usage (from functions/):
 *   npx ts-node --transpile-only scripts/migrate_legacy_academy.ts \
 *     --project=my-staging-project
 *   npx ts-node --transpile-only scripts/migrate_legacy_academy.ts \
 *     --project=my-staging-project --execute \
 *     --confirm-project=my-staging-project \
 *     --confirm-telemetry=legacy-academy-observed
 */

import {applicationDefault, initializeApp} from "firebase-admin/app";
import {
  FieldPath,
  getFirestore,
  type DocumentSnapshot,
  type Firestore,
} from "firebase-admin/firestore";
import {courseBank, lessonIdsInOrder} from "../src/course_catalog";
import {
  assessLegacyAcademy,
  parseMigrationArguments,
  type MigrationDecision,
} from "../src/legacy_academy_migration";

const PAGE_SIZE = 200;

export async function main(argv = process.argv.slice(2)): Promise<void> {
  const options = parseMigrationArguments(argv);
  initializeApp({
    credential: applicationDefault(),
    projectId: options.projectId,
  });
  const db = getFirestore();
  const knownLessonIds = new Set(lessonIdsInOrder(courseBank));
  console.log(
    options.execute ?
      `EXECUTE mode — migrating legacy academy data in ${options.projectId}` :
      `DRY-RUN mode — target project: ${options.projectId}; no writes will occur`,
  );

  let scanned = 0;
  let preserved = 0;
  let incompatible = 0;
  let skipped = 0;
  let cursor: DocumentSnapshot | undefined;

  for (;;) {
    const query = cursor === undefined ?
      db.collection("users").orderBy(FieldPath.documentId()).limit(PAGE_SIZE) :
      db.collection("users").orderBy(FieldPath.documentId())
        .startAfter(cursor).limit(PAGE_SIZE);
    const snap = await query.get();
    if (snap.empty) break;
    for (const user of snap.docs) {
      scanned += 1;
      const academySnap = await db
        .collection("users").doc(user.id)
        .collection("academy").doc("main")
        .get();
      const decision = assessLegacyAcademy(
        academySnap.exists ? academySnap.data() ?? null : null,
        {
          uid: user.id,
          currentCatalogVersion: courseBank.catalogVersion,
          knownLessonIds,
        },
      );
      if (decision.action === "skip") skipped += 1;
      if (decision.action === "preserve_legacy_xp") preserved += 1;
      if (decision.action === "delete_incompatible") incompatible += 1;
      await applyDecision(db, user.id, decision, options.execute);
    }
    cursor = snap.docs[snap.docs.length - 1];
    if (snap.size < PAGE_SIZE) break;
  }

  console.log(
    `scanned=${scanned} preservedXp=${preserved} ` +
    `incompatible=${incompatible} skipped=${skipped} ` +
    `mode=${options.execute ? "execute" : "dry-run"}`,
  );
}

async function applyDecision(
  db: Firestore,
  uid: string,
  decision: MigrationDecision,
  execute: boolean,
): Promise<void> {
  if (decision.action === "skip") return;
  if (decision.patch) {
    const path = `users/${uid}/course/main`;
    if (execute) {
      await db.doc(path).set(decision.patch, {merge: true});
      console.log(`  wrote legacy XP metadata on ${path}`);
    } else {
      console.log(
        `  would write legacy XP ${decision.patch.legacyLifetimeXp} on ${path}`,
      );
    }
  } else if (!execute) {
    console.log(
      `  would leave incompatible academy data read-only for users/${uid} ` +
      `(${decision.reason}) until execute`,
    );
  }
  if (!execute) {
    for (const path of decision.deletePaths) {
      console.log(`  would delete ${path} after confirmation`);
    }
    return;
  }
  for (const path of decision.deletePaths) {
    const collection = db.collection(path);
    const docs = await collection.limit(400).get();
    if (docs.empty) continue;
    const batch = db.batch();
    for (const doc of docs.docs) batch.delete(doc.ref);
    await batch.commit();
    console.log(`  deleted ${docs.size} docs under ${path}`);
  }
}

if (require.main === module) {
  void main().catch((err: unknown) => {
    console.error(err instanceof Error ? err.message : err);
    process.exitCode = 1;
  });
}
