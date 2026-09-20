/**
 * Anthropic Messages API caller for exploit-coach benchmarks.
 *
 * Production live coaching remains Gemini-backed. This module lets the
 * versioned coach benchmark exercise Claude Haiku with the same prompts,
 * JSON schema, and draft/critic loop so quality/cost/latency can be compared.
 */

import {
  generationUsageFromAnthropicUsage,
  type AnthropicUsageMetadata,
} from "./generation_usage";
import {
  liveUsageFromPurpose,
  LiveUsageError,
  type LiveLlmPurpose,
  type LiveUsageBreakdown,
} from "./live_usage";

/** Default Claude Haiku snapshot for coach benches. */
export const DEFAULT_CLAUDE_HAIKU_MODEL_ID = "claude-haiku-4-5-20251001";

type CoachThinkingLevel = "low" | "medium" | "high";

/** True when the coach model id should use the Anthropic Messages API. */
export function isAnthropicCoachModel(modelId: string): boolean {
  const normalized = modelId.trim().toLowerCase();
  return normalized.startsWith("claude-");
}

/** Maps Gemini-style thinking levels onto Haiku extended-thinking budgets. */
export function anthropicThinkingBudget(
  level: CoachThinkingLevel,
): number | null {
  if (level === "low") return null;
  if (level === "medium") return 2048;
  return 8192;
}

/** Calls Anthropic with structured JSON output for one coach pass. */
export async function callAnthropicCoachJson(options: {
  apiKey: string;
  modelId: string;
  system: string;
  user: string;
  schema: Record<string, unknown>;
  thinkingLevel: CoachThinkingLevel;
  purpose: LiveLlmPurpose;
  fetchImpl?: typeof fetch;
}): Promise<{value: unknown; usage: LiveUsageBreakdown}> {
  const modelId = options.modelId.trim() || DEFAULT_CLAUDE_HAIKU_MODEL_ID;
  const budget = anthropicThinkingBudget(options.thinkingLevel);
  const maxTokens = budget === null ? 8192 : budget + 8192;
  const body: Record<string, unknown> = {
    model: modelId,
    max_tokens: maxTokens,
    system: options.system,
    messages: [{role: "user", content: options.user}],
    output_config: {
      format: {
        type: "json_schema",
        schema: anthropicCompatibleSchema(options.schema),
      },
    },
  };
  if (budget !== null) {
    body.thinking = {type: "enabled", budget_tokens: budget};
  }
  const fetchImpl = options.fetchImpl ?? fetch;
  const startedMs = Date.now();
  let response: Response | null = null;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      response = await fetchImpl("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": options.apiKey,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify(body),
      });
    } catch (error) {
      if (attempt === 2) throw error;
      await delay(500 * 2 ** attempt);
      continue;
    }
    if (response.ok) break;
    const retryable =
      response.status === 429 ||
      response.status === 500 ||
      response.status === 503;
    if (!retryable || attempt === 2) {
      const text = await response.text();
      throw new Error(
        `Anthropic coach HTTP ${response.status}: ` +
          text.split(options.apiKey).join("[REDACTED]"),
      );
    }
    await delay(500 * 2 ** attempt);
  }
  if (!response?.ok) throw new Error("Anthropic coach request failed");
  const json = await response.json() as Record<string, unknown>;
  const durationMs = Date.now() - startedMs;
  const usage = liveUsageFromPurpose(
    generationUsageFromAnthropicUsage(
      json.usage as AnthropicUsageMetadata | undefined,
      Date.now(),
      modelId,
    ),
    options.purpose,
    durationMs,
  );
  const text = extractAnthropicText(json);
  if (!text) {
    throw new LiveUsageError("Anthropic coach returned empty text", usage);
  }
  try {
    return {
      value: JSON.parse(
        text
          .trim()
          .replace(/^```(?:json)?\s*/i, "")
          .replace(/\s*```$/i, ""),
      ) as unknown,
      usage,
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new LiveUsageError(
      `Anthropic coach returned invalid JSON: ${message}`,
      usage,
    );
  }
}

function extractAnthropicText(response: Record<string, unknown>): string | null {
  const content = response.content;
  if (!Array.isArray(content)) return null;
  const parts = content
    .map((block) => {
      if (!block || typeof block !== "object") return "";
      const record = block as {type?: unknown; text?: unknown};
      if (record.type === "text" && typeof record.text === "string") {
        return record.text;
      }
      return "";
    })
    .join("")
    .trim();
  return parts || null;
}

/**
 * Anthropic structured outputs only allow array minItems/maxItems of 0 or 1.
 * Exact action coverage is still enforced by parseAssessments after the call.
 */
export function anthropicCompatibleSchema(
  schema: Record<string, unknown>,
): Record<string, unknown> {
  return sanitizeSchemaNode(schema) as Record<string, unknown>;
}

function sanitizeSchemaNode(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map((entry) => sanitizeSchemaNode(entry));
  }
  if (!value || typeof value !== "object") return value;
  const input = value as Record<string, unknown>;
  const output: Record<string, unknown> = {};
  for (const [key, child] of Object.entries(input)) {
    if (
      (key === "minItems" || key === "maxItems") &&
      typeof child === "number" &&
      child > 1
    ) {
      continue;
    }
    output[key] = sanitizeSchemaNode(child);
  }
  return output;
}

function delay(milliseconds: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}
