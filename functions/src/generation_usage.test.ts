/**
 * Unit tests for Gemini token usage and cost accounting.
 */

import {describe, expect, it} from "vitest";
import {
  addGenerationUsage,
  emptyGenerationUsage,
  generationUsageFromMetadata,
} from "./generation_usage";

describe("generation usage", () => {
  it("prices uncached input, cached input, visible output, and thinking", () => {
    const usage = generationUsageFromMetadata({
      promptTokenCount: 1000,
      cachedContentTokenCount: 200,
      candidatesTokenCount: 300,
      thoughtsTokenCount: 400,
      totalTokenCount: 1700,
    });

    expect(usage).toMatchObject({
      modelRequestCount: 1,
      promptTokenCount: 1000,
      cachedContentTokenCount: 200,
      candidatesTokenCount: 300,
      thoughtsTokenCount: 400,
      totalTokenCount: 1700,
      // 800 * .75 + 200 * .075 + 700 * 3.75 micro-USD.
      estimatedCostUsdMicros: 3240,
    });
  });

  it("adds request usage using integer counters", () => {
    const first = generationUsageFromMetadata({
      promptTokenCount: 10,
      candidatesTokenCount: 20,
      thoughtsTokenCount: 30,
      totalTokenCount: 60,
    });
    const total = addGenerationUsage(emptyGenerationUsage(), first);

    expect(total.modelRequestCount).toBe(1);
    expect(total.totalTokenCount).toBe(60);
    expect(total.estimatedCostUsdMicros).toBe(
      first.estimatedCostUsdMicros,
    );
  });

  it("tracks a completed request even when usage metadata is absent", () => {
    expect(generationUsageFromMetadata(undefined)).toMatchObject({
      modelRequestCount: 1,
      totalTokenCount: 0,
      estimatedCostUsdMicros: 0,
    });
  });
});
