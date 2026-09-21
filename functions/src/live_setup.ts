/**
 * Canonical parsing and pool keys for live-hand table setups.
 */

import {HttpsError} from "firebase-functions/v2/https";
import type {LiveTableSetup} from "./live_types";

const SUPPORTED_BLINDS = [
  [0.5, 1],
  [1, 2],
  [2, 5],
  [5, 10],
] as const;
const SUPPORTED_MAX_STACKS_BB = new Set([50, 100, 200, 300]);

/** Production default while the app remains in initial launch. */
export const DEFAULT_LIVE_SETUP: LiveTableSetup = {
  mode: "random",
  seatCount: 6,
  smallBlind: 1,
  bigBlind: 2,
  maxStackDepthBb: 200,
  heroSeat: 0,
};

/** Parses the v3 setup sent by the Flutter client. */
export function parseLiveTableSetup(raw: unknown): LiveTableSetup {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new HttpsError("invalid-argument", "tableSetup must be an object.");
  }
  const data = raw as Record<string, unknown>;
  const mode = data.mode ?? "random";
  if (mode === "course") {
    throw new HttpsError(
      "invalid-argument",
      "Course setups must use the course live bridge path.",
    );
  }
  if (mode !== "random") {
    throw new HttpsError(
      "invalid-argument",
      "Only random lineups are supported in live training.",
    );
  }
  const seatCount = integer(data.seatCount, "seatCount");
  if (seatCount < 2 || seatCount > 9) {
    throw new HttpsError("invalid-argument", "seatCount must be 2..9.");
  }
  const smallBlind = chips(data.smallBlind, "smallBlind");
  const bigBlind = chips(data.bigBlind, "bigBlind");
  if (bigBlind < smallBlind) {
    throw new HttpsError(
      "invalid-argument",
      "bigBlind must be at least smallBlind.",
    );
  }
  if (!SUPPORTED_BLINDS.some(
    ([sb, bb]) => sb === smallBlind && bb === bigBlind,
  )) {
    throw new HttpsError(
      "invalid-argument",
      "Blinds must use a supported app preset.",
    );
  }
  const maxStackDepthBb = integer(
    data.maxStackDepthBb ?? data.stackDepthBb,
    "maxStackDepthBb",
  );
  if (maxStackDepthBb < 20 || maxStackDepthBb > 500) {
    throw new HttpsError(
      "invalid-argument",
      "maxStackDepthBb must be 20..500.",
    );
  }
  if (!SUPPORTED_MAX_STACKS_BB.has(maxStackDepthBb)) {
    throw new HttpsError(
      "invalid-argument",
      "Maximum stack depth must use a supported app preset.",
    );
  }
  return {
    mode: "random",
    seatCount,
    smallBlind,
    bigBlind,
    maxStackDepthBb,
    // Hero is the logical bottom seat. Gemini varies position via the button.
    heroSeat: 0,
  };
}

/** Canonical key; per-hand random lineups intentionally do not affect it. */
export function buildLiveSetupKey(setup: LiveTableSetup): string {
  return [
    "live-v3",
    "random",
    `s${setup.seatCount}`,
    `max${setup.maxStackDepthBb}bb`,
    `sb${normalized(setup.smallBlind)}`,
    `bb${normalized(setup.bigBlind)}`,
  ].join("|");
}

function integer(value: unknown, field: string): number {
  if (
    typeof value !== "number" ||
    !Number.isInteger(value) ||
    !Number.isFinite(value)
  ) {
    throw new HttpsError("invalid-argument", `${field} must be an integer.`);
  }
  return value;
}

function chips(value: unknown, field: string): number {
  if (typeof value !== "number" || !Number.isFinite(value) || value <= 0) {
    throw new HttpsError("invalid-argument", `${field} must be positive.`);
  }
  const cents = Math.round(value * 100);
  if (Math.abs(value * 100 - cents) > 1e-9) {
    throw new HttpsError(
      "invalid-argument",
      `${field} supports at most two decimals.`,
    );
  }
  return cents / 100;
}

function normalized(value: number): string {
  const rounded = Math.round(value * 100) / 100;
  return Number.isInteger(rounded) ?
    String(rounded) :
    rounded.toFixed(2).replace(/0+$/, "").replace(/\.$/, "");
}
