/**
 * Version-three live training contracts.
 *
 * A hand definition owns immutable private cards, runout, lineup, and bounded
 * tendency profiles. Hand sessions and shared tree nodes contain authoritative
 * poker state derived from that definition; clients receive only projected
 * views that exclude unrevealed cards and future board cards.
 */

import type {VillainArchetype} from "./situation_types";

/** Current live-hand payload version. */
export const LIVE_PAYLOAD_VERSION = 3 as const;

/** Version for the bounded exploit tendency templates. */
export const TENDENCY_PROFILE_VERSION = "tendencies-v1";

/** Version for the qualitative coaching contract. */
export const COACHING_SCHEMA_VERSION = "exploit-coach-v1";

/** Pool inventory policy. */
export const LIVE_INITIAL_POOL_SIZE = 10;
export const LIVE_REFILL_BATCH_SIZE = 10;
export const LIVE_UNSEEN_LOW_WATER = 5;

/** Root continuations warmed before a hand can be marked ready. */
export const LIVE_WARM_BRANCH_COUNT = 3;

export type LiveStreet = "preflop" | "flop" | "turn" | "river";

export type LiveActionKind =
  "FOLD" | "CHECK" | "CALL" | "BET" | "RAISE" | "ALL_IN";

export type LiveActionBucket =
  "CHECK" |
  "FOLD" |
  "CALL" |
  "OPEN_2_5_BB" |
  "OPEN_3_BB" |
  "OPEN_4_BB" |
  "BET_33" |
  "BET_67" |
  "BET_100" |
  "RAISE_MIN" |
  "RAISE_50" |
  "RAISE_100" |
  "RERAISE_3X" |
  "RERAISE_4X" |
  "ALL_IN";

/** Canonical setup shared by a pool of independently generated hands. */
export interface LiveTableSetup {
  mode: "random";
  seatCount: number;
  smallBlind: number;
  bigBlind: number;
  maxStackDepthBb: number;
  heroSeat: number;
}

/** Bounded modeled tendencies shown to the user on demand. */
export interface TendencyProfile {
  profileVersion: typeof TENDENCY_PROFILE_VERSION;
  archetype: VillainArchetype;
  vpip: number;
  pfr: number;
  threeBet: number;
  aggression: number;
  foldToFlopBet: number;
  foldToTurnBet: number;
  foldToRiverBet: number;
  bluffRiver: number;
  showdownCall: number;
  sizingTellStrength: number;
  confidence: "medium" | "high";
  reads: string[];
}

/** One immutable seat in a generated live hand. */
export interface LiveSeatDefinition {
  seat: number;
  name: string;
  archetype: VillainArchetype | "HERO";
  startingStack: number;
  holeCards: [string, string];
  tendency?: TendencyProfile;
}

/**
 * Immutable server-only hand definition.
 *
 * The client never receives all seats' cards or unrevealed runout entries.
 */
export interface LiveHandDefinition {
  payloadVersion: typeof LIVE_PAYLOAD_VERSION;
  schemaVersion: string;
  handId: string;
  setupKey: string;
  setup: LiveTableSetup;
  buttonSeat: number;
  seats: LiveSeatDefinition[];
  runout: [string, string, string, string, string];
  source: "gemini";
  modelId: string;
}

/** Mutable authoritative state for one node in a shared hand tree. */
export interface LivePlayerState {
  seat: number;
  stack: number;
  streetBet: number;
  contribution: number;
  folded: boolean;
  allIn: boolean;
  acted: boolean;
  /** Highest street price this player faced when they last acted. */
  lastFacedBet: number;
  lastAction?: string;
}

export interface LivePotResult {
  amount: number;
  eligibleSeats: number[];
  winnerSeats: number[];
}

export interface LiveHandState {
  street: LiveStreet;
  board: string[];
  players: LivePlayerState[];
  actorSeat: number | null;
  highestBet: number;
  minRaiseIncrement: number;
  actionNumber: number;
  status: "playing" | "hero_folded" | "complete";
  terminalReason?: "fold" | "showdown";
  winnerSeats: number[];
  pots: LivePotResult[];
  payouts: Record<string, number>;
}

/** Fixed legal action returned by the authoritative engine. */
export interface LiveLegalAction {
  actionId: string;
  kind: LiveActionKind;
  bucket: LiveActionBucket;
  /** Total street commitment after acting. */
  amountTo?: number;
  label: string;
}

/** One applied action in a session or shared continuation. */
export interface LiveActionEvent {
  sequence: number;
  seat: number;
  street: LiveStreet;
  actionId: string;
  kind: LiveActionKind;
  bucket: LiveActionBucket;
  amountTo?: number;
}

export type CoachingRating =
  "recommended" | "strong" | "reasonable" | "questionable" | "clear_mistake";

export interface CoachingActionAssessment {
  actionId: string;
  rating: CoachingRating;
  confidence: "low" | "medium" | "high";
  summary: string;
  playerTypeReason: string;
  sizingNote: string;
  betterActionId?: string;
  reversalRead?: string;
  tendencyKeys: string[];
}

/** Hidden until the hero acts; generated for all choices at one node. */
export interface CoachingRubric {
  schemaVersion: typeof COACHING_SCHEMA_VERSION;
  stateHash: string;
  assessments: CoachingActionAssessment[];
  generatedBy: string;
  criticModel: string;
}

/** Client-safe seat state. */
export interface LiveSeatView {
  seat: number;
  name: string;
  archetype: VillainArchetype | "HERO";
  stack: number;
  streetBet: number;
  folded: boolean;
  allIn: boolean;
  lastAction?: string;
  holeCards?: [string, string];
  tendency?: TendencyProfile;
}

/** Client projection returned at a hero decision or terminal. */
export interface LiveHandView {
  sessionId: string;
  handId: string;
  setupKey: string;
  decisionId: string;
  stateVersion: number;
  smallBlind: number;
  bigBlind: number;
  street: LiveStreet;
  board: string[];
  pot: number;
  buttonSeat: number;
  heroSeat: number;
  actorSeat: number | null;
  status: LiveHandState["status"];
  terminalReason?: LiveHandState["terminalReason"];
  seats: LiveSeatView[];
  legalActions: LiveLegalAction[];
  winnerSeats: number[];
  pots: LivePotResult[];
}

export interface StartLiveHandInput {
  tableSetup: unknown;
  clientVersion: string;
}

export interface StartLiveHandResult {
  ok: true;
  view: LiveHandView;
  events: LiveActionEvent[];
}

export interface SubmitLiveActionInput {
  sessionId: string;
  handId: string;
  stateVersion: number;
  decisionId: string;
  idempotencyKey: string;
  actionId: string;
}

export interface SubmitLiveActionResult {
  ok: true;
  view: LiveHandView;
  events: LiveActionEvent[];
  coaching: CoachingActionAssessment;
  replayed: boolean;
}
