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
  generationUsageFromAnthropicUsage,
  generationUsageFromMetadata,
  generationUsageFromOpenAiCompatibleUsage,
  resolveGeminiPricing,
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

  it("prices lite and pro models with their published rate cards", () => {
    const tokens = {
      promptTokenCount: 1000,
      cachedContentTokenCount: 0,
      candidatesTokenCount: 100,
      thoughtsTokenCount: 100,
    };
    expect(
      generationUsageFromMetadata(tokens, introTimestamp, "gemini-3.5-flash-lite")
        .estimatedCostUsdMicros,
    ).toBe(Math.round(1000 * 0.3 + 200 * 2.5));
    expect(
      generationUsageFromMetadata(
        tokens,
        introTimestamp,
        "gemini-3.1-pro-preview",
      ).estimatedCostUsdMicros,
    ).toBe(Math.round(1000 * 2.0 + 200 * 12.0));
    expect(resolveGeminiPricing(introTimestamp, "gemini-3.7-flash").version)
      .toBe(GEMINI_INTRO_PRICING_VERSION);
  });

  it("clamps cached tokens and drops corrupt counts", () => {
    const usage = generationUsageFromMetadata({
      promptTokenCount: 100,
      cachedContentTokenCount: 500,
      candidatesTokenCount: -4,
      thoughtsTokenCount: 1.5,
      totalTokenCount: Number.MAX_SAFE_INTEGER + 1,
    }, introTimestamp);

    expect(usage).toMatchObject({
      promptTokenCount: 100,
      cachedContentTokenCount: 100,
      candidatesTokenCount: 0,
      thoughtsTokenCount: 0,
      totalTokenCount: 100,
      estimatedCostUsdMicros: Math.round(100 * 0.075),
      pricingVersion: GEMINI_INTRO_PRICING_VERSION,
    });
  });

  it("keeps the calculated total when the provider under-reports it", () => {
    const usage = generationUsageFromMetadata({
      promptTokenCount: 1000,
      candidatesTokenCount: 200,
      thoughtsTokenCount: 50,
      totalTokenCount: 10,
    }, introTimestamp);

    expect(usage.totalTokenCount).toBe(1250);
  });

  it("prices dated model aliases and never zeroes an unknown model", () => {
    const tokens = {
      promptTokenCount: 1000,
      candidatesTokenCount: 100,
      thoughtsTokenCount: 0,
    };
    expect(
      resolveGeminiPricing(introTimestamp, "claude-haiku-4-5-20251001").version,
    ).toBe("claude-haiku-4-5-standard");
    expect(resolveGeminiPricing(introTimestamp, "  GPT-5-MINI-2026-01  ").version)
      .toBe("gpt-5-mini-standard");
    expect(resolveGeminiPricing(introTimestamp, "deepseek-v4-flash").version)
      .toBe("deepseek-flash-peak-standard");
    expect(
      resolveGeminiPricing(
        introTimestamp,
        "gemini-3.1-pro-preview-customtools",
      ).version,
    ).toBe("gemini-3.1-pro-preview-standard-le200k");
    expect(resolveGeminiPricing(introTimestamp, "gemini-3.1-flash-lite").version)
      .toBe("gemini-3.1-flash-lite-standard");

    const flash = generationUsageFromMetadata(
      tokens,
      introTimestamp,
      "gemini-3.8-flash",
    );
    const unknown = generationUsageFromMetadata(
      tokens,
      introTimestamp,
      "mystery-model",
    );
    const blank = generationUsageFromMetadata(tokens, introTimestamp, "   ");
    expect(unknown.pricingVersion).toBe(GEMINI_INTRO_PRICING_VERSION);
    expect(unknown.estimatedCostUsdMicros).toBe(flash.estimatedCostUsdMicros);
    expect(unknown.estimatedCostUsdMicros).toBeGreaterThan(0);
    expect(blank.estimatedCostUsdMicros).toBe(flash.estimatedCostUsdMicros);

    const afterRollover = generationUsageFromMetadata(
      tokens,
      GEMINI_PRICING_ROLLOVER_MS,
      "not-a-real-model",
    );
    expect(afterRollover.pricingVersion).toBe(GEMINI_2027_PRICING_VERSION);
    expect(afterRollover.estimatedCostUsdMicros).toBe(
      flash.estimatedCostUsdMicros * 2,
    );
  });

  it("keeps the priced card when the other accumulator has no requests", () => {
    const priced = generationUsageFromMetadata({
      promptTokenCount: 10,
      candidatesTokenCount: 1,
    }, introTimestamp, "gemini-3.1-flash-lite");
    const empty = emptyGenerationUsage(introTimestamp);

    expect(addGenerationUsage(priced, empty).pricingVersion)
      .toBe("gemini-3.1-flash-lite-standard");
    expect(addGenerationUsage(empty, priced).pricingVersion)
      .toBe("gemini-3.1-flash-lite-standard");
  });

  it("clamps Anthropic cache reads onto the billed prompt", () => {
    const usage = generationUsageFromAnthropicUsage({
      input_tokens: 100,
      cache_read_input_tokens: 400,
      output_tokens: 10,
    }, introTimestamp, "claude-haiku-4-5-20251001");

    expect(usage).toMatchObject({
      modelRequestCount: 1,
      promptTokenCount: 100,
      cachedContentTokenCount: 100,
      candidatesTokenCount: 10,
      thoughtsTokenCount: 0,
      totalTokenCount: 110,
      estimatedCostUsdMicros: Math.round(100 * 0.1 + 10 * 5),
      pricingVersion: "claude-haiku-4-5-standard",
    });
    expect(generationUsageFromAnthropicUsage(undefined, introTimestamp))
      .toMatchObject({
        modelRequestCount: 1,
        totalTokenCount: 0,
        estimatedCostUsdMicros: 0,
      });
  });

  it("splits reasoning out of output without billing it twice", () => {
    const within = generationUsageFromOpenAiCompatibleUsage({
      input_tokens: 1000,
      output_tokens: 300,
      input_tokens_details: {cached_tokens: 250},
      output_tokens_details: {reasoning_tokens: 300},
    }, introTimestamp, "gpt-5-mini");

    expect(within).toMatchObject({
      promptTokenCount: 1000,
      cachedContentTokenCount: 250,
      candidatesTokenCount: 0,
      thoughtsTokenCount: 300,
      totalTokenCount: 1300,
      estimatedCostUsdMicros: Math.round(750 * 0.25 + 250 * 0.025 + 300 * 2),
      pricingVersion: "gpt-5-mini-standard",
    });

    const overflow = generationUsageFromOpenAiCompatibleUsage({
      input_tokens: 80,
      output_tokens: 20,
      input_tokens_details: {cached_tokens: 200},
      output_tokens_details: {reasoning_tokens: 50},
    }, introTimestamp, "deepseek-v4-flash");
    expect(overflow.cachedContentTokenCount).toBe(80);
    expect(overflow.candidatesTokenCount).toBe(0);
    expect(overflow.totalTokenCount).toBe(100);
    expect(overflow.pricingVersion).toBe("deepseek-flash-peak-standard");
  });
});
