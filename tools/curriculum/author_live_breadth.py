#!/usr/bin/env python3
"""Author Section 8 static exercises and sync generated catalogs.

Depth and stakes questions use stack sizes the table can already represent.
Straddles, bomb pots, run-it-twice, insurance, and time rake stay conceptual:
this trainer does not deal those mechanics yet.
"""

from __future__ import annotations

import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTENT = ROOT / "content/curriculum/v1"
EX_DIR = CONTENT / "exercises"
CATALOG = CONTENT / "catalog.json"
ASSET_CATALOG = ROOT / "assets/curriculum/catalog.json"
ASSET_EX = ROOT / "assets/curriculum/exercises"
FN_CATALOG = ROOT / "functions/src/generated/curriculum_catalog.json"
FN_EX = ROOT / "functions/src/generated/exercises"
BANK = ROOT / "functions/src/generated/exercise_bank.json"

Q = tuple[str, int, list[str], str]
LESSONS: dict[str, tuple[str, list[Q]]] = {}

OBJECTIVE_TAGS: dict[str, dict[str, list[str]]] = {
    "obj-short-stack": {"stack": ["20-50bb"]},
    "obj-mid-stack": {"stack": ["50-100bb"]},
    "obj-deep-stack": {"stack": ["100-200bb", "200-500bb"]},
    "obj-stakes-econ": {"topic": ["rake", "stakes"]},
    "obj-local-variants": {"topic": ["straddle", "bomb-pot", "run-it-twice"]},
}


def add(lesson_id: str, title: str, questions: list[Q]) -> None:
    LESSONS[lesson_id] = (title, questions)


def _q(prompt: str, correct: str, wrong: list[str], why: str) -> Q:
    if len(wrong) != 3:
        raise SystemExit(f"need 3 wrong answers: {prompt}")
    return (prompt, 0, [correct, *wrong], why)


add(
    "lesson-08-01-01-short-stack-20-50bb-play",
    "Short-stack 20-50BB play",
    [
        _q(
            "At 20–30 big blinds, suited connectors are worth less because…",
            "You cannot win a deep implied-odds pot when you flop a monster.",
            ["Short stacks make every draw the nuts", "Position disappears", "You are forced to limp"],
            "Implied odds need chips behind. A short stack is paid off less when the draw gets there.",
        ),
        _q(
            "Hands that are ahead right now, such as offsuit broadways and pairs, …",
            "Go up in value. You are often committed if you continue.",
            ["Become unplayable", "Should all be limped", "Are folds from the button"],
            "Low stacks reward current equity, not speculative flop potential.",
        ),
        _q(
            "Under about 20 big blinds, a small open you hate folding is often replaced by…",
            "A shove or a fold.",
            ["A limp", "A 100bb cold-call tree", "Checking your option before cards are dealt"],
            "There is no room for a raise and a fold. Decide for the stack before you put chips in.",
        ),
        _q(
            "Set-mining 22 for 20 big blinds is…",
            "A mistake. The payoff is too small when you flop the set.",
            ["The best use of a short stack", "Required from every seat", "Better than jamming aces"],
            "You need a deep stack behind the raiser to make small pairs profitable as calls.",
        ),
    ],
)

add(
    "lesson-08-01-02-decide-at-20-50bb",
    "Decide at 20-50BB",
    [
        _q(
            "Effective stacks are 22bb. Folded to the button, you have AJo. A fitting plan is…",
            "Raise all-in, or raise an amount you are willing to call.",
            ["Limp and fold to a jam", "Use a 200bb call-and-see-five-streets plan", "Fold. AJo is an under-the-gun hand only"],
            "At this depth the button does not have a long postflop tree.",
        ),
        _q(
            "Effective stacks are 40bb. You have 76s under the gun. Best default?",
            "Fold. You are early, short, and the hand needs depth and position.",
            ["Open all-in", "Limp and call any jam", "Open and stack off preflop"],
            "Speculative hands from early position get worse as stacks shrink.",
        ),
        _q(
            "You have top pair, good kicker, on a dry flop, and the pot already holds a third of your 30bb stack. Best default?",
            "Commit. There is not enough stack left to find a fold with this hand.",
            ["Fold top pair because the stack is short", "Check-fold", "Open-limp the flop"],
            "Low stack-to-pot ratio means good one pair is a get-in hand on a safe board.",
        ),
        _q(
            "A short stack jams 20bb over your open and you cover them with 200bb. Your extra chips…",
            "Do not matter. You can only win the 20bb.",
            ["Must be risked as well", "Make aces a fold", "Change the jam into a 200bb decision"],
            "Effective stack is the smaller stack in the pot.",
        ),
    ],
)

