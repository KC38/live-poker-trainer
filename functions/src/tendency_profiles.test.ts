/**
 * Unit tests for exploit tendency bounds used by live opponents and the coach.
 */

import {describe, expect, it} from "vitest";
import type {TendencyProfile} from "./live_types";
import {
  generateTendencyProfile,
  validateTendencyProfile,
} from "./tendency_profiles";

describe("validateTendencyProfile", () => {
  it("rejects values outside the archetype template and empty reads", () => {
    const profile = generateTendencyProfile("TAG", "bounds-seed");
    expect(validateTendencyProfile(profile)).toEqual([]);

    const tooLoose: TendencyProfile = {...profile, vpip: 1};
    expect(validateTendencyProfile(tooLoose)).toEqual([
      expect.stringContaining("vpip=1 outside"),
    ]);

    const blankReads: TendencyProfile = {...profile, reads: ["", "  "]};
    expect(validateTendencyProfile(blankReads)).toEqual([
      "at least two non-empty visible reads are required",
    ]);

    const unknown = {
      ...profile,
      archetype: "FISH",
    } as unknown as TendencyProfile;
    expect(validateTendencyProfile(unknown)).toEqual(["unknown archetype"]);
  });

  it("is stable for the same seed and varies confidence with the seed", () => {
    const first = generateTendencyProfile("NIT", "same-seed");
    const second = generateTendencyProfile("NIT", "same-seed");
    expect(second).toEqual(first);
    const confidences = new Set<string>();
    for (let index = 0; index < 40; index++) {
      confidences.add(
        generateTendencyProfile("LAG", `confidence-${index}`).confidence,
      );
    }
    expect(confidences).toEqual(new Set(["medium", "high"]));
  });
});
