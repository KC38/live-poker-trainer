/**
 * Unit tests for Gemini token usage and cost accounting.
 */

import {describe, expect, it} from "vitest";
import {
  GEMINI_2027_PRICING_VERSION,
  GEMINI_INTRO_PRICING_VERSION,
  GEMINI_PRICING_ROLLOVER_MS,
  addGenerationUsage,
  emptyGenerationUsage,
  generationUsageFromMetadata,
} from "./generation_usage";

describe("generation usage", () => {
  const introTimestamp = Date.UTC(2026, 8, 19);

  it("prices uncached input, cached input, visible output, and thinking", () => {
    const usage = generationUsageFromMetadata({
      promptTokenCount: 1000,
      cachedContentTokenCount: 200,
      candidatesTokenCount: 300,
      thoughtsTokenCount: 400,
      totalTokenCount: 1700,
    }, introTimestamp);

    expect(usage).toMatchObject({
      modelRequestCount: 1,
      promptTokenCount: 1000,
      cachedContentTokenCount: 200,
      candidatesTokenCount: 300,
      thoughtsTokenCount: 400,
      totalTokenCount: 1700,
      // 800 * .75 + 200 * .075 + 700 * 3.75 micro-USD.
      estimatedCostUsdMicros: 3240,
      pricingVersion: GEMINI_INTRO_PRICING_VERSION,
    });
  });

  it("uses the doubled standard rates starting January 1, 2027", () => {
    const tokens = {
      promptTokenCount: 1000,
      cachedContentTokenCount: 200,
      candidatesTokenCount: 300,
      thoughtsTokenCount: 400,
      totalTokenCount: 1700,
    };
    const before = generationUsageFromMetadata(
      tokens,
      GEMINI_PRICING_ROLLOVER_MS - 1,
    );
    const after = generationUsageFromMetadata(
      tokens,
      GEMINI_PRICING_ROLLOVER_MS,
    );

    expect(after.pricingVersion).toBe(GEMINI_2027_PRICING_VERSION);
    expect(after.estimatedCostUsdMicros).toBe(
      before.estimatedCostUsdMicros * 2,
    );
    expect(addGenerationUsage(before, after).pricingVersion).toBe("mixed");
  });

  it("adds request usage using integer counters", () => {
    const first = generationUsageFromMetadata({
      promptTokenCount: 10,
      candidatesTokenCount: 20,
      thoughtsTokenCount: 30,
      totalTokenCount: 60,
    }, introTimestamp);
    const total = addGenerationUsage(
      emptyGenerationUsage(introTimestamp),
      first,
    );

    expect(total.modelRequestCount).toBe(1);
    expect(total.totalTokenCount).toBe(60);
    expect(total.estimatedCostUsdMicros).toBe(
      first.estimatedCostUsdMicros,
    );
  });

  it("tracks a completed request even when usage metadata is absent", () => {
    expect(generationUsageFromMetadata(
      undefined,
      introTimestamp,
    )).toMatchObject({
      modelRequestCount: 1,
      totalTokenCount: 0,
      estimatedCostUsdMicros: 0,
    });
  });
});
