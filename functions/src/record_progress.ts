/**
 * Authenticated recording of situation path / results.
 */

import {
  FieldValue,
  getFirestore,
  type Firestore,
} from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import { poolRefs } from "./pool";
import {
  emptyProgress,
  mergeProgressDelta,
  progressRef,
} from "./progress_stats";
import type {
  GradingSummary,
  HandHistoryAction,
  HeroActionEdge,
  HeroDecisionNode,
  ProgressAggregateDoc,
  RecordProgressInput,
  SituationPayload,
  TerminalNode,
} from "./situation_types";
import { deriveTerminalWinnerSeats } from "./validate_situation";
import { potShareForSeat } from "./payout";

export interface RecordProgressResult {
  ok: true;
  situationId: string;
  heroNetBb: number;
  grading: GradingSummary;
  alreadyCompleted: boolean;
}

export interface ValidatedTraversal {
  terminal: TerminalNode;
  chosenEdges: HeroActionEdge[];
  actions: HandHistoryAction[];
  grading: GradingSummary;
}

/**
 * Validates the client's path against the allocated situation and updates
 * receipt, hand history, and aggregate progress.
 */
export async function recordSituationProgressForUser(options: {
  uid: string;
  raw: unknown;
  db?: Firestore;
}): Promise<RecordProgressResult> {
  const db = options.db ?? getFirestore();
  const input = parseRecordInput(options.raw);
  const { uid } = options;

  const receiptRef = db
    .collection("users")
    .doc(uid)
    .collection("situationReceipts")
    .doc(input.situationId);

  const { situations } = poolRefs(db, input.setupKey);
  const situationRef = situations.doc(input.situationId);

  const handRef = db
    .collection("users")
    .doc(uid)
    .collection("handHistory")
    .doc(input.situationId);
  const aggregateRef = progressRef(db, uid);

  const result = await db.runTransaction(async (tx) => {
    const [receiptSnap, sitSnap, aggregateSnap] = await Promise.all([
      tx.get(receiptRef),
      tx.get(situationRef),
      tx.get(aggregateRef),
    ]);
    if (!receiptSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "No receipt for this situation — fetch it before recording progress.",
      );
    }
    const receipt = receiptSnap.data() ?? {};
    if (receipt.setupKey !== input.setupKey) {
      throw new HttpsError(
        "invalid-argument",
        "setupKey does not match the allocated receipt.",
      );
    }
    if (receipt.status === "completed") {
      return {
        ok: true as const,
        situationId: input.situationId,
        heroNetBb: Number(receipt.heroNetBb ?? 0),
        grading: isGradingSummary(receipt.grading)
          ? receipt.grading
          : emptyGrading(),
        alreadyCompleted: true,
      };
    }
    if (!sitSnap.exists) {
      throw new HttpsError(
        "not-found",
        "Situation no longer exists in the pool.",
      );
    }
    const payload = sitSnap.data()?.payload as SituationPayload | undefined;
    if (!payload) {
      throw new HttpsError("internal", "Situation payload missing.");
    }

    const traversal = validatePathAgainstSituation(payload, input);
    const bb = payload.bigBlind > 0 ? payload.bigBlind : 1;
    const heroNetChips = deriveTerminalHeroNetChips(
      payload,
      traversal.terminal,
    );
    const heroNetBb = heroNetChips / bb;
    const primaryArchetype = inferPrimaryVillain(payload, traversal.actions);
    const currentProgress =
      (aggregateSnap.data() as ProgressAggregateDoc | undefined) ??
      emptyProgress();
    const nextProgress = mergeProgressDelta(currentProgress, {
      heroNetBb,
      totalEvDeltaBb: traversal.grading.totalEvDeltaBb,
      archetype: primaryArchetype,
      decisionCount: traversal.grading.decisionCount,
      correctCount: traversal.grading.correctCount,
      streetStats: traversal.grading.streetStats,
    });

    tx.set(
      receiptRef,
      {
        status: "completed",
        completedAt: FieldValue.serverTimestamp(),
        pathNodeIds: input.pathNodeIds,
        chosenActionKeys: input.chosenActionKeys,
        terminalNodeId: input.terminalNodeId,
        heroNetChips,
        heroNetBb,
        grading: traversal.grading,
        notes: input.notes ?? null,
      },
      { merge: true },
    );
    tx.set(handRef, {
      situationId: input.situationId,
      setupKey: input.setupKey,
      pathNodeIds: input.pathNodeIds,
      chosenActionKeys: input.chosenActionKeys,
      terminalNodeId: input.terminalNodeId,
      heroSeat: payload.heroSeat,
      heroNetChips,
      heroNetBb,
      primaryArchetype,
      grading: traversal.grading,
      actions: traversal.actions,
      wentToShowdown:
        traversal.terminal.reason === "showdown" ||
        traversal.terminal.reason === "all_in_runout",
      heroWon: traversal.terminal.winnerSeats.includes(payload.heroSeat),
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(
      aggregateRef,
      {
        ...nextProgress,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return {
      ok: true as const,
      situationId: input.situationId,
      heroNetBb,
      grading: traversal.grading,
      alreadyCompleted: false,
    };
  });

  logger.info("recordSituationProgress completed", {
    uid,
    situationId: input.situationId,
    setupKey: input.setupKey,
    heroNetBb: result.heroNetBb,
    alreadyCompleted: result.alreadyCompleted,
  });
  return result;
}

/**
 * Ensures chosen actions exist on successive hero nodes and end at terminal.
 */
export function validatePathAgainstSituation(
  payload: SituationPayload,
  input: RecordProgressInput,
): ValidatedTraversal {
  if (input.pathNodeIds.length !== input.chosenActionKeys.length) {
    throw new HttpsError(
      "invalid-argument",
      "pathNodeIds and chosenActionKeys must be the same length.",
    );
  }
  if (input.pathNodeIds.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "At least one hero decision is required.",
    );
  }

  const terminal = payload.nodes[input.terminalNodeId];
  if (!terminal || terminal.type !== "terminal") {
    throw new HttpsError(
      "invalid-argument",
      "terminalNodeId must reference a terminal node.",
    );
  }

  // Walk from root following scripted auto-edges and claimed hero choices.
  let currentId = payload.rootNodeId;
  let heroStep = 0;
  const chosenEdges: HeroActionEdge[] = [];
  const actions: HandHistoryAction[] = [];
  const streetStats: GradingSummary["streetStats"] = {};
  const guard = Object.keys(payload.nodes).length + 5;
  let steps = 0;

  while (steps < guard) {
    steps += 1;
    const node = payload.nodes[currentId];
    if (!node) {
      throw new HttpsError("invalid-argument", `Unknown node ${currentId}`);
    }
    if (node.type === "terminal") {
      if (currentId !== input.terminalNodeId) {
        throw new HttpsError(
          "invalid-argument",
          "Path ended at a different terminal than reported.",
        );
      }
      if (heroStep !== input.pathNodeIds.length) {
        throw new HttpsError(
          "invalid-argument",
          "Not all reported hero decisions were consumed.",
        );
      }
      const t = node as TerminalNode;
      return {
        terminal: t,
        chosenEdges,
        actions,
        grading: {
          decisionCount: chosenEdges.length,
          correctCount: chosenEdges.filter((edge) => edge.verdict === "correct")
            .length,
          totalEvDeltaBb: chosenEdges.reduce(
            (total, edge) => total + edge.evDeltaBb,
            0,
          ),
          streetStats,
          chosenActionKinds: chosenEdges.map((edge) => edge.kind),
        },
      };
    }
    if (node.type === "scripted") {
      for (const action of node.actions) {
        actions.push(toHistoryAction(payload, node.street, action));
      }
      currentId = node.nextNodeId;
      continue;
    }
    // hero
    if (heroStep >= input.pathNodeIds.length) {
      throw new HttpsError(
        "invalid-argument",
        "Path continues past reported hero decisions.",
      );
    }
    if (input.pathNodeIds[heroStep] !== node.id) {
      throw new HttpsError(
        "invalid-argument",
        `Expected hero node ${node.id}, got ${input.pathNodeIds[heroStep]}`,
      );
    }
    const actionKey = input.chosenActionKeys[heroStep];
    const edge = (node as HeroDecisionNode).actions.find(
      (a) => a.actionKey === actionKey,
    );
    if (!edge) {
      throw new HttpsError(
        "invalid-argument",
        `Action ${actionKey} not legal at node ${node.id}`,
      );
    }
    chosenEdges.push(edge);
    actions.push(
      toHistoryAction(payload, node.street, {
        seat: payload.heroSeat,
        kind: edge.kind,
        amountTo: edge.amountTo,
      }),
    );
    const street = streetStats[node.street] ?? {
      decisionCount: 0,
      correctCount: 0,
      evDeltaBb: 0,
    };
    streetStats[node.street] = {
      decisionCount: street.decisionCount + 1,
      correctCount: street.correctCount + (edge.verdict === "correct" ? 1 : 0),
      evDeltaBb: street.evDeltaBb + edge.evDeltaBb,
    };
    heroStep += 1;
    currentId = edge.nextNodeId;
  }

  throw new HttpsError(
    "invalid-argument",
    "Path validation exceeded graph size.",
  );
}

/**
 * Re-derives the validated terminal result instead of trusting its duplicate
 * heroNetChips field when recording authoritative progress.
 */
export function deriveTerminalHeroNetChips(
  payload: SituationPayload,
  terminal: TerminalNode,
): number {
  const heroStartingStack = payload.lineup.find(
    (seat) => seat.seat === payload.heroSeat,
  )?.startingStack;
  const heroStack = terminal.stacks[payload.heroSeat];
  const derivedWinners = deriveTerminalWinnerSeats(payload, terminal);
  if (
    typeof heroStartingStack !== "number" ||
    !Number.isFinite(heroStartingStack) ||
    typeof heroStack !== "number" ||
    !Number.isFinite(heroStack) ||
    derivedWinners.length === 0 ||
    derivedWinners.length !== terminal.winnerSeats.length ||
    derivedWinners.some((seat) => !terminal.winnerSeats.includes(seat))
  ) {
    throw new HttpsError("internal", "Validated terminal payout is malformed.");
  }
  const heroShare = potShareForSeat(
    terminal.pot,
    derivedWinners,
    payload.heroSeat,
  );
  const result = heroStack + heroShare - heroStartingStack;
  if (!Number.isFinite(result)) {
    throw new HttpsError(
      "internal",
      "Validated terminal payout is non-finite.",
    );
  }
  return result;
}

function parseRecordInput(raw: unknown): RecordProgressInput {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new HttpsError("invalid-argument", "Request body must be an object.");
  }
  const data = raw as Record<string, unknown>;
  const situationId = asNonEmptyString(data.situationId, "situationId");
  const setupKey = asNonEmptyString(data.setupKey, "setupKey");
  const terminalNodeId = asNonEmptyString(
    data.terminalNodeId,
    "terminalNodeId",
  );
  if (
    !Array.isArray(data.pathNodeIds) ||
    !Array.isArray(data.chosenActionKeys)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "pathNodeIds and chosenActionKeys must be arrays.",
    );
  }
  const pathNodeIds = data.pathNodeIds.map((v, i) =>
    asNonEmptyString(v, `pathNodeIds[${i}]`),
  );
  const chosenActionKeys = data.chosenActionKeys.map((v, i) =>
    asNonEmptyString(v, `chosenActionKeys[${i}]`),
  );
  if (
    data.heroNetChips !== undefined &&
    (typeof data.heroNetChips !== "number" ||
      !Number.isFinite(data.heroNetChips))
  ) {
    throw new HttpsError(
      "invalid-argument",
      "heroNetChips, when provided, must be a finite number.",
    );
  }
  return {
    situationId,
    setupKey,
    pathNodeIds,
    chosenActionKeys,
    terminalNodeId,
    heroNetChips:
      typeof data.heroNetChips === "number" ? data.heroNetChips : undefined,
    notes: typeof data.notes === "string" ? data.notes : undefined,
  };
}

