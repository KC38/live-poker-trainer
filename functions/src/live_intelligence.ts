/**
 * Fair-information Gemini calls for opponent decisions and exploit coaching.
 *
 * Opponent calls contain only the acting villain's private cards. Coaching
 * calls contain only Hero's cards and public information. Both return stable
 * action ids that the authoritative engine independently validates.
 */

import {
  assertFairCoachingFacts,
  buildCoachingFacts,
  type CoachingFacts,
} from "./coaching_facts";
import {
  DEFAULT_GEMINI_MODEL_ID,
  generationUsageFromMetadata,
  type GeminiUsageMetadata,
} from "./generation_usage";
import {
  addLiveUsage,
  emptyLiveUsageBreakdown,
  liveUsageFromError,
  liveUsageFromPurpose,
  LiveUsageError,
  type LiveUsageBreakdown,
} from "./live_usage";
import {
  COACHING_SCHEMA_VERSION,
  type CoachingActionAssessment,
  type CoachingRubric,
  type LiveActionEvent,
  type LiveHandDefinition,
  type LiveHandState,
  type LiveLegalAction,
} from "./live_types";
import {hashLiveState, livePotSize} from "./live_poker_engine";

export const LIVE_INTELLIGENCE_MODEL = DEFAULT_GEMINI_MODEL_ID;

/** Thinking levels accepted by current Gemini 3.x coach models. */
export type GeminiThinkingLevel = "low" | "medium" | "high";

/** Configurable coach draft/critic pipeline settings for production or benches. */
export interface CoachIntelligenceConfig {
  modelId: string;
  draftThinking: GeminiThinkingLevel;
  criticThinking: GeminiThinkingLevel;
}

/**
 * Production coach defaults: gemini-3.8-flash medium/medium.
 *
 * Selected from the quality→cost→latency compare: passes the stratified gate
 * at ~3.5× lower cost and ~3× lower latency than high/high on the same model.
 */
export const DEFAULT_COACH_INTELLIGENCE: CoachIntelligenceConfig = {
  modelId: LIVE_INTELLIGENCE_MODEL,
  draftThinking: "medium",
  criticThinking: "medium",
};

const TENDENCY_KEYS = new Set([
  "vpip",
  "pfr",
  "threeBet",
  "aggression",
  "foldToFlopBet",
  "foldToTurnBet",
  "foldToRiverBet",
  "bluffRiver",
  "showdownCall",
  "sizingTellStrength",
]);

/** Villain decision result with billable Gemini usage. */
export interface VillainActionResult {
  actionId: string;
  usage: LiveUsageBreakdown;
}

/** Coaching rubric result with billable Gemini usage. */
export interface CoachingRubricResult {
  rubric: CoachingRubric;
  usage: LiveUsageBreakdown;
}

/** Chooses one legal action using only the acting villain's fair information. */
export async function chooseVillainAction(options: {
  apiKey: string;
  hand: LiveHandDefinition;
  state: LiveHandState;
  legalActions: LiveLegalAction[];
  publicHistory: LiveActionEvent[];
  fetchImpl?: typeof fetch;
}): Promise<VillainActionResult> {
  const actor = options.state.actorSeat;
  if (actor === null || actor === options.hand.setup.heroSeat) {
    throw new Error("villain action requested without a villain actor");
  }
  if (options.legalActions.length === 0) {
    throw new Error("villain has no legal actions");
  }
  if (options.legalActions.length === 1) {
    return {
      actionId: options.legalActions[0].actionId,
      usage: emptyLiveUsageBreakdown(),
    };
  }
  const seat = options.hand.seats.find((candidate) => candidate.seat === actor);
  const player = options.state.players[actor];
  if (!seat || !seat.tendency) throw new Error("villain profile missing");
  const publicSeats = options.hand.seats.map((definition) => {
    const stateSeat = options.state.players[definition.seat];
    return {
      seat: definition.seat,
      name: definition.name,
      archetype: definition.archetype,
      stack: stateSeat.stack,
      streetBet: stateSeat.streetBet,
      folded: stateSeat.folded,
      lastAction: stateSeat.lastAction,
    };
  });
  const context = {
    actingSeat: actor,
    ownCards: seat.holeCards,
    ownProfile: seat.tendency,
    street: options.state.street,
    board: options.state.board,
    pot: livePotSize(options.state),
    highestBet: options.state.highestBet,
    ownStack: player.stack,
    ownStreetBet: player.streetBet,
    buttonSeat: options.hand.buttonSeat,
    publicSeats,
    publicHistory: options.publicHistory,
    legalActions: options.legalActions,
  };
  const response = await callGeminiJson({
    apiKey: options.apiKey,
    system: [
      "Act as exactly one live poker opponent.",
      "Use only the supplied own cards, visible board, public history, stack",
      "state, and bounded tendency profile. Never infer or request another",
      "player's cards or the future board. Select exactly one supplied actionId.",
      "Behave recognizably according to the profile without making every action",
      "mechanically predictable. Return JSON only.",
    ].join(" "),
    user: JSON.stringify(context),
    schema: {
      type: "object",
      additionalProperties: false,
      properties: {
        actionId: {
          type: "string",
          enum: options.legalActions.map((action) => action.actionId),
        },
      },
      required: ["actionId"],
    },
    thinkingLevel: "low",
    purpose: "villain",
    modelId: LIVE_INTELLIGENCE_MODEL,
    fetchImpl: options.fetchImpl ?? fetch,
  });
  const actionId = (response.value as {actionId?: unknown}).actionId;
  if (
    typeof actionId !== "string" ||
    !options.legalActions.some((candidate) => candidate.actionId === actionId)
  ) {
    throw new LiveUsageError(
      "Gemini selected an illegal villain action",
      response.usage,
    );
  }
  return {actionId, usage: response.usage};
}

