/**
 * Gemini generateContent client for branching situations.
 *
 * Uses gemini-3.8-flash only, with low thinking for generation and medium
 * thinking for critique. No sampling controls are sent.
 * Two-pass pipeline: generate structured JSON, then critique/correct.
 */

import { logger } from "firebase-functions";
import {
  GEMINI_MODEL_ID,
  PAYLOAD_VERSION,
  SIZING_BUCKETS,
  SITUATION_SCHEMA_VERSION,
  VILLAIN_ARCHETYPES,
  type SituationPayload,
  type TableSetupInput,
} from "./situation_types";
import { assertValidSituation } from "./validate_situation";
import { buildSetupKey } from "./setup_key";

export const DEFAULT_GEMINI_MODEL = GEMINI_MODEL_ID;

const STREET_SCHEMA = {
  type: "string",
  enum: ["preflop", "flop", "turn", "river"],
} as const;

const HERO_ACTION_KIND_SCHEMA = {
  type: "string",
  enum: ["FOLD", "CHECK", "CALL", "BET", "RAISE", "ALL_IN"],
} as const;

const STATE_PROPERTIES = {
  id: { type: "string", minLength: 1 },
  street: STREET_SCHEMA,
  pot: { type: "number" },
  stacks: { type: "array", items: { type: "number" } },
  streetBets: { type: "array", items: { type: "number" } },
  board: { type: "array", items: { type: "string" } },
  foldedSeats: { type: "array", items: { type: "integer" } },
} as const;

const HERO_ACTION_EDGE_SCHEMA = {
  type: "object",
  additionalProperties: false,
  properties: {
    actionKey: { type: "string", minLength: 1 },
    kind: HERO_ACTION_KIND_SCHEMA,
    amountTo: { type: "number" },
    sizingBucket: { type: "string", enum: [...SIZING_BUCKETS] },
    coaching: { type: "string", minLength: 1 },
    verdict: {
      type: "string",
      enum: ["correct", "incorrect", "close"],
    },
    evDeltaBb: { type: "number" },
    optimalActionKey: { type: "string", minLength: 1 },
    nextNodeId: { type: "string", minLength: 1 },
  },
  required: [
    "actionKey",
    "kind",
    "coaching",
    "verdict",
    "evDeltaBb",
    "optimalActionKey",
    "nextNodeId",
  ],
} as const;

const SCRIPTED_ACTION_SCHEMA = {
  type: "object",
  additionalProperties: false,
  properties: {
    seat: { type: "integer" },
    kind: {
      type: "string",
      enum: [
        "FOLD",
        "CHECK",
        "CALL",
        "BET",
        "RAISE",
        "ALL_IN",
        "POST_SB",
        "POST_BB",
        "POST_ANTE",
      ],
    },
    amountTo: { type: "number" },
    label: { type: "string" },
  },
  required: ["seat", "kind"],
} as const;

const HERO_NODE_SCHEMA = {
  type: "object",
  additionalProperties: false,
  properties: {
    type: { type: "string", enum: ["hero"] },
    ...STATE_PROPERTIES,
    toAct: { type: "integer" },
    callAmount: { type: "number" },
    minRaiseTo: { type: "number" },
    actions: {
      type: "array",
      minItems: 2,
      maxItems: 4,
      items: HERO_ACTION_EDGE_SCHEMA,
    },
  },
  required: [
    "type",
    "id",
    "street",
    "pot",
    "stacks",
    "streetBets",
    "board",
    "foldedSeats",
    "toAct",
    "callAmount",
    "minRaiseTo",
    "actions",
  ],
} as const;

const SCRIPTED_NODE_SCHEMA = {
  type: "object",
  description:
    "The root must be a canonical preflop scripted node with pot 0, full " +
    "starting stacks, zero street bets, empty board/folds, and a complete " +
    "forced-post action prefix.",
  additionalProperties: false,
  properties: {
    type: { type: "string", enum: ["scripted"] },
    ...STATE_PROPERTIES,
    actions: {
      type: "array",
      minItems: 1,
      items: SCRIPTED_ACTION_SCHEMA,
    },
    nextNodeId: { type: "string", minLength: 1 },
  },
  required: [
    "type",
    "id",
    "street",
    "pot",
    "stacks",
    "streetBets",
    "board",
    "foldedSeats",
    "actions",
    "nextNodeId",
  ],
} as const;

