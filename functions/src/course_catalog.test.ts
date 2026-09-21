import {readFileSync} from "node:fs";
import {resolve} from "node:path";
import {describe, expect, it} from "vitest";

import {
  activityIdsInOrder,
  courseBank,
  findActivity,
  findLesson,
  lessonGrantsLiveTrainingEntitlement,
  lessonIdsInOrder,
  lessonRequiresPlacementFlag,
} from "./course_catalog";

describe("course catalog bank", () => {
  it("exposes matching version checksum and ordered ids", () => {
    expect(courseBank.scope).toBe("live_cash_nlh");
    expect(courseBank.coachId).toBe("rex");
    expect(courseBank.sections).toHaveLength(7);
    expect(courseBank.contentChecksum.length).toBe(64);
    expect(lessonIdsInOrder()[0]).toBe(
      "lesson-01-01-01-your-two-cards",
    );
    expect(lessonIdsInOrder().at(-1)).toBe("lesson-07-12-01-five-type-final");
    expect(activityIdsInOrder()).toContain("act-01-06-01-unguided-lab");
    expect(courseBank.handLabsById["lab-01-06-01-bb-defend"]).toBeTruthy();
    expect(courseBank.handLabsById["lab-02-07-01-full-ring-btn"]).toBeTruthy();
    expect(courseBank.catalogVersion).toBe("2.0.0");
    expect(courseBank.sections[0].units).toHaveLength(6);
    expect(courseBank.sections[1].units).toHaveLength(7);
    expect(courseBank.sections[2].units).toHaveLength(8);
    expect(courseBank.sections[3].units).toHaveLength(10);
    expect(courseBank.sections[4].units).toHaveLength(9);
    expect(courseBank.sections[5].units).toHaveLength(13);
    expect(courseBank.sections[6].units).toHaveLength(12);
    expect(courseBank.handLabsById["lab-04-10-01-btn-vs-nit"]).toBeTruthy();
    expect(
      courseBank.playerTypes.find((p) => p.id === "tag")?.introducedByLessonId,
    ).toBe("lesson-06-11-02-meet-tag");
    expect(
      courseBank.playerTypes.find((p) => p.id === "lag")?.introducedByLessonId,
    ).toBe("lesson-06-12-02-meet-lag");
  });

  it("matches the generated client catalog checksum and id order", () => {
    const clientPath = resolve(
      __dirname,
      "../../assets/course/v2/catalog.json",
    );
    const client = JSON.parse(readFileSync(clientPath, "utf8")) as {
      catalogVersion: string;
      contentChecksum: string;
      sections: Array<{
        units: Array<{
          lessons: Array<{
            id: string;
            activities: Array<{id: string}>;
          }>;
        }>;
      }>;
    };
    expect(client.catalogVersion).toBe(courseBank.catalogVersion);
    expect(client.contentChecksum).toBe(courseBank.contentChecksum);

    const clientLessonIds: string[] = [];
    const clientActivityIds: string[] = [];
    for (const section of client.sections) {
      for (const unit of section.units) {
        for (const lesson of unit.lessons) {
          clientLessonIds.push(lesson.id);
          for (const activity of lesson.activities) {
            clientActivityIds.push(activity.id);
          }
        }
      }
    }
    expect(clientLessonIds).toEqual(lessonIdsInOrder());
    expect(clientActivityIds).toEqual(activityIdsInOrder());
  });

  it("keeps private grading out of the client catalog", () => {
    const raw = readFileSync(
      resolve(__dirname, "../../assets/course/v2/catalog.json"),
      "utf8",
    );
    for (const token of [
      '"grading"',
      '"correctSequence"',
      '"sequenceGrading"',
      '"handLabSpec"',
      '"betterChoiceId"',
      '"reversalRead"',
      '"missGrading"',
      '"acceptedMin"',
      '"acceptedMax"',
    ]) {
      expect(raw.includes(token)).toBe(false);
    }
    // Public metadata required by the contract.
    expect(raw.includes('"lifeLossEligible"')).toBe(true);
    expect(raw.includes('"acceptedGrades"')).toBe(true);
  });

  it("exposes lesson lookup helpers for course session consumers", () => {
    const located = findLesson("lesson-01-01-01-your-two-cards");
    expect(located?.section.id).toBe("sec-01-never-played");
    expect(findActivity(located!.lesson, "act-01-01-01-explain-hole-cards")?.stage)
      .toBe("explain");
    expect(lessonRequiresPlacementFlag(located!.lesson)).toBe(false);
    const jump = findLesson("lesson-01-06-02-section-one-jump");
    expect(lessonRequiresPlacementFlag(jump!.lesson)).toBe(true);
    expect(lessonGrantsLiveTrainingEntitlement(located!)).toBe(false);
    const sec4Jump = findLesson("lesson-04-10-02-section-four-jump-test");
    expect(sec4Jump?.section.id).toBe("sec-04-regular-live");
    expect(lessonRequiresPlacementFlag(sec4Jump!.lesson)).toBe(true);
    expect(lessonGrantsLiveTrainingEntitlement(sec4Jump!)).toBe(true);
    const sec3Jump = findLesson("lesson-03-08-02-section-three-jump-test");
    expect(lessonGrantsLiveTrainingEntitlement(sec3Jump!)).toBe(false);
  });
});
