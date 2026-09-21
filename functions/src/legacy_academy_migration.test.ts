/**
 * Unit tests for legacy academy migration planning.
 */

import {describe, expect, it} from "vitest";
import {
  assessLegacyAcademy,
  parseMigrationArguments,
  preservedLivePaths,
} from "./legacy_academy_migration";

const known = new Set(["lesson-01-01-01-your-two-cards"]);

describe("parseMigrationArguments", () => {
  it("defaults to dry run and requires a project", () => {
    expect(parseMigrationArguments(["--project=staging"]).execute).toBe(false);
    expect(() => parseMigrationArguments([])).toThrow(/--project/);
  });

  it("rejects execute without an exact project confirmation", () => {
    expect(() => parseMigrationArguments([
      "--project=staging",
      "--execute",
      "--confirm-telemetry=legacy-academy-observed",
    ])).toThrow(/confirm-project/);
  });

  it("rejects execute without telemetry confirmation", () => {
    expect(() => parseMigrationArguments([
      "--project=staging",
      "--execute",
      "--confirm-project=staging",
    ])).toThrow(/confirm-telemetry/);
  });

  it("rejects production execute without the production guard", () => {
    expect(() => parseMigrationArguments([
      "--project=live-poker-trainer",
      "--execute",
      "--confirm-project=live-poker-trainer",
      "--confirm-telemetry=legacy-academy-observed",
    ])).toThrow(/allow-production-migration/);
  });

  it("accepts a confirmed non-production execute", () => {
    const args = parseMigrationArguments([
      "--project=staging",
      "--execute",
      "--confirm-project=staging",
      "--confirm-telemetry=legacy-academy-observed",
    ]);
    expect(args.execute).toBe(true);
    expect(args.projectId).toBe("staging");
  });
});

describe("assessLegacyAcademy", () => {
  it("skips users with no academy document and deletes nothing", () => {
    const decision = assessLegacyAcademy(null, {
      uid: "u1",
      currentCatalogVersion: "2.0.0",
      knownLessonIds: known,
    });
    expect(decision.action).toBe("skip");
    expect(decision.deletePaths).toEqual([]);
    expect(decision.patch).toBeNull();
  });

  it("keeps compatible XP as labeled metadata and does not map lesson ids", () => {
    const decision = assessLegacyAcademy({
      catalogVersion: "2.0.0",
      lifetimeXp: 80,
      completedLessonIds: ["lesson-01-01-01-your-two-cards"],
    }, {
      uid: "u1",
      currentCatalogVersion: "2.0.0",
      knownLessonIds: known,
    });
    expect(decision.action).toBe("preserve_legacy_xp");
    expect(decision.patch).toEqual({
      legacyLifetimeXp: 80,
      legacyXpCatalogVersion: "2.0.0",
      legacyXpLabel: "legacy_academy",
    });
    expect(decision.patch).not.toHaveProperty("completedLessonIds");
    expect(decision.patch).not.toHaveProperty("lifetimeXp");
    for (const path of preservedLivePaths("u1")) {
      expect(decision.deletePaths).not.toContain(path);
    }
  });

  it("does not keep XP when the catalog version or lesson ids are incompatible", () => {
    const mismatch = assessLegacyAcademy({
      catalogVersion: "1.0.0",
      lifetimeXp: 80,
      completedLessonIds: ["lesson-01-01-01-your-two-cards"],
    }, {
      uid: "u1",
      currentCatalogVersion: "2.0.0",
      knownLessonIds: known,
    });
    expect(mismatch.action).toBe("delete_incompatible");
    expect(mismatch.patch).toBeNull();

    const unknown = assessLegacyAcademy({
      catalogVersion: "2.0.0",
      lifetimeXp: 40,
      unlockedLessonIds: ["old-academy-lesson"],
    }, {
      uid: "u1",
      currentCatalogVersion: "2.0.0",
      knownLessonIds: known,
    });
    expect(unknown.action).toBe("delete_incompatible");
    expect(unknown.reason).toBe("unknown_lesson_ids");
    expect(JSON.stringify(unknown)).not.toContain("completedLessonIds");
  });
});
