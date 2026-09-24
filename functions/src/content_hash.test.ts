/**
 * Unit tests for canonical situation hashes used as pool identity.
 */

import {describe, expect, it} from "vitest";
import {
  hashContent,
  hashSituationStructure,
  sortedJsonValue,
} from "./content_hash";
import {minimalFoldSituation} from "./test_fixtures";

describe("content hash", () => {
  it("ignores object key order and preserves array order", () => {
    expect(sortedJsonValue({b: 1, a: {d: 2, c: 3}})).toEqual({
      a: {c: 3, d: 2},
      b: 1,
    });
    expect(hashContent({b: 1, a: {d: 2, c: [3, 1]}})).toBe(
      hashContent({a: {c: [3, 1], d: 2}, b: 1}),
    );
    expect(hashContent([2, 1])).not.toBe(hashContent([1, 2]));
  });

  it("keeps the same structural hash when only copy or node order changes", () => {
    const base = minimalFoldSituation();
    const renamed = minimalFoldSituation({
      title: "completely different title",
      schemaVersion: "other-schema",
    });
    const recoached = minimalFoldSituation();
    const open = recoached.nodes.open;
    if (open.type !== "hero") throw new Error("expected hero open node");
    open.actions[0].coaching = "Different coaching text entirely.";

    const reordered = minimalFoldSituation();
    const nodes: typeof reordered.nodes = {};
    for (const key of Object.keys(reordered.nodes).reverse()) {
      nodes[key] = reordered.nodes[key];
    }
    reordered.nodes = nodes;

    expect(hashSituationStructure(renamed)).toBe(hashSituationStructure(base));
    expect(hashSituationStructure(recoached)).toBe(
      hashSituationStructure(base),
    );
    expect(hashSituationStructure(reordered)).toBe(
      hashSituationStructure(base),
    );

    const changedPot = minimalFoldSituation();
    const changedOpen = changedPot.nodes.open;
    if (changedOpen.type !== "hero") throw new Error("expected hero open node");
    changedOpen.pot += 1;
    expect(hashSituationStructure(changedPot)).not.toBe(
      hashSituationStructure(base),
    );
  });
});
