/**
 * Live (v3) Gemini usage accumulators and Firestore metric increments.
 *
 * Mirrors v2 generation_usage accounting, with purpose tags so deal, villain,
 * and coaching spend/latency can be broken down independently of invoices.
 */

import {FieldValue} from "firebase-admin/firestore";
import {
  addGenerationUsage,
  emptyGenerationUsage,
  type GenerationUsage,
} from "./generation_usage";

/** Billable live Gemini call categories. */
export type LiveLlmPurpose =
  | "deal"
  | "villain"
  | "coach_draft"
  | "coach_critique";

const LIVE_LLM_PURPOSES: readonly LiveLlmPurpose[] = [
  "deal",
  "villain",
  "coach_draft",
  "coach_critique",
];

/** Wall-clock timing for one or more Gemini HTTP calls. */
export interface LiveLatencyStats {
  callCount: number;
  totalDurationMs: number;
  maxDurationMs: number;
}

/** Token/cost totals plus per-purpose split for one live generation scope. */
export interface LiveUsageBreakdown {
  total: GenerationUsage;
  byPurpose: Record<LiveLlmPurpose, GenerationUsage>;
  latency: LiveLatencyStats;
  latencyByPurpose: Record<LiveLlmPurpose, LiveLatencyStats>;
}

/** Setup-level counters stored on liveTableSetups/{setupKey}.generationMetrics. */
export interface LiveGenerationMetrics extends GenerationUsage {
  completedJobCount: number;
  successfulJobCount: number;
  failedJobCount: number;
  publishedHandCount: number;
  expandCount: number;
  dealRequestCount: number;
  villainRequestCount: number;
  coachDraftRequestCount: number;
  coachCritiqueRequestCount: number;
  totalDurationMs: number;
  maxDurationMs: number;
  dealDurationMs: number;
  villainDurationMs: number;
  coachDraftDurationMs: number;
  coachCritiqueDurationMs: number;
  expandDurationMs: number;
}

/** Returns a zeroed purpose-aware accumulator. */
export function emptyLiveUsageBreakdown(
  atMs: number = Date.now(),
): LiveUsageBreakdown {
  return {
    total: emptyGenerationUsage(atMs),
    byPurpose: {
      deal: emptyGenerationUsage(atMs),
      villain: emptyGenerationUsage(atMs),
      coach_draft: emptyGenerationUsage(atMs),
      coach_critique: emptyGenerationUsage(atMs),
    },
    latency: emptyLatencyStats(),
    latencyByPurpose: {
      deal: emptyLatencyStats(),
      villain: emptyLatencyStats(),
      coach_draft: emptyLatencyStats(),
      coach_critique: emptyLatencyStats(),
    },
  };
}

/** Tags one Gemini response under a purpose bucket with call latency. */
export function liveUsageFromPurpose(
  usage: GenerationUsage,
  purpose: LiveLlmPurpose,
  durationMs: number = 0,
): LiveUsageBreakdown {
  const safeDurationMs = Math.max(0, Math.round(durationMs));
  const breakdown = emptyLiveUsageBreakdown();
  breakdown.total = usage;
  breakdown.byPurpose[purpose] = usage;
  const latency = latencyFromDuration(safeDurationMs, usage.modelRequestCount);
  breakdown.latency = latency;
  breakdown.latencyByPurpose[purpose] = latency;
  return breakdown;
}

/** Adds two live usage accumulators without losing integer precision. */
export function addLiveUsage(
  left: LiveUsageBreakdown,
  right: LiveUsageBreakdown,
): LiveUsageBreakdown {
  return {
    total: addGenerationUsage(left.total, right.total),
    byPurpose: {
      deal: addGenerationUsage(left.byPurpose.deal, right.byPurpose.deal),
      villain: addGenerationUsage(
        left.byPurpose.villain,
        right.byPurpose.villain,
      ),
      coach_draft: addGenerationUsage(
        left.byPurpose.coach_draft,
        right.byPurpose.coach_draft,
      ),
      coach_critique: addGenerationUsage(
        left.byPurpose.coach_critique,
        right.byPurpose.coach_critique,
      ),
    },
    latency: addLatencyStats(left.latency, right.latency),
    latencyByPurpose: {
      deal: addLatencyStats(
        left.latencyByPurpose.deal,
        right.latencyByPurpose.deal,
      ),
      villain: addLatencyStats(
        left.latencyByPurpose.villain,
        right.latencyByPurpose.villain,
      ),
      coach_draft: addLatencyStats(
        left.latencyByPurpose.coach_draft,
        right.latencyByPurpose.coach_draft,
      ),
      coach_critique: addLatencyStats(
        left.latencyByPurpose.coach_critique,
        right.latencyByPurpose.coach_critique,
      ),
    },
  };
}

/** Pulls usage from errors that already paid for a Gemini response. */
export function liveUsageFromError(error: unknown): LiveUsageBreakdown {
  if (error instanceof LiveUsageError) return error.usage;
  return emptyLiveUsageBreakdown();
}