const TERMINAL_NODE_SCHEMA = {
  type: "object",
  additionalProperties: false,
  properties: {
    type: { type: "string", enum: ["terminal"] },
    id: { type: "string", minLength: 1 },
    reason: {
      type: "string",
      enum: ["fold", "showdown", "all_in_runout"],
    },
    street: STREET_SCHEMA,
    board: { type: "array", items: { type: "string" } },
    foldedSeats: { type: "array", items: { type: "integer" } },
    stacks: { type: "array", items: { type: "number" } },
    pot: { type: "number" },
    winnerSeats: { type: "array", minItems: 1, items: { type: "integer" } },
    heroNetChips: { type: "number" },
    summary: { type: "string" },
  },
  required: [
    "type",
    "id",
    "reason",
    "street",
    "board",
    "foldedSeats",
    "stacks",
    "pot",
    "winnerSeats",
    "heroNetChips",
  ],
} as const;

/**
 * Gemini response JSON Schema for one complete SituationPayload.
 *
 * Nodes use an explicit non-recursive union. Graph links remain string ids and
 * are checked by the deterministic validator after both model passes.
 */
export const SITUATION_RESPONSE_JSON_SCHEMA = {
  type: "object",
  additionalProperties: false,
  properties: {
    payloadVersion: { type: "integer", enum: [PAYLOAD_VERSION] },
    schemaVersion: { type: "string", minLength: 1 },
    setupKey: { type: "string", minLength: 1 },
    setupMode: { type: "string", enum: ["random", "custom"] },
    seatCount: { type: "integer" },
    smallBlind: { type: "number" },
    bigBlind: { type: "number" },
    ante: { type: "number" },
    startingStack: { type: "number" },
    buttonSeat: { type: "integer" },
    heroSeat: { type: "integer" },
    lineup: {
      type: "array",
      minItems: 2,
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          seat: { type: "integer" },
          archetype: {
            type: "string",
            enum: [...VILLAIN_ARCHETYPES, "HERO"],
          },
          name: { type: "string", minLength: 1 },
          startingStack: { type: "number" },
        },
        required: ["seat", "archetype", "name", "startingStack"],
      },
    },
    heroHand: {
      type: "array",
      minItems: 2,
      maxItems: 2,
      items: { type: "string" },
    },
    holeCards: {
      type: "array",
      minItems: 2,
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          seat: { type: "integer" },
          cards: {
            type: "array",
            minItems: 2,
            maxItems: 2,
            items: { type: "string" },
          },
        },
        required: ["seat", "cards"],
      },
    },
    runouts: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          street: { type: "string", enum: ["flop", "turn", "river"] },
          cards: { type: "array", items: { type: "string" } },
        },
        required: ["street", "cards"],
      },
    },
    rootNodeId: {
      type: "string",
      minLength: 1,
      description:
        "References a canonical preflop scripted node whose actions begin " +
        "with the complete ante/SB/BB ledger.",
    },
    nodes: {
      type: "object",
      minProperties: 1,
      maxProperties: 12,
      additionalProperties: {
        anyOf: [HERO_NODE_SCHEMA, SCRIPTED_NODE_SCHEMA, TERMINAL_NODE_SCHEMA],
      },
    },
    title: { type: "string" },
  },
  required: [
    "payloadVersion",
    "schemaVersion",
    "setupKey",
    "setupMode",
    "seatCount",
    "smallBlind",
    "bigBlind",
    "ante",
    "startingStack",
    "buttonSeat",
    "heroSeat",
    "lineup",
    "holeCards",
    "heroHand",
    "runouts",
    "rootNodeId",
    "nodes",
  ],
} as const;

/** Generation controls shared by generate and critique passes. */
export const GEMINI_GENERATION_CONFIG = {
  responseMimeType: "application/json",
  responseJsonSchema: SITUATION_RESPONSE_JSON_SCHEMA,
  thinkingConfig: {
    thinkingLevel: "medium",
  },
} as const;