/**
 * Generates a hidden all-actions rubric, then runs an adversarial correction
 * pass before the node becomes coach-ready.
 */
export async function generateCoachingRubric(options: {
  apiKey: string;
  hand: LiveHandDefinition;
  state: LiveHandState;
  legalActions: LiveLegalAction[];
  publicHistory: LiveActionEvent[];
  intelligence?: CoachIntelligenceConfig;
  fetchImpl?: typeof fetch;
}): Promise<CoachingRubricResult> {
  const facts = buildCoachingFacts(options);
  assertFairCoachingFacts(facts);
  return generateCoachingRubricFromFacts({
    apiKey: options.apiKey,
    facts,
    stateHash: hashLiveState(options.state, options.publicHistory),
    intelligence: options.intelligence,
    fetchImpl: options.fetchImpl,
  });
}

/**
 * Runs the production draft/critique pipeline for a fair-information fact set.
 *
 * Exported so the versioned benchmark exercises the exact production prompt,
 * schema, parser, and critic instead of a simplified test-only imitation.
 * Benchmarks may override model id and thinking levels via `intelligence`.
 */
export async function generateCoachingRubricFromFacts(options: {
  apiKey: string;
  facts: CoachingFacts;
  stateHash: string;
  intelligence?: CoachIntelligenceConfig;
  fetchImpl?: typeof fetch;
}): Promise<CoachingRubricResult> {
  const facts = options.facts;
  assertFairCoachingFacts(facts);
  const intelligence = options.intelligence ?? DEFAULT_COACH_INTELLIGENCE;
  const fetchImpl = options.fetchImpl ?? fetch;
  const schema = coachingSchema(facts.legalActions);
  let usage = emptyLiveUsageBreakdown();
  try {
    const draft = await callGeminiJson({
      apiKey: options.apiKey,
      system: coachSystemPrompt(),
      user: JSON.stringify({task: "draft", facts}),
      schema,
      thinkingLevel: intelligence.draftThinking,
      purpose: "coach_draft",
      modelId: intelligence.modelId,
      fetchImpl,
    });
    usage = addLiveUsage(usage, draft.usage);
    const corrected = await callGeminiJson({
      apiKey: options.apiKey,
      system: [
        coachSystemPrompt(),
        "You are now the adversarial critic. Correct unsupported certainty,",
        "generic archetype stereotypes, invented statistics, mathematical",
        "contradictions, inconsistent action rankings, and outcome-oriented",
        "reasoning. Preserve every legal action exactly once. Return the complete",
        "corrected assessments array only in the required JSON object.",
      ].join(" "),
      user: JSON.stringify({task: "critique", facts, draft: draft.value}),
      schema,
      thinkingLevel: intelligence.criticThinking,
      purpose: "coach_critique",
      modelId: intelligence.modelId,
      fetchImpl,
    });
    usage = addLiveUsage(usage, corrected.usage);
    const assessments = parseAssessments(
      corrected.value,
      facts.legalActions,
      facts,
    );
    return {
      rubric: {
        schemaVersion: COACHING_SCHEMA_VERSION,
        stateHash: options.stateHash,
        assessments,
        generatedBy: intelligence.modelId,
        criticModel: intelligence.modelId,
      },
      usage,
    };
  } catch (error) {
    throw new LiveUsageError(
      error instanceof Error ? error.message : String(error),
      addLiveUsage(usage, liveUsageFromError(error)),
    );
  }
}