add(
    "lesson-08-01-03-20-50bb-check",
    "20-50BB check",
    [
        _q(
            "Which hand gains when stacks drop from 100bb to 25bb?",
            "AQo. It is ahead now and does not need a deep flop.",
            ["76s from under the gun", "22 as a set-mine against a 3-bet", "A hand that only wins if it flops a flush"],
            "Current equity goes up. Implied-odds hands go down.",
        ),
        _q(
            "Which line is the short-stack leak?",
            "Open-limping 40bb with a hand you will not call a jam with.",
            ["Jamming 18bb with ace-king from the button", "Folding 72o", "Getting in top pair on a dry board when the pot is large"],
            "A limp that folds to a shove wasted the chance to shove or to fold for free.",
        ),
        _q(
            "At 50bb you still have…",
            "A short postflop tree, not a 200bb one. One pair can commit on dry boards and fold on wet ones.",
            ["No decisions after the flop", "The same play as 500bb", "A requirement to open every pair"],
            "50bb is short, not all-in. Texture still matters for the last bet.",
        ),
        _q(
            "Premature commitment means…",
            "Putting in chips with a hand that needed more depth than you have.",
            ["Folding 72o", "Getting aces in at 20bb", "Counting the effective stack"],
            "Know the depth before you call a raise that prices you in.",
        ),
    ],
)

add(
    "lesson-08-02-01-standard-50-100bb-play",
    "Standard 50-100BB play",
    [
        _q(
            "100 big blinds is the baseline for the earlier path because…",
            "You have room for a preflop raise, a flop bet, and a turn decision without being all-in.",
            ["The blinds double every orbit", "Rake is zero at 100bb by rule", "Position stops mattering"],
            "Most live open, 3-bet, and c-bet sizes in this academy assume about 100bb.",
        ),
        _q(
            "At 80–100bb, top pair on a wet multiway board should…",
            "Not automatically stack off. There are still streets and stronger hands.",
            ["Always jam", "Always fold", "Be played exactly like 20bb"],
            "Standard depth leaves room to pot-control one pair when the board gets dangerous.",
        ),
        _q(
            "A common live leak at this depth is…",
            "Stacking off one pair on the flop because the pot 'feels big.'",
            ["Folding 72o under the gun", "3-betting queens", "Checking air on a wet board"],
            "100bb is deep enough that one pair is not a mandatory all-in on every texture.",
        ),
        _q(
            "50bb and 100bb are not the same plan. At 50bb you…",
            "Commit more often with good one pair. At 100bb you can still find folds.",
            ["Play deeper than 100bb", "Ignore position", "Only limp"],
            "Name the depth. 'About 100' is not 'about 40.'",
        ),
    ],
)

add(
    "lesson-08-02-02-decide-at-50-100bb",
    "Decide at 50-100BB",
    [
        _q(
            "100bb, single-raised pot, you have top pair top kicker on A72 rainbow, heads-up, in position. Best default?",
            "Bet for value. You are not all-in yet and the board is dry.",
            ["Fold", "Check-fold the turn no matter what", "Jam 100bb on the flop as the only size"],
            "This is the standard-depth value bet from the postflop path, not a short-stack shove.",
        ),
        _q(
            "70bb, you called a 3-bet with 76s and the flop is ace-high and dry. Best default?",
            "Fold to a bet. The stack is too short to float a miss.",
            ["Stack off", "Call any size because suited connectors always continue", "Limp"],
            "At 70bb the implied odds you wanted are already gone if you missed.",
        ),
        _q(
            "100bb, you have a set on a wet flop. Best default?",
            "Bet or raise. There is enough behind to get value and to charge draws.",
            ["Check-fold", "Open-limp", "Treat the stack as 20bb and jam only aces"],
            "A set at 100bb wants a bigger pot. You are not forced all-in before the bet.",
        ),
        _q(
            "You cover the table with 100bb and a player has 15bb. A decision against that player uses…",
            "15bb, the effective stack, not your 100bb.",
            ["100bb", "The average of every stack", "500bb"],
            "You cannot win more than they have in front of them.",
        ),
    ],
)

