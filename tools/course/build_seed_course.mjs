#!/usr/bin/env node
import {writeFileSync} from 'node:fs';
import {dirname, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {
  buildSectionOne,
  buildSectionTwo,
} from './wave_one_foundations.mjs';
import {
  MEET_CALLING_STATION,
  MEET_MANIAC,
  MEET_NIT,
  buildSectionFour,
  buildSectionThree,
} from './wave_two_live_competence.mjs';
import {
  MEET_LAG,
  MEET_TAG,
  buildSectionFive,
  buildSectionSeven,
  buildSectionSix,
} from './wave_three_advanced_play.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const outPath = resolve(__dirname, '../../content/course/v2/course.json');

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
      introducedByLessonId: MEET_TAG,
      summary: "Selective entry with disciplined aggression.",
    },
    {
      id: "lag", label: "LAG",
      introducedByLessonId: MEET_LAG,
      summary: "Wide entry with sustained pressure.",
    },
  ],
  sections: [
    buildSectionOne(),
    buildSectionTwo(),
    buildSectionThree(),
    buildSectionFour(),
    buildSectionFive(),
    buildSectionSix(),
    buildSectionSeven(),
  ],
};

writeFileSync(outPath, `${JSON.stringify(course, null, 2)}\n`);
console.log(`wrote ${outPath}`);
