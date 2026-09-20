/**
 * Gemini token usage and estimated-cost accounting.
 *
 * Prices follow published Gemini Developer API standard-tier rates. Values are
 * stored in USD micros so Firestore aggregation remains integer and
 * deterministic across pricing periods. Cost estimates are model-aware so the
 * coach benchmark can compare Flash, Flash-Lite, and Pro configurations.
 */

export const GEMINI_INTRO_PRICING_VERSION =
  "gemini-3.8-flash-standard-through-2026-12-31";
export const GEMINI_2027_PRICING_VERSION =
  "gemini-3.8-flash-standard-from-2027-01-01";
export const GEMINI_PRICING_ROLLOVER_MS = Date.UTC(2027, 0, 1);

/** Default production intelligence / deal model. */
export const DEFAULT_GEMINI_MODEL_ID = "gemini-3.8-flash";

export type GeminiPricingVersion =
  | typeof GEMINI_INTRO_PRICING_VERSION
  | typeof GEMINI_2027_PRICING_VERSION
  | "gemini-3.5-flash-lite-standard"
  | "gemini-3.1-flash-lite-standard"
  | "gemini-3.1-pro-preview-standard-le200k"
  | "mixed"
  | string;

interface GeminiPricing {
  version: Exclude<GeminiPricingVersion, "mixed">;
  inputUsdPerMillion: number;
  cachedInputUsdPerMillion: number;
  outputUsdPerMillion: number;
}

const FLASH_INTRO_PRICING: GeminiPricing = {
  version: GEMINI_INTRO_PRICING_VERSION,
  inputUsdPerMillion: 0.75,
  cachedInputUsdPerMillion: 0.075,
  outputUsdPerMillion: 3.75,
};

const FLASH_2027_PRICING: GeminiPricing = {
  version: GEMINI_2027_PRICING_VERSION,
  inputUsdPerMillion: 1.5,
  cachedInputUsdPerMillion: 0.15,
  outputUsdPerMillion: 7.5,
};

const FLASH_LITE_35_PRICING: GeminiPricing = {
  version: "gemini-3.5-flash-lite-standard",
  inputUsdPerMillion: 0.3,
  cachedInputUsdPerMillion: 0.15,
  outputUsdPerMillion: 2.5,
};

const FLASH_LITE_31_PRICING: GeminiPricing = {
  version: "gemini-3.1-flash-lite-standard",
  inputUsdPerMillion: 0.25,
  cachedInputUsdPerMillion: 0.125,
  outputUsdPerMillion: 1.5,
};

const PRO_31_PRICING: GeminiPricing = {
  version: "gemini-3.1-pro-preview-standard-le200k",
  inputUsdPerMillion: 2.0,
  cachedInputUsdPerMillion: 1.0,
  outputUsdPerMillion: 12.0,
};

const INTRO_FLASH_MODELS = new Set([
  "gemini-3.8-flash",
  "gemini-3.7-flash",
  "gemini-3.6-flash",
]);

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
export function emptyGenerationUsage(
  atMs: number = Date.now(),
  modelId: string = DEFAULT_GEMINI_MODEL_ID,
): GenerationUsage {
  return {
    modelRequestCount: 0,
    promptTokenCount: 0,
    cachedContentTokenCount: 0,
    candidatesTokenCount: 0,
    thoughtsTokenCount: 0,
    totalTokenCount: 0,
    estimatedCostUsdMicros: 0,
    pricingVersion: resolveGeminiPricing(atMs, modelId).version,
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
  modelId: string = DEFAULT_GEMINI_MODEL_ID,
): GenerationUsage {
  const pricing = resolveGeminiPricing(atMs, modelId);
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

/**
 * Resolves the published rate card in effect when a request completes.
 *
 * Unknown model ids fall back to Gemini 3.8 Flash standard rates so metering
 * never silently drops to zero.
 */
export function resolveGeminiPricing(
  atMs: number,
  modelId: string = DEFAULT_GEMINI_MODEL_ID,
): GeminiPricing {
  const normalized = modelId.trim().toLowerCase();
  if (normalized === "gemini-3.5-flash-lite") return FLASH_LITE_35_PRICING;
  if (normalized === "gemini-3.1-flash-lite") return FLASH_LITE_31_PRICING;
  if (
    normalized === "gemini-3.1-pro-preview" ||
    normalized === "gemini-3.1-pro-preview-customtools"
  ) {
    return PRO_31_PRICING;
  }
  if (INTRO_FLASH_MODELS.has(normalized) || normalized.length === 0) {
    return atMs >= GEMINI_PRICING_ROLLOVER_MS ?
      FLASH_2027_PRICING :
      FLASH_INTRO_PRICING;
  }
  // Unknown Gemini ids still get Flash rates for a conservative estimate.
  return atMs >= GEMINI_PRICING_ROLLOVER_MS ?
    FLASH_2027_PRICING :
    FLASH_INTRO_PRICING;
}

/** Lists model ids with first-class coach-benchmark pricing cards. */
export function pricedGeminiModelIds(): readonly string[] {
  return [
    "gemini-3.8-flash",
    "gemini-3.7-flash",
    "gemini-3.6-flash",
    "gemini-3.5-flash-lite",
    "gemini-3.1-flash-lite",
    "gemini-3.1-pro-preview",
  ];
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