/**
 * Error that preserves billable usage from partial or failed Gemini work.
 */
export class LiveUsageError extends Error {
  constructor(
    message: string,
    readonly usage: LiveUsageBreakdown,
  ) {
    super(message);
    this.name = "LiveUsageError";
  }
}

/**
 * Builds Firestore FieldValue.increment patches for setup-level metrics.
 *
 * Callers merge this under `generationMetrics` on liveTableSetups docs.
 */
export function liveGenerationMetricsIncrements(options: {
  usage: LiveUsageBreakdown;
  completedJobCount?: number;
  successfulJobCount?: number;
  failedJobCount?: number;
  publishedHandCount?: number;
  expandCount?: number;
  expandDurationMs?: number;
}): Record<string, unknown> {
  const usage = options.usage.total;
  const byPurpose = options.usage.byPurpose;
  const latency = options.usage.latency;
  const latencyByPurpose = options.usage.latencyByPurpose;
  return {
    pricingVersion: usage.pricingVersion,
    modelRequestCount: FieldValue.increment(usage.modelRequestCount),
    promptTokenCount: FieldValue.increment(usage.promptTokenCount),
    cachedContentTokenCount: FieldValue.increment(
      usage.cachedContentTokenCount,
    ),
    candidatesTokenCount: FieldValue.increment(usage.candidatesTokenCount),
    thoughtsTokenCount: FieldValue.increment(usage.thoughtsTokenCount),
    totalTokenCount: FieldValue.increment(usage.totalTokenCount),
    estimatedCostUsdMicros: FieldValue.increment(
      usage.estimatedCostUsdMicros,
    ),
    completedJobCount: FieldValue.increment(options.completedJobCount ?? 0),
    successfulJobCount: FieldValue.increment(options.successfulJobCount ?? 0),
    failedJobCount: FieldValue.increment(options.failedJobCount ?? 0),
    publishedHandCount: FieldValue.increment(options.publishedHandCount ?? 0),
    expandCount: FieldValue.increment(options.expandCount ?? 0),
    dealRequestCount: FieldValue.increment(
      byPurpose.deal.modelRequestCount,
    ),
    villainRequestCount: FieldValue.increment(
      byPurpose.villain.modelRequestCount,
    ),
    coachDraftRequestCount: FieldValue.increment(
      byPurpose.coach_draft.modelRequestCount,
    ),
    coachCritiqueRequestCount: FieldValue.increment(
      byPurpose.coach_critique.modelRequestCount,
    ),
    totalDurationMs: FieldValue.increment(latency.totalDurationMs),
    dealDurationMs: FieldValue.increment(
      latencyByPurpose.deal.totalDurationMs,
    ),
    villainDurationMs: FieldValue.increment(
      latencyByPurpose.villain.totalDurationMs,
    ),
    coachDraftDurationMs: FieldValue.increment(
      latencyByPurpose.coach_draft.totalDurationMs,
    ),
    coachCritiqueDurationMs: FieldValue.increment(
      latencyByPurpose.coach_critique.totalDurationMs,
    ),
    expandDurationMs: FieldValue.increment(options.expandDurationMs ?? 0),
  };
}

/** Serializes a breakdown for Firestore document fields. */
export function liveUsageFirestoreFields(
  usage: LiveUsageBreakdown,
): {
  generationUsage: GenerationUsage;
  usageByPurpose: Record<LiveLlmPurpose, GenerationUsage>;
  latency: LiveLatencyStats;
  latencyByPurpose: Record<LiveLlmPurpose, LiveLatencyStats>;
} {
  return {
    generationUsage: usage.total,
    usageByPurpose: usage.byPurpose,
    latency: usage.latency,
    latencyByPurpose: usage.latencyByPurpose,
  };
}

/** Average call duration in milliseconds, or 0 when no calls were timed. */
export function averageLatencyMs(stats: LiveLatencyStats): number {
  if (stats.callCount <= 0) return 0;
  return Math.round(stats.totalDurationMs / stats.callCount);
}

/** Lists every tracked purpose (for tests and reports). */
export function liveLlmPurposes(): readonly LiveLlmPurpose[] {
  return LIVE_LLM_PURPOSES;
}

function emptyLatencyStats(): LiveLatencyStats {
  return {
    callCount: 0,
    totalDurationMs: 0,
    maxDurationMs: 0,
  };
}

function latencyFromDuration(
  durationMs: number,
  callCount: number,
): LiveLatencyStats {
  if (callCount <= 0 && durationMs <= 0) return emptyLatencyStats();
  const count = Math.max(1, callCount);
  return {
    callCount: count,
    totalDurationMs: durationMs,
    maxDurationMs: durationMs,
  };
}

function addLatencyStats(
  left: LiveLatencyStats,
  right: LiveLatencyStats,
): LiveLatencyStats {
  return {
    callCount: left.callCount + right.callCount,
    totalDurationMs: left.totalDurationMs + right.totalDurationMs,
    maxDurationMs: Math.max(left.maxDurationMs, right.maxDurationMs),
  };
}
