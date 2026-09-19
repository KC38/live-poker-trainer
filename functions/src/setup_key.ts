/**
 * Canonical table-setup keys for situation pools.
 *
 * Random Pool: normalized seat-count / stack / blinds (lineup lives on each
 * situation). Custom: exact seat count + stack + blinds + ordered archetypes
 * + button / hero seats.
 */

import {
  type SetupMode,
  type TableSetupInput,
  VILLAIN_ARCHETYPES,
  type VillainArchetype,
} from "./situation_types";

const RANK_ORDER = "23456789TJQKA";
const SUITS = new Set(["s", "h", "d", "c"]);

/**
 * Parses and normalizes a client table-setup request.
 *
 * @throws Error when the setup is invalid.
 */
export function parseTableSetupInput(raw: unknown): TableSetupInput {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new Error("tableSetup must be an object");
  }
  const data = raw as Record<string, unknown>;
  const mode = data.mode;
  if (mode !== "random" && mode !== "custom") {
    throw new Error('tableSetup.mode must be "random" or "custom"');
  }

  const seatCount = asPositiveInt(data.seatCount, "seatCount");
  if (seatCount < 2 || seatCount > 9) {
    throw new Error("seatCount must be between 2 and 9");
  }

  const smallBlind = asMoneyInRange(data.smallBlind, "smallBlind", 0.01, 500);
  const bigBlind = asMoneyInRange(data.bigBlind, "bigBlind", 0.02, 1000);
  if (bigBlind < smallBlind) {
    throw new Error("bigBlind must be >= smallBlind");
  }
  const ante = data.ante === undefined || data.ante === null
    ? 0
    : asMoneyInRange(data.ante, "ante", 0, bigBlind);
  const startingStack = asMoney(data.startingStack, "startingStack");
  const stackBb = startingStack / bigBlind;
  const epsilon = 1e-9;
  if (stackBb < 20 - epsilon || stackBb > 500 + epsilon) {
    throw new Error("startingStack must be between 20 and 500 big blinds");
  }

  const parsed: TableSetupInput = {
    mode,
    seatCount,
    smallBlind,
    bigBlind,
    ante,
    startingStack,
  };

  if (mode === "custom") {
    const buttonSeat = asSeatIndex(data.buttonSeat, seatCount, "buttonSeat");
    const heroSeat = asSeatIndex(data.heroSeat, seatCount, "heroSeat");
    const lineupRaw = data.lineup;
    if (!Array.isArray(lineupRaw) || lineupRaw.length !== seatCount) {
      throw new Error("custom lineup must include exactly seatCount seats");
    }
    const lineup = lineupRaw.map((entry, index) => {
      if (!entry || typeof entry !== "object") {
        throw new Error(`lineup[${index}] must be an object`);
      }
      const row = entry as Record<string, unknown>;
      const seat = asSeatIndex(row.seat, seatCount, `lineup[${index}].seat`);
      const archetype = normalizeArchetype(String(row.archetype ?? ""));
      if (row.name !== undefined && typeof row.name !== "string") {
        throw new Error(`lineup[${index}].name must be a string`);
      }
      const name =
        typeof row.name === "string" && row.name.trim()
          ? row.name.trim().slice(0, 32)
          : undefined;
      return {seat, archetype, name};
    });

    const seats = new Set(lineup.map((s) => s.seat));
    if (seats.size !== seatCount) {
      throw new Error("lineup seats must be unique and cover 0..seatCount-1");
    }
    for (let i = 0; i < seatCount; i++) {
      if (!seats.has(i)) {
        throw new Error("lineup seats must cover 0..seatCount-1");
      }
    }
    const heroes = lineup.filter((s) => s.archetype === "HERO");
    if (heroes.length !== 1) {
      throw new Error("custom lineup must contain exactly one HERO");
    }
    if (heroes[0].seat !== heroSeat) {
      throw new Error("heroSeat must match the HERO lineup seat");
    }

    parsed.buttonSeat = buttonSeat;
    parsed.heroSeat = heroSeat;
    parsed.lineup = lineup;
  }

  return parsed;
}

/**
 * Builds the canonical pool document id for a table setup.
 */
