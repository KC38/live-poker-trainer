/**
 * Gemini-backed immutable deal generation for live training.
 *
 * Product code, not Gemini, chooses the ordered random lineup and bounded
 * tendencies. Gemini receives that visible lineup and authors only button,
 * varied stacks, private cards, and a fixed five-card runout.
 */

import {createHash} from "node:crypto";
import {
  generationUsageFromMetadata,
  type GeminiUsageMetadata,
} from "./generation_usage";
import {
  liveUsageFromPurpose,
  LiveUsageError,
  type LiveUsageBreakdown,
} from "./live_usage";
import {isValidCard, normalizeCard} from "./setup_key";
import {generateTendencyProfile} from "./tendency_profiles";
import {
  LIVE_PAYLOAD_VERSION,
  type LiveHandDefinition,
  type LiveSeatDefinition,
  type LiveTableSetup,
} from "./live_types";
import type {VillainArchetype} from "./situation_types";

export const LIVE_HAND_SCHEMA_VERSION = "live-hand-v3.0";
export const LIVE_GEMINI_MODEL = "gemini-3.8-flash";

const ARCHETYPE_BAG: VillainArchetype[] = [
  "CALLING_STATION",
  "TAG",
  "LAG",
  "NIT",
  "MANIAC",
  "CALLING_STATION",
  "TAG",
  "LAG",
];

const NAMES: Record<VillainArchetype, string[]> = {
  CALLING_STATION: ["Fred", "Paul", "Gus", "Dale"],
  TAG: ["Alex", "Nina", "Ivy", "Cole"],
  LAG: ["Sammy", "Rex", "Maya", "Jade"],
  NIT: ["Stan", "Ned", "Otto", "Carl"],
  MANIAC: ["Viktor", "Rico", "Blitz", "Chaos"],
};

interface GeminiDeal {
  buttonSeat: number;
  stacks: Array<{seat: number; startingStack: number}>;
  holeCards: Array<{seat: number; cards: [string, string]}>;
  runout: [string, string, string, string, string];
}

/** Deal generation result with billable Gemini usage. */
export interface GeneratedLiveHand {
  hand: LiveHandDefinition;
  usage: LiveUsageBreakdown;
}

/** Generates and validates one complete server-only live hand definition. */
export async function generateLiveHandDefinition(options: {
  apiKey: string;
  setup: LiveTableSetup;
  setupKey: string;
  variationSeed: string;
  fetchImpl?: typeof fetch;
}): Promise<GeneratedLiveHand> {
  const lineup = buildRandomLiveLineup(options.setup, options.variationSeed);
  const response = await callGeminiDeal({
    apiKey: options.apiKey,
    setup: options.setup,
    lineup,
    variationSeed: options.variationSeed,
    fetchImpl: options.fetchImpl ?? fetch,
  });
  const hand = normalizeLiveHand({
    setup: options.setup,
    setupKey: options.setupKey,
    lineup,
    deal: response.deal,
  });
  const issues = validateLiveHandDefinition(hand);
  if (issues.length > 0) {
    throw new LiveUsageError(
      `invalid live hand: ${issues.join("; ")}`,
      response.usage,
    );
  }
  return {hand, usage: response.usage};
}

/** Deterministically creates a fresh ordered lineup for one generated hand. */
export function buildRandomLiveLineup(
  setup: LiveTableSetup,
  seed: string,
): Omit<LiveSeatDefinition, "startingStack" | "holeCards">[] {
  const usedNames = new Set<string>(["Hero"]);
  const seats: Omit<LiveSeatDefinition, "startingStack" | "holeCards">[] = [];
  for (let seat = 0; seat < setup.seatCount; seat++) {
    if (seat === setup.heroSeat) {
      seats.push({seat, name: "Hero", archetype: "HERO"});
      continue;
    }
    const archetype = ARCHETYPE_BAG[
      deterministicIndex(`${seed}:archetype:${seat}`, ARCHETYPE_BAG.length)
    ];
    const names = NAMES[archetype];
    const start = deterministicIndex(`${seed}:name:${seat}`, names.length);
    let name = names[start];
    for (let offset = 1; usedNames.has(name) && offset < names.length; offset++) {
      name = names[(start + offset) % names.length];
    }
    if (usedNames.has(name)) {
      name = `${archetype.replaceAll("_", " ")} ${seat + 1}`;
    }
    usedNames.add(name);
    seats.push({
      seat,
      name,
      archetype,
      tendency: generateTendencyProfile(archetype, `${seed}:seat:${seat}`),
    });
  }
  return seats;
}