/** Lower-cost first pass; critique retains medium reasoning. */
export const GEMINI_INITIAL_GENERATION_CONFIG = {
  ...GEMINI_GENERATION_CONFIG,
  thinkingConfig: {
    thinkingLevel: "low",
  },
} as const;

const SYSTEM_GENERATE = `You are a poker situation architect for live No-Limit Hold'em training.
Build ONE curated full-hand branching situation that ALWAYS starts preflop.

Rules:
- Output a single JSON object matching the SituationPayload schema (payloadVersion ${PAYLOAD_VERSION}).
- Hero decision nodes offer standard legal actions/sizing buckets only (FOLD/CHECK/CALL/BET/RAISE/ALL_IN with buckets MIN|33|50|67|75|100|125|150|200|ALL_IN).
- Between hero nodes, use scripted villain actions (type "scripted").
- Scripted nodes must NEVER contain a voluntary Hero action. Every Hero fold/check/call/bet/raise/all-in must be represented by an edge from a hero node.
- On EVERY hero action edge include non-empty general coaching plus:
  - verdict: exactly "correct", "incorrect", or "close"
  - evDeltaBb: a finite strategic estimate relative to the best action
  - optimalActionKey: the actionKey of a correct edge in that same node
- EV deltas are strategic estimates, not chip results. Keep them internally consistent within each node: best/correct action(s) are 0 and all alternatives are non-positive.
- Every hero node has at least one correct action. All edges in that node use the same optimalActionKey, which must exist and point to a correct edge.
- Supply holeCards for every seat exactly once; heroHand must equal Hero's entry. Every hole and board card must be globally unique.
- Every node includes foldedSeats. Carry it exactly across edges; FOLD adds its actor, and folded seats never act again.
- Conserve chips: stacks + streetBets + pot must stay consistent along every branch.
- Every terminal includes stacks (chips behind immediately before awarding the pot) and unique, in-range winnerSeats. Terminal pot/stacks must exactly match the simulated transition.
- Side pots are unsupported. Convert each terminal pot to integer cents, sort winnerSeats ascending, assign floor(cents/winnerCount) to each, then one extra cent to each of the first remainder seats. Compute heroNetChips from Hero's assigned seat-specific share.
- Fold terminals stay on the same street, have exactly one active seat, and name that seat as winner. Showdown/all_in_runout terminals finish on the river with five cards; winnerSeats must be the exact tied best NLH hand(s) from authored hole cards plus board.
- Root must be scripted, preflop, pot=0, stacks all equal startingStack, streetBets all 0, board=[], and foldedSeats=[].
- Root actions must begin with the complete forced-post ledger. If ante>0, POST_ANTE every seat exactly once in seat order 0..N-1 with amountTo=ante. Heads-up: the button posts SB and the other seat posts BB. With 3+ seats: POST_SB at (buttonSeat+1)%seatCount and POST_BB at (buttonSeat+2)%seatCount. Blind amountTo is ante+smallBlind or ante+bigBlind. No forced posts may be missing, duplicated, reordered, or added after this prefix. Voluntary actions may follow it.
- Include at least one meaningful hero decision.
- Keep the entire graph to at most 12 nodes.
- Every root-to-terminal path has 1-3 hero decisions.
- Every hero node has 2-4 curated action choices.
- Do not personalize coaching to any player history.
- amountTo is total chips committed on the current street ("raise to").
`;

