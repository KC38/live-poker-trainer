/**
 * Plan 08 — Sections 3–4 authored curriculum helpers.
 * Consumed by build_seed_course.mjs; not run standalone.
 */

import {SECTION_TWO_EXIT_LESSON} from "./wave_one_foundations.mjs";
import {
  actionAct,
  choice,
  classifyAct,
  dialogue,
  handLabAct,
  lesson,
  multiStepAct,
  numericAct,
  selectAct,
  unit,
} from "./wave_one_foundations.mjs";

/** @returns {object} Section 3 — First Casino Sessions */
export function buildSectionThree() {
  const prev = SECTION_TWO_EXIT_LESSON;
  const L030101 = "lesson-03-01-01-reading-live-table";
  const L030201 = "lesson-03-02-01-flop-hand-classes";
  const L030301 = "lesson-03-03-01-outs-and-price";
  const L030401 = "lesson-03-04-01-flop-decisions";
  const L030501 = "lesson-03-05-01-turn-decisions";
  const L030601 = "lesson-03-06-01-river-decisions";
  const L030701 = "lesson-03-07-01-multiway-fundamentals";
  const L030801 = "lesson-03-08-01-leak-repair";
  const L030802 = "lesson-03-08-02-section-three-jump-test";

  return {
    id: "sec-03-first-casino",
    order: 3,
    title: "First Casino Sessions",
    summary: "Reach the river with a plan and avoid the common beginner leaks.",
    experienceBand: "first_casino",
    units: [
      unit("unit-03-01-reading-table", 1, "Reading the live table",
        "Pot, stacks, commitments, button, action, and verbal declarations.", [
          lesson({
            id: L030101, order: 1,
            title: "Read the table first",
            summary: "Track pot, stacks, button, and who must act before deciding.",
            objectives: ["Track pot size and stack depths", "Locate the button and action seat", "Honor verbal declarations at a live table"],
            prereq: prev, remediation: prev, minutes: 8, band: 2,
            activities: [
              dialogue("act-03-01-01-explain", 1,
                "Before cards, read pot, stacks, button, and who acts. Words count live.",
                {objectives: ["Track pot size and stack depths"]}),
              selectAct({
                id: "act-03-01-01-guided", order: 2, stage: "guided",
                prompt: "Blinds 1/2. UTG opens to 6, BTN calls, BB calls. Pot now?",
                a11y: "Add blinds plus three contributions to size the pot.",
                objectives: ["Track pot size and stack depths"],
                choices: [
                  choice("pot-21", "21", "recommended",
                    "1+2+6+6+6 = 21 before the flop."),
                  choice("pot-18", "18", "clear_mistake",
                    "You dropped a blind.", {betterChoiceId: "pot-21"}),
                  choice("pot-12", "12", "clear_mistake",
                    "Only counted the open.", {betterChoiceId: "pot-21"})
                ],
              }),
              selectAct({
                id: "act-03-01-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Nine-handed. Dealer button is on seat 7. Who acts first preflop?",
                a11y: "Find UTG left of the big blind.",
                objectives: ["Locate the button and action seat"],
                choices: [
                  choice("utg-first", "Seat left of the big blind (UTG)", "recommended",
                    "Preflop starts left of the BB."),
                  choice("btn-first", "The button", "clear_mistake",
                    "Button acts last preflop.", {betterChoiceId: "utg-first"}),
                  choice("sb-first", "Small blind", "clear_mistake",
                    "Blinds already posted; UTG opens the voluntary action.", {betterChoiceId: "utg-first"})
                ],
              }),
              selectAct({
                id: "act-03-01-01-unguided", order: 4, stage: "unguided",
                prompt: "You say \"raise\" then try to take it back to a call. Result?",
                a11y: "Verbal raise binds at a live table.",
                objectives: ["Honor verbal declarations at a live table"], lifeLoss: true,
                choices: [
                  choice("bound", "The raise stands — verbal is binding", "recommended",
                    "Live rooms treat clear verbal action as final."),
                  choice("takeback", "You can switch to a call freely", "clear_mistake",
                    "Words lock the action.", {betterChoiceId: "bound"}),
                  choice("dealer-choice", "Only the dealer decides after cards move", "questionable",
                    "Dealer enforces the rule; the raise already happened.")
                ],
              }),
              selectAct({
                id: "act-03-01-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Hero 140bb, villain 55bb, pot 18. What matters most next?",
                a11y: "Effective stack is the shorter committed stack.",
                objectives: ["Honor verbal declarations at a live table"], lifeLoss: true,
                choices: [
                  choice("eff-55", "Effective 55bb and the 18 pot", "recommended",
                    "Shorter stack caps the matchup; pot frames price."),
                  choice("hero-140", "Only hero's 140bb", "clear_mistake",
                    "Villain cannot pay more than 55bb.", {betterChoiceId: "eff-55"}),
                  choice("ignore-pot", "Ignore pot until the river", "clear_mistake",
                    "Pot drives every price.", {betterChoiceId: "eff-55"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-03-02-flop-classes", 2, "Flop hand classes",
        "Made hands, draws, showdown value, and air.", [
          lesson({
            id: L030201, order: 1,
            title: "Name your flop class",
            summary: "Sort flop holdings into made, draw, showdown, or air.",
            objectives: ["Identify made hands on the flop", "Separate draws from showdown value", "Recognize air that needs equity or fold equity"],
            prereq: L030101, remediation: L030101, minutes: 8, band: 3,
            activities: [
              dialogue("act-03-02-01-explain", 1,
                "Flop first: made, draw, showdown value, or air. Label before you bet.",
                {objectives: ["Identify made hands on the flop"]}),
              selectAct({
                id: "act-03-02-01-guided", order: 2, stage: "guided",
                prompt: "Board Ks 9d 2c. You hold Kh Qh. Class?",
                a11y: "Top pair is a made hand.",
                objectives: ["Identify made hands on the flop"],
                choices: [
                  choice("made-tp", "Made hand — top pair", "recommended",
                    "Pair of kings is already showdown-ready."),
                  choice("draw-tp", "Draw only", "clear_mistake",
                    "You already paired.", {betterChoiceId: "made-tp"}),
                  choice("air-tp", "Air", "clear_mistake",
                    "Top pair is not air.", {betterChoiceId: "made-tp"})
                ],
              }),
              selectAct({
                id: "act-03-02-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Board Jh 8h 3c. You hold Ah 9h. Class?",
                a11y: "Nut flush draw with overcard equity.",
                objectives: ["Separate draws from showdown value"],
                choices: [
                  choice("nfd", "Strong draw — nut flush draw", "recommended",
                    "You need a heart or sometimes an ace; not made yet."),
                  choice("made-aj", "Made top pair", "clear_mistake",
                    "No jack in your hand.", {betterChoiceId: "nfd"}),
                  choice("sdv", "Strong showdown value already", "questionable",
                    "Ace-high can win sometimes, but this is primarily a draw.")
                ],
              }),
              selectAct({
                id: "act-03-02-01-unguided", order: 4, stage: "unguided",
                prompt: "Board Qc 7d 2s. You hold 5h 4h multiway. Class?",
                a11y: "No pair and almost no draw — air.",
                objectives: ["Recognize air that needs equity or fold equity"], lifeLoss: true,
                choices: [
                  choice("air", "Air — little equity, no pair", "recommended",
                    "Gutshot-ish trash multiway is give-up territory."),
                  choice("sdv-54", "Playable showdown value", "clear_mistake",
                    "Five-high does not showdown multiway.", {betterChoiceId: "air"}),
                  choice("made-54", "Made hand", "clear_mistake",
                    "No pair on board matches your cards.", {betterChoiceId: "air"})
                ],
              }),
              selectAct({
                id: "act-03-02-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Board Ts 9s 4d. You hold Js 8d. Best label?",
                a11y: "Open-ender with a spade is a draw class.",
                objectives: ["Recognize air that needs equity or fold equity"], lifeLoss: true,
                choices: [
                  choice("oesd", "Draw — open-ended straight draw", "recommended",
                    "Eight or queen completes; treat it as a draw."),
                  choice("made-jt", "Made top pair", "clear_mistake",
                    "No ten in hand.", {betterChoiceId: "oesd"}),
                  choice("air-j8", "Pure air", "questionable",
                    "You have real equity — still a draw, not air.")
                ],
              }),
            ],
          }),
        ]),
      unit("unit-03-03-outs-price", 3, "Outs and price",
        "Clean versus dirty outs, pot odds, and implied-odds intuition.", [
          lesson({
            id: L030301, order: 1,
            title: "Count outs, pay the right price",
            summary: "Estimate outs and decide if the pot pays you to continue.",
            objectives: ["Count clean versus dirty outs", "Compare pot odds to draw equity", "Use implied-odds intuition deep-stacked"],
            prereq: L030201, remediation: L030201, minutes: 9, band: 3,
            activities: [
              dialogue("act-03-03-01-explain", 1,
                "Clean outs help. Dirty outs improve you into second-best. Price the call.",
                {objectives: ["Count clean versus dirty outs"]}),
              selectAct({
                id: "act-03-03-01-guided", order: 2, stage: "guided",
                prompt: "Board Kc 8h 2d. You hold Ah Qh. Clean outs to the best hand?",
                a11y: "Three remaining aces are the clean outs.",
                objectives: ["Count clean versus dirty outs"],
                choices: [
                  choice("outs-3", "About 3 — the aces", "recommended",
                    "Aces are clean; queens are dirty versus a king."),
                  choice("outs-6", "6 — aces and queens", "questionable",
                    "Queens often leave you second-best."),
                  choice("outs-0", "0 — never improve", "clear_mistake",
                    "An ace pairs you ahead of one pair of kings often.", {betterChoiceId: "outs-3"})
                ],
              }),
              selectAct({
                id: "act-03-03-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Pot is 20. Villain bets 10. How many chips to call?",
                a11y: "Calling price is the bet size: 10.",
                objectives: ["Compare pot odds to draw equity"],
                choices: [
                  choice("call-10", "10", "recommended",
                    "You must call 10 into a 30 pot after calling."),
                  choice("call-20", "20", "clear_mistake",
                    "That is the pot, not the call.", {betterChoiceId: "call-10"}),
                  choice("call-30", "30", "clear_mistake",
                    "That is the pot after you call — you only put in 10.",
                    {betterChoiceId: "call-10"})
                ],
              }),
              selectAct({
                id: "act-03-03-01-unguided", order: 4, stage: "unguided",
                prompt: "Pot 20, bet 10 (call 10 into 30). You have ~8 clean outs on the turn. Call?",
                a11y: "Nine-outish equity is close; with implied odds deep, call is fine.",
                objectives: ["Compare pot odds to draw equity"],
                lifeLoss: true,
                choices: [
                  choice("call-draw", "Call — price is acceptable with outs", "recommended",
                    "Getting 3:1 with real outs is a continue, especially deep."),
                  choice("fold-draw", "Fold always without a made hand", "clear_mistake",
                    "Draws can be priced in.", {betterChoiceId: "call-draw"}),
                  choice("raise-auto", "Raise every draw", "questionable",
                    "Sometimes; here the assignment is whether the call prices.")
                ],
              }),
              selectAct({
                id: "act-03-03-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "200bb deep. Nut flush draw, pot-sized bet from a sticky caller. Edge?",
                a11y: "Deep stacks add implied odds versus sticky players.",
                objectives: ["Use implied-odds intuition deep-stacked"],
                lifeLoss: true,
                choices: [
                  choice("implied-yes", "Implied odds improve — they pay when you hit", "recommended",
                    "Deep stacks plus a caller who sticks around pay off the nuts."),
                  choice("implied-no", "Depth never changes draw price", "clear_mistake",
                    "Future streets matter when stacks are deep.", {betterChoiceId: "implied-yes"}),
                  choice("fold-nfd", "Fold nut flush draws to any bet", "clear_mistake",
                    "This is a premium continue.", {betterChoiceId: "implied-yes"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-03-04-flop-decisions", 4, "Flop decisions",
        "Value bet, c-bet, check back, call, fold, raise.", [
          lesson({
            id: L030401, order: 1,
            title: "Choose a flop line",
            summary: "Pick value, protection, pot control, or give-up on the flop.",
            objectives: ["Value bet strong made hands", "C-bet selectively as the preflop aggressor", "Check back, call, fold, or raise with a plan"],
            prereq: L030301, remediation: L030301, minutes: 9, band: 3,
            activities: [
              dialogue("act-03-04-01-explain", 1,
                "Flop lines: value, c-bet, check back, call, fold, raise. One plan.",
                {objectives: ["Value bet strong made hands"]}),
              actionAct({
                id: "act-03-04-01-guided", order: 2, stage: "guided",
                prompt: "Heads-up. You hold top pair top kicker. Checked to you. Action?",
                a11y: "Bet for value with TPTK.",
                objectives: ["Value bet strong made hands"],
                choices: [
                  choice("bet-tp", "Bet half pot", "recommended",
                    "Get value and deny free cards.", {action: "BET", amountBb: 4}),
                  choice("check-tp", "Check back", "questionable",
                    "Pot control is okay sometimes; value is cleaner here.", {action: "CHECK"}),
                  choice("fold-tp", "Fold", "clear_mistake",
                    "Do not fold TPTK unbet into.", {action: "FOLD", betterChoiceId: "bet-tp"})
                ],
              }),
              actionAct({
                id: "act-03-04-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "You opened BTN, BB called. Flop As 7d 2c. You have KQo. Action?",
                a11y: "High-card air can c-bet a dry ace-high board selectively.",
                objectives: ["C-bet selectively as the preflop aggressor"],
                choices: [
                  choice("cbet", "C-bet small", "recommended",
                    "Dry ace boards favor the opener's range.", {action: "BET", amountBb: 3}),
                  choice("check-kq", "Check back", "reasonable",
                    "Checking is fine; a small c-bet is still standard.", {action: "CHECK"}),
                  choice("jam-kq", "Jam all-in", "clear_mistake",
                    "Oversizing with air is a leak.", {action: "ALL_IN", betterChoiceId: "cbet"})
                ],
              }),
              actionAct({
                id: "act-03-04-01-unguided", order: 4, stage: "unguided",
                prompt: "Multiway pot. Villain bets half pot. You flopped a set. Action?",
                a11y: "Raise a set for value multiway.",
                objectives: ["Check back, call, fold, or raise with a plan"], lifeLoss: true,
                choices: [
                  choice("raise-set", "Raise", "recommended",
                    "Build the pot with a monster while multiway.", {action: "RAISE", amountBb: 12}),
                  choice("call-set", "Call", "reasonable",
                    "Slow-playing is okay; raising extracts more multiway.", {action: "CALL"}),
                  choice("fold-set", "Fold", "clear_mistake",
                    "Never fold a set here.", {action: "FOLD", betterChoiceId: "raise-set"})
                ],
              }),
              actionAct({
                id: "act-03-04-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Three players. Flop bets and a raise ahead. You have bottom pair. Action?",
                a11y: "Fold weak one-pair multiway to heat.",
                objectives: ["Check back, call, fold, or raise with a plan"], lifeLoss: true,
                choices: [
                  choice("fold-bp", "Fold", "recommended",
                    "Bottom pair dies to multiway aggression.", {action: "FOLD"}),
                  choice("call-bp", "Call", "clear_mistake",
                    "Dominated and priced poorly.", {action: "CALL", betterChoiceId: "fold-bp"}),
                  choice("raise-bp", "Raise", "clear_mistake",
                    "Do not bluff-raise crowds with bottom pair.", {action: "RAISE", amountBb: 15, betterChoiceId: "fold-bp"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-03-05-turn-decisions", 5, "Turn decisions",
        "Brick versus changing card, second barrel, delayed aggression.", [
          lesson({
            id: L030501, order: 1,
            title: "Plan the turn card",
            summary: "React to bricks and scare cards with a second barrel or delay.",
            objectives: ["Recognize brick versus changing turns", "Fire a second barrel with a plan", "Use delayed aggression when checked to"],
            prereq: L030401, remediation: L030401, minutes: 8, band: 3,
            activities: [
              dialogue("act-03-05-01-explain", 1,
                "Turn cards either brick or change the story. Barrel or delay with intent.",
                {objectives: ["Recognize brick versus changing turns"]}),
              selectAct({
                id: "act-03-05-01-guided", order: 2, stage: "guided",
                prompt: "Flop As 7d 2c. Turn 3h. For a missed c-bettor, is this a brick?",
                a11y: "A blank three is a brick on this dry ace board.",
                objectives: ["Recognize brick versus changing turns"],
                choices: [
                  choice("brick", "Brick — rarely helps the caller", "recommended",
                    "Low blank keeps the ace-high story intact."),
                  choice("scare", "Major scare card", "clear_mistake",
                    "A three is not a flush or broadway completer here.", {betterChoiceId: "brick"}),
                  choice("always-change", "Every turn changes everything", "questionable",
                    "Some turns matter more than others.")
                ],
              }),
              actionAct({
                id: "act-03-05-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "You c-bet A-high flop with AK. Brick turn. Villain called flop. Action?",
                a11y: "Second barrel value with top pair top kicker.",
                objectives: ["Fire a second barrel with a plan"],
                choices: [
                  choice("barrel", "Bet again for value", "recommended",
                    "Still ahead of most flop calls.", {action: "BET", amountBb: 8}),
                  choice("check-ak", "Check", "reasonable",
                    "Pot control is fine; value betting is preferred.", {action: "CHECK"}),
                  choice("fold-ak", "Fold to a future bet preemptively", "clear_mistake",
                    "You act first — decide to bet or check.", {action: "FOLD", betterChoiceId: "barrel"})
                ],
              }),
              actionAct({
                id: "act-03-05-01-unguided", order: 4, stage: "unguided",
                prompt: "You checked back flop with a flush draw. Turn completes your flush. Checked to you. Action?",
                a11y: "Delayed value bet when the draw comes in.",
                objectives: ["Use delayed aggression when checked to"], lifeLoss: true,
                choices: [
                  choice("delay-bet", "Bet for value now", "recommended",
                    "Delayed aggression gets paid when you improve.", {action: "BET", amountBb: 7}),
                  choice("delay-check", "Check again always", "questionable",
                    "Checking may be tricky; value is clearer.", {action: "CHECK"}),
                  choice("delay-fold", "Fold the nuts", "clear_mistake",
                    "You have the flush.", {action: "FOLD", betterChoiceId: "delay-bet"})
                ],
              }),
              selectAct({
                id: "act-03-05-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "You bluffed flop on Kc 8d 3s. Turn Qh completes front-door draws. Plan?",
                a11y: "Scare cards often end unsupported barrels.",
                objectives: ["Use delayed aggression when checked to"], lifeLoss: true,
                choices: [
                  choice("give-up", "Often give up — changing card hurts air", "recommended",
                    "Unsupported second barrels die on draw-completing turns."),
                  choice("auto-jam", "Always jam larger", "clear_mistake",
                    "Sizing up without equity is a leak.", {betterChoiceId: "give-up"}),
                  choice("ignore", "Treat every turn like a brick", "clear_mistake",
                    "Board texture matters.", {betterChoiceId: "give-up"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-03-06-river-decisions", 6, "River decisions",
        "Value, bluff, bluff-catch, fold.", [
          lesson({
            id: L030601, order: 1,
            title: "Close the river correctly",
            summary: "Pick value, bluff, bluff-catch, or fold on the end.",
            objectives: ["Value bet hands that beat calling ranges", "Bluff only with a credible story", "Bluff-catch or fold with clarity"],
            prereq: L030501, remediation: L030501, minutes: 8, band: 3,
            activities: [
              dialogue("act-03-06-01-explain", 1,
                "River is binary: value, bluff, bluff-catch, or fold. No mystery floats.",
                {objectives: ["Value bet hands that beat calling ranges"]}),
              actionAct({
                id: "act-03-06-01-guided", order: 2, stage: "guided",
                prompt: "River bricks. You have top two pair. Villain checked. Action?",
                a11y: "Value bet two pair on a brick river.",
                objectives: ["Value bet hands that beat calling ranges"],
                choices: [
                  choice("val-bet", "Bet for value", "recommended",
                    "Two pair gets called by worse one-pair hands.", {action: "BET", amountBb: 10}),
                  choice("val-check", "Check", "questionable",
                    "Checking misses value.", {action: "CHECK"}),
                  choice("val-fold", "Fold", "clear_mistake",
                    "You are value-betting, not folding.", {action: "FOLD", betterChoiceId: "val-bet"})
                ],
              }),
              actionAct({
                id: "act-03-06-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "You missed a flush draw after betting twice. River completes the flush. Action?",
                a11y: "Represent the flush as a bluff when the story fits.",
                objectives: ["Bluff only with a credible story"],
                choices: [
                  choice("bluff", "Bluff the completed flush", "recommended",
                    "Your line tells a flush story.", {action: "BET", amountBb: 14}),
                  choice("giveup", "Give up — never bluff rivers", "questionable",
                    "Some rivers are bluff candidates; this one is.", {action: "CHECK"}),
                  choice("tiny", "Bet 1 chip as a joke", "clear_mistake",
                    "Live sizing should look like a real hand.", {action: "BET", amountBb: 0.5, betterChoiceId: "bluff"})
                ],
              }),
              actionAct({
                id: "act-03-06-01-unguided", order: 4, stage: "unguided",
                prompt: "You have top pair weak kicker. Villain jams river after a quiet line. Action?",
                a11y: "Often fold weak top pair to a huge river jam.",
                objectives: ["Bluff-catch or fold with clarity"], lifeLoss: true,
                choices: [
                  choice("fold-weak", "Fold", "recommended",
                    "Weak kickers lose to value-heavy jams.", {action: "FOLD"}),
                  choice("call-weak", "Call", "questionable",
                    "Sometimes a bluff-catch; default is fold versus quiet-then-jam.", {action: "CALL"}),
                  choice("raise-weak", "Re-raise all-in", "clear_mistake",
                    "Do not turn a bluff-catch into a bluff.", {action: "RAISE", amountBb: 50, betterChoiceId: "fold-weak"})
                ],
              }),
              selectAct({
                id: "act-03-06-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Which river job matches medium-strength one pair versus a big bet?",
                a11y: "Medium one pair is often a bluff-catch decision.",
                objectives: ["Bluff-catch or fold with clarity"], lifeLoss: true,
                choices: [
                  choice("role-catch", "Bluff-catch or fold — not thin value", "recommended",
                    "Versus a big bet you decide if they bluff enough."),
                  choice("role-value", "Always thin-value shove", "clear_mistake",
                    "Facing a bet you are not value-betting.", {betterChoiceId: "role-catch"}),
                  choice("role-air", "Pure bluff with one pair", "clear_mistake",
                    "One pair is showdown value, not a bluff.", {betterChoiceId: "role-catch"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-03-07-multiway", 7, "Multiway fundamentals",
        "Stronger ranges, less bluffing, position and nut potential.", [
          lesson({
            id: L030701, order: 1,
            title: "Play tighter multiway",
            summary: "Need stronger holdings and nut potential when many players see flops.",
            objectives: ["Demand stronger made hands multiway", "Bluff less with players left to act", "Prefer nut potential and position"],
            prereq: L030601, remediation: L030601, minutes: 8, band: 3,
            activities: [
              dialogue("act-03-07-01-explain", 1,
                "More players: stronger value, fewer bluffs, chase nuts not second-best.",
                {objectives: ["Demand stronger made hands multiway"]}),
              actionAct({
                id: "act-03-07-01-guided", order: 2, stage: "guided",
                prompt: "Four players to the flop. You have second pair. Checked to you. Action?",
                a11y: "Often check second pair multiway.",
                objectives: ["Demand stronger made hands multiway"],
                choices: [
                  choice("check-2p", "Check", "recommended",
                    "Second pair is not automatic value four ways.", {action: "CHECK"}),
                  choice("bet-2p", "Bet large for value", "questionable",
                    "Sometimes; multiway prefers stronger value.", {action: "BET", amountBb: 6}),
                  choice("jam-2p", "Jam", "clear_mistake",
                    "Overplaying medium strength multiway.", {action: "ALL_IN", betterChoiceId: "check-2p"})
                ],
              }),
              actionAct({
                id: "act-03-07-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Three callers behind. You missed entirely on a wet board. Action?",
                a11y: "Do not bluff into a crowd.",
                objectives: ["Bluff less with players left to act"],
                choices: [
                  choice("mw-check", "Check or give up", "recommended",
                    "Bluffs need folds; crowds call.", {action: "CHECK"}),
                  choice("mw-bluff", "Bluff large", "clear_mistake",
                    "Too many players left.", {action: "BET", amountBb: 10, betterChoiceId: "mw-check"}),
                  choice("mw-min", "Min-bluff", "clear_mistake",
                    "Tiny bluffs get called multiway.", {action: "BET", amountBb: 1, betterChoiceId: "mw-check"})
                ],
              }),
              selectAct({
                id: "act-03-07-01-unguided", order: 4, stage: "unguided",
                prompt: "Multiway. Choose the better speculative hand deep.",
                a11y: "Suited connectors with nut potential beat dominated offsuit trash.",
                objectives: ["Prefer nut potential and position"], lifeLoss: true,
                choices: [
                  choice("sc", "Suited connector in position", "recommended",
                    "Nut flushes/straights cash multiway."),
                  choice("kto", "KTo out of position", "clear_mistake",
                    "Dominated and awkward multiway.", {betterChoiceId: "sc"}),
                  choice("q6o", "Q6o any seat", "clear_mistake",
                    "Trash without nut potential.", {betterChoiceId: "sc"})
                ],
              }),
              selectAct({
                id: "act-03-07-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "One seat has entered eight of the last ten pots with calls. Observation?",
                a11y: "Tag high participation without naming an archetype yet.",
                objectives: ["Prefer nut potential and position"], lifeLoss: true,
                choices: [
                  choice("obs-many", "They play many hands — note it", "recommended",
                    "Record participation. Labels come later."),
                  choice("obs-ignore", "Ignore seat history", "clear_mistake",
                    "Live reads start with counts.", {betterChoiceId: "obs-many"}),
                  choice("obs-label", "Immediately insult their personality", "clear_mistake",
                    "Observe behavior; do not moralize.", {betterChoiceId: "obs-many"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-03-08-leak-repair", 8, "Leak repair",
        "Top-pair overplay, bad prices, passive calling, bluffing crowds.", [
          lesson({
            id: L030801, order: 1,
            title: "Patch the common leaks",
            summary: "Fix overplaying top pair, chasing bad prices, and bluffing crowds.",
            objectives: ["Stop overplaying weak top pair", "Fold draws at bad prices", "Avoid passive calling and crowd bluffs"],
            prereq: L030701, remediation: L030401, minutes: 9, band: 3,
            activities: [
              dialogue("act-03-08-01-explain", 1,
                "Common leaks: worship top pair, chase bad prices, call too passive, bluff crowds.",
                {objectives: ["Stop overplaying weak top pair"]}),
              actionAct({
                id: "act-03-08-01-guided", order: 2, stage: "guided",
                prompt: "Multiway raise-reraise pot. You have top pair weak kicker. Action?",
                a11y: "Fold or play cautious — do not stack with weak top pair.",
                objectives: ["Stop overplaying weak top pair"],
                choices: [
                  choice("careful", "Fold or keep the pot small", "recommended",
                    "Weak kickers lose big multiway pots.", {action: "FOLD"}),
                  choice("stack", "Jam for stacks", "clear_mistake",
                    "Classic overplay.", {action: "ALL_IN", betterChoiceId: "careful"}),
                  choice("call-down", "Silent call-down forever", "questionable",
                    "Sometimes; default is not stacking lightly.", {action: "CALL"})
                ],
              }),
              actionAct({
                id: "act-03-08-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Gutshot only. Pot 12, bet 18. Action?",
                a11y: "Fold a gutshot to an oversized bet.",
                objectives: ["Fold draws at bad prices"],
                choices: [
                  choice("fold-gut", "Fold", "recommended",
                    "Price is terrible for four outs.", {action: "FOLD"}),
                  choice("call-gut", "Call", "clear_mistake",
                    "Not getting the right price.", {action: "CALL", betterChoiceId: "fold-gut"}),
                  choice("raise-gut", "Bluff-raise", "questionable",
                    "Rarely; not the leak repair baseline.", {action: "RAISE", amountBb: 40})
                ],
              }),
              actionAct({
                id: "act-03-08-01-unguided", order: 4, stage: "unguided",
                prompt: "Four players. You have no pair, no draw. Someone bets. Action?",
                a11y: "Fold air multiway; do not float or bluff the crowd.",
                objectives: ["Avoid passive calling and crowd bluffs"], lifeLoss: true,
                choices: [
                  choice("fold-air", "Fold", "recommended",
                    "No equity, no bluff target.", {action: "FOLD"}),
                  choice("float-air", "Call to keep them honest", "clear_mistake",
                    "Passive calling with air is a leak.", {action: "CALL", betterChoiceId: "fold-air"}),
                  choice("bluff-crowd", "Raise as a bluff", "clear_mistake",
                    "Crowds call.", {action: "RAISE", amountBb: 20, betterChoiceId: "fold-air"})
                ],
              }),
              selectAct({
                id: "act-03-08-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Seat A raises often; Seat B almost never enters. Best notes?",
                a11y: "Track raise-versus-call and participation without labels.",
                objectives: ["Avoid passive calling and crowd bluffs"], lifeLoss: true,
                choices: [
                  choice("notes", "A raises a lot; B plays few hands", "recommended",
                    "Behavior notes only — no fixed labels yet."),
                  choice("guess", "Invent life stories for both", "clear_mistake",
                    "Stick to observed frequencies.", {betterChoiceId: "notes"}),
                  choice("same", "Treat every seat identically forever", "clear_mistake",
                    "You already have evidence.", {betterChoiceId: "notes"})
                ],
              }),
            ],
          }),
          lesson({
            id: L030802, order: 2,
            title: "Section 3 jump check",
            summary: "Placement-style check on live postflop competence.",
            objectives: ["Confirm table reading", "Confirm flop classes and price", "Confirm street plans and multiway discipline"],
            prereq: L030801, remediation: L030101, minutes: 10, band: 3,
            activities: [
              selectAct({
                id: "act-03-08-02-jump-table", order: 1, stage: "jump_test",
                prompt: "Pot 16, shorter stack 40bb. What do you track first?",
                a11y: "Jump: pot and effective stack.",
                objectives: ["Confirm table reading"],
                lifeLoss: true,
                choices: [
                  choice("j3-track", "Pot and effective 40bb", "recommended",
                    "Price and commitment frame the hand."),
                  choice("j3-ignore", "Only hole cards", "clear_mistake",
                    "Table state comes first.", {betterChoiceId: "j3-track"}),
                  choice("j3-chat", "Only table talk", "clear_mistake",
                    "Useful later — not instead of pot/stacks.", {betterChoiceId: "j3-track"})
                ],
              }),
              selectAct({
                id: "act-03-08-02-jump-class", order: 2, stage: "jump_test",
                prompt: "Board Qd 9d 3c. You hold Jd Td. Class?",
                a11y: "Jump: combo draw.",
                objectives: ["Confirm flop classes and price"],
                lifeLoss: true,
                choices: [
                  choice("j3-draw", "Draw — straight and flush potential", "recommended",
                    "Open-ender plus flush draw."),
                  choice("j3-made", "Made two pair", "clear_mistake",
                    "No pair yet.", {betterChoiceId: "j3-draw"}),
                  choice("j3-air", "Air", "questionable",
                    "This has strong equity — still a draw.")
                ],
              }),
              actionAct({
                id: "act-03-08-02-jump-mw", order: 3, stage: "jump_test",
                prompt: "Four-way. You have air on a wet flop. Action?",
                a11y: "Jump: fold air multiway.",
                objectives: ["Confirm street plans and multiway discipline"],
                lifeLoss: true,
                choices: [
                  choice("j3-fold", "Fold", "recommended",
                    "Do not bluff crowds.", {action: "FOLD"}),
                  choice("j3-bluff", "Bluff large", "clear_mistake",
                    "Multiway bluffs fail.", {action: "BET", amountBb: 12, betterChoiceId: "j3-fold"})
                ],
              }),
              actionAct({
                id: "act-03-08-02-jump-river", order: 4, stage: "jump_test",
                prompt: "Brick river. You have top two. Villain checks. Action?",
                a11y: "Jump: value bet two pair.",
                objectives: ["Confirm street plans and multiway discipline"],
                lifeLoss: true,
                choices: [
                  choice("j3-val", "Bet value", "recommended",
                    "Two pair value bets.", {action: "BET", amountBb: 10}),
                  choice("j3-check", "Check always", "questionable",
                    "Misses value.", {action: "CHECK"}),
                  choice("j3-fold2", "Fold", "clear_mistake",
                    "You are ahead.", {action: "FOLD", betterChoiceId: "j3-val"})
                ],
              }),
              selectAct({
                id: "act-03-08-02-jump-leak", order: 5, stage: "jump_test",
                prompt: "Gutshot, pot 10, face a 20 bet. Fix the leak?",
                a11y: "Jump: fold bad price.",
                objectives: ["Confirm flop classes and price"],
                lifeLoss: true,
                choices: [
                  choice("j3-foldprice", "Fold — price is wrong", "recommended",
                    "Stop chasing bad prices."),
                  choice("j3-callprice", "Call because any draw is lucky", "clear_mistake",
                    "Math first.", {betterChoiceId: "j3-foldprice"})
                ],
              }),
            ],
          }),
        ]),
    ],
  };
}

export const SECTION_THREE_EXIT_LESSON =
  "lesson-03-08-02-section-three-jump-test";

/** Player-type intro lesson ids (catalog playerTypes.introducedByLessonId). */
export const MEET_CALLING_STATION = "lesson-04-06-02-meet-calling-station";
export const MEET_NIT = "lesson-04-07-02-meet-nit";
export const MEET_MANIAC = "lesson-04-08-02-meet-maniac";

/** @returns {object} Section 4 — Regular Live Cash Player */
export function buildSectionFour() {
  const prev = SECTION_THREE_EXIT_LESSON;
  const L040101 = "lesson-04-01-01-ranges-not-hands";
  const L040201 = "lesson-04-02-01-threebet-squeeze";
  const L040301 = "lesson-04-03-01-continuation-plans";
  const L040401 = "lesson-04-04-01-sizing-communicates";
  const L040501 = "lesson-04-05-01-spr-commitment";
  const L040601 = "lesson-04-06-01-observe-sticky-caller";
  const L040602 = MEET_CALLING_STATION;
  const L040603 = "lesson-04-06-03-adjust-calling-station";
  const L040701 = "lesson-04-07-01-observe-narrow-player";
  const L040702 = MEET_NIT;
  const L040703 = "lesson-04-07-03-adjust-nit";
  const L040801 = "lesson-04-08-01-observe-wild-aggressor";
  const L040802 = MEET_MANIAC;
  const L040803 = "lesson-04-08-03-adjust-maniac";
  const L040901 = "lesson-04-09-01-type-identification";
  const L041001 = "lesson-04-10-01-exploit-checkpoints";
  const L041002 = "lesson-04-10-02-section-four-jump-test";

  return {
    id: "sec-04-regular-live",
    order: 4,
    title: "Regular Live Cash Player",
    summary: "Build ranges, recognize opponents, and make deliberate exploits.",
    experienceBand: "regular_live",
    units: [
      unit("unit-04-01-ranges", 1, "Ranges, not exact hands",
        "Think in sets of hands instead of a single holding.", [
          lesson({
            id: L040101, order: 1,
            title: "Think in ranges",
            summary: "Replace exact-hand mind-reading with range construction.",
            objectives: ["Describe a seat as a range", "Widen or narrow ranges with action", "Avoid assigning one exact hand too early"],
            prereq: prev, remediation: prev, minutes: 8, band: 3,
            activities: [
              dialogue("act-04-01-01-explain", 1,
                "You never know one hand. You know a range — then update it.",
                {objectives: ["Describe a seat as a range"]}),
              selectAct({
                id: "act-04-01-01-guided", order: 2, stage: "guided",
                prompt: "UTG opens at 1/2. Best description?",
                a11y: "Early opens are a stronger, narrower range.",
                objectives: ["Describe a seat as a range"],
                choices: [
                  choice("strong-narrow", "Stronger, narrower range", "recommended",
                    "Early position opens fewer hands."),
                  choice("any-two", "Any two cards", "clear_mistake",
                    "UTG is not that wide live.", {betterChoiceId: "strong-narrow"}),
                  choice("exact-ak", "Exactly Ace-King", "clear_mistake",
                    "Do not collapse to one hand.", {betterChoiceId: "strong-narrow"})
                ],
              }),
              selectAct({
                id: "act-04-01-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "BTN opens, BB 3-bets, BTN calls. Whose range is stronger?",
                a11y: "The 3-bettor's range is stronger.",
                objectives: ["Widen or narrow ranges with action"],
                choices: [
                  choice("bb-stronger", "Big blind 3-bet range is stronger", "recommended",
                    "Calling a 3-bet is wider than 3-betting."),
                  choice("btn-stronger", "Button call is stronger", "clear_mistake",
                    "Callers include more speculative hands.", {betterChoiceId: "bb-stronger"}),
                  choice("equal", "Identical ranges", "clear_mistake",
                    "Action asymmetry matters.", {betterChoiceId: "bb-stronger"})
                ],
              }),
              selectAct({
                id: "act-04-01-01-unguided", order: 4, stage: "unguided",
                prompt: "Villain bets twice. You decide they have exactly AK. Problem?",
                a11y: "Over-precision is a leak.",
                objectives: ["Avoid assigning one exact hand too early"], lifeLoss: true,
                choices: [
                  choice("too-exact", "Too exact — keep a weighted range", "recommended",
                    "AK is one node in a range, not the whole story."),
                  choice("fine-exact", "Exact hands are always knowable", "clear_mistake",
                    "Live poker is probabilistic.", {betterChoiceId: "too-exact"}),
                  choice("ignore-action", "Ignore betting pattern entirely", "clear_mistake",
                    "Patterns update ranges; they do not print exact hands.", {betterChoiceId: "too-exact"})
                ],
              }),
              selectAct({
                id: "act-04-01-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Same board. Same hero hand. Different villain lines. Result?",
                a11y: "Recommendations change only when the read/range changes.",
                objectives: ["Avoid assigning one exact hand too early"], lifeLoss: true,
                choices: [
                  choice("read-drives", "Advice may change when the range changes", "recommended",
                    "Exploits follow evidence, not vibes."),
                  choice("always-same", "Always do the same thing forever", "clear_mistake",
                    "Baseline is shared; exploits diverge with reads.", {betterChoiceId: "read-drives"}),
                  choice("random", "Pick randomly for unpredictability", "clear_mistake",
                    "Plans beat randomness.", {betterChoiceId: "read-drives"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-04-02-threebet", 2, "3-bet and squeezed pots",
        "Play raised and re-raised pots with clear roles.", [
          lesson({
            id: L040201, order: 1,
            title: "Navigate 3-bet pots",
            summary: "Value 3-bet, defend or fold, and understand squeezes.",
            objectives: ["Value 3-bet strong hands", "Fold or continue correctly versus 3-bets", "Recognize squeeze spots multiway"],
            prereq: L040101, remediation: L040101, minutes: 8, band: 3,
            activities: [
              dialogue("act-04-02-01-explain", 1,
                "3-bets define ranges. Squeezes punish multiway limps and flatting.",
                {objectives: ["Value 3-bet strong hands"]}),
              actionAct({
                id: "act-04-02-01-guided", order: 2, stage: "guided",
                prompt: "CO opens to 6. You have QQ on the button. Action?",
                a11y: "3-bet queens for value.",
                objectives: ["Value 3-bet strong hands"],
                choices: [
                  choice("3bet-qq", "3-bet to ~18", "recommended",
                    "Queens raise for value.", {action: "RAISE", amountBb: 9}),
                  choice("call-qq", "Call", "reasonable",
                    "Flat is playable; value 3-bet is cleaner.", {action: "CALL"}),
                  choice("fold-qq", "Fold", "clear_mistake",
                    "Do not fold queens.", {action: "FOLD", betterChoiceId: "3bet-qq"})
                ],
              }),
              actionAct({
                id: "act-04-02-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "You open BTN to 6. BB 3-bets to 20. You have 72o. Action?",
                a11y: "Fold trash to a 3-bet.",
                objectives: ["Fold or continue correctly versus 3-bets"],
                choices: [
                  choice("fold-72", "Fold", "recommended",
                    "No playability versus a 3-bet.", {action: "FOLD"}),
                  choice("call-72", "Call", "clear_mistake",
                    "Dominated trash.", {action: "CALL", betterChoiceId: "fold-72"}),
                  choice("4bet-72", "4-bet bluff", "clear_mistake",
                    "Not with 72o.", {action: "RAISE", amountBb: 50, betterChoiceId: "fold-72"})
                ],
              }),
              actionAct({
                id: "act-04-02-01-unguided", order: 4, stage: "unguided",
                prompt: "UTG opens, two callers. You have AKo in the big blind. Action?",
                a11y: "Squeeze with strong hands multiway.",
                objectives: ["Recognize squeeze spots multiway"], lifeLoss: true,
                choices: [
                  choice("squeeze", "Squeeze to ~20", "recommended",
                    "Punish the multiway flat with a strong hand.",
                    {action: "RAISE", amountBb: 10}),
                  choice("limp-more", "Limp behind", "clear_mistake",
                    "You already posted; raise or fold — do not limp.",
                    {action: "CALL", betterChoiceId: "squeeze"}),
                  choice("fold-ak", "Fold", "clear_mistake",
                    "Too strong.", {action: "FOLD", betterChoiceId: "squeeze"})
                ],
              }),
              actionAct({
                id: "act-04-02-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Live open is 6. Choose a value 3-bet size with KK.",
                a11y: "Soft-grade nearby live 3-bet sizes.",
                objectives: ["Recognize squeeze spots multiway"], lifeLoss: true,
                choices: [
                  choice("size-18", "3-bet to 18", "recommended",
                    "About 3x is a clean live value size.", {action: "RAISE", amountBb: 9}),
                  choice("size-20", "3-bet to 20", "strong",
                    "Slightly larger is still fine.", {action: "RAISE", amountBb: 10}),
                  choice("size-22", "3-bet to 22", "reasonable",
                    "A bit big but acceptable live.", {action: "RAISE", amountBb: 11}),
                  choice("size-7", "3-bet to 7", "clear_mistake",
                    "That is not a real re-raise.", {action: "RAISE", amountBb: 3.5, betterChoiceId: "size-18"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-04-03-continuation", 3, "Continuation plans across streets",
        "Choose lines that still make sense on later streets.", [
          lesson({
            id: L040301, order: 1,
            title: "Plan beyond the flop",
            summary: "Pick flop actions that leave turn and river options.",
            objectives: ["Build a multi-street plan", "Abort plans when the board changes", "Keep pot size matched to hand strength"],
            prereq: L040201, remediation: L040201, minutes: 8, band: 3,
            activities: [
              dialogue("act-04-03-01-explain", 1,
                "Every flop choice should answer: what do I do on turn and river?",
                {objectives: ["Build a multi-street plan"]}),
              multiStepAct({
                id: "act-04-03-01-guided", order: 2, stage: "guided",
                a11y: "Plan top pair across flop and turn.",
                objectives: ["Build a multi-street plan"],
                steps: [
                  {
                    id: "step-flop-tp",
                    street: "flop",
                    prompt: "Heads-up with TPTK on a dry flop. Checked to you.",
                    accessibilityText: "Bet flop for value.",
                    choices: [
                  choice("flop-bet", "Bet", "recommended",
                    "Start the value plan.", {action: "BET", amountBb: 4}),
                  choice("flop-check", "Check", "reasonable",
                    "Pot control is okay; betting starts the plan.", {action: "CHECK"})
                    ],
                  },
                  {
                    id: "step-turn-tp",
                    street: "turn",
                    prompt: "Brick turn. Villain calls flop. Continue?",
                    accessibilityText: "Second barrel for value.",
                    choices: [
                  choice("turn-bet", "Bet again", "recommended",
                    "Continue value on a brick.", {action: "BET", amountBb: 9}),
                  choice("turn-check", "Check", "reasonable",
                    "Acceptable; value betting is preferred.", {action: "CHECK"})
                    ],
                  },
                ],
              }),
              actionAct({
                id: "act-04-03-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "You bluffed flop. Turn puts four to a flush; you have no heart. Action?",
                a11y: "Abort unsupported barrels on changing boards.",
                objectives: ["Abort plans when the board changes"],
                choices: [
                  choice("abort", "Check", "recommended",
                    "The story got worse for air.", {action: "CHECK"}),
                  choice("bigger", "Bet bigger", "clear_mistake",
                    "Do not auto-escalate.", {action: "BET", amountBb: 16, betterChoiceId: "abort"}),
                  choice("ignore-board", "Bet as if dry", "clear_mistake",
                    "Board texture is the plan update.", {action: "BET", amountBb: 8, betterChoiceId: "abort"})
                ],
              }),
              actionAct({
                id: "act-04-03-01-unguided", order: 4, stage: "unguided",
                prompt: "Medium strength, deep stacks, multiway. Prefer?",
                a11y: "Keep medium hands in smaller pots.",
                objectives: ["Keep pot size matched to hand strength"],
                lifeLoss: true,
                choices: [
                  choice("small-pot", "Keep pot small", "recommended",
                    "Medium hands hate gigantic multiway pots.", {action: "CHECK"}),
                  choice("jam-med", "Jam stacks in", "clear_mistake",
                    "Over-commitment with medium strength.",
                    {action: "ALL_IN", betterChoiceId: "small-pot"})
                ],
              }),
              selectAct({
                id: "act-04-03-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Good multi-street plans do what?",
                a11y: "Plans state flop intent and turn/river branches.",
                objectives: ["Build a multi-street plan"],
                lifeLoss: true,
                choices: [
                  choice("branches", "Brick → barrel · flush → abort", "recommended",
                    "If X card, continue; if Y card, shut down."),
                  choice("vibes", "Wait for vibes each street", "clear_mistake",
                    "Author a plan first.", {betterChoiceId: "branches"}),
                  choice("one-street", "Only this street, always", "questionable",
                    "One street is incomplete for live depth.")
                ],
              }),
            ],
          }),
        ]),
      unit("unit-04-04-sizing", 4, "Bet sizing that communicates a range",
        "Choose sizes that match the story you want to tell.", [
          lesson({
            id: L040401, order: 1,
            title: "Size with a message",
            summary: "Live sizing should look like value or pressure on purpose.",
            objectives: ["Match size to value versus polar pressure", "Accept nearby reasonable live sizes", "Avoid tiny or nonsensical sizes"],
            prereq: L040301, remediation: L040301, minutes: 8, band: 3,
            activities: [
              dialogue("act-04-04-01-explain", 1,
                "Size is language. Value looks like value; pressure looks like pressure.",
                {objectives: ["Match size to value versus polar pressure"]}),
              actionAct({
                id: "act-04-04-01-guided", order: 2, stage: "guided",
                prompt: "Dry board, top pair, heads-up. Choose a value size into 20.",
                a11y: "Half to two-thirds pot is fine value.",
                objectives: ["Match size to value versus polar pressure"],
                choices: [
                  choice("half", "Bet 10", "recommended",
                    "Half pot is a clean value ask.", {action: "BET", amountBb: 5}),
                  choice("two-third", "Bet 14", "strong",
                    "Also a fine value size.", {action: "BET", amountBb: 7}),
                  choice("pot", "Bet 20", "reasonable",
                    "A bit large for thin value; still acceptable.", {action: "BET", amountBb: 10}),
                  choice("one-chip", "Bet 1", "clear_mistake",
                    "Does not look like value.", {action: "BET", amountBb: 0.5, betterChoiceId: "half"})
                ],
              }),
              actionAct({
                id: "act-04-04-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Missed draw, credible river scare card. Choose pressure size into 40.",
                a11y: "Larger polar sizes sell the story.",
                objectives: ["Accept nearby reasonable live sizes"],
                choices: [
                  choice("big", "Bet 30-40", "recommended",
                    "Polar pressure needs a real number.", {action: "BET", amountBb: 18}),
                  choice("tiny-bluff", "Bet 2", "clear_mistake",
                    "Not credible.", {action: "BET", amountBb: 1, betterChoiceId: "big"}),
                  choice("check-bluff", "Check and hope", "questionable",
                    "Giving up is fine; tiny bets are worse.", {action: "CHECK"})
                ],
              }),
              selectAct({
                id: "act-04-04-01-unguided", order: 4, stage: "unguided",
                prompt: "Two value sizes both get worse hands to call. Grading idea?",
                a11y: "Nearby sizes earn soft grades.",
                objectives: ["Avoid tiny or nonsensical sizes"], lifeLoss: true,
                choices: [
                  choice("soft", "Nearby sizes both soft-grade", "recommended",
                    "Live sizing has a band, not one chip exactness."),
                  choice("one-only", "Only one chip count is correct", "clear_mistake",
                    "That overfits.", {betterChoiceId: "soft"}),
                  choice("random-size", "Even 1-chip bets are fine", "clear_mistake",
                    "Nonsensical sizes still fail.", {betterChoiceId: "soft"})
                ],
              }),
              actionAct({
                id: "act-04-04-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Pot 30. You want value with a strong hand. Worst size?",
                a11y: "One-chip value bets are clear mistakes.",
                objectives: ["Avoid tiny or nonsensical sizes"], lifeLoss: true,
                choices: [
                  choice("bad-1", "Bet 1", "recommended",
                    "Tiny bets do not look like value.", {action: "BET", amountBb: 0.5}),
                  choice("good-15", "Bet 15", "clear_mistake",
                    "Half pot is fine value — not the worst size.",
                    {action: "BET", amountBb: 7.5, betterChoiceId: "bad-1"}),
                  choice("good-20", "Bet 20", "clear_mistake",
                    "A real value size, not the worst.",
                    {action: "BET", amountBb: 10, betterChoiceId: "bad-1"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-04-05-spr", 5, "SPR and commitment",
        "Use stack-to-pot ratio to know when you are committed.", [
          lesson({
            id: L040501, order: 1,
            title: "SPR decides commitment",
            summary: "Low SPR means commit with strong hands; high SPR means caution.",
            objectives: ["Estimate stack-to-pot ratio", "Commit correctly at low SPR", "Keep flexibility at high SPR"],
            prereq: L040401, remediation: L040401, minutes: 8, band: 3,
            activities: [
              dialogue("act-04-05-01-explain", 1,
                "SPR = effective stack / pot. Low SPR: commit. High SPR: maneuver.",
                {objectives: ["Estimate stack-to-pot ratio"]}),
              numericAct({
                id: "act-04-05-01-guided", order: 2, stage: "guided",
                question: "Effective stack 80bb, pot 20bb. SPR?",
                a11y: "SPR is 4.",
                objectives: ["Estimate stack-to-pot ratio"],
                unit: "ratio", min: 4, max: 4,
                okFeedback: "80 / 20 = 4.",
                missFeedback: "Divide stack by pot: 80/20 = 4.",
              }),
              actionAct({
                id: "act-04-05-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "SPR ~1 after a 3-bet. You flop top set. Action?",
                a11y: "Get it in with top set at low SPR.",
                objectives: ["Commit correctly at low SPR"],
                choices: [
                  choice("commit", "Commit for stacks", "recommended",
                    "Low SPR + monster = get it in.", {action: "RAISE", amountBb: 20}),
                  choice("tiny", "Check forever", "clear_mistake",
                    "You are missing value and risking free cards.",
                    {action: "CHECK", betterChoiceId: "commit"})
                ],
              }),
              actionAct({
                id: "act-04-05-01-unguided", order: 4, stage: "unguided",
                prompt: "SPR 20, multiway, second pair. Prefer?",
                a11y: "High SPR medium hands keep pots smaller.",
                objectives: ["Keep flexibility at high SPR"],
                lifeLoss: true,
                choices: [
                  choice("flexible", "Keep pot small", "recommended",
                    "Deep SPR punishes medium-strength stacks-in.", {action: "CHECK"}),
                  choice("spr-jam", "Jam day one", "clear_mistake",
                    "Over-commitment.", {action: "ALL_IN", betterChoiceId: "flexible"})
                ],
              }),
              actionAct({
                id: "act-04-05-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "About to put stacks in. First?",
                a11y: "Check SPR before committing the rest.",
                objectives: ["Estimate stack-to-pot ratio"],
                lifeLoss: true,
                choices: [
                  choice("before", "Weigh SPR first", "recommended",
                    "Commitment is an SPR decision."),
                  choice("never", "Jam on cards alone", "clear_mistake",
                    "Depth changes correct plays.",
                    {action: "ALL_IN", betterChoiceId: "before"}),
                  choice("showdown-only", "Wait for showdown", "clear_mistake",
                    "Decide earlier.", {betterChoiceId: "before"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-04-06-calling-station", 6, "Player type: Calling Station",
        "Observe sticky calling, then label and exploit carefully.", [
          lesson({
            id: L040601, order: 1,
            title: "Observe sticky callers",
            summary: "Tag high participation and low folding before any label.",
            objectives: ["Tag high participation", "Tag low folding to bets", "Separate observation from certainty"],
            prereq: L040501, remediation: L040501, minutes: 7, band: 3,
            activities: [
              dialogue("act-04-06-01-explain", 1,
                "Before labels: who enters pots, who calls, who folds. Count samples.",
                {objectives: ["Tag high participation"]}),
              selectAct({
                id: "act-04-06-01-guided", order: 2, stage: "guided",
                prompt: "Seat calls preflop seven of nine hands. Observation?",
                a11y: "High participation noted.",
                objectives: ["Tag high participation"],
                choices: [
                  choice("high-part", "High participation", "recommended",
                    "They play many hands."),
                  choice("low-part", "Low participation", "clear_mistake",
                    "Seven of nine is high.", {betterChoiceId: "high-part"}),
                  choice("label-now", "Label archetype now", "clear_mistake",
                    "Observe first.", {betterChoiceId: "high-part"})
                ],
              }),
              selectAct({
                id: "act-04-06-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Same seat calls three streets with second pair twice tonight. Note?",
                a11y: "Low folding / sticky calls.",
                objectives: ["Tag low folding to bets"],
                choices: [
                  choice("sticky", "Sticky calls — low folding", "recommended",
                    "They continue without strong hands."),
                  choice("folds-alot", "They fold too much", "clear_mistake",
                    "Opposite evidence.", {betterChoiceId: "sticky"})
                ],
              }),
              selectAct({
                id: "act-04-06-01-unguided", order: 4, stage: "unguided",
                prompt: "One dramatic call. How confident is a type label?",
                a11y: "One hand is low confidence.",
                objectives: ["Separate observation from certainty"], lifeLoss: true,
                choices: [
                  choice("low-conf", "Low confidence — need samples", "recommended",
                    "One hand is a note, not a verdict."),
                  choice("sure", "Certain forever", "clear_mistake",
                    "Samples build confidence.", {betterChoiceId: "low-conf"})
                ],
              }),
              selectAct({
                id: "act-04-06-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Best pre-label note bundle?",
                a11y: "High participation plus low folding.",
                objectives: ["Separate observation from certainty"], lifeLoss: true,
                choices: [
                  choice("bundle", "Many hands · rarely folds", "recommended",
                    "That is the evidence bundle."),
                  choice("insult", "They are a bad person", "clear_mistake",
                    "Behavior, not judgment.", {betterChoiceId: "bundle"})
                ],
              }),
            ],
          }),
          lesson({
            id: L040602, order: 2,
            title: "Meet the Calling Station",
            summary: "Attach the Calling Station label to sticky-call evidence.",
            objectives: ["Introduce Calling Station", "Identify from evidence"],
            prereq: L040601, remediation: L040601, minutes: 7, band: 3,
            playerTypeRefs: ["calling_station"],
            introducesPlayerTypes: ["calling_station"],
            activities: [
              dialogue("act-04-06-02-explain", 1,
                "Calling Station is a working model: high participation, low folding.",
                {objectives: ["Introduce Calling Station"], playerTypeRefs: ["calling_station"]}),
              classifyAct({
                id: "act-04-06-02-guided", order: 2, stage: "guided",
                prompt: "Seat called three streets with second pair. Best working label?",
                a11y: "Calling Station fits sticky calls.",
                objectives: ["Identify from evidence"],
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("pt-station", "Calling Station", "recommended",
                    "Sticky calls are the Calling Station tell.", {reversalRead: "If they start folding rivers, retire the label."}),
                  choice("pt-nit", "Nit", "clear_mistake",
                    "Nits fold too much; this seat calls too much.", {betterChoiceId: "pt-station", reversalRead: "Nit evidence is narrow entry and overfolding."})
                ],
              }),
              selectAct({
                id: "act-04-06-02-scaffolded", order: 3, stage: "scaffolded",
                prompt: "A label is…",
                a11y: "Working model, not a personality judgment.",
                objectives: ["Introduce Calling Station"],
                choices: [
                  choice("model", "A working model from evidence", "recommended",
                    "Update or drop it as samples change."),
                  choice("soul", "A permanent personality verdict", "clear_mistake",
                    "Too rigid.", {betterChoiceId: "model"})
                ],
              }),
              classifyAct({
                id: "act-04-06-02-unguided", order: 4, stage: "unguided",
                prompt: "Seat limps often, calls raises, almost never folds turns. Label?",
                a11y: "Calling Station.",
                objectives: ["Identify from evidence"],
                lifeLoss: true,
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("station2", "Calling Station", "recommended",
                    "Participation + sticky continues.", {reversalRead: "If they 3-bet light and fold to barrels, rethink."}),
                  choice("maniac2", "Maniac", "clear_mistake",
                    "Maniacs raise and barrel; this seat calls.", {betterChoiceId: "station2", reversalRead: "Maniac evidence is extreme aggression."})
                ],
              }),
              selectAct({
                id: "act-04-06-02-checkpoint", order: 5, stage: "checkpoint",
                prompt: "After 2 hands, confidence in Calling Station should be?",
                a11y: "Low sample confidence.",
                objectives: ["Identify from evidence"],
                lifeLoss: true,
                choices: [
                  choice("low", "Low — keep collecting samples", "recommended",
                    "Display sample limits; do not overfit."),
                  choice("max", "Maximum certainty", "clear_mistake",
                    "Two hands are thin.", {betterChoiceId: "low"})
                ],
              }),
            ],
          }),
          lesson({
            id: L040603, order: 3,
            title: "Adjust versus Calling Station",
            summary: "Widen value and cut unsupported bluffs versus sticky callers.",
            objectives: ["Value wider versus Calling Station", "Bluff less without equity", "Cite the sticky-call tendency"],
            prereq: L040602, remediation: L040602, minutes: 8, band: 3,
            playerTypeRefs: ["calling_station"],
            activities: [
              dialogue("act-04-06-03-explain", 1,
                "Versus stations: thicker value, fewer pure bluffs. Cite their calling.",
                {objectives: ["Value wider versus Calling Station"], playerTypeRefs: ["calling_station"]}),
              actionAct({
                id: "act-04-06-03-guided", order: 2, stage: "guided",
                prompt: "Known sticky caller. You have second pair good kicker on river. Action?",
                a11y: "Thin value versus station.",
                objectives: ["Value wider versus Calling Station"],
                choices: [
                  choice("thin-val", "Bet thin value", "recommended",
                    "They call too wide — value thinner.", {action: "BET", amountBb: 8, reversalRead: "If they suddenly fold rivers, stop thinning value."}),
                  choice("check-val", "Check behind", "reasonable",
                    "Okay; you leave value behind versus a station.", {action: "CHECK"}),
                  choice("bluff-air", "Bluff-raise later with air", "clear_mistake",
                    "They do not fold.", {action: "RAISE", amountBb: 20, betterChoiceId: "thin-val", reversalRead: "Bluffs need folders; stations are not folders."})
                ],
              }),
              actionAct({
                id: "act-04-06-03-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Missed draw versus the same sticky seat. River brick. Action?",
                a11y: "Give up bluffs versus stations.",
                objectives: ["Bluff less without equity"],
                choices: [
                  choice("give-up", "Give up", "recommended",
                    "Unsupported bluffs fail when they never fold.", {action: "CHECK", reversalRead: "If evidence flips to overfolding, bluffs return."}),
                  choice("bluff-station", "Bluff large anyway", "clear_mistake",
                    "Tendency cited: low folding.", {action: "BET", amountBb: 20, betterChoiceId: "give-up", reversalRead: "Only bluff seats that fold enough."})
                ],
              }),
              actionAct({
                id: "act-04-06-03-unguided", order: 4, stage: "unguided",
                prompt: "Same second pair. Unknown opponent with no sample. Action?",
                a11y: "Baseline is more cautious without the station read.",
                objectives: ["Cite the sticky-call tendency"],
                lifeLoss: true,
                choices: [
                  choice("baseline-check", "Keep it cautious", "recommended",
                    "Without sticky evidence, do not auto-thin-value.", {action: "CHECK", reversalRead: "With sticky-call samples, thin value becomes recommended."}),
                  choice("auto-thin", "Always thin-value strangers", "questionable",
                    "Needs the calling tendency.", {action: "BET", amountBb: 8})
                ],
              }),
              selectAct({
                id: "act-04-06-03-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Why bluff less versus a Calling Station?",
                a11y: "Because they fold too little.",
                objectives: ["Cite the sticky-call tendency"],
                lifeLoss: true,
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("cite-fold", "They fold too rarely", "recommended",
                    "Exploit cites the specific tendency.", {reversalRead: "If fold frequency rises, re-open bluffs."}),
                  choice("cite-mean", "The label sounds mean", "clear_mistake",
                    "Cite behavior, not vibe.", {betterChoiceId: "cite-fold"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-04-07-nit", 7, "Player type: Nit",
        "Observe narrow entry, then label and exploit.", [
          lesson({
            id: L040701, order: 1,
            title: "Observe narrow players",
            summary: "Tag few hands and strong aggression before labeling.",
            objectives: ["Tag narrow entry", "Tag strong aggression when they play", "Wait for samples before labeling"],
            prereq: L040603, remediation: L040601, minutes: 7, band: 3,
            activities: [
              dialogue("act-04-07-01-explain", 1,
                "Some seats almost never enter. When they do, they mean it. Note both.",
                {objectives: ["Tag narrow entry"]}),
              selectAct({
                id: "act-04-07-01-guided", order: 2, stage: "guided",
                prompt: "Seat folded 20 of 22 hands. Observation?",
                a11y: "Narrow entry.",
                objectives: ["Tag narrow entry"],
                choices: [
                  choice("narrow", "Narrow entry — plays few hands", "recommended",
                    "Participation is very low."),
                  choice("wide", "Wide entry", "clear_mistake",
                    "Opposite.", {betterChoiceId: "narrow"})
                ],
              }),
              selectAct({
                id: "act-04-07-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "That seat finally raises and then barrels. Observation?",
                a11y: "Strong aggression when involved.",
                objectives: ["Tag strong aggression when they play"],
                choices: [
                  choice("strong-aggr", "Strong aggression when they enter", "recommended",
                    "Few hands plus heat suggests strength."),
                  choice("passive", "They are passive callers", "clear_mistake",
                    "Raising and barreling is aggression.", {betterChoiceId: "strong-aggr"})
                ],
              }),
              selectAct({
                id: "act-04-07-01-unguided", order: 4, stage: "unguided",
                prompt: "They folded two hands. Label them already?",
                a11y: "Not enough samples.",
                objectives: ["Wait for samples before labeling"], lifeLoss: true,
                choices: [
                  choice("wait", "No — sample too small", "recommended",
                    "Confidence scales with samples."),
                  choice("now", "Yes — two folds is enough forever", "clear_mistake",
                    "Too thin.", {betterChoiceId: "wait"})
                ],
              }),
              selectAct({
                id: "act-04-07-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Evidence bundle for this seat?",
                a11y: "Narrow entry and strong aggression.",
                objectives: ["Wait for samples before labeling"], lifeLoss: true,
                choices: [
                  choice("bundle-nit", "Few hands; heavy action when involved", "recommended",
                    "That is the pre-label note."),
                  choice("bundle-station", "Calls every street", "clear_mistake",
                    "Different evidence.", {betterChoiceId: "bundle-nit"})
                ],
              }),
            ],
          }),
          lesson({
            id: L040702, order: 2,
            title: "Meet the Nit",
            summary: "Attach the Nit label to narrow-entry evidence.",
            objectives: ["Introduce Nit", "Identify from evidence"],
            prereq: L040701, remediation: L040701, minutes: 7, band: 3,
            playerTypeRefs: ["nit"],
            introducesPlayerTypes: ["nit"],
            activities: [
              dialogue("act-04-07-02-explain", 1,
                "Nit means narrow entry and respect for their heavy action.",
                {objectives: ["Introduce Nit"], playerTypeRefs: ["nit"]}),
              classifyAct({
                id: "act-04-07-02-guided", order: 2, stage: "guided",
                prompt: "Seat plays ~8% of hands and 3-bets rarely but large. Label?",
                a11y: "Nit.",
                objectives: ["Identify from evidence"],
                playerTypeRefs: ["nit"],
                choices: [
                  choice("pt-nit", "Nit", "recommended",
                    "Tiny range with strong aggression.", {reversalRead: "If they open 40% and float light, drop Nit."}),
                  choice("pt-station-n", "Calling Station", "clear_mistake",
                    "Stations call wide; this seat rarely enters.", {betterChoiceId: "pt-nit", reversalRead: "Station evidence is sticky calling."})
                ],
              }),
              classifyAct({
                id: "act-04-07-02-unguided", order: 3, stage: "unguided",
                prompt: "Seat folds forever, then check-raises a triple barrel. Label?",
                a11y: "Nit.",
                objectives: ["Identify from evidence"],
                lifeLoss: true,
                playerTypeRefs: ["nit"],
                choices: [
                  choice("nit2", "Nit", "recommended",
                    "Narrow until proven strong.", {reversalRead: "If they show bluffs often, widen their range."}),
                  choice("maniac-n", "Maniac", "clear_mistake",
                    "Maniacs are always involved.", {betterChoiceId: "nit2"})
                ],
              }),
              selectAct({
                id: "act-04-07-02-checkpoint", order: 4, stage: "checkpoint",
                prompt: "Nit is best treated as?",
                a11y: "Working model.",
                objectives: ["Introduce Nit"],
                lifeLoss: true,
                choices: [
                  choice("model-n", "A working model with sample limits", "recommended",
                    "Update with new evidence."),
                  choice("insult-n", "An insult", "clear_mistake",
                    "Keep it technical.", {betterChoiceId: "model-n"})
                ],
              }),
            ],
          }),
          lesson({
            id: L040703, order: 3,
            title: "Adjust versus Nit",
            summary: "Steal more; respect heavy action from a Nit.",
            objectives: ["Steal more versus Nits", "Respect their heavy action", "Cite narrow-entry tendency"],
            prereq: L040702, remediation: L040702, minutes: 8, band: 3,
            playerTypeRefs: ["nit"],
            activities: [
              dialogue("act-04-07-03-explain", 1,
                "Versus nits: steal blinds more; give credit when they explode.",
                {objectives: ["Steal more versus Nits"], playerTypeRefs: ["nit"]}),
              actionAct({
                id: "act-04-07-03-guided", order: 2, stage: "guided",
                prompt: "Nit in BB. You have K9o on BTN. Action?",
                a11y: "Open wider steal versus nit big blind.",
                objectives: ["Steal more versus Nits"],
                choices: [
                  choice("steal", "Open / steal", "recommended",
                    "They fold too many blinds.", {action: "RAISE", amountBb: 3, reversalRead: "If the nit starts defending wide, tighten steals."}),
                  choice("fold-k9", "Fold", "questionable",
                    "Baseline fold is okay; versus a nit, stealing is better.", {action: "FOLD"})
                ],
              }),
              actionAct({
                id: "act-04-07-03-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Nit check-raises your c-bet. You have middle pair. Action?",
                a11y: "Respect nit aggression — often fold.",
                objectives: ["Respect their heavy action"],
                choices: [
                  choice("fold-mid", "Fold", "recommended",
                    "Their raising range is strong.", {action: "FOLD", reversalRead: "If they show bluff check-raises, widen calls."}),
                  choice("hero-call", "Hero-call forever", "clear_mistake",
                    "Tendency: strong when aggressive.", {action: "CALL", betterChoiceId: "fold-mid"})
                ],
              }),
              actionAct({
                id: "act-04-07-03-unguided", order: 4, stage: "unguided",
                prompt: "Same K9o steal. Unknown BB. Action?",
                a11y: "Without nit evidence, K9o steal is thinner.",
                objectives: ["Cite narrow-entry tendency"],
                lifeLoss: true,
                choices: [
                  choice("tighter", "Tighter baseline", "recommended",
                    "Steal width cites their overfolding.", {action: "FOLD", reversalRead: "With nit evidence, K9o becomes a steal."}),
                  choice("same-always", "Always steal K9o", "questionable",
                    "Read-dependent.", {action: "RAISE", amountBb: 3})
                ],
              }),
              selectAct({
                id: "act-04-07-03-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Why respect a Nit check-raise?",
                a11y: "Because their aggression is value-heavy.",
                objectives: ["Cite narrow-entry tendency"],
                lifeLoss: true,
                playerTypeRefs: ["nit"],
                choices: [
                  choice("cite-strong", "Range is strong when they raise", "recommended",
                    "Cite narrow entry plus aggression.", {reversalRead: "Shown bluffs reduce that respect."}),
                  choice("cite-fear", "Nits are scary people", "clear_mistake",
                    "Cite range, not fear.", {betterChoiceId: "cite-strong"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-04-08-maniac", 8, "Player type: Maniac",
        "Observe extreme aggression, then label and exploit.", [
          lesson({
            id: L040801, order: 1,
            title: "Observe wild aggressors",
            summary: "Tag extreme entry and constant pressure before labeling.",
            objectives: ["Tag extreme entry", "Tag constant aggression", "Avoid ego battles in notes"],
            prereq: L040703, remediation: L040701, minutes: 7, band: 3,
            activities: [
              dialogue("act-04-08-01-explain", 1,
                "Some seats raise and barrel seemingly forever. Count it calmly.",
                {objectives: ["Tag extreme entry"]}),
              selectAct({
                id: "act-04-08-01-guided", order: 2, stage: "guided",
                prompt: "Seat raises or 3-bets twelve of fifteen pots. Observation?",
                a11y: "Extreme entry/aggression.",
                objectives: ["Tag extreme entry"],
                choices: [
                  choice("extreme", "Extreme entry and aggression", "recommended",
                    "Far above baseline."),
                  choice("nit-like", "Narrow and timid", "clear_mistake",
                    "Opposite.", {betterChoiceId: "extreme"})
                ],
              }),
              selectAct({
                id: "act-04-08-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "They bet flop, turn, and river with weak showdowns twice. Note?",
                a11y: "Continues with pressure too wide.",
                objectives: ["Tag constant aggression"],
                choices: [
                  choice("pressure", "Continues pressure too wide", "recommended",
                    "Barrels without the goods."),
                  choice("passive-m", "They never bet", "clear_mistake",
                    "They never stop betting.", {betterChoiceId: "pressure"})
                ],
              }),
              selectAct({
                id: "act-04-08-01-unguided", order: 4, stage: "unguided",
                prompt: "Best note style versus wild aggression?",
                a11y: "Frequencies, not ego.",
                objectives: ["Avoid ego battles in notes"], lifeLoss: true,
                choices: [
                  choice("calm", "Frequencies and shows — no ego story", "recommended",
                    "You will exploit later; do not tilt notes."),
                  choice("ego", "Write revenge plans", "clear_mistake",
                    "Ego battles burn stacks.", {betterChoiceId: "calm"})
                ],
              }),
              selectAct({
                id: "act-04-08-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Evidence bundle?",
                a11y: "Extreme entry and aggression.",
                objectives: ["Avoid ego battles in notes"], lifeLoss: true,
                choices: [
                  choice("bundle-m", "Enters constantly; barrels without mercy", "recommended",
                    "Pre-label evidence."),
                  choice("bundle-n", "Almost never plays", "clear_mistake",
                    "That is nit evidence.", {betterChoiceId: "bundle-m"})
                ],
              }),
            ],
          }),
          lesson({
            id: L040802, order: 2,
            title: "Meet the Maniac",
            summary: "Attach the Maniac label to extreme aggression evidence.",
            objectives: ["Introduce Maniac", "Identify from evidence"],
            prereq: L040801, remediation: L040801, minutes: 7, band: 3,
            playerTypeRefs: ["maniac"],
            introducesPlayerTypes: ["maniac"],
            activities: [
              dialogue("act-04-08-02-explain", 1,
                "Maniac means extreme entry and aggression — a model, not an insult.",
                {objectives: ["Introduce Maniac"], playerTypeRefs: ["maniac"]}),
              classifyAct({
                id: "act-04-08-02-guided", order: 2, stage: "guided",
                prompt: "Seat open-raises 60% and triple-barrels light. Label?",
                a11y: "Maniac.",
                objectives: ["Identify from evidence"],
                playerTypeRefs: ["maniac"],
                choices: [
                  choice("pt-maniac", "Maniac", "recommended",
                    "Extreme entry/aggression.", {reversalRead: "If they tighten for an hour, update the model."}),
                  choice("pt-nit-m", "Nit", "clear_mistake",
                    "Nits do not open 60%.", {betterChoiceId: "pt-maniac"})
                ],
              }),
              classifyAct({
                id: "act-04-08-02-unguided", order: 3, stage: "unguided",
                prompt: "Seat 3-bets light and never gives up rivers. Label?",
                a11y: "Maniac.",
                objectives: ["Identify from evidence"],
                lifeLoss: true,
                playerTypeRefs: ["maniac"],
                choices: [
                  choice("maniac2", "Maniac", "recommended",
                    "Pressure without selection.", {reversalRead: "Shown strong-only hands reduce maniac confidence."}),
                  choice("station-m", "Calling Station", "clear_mistake",
                    "Stations call; maniacs raise.", {betterChoiceId: "maniac2"})
                ],
              }),
              selectAct({
                id: "act-04-08-02-checkpoint", order: 4, stage: "checkpoint",
                prompt: "Which types are legal to mix now?",
                a11y: "Station, Nit, and Maniac — already introduced.",
                objectives: ["Introduce Maniac"],
                lifeLoss: true,
                playerTypeRefs: ["calling_station", "nit", "maniac"],
                choices: [
                  choice("three", "Calling Station, Nit, and Maniac", "recommended",
                    "Only mix types already introduced."),
                  choice("early", "Add an unlabeled loose seat", "clear_mistake",
                    "Only mix Calling Station, Nit, and Maniac.", {betterChoiceId: "three"})
                ],
              }),
            ],
          }),
          lesson({
            id: L040803, order: 3,
            title: "Adjust versus Maniac",
            summary: "Widen bluff-catching and value; avoid ego wars.",
            objectives: ["Widen value and bluff-catch ranges", "Avoid ego battles", "Cite extreme aggression tendency"],
            prereq: L040802, remediation: L040802, minutes: 8, band: 3,
            playerTypeRefs: ["maniac"],
            activities: [
              dialogue("act-04-08-03-explain", 1,
                "Versus maniacs: call wider for value, let them hang themselves, no ego.",
                {objectives: ["Widen value and bluff-catch ranges"], playerTypeRefs: ["maniac"]}),
              actionAct({
                id: "act-04-08-03-guided", order: 2, stage: "guided",
                prompt: "Maniac barrels river. You have top pair weakish kicker. Action?",
                a11y: "Wider bluff-catch versus maniac.",
                objectives: ["Widen value and bluff-catch ranges"],
                choices: [
                  choice("call-wider", "Call", "recommended",
                    "Their bet range is too wide.", {action: "CALL", reversalRead: "If they tighten barrels, tighten catches."}),
                  choice("fold-tp", "Fold top pair always", "questionable",
                    "Versus maniacs, calling is better.", {action: "FOLD"}),
                  choice("punish-jam", "Jam to punish ego-to-ego", "clear_mistake",
                    "Avoid ego battles; calling realizes value.", {action: "RAISE", amountBb: 80, betterChoiceId: "call-wider", reversalRead: "Raise for value when you crush; do not tilt-raise."})
                ],
              }),
              actionAct({
                id: "act-04-08-03-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Maniac checks to you. You have top two. Action?",
                a11y: "Bet value; they call light.",
                objectives: ["Widen value and bluff-catch ranges"],
                choices: [
                  choice("val-m", "Bet value", "recommended",
                    "They continue too often.", {action: "BET", amountBb: 10, reversalRead: "If they start folding, size down or check more."}),
                  choice("trap-always", "Check back always to trap", "questionable",
                    "Trapping is okay; betting gets value now.", {action: "CHECK"})
                ],
              }),
              actionAct({
                id: "act-04-08-03-unguided", order: 4, stage: "unguided",
                prompt: "Same river bet, unknown opponent. Top pair weak kicker?",
                a11y: "Without maniac evidence, more folds.",
                objectives: ["Cite extreme aggression tendency"],
                lifeLoss: true,
                choices: [
                  choice("baseline-fold", "More often fold", "recommended",
                    "Wide catching cites their over-aggression.", {action: "FOLD", reversalRead: "With maniac samples, calling becomes recommended."}),
                  choice("baseline-call", "Always call strangers' jams", "questionable",
                    "Needs the aggression tendency.", {action: "CALL"})
                ],
              }),
              selectAct({
                id: "act-04-08-03-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Why call wider versus a Maniac?",
                a11y: "Because they bet too many hands.",
                objectives: ["Cite extreme aggression tendency"],
                lifeLoss: true,
                playerTypeRefs: ["maniac"],
                choices: [
                  choice("cite-wide", "Their betting range is too wide", "recommended",
                    "Exploit cites over-aggression.", {reversalRead: "Tightening aggression removes the exploit."}),
                  choice("cite-brave", "To prove bravery", "clear_mistake",
                    "No ego.", {betterChoiceId: "cite-wide"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-04-09-type-id", 9, "Type identification",
        "Separate observation from certainty; grow confidence with samples.", [
          lesson({
            id: L040901, order: 1,
            title: "Confidence and samples",
            summary: "Treat labels as models with explicit sample limits.",
            objectives: ["Separate observation from certainty", "Raise confidence only with samples", "Retire labels when evidence flips"],
            prereq: L040803, remediation: L040602, minutes: 7, band: 3,
            playerTypeRefs: ["calling_station", "nit", "maniac"],
            activities: [
              dialogue("act-04-09-01-explain", 1,
                "Observation ≠ certainty. Confidence grows with samples and showdowns.",
                {objectives: ["Separate observation from certainty"]}),
              selectAct({
                id: "act-04-09-01-guided", order: 2, stage: "guided",
                prompt: "You saw one huge bluff. What do you know?",
                a11y: "One observation, low certainty.",
                objectives: ["Separate observation from certainty"],
                choices: [
                  choice("one-note", "One note — low certainty", "recommended",
                    "Log it; do not crown a type yet."),
                  choice("proven", "Type proven forever", "clear_mistake",
                    "Insufficient samples.", {betterChoiceId: "one-note"})
                ],
              }),
              selectAct({
                id: "act-04-09-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "After 30 hands of sticky calls, confidence should?",
                a11y: "Rise but stay revisable.",
                objectives: ["Raise confidence only with samples"],
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("rise", "Rise — still revisable", "recommended",
                    "More samples, higher confidence, still a model."),
                  choice("zero", "Stay at zero forever", "clear_mistake",
                    "Evidence matters.", {betterChoiceId: "rise"})
                ],
              }),
              classifyAct({
                id: "act-04-09-01-unguided", order: 4, stage: "unguided",
                prompt: "Former 'station' starts folding three streets. Next step?",
                a11y: "Retire or update the label.",
                objectives: ["Retire labels when evidence flips"], lifeLoss: true,
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("update", "Update/retire the Calling Station model", "recommended",
                    "Evidence flipped.", {reversalRead: "If sticky calls return, the model can return."}),
                  choice("freeze", "Keep the old label forever", "clear_mistake",
                    "Models must update.", {betterChoiceId: "update"})
                ],
              }),
              selectAct({
                id: "act-04-09-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Course should show what beside a type label?",
                a11y: "Sample/confidence limits.",
                objectives: ["Retire labels when evidence flips"], lifeLoss: true,
                choices: [
                  choice("limits", "Sample and confidence limits", "recommended",
                    "No type from one dramatic hand."),
                  choice("destiny", "Destiny and aura", "clear_mistake",
                    "Stay empirical.", {betterChoiceId: "limits"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-04-10-exploits", 10, "Exploit checkpoints",
        "Same hand, different types — then the section jump.", [
          lesson({
            id: L041001, order: 1,
            title: "Same hand, different types",
            summary: "Change only when the authored read justifies it.",
            objectives: ["Change lines by type with justification", "Combine type × position × stack × board", "Keep baseline when evidence is missing"],
            prereq: L040901, remediation: L040603, minutes: 10, band: 4,
            playerTypeRefs: ["calling_station", "nit", "maniac"],
            activities: [
              dialogue("act-04-10-01-explain", 1,
                "Same cards. Different seats. Exploits change only with evidence.",
                {objectives: ["Change lines by type with justification"]}),
              actionAct({
                id: "act-04-10-01-guided", order: 2, stage: "guided",
                prompt: "River, second pair. Versus Calling Station. Action?",
                a11y: "Thin value versus station.",
                objectives: ["Change lines by type with justification"],
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("st-val", "Bet value", "recommended",
                    "Sticky calls justify thin value.", {action: "BET", amountBb: 8, reversalRead: "Without sticky evidence, prefer check."}),
                  choice("st-bluff", "Huge bluff", "clear_mistake",
                    "They do not fold.", {action: "BET", amountBb: 30, betterChoiceId: "st-val"})
                ],
              }),
              actionAct({
                id: "act-04-10-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Same second pair river. Versus Nit who just check-raised. Action?",
                a11y: "Fold versus nit heat.",
                objectives: ["Change lines by type with justification"],
                playerTypeRefs: ["nit"],
                choices: [
                  choice("nit-fold", "Fold", "recommended",
                    "Nit aggression is strong.", {action: "FOLD", reversalRead: "Versus a maniac barrel, calling is wider."}),
                  choice("nit-call", "Call", "clear_mistake",
                    "Different type, different line.", {action: "CALL", betterChoiceId: "nit-fold"})
                ],
              }),
              actionAct({
                id: "act-04-10-01-unguided", order: 4, stage: "unguided",
                prompt: "Same second pair. Maniac barrels river. Action?",
                a11y: "Call wider versus maniac.",
                objectives: ["Change lines by type with justification"],
                lifeLoss: true,
                playerTypeRefs: ["maniac"],
                choices: [
                  choice("m-call", "Call", "recommended",
                    "Over-aggression justifies the catch.", {action: "CALL", reversalRead: "Versus a nit barrel, folding is recommended."}),
                  choice("m-fold", "Fold", "questionable",
                    "Sometimes; maniac tendency supports calling.", {action: "FOLD"}),
                  choice("m-ego", "Raise for ego", "clear_mistake",
                    "No ego battles.", {action: "RAISE", amountBb: 60, betterChoiceId: "m-call"})
                ],
              }),
              handLabAct({
                id: "act-04-10-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Full ring. Type × position × stack decide the line.",
                a11y: "Button vs nit BB steal; deep stack.",
                objectives: ["Combine type × position × stack × board"],
                lifeLoss: true,
                playerTypeRefs: ["nit"],
                choices: [
                  choice("lab-steal", "Open to 6", "recommended",
                    "Deep BTN vs nit BB — steal wider.", {action: "RAISE", amountBb: 3, reversalRead: "Unknown BB: tighter open."}),
                  choice("lab-fold", "Fold KTo", "questionable",
                    "Fine without the nit read; with it, open.", {action: "FOLD"}),
                  choice("lab-limp", "Limp", "clear_mistake",
                    "Raise or fold.", {action: "CALL", betterChoiceId: "lab-steal"})
                ],
                lab: {
                  id: "lab-04-10-01-btn-vs-nit",
                  title: "Button steal versus nit big blind",
                  tableSize: 9,
                  heroSeat: 7,
                  smallBlind: 1,
                  bigBlind: 2,
                  startingStackBb: 200,
                  heroCards: ["Kh", "Td"],
                  board: [],
                  scriptedActions: [
                    {seat: 2, street: "preflop", action: "FOLD"},
                    {seat: 3, street: "preflop", action: "FOLD"},
                    {seat: 4, street: "preflop", action: "FOLD"},
                    {seat: 5, street: "preflop", action: "FOLD"},
                    {seat: 6, street: "preflop", action: "FOLD"},
                  ],
                  decisionPoints: [{
                    id: "dp-btn-steal-nit",
                    street: "preflop",
                    prompt: "Folds to you on the button. Nit in the BB. KTo. Action?",
                    choices: [
                  choice("lab-steal", "Open to 6", "recommended",
                    "Deep BTN vs nit BB — steal wider.", {action: "RAISE", amountBb: 3, reversalRead: "Unknown BB: tighter open."}),
                  choice("lab-fold", "Fold KTo", "questionable",
                    "Fine without the nit read; with it, open.", {action: "FOLD"}),
                  choice("lab-limp", "Limp", "clear_mistake",
                    "Raise or fold.", {action: "CALL", betterChoiceId: "lab-steal"})
                    ],
                  }],
                },
              }),
            ],
          }),
          lesson({
            id: L041002, order: 2,
            title: "Section 4 jump check",
            summary: "Placement check: ranges, plans, sizing, SPR, and player types.",
            objectives: ["Confirm ranges and 3-bet basics", "Confirm sizing and SPR", "Confirm Calling Station, Nit, and Maniac adjustments"],
            prereq: L041001, remediation: L040101, minutes: 12, band: 4,
            playerTypeRefs: ["calling_station", "nit", "maniac"],
            activities: [
              selectAct({
                id: "act-04-10-02-jump-range", order: 1, stage: "jump_test",
                prompt: "UTG open is best described as?",
                a11y: "Jump: stronger narrower range.",
                objectives: ["Confirm ranges and 3-bet basics"],
                lifeLoss: true,
                choices: [
                  choice("j4-range", "Stronger, narrower range", "recommended",
                    "Position tightens opens."),
                  choice("j4-any", "Any two", "clear_mistake",
                    "Too wide.", {betterChoiceId: "j4-range"})
                ],
              }),
              actionAct({
                id: "act-04-10-02-jump-3bet", order: 2, stage: "jump_test",
                prompt: "CO opens 6. You have KK on BTN. Action?",
                a11y: "Jump: value 3-bet.",
                objectives: ["Confirm ranges and 3-bet basics"],
                lifeLoss: true,
                choices: [
                  choice("j4-3bet", "3-bet to 18", "recommended",
                    "Value.", {action: "RAISE", amountBb: 9}),
                  choice("j4-3bet20", "3-bet to 20", "strong",
                    "Also fine.", {action: "RAISE", amountBb: 10}),
                  choice("j4-foldkk", "Fold", "clear_mistake",
                    "Never.", {action: "FOLD", betterChoiceId: "j4-3bet"})
                ],
              }),
              numericAct({
                id: "act-04-10-02-jump-spr", order: 3, stage: "jump_test",
                question: "Stack 60bb, pot 15bb. SPR?",
                a11y: "Jump: SPR 4.",
                objectives: ["Confirm sizing and SPR"],
                lifeLoss: true,
                unit: "ratio", min: 4, max: 4,
                okFeedback: "60/15 = 4.",
                missFeedback: "Divide stack by pot.",
              }),
              actionAct({
                id: "act-04-10-02-jump-size", order: 4, stage: "jump_test",
                prompt: "Value bet into pot 20 with top pair. Best sizes?",
                a11y: "Jump: soft-grade value sizes.",
                objectives: ["Confirm sizing and SPR"],
                lifeLoss: true,
                choices: [
                  choice("j4-10", "Bet 10", "recommended",
                    "Half pot.", {action: "BET", amountBb: 5}),
                  choice("j4-12", "Bet 12", "strong",
                    "Fine.", {action: "BET", amountBb: 6}),
                  choice("j4-1", "Bet 1", "clear_mistake",
                    "Not value language.", {action: "BET", amountBb: 0.5, betterChoiceId: "j4-10"})
                ],
              }),
              classifyAct({
                id: "act-04-10-02-jump-station", order: 5, stage: "jump_test",
                prompt: "Sticky caller three streets. Label + exploit direction?",
                a11y: "Jump: Calling Station — value more, bluff less.",
                objectives: ["Confirm Calling Station, Nit, and Maniac adjustments"],
                lifeLoss: true,
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("j4-cs", "Calling Station — thicker value, fewer bluffs", "recommended",
                    "Cite low folding.", {reversalRead: "If they fold more, re-open bluffs."}),
                  choice("j4-cs-wrong", "Calling Station — bluff more", "clear_mistake",
                    "Opposite exploit.", {betterChoiceId: "j4-cs"})
                ],
              }),
              classifyAct({
                id: "act-04-10-02-jump-nit", order: 6, stage: "jump_test",
                prompt: "Tiny range, huge check-raise. Label + line?",
                a11y: "Jump: Nit — respect heat.",
                objectives: ["Confirm Calling Station, Nit, and Maniac adjustments"],
                lifeLoss: true,
                playerTypeRefs: ["nit"],
                choices: [
                  choice("j4-nit", "Nit — respect the raise; steal more elsewhere", "recommended",
                    "Narrow entry + strong aggression.", {reversalRead: "Shown light check-raises reduce respect."}),
                  choice("j4-nit-bluff", "Nit — bluff-catch light always", "clear_mistake",
                    "Wrong direction versus nit heat.", {betterChoiceId: "j4-nit"})
                ],
              }),
              classifyAct({
                id: "act-04-10-02-jump-maniac", order: 7, stage: "jump_test",
                prompt: "Seat barrels forever. You have top pair. Label + line?",
                a11y: "Jump: Maniac — call wider.",
                objectives: ["Confirm Calling Station, Nit, and Maniac adjustments"],
                lifeLoss: true,
                playerTypeRefs: ["maniac"],
                choices: [
                  choice("j4-man", "Maniac — widen bluff-catch; avoid ego raises", "recommended",
                    "Over-aggression cited.", {reversalRead: "If barrels tighten, tighten calls."}),
                  choice("j4-man-fold", "Maniac — fold all one-pair forever", "clear_mistake",
                    "You should call wider.", {betterChoiceId: "j4-man"})
                ],
              }),
            ],
          }),
        ]),
    ],
  };
}

export const SECTION_FOUR_EXIT_LESSON =
  "lesson-04-10-02-section-four-jump-test";