add(
    "lesson-08-02-03-50-100bb-check",
    "50-100BB check",
    [
        _q(
            "Which statement matches 100bb better than 25bb?",
            "You can check back a medium pair and still have a river decision.",
            ["Every open is a shove", "Set-mining is impossible", "There is no postflop play"],
            "Standard depth still has streets. Short depth often does not.",
        ),
        _q(
            "Avoiding premature commitment at 100bb means…",
            "Not putting the stack in with one pair when the board and the action say you are behind.",
            ["Folding every pair", "Never betting", "Jamming every draw"],
            "Commitment is for hands that are ahead or correctly priced. It is not a mood.",
        ),
        _q(
            "A 3-bet pot at 100bb has a lower stack-to-pot ratio than a single-raised pot, so…",
            "Good one pair commits more often than in a single-raised pot.",
            ["You should play it like 500bb", "Bluffs increase", "The 3-bet is refunded"],
            "More money is in. The same top pair is stronger relative to the remaining stack.",
        ),
        _q(
            "Which depth is the usual live open-raise baseline in this academy?",
            "About 100 big blinds, with 3–5bb opens when nobody has limped.",
            ["10 big blinds", "500 big blinds only", "The tournament clock"],
            "Adjust when the actual stack is far from that baseline. Do not pretend every stack is 100bb.",
        ),
    ],
)

add(
    "lesson-08-03-01-deep-100-200bb-play",
    "Deep 100-200BB play",
    [
        _q(
            "From 100bb to 180bb, which hands gain?",
            "Suited connectors and suited aces, because implied odds increase.",
            ["Dominated offsuit broadways that make one pair", "72o", "Hands you will stack off with ace-high"],
            "Extra depth pays the nuts and punishes one-pair domination.",
        ),
        _q(
            "Reverse implied odds at this depth means…",
            "You can lose a big pot when your one pair is dominated.",
            ["You are guaranteed to win more", "Draws lose equity", "The pot is raked twice"],
            "KJo feels strong and loses a stack to AK or KJ with a better kicker.",
        ),
        _q(
            "Stacking off TT preflop at 180bb against a tight 4-bet is…",
            "Usually a mistake. You are deep and behind the continuing range.",
            ["Automatic", "The same as jamming 20bb", "Required for balance"],
            "Tens are a 100bb continue in many spots and a fold to heavy action when stacks get deep.",
        ),
        _q(
            "Top pair at 180bb, compared with 40bb, is…",
            "Less of an automatic stack-off. There is too much money behind.",
            ["Always an all-in", "Worthless", "The nuts"],
            "Deeper stacks make one pair a pot-control hand more often.",
        ),
    ],
)

add(
    "lesson-08-03-02-decide-at-100-200bb",
    "Decide at 100-200BB",
    [
        _q(
            "160bb, button, folded to you with 76s. Compared with 40bb, you should…",
            "Open more happily. You can win a big pot if you flop a straight or two pair.",
            ["Fold. Suited connectors hate depth", "All-in", "Limp only"],
            "Depth is the reason this hand is playable in position.",
        ),
        _q(
            "150bb, you have KTo in the small blind facing an early open. Best default?",
            "Fold. You are dominated, out of position, and deep.",
            ["Call and stack off top pair", "All-in", "Complete because you posted a blind"],
            "Reverse implied odds are the point of this fold.",
        ),
        _q(
            "140bb, you flop top pair weak kicker on a wet board, multiway. Best default?",
            "Pot-control. Do not build a 140bb pot with this hand.",
            ["Jam", "Fold the best hand to a min-bet with no read", "Ignore the extra players"],
            "Weak kickers and depth do not mix in a big pot.",
        ),
        _q(
            "You have a set at 180bb on a dry board. Best default?",
            "Bet for value across streets. You are not forced to jam the flop.",
            ["Check-fold", "Open-shove the flop for 180bb every time", "Fold"],
            "Depth lets you get more from worse hands by betting, not by ending the hand immediately.",
        ),
    ],
)