/** Strict deterministic validation before a hand can enter a ready pool. */
export function validateLiveHandDefinition(
  hand: LiveHandDefinition,
): string[] {
  const issues: string[] = [];
  const {setup} = hand;
  if (hand.payloadVersion !== LIVE_PAYLOAD_VERSION) {
    issues.push(`payloadVersion must be ${LIVE_PAYLOAD_VERSION}`);
  }
  if (
    !Number.isInteger(hand.buttonSeat) ||
    hand.buttonSeat < 0 ||
    hand.buttonSeat >= setup.seatCount
  ) {
    issues.push("buttonSeat out of range");
  }
  if (hand.seats.length !== setup.seatCount) {
    issues.push("seat count mismatch");
  }
  const cards: string[] = [];
  for (let seat = 0; seat < setup.seatCount; seat++) {
    const entry = hand.seats.find((candidate) => candidate.seat === seat);
    if (!entry) {
      issues.push(`missing seat ${seat}`);
      continue;
    }
    const minStack = 20 * setup.bigBlind;
    const maxStack = setup.maxStackDepthBb * setup.bigBlind;
    if (
      !Number.isFinite(entry.startingStack) ||
      entry.startingStack < minStack ||
      entry.startingStack > maxStack
    ) {
      issues.push(`seat ${seat} stack outside 20..max BB`);
    }
    if (entry.holeCards.length !== 2) {
      issues.push(`seat ${seat} needs two cards`);
    }
    cards.push(...entry.holeCards);
    if (seat === setup.heroSeat && entry.archetype !== "HERO") {
      issues.push("hero seat must use HERO archetype");
    }
    if (seat !== setup.heroSeat && entry.archetype === "HERO") {
      issues.push(`villain seat ${seat} cannot use HERO archetype`);
    }
  }
  if (hand.runout.length !== 5) issues.push("runout must contain five cards");
  cards.push(...hand.runout);
  for (const card of cards) {
    if (!isValidCard(card)) issues.push(`invalid card ${card}`);
  }
  if (new Set(cards.map(normalizeCard)).size !== cards.length) {
    issues.push("hole cards and runout must be globally unique");
  }
  return issues;
}

function normalizeLiveHand(options: {
  setup: LiveTableSetup;
  setupKey: string;
  lineup: Omit<LiveSeatDefinition, "startingStack" | "holeCards">[];
  deal: GeminiDeal;
}): LiveHandDefinition {
  const cardsBySeat = new Map(
    options.deal.holeCards.map((entry) => [
      entry.seat,
      entry.cards.map(normalizeCard) as [string, string],
    ]),
  );
  const stacksBySeat = new Map(
    options.deal.stacks.map((entry) => [
      entry.seat,
      snapStack(entry.startingStack, options.setup.smallBlind),
    ]),
  );
  const seats: LiveSeatDefinition[] = options.lineup.map((seat) => ({
    ...seat,
    startingStack: stacksBySeat.get(seat.seat) ?? 0,
    holeCards: cardsBySeat.get(seat.seat) ?? ["", ""],
  }));
  const normalized = {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: LIVE_HAND_SCHEMA_VERSION,
    setupKey: options.setupKey,
    setup: options.setup,
    buttonSeat: options.deal.buttonSeat,
    seats,
    runout: options.deal.runout.map(normalizeCard) as [
      string,
      string,
      string,
      string,
      string,
    ],
    source: "gemini" as const,
    modelId: LIVE_GEMINI_MODEL,
  };
  const content = JSON.stringify(normalized);
  return {
    ...normalized,
    handId: createHash("sha256").update(content).digest("hex").slice(0, 32),
  };
}

