#!/usr/bin/env node
import {writeFileSync} from 'node:fs';
import {dirname, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {
  ACC,
  buildSectionOne,
  buildSectionTwo,
  dialogue,
} from './wave_one_foundations.mjs';
import {
  MEET_CALLING_STATION,
  MEET_MANIAC,
  MEET_NIT,
  SECTION_FOUR_EXIT_LESSON,
  buildSectionFour,
  buildSectionThree,
} from './wave_two_live_competence.mjs';

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
      introducedByLessonId: MEET_CALLING_STATION,
      summary: "Calls too often and rarely folds to pressure.",
    },
    {
      id: "nit", label: "Nit",
      introducedByLessonId: MEET_NIT,
      summary: "Plays very few hands and overfolds to aggression.",
    },
    {
      id: "maniac", label: "Maniac",
      introducedByLessonId: MEET_MANIAC,
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
    buildSectionThree(),
    buildSectionFour(),
  ],
};

course.sections.push(stubSection({
  id: "sec-05-winning-12", order: 5, title: "Winning 1/2",
  summary: "Win larger value pots and avoid expensive marginal mistakes.",
  band: "winning_12",
  unitId: "unit-05-01-value-stub",
  lessonId: "lesson-05-01-01-value-stub",
  prereq: SECTION_FOUR_EXIT_LESSON,
  remediation: MEET_CALLING_STATION,
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
