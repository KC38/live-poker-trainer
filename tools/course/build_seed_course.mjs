#!/usr/bin/env node
import {writeFileSync} from 'node:fs';
import {dirname, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {
  ACC,
  buildSectionOne,
  buildSectionTwo,
  dialogue,
  SECTION_TWO_EXIT_LESSON,
} from './wave_one_foundations.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const outPath = resolve(__dirname, '../../content/course/v2/course.json');

function stubSection({
  id, order, title, summary, band, unitId, lessonId, prereq, remediation,
  objective, line, playerTypeRefs = [], introduces = [],
}) {
  return {
    id, order, title, summary, experienceBand: band,
    units: [{
      id: unitId, order: 1, title: `${title} stub unit`,
      summary: "Stub unit for pipeline coverage.",
      lessons: [{
        id: lessonId, order: 1, title: `${title} stub`,
        summary: "Placeholder lesson until later content waves.",
        objectives: [objective],
        prerequisites: prereq ? [prereq] : [],
        remediationLessonIds: [remediation],
        estimatedMinutes: 5, difficultyBand: Math.min(5, order),
        playerTypeRefs, introducesPlayerTypes: introduces,
        activities: [
          dialogue(
            `act-${lessonId}-explain`,
            1,
            line,
            playerTypeRefs.length ? {playerTypeRefs} : {},
          ),
        ],
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
    {
      id: "calling_station", label: "Calling Station",
      introducedByLessonId: "lesson-04-01-01-meet-calling-station",
      summary: "Calls too often and rarely folds to pressure.",
    },
    {
      id: "nit", label: "Nit",
      introducedByLessonId: "lesson-04-01-02-meet-nit",
      summary: "Plays very few hands and overfolds to aggression.",
    },
    {
      id: "maniac", label: "Maniac",
      introducedByLessonId: "lesson-04-01-03-meet-maniac",
      summary: "Raises and barrels far too wide.",
    },
    {
      id: "tag", label: "TAG",
      introducedByLessonId: "lesson-06-01-01-meet-tag",
      summary: "Selective entry with disciplined aggression.",
    },
    {
      id: "lag", label: "LAG",
      introducedByLessonId: "lesson-06-01-02-meet-lag",
      summary: "Wide entry with sustained pressure.",
    },
  ],
  sections: [
    buildSectionOne(),
    buildSectionTwo(),
  ],
};

course.sections.push(stubSection({
  id: "sec-03-first-casino", order: 3, title: "First Casino Sessions",
  summary: "Reach the river with a plan and avoid beginner leaks.",
  band: "first_casino",
  unitId: "unit-03-01-table-read-stub",
  lessonId: "lesson-03-01-01-table-read-stub",
  prereq: SECTION_TWO_EXIT_LESSON,
  remediation: SECTION_TWO_EXIT_LESSON,
  objective: "Track pot and stacks",
  line: "Pot, stacks, button, action. Read those first.",
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
        id: "lesson-04-01-01-meet-calling-station", order: 1,
        title: "Meet the Calling Station",
        summary: "Introduce the Calling Station label from observed call frequency.",
        objectives: ["Introduce Calling Station"],
        prerequisites: ["lesson-03-01-01-table-read-stub"],
        remediationLessonIds: ["lesson-03-01-01-table-read-stub"],
        estimatedMinutes: 6, difficultyBand: 3,
        playerTypeRefs: ["calling_station"],
        introducesPlayerTypes: ["calling_station"],
        activities: [
          dialogue(
            "act-04-01-01-explain-station", 1,
            "They call and call. Value thin; bluff less.",
            {playerTypeRefs: ["calling_station"]},
          ),
          {
            id: "act-04-01-01-classify-station", order: 2, stage: "guided",
            renderer: "player_read_classify",
            estimatedSeconds: 40,
            accessibilityText: "Classify a seat that calls three streets with second pair.",
            acceptedGrades: ACC, lifeLossEligible: false,
            playerTypeRefs: ["calling_station"],
            prompt: "This seat called three streets with second pair. Best label?",
            choices: [
              {
                id: "pt-station", label: "Calling Station",
                grading: {
                  grade: "recommended",
                  feedback: "Sticky calls are the Calling Station tell.",
                },
              },
              {
                id: "pt-nit", label: "Nit",
                grading: {
                  grade: "clear_mistake",
                  feedback: "Nits fold too much; this seat calls too much.",
                  betterChoiceId: "pt-station",
                },
              },
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
        activities: [
          dialogue(
            "act-04-01-02-explain-nit", 1,
            "Tiny range. Steal their blinds; respect their raises.",
            {playerTypeRefs: ["nit"]},
          ),
        ],
      },
      {
        id: "lesson-04-01-03-meet-maniac", order: 3, title: "Meet the Maniac",
        summary: "Introduce the Maniac label from reckless aggression.",
        objectives: ["Introduce Maniac"],
        prerequisites: ["lesson-04-01-02-meet-nit"],
        remediationLessonIds: ["lesson-04-01-02-meet-nit"],
        estimatedMinutes: 6, difficultyBand: 3,
        playerTypeRefs: ["maniac"], introducesPlayerTypes: ["maniac"],
        activities: [
          dialogue(
            "act-04-01-03-explain-maniac", 1,
            "They blast. Tighten up and let them hang themselves.",
            {playerTypeRefs: ["maniac"]},
          ),
        ],
      },
    ],
  }],
});

course.sections.push(stubSection({
  id: "sec-05-winning-12", order: 5, title: "Winning 1/2",
  summary: "Win larger value pots and avoid expensive marginal mistakes.",
  band: "winning_12",
  unitId: "unit-05-01-value-stub",
  lessonId: "lesson-05-01-01-value-stub",
  prereq: "lesson-04-01-03-meet-maniac",
  remediation: "lesson-04-01-01-meet-calling-station",
  objective: "Choose thin value spots",
  line: "Against stations, bet thinner for value.",
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
        activities: [
          dialogue(
            "act-06-01-01-explain-tag", 1,
            "Tight in, aggressive after. Do not bluff their check-raises light.",
            {playerTypeRefs: ["tag"]},
          ),
        ],
      },
      {
        id: "lesson-06-01-02-meet-lag", order: 2, title: "Meet the LAG",
        summary: "Introduce the LAG label.",
        objectives: ["Introduce LAG"],
        prerequisites: ["lesson-06-01-01-meet-tag"],
        remediationLessonIds: ["lesson-06-01-01-meet-tag"],
        estimatedMinutes: 6, difficultyBand: 4,
        playerTypeRefs: ["lag"], introducesPlayerTypes: ["lag"],
        activities: [
          dialogue(
            "act-06-01-02-explain-lag", 1,
            "Wide and sticky aggression. Trap more; fancy less.",
            {playerTypeRefs: ["lag"]},
          ),
        ],
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
        dialogue(
          "act-07-01-01-explain-plan", 1,
          "One plan from preflop to river. Adjust with evidence.",
          {playerTypeRefs: ["tag", "lag"]},
        ),
        {
          id: "act-07-01-01-multi-step-stub", order: 2, stage: "scaffolded",
          renderer: "authored_multi_step_hand",
          estimatedSeconds: 70,
          accessibilityText: "Work a two-street authored hand against a TAG.",
          acceptedGrades: ACC, lifeLossEligible: false,
          playerTypeRefs: ["tag"],
          handSteps: [{
            id: "step-preflop", street: "preflop",
            prompt: "BTN TAG opens 3x. You have AQo on the CO after folds. Action?",
            accessibilityText: "Choose a preflop action with ace-queen offsuit.",
            choices: [
              {
                id: "fold-aq", label: "Fold", action: "FOLD",
                grading: {
                  grade: "questionable",
                  feedback: "Folding AQo to a TAG open is cautious but not awful.",
                },
              },
              {
                id: "call-aq", label: "Call", action: "CALL",
                grading: {
                  grade: "reasonable",
                  feedback: "Calling is playable; a value three-bet is cleaner.",
                },
              },
              {
                id: "threebet-aq", label: "3-bet to 9x", action: "RAISE", amountBb: 9,
                grading: {
                  grade: "recommended",
                  feedback: "AQo is a standard value three-bet versus a TAG open.",
                },
              },
            ],
          }],
        },
      ],
    }],
  }],
});

writeFileSync(outPath, `${JSON.stringify(course, null, 2)}\n`);
console.log(`wrote ${outPath}`);
