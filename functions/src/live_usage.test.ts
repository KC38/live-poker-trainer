/**
 * Unit tests for live Gemini usage accumulators and metric increments.
 */

import {describe, expect, it} from "vitest";
import {generationUsageFromMetadata} from "./generation_usage";
import {
  addLiveUsage,
  emptyLiveUsageBreakdown,
  liveGenerationMetricsIncrements,
  liveUsageFromPurpose,
  liveUsageFirestoreFields,
} from "./live_usage";

describe("live usage", () => {
  it("tags one response under a purpose bucket", () => {
    const usage = generationUsageFromMetadata({
      promptTokenCount: 1000,
      candidatesTokenCount: 100,
      thoughtsTokenCount: 200,
      totalTokenCount: 1300,
    });
    const tagged = liveUsageFromPurpose(usage, "coach_draft");
    expect(tagged.total.modelRequestCount).toBe(1);
    expect(tagged.byPurpose.coach_draft.promptTokenCount).toBe(1000);
    expect(tagged.byPurpose.villain.modelRequestCount).toBe(0);
    expect(tagged.total.estimatedCostUsdMicros).toBeGreaterThan(0);
  });

  it("adds purpose-aware accumulators", () => {
    const deal = liveUsageFromPurpose(
      generationUsageFromMetadata({
        promptTokenCount: 100,
        candidatesTokenCount: 20,
        thoughtsTokenCount: 10,
      }),
      "deal",
    );
    const villain = liveUsageFromPurpose(
      generationUsageFromMetadata({
        promptTokenCount: 50,
        candidatesTokenCount: 5,
        thoughtsTokenCount: 5,
      }),
      "villain",
    );
    const total = addLiveUsage(deal, villain);
    expect(total.total.modelRequestCount).toBe(2);
    expect(total.byPurpose.deal.modelRequestCount).toBe(1);
    expect(total.byPurpose.villain.modelRequestCount).toBe(1);
    expect(total.total.promptTokenCount).toBe(150);
  });

  it("builds firestore fields and metric increments", () => {
    const usage = addLiveUsage(
      liveUsageFromPurpose(
        generationUsageFromMetadata({
          promptTokenCount: 100,
          candidatesTokenCount: 20,
          thoughtsTokenCount: 10,
        }),
        "deal",
      ),
      emptyLiveUsageBreakdown(),
    );
    const fields = liveUsageFirestoreFields(usage);
    expect(fields.generationUsage.modelRequestCount).toBe(1);
    expect(fields.usageByPurpose.deal.modelRequestCount).toBe(1);

    const increments = liveGenerationMetricsIncrements({
      usage,
      publishedHandCount: 1,
      successfulJobCount: 1,
      completedJobCount: 1,
    });
    expect(increments.dealRequestCount).toBeTruthy();
    expect(increments.publishedHandCount).toBeTruthy();
    expect(increments.expandCount).toBeTruthy();
  });
});