export function buildSetupKey(setup: TableSetupInput): string {
  const ante = setup.ante ?? 0;
  const stack = normalizeMoney(setup.startingStack);
  const sb = normalizeMoney(setup.smallBlind);
  const bb = normalizeMoney(setup.bigBlind);
  const anteN = normalizeMoney(ante);

  if (setup.mode === "random") {
    return [
      "random",
      `s${setup.seatCount}`,
      `stack${stack}`,
      `sb${sb}`,
      `bb${bb}`,
      `ante${anteN}`,
    ].join("|");
  }

  if (
    setup.buttonSeat === undefined ||
    setup.heroSeat === undefined ||
    !setup.lineup
  ) {
    throw new Error("custom setup requires buttonSeat, heroSeat, and lineup");
  }

  const ordered = [...setup.lineup].sort((a, b) => a.seat - b.seat);
  const arch = ordered
    .map((s) => normalizeArchetype(s.archetype))
    .join(",");

  return [
    "custom",
    `s${setup.seatCount}`,
    `stack${stack}`,
    `sb${sb}`,
    `bb${bb}`,
    `ante${anteN}`,
    `btn${setup.buttonSeat}`,
    `hero${setup.heroSeat}`,
    `lineup${arch}`,
  ].join("|");
}

/**
 * Normalizes archetype labels to canonical ids.
 */
export function normalizeArchetype(raw: string): VillainArchetype | "HERO" {
  const key = raw.trim().toUpperCase().replace(/\s+/g, "_");
  if (key === "HERO" || key === "YOU") return "HERO";
  if (key === "STATION" || key === "CALLINGSTATION") {
    return "CALLING_STATION";
  }
  if ((VILLAIN_ARCHETYPES as readonly string[]).includes(key)) {
    return key as VillainArchetype;
  }
  throw new Error(`unknown archetype: ${raw}`);
}

/**
 * Validates a card code like "As" or "Td".
 */
export function isValidCard(code: string): boolean {
  if (typeof code !== "string" || code.length !== 2) return false;
  const rank = code[0].toUpperCase();
  const suit = code[1].toLowerCase();
  return RANK_ORDER.includes(rank) && SUITS.has(suit);
}

/**
 * Canonical card code (rank upper, suit lower).
 */
export function normalizeCard(code: string): string {
  if (!isValidCard(code)) {
    throw new Error(`invalid card: ${code}`);
  }
  return `${code[0].toUpperCase()}${code[1].toLowerCase()}`;
}

/**
 * Money fingerprint that collapses float noise (e.g. 100 vs 100.0000001).
 */
export function normalizeMoney(value: number): string {
  const rounded = Math.round(value * 100) / 100;
  if (Number.isInteger(rounded)) return String(rounded);
  return rounded.toFixed(2).replace(/\.?0+$/, "");
}

export function modeFromSetupKey(setupKey: string): SetupMode {
  if (setupKey.startsWith("random|")) return "random";
  if (setupKey.startsWith("custom|")) return "custom";
  throw new Error(`unrecognized setupKey: ${setupKey}`);
}

function asPositiveInt(value: unknown, field: string): number {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    throw new Error(`${field} must be a finite number`);
  }
  const n = Math.trunc(value);
  if (n !== value || n <= 0) {
    throw new Error(`${field} must be a positive integer`);
  }
  return n;
}

function asSeatIndex(value: unknown, seatCount: number, field: string): number {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    throw new Error(`${field} must be a finite number`);
  }
  const n = Math.trunc(value);
  if (n !== value || n < 0 || n >= seatCount) {
    throw new Error(`${field} must be an integer in [0, ${seatCount - 1}]`);
  }
  return n;
}

function asMoney(value: unknown, field: string): number {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    throw new Error(`${field} must be a finite number`);
  }
  const cents = Math.round(value * 100);
  if (Math.abs(value * 100 - cents) > 1e-9) {
    throw new Error(`${field} must have at most 2 decimal places`);
  }
  return cents / 100;
}

function asMoneyInRange(
  value: unknown,
  field: string,
  min: number,
  max: number,
): number {
  const amount = asMoney(value, field);
  if (amount < min || amount > max) {
    throw new Error(`${field} must be between ${min} and ${max}`);
  }
  return amount;
}
