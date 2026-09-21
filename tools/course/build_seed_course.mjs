#!/usr/bin/env node
import {writeFileSync} from 'node:fs';
import {dirname, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const outPath = resolve(__dirname, '../../content/course/v2/course.json');
const ACC = ["recommended", "strong", "reasonable"];

const dialogue = (id, order, text, extra = {}) => ({
  id, order, stage: "explain", renderer: "coach_dialogue",
  estimatedSeconds: 30, accessibilityText: text,
  acceptedGrades: ["recommended"], lifeLossEligible: false,
  coachMedia: [{id: `${id}-media`, kind: "dialogue", text}],
  ...extra,
});

function stubSection({id, order, title, summary, band, unitId, lessonId, prereq, remediation, objective, line, playerTypeRefs = [], introduces = []}) {
  return {
    id, order, title, summary, experienceBand: band,
    units: [{
      id: unitId, order: 1, title: `${title} stub unit`, summary: "Stub unit for pipeline coverage.",
      lessons: [{
        id: lessonId, order: 1, title: `${title} stub`,
        summary: "Placeholder lesson until later content waves.",
        objectives: [objective],
        prerequisites: prereq ? [prereq] : [],
        remediationLessonIds: [remediation],
        estimatedMinutes: 5, difficultyBand: Math.min(5, order),
        playerTypeRefs, introducesPlayerTypes: introduces,
        activities: [dialogue(`act-${lessonId}-explain`, 1, line, playerTypeRefs.length ? {playerTypeRefs} : {})],
      }],
    }],
  };
}

const course = {
  catalogVersion: "2.0.0",
  minClientVersion: "2.0.0",
  scope: "live_cash_nlh",
  coachId: "rex",
  playerTypes: [
    {id: "calling_station", label: "Calling Station", introducedByLessonId: "lesson-04-01-01-meet-calling-station", summary: "Calls too often and rarely folds to pressure."},
    {id: "nit", label: "Nit", introducedByLessonId: "lesson-04-01-02-meet-nit", summary: "Plays very few hands and overfolds to aggression."},
    {id: "maniac", label: "Maniac", introducedByLessonId: "lesson-04-01-03-meet-maniac", summary: "Raises and barrels far too wide."},
    {id: "tag", label: "TAG", introducedByLessonId: "lesson-06-01-01-meet-tag", summary: "Selective entry with disciplined aggression."},
    {id: "lag", label: "LAG", introducedByLessonId: "lesson-06-01-02-meet-lag", summary: "Wide entry with sustained pressure."},
  ],
  sections: [
    {
      id: "sec-01-never-played", order: 1, title: "Never Played",
      summary: "Sit down and play a complete live cash hand without freezing.",
      experienceBand: "never_played",
      units: [{
        id: "unit-01-01-cards-and-table", order: 1, title: "Cards and the table",
        summary: "Suits, ranks, hole cards, and the live table layout.",
        lessons: [
          {
            id: "lesson-01-01-01-your-two-cards", order: 1,
            title: "Your two cards",
            summary: "Learn that hole cards are private to you until showdown.",
            objectives: [
              "Identify your two hole cards",
              "Distinguish hole cards from community cards",
              "Recognize that other seats hide their hole cards",
            ],
            prerequisites: [],
            remediationLessonIds: ["lesson-01-01-01-your-two-cards"],
            estimatedMinutes: 6, difficultyBand: 1, playerTypeRefs: [],
            activities: [
              dialogue(
                "act-01-01-01-explain-hole-cards",
                1,
                "These two are yours alone. Nobody else sees them.",
                {objectives: ["Identify your two hole cards"]},
              ),
              {
                id: "act-01-01-01-guided-find-holes", order: 2, stage: "guided",
                renderer: "select_identify",
                estimatedSeconds: 40,
                accessibilityText: "Choose which pair are your private hole cards.",
                acceptedGrades: ACC, lifeLossEligible: false,
                objectives: ["Identify your two hole cards"],
                prompt: "Which cards are your hole cards?",
                coachMedia: [{
                  id: "act-01-01-01-guided-find-holes-hint",
                  kind: "hint",
                  text: "Look at the two cards in front of you — not the board.",
                }],
                choices: [
                  {
                    id: "choice-hero-holes",
                    label: "Ah Kd in front of you",
                    accessibilityText: "Select ace of hearts and king of diamonds as your hole cards.",
                    grading: {
                      grade: "recommended",
                      feedback: "Right. Those two stay private until showdown.",
                    },
                  },
                  {
                    id: "choice-board",
                    label: "The flop cards in the middle",
                    accessibilityText: "Select the community flop cards.",
                    grading: {
                      grade: "clear_mistake",
                      feedback: "Board cards are shared. Your hole cards sit in front of you.",
                      betterChoiceId: "choice-hero-holes",
                    },
                  },
                  {
                    id: "choice-villain",
                    label: "Face-down cards at another seat",
                    accessibilityText: "Select another seat's face-down cards.",
                    grading: {
                      grade: "clear_mistake",
                      feedback: "Those belong to someone else. Yours are the two in front of you.",
                      betterChoiceId: "choice-hero-holes",
                    },
                  },
                ],
              },
              {
                id: "act-01-01-01-scaffolded-private", order: 3, stage: "scaffolded",
                renderer: "select_identify",
                estimatedSeconds: 40,
                accessibilityText: "Decide who can see your hole cards during the hand.",
                acceptedGrades: ACC, lifeLossEligible: false,
                objectives: ["Recognize that other seats hide their hole cards"],
                prompt: "Who can see your hole cards right now?",
                choices: [
                  {
                    id: "choice-only-you",
                    label: "Only you",
                    accessibilityText: "Select that only you see your hole cards.",
                    grading: {
                      grade: "recommended",
                      feedback: "Private until showdown. Protect them.",
                    },
                  },
                  {
                    id: "choice-whole-table",
                    label: "Everyone at the table",
                    accessibilityText: "Select that the whole table sees your hole cards.",
                    grading: {
                      grade: "clear_mistake",
                      feedback: "If everyone saw them, they would not be hole cards.",
                      betterChoiceId: "choice-only-you",
                    },
                  },
                  {
                    id: "choice-dealer-only",
                    label: "Only the dealer",
                    accessibilityText: "Select that only the dealer sees your hole cards.",
                    grading: {
                      grade: "questionable",
                      feedback: "Dealers should not peek. Treat the cards as yours alone.",
                      reversalRead: "Casino procedures vary; still play as if only you know them.",
                    },
                  },
                ],
              },
              {
                id: "act-01-01-01-unguided-mix", order: 4, stage: "unguided",
                renderer: "select_identify",
                estimatedSeconds: 35,
                accessibilityText: "Pick the shared community cards on a simple flop.",
                acceptedGrades: ACC, lifeLossEligible: true,
                objectives: ["Distinguish hole cards from community cards"],
                prompt: "Which cards are community cards?",
                choices: [
                  {
                    id: "choice-flop",
                    label: "Qs Jh 2c in the middle",
                    accessibilityText: "Select the queen, jack, and deuce in the middle.",
                    grading: {
                      grade: "recommended",
                      feedback: "Those are shared. Everyone uses them.",
                    },
                  },
                  {
                    id: "choice-hero-again",
                    label: "Your Ah Kd",
                    accessibilityText: "Select your ace-king as community cards.",
                    grading: {
                      grade: "clear_mistake",
                      feedback: "Those stay yours. Community cards are in the middle.",
                      betterChoiceId: "choice-flop",
                    },
                  },
                  {
                    id: "choice-muck",
                    label: "Folded cards in the muck",
                    accessibilityText: "Select folded cards in the muck.",
                    grading: {
                      grade: "clear_mistake",
                      feedback: "Mucked cards are dead, not the board.",
                      betterChoiceId: "choice-flop",
                    },
                  },
                ],
              },
              {
                id: "act-01-01-01-checkpoint-table", order: 5, stage: "checkpoint",
                renderer: "select_identify",
                estimatedSeconds: 45,
                accessibilityText: "On a fuller table, identify your private hole cards again.",
                acceptedGrades: ACC, lifeLossEligible: true,
                objectives: [
                  "Identify your two hole cards",
                  "Distinguish hole cards from community cards",
                ],
                prompt: "Six seats, flop out. Which cards are only yours?",
                choices: [
                  {
                    id: "choice-checkpoint-holes",
                    label: "The two cards at your seat",
                    accessibilityText: "Select the two cards at your seat.",
                    grading: {
                      grade: "recommended",
                      feedback: "Still just your two. Board and other seats stay separate.",
                    },
                  },
                  {
                    id: "choice-checkpoint-board",
                    label: "Flop plus your two cards",
                    accessibilityText: "Select the flop plus your hole cards.",
                    grading: {
                      grade: "clear_mistake",
                      feedback: "You combine them later to make a hand. Ownership stays split.",
                      betterChoiceId: "choice-checkpoint-holes",
                      reversalRead: "At showdown you reveal them, but until then they are private.",
                    },
                  },
                  {
                    id: "choice-checkpoint-all",
                    label: "Every face-up card you can see",
                    accessibilityText: "Select every face-up card in view.",
                    grading: {
                      grade: "questionable",
                      feedback: "You can see the board, but those cards are not yours alone.",
                    },
                  },
                ],
              },
            ],
          },
          {
            id: "lesson-01-01-02-renderer-coverage-seed", order: 2,
            title: "Table coverage seed",
            summary: "Seed activities that cover remaining renderers until Plan 07 authoring.",
            objectives: ["Exercise remaining activity renderers"],
            prerequisites: ["lesson-01-01-01-your-two-cards"],
            remediationLessonIds: ["lesson-01-01-01-your-two-cards"],
            estimatedMinutes: 8, difficultyBand: 1, playerTypeRefs: [],
            activities: [
              {
                id: "act-01-01-02-scaffolded-action-order", order: 1, stage: "scaffolded",
                renderer: "order_sequence",
                estimatedSeconds: 50,
                accessibilityText: "Put preflop action seats in order after the big blind.",
                acceptedGrades: ACC, lifeLossEligible: false,
                objectives: ["Exercise remaining activity renderers"],
                prompt: "Order the first three seats to act preflop after the blinds post.",
                sequenceItems: [{id: "seat-utg", label: "UTG"}, {id: "seat-hj", label: "HJ"}, {id: "seat-btn", label: "BTN"}],
                correctSequence: ["seat-utg", "seat-hj", "seat-btn"],
                sequenceGrading: {
                  correct: {grade: "recommended", feedback: "UTG acts first. Button acts last."},
                  incorrect: {grade: "clear_mistake", feedback: "Start under the gun, then move toward the button."},
                },
              },
              {
                id: "act-01-01-02-unguided-pot-price", order: 2, stage: "unguided",
                renderer: "numeric_pot_price",
                estimatedSeconds: 40,
                accessibilityText: "Enter the pot size after a three-big-blind open into a one-big-blind pot.",
                acceptedGrades: ACC, lifeLossEligible: true,
                objectives: ["Exercise remaining activity renderers"],
                numericPrompt: {
                  question: "Blinds are 1/2. Nobody limps. BTN opens to 6. What is the pot before the blinds act?",
                  unit: "chips", acceptedMin: 9, acceptedMax: 9,
                  grading: {grade: "recommended", feedback: "1 + 2 + 6 = 9 chips in the middle."},
                  missGrading: {grade: "clear_mistake", feedback: "Add both blinds and the open: 1 + 2 + 6."},
                },
              },
              {
                id: "act-01-01-02-checkpoint-open-fold", order: 3, stage: "checkpoint",
                renderer: "poker_action_sizing",
                estimatedSeconds: 55,
                accessibilityText: "Choose whether to open or fold UTG with seven-two offsuit.",
                acceptedGrades: ACC, lifeLossEligible: true,
                objectives: ["Exercise remaining activity renderers"],
                prompt: "You are UTG with 72o at 1/2. What do you do?",
                choices: [
                  {id: "fold", label: "Fold", action: "FOLD", grading: {grade: "recommended", feedback: "Trash from early position is an easy fold."}},
                  {id: "open-six", label: "Open to 6", action: "RAISE", amountBb: 3, grading: {grade: "clear_mistake", feedback: "Seventy-two offsuit is not an open from UTG.", betterChoiceId: "fold"}},
                  {id: "limp", label: "Limp", action: "CALL", grading: {grade: "questionable", feedback: "Limping junk builds multiway pots you do not want."}},
                ],
              },
              {
                id: "act-01-01-02-jump-compare", order: 4, stage: "jump_test",
                renderer: "compare_rank",
                estimatedSeconds: 45,
                accessibilityText: "Rank three starting hands from strongest to weakest for an early-position open.",
                acceptedGrades: ACC, lifeLossEligible: true,
                objectives: ["Exercise remaining activity renderers"],
                prompt: "Rank these UTG open candidates from strongest to weakest.",
                sequenceItems: [{id: "hand-aa", label: "AA"}, {id: "hand-aqs", label: "AQs"}, {id: "hand-72o", label: "72o"}],
                correctSequence: ["hand-aa", "hand-aqs", "hand-72o"],
                sequenceGrading: {
                  correct: {grade: "strong", feedback: "Premium pair, then strong broadway, then trash."},
                  incorrect: {grade: "clear_mistake", feedback: "Aces lead. Suited ace next. Seventy-two is last."},
                },
              },
              {
                id: "act-01-01-02-hand-lab-seed", order: 5, stage: "unguided",
                renderer: "full_table_hand_lab",
                estimatedSeconds: 90,
                accessibilityText: "Play a short scripted live cash hand as the big blind.",
                acceptedGrades: ACC, lifeLossEligible: true,
                objectives: ["Exercise remaining activity renderers"],
                prompt: "Defend or fold this big-blind hand.",
                choices: [
                  {id: "fold-bb", label: "Fold", action: "FOLD", grading: {grade: "reasonable", feedback: "Folding A7o is fine; defending is optional this deep."}},
                  {id: "call-bb", label: "Call 4 more", action: "CALL", grading: {grade: "strong", feedback: "A call keeps the hand playable in position later."}},
                  {id: "shove-bb", label: "Jam 100bb", action: "ALL_IN", grading: {grade: "clear_mistake", feedback: "Jamming A7o for 100bb is a clear mistake.", betterChoiceId: "call-bb"}},
                ],
                handLabSpec: {
                  id: "lab-01-01-02-bb-defend-seed", title: "Big blind toy defend",
                  tableSize: 6, heroSeat: 1, smallBlind: 1, bigBlind: 2, startingStackBb: 100,
                  heroCards: ["Ah", "7d"], board: [],
                  scriptedActions: [
                    {seat: 2, street: "preflop", action: "FOLD"},
                    {seat: 3, street: "preflop", action: "FOLD"},
                    {seat: 4, street: "preflop", action: "RAISE", amountBb: 3},
                    {seat: 5, street: "preflop", action: "FOLD"},
                    {seat: 0, street: "preflop", action: "FOLD"},
                  ],
                  decisionPoints: [{
                    id: "dp-bb-vs-btn-open", street: "preflop",
                    prompt: "BTN opens to 6. You hold A7o in the big blind. What do you do?",
                    choices: [
                      {id: "fold-bb", label: "Fold", action: "FOLD", grading: {grade: "reasonable", feedback: "Folding A7o is fine; defending is optional this deep."}},
                      {id: "call-bb", label: "Call 4 more", action: "CALL", grading: {grade: "strong", feedback: "A call keeps the hand playable in position later."}},
                      {id: "shove-bb", label: "Jam 100bb", action: "ALL_IN", grading: {grade: "clear_mistake", feedback: "Jamming A7o for 100bb is a clear mistake.", betterChoiceId: "call-bb"}},
                    ],
                  }],
                },
              },
            ],
          },
        ],
      }],
    },
  ],
};

course.sections.push(stubSection({
  id: "sec-02-rules-known", order: 2, title: "Rules Known / Home Games",
  summary: "Play a disciplined baseline instead of guessing.", band: "rules_known",
  unitId: "unit-02-01-position-power", lessonId: "lesson-02-01-01-position-stub",
  prereq: "lesson-01-01-01-your-two-cards", remediation: "lesson-01-01-01-your-two-cards",
  objective: "Recognize position labels", line: "Later seats see more. That is the whole edge.",
}));
course.sections.push(stubSection({
  id: "sec-03-first-casino", order: 3, title: "First Casino Sessions",
  summary: "Reach the river with a plan and avoid beginner leaks.", band: "first_casino",
  unitId: "unit-03-01-table-read-stub", lessonId: "lesson-03-01-01-table-read-stub",
  prereq: "lesson-02-01-01-position-stub", remediation: "lesson-02-01-01-position-stub",
  objective: "Track pot and stacks", line: "Pot, stacks, button, action. Read those first.",
}));
course.sections.push({
  id: "sec-04-regular-live", order: 4, title: "Regular Live Cash Player",
  summary: "Build ranges, recognize opponents, and make deliberate exploits.",
  experienceBand: "regular_live",
  units: [{
    id: "unit-04-01-player-types-intro", order: 1, title: "Core player types",
    summary: "Introduce Calling Station, Nit, and Maniac.",
    lessons: [
      {
        id: "lesson-04-01-01-meet-calling-station", order: 1, title: "Meet the Calling Station",
        summary: "Introduce the Calling Station label from observed call frequency.",
        objectives: ["Introduce Calling Station"],
        prerequisites: ["lesson-03-01-01-table-read-stub"],
        remediationLessonIds: ["lesson-03-01-01-table-read-stub"],
        estimatedMinutes: 6, difficultyBand: 3,
        playerTypeRefs: ["calling_station"], introducesPlayerTypes: ["calling_station"],
        activities: [
          dialogue("act-04-01-01-explain-station", 1, "They call and call. Value thin; bluff less.", {playerTypeRefs: ["calling_station"]}),
          {
            id: "act-04-01-01-classify-station", order: 2, stage: "guided", renderer: "player_read_classify",
            estimatedSeconds: 40, accessibilityText: "Classify a seat that calls three streets with second pair.",
            acceptedGrades: ACC, lifeLossEligible: false, playerTypeRefs: ["calling_station"],
            prompt: "This seat called three streets with second pair. Best label?",
            choices: [
              {id: "pt-station", label: "Calling Station", grading: {grade: "recommended", feedback: "Sticky calls are the Calling Station tell."}},
              {id: "pt-nit", label: "Nit", grading: {grade: "clear_mistake", feedback: "Nits fold too much; this seat calls too much.", betterChoiceId: "pt-station"}},
            ],
          },
        ],
      },
      {
        id: "lesson-04-01-02-meet-nit", order: 2, title: "Meet the Nit",
        summary: "Introduce the Nit label from tight fold frequency.",
        objectives: ["Introduce Nit"],
        prerequisites: ["lesson-04-01-01-meet-calling-station"],
        remediationLessonIds: ["lesson-04-01-01-meet-calling-station"],
        estimatedMinutes: 6, difficultyBand: 3,
        playerTypeRefs: ["nit"], introducesPlayerTypes: ["nit"],
        activities: [dialogue("act-04-01-02-explain-nit", 1, "Tiny range. Steal their blinds; respect their raises.", {playerTypeRefs: ["nit"]})],
      },
      {
        id: "lesson-04-01-03-meet-maniac", order: 3, title: "Meet the Maniac",
        summary: "Introduce the Maniac label from reckless aggression.",
        objectives: ["Introduce Maniac"],
        prerequisites: ["lesson-04-01-02-meet-nit"],
        remediationLessonIds: ["lesson-04-01-02-meet-nit"],
        estimatedMinutes: 6, difficultyBand: 3,
        playerTypeRefs: ["maniac"], introducesPlayerTypes: ["maniac"],
        activities: [dialogue("act-04-01-03-explain-maniac", 1, "They blast. Tighten up and let them hang themselves.", {playerTypeRefs: ["maniac"]})],
      },
    ],
  }],
});
course.sections.push(stubSection({
  id: "sec-05-winning-12", order: 5, title: "Winning 1/2",
  summary: "Win larger value pots and avoid expensive marginal mistakes.", band: "winning_12",
  unitId: "unit-05-01-value-stub", lessonId: "lesson-05-01-01-value-stub",
  prereq: "lesson-04-01-03-meet-maniac", remediation: "lesson-04-01-01-meet-calling-station",
  objective: "Choose thin value spots", line: "Against stations, bet thinner for value.",
  playerTypeRefs: ["calling_station"],
}));
course.sections.push({
  id: "sec-06-advanced-live", order: 6, title: "Advanced Live Cash",
  summary: "Think in ranges, incentives, and future streets.",
  experienceBand: "advanced_live",
  units: [{
    id: "unit-06-01-tag-lag-intro", order: 1, title: "TAG and LAG",
    summary: "Introduce TAG and LAG labels.",
    lessons: [
      {
        id: "lesson-06-01-01-meet-tag", order: 1, title: "Meet the TAG",
        summary: "Introduce the TAG label.",
        objectives: ["Introduce TAG"],
        prerequisites: ["lesson-05-01-01-value-stub"],
        remediationLessonIds: ["lesson-05-01-01-value-stub"],
        estimatedMinutes: 6, difficultyBand: 4,
        playerTypeRefs: ["tag"], introducesPlayerTypes: ["tag"],
        activities: [dialogue("act-06-01-01-explain-tag", 1, "Tight in, aggressive after. Do not bluff their check-raises light.", {playerTypeRefs: ["tag"]})],
      },
      {
        id: "lesson-06-01-02-meet-lag", order: 2, title: "Meet the LAG",
        summary: "Introduce the LAG label.",
        objectives: ["Introduce LAG"],
        prerequisites: ["lesson-06-01-01-meet-tag"],
        remediationLessonIds: ["lesson-06-01-01-meet-tag"],
        estimatedMinutes: 6, difficultyBand: 4,
        playerTypeRefs: ["lag"], introducesPlayerTypes: ["lag"],
        activities: [dialogue("act-06-01-02-explain-lag", 1, "Wide and sticky aggression. Trap more; fancy less.", {playerTypeRefs: ["lag"]})],
      },
    ],
  }],
});
course.sections.push({
  id: "sec-07-full-hand-integration", order: 7, title: "Full-Hand Integration",
  summary: "Build, execute, and review a complete exploitative plan.",
  experienceBand: "full_hand_integration",
  units: [{
    id: "unit-07-01-plan-stub", order: 1, title: "Full-hand plan stub",
    summary: "Stub unit for pipeline coverage.",
    lessons: [{
      id: "lesson-07-01-01-plan-stub", order: 1, title: "Plan stub",
      summary: "Placeholder lesson until wave-three authoring.",
      objectives: ["Build a full-hand plan"],
      prerequisites: ["lesson-06-01-02-meet-lag"],
      remediationLessonIds: ["lesson-06-01-01-meet-tag"],
      estimatedMinutes: 5, difficultyBand: 5,
      playerTypeRefs: ["tag", "lag", "calling_station"],
      activities: [
        dialogue("act-07-01-01-explain-plan", 1, "One plan from preflop to river. Adjust with evidence.", {playerTypeRefs: ["tag", "lag"]}),
        {
          id: "act-07-01-01-multi-step-stub", order: 2, stage: "scaffolded", renderer: "authored_multi_step_hand",
          estimatedSeconds: 70, accessibilityText: "Work a two-street authored hand against a TAG.",
          acceptedGrades: ACC, lifeLossEligible: false, playerTypeRefs: ["tag"],
          handSteps: [{
            id: "step-preflop", street: "preflop",
            prompt: "BTN TAG opens 3x. You have AQo on the CO after folds. Action?",
            accessibilityText: "Choose a preflop action with ace-queen offsuit.",
            choices: [
              {id: "fold-aq", label: "Fold", action: "FOLD", grading: {grade: "questionable", feedback: "Folding AQo to a TAG open is cautious but not awful."}},
              {id: "call-aq", label: "Call", action: "CALL", grading: {grade: "reasonable", feedback: "Calling is playable; a value three-bet is cleaner."}},
              {id: "threebet-aq", label: "3-bet to 9x", action: "RAISE", amountBb: 9, grading: {grade: "recommended", feedback: "AQo is a standard value three-bet versus a TAG open."}},
            ],
          }],
        },
      ],
    }],
  }],
});

writeFileSync(outPath, JSON.stringify(course, null, 2) + "\n");
console.log(`wrote ${outPath}`);
