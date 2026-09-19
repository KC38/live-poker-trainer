/**
 * Gemini token usage and estimated-cost accounting.
 *
 * Prices are the Gemini 3.8 Flash standard-tier introductory rates published
 * for requests made through December 31, 2026. Values are stored in USD
 * micros so Firestore aggregation remains integer and deterministic.
 */

export const GEMINI_PRICING_VERSION =
  "gemini-3.8-flash-standard-through-2026-12-31";
export const GEMINI_INPUT_USD_PER_MILLION = 0.75;
export const GEMINI_CACHED_INPUT_USD_PER_MILLION = 0.075;
export const GEMINI_OUTPUT_USD_PER_MILLION = 3.75;

/** Token counts returned by one or more Gemini requests. */
export interface GenerationUsage {
  modelRequestCount: number;
  promptTokenCount: number;
  cachedContentTokenCount: number;
  candidatesTokenCount: number;
  thoughtsTokenCount: number;
  totalTokenCount: number;
  estimatedCostUsdMicros: number;
  pricingVersion: typeof GEMINI_PRICING_VERSION;
}

/** Raw usageMetadata fields returned by generateContent. */
export interface GeminiUsageMetadata {
  promptTokenCount?: unknown;
  cachedContentTokenCount?: unknown;
  candidatesTokenCount?: unknown;
  thoughtsTokenCount?: unknown;
  totalTokenCount?: unknown;
}

/** Returns a zero-valued usage accumulator. */
export function emptyGenerationUsage(): GenerationUsage {
  return {
    modelRequestCount: 0,
    promptTokenCount: 0,
    cachedContentTokenCount: 0,
    candidatesTokenCount: 0,
    thoughtsTokenCount: 0,
    totalTokenCount: 0,
    estimatedCostUsdMicros: 0,
    pricingVersion: GEMINI_PRICING_VERSION,
  };
}

/**
 * Converts one Gemini usageMetadata object into billable usage.
 *
 * Gemini bills visible candidate and thinking tokens as output. Cached input
 * is split from regular prompt input so a future cached request is not
 * overestimated.
 */
export function generationUsageFromMetadata(
  metadata: GeminiUsageMetadata | undefined,
): GenerationUsage {
  const promptTokenCount = tokenCount(metadata?.promptTokenCount);
  const cachedContentTokenCount = Math.min(
    promptTokenCount,
    tokenCount(metadata?.cachedContentTokenCount),
  );
  const candidatesTokenCount = tokenCount(metadata?.candidatesTokenCount);
  const thoughtsTokenCount = tokenCount(metadata?.thoughtsTokenCount);
  const reportedTotal = tokenCount(metadata?.totalTokenCount);
  const calculatedTotal =
    promptTokenCount + candidatesTokenCount + thoughtsTokenCount;
  const totalTokenCount = Math.max(reportedTotal, calculatedTotal);

  return {
    modelRequestCount: 1,
    promptTokenCount,
    cachedContentTokenCount,
    candidatesTokenCount,
    thoughtsTokenCount,
    totalTokenCount,
    estimatedCostUsdMicros: estimateCostUsdMicros({
      promptTokenCount,
      cachedContentTokenCount,
      candidatesTokenCount,
      thoughtsTokenCount,
    }),
    pricingVersion: GEMINI_PRICING_VERSION,
  };
}

/** Adds usage accumulators without losing integer precision. */
export function addGenerationUsage(
  left: GenerationUsage,
  right: GenerationUsage,
): GenerationUsage {
  return {
    modelRequestCount: left.modelRequestCount + right.modelRequestCount,
    promptTokenCount: left.promptTokenCount + right.promptTokenCount,
    cachedContentTokenCount:
      left.cachedContentTokenCount + right.cachedContentTokenCount,
    candidatesTokenCount:
      left.candidatesTokenCount + right.candidatesTokenCount,
    thoughtsTokenCount: left.thoughtsTokenCount + right.thoughtsTokenCount,
    totalTokenCount: left.totalTokenCount + right.totalTokenCount,
    estimatedCostUsdMicros:
      left.estimatedCostUsdMicros + right.estimatedCostUsdMicros,
    pricingVersion: GEMINI_PRICING_VERSION,
  };
}

/** Estimates standard-tier cost from token counts, rounded to one USD micro. */
export function estimateCostUsdMicros(options: {
  promptTokenCount: number;
  cachedContentTokenCount: number;
  candidatesTokenCount: number;
  thoughtsTokenCount: number;
}): number {
  const cachedInput = Math.min(
    options.promptTokenCount,
    options.cachedContentTokenCount,
  );
  const uncachedInput = Math.max(0, options.promptTokenCount - cachedInput);
  const output = options.candidatesTokenCount + options.thoughtsTokenCount;

  // At a per-million-token USD rate, each token costs the same numeric
  // amount in USD micros.
  return Math.round(
    uncachedInput * GEMINI_INPUT_USD_PER_MILLION +
      cachedInput * GEMINI_CACHED_INPUT_USD_PER_MILLION +
      output * GEMINI_OUTPUT_USD_PER_MILLION,
  );
}

function tokenCount(value: unknown): number {
  if (typeof value !== "number" || !Number.isSafeInteger(value) || value < 0) {
    return 0;
  }
  return value;
}