async function callGeminiDeal(options: {
  apiKey: string;
  setup: LiveTableSetup;
  lineup: Omit<LiveSeatDefinition, "startingStack" | "holeCards">[];
  variationSeed: string;
  fetchImpl: typeof fetch;
}): Promise<{deal: GeminiDeal; usage: LiveUsageBreakdown}> {
  const url =
    "https://generativelanguage.googleapis.com/v1beta/models/" +
    `${LIVE_GEMINI_MODEL}:generateContent?key=${encodeURIComponent(options.apiKey)}`;
  const minStack = 20 * options.setup.bigBlind;
  const maxStack = options.setup.maxStackDepthBb * options.setup.bigBlind;
  const system = [
    "Author one strategically interesting live No-Limit Hold'em cash-game deal.",
    "Output only JSON matching the schema.",
    "Choose the button, every starting stack, every private hand, and one fixed",
    "five-card runout. Do not author actions, coaching, branches, or winners.",
    `Every stack must be from ${minStack} through ${maxStack},`,
    "a whole multiple of the small blind, with no cents,",
    "with Hero usually at least 80 BB when the configured maximum permits it,",
    "and a realistic weighted mix of villain stacks. Every card must be unique.",
    "Do not include rake, straddles, bomb",
    "pots, run-it-twice, or tournament concepts.",
  ].join(" ");
  const body = {
    system_instruction: {parts: [{text: system}]},
    contents: [{
      role: "user",
      parts: [{
        text: JSON.stringify({
          variationSeed: options.variationSeed,
          setup: options.setup,
          orderedLineup: options.lineup.map((seat) => ({
            seat: seat.seat,
            name: seat.name,
            archetype: seat.archetype,
            tendency: seat.tendency,
          })),
        }),
      }],
    }],
    generationConfig: {
      responseMimeType: "application/json",
      responseJsonSchema: dealSchema(options.setup.seatCount),
      thinkingConfig: {thinkingLevel: "medium"},
    },
  };
  let response: Response | null = null;
  const startedMs = Date.now();
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      response = await options.fetchImpl(url, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(body),
      });
    } catch (error) {
      if (attempt === 2) throw error;
      await new Promise((resolve) => setTimeout(resolve, 500 * 2 ** attempt));
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
        `Gemini deal HTTP ${response.status}: ${redact(text, options.apiKey)}`,
      );
    }
    await new Promise((resolve) => setTimeout(resolve, 500 * 2 ** attempt));
  }
  if (!response?.ok) throw new Error("Gemini deal request failed");
  const json = await response.json() as Record<string, unknown>;
  const durationMs = Date.now() - startedMs;
  const usage = liveUsageFromPurpose(
    generationUsageFromMetadata(
      json.usageMetadata as GeminiUsageMetadata | undefined,
    ),
    "deal",
    durationMs,
  );
  const text = extractGeminiText(json);
  if (!text) {
    throw new LiveUsageError("Gemini returned an empty deal", usage);
  }
  try {
    return {
      deal: JSON.parse(stripFences(text)) as GeminiDeal,
      usage,
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new LiveUsageError(`Gemini returned invalid deal JSON: ${message}`, usage);
  }
}

function dealSchema(seatCount: number): Record<string, unknown> {
  return {
    type: "object",
    additionalProperties: false,
    properties: {
      buttonSeat: {type: "integer", minimum: 0, maximum: seatCount - 1},
      stacks: {
        type: "array",
        minItems: seatCount,
        maxItems: seatCount,
        items: {
          type: "object",
          additionalProperties: false,
          properties: {
            seat: {type: "integer"},
            startingStack: {type: "number"},
          },
          required: ["seat", "startingStack"],
        },
      },
      holeCards: {
        type: "array",
        minItems: seatCount,
        maxItems: seatCount,
        items: {
          type: "object",
          additionalProperties: false,
          properties: {
            seat: {type: "integer"},
            cards: {
              type: "array",
              minItems: 2,
              maxItems: 2,
              items: {type: "string"},
            },
          },
          required: ["seat", "cards"],
        },
      },
      runout: {
        type: "array",
        minItems: 5,
        maxItems: 5,
        items: {type: "string"},
      },
    },
    required: ["buttonSeat", "stacks", "holeCards", "runout"],
  };
}

function extractGeminiText(response: Record<string, unknown>): string | null {
  const candidates = response.candidates;
  if (!Array.isArray(candidates) || candidates.length === 0) return null;
  const first = candidates[0] as {content?: {parts?: unknown[]}};
  const parts = first.content?.parts;
  if (!Array.isArray(parts)) return null;
  const text = parts
    .map((part) =>
      part && typeof part === "object" && "text" in part ?
        String((part as {text: unknown}).text) :
        "",
    )
    .join("")
    .trim();
  return text || null;
}

function stripFences(value: string): string {
  return value
    .trim()
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();
}

function deterministicIndex(seed: string, length: number): number {
  const digest = createHash("sha256").update(seed).digest();
  return digest.readUInt32BE(0) % length;
}

function money(value: number): number {
  return Math.round(value * 100) / 100;
}

/** Generated buy-ins are live chips, so cents from the model do not stick. */
function snapStack(amount: number, smallBlind: number): number {
  const unit = smallBlind > 0 ? smallBlind : 1;
  return money(Math.round(money(amount) / unit) * unit);
}

function redact(value: string, apiKey: string): string {
  return value.split(apiKey).join("[REDACTED]");
}
