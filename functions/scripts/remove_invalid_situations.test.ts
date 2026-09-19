/**
 * Guard and validator tests for invalid-situation cleanup.
 */

import {describe, expect, it} from "vitest";
import {minimalFoldSituation} from "../src/test_fixtures";
import {
  parseCleanupArguments,
  situationValidationIssues,
} from "./remove_invalid_situations";

describe("parseCleanupArguments", () => {
  it("requires an explicit project", () => {
    expect(() => parseCleanupArguments([])).toThrow(
      "Missing required --project=<id>.",
    );
  });

  it("defaults to dry-run", () => {
    expect(parseCleanupArguments(["--project=staging-project"])).toEqual({
      projectId: "staging-project",
      execute: false,
      allowProductionCleanup: false,
    });
  });

  it("requires exact confirmation for execution", () => {
    expect(() =>
      parseCleanupArguments([
        "--project=staging-project",
        "--execute",
      ]),
    ).toThrow("--confirm-project=<id>");
  });

  it("requires an additional production cleanup flag", () => {
    expect(() =>
      parseCleanupArguments([
        "--project=live-poker-trainer",
        "--execute",
        "--confirm-project=live-poker-trainer",
      ]),
    ).toThrow("--allow-production-cleanup");

    expect(
      parseCleanupArguments([
        "--project=live-poker-trainer",
        "--execute",
        "--confirm-project=live-poker-trainer",
        "--allow-production-cleanup",
      ]),
    ).toMatchObject({
      projectId: "live-poker-trainer",
      execute: true,
      allowProductionCleanup: true,
    });
  });

  it("rejects empty values and unknown arguments", () => {
    expect(() => parseCleanupArguments(["--project="])).toThrow(
      "must not be empty",
    );
    expect(() =>
      parseCleanupArguments(["--project=test", "--force"]),
    ).toThrow("Unknown argument");
  });
});

describe("situationValidationIssues", () => {
  it("accepts a currently valid situation", () => {
    expect(situationValidationIssues(minimalFoldSituation())).toEqual([]);
  });

  it("identifies a legacy showdown shortcut", () => {
    const payload = minimalFoldSituation();
    const open = payload.nodes.open;
    const terminal = payload.nodes.term_call_open;
    if (open.type !== "hero" || terminal.type !== "terminal") {
      throw new Error("unexpected fixture nodes");
    }
    const call = open.actions.find((action) => action.kind === "CALL");
    if (!call) throw new Error("expected CALL edge");

    call.nextNodeId = terminal.id;
    terminal.reason = "showdown";
    terminal.street = "river";
    terminal.board = ["2c", "7d", "Jh", "9s", "3h"];
    terminal.foldedSeats = [];
    terminal.stacks = [198, 198];
    terminal.pot = 4;
    terminal.winnerSeats = [0];
    terminal.heroNetChips = 2;

    expect(
      situationValidationIssues(payload).some(
        (issue) =>
          issue.code === "transition" &&
          issue.message.includes("reached from the river"),
      ),
    ).toBe(true);
  });

  it("treats malformed payloads as invalid", () => {
    expect(situationValidationIssues(null)).not.toEqual([]);
  });
});
