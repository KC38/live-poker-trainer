/**
 * Tests for curriculum catalog invariants and lookups.
 */

import {describe, expect, it, beforeEach} from "vitest";
import {
  assertCatalogInvariants,
  getCurriculumCatalog,
  getLessonById,
  resetCurriculumCatalogCacheForTests,
} from "./curriculum_catalog";
import type {CurriculumCatalog} from "./curriculum_types";

function cloneCatalog(): CurriculumCatalog {
  return structuredClone(getCurriculumCatalog());
}

describe("curriculum_catalog", () => {
  beforeEach(() => {
    resetCurriculumCatalogCacheForTests();
  });

  it("loads a validated frozen catalog", () => {
    const catalog = getCurriculumCatalog();
    expect(catalog.catalogVersion).toMatch(/^\d+\.\d+\.\d+$/);
    expect(catalog.sections.length).toBeGreaterThanOrEqual(1);
    expect(
      catalog.sections.every((section) =>
        section.units.every((unit) => unit.lessons.length === 3),
      ),
    ).toBe(true);
  });

  it("looks up lessons by id", () => {
    const catalog = getCurriculumCatalog();
    const first = catalog.sections[0].units[0].lessons[0];
    expect(getLessonById(first.id)?.title).toBe(first.title);
    expect(getLessonById("missing-lesson-id")).toBeUndefined();
  });

  it("requires unique ids", () => {
    const catalog = cloneCatalog();
    const mutable = catalog as {
      sections: Array<{
        units: Array<{lessons: Array<{id: string}>}>;
      }>;
    };
    const firstLesson = mutable.sections[0].units[0].lessons[0];
    const secondLesson = mutable.sections[0].units[0].lessons[1];
    secondLesson.id = firstLesson.id;
    expect(() => assertCatalogInvariants(catalog)).toThrow(/Duplicate lesson/);
  });

  it("requires exactly three lessons per unit", () => {
    const catalog = cloneCatalog();
    const unit = catalog.sections[0].units[0] as {
      lessons: unknown[];
    };
    unit.lessons = unit.lessons.slice(0, 2);
    expect(() => assertCatalogInvariants(catalog)).toThrow(/exactly 3 lessons/);
  });

  it("requires conceptual_only claims on variant lessons", () => {
    const catalog = cloneCatalog();
    const variantUnit = catalog.sections
      .flatMap((section) => section.units)
      .find((unit) => /variant/i.test(unit.id));
    expect(variantUnit).toBeDefined();
    const lesson = variantUnit!.lessons[0] as {simulationClaims: string};
    lesson.simulationClaims = "engine_supported";
    expect(() => assertCatalogInvariants(catalog)).toThrow(/conceptual_only/);
  });
});