add(
    "lesson-08-03-03-100-200bb-check",
    "100-200BB check",
    [
        _q(
            "Which adjustment is right as stacks move from 80bb toward 180bb?",
            "Call more suited hands in position and fewer dominated offsuit hands.",
            ["Jam more offsuit trash", "Stop using position", "Play every stack like 20bb"],
            "Implied odds up, reverse implied odds up. The hands move in opposite directions.",
        ),
        _q(
            "A 180bb stack does not mean…",
            "You should see every flop. Folds are still free.",
            ["Position matters more", "One pair is less of a stack-off", "Suited aces gain"],
            "Depth is not a reason to play junk.",
        ),
        _q(
            "Effective stacks are 120bb because the short stack has 120bb and you have 300bb. Play…",
            "120bb, not 300bb.",
            ["300bb", "20bb", "The sum"],
            "The extra chips you cannot win are not part of this pot.",
        ),
        _q(
            "Expanded calling ranges at this depth belong…",
            "In position, with hands that make the nuts, not out of position with offsuit broadways.",
            ["Under the gun with 72o", "In the small blind with KTo", "Only all-in"],
            "The extra chips help the player who can realize them.",
        ),
    ],
)

add(
    "lesson-08-04-01-very-deep-200-500bb-play",
    "Very deep 200-500BB play",
    [
        _q(
            "At 300–500bb, the hands that can stack someone are mostly…",
            "Sets, straights, flushes, and the nutted two pair. One pair is not enough.",
            ["Any pair", "Ace-high", "A preflop limp"],
            "Nut potential is the whole game when stacks are this deep.",
        ),
        _q(
            "Position is worth more very deep because…",
            "More streets remain, so acting last avoids the big blunders.",
            ["The button posts nothing", "Blinds disappear", "You must act first"],
            "A mistake at 400bb costs a buy-in, not a few blinds.",
        ),
        _q(
            "Large-pot risk means…",
            "Do not put in 400bb without a hand that beats the hands willing to call.",
            ["Bet the pot with air because the stack is large", "Ignore the nuts", "Rake makes deep pots free"],
            "The deeper you are, the stronger the hand you need to build the biggest pot.",
        ),
        _q(
            "A multi-street plan at 400bb starts…",
            "Before the flop: which hands can make the nuts, and which cannot.",
            ["On the river only", "After you are all-in", "By copying a 20bb jam chart"],
            "If the hand cannot make a very strong hand, it should not play a very large pot.",
        ),
    ],
)

add(
    "lesson-08-04-02-decide-at-200-500bb",
    "Decide at 200-500BB",
    [
        _q(
            "400bb, in position, folded to you with 76s. Best default?",
            "Open. This is a high nut-potential hand when you are deep and last to act.",
            ["Fold. Deep stacks make suited connectors worse", "All-in", "Limp and call any 4-bet"],
            "Very deep, suited connectors are a reason to play, not a fold.",
        ),
        _q(
            "350bb, you have top pair on the river and face a huge bet from a tight player. Best default?",
            "Fold most of the time. One pair does not beat a 300bb value bet.",
            ["Call because you were ahead on the flop", "Raise all-in", "Call every river because you are deep"],
            "Depth turns top pair into a bluff-catcher, and tight players under-bluff the river.",
        ),
        _q(
            "250bb, you flop the nut straight on a dry board. Best default?",
            "Bet for value over multiple streets. Do not check it away.",
            ["Fold", "Jam 250bb into a tiny pot with no callers who can have anything", "Check-fold"],
            "You have the nuts and the stack to get paid. Build the pot. A single overbet is not the only way.",
        ),
        _q(
            "500bb effective, early position, KJo. Best default?",
            "Fold. Deep and early, this offsuit hand is dominated.",
            ["Open and stack off", "All-in", "Call a 4-bet"],
            "The same hand that opens on the button at 100bb is a fold under the gun at 500bb.",
        ),
    ],
)

