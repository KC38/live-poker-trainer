/**
 * Unit tests for OpenAI-compatible coach-benchmark helpers.
 */

import {describe, expect, it} from "vitest";
import {
  openAiCompatibleProviderForModel,
  openAiCompatibleSchema,
  openAiReasoningEffort,
} from "./coach_openai_compatible";
import {
  generationUsageFromOpenAiCompatibleUsage,
  resolveGeminiPricing,
} from "./generation_usage";

describe("openai-compatible coach helpers", () => {
  it("routes gpt and deepseek model ids", () => {
    expect(openAiCompatibleProviderForModel("gpt-5-mini")).toBe("openai");
    expect(openAiCompatibleProviderForModel("deepseek-flash")).toBe("deepseek");
    expect(openAiCompatibleProviderForModel("gemini-3.7-flash")).toBeNull();
  });

  it("maps low thinking to minimal reasoning effort", () => {
    expect(openAiReasoningEffort("low")).toBe("minimal");
    expect(openAiReasoningEffort("medium")).toBe("medium");
    expect(openAiReasoningEffort("high")).toBe("high");
  });

  it("makes optional object fields nullable and required for strict mode", () => {
    const sanitized = openAiCompatibleSchema({
      type: "object",
      additionalProperties: false,
      properties: {
        summary: {type: "string"},
        betterActionId: {type: "string"},
      },
      required: ["summary"],
    });
    expect(sanitized.required).toEqual(
      expect.arrayContaining(["summary", "betterActionId"]),
    );
    expect(
      (sanitized.properties as Record<string, unknown>).betterActionId,
    ).toMatchObject({
      anyOf: expect.any(Array),
    });
  });

  it("prices gpt-5-mini and deepseek-flash usage", () => {
    expect(resolveGeminiPricing(Date.now(), "gpt-5-mini").version)
      .toBe("gpt-5-mini-standard");
    expect(resolveGeminiPricing(Date.now(), "deepseek-flash").version)
      .toBe("deepseek-flash-peak-standard");
    const usage = generationUsageFromOpenAiCompatibleUsage({
      input_tokens: 1000,
      output_tokens: 300,
      output_tokens_details: {reasoning_tokens: 100},
    }, Date.UTC(2026, 8, 20), "gpt-5-mini");
    expect(usage.estimatedCostUsdMicros).toBe(
      Math.round(1000 * 0.25 + 200 * 2.0 + 100 * 2.0),
    );
  });
});
