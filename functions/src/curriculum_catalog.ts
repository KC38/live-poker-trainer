/**
 * Frozen curriculum catalog loader for the learning platform foundation.
 *
 * Imports a generated slim subset under `generated/`. Learning callables import
 * this module and gate on LearningFeatureFlags (default off).
 */

import rawCatalog from "./generated/curriculum_catalog.json";
import type {
  CurriculumCatalog,
  CurriculumLesson,
  SimulationClaim,
} from "./curriculum_types";

const LESSONS_PER_UNIT = 3;

const VALID_FORMATS = new Set([
  "concept",
  "decision_drill",
  "worked_review",
  "scenario",
  "assessment",
  "hand_lab",
]);

const VALID_CLAIMS = new Set<SimulationClaim>([
  "engine_supported",
  "conceptual_only",
]);

function isVariantUnit(unitId: string, unitTitle: string): boolean {
  return /variant/i.test(unitId) || /variant/i.test(unitTitle);
}

function pushUnique(
  map: Map<string, string>,
  id: string,
  kind: string,
  errors: string[],
): void {
  const existing = map.get(id);
  if (existing) {
    errors.push(`Duplicate ${kind} id "${id}" (also used as ${existing})`);
    return;
  }
  map.set(id, kind);
}

/**
 * Structural invariants for any catalog document (full or slim subset).
 * Throws AggregateError-style Error with a joined message on failure.
 */
export function assertCatalogInvariants(catalog: CurriculumCatalog): void {
  const errors: string[] = [];

  if (!catalog.catalogVersion?.trim()) {
    errors.push("catalogVersion is required");
  }
  if (!catalog.minClientVersion?.trim()) {
    errors.push("minClientVersion is required");
  }
  if (!Array.isArray(catalog.sections) || catalog.sections.length < 1) {
    errors.push("sections must be a non-empty array");
  }
  if (!Array.isArray(catalog.objectives) || catalog.objectives.length < 1) {
    errors.push("objectives must be a non-empty array");
  }
  if (
    !Array.isArray(catalog.milestoneGates) ||
    catalog.milestoneGates.length < 1
  ) {
    errors.push("milestoneGates must be a non-empty array");
  }

  const ids = new Map<string, string>();
  let unitCount = 0;
  let lessonCount = 0;

  for (const objective of catalog.objectives ?? []) {
    if (!objective?.id) {
      errors.push("objective missing id");
      continue;
    }
    pushUnique(ids, objective.id, "objective", errors);
  }

  const objectiveIdSet = new Set(
    (catalog.objectives ?? [])
      .map((objective) => objective?.id)
      .filter((id): id is string => Boolean(id)),
  );

  for (const gate of catalog.milestoneGates ?? []) {
    if (!gate?.id) {
      errors.push("milestoneGate missing id");
      continue;
    }
    pushUnique(ids, gate.id, "milestoneGate", errors);
    for (const objectiveId of gate.requiredObjectiveIds ?? []) {
      if (!objectiveIdSet.has(objectiveId)) {
        errors.push(
          `milestoneGate "${gate.id}" references unknown objective "${objectiveId}"`,
        );
      }
    }
  }

  for (const section of catalog.sections ?? []) {
    if (!section?.id) {
      errors.push("section missing id");
      continue;
    }
    pushUnique(ids, section.id, "section", errors);
    if (!Array.isArray(section.units) || section.units.length < 1) {
      errors.push(`section "${section.id}" must contain units`);
      continue;
    }

    for (const unit of section.units) {
      if (!unit?.id) {
        errors.push(`section "${section.id}" has a unit without id`);
        continue;
      }
      pushUnique(ids, unit.id, "unit", errors);
      unitCount += 1;

      if (!Array.isArray(unit.lessons) || unit.lessons.length !== LESSONS_PER_UNIT) {
        errors.push(
          `unit "${unit.id}" must have exactly ${LESSONS_PER_UNIT} lessons ` +
            `(found ${unit.lessons?.length ?? 0})`,
        );
      }

      const variantUnit = isVariantUnit(unit.id, unit.title ?? "");

      for (const lesson of unit.lessons ?? []) {
        if (!lesson?.id) {
          errors.push(`unit "${unit.id}" has a lesson without id`);
          continue;
        }
        pushUnique(ids, lesson.id, "lesson", errors);
        lessonCount += 1;

        if (!VALID_FORMATS.has(lesson.format)) {
          errors.push(
            `lesson "${lesson.id}" has invalid format "${String(lesson.format)}"`,
          );
        }
        if (!VALID_CLAIMS.has(lesson.simulationClaims)) {
          errors.push(
            `lesson "${lesson.id}" has invalid simulationClaims ` +
              `"${String(lesson.simulationClaims)}"`,
          );
        }
        if (
          variantUnit &&
          lesson.simulationClaims !== "conceptual_only"
        ) {
          errors.push(
            `variant lesson "${lesson.id}" must declare simulationClaims ` +
              `"conceptual_only"`,
          );
        }
      }
    }
  }

  // Nested counts must match the declared structure we just walked.
  const declaredUnits = (catalog.sections ?? []).reduce(
    (n, section) => n + (section.units?.length ?? 0),
    0,
  );
  const declaredLessons = (catalog.sections ?? []).reduce(
    (n, section) =>
      n +
      (section.units ?? []).reduce(
        (m, unit) => m + (unit.lessons?.length ?? 0),
        0,
      ),
    0,
  );
  if (declaredUnits !== unitCount) {
    errors.push(
      `unit count mismatch: walked ${unitCount}, declared ${declaredUnits}`,
    );
  }
  if (declaredLessons !== lessonCount) {
    errors.push(
      `lesson count mismatch: walked ${lessonCount}, declared ${declaredLessons}`,
    );
  }

  if (errors.length > 0) {
    throw new Error(
      `Curriculum catalog invariants failed:\n- ${errors.join("\n- ")}`,
    );
  }
}

let cachedCatalog: CurriculumCatalog | undefined;

/** Return the frozen catalog after validating invariants (cached). */
export function getCurriculumCatalog(): CurriculumCatalog {
  if (cachedCatalog) return cachedCatalog;
  const catalog = rawCatalog as CurriculumCatalog;
  assertCatalogInvariants(catalog);
  cachedCatalog = catalog;
  return catalog;
}

/** Look up a lesson by id within the given (or default) catalog. */
export function getLessonById(
  lessonId: string,
  catalog: CurriculumCatalog = getCurriculumCatalog(),
): CurriculumLesson | undefined {
  const needle = lessonId.trim();
  if (!needle) return undefined;
  for (const section of catalog.sections) {
    for (const unit of section.units) {
      for (const lesson of unit.lessons) {
        if (lesson.id === needle) return lesson;
      }
    }
  }
  return undefined;
}

/** Test helper: clear the cached catalog between cases. */
export function resetCurriculumCatalogCacheForTests(): void {
  cachedCatalog = undefined;
}