add(
    "lesson-08-04-03-200-500bb-check",
    "200-500BB check",
    [
        _q(
            "Which hand should play a bigger pot at 400bb?",
            "A set.",
            ["Bottom pair", "Ace-high", "A dominated offsuit king"],
            "Nut potential, not the first pair you make.",
        ),
        _q(
            "Bluffing off 400bb with ace-high is…",
            "A clear mistake. The stack is too large for a one-card bluff.",
            ["Standard", "Required very deep", "The same as a 20bb shove"],
            "Bluff sizes and bluff hands shrink as the punishment grows.",
        ),
        _q(
            "Very deep play still uses the same streets. What changes is…",
            "How strong a hand must be before you commit the stack.",
            ["The ranking of poker hands", "That flushes no longer count", "That position is gone"],
            "A straight still beats a pair. You just should not stack off the pair.",
        ),
        _q(
            "A 200bb stack and a 40bb stack at the same table are…",
            "Two different games. Use the effective stack for each opponent.",
            ["Both 200bb", "Both short", "Illegal"],
            "Covering someone does not make their pot deep.",
        ),
    ],
)

add(
    "lesson-08-05-01-stakes-rake-and-ev-economics",
    "Stakes, rake, and EV economics",
    [
        _q(
            "A pot rake or drop makes marginal calls worse because…",
            "You win less than the chips in the middle. The price you were getting shrinks.",
            ["It adds chips to the pot", "It only affects the loser", "It removes the big blind"],
            "This trainer does not deduct rake yet. Live, the house takes a piece before you are paid.",
        ),
        _q(
            "Small pots are punished more by a percent rake or a drop than large pots because…",
            "The rake is a bigger fraction of a small pot, up to the cap.",
            ["Large pots are raked at a higher percent forever", "Rake is a flat fee equal to the pot", "Only jackpots are raked"],
            "Stealing a tiny pot can be a loss after the drop. Winning a capped pot gives the rake back as a smaller percent.",
        ),
        _q(
            "Time rake, common at some $5/$10 and higher games, is…",
            "A seat charge for time, not a percent of each pot. This app does not charge it.",
            ["A card that is dealt twice", "The same as a pot drop", "A straddle"],
            "Time collection does not shrink each pot, so speculative hands are less taxed than under a drop. The lineup is usually tougher.",
        ),
        _q(
            "A tip is…",
            "Money you choose to give the dealer. It is not won back from the pot.",
            ["Added to your stack by the casino", "A required part of every call", "Refunded when you fold"],
            "Tipping is a cost of the session. It is not a strategy bet.",
        ),
    ],
)

add(
    "lesson-08-05-02-choose-stakes-economically",
    "Choose stakes economically",
    [
        _q(
            "You won two buy-ins at $1/$2 tonight. Moving to $5/$10 for the next hand is…",
            "A mistake. One session is not a bankroll or a skill proof.",
            ["Required, because winners must move up", "The same stake", "How rake is avoided"],
            "Stake choice is a money decision, not a celebration.",
        ),
        _q(
            "$1/$2 with a drop makes which play less profitable than the unraked chart?",
            "A thin call of a small bet, and a steal of a tiny pot.",
            ["Folding 72o", "Getting a set all-in when you are a big favorite in a large pot", "Looking at your cards"],
            "The drop takes the edge off small pots. Big favorite pots still clear a capped rake.",
        ),
        _q(
            "A $2/$5 game that is tougher and uses a percent rake, compared with a soft $1/$2, should be chosen when…",
            "Your edge is real and the buy-in does not threaten rent or food.",
            ["You are stuck in the $1/$2 game", "The bigger chips look better", "You want a faster loss"],
            "Higher stakes are not a reward. They are a higher price for the same mistakes.",
        ),
        _q(
            "This app’s hands do not currently subtract rake. When you practice a close call you should remember…",
            "A live room may take that edge away. Do not treat a break-even unraked call as a must-call live.",
            ["Rake makes every call better", "The app’s result is the casino’s result", "Time rake is dealt as a community card"],
            "Practice the decision. Adjust the price when the house takes a piece.",
        ),
    ],
)

