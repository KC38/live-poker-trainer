/**
 * Content-hash helpers for situation identity.
 *
 * Situation ids are SHA-256 of a canonical subset of the payload so coaching
 * text churn alone does not fork pool entries when the tree is identical.
 */

import { createHash } from "crypto";
import type { SituationPayload } from "./situation_types";

/**
 * Recursively sorts object keys for stable JSON encoding.
 */
export function sortedJsonValue(value: unknown): unknown {
  if (value === null || typeof value !== "object") {
    return value;
  }
  if (Array.isArray(value)) {
    return value.map(sortedJsonValue);
  }
  const obj = value as Record<string, unknown>;
  const keys = Object.keys(obj).sort();
  const out: Record<string, unknown> = {};
  for (const key of keys) {
    out[key] = sortedJsonValue(obj[key]);
  }
  return out;
}

/**
 * SHA-256 hex of canonical JSON for [value].
 */
export function hashContent(value: unknown): string {
  const encoded = JSON.stringify(sortedJsonValue(value));
  return createHash("sha256").update(encoded, "utf8").digest("hex");
}

/**
 * Hash identifying a situation's structural tree (excludes title / coaching).
 */
export function hashSituationStructure(payload: SituationPayload): string {
  const nodes: Record<string, unknown> = {};
  for (const [id, node] of Object.entries(payload.nodes)) {
    if (node.type === "hero") {
      nodes[id] = {
        type: node.type,
        id: node.id,
        street: node.street,
        pot: node.pot,
        stacks: node.stacks,
        streetBets: node.streetBets,
        board: node.board,
        foldedSeats: node.foldedSeats,
        toAct: node.toAct,
        callAmount: node.callAmount,
        minRaiseTo: node.minRaiseTo,
        actions: node.actions.map((a) => ({
          actionKey: a.actionKey,
          kind: a.kind,
          amountTo: a.amountTo ?? null,
          sizingBucket: a.sizingBucket ?? null,
          nextNodeId: a.nextNodeId,
        })),
      };
    } else if (node.type === "scripted") {
      nodes[id] = {
        type: node.type,
        id: node.id,
        street: node.street,
        pot: node.pot,
        stacks: node.stacks,
        streetBets: node.streetBets,
        board: node.board,
        foldedSeats: node.foldedSeats,
        actions: node.actions,
        nextNodeId: node.nextNodeId,
      };
    } else {
      nodes[id] = {
        type: node.type,
        id: node.id,
        reason: node.reason,
        street: node.street,
        board: node.board,
        foldedSeats: node.foldedSeats,
        stacks: node.stacks,
        pot: node.pot,
        winnerSeats: node.winnerSeats,
        heroNetChips: node.heroNetChips,
      };
    }
  }

  return hashContent({
    payloadVersion: payload.payloadVersion,
    setupKey: payload.setupKey,
    setupMode: payload.setupMode,
    seatCount: payload.seatCount,
    smallBlind: payload.smallBlind,
    bigBlind: payload.bigBlind,
    ante: payload.ante,
    startingStack: payload.startingStack,
    buttonSeat: payload.buttonSeat,
    heroSeat: payload.heroSeat,
    lineup: payload.lineup.map((s) => ({
      seat: s.seat,
      archetype: s.archetype,
      startingStack: s.startingStack,
    })),
    heroHand: payload.heroHand,
    holeCards: payload.holeCards,
    runouts: payload.runouts,
    rootNodeId: payload.rootNodeId,
    nodes,
  });
}
