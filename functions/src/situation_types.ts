/**
 * Server-authored branching situation schema (payloadVersion 2).
 *
 * Situations always start preflop. Hero nodes carry curated legal action
 * choices with general (non-user-specific) coaching. Scripted interstitial
 * nodes advance villain actions between hero decisions.
 */

import type {GenerationUsage} from "./generation_usage";

/** Current published payload version. */
export const PAYLOAD_VERSION = 2 as const;

/** Gemini model used for generation and critique. */
export const GEMINI_MODEL_ID = "gemini-3.8-flash" as const;

/** Schema / prompt version stamped on published docs for auditability. */
export const SITUATION_SCHEMA_VERSION = "situation-v2.2";

/** Pool generation batch sizes (configurable constants). */
export const INITIAL_POOL_SIZE = 5;
export const REFILL_BATCH_SIZE = 5;
/**
 * Empty-pool first wave: generate this many ASAP so the client can allocate
 * before the rest of [INITIAL_POOL_SIZE] finishes.
 */
export const ASAP_INITIAL_COUNT = 2;
/** Trigger refill when globally never-served remaining reaches this count. */
export const NEVER_SERVED_LOW_WATER = 3;

/** Generation lease TTL in milliseconds (covers a full two-pass batch). */
export const GENERATION_LEASE_MS = 600_000;

/** Allowed villain archetypes (excludes hero). */
export const VILLAIN_ARCHETYPES = [
  "MANIAC",
  "NIT",
  "CALLING_STATION",
  "TAG",
  "LAG",
] as const;

export type VillainArchetype = (typeof VILLAIN_ARCHETYPES)[number];

export type SetupMode = "random" | "custom";

export type Street = "preflop" | "flop" | "turn" | "river";

export type HeroActionKind =
  "FOLD" | "CHECK" | "CALL" | "BET" | "RAISE" | "ALL_IN";

/** Standard sizing buckets for curated BET/RAISE choices. */
export const SIZING_BUCKETS = [
  "MIN",
  "33",
  "50",
  "67",
  "75",
  "100",
  "125",
  "150",
  "200",
  "ALL_IN",
] as const;

export type SizingBucket = (typeof SIZING_BUCKETS)[number];

/** One seat in the ordered lineup. */
export interface SeatLineup {
  seat: number;
  archetype: VillainArchetype | "HERO";
  name: string;
  /** Starting stack in chips for this hand (usually equals setup startingStack). */
  startingStack: number;
}

/** Fixed runout cards revealed when a street is reached. */
export interface StreetRunout {
  street: Exclude<Street, "preflop">;
  cards: string[];
}

/** Authored private cards for one seat. */
export interface SeatHoleCards {
  seat: number;
  cards: [string, string];
}

/** Edge from a hero decision node. */
export interface HeroActionEdge {
  /** Stable key within the node, e.g. FOLD, CALL, BET_67, RAISE_100. */
  actionKey: string;
  kind: HeroActionKind;
  /**
   * Total chips committed on this street after the action ("raise to"),
   * required for BET / RAISE / ALL_IN / CALL when chips are added.
   */
  amountTo?: number;
  sizingBucket?: SizingBucket;
  /** General coaching for taking this action at this node. */
  coaching: string;
  /** Explicit server-authored assessment used for grading. */
  verdict: "correct" | "incorrect" | "close";
  /**
   * Strategic EV estimate in big blinds relative to the best action.
   * Correct/best lines are 0; alternatives are non-positive.
   */
  evDeltaBb: number;
  /** Action key of a correct edge in this same hero node. */
  optimalActionKey: string;
  nextNodeId: string;
}

/** Scripted villain (or blind) action between hero nodes. */
export interface ScriptedAction {
  seat: number;
  kind: HeroActionKind | "POST_SB" | "POST_BB" | "POST_ANTE";
  amountTo?: number;
  /** Optional narrative label for UI. */
  label?: string;
}

export interface HeroDecisionNode {
  type: "hero";
  id: string;
  street: Street;
  /** Pot after prior actions, before hero acts. */
  pot: number;
  /** Remaining stacks by seat index. */
  stacks: number[];
  /** Street commitments by seat index. */
  streetBets: number[];
  /** Board cards visible at this decision. */
  board: string[];
  foldedSeats: number[];
  toAct: number;
  /** Facing amount to call (0 when checked to / open action). */
  callAmount: number;
  minRaiseTo: number;
  actions: HeroActionEdge[];
}

export interface ScriptedNode {
  type: "scripted";
  id: string;
  street: Street;
  pot: number;
  stacks: number[];
  streetBets: number[];
  board: string[];
  foldedSeats: number[];
  actions: ScriptedAction[];
  nextNodeId: string;
}

export interface TerminalNode {
  type: "terminal";
  id: string;
  reason: "fold" | "showdown" | "all_in_runout";
  street: Street;
  board: string[];
  foldedSeats: number[];
  /** Chips behind by seat immediately before awarding the terminal pot. */
  stacks: number[];
  pot: number;
  /**
   * Unique seat indexes sharing the pot (side pots unsupported). Payouts are
   * cent-exact by ascending seat id, with odd cents going to earliest seats.
   */
  winnerSeats: number[];
  /** Validated hero chip delta for this terminal (positive = win). */
  heroNetChips: number;
  summary?: string;
}

export type SituationNode = HeroDecisionNode | ScriptedNode | TerminalNode;

/**
 * Validated branching situation payload stored under
 * `tableSetups/{setupKey}/situations/{situationId}`.
 */
