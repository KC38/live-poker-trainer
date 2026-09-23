/**
 * Plan 09 — Sections 5–7 authored curriculum helpers.
 * Consumed by build_seed_course.mjs; not run standalone.
 */

import {SECTION_FOUR_EXIT_LESSON} from "./wave_two_live_competence.mjs";
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

export const MEET_TAG = "lesson-06-11-02-meet-tag";
export const MEET_LAG = "lesson-06-12-02-meet-lag";

/** @returns {object} Section 5 — Winning 1/2 */
export function buildSectionFive() {
  const prev = SECTION_FOUR_EXIT_LESSON;
  const L050101 = "lesson-05-01-01-multiway-ranges";
  const L050201 = "lesson-05-02-01-deep-stack-play";
  const L050301 = "lesson-05-03-01-implied-odds";
  const L050401 = "lesson-05-04-01-thin-value-bluffcatch";
  const L050501 = "lesson-05-05-01-lines-and-probes";
  const L050601 = "lesson-05-06-01-line-reading";
  const L050701 = "lesson-05-07-01-timing-sizing-evidence";
  const L050801 = "lesson-05-08-01-table-dynamics";
  const L050901 = "lesson-05-09-01-session-discipline";
  const L050902 = "lesson-05-09-02-section-five-checkpoint";

  return {
    id: "sec-05-winning-12",
    order: 5,
    title: "Winning 1/2",
    summary: "Win larger value pots and avoid expensive marginal mistakes.",
    experienceBand: "winning_12",
    units: [
      unit("unit-05-01-multiway-ranges", 1, "Multiway range construction",
        "Nut potential and tighter multiway construction.", [
          lesson({
            id: L050101, order: 1,
            title: "Build multiway ranges with nut potential",
            summary: "Prefer nutted hands and clean draws when many players see the flop.",
            objectives: ["Prefer nut potential multiway", "Tighten speculative hands multiway", "Value thicker when capped opponents call"],
            prereq: prev, remediation: prev, minutes: 9, band: 4,
            playerTypeRefs: ["calling_station"],
            activities: [
              dialogue("act-05-01-01-explain", 1,
                "Multiway: nutted hands up, air down. Domination hurts more.",
                {objectives: ["Prefer nut potential multiway"]}),
              selectAct({
                id: "act-05-01-01-guided", order: 2, stage: "guided",
                prompt: "Four-way flop. Best continue with?",
                a11y: "Nut flush draw beats weak pair-draw mixes.",
                objectives: ["Prefer nut potential multiway"],
                choices: [
                  choice("nfd", "Nut flush draw", "recommended",
                    "Nutted equity realizes better multiway."),
                  choice("weak-fd", "Low flush draw with no overs", "questionable",
                    "Playable sometimes, but dominated often."),
                  choice("air", "Complete air for a stab", "clear_mistake",
                    "Bluffing crowds is expensive.", {betterChoiceId: "nfd"})
                ],
              }),
              actionAct({
                id: "act-05-01-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "BTN open, BB + MP call. You have 76s in SB. Action?",
                a11y: "Fold speculative suited connectors multiway OOP.",
                objectives: ["Tighten speculative hands multiway"],
                choices: [
                  choice("fold-76", "Fold", "recommended",
                    "OOP multiway with medium connectors is −EV often.", {action: "FOLD"}),
                  choice("call-76", "Call", "questionable",
                    "Needs deep stacks and great implied odds."),
                  choice("shove-76", "Jam 100bb", "clear_mistake",
                    "Not a shove.", {action: "RAISE", amountBb: 100, betterChoiceId: "fold-76"})
                ],
              }),
              actionAct({
                id: "act-05-01-01-unguided", order: 4, stage: "unguided",
                prompt: "Three callers. You flop top set on a wet board. Action?",
                a11y: "Bet for value; protect and build.",
                objectives: ["Value thicker when capped opponents call"],
                lifeLoss: true,
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("bet-set", "Bet solid value", "recommended",
                    "Multiway sets want thick value and protection.", {action: "BET", amountBb: 12, reversalRead: "Heads-up vs a nit, smaller or slower is fine."}),
                  choice("check-set", "Check always", "questionable",
                    "Slow plays die to free cards multiway."),
                  choice("tiny", "Bet 1bb", "clear_mistake",
                    "Not value language.", {action: "BET", amountBb: 1, betterChoiceId: "bet-set"})
                ],
              }),
              selectAct({
                id: "act-05-01-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Multiway construction priority?",
                a11y: "Nut potential and domination avoidance.",
                objectives: ["Prefer nut potential multiway"], lifeLoss: true,
                choices: [
                  choice("nuts", "Nut potential and clean equity", "recommended",
                    "Avoid second-best traps."),
                  choice("any-two", "Any two for initiative", "clear_mistake",
                    "Crowds punish air.", {betterChoiceId: "nuts"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-05-02-deep-stacks", 2, "Deep-stack play",
        "150–300bb decisions and implied-odds geometry.", [
          lesson({
            id: L050201, order: 1,
            title: "Play 150–300bb stacks with a plan",
            summary: "Deep stacks reward implied odds, position, and disciplined folds.",
            objectives: ["Use depth for speculative implied odds", "Avoid stacking off light deep", "Plan future streets when SPR is high"],
            prereq: L050101, remediation: L050101, minutes: 9, band: 4,
            activities: [
              dialogue("act-05-02-01-explain", 1,
                "Deep: more room to realize. Also more room to lose a stack.",
                {objectives: ["Use depth for speculative implied odds"]}),
              selectAct({
                id: "act-05-02-01-guided", order: 2, stage: "guided",
                prompt: "200bb effective. Best reason to call a raise with 55 BTN?",
                a11y: "Implied odds versus stacks that pay sets.",
                objectives: ["Use depth for speculative implied odds"],
                choices: [
                  choice("impl", "Implied odds if they pay sets", "recommended",
                    "Depth makes set-mining viable."),
                  choice("spr-low", "SPR is already low", "clear_mistake",
                    "200bb is high SPR.", {betterChoiceId: "impl"}),
                  choice("bluff", "You will bluff every flop", "clear_mistake",
                    "Not the thesis.", {betterChoiceId: "impl"})
                ],
              }),
              actionAct({
                id: "act-05-02-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "250bb. Top pair weak kicker faces a huge check-raise on a wet flop. Action?",
                a11y: "Deep stacks: fold light top pair to heavy heat.",
                objectives: ["Avoid stacking off light deep"],
                choices: [
                  choice("fold-tp", "Fold", "recommended",
                    "Deep money + wet board + huge raise ≠ light stack-off.", {action: "FOLD", reversalRead: "Shallow SPR or maniac history can widen calls."}),
                  choice("call-tp", "Call huge", "questionable",
                    "Needs a stronger read."),
                  choice("jam-tp", "Jam for value", "clear_mistake",
                    "Too thin deep.", {action: "RAISE", amountBb: 200, betterChoiceId: "fold-tp"})
                ],
              }),
              selectAct({
                id: "act-05-02-01-unguided", order: 4, stage: "unguided",
                prompt: "SPR ~12 on the flop. Your first job?",
                a11y: "Plan turn and river before stacking.",
                objectives: ["Plan future streets when SPR is high"], lifeLoss: true,
                choices: [
                  choice("plan", "Map turn/river plans before committing", "recommended",
                    "High SPR is a multi-street problem."),
                  choice("jamnow", "Jam any pair now", "clear_mistake",
                    "Too early.", {betterChoiceId: "plan"})
                ],
              }),
              selectAct({
                id: "act-05-02-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "150–300bb cash play rewards?",
                a11y: "Position, implied odds, disciplined folds.",
                objectives: ["Plan future streets when SPR is high"], lifeLoss: true,
                choices: [
                  choice("pos", "Position, implied odds, and disciplined folds", "recommended",
                    "Depth amplifies skill edges."),
                  choice("spew", "Automatic light stacks", "clear_mistake",
                    "Opposite.", {betterChoiceId: "pos"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-05-03-implied-odds", 3, "Implied and reverse implied odds",
        "When depth pays you — and when it taxes you.", [
          lesson({
            id: L050301, order: 1,
            title: "Price draws with implied and reverse implied odds",
            summary: "Estimate future payoffs and domination risk, not only pot odds.",
            objectives: ["Estimate implied odds from depth and tendencies", "Spot reverse implied odds traps", "Skip dominated draws multiway"],
            prereq: L050201, remediation: L050201, minutes: 9, band: 4,
            playerTypeRefs: ["calling_station", "nit"],
            activities: [
              dialogue("act-05-03-01-explain", 1,
                "Implied odds: future money. Reverse implied: future losses when second-best.",
                {objectives: ["Estimate implied odds from depth and tendencies"]}),
              actionAct({
                id: "act-05-03-01-guided", order: 2, stage: "guided",
                prompt: "Deep vs Calling Station. Gutshot with overs facing a small bet. Action?",
                a11y: "Station pays — implied odds improve. Call.",
                objectives: ["Estimate implied odds from depth and tendencies"],
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("call-io", "Call", "recommended",
                    "Sticky callers raise implied odds.",
                    {action: "CALL", reversalRead: "Versus a nit, implied odds shrink."}),
                  choice("fold-io", "Fold", "clear_mistake",
                    "Ignore tendency and depth.", {action: "FOLD", betterChoiceId: "call-io"})
                ],
              }),
              actionAct({
                id: "act-05-03-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "KJo on A-high wet board. Nit check-raises large. Action?",
                a11y: "Reverse implied odds — fold dominated broadway.",
                objectives: ["Spot reverse implied odds traps"],
                playerTypeRefs: ["nit"],
                choices: [
                  choice("rio", "Fold", "recommended",
                    "Nit heat + broadway underpairs to ace — reverse implied.",
                    {action: "FOLD"}),
                  choice("free", "Call", "clear_mistake",
                    "Wrong direction — often second-best.",
                    {action: "CALL", betterChoiceId: "rio"})
                ],
              }),
              actionAct({
                id: "act-05-03-01-unguided", order: 4, stage: "unguided",
                prompt: "Four-way. 7h6h on Kh 9h 2c facing a bet. Action?",
                a11y: "Non-nut flush draw — fold the domination leak.",
                objectives: ["Skip dominated draws multiway"], lifeLoss: true,
                choices: [
                  choice("nonut", "Fold", "recommended",
                    "Dominated flush draws leak multiway.", {action: "FOLD"}),
                  choice("auto", "Call", "clear_mistake",
                    "Ignore domination.", {action: "CALL", betterChoiceId: "nonut"})
                ],
              }),
              selectAct({
                id: "act-05-03-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Implied odds rise most when?",
                a11y: "Depth plus paying tendencies.",
                objectives: ["Estimate implied odds from depth and tendencies"], lifeLoss: true,
                choices: [
                  choice("depth-pay", "Deep stacks and opponents who pay", "recommended",
                    "Both matter."),
                  choice("short", "Short stacks always", "clear_mistake",
                    "Short stacks cut implied odds.", {betterChoiceId: "depth-pay"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-05-04-thin-value", 4, "Thin value and bluff-catching",
        "Extract thin value; catch when aggression is wide.", [
          lesson({
            id: L050401, order: 1,
            title: "Bet thin for value; catch wide aggression",
            summary: "Widen value versus sticky callers; widen catches versus maniacs.",
            objectives: ["Choose thin value versus sticky callers", "Widen bluff-catches versus over-aggression", "Skip thin value versus overfolders"],
            prereq: L050301, remediation: L050301, minutes: 9, band: 4,
            playerTypeRefs: ["calling_station", "maniac", "nit"],
            activities: [
              dialogue("act-05-04-01-explain", 1,
                "Thin value needs calls. Bluff-catches need wide barrels.",
                {objectives: ["Choose thin value versus sticky callers"]}),
              actionAct({
                id: "act-05-04-01-guided", order: 2, stage: "guided",
                prompt: "River second pair. Calling Station checked twice. Action?",
                a11y: "Thin value bet.",
                objectives: ["Choose thin value versus sticky callers"],
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("tv", "Bet thin value", "recommended",
                    "They call worse.", {action: "BET", amountBb: 7, reversalRead: "Versus a nit check, prefer check-back."}),
                  choice("check", "Check always", "questionable",
                    "Misses value versus stations."),
                  choice("overbet", "Overbet bluff", "clear_mistake",
                    "They do not fold.", {action: "BET", amountBb: 40, betterChoiceId: "tv"})
                ],
              }),
              actionAct({
                id: "act-05-04-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Maniac barrels river. You have second pair. Action?",
                a11y: "Call wider.",
                objectives: ["Widen bluff-catches versus over-aggression"],
                playerTypeRefs: ["maniac"],
                choices: [
                  choice("call-m", "Call", "recommended",
                    "Wide barrels justify the catch.", {action: "CALL", reversalRead: "Nit barrel: fold more."}),
                  choice("fold-m", "Fold", "questionable",
                    "Too tight versus maniac."),
                  choice("raise-m", "Hero-raise for ego", "clear_mistake",
                    "No ego.", {action: "RAISE", amountBb: 50, betterChoiceId: "call-m"})
                ],
              }),
              actionAct({
                id: "act-05-04-01-unguided", order: 4, stage: "unguided",
                prompt: "Same second pair river. Nit checked to you. Action?",
                a11y: "Check back — thin value dies.",
                objectives: ["Skip thin value versus overfolders"],
                lifeLoss: true,
                playerTypeRefs: ["nit"],
                choices: [
                  choice("check-nit", "Check back", "recommended",
                    "Nits fold worse; thin value fails.", {action: "CHECK", reversalRead: "Station: bet thin."}),
                  choice("bet-nit", "Bet thin", "questionable",
                    "They fold too much."),
                  choice("jam-nit", "Overbet", "clear_mistake",
                    "No.", {action: "BET", amountBb: 60, betterChoiceId: "check-nit"})
                ],
              }),
              selectAct({
                id: "act-05-04-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Same hand, different types — what must change?",
                a11y: "The recommendation only when the read justifies it.",
                objectives: ["Choose thin value versus sticky callers"], lifeLoss: true,
                choices: [
                  choice("read", "The line — only when the authored read justifies it", "recommended",
                    "Baseline first; exploit second."),
                  choice("random", "Flip a coin every time", "clear_mistake",
                    "Not strategy.", {betterChoiceId: "read"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-05-05-lines-probes", 5, "Check-raises, probes, delayed c-bets, donks",
        "Interpret and choose advanced flop/turn lines.", [
          lesson({
            id: L050501, order: 1,
            title: "Read and choose advanced flop lines",
            summary: "Interpret check-raises, probes, delayed c-bets, and donk bets in live cash.",
            objectives: ["Interpret check-raises by strength and type", "Use probes and delayed c-bets with a plan", "Treat donks as polarized information"],
            prereq: L050401, remediation: L050401, minutes: 9, band: 4,
            activities: [
              dialogue("act-05-05-01-explain", 1,
                "Lines mean ranges. Check-raise, probe, delay, donk — each updates the story.",
                {objectives: ["Interpret check-raises by strength and type"]}),
              selectAct({
                id: "act-05-05-01-guided", order: 2, stage: "guided",
                prompt: "Nit check-raises flop. Default read?",
                a11y: "Strong value-heavy.",
                objectives: ["Interpret check-raises by strength and type"],
                playerTypeRefs: ["nit"],
                choices: [
                  choice("strong", "Value-heavy — respect", "recommended",
                    "Nit check-raises are rarely air.", {reversalRead: "Maniac check-raises are wider."}),
                  choice("air", "Always a bluff", "clear_mistake",
                    "Wrong type.", {betterChoiceId: "strong"})
                ],
              }),
              selectAct({
                id: "act-05-05-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Preflop raiser checks flop. You are BB with middle pair. Probe?",
                a11y: "Small probe can be reasonable.",
                objectives: ["Use probes and delayed c-bets with a plan"],
                choices: [
                  choice("probe", "Small probe bet with a turn plan", "recommended",
                    "Test capped ranges; prepare to give up."),
                  choice("huge", "Pot-size probe every time", "questionable",
                    "Too large without equity."),
                  choice("never", "Never bet when they check", "clear_mistake",
                    "Misses value and folds.", {betterChoiceId: "probe"})
                ],
              }),
              selectAct({
                id: "act-05-05-01-unguided", order: 4, stage: "unguided",
                prompt: "BB donks large on A-high dry flop into PFR. Meaning?",
                a11y: "Often polarized — ace or air.",
                objectives: ["Treat donks as polarized information"], lifeLoss: true,
                choices: [
                  choice("polar", "Often polarized — strong or bluff", "recommended",
                    "Live donks skew polar on dry ace boards."),
                  choice("merged", "Always medium pairs", "clear_mistake",
                    "Less common for large donks.", {betterChoiceId: "polar"})
                ],
              }),
              selectAct({
                id: "act-05-05-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Delayed c-bet is best when?",
                a11y: "Flop check then turn barrel after they show weakness.",
                objectives: ["Use probes and delayed c-bets with a plan"], lifeLoss: true,
                choices: [
                  choice("delay", "After flop check takes away their range strength", "recommended",
                    "Turn barrels punish capped continues."),
                  choice("always", "Every hand regardless", "clear_mistake",
                    "Need a reason.", {betterChoiceId: "delay"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-05-06-line-reading", 6, "Line reading across streets",
        "Update ranges street by street.", [
          lesson({
            id: L050601, order: 1,
            title: "Update the story street by street",
            summary: "Rebuild villain's range after each action; do not freeze on flop reads.",
            objectives: ["Update ranges after each street", "Notice capped versus uncapped lines", "Abandon stale flop stories"],
            prereq: L050501, remediation: L050501, minutes: 8, band: 4,
            activities: [
              dialogue("act-05-06-01-explain", 1,
                "Each action rewrites the range. Keep updating.",
                {objectives: ["Update ranges after each street"]}),
              selectAct({
                id: "act-05-06-01-guided", order: 2, stage: "guided",
                prompt: "Villain bets flop, checks turn. Range now?",
                a11y: "Often capped / weakened.",
                objectives: ["Notice capped versus uncapped lines"],
                choices: [
                  choice("capped", "More capped — fewer nuts", "recommended",
                    "Check-back turn removes many strong hands."),
                  choice("nutted", "Still full of nuts", "clear_mistake",
                    "Nuts usually keep betting.", {betterChoiceId: "capped"})
                ],
              }),
              selectAct({
                id: "act-05-06-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "You called flop as a draw. Turn bricks and villain bombs. Update?",
                a11y: "Re-price; folding draws is allowed.",
                objectives: ["Abandon stale flop stories"],
                choices: [
                  choice("repr", "Re-price equity versus the new sizing", "recommended",
                    "Flop call does not obligate turn call."),
                  choice("auto", "Always call because flop was correct", "clear_mistake",
                    "Sunk cost.", {betterChoiceId: "repr"})
                ],
              }),
              selectAct({
                id: "act-05-06-01-unguided", order: 4, stage: "unguided",
                prompt: "Best line-reading habit?",
                a11y: "Street-by-street updates.",
                objectives: ["Update ranges after each street"], lifeLoss: true,
                choices: [
                  choice("update", "Rebuild the range after every action", "recommended",
                    "Stories go stale fast."),
                  choice("freeze", "Lock the flop read forever", "clear_mistake",
                    "Misses turn/river info.", {betterChoiceId: "update"})
                ],
              }),
              selectAct({
                id: "act-05-06-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Check-raise flop, bet turn, shove river usually means?",
                a11y: "Strong uncapped pressure — respect without a read.",
                objectives: ["Notice capped versus uncapped lines"], lifeLoss: true,
                choices: [
                  choice("uncap", "Uncapped pressure — strong unless type says otherwise", "recommended",
                    "Baseline respect; exploit only with evidence."),
                  choice("bluff", "Always pure bluff", "clear_mistake",
                    "Too absolute.", {betterChoiceId: "uncap"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-05-07-timing-sizing", 7, "Live timing and sizing evidence",
        "Use timing/sizing as soft evidence — never magic tells.", [
          lesson({
            id: L050701, order: 1,
            title: "Treat timing and sizing as soft evidence",
            summary: "Live timing and sizing update confidence slightly; they never prove a hand.",
            objectives: ["Treat timing as soft evidence only", "Read sizing as range language", "Reject magic-tell claims"],
            prereq: L050601, remediation: L050601, minutes: 8, band: 4,
            activities: [
              dialogue("act-05-07-01-explain", 1,
                "Timing and sizing are clues, not mind-reading. Small updates only.",
                {objectives: ["Treat timing as soft evidence only"]}),
              selectAct({
                id: "act-05-07-01-guided", order: 2, stage: "guided",
                prompt: "Instant river shove after you bet. Correct framing?",
                a11y: "Soft evidence — not proof.",
                objectives: ["Treat timing as soft evidence only"],
                choices: [
                  choice("soft", "Soft evidence — bump confidence slightly either way", "recommended",
                    "Never a magic tell."),
                  choice("nuts", "Proven nuts forever", "clear_mistake",
                    "Overclaim.", {betterChoiceId: "soft"}),
                  choice("air", "Proven bluff forever", "clear_mistake",
                    "Also overclaim.", {betterChoiceId: "soft"})
                ],
              }),
              selectAct({
                id: "act-05-07-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Tiny flop bet into a huge pot often says?",
                a11y: "Weak or blocking — not solver gospel.",
                objectives: ["Read sizing as range language"],
                choices: [
                  choice("weakish", "Often weaker / blocking — still not proof", "recommended",
                    "Sizing is language with error bars."),
                  choice("solver", "Exact solver frequency known", "clear_mistake",
                    "No fabricated EV claims.", {betterChoiceId: "weakish"})
                ],
              }),
              selectAct({
                id: "act-05-07-01-unguided", order: 4, stage: "unguided",
                prompt: "Coach says \"look left means bluff.\" Response?",
                a11y: "Reject magic tells.",
                objectives: ["Reject magic-tell claims"], lifeLoss: true,
                choices: [
                  choice("reject", "Reject — no magic tells in this course", "recommended",
                    "Stay with frequencies and lines."),
                  choice("trust", "Trust the tell book", "clear_mistake",
                    "Out of scope.", {betterChoiceId: "reject"})
                ],
              }),
              selectAct({
                id: "act-05-07-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Best use of live timing?",
                a11y: "Tiny confidence update alongside stronger evidence.",
                objectives: ["Treat timing as soft evidence only"], lifeLoss: true,
                choices: [
                  choice("tiny", "Tiny update beside line/sizing/type evidence", "recommended",
                    "Hierarchy of evidence."),
                  choice("only", "Only evidence you need", "clear_mistake",
                    "Too weak alone.", {betterChoiceId: "tiny"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-05-08-table-dynamics", 8, "Table dynamics",
        "Tilt, stuck, tired, and gear changes.", [
          lesson({
            id: L050801, order: 1,
            title: "Adjust to live table dynamics",
            summary: "Spot tilted, stuck, tired, or gear-shifting opponents and update plans.",
            objectives: ["Identify tilted or stuck opponents", "Recognize gear changes mid-session", "Avoid chasing emotional pots"],
            prereq: L050701, remediation: L050701, minutes: 8, band: 4,
            activities: [
              dialogue("act-05-08-01-explain", 1,
                "Tables change. Stuck, tilted, tired, or shifting gears — update.",
                {objectives: ["Identify tilted or stuck opponents"]}),
              selectAct({
                id: "act-05-08-01-guided", order: 2, stage: "guided",
                prompt: "Villain lost two buy-ins, now open-raises every hand. Note?",
                a11y: "Stuck/tilted — widen value, choose spots.",
                objectives: ["Identify tilted or stuck opponents"],
                choices: [
                  choice("stuck", "Stuck/tilted — widen value carefully", "recommended",
                    "Do not ego-war; pick +EV spots."),
                  choice("ignore", "Ignore dynamics entirely", "clear_mistake",
                    "Dynamics are evidence.", {betterChoiceId: "stuck"})
                ],
              }),
              selectAct({
                id: "act-05-08-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Solid selective player suddenly flats junk and donks rivers. Best read?",
                a11y: "Possible gear change — sample again.",
                objectives: ["Recognize gear changes mid-session"],
                choices: [
                  choice("gear", "Possible gear change — gather new samples", "recommended",
                    "Do not cling to the old model."),
                  choice("same", "Old label forever", "clear_mistake",
                    "Evidence flipped.", {betterChoiceId: "gear"})
                ],
              }),
              selectAct({
                id: "act-05-08-01-unguided", order: 4, stage: "unguided",
                prompt: "You are steaming after a cooler. Best action?",
                a11y: "Reset or step away — bankroll guardrail.",
                objectives: ["Avoid chasing emotional pots"], lifeLoss: true,
                choices: [
                  choice("reset", "Reset or step away before next hand", "recommended",
                    "Session discipline beats revenge poker."),
                  choice("revenge", "Force a bluff to get even", "clear_mistake",
                    "Emotional leak.", {betterChoiceId: "reset"})
                ],
              }),
              selectAct({
                id: "act-05-08-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Dynamic reads should be?",
                a11y: "Temporary working models with samples.",
                objectives: ["Recognize gear changes mid-session"], lifeLoss: true,
                choices: [
                  choice("temp", "Temporary models with fresh samples", "recommended",
                    "Update as the table shifts."),
                  choice("perm", "Permanent seat identities", "clear_mistake",
                    "Too rigid.", {betterChoiceId: "temp"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-05-09-discipline", 9, "Session discipline and bankroll",
        "Cash guardrails and section checkpoint.", [
          lesson({
            id: L050901, order: 1,
            title: "Keep cash session guardrails",
            summary: "Set stop-loss, win-goal awareness, and bankroll rules for 1/2.",
            objectives: ["Set session stop-losses", "Respect bankroll for stakes", "End sessions before leaks spiral"],
            prereq: L050801, remediation: L050801, minutes: 8, band: 4,
            activities: [
              dialogue("act-05-09-01-explain", 1,
                "Winning 1/2 includes knowing when to quit. Guardrails first.",
                {objectives: ["Set session stop-losses"]}),
              selectAct({
                id: "act-05-09-01-guided", order: 2, stage: "guided",
                prompt: "You hit a planned stop-loss. Next step?",
                a11y: "Leave or move down — do not reload emotionally.",
                objectives: ["Set session stop-losses"],
                choices: [
                  choice("stop", "Stop or move down per plan", "recommended",
                    "Plans beat feelings."),
                  choice("reload", "Reload and chase", "clear_mistake",
                    "Bankroll leak.", {betterChoiceId: "stop"})
                ],
              }),
              selectAct({
                id: "act-05-09-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Bankroll 40 buy-ins for 1/2. Spot opens at 2/5. Action?",
                a11y: "Decline if outside bankroll plan.",
                objectives: ["Respect bankroll for stakes"],
                choices: [
                  choice("decline", "Decline — outside the plan", "recommended",
                    "Stakes follow bankroll."),
                  choice("jump", "Jump up on vibe", "clear_mistake",
                    "Risk of ruin.", {betterChoiceId: "decline"})
                ],
              }),
              selectAct({
                id: "act-05-09-01-unguided", order: 4, stage: "unguided",
                prompt: "Tired, winning small, table getting wild. Best?",
                a11y: "Cash out while ahead of fatigue.",
                objectives: ["End sessions before leaks spiral"], lifeLoss: true,
                choices: [
                  choice("cash", "Cash out — fatigue is a leak", "recommended",
                    "Protect the win."),
                  choice("punish", "Stay to punish the table forever", "questionable",
                    "Only if sharp and planned.")
                ],
              }),
              selectAct({
                id: "act-05-09-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Session discipline is part of?",
                a11y: "Winning strategy — not soft extra credit.",
                objectives: ["End sessions before leaks spiral"], lifeLoss: true,
                choices: [
                  choice("edge", "Your edge — same as technical skill", "recommended",
                    "Bankroll and fatigue matter."),
                  choice("soft", "Optional soft skills only", "clear_mistake",
                    "It is core.", {betterChoiceId: "edge"})
                ],
              }),
            ],
          }),
          lesson({
            id: L050902, order: 2,
            title: "Section 5 checkpoint",
            summary: "Confirm multiway, depth, value, lines, and discipline.",
            objectives: ["Confirm multiway and deep-stack priorities", "Confirm thin value versus types", "Confirm soft evidence and discipline"],
            prereq: L050901, remediation: L050101, minutes: 10, band: 4,
            playerTypeRefs: ["calling_station", "maniac", "nit"],
            activities: [
              selectAct({
                id: "act-05-09-02-cp-multi", order: 1, stage: "checkpoint",
                prompt: "Four-way pot priority?",
                a11y: "Nut potential.",
                objectives: ["Confirm multiway and deep-stack priorities"], lifeLoss: true,
                choices: [
                  choice("nut", "Nut potential over weak bluffs", "recommended",
                    "Crowds punish air."),
                  choice("bluff", "Bluff more multiway", "clear_mistake",
                    "Opposite.", {betterChoiceId: "nut"})
                ],
              }),
              actionAct({
                id: "act-05-09-02-cp-value", order: 2, stage: "checkpoint",
                prompt: "River second pair vs Calling Station. Action?",
                a11y: "Thin value.",
                objectives: ["Confirm thin value versus types"],
                lifeLoss: true,
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("bet", "Bet thin value", "recommended",
                    "They call worse.", {action: "BET", amountBb: 8, reversalRead: "Versus nit: check."}),
                  choice("bluff", "Huge bluff", "clear_mistake",
                    "They call.", {action: "BET", amountBb: 40, betterChoiceId: "bet"})
                ],
              }),
              actionAct({
                id: "act-05-09-02-cp-catch", order: 3, stage: "checkpoint",
                prompt: "Maniac river barrel. Second pair. Action?",
                a11y: "Call.",
                objectives: ["Confirm thin value versus types"],
                lifeLoss: true,
                playerTypeRefs: ["maniac"],
                choices: [
                  choice("call", "Call", "recommended",
                    "Wide aggression.", {action: "CALL", reversalRead: "Nit barrel: fold more."}),
                  choice("fold", "Fold always", "questionable",
                    "Too tight.", {action: "FOLD"})
                ],
              }),
              selectAct({
                id: "act-05-09-02-cp-tell", order: 4, stage: "checkpoint",
                prompt: "Instant shove proves?",
                a11y: "Nothing absolute.",
                objectives: ["Confirm soft evidence and discipline"], lifeLoss: true,
                choices: [
                  choice("soft", "Nothing absolute — soft evidence only", "recommended",
                    "No magic tells."),
                  choice("nuts", "Absolute nuts", "clear_mistake",
                    "Overclaim.", {betterChoiceId: "soft"})
                ],
              }),
              selectAct({
                id: "act-05-09-02-cp-stop", order: 5, stage: "checkpoint",
                prompt: "Hit stop-loss. Do?",
                a11y: "Stop.",
                objectives: ["Confirm soft evidence and discipline"], lifeLoss: true,
                choices: [
                  choice("stop", "Honor the stop-loss", "recommended",
                    "Guardrails."),
                  choice("chase", "Chase", "clear_mistake",
                    "Leak.", {betterChoiceId: "stop"})
                ],
              }),
            ],
          }),
        ]),
    ],
  };
}

export const SECTION_FIVE_EXIT_LESSON =
  "lesson-05-09-02-section-five-checkpoint";

/** @returns {object} Section 6 — Advanced Live Cash */
export function buildSectionSix() {
  const prev = SECTION_FIVE_EXIT_LESSON;
  const L060101 = "lesson-06-01-01-range-nut-advantage";
  const L060201 = "lesson-06-02-01-equity-realization";
  const L060301 = "lesson-06-03-01-capped-uncapped";
  const L060401 = "lesson-06-04-01-polar-merged";
  const L060501 = "lesson-06-05-01-overbets-geometric";
  const L060601 = "lesson-06-06-01-blockers";
  const L060701 = "lesson-06-07-01-minimum-defense";
  const L060801 = "lesson-06-08-01-mixed-strategy";
  const L060901 = "lesson-06-09-01-threebet-fourbet";
  const L061001 = "lesson-06-10-01-difficult-folds";
  const L061101 = "lesson-06-11-01-observe-selective";
  const L061102 = MEET_TAG;
  const L061103 = "lesson-06-11-03-adjust-tag";
  const L061201 = "lesson-06-12-01-observe-wide-pressure";
  const L061202 = MEET_LAG;
  const L061203 = "lesson-06-12-03-adjust-lag";
  const L061301 = "lesson-06-13-01-mix-five-types";
  const L061302 = "lesson-06-13-02-section-six-checkpoint";

  return {
    id: "sec-06-advanced-live",
    order: 6,
    title: "Advanced Live Cash",
    summary: "Think in ranges, incentives, and future streets.",
    experienceBand: "advanced_live",
    units: [
      unit("unit-06-01-range-nut-adv", 1, "Range and nut advantage",
        "Who owns the range and the nuts.", [
          lesson({
            id: L060101, order: 1,
            title: "Spot range advantage and nut advantage",
            summary: "Bet more when you own the range or the nuts; check more when you do not.",
            objectives: ["Identify range advantage", "Identify nut advantage", "Choose pressure when you own both"],
            prereq: prev, remediation: prev, minutes: 9, band: 5,
            activities: [
              dialogue("act-06-01-01-explain", 1,
                "Range advantage: more strong hands overall. Nut advantage: more of the nuts.",
                {objectives: ["Identify range advantage"]}),
              selectAct({
                id: "act-06-01-01-guided", order: 2, stage: "guided",
                prompt: "PFR on A-high dry flop. Who often has range advantage?",
                a11y: "Preflop raiser.",
                objectives: ["Identify range advantage"],
                choices: [
                  choice("pfr", "The preflop raiser", "recommended",
                    "Aces and big pairs sit more in the PFR range."),
                  choice("caller", "The flatting BB always", "clear_mistake",
                    "Usually not.", {betterChoiceId: "pfr"})
                ],
              }),
              selectAct({
                id: "act-06-01-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Paired board. Caller defends wide. Who may have nut advantage?",
                a11y: "Often the wider caller has more trips/fulls.",
                objectives: ["Identify nut advantage"],
                choices: [
                  choice("caller-nuts", "The wide caller can hold more trips/fulls", "recommended",
                    "Nut advantage can flip even if PFR has range advantage."),
                  choice("pfr-always", "PFR always owns the nuts", "clear_mistake",
                    "Not on paired boards.", {betterChoiceId: "caller-nuts"})
                ],
              }),
              actionAct({
                id: "act-06-01-01-unguided", order: 4, stage: "unguided",
                prompt: "You are PFR on K72r. Action with range+nut lean?",
                a11y: "C-bet with advantage.",
                objectives: ["Choose pressure when you own both"], lifeLoss: true,
                choices: [
                  choice("cbet", "C-bet", "recommended",
                    "Advantage boards support betting.", {action: "BET", amountBb: 6}),
                  choice("check", "Auto-check", "questionable",
                    "Misses pressure."),
                  choice("jam", "Jam 200bb", "clear_mistake",
                    "Too much.", {action: "RAISE", amountBb: 200, betterChoiceId: "cbet"})
                ],
              }),
              selectAct({
                id: "act-06-01-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Advantage is a reason to?",
                a11y: "Apply pressure selectively.",
                objectives: ["Choose pressure when you own both"], lifeLoss: true,
                choices: [
                  choice("press", "Apply pressure with a turn plan", "recommended",
                    "Not random aggression."),
                  choice("random", "Bet any two blindly", "clear_mistake",
                    "Still need a plan.", {betterChoiceId: "press"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-02-eq-realize", 2, "Equity realization",
        "Realize equity in and out of position.", [
          lesson({
            id: L060201, order: 1,
            title: "Realize equity in and out of position",
            summary: "Position and initiative change how much equity you actually cash.",
            objectives: ["Prefer IP for marginal equity", "Discount OOP equity", "Use aggression to realize when appropriate"],
            prereq: L060101, remediation: L060101, minutes: 8, band: 5,
            activities: [
              dialogue("act-06-02-01-explain", 1,
                "Equity on a chart is not cash. Position decides realization.",
                {objectives: ["Prefer IP for marginal equity"]}),
              selectAct({
                id: "act-06-02-01-guided", order: 2, stage: "guided",
                prompt: "Same draw OOP vs IP. Where does it realize better?",
                a11y: "In position.",
                objectives: ["Prefer IP for marginal equity"],
                choices: [
                  choice("ip", "In position", "recommended",
                    "IP sees cheap cards and controls size."),
                  choice("oop", "Out of position always", "clear_mistake",
                    "OOP realizes worse.", {betterChoiceId: "ip"})
                ],
              }),
              selectAct({
                id: "act-06-02-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Weak showdown value OOP facing dual barrels. Default?",
                a11y: "Discount and fold more.",
                objectives: ["Discount OOP equity"],
                choices: [
                  choice("discount", "Discount realization — fold more", "recommended",
                    "OOP one-pair dies to pressure."),
                  choice("hero", "Hero-call every street", "clear_mistake",
                    "Over-realize fantasy.", {betterChoiceId: "discount"})
                ],
              }),
              selectAct({
                id: "act-06-02-01-unguided", order: 4, stage: "unguided",
                prompt: "Semi-bluff check-raise with nut draw IP-denied. Purpose?",
                a11y: "Realize equity via fold equity + outs.",
                objectives: ["Use aggression to realize when appropriate"], lifeLoss: true,
                choices: [
                  choice("realize", "Create fold equity and deny their cheap cards", "recommended",
                    "Aggression can realize equity."),
                  choice("fancy", "Fancy play for its own sake", "clear_mistake",
                    "Need a reason.", {betterChoiceId: "realize"})
                ],
              }),
              selectAct({
                id: "act-06-02-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Equity realization rises with?",
                a11y: "Position and initiative.",
                objectives: ["Prefer IP for marginal equity"], lifeLoss: true,
                choices: [
                  choice("pos", "Position and initiative", "recommended",
                    "Core levers."),
                  choice("hope", "Hope alone", "clear_mistake",
                    "Not a plan.", {betterChoiceId: "pos"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-03-capped", 3, "Capped and uncapped ranges",
        "Know when the nuts are still possible.", [
          lesson({
            id: L060301, order: 1,
            title: "Recognize capped versus uncapped ranges",
            summary: "Lines remove or keep the nuts; attack caps, respect uncapped heat.",
            objectives: ["Spot capped ranges from passive lines", "Respect uncapped aggression", "Attack caps with thin value and bluffs"],
            prereq: L060201, remediation: L060201, minutes: 8, band: 5,
            activities: [
              dialogue("act-06-03-01-explain", 1,
                "Capped = nuts unlikely. Uncapped = nuts still live.",
                {objectives: ["Spot capped ranges from passive lines"]}),
              selectAct({
                id: "act-06-03-01-guided", order: 2, stage: "guided",
                prompt: "Villain checks turn after betting flop. Often?",
                a11y: "Capped.",
                objectives: ["Spot capped ranges from passive lines"],
                choices: [
                  choice("cap", "Capped — fewer nuts", "recommended",
                    "Strong hands keep charging."),
                  choice("uncap", "Still full uncapped nuts", "clear_mistake",
                    "Less likely.", {betterChoiceId: "cap"})
                ],
              }),
              actionAct({
                id: "act-06-03-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Villain capped on river. You have thin value. Action?",
                a11y: "Bet thin / stab.",
                objectives: ["Attack caps with thin value and bluffs"],
                choices: [
                  choice("bet", "Bet for thin value or a stab", "recommended",
                    "Caps call worse and fold medium.", {action: "BET", amountBb: 10}),
                  choice("check", "Always check", "questionable",
                    "Misses the exploit."),
                  choice("fold", "Fold showdown value", "clear_mistake",
                    "You are betting.", {action: "FOLD", betterChoiceId: "bet"})
                ],
              }),
              selectAct({
                id: "act-06-03-01-unguided", order: 4, stage: "unguided",
                prompt: "Check-raise flop, bet turn, bomb river. Treat as?",
                a11y: "Uncapped — respect.",
                objectives: ["Respect uncapped aggression"], lifeLoss: true,
                choices: [
                  choice("uncap", "Uncapped — need a strong catcher", "recommended",
                    "Baseline respect."),
                  choice("cap2", "Capped air only", "clear_mistake",
                    "Wrong.", {betterChoiceId: "uncap"})
                ],
              }),
              selectAct({
                id: "act-06-03-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Caps are for?",
                a11y: "Attacking.",
                objectives: ["Attack caps with thin value and bluffs"], lifeLoss: true,
                choices: [
                  choice("attack", "Attacking with value and chosen bluffs", "recommended",
                    "That is the exploit."),
                  choice("fear", "Automatic folds forever", "clear_mistake",
                    "Opposite.", {betterChoiceId: "attack"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-04-polar-merged", 4, "Polarized versus merged betting",
        "Match sizing and range shape.", [
          lesson({
            id: L060401, order: 1,
            title: "Choose polarized or merged betting",
            summary: "Big sizes skew polar; medium sizes support merged value.",
            objectives: ["Recognize polarized sizing", "Use merged sizes for thin value", "Avoid mismatched shapes"],
            prereq: L060301, remediation: L060301, minutes: 8, band: 5,
            activities: [
              dialogue("act-06-04-01-explain", 1,
                "Polar: nuts or air. Merged: many medium-strong hands. Size accordingly.",
                {objectives: ["Recognize polarized sizing"]}),
              selectAct({
                id: "act-06-04-01-guided", order: 2, stage: "guided",
                prompt: "River overbet usually wants which shape?",
                a11y: "Polarized.",
                objectives: ["Recognize polarized sizing"],
                choices: [
                  choice("polar", "Polarized — value or bluff", "recommended",
                    "Overbets punish medium."),
                  choice("merged", "Merged thin value only", "clear_mistake",
                    "Thin value prefers smaller.", {betterChoiceId: "polar"})
                ],
              }),
              actionAct({
                id: "act-06-04-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Thin value vs station on river. Size shape?",
                a11y: "Merged medium.",
                objectives: ["Use merged sizes for thin value"],
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("mid", "Medium merged value bet", "recommended",
                    "Get called by worse.", {action: "BET", amountBb: 8}),
                  choice("ob", "Huge polar overbet", "questionable",
                    "Can fold out worse."),
                  choice("check", "Check always", "questionable",
                    "Misses value.")
                ],
              }),
              selectAct({
                id: "act-06-04-01-unguided", order: 4, stage: "unguided",
                prompt: "Mismatch to avoid?",
                a11y: "Tiny bets as pure polar bluffs without a story.",
                objectives: ["Avoid mismatched shapes"], lifeLoss: true,
                choices: [
                  choice("mismatch", "Tiny \"polar\" bluffs that never get folds", "recommended",
                    "Shape must match goal."),
                  choice("ok", "Any size is always fine", "clear_mistake",
                    "Sizes communicate.", {betterChoiceId: "mismatch"})
                ],
              }),
              selectAct({
                id: "act-06-04-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Merged betting aims to?",
                a11y: "Get called by worse / fold out some better sometimes.",
                objectives: ["Use merged sizes for thin value"], lifeLoss: true,
                choices: [
                  choice("thin", "Extract from worse medium hands", "recommended",
                    "Classic thin value."),
                  choice("only-nuts", "Only ever bet nuts", "clear_mistake",
                    "Too polar.", {betterChoiceId: "thin"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-05-overbets", 5, "Overbets and geometric sizing",
        "Pressure stacks with coherent street sizes.", [
          lesson({
            id: L060501, order: 1,
            title: "Use overbets and geometric pressure",
            summary: "Choose overbets when polar; plan geometric sizes across streets.",
            objectives: ["Select overbets for polar spots", "Plan geometric street sizes", "Avoid random huge bets"],
            prereq: L060401, remediation: L060401, minutes: 8, band: 5,
            activities: [
              dialogue("act-06-05-01-explain", 1,
                "Overbets need a polar story. Geometry links flop-turn-river sizes.",
                {objectives: ["Select overbets for polar spots"]}),
              selectAct({
                id: "act-06-05-01-guided", order: 2, stage: "guided",
                prompt: "Best overbet river candidate?",
                a11y: "Nuts or strong bluffs with blockers.",
                objectives: ["Select overbets for polar spots"],
                choices: [
                  choice("polar-ob", "Nuts or chosen bluffs with blockers", "recommended",
                    "Polar story."),
                  choice("tpwk", "Top pair weak kicker always", "clear_mistake",
                    "Merged hand, wrong size.", {betterChoiceId: "polar-ob"})
                ],
              }),
              numericAct({
                id: "act-06-05-01-scaffolded", order: 3, stage: "scaffolded",
                question: "Pot 20. Geometric ~pot-ish turn after half-pot flop. Rough turn bet?",
                a11y: "Around 20.",
                objectives: ["Plan geometric street sizes"],
                unit: "chips", min: 16, max: 28,
                okFeedback: "Near-pot keeps river shove geometry clean.",
                missFeedback: "Think pot-sized continuation.",
              }),
              selectAct({
                id: "act-06-05-01-unguided", order: 4, stage: "unguided",
                prompt: "Random 3x pot bet with medium strength?",
                a11y: "Avoid.",
                objectives: ["Avoid random huge bets"], lifeLoss: true,
                choices: [
                  choice("avoid", "Avoid — size needs a story", "recommended",
                    "No random bombs."),
                  choice("yolo", "Always fine", "clear_mistake",
                    "Leaks stacks.", {betterChoiceId: "avoid"})
                ],
              }),
              selectAct({
                id: "act-06-05-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Geometric sizing primarily helps?",
                a11y: "Multi-street stack pressure.",
                objectives: ["Plan geometric street sizes"], lifeLoss: true,
                choices: [
                  choice("multi", "Multi-street commitment planning", "recommended",
                    "Link streets."),
                  choice("style", "Looking flashy", "clear_mistake",
                    "Not the goal.", {betterChoiceId: "multi"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-06-blockers", 6, "Blockers and unblockers",
        "Card removal for bluffs and calls.", [
          lesson({
            id: L060601, order: 1,
            title: "Use blockers without solver theater",
            summary: "Blocker cards remove villain nuts or value; unblockers keep their folds.",
            objectives: ["Choose bluffs that block call-downs", "Prefer call-downs that unblock bluffs", "Avoid fabricated EV claims"],
            prereq: L060501, remediation: L060501, minutes: 8, band: 5,
            activities: [
              dialogue("act-06-06-01-explain", 1,
                "Blockers remove hands. Use them; do not invent EV decimals.",
                {objectives: ["Choose bluffs that block call-downs"]}),
              selectAct({
                id: "act-06-06-01-guided", order: 2, stage: "guided",
                prompt: "River bluff on completed flush board. Better blocker?",
                a11y: "Ace of the suit.",
                objectives: ["Choose bluffs that block call-downs"],
                choices: [
                  choice("as", "Ace of the flush suit", "recommended",
                    "Blocks nut flushes that call."),
                  choice("off", "Offsuit undercards with no blockers", "questionable",
                    "Worse bluff candidate."),
                  choice("ev", "Whatever has +0.37bb in a sim you invented", "clear_mistake",
                    "No fabricated EV.", {betterChoiceId: "as"})
                ],
              }),
              selectAct({
                id: "act-06-06-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Bluff-catching a river bomb on flush board. Prefer?",
                a11y: "Unblock bluffs — no flush blockers.",
                objectives: ["Prefer call-downs that unblock bluffs"],
                choices: [
                  choice("unblock", "Hands that unblock their bluffs", "recommended",
                    "You want them to have air."),
                  choice("block-nuts", "Block their air and unblock nuts", "clear_mistake",
                    "Opposite.", {betterChoiceId: "unblock"})
                ],
              }),
              selectAct({
                id: "act-06-06-01-unguided", order: 4, stage: "unguided",
                prompt: "Blockers replace?",
                a11y: "Nothing — they tweak choices.",
                objectives: ["Avoid fabricated EV claims"], lifeLoss: true,
                choices: [
                  choice("tweak", "A tweak on top of line/type evidence", "recommended",
                    "Not a magic wand."),
                  choice("replace", "All other poker reasoning", "clear_mistake",
                    "Too narrow.", {betterChoiceId: "tweak"})
                ],
              }),
              selectAct({
                id: "act-06-06-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Course stance on solver EV quotes?",
                a11y: "No fabricated EV.",
                objectives: ["Avoid fabricated EV claims"], lifeLoss: true,
                choices: [
                  choice("no", "No fabricated solver EV", "recommended",
                    "Qualitative and decision-linked only."),
                  choice("fake", "Invent precise EVs freely", "clear_mistake",
                    "Forbidden.", {betterChoiceId: "no"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-07-min-defense", 7, "Minimum-defense intuition",
        "Defend enough to punish over-bluffing — without frequency theater.", [
          lesson({
            id: L060701, order: 1,
            title: "Defend enough without frequency theater",
            summary: "Continue with better bluff-catchers; fold the clear trash.",
            objectives: ["Continue with stronger catchers", "Fold dominated trash", "Ignore fake MDF percentages"],
            prereq: L060601, remediation: L060601, minutes: 8, band: 5,
            activities: [
              dialogue("act-06-07-01-explain", 1,
                "Defend enough that over-bluffing fails. No fake percentages.",
                {objectives: ["Continue with stronger catchers"]}),
              selectAct({
                id: "act-06-07-01-guided", order: 2, stage: "guided",
                prompt: "Facing a river bet. Best continue?",
                a11y: "Top pair / strong blockers.",
                objectives: ["Continue with stronger catchers"],
                choices: [
                  choice("strong", "Better showdown + blocker hands", "recommended",
                    "Quality over quota."),
                  choice("any", "Any two to hit a magic percent", "clear_mistake",
                    "No frequency theater.", {betterChoiceId: "strong"})
                ],
              }),
              selectAct({
                id: "act-06-07-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Third pair no blockers on scary river. Default?",
                a11y: "Fold.",
                objectives: ["Fold dominated trash"],
                choices: [
                  choice("fold", "Fold", "recommended",
                    "Clear trash exits."),
                  choice("call-mdf", "Call to satisfy a memorized MDF number", "clear_mistake",
                    "Theater.", {betterChoiceId: "fold"})
                ],
              }),
              selectAct({
                id: "act-06-07-01-unguided", order: 4, stage: "unguided",
                prompt: "MDF numbers in this course?",
                a11y: "Intuition only — no fake precision.",
                objectives: ["Ignore fake MDF percentages"], lifeLoss: true,
                choices: [
                  choice("int", "Intuition — defend better hands, fold trash", "recommended",
                    "Decision-linked."),
                  choice("pct", "Memorize exact percents as truth", "clear_mistake",
                    "Not our method.", {betterChoiceId: "int"})
                ],
              }),
              selectAct({
                id: "act-06-07-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Minimum defense goal?",
                a11y: "Punish over-bluffing with sensible continues.",
                objectives: ["Continue with stronger catchers"], lifeLoss: true,
                choices: [
                  choice("punish", "Make over-bluffing unprofitable with good continues", "recommended",
                    "That's the idea."),
                  choice("call-all", "Never fold", "clear_mistake",
                    "Too wide.", {betterChoiceId: "punish"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-08-mixed", 8, "Mixed strategy as frequency",
        "Mix for balance and unpredictability — not randomness for its own sake.", [
          lesson({
            id: L060801, order: 1,
            title: "Mix with a reason",
            summary: "Sometimes check strong; sometimes bet medium — with an exploit purpose.",
            objectives: ["Mix strong hands sometimes", "Avoid pure randomness", "Let types reduce mixing needs"],
            prereq: L060701, remediation: L060701, minutes: 8, band: 5,
            playerTypeRefs: ["calling_station"],
            activities: [
              dialogue("act-06-08-01-explain", 1,
                "Mixing is frequency with a purpose — not coin-flip theater.",
                {objectives: ["Mix strong hands sometimes"]}),
              selectAct({
                id: "act-06-08-01-guided", order: 2, stage: "guided",
                prompt: "Why check a set sometimes?",
                a11y: "Protect checking range / induce.",
                objectives: ["Mix strong hands sometimes"],
                choices: [
                  choice("protect", "Protect checks and induce bluffs", "recommended",
                    "Purposeful mix."),
                  choice("coin", "Because a coin said so", "clear_mistake",
                    "Need a reason.", {betterChoiceId: "protect"})
                ],
              }),
              selectAct({
                id: "act-06-08-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Versus a Calling Station, how much bluff-mixing?",
                a11y: "Less — they do not fold.",
                objectives: ["Let types reduce mixing needs"],
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("less", "Less bluffing — value heavier", "recommended",
                    "Exploit reduces mix need.", {reversalRead: "Versus nit: more bluff mix."}),
                  choice("same", "Same mix as versus unknowns always", "clear_mistake",
                    "Ignore type.", {betterChoiceId: "less"})
                ],
              }),
              selectAct({
                id: "act-06-08-01-unguided", order: 4, stage: "unguided",
                prompt: "Randomness for its own sake?",
                a11y: "No.",
                objectives: ["Avoid pure randomness"], lifeLoss: true,
                choices: [
                  choice("no", "No — mix only with a strategic reason", "recommended",
                    "Frequency ≠ chaos."),
                  choice("yes", "Yes — always randomize", "clear_mistake",
                    "Wrong.", {betterChoiceId: "no"})
                ],
              }),
              selectAct({
                id: "act-06-08-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Best mix description?",
                a11y: "Frequency with purpose.",
                objectives: ["Avoid pure randomness"], lifeLoss: true,
                choices: [
                  choice("freq", "Frequency with purpose", "recommended",
                    "Course standard."),
                  choice("chaos", "Chaos as a lifestyle", "clear_mistake",
                    "No.", {betterChoiceId: "freq"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-09-3bet4bet", 9, "3-bet and 4-bet pots",
        "Play raised pots across stack depths.", [
          lesson({
            id: L060901, order: 1,
            title: "Navigate 3-bet and 4-bet pots by depth",
            summary: "Stack depth changes commitment, ranges, and postflop plans.",
            objectives: ["Tighten 4-bet pots appropriately", "Plan 3-bet pots by SPR", "Avoid ego 4-bets"],
            prereq: L060801, remediation: L060801, minutes: 9, band: 5,
            activities: [
              dialogue("act-06-09-01-explain", 1,
                "3-bet and 4-bet pots shrink ranges and SPR. Depth decides commitment.",
                {objectives: ["Plan 3-bet pots by SPR"]}),
              selectAct({
                id: "act-06-09-01-guided", order: 2, stage: "guided",
                prompt: "100bb 4-bet pot. Flop top pair. Default mindset?",
                a11y: "Often committed-ish — careful.",
                objectives: ["Tighten 4-bet pots appropriately"],
                choices: [
                  choice("careful", "High commitment — fewer heroics with weak kickers", "recommended",
                    "SPR is low."),
                  choice("deep", "Play as if 300bb deep", "clear_mistake",
                    "Wrong depth.", {betterChoiceId: "careful"})
                ],
              }),
              actionAct({
                id: "act-06-09-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "BTN opens, you 3-bet AQo BB, depth 180bb. Flop misses. Action?",
                a11y: "Small c-bet or give-up — not auto-jam.",
                objectives: ["Plan 3-bet pots by SPR"],
                choices: [
                  choice("small", "Small c-bet or disciplined give-up", "recommended",
                    "Deep 3-bet pots need a plan.", {action: "BET", amountBb: 8}),
                  choice("jam", "Jam all three streets forever", "clear_mistake",
                    "Too automatic.", {action: "RAISE", amountBb: 180, betterChoiceId: "small"})
                ],
              }),
              selectAct({
                id: "act-06-09-01-unguided", order: 4, stage: "unguided",
                prompt: "Light 4-bet bluff with no blockers for ego?",
                a11y: "Avoid.",
                objectives: ["Avoid ego 4-bets"], lifeLoss: true,
                choices: [
                  choice("avoid", "Avoid ego 4-bets", "recommended",
                    "Need blockers and folds."),
                  choice("ego", "4-bet any two for style", "clear_mistake",
                    "Leak.", {betterChoiceId: "avoid"})
                ],
              }),
              selectAct({
                id: "act-06-09-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Depth change in 3-bet pots mainly changes?",
                a11y: "SPR and commitment thresholds.",
                objectives: ["Plan 3-bet pots by SPR"], lifeLoss: true,
                choices: [
                  choice("spr", "SPR and when you are committed", "recommended",
                    "Core."),
                  choice("suits", "Only the suit of the felt", "clear_mistake",
                    "Irrelevant.", {betterChoiceId: "spr"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-10-folds", 10, "Difficult folds and coolers",
        "Separate coolers from mistakes.", [
          lesson({
            id: L061001, order: 1,
            title: "Make difficult folds; review coolers fairly",
            summary: "Fold dominated hands; do not call down for ego; review cooler versus mistake.",
            objectives: ["Fold dominated one-pair in heat", "Separate coolers from mistakes", "Avoid ego call-downs"],
            prereq: L060901, remediation: L060901, minutes: 8, band: 5,
            activities: [
              dialogue("act-06-10-01-explain", 1,
                "Hard folds save buy-ins. Coolers happen; ego call-downs are mistakes.",
                {objectives: ["Fold dominated one-pair in heat"]}),
              actionAct({
                id: "act-06-10-01-guided", order: 2, stage: "guided",
                prompt: "Top pair weak kicker faces triple barrels from a solid unknown. Action?",
                a11y: "Often fold.",
                objectives: ["Fold dominated one-pair in heat"],
                choices: [
                  choice("fold", "Fold", "recommended",
                    "Difficult but correct without a maniac read.", {action: "FOLD", reversalRead: "Maniac barrels: call wider."}),
                  choice("call", "Call it off", "questionable",
                    "Needs a wider read."),
                  choice("raise", "Hero-raise light", "clear_mistake",
                    "Ego.", {action: "RAISE", amountBb: 40, betterChoiceId: "fold"})
                ],
              }),
              selectAct({
                id: "act-06-10-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "KK loses to AA all-in pre. Review label?",
                a11y: "Cooler.",
                objectives: ["Separate coolers from mistakes"],
                choices: [
                  choice("cooler", "Cooler — standard stack-off", "recommended",
                    "Not a skill leak."),
                  choice("mistake", "Mistake — you should fold KK pre", "clear_mistake",
                    "Wrong.", {betterChoiceId: "cooler"})
                ],
              }),
              selectAct({
                id: "act-06-10-01-unguided", order: 4, stage: "unguided",
                prompt: "Calling because you are \"due\"?",
                a11y: "Mistake.",
                objectives: ["Avoid ego call-downs"], lifeLoss: true,
                choices: [
                  choice("ego", "Mistake — ego call-down", "recommended",
                    "Due is not a reason."),
                  choice("ok", "Sound strategy", "clear_mistake",
                    "No.", {betterChoiceId: "ego"})
                ],
              }),
              selectAct({
                id: "act-06-10-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Review question after a big loss?",
                a11y: "Cooler or mistake?",
                objectives: ["Separate coolers from mistakes"], lifeLoss: true,
                choices: [
                  choice("ask", "Was this a cooler or a mistake?", "recommended",
                    "Honest review."),
                  choice("rtilt", "Only tilt harder", "clear_mistake",
                    "No.", {betterChoiceId: "ask"})
                ],
              }),
            ],
          }),
        ]),

      unit("unit-06-11-tag", 11, "Player type: TAG",
        "Observe selective aggression, then label and adjust.", [
          lesson({
            id: L061101, order: 1,
            title: "Observe selective aggression",
            summary: "Note tight entry with disciplined barrels before any label.",
            objectives: ["Note selective entry", "Note disciplined aggression", "Delay the label until samples exist"],
            prereq: L061001, remediation: L061001, minutes: 7, band: 5,
            activities: [
              dialogue("act-06-11-01-explain", 1,
                "Before labels: who enters tight, then barrels with a plan? Count samples.",
                {objectives: ["Note selective entry"]}),
              selectAct({
                id: "act-06-11-01-guided", order: 2, stage: "guided",
                prompt: "Seat folds most hands, then 3-bets and c-bets strong boards. Note?",
                a11y: "Selective entry + disciplined aggression.",
                objectives: ["Note selective entry"],
                choices: [
                  choice("sel", "Selective entry with disciplined aggression", "recommended",
                    "That is the evidence bundle."),
                  choice("loose", "Loose passive", "clear_mistake",
                    "Opposite.", {betterChoiceId: "sel"}),
                  choice("label", "Name an archetype immediately", "clear_mistake",
                    "Observe first — need samples.", {betterChoiceId: "sel"})
                ],
              }),
              selectAct({
                id: "act-06-11-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Same seat gives up on turns when called. Observation?",
                a11y: "Disciplined — not maniac.",
                objectives: ["Note disciplined aggression"],
                choices: [
                  choice("disc", "Disciplined give-ups — not spewy", "recommended",
                    "Separates planned aggression from maniac spew."),
                  choice("mania", "Identical to maniac", "clear_mistake",
                    "Maniacs continue too wide.", {betterChoiceId: "disc"})
                ],
              }),
              selectAct({
                id: "act-06-11-01-unguided", order: 4, stage: "unguided",
                prompt: "Two hands of tightness. Confidence?",
                a11y: "Low.",
                objectives: ["Delay the label until samples exist"], lifeLoss: true,
                choices: [
                  choice("low", "Low — keep sampling", "recommended",
                    "Working notes first."),
                  choice("max", "Maximum certainty", "clear_mistake",
                    "Too soon.", {betterChoiceId: "low"})
                ],
              }),
              selectAct({
                id: "act-06-11-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Best pre-label note bundle?",
                a11y: "Tight in, aggressive with discipline.",
                objectives: ["Delay the label until samples exist"], lifeLoss: true,
                choices: [
                  choice("bundle", "Tight entry + planned aggression + give-ups", "recommended",
                    "That's the bundle."),
                  choice("vibe", "Good haircut", "clear_mistake",
                    "Not evidence.", {betterChoiceId: "bundle"})
                ],
              }),
            ],
          }),
          lesson({
            id: L061102, order: 2,
            title: "Meet the TAG",
            summary: "Attach TAG to selective entry with disciplined aggression.",
            objectives: ["Introduce TAG", "Identify TAG from evidence"],
            prereq: L061101, remediation: L061101, minutes: 7, band: 5,
            playerTypeRefs: ["tag"],
            introducesPlayerTypes: ["tag"],
            activities: [
              dialogue("act-06-11-02-explain", 1,
                "TAG: tight in, aggressive after — a working model.",
                {objectives: ["Introduce TAG"], playerTypeRefs: ["tag"]}),
              classifyAct({
                id: "act-06-11-02-guided", order: 2, stage: "guided",
                prompt: "Folds most, 3-bets strong, barrels with a plan. Label?",
                a11y: "TAG.",
                objectives: ["Identify TAG from evidence"],
                playerTypeRefs: ["tag"],
                choices: [
                  choice("tag", "TAG", "recommended",
                    "Selective + disciplined.", {reversalRead: "If entry widens and barrels never stop, consider maniac."}),
                  choice("station", "Calling Station", "clear_mistake",
                    "Stations call; this seat raises selectively.", {betterChoiceId: "tag"})
                ],
              }),
              selectAct({
                id: "act-06-11-02-scaffolded", order: 3, stage: "scaffolded",
                prompt: "TAG versus Maniac difference?",
                a11y: "Entry width and discipline.",
                objectives: ["Introduce TAG"],
                choices: [
                  choice("diff", "TAG is selective; maniac is extreme and sticky", "recommended",
                    "Discipline matters."),
                  choice("same", "Identical labels", "clear_mistake",
                    "No.", {betterChoiceId: "diff"})
                ],
              }),
              classifyAct({
                id: "act-06-11-02-unguided", order: 4, stage: "unguided",
                prompt: "Seat opens tight, folds to 3-bets, c-bets selectively. Label?",
                a11y: "TAG.",
                objectives: ["Identify TAG from evidence"],
                lifeLoss: true,
                playerTypeRefs: ["tag"],
                choices: [
                  choice("tag2", "TAG", "recommended",
                    "Fits.", {reversalRead: "Loose opens + endless barrels → not TAG."}),
                  choice("mania2", "Maniac", "clear_mistake",
                    "Maniacs enter and continue far too wide.", {betterChoiceId: "tag2"})
                ],
              }),
              selectAct({
                id: "act-06-11-02-checkpoint", order: 5, stage: "checkpoint",
                prompt: "TAG is?",
                a11y: "Working model.",
                objectives: ["Introduce TAG"], lifeLoss: true,
                choices: [
                  choice("model", "A working model from frequencies", "recommended",
                    "Update with evidence."),
                  choice("soul", "A personality insult", "clear_mistake",
                    "No judgments.", {betterChoiceId: "model"})
                ],
              }),
            ],
          }),
          lesson({
            id: L061103, order: 3,
            title: "Adjust versus TAG",
            summary: "Respect TAG heat; steal less than versus nits; avoid light bluff-raises.",
            objectives: ["Respect TAG aggression", "Value thin only when they call", "Avoid bluffing TAG check-raises light"],
            prereq: L061102, remediation: L061102, minutes: 8, band: 5,
            playerTypeRefs: ["tag"],
            activities: [
              dialogue("act-06-11-03-explain", 1,
                "Versus TAG: respect raises; do not invent light bluff-raises.",
                {objectives: ["Respect TAG aggression"], playerTypeRefs: ["tag"]}),
              actionAct({
                id: "act-06-11-03-guided", order: 2, stage: "guided",
                prompt: "TAG check-raises flop. You have second pair. Action?",
                a11y: "Fold often.",
                objectives: ["Avoid bluffing TAG check-raises light"],
                playerTypeRefs: ["tag"],
                choices: [
                  choice("fold", "Fold", "recommended",
                    "TAG check-raises are strong.", {action: "FOLD", reversalRead: "Maniac check-raise: continue wider."}),
                  choice("raise", "Rebluff light", "clear_mistake",
                    "Bad versus TAG.", {action: "RAISE", amountBb: 30, betterChoiceId: "fold"})
                ],
              }),
              actionAct({
                id: "act-06-11-03-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Steal BTN vs TAG BB with K9o. Action?",
                a11y: "Tighter than vs nit.",
                objectives: ["Respect TAG aggression"],
                playerTypeRefs: ["tag"],
                choices: [
                  choice("fold-k9", "Fold more than versus a nit", "recommended",
                    "TAG defends better than nits.", {action: "FOLD", reversalRead: "Versus nit BB: steal wider."}),
                  choice("open-wide", "Open any two", "clear_mistake",
                    "Too wide.", {action: "RAISE", amountBb: 3, betterChoiceId: "fold-k9"})
                ],
              }),
              actionAct({
                id: "act-06-11-03-unguided", order: 4, stage: "unguided",
                prompt: "River thin value vs TAG who rarely calls light. Action?",
                a11y: "Check more.",
                objectives: ["Value thin only when they call"],
                lifeLoss: true,
                playerTypeRefs: ["tag"],
                choices: [
                  choice("check", "Check back more", "recommended",
                    "They fold worse.", {action: "CHECK", reversalRead: "Station: bet thin."}),
                  choice("bet", "Always bet thin", "questionable",
                    "Needs call-down evidence.", {action: "BET", amountBb: 8})
                ],
              }),
              selectAct({
                id: "act-06-11-03-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Versus TAG, cite which tendency?",
                a11y: "Selective aggression / tighter call-downs.",
                objectives: ["Respect TAG aggression"], lifeLoss: true,
                playerTypeRefs: ["tag"],
                choices: [
                  choice("cite", "Selective aggression and disciplined folds", "recommended",
                    "Advice must cite the tendency."),
                  choice("vague", "Because vibes", "clear_mistake",
                    "Cite evidence.", {betterChoiceId: "cite"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-12-lag", 12, "Player type: LAG",
        "Observe wide pressure, then label and adjust.", [
          lesson({
            id: L061201, order: 1,
            title: "Observe wide sustained pressure",
            summary: "Note wide entry with ongoing barrels before any label.",
            objectives: ["Note wide entry", "Note sustained pressure", "Separate planned pressure from maniac samples"],
            prereq: L061103, remediation: L061103, minutes: 7, band: 5,
            activities: [
              dialogue("act-06-12-01-explain", 1,
                "Before labels: wide entry plus pressure that still has a plan. Count samples.",
                {objectives: ["Note wide entry"]}),
              selectAct({
                id: "act-06-12-01-guided", order: 2, stage: "guided",
                prompt: "Seat opens many hands and barrels often but folds some turn raises. Note?",
                a11y: "Wide + sustained but not mindless.",
                objectives: ["Note wide entry"],
                choices: [
                  choice("wide", "Wide entry with sustained pressure", "recommended",
                    "That is the evidence bundle."),
                  choice("nit", "Nit", "clear_mistake",
                    "Opposite entry.", {betterChoiceId: "wide"}),
                  choice("label", "Name an archetype immediately", "clear_mistake",
                    "Observe first — need samples.", {betterChoiceId: "wide"})
                ],
              }),
              selectAct({
                id: "act-06-12-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Difference brewing vs maniac?",
                a11y: "This seat still folds sometimes; maniac rarely.",
                objectives: ["Separate planned pressure from maniac samples"],
                choices: [
                  choice("sep", "Still makes some folds; maniac rarely does", "recommended",
                    "Discipline vs chaos."),
                  choice("same", "No difference ever", "clear_mistake",
                    "There is.", {betterChoiceId: "sep"})
                ],
              }),
              selectAct({
                id: "act-06-12-01-unguided", order: 4, stage: "unguided",
                prompt: "Label after one wide open?",
                a11y: "No.",
                objectives: ["Note sustained pressure"], lifeLoss: true,
                choices: [
                  choice("wait", "Wait for more samples", "recommended",
                    "One hand is a note."),
                  choice("now", "Lock a type label immediately", "clear_mistake",
                    "Too soon.", {betterChoiceId: "wait"})
                ],
              }),
              selectAct({
                id: "act-06-12-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Best pre-label note bundle?",
                a11y: "Wide + pressure + some discipline.",
                objectives: ["Separate planned pressure from maniac samples"], lifeLoss: true,
                choices: [
                  choice("bundle", "Wide entry, sustained barrels, occasional folds", "recommended",
                    "Bundle ready."),
                  choice("soul", "They seem loud", "clear_mistake",
                    "Not enough.", {betterChoiceId: "bundle"})
                ],
              }),
            ],
          }),
          lesson({
            id: L061202, order: 2,
            title: "Meet the LAG",
            summary: "Attach LAG to wide entry with sustained pressure.",
            objectives: ["Introduce LAG", "Identify LAG from evidence"],
            prereq: L061201, remediation: L061201, minutes: 7, band: 5,
            playerTypeRefs: ["lag"],
            introducesPlayerTypes: ["lag"],
            activities: [
              dialogue("act-06-12-02-explain", 1,
                "LAG: wide in, pressure on — still a working model.",
                {objectives: ["Introduce LAG"], playerTypeRefs: ["lag"]}),
              classifyAct({
                id: "act-06-12-02-guided", order: 2, stage: "guided",
                prompt: "Opens wide, barrels often, folds some raises. Label?",
                a11y: "LAG.",
                objectives: ["Identify LAG from evidence"],
                playerTypeRefs: ["lag"],
                choices: [
                  choice("lag", "LAG", "recommended",
                    "Wide + pressure.", {reversalRead: "If they never fold, shift toward maniac."}),
                  choice("tag", "TAG", "clear_mistake",
                    "TAG is selective.", {betterChoiceId: "lag"})
                ],
              }),
              selectAct({
                id: "act-06-12-02-scaffolded", order: 3, stage: "scaffolded",
                prompt: "LAG vs Calling Station?",
                a11y: "LAG raises; station calls.",
                objectives: ["Introduce LAG"],
                choices: [
                  choice("diff", "LAG applies pressure; stations call passively", "recommended",
                    "Different exploits."),
                  choice("same", "Same exploit always", "clear_mistake",
                    "No.", {betterChoiceId: "diff"})
                ],
              }),
              classifyAct({
                id: "act-06-12-02-unguided", order: 4, stage: "unguided",
                prompt: "Wide opens, 3-bets light, keeps barreling. Label?",
                a11y: "LAG.",
                objectives: ["Identify LAG from evidence"],
                lifeLoss: true,
                playerTypeRefs: ["lag"],
                choices: [
                  choice("lag2", "LAG", "recommended",
                    "Fits.", {reversalRead: "If barrels become mindless and never fold, maniac."}),
                  choice("nit2", "Nit", "clear_mistake",
                    "Opposite.", {betterChoiceId: "lag2"})
                ],
              }),
              selectAct({
                id: "act-06-12-02-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Show beside LAG label?",
                a11y: "Sample/confidence limits.",
                objectives: ["Introduce LAG"], lifeLoss: true,
                choices: [
                  choice("limits", "Sample and confidence limits", "recommended",
                    "Always."),
                  choice("destiny", "Destiny", "clear_mistake",
                    "No.", {betterChoiceId: "limits"})
                ],
              }),
            ],
          }),
          lesson({
            id: L061203, order: 3,
            title: "Adjust versus LAG",
            summary: "Trap more, call down wider, invent fewer fancy bluffs.",
            objectives: ["Widen bluff-catches versus LAG", "Trap strong hands more", "Avoid fancy bluffs into pressure"],
            prereq: L061202, remediation: L061202, minutes: 8, band: 5,
            playerTypeRefs: ["lag"],
            activities: [
              dialogue("act-06-12-03-explain", 1,
                "Versus LAG: trap more, call wider, fancy less.",
                {objectives: ["Widen bluff-catches versus LAG"], playerTypeRefs: ["lag"]}),
              actionAct({
                id: "act-06-12-03-guided", order: 2, stage: "guided",
                prompt: "LAG barrels river. You have second pair good kicker. Action?",
                a11y: "Call.",
                objectives: ["Widen bluff-catches versus LAG"],
                playerTypeRefs: ["lag"],
                choices: [
                  choice("call", "Call", "recommended",
                    "Pressure is wide.", {action: "CALL", reversalRead: "TAG barrel: tighter."}),
                  choice("fold", "Fold always", "questionable",
                    "Too tight.", {action: "FOLD"}),
                  choice("raise", "Bluff-raise light", "clear_mistake",
                    "Fancy less.", {action: "RAISE", amountBb: 45, betterChoiceId: "call"})
                ],
              }),
              actionAct({
                id: "act-06-12-03-scaffolded", order: 3, stage: "scaffolded",
                prompt: "You flop top set vs LAG. Line?",
                a11y: "Trap / let them bluff sometimes.",
                objectives: ["Trap strong hands more"],
                playerTypeRefs: ["lag"],
                choices: [
                  choice("trap", "Check/call some streets to let them barrel", "recommended",
                    "Induce.", {action: "CHECK", reversalRead: "Multiway: bet for protection."}),
                  choice("repel", "Bet-bet-jam every time only", "questionable",
                    "Also fine; trapping is available.")
                ],
              }),
              selectAct({
                id: "act-06-12-03-unguided", order: 4, stage: "unguided",
                prompt: "Inventing triple-barrel bluffs into a LAG?",
                a11y: "Usually bad.",
                objectives: ["Avoid fancy bluffs into pressure"], lifeLoss: true,
                playerTypeRefs: ["lag"],
                choices: [
                  choice("avoid", "Usually avoid — they continue too often", "recommended",
                    "Fancy less."),
                  choice("more", "Bluff more than versus stations", "clear_mistake",
                    "Wrong direction.", {betterChoiceId: "avoid"})
                ],
              }),
              selectAct({
                id: "act-06-12-03-checkpoint", order: 5, stage: "checkpoint",
                prompt: "LAG exploit cites?",
                a11y: "Wide entry and sustained pressure.",
                objectives: ["Widen bluff-catches versus LAG"], lifeLoss: true,
                playerTypeRefs: ["lag"],
                choices: [
                  choice("cite", "Wide entry and sustained pressure", "recommended",
                    "Cite the tendency."),
                  choice("mood", "Mood only", "clear_mistake",
                    "Cite evidence.", {betterChoiceId: "cite"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-06-13-mix", 13, "Mix TAG/LAG with earlier types",
        "Same spot, five models — then section checkpoint.", [
          lesson({
            id: L061301, order: 1,
            title: "Same cards, five type models",
            summary: "Change lines only when the authored type tendency justifies it.",
            objectives: ["Adjust across all five types", "Keep baseline without evidence", "Cite the tendency that changes the line"],
            prereq: L061203, remediation: L061103, minutes: 10, band: 5,
            playerTypeRefs: ["calling_station", "nit", "maniac", "tag", "lag"],
            activities: [
              dialogue("act-06-13-01-explain", 1,
                "Five models. Same cards. Change only with evidence.",
                {objectives: ["Adjust across all five types"]}),
              actionAct({
                id: "act-06-13-01-guided", order: 2, stage: "guided",
                prompt: "River second pair. Versus Calling Station?",
                a11y: "Thin value.",
                objectives: ["Adjust across all five types"],
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("cs", "Bet thin value", "recommended",
                    "Sticky calls.", {action: "BET", amountBb: 8, reversalRead: "TAG: check more."}),
                  choice("cs-bluff", "Huge bluff", "clear_mistake",
                    "They call.", {action: "BET", amountBb: 40, betterChoiceId: "cs"})
                ],
              }),
              actionAct({
                id: "act-06-13-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Same hand. Versus Nit who check-raised. Action?",
                a11y: "Fold.",
                objectives: ["Adjust across all five types"],
                playerTypeRefs: ["nit"],
                choices: [
                  choice("nit", "Fold", "recommended",
                    "Nit heat.", {action: "FOLD", reversalRead: "LAG barrel without raise: call wider."}),
                  choice("nit-call", "Call light", "clear_mistake",
                    "Wrong type.", {action: "CALL", betterChoiceId: "nit"})
                ],
              }),
              actionAct({
                id: "act-06-13-01-unguided", order: 4, stage: "unguided",
                prompt: "Same hand. LAG barrels. Action?",
                a11y: "Call.",
                objectives: ["Adjust across all five types"],
                lifeLoss: true,
                playerTypeRefs: ["lag"],
                choices: [
                  choice("lag", "Call", "recommended",
                    "Wide pressure.", {action: "CALL", reversalRead: "TAG: tighter."}),
                  choice("lag-fold", "Auto-fold", "questionable",
                    "Too tight.", {action: "FOLD"})
                ],
              }),
              classifyAct({
                id: "act-06-13-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Selective entry + disciplined barrels. Label + line vs their raise?",
                a11y: "TAG — respect.",
                objectives: ["Cite the tendency that changes the line"],
                lifeLoss: true,
                playerTypeRefs: ["tag"],
                choices: [
                  choice("tag", "TAG — respect the raise", "recommended",
                    "Cite selective aggression.", {reversalRead: "If they widen and never fold, retag LAG/maniac."}),
                  choice("wrong", "Calling Station — bluff more", "clear_mistake",
                    "Wrong model.", {betterChoiceId: "tag"})
                ],
              }),
            ],
          }),
          lesson({
            id: L061302, order: 2,
            title: "Section 6 checkpoint",
            summary: "Confirm advanced concepts plus TAG/LAG identification.",
            objectives: ["Confirm advantage and caps", "Confirm polar/merged and blockers", "Confirm TAG and LAG"],
            prereq: L061301, remediation: L060101, minutes: 10, band: 5,
            playerTypeRefs: ["tag", "lag"],
            activities: [
              selectAct({
                id: "act-06-13-02-cp-adv", order: 1, stage: "checkpoint",
                prompt: "PFR on dry A-high often has?",
                a11y: "Range advantage.",
                objectives: ["Confirm advantage and caps"], lifeLoss: true,
                choices: [
                  choice("ra", "Range advantage", "recommended",
                    "Yes."),
                  choice("none", "No concept applies", "clear_mistake",
                    "It does.", {betterChoiceId: "ra"})
                ],
              }),
              selectAct({
                id: "act-06-13-02-cp-cap", order: 2, stage: "checkpoint",
                prompt: "Check-back turn often makes river range?",
                a11y: "Capped.",
                objectives: ["Confirm advantage and caps"], lifeLoss: true,
                choices: [
                  choice("cap", "More capped", "recommended",
                    "Yes."),
                  choice("uncap", "More uncapped nuts", "clear_mistake",
                    "No.", {betterChoiceId: "cap"})
                ],
              }),
              selectAct({
                id: "act-06-13-02-cp-polar", order: 3, stage: "checkpoint",
                prompt: "River overbet shape?",
                a11y: "Polar.",
                objectives: ["Confirm polar/merged and blockers"], lifeLoss: true,
                choices: [
                  choice("polar", "Polarized", "recommended",
                    "Yes."),
                  choice("merged", "Always merged thin value", "clear_mistake",
                    "Wrong size story.", {betterChoiceId: "polar"})
                ],
              }),
              classifyAct({
                id: "act-06-13-02-cp-tag", order: 4, stage: "checkpoint",
                prompt: "Tight entry, planned barrels. Label?",
                a11y: "TAG.",
                objectives: ["Confirm TAG and LAG"],
                lifeLoss: true,
                playerTypeRefs: ["tag"],
                choices: [
                  choice("tag", "TAG", "recommended",
                    "Fits.", {reversalRead: "Wide sticky aggression → LAG/maniac."}),
                  choice("lag", "LAG", "clear_mistake",
                    "Entry too tight.", {betterChoiceId: "tag"})
                ],
              }),
              classifyAct({
                id: "act-06-13-02-cp-lag", order: 5, stage: "checkpoint",
                prompt: "Wide entry, sustained pressure, some folds. Label?",
                a11y: "LAG.",
                objectives: ["Confirm TAG and LAG"],
                lifeLoss: true,
                playerTypeRefs: ["lag"],
                choices: [
                  choice("lag", "LAG", "recommended",
                    "Fits.", {reversalRead: "Never folds → maniac."}),
                  choice("nit", "Nit", "clear_mistake",
                    "Opposite.", {betterChoiceId: "lag"})
                ],
              }),
            ],
          }),
        ]),
    ],
  };
}

export const SECTION_SIX_EXIT_LESSON =
  "lesson-06-13-02-section-six-checkpoint";

/** @returns {object} Section 7 — Full-Hand Integration */
export function buildSectionSeven() {
  const prev = SECTION_SIX_EXIT_LESSON;
  const L070101 = "lesson-07-01-01-preflop-to-flop";
  const L070201 = "lesson-07-02-01-flop-to-turn-map";
  const L070301 = "lesson-07-03-01-river-composition";
  const L070401 = "lesson-07-04-01-pot-type-plans";
  const L070501 = "lesson-07-05-01-hu-vs-multiway";
  const L070601 = "lesson-07-06-01-stack-depth-plans";
  const L070701 = "lesson-07-07-01-same-cards-types";
  const L070801 = "lesson-07-08-01-type-board-line";
  const L070901 = "lesson-07-09-01-leak-review-book";
  const L071001 = "lesson-07-10-01-capstone-srp";
  const L071002 = "lesson-07-10-02-capstone-3bet";
  const L071003 = "lesson-07-10-03-capstone-multiway-deep";
  const L071004 = "lesson-07-10-04-capstone-limped";
  const L071005 = "lesson-07-10-05-capstone-4bet";
  const L071101 = "lesson-07-11-01-live-warmup-prep";
  const L071201 = "lesson-07-12-01-five-type-final";

  return {
    id: "sec-07-full-hand-integration",
    order: 7,
    title: "Full-Hand Integration",
    summary: "Build, execute, and review a complete exploitative plan.",
    experienceBand: "full_hand_integration",
    units: [
      unit("unit-07-01-preflop-flop", 1, "Preflop plan to flop interaction",
        "Start with a preflop thesis; update on the flop.", [
          lesson({
            id: L070101, order: 1,
            title: "Carry a preflop plan onto the flop",
            summary: "State why you entered; let the flop confirm or kill the plan.",
            objectives: ["State a preflop thesis", "Update on flop texture", "Abandon dead plans quickly"],
            prereq: prev, remediation: prev, minutes: 8, band: 5,
            activities: [
              dialogue("act-07-01-01-explain", 1,
                "Enter with a reason. Flop confirms or cancels.",
                {objectives: ["State a preflop thesis"]}),
              selectAct({
                id: "act-07-01-01-guided", order: 2, stage: "guided",
                prompt: "You 3-bet AQo for value. Flop 872tt. Update?",
                a11y: "Give up more — plan dead.",
                objectives: ["Update on flop texture"],
                choices: [
                  choice("dead", "Plan is sick — give up more", "recommended",
                    "Value thesis died."),
                  choice("jam", "Still jam every street", "clear_mistake",
                    "Ego.", {betterChoiceId: "dead"})
                ],
              }),
              selectAct({
                id: "act-07-01-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "BTN steal with KTo. Flop KT2r. Update?",
                a11y: "Value continues.",
                objectives: ["Update on flop texture"],
                choices: [
                  choice("value", "Value plan continues", "recommended",
                    "Thesis improved."),
                  choice("fold", "Auto-fold top two", "clear_mistake",
                    "No.", {betterChoiceId: "value"})
                ],
              }),
              selectAct({
                id: "act-07-01-01-unguided", order: 4, stage: "unguided",
                prompt: "Best habit?",
                a11y: "Write the thesis before flop.",
                objectives: ["State a preflop thesis"], lifeLoss: true,
                choices: [
                  choice("thesis", "Name the preflop reason before acting flop", "recommended",
                    "Integration."),
                  choice("vibes", "Wing it every street", "clear_mistake",
                    "No plan.", {betterChoiceId: "thesis"})
                ],
              }),
              selectAct({
                id: "act-07-01-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Dead plan response?",
                a11y: "Abandon quickly.",
                objectives: ["Abandon dead plans quickly"], lifeLoss: true,
                choices: [
                  choice("abandon", "Abandon quickly", "recommended",
                    "Sunk cost dies."),
                  choice("force", "Force the old line", "clear_mistake",
                    "Leak.", {betterChoiceId: "abandon"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-02-turn-map", 2, "Flop action to turn barrel map",
        "Pre-decide turn cards to continue or kill.", [
          lesson({
            id: L070201, order: 1,
            title: "Map turn barrels before you bet flop",
            summary: "List continue cards and give-up cards while choosing the flop bet.",
            objectives: ["List turn continue cards", "List give-up cards", "Bet flop only with a turn map"],
            prereq: L070101, remediation: L070101, minutes: 8, band: 5,
            activities: [
              dialogue("act-07-02-01-explain", 1,
                "Flop bet needs a turn map. Continue or kill.",
                {objectives: ["List turn continue cards"]}),
              selectAct({
                id: "act-07-02-01-guided", order: 2, stage: "guided",
                prompt: "C-betting AK on Q72r. Good turn continue?",
                a11y: "A/K or blanks that keep equity.",
                objectives: ["List turn continue cards"],
                choices: [
                  choice("ok", "Aces, kings, and many blanks with a plan", "recommended",
                    "Map ready."),
                  choice("any", "Any card including four-to-flush always", "questionable",
                    "Some scare cards need give-ups.")
                ],
              }),
              selectAct({
                id: "act-07-02-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "You c-bet a gutshot. Turn bricks and they raise big. Map says?",
                a11y: "Often give up.",
                objectives: ["List give-up cards"],
                choices: [
                  choice("give", "Give up — map included this kill", "recommended",
                    "Pre-planned."),
                  choice("hero", "Hero-call because flop bet exists", "clear_mistake",
                    "Sunk cost.", {betterChoiceId: "give"})
                ],
              }),
              selectAct({
                id: "act-07-02-01-unguided", order: 4, stage: "unguided",
                prompt: "Bet flop with no turn idea?",
                a11y: "Avoid.",
                objectives: ["Bet flop only with a turn map"], lifeLoss: true,
                choices: [
                  choice("avoid", "Avoid — map first", "recommended",
                    "Integration standard."),
                  choice("yolo", "Yolo barrels", "clear_mistake",
                    "No.", {betterChoiceId: "avoid"})
                ],
              }),
              selectAct({
                id: "act-07-02-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Turn map is?",
                a11y: "Continue vs kill list.",
                objectives: ["Bet flop only with a turn map"], lifeLoss: true,
                choices: [
                  choice("list", "A continue/kill list made on the flop", "recommended",
                    "Yes."),
                  choice("later", "Something you invent after you are stuck", "clear_mistake",
                    "Too late.", {betterChoiceId: "list"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-03-river", 3, "River value and bluff composition",
        "Finish hands with a coherent river range story.", [
          lesson({
            id: L070301, order: 1,
            title: "Compose river value and bluffs",
            summary: "Value needs calls; bluffs need folds; blockers help choose.",
            objectives: ["Choose river value candidates", "Choose bluff candidates with blockers", "Check trash without a story"],
            prereq: L070201, remediation: L070201, minutes: 8, band: 5,
            activities: [
              dialogue("act-07-03-01-explain", 1,
                "River: value if they call worse; bluff if they fold better.",
                {objectives: ["Choose river value candidates"]}),
              actionAct({
                id: "act-07-03-01-guided", order: 2, stage: "guided",
                prompt: "Thick value vs station. Size?",
                a11y: "Value bet.",
                objectives: ["Choose river value candidates"],
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("val", "Value bet", "recommended",
                    "They call.", {action: "BET", amountBb: 12}),
                  choice("check", "Check to be fancy", "questionable",
                    "Misses value.")
                ],
              }),
              selectAct({
                id: "act-07-03-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Bluff river with nut flush blocker. Why?",
                a11y: "Blocks their calling flushes.",
                objectives: ["Choose bluff candidates with blockers"],
                choices: [
                  choice("block", "Blocks strong calls", "recommended",
                    "Blocker logic."),
                  choice("ev", "Because a fake EV sheet said +0.02", "clear_mistake",
                    "No fabricated EV.", {betterChoiceId: "block"})
                ],
              }),
              selectAct({
                id: "act-07-03-01-unguided", order: 4, stage: "unguided",
                prompt: "No value, no blockers, no fold equity. River?",
                a11y: "Check.",
                objectives: ["Check trash without a story"], lifeLoss: true,
                choices: [
                  choice("check", "Check", "recommended",
                    "No story."),
                  choice("spew", "Blast off", "clear_mistake",
                    "Leak.", {betterChoiceId: "check"})
                ],
              }),
              selectAct({
                id: "act-07-03-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "River composition rule?",
                a11y: "Value needs calls; bluffs need folds.",
                objectives: ["Choose river value candidates"], lifeLoss: true,
                choices: [
                  choice("rule", "Value needs calls; bluffs need folds", "recommended",
                    "Core."),
                  choice("random", "Bet every river for style", "clear_mistake",
                    "No.", {betterChoiceId: "rule"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-04-pot-types", 4, "Plans by pot type",
        "Limped, SRP, 3-bet, and 4-bet pots.", [
          lesson({
            id: L070401, order: 1,
            title: "Change plans by pot type",
            summary: "Limped pots differ from single-raised and 3-/4-bet pots.",
            objectives: ["Plan limped pots", "Plan single-raised pots", "Plan 3-bet/4-bet pots"],
            prereq: L070301, remediation: L070301, minutes: 9, band: 5,
            activities: [
              dialogue("act-07-04-01-explain", 1,
                "Pot type sets ranges and SPR. Plan accordingly.",
                {objectives: ["Plan single-raised pots"]}),
              selectAct({
                id: "act-07-04-01-guided", order: 2, stage: "guided",
                prompt: "Multiway limped pot. Priority?",
                a11y: "Nut potential / stronger made hands.",
                objectives: ["Plan limped pots"],
                choices: [
                  choice("nuts", "Nut potential and strong made hands", "recommended",
                    "Limped multiway is crowded."),
                  choice("air", "Pure air stabs always", "clear_mistake",
                    "Expensive.", {betterChoiceId: "nuts"})
                ],
              }),
              selectAct({
                id: "act-07-04-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Heads-up SRP IP. Default weapon?",
                a11y: "C-bets with turn maps.",
                objectives: ["Plan single-raised pots"],
                choices: [
                  choice("cb", "C-bets with turn maps", "recommended",
                    "Standard SRP tool."),
                  choice("check", "Never bet", "clear_mistake",
                    "Too passive.", {betterChoiceId: "cb"})
                ],
              }),
              selectAct({
                id: "act-07-04-01-unguided", order: 4, stage: "unguided",
                prompt: "4-bet pot 100bb. Mindset?",
                a11y: "High commitment — tighter.",
                objectives: ["Plan 3-bet/4-bet pots"], lifeLoss: true,
                choices: [
                  choice("commit", "Higher commitment — fewer spewy bluffs", "recommended",
                    "SPR is short."),
                  choice("deep", "Play like 300bb deep", "clear_mistake",
                    "Wrong.", {betterChoiceId: "commit"})
                ],
              }),
              selectAct({
                id: "act-07-04-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Pot type changes?",
                a11y: "Ranges and SPR.",
                objectives: ["Plan 3-bet/4-bet pots"], lifeLoss: true,
                choices: [
                  choice("both", "Ranges and SPR", "recommended",
                    "Yes."),
                  choice("nothing", "Nothing material", "clear_mistake",
                    "It matters.", {betterChoiceId: "both"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-05-hu-mw", 5, "Heads-up versus multiway",
        "Player count changes bluff and value frequency.", [
          lesson({
            id: L070501, order: 1,
            title: "Switch gears between HU and multiway",
            summary: "Bluff less multiway; value thicker; nut potential rises.",
            objectives: ["Bluff less multiway", "Value thicker multiway", "Widen selected HU bluffs"],
            prereq: L070401, remediation: L070401, minutes: 7, band: 5,
            activities: [
              dialogue("act-07-05-01-explain", 1,
                "More players: fewer bluffs, thicker value.",
                {objectives: ["Bluff less multiway"]}),
              selectAct({
                id: "act-07-05-01-guided", order: 2, stage: "guided",
                prompt: "Four-way river. Naked air bluff?",
                a11y: "Usually no.",
                objectives: ["Bluff less multiway"],
                choices: [
                  choice("no", "Usually no", "recommended",
                    "Someone calls."),
                  choice("yes", "Always yes", "clear_mistake",
                    "Leak.", {betterChoiceId: "no"})
                ],
              }),
              selectAct({
                id: "act-07-05-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "HU vs nit BB. Steal frequency vs multiway limped?",
                a11y: "Higher HU.",
                objectives: ["Widen selected HU bluffs"],
                playerTypeRefs: ["nit"],
                choices: [
                  choice("higher", "Higher heads-up versus the nit", "recommended",
                    "Exploit + player count."),
                  choice("same", "Identical always", "clear_mistake",
                    "No.", {betterChoiceId: "higher"})
                ],
              }),
              selectAct({
                id: "act-07-05-01-unguided", order: 4, stage: "unguided",
                prompt: "Multiway top set. Line lean?",
                a11y: "Thicker value / protection.",
                objectives: ["Value thicker multiway"], lifeLoss: true,
                choices: [
                  choice("thick", "Thicker value and protection", "recommended",
                    "Yes."),
                  choice("slow", "Ultra-slow every time", "questionable",
                    "Risk free cards.")
                ],
              }),
              selectAct({
                id: "act-07-05-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Player count is?",
                a11y: "A first-class input.",
                objectives: ["Bluff less multiway"], lifeLoss: true,
                choices: [
                  choice("input", "A first-class planning input", "recommended",
                    "Yes."),
                  choice("ignore", "Noise", "clear_mistake",
                    "No.", {betterChoiceId: "input"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-06-stacks", 6, "Shorter and deep effective stacks",
        "Rewrite the plan when effective stacks change.", [
          lesson({
            id: L070601, order: 1,
            title: "Rewrite plans when stacks change",
            summary: "Short stacks commit earlier; deep stacks delay and use implied odds.",
            objectives: ["Commit earlier short", "Use implied odds deep", "Recalculate effective stacks each hand"],
            prereq: L070501, remediation: L070501, minutes: 7, band: 5,
            activities: [
              dialogue("act-07-06-01-explain", 1,
                "Effective stack rewrites the plan every hand.",
                {objectives: ["Recalculate effective stacks each hand"]}),
              selectAct({
                id: "act-07-06-01-guided", order: 2, stage: "guided",
                prompt: "35bb effective. Top pair strong kicker vs raise. Lean?",
                a11y: "Closer to committed.",
                objectives: ["Commit earlier short"],
                choices: [
                  choice("commit", "Closer to stacking — SPR is low", "recommended",
                    "Short stack math."),
                  choice("deep", "Play as 250bb deep", "clear_mistake",
                    "Wrong.", {betterChoiceId: "commit"})
                ],
              }),
              selectAct({
                id: "act-07-06-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "250bb. Set-mine 55?",
                a11y: "More attractive.",
                objectives: ["Use implied odds deep"],
                choices: [
                  choice("yes", "More attractive with depth", "recommended",
                    "Implied odds."),
                  choice("no", "Never set-mine deep", "clear_mistake",
                    "Opposite.", {betterChoiceId: "yes"})
                ],
              }),
              selectAct({
                id: "act-07-06-01-unguided", order: 4, stage: "unguided",
                prompt: "Hero 200bb, villain 40bb. Effective?",
                a11y: "40bb.",
                objectives: ["Recalculate effective stacks each hand"], lifeLoss: true,
                choices: [
                  choice("40", "40bb", "recommended",
                    "Shorter stack caps."),
                  choice("200", "200bb", "clear_mistake",
                    "Cannot play more than villain has.", {betterChoiceId: "40"})
                ],
              }),
              selectAct({
                id: "act-07-06-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Stack depth is?",
                a11y: "Plan input every hand.",
                objectives: ["Recalculate effective stacks each hand"], lifeLoss: true,
                choices: [
                  choice("every", "Recalculated every hand", "recommended",
                    "Yes."),
                  choice("once", "Set once per lifetime", "clear_mistake",
                    "No.", {betterChoiceId: "every"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-07-same-cards", 7, "Same cards, different types",
        "Full transfer across the five models.", [
          lesson({
            id: L070701, order: 1,
            title: "Replay the same hand versus each type",
            summary: "Recommendations diverge only when the authored tendency justifies it.",
            objectives: ["Change lines by type with citations", "Keep identical lines when evidence is absent", "Practice all five types"],
            prereq: L070601, remediation: "lesson-06-13-01-mix-five-types", minutes: 10, band: 5,
            playerTypeRefs: ["calling_station", "nit", "maniac", "tag", "lag"],
            activities: [
              dialogue("act-07-07-01-explain", 1,
                "Same cards. Five models. Cite the tendency.",
                {objectives: ["Change lines by type with citations"]}),
              actionAct({
                id: "act-07-07-01-guided", order: 2, stage: "guided",
                prompt: "Flop top pair. Station check. Action?",
                a11y: "Bet value.",
                objectives: ["Practice all five types"],
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("bet", "Bet for value", "recommended",
                    "They call.", {action: "BET", amountBb: 8, reversalRead: "Nit: smaller or check."}),
                  choice("check", "Check always", "questionable",
                    "Misses value.")
                ],
              }),
              actionAct({
                id: "act-07-07-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Same top pair. TAG check-raises. Action?",
                a11y: "Fold/more careful.",
                objectives: ["Practice all five types"],
                playerTypeRefs: ["tag"],
                choices: [
                  choice("fold", "Fold more often", "recommended",
                    "TAG heat.", {action: "FOLD", reversalRead: "Maniac raise: continue wider."}),
                  choice("bluff", "Rebluff light", "clear_mistake",
                    "Bad.", {action: "RAISE", amountBb: 25, betterChoiceId: "fold"})
                ],
              }),
              actionAct({
                id: "act-07-07-01-unguided", order: 4, stage: "unguided",
                prompt: "Same top pair. LAG barrels turn. Action?",
                a11y: "Call.",
                objectives: ["Practice all five types"],
                lifeLoss: true,
                playerTypeRefs: ["lag"],
                choices: [
                  choice("call", "Call", "recommended",
                    "Wide pressure.", {action: "CALL", reversalRead: "Nit barrel: fold more."}),
                  choice("fold", "Auto-fold", "questionable",
                    "Too tight.", {action: "FOLD"})
                ],
              }),
              selectAct({
                id: "act-07-07-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "No type evidence yet. Default?",
                a11y: "Baseline strategy.",
                objectives: ["Keep identical lines when evidence is absent"], lifeLoss: true,
                choices: [
                  choice("base", "Baseline strategy", "recommended",
                    "Exploit needs evidence."),
                  choice("guess", "Guess a type and overfit", "clear_mistake",
                    "No.", {betterChoiceId: "base"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-08-checkpoints", 8, "Type × board × line × sizing",
        "Integrated checkpoints.", [
          lesson({
            id: L070801, order: 1,
            title: "Integrate type, board, line, and sizing",
            summary: "One decision uses all four inputs together.",
            objectives: ["Combine type with board texture", "Combine line history with sizing", "Produce one coherent action"],
            prereq: L070701, remediation: L070701, minutes: 9, band: 5,
            playerTypeRefs: ["maniac", "nit", "tag"],
            activities: [
              dialogue("act-07-08-01-explain", 1,
                "Type × board × line × size. One answer.",
                {objectives: ["Produce one coherent action"]}),
              actionAct({
                id: "act-07-08-01-guided", order: 2, stage: "guided",
                prompt: "Wet board. Maniac overbets turn. Second pair. Action?",
                a11y: "Call.",
                objectives: ["Combine type with board texture"],
                playerTypeRefs: ["maniac"],
                choices: [
                  choice("call", "Call", "recommended",
                    "Wide overbets + wet board still favors catching versus maniac.", {action: "CALL", reversalRead: "Nit overbet: fold."}),
                  choice("fold", "Fold", "questionable",
                    "Reasonable vs unknowns; maniac widens calls.", {action: "FOLD"})
                ],
              }),
              actionAct({
                id: "act-07-08-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Dry board. Nit tiny turn bet. Air. Action?",
                a11y: "Raise/bluff more available.",
                objectives: ["Combine line history with sizing"],
                playerTypeRefs: ["nit"],
                choices: [
                  choice("raise", "Raise as a bluff candidate", "recommended",
                    "Tiny nit bets are weak on dry boards.", {action: "RAISE", amountBb: 14, reversalRead: "TAG large bet: fold air."}),
                  choice("call", "Call air", "clear_mistake",
                    "No showdown.", {action: "CALL", betterChoiceId: "raise"})
                ],
              }),
              actionAct({
                id: "act-07-08-01-unguided", order: 4, stage: "unguided",
                prompt: "TAG pots river after strong line. Second pair. Action?",
                a11y: "Fold.",
                objectives: ["Produce one coherent action"],
                lifeLoss: true,
                playerTypeRefs: ["tag"],
                choices: [
                  choice("fold", "Fold", "recommended",
                    "Strong TAG line.", {action: "FOLD", reversalRead: "LAG: call wider."}),
                  choice("hero", "Hero-call for storytime", "clear_mistake",
                    "Ego.", {action: "CALL", betterChoiceId: "fold"})
                ],
              }),
              selectAct({
                id: "act-07-08-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Integrated decision uses?",
                a11y: "All four inputs.",
                objectives: ["Produce one coherent action"], lifeLoss: true,
                choices: [
                  choice("four", "Type, board, line, and sizing together", "recommended",
                    "Yes."),
                  choice("one", "Only hole card beauty", "clear_mistake",
                    "Incomplete.", {betterChoiceId: "four"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-09-leaks", 9, "Personal leak review and default book",
        "Build your default strategy book.", [
          lesson({
            id: L070901, order: 1,
            title: "Write your default strategy book",
            summary: "List personal leaks and default lines for common live spots.",
            objectives: ["Name personal leaks", "Write default lines for common spots", "Schedule review habits"],
            prereq: L070801, remediation: L070801, minutes: 8, band: 5,
            activities: [
              dialogue("act-07-09-01-explain", 1,
                "Defaults beat vibes. Write the book; review leaks.",
                {objectives: ["Write default lines for common spots"]}),
              selectAct({
                id: "act-07-09-01-guided", order: 2, stage: "guided",
                prompt: "Best leak note?",
                a11y: "Specific and actionable.",
                objectives: ["Name personal leaks"],
                choices: [
                  choice("spec", "I overcall river vs unknowns — fold more second pair", "recommended",
                    "Actionable."),
                  choice("vague", "I am bad", "clear_mistake",
                    "Not useful.", {betterChoiceId: "spec"})
                ],
              }),
              selectAct({
                id: "act-07-09-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Default BTN vs unknown BB open?",
                a11y: "A written range family.",
                objectives: ["Write default lines for common spots"],
                choices: [
                  choice("book", "A written range family from your book", "recommended",
                    "Defaults first."),
                  choice("mood", "Whatever mood says", "clear_mistake",
                    "No.", {betterChoiceId: "book"})
                ],
              }),
              selectAct({
                id: "act-07-09-01-unguided", order: 4, stage: "unguided",
                prompt: "When to review the book?",
                a11y: "After sessions / on a schedule.",
                objectives: ["Schedule review habits"], lifeLoss: true,
                choices: [
                  choice("sched", "After sessions on a schedule", "recommended",
                    "Habit."),
                  choice("never", "Never — memory is enough", "clear_mistake",
                    "Leaks return.", {betterChoiceId: "sched"})
                ],
              }),
              selectAct({
                id: "act-07-09-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Default book purpose?",
                a11y: "Baseline before exploits.",
                objectives: ["Write default lines for common spots"], lifeLoss: true,
                choices: [
                  choice("base", "Baseline before exploits", "recommended",
                    "Yes."),
                  choice("replace", "Replace all thinking forever", "clear_mistake",
                    "Still update.", {betterChoiceId: "base"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-10-capstones", 10, "Capstone authored hands",
        "No hints. Full-hand transfer across pot types and depths.", [
          lesson({
            id: L071001, order: 1,
            title: "Capstone: single-raised pot",
            summary: "Play a full SRP without hints.",
            objectives: ["Execute a full SRP plan", "Update streets without hints", "Finish river coherently"],
            prereq: L070901, remediation: L070401, minutes: 12, band: 5,
            activities: [
              dialogue("act-07-10-01-explain", 1,
                "Capstone SRP. No hints. Trust your map.",
                {objectives: ["Execute a full SRP plan"]}),
              multiStepAct({
                id: "act-07-10-01-hand", order: 2, stage: "unguided",
                a11y: "BTN open, BB call. Play three streets.",
                objectives: ["Execute a full SRP plan", "Update streets without hints", "Finish river coherently"],
                lifeLoss: true,
                steps: [
                  {
                    id: "step-flop", street: "flop",
                    prompt: "BTN, SRP, board K72r, you have AQ. Action?",
                    accessibilityText: "C-bet ace-high on king-high dry.",
                    choices: [
                      choice("cb", "C-bet", "recommended",
                        "Range advantage; turn map ready.", {action: "BET", amountBb: 6}),
                      choice("check", "Check", "questionable",
                        "Misses pressure.", {action: "CHECK"}),
                      choice("jam", "Jam 150bb", "clear_mistake",
                        "Too much.", {action: "RAISE", amountBb: 150, betterChoiceId: "cb"}),
                    ],
                  },
                  {
                    id: "step-turn", street: "turn",
                    prompt: "Called. Turn 2d. Action?",
                    accessibilityText: "Many continue with delayed pressure or give-up.",
                    choices: [
                      choice("barrel", "Barrel many blanks", "recommended",
                        "Map continue.", {action: "BET", amountBb: 14}),
                      choice("check-t", "Check/give-up sometimes", "strong",
                        "Also fine with a plan.", {action: "CHECK"}),
                      choice("min", "Bet 1bb", "clear_mistake",
                        "Not a story.", {action: "BET", amountBb: 1, betterChoiceId: "barrel"}),
                    ],
                  },
                  {
                    id: "step-river", street: "river",
                    prompt: "Called again. River 9c. Ace-high. Action?",
                    accessibilityText: "Give up without blockers sometimes; bluff only with a story.",
                    choices: [
                      choice("check-r", "Check / give up", "recommended",
                        "No strong story.", {action: "CHECK"}),
                      choice("bluff", "Bluff large with no blockers", "questionable",
                        "Needs a better blocker story.", {action: "BET", amountBb: 40}),
                      choice("tiny", "Bet 1bb", "clear_mistake",
                        "Not polar language.", {action: "BET", amountBb: 1, betterChoiceId: "check-r"}),
                    ],
                  },
                ],
              }),
            ],
          }),
          lesson({
            id: L071002, order: 2,
            title: "Capstone: 3-bet pot",
            summary: "Play a 3-bet pot across streets without hints.",
            objectives: ["Plan a 3-bet pot by SPR", "Continue or kill on turn", "Close river without ego"],
            prereq: L071001, remediation: "lesson-06-09-01-threebet-fourbet", minutes: 12, band: 5,
            playerTypeRefs: ["tag"],
            activities: [
              dialogue("act-07-10-02-explain", 1,
                "Capstone 3-bet. Short prompts. No hints.",
                {objectives: ["Plan a 3-bet pot by SPR"], playerTypeRefs: ["tag"]}),
              multiStepAct({
                id: "act-07-10-02-hand", order: 2, stage: "unguided",
                a11y: "You 3-bet TAG open with AQ; 120bb deep.",
                objectives: ["Plan a 3-bet pot by SPR", "Continue or kill on turn", "Close river without ego"],
                lifeLoss: true,
                playerTypeRefs: ["tag"],
                steps: [
                  {
                    id: "step-3b-flop", street: "flop",
                    prompt: "Flop Q83tt. Action?",
                    accessibilityText: "Value c-bet top pair.",
                    choices: [
                      choice("bet", "C-bet value", "recommended",
                        "Top pair in 3-bet pot.", {action: "BET", amountBb: 10}),
                      choice("check", "Check", "questionable",
                        "Misses value vs TAG continuum.", {action: "CHECK"}),
                    ],
                  },
                  {
                    id: "step-3b-turn", street: "turn",
                    prompt: "Called. Turn 2d. Action?",
                    accessibilityText: "Continue value.",
                    choices: [
                      choice("barrel", "Continue value", "recommended",
                        "Still best often.", {action: "BET", amountBb: 22}),
                      choice("check-t", "Check", "questionable",
                        "Allows free cards / thinner.", {action: "CHECK"}),
                    ],
                  },
                  {
                    id: "step-3b-river", street: "river",
                    prompt: "TAG check-raises huge. Action?",
                    accessibilityText: "Respect TAG — fold top pair often.",
                    choices: [
                      choice("fold", "Fold", "recommended",
                        "TAG heat — difficult fold.", {action: "FOLD", reversalRead: "Maniac raise: call wider."}),
                      choice("call", "Call", "questionable",
                        "Needs a wider read.", {action: "CALL"}),
                      choice("jam", "Rejam for ego", "clear_mistake",
                        "Ego.", {action: "RAISE", amountBb: 90, betterChoiceId: "fold"}),
                    ],
                  },
                ],
              }),
            ],
          }),
          lesson({
            id: L071003, order: 3,
            title: "Capstone: multiway deep",
            summary: "Deep multiway pot without hints.",
            objectives: ["Prefer nut potential multiway", "Use deep implied odds correctly", "Avoid bluffing crowds"],
            prereq: L071002, remediation: "lesson-05-01-01-multiway-ranges", minutes: 12, band: 5,
            activities: [
              dialogue("act-07-10-03-explain", 1,
                "Capstone multiway deep. No hints.",
                {objectives: ["Prefer nut potential multiway"]}),
              multiStepAct({
                id: "act-07-10-03-hand", order: 2, stage: "unguided",
                a11y: "Four-way, 200bb, you hold AhQh.",
                objectives: ["Prefer nut potential multiway", "Use deep implied odds correctly", "Avoid bluffing crowds"],
                lifeLoss: true,
                steps: [
                  {
                    id: "step-mw-flop", street: "flop",
                    prompt: "Flop Jh 8h 2c. Bet into you. Action?",
                    accessibilityText: "Continue with nut flush draw deep.",
                    choices: [
                      choice("call", "Call", "recommended",
                        "Nutted draw + depth.", {action: "CALL"}),
                      choice("fold", "Fold", "clear_mistake",
                        "Too strong to fold small.", {action: "FOLD", betterChoiceId: "call"}),
                      choice("bluffjam", "Bluff-jam off", "questionable",
                        "Sometimes; calling realizes well deep.", {action: "RAISE", amountBb: 80}),
                    ],
                  },
                  {
                    id: "step-mw-turn", street: "turn",
                    prompt: "Turn 3d. Checked to you. Action?",
                    accessibilityText: "Can bet for fold equity + equity.",
                    choices: [
                      choice("bet", "Bet semi-bluff", "recommended",
                        "Still nutted equity.", {action: "BET", amountBb: 18}),
                      choice("check", "Check", "strong",
                        "Also fine to realize.", {action: "CHECK"}),
                    ],
                  },
                  {
                    id: "step-mw-river", street: "river",
                    prompt: "River 9c misses. Two players behind. Action?",
                    accessibilityText: "Do not bluff the crowd light.",
                    choices: [
                      choice("check", "Check / give up", "recommended",
                        "Multiway missed draw — no crowd bluff.", {action: "CHECK"}),
                      choice("bluff", "Blast bluff both", "clear_mistake",
                        "Crowds call.", {action: "BET", amountBb: 60, betterChoiceId: "check"}),
                    ],
                  },
                ],
              }),
            ],
          }),
          lesson({
            id: L071004, order: 4,
            title: "Capstone: limped pot",
            summary: "Play a multiway limped pot without hints.",
            objectives: ["Prefer nut potential limped multiway", "Avoid light multiway bluffs", "Use depth for draws carefully"],
            prereq: L071003, remediation: L070401, minutes: 12, band: 5,
            activities: [
              dialogue("act-07-10-04-explain", 1,
                "Capstone limped pot. Crowded. No hints.",
                {objectives: ["Prefer nut potential limped multiway"]}),
              multiStepAct({
                id: "act-07-10-04-hand", order: 2, stage: "unguided",
                a11y: "Four-way limp, 150bb, you hold AhKh on BTN.",
                objectives: ["Prefer nut potential limped multiway", "Avoid light multiway bluffs", "Use depth for draws carefully"],
                lifeLoss: true,
                steps: [
                  {
                    id: "step-limp-flop", street: "flop",
                    prompt: "Flop Kd 9c 4h. Checked to you. Action?",
                    accessibilityText: "Value bet top pair strong kicker multiway.",
                    choices: [
                      choice("bet", "Bet value", "recommended",
                        "Strong made hand; still multiway.", {action: "BET", amountBb: 8}),
                      choice("check", "Check forever", "questionable",
                        "Misses value.", {action: "CHECK"}),
                      choice("jam", "Jam 150bb", "clear_mistake",
                        "Overplay.", {action: "RAISE", amountBb: 150, betterChoiceId: "bet"}),
                    ],
                  },
                  {
                    id: "step-limp-turn", street: "turn",
                    prompt: "Called by two. Turn 2s. Action?",
                    accessibilityText: "Continue value or slow down with a plan.",
                    choices: [
                      choice("barrel", "Continue value", "recommended",
                        "Still best often multiway.", {action: "BET", amountBb: 18}),
                      choice("check-t", "Check", "questionable",
                        "Allows free cards / thinner.", {action: "CHECK"}),
                    ],
                  },
                  {
                    id: "step-limp-river", street: "river",
                    prompt: "Both call. River 8d. Action?",
                    accessibilityText: "Thin value carefully; do not invent a bluff.",
                    choices: [
                      choice("value", "Bet thin value", "recommended",
                        "Still often ahead; size down.", {action: "BET", amountBb: 22}),
                      choice("check-r", "Check", "strong",
                        "Also fine versus sticky crowds.", {action: "CHECK"}),
                      choice("bluff", "Blast as a pure bluff", "clear_mistake",
                        "Crowds call limped pots.", {action: "BET", amountBb: 80, betterChoiceId: "value"}),
                    ],
                  },
                ],
              }),
            ],
          }),
          lesson({
            id: L071005, order: 5,
            title: "Capstone: 4-bet pot",
            summary: "Play a 4-bet pot across streets without hints.",
            objectives: ["Respect short SPR commitment", "Avoid ego bluffs in 4-bet pots", "Close river without hero calls"],
            prereq: L071004, remediation: "lesson-06-09-01-threebet-fourbet", minutes: 12, band: 5,
            activities: [
              dialogue("act-07-10-05-explain", 1,
                "Capstone 4-bet. Short SPR. No hints.",
                {objectives: ["Respect short SPR commitment"]}),
              multiStepAct({
                id: "act-07-10-05-hand", order: 2, stage: "unguided",
                a11y: "100bb 4-bet pot; you hold KK after 4-betting.",
                objectives: ["Respect short SPR commitment", "Avoid ego bluffs in 4-bet pots", "Close river without hero calls"],
                lifeLoss: true,
                steps: [
                  {
                    id: "step-4b-flop", street: "flop",
                    prompt: "Flop Q83r. Action?",
                    accessibilityText: "C-bet for value/protection in a committed pot.",
                    choices: [
                      choice("bet", "C-bet", "recommended",
                        "Overpair; SPR is short.", {action: "BET", amountBb: 12}),
                      choice("check", "Check", "questionable",
                        "Gives free equity.", {action: "CHECK"}),
                      choice("min", "Bet 1bb", "clear_mistake",
                        "Not a 4-bet-pot size.", {action: "BET", amountBb: 1, betterChoiceId: "bet"}),
                    ],
                  },
                  {
                    id: "step-4b-turn", street: "turn",
                    prompt: "Called. Turn 2d. Action?",
                    accessibilityText: "Often continue or stack off with overpair.",
                    choices: [
                      choice("barrel", "Continue / commit", "recommended",
                        "Overpair in a short-SPR pot.", {action: "BET", amountBb: 28}),
                      choice("check-t", "Check/give up", "questionable",
                        "Too weak with KK here often.", {action: "CHECK"}),
                    ],
                  },
                  {
                    id: "step-4b-river", street: "river",
                    prompt: "Called. River Ad. Opponent jams. Action?",
                    accessibilityText: "Ace is a bad card — fold more without a read.",
                    choices: [
                      choice("fold", "Fold", "recommended",
                        "Ace caps many value lines; avoid ego hero call.", {action: "FOLD", reversalRead: "Known maniac: call wider."}),
                      choice("call", "Hero call", "questionable",
                        "Needs a wide spew read.", {action: "CALL"}),
                      choice("jam", "Rejam for style", "clear_mistake",
                        "Already facing a jam.", {action: "RAISE", amountBb: 60, betterChoiceId: "fold"}),
                    ],
                  },
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-11-warmup", 11, "Live Training warm-up prep",
        "Prepare for a coached warm-up hand in Live Training.", [
          lesson({
            id: L071101, order: 1,
            title: "Prep a coached Live warm-up hand",
            summary: "Carry course defaults into Live Training with a short plan checklist.",
            objectives: ["List warm-up checklist items", "Carry defaults into Live", "Stay inside live cash NLH scope"],
            prereq: L071005, remediation: L070901, minutes: 8, band: 5,
            activities: [
              dialogue("act-07-11-01-explain", 1,
                "Live warm-up: short checklist, then play. Plan 10 wires the bridge.",
                {objectives: ["List warm-up checklist items"]}),
              selectAct({
                id: "act-07-11-01-guided", order: 2, stage: "guided",
                prompt: "Warm-up checklist must include?",
                a11y: "Effective stacks, pot type, type notes, street map.",
                objectives: ["List warm-up checklist items"],
                choices: [
                  choice("list", "Stacks, pot type, type notes, street map", "recommended",
                    "Enough to start."),
                  choice("hud", "Ignore stacks and invent a random plan", "clear_mistake",
                    "Warm-up needs the checklist.", {betterChoiceId: "list"})
                ],
              }),
              selectAct({
                id: "act-07-11-01-scaffolded", order: 3, stage: "scaffolded",
                prompt: "Carry into Live?",
                a11y: "Course defaults + exploit notes.",
                objectives: ["Carry defaults into Live"],
                choices: [
                  choice("defaults", "Course defaults plus typed exploits", "recommended",
                    "Transfer."),
                  choice("blank", "Forget the course", "clear_mistake",
                    "No.", {betterChoiceId: "defaults"})
                ],
              }),
              selectAct({
                id: "act-07-11-01-unguided", order: 4, stage: "unguided",
                prompt: "Scope reminder?",
                a11y: "Live cash NLH only.",
                objectives: ["Stay inside live cash NLH scope"], lifeLoss: true,
                choices: [
                  choice("scope", "Live cash NLH only", "recommended",
                    "Course invariant."),
                  choice("tourney", "Study other betting games instead", "clear_mistake",
                    "Out of scope.", {betterChoiceId: "scope"})
                ],
              }),
              selectAct({
                id: "act-07-11-01-checkpoint", order: 5, stage: "checkpoint",
                prompt: "Warm-up goal?",
                a11y: "Load the plan, then execute one hand.",
                objectives: ["Carry defaults into Live"], lifeLoss: true,
                choices: [
                  choice("one", "Load checklist and execute one coached hand", "recommended",
                    "Ready for Plan 10 bridge."),
                  choice("grind", "Ignore checklist and mash buttons", "clear_mistake",
                    "No.", {betterChoiceId: "one"})
                ],
              }),
            ],
          }),
        ]),
      unit("unit-07-12-final", 12, "Five-type final assessment",
        "Identify, adjust, handle uncertainty, and retire bad labels.", [
          lesson({
            id: L071201, order: 1,
            title: "Final: all five player types",
            summary: "Identify from behavior, choose adjustments, manage uncertainty, abandon bad labels.",
            objectives: ["Identify all five types from behavior", "Select adjustments with citations", "Retire labels when evidence flips"],
            prereq: L071101, remediation: "lesson-06-13-01-mix-five-types", minutes: 14, band: 5,
            playerTypeRefs: ["calling_station", "nit", "maniac", "tag", "lag"],
            activities: [
              classifyAct({
                id: "act-07-12-01-cs", order: 1, stage: "checkpoint",
                prompt: "Sticky calls three streets. Label + exploit?",
                a11y: "Calling Station — value more.",
                objectives: ["Identify all five types from behavior"],
                lifeLoss: true,
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("cs", "Calling Station — thicker value, fewer bluffs", "recommended",
                    "Cite low folding.", {reversalRead: "If they fold more, reopen bluffs."}),
                  choice("cs-wrong", "Calling Station — bluff more", "clear_mistake",
                    "Opposite.", {betterChoiceId: "cs"})
                ],
              }),
              classifyAct({
                id: "act-07-12-01-nit", order: 2, stage: "checkpoint",
                prompt: "Tiny range, huge check-raise. Label + line?",
                a11y: "Nit — respect.",
                objectives: ["Identify all five types from behavior"],
                lifeLoss: true,
                playerTypeRefs: ["nit"],
                choices: [
                  choice("nit", "Nit — respect heat; steal elsewhere", "recommended",
                    "Cite narrow entry.", {reversalRead: "Light check-raises reduce respect."}),
                  choice("nit-wrong", "Nit — call down light always", "clear_mistake",
                    "Wrong.", {betterChoiceId: "nit"})
                ],
              }),
              classifyAct({
                id: "act-07-12-01-maniac", order: 3, stage: "checkpoint",
                prompt: "Endless barrels, never folds. Label + line?",
                a11y: "Maniac — call wider.",
                objectives: ["Select adjustments with citations"],
                lifeLoss: true,
                playerTypeRefs: ["maniac"],
                choices: [
                  choice("man", "Maniac — widen catches; avoid ego raises", "recommended",
                    "Cite over-aggression.", {reversalRead: "If barrels tighten, tighten calls."}),
                  choice("man-wrong", "Maniac — fold all one-pair forever", "clear_mistake",
                    "Too tight.", {betterChoiceId: "man"})
                ],
              }),
              classifyAct({
                id: "act-07-12-01-tag", order: 4, stage: "checkpoint",
                prompt: "Selective entry, disciplined barrels. Label + vs raise?",
                a11y: "TAG — respect.",
                objectives: ["Select adjustments with citations"],
                lifeLoss: true,
                playerTypeRefs: ["tag"],
                choices: [
                  choice("tag", "TAG — respect raises; steal less than vs nits", "recommended",
                    "Cite selective aggression.", {reversalRead: "Entry widens → reconsider LAG."}),
                  choice("tag-wrong", "TAG — bluff their check-raises light", "clear_mistake",
                    "Bad.", {betterChoiceId: "tag"})
                ],
              }),
              classifyAct({
                id: "act-07-12-01-lag", order: 5, stage: "checkpoint",
                prompt: "Wide entry, sustained pressure, some folds. Label + line?",
                a11y: "LAG — trap/call wider.",
                objectives: ["Select adjustments with citations"],
                lifeLoss: true,
                playerTypeRefs: ["lag"],
                choices: [
                  choice("lag", "LAG — trap more; call wider; fancy less", "recommended",
                    "Cite wide pressure.", {reversalRead: "Never folds → maniac."}),
                  choice("lag-wrong", "LAG — bluff into them more", "clear_mistake",
                    "Wrong.", {betterChoiceId: "lag"})
                ],
              }),
              selectAct({
                id: "act-07-12-01-uncertain", order: 6, stage: "checkpoint",
                prompt: "Three mixed samples only. Confidence?",
                a11y: "Low — keep baseline heavier.",
                objectives: ["Retire labels when evidence flips"], lifeLoss: true,
                choices: [
                  choice("low", "Low — lean baseline until samples grow", "recommended",
                    "Uncertainty is honest."),
                  choice("max", "Maximum certainty on a label", "clear_mistake",
                    "Overfit.", {betterChoiceId: "low"})
                ],
              }),
              selectAct({
                id: "act-07-12-01-retire", order: 7, stage: "checkpoint",
                prompt: "Old Calling Station now folds rivers and 3-bets light. Do?",
                a11y: "Retire/update the label.",
                objectives: ["Retire labels when evidence flips"], lifeLoss: true,
                playerTypeRefs: ["calling_station"],
                choices: [
                  choice("retire", "Retire or update the model", "recommended",
                    "Evidence flipped.", {reversalRead: "Sticky calls return → model can return."}),
                  choice("freeze", "Keep the old label forever", "clear_mistake",
                    "Stale.", {betterChoiceId: "retire"})
                ],
              }),
            ],
          }),
        ]),
    ],
  };
}

export const SECTION_SEVEN_EXIT_LESSON =
  "lesson-07-12-01-five-type-final";
