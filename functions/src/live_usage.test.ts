/**
 * Unit tests for live Gemini usage accumulators and metric increments.
 */

import {describe, expect, it} from "vitest";
import {generationUsageFromMetadata} from "./generation_usage";
import {
  addLiveUsage,
  averageLatencyMs,
  emptyLiveUsageBreakdown,
  liveGenerationMetricsIncrements,
  liveUsageFromPurpose,
  liveUsageFirestoreFields,
} from "./live_usage";

describe("live usage", () => {
  it("tags one response under a purpose bucket with latency", () => {
    const usage = generationUsageFromMetadata({
      promptTokenCount: 1000,
      candidatesTokenCount: 100,
      thoughtsTokenCount: 200,
      totalTokenCount: 1300,
    });
    const tagged = liveUsageFromPurpose(usage, "coach_draft", 4200);
    expect(tagged.total.modelRequestCount).toBe(1);
    expect(tagged.byPurpose.coach_draft.promptTokenCount).toBe(1000);
    expect(tagged.byPurpose.villain.modelRequestCount).toBe(0);
    expect(tagged.total.estimatedCostUsdMicros).toBeGreaterThan(0);
    expect(tagged.latency).toEqual({
      callCount: 1,
      totalDurationMs: 4200,
      maxDurationMs: 4200,
    });
    expect(tagged.latencyByPurpose.coach_draft.totalDurationMs).toBe(4200);
    expect(tagged.latencyByPurpose.deal.callCount).toBe(0);
  });

  it("adds purpose-aware usage and latency accumulators", () => {
    const deal = liveUsageFromPurpose(
      generationUsageFromMetadata({
        promptTokenCount: 100,
        candidatesTokenCount: 20,
        thoughtsTokenCount: 10,
      }),
      "deal",
      1500,
    );
    const villain = liveUsageFromPurpose(
      generationUsageFromMetadata({
        promptTokenCount: 50,
        candidatesTokenCount: 5,
        thoughtsTokenCount: 5,
      }),
      "villain",
      800,
    );
    const total = addLiveUsage(deal, villain);
    expect(total.total.modelRequestCount).toBe(2);
    expect(total.byPurpose.deal.modelRequestCount).toBe(1);
    expect(total.byPurpose.villain.modelRequestCount).toBe(1);
    expect(total.total.promptTokenCount).toBe(150);
    expect(total.latency.totalDurationMs).toBe(2300);
    expect(total.latency.maxDurationMs).toBe(1500);
    expect(total.latency.callCount).toBe(2);
    expect(averageLatencyMs(total.latency)).toBe(1150);
  });

  it("builds firestore fields and metric increments including latency", () => {
    const usage = addLiveUsage(
      liveUsageFromPurpose(
        generationUsageFromMetadata({
          promptTokenCount: 100,
          candidatesTokenCount: 20,
          thoughtsTokenCount: 10,
        }),
        "deal",
        1200,
      ),
      emptyLiveUsageBreakdown(),
    );
    const fields = liveUsageFirestoreFields(usage);
    expect(fields.generationUsage.modelRequestCount).toBe(1);
    expect(fields.usageByPurpose.deal.modelRequestCount).toBe(1);
    expect(fields.latency.totalDurationMs).toBe(1200);
    expect(fields.latencyByPurpose.deal.maxDurationMs).toBe(1200);

    const increments = liveGenerationMetricsIncrements({
      usage,
      publishedHandCount: 1,
      successfulJobCount: 1,
      completedJobCount: 1,
      expandDurationMs: 5000,
    });
    expect(increments.dealRequestCount).toBeTruthy();
    expect(increments.publishedHandCount).toBeTruthy();
    expect(increments.expandCount).toBeTruthy();
    expect(increments.totalDurationMs).toBeTruthy();
    expect(increments.dealDurationMs).toBeTruthy();
    expect(increments.expandDurationMs).toBeTruthy();
  });
});