add(
    "lesson-08-05-03-stakes-economics-check",
    "Stakes economics check",
    [
        _q(
            "Which cost shrinks the pot you win?",
            "A drop or percent rake, up to the cap.",
            ["A time charge that never touches the pot", "Folding before you put chips in", "The button"],
            "Pot rake comes out of the pot. A time charge is paid separately.",
        ),
        _q(
            "Which game is less harsh on small speculative pots?",
            "A time-rake game, because the pot is not reduced. The players are often better.",
            ["A high drop on every $1/$2 hand", "A game that rakes 100% of the pot", "A game with no opponents"],
            "Time rake taxes the seat, not the small pot. Skill still has to be there.",
        ),
        _q(
            "EV of a session includes…",
            "The decisions, the rake, and the tips. Not one lucky pot.",
            ["Only the biggest win", "Only the rack", "The jackpot you did not hit"],
            "A winning night can be a bad decision if you paid too much rake at the wrong stake.",
        ),
        _q(
            "The economic check before you sit is…",
            "Can I lose a buy-in here without changing how I live, at a rake I understand?",
            ["Are the chips a nicer color", "Did I win last time", "Is the stake the highest in the room"],
            "If the answer is no, the strategy lesson does not matter yet.",
        ),
    ],
)

add(
    "lesson-08-06-01-straddles-bomb-pots-and-run-it-twice",
    "Straddles, bomb pots, and run-it-twice",
    [
        _q(
            "A live straddle is…",
            "An extra blind posted before cards, often by under the gun. This trainer does not deal it.",
            ["A fourth community card", "A tournament ante that doubles the blinds", "A rule that the button acts first on the flop"],
            "Conceptually the straddler is a bigger big blind and acts last preflop. The first voluntary actor sits to their left.",
        ),
        _q(
            "A bomb pot is…",
            "Everyone posts, there is no preflop betting, and the hand starts on the flop. This trainer does not deal it.",
            ["A normal open to 3 big blinds", "An all-in preflop", "A side pot from a short stack"],
            "Ranges are random and wide. Play for nut potential, not for a preflop raiser’s range advantage.",
        ),
        _q(
            "Running it twice, after an all-in, …",
            "Deals the remaining board twice and splits the pot by board. It reduces variance. It does not change a fair all-in price. This trainer does not offer it.",
            ["Lets you fold after you see the first board", "Doubles your equity", "Is insurance"],
            "If you were getting the right price once, you are getting it on each run. You are not twice as good.",
        ),
        _q(
            "Insurance is…",
            "A side bet that pays when you are ahead and lose the runout. It is not a poker action, and this app does not sell it.",
            ["A required call", "The same as running it twice", "A community card"],
            "Do not confuse a proposition bet with the hand. Your poker decision is still the all-in price.",
        ),
    ],
)

add(
    "lesson-08-06-02-navigate-straddles-and-bomb-pots",
    "Navigate straddles and bomb pots",
    [
        _q(
            "Under the gun posts a straddle to two big blinds. You are next to act. Conceptually you are…",
            "The first voluntary actor, in the straddle’s 'under the gun,' not in a normal big blind.",
            ["The button", "Forced to call the straddle", "Allowed to check",],
            "Do not use a 9-handed UTG chart from the seat that now faces a bigger blind. This app will not deal the straddle for you.",
        ),
        _q(
            "The straddler has not acted and you hold 72o. Best conceptual default?",
            "Fold. A bigger blind does not make trash playable.",
            ["Call because a straddle is a limp", "All-in", "Check"],
            "The straddle changes position and price. It does not change hand values that much for junk.",
        ),
        _q(
            "A bomb pot is dealt to the flop with five players and you have top pair weak kicker. Conceptually…",
            "Bet small or check. Ranges are wide and multiway, so weak kickers do not stack off.",
            ["Jam because there was no preflop raiser", "Fold the nuts", "Play it as a 4-bet pot"],
            "No preflop raise means no capped-versus-uncapped story. Nut potential and player count still rule.",
        ),
        _q(
            "You are all-in and the table asks to run it twice. A sound poker answer is…",
            "Either once or twice is fine if the price was right. Running twice does not fix a bad call, and this app will not deal the second board.",
            ["You must run it twice or the hand is dead", "Running twice doubles your win", "Refuse because the second board changes the ranking of hands"],
            "Variance changes. The equity of each board does not.",
        ),
    ],
)

