/**
 * Bounded, visible exploit tendency profiles for live opponents.
 *
 * Profiles vary by hand while remaining inside an auditable archetype
 * template. The same stored profile drives opponent prompts and coaching, so
 * the coach cannot justify advice using an invisible or contradictory read.
 */

import {createHash} from "node:crypto";
import {
  TENDENCY_PROFILE_VERSION,
  type TendencyProfile,
} from "./live_types";
import type {VillainArchetype} from "./situation_types";

interface NumericBounds {
  min: number;
  max: number;
}

interface ProfileTemplate {
  vpip: NumericBounds;
  pfr: NumericBounds;
  threeBet: NumericBounds;
  aggression: NumericBounds;
  foldToFlopBet: NumericBounds;
  foldToTurnBet: NumericBounds;
  foldToRiverBet: NumericBounds;
  bluffRiver: NumericBounds;
  showdownCall: NumericBounds;
  sizingTellStrength: NumericBounds;
  reads: readonly string[];
}

/** Public templates are intentionally narrow enough to stay recognizable. */
export const TENDENCY_TEMPLATES: Record<VillainArchetype, ProfileTemplate> = {
  NIT: {
    vpip: {min: 10, max: 17},
    pfr: {min: 8, max: 14},
    threeBet: {min: 2, max: 5},
    aggression: {min: 25, max: 45},
    foldToFlopBet: {min: 52, max: 68},
    foldToTurnBet: {min: 58, max: 74},
    foldToRiverBet: {min: 62, max: 80},
    bluffRiver: {min: 3, max: 12},
    showdownCall: {min: 18, max: 34},
    sizingTellStrength: {min: 62, max: 86},
    reads: [
      "Enters pots with a narrow range.",
      "Large turn and river aggression is value-heavy.",
      "Gives up too often when capped and pressured.",
    ],
  },
  CALLING_STATION: {
    vpip: {min: 40, max: 58},
    pfr: {min: 3, max: 11},
    threeBet: {min: 0, max: 4},
    aggression: {min: 8, max: 24},
    foldToFlopBet: {min: 15, max: 31},
    foldToTurnBet: {min: 18, max: 36},
    foldToRiverBet: {min: 20, max: 40},
    bluffRiver: {min: 2, max: 10},
    showdownCall: {min: 62, max: 82},
    sizingTellStrength: {min: 56, max: 82},
    reads: [
      "Calls too widely with pairs and draws.",
      "Rare aggression is stronger than usual.",
      "Reward thin value; avoid low-equity bluffs.",
    ],
  },
  MANIAC: {
    vpip: {min: 50, max: 72},
    pfr: {min: 34, max: 52},
    threeBet: {min: 14, max: 26},
    aggression: {min: 72, max: 94},
    foldToFlopBet: {min: 22, max: 42},
    foldToTurnBet: {min: 20, max: 40},
    foldToRiverBet: {min: 24, max: 46},
    bluffRiver: {min: 46, max: 72},
    showdownCall: {min: 46, max: 68},
    sizingTellStrength: {min: 8, max: 32},
    reads: [
      "Attacks pots with an extremely wide range.",
      "Arrives at the river with many bluffs.",
      "Widen value and bluff-catching ranges.",
    ],
  },
  TAG: {
    vpip: {min: 19, max: 27},
    pfr: {min: 16, max: 23},
    threeBet: {min: 6, max: 11},
    aggression: {min: 45, max: 62},
    foldToFlopBet: {min: 38, max: 52},
    foldToTurnBet: {min: 42, max: 56},
    foldToRiverBet: {min: 44, max: 60},
    bluffRiver: {min: 20, max: 34},
    showdownCall: {min: 38, max: 54},
    sizingTellStrength: {min: 18, max: 38},
    reads: [
      "Uses position and enters with disciplined ranges.",
      "Can apply pressure with credible semi-bluffs.",
      "Avoid large deviations without a line-specific read.",
    ],
  },
  LAG: {
    vpip: {min: 33, max: 46},
    pfr: {min: 24, max: 35},
    threeBet: {min: 9, max: 16},
    aggression: {min: 58, max: 78},
    foldToFlopBet: {min: 30, max: 46},
    foldToTurnBet: {min: 32, max: 48},
    foldToRiverBet: {min: 34, max: 52},
    bluffRiver: {min: 30, max: 50},
    showdownCall: {min: 42, max: 60},
    sizingTellStrength: {min: 12, max: 34},
    reads: [
      "Opens wide and pressures capped ranges.",
      "Carries more bluffs through later streets.",
      "Defend more often, but value-raise with discipline.",
    ],
  },
};

/**
 * Generates a stable profile for a seat and hand.
 */
export function generateTendencyProfile(
  archetype: VillainArchetype,
  seed: string,
): TendencyProfile {
  const template = TENDENCY_TEMPLATES[archetype];
  let offset = 0;
  const next = (bounds: NumericBounds): number => {
    const unit = deterministicUnit(`${seed}:${offset++}`);
    return roundOne(bounds.min + unit * (bounds.max - bounds.min));
  };
  const confidenceUnit = deterministicUnit(`${seed}:confidence`);
  return {
    profileVersion: TENDENCY_PROFILE_VERSION,
    archetype,
    vpip: next(template.vpip),
    pfr: next(template.pfr),
    threeBet: next(template.threeBet),
    aggression: next(template.aggression),
    foldToFlopBet: next(template.foldToFlopBet),
    foldToTurnBet: next(template.foldToTurnBet),
    foldToRiverBet: next(template.foldToRiverBet),
    bluffRiver: next(template.bluffRiver),
    showdownCall: next(template.showdownCall),
    sizingTellStrength: next(template.sizingTellStrength),
    confidence: confidenceUnit >= 0.35 ? "high" : "medium",
    reads: [...template.reads],
  };
}

/** Validates that stored/generated values stay inside their archetype bounds. */
export function validateTendencyProfile(profile: TendencyProfile): string[] {
  const errors: string[] = [];
  const template = TENDENCY_TEMPLATES[profile.archetype];
  if (!template) return ["unknown archetype"];
  for (const key of [
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
  ] as const) {
    const value = profile[key];
    const bounds = template[key];
    if (!Number.isFinite(value) || value < bounds.min || value > bounds.max) {
      errors.push(
        `${key}=${value} outside ${bounds.min}..${bounds.max} for ` +
          profile.archetype,
      );
    }
  }
  if (profile.reads.length < 2 || profile.reads.some((read) => !read.trim())) {
    errors.push("at least two non-empty visible reads are required");
  }
  return errors;
}

function deterministicUnit(seed: string): number {
  const digest = createHash("sha256").update(seed).digest();
  return digest.readUInt32BE(0) / 0xffffffff;
}

function roundOne(value: number): number {
  return Math.round(value * 10) / 10;
}