const SYSTEM_CRITIQUE = `You are an adversarial poker-situation critic and corrector.
Given a SituationPayload JSON, find and FIX:
- illegal actions / missing legal coverage at hero nodes
- any scripted voluntary Hero action (convert it to a hero decision edge/node)
- card collisions
- missing/inconsistent all-seat holeCards or foldedSeats
- pot / stack / streetBet inconsistencies
- terminal stacks/pot that do not exactly match the simulated pre-award state
- missing, duplicate, or out-of-range terminal winnerSeats
- invalid terminal outcomes: fold has one non-folded winner; showdown/all_in_runout uses the exact deterministic best seven-card hand winner(s)
- incorrect heroNetChips: side pots are unsupported; split integer pot cents by ascending winner seat, with one extra cent to each of the first remainder winners, then subtract Hero's lineup startingStack from Hero's final chips
- non-canonical root state or forced-post ledger (ordered all-seat antes when ante>0, then exact SB and BB seats/amountTo totals)
- street/board/runout mismatches
- coaching that contradicts the action (e.g. "never fold" on a FOLD edge)
- missing/invalid verdict, evDeltaBb, or optimalActionKey on any hero edge
- grading inconsistency: each node needs a correct action; correct/best is 0 EV, alternatives are non-positive strategic estimates; every edge must share an optimalActionKey that exists and points to a correct edge
- cycles, unreachable nodes, non-terminal leaves
- graphs over 12 nodes (prune low-value branches while preserving legal terminal paths)
Return ONLY the corrected full SituationPayload JSON. If already valid, return it unchanged.
Keep payloadVersion ${PAYLOAD_VERSION} and schemaVersion "${SITUATION_SCHEMA_VERSION}".
`;

export interface GenerateSituationResult {
  payload: SituationPayload;
  modelId: string;
  rawGenerate?: unknown;
  rawCritique?: unknown;
}

/**
 * Two-pass generation: create then critique/correct. Does not publish.
 */
export async function generateValidatedSituation(options: {
  apiKey: string;
  setup: TableSetupInput;
  setupKey?: string;
  variationSeed?: string;
  fetchImpl?: typeof fetch;
  maxAttempts?: number;
}): Promise<GenerateSituationResult> {
  const modelId = DEFAULT_GEMINI_MODEL;
  const fetchFn = options.fetchImpl ?? fetch;
  const setupKey = options.setupKey ?? buildSetupKey(options.setup);
  const maxAttempts = options.maxAttempts ?? 3;
  let lastError = "unknown";

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      const generated = await callGeminiJson({
        apiKey: options.apiKey,
        modelId,
        system: SYSTEM_GENERATE,
        user: buildGenerateUserPrompt(
          options.setup,
          setupKey,
          options.variationSeed ?? "default",
          attempt,
        ),
        fetchImpl: fetchFn,
        thinkingLevel: "low",
      });

      const critiqued = await callGeminiJson({
        apiKey: options.apiKey,
        modelId,
        system: SYSTEM_CRITIQUE,
        user:
          `Setup key: ${setupKey}\n` +
          `Critique and correct this SituationPayload:\n` +
          `${JSON.stringify(generated)}`,
        fetchImpl: fetchFn,
        thinkingLevel: "medium",
      });

      const normalized = normalizePayload(critiqued, options.setup, setupKey);
      const payload = assertValidSituation(normalized);
      return {
        payload,
        modelId,
        rawGenerate: generated,
        rawCritique: critiqued,
      };
    } catch (err) {
      lastError = err instanceof Error ? err.message : String(err);
      logger.warn("situation generation attempt failed", {
        attempt,
        setupKey,
        error: lastError,
      });
    }
  }

  throw new Error(
    `failed to generate valid situation after ${maxAttempts} attempts: ${lastError}`,
  );
}

function buildGenerateUserPrompt(
  setup: TableSetupInput,
  setupKey: string,
  variationSeed: string,
  attempt: number,
): string {
  const ante = setup.ante ?? 0;
  const base =
    `Create one unique branching situation for setupKey=${setupKey}.\n` +
    `mode=${setup.mode}, seats=${setup.seatCount}, ` +
    `SB=${setup.smallBlind}, BB=${setup.bigBlind}, ante=${ante}, ` +
    `startingStack=${setup.startingStack}.\n` +
    `Batch variation seed: ${variationSeed}; validation attempt: ${attempt}.\n` +
    `JSON must include: payloadVersion, schemaVersion, setupKey, setupMode, ` +
    `seatCount, smallBlind, bigBlind, ante, startingStack, buttonSeat, heroSeat, ` +
    `lineup[], holeCards[], heroHand[2], runouts[], rootNodeId, nodes{}, title.\n` +
    `Node types: hero | scripted | terminal.\n`;

  if (setup.mode === "custom" && setup.lineup) {
    return (
      base +
      `Custom lineup (ordered): ${JSON.stringify(setup.lineup)}\n` +
      `buttonSeat=${setup.buttonSeat}, heroSeat=${setup.heroSeat}.\n` +
      `Use this exact lineup/button/hero.`
    );
  }

  return (
    base +
    `Random Pool: invent a realistic ordered lineup with exactly one HERO, ` +
    `varied villain archetypes (MANIAC|NIT|CALLING_STATION|TAG|LAG), ` +
    `choose buttonSeat and heroSeat.`
  );
}

