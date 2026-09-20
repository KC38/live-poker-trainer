/**
 * Unit tests for Anthropic coach-benchmark helpers and pricing.
 */

import {describe, expect, it} from "vitest";
import {
  anthropicThinkingBudget,
  isAnthropicCoachModel,
} from "./coach_anthropic";
import {
  generationUsageFromAnthropicUsage,
  resolveGeminiPricing,
} from "./generation_usage";

describe("anthropic coach helpers", () => {
  it("routes Claude model ids to Anthropic", () => {
    expect(isAnthropicCoachModel("claude-haiku-4-5-20251001")).toBe(true);
    expect(isAnthropicCoachModel("gemini-3.7-flash")).toBe(false);
  });

  it("maps low thinking to no extended budget", () => {
    expect(anthropicThinkingBudget("low")).toBeNull();
    expect(anthropicThinkingBudget("medium")).toBe(2048);
    expect(anthropicThinkingBudget("high")).toBe(8192);
  });

  it("prices Haiku usage with the published rate card", () => {
    const usage = generationUsageFromAnthropicUsage({
      input_tokens: 1000,
      output_tokens: 200,
      cache_read_input_tokens: 0,
    }, Date.UTC(2026, 8, 20), "claude-haiku-4-5");
    expect(resolveGeminiPricing(Date.now(), "claude-haiku-4-5").version)
      .toBe("claude-haiku-4-5-standard");
    expect(usage.estimatedCostUsdMicros).toBe(Math.round(1000 * 1.0 + 200 * 5.0));
  });
});