/** Returns only the chosen action's already-generated coaching. */
export function assessmentForAction(
  rubric: CoachingRubric,
  actionId: string,
): CoachingActionAssessment {
  const assessment = rubric.assessments.find(
    (candidate) => candidate.actionId === actionId,
  );
  if (!assessment) throw new Error(`coaching missing action ${actionId}`);
  return assessment;
}

function coachSystemPrompt(): string {
  return [
    "You are an exploitative live No-Limit Hold'em coach, not a GTO solver.",
    "Evaluate every supplied legal action together before the user chooses.",
    "Mark exactly one action recommended; use strong or reasonable for other",
    "good alternatives so the recommendation cannot contradict itself.",
    "Anchor advice in sound poker fundamentals, then make only justified",
    "deviations tied to the visible bounded opponent tendencies.",
    "Never use actual opponent cards, unrevealed board cards, or outcomes.",
    "The supplied pot odds, profile-range equity estimate, SPR, stacks,",
    "position, heroFeatures, actions, and legal sizings are authoritative;",
    "do not recalculate or contradict them. Never relabel a trips/set hand",
    "as a pair, or a top-pair hand as second-pair. Equity is an estimate",
    "against modeled ranges, never the opponents' actual cards.",
    "Against low-aggression or underbluffing profiles, treat voluntary bets as",
    "value-dense. Against calling stations, value bet thinly when checked to,",
    "but do not turn a weak bluff-catcher into a value raise when they show",
    "rare aggression. Do not recommend an all-in with a medium-strength hand",
    "unless stack-to-pot ratio and modeled equity clearly justify it.",
    "A weak or middle pair facing voluntary postflop aggression from a Nit or",
    "Calling Station is usually a fold unless the supplied range equity and",
    "price clearly support continuing. Prefer bluff-catching over raising",
    "medium hands against aggressive profiles.",
    "Do not invent population statistics or exact EV. Multiple actions may be",
    "reasonable. Use low confidence when ranges or reads do not justify a",
    "strong verdict. Every tendencyKeys value must name a supplied profile",
    "field, and every assessment must cite at least one relevant tendency key.",
    "A standard legal alternative should not be called a high-confidence clear",
    "mistake merely because another size is preferred; use questionable when",
    "the strategic difference is uncertain. Keep each explanation concise and",
    "actionable. Never assign high confidence to the recommendation when a",
    "relevant visible tendency profile itself has only medium confidence.",
    "Return JSON only.",
  ].join(" ");
}

function coachingSchema(actions: LiveLegalAction[]): Record<string, unknown> {
  return {
    type: "object",
    additionalProperties: false,
    properties: {
      assessments: {
        type: "array",
        minItems: actions.length,
        maxItems: actions.length,
        items: {
          type: "object",
          additionalProperties: false,
          properties: {
            actionId: {
              type: "string",
              enum: actions.map((action) => action.actionId),
            },
            rating: {
              type: "string",
              enum: [
                "recommended",
                "strong",
                "reasonable",
                "questionable",
                "clear_mistake",
              ],
            },
            confidence: {
              type: "string",
              enum: ["low", "medium", "high"],
            },
            summary: {type: "string", minLength: 1, maxLength: 320},
            playerTypeReason: {type: "string", minLength: 1, maxLength: 320},
            sizingNote: {type: "string", minLength: 1, maxLength: 240},
            betterActionId: {
              type: "string",
              enum: actions.map((action) => action.actionId),
            },
            reversalRead: {type: "string", maxLength: 240},
            tendencyKeys: {
              type: "array",
              minItems: 1,
              items: {type: "string", enum: [...TENDENCY_KEYS]},
            },
          },
          required: [
            "actionId",
            "rating",
            "confidence",
            "summary",
            "playerTypeReason",
            "sizingNote",
            "tendencyKeys",
          ],
        },
      },
    },
    required: ["assessments"],
  };
}