export interface SituationPayload {
  payloadVersion: typeof PAYLOAD_VERSION;
  schemaVersion: string;
  setupKey: string;
  setupMode: SetupMode;
  seatCount: number;
  smallBlind: number;
  bigBlind: number;
  ante: number;
  startingStack: number;
  buttonSeat: number;
  heroSeat: number;
  lineup: SeatLineup[];
  holeCards: SeatHoleCards[];
  heroHand: [string, string];
  /** Fixed boards for flop/turn/river when those streets are reached. */
  runouts: StreetRunout[];
  rootNodeId: string;
  nodes: Record<string, SituationNode>;
  /** Short human title. */
  title?: string;
}

/** Canonical table setup request from the client. */
export interface TableSetupInput {
  mode: SetupMode;
  seatCount: number;
  smallBlind: number;
  bigBlind: number;
  ante?: number;
  /** Starting stack in chips. */
  startingStack: number;
  /** Required for custom; ignored for random (situation carries lineup). */
  buttonSeat?: number;
  heroSeat?: number;
  /** Ordered seat archetypes including HERO — custom only. */
  lineup?: Array<{
    seat: number;
    archetype: string;
    name?: string;
  }>;
}

/** Firestore doc at `tableSetups/{setupKey}`. */
export interface TableSetupDoc {
  setupKey: string;
  mode: SetupMode;
  seatCount: number;
  smallBlind: number;
  bigBlind: number;
  ante: number;
  startingStack: number;
  /** Custom-only fingerprint fields. */
  buttonSeat?: number;
  heroSeat?: number;
  lineupArchetypes?: string[];
  lineup?: TableSetupInput["lineup"];
  situationCount: number;
  neverServedCount: number;
  generation?: GenerationLeaseState;
  generationMetrics?: GenerationMetrics;
  createdAt?: unknown;
  updatedAt?: unknown;
}

/** Aggregate model usage for one table setup. */
export interface GenerationMetrics extends GenerationUsage {
  completedRunCount: number;
  successfulRunCount: number;
  failedRunCount: number;
  publishedSituationCount: number;
}

export interface GenerationLeaseState {
  status: "queued" | "generating" | "idle";
  leaseId: string | null;
  leaseExpiresAtMs: number | null;
  lastBatchSize: number;
  lastError?: string | null;
  requestedAt?: unknown;
  requestReason?: PoolRefillReason | null;
}

export type PoolRefillReason = "empty" | "exhausted" | "low-water";

/** Firestore doc at `tableSetups/{setupKey}/situations/{situationId}`. */
export interface SituationDoc {
  situationId: string;
  setupKey: string;
  payload: SituationPayload;
  payloadVersion: number;
  schemaVersion: string;
  source: "gemini";
  modelId: string;
  generationRunId: string;
  generationUsage: GenerationUsage;
  validationFailureCount: number;
  contentHash: string;
  timesServed: number;
  generatedAt: unknown;
  validation: {
    ok: true;
    checkedAt: unknown;
  };
}

/** One auditable generation job under a table setup. */
export interface GenerationRunDoc {
  runId: string;
  setupKey: string;
  modelId: string;
  status: "published" | "duplicate" | "failed";
  usage: GenerationUsage;
  validationFailureCount: number;
  error?: string;
  createdAt: unknown;
}

/** Receipt allocated atomically when a situation is served. */
export interface SituationReceiptDoc {
  situationId: string;
  setupKey: string;
  status: "allocated" | "completed";
  allocatedAt: unknown;
  completedAt?: unknown;
  pathNodeIds?: string[];
  chosenActionKeys?: string[];
  heroNetChips?: number;
  heroNetBb?: number;
  grading?: GradingSummary;
}

/** Progress recording request from the client. */
export interface RecordProgressInput {
  situationId: string;
  setupKey: string;
  /** Ordered hero node ids visited. */
  pathNodeIds: string[];
  /** Action keys chosen at each hero node (parallel to pathNodeIds). */
  chosenActionKeys: string[];
  /** Final terminal node id. */
  terminalNodeId: string;
  /** @deprecated Server derives this from the terminal node. */
  heroNetChips?: number;
  /** Optional per-action timestamps / notes. */
  notes?: string;
}

/** Aggregate progress stored at `users/{uid}/progress/main`. */
export interface ProgressAggregateDoc {
  handsPlayed: number;
  handsCompleted: number;
  netEvBb: number;
  netResultBb: number;
  correctSpots: number;
  totalSpots: number;
  streetAccuracy: Record<string, { played: number; correct: number }>;
  archetypeAccuracy: Record<
    string,
    { played: number; correct: number; evBb: number }
  >;
  recentEvDeltas: number[];
  updatedAt: unknown;
}

/** Server-derived grading for one completed situation. */
export interface GradingSummary {
  decisionCount: number;
  correctCount: number;
  totalEvDeltaBb: number;
  streetStats: Record<
    string,
    { decisionCount: number; correctCount: number; evDeltaBb: number }
  >;
  chosenActionKinds: HeroActionKind[];
}

/** Chronological action entry written to a hand history document. */
export interface HandHistoryAction {
  seat: number;
  street: Street;
  kind: HeroActionKind | "POST_SB" | "POST_BB" | "POST_ANTE";
  /** Total amount committed on the street, expressed in big blinds. */
  amountBb: number;
  isHero: boolean;
  archetype: VillainArchetype | "HERO";
}