add(
    "lesson-08-06-03-local-variants-check",
    "Local variants check",
    [
        _q(
            "Which mechanic does this trainer deal today?",
            "None of the variants. No straddles, bomb pots, run-it-twice, or insurance.",
            ["Straddles only", "Bomb pots only", "Insurance on every all-in"],
            "Learn the idea. Do not expect the felt to deal it until the engine supports it.",
        ),
        _q(
            "A straddle changes…",
            "Who is in the blinds and who acts first. It is still no-limit hold’em.",
            ["The ranking of a flush", "The number of hole cards", "The dealer button into the big blind by rule"],
            "Hand rankings stay. Position and the price change.",
        ),
        _q(
            "Before you play a local rule, you should…",
            "Ask the dealer how this room does it. Rooms differ.",
            ["Assume every straddle is a button straddle", "Assume bomb pots are optional and free", "Ignore the floor"],
            "Conceptual knowledge is not a substitute for the room’s actual rule.",
        ),
        _q(
            "The live-environment check is…",
            "Depth, stake, rake, and whether the variant is actually in the hand.",
            ["Only the highest stake", "Only the variant name", "Only whether you are winning"],
            "Play the stack and the game in front of you. Do not import a rule the cards did not use.",
        ),
    ],
)


def _question(index: int, raw: Q) -> dict:
    prompt, correct_index, choices, explanation = raw
    if len(choices) != 4:
        raise SystemExit(f"need 4 choices: {prompt}")
    if not 0 <= correct_index < 4:
        raise SystemExit(f"bad correct index: {prompt}")
    letters = ["a", "b", "c", "d"]
    return {
        "id": f"q{index}",
        "prompt": prompt,
        "choices": [{"id": letters[i], "text": text} for i, text in enumerate(choices)],
        "correctChoiceId": letters[correct_index],
        "explanation": explanation,
    }


def write_exercises() -> None:
    EX_DIR.mkdir(parents=True, exist_ok=True)
    for lesson_id, (title, questions) in LESSONS.items():
        path = EX_DIR / f"{lesson_id}.json"
        if path.exists():
            continue
        payload = {
            "id": lesson_id,
            "lessonId": lesson_id,
            "version": "1.0.0",
            "title": title,
            "questions": [_question(i, raw) for i, raw in enumerate(questions, start=1)],
        }
        path.write_text(json.dumps(payload, indent=2) + "\n")


def patch_catalog() -> None:
    catalog = json.loads(CATALOG.read_text())
    for section in catalog["sections"]:
        if section["order"] != 8:
            continue
        for unit in section["units"]:
            for lesson in unit["lessons"]:
                lesson["exerciseRefs"] = [lesson["id"]]
    for objective in catalog["objectives"]:
        extra = OBJECTIVE_TAGS.get(objective["id"])
        if not extra:
            continue
        tags = objective.setdefault("tagSelectors", {})
        for key, values in extra.items():
            current = list(tags.get(key, []))
            for value in values:
                if value not in current:
                    current.append(value)
            tags[key] = current
    text = json.dumps(catalog, indent=2) + "\n"
    CATALOG.write_text(text)
    ASSET_CATALOG.write_text(text)
    FN_CATALOG.parent.mkdir(parents=True, exist_ok=True)
    FN_CATALOG.write_text(text)


def write_bank() -> None:
    bank = {}
    for path in sorted(EX_DIR.glob("*.json")):
        payload = json.loads(path.read_text())
        bank[payload["id"]] = payload
        for dest in (FN_EX, ASSET_EX):
            target = dest / path.name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(path, target)
    BANK.write_text(json.dumps(bank, indent=2) + "\n")


def main() -> None:
    if len(LESSONS) != 18:
        raise SystemExit(f"expected 18 lessons, got {len(LESSONS)}")
    write_exercises()
    patch_catalog()
    write_bank()
    print(
        f"authored={len(LESSONS)} exercises={len(list(EX_DIR.glob('*.json')))} "
        f"bank={len(json.loads(BANK.read_text()))}"
    )


if __name__ == "__main__":
    main()
