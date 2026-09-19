/**
 * Argument guard tests for the obsolete-data reset script.
 */

import {describe, expect, it} from "vitest";
import {parseResetArguments} from "./reset_obsolete_data";

describe("parseResetArguments", () => {
  it("requires an explicit project even for dry-run", () => {
    expect(() => parseResetArguments([])).toThrow(
      "Missing required --project=<id>.",
    );
  });

  it("defaults to dry-run for an explicit project", () => {
    expect(parseResetArguments(["--project=staging-project"])).toEqual({
      projectId: "staging-project",
      execute: false,
      allowProductionReset: false,
    });
  });

  it("requires an exact execute confirmation", () => {
    expect(() =>
      parseResetArguments([
        "--project=staging-project",
        "--execute",
      ]),
    ).toThrow("--confirm-project=<id>");

    expect(() =>
      parseResetArguments([
        "--project=staging-project",
        "--execute",
        "--confirm-project=other-project",
      ]),
    ).toThrow("--confirm-project=<id>");
  });

  it("allows a confirmed non-production execute", () => {
    expect(
      parseResetArguments([
        "--project=staging-project",
        "--execute",
        "--confirm-project=staging-project",
      ]),
    ).toMatchObject({
      projectId: "staging-project",
      execute: true,
    });
  });

  it("requires the additional production reset flag", () => {
    expect(() =>
      parseResetArguments([
        "--project=live-poker-trainer",
        "--execute",
        "--confirm-project=live-poker-trainer",
      ]),
    ).toThrow("--allow-production-reset");

    expect(
      parseResetArguments([
        "--project=live-poker-trainer",
        "--execute",
        "--confirm-project=live-poker-trainer",
        "--allow-production-reset",
      ]),
    ).toMatchObject({
      projectId: "live-poker-trainer",
      execute: true,
      allowProductionReset: true,
    });
  });

  it("rejects empty values and unknown arguments", () => {
    expect(() => parseResetArguments(["--project="])).toThrow(
      "must not be empty",
    );
    expect(() =>
      parseResetArguments(["--project=test", "--force"]),
    ).toThrow("Unknown argument");
  });
});