function parseAssessments(
  raw: unknown,
  actions: LiveLegalAction[],
  facts: CoachingFacts,
): CoachingActionAssessment[] {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new Error("coaching response must be an object");
  }
  const assessments = (raw as {assessments?: unknown}).assessments;
  if (!Array.isArray(assessments) || assessments.length !== actions.length) {
    throw new Error("coaching must assess every legal action exactly once");
  }
  const parsed = assessments as CoachingActionAssessment[];
  const ids = parsed.map((assessment) => assessment.actionId);
  if (
    new Set(ids).size !== actions.length ||
    actions.some((action) => !ids.includes(action.actionId))
  ) {
    throw new Error("coaching action ids do not match legal action ids");
  }
  if (
    parsed.filter((assessment) => assessment.rating === "recommended").length !==
    1
  ) {
    throw new Error("coaching must identify exactly one recommended action");
  }
  for (const assessment of parsed) {
    if (
      assessment.tendencyKeys.length === 0 ||
      assessment.tendencyKeys.some((key) => !TENDENCY_KEYS.has(key)) ||
      (assessment.rating === "clear_mistake" &&
        assessment.confidence === "high" &&
        !assessment.betterActionId)
    ) {
      throw new Error(`invalid coaching assessment ${assessment.actionId}`);
    }
    if (
      assessment.betterActionId &&
      !actions.some((action) => action.actionId === assessment.betterActionId)
    ) {
      throw new Error("betterActionId must be legal");
    }
  }
  // Accessing facts here makes the validation boundary explicit and prevents
  // future callers from parsing a rubric without fair-information context.
  assertFairCoachingFacts(facts);
  return parsed;
}

async function callGeminiJson(options: {
  apiKey: string;
  system: string;
  user: string;
  schema: Record<string, unknown>;
  thinkingLevel: GeminiThinkingLevel;
  purpose: "villain" | "coach_draft" | "coach_critique";
  modelId: string;
  fetchImpl: typeof fetch;
}): Promise<{value: unknown; usage: LiveUsageBreakdown}> {
  const modelId = options.modelId.trim() || LIVE_INTELLIGENCE_MODEL;
  const url =
    "https://generativelanguage.googleapis.com/v1beta/models/" +
    `${modelId}:generateContent?key=` +
    encodeURIComponent(options.apiKey);
  const requestBody = JSON.stringify({
    system_instruction: {parts: [{text: options.system}]},
    contents: [{role: "user", parts: [{text: options.user}]}],
    generationConfig: {
      responseMimeType: "application/json",
      responseJsonSchema: options.schema,
      thinkingConfig: {thinkingLevel: options.thinkingLevel},
    },
  });
  let response: Response | null = null;
  const startedMs = Date.now();
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      response = await options.fetchImpl(url, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: requestBody,
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
        `Gemini intelligence HTTP ${response.status}: ` +
          text.split(options.apiKey).join("[REDACTED]"),
      );
    }
    await delay(500 * 2 ** attempt);
  }
  if (!response?.ok) throw new Error("Gemini intelligence request failed");
  const json = await response.json() as Record<string, unknown>;
  const durationMs = Date.now() - startedMs;
  const usage = liveUsageFromPurpose(
    generationUsageFromMetadata(
      json.usageMetadata as GeminiUsageMetadata | undefined,
      Date.now(),
      modelId,
    ),
    options.purpose,
    durationMs,
  );
  const text = extractText(json);
  if (!text) {
    throw new LiveUsageError(
      "Gemini intelligence returned empty text",
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
      `Gemini intelligence returned invalid JSON: ${message}`,
      usage,
    );
  }
}

function delay(milliseconds: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

function extractText(response: Record<string, unknown>): string | null {
  const candidates = response.candidates;
  if (!Array.isArray(candidates) || candidates.length === 0) return null;
  const first = candidates[0] as {content?: {parts?: unknown[]}};
  const parts = first.content?.parts;
  if (!Array.isArray(parts)) return null;
  const output = parts
    .map((part) =>
      part && typeof part === "object" && "text" in part ?
        String((part as {text: unknown}).text) :
        "",
    )
    .join("")
    .trim();
  return output || null;
}
