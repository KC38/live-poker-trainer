/**
 * Content-hash helpers matching Dart `ScenarioModel.hashSetup`.
 *
 * Setup keys only — optimal / reasoning fields must not affect the id.
 */
import {createHash} from "crypto";

/** Keys that describe setup only (mirrors ScenarioModel._setupHashKeys). */
export const SETUP_HASH_KEYS = [
  "table_size",
  "hero_position",
  "hero_hand",
  "board_cards",
  "pot_size",
  "villain_seat",
  "villain_archetype",
  "previous_action_narrative",
  "villain_action",
  "call_amount",
  "min_raise",
  "max_raise",
  "name",
] as const;

/**
 * Recursively sorts object keys the same way Dart `_sorted` does.
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
 * SHA-256 hex of canonical JSON for [json] (full map).
 */
export function hashContent(json: Record<string, unknown>): string {
  const encoded = JSON.stringify(sortedJsonValue(json));
  return createHash("sha256").update(encoded, "utf8").digest("hex");
}

/**
 * Hash over setup fields only (excludes optimal / reasoning).
 */
export function hashSetup(json: Record<string, unknown>): string {
  const setup: Record<string, unknown> = {};
  for (const key of SETUP_HASH_KEYS) {
    if (Object.prototype.hasOwnProperty.call(json, key)) {
      setup[key] = json[key];
    }
  }
  return hashContent(setup);
}
