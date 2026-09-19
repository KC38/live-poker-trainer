/**
 * Gemini token usage and estimated-cost accounting.
 *
 * Prices are the published Gemini 3.8 Flash standard-tier rates. Values are
 * stored in USD micros so Firestore aggregation remains integer and
 * deterministic across pricing periods.
 */

export const GEMINI_INTRO_PRICING_VERSION =
  "gemini-3.8-flash-standard-through-2026-12-31";
export const GEMINI_2027_PRICING_VERSION =
  "gemini-3.8-flash-standard-from-2027-01-01";
export const GEMINI_PRICING_ROLLOVER_MS = Date.UTC(2027, 0, 1);

export type GeminiPricingVersion =
  | typeof GEMINI_INTRO_PRICING_VERSION
  | typeof GEMINI_2027_PRICING_VERSION
  | "mixed";

interface GeminiPricing {
  version: Exclude<GeminiPricingVersion, "mixed">;
  inputUsdPerMillion: number;
  cachedInputUsdPerMillion: number;
  outputUsdPerMillion: number;
}

const GEMINI_INTRO_PRICING: GeminiPricing = {
  version: GEMINI_INTRO_PRICING_VERSION,
  inputUsdPerMillion: 0.75,
  cachedInputUsdPerMillion: 0.075,
  outputUsdPerMillion: 3.75,
};

const GEMINI_2027_PRICING: GeminiPricing = {
  version: GEMINI_2027_PRICING_VERSION,
  inputUsdPerMillion: 1.5,
  cachedInputUsdPerMillion: 0.15,
  outputUsdPerMillion: 7.5,
};

/** Token counts returned by one or more Gemini requests. */
export interface GenerationUsage {
  modelRequestCount: number;
  promptTokenCount: number;
  cachedContentTokenCount: number;
  candidatesTokenCount: number;
  thoughtsTokenCount: number;
  totalTokenCount: number;
  estimatedCostUsdMicros: number;
  pricingVersion: GeminiPricingVersion;
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
export function emptyGenerationUsage(atMs: number = Date.now()): GenerationUsage {
  return {
    modelRequestCount: 0,
    promptTokenCount: 0,
    cachedContentTokenCount: 0,
    candidatesTokenCount: 0,
    thoughtsTokenCount: 0,
    totalTokenCount: 0,
    estimatedCostUsdMicros: 0,
    pricingVersion: resolveGeminiPricing(atMs).version,
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
  atMs: number = Date.now(),
): GenerationUsage {
  const pricing = resolveGeminiPricing(atMs);
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
    }, pricing),
    pricingVersion: pricing.version,
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
    pricingVersion: aggregatePricingVersion(left, right),
  };
}

/** Estimates standard-tier cost from token counts, rounded to one USD micro. */
export function estimateCostUsdMicros(options: {
  promptTokenCount: number;
  cachedContentTokenCount: number;
  candidatesTokenCount: number;
  thoughtsTokenCount: number;
}, pricing: GeminiPricing = resolveGeminiPricing(Date.now())): number {
  const cachedInput = Math.min(
    options.promptTokenCount,
    options.cachedContentTokenCount,
  );
  const uncachedInput = Math.max(0, options.promptTokenCount - cachedInput);
  const output = options.candidatesTokenCount + options.thoughtsTokenCount;

  // At a per-million-token USD rate, each token costs the same numeric
  // amount in USD micros.
  return Math.round(
    uncachedInput * pricing.inputUsdPerMillion +
      cachedInput * pricing.cachedInputUsdPerMillion +
      output * pricing.outputUsdPerMillion,
  );
}

/** Resolves the published rate card in effect when a request completes. */
export function resolveGeminiPricing(atMs: number): GeminiPricing {
  return atMs >= GEMINI_PRICING_ROLLOVER_MS ?
    GEMINI_2027_PRICING :
    GEMINI_INTRO_PRICING;
}

function aggregatePricingVersion(
  left: GenerationUsage,
  right: GenerationUsage,
): GeminiPricingVersion {
  if (left.modelRequestCount === 0) return right.pricingVersion;
  if (right.modelRequestCount === 0) return left.pricingVersion;
  return left.pricingVersion === right.pricingVersion ?
    left.pricingVersion :
    "mixed";
}

function tokenCount(value: unknown): number {
  if (typeof value !== "number" || !Number.isSafeInteger(value) || value < 0) {
    return 0;
  }
  return value;
}
