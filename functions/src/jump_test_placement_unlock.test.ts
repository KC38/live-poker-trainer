/**
 * LPT-1032: passing the Section N jump test credits Sections < N, lands on
 * Section N, and leaves Section N+1 and later locked.
 *
 * Jump tests are the last node of their section and the next section's first
 * lesson lists the jump test as a prerequisite. Before the fix the completion
 * write recorded the jump test itself, which unlocked Section N+1 as well.
 */

import {describe, expect, it} from "vitest";
import {
  courseBank,
  effectiveCompletedLessonIds,
  isPlacementOnlyJumpTest,
  jumpTestPlacementCreditLessonIds,
  lessonRequiresPlacementFlag,
} from "./course_catalog";
import {
  completedLessonIdsAfterCompletion,
  missingStartPrerequisite,
} from "./course_session";
import {hasCompletedLessonId} from "./lesson_split_map";

interface JumpTest {
  order: number;
  jumpId: string;
  sectionIndex: number;
}

const jumpTests: JumpTest[] = [];
courseBank.sections.forEach((section, sectionIndex) => {
  for (const unit of section.units) {
    for (const lesson of unit.lessons) {
      if (lessonRequiresPlacementFlag(lesson)) {
        jumpTests.push({order: sectionIndex + 1, jumpId: lesson.id, sectionIndex});
      }
    }
  }
});

function sectionLessonIds(index: number): string[] {
  return courseBank.sections[index].units.flatMap(
      (unit) => unit.lessons.map((lesson) => lesson.id),
  );
}

function prerequisitesOf(lessonId: string): readonly string[] {
  for (const section of courseBank.sections) {
    for (const unit of section.units) {
      for (const lesson of unit.lessons) {
        if (lesson.id === lessonId) return lesson.prerequisites;
      }
    }
  }
  throw new Error(`unknown lesson ${lessonId}`);
}

/** Same unlock test the server applies to a new start (deep-link lock). */
function isUnlocked(lessonId: string, completed: readonly string[]): boolean {
  if (hasCompletedLessonId(completed, lessonId, courseBank.lessonSplitMap)) {
    return true;
  }
  return missingStartPrerequisite({
    prerequisites: prerequisitesOf(lessonId),
    requiresPlacement: false,
    completedLessonIds: completed,
    lessonSplitMap: courseBank.lessonSplitMap,
  }) === undefined;
}

function expectPlacedAtSection(completed: readonly string[], jump: JumpTest) {
  const {sectionIndex, jumpId} = jump;
  for (let i = 0; i < sectionIndex; i++) {
    for (const id of sectionLessonIds(i)) {
      expect(completed, `section ${i + 1} ${id} complete`).toContain(id);
    }
  }
  const current = sectionLessonIds(sectionIndex);
  for (const id of current) {
    expect(completed, `section ${jump.order} ${id} not complete`)
        .not.toContain(id);
  }
  expect(isUnlocked(current[0], completed),
      `section ${jump.order} first lesson unlocked`).toBe(true);
  expect(completed).not.toContain(jumpId);
  for (let i = sectionIndex + 1; i < courseBank.sections.length; i++) {
    for (const id of sectionLessonIds(i)) {
      expect(isUnlocked(id, completed),
          `section ${i + 1} ${id} locked`).toBe(false);
    }
  }
}

describe("LPT-1032 jump test placement unlocks only its own section", () => {
  it("publishes jump tests for Sections 1-4", () => {
    expect(jumpTests.map((j) => j.order)).toEqual([1, 2, 3, 4]);
  });

  for (const jump of jumpTests) {
    it(`Section ${jump.order} jump pass: <${jump.order} done, ` +
        `${jump.order} current, >${jump.order} locked`, () => {
      const completed = completedLessonIdsAfterCompletion({
        priorCompleted: [],
        lessonId: jump.jumpId,
        jumpTestPassed: true,
      });
      expect(completed).toEqual(jumpTestPlacementCreditLessonIds(jump.jumpId));
      expectPlacedAtSection(completed, jump);
    });

    it(`Section ${jump.order}: pre-fix profile (jump id stored) is repaired`,
        () => {
          const legacy = [
            ...jumpTestPlacementCreditLessonIds(jump.jumpId),
            jump.jumpId,
          ];
          expect(isPlacementOnlyJumpTest(jump.jumpId, legacy)).toBe(true);
          expectPlacedAtSection(effectiveCompletedLessonIds(legacy), jump);
        });

    it(`Section ${jump.order}: jump after finishing the section still ` +
        "opens the next one", () => {
      const prior = [
        ...jumpTestPlacementCreditLessonIds(jump.jumpId),
        ...sectionLessonIds(jump.sectionIndex).filter((id) =>
          id !== jump.jumpId),
      ];
      const completed = completedLessonIdsAfterCompletion({
        priorCompleted: prior,
        lessonId: jump.jumpId,
        jumpTestPassed: true,
      });
      expect(completed).toContain(jump.jumpId);
      const next = courseBank.sections[jump.sectionIndex + 1];
      expect(isUnlocked(next.units[0].lessons[0].id, completed)).toBe(true);
    });
  }

  it("keeps a stored jump test the learner already built on", () => {
    // Pre-fix Section 4 placement, then Section 5 lesson 1 finished: the
    // path must not re-lock under the learner.
    const jump = jumpTests[3];
    const sec5First = sectionLessonIds(jump.sectionIndex + 1)[0];
    const stored = [
      ...jumpTestPlacementCreditLessonIds(jump.jumpId),
      jump.jumpId,
      sec5First,
    ];
    expect(effectiveCompletedLessonIds(stored)).toEqual(stored);
  });

  it("reads non-array Firestore values as empty", () => {
    expect(effectiveCompletedLessonIds(undefined)).toEqual([]);
    expect(effectiveCompletedLessonIds("x")).toEqual([]);
  });
});