/**
 * Forces setup fingerprint fields onto the model output.
 */
export function normalizePayload(
  raw: unknown,
  setup: TableSetupInput,
  setupKey: string,
): SituationPayload {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new Error("Gemini returned non-object payload");
  }
  const obj = { ...(raw as Record<string, unknown>) };
  obj.payloadVersion = PAYLOAD_VERSION;
  obj.schemaVersion = SITUATION_SCHEMA_VERSION;
  obj.setupKey = setupKey;
  obj.setupMode = setup.mode;
  obj.seatCount = setup.seatCount;
  obj.smallBlind = setup.smallBlind;
  obj.bigBlind = setup.bigBlind;
  obj.ante = setup.ante ?? 0;
  obj.startingStack = setup.startingStack;

  const existing = Array.isArray(obj.lineup) ? obj.lineup : [];
  obj.lineup = existing.map((entry, index) => {
    const row =
      entry && typeof entry === "object" && !Array.isArray(entry)
        ? (entry as Record<string, unknown>)
        : {};
    return {
      seat: Number.isInteger(row.seat) ? row.seat : index,
      archetype: typeof row.archetype === "string" ? row.archetype : "TAG",
      name:
        typeof row.name === "string" && row.name.trim()
          ? row.name.trim()
          : `Seat${index}`,
      startingStack: setup.startingStack,
    };
  });

  if (setup.mode === "custom") {
    obj.buttonSeat = setup.buttonSeat;
    obj.heroSeat = setup.heroSeat;
    if (setup.lineup) {
      obj.lineup = setup.lineup.map((seat, i) => {
        const prev = (existing[i] ?? {}) as Record<string, unknown>;
        return {
          seat: seat.seat,
          archetype: seat.archetype,
          name:
            seat.name ??
            (typeof prev.name === "string" ? prev.name : `Seat${seat.seat}`),
          startingStack: setup.startingStack,
        };
      });
    }
  }

  return obj as unknown as SituationPayload;
}

async function callGeminiJson(options: {
  apiKey: string;
  modelId: string;
  system: string;
  user: string;
  fetchImpl: typeof fetch;
  thinkingLevel: "low" | "medium";
}): Promise<unknown> {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/` +
    `${encodeURIComponent(options.modelId)}:generateContent` +
    `?key=${encodeURIComponent(options.apiKey)}`;

  const body = {
    system_instruction: {
      parts: [{ text: options.system }],
    },
    contents: [
      {
        role: "user",
        parts: [{ text: options.user }],
      },
    ],
    generationConfig: {
      ...GEMINI_GENERATION_CONFIG,
      thinkingConfig: {
        thinkingLevel: options.thinkingLevel,
      },
    },
  };

  const res = await options.fetchImpl(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(
      `Gemini HTTP ${res.status}: ${redactKey(text, options.apiKey)}`,
    );
  }

  const responseJson = (await res.json()) as Record<string, unknown>;
  const text = extractText(responseJson);
  if (!text) {
    throw new Error("Gemini returned empty text");
  }

  const decoded = JSON.parse(stripFences(text)) as unknown;
  if (!decoded || typeof decoded !== "object" || Array.isArray(decoded)) {
    throw new Error("Gemini JSON was not an object");
  }
  return decoded;
}

function extractText(response: Record<string, unknown>): string | null {
  const candidates = response.candidates;
  if (!Array.isArray(candidates) || candidates.length === 0) return null;
  const first = candidates[0] as { content?: { parts?: unknown[] } };
  const parts = first.content?.parts;
  if (!Array.isArray(parts)) return null;
  let buffer = "";
  for (const part of parts) {
    if (part && typeof part === "object" && "text" in part) {
      const text = (part as { text?: unknown }).text;
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
