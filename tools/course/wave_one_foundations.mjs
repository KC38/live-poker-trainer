/**
 * Plan 07 — Sections 1–2 authored curriculum helpers.
 * Consumed by build_seed_course.mjs; not run standalone.
 */

export const ACC = ["recommended", "strong", "reasonable"];

export function dialogue(id, order, text, extra = {}) {
  const {okFeedback, ...rest} = extra;
  const out = {
    id,
    order,
    stage: "guided",
    renderer: "coach_dialogue",
    estimatedSeconds: 30,
    accessibilityText: text,
    acceptedGrades: ["recommended"],
    coachMedia: [{id: `${id}-media`, kind: "dialogue", text}],
    ...rest,
  };
  // Optional Nice! why line — private bank only (LPT-74). Without it,
  // gradeCourseResponse falls back to accessibilityText (often the ask).
  if (typeof okFeedback === "string" && okFeedback.trim()) {
    out.explainGrading = {
      grade: "recommended",
      feedback: okFeedback.trim(),
    };
  }
  // teachSpec stays the last key, as in content/course/v2/course.json.
  if (out.teachSpec) {
    const {teachSpec} = out;
    delete out.teachSpec;
    out.teachSpec = teachSpec;
  }
  return out;
}

export function choice(id, label, grade, feedback, extra = {}) {
  const out = {
    id,
    label,
    accessibilityText: extra.accessibilityText ?? label,
    grading: {
      grade,
      feedback,
      ...(extra.betterChoiceId ? {betterChoiceId: extra.betterChoiceId} : {}),
      ...(extra.reversalRead ? {reversalRead: extra.reversalRead} : {}),
    },
  };
  if (extra.action) out.action = extra.action;
  if (extra.amountBb !== undefined) out.amountBb = extra.amountBb;
  return out;
}

export function selectAct({
  id, order, stage, prompt, a11y, objectives, choices, hint, playerTypeRefs = [],
  assessmentRole, teachSpec,
}) {
  const act = {
    id, order, stage, renderer: "select_identify",
    estimatedSeconds:
      stage === "checkpoint" || assessmentRole === "checkpoint" ? 45 : 40,
    accessibilityText: a11y,
    acceptedGrades: ACC,
    objectives,
    prompt,
    choices,
  };
  if (playerTypeRefs.length) act.playerTypeRefs = playerTypeRefs;
  if (hint) {
    act.coachMedia = [{id: `${id}-hint`, kind: "hint", text: hint}];
  }
  // Same key order as content/course/v2/course.json (LPT-81).
  if (assessmentRole) act.assessmentRole = assessmentRole;
  if (teachSpec) act.teachSpec = teachSpec;
  return act;
}

export function sequenceAct({
  id, order, stage, prompt, a11y, objectives, items, correct,
  okFeedback, missFeedback, renderer = "order_sequence", assessmentRole,
  teachSpec,
}) {
  const act = {
    id, order, stage, renderer,
    estimatedSeconds: 50,
    accessibilityText: a11y,
    acceptedGrades: ACC,
    objectives,
    prompt,
    sequenceItems: items,
    correctSequence: correct,
    sequenceGrading: {
      correct: {grade: "recommended", feedback: okFeedback},
      incorrect: {grade: "clear_mistake", feedback: missFeedback},
    },
  };
  // Same key order as content/course/v2/course.json (LPT-88).
  if (assessmentRole) act.assessmentRole = assessmentRole;
  if (teachSpec) act.teachSpec = teachSpec;
  return act;
}

export function numericAct({
  id, order, stage, question, a11y, objectives,
  unit, min, max, okFeedback, missFeedback,
}) {
  return {
    id, order, stage, renderer: "numeric_pot_price",
    estimatedSeconds: 40,
    accessibilityText: a11y,
    acceptedGrades: ACC,
    objectives,
    numericPrompt: {
      question,
      unit,
      acceptedMin: min,
      acceptedMax: max,
      grading: {grade: "recommended", feedback: okFeedback},
      missGrading: {grade: "clear_mistake", feedback: missFeedback},
    },
  };
}

export function actionAct({
  id, order, stage, prompt, a11y, objectives, choices, hint, playerTypeRefs = [],
  assessmentRole, teachSpec,
}) {
  const act = {
    id, order, stage, renderer: "poker_action_sizing",
    estimatedSeconds: 55,
    accessibilityText: a11y,
    acceptedGrades: ACC,
    objectives,
    prompt,
    choices,
  };
  if (playerTypeRefs.length) act.playerTypeRefs = playerTypeRefs;
  if (hint) {
    act.coachMedia = [{id: `${id}-hint`, kind: "hint", text: hint}];
  }
  if (assessmentRole) act.assessmentRole = assessmentRole;
  if (teachSpec) act.teachSpec = teachSpec;
  return act;
}

export function multiStepAct({
  id, order, stage, a11y, objectives, steps,
  playerTypeRefs = [], assessmentRole, teachSpec,
}) {
  const act = {
    id, order, stage, renderer: "authored_multi_step_hand",
    estimatedSeconds: 70,
    accessibilityText: a11y,
    acceptedGrades: ACC,
    objectives,
    handSteps: steps,
  };
  if (playerTypeRefs.length) act.playerTypeRefs = playerTypeRefs;
  if (assessmentRole) act.assessmentRole = assessmentRole;
  if (teachSpec) act.teachSpec = teachSpec;
  return act;
}

export function handLabAct({
  id, order, stage, prompt, a11y, objectives, choices, lab,
  playerTypeRefs = [], assessmentRole, teachSpec,
}) {
  const act = {
    id, order, stage, renderer: "full_table_hand_lab",
    estimatedSeconds: 90,
    accessibilityText: a11y,
    acceptedGrades: ACC,
    objectives,
    prompt,
    choices,
    handLabSpec: lab,
  };
  if (playerTypeRefs.length) act.playerTypeRefs = playerTypeRefs;
  if (assessmentRole) act.assessmentRole = assessmentRole;
  if (teachSpec) act.teachSpec = teachSpec;
  return act;
}

export function lesson({
  id, order, title, summary, objectives, prereq, remediation,
  minutes = 6, band = 1, activities, playerTypeRefs = [],
  introducesPlayerTypes = [],
}) {
  return {
    id, order, title, summary, objectives,
    prerequisites: prereq ? [prereq] : [],
    remediationLessonIds: [remediation ?? id],
    estimatedMinutes: minutes,
    difficultyBand: band,
    playerTypeRefs,
    introducesPlayerTypes,
    activities,
  };
}

export function unit(id, order, title, summary, lessons) {
  return {id, order, title, summary, lessons};
}

/** Player-read classify activity (Plan 08+). */
export function classifyAct({
  id, order, stage, prompt, a11y, objectives, choices, playerTypeRefs = [], hint,
}) {
  const act = {
    id, order, stage, renderer: "player_read_classify",
    estimatedSeconds: 45,
    accessibilityText: a11y,
    acceptedGrades: ACC,
    objectives,
    prompt,
    choices,
  };
  if (playerTypeRefs.length) act.playerTypeRefs = playerTypeRefs;
  if (hint) {
    act.coachMedia = [{id: `${id}-hint`, kind: "hint", text: hint}];
  }
  return act;
}

