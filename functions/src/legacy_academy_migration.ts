/**
 * Plans migration of reverted academy documents.
 *
 * Lifetime XP is copied only as labeled legacy metadata when the stored
 * catalog version matches the current course and every referenced lesson id
 * is still in that catalog. Old lesson ids are never written as completions
 * or unlocks. Live Training paths are never in the delete set.
 *
 * Execute mode is a separate script concern: this module only plans.
 */

export const LEGACY_XP_LABEL = "legacy_academy";

export const PRESERVED_LIVE_SUBCOLLECTIONS = [
  "liveProgress",
  "liveHandHistory",
  "liveHandReceipts",
  "liveSessions",
  "liveStartRequests",
  "liveOpenSession",
  "liveActionFeed",
] as const;

const LEGACY_SUBCOLLECTIONS = [
  "academy",
  "academyLessons",
  "playedScenarios",
  "mistakes",
] as const;

export interface MigrationArguments {
  projectId: string;
  execute: boolean;
  allowProductionMigration: boolean;
  telemetryConfirmed: boolean;
}

export interface LegacyXpPatch {
  legacyLifetimeXp: number;
  legacyXpCatalogVersion: string;
  legacyXpLabel: typeof LEGACY_XP_LABEL;
}

export interface MigrationDecision {
  action: "skip" | "preserve_legacy_xp" | "delete_incompatible";
  reason: string;
  legacyLifetimeXp: number | null;
  patch: LegacyXpPatch | null;
  deletePaths: string[];
}

/** Parses CLI args. Execute requires an exact project match and telemetry. */
export function parseMigrationArguments(
  argv: readonly string[],
  productionProject = "live-poker-trainer",
): MigrationArguments {
  let projectId: string | undefined;
  let confirmProject: string | undefined;
  let execute = false;
  let allowProductionMigration = false;
  let telemetryConfirmed = false;

  for (const argument of argv) {
    if (argument === "--execute") {
      execute = true;
    } else if (argument === "--allow-production-migration") {
      allowProductionMigration = true;
    } else if (argument === "--confirm-telemetry=legacy-academy-observed") {
      telemetryConfirmed = true;
    } else if (argument.startsWith("--project=")) {
      projectId = argument.slice("--project=".length).trim();
    } else if (argument.startsWith("--confirm-project=")) {
      confirmProject = argument.slice("--confirm-project=".length).trim();
    } else {
      throw new Error(`Unknown argument: ${argument}`);
    }
  }

  if (!projectId) {
    throw new Error("Missing required --project=<id>.");
  }
  if (execute && confirmProject !== projectId) {
    throw new Error(
      "--execute requires --confirm-project=<id> matching --project exactly.",
    );
  }
  if (execute && !telemetryConfirmed) {
    throw new Error(
      "--execute requires --confirm-telemetry=legacy-academy-observed.",
    );
  }
  if (execute && projectId === productionProject && !allowProductionMigration) {
    throw new Error("Production migration requires --allow-production-migration.");
  }
  return {projectId, execute, allowProductionMigration, telemetryConfirmed};
}

/** Paths this migration may delete. Live Training is excluded. */
export function legacyDeletionPaths(uid: string): string[] {
  return LEGACY_SUBCOLLECTIONS.map((name) => `users/${uid}/${name}`);
}

export function preservedLivePaths(uid: string): string[] {
  return PRESERVED_LIVE_SUBCOLLECTIONS.map((name) => `users/${uid}/${name}`);
}

/**
 * Decides whether academy XP can be kept as metadata.
 *
 * Lesson id lists are inspected for compatibility only. They are not returned
 * as completions.
 */
export function assessLegacyAcademy(
  academy: Record<string, unknown> | null,
  options: {
    uid: string;
    currentCatalogVersion: string;
    knownLessonIds: ReadonlySet<string>;
  },
): MigrationDecision {
  const preserved = new Set(preservedLivePaths(options.uid));
  const deletePaths = legacyDeletionPaths(options.uid).filter(
    (path) => !preserved.has(path),
  );
  if (!academy) {
    return {
      action: "skip",
      reason: "no_academy_document",
      legacyLifetimeXp: null,
      patch: null,
      deletePaths: [],
    };
  }

  const version = typeof academy.catalogVersion === "string" ?
    academy.catalogVersion :
    "";
  const lessonIds = collectLessonIds(academy);
  const unknownIds = lessonIds.filter((id) => !options.knownLessonIds.has(id));
  const versionOk = version === options.currentCatalogVersion;
  const idsOk = unknownIds.length === 0;
  const xp = finiteXp(academy.lifetimeXp);

  if (versionOk && idsOk && xp != null) {
    return {
      action: "preserve_legacy_xp",
      reason: "catalog_compatible",
      legacyLifetimeXp: xp,
      patch: {
        legacyLifetimeXp: xp,
        legacyXpCatalogVersion: version,
        legacyXpLabel: LEGACY_XP_LABEL,
      },
      deletePaths,
    };
  }

  const reason = !versionOk ?
    "catalog_version_mismatch" :
    !idsOk ?
      "unknown_lesson_ids" :
      "missing_lifetime_xp";
  return {
    action: "delete_incompatible",
    reason,
    legacyLifetimeXp: null,
    patch: null,
    deletePaths,
  };
}

function collectLessonIds(academy: Record<string, unknown>): string[] {
  const ids = new Set<string>();
  for (const key of ["completedLessonIds", "lessonIds", "unlockedLessonIds"]) {
    const raw = academy[key];
    if (!Array.isArray(raw)) continue;
    for (const item of raw) {
      if (typeof item === "string" && item.length > 0) ids.add(item);
    }
  }
  return [...ids];
}

function finiteXp(value: unknown): number | null {
  const xp = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(xp) || xp < 0) return null;
  return Math.floor(xp);
}