function asNonEmptyString(value: unknown, field: string): string {
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpsError(
      "invalid-argument",
      `${field} must be a non-empty string.`,
    );
  }
  return value.trim();
}

function toHistoryAction(
  payload: SituationPayload,
  street: HandHistoryAction["street"],
  action: {
    seat: number;
    kind: HandHistoryAction["kind"];
    amountTo?: number;
  },
): HandHistoryAction {
  const lineupSeat = payload.lineup.find((seat) => seat.seat === action.seat);
  return {
    seat: action.seat,
    street,
    kind: action.kind,
    amountBb: (action.amountTo ?? 0) / payload.bigBlind,
    isHero: action.seat === payload.heroSeat,
    archetype: lineupSeat?.archetype ?? "TAG",
  };
}

function inferPrimaryVillain(
  payload: SituationPayload,
  actions: HandHistoryAction[],
): string {
  const aggressive = [...actions]
    .reverse()
    .find(
      (action) =>
        !action.isHero &&
        (action.kind === "BET" ||
          action.kind === "RAISE" ||
          action.kind === "ALL_IN"),
    );
  if (aggressive) return aggressive.archetype;
  const lastVillain = [...actions].reverse().find((action) => !action.isHero);
  if (lastVillain) return lastVillain.archetype;
  return (
    payload.lineup.find((seat) => seat.archetype !== "HERO")?.archetype ?? "TAG"
  );
}

function isGradingSummary(value: unknown): value is GradingSummary {
  if (!value || typeof value !== "object" || Array.isArray(value)) return false;
  const grading = value as Partial<GradingSummary>;
  return (
    typeof grading.decisionCount === "number" &&
    typeof grading.correctCount === "number" &&
    typeof grading.totalEvDeltaBb === "number" &&
    Array.isArray(grading.chosenActionKinds) &&
    !!grading.streetStats
  );
}

function emptyGrading(): GradingSummary {
  return {
    decisionCount: 0,
    correctCount: 0,
    totalEvDeltaBb: 0,
    streetStats: {},
    chosenActionKinds: [],
  };
}
