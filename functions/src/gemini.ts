/**
 * Gemini generateContent client for scenario JSON batches.
 *
 * Prompt / JSON contract ports `GeminiService` in the Flutter app
 * (`lib/services/gemini_service.dart`).
 */
import {logger} from "firebase-functions";

/** Same system instruction as Dart `GeminiService._scenarioSystem`. */
export const SCENARIO_SYSTEM = `You are a poker scenario architect for \$1/\$2 to \$5/\$10 No-Limit Hold'em.
Invent tough *exploitative decision spots* — never decide the optimal play. A separate EV engine grades the spot.

Diversity rules (critical for training engagement):
- Mix streets: roughly half preflop, half postflop (flop / turn / river).
- Hero must have a real decision — NOT an automatic fold. Prefer playable hands (opens, 3-bet pots, BB defense with decent holdings, value bets, thin value, bluffs with equity, river calls/folds that are close).
- Avoid junk hole cards facing a large raise preflop (those are just fold).
- Vary villain archetypes: Maniac, Nit, Calling Station, TAG, LAG.
- Vary action shapes: open, face raise, c-bet, check-raise, river bet, multiway-ish pots at 6-max.

Board / pot rules:
- Preflop: board_cards = [], pot_size is blinds (+ any preflop raises already in).
- Flop: exactly 3 board cards; turn: 4; river: 5. pot_size must match the action narrative.
- call_amount is chips hero must add to continue (0 when checked to).

Output valid JSON with exactly these keys:
table_size (preferably 6), hero_position, hero_hand (two codes like As,Kd), board_cards, pot_size, villain_seat, villain_archetype ('Maniac', 'Nit', 'Calling Station', 'TAG', 'LAG'), previous_action_narrative, villain_action, call_amount, min_raise, max_raise, name (short title).
Do NOT invent optimal_exploit_action, optimal_sizing_bb, theoretical_ev_explanation, or exploit_reasoning — leave those out.
`;

/** Default model — keep in sync with `Config.geminiModel` in Flutter. */
export const DEFAULT_GEMINI_MODEL = "gemini-3.8-flash";

export type ScenarioJson = Record<string, unknown>;

export interface GenerateScenariosResult {
  scenarios: ScenarioJson[];
  modelId: string;
  errors: string[];
}

/**
 * Calls Gemini once per requested scenario (matches Flutter batch loop).
 */
export async function generateScenarios(options: {
  apiKey: string;
  count: number;
  modelId?: string;
  fetchImpl?: typeof fetch;
}): Promise<GenerateScenariosResult> {
  const modelId = options.modelId ?? DEFAULT_GEMINI_MODEL;
  const fetchFn = options.fetchImpl ?? fetch;
  const scenarios: ScenarioJson[] = [];
  const errors: string[] = [];

  for (let i = 0; i < options.count; i++) {
    try {
      const json = await generateOneScenarioJson({
        apiKey: options.apiKey,
        modelId,
        seed: i,
        fetchImpl: fetchFn,
      });
      if (json) {
        scenarios.push(json);
      } else {
        errors.push(`seed ${i}: empty response`);
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      errors.push(`seed ${i}: ${message}`);
      logger.warn("Gemini scenario generation failed for seed", {
        seed: i,
        error: message,
      });
    }
  }

  return {scenarios, modelId, errors};
}

async function generateOneScenarioJson(options: {
  apiKey: string;
  modelId: string;
  seed: number;
  fetchImpl: typeof fetch;
}): Promise<ScenarioJson | null> {
  const focus = scenarioFocusForSeed(options.seed);
  const user =
    `Generate one unique tough exploitative spot focused on: ${focus}. ` +
    `Variation seed: ${options.seed}. Hero should usually continue ` +
    `(raise/call/bet), not auto-fold.`;
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/` +
    `${encodeURIComponent(options.modelId)}:generateContent` +
    `?key=${encodeURIComponent(options.apiKey)}`;

  const body = {
    system_instruction: {
      parts: [{text: SCENARIO_SYSTEM}],
    },
    contents: [
      {
        role: "user",
        parts: [{text: user}],
      },
    ],
    generationConfig: {
      responseMimeType: "application/json",
      temperature: 0.9,
    },
  };

  const res = await options.fetchImpl(url, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Gemini HTTP ${res.status}: ${redactKey(text, options.apiKey)}`);
  }

  const responseJson = (await res.json()) as Record<string, unknown>;
  const text = extractText(responseJson);
  if (!text) return null;

  const decoded = JSON.parse(stripFences(text)) as unknown;
  if (decoded && typeof decoded === "object" && !Array.isArray(decoded)) {
    return decoded as ScenarioJson;
  }
  return null;
}

function scenarioFocusForSeed(seed: number): string {
  switch (seed % 8) {
  case 0:
    return "preflop open from late position with a playable hand";
  case 1:
    return "preflop facing a raise with a defendable / 3-bettable hand";
  case 2:
    return "flop value vs a Calling Station or Nit";
  case 3:
    return "flop decision vs a Maniac or LAG bet";
  case 4:
    return "turn barrel or probe with equity";
  case 5:
    return "river thin value or bluff-catch vs archetype";
  case 6:
    return "3-bet pot preflop with a premium or suited broadway";
  default:
    return "multiway-aware flop or turn spot at 6-max";
  }
}

function extractText(response: Record<string, unknown>): string | null {
  const candidates = response.candidates;
  if (!Array.isArray(candidates) || candidates.length === 0) return null;
  const first = candidates[0] as {content?: {parts?: unknown[]}};
  const parts = first.content?.parts;
  if (!Array.isArray(parts)) return null;
  let buffer = "";
  for (const part of parts) {
    if (part && typeof part === "object" && "text" in part) {
      const text = (part as {text?: unknown}).text;
      if (typeof text === "string") buffer += text;
    }
  }
  const trimmed = buffer.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function stripFences(text: string): string {
  let t = text.trim();
  if (t.startsWith("```")) {
    t = t.replace(/^```(?:json)?\s*/i, "");
    t = t.replace(/\s*```$/i, "");
  }
  return t.trim();
}

function redactKey(text: string, apiKey: string): string {
  if (!apiKey) return text;
  return text.split(apiKey).join("[REDACTED]");
}