/** @returns {object} Section 1 — Never Played */
export function buildSectionOne() {
  const L010101 = "lesson-01-01-01-your-two-cards";
  const L010102 = "lesson-01-01-02-suits-and-ranks";
  const L010103 = "lesson-01-01-03-blinds-and-button";
  const L010201 = "lesson-01-02-01-hand-ranks";
  const L010202 = "lesson-01-02-02-best-five-kickers";
  const L010301 = "lesson-01-03-01-fold-check-call";
  const L010302 = "lesson-01-03-02-bet-raise-allin";
  const L010401 = "lesson-01-04-01-streets-and-order";
  const L010501 = "lesson-01-05-01-winning-pots";
  const L010601 = "lesson-01-06-01-guided-complete-hand";
  const L010602 = "lesson-01-06-02-section-one-jump";

  return {
    id: "sec-01-never-played",
    order: 1,
    title: "Never Played",
    summary: "Sit down and play a complete live cash hand without freezing.",
    experienceBand: "never_played",
    units: [
      unit("unit-01-01-cards-and-table", 1, "Cards and the table",
        "Suits, ranks, hole cards, and the live table layout.", [
          lesson({
            id: L010101, order: 1,
            title: "Your two cards",
            summary: "Learn that hole cards are private to you until showdown.",
            objectives: [
              "Identify your two hole cards",
              "Distinguish hole cards from community cards",
              "Recognize that other seats hide their hole cards",
            ],
            remediation: L010101,
            activities: [
              dialogue("act-01-01-01-explain-hole-cards", 1,
                "These two are yours alone. Nobody else sees them.",
                {objectives: ["Identify your two hole cards"]}),
              selectAct({
                id: "act-01-01-01-guided-find-holes", order: 2, stage: "guided",
                prompt: "Tap your hole cards on the table.",
                a11y: "Tap the two private hole cards in front of you.",
                objectives: ["Identify your two hole cards"],
                hint: "Your two cards sit at your seat — not the board.",
                choices: [
                  choice("choice-hero-holes", "Ah Kd in front of you", "recommended",
                    "Right. Those two stay private until showdown."),
                  choice("choice-board", "The flop cards in the middle", "clear_mistake",
                    "Board cards are shared. Your hole cards sit in front of you.",
                    {betterChoiceId: "choice-hero-holes"}),
                  choice("choice-villain", "Face-down cards at another seat", "clear_mistake",
                    "Those belong to someone else. Yours are the two in front of you.",
                    {betterChoiceId: "choice-hero-holes"}),
                ],
              }),
              selectAct({
                id: "act-01-01-01-scaffolded-private", order: 3, stage: "scaffolded",
                prompt: "Tap the cards only you can see.",
                a11y: "Tap your private hole cards — not the board or other seats.",
                objectives: ["Recognize that other seats hide their hole cards"],
                choices: [
                  choice("choice-only-you", "Only you", "recommended",
                    "Private until showdown. Protect them."),
                  choice("choice-whole-table", "Everyone at the table", "clear_mistake",
                    "If everyone saw them, they would not be hole cards.",
                    {betterChoiceId: "choice-only-you"}),
                  choice("choice-dealer-only", "Only the dealer", "questionable",
                    "Dealers should not peek. Treat the cards as yours alone.",
                    {reversalRead: "Casino procedures vary; still play as if only you know them."}),
                ],
              }),
              selectAct({
                id: "act-01-01-01-unguided-mix", order: 4, stage: "scaffolded",
                prompt: "Tap the community cards.",
                a11y: "Tap the shared community cards on the flop.",
                objectives: ["Distinguish hole cards from community cards"],
                choices: [
                  choice("choice-flop", "Qs Jh 2c in the middle", "recommended",
                    "Those are shared. Everyone uses them."),
                  choice("choice-hero-again", "Your Ah Kd", "clear_mistake",
                    "Those stay yours. Community cards are in the middle.",
                    {betterChoiceId: "choice-flop"}),
                  choice("choice-muck", "Folded cards in the muck", "clear_mistake",
                    "Mucked cards are dead, not the board.",
                    {betterChoiceId: "choice-flop"}),
                ],
              }),
              selectAct({
                id: "act-01-01-01-checkpoint-table", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Tap the cards that are only yours.",
                a11y: "On a fuller table, tap your private hole cards again.",
                objectives: [
                  "Identify your two hole cards",
                  "Distinguish hole cards from community cards",
                ],
                choices: [
                  choice("choice-checkpoint-holes", "The two cards at your seat", "recommended",
                    "Still just your two. Board and other seats stay separate."),
                  choice("choice-checkpoint-board", "Flop plus your two cards", "clear_mistake",
                    "You combine them later to make a hand. Ownership stays split.",
                    {
                      betterChoiceId: "choice-checkpoint-holes",
                      reversalRead: "At showdown you reveal them, but until then they are private.",
                    }),
                  choice("choice-checkpoint-all", "Every face-up card you can see", "questionable",
                    "You can see the board, but those cards are not yours alone."),
                ],
              }),
            ],
          }),
          lesson({
            id: L010102, order: 2,
            title: "Suits and ranks",
            summary: "Name ranks and suits, and spot when cards match.",
            objectives: [
              "Name the four suits",
              "Order ranks from deuce to ace",
              "Spot pairs and suited cards",
            ],
            prereq: L010101, remediation: L010101,
            activities: [
              dialogue("act-01-01-02-explain-suits", 1,
                "Four suits, thirteen ranks. Ace is high here.",
                {
                  objectives: ["Name the four suits"],
                  accessibilityText:
                    "You found all four suits. Ace is still the high card.",
                  // LPT-353
                  teachSpec: {
                    deal: {mode: "none"},
                    cues: [
                      {press: 1, target: "hearts", kind: "soft_pulse"},
                      {press: 2, target: "diamonds", kind: "soft_pulse"},
                      {press: 3, target: "clubs", kind: "soft_pulse"},
                      {press: 4, target: "spades", kind: "soft_pulse"},
                    ],
                  },
                }),
              selectAct({
                id: "act-01-01-02-guided-suits", order: 2, stage: "guided",
                prompt: "Tap one community card of each suit.",
                a11y: "Tap hearts, diamonds, clubs, and spades on the board.",
                objectives: ["Name the four suits"],
                hint: "Four suits — one card of each on the board.",
                choices: [
                  choice("suits-full", "Hearts, diamonds, clubs, spades", "recommended",
                    "Those four cover the deck."),
                ],
                // LPT-81: dealSuitLessonBoard — one real card per suit (fresh
                // ranks) plus the star decoy. SoftPulse walks the next untapped
                // suit in board order, one gold card per press.
                teachSpec: {
                  deal: {mode: "random_in_class", suitFamily: "four_suits"},
                  cues: [
                    {press: 1, target: "board_hearts", kind: "soft_pulse"},
                    {press: 2, target: "board_diamonds", kind: "soft_pulse"},
                    {press: 3, target: "board_clubs", kind: "soft_pulse"},
                    {press: 4, target: "board_spades", kind: "soft_pulse"},
                  ],
                },
              }),
              sequenceAct({
                id: "act-01-01-02-scaffolded-ranks", order: 3, stage: "scaffolded",
                prompt: "Tap these ranks from lowest to highest.",
                a11y: "Tap the three board ranks from lowest to highest.",
                objectives: ["Order ranks from lowest to highest"],
                items: [
                  {id: "rank-2", label: "2"},
                  {id: "rank-T", label: "T"},
                  {id: "rank-A", label: "A"},
                ],
                correct: ["rank-2", "rank-T", "rank-A"],
                okFeedback: "Lowest first, then the middle rank, highest last.",
                missFeedback: "Start with the smallest rank and climb up.",
                // LPT-82
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "high_card", suitFamily: "rainbow"},
                  pressHints: [
                    {press: 1, text: "Start with the lowest rank."},
                    {press: 2, text: "Next comes the middle rank."},
                    {press: 3, text: "The highest rank goes last."},
                  ],
                },
              }),
              selectAct({
                id: "act-01-01-02-unguided-suited", order: 4, stage: "scaffolded",
                prompt: "Tap the suited hole cards.",
                a11y: "Tap the seat whose hole cards share a suit.",
                objectives: ["Spot pairs and suited cards"],
                choices: [
                  choice("suited-ah-kh", "Suited", "recommended",
                    "Same suit — that is suited."),
                  choice("offsuit-ah-kd", "Offsuit", "clear_mistake",
                    "Different suits. That is offsuit.", {betterChoiceId: "suited-ah-kh"}),
                  choice("pair-77", "Pocket pair", "questionable",
                    "That is a pair, not suited. Look for matching suits."),
                ],
                // LPT-82
                teachSpec: {
                  deal: {
                    mode: "random_in_class",
                    suitFamily: "suited",
                    variants: [
                      {
                        id: "var-offsuit-seat",
                        suitFamily: "offsuit",
                        label: "Offsuit distractor seat",
                      },
                      {
                        id: "var-pair-seat",
                        handFamily: "pair",
                        label: "Pocket pair distractor seat",
                      },
                    ],
                  },
                  pressHints: [{press: 1, text: "Look for the two hole cards that share a suit."}],
                  cues: [{press: 1, target: "suited_seat", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-01-01-02-checkpoint-pair", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Tap the pocket pair.",
                a11y: "Tap the seat with a pocket pair.",
                objectives: ["Spot pairs and suited cards"],
                choices: [
                  choice("pocket-pair", "Pocket pair", "recommended",
                    "Matching ranks — that is a pocket pair."),
                  choice("suited-nine", "Suited", "clear_mistake",
                    "Suited, but not a pair. Matching ranks make a pair.",
                    {betterChoiceId: "pocket-pair"}),
                  choice("two-high", "Offsuit", "clear_mistake",
                    "High cards, not a pair. Matching ranks make a pair.",
                    {betterChoiceId: "pocket-pair"}),
                ],
                // LPT-81: checkpoint — no pressHints / Hint media. Pocket pair
                // answer seat plus suited and offsuit distractor seats.
                teachSpec: {
                  deal: {
                    mode: "random_in_class",
                    handFamily: "pair",
                    variants: [
                      {id: "var-suited-seat", suitFamily: "suited", label: "Suited distractor seat"},
                      {id: "var-offsuit-seat", suitFamily: "offsuit", label: "Offsuit distractor seat"},
                    ],
                  },
                  cues: [{press: 1, target: "pair_seat", kind: "none"}],
                },
              }),
            ],
          }),
          lesson({
            id: L010103, order: 3,
            title: "Button and blinds",
            summary: "Find the dealer button, small blind, and big blind.",
            objectives: [
              "Locate the dealer button",
              "Identify the small and big blinds",
              "Know blinds post before cards are dealt",
            ],
            prereq: L010102, remediation: L010102,
            activities: [
              dialogue("act-01-01-03-explain-button", 1,
                "Button marks the dealer. Blinds sit left of it.",
                {
                  objectives: [
                    "Locate the dealer button",
                    "Identify the small and big blinds",
                  ],
                  accessibilityText:
                    "Clockwise from the button: small blind, then big blind.",
                  // LPT-85: seat/puck lesson, no cards dealt. SoftPulse walks
                  // the pucks D -> SB -> BB (lessonPuckLabelForHighlight).
                  teachSpec: {
                    deal: {mode: "none"},
                    cues: [
                      {press: 1, target: "D", kind: "soft_pulse"},
                      {press: 2, target: "SB", kind: "soft_pulse"},
                      {press: 3, target: "BB", kind: "soft_pulse"},
                    ],
                  },
                }),
              selectAct({
                id: "act-01-01-03-guided-button", order: 2, stage: "guided",
                prompt: "Tap the dealer button on the table.",
                a11y: "Tap the seat that has the dealer button chip.",
                objectives: ["Locate the dealer button"],
                hint: "Look for the chip labeled D.",
                choices: [
                  choice("btn-seat", "The seat with the D chip", "recommended",
                    "That chip is the button."),
                  choice("bb-seat", "The seat that posted 2 chips", "clear_mistake",
                    "That is the big blind, left of the small blind.",
                    {betterChoiceId: "btn-seat"}),
                  choice("empty-seat", "Any empty seat", "clear_mistake",
                    "Empty seats do not hold the button.",
                    {betterChoiceId: "btn-seat"}),
                ],
                // LPT-85: same-concept quiet guided step; gold D after Hint.
                teachSpec: {
                  deal: {mode: "none"},
                  cues: [{press: 1, target: "D", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-01-01-03-scaffolded-blinds", order: 3, stage: "scaffolded",
                prompt: "Blinds are 1/2. Tap who posts the big blind.",
                a11y: "Tap the seat that posts the big blind.",
                objectives: ["Identify the small and big blinds"],
                choices: [
                  choice("bb-two", "The seat two left of the button, posting 2", "recommended",
                    "Small blind is first left; big blind is next."),
                  choice("sb-one", "The seat immediately left of the button", "clear_mistake",
                    "That seat posts the small blind (1), not the big.",
                    {betterChoiceId: "bb-two"}),
                  choice("btn-posts", "The button posts both blinds", "clear_mistake",
                    "Button deals later; blinds post to the left.",
                    {betterChoiceId: "bb-two"}),
                ],
                // LPT-85: authored target stays BB; the seat-ring fallback when
                // the BB puck is hidden stays in Dart.
                teachSpec: {
                  deal: {mode: "none"},
                  cues: [{press: 1, target: "BB", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-01-01-03-unguided-when", order: 4, stage: "scaffolded",
                prompt: "Tap when the blinds go in.",
                a11y: "Tap the hand phase when blinds are posted.",
                objectives: ["Know blinds post before cards are dealt"],
                choices: [
                  choice("before-deal", "Before any hole cards are dealt", "recommended",
                    "Blinds first, then cards."),
                  choice("after-flop", "After the flop", "clear_mistake",
                    "Blinds start the pot before the deal.",
                    {betterChoiceId: "before-deal"}),
                  choice("only-showdown", "Only if the hand reaches showdown", "clear_mistake",
                    "Blinds are forced bets every hand.",
                    {betterChoiceId: "before-deal"}),
                ],
                // LPT-85: phase strip, no cards dealt; Hint golds Before deal.
                teachSpec: {
                  deal: {mode: "none"},
                  cues: [{press: 1, target: "before-deal", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-01-01-03-checkpoint-layout", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Button is seat 5. Tap the small blind.",
                a11y: "On a six-handed table, tap the small blind seat.",
                objectives: [
                  "Locate the dealer button",
                  "Identify the small and big blinds",
                ],
                choices: [
                  choice("sb-seat0", "Seat 0 (first left of button)", "recommended",
                    "Clockwise: button, then small blind, then big blind."),
                  choice("sb-seat4", "Seat 4 (right of button)", "clear_mistake",
                    "Action moves left of the button, not right.",
                    {betterChoiceId: "sb-seat0"}),
                  choice("sb-seat1", "Seat 1 (big blind seat)", "clear_mistake",
                    "Seat 1 would be big blind when seat 0 is small blind.",
                    {betterChoiceId: "sb-seat0"}),
                ],
                // LPT-85: checkpoint, no pressHints / Hint media.
                teachSpec: {
                  deal: {mode: "none"},
                  cues: [{press: 1, target: "SB", kind: "none"}],
                },
              }),
            ],
          }),
        ]),
      unit("unit-01-02-what-beats-what", 2, "What beats what",
        "Hand ranks, best five of seven, ties and kickers.", [
          lesson({
            id: L010201, order: 1,
            title: "Hand ranks",
            summary: "Rank made hands from high card up through straight flush.",
            objectives: [
              "Order common hand ranks",
              "Recognize pairs, straights, and flushes",
              "Compare two finished hands",
            ],
            prereq: L010103, remediation: L010103, band: 1, minutes: 8,
            activities: [
              dialogue("act-01-02-01-explain-ladder", 1,
                "Pair beats high card. Flush beats straight. Tap seats weakest to strongest.",
                {
                  objectives: ["Order common hand ranks"],
                  okFeedback: "High card, then pair, then flush.",
                  // LPT-88: dealShowdownOrderCards classes (role ids you/sam/jo = press order);
                  // seat roles shuffle in Dart, cues follow the role ids.
                  teachSpec: {
                    deal: {
                      mode: "random_in_class",
                      handFamily: "high_card",
                      variants: [
                        {id: "var-pair-seat", handFamily: "pair", label: "Pair seat"},
                        {id: "var-flush-seat", handFamily: "flush", label: "Flush seat"},
                      ],
                    },
                    cues: [
                      {press: 1, target: "you", kind: "soft_pulse"},
                      {press: 2, target: "sam", kind: "soft_pulse"},
                      {press: 3, target: "jo", kind: "soft_pulse"},
                    ],
                  },
                }),
              sequenceAct({
                id: "act-01-02-01-guided-ladder", order: 2, stage: "guided",
                renderer: "compare_rank",
                prompt: "Tap weakest to strongest.",
                a11y: "Showdown — tap You (high card), Sam (pair), then Jo (flush).",
                objectives: ["Order common hand ranks"],
                items: [
                  {id: "you", label: "You"},
                  {id: "sam", label: "Sam"},
                  {id: "jo", label: "Jo"},
                ],
                correct: ["you", "sam", "jo"],
                okFeedback: "High card, then pair, then flush.",
                missFeedback: "Flush is strongest of these three.",
                // LPT-88: dealShowdownOrderCards classes (role ids you/sam/jo = press order);
                // seat roles shuffle in Dart, cues follow the role ids.
                teachSpec: {
                  deal: {
                    mode: "random_in_class",
                    handFamily: "high_card",
                    variants: [
                      {id: "var-pair-seat", handFamily: "pair", label: "Pair seat"},
                      {id: "var-flush-seat", handFamily: "flush", label: "Flush seat"},
                    ],
                  },
                  cues: [
                    {press: 1, target: "you", kind: "soft_pulse"},
                    {press: 2, target: "sam", kind: "soft_pulse"},
                    {press: 3, target: "jo", kind: "soft_pulse"},
                  ],
                },
              }),
              sequenceAct({
                id: "act-01-02-01-scaffolded-spot", order: 3, stage: "scaffolded",
                renderer: "compare_rank",
                prompt: "Tap weakest to strongest.",
                a11y: "Showdown — tap You (pair), Sam (straight), then Jo (flush).",
                objectives: ["Recognize pairs, straights, and flushes"],
                items: [
                  {id: "you", label: "You"},
                  {id: "sam", label: "Sam"},
                  {id: "jo", label: "Jo"},
                ],
                correct: ["you", "sam", "jo"],
                okFeedback: "Pair, then straight, then flush.",
                missFeedback: "Flush beats straight; straight beats pair.",
                // LPT-88: dealShowdownOrderCards classes (role ids you/sam/jo = press order);
                // seat roles shuffle in Dart, cues follow the role ids.
                teachSpec: {
                  deal: {
                    mode: "random_in_class",
                    handFamily: "pair",
                    variants: [
                      {id: "var-straight-seat", handFamily: "straight", label: "Straight seat"},
                      {id: "var-flush-seat", handFamily: "flush", label: "Flush seat"},
                    ],
                  },
                  cues: [
                    {press: 1, target: "you", kind: "soft_pulse"},
                    {press: 2, target: "sam", kind: "soft_pulse"},
                    {press: 3, target: "jo", kind: "soft_pulse"},
                  ],
                },
              }),
              sequenceAct({
                id: "act-01-02-01-unguided-compare", order: 4, stage: "scaffolded",
                renderer: "compare_rank",
                prompt: "Tap highest to lowest.",
                a11y: "Showdown — tap You (full house), Sam (trips), then Jo (two pair).",
                objectives: ["Compare two finished hands"],
                items: [
                  {id: "you", label: "You"},
                  {id: "sam", label: "Sam"},
                  {id: "jo", label: "Jo"},
                ],
                correct: ["you", "sam", "jo"],
                okFeedback: "Full house, then trips, then two pair.",
                missFeedback: "Full house tops trips; trips top two pair.",
                // LPT-88: dealShowdownOrderCards classes (role ids you/sam/jo = press order);
                // seat roles shuffle in Dart, cues follow the role ids.
                teachSpec: {
                  deal: {
                    mode: "random_in_class",
                    handFamily: "full_house",
                    variants: [
                      {id: "var-trips-seat", handFamily: "trips", label: "Trips seat"},
                      {id: "var-two-pair-seat", handFamily: "two_pair", label: "Two pair seat"},
                    ],
                  },
                  cues: [
                    {press: 1, target: "you", kind: "soft_pulse"},
                    {press: 2, target: "sam", kind: "soft_pulse"},
                    {press: 3, target: "jo", kind: "soft_pulse"},
                  ],
                },
              }),
              sequenceAct({
                id: "act-01-02-01-checkpoint-winner", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                renderer: "compare_rank",
                prompt: "Tap highest to lowest.",
                a11y: "Showdown — tap You (flush), Sam (straight), then Jo (high card).",
                objectives: ["Compare two finished hands", "Order common hand ranks"],
                items: [
                  {id: "you", label: "You"},
                  {id: "sam", label: "Sam"},
                  {id: "jo", label: "Jo"},
                ],
                correct: ["you", "sam", "jo"],
                okFeedback: "Flush beats straight; straight beats high card.",
                missFeedback: "Flush is strongest; high card is weakest.",
                // LPT-88: dealShowdownOrderCards classes (role ids you/sam/jo = press order);
                // seat roles shuffle in Dart, cues follow the role ids.
                teachSpec: {
                  deal: {
                    mode: "random_in_class",
                    handFamily: "flush",
                    variants: [
                      {id: "var-straight-seat", handFamily: "straight", label: "Straight seat"},
                      {id: "var-high-card-seat", handFamily: "high_card", label: "High card seat"},
                    ],
                  },
                  cues: [
                    {press: 1, target: "you", kind: "none"},
                    {press: 2, target: "sam", kind: "none"},
                    {press: 3, target: "jo", kind: "none"},
                  ],
                },
              }),
            ],
          }),
          lesson({
            id: L010202, order: 2,
            title: "Best five and kickers",
            summary: "Use exactly five cards; kickers break ties.",
            objectives: [
              "Build the best five-card hand from seven",
              "Use kickers when categories tie",
              "Spot board-tied pots",
            ],
            prereq: L010201, remediation: L010201, minutes: 7,
            activities: [
              dialogue("act-01-02-02-explain-five", 1,
                "Only five cards count. Pick the strongest five.",
                {
                  objectives: ["Build the best five-card hand from seven"],
                  okFeedback: "Exactly five cards — leave the extras out.",
                  // LPT-91: dealBestFiveExplainLayout (_dealTopPairBestKicker):
                  // top pair + best kicker, fresh ranks; cues follow its
                  // playOrder, one gold card per press.
                  teachSpec: {
                    deal: {mode: "random_in_class", handFamily: "pair"},
                    cues: [
                      {press: 1, target: "hero_pair", kind: "soft_pulse"},
                      {press: 2, target: "hero_kicker", kind: "soft_pulse"},
                      {press: 3, target: "board_pair", kind: "soft_pulse"},
                      {press: 4, target: "board_second_kicker", kind: "soft_pulse"},
                      {press: 5, target: "board_top_kicker", kind: "soft_pulse"},
                    ],
                  },
                }),
              selectAct({
                id: "act-01-02-02-guided-seven", order: 2, stage: "guided",
                prompt: "Tap the five cards that make your best hand.",
                a11y: "Tap the five cards for top pair with the best kicker.",
                objectives: ["Build the best five-card hand from seven"],
                hint: "Use your pair plus the strongest kickers.",
                choices: [
                  choice("best-pair-k", "Top pair with best kicker", "recommended",
                    "Pair plus the strongest available kickers."),
                  choice("weak-kickers", "Pair with a weaker kicker", "clear_mistake",
                    "Keep the stronger kicker in your five.",
                    {betterChoiceId: "best-pair-k"}),
                  choice("ignore-ace", "High card only", "clear_mistake",
                    "You paired a board card — use the pair.", {betterChoiceId: "best-pair-k"}),
                ],
                // LPT-91: dealtBestFiveSpot (_dealTopPairBestKicker): picker gold
                // walks the best-pair-k set in catalog order.
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "pair"},
                  cues: [
                    {press: 1, target: "hero_pair", kind: "soft_pulse"},
                    {press: 2, target: "board_pair", kind: "soft_pulse"},
                    {press: 3, target: "hero_kicker", kind: "soft_pulse"},
                    {press: 4, target: "board_top_kicker", kind: "soft_pulse"},
                    {press: 5, target: "board_second_kicker", kind: "soft_pulse"},
                  ],
                },
              }),
              selectAct({
                id: "act-01-02-02-scaffolded-kicker", order: 3, stage: "scaffolded",
                prompt: "Same pair — tap who wins on kickers.",
                a11y: "Tap who wins when kickers break a tied pair.",
                objectives: ["Use kickers when categories tie"],
                choices: [
                  choice("you-kicker", "You win — better kicker", "recommended",
                    "Same pair; higher kicker wins."),
                  choice("they-kicker", "They win — their kicker", "clear_mistake",
                    "Higher kicker takes it — look again.", {betterChoiceId: "you-kicker"}),
                  choice("chop-kicker", "Chop — same pair always ties", "clear_mistake",
                    "Kickers decide when pairs match.", {betterChoiceId: "you-kicker"}),
                ],
                // LPT-91: kicker showdown remap: same board pair, hero kicker
                // beats villain; Hint golds the You seat.
                teachSpec: {
                  deal: {
                    mode: "random_in_class",
                    handFamily: "pair",
                    variants: [
                      {
                        id: "var-villain-weaker-kicker",
                        handFamily: "pair",
                        label: "Villain plays the same board pair with a weaker kicker",
                      },
                    ],
                  },
                  cues: [{press: 1, target: "hero_holes", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-01-02-02-unguided-board", order: 4, stage: "scaffolded",
                prompt: "Both checked down — tap who takes the pot.",
                a11y: "Tap chop when the board plays for everyone.",
                objectives: ["Spot board-tied pots"],
                choices: [
                  choice("chop-broadway", "Chop — both play the board", "recommended",
                    "Neither hole card beats this straight flush board."),
                  choice("button-wins", "Button wins automatically", "clear_mistake",
                    "Showdown compares five-card hands, not seats.",
                    {betterChoiceId: "chop-broadway"}),
                  choice("high-card-wins", "Higher hole card wins", "clear_mistake",
                    "Hole cards do not improve this board.",
                    {betterChoiceId: "chop-broadway"}),
                ],
                // LPT-91: board-plays chop: monotone straight-flush board, small
                // hero pair; Hint golds the board.
                teachSpec: {
                  deal: {
                    mode: "random_in_class",
                    handFamily: "straight_flush",
                    suitFamily: "monotone",
                    variants: [
                      {
                        id: "var-hero-small-pair",
                        handFamily: "pair",
                        label: "Hero small pocket pair under the board",
                      },
                    ],
                  },
                  cues: [{press: 1, target: "board", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                // SoftPulse-quiet scaffolded transfer: Hint unlocks one-gold
                // SoftPulse on the recommended five (not assessmentRole — that
                // leaves Hint permanently disabled).
                id: "act-01-02-02-checkpoint-build", order: 5, stage: "scaffolded",
                prompt: "Tap the five cards for your strongest hand.",
                a11y: "Tap three of a kind plus a pair for a full house.",
                objectives: [
                  "Build the best five-card hand from seven",
                  "Use kickers when categories tie",
                ],
                choices: [
                  choice("fh-eights", "Full house — trips over the higher pair", "recommended",
                    "Trips plus the stronger pair."),
                  choice("fh-deuces", "Full house — trips over the lower pair", "clear_mistake",
                    "Use the higher pair under your trips.",
                    {betterChoiceId: "fh-eights"}),
                  choice("two-pair-only", "Two pair only", "clear_mistake",
                    "You have trips plus a pair — full house.",
                    {betterChoiceId: "fh-eights"}),
                ],
                // LPT-91: _dealTripsOverTwoPairs pocket + board trips over two
                // pairs. Guide order matches fh-eights choice set.
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "full_house", suitFamily: "pair"},
                  cues: [
                    {press: 1, target: "hero_trip_1", kind: "soft_pulse"},
                    {press: 2, target: "hero_trip_2", kind: "soft_pulse"},
                    {press: 3, target: "board_trip", kind: "soft_pulse"},
                    {press: 4, target: "board_high_1", kind: "soft_pulse"},
                    {press: 5, target: "board_high_2", kind: "soft_pulse"},
                  ],
                },
              }),
            ],
          }),
        ]),
      unit("unit-01-03-five-actions", 3, "The five actions",
        "Fold, check, call, bet, raise — and all-in limits.", [
          lesson({
            id: L010301, order: 1,
            title: "Fold, check, call",
            summary: "Passive choices when facing a bet or a free option.",
            objectives: [
              "Fold to give up the hand",
              "Check when no bet faces you",
              "Call to match the current bet",
            ],
            prereq: L010202, remediation: L010202,
            activities: [
              dialogue("act-01-03-01-explain-passive", 1,
                "Three quiet buttons — each has a different job.",
                {objectives: ["Fold to give up the hand"]}),
              actionAct({
                id: "act-01-03-01-guided-fold", order: 2, stage: "guided",
                prompt: "Worst hand vs a raise — pick how you leave.",
                a11y: "Tap Fold with seven-two offsuit versus an open.",
                objectives: ["Fold to give up the hand"],
                hint: "Trash hands fold to raises.",
                choices: [
                  choice("fold-72", "Fold", "recommended",
                    "No reason to continue with trash offsuit.", {action: "FOLD"}),
                  choice("call-72", "Call 6", "clear_mistake",
                    "Calling with junk burns chips.", {action: "CALL", betterChoiceId: "fold-72"}),
                  choice("raise-72", "Raise to 18", "clear_mistake",
                    "Do not invent aggression with trash offsuit.",
                    {action: "RAISE", amountBb: 9, betterChoiceId: "fold-72"}),
                ],
                // LPT-94
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "trash", suitFamily: "offsuit"},
                  cues: [{press: 1, target: "fold-72", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-01-03-01-scaffolded-check", order: 3, stage: "scaffolded",
                prompt: "Nothing faces you — pick the free action.",
                a11y: "Tap Check when the action is free.",
                objectives: ["Check when no bet faces you"],
                choices: [
                  choice("check-free", "Check free", "recommended",
                    "No bet to match — check is available.", {action: "CHECK"}),
                  choice("call-free", "Call", "clear_mistake",
                    "Call needs a bet to match.", {action: "CALL", betterChoiceId: "check-free"}),
                  choice("fold-free", "Fold", "clear_mistake",
                    "Folding for free throws away equity.",
                    {action: "FOLD", betterChoiceId: "check-free"}),
                ],
                // LPT-94
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "weak_draw"},
                  cues: [{press: 1, target: "check-free", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-01-03-01-unguided-call", order: 4, stage: "scaffolded",
                prompt: "A bet is out — pick how you continue.",
                a11y: "Tap Call to match a half-pot bet.",
                objectives: ["Call to match the current bet"],
                choices: [
                  choice("call-5", "Call 5", "recommended",
                    "Calling matches the 5.", {action: "CALL"}),
                  choice("check-5", "Check", "clear_mistake",
                    "A bet faces you — check is not legal.",
                    {action: "CHECK", betterChoiceId: "call-5"}),
                  choice("fold-strong", "Fold", "questionable",
                    "Sometimes fold, but here the price is fine if you planned to continue.",
                    {action: "FOLD"}),
                ],
                // LPT-94
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "strong_draw"},
                  cues: [{press: 1, target: "call-5", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-01-03-01-checkpoint-legal", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "A bet faces you. Tap the action you cannot take.",
                a11y: "Tap Check — it is illegal facing a bet.",
                objectives: [
                  "Check when no bet faces you",
                  "Call to match the current bet",
                ],
                choices: [
                  choice("check-illegal", "Check", "recommended",
                    "You must fold, call, or raise — check is off.",
                    {action: "CHECK"}),
                  choice("call-legal", "Call", "clear_mistake",
                    "Call is available facing a bet.",
                    {action: "CALL", betterChoiceId: "check-illegal"}),
                  choice("fold-legal", "Fold", "clear_mistake",
                    "Fold is always available.",
                    {action: "FOLD", betterChoiceId: "check-illegal"}),
                ],
                // LPT-94
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "weak_draw"},
                  cues: [{press: 1, target: "check-illegal", kind: "none"}],
                },
              }),
            ],
          }),
          lesson({
            id: L010302, order: 2,
            title: "Bet, raise, all-in",
            summary: "Add chips; all-in is capped by your stack.",
            objectives: [
              "Bet when the pot is unchecked",
              "Raise to increase a facing bet",
              "Treat all-in as a sized bet or raise",
            ],
            prereq: L010301, remediation: L010301,
            minutes: 7,
            activities: [
              dialogue("act-01-03-02-explain-aggro", 1,
                "Three chip-pushing buttons — each has a different job.",
                {objectives: ["Bet when the pot is unchecked"]}),
              actionAct({
                id: "act-01-03-02-guided-bet", order: 2, stage: "guided",
                prompt: "Checked to you on the flop with top pair. Tap a value size.",
                a11y: "Tap Bet 5 into 10 for value when checked to.",
                objectives: ["Bet when the pot is unchecked"],
                hint: "Nobody put in a bet yet — betting is open.",
                choices: [
                  choice("bet-half", "Bet 5", "recommended",
                    "A half-pot bet asks for value.", {action: "BET", amountBb: 2.5}),
                  choice("check-value", "Check", "questionable",
                    "Checking is fine sometimes, but you wanted value.",
                    {action: "CHECK"}),
                  choice("raise-no-bet", "Raise", "clear_mistake",
                    "Nothing to raise yet — bet instead.",
                    {action: "RAISE", amountBb: 5, betterChoiceId: "bet-half"}),
                ],
                // LPT-98: guided bet keeps top_pair SoftPulse on bet-half
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "top_pair"},
                  cues: [{press: 1, target: "bet-half", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-01-03-02-scaffolded-raise", order: 3, stage: "scaffolded",
                prompt: "Villain bets 5. Strong hand — tap how you charge.",
                a11y: "Tap Raise to 15 facing a bet.",
                objectives: ["Raise to increase a facing bet"],
                choices: [
                  choice("raise-15", "Raise to 15", "recommended",
                    "Raising builds the pot with the best of it.",
                    {action: "RAISE", amountBb: 7.5}),
                  choice("call-flat", "Call 5", "reasonable",
                    "Calling is playable; raising extracts more.", {action: "CALL"}),
                  choice("bet-again", "Bet 5", "clear_mistake",
                    "Facing a bet you raise or call — you do not 'bet'.",
                    {action: "BET", amountBb: 2.5, betterChoiceId: "raise-15"}),
                ],
                // LPT-98: scaffolded raise keeps top_pair SoftPulse on raise-15
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "top_pair"},
                  cues: [{press: 1, target: "raise-15", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-01-03-02-unguided-allin", order: 4, stage: "scaffolded",
                prompt: "Stack 12. Villain bets 20. Tap what you can put in.",
                a11y: "Tap All-in 12 — capped by your remaining stack.",
                objectives: ["Treat all-in as a sized bet or raise"],
                choices: [
                  choice("shove-12", "All-in 12", "recommended",
                    "You can only put in what you have.", {action: "ALL_IN"}),
                  choice("call-20", "Call 20", "clear_mistake",
                    "You cannot call more than your stack.",
                    {action: "CALL", betterChoiceId: "shove-12"}),
                  choice("fold-only", "Fold", "clear_mistake",
                    "All-in for less is legal and creates a side pot later.",
                    {action: "FOLD", betterChoiceId: "shove-12"}),
                ],
                // LPT-98: unguided all-in keeps top_pair SoftPulse on shove-12
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "top_pair"},
                  cues: [{press: 1, target: "shove-12", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-01-03-02-checkpoint-names", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Pot is unchecked. Tap the first chips into the pot.",
                a11y: "Tap Bet — first chips into an unchecked pot.",
                objectives: [
                  "Bet when the pot is unchecked",
                  "Raise to increase a facing bet",
                ],
                choices: [
                  choice("named-bet", "Bet 4", "recommended",
                    "First chips into an unchecked pot are a bet.",
                    {action: "BET", amountBb: 2}),
                  choice("named-raise", "Raise", "clear_mistake",
                    "Raise needs a bet to raise.",
                    {action: "RAISE", amountBb: 4, betterChoiceId: "named-bet"}),
                  choice("named-call", "Call", "clear_mistake",
                    "Call matches; it does not open.",
                    {action: "CALL", betterChoiceId: "named-bet"}),
                ],
                // LPT-98: checkpoint-names air + named-bet kind none; no
                // pressHints
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "air"},
                  cues: [{press: 1, target: "named-bet", kind: "none"}],
                },
              }),
            ],
          }),
        ]),
      unit("unit-01-04-streets", 4, "Streets of a hand",
        "Preflop through river, and when a street ends.", [
          lesson({
            id: L010401, order: 1,
            title: "Streets and action order",
            summary: "Name each street and know who acts when.",
            objectives: [
              "Name preflop, flop, turn, and river",
              "Know preflop order starts left of the big blind",
              "Know a street ends when bets are matched",
            ],
            prereq: L010302, remediation: L010302, minutes: 7,
            activities: [
              dialogue("act-01-04-01-explain-streets", 1,
                "Four streets: preflop, flop, turn, river. Match bets to move on.",
                {
                  objectives: ["Name preflop, flop, turn, and river"],
                  okFeedback: "Preflop → flop → turn → river.",
                }),
              sequenceAct({
                id: "act-01-04-01-guided-streets", order: 2, stage: "guided",
                prompt: "Tap the streets from first to last.",
                a11y: "Put preflop, flop, turn, and river in chronological order.",
                objectives: ["Name preflop, flop, turn, and river"],
                items: [
                  {id: "st-pre", label: "Preflop"},
                  {id: "st-flop", label: "Flop"},
                  {id: "st-turn", label: "Turn"},
                  {id: "st-river", label: "River"},
                ],
                correct: ["st-pre", "st-flop", "st-turn", "st-river"],
                okFeedback: "Preflop → flop → turn → river.",
                missFeedback: "Holes first; flop is three; turn then river.",
                // LPT-101: guided streets SoftPulse st-pre→st-river; deal none
                teachSpec: {
                  deal: {mode: "none"},
                  cues: [
                    {press: 1, target: "st-pre", kind: "soft_pulse"},
                    {press: 2, target: "st-flop", kind: "soft_pulse"},
                    {press: 3, target: "st-turn", kind: "soft_pulse"},
                    {press: 4, target: "st-river", kind: "soft_pulse"},
                  ],
                },
              }),
              sequenceAct({
                id: "act-01-04-01-scaffolded-order", order: 3, stage: "scaffolded",
                prompt: "Tap seats in the order they act preflop after blinds.",
                a11y: "Put UTG, HJ, CO, and BTN in preflop action order.",
                objectives: ["Know preflop order starts left of the big blind"],
                items: [
                  {id: "seat-utg", label: "UTG"},
                  {id: "seat-hj", label: "HJ"},
                  {id: "seat-co", label: "CO"},
                  {id: "seat-btn", label: "BTN"},
                ],
                correct: ["seat-utg", "seat-hj", "seat-co", "seat-btn"],
                okFeedback: "UTG → HJ → CO → BTN. Button acts last preflop.",
                missFeedback: "Start under the gun, then HJ, CO, and the button.",
                // LPT-101: scaffolded order SoftPulse UTG→HJ→CO→BTN; deal none;
                // CO synced
                teachSpec: {
                  deal: {mode: "none"},
                  cues: [
                    {press: 1, target: "seat-utg", kind: "soft_pulse"},
                    {press: 2, target: "seat-hj", kind: "soft_pulse"},
                    {press: 3, target: "seat-co", kind: "soft_pulse"},
                    {press: 4, target: "seat-btn", kind: "soft_pulse"},
                  ],
                },
              }),
              selectAct({
                id: "act-01-04-01-unguided-end", order: 4, stage: "scaffolded",
                prompt: "Flop betting is live. Tap when this street ends.",
                a11y: "Tap bets matched — a street ends when action is complete.",
                objectives: ["Know a street ends when bets are matched"],
                choices: [
                  choice("matched", "Bets matched",
                    "recommended", "Equalized action closes the street."),
                  choice("three-cards", "Flop appears", "clear_mistake",
                    "The flop deal starts the street; betting still happens.",
                    {betterChoiceId: "matched"}),
                  choice("someone-folds", "Someone folds", "clear_mistake",
                    "Folding removes a player; others may still act.",
                    {betterChoiceId: "matched"}),
                ],
                // LPT-101: unguided-end SoftPulse matched; deal none
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "matched", kind: "soft_pulse"}]},
              }),
              selectAct({
                id: "act-01-04-01-checkpoint-postflop", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Postflop multiway. Tap who acts first.",
                a11y: "Tap the seat left of the button — first to act postflop.",
                objectives: [
                  "Know preflop order starts left of the big blind",
                  "Name preflop, flop, turn, and river",
                ],
                choices: [
                  choice("sb-first", "SB", "recommended",
                    "Postflop starts left of the button — usually the small blind if live."),
                  choice("btn-first", "BTN", "clear_mistake",
                    "Button acts last postflop.", {betterChoiceId: "sb-first"}),
                  choice("bb-first-always", "BB",
                    "clear_mistake",
                    "Big blind acts last preflop only.", {betterChoiceId: "sb-first"}),
                ],
                // LPT-101: checkpoint-postflop sb-first kind none; no pressHints
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "sb-first", kind: "none"}]},
              }),
            ],
          }),
        ]),
      unit("unit-01-05-winning-pots", 5, "Winning and protecting pots",
        "Folds versus showdown, and side-pot intuition.", [
          lesson({
            id: L010501, order: 1,
            title: "How pots are won",
            summary: "Win when everyone folds, or at showdown; sense side pots.",
            objectives: [
              "Win the pot when everyone else folds",
              "Win at showdown with the best five",
              "Sense main pot versus side pot without deep math",
            ],
            prereq: L010401, remediation: L010401,
            activities: [
              dialogue("act-01-05-01-explain-win", 1,
                "Folds win pots early. Showdown compares hands. Short stacks make side pots.",
                {objectives: ["Win the pot when everyone else folds"]}),
              selectAct({
                id: "act-01-05-01-guided-fold-win", order: 2, stage: "guided",
                prompt: "You bet. Everyone folds. Tap how you take the pot.",
                a11y: "Tap take pot — uncontested pots do not require a show.",
                objectives: ["Win the pot when everyone else folds"],
                hint: "No contest means no showdown.",
                choices: [
                  choice("no-show", "Take pot", "recommended",
                    "Uncontested pots do not require a show."),
                  choice("must-show", "Must show", "clear_mistake",
                    "You only show when called to showdown.",
                    {betterChoiceId: "no-show"}),
                  choice("dealer-shows", "Dealer shows", "clear_mistake",
                    "Your cards stay private if uncalled.",
                    {betterChoiceId: "no-show"}),
                ],
                // LPT-104: guided fold-win fixed AhKd SoftPulse no-show
                teachSpec: {
                  deal: {mode: "fixed", fixedCards: {hero: ["Ah", "Kd"]}},
                  cues: [{press: 1, target: "no-show", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-01-05-01-scaffolded-showdown", order: 3, stage: "scaffolded",
                prompt: "River bets are called. Tap what happens next.",
                a11y: "Tap showdown — best five-card hand wins.",
                objectives: ["Win at showdown with the best five"],
                choices: [
                  choice("showdown", "Showdown", "recommended",
                    "Cards speak."),
                  choice("last-bet-wins", "Last bettor", "clear_mistake",
                    "A call forces showdown.", {betterChoiceId: "showdown"}),
                  choice("chop-default", "Always chop", "clear_mistake",
                    "Hands still compare.", {betterChoiceId: "showdown"}),
                ],
                // LPT-104: scaffolded showdown fixed river SoftPulse showdown
                teachSpec: {
                  deal: {
                    mode: "fixed",
                    fixedCards: {hero: ["Ah", "Kd"], board: ["Qs", "7c", "2d", "9h", "3s"]},
                  },
                  cues: [{press: 1, target: "showdown", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-01-05-01-unguided-pot", order: 4, stage: "scaffolded",
                prompt: "Blinds 1/2. BTN opens. Tap the pot before blinds act.",
                a11y: "Tap the pot total — blinds plus the open. Open size varies each attempt.",
                objectives: ["Sense main pot versus side pot without deep math"],
                choices: [
                  choice("pot-correct", "Correct pot", "recommended",
                    "Add both blinds and the open."),
                  choice("pot-miss-blind", "Miss a blind", "clear_mistake",
                    "Add both blinds and the open.",
                    {betterChoiceId: "pot-correct"}),
                  choice("pot-too-big", "Too big", "clear_mistake",
                    "Add both blinds and the open — do not double the raise.",
                    {betterChoiceId: "pot-correct"}),
                ],
                // LPT-104: unguided-pot none + open-to variants 5-10 SoftPulse
                // pot-correct
                teachSpec: {
                  deal: {
                    mode: "none",
                    variants: [
                      {id: "open-5", label: "Open to 5"},
                      {id: "open-6", label: "Open to 6"},
                      {id: "open-7", label: "Open to 7"},
                      {id: "open-8", label: "Open to 8"},
                      {id: "open-9", label: "Open to 9"},
                      {id: "open-10", label: "Open to 10"},
                    ],
                  },
                  cues: [{press: 1, target: "pot-correct", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-01-05-01-checkpoint-side", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "You are all-in for less; two big stacks keep betting. Tap what is true.",
                a11y: "Tap side pot — unmatched chips form a side pot you cannot win.",
                objectives: ["Sense main pot versus side pot without deep math"],
                choices: [
                  choice("side-exists", "Side pot",
                    "recommended",
                    "You can only win the main pot you covered."),
                  choice("you-win-all", "Win all",
                    "clear_mistake",
                    "Extra chips beyond your all-in go to a side pot.",
                    {betterChoiceId: "side-exists"}),
                  choice("hand-void", "Hand dead", "clear_mistake",
                    "You remain live for the main pot.",
                    {betterChoiceId: "side-exists"}),
                ],
                // LPT-104: checkpoint-side side-exists kind none; no pressHints
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "side-exists", kind: "none"}]},
              }),
            ],
          }),
        ]),
      unit("unit-01-06-first-complete-hand", 6, "First complete hand",
        "Guided hand from blinds through a terminal state.", [
          lesson({
            id: L010601, order: 1,
            title: "Play a full toy hand",
            summary: "Walk a short live cash hand from blinds to a finish.",
            objectives: [
              "Follow a hand from blinds to a terminal state",
              "Choose legal actions on more than one street",
              "Finish without freezing on basic decisions",
            ],
            prereq: L010501, remediation: L010501, minutes: 10,
            activities: [
              dialogue("act-01-06-01-explain-run", 1,
                "One short hand. Blinds post, you act, we reach an ending.",
                {objectives: ["Follow a hand from blinds to a terminal state"]}),
              multiStepAct({
                id: "act-01-06-01-guided-steps", order: 2, stage: "guided",
                a11y: "Button with a suited ace — open to 6, then take the pot when blinds fold.",
                objectives: ["Choose legal actions on more than one street"],
                steps: [
                  {
                    id: "step-01-06-pre",
                    street: "preflop",
                    prompt: "Button with a suited ace. Folds to you. Blinds 1/2.",
                    accessibilityText: "Open to 6 from the button with ace-nine suited.",
                    choices: [
                      choice("open-6", "Raise to 6", "recommended",
                        "A standard live open from the button.",
                        {action: "RAISE", amountBb: 3}),
                      choice("limp-a9", "Limp", "questionable",
                        "Limping works sometimes; opening is cleaner.", {action: "CALL"}),
                      choice("fold-a9", "Fold", "clear_mistake",
                        "Too strong to fold on the button.",
                        {action: "FOLD", betterChoiceId: "open-6"}),
                    ],
                  },
                  {
                    id: "step-01-06-flop",
                    street: "flop",
                    prompt: "Blinds fold. What happened?",
                    accessibilityText: "You won — everyone folded.",
                    choices: [
                      choice("won-folds", "Won pot", "recommended",
                        "Uncontested. Stack the chips."),
                      choice("must-deal", "Must flop", "clear_mistake",
                        "No callers means the hand is over.",
                        {betterChoiceId: "won-folds"}),
                      choice("show-anyway", "Show cards", "questionable",
                        "Not required, but flashing is a live habit some use."),
                    ],
                  },
                ],
                // LPT-108: guided-steps suited_ace SoftPulse open-6 then
                // won-folds
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "suited_ace", suitFamily: "suited"},
                  cues: [
                    {press: 1, target: "open-6", kind: "soft_pulse"},
                    {press: 2, target: "won-folds", kind: "soft_pulse"},
                  ],
                },
              }),
              multiStepAct({
                id: "act-01-06-01-scaffolded-multi", order: 3, stage: "scaffolded",
                a11y: "BB calls your open — confirm the flop, then bet top pair.",
                objectives: ["Choose legal actions on more than one street"],
                steps: [
                  {
                    id: "step-01-06-bb-defend",
                    street: "preflop",
                    prompt: "You open BTN to 6. BB calls. Next?",
                    accessibilityText: "Yes — watch the flop next.",
                    choices: [
                      choice("ready-flop", "See flop", "recommended",
                        "Two players; deal three community cards."),
                      choice("already-won", "Already over", "clear_mistake",
                        "A call keeps the hand alive.",
                        {betterChoiceId: "ready-flop"}),
                    ],
                  },
                  {
                    id: "step-01-06-flop-cbet",
                    street: "flop",
                    prompt: "Flop Ace-high rainbow. BB checks. You hold a suited ace.",
                    accessibilityText: "Bet 6 into 13 with top pair.",
                    choices: [
                      choice("cbet", "Bet 6", "recommended",
                        "Top pair bets for value.", {action: "BET", amountBb: 3}),
                      choice("check-back", "Check", "reasonable",
                        "Checking is fine; betting is clearer value.", {action: "CHECK"}),
                      choice("jam-flop", "Jam 100bb", "clear_mistake",
                        "No need to stack off this small pot yet.",
                        {action: "ALL_IN", betterChoiceId: "cbet"}),
                    ],
                  },
                ],
                // LPT-108: scaffolded-multi suited_ace SoftPulse ready-flop then
                // cbet
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "suited_ace", suitFamily: "suited"},
                  cues: [
                    {press: 1, target: "ready-flop", kind: "soft_pulse"},
                    {press: 2, target: "cbet", kind: "soft_pulse"},
                  ],
                },
              }),
              handLabAct({
                id: "act-01-06-01-unguided-lab", order: 4, stage: "scaffolded",
                prompt: "BTN opens to 6. You hold a weak ace offsuit in the big blind.",
                a11y: "Big blind vs button open — call, fold, or jam.",
                objectives: ["Finish without freezing on basic decisions"],
                choices: [
                  choice("fold-bb", "Fold", "reasonable",
                    "Folding a weak ace offsuit is fine; defending is optional this deep.",
                    {action: "FOLD"}),
                  choice("call-bb", "Call 4", "strong",
                    "A call keeps the hand playable in position later.",
                    {action: "CALL"}),
                  choice("shove-bb", "Jam 100bb", "clear_mistake",
                    "Jamming a weak ace offsuit for 100bb is a clear mistake.",
                    {action: "ALL_IN", betterChoiceId: "call-bb"}),
                ],
                lab: {
                  id: "lab-01-06-01-bb-defend",
                  title: "Big blind toy defend",
                  tableSize: 6,
                  heroSeat: 1,
                  smallBlind: 1,
                  bigBlind: 2,
                  startingStackBb: 100,
                  heroCards: ["Ah", "7d"],
                  board: [],
                  scriptedActions: [
                    {seat: 2, street: "preflop", action: "FOLD"},
                    {seat: 3, street: "preflop", action: "FOLD"},
                    {seat: 4, street: "preflop", action: "RAISE", amountBb: 3},
                    {seat: 5, street: "preflop", action: "FOLD"},
                    {seat: 0, street: "preflop", action: "FOLD"},
                  ],
                  decisionPoints: [{
                    id: "dp-bb-vs-btn-open",
                    street: "preflop",
                    prompt: "BTN opens to 6. You hold a weak ace offsuit in the big blind. What do you do?",
                    choices: [
                      choice("fold-bb", "Fold", "reasonable",
                        "Folding a weak ace offsuit is fine; defending is optional this deep.",
                        {action: "FOLD"}),
                      choice("call-bb", "Call 4", "strong",
                        "A call keeps the hand playable in position later.",
                        {action: "CALL"}),
                      choice("shove-bb", "Jam 100bb", "clear_mistake",
                        "Jamming a weak ace offsuit for 100bb is a clear mistake.",
                        {action: "ALL_IN", betterChoiceId: "call-bb"}),
                    ],
                  }],
                },
                // LPT-108: unguided-lab high_card offsuit SoftPulse call-bb
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "high_card", suitFamily: "offsuit"},
                  cues: [{press: 1, target: "call-bb", kind: "soft_pulse"}],
                },
              }),
              multiStepAct({
                id: "act-01-06-01-checkpoint-finish", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                a11y: "Button with offsuit broadway — open, then take the blinds when they fold.",
                objectives: [
                  "Follow a hand from blinds to a terminal state",
                  "Finish without freezing on basic decisions",
                ],
                steps: [
                  {
                    id: "step-01-06-cp-open",
                    street: "preflop",
                    prompt: "Button with offsuit broadway. CO folds. Blinds 1/2.",
                    accessibilityText: "Open to 6 with king-queen offsuit on the button.",
                    choices: [
                      choice("open-kq", "Raise to 6", "recommended",
                        "Strong button open.", {action: "RAISE", amountBb: 3}),
                      choice("fold-kq", "Fold", "clear_mistake",
                        "Do not fold offsuit broadway on the button.",
                        {action: "FOLD", betterChoiceId: "open-kq"}),
                      choice("limp-kq", "Limp", "questionable",
                        "Prefer a raise with offsuit broadway here.", {action: "CALL"}),
                    ],
                  },
                  {
                    id: "step-01-06-cp-end",
                    street: "preflop",
                    prompt: "Both blinds fold. Result?",
                    accessibilityText: "You win the blinds.",
                    choices: [
                      choice("take-down", "Win blinds", "recommended",
                        "Terminal state — pot is yours."),
                      choice("force-flop", "Force flop", "clear_mistake",
                        "No callers, no flop.", {betterChoiceId: "take-down"}),
                    ],
                  },
                ],
                // LPT-108: checkpoint-finish broadway offsuit cues kind none; no
                // pressHints
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "broadway", suitFamily: "offsuit"},
                  cues: [
                    {press: 1, target: "open-kq", kind: "none"},
                    {press: 2, target: "take-down", kind: "none"},
                  ],
                },
              }),
            ],
          }),
          lesson({
            id: L010602, order: 2,
            title: "Section 1 jump check",
            summary: "Quick placement-style check on foundations.",
            objectives: [
              "Confirm hand ranking",
              "Confirm acting order",
              "Confirm legal action",
              "Confirm a complete toy hand",
            ],
            prereq: L010601, remediation: L010201, minutes: 8, band: 2,
            activities: [
              sequenceAct({
                id: "act-01-06-02-jump-ranks", order: 1, stage: "scaffolded", assessmentRole: "jump_test",
                renderer: "compare_rank",
                prompt: "Tap the hands from strongest to weakest.",
                a11y: "Jump test: tap showdown seats strongest to weakest (flush, straight, two pair).",
                objectives: ["Confirm hand ranking"],
                items: [
                  {id: "you", label: "You"},
                  {id: "sam", label: "Sam"},
                  {id: "jo", label: "Jo"},
                ],
                correct: ["you", "sam", "jo"],
                okFeedback: "Flush, straight, two pair.",
                missFeedback: "Flush beats straight; straight beats two pair.",
                // LPT-110: jump-ranks flush+variants cues kind none
                teachSpec: {
                  deal: {
                    mode: "random_in_class",
                    handFamily: "flush",
                    variants: [
                      {id: "var-straight-seat", handFamily: "straight", label: "Straight seat"},
                      {id: "var-two-pair-seat", handFamily: "two_pair", label: "Two pair seat"},
                    ],
                  },
                  cues: [
                    {press: 1, target: "you", kind: "none"},
                    {press: 2, target: "sam", kind: "none"},
                    {press: 3, target: "jo", kind: "none"},
                  ],
                },
              }),
              sequenceAct({
                id: "act-01-06-02-jump-order", order: 2, stage: "scaffolded", assessmentRole: "jump_test",
                prompt: "Pick seats in the order they act.",
                a11y: "Jump test: pick seats in the order they act.",
                objectives: ["Confirm acting order"],
                items: [
                  {id: "j-utg", label: "UTG"},
                  {id: "j-hj", label: "HJ"},
                  {id: "j-co", label: "CO"},
                  {id: "j-btn", label: "BTN"},
                ],
                correct: ["j-utg", "j-hj", "j-co", "j-btn"],
                okFeedback: "UTG → HJ → CO → BTN. Left of big blind first; button last.",
                missFeedback: "UTG, then HJ, CO, and the button.",
                // LPT-110: jump-order none + CO synced cues kind none
                teachSpec: {
                  deal: {mode: "none"},
                  cues: [
                    {press: 1, target: "j-utg", kind: "none"},
                    {press: 2, target: "j-hj", kind: "none"},
                    {press: 3, target: "j-co", kind: "none"},
                    {press: 4, target: "j-btn", kind: "none"},
                  ],
                },
              }),
              actionAct({
                id: "act-01-06-02-jump-legal", order: 3, stage: "scaffolded", assessmentRole: "jump_test",
                prompt: "A bet faces you. Pick the action you cannot take.",
                a11y: "Jump test: check is illegal facing a bet.",
                objectives: ["Confirm legal action"],
                choices: [
                  choice("j-check", "Check", "recommended",
                    "Check is off when a bet faces you.",
                    {action: "CHECK"}),
                  choice("j-call", "Call", "clear_mistake",
                    "Call is legal.", {action: "CALL", betterChoiceId: "j-check"}),
                  choice("j-raise", "Raise", "clear_mistake",
                    "Raise is legal.", {action: "RAISE", betterChoiceId: "j-check"}),
                ],
                // LPT-110: jump-legal fixed QhJd/Td8s2c cue j-check kind none
                teachSpec: {
                  deal: {mode: "fixed", fixedCards: {hero: ["Qh", "Jd"], board: ["Td", "8s", "2c"]}},
                  cues: [{press: 1, target: "j-check", kind: "none"}],
                },
              }),
              multiStepAct({
                id: "act-01-06-02-jump-hand", order: 4, stage: "scaffolded", assessmentRole: "jump_test",
                a11y: "Jump test: complete a tiny button steal hand.",
                objectives: ["Confirm a complete toy hand"],
                steps: [
                  {
                    id: "j-hand-open",
                    street: "preflop",
                    prompt: "Button with a suited ace. Folds to you. Action?",
                    accessibilityText: "Raise to 6 with a suited ace on the button.",
                    choices: [
                      choice("j-open", "Raise to 6", "recommended",
                        "Standard steal-plus open.", {action: "RAISE", amountBb: 3}),
                      choice("j-fold", "Fold", "clear_mistake",
                        "Too playable to fold.", {action: "FOLD", betterChoiceId: "j-open"}),
                    ],
                  },
                  {
                    id: "j-hand-end",
                    street: "preflop",
                    prompt: "Blinds fold. What happened?",
                    accessibilityText: "Confirm the pot is won.",
                    choices: [
                      choice("j-yes", "Won pot", "recommended",
                        "Foundations check complete."),
                      choice("j-no", "Need showdown", "clear_mistake",
                        "No callers means no showdown.", {betterChoiceId: "j-yes"}),
                    ],
                  },
                ],
                // LPT-110: jump-hand suited_ace cues kind none; ATs copy softened
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "suited_ace", suitFamily: "suited"},
                  cues: [
                    {press: 1, target: "j-open", kind: "none"},
                    {press: 2, target: "j-yes", kind: "none"},
                  ],
                },
              }),
            ],
          }),
        ]),
    ],
  };
}

/** Last lesson id in section 1 (for section 2 prereq chain). */
export const SECTION_ONE_EXIT_LESSON = "lesson-01-06-02-section-one-jump";

/** @returns {object} Section 2 — Rules Known / Home Games */
export function buildSectionTwo() {
  const prev = SECTION_ONE_EXIT_LESSON;
  const L020101 = "lesson-02-01-01-position-labels";
  const L020102 = "lesson-02-01-02-acting-order";
  const L020201 = "lesson-02-02-01-hand-families";
  const L020301 = "lesson-02-03-01-open-fold";
  const L020401 = "lesson-02-04-01-facing-raise";
  const L020501 = "lesson-02-05-01-effective-stack";
  const L020601 = "lesson-02-06-01-live-habits";
  const L020701 = "lesson-02-07-01-baseline-full-hand";
  const L020702 = "lesson-02-07-02-section-two-jump";

  return {
    id: "sec-02-rules-known",
    order: 2,
    title: "Rules Known / Home Games",
    summary: "Play a disciplined baseline instead of guessing.",
    experienceBand: "rules_known",
    units: [
      unit("unit-02-01-position-power", 1, "Position is power",
        "EP through blinds, and who acts when.", [
          lesson({
            id: L020101, order: 1,
            title: "Position labels",
            summary: "Name EP, HJ, CO, BTN, SB, and BB.",
            objectives: [
              "Label EP, HJ, CO, and BTN",
              "Label SB and BB",
              "Prefer later seats when choosing hands",
            ],
            prereq: prev, remediation: prev, band: 2,
            activities: [
              dialogue("act-02-01-01-explain-pos", 1,
                "Later seats see more. That is the whole edge.",
                {objectives: ["Prefer later seats when choosing hands"]}),
              selectAct({
                id: "act-02-01-01-guided-btn", order: 2, stage: "guided",
                prompt: "Tap who acts last postflop.",
                a11y: "Tap the button seat — last to act after the flop.",
                objectives: ["Label EP, HJ, CO, and BTN"],
                hint: "Look for the D chip. Button closes postflop action.",
                choices: [
                  choice("pos-btn", "BTN", "recommended",
                    "Button is last to act postflop."),
                  choice("pos-bb", "BB", "clear_mistake",
                    "Big blind acts early postflop if still in.",
                    {betterChoiceId: "pos-btn"}),
                  choice("pos-ep", "EP", "clear_mistake",
                    "Early position acts first.", {betterChoiceId: "pos-btn"}),
                ],
                // LPT-112: guided-btn SoftPulse pos-btn deal none
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "pos-btn", kind: "soft_pulse"}]},
              }),
              selectAct({
                id: "act-02-01-01-scaffolded-blinds", order: 3, stage: "scaffolded",
                prompt: "Tap a seat that posts a forced bet every hand.",
                a11y: "Tap the small blind or big blind seat.",
                objectives: ["Label SB and BB"],
                choices: [
                  choice("sb-bb", "SB or BB", "recommended",
                    "Those two post every hand."),
                  choice("btn-bb", "BTN", "clear_mistake",
                    "Button does not post a blind.", {betterChoiceId: "sb-bb"}),
                  choice("ep-only", "EP", "clear_mistake",
                    "Early position is voluntary action.", {betterChoiceId: "sb-bb"}),
                ],
                // LPT-112: scaffolded-blinds SoftPulse sb-bb deal none
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "sb-bb", kind: "soft_pulse"}]},
              }),
              selectAct({
                id: "act-02-01-01-unguided-co", order: 4, stage: "scaffolded",
                prompt: "Tap the seat right before the button.",
                a11y: "Tap the cutoff seat on the six-max table.",
                objectives: ["Label EP, HJ, CO, and BTN"],
                choices: [
                  choice("label-co", "Cutoff (CO)", "recommended",
                    "Cutoff sits right before the button."),
                  choice("label-hj", "Hijack (HJ)", "clear_mistake",
                    "Hijack is one earlier than cutoff.", {betterChoiceId: "label-co"}),
                  choice("label-ep", "Early position", "clear_mistake",
                    "EP is near the blinds, not near the button.",
                    {betterChoiceId: "label-co"}),
                ],
                // LPT-112: unguided-co SoftPulse label-co deal none
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "label-co", kind: "soft_pulse"}]},
              }),
              selectAct({
                id: "act-02-01-01-checkpoint-edge", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Same hand — tap where it is stronger to play.",
                a11y: "Tap the button rather than early position.",
                objectives: ["Prefer later seats when choosing hands"],
                choices: [
                  choice("prefer-btn", "On the button", "recommended",
                    "More information, last action."),
                  choice("prefer-ep", "Under the gun", "clear_mistake",
                    "Early seats play fewer hands.", {betterChoiceId: "prefer-btn"}),
                  choice("same-always", "Seat never matters", "clear_mistake",
                    "Position changes every decision.", {betterChoiceId: "prefer-btn"}),
                ],
                // LPT-112: checkpoint-edge prefer-btn kind none; no pressHints
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "prefer-btn", kind: "none"}]},
              }),
            ],
          }),
          lesson({
            id: L020102, order: 2,
            title: "Acting order",
            summary: "Track who acts preflop and postflop.",
            objectives: [
              "Order preflop action after the blinds",
              "Order postflop action from the button",
              "Wait for your turn before acting",
            ],
            prereq: L020101, remediation: L020101, band: 2,
            activities: [
              dialogue("act-02-01-02-explain-order", 1,
                "Preflop starts left of the big blind. Postflop starts left of the button.",
                {
                  objectives: ["Order preflop action after the blinds"],
                  okFeedback: "UTG → HJ → CO → BTN.",
                }),
              sequenceAct({
                id: "act-02-01-02-guided-pre", order: 2, stage: "guided",
                prompt: "Order CO, BTN, SB to act preflop after an open folds to them.",
                a11y: "Order cutoff, button, then small blind preflop.",
                objectives: ["Order preflop action after the blinds"],
                items: [
                  {id: "ord-co", label: "CO"},
                  {id: "ord-btn", label: "BTN"},
                  {id: "ord-sb", label: "SB"},
                ],
                correct: ["ord-co", "ord-btn", "ord-sb"],
                okFeedback: "Cutoff, button, then small blind.",
                missFeedback: "Move toward the blinds after the button.",
                // LPT-115: SoftPulse ord-co→ord-btn→ord-sb / post-sb→post-btn;
                // wait soft_pulse; checkpoint last-btn kind none
                teachSpec: {
                  deal: {mode: "none"},
                  cues: [
                    {press: 1, target: "ord-co", kind: "soft_pulse"},
                    {press: 2, target: "ord-btn", kind: "soft_pulse"},
                    {press: 3, target: "ord-sb", kind: "soft_pulse"},
                  ],
                },
              }),
              sequenceAct({
                id: "act-02-01-02-scaffolded-post", order: 3, stage: "scaffolded",
                prompt: "Heads-up flop: SB vs BTN. Who acts first?",
                a11y: "Order small blind before button postflop.",
                objectives: ["Order postflop action from the button"],
                items: [
                  {id: "post-sb", label: "SB"},
                  {id: "post-btn", label: "BTN"},
                ],
                correct: ["post-sb", "post-btn"],
                okFeedback: "Small blind first; button last.",
                missFeedback: "Left of the button acts first.",
                // LPT-115: scaffolded-post SoftPulse after Hint; deal.mode none
                // on all four
                teachSpec: {
                  deal: {mode: "none"},
                  cues: [
                    {press: 1, target: "post-sb", kind: "soft_pulse"},
                    {press: 2, target: "post-btn", kind: "soft_pulse"},
                  ],
                },
              }),
              selectAct({
                id: "act-02-01-02-unguided-wait", order: 4, stage: "scaffolded",
                prompt: "Action is on UTG. You are on the button. What do you do?",
                a11y: "Wait for earlier seats before acting.",
                objectives: ["Wait for your turn before acting"],
                choices: [
                  choice("wait", "Wait — do not act yet", "recommended",
                    "Acting out of turn creates messes."),
                  choice("open-early", "Open now to save time", "clear_mistake",
                    "Never skip earlier seats.", {betterChoiceId: "wait"}),
                  choice("flash-cards", "Show your cards while waiting", "clear_mistake",
                    "Protect your cards; still wait.", {betterChoiceId: "wait"}),
                ],
                // LPT-115: unguided SoftPulse wait; checkpoint no pressHints
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "wait", kind: "soft_pulse"}]},
              }),
              selectAct({
                id: "act-02-01-02-checkpoint-full", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Six-max flop, everyone in. Who acts last?",
                a11y: "Confirm button acts last postflop multiway.",
                objectives: [
                  "Order postflop action from the button",
                  "Wait for your turn before acting",
                ],
                choices: [
                  choice("last-btn", "BTN", "recommended",
                    "Button closes postflop action."),
                  choice("last-bb", "BB", "clear_mistake",
                    "BB acts early if still live.", {betterChoiceId: "last-btn"}),
                  choice("last-utg", "UTG", "clear_mistake",
                    "UTG is early.", {betterChoiceId: "last-btn"}),
                ],
                // LPT-115: checkpoint last-btn kind none
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "last-btn", kind: "none"}]},
              }),
            ],
          }),
        ]),
      unit("unit-02-02-starting-hands", 2, "Starting-hand families",
        "Pairs, broadways, suited aces, suited connectors, trash.", [
          lesson({
            id: L020201, order: 1,
            title: "Hand families",
            summary: "Sort starting hands into useful families.",
            objectives: [
              "Recognize pocket pairs",
              "Recognize broadways and suited aces",
              "Recognize suited connectors versus offsuit trash",
            ],
            prereq: L020102, remediation: L020102, band: 2,
            activities: [
              dialogue("act-02-02-01-explain-families", 1,
                "Pairs, broadways, suited aces, connectors — trash is everything else.",
                {objectives: ["Recognize pocket pairs"]}),
              // Teach-by-doing: see holes on felt → tap the family name
              // (same direction as the S2 jump family check).
              selectAct({
                id: "act-02-02-01-guided-pair", order: 2, stage: "guided",
                prompt: "Name the family for your holes.",
                a11y: "Look at the pocket pair on the felt — tap Pocket pair.",
                objectives: ["Recognize pocket pairs"],
                hint: "Matching ranks in the hole.",
                choices: [
                  choice("hf-pair", "Pocket pair", "recommended",
                    "Matching ranks — pocket pair."),
                  choice("hf-suited-ace", "Suited ace", "clear_mistake",
                    "Suited ace needs an ace with a suited kicker.",
                    {betterChoiceId: "hf-pair"}),
                  choice("hf-broadway", "Broadway", "clear_mistake",
                    "Broadway needs both cards ten-or-better.",
                    {betterChoiceId: "hf-pair"}),
                ],
                // LPT-119: random_in_class
                // pair/broadway/connector+suited/trash+offsuit
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "pair", suitFamily: "pair"},
                  cues: [{press: 1, target: "hf-pair", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-02-02-01-scaffolded-broadway", order: 3, stage: "scaffolded",
                prompt: "Name the family for your holes.",
                a11y: "Look at the broadway holes on the felt — tap Broadway.",
                objectives: ["Recognize broadways and suited aces"],
                choices: [
                  choice("hf-broadway", "Broadway", "recommended",
                    "Both cards ten-or-better — broadway."),
                  choice("hf-pair", "Pocket pair", "clear_mistake",
                    "Ranks do not match — not a pair.",
                    {betterChoiceId: "hf-broadway"}),
                  choice("hf-trash", "Offsuit trash", "clear_mistake",
                    "Ace-king is a premium broadway, not trash.",
                    {betterChoiceId: "hf-broadway"}),
                ],
                // LPT-119: SoftPulse hf-pair/hf-broadway/hf-sc; checkpoint
                // hf-trash kind none
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "broadway"},
                  cues: [{press: 1, target: "hf-broadway", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-02-02-01-unguided-sc", order: 4, stage: "scaffolded",
                prompt: "Name the family for your holes.",
                a11y: "Look at seven-six suited on the felt — tap Suited connector.",
                objectives: ["Recognize suited connectors versus offsuit trash"],
                choices: [
                  choice("hf-sc", "Suited connector", "recommended",
                    "Connected and suited."),
                  choice("hf-offsuit-conn", "Offsuit connector", "questionable",
                    "Connected but offsuit — weaker family."),
                  choice("hf-trash", "Offsuit trash", "clear_mistake",
                    "Connected and suited is a real family, not trash.",
                    {betterChoiceId: "hf-sc"}),
                ],
                // LPT-119: isomorphic preflop redeals in family
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "connector", suitFamily: "suited"},
                  cues: [{press: 1, target: "hf-sc", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-02-02-01-checkpoint-trash", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Name the family for your holes.",
                a11y: "Look at seven-two offsuit on the felt — tap Offsuit trash.",
                objectives: ["Recognize suited connectors versus offsuit trash"],
                choices: [
                  choice("hf-trash", "Offsuit trash", "recommended",
                    "Worst starting shape — fold early."),
                  choice("hf-pair", "Pocket pair", "clear_mistake",
                    "Ranks do not match — premium pairs look like matching face cards.",
                    {betterChoiceId: "hf-trash"}),
                  choice("hf-suited-ace", "Suited ace", "clear_mistake",
                    "Suited ace has playability — this is offsuit junk.",
                    {betterChoiceId: "hf-trash"}),
                ],
                // LPT-119: no pressHints on checkpoint
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "trash", suitFamily: "offsuit"},
                  cues: [{press: 1, target: "hf-trash", kind: "none"}],
                },
              }),
            ],
          }),
        ]),
      unit("unit-02-03-open-fold", 3, "Open or fold",
        "Position-dependent baseline opens and live sizes.", [
          lesson({
            id: L020301, order: 1,
            title: "Open or fold baseline",
            summary: "Tighten early; open wider on the button at live sizes.",
            objectives: [
              "Fold trash from early position",
              "Open strong hands for a live size",
              "Widen opens on the button",
            ],
            prereq: L020201, remediation: L020201, band: 2,
            activities: [
              dialogue("act-02-03-01-explain-open", 1,
                "Who opens — and how wide. Position shapes the first action.",
                {objectives: ["Fold trash from early position"]}),
              actionAct({
                id: "act-02-03-01-guided-utg", order: 2, stage: "guided",
                prompt: "You are UTG with trash offsuit at 1/2. What do you do?",
                a11y: "Fold seven-two offsuit under the gun.",
                objectives: ["Fold trash from early position"],
                hint: "Trash from early position is an easy fold.",
                choices: [
                  choice("fold", "Fold", "recommended",
                    "Trash from early position is an easy fold.", {action: "FOLD"}),
                  choice("open-six", "Open to 6", "clear_mistake",
                    "Seventy-two offsuit is not an open from UTG.",
                    {action: "RAISE", amountBb: 3, betterChoiceId: "fold"}),
                  choice("limp", "Limp", "questionable",
                    "Limping junk builds multiway pots you do not want.",
                    {action: "CALL"}),
                ],
                // LPT-122: teachSpec authored
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "trash", suitFamily: "offsuit"},
                  cues: [{press: 1, target: "fold", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-02-03-01-scaffolded-qq", order: 3, stage: "scaffolded",
                prompt: "UTG with a premium pair at 1/2. Action?",
                a11y: "Open queens to a live size.",
                objectives: ["Open strong hands for a live size"],
                choices: [
                  choice("open-qq", "Open to 6", "recommended",
                    "Premium pair opens.", {action: "RAISE", amountBb: 3}),
                  choice("limp-qq", "Limp", "questionable",
                    "Limping premiums invites chaos.", {action: "CALL"}),
                  choice("fold-qq", "Fold", "clear_mistake",
                    "Never fold queens here.", {action: "FOLD", betterChoiceId: "open-qq"}),
                ],
                // LPT-122: SoftPulse cues + deal
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "pair"},
                  cues: [{press: 1, target: "open-qq", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-02-03-01-unguided-btn", order: 4, stage: "scaffolded",
                prompt: "Folds to you on the button with K9s. Action?",
                a11y: "Open king-nine suited on the button.",
                objectives: ["Widen opens on the button"],
                choices: [
                  choice("open-k9s", "Open to 6", "recommended",
                    "Button can open this suited king.", {action: "RAISE", amountBb: 3}),
                  choice("fold-k9s", "Fold", "questionable",
                    "Tight is okay, but button opens wider than EP.", {action: "FOLD"}),
                  choice("limp-k9s", "Limp", "clear_mistake",
                    "Prefer a raise on the button.",
                    {action: "CALL", betterChoiceId: "open-k9s"}),
                ],
                // LPT-122: checkpoint quiet
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "high_card", suitFamily: "suited"},
                  cues: [{press: 1, target: "open-k9s", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-02-03-01-checkpoint-hj", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "HJ with ATo. Folds to you. Action?",
                a11y: "Open ace-ten offsuit from the hijack.",
                objectives: [
                  "Open strong hands for a live size",
                  "Widen opens on the button",
                ],
                choices: [
                  choice("open-ato", "Open to 6", "recommended",
                    "Solid HJ open.", {action: "RAISE", amountBb: 3}),
                  choice("fold-ato", "Fold", "reasonable",
                    "Folding is cautious; opening is the baseline.", {action: "FOLD"}),
                  choice("jam-ato", "Jam 100bb", "clear_mistake",
                    "No need to stack off preflop here.",
                    {action: "ALL_IN", betterChoiceId: "open-ato"}),
                ],
                // LPT-122: wave synced
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "broadway", suitFamily: "offsuit"},
                  cues: [{press: 1, target: "open-ato", kind: "none"}],
                },
              }),
            ],
          }),
        ]),
      unit("unit-02-04-facing-raise", 4, "Facing a raise",
        "Fold, call, or value 3-bet with a plan.", [
          lesson({
            id: L020401, order: 1,
            title: "Versus an open",
            summary: "Respond to a raise without guessing.",
            objectives: [
              "Fold weak hands to an open",
              "Call with playable hands in position",
              "Value 3-bet strong hands",
            ],
            prereq: L020301, remediation: L020301, band: 2,
            activities: [
              dialogue("act-02-04-01-explain-vs", 1,
                "Weak hands fold. Playable hands call. Strong hands make it more.",
                {objectives: ["Fold weak hands to an open"]}),
              actionAct({
                id: "act-02-04-01-guided-fold", order: 2, stage: "guided",
                prompt: "UTG opens to 6. You have junk offsuit in the big blind. Action?",
                a11y: "Fold jack-three offsuit versus an open.",
                objectives: ["Fold weak hands to an open"],
                hint: "Dominated junk folds.",
                choices: [
                  choice("fold-j3", "Fold", "recommended",
                    "No defend with junk offsuit.", {action: "FOLD"}),
                  choice("call-j3", "Call", "clear_mistake",
                    "Too weak and dominated.", {action: "CALL", betterChoiceId: "fold-j3"}),
                  choice("3bet-j3", "3-bet to 18", "clear_mistake",
                    "Do not invent a bluff with junk yet.",
                    {action: "RAISE", amountBb: 9, betterChoiceId: "fold-j3"}),
                ],
                // LPT-125: teachSpec authored
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "trash", suitFamily: "offsuit"},
                  cues: [{press: 1, target: "fold-j3", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-02-04-01-scaffolded-call", order: 3, stage: "scaffolded",
                prompt: "CO opens to 6. You have 87s on the button. Action?",
                a11y: "Call with suited connectors on the button.",
                objectives: ["Call with playable hands in position"],
                choices: [
                  choice("call-87s", "Call", "recommended",
                    "Suited connector in position is a call.", {action: "CALL"}),
                  choice("fold-87s", "Fold", "reasonable",
                    "Folding is tight; calling is the baseline.", {action: "FOLD"}),
                  choice("3bet-87s", "3-bet to 18", "questionable",
                    "Sometimes fine later; baseline is call.",
                    {action: "RAISE", amountBb: 9}),
                ],
                // LPT-125: SoftPulse cues + deal
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "connector", suitFamily: "suited"},
                  cues: [{press: 1, target: "call-87s", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-02-04-01-unguided-3bet", order: 4, stage: "scaffolded",
                prompt: "BTN opens to 6. You have a premium pair in the small blind. Action?",
                a11y: "Value three-bet kings.",
                objectives: ["Value 3-bet strong hands"],
                choices: [
                  choice("3bet-kk", "3-bet to 18", "recommended",
                    "Kings want a bigger pot.", {action: "RAISE", amountBb: 9}),
                  choice("call-kk", "Call", "questionable",
                    "Flatting traps sometimes; value 3-bet is clearer.",
                    {action: "CALL"}),
                  choice("fold-kk", "Fold", "clear_mistake",
                    "Never fold kings here.", {action: "FOLD", betterChoiceId: "3bet-kk"}),
                ],
                // LPT-125: checkpoint quiet
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "pair"},
                  cues: [{press: 1, target: "3bet-kk", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-02-04-01-checkpoint-aq", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "HJ opens to 6. You have AQs on the CO. Action?",
                a11y: "Value three-bet ace-queen suited.",
                objectives: [
                  "Call with playable hands in position",
                  "Value 3-bet strong hands",
                ],
                choices: [
                  choice("3bet-aqs", "3-bet to 18", "recommended",
                    "Strong suited broadway — value 3-bet.",
                    {action: "RAISE", amountBb: 9}),
                  choice("call-aqs", "Call", "reasonable",
                    "Calling is playable; 3-bet is cleaner.", {action: "CALL"}),
                  choice("fold-aqs", "Fold", "clear_mistake",
                    "Too strong to fold.", {action: "FOLD", betterChoiceId: "3bet-aqs"}),
                ],
                // LPT-125: wave synced
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "broadway", suitFamily: "suited"},
                  cues: [{press: 1, target: "3bet-aqs", kind: "none"}],
                },
              }),
            ],
          }),
        ]),
      unit("unit-02-05-stacks", 5, "Stacks in big blinds",
        "Effective stack and 50/100/200 BB intuition.", [
          lesson({
            id: L020501, order: 1,
            title: "Effective stacks",
            summary: "Measure stacks in big blinds and use the shorter one.",
            objectives: [
              "Convert chips to big blinds",
              "Use the shorter stack as effective",
              "Sense 50bb vs 100bb vs 200bb depth",
            ],
            prereq: L020401, remediation: L020401, band: 2,
            activities: [
              dialogue("act-02-05-01-explain-bb", 1,
                "Count stacks in big blinds. The shorter stack sets the ceiling.",
                {objectives: ["Convert chips to big blinds"]}),
              selectAct({
                id: "act-02-05-01-guided-convert", order: 2, stage: "guided",
                prompt: "Blinds 1/2. You have 200 chips. How many big blinds?",
                a11y: "Convert 200 chips at 1/2 into big blinds.",
                objectives: ["Convert chips to big blinds"],
                choices: [
                  choice("bb-100", "100bb", "recommended",
                    "200 / 2 = 100 big blinds."),
                  choice("bb-50", "50bb", "clear_mistake",
                    "Divide your chips by the big blind.", {betterChoiceId: "bb-100"}),
                  choice("bb-200", "200bb", "clear_mistake",
                    "Divide your chips by the big blind.", {betterChoiceId: "bb-100"}),
                ],
                // LPT-128: teachSpec authored
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "bb-100", kind: "soft_pulse"}]},
              }),
              selectAct({
                id: "act-02-05-01-scaffolded-eff", order: 3, stage: "scaffolded",
                prompt: "You have 150bb. Villain has 60bb. Effective stack?",
                a11y: "Choose the shorter stack as effective.",
                objectives: ["Use the shorter stack as effective"],
                choices: [
                  choice("eff-60", "60bb", "recommended",
                    "You can only win what they have."),
                  choice("eff-150", "150bb", "clear_mistake",
                    "Your extra chips are not in play versus them.",
                    {betterChoiceId: "eff-60"}),
                  choice("eff-210", "210bb combined", "clear_mistake",
                    "Effective is the minimum, not the sum.",
                    {betterChoiceId: "eff-60"}),
                ],
                // LPT-128: SoftPulse cues + deal
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "eff-60", kind: "soft_pulse"}]},
              }),
              selectAct({
                id: "act-02-05-01-unguided-depth", order: 4, stage: "scaffolded",
                prompt: "Which depth plays closest to a short-stack shove game?",
                a11y: "Identify 50bb as shallower than 100 or 200.",
                objectives: ["Sense 50bb vs 100bb vs 200bb depth"],
                choices: [
                  choice("depth-50", "50bb", "recommended",
                    "Shallower — stack-off pressure shows up sooner."),
                  choice("depth-100", "100bb", "questionable",
                    "Standard live depth; still room to maneuver."),
                  choice("depth-200", "200bb", "clear_mistake",
                    "Deep — more postflop room, not shove-or-fold.",
                    {betterChoiceId: "depth-50"}),
                ],
                // LPT-128: checkpoint quiet
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "depth-50", kind: "soft_pulse"}]},
              }),
              selectAct({
                id: "act-02-05-01-checkpoint-200", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Blinds 2/5. You buy in for 1000 chips. Stack in big blinds?",
                a11y: "Convert a 1000 chip buy-in at 2/5 to big blinds.",
                objectives: [
                  "Convert chips to big blinds",
                  "Sense 50bb vs 100bb vs 200bb depth",
                ],
                choices: [
                  choice("bb-200", "200bb", "recommended",
                    "1000 / 5 = 200 big blinds — deep."),
                  choice("bb-100", "100bb", "clear_mistake",
                    "Divide buy-in by the big blind (5).", {betterChoiceId: "bb-200"}),
                  choice("bb-500", "500bb", "clear_mistake",
                    "Divide buy-in by the big blind (5).", {betterChoiceId: "bb-200"}),
                ],
                // LPT-128: wave synced
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "bb-200", kind: "none"}]},
              }),
            ],
          }),
        ]),
      unit("unit-02-06-table-habits", 6, "First live table habits",
        "Follow action, speak clearly, protect cards, act in turn.", [
          lesson({
            id: L020601, order: 1,
            title: "Live table habits",
            summary: "Basic live room discipline for every hand.",
            objectives: [
              "Follow the action before deciding",
              "Verbalize actions clearly",
              "Protect cards and avoid acting out of turn",
            ],
            prereq: L020501, remediation: L020501, band: 2,
            activities: [
              dialogue("act-02-06-01-explain-habits", 1,
                "Watch the action. Say your action. Cover your cards. Wait your turn.",
                {
                  objectives: ["Follow the action before deciding"],
                  // LPT-199: short Nice! why — not accessibilityText / idle ask.
                  okFeedback: "Watch → Say → Cover → Wait.",
                  // LPT-131: teachSpec authored
                  teachSpec: {
                    deal: {mode: "none"},
                    cues: [
                      {press: 1, target: "WATCH", kind: "soft_pulse"},
                      {press: 2, target: "SAY", kind: "soft_pulse"},
                      {press: 3, target: "COVER", kind: "soft_pulse"},
                      {press: 4, target: "WAIT", kind: "soft_pulse"},
                    ],
                  },
                }),
              selectAct({
                id: "act-02-06-01-guided-follow", order: 2, stage: "guided",
                prompt: "Two seats act before you. What first?",
                a11y: "Follow earlier actions before choosing yours.",
                objectives: ["Follow the action before deciding"],
                hint: "Information first.",
                choices: [
                  choice("watch", "Watch what they do, then decide", "recommended",
                    "Action informs your choice."),
                  choice("look-away", "Stare at your phone until it is your turn",
                    "clear_mistake",
                    "You will miss bets and raises.", {betterChoiceId: "watch"}),
                  choice("decide-now", "Decide your action before they act", "questionable",
                    "Have a plan, but update with their actions."),
                ],
                // LPT-131: SoftPulse cues + deal
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "watch", kind: "soft_pulse"}]},
              }),
              selectAct({
                id: "act-02-06-01-scaffolded-verbal", order: 3, stage: "scaffolded",
                prompt: "You want to raise. Clearest live choice?",
                a11y: "Verbalize a raise clearly.",
                objectives: ["Verbalize actions clearly"],
                choices: [
                  choice("say-raise", "Say \"raise\" and put out the chips", "recommended",
                    "Clear words beat silent chip slides."),
                  choice("silent-toss", "Toss chips without a word", "questionable",
                    "Risky — dealers may mishear the amount."),
                  choice("tap-table", "Tap the table then shove a stack", "clear_mistake",
                    "A tap looks like a check.", {betterChoiceId: "say-raise"}),
                ],
                // LPT-131: checkpoint quiet
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "say-raise", kind: "soft_pulse"}]},
              }),
              selectAct({
                id: "act-02-06-01-unguided-protect", order: 4, stage: "scaffolded",
                prompt: "Your cards sit near the muck. Best habit?",
                a11y: "Protect hole cards with a chip or hand.",
                objectives: ["Protect cards and avoid acting out of turn"],
                choices: [
                  choice("chip-on-cards", "Keep a chip or hand on your cards", "recommended",
                    "Protected cards do not get scooped."),
                  choice("spread-out", "Spread them face-up for the camera", "clear_mistake",
                    "Keep them private and covered.", {betterChoiceId: "chip-on-cards"}),
                  choice("leave-loose", "Leave them loose near the dealer", "clear_mistake",
                    "Loose cards get killed.", {betterChoiceId: "chip-on-cards"}),
                ],
                // LPT-131: wave synced
                teachSpec: {
                  deal: {mode: "none"},
                  cues: [{press: 1, target: "chip-on-cards", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-02-06-01-checkpoint-oot", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Action is two seats left. You toss in a raise early. Problem?",
                a11y: "Recognize acting out of turn.",
                objectives: [
                  "Protect cards and avoid acting out of turn",
                  "Follow the action before deciding",
                ],
                choices: [
                  choice("oot-bad", "You acted out of turn", "recommended",
                    "Wait. Out-of-turn action can be binding or pulled back."),
                  choice("oot-fine", "Faster play is always rewarded", "clear_mistake",
                    "Speed does not beat order.", {betterChoiceId: "oot-bad"}),
                  choice("oot-dealer", "Dealer should have stopped earlier seats",
                    "clear_mistake",
                    "Your job is still to wait.", {betterChoiceId: "oot-bad"}),
                ],
                // LPT-131
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "oot-bad", kind: "none"}]},
              }),
            ],
          }),
        ]),
      unit("unit-02-07-baseline-checkpoint", 7, "Baseline full-hand checkpoint",
        "Full-ring baseline decisions and section jump.", [
          lesson({
            id: L020701, order: 1,
            title: "Full-ring baseline hand",
            summary: "Apply open/fold and facing-raise skills on a full ring.",
            objectives: [
              "Make a baseline open on a full ring",
              "Respond to a raise with a planned action",
              "Keep live habits while deciding",
            ],
            prereq: L020601, remediation: L020301, minutes: 10, band: 2,
            activities: [
              dialogue("act-02-07-01-explain-full", 1,
                "Nine seats. Same rules. Position still runs the show.",
                {objectives: ["Make a baseline open on a full ring"]}),
              actionAct({
                id: "act-02-07-01-guided-ep", order: 2, stage: "guided",
                prompt: "Nine-handed. UTG with suited broadway. Action?",
                a11y: "Open ace-jack suited under the gun full ring.",
                objectives: ["Make a baseline open on a full ring"],
                hint: "Suited broadway opens from early seats.",
                choices: [
                  choice("open-ajs", "Open to 6", "recommended",
                    "Standard full-ring early open.", {action: "RAISE", amountBb: 3}),
                  choice("fold-ajs", "Fold", "questionable",
                    "Tight, but suited broadway is an open.", {action: "FOLD"}),
                  choice("limp-ajs", "Limp", "clear_mistake",
                    "Raise or fold — do not limp.",
                    {action: "CALL", betterChoiceId: "open-ajs"}),
                ],
                // LPT-135: teachSpec authored
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "broadway", suitFamily: "suited"},
                  cues: [{press: 1, target: "open-ajs", kind: "soft_pulse"}],
                },
              }),
              actionAct({
                id: "act-02-07-01-scaffolded-vs", order: 3, stage: "scaffolded",
                prompt: "UTG opens to 6. You have 22 on the button. Action?",
                a11y: "Call a small pair on the button versus an open.",
                objectives: ["Respond to a raise with a planned action"],
                choices: [
                  choice("call-22", "Call", "recommended",
                    "Set-mine in position at a friendly price.", {action: "CALL"}),
                  choice("fold-22", "Fold", "reasonable",
                    "Folding pairs is okay if stacks are awkward; call is baseline.",
                    {action: "FOLD"}),
                  choice("3bet-22", "3-bet to 18", "questionable",
                    "Sometimes as a bluff later — not the baseline yet.",
                    {action: "RAISE", amountBb: 9}),
                ],
                // LPT-135: SoftPulse cues + deal
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "pair"},
                  cues: [{press: 1, target: "call-22", kind: "soft_pulse"}],
                },
              }),
              handLabAct({
                id: "act-02-07-01-unguided-lab", order: 4, stage: "scaffolded",
                prompt: "Full ring. Decide versus a cutoff open.",
                a11y: "Full-ring hand lab: button versus cutoff open.",
                objectives: [
                  "Respond to a raise with a planned action",
                  "Keep live habits while deciding",
                ],
                choices: [
                  choice("lab-fold", "Fold", "clear_mistake",
                    "Offsuit broadway on the button calls or 3-bets; folding is too tight.",
                    {action: "FOLD", betterChoiceId: "lab-call"}),
                  choice("lab-call", "Call", "reasonable",
                    "Calling keeps offsuit broadway in position.", {action: "CALL"}),
                  choice("lab-3bet", "3-bet to 18", "recommended",
                    "Strong offsuit broadway — value 3-bet is clean.",
                    {action: "RAISE", amountBb: 9}),
                ],
                lab: {
                  id: "lab-02-07-01-full-ring-btn",
                  title: "Full-ring button versus cutoff",
                  tableSize: 9,
                  heroSeat: 7,
                  smallBlind: 1,
                  bigBlind: 2,
                  startingStackBb: 100,
                  heroCards: ["Kh", "Qd"],
                  board: [],
                  scriptedActions: [
                    {seat: 2, street: "preflop", action: "FOLD"},
                    {seat: 3, street: "preflop", action: "FOLD"},
                    {seat: 4, street: "preflop", action: "FOLD"},
                    {seat: 5, street: "preflop", action: "FOLD"},
                    {seat: 6, street: "preflop", action: "RAISE", amountBb: 3},
                  ],
                  decisionPoints: [{
                    id: "dp-btn-vs-co",
                    street: "preflop",
                    prompt: "CO opens to 6. You hold offsuit broadway on the button. Action?",
                    choices: [
                      choice("lab-fold", "Fold", "clear_mistake",
                        "Offsuit broadway on the button calls or 3-bets; folding is too tight.",
                        {action: "FOLD", betterChoiceId: "lab-call"}),
                      choice("lab-call", "Call", "reasonable",
                        "Calling keeps offsuit broadway in position.", {action: "CALL"}),
                      choice("lab-3bet", "3-bet to 18", "recommended",
                        "Strong offsuit broadway — value 3-bet is clean.",
                        {action: "RAISE", amountBb: 9}),
                    ],
                  }],
                },
                // LPT-135: checkpoint quiet
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "broadway", suitFamily: "offsuit"},
                  cues: [{press: 1, target: "lab-3bet", kind: "soft_pulse"}],
                },
              }),
              selectAct({
                id: "act-02-07-01-checkpoint-habit", order: 5, stage: "scaffolded", assessmentRole: "checkpoint",
                prompt: "Full ring. Action two seats left. Your cards are uncovered. Fix?",
                a11y: "Protect cards and wait for action on a full ring.",
                objectives: ["Keep live habits while deciding"],
                choices: [
                  choice("cover-wait", "Cover your cards and wait your turn", "recommended",
                    "Habits first, then the decision."),
                  choice("act-now", "Announce fold immediately to speed up", "clear_mistake",
                    "Out of turn and uncovered.", {betterChoiceId: "cover-wait"}),
                  choice("leave-cards", "Leave cards bare so the table can see you are folding",
                    "clear_mistake",
                    "Never expose live cards.", {betterChoiceId: "cover-wait"}),
                ],
                // LPT-135: wave synced
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "cover-wait", kind: "none"}]},
              }),
            ],
          }),
          lesson({
            id: L020702, order: 2,
            title: "Baseline jump check",
            summary: "Placement-style check on baseline skills.",
            objectives: [
              "Confirm position labels",
              "Confirm starting-hand family",
              "Confirm open or fold",
              "Confirm facing a raise",
              "Confirm effective stack",
            ],
            prereq: L020701, remediation: L020101, minutes: 8, band: 2,
            activities: [
              selectAct({
                id: "act-02-07-02-jump-pos", order: 1, stage: "scaffolded", assessmentRole: "jump_test",
                prompt: "Seat right before the button?",
                a11y: "Jump test: cutoff label.",
                objectives: ["Confirm position labels"],
                choices: [
                  choice("j2-co", "Cutoff", "recommended", "CO sits before the button."),
                  choice("j2-hj", "Hijack", "clear_mistake",
                    "Hijack is one earlier.", {betterChoiceId: "j2-co"}),
                  choice("j2-sb", "Small blind", "clear_mistake",
                    "Blinds are left of the button.", {betterChoiceId: "j2-co"}),
                ],
                // LPT-137
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "j2-co", kind: "none"}]},
              }),
              selectAct({
                id: "act-02-07-02-jump-family", order: 2, stage: "scaffolded", assessmentRole: "jump_test",
                prompt: "These holes belong to which family?",
                a11y: "Jump test: suited ace family.",
                objectives: ["Confirm starting-hand family"],
                choices: [
                  choice("j2-sa", "Suited ace", "recommended", "Ace with a suited kicker."),
                  choice("j2-pair", "Pocket pair", "clear_mistake",
                    "Ranks do not match.", {betterChoiceId: "j2-sa"}),
                  choice("j2-trash", "Offsuit trash", "clear_mistake",
                    "It is suited.", {betterChoiceId: "j2-sa"}),
                ],
                // LPT-137
                teachSpec: {
                  deal: {
                    mode: "random_in_class",
                    handFamily: "suited_ace",
                    suitFamily: "suited",
                    variants: [
                      {id: "var-pair-distractor", handFamily: "pair", label: "Pair distractor"},
                      {id: "var-trash-distractor", handFamily: "trash", label: "Trash distractor"},
                    ],
                  },
                  cues: [{press: 1, target: "j2-sa", kind: "none"}],
                },
              }),
              actionAct({
                id: "act-02-07-02-jump-open", order: 3, stage: "scaffolded", assessmentRole: "jump_test",
                prompt: "UTG with trash offsuit. Action?",
                a11y: "Jump test: fold trash early.",
                objectives: ["Confirm open or fold"],
                choices: [
                  choice("j2-fold", "Fold", "recommended",
                    "Easy fold.", {action: "FOLD"}),
                  choice("j2-open", "Open to 6", "clear_mistake",
                    "Not from UTG.", {action: "RAISE", amountBb: 3, betterChoiceId: "j2-fold"}),
                ],
                // LPT-137
                teachSpec: {
                  deal: {mode: "random_in_class", handFamily: "trash", suitFamily: "offsuit"},
                  cues: [{press: 1, target: "j2-fold", kind: "none"}],
                },
              }),
              actionAct({
                id: "act-02-07-02-jump-vs", order: 4, stage: "scaffolded", assessmentRole: "jump_test",
                prompt: "Open to 6. You have pocket aces in the big blind. Action?",
                a11y: "Jump test: value 3-bet pocket aces.",
                objectives: ["Confirm facing a raise"],
                choices: [
                  choice("j2-3bet", "3-bet to 18", "recommended",
                    "Aces raise for value.", {action: "RAISE", amountBb: 9}),
                  choice("j2-call", "Call", "questionable",
                    "Slow-playing is optional; 3-bet is baseline.", {action: "CALL"}),
                  choice("j2-fold-aa", "Fold", "clear_mistake",
                    "Never.", {action: "FOLD", betterChoiceId: "j2-3bet"}),
                ],
                // LPT-137
                teachSpec: {
                  deal: {mode: "fixed", fixedCards: {hero: ["Ah", "Ad"]}},
                  cues: [{press: 1, target: "j2-3bet", kind: "none"}],
                },
              }),
              selectAct({
                id: "act-02-07-02-jump-stack", order: 5, stage: "scaffolded", assessmentRole: "jump_test",
                prompt: "You 120bb, villain 55bb. Effective stack?",
                a11y: "Jump test: effective stack is 55bb.",
                objectives: ["Confirm effective stack"],
                choices: [
                  choice("j2-55", "55bb", "recommended", "Shorter stack rules."),
                  choice("j2-120", "120bb", "clear_mistake",
                    "You cannot use the extra versus them.", {betterChoiceId: "j2-55"}),
                  choice("j2-175", "175bb", "clear_mistake",
                    "Do not add stacks.", {betterChoiceId: "j2-55"}),
                ],
                // LPT-137
                teachSpec: {deal: {mode: "none"}, cues: [{press: 1, target: "j2-55", kind: "none"}]},
              }),
            ],
          }),
        ]),
    ],
  };
}

/** Exit lesson for later stub sections to depend on. */
export const SECTION_TWO_EXIT_LESSON = "lesson-02-07-02-section-two-jump";
