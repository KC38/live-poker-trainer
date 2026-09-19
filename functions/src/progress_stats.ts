/**
 * Aggregate progress updates under users/{uid}/progress/main.
 */

import {
  FieldValue,
  type DocumentReference,
  type Firestore,
} from "firebase-admin/firestore";
import type {ProgressAggregateDoc} from "./situation_types";

const RECENT_LIMIT = 40;

export interface ProgressDelta {
  /** Actual chip result, separate from coaching EV. */
  heroNetBb: number;
  /** Sum of server-authored coaching EV deltas for chosen actions. */
  totalEvDeltaBb: number;
  correctCount: number;
  decisionCount: number;
  streetStats: Record<
    string,
    {decisionCount: number; correctCount: number; evDeltaBb: number}
  >;
  archetype?: string;
}

/**
 * Applies a completed-hand delta to the aggregate progress doc.
 */
export async function applyProgressDelta(
  db: Firestore,
  uid: string,
  delta: ProgressDelta,
): Promise<ProgressAggregateDoc> {
  const ref = progressRef(db, uid);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const current = (snap.data() ?? emptyProgress()) as ProgressAggregateDoc;

    const streetAccuracy = {...(current.streetAccuracy ?? {})};
    for (const [street, stats] of Object.entries(delta.streetStats)) {
      const prev = streetAccuracy[street] ?? {played: 0, correct: 0};
      streetAccuracy[street] = {
        played: prev.played + stats.decisionCount,
        correct: prev.correct + stats.correctCount,
      };
    }

    const archetypeAccuracy = {...(current.archetypeAccuracy ?? {})};
    if (delta.archetype) {
      const prev = archetypeAccuracy[delta.archetype] ?? {
        played: 0,
        correct: 0,
        evBb: 0,
      };
      archetypeAccuracy[delta.archetype] = {
        played: prev.played + delta.decisionCount,
        correct: prev.correct + delta.correctCount,
        evBb: prev.evBb + delta.totalEvDeltaBb,
      };
    }

    const recent = [
      ...(current.recentEvDeltas ?? []),
      delta.totalEvDeltaBb,
    ];
    if (recent.length > RECENT_LIMIT) {
      recent.splice(0, recent.length - RECENT_LIMIT);
    }

    const next: ProgressAggregateDoc = {
      handsPlayed: (current.handsPlayed ?? 0) + 1,
      handsCompleted: (current.handsCompleted ?? 0) + 1,
      netEvBb: (current.netEvBb ?? 0) + delta.totalEvDeltaBb,
      netResultBb: (current.netResultBb ?? 0) + delta.heroNetBb,
      correctSpots: (current.correctSpots ?? 0) + delta.correctCount,
      totalSpots: (current.totalSpots ?? 0) + delta.decisionCount,
      streetAccuracy,
      archetypeAccuracy,
      recentEvDeltas: recent,
      updatedAt: FieldValue.serverTimestamp(),
    };

    tx.set(ref, next, {merge: true});
    return next;
  });
}

/**
 * Pure merge used by unit tests (no Firestore).
 */
export function mergeProgressDelta(
  current: ProgressAggregateDoc,
  delta: ProgressDelta,
): ProgressAggregateDoc {
  const streetAccuracy = {...(current.streetAccuracy ?? {})};
  for (const [street, stats] of Object.entries(delta.streetStats)) {
    const prev = streetAccuracy[street] ?? {played: 0, correct: 0};
    streetAccuracy[street] = {
      played: prev.played + stats.decisionCount,
      correct: prev.correct + stats.correctCount,
    };
  }

  const archetypeAccuracy = {...(current.archetypeAccuracy ?? {})};
  if (delta.archetype) {
    const prev = archetypeAccuracy[delta.archetype] ?? {
      played: 0,
      correct: 0,
      evBb: 0,
    };
    archetypeAccuracy[delta.archetype] = {
      played: prev.played + delta.decisionCount,
      correct: prev.correct + delta.correctCount,
      evBb: prev.evBb + delta.totalEvDeltaBb,
    };
  }

  const recent = [
    ...(current.recentEvDeltas ?? []),
    delta.totalEvDeltaBb,
  ];
  if (recent.length > RECENT_LIMIT) {
    recent.splice(0, recent.length - RECENT_LIMIT);
  }

  return {
    handsPlayed: (current.handsPlayed ?? 0) + 1,
    handsCompleted: (current.handsCompleted ?? 0) + 1,
    netEvBb: (current.netEvBb ?? 0) + delta.totalEvDeltaBb,
    netResultBb: (current.netResultBb ?? 0) + delta.heroNetBb,
    correctSpots: (current.correctSpots ?? 0) + delta.correctCount,
    totalSpots: (current.totalSpots ?? 0) + delta.decisionCount,
    streetAccuracy,
    archetypeAccuracy,
    recentEvDeltas: recent,
    updatedAt: current.updatedAt,
  };
}

export function emptyProgress(): ProgressAggregateDoc {
  return {
    handsPlayed: 0,
    handsCompleted: 0,
    netEvBb: 0,
    netResultBb: 0,
    correctSpots: 0,
    totalSpots: 0,
    streetAccuracy: {},
    archetypeAccuracy: {},
    recentEvDeltas: [],
    updatedAt: null,
  };
}

export function progressRef(db: Firestore, uid: string): DocumentReference {
  return db.collection("users").doc(uid).collection("progress").doc("main");
}
