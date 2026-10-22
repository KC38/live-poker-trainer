/**
 * Preflop seat-order contract for lesson copy.
 *
 * Every seat that acts before the hero must have an action that is possible
 * in live preflop order (UTG → … → BTN → SB → BB). A prompt like
 * "BTN open, BB + MP call. You have 76s in SB." is impossible: MP acts
 * before the BTN open and the BB acts after the SB hero, so the felt would
 * have to show seats acting out of turn (or silently skip them).
 */

export const SIX_MAX_PREFLOP_ORDER = ["UTG", "HJ", "CO", "BTN", "SB", "BB"];
export const NINE_MAX_PREFLOP_ORDER = [
  "UTG", "UTG+1", "MP", "MP+1", "HJ", "CO", "BTN", "SB", "BB",
];

const TOKEN = String.raw`(UTG\+1|MP\+1|UTG|MP|HJ|CO|BTN|SB|BB)`;

/** Position order index on a nine-max ring (six-max names fit inside it). */
function orderOf(pos) {
  return NINE_MAX_PREFLOP_ORDER.indexOf(pos);
}

function positionsIn(text) {
  return [...text.matchAll(new RegExp(`(?<![A-Za-z0-9+])${TOKEN}(?![A-Za-z0-9+])`, "g"))]
    .map((m) => m[1]);
}

/**
 * Parses opener / named callers / hero seat from one preflop prompt.
 * Returns null when the prompt is not a simple preflop open spot.
 */
export function parsePreflopPrompt(raw) {
  if (typeof raw !== "string" || !raw) return null;
  const text = raw
    .replace(/\bbig blind\b/gi, "BB")
    .replace(/\bsmall blind\b/gi, "SB")
    .replace(/\bbutton\b/gi, "BTN")
    .replace(/\bcutoff\b/gi, "CO")
    .replace(/\bhijack\b/gi, "HJ");
  // Postflop prompts (flop/turn/river/board) are out of scope here.
  if (/\b(flop|turn|river|board)\b/i.test(text)) return null;
  const opener = new RegExp(`(?<![A-Za-z0-9+])${TOKEN}\\s+opens?\\b`).exec(text);
  if (!opener) return null;
  const heroMatch =
    new RegExp(`\\b(?:in|on|from)\\s+(?:the\\s+)?${TOKEN}(?![A-Za-z0-9+])`).exec(text) ??
    new RegExp(`\\bYou(?:'re| are)\\s+(?:in\\s+)?(?:the\\s+)?${TOKEN}(?![A-Za-z0-9+])`).exec(text);
  const hero = heroMatch ? heroMatch[1] : null;
  // Callers: positions in the clause that contains "call(s)" after the open,
  // up to the end of that sentence.
  const afterOpen = text.slice(opener.index + opener[0].length);
  const sentenceEnd = afterOpen.search(/[.?!]/);
  const clause = sentenceEnd < 0 ? afterOpen : afterOpen.slice(0, sentenceEnd);
  const callers = /\bcalls?\b/i.test(clause)
    ? [...clause.matchAll(new RegExp(`(?<![A-Za-z0-9+])${TOKEN}(?![A-Za-z0-9+])(?!\\s+(?:3-bets?|4-bets?|raises?|folds?|squeezes?|jams?|shoves?))`, "g"))]
      .map((m) => m[1])
      .filter((p) => p !== opener[1])
    : [];
  return {opener: opener[1], callers, hero};
}

/** Human-readable seat-order problems for one prompt (empty when fine). */
export function preflopActionOrderProblems(text) {
  const spot = parsePreflopPrompt(text);
  if (!spot || !spot.hero) return [];
  const problems = [];
  const {opener, callers, hero} = spot;
  const o = orderOf(opener);
  const h = orderOf(hero);
  if (opener === hero) {
    problems.push(`opener ${opener} is the hero's seat`);
    return problems;
  }
  const wrapped = o > h; // action came round to the hero (e.g. BB 3-bets)
  for (const c of callers) {
    const k = orderOf(c);
    if (c === hero) {
      problems.push(`caller ${c} is the hero's seat`);
    } else if (k < o) {
      problems.push(`caller ${c} acts before the ${opener} open`);
    } else if (!wrapped && k > h) {
      problems.push(`caller ${c} acts after the ${hero} hero and cannot have called yet`);
    }
  }
  return problems;
}
