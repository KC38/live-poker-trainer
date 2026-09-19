/**
 * Regression tests for live-pot all-in runout shortcuts.
 */

import {describe, expect, it} from "vitest";
import {validateSituation} from "./validate_situation";
import {minimalFoldSituation} from "./test_fixtures";

describe("all_in_runout live-pot rule", () => {
  it("rejects all_in_runout while two players still have chips", () => {
    const payload = minimalFoldSituation();
    const open = payload.nodes.open;
    if (open.type !== "hero") throw new Error("expected hero open");
    const call = open.actions.find((action) => action.kind === "CALL");
    if (!call) throw new Error("expected CALL");
    // Skip the villain fold so both stacks remain live into the terminal.
    call.nextNodeId = "term_call_open";
    delete payload.nodes.villain_folds_limp;

    const terminal = payload.nodes.term_call_open;
    if (terminal.type !== "terminal") throw new Error("expected terminal");
    terminal.reason = "all_in_runout";
    terminal.street = "river";
    terminal.board = ["2c", "7d", "Jh", "9s", "3h"];
    terminal.foldedSeats = [];
    const result = validateSituation(payload);
    expect(result.ok).toBe(false);
    expect(
      result.issues.some(
        (issue) =>
          issue.code === "transition" &&
          issue.message.includes(
            "fewer than two players with chips behind",
          ),
      ),
    ).toBe(true);
  });
});
