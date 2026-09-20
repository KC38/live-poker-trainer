/**
 * OpenAI-compatible Responses API caller for coach benchmarks.
 *
 * Used for OpenAI (gpt-*) and DeepSeek (deepseek-*) model ids. Production live
 * coaching remains Gemini-backed until a non-Google config wins the gate.
 */

import {
  generationUsageFromOpenAiCompatibleUsage,
  type OpenAiCompatibleUsageMetadata,
} from "./generation_usage";
import {
  liveUsageFromPurpose,
  LiveUsageError,
  type LiveLlmPurpose,
  type LiveUsageBreakdown,
} from "./live_usage";

/** Default OpenAI coach candidate. */
export const DEFAULT_OPENAI_COACH_MODEL_ID = "gpt-5-mini";

/** Default DeepSeek coach candidate. */
export const DEFAULT_DEEPSEEK_COACH_MODEL_ID = "deepseek-flash";

type CoachThinkingLevel = "low" | "medium" | "high";

export type OpenAiCompatibleProvider = "openai" | "deepseek";

interface ProviderEndpoint {
  provider: OpenAiCompatibleProvider;
  baseUrl: string;
}

/** Resolves OpenAI-compatible provider routing from a model id. */
export function openAiCompatibleProviderForModel(
  modelId: string,
): OpenAiCompatibleProvider | null {
  const normalized = modelId.trim().toLowerCase();
  if (normalized.startsWith("gpt-")) return "openai";
  if (normalized.startsWith("deepseek-")) return "deepseek";
  return null;
}

/** Maps Gemini-style thinking levels onto Responses API reasoning effort. */
export function openAiReasoningEffort(
  level: CoachThinkingLevel,
): "minimal" | "low" | "medium" | "high" {
  if (level === "low") return "minimal";
  if (level === "medium") return "medium";
  return "high";
}

/** Calls an OpenAI-compatible Responses endpoint with JSON schema output. */
export async function callOpenAiCompatibleCoachJson(options: {
  apiKey: string;
  modelId: string;
  system: string;
  user: string;
  schema: Record<string, unknown>;
  thinkingLevel: CoachThinkingLevel;
  purpose: LiveLlmPurpose;
  fetchImpl?: typeof fetch;
}): Promise<{value: unknown; usage: LiveUsageBreakdown}> {
  const provider = openAiCompatibleProviderForModel(options.modelId);
  if (!provider) {
    throw new Error(`unsupported OpenAI-compatible model ${options.modelId}`);
  }
  const endpoint = providerEndpoint(provider);
  const modelId = options.modelId.trim();
  const effort = openAiReasoningEffort(options.thinkingLevel);
  const body: Record<string, unknown> = {
    model: modelId,
    instructions: options.system,
    input: options.user,
    text: {
      format: {
        type: "json_schema",
        name: "coaching_rubric",
        schema: openAiCompatibleSchema(options.schema),
        strict: true,
      },
    },
  };
  // DeepSeek thinking defaults on; disable for low, enable otherwise.
  if (provider === "deepseek") {
    body.thinking = {
      type: effort === "minimal" ? "disabled" : "enabled",
    };
  } else {
    body.reasoning = {effort};
  }
  const fetchImpl = options.fetchImpl ?? fetch;
  const startedMs = Date.now();
  let response: Response | null = null;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      response = await fetchImpl(`${endpoint.baseUrl}/responses`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${options.apiKey}`,
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
        `${endpoint.provider} coach HTTP ${response.status}: ` +
          text.split(options.apiKey).join("[REDACTED]"),
      );
    }
    await delay(500 * 2 ** attempt);
  }
  if (!response?.ok) {
    throw new Error(`${endpoint.provider} coach request failed`);
  }
  const json = await response.json() as Record<string, unknown>;
  const durationMs = Date.now() - startedMs;
  const usage = liveUsageFromPurpose(
    generationUsageFromOpenAiCompatibleUsage(
      json.usage as OpenAiCompatibleUsageMetadata | undefined,
      Date.now(),
      modelId,
    ),
    options.purpose,
    durationMs,
  );
  const text = extractResponsesText(json);
  if (!text) {
    throw new LiveUsageError(
      `${endpoint.provider} coach returned empty text`,
      usage,
    );
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
      `${endpoint.provider} coach returned invalid JSON: ${message}`,
      usage,
    );
  }
}

/**
 * OpenAI strict structured outputs require every property to be listed in
 * `required`. Optional coach fields become nullable instead of omitted.
 */
export function openAiCompatibleSchema(
  schema: Record<string, unknown>,
): Record<string, unknown> {
  return makeStrictObject(schema) as Record<string, unknown>;
}

function makeStrictObject(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map((entry) => makeStrictObject(entry));
  }
  if (!value || typeof value !== "object") return value;
  const input = value as Record<string, unknown>;
  const output: Record<string, unknown> = {};
  for (const [key, child] of Object.entries(input)) {
    output[key] = makeStrictObject(child);
  }
  if (output.type === "object" && output.properties &&
    typeof output.properties === "object") {
    const properties = output.properties as Record<string, unknown>;
    const required = new Set(
      Array.isArray(output.required) ?
        output.required.filter((entry): entry is string =>
          typeof entry === "string"
        ) :
        [],
    );
    for (const [name, property] of Object.entries(properties)) {
      if (!required.has(name)) {
        properties[name] = makeNullable(property);
        required.add(name);
      }
    }
    output.required = [...required];
    output.additionalProperties = false;
  }
  return output;
}

function makeNullable(property: unknown): unknown {
  if (!property || typeof property !== "object") {
    return {anyOf: [{type: typeof property === "string" ? property : "string"}, {type: "null"}]};
  }
  const record = property as Record<string, unknown>;
  if (record.anyOf) return property;
  return {
    anyOf: [
      record,
      {type: "null"},
    ],
  };
}

function providerEndpoint(provider: OpenAiCompatibleProvider): ProviderEndpoint {
  if (provider === "deepseek") {
    return {provider, baseUrl: "https://api.deepseek.com"};
  }
  return {provider, baseUrl: "https://api.openai.com/v1"};
}

function extractResponsesText(response: Record<string, unknown>): string | null {
  if (typeof response.output_text === "string" && response.output_text.trim()) {
    return response.output_text.trim();
  }
  const output = response.output;
  if (!Array.isArray(output)) return null;
  const chunks: string[] = [];
  for (const item of output) {
    if (!item || typeof item !== "object") continue;
    const record = item as {type?: unknown; content?: unknown};
    if (record.type !== "message" || !Array.isArray(record.content)) continue;
    for (const part of record.content) {
      if (!part || typeof part !== "object") continue;
      const block = part as {type?: unknown; text?: unknown};
      if (
        (block.type === "output_text" || block.type === "text") &&
        typeof block.text === "string"
      ) {
        chunks.push(block.text);
      }
    }
  }
  const joined = chunks.join("").trim();
  return joined || null;
}

function delay(milliseconds: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}
