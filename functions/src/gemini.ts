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
import {
  addGenerationUsage,
  emptyGenerationUsage,
  generationUsageFromMetadata,
  type GenerationUsage,
  type GeminiUsageMetadata,
} from "./generation_usage";
import {
  validateSituation,
  type ValidationIssue,
} from "./validate_situation";
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
      maxItems: 2,
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
      maxProperties: 16,
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
- At every hero node facing a bet, actions MUST include FOLD and either CALL or ALL_IN; never include CHECK or BET. When checked to, include CHECK or BET/ALL_IN; never include FOLD, CALL, or RAISE.
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
- Recompute every target node snapshot from its incoming action: amountTo is the actor's total street commitment; add only the commitment delta to pot, subtract that delta from stack, carry all folds, and reset all streetBets to zero only when advancing exactly one street.
- Every terminal includes stacks (chips behind immediately before awarding the pot) and unique, in-range winnerSeats. Terminal pot/stacks must exactly match the simulated transition.
- Side pots are unsupported. Convert each terminal pot to integer cents, sort winnerSeats ascending, assign floor(cents/winnerCount) to each, then one extra cent to each of the first remainder seats. Compute heroNetChips from Hero's assigned seat-specific share.
- Fold terminals stay on the same street, have exactly one active seat, and name that seat as winner. Showdown/all_in_runout terminals finish on the river with five cards; winnerSeats must be the exact tied best NLH hand(s) from authored hole cards plus board.
- Root must be scripted, preflop, pot=0, stacks all equal startingStack, streetBets all 0, board=[], and foldedSeats=[].
- Root actions must begin with the complete forced-post ledger. If ante>0, POST_ANTE every seat exactly once in seat order 0..N-1 with amountTo=ante. Heads-up: the button posts SB and the other seat posts BB. With 3+ seats: POST_SB at (buttonSeat+1)%seatCount and POST_BB at (buttonSeat+2)%seatCount. Blind amountTo is ante+smallBlind or ante+bigBlind. No forced posts may be missing, duplicated, reordered, or added after this prefix. Voluntary actions may follow it.
- Include at least one meaningful hero decision.
- Keep the entire graph to at most 16 nodes.
- Every root-to-terminal path has 1-4 hero decisions.
- Every hero node has exactly 2 curated action choices.
- To stay within 16 nodes, allow only one nonterminal continuation from each hero node; the other choice should end the hand legally by fold or all-in whenever strategically plausible.
- Play every street: while two or more players still have chips, do NOT jump to a showdown or all_in_runout terminal. Advance one street at a time with a hero decision on each street (preflop/flop/turn/river) until a fold ends the hand or an all-in leaves fewer than two stacks behind.
- Showdown terminals are only legal from a river node after the river betting round. all_in_runout is only legal when fewer than two players have chips behind.
- Do not personalize coaching to any player history.
- amountTo is total chips committed on the current street ("raise to").
`;

const SYSTEM_CRITIQUE = `You are an adversarial poker-situation critic and corrector.
Given a SituationPayload JSON, find and FIX:
- illegal actions / missing legal coverage at hero nodes
- facing-bet nodes missing FOLD plus CALL/ALL_IN, or checked-to nodes using FOLD/CALL/RAISE
- any scripted voluntary Hero action (convert it to a hero decision edge/node)
- card collisions
- missing/inconsistent all-seat holeCards or foldedSeats
- pot / stack / streetBet inconsistencies
- target snapshots not exactly recomputed from the incoming action's commitment delta and carried folds
- terminal stacks/pot that do not exactly match the simulated pre-award state
- missing, duplicate, or out-of-range terminal winnerSeats
- invalid terminal outcomes: fold has one non-folded winner; showdown/all_in_runout uses the exact deterministic best seven-card hand winner(s)
- incorrect heroNetChips: side pots are unsupported; split integer pot cents by ascending winner seat, with one extra cent to each of the first remainder winners, then subtract Hero's lineup startingStack from Hero's final chips
- non-canonical root state or forced-post ledger (ordered all-seat antes when ante>0, then exact SB and BB seats/amountTo totals)
- street/board/runout mismatches
- shortcut showdowns: showdown terminals must come from the river; all_in_runout only when fewer than two players have chips; live pots need a hero decision on each street
- coaching that contradicts the action (e.g. "never fold" on a FOLD edge)
- missing/invalid verdict, evDeltaBb, or optimalActionKey on any hero edge
- grading inconsistency: each node needs a correct action; correct/best is 0 EV, alternatives are non-positive strategic estimates; every edge must share an optimalActionKey that exists and points to a correct edge
- cycles, unreachable nodes, non-terminal leaves
- graphs over 16 nodes (prune low-value branches while preserving legal terminal paths)
Return ONLY the corrected full SituationPayload JSON. If already valid, return it unchanged.
Keep payloadVersion ${PAYLOAD_VERSION} and schemaVersion "${SITUATION_SCHEMA_VERSION}".
`;

export interface GenerateSituationResult {
  payload: SituationPayload;
  modelId: string;
  usage: GenerationUsage;
  validationFailureCount: number;
  rawGenerate?: unknown;
  rawCritique?: unknown;
}

/** Generation failure carrying usage from every billable response received. */
export class SituationGenerationError extends Error {
  constructor(
    message: string,
    readonly usage: GenerationUsage,
    readonly validationFailureCount: number,
  ) {
    super(message);
    this.name = "SituationGenerationError";
  }
}

/**
 * Generates once, then critiques or repairs the same payload with exact local
 * validator feedback. Reusing the candidate avoids paying for a fresh
 * generate+critique pair after every validation failure.
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
  let usage = emptyGenerationUsage();
  let validationFailureCount = 0;
  let lastError = "unknown";
  let generated: unknown | undefined;
  let candidate: SituationPayload | undefined;
  let candidateIssues: ValidationIssue[] | undefined;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      if (!candidate) {
        const generationCall = await callGeminiJson({
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
        usage = addGenerationUsage(usage, generationCall.usage);
        generated = generationCall.value;
        candidate = normalizePayload(generated, options.setup, setupKey);
        const generationValidation = validateSituation(candidate);
        candidateIssues = generationValidation.issues;
        if (!generationValidation.ok) validationFailureCount += 1;
      }

      const critiqueCall = await callGeminiJson({
        apiKey: options.apiKey,
        modelId,
        system: SYSTEM_CRITIQUE,
        user: buildCritiquePrompt(setupKey, candidate, candidateIssues ?? []),
        fetchImpl: fetchFn,
        thinkingLevel: "medium",
      });
      usage = addGenerationUsage(usage, critiqueCall.usage);
      const critiqued = critiqueCall.value;
      candidate = normalizePayload(critiqued, options.setup, setupKey);
      const correctedValidation = validateSituation(candidate);
      if (!correctedValidation.ok) {
        validationFailureCount += 1;
        candidateIssues = correctedValidation.issues;
        lastError = validationIssueSummary(correctedValidation.issues);
        logger.warn("situation correction still invalid", {
          attempt,
          setupKey,
          issues: correctedValidation.issues.slice(0, 8),
        });
        continue;
      }
      return {
        payload: candidate,
        modelId,
        usage,
        validationFailureCount,
        rawGenerate: generated,
        rawCritique: critiqued,
      };
    } catch (err) {
      usage = addGenerationUsage(usage, usageFromError(err));
      lastError = err instanceof Error ? err.message : String(err);
      logger.warn("situation generation attempt failed", {
        attempt,
        setupKey,
        error: lastError,
      });
    }
  }

  throw new SituationGenerationError(
    `failed to generate valid situation after ${maxAttempts} attempts: ` +
      lastError,
    usage,
    validationFailureCount,
  );
}

function buildCritiquePrompt(
  setupKey: string,
  candidate: SituationPayload,
  issues: ValidationIssue[],
): string {
  const feedback = issues.length === 0 ?
    "The deterministic validator found no structural errors. Preserve all " +
      "valid state while checking poker strategy and coaching." :
    "The deterministic validator found these errors. Fix every listed error " +
      "without introducing new branches or unrelated changes:\n" +
      prioritizeValidationIssues(issues)
        .slice(0, 20)
        .map((issue) =>
          `- [${issue.code}]${issue.nodeId ? ` node=${issue.nodeId}` : ""}: ` +
          issue.message
        )
        .join("\n");
  return (
    `Setup key: ${setupKey}\n` +
    `${feedback}\n` +
    "Return the complete corrected SituationPayload JSON:\n" +
    JSON.stringify(candidate)
  );
}

function prioritizeValidationIssues(
  issues: ValidationIssue[],
): ValidationIssue[] {
  const priority = (issue: ValidationIssue): number => {
    if (issue.code === "transition" || issue.code === "coverage") return 0;
    if (issue.code === "reachability") return 2;
    return 1;
  };
  return [...issues].sort((left, right) => priority(left) - priority(right));
}

function validationIssueSummary(issues: ValidationIssue[]): string {
  return issues
    .slice(0, 8)
    .map((issue) =>
      `${issue.code}${issue.nodeId ? `(${issue.nodeId})` : ""}: ` +
      issue.message
    )
    .join("; ");
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

  canonicalizePayloadCards(obj);
  return obj as unknown as SituationPayload;
}

function canonicalizePayloadCards(obj: Record<string, unknown>): void {
  obj.heroHand = canonicalizeCardArray(obj.heroHand);
  if (Array.isArray(obj.holeCards)) {
    for (const entry of obj.holeCards) {
      if (entry && typeof entry === "object" && !Array.isArray(entry)) {
        const row = entry as Record<string, unknown>;
        row.cards = canonicalizeCardArray(row.cards);
      }
    }
  }
  if (Array.isArray(obj.runouts)) {
    for (const entry of obj.runouts) {
      if (entry && typeof entry === "object" && !Array.isArray(entry)) {
        const row = entry as Record<string, unknown>;
        row.cards = canonicalizeCardArray(row.cards);
      }
    }
  }
  if (obj.nodes && typeof obj.nodes === "object" && !Array.isArray(obj.nodes)) {
    for (const node of Object.values(
      obj.nodes as Record<string, unknown>,
    )) {
      if (node && typeof node === "object" && !Array.isArray(node)) {
        const row = node as Record<string, unknown>;
        row.board = canonicalizeCardArray(row.board);
      }
    }
  }
}

function canonicalizeCardArray(value: unknown): unknown {
  if (!Array.isArray(value)) return value;
  return value.map(canonicalizeCardCode);
}

function canonicalizeCardCode(value: unknown): unknown {
  if (typeof value !== "string") return value;
  const trimmed = value.trim();
  const ten = /^10([cdhs])$/i.exec(trimmed);
  if (ten) return `T${ten[1].toLowerCase()}`;
  if (/^[2-9tjqka][cdhs]$/i.test(trimmed)) {
    return `${trimmed[0].toUpperCase()}${trimmed[1].toLowerCase()}`;
  }
  return value;
}

async function callGeminiJson(options: {
  apiKey: string;
  modelId: string;
  system: string;
  user: string;
  fetchImpl: typeof fetch;
  thinkingLevel: "low" | "medium";
}): Promise<{value: unknown; usage: GenerationUsage}> {
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
  const usage = generationUsageFromMetadata(
    responseJson.usageMetadata as GeminiUsageMetadata | undefined,
  );
  const text = extractText(responseJson);
  if (!text) {
    throw new GeminiCallError("Gemini returned empty text", usage);
  }

  let decoded: unknown;
  try {
    decoded = JSON.parse(stripFences(text)) as unknown;
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    throw new GeminiCallError(`Gemini returned invalid JSON: ${message}`, usage);
  }
  if (!decoded || typeof decoded !== "object" || Array.isArray(decoded)) {
    throw new GeminiCallError("Gemini JSON was not an object", usage);
  }
  return {value: decoded, usage};
}

class GeminiCallError extends Error {
  constructor(
    message: string,
    readonly usage: GenerationUsage,
  ) {
    super(message);
    this.name = "GeminiCallError";
  }
}

function usageFromError(error: unknown): GenerationUsage {
  if (error instanceof GeminiCallError) return error.usage;
  return emptyGenerationUsage();
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
