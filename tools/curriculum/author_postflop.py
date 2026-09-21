#!/usr/bin/env python3
"""Author Sections 5–7 static exercises and sync generated catalogs.

Canonical exercises land in content/curriculum/v1/exercises/.
Does not overwrite an existing exercise file.
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

POSTFLOP_GATE_OBJECTIVES = (
    "obj-river-bluffs",
    "obj-4bet-pots",
    "obj-player-count",
)

OBJECTIVE_TAGS: dict[str, dict[str, list[str]]] = {
    "obj-flop-texture": {"street": ["flop"], "topic": ["texture"]},
    "obj-flop-hand-classes": {"street": ["flop"], "topic": ["hand-class"]},
    "obj-flop-ip": {"street": ["flop"], "position": ["ip"], "action": ["cbet"]},
    "obj-flop-oop": {"street": ["flop"], "position": ["oop"], "action": ["check"]},
    "obj-turn-effects": {"street": ["turn"], "topic": ["runout"]},
    "obj-turn-lines": {"street": ["turn"], "action": ["barrel"]},
    "obj-river-value": {"street": ["river"], "action": ["value"]},
    "obj-river-bluffs": {"street": ["river"], "action": ["bluff"]},
    "obj-river-defense": {"street": ["river"], "action": ["bluff-catch"]},
    "obj-limped-pots": {"potFamily": ["limped"]},
    "obj-srp": {"potFamily": ["srp"]},
    "obj-3bet-pots": {"potFamily": ["3bet"]},
    "obj-4bet-pots": {"potFamily": ["4bet"]},
    "obj-player-count": {"playerCount": ["multiway", "heads-up"]},
}


def add(lesson_id: str, title: str, questions: list[Q]) -> None:
    LESSONS[lesson_id] = (title, questions)


def _q(prompt: str, correct: str, wrong: list[str], why: str) -> Q:
    if len(wrong) != 3:
        raise SystemExit(f"need 3 wrong answers: {prompt}")
    return (prompt, 0, [correct, *wrong], why)


# --- Section 5: flop ---

add(
    "lesson-05-01-01-flop-textures-and-categories",
    "Flop textures and categories",
    [
        _q(
            "Which flop is the driest?",
            "Ks 7d 2c",
            ["Jh Th 9h", "9h 8h 7c", "Qs Js Td"],
            "Unpaired, rainbow, and disconnected boards change on fewer turns than monotone or connected boards.",
        ),
        _q(
            "Which flop is dynamic?",
            "Jh Th 9h",
            ["As Kd 2c", "Kc 8d 3h", "Ad 7c 2s"],
            "A monotone connected flop has many turns that complete straights and flushes.",
        ),
        _q(
            "On As 7d 2c, who usually has the range advantage in a single-raised pot?",
            "The preflop raiser",
            ["The big blind caller", "Whoever limped", "The player with the smaller stack, always"],
            "The raiser has more strong aces and overpairs. The caller’s range is capped and heavier in suited junk that missed.",
        ),
        _q(
            "Nut advantage means…",
            "Who has more of the very strongest hands, not just who has more high cards.",
            ["Who acts last", "Who posted the big blind", "Who has more chips off the table"],
            "On 9h 8h 7c the caller often has more straights and two pair than a tight early raiser.",
        ),
    ],
)

add(
    "lesson-05-01-02-classify-flop-textures",
    "Classify flop textures",
    [
        _q(
            "Ts 6c 2d is best classified as…",
            "Dry",
            ["Monotone", "Four-straight", "A paired board"],
            "One broadway, two low unconnected cards, three suits. Few draws.",
        ),
        _q(
            "8h 7h 6c is best classified as…",
            "Wet",
            ["Dry and static", "A blank", "A board with no straights possible"],
            "Two-tone and connected. Straights, two pair, and flush draws are all live.",
        ),
        _q(
            "Ah Kh Qh. What is true?",
            "The board is monotone, so the nut hand is often the nut flush, not top pair.",
            ["Top pair of aces is always the nuts", "There is no flush draw", "The board is dry"],
            "Three hearts mean any heart makes a flush, and the ace of hearts makes the nut flush.",
        ),
        _q(
            "A paired flop such as Ks Kd 4c favors…",
            "The preflop raiser more than a wide caller, because the raiser has more kings and pocket pairs.",
            ["Only the player who limped", "A random hand equally", "The player who folded preflop"],
            "Trips and overpairs sit in the raising range. A wide call has more air.",
        ),
    ],
)

add(
    "lesson-05-01-03-board-texture-check",
    "Board texture check",
    [
        _q(
            "As 7d 2c compared with Jh Th 9h is…",
            "Drier. Fewer turns complete a straight or a flush.",
            ["Wetter, because of the ace", "The same texture", "A monotone board"],
            "Ace-high disconnected rainbow is static. Jack-ten-nine with a flush draw is dynamic.",
        ),
        _q(
            "Button opened, big blind called. Flop 9h 8h 7c. Who has more of the nuts?",
            "The big blind. Straights and two pair show up more in a calling range.",
            ["The button, because position is the nuts", "Neither. The nuts are always pocket aces", "The player who folded under the gun"],
            "Nut advantage can sit with the caller even when the raiser has more overpairs.",
        ),
        _q(
            "Range advantage and nut advantage differ because…",
            "Range advantage is who has more strong hands overall. Nut advantage is who has more of the absolute best hands.",
            ["They are the same thing", "Nut advantage is only stack size", "Range advantage ignores position and preflop action"],
            "On A72 rainbow the raiser often has both. On 876 the caller can have the nuts while the raiser still has more overpairs.",
        ),
        _q(
            "A blank turn on K72 rainbow is a card that…",
            "Does not complete many draws or change who holds the nuts.",
            ["Always makes a flush", "Always counterfeits two pair", "Is illegal to deal"],
            "A deuce, seven, or king pairs the board. A low offsuit brick such as a three changes less.",
        ),
    ],
)

add(
    "lesson-05-02-01-made-hands-draws-and-air",
    "Made hands, draws, and air",
    [
        _q(
            "You hold Ah Kh on a flop of Qh 9c 4d. Your hand is…",
            "Overcards with the nut-flush draw: 9 flush outs, not 12.",
            ["A made flush", "A set", "Air with no outs"],
            "Two hearts on a one-heart board is a flush draw. Nine hearts remain. The two overcards are extra, not more flush outs.",
        ),
        _q(
            "An open-ended straight draw has how many outs to the straight?",
            "8",
            ["4", "9", "15"],
            "Four cards on each end. A gutshot has 4. A flush draw has 9.",
        ),
        _q(
            "From the flop, a rough equity for a 9-out flush draw through the river is…",
            "About 35%, using outs times 4. It is not a lock.",
            ["About 9%", "100% if you call", "About 2%, using outs times 2 on the flop"],
            "Outs times 4 is the flop-to-river shortcut. Outs times 2 is one card, which is the turn.",
        ),
        _q(
            "Top pair with a weak kicker on a wet board is…",
            "A made hand that is often behind sets, two pair, and better kickers.",
            ["The nuts", "A flush draw", "Air that should always stack off"],
            "Classify the hand before you choose a size. One pair is not the nuts on a connected board.",
        ),
    ],
)

add(
    "lesson-05-02-02-assign-flop-hand-classes",
    "Assign flop hand classes",
    [
        _q(
            "You hold 9c 9d on 9h Ks 4c. That is…",
            "A set, among the strongest made hands.",
            ["Top pair only", "A flush draw", "Air"],
            "Three nines. You are ahead of top pair and most two pair.",
        ),
        _q(
            "You hold Jc Td on Qh 9c 2d. That is…",
            "An open-ended straight draw, 8 outs. King or eight completes it.",
            ["A gutshot with 4 outs", "The nuts", "A flush draw with 9 outs"],
            "Queen, jack, ten, and nine are consecutive. Either end completes the straight. There is no flush draw on this rainbow board.",
        ),
        _q(
            "You hold 7c 6c on Ks 8d 2h. That is…",
            "Air. No pair, no straight draw, no flush draw.",
            ["A combo draw", "Middle pair", "The nut flush draw"],
            "Do not invent equity. This hand needs help that the flop did not offer.",
        ),
        _q(
            "Combo draws are strong because…",
            "A flush draw plus an open-ender is about 15 outs, not a made hand and not 9 outs only.",
            ["They are always the nuts already", "They have 2 outs", "They should be folded on every flop"],
            "Count overlapping outs once. Fifteen outs is a strong draw, still not a guaranteed win.",
        ),
    ],
)

add(
    "lesson-05-02-03-hand-classes-check",
    "Hand classes check",
    [
        _q(
            "Which hand is air on As Kd 4c?",
            "7c 6d",
            ["Ac Qd", "Ad Ah", "Kd Kc"],
            "Seven-six missed. Ace-queen is top pair. Pocket aces and kings are sets or an overpair.",
        ),
        _q(
            "Ah 5h on Qh 9h 2c is…",
            "The nut flush draw, 9 outs.",
            ["A made nut flush", "A gutshot only", "12 flush outs"],
            "Two hearts remain in your hand and two are on the board, so nine hearts are left. You do not have a flush yet.",
        ),
        _q(
            "The rule-of-two shortcut belongs on…",
            "The turn, one card to come. The flop uses about four.",
            ["The flop, because two cards remain so you multiply by 2", "Only preflop", "Only when you are all-in"],
            "One card left: outs times 2. Two cards left: outs times 4. Both are approximations.",
        ),
        _q(
            "Second pair on a dry board is usually…",
            "Showdown value. It does not need a huge bluff and it is not the nuts.",
            ["A mandatory all-in", "Air", "A flush"],
            "Medium made hands want to get to showdown more than they want to build a huge pot.",
        ),
    ],
)

add(
    "lesson-05-03-01-in-position-flop-aggression",
    "In-position flop aggression",
    [
        _q(
            "You raised preflop and are in position on As 7d 2c. A small continuation bet is common because…",
            "Your range has the advantage and the board has few draws to charge.",
            ["The caller has the nuts more often", "Small bets are only for bluffs", "Position means you must check"],
            "Dry ace-high boards favor the raiser. A small bet denies equity without bloating the pot.",
        ),
        _q(
            "You raised and are in position on 9h 8h 7c with ace-high and no draw. The better default is…",
            "Check back. The board hits the caller’s range.",
            ["Bet the size of the pot with air every time", "All-in", "Fold a hand that can still win"],
            "Checking back air and weak showdown on a wet caller board avoids lighting money on fire.",
        ),
        _q(
            "When you do bet a wet board with a strong hand or a strong draw, the size is usually…",
            "Larger than the small dry-board bet, so draws pay.",
            ["Always the minimum", "Always all-in at 100 big blinds", "Smaller than on a dry board"],
            "Charge hands that have equity. A tiny bet on 876 two-tone lets every draw continue.",
        ),
        _q(
            "Checking back second pair in position is often right because…",
            "You have showdown value and keep the caller’s bluffs in.",
            ["Second pair is the nuts", "The rules require a check", "You should bet only when you will fold to a raise you cannot beat"],
            "A small pair that is ahead of air does not need protection on a dry board as much as it needs a cheap showdown.",
        ),
    ],
)

add(
    "lesson-05-03-02-choose-ip-flop-lines",
    "Choose IP flop lines",
    [
        _q(
            "Button versus big blind, you have AK on A72 rainbow. Best default?",
            "Bet for value. Top pair, top kicker is ahead of the calling range.",
            ["Check because an ace hits the caller", "Fold", "All-in for 100 big blinds as the only value bet"],
            "This is a value bet, usually a smaller size on a dry board, not a check and not a stack-off size.",
        ),
        _q(
            "Same pot, you have 76 with no pair and no draw on A72 rainbow. Best default?",
            "Check back. You have little equity and little fold equity against a hand that called an ace-high board.",
            ["Pot-size bluff", "All-in", "Bet large because you were the raiser"],
            "Being the raiser is not a reason to fire air into a board that already favors you with better hands.",
        ),
        _q(
            "Button versus big blind, you have a set on 9h 8h 6c. Best default?",
            "Bet larger. You want calls from draws and worse made hands.",
            ["Check back so the draws see a free card", "Fold", "Bet the minimum and fold to a raise"],
            "A set on a wet board wants a bigger pot. Giving a free card lets flushes and straights catch up.",
        ),
        _q(
            "In position with a medium pocket pair that did not set, on a king-high dry board, a sound line is…",
            "Check back and reevaluate the turn.",
            ["All-in", "Fold the best hand automatically", "Bet pot and call a check-raise"],
            "Underpairs have showdown value against ace-high and missed hands. They do not want a huge pot.",
        ),
    ],
)

add(
    "lesson-05-03-03-ip-aggression-check",
    "IP aggression check",
    [
        _q(
            "A continuation bet is most attractive when…",
            "You have range advantage and the board is dry.",
            ["The board is 876 with two suits and you have no pair", "You are out of position", "Four players called your open"],
            "Bet the boards you smash. Check the boards the caller smashes, especially multiway.",
        ),
        _q(
            "Checking back in position does not mean you give up the hand. It means…",
            "You can still bet a later street or win at showdown.",
            ["You must fold the turn", "The hand is over", "You cannot win the pot"],
            "Position lets you realize equity and choose a later bluff or value bet.",
        ),
        _q(
            "Which sizing story is backwards?",
            "Bet tiny on a wet draw-heavy board and huge with air on a dry ace-high board.",
            ["Bet small on dry ace-high", "Bet larger with a set on a wet board", "Check back weak showdown value"],
            "Small on dry, larger when you charge draws or value a strong hand. The reverse leaks chips.",
        ),
        _q(
            "You are in position as the preflop caller, not the raiser, on A72. You should…",
            "Not assume the raiser’s c-bet frequency. Your calling range is the one that missed this board.",
            ["Always lead all-in", "Always have the nuts", "Fold every ace"],
            "The raiser has the range advantage here. Floats and calls need a real hand or a plan, not hope.",
        ),
    ],
)

add(
    "lesson-05-04-01-out-of-position-flop-strategy",
    "Out-of-position flop strategy",
    [
        _q(
            "Out of position, the default start for a preflop caller is…",
            "Check, then decide to call, raise, or fold against a bet.",
            ["Donk bet every flop", "All-in", "Check-fold every made hand"],
            "Leading into the raiser is the exception. Checking keeps the raiser’s bluffs in the pot.",
        ),
        _q(
            "A check-raise is for…",
            "Strong made hands and some strong draws, not every missed hand.",
            ["Only air", "Only the nuts, never a draw", "Any two cards, every flop"],
            "You build the pot when you are ahead or have a lot of equity, and you fold out better one-pair hands with some draws.",
        ),
        _q(
            "Check-calling fits…",
            "Medium made hands and decent draws that cannot raise for value.",
            ["The nuts, which should usually raise", "Air with no plan", "A hand you will stack off with no pair and no draw"],
            "Call when you beat bluffs or have equity. Do not call when you beat nothing and cannot improve.",
        ),
        _q(
            "A donk bet can make sense when…",
            "The flop hits your calling range much harder than the raiser’s range.",
            ["You have bottom pair on ace-high", "You are in position", "You want to bet air because you act first"],
            "Leading 876 after you called in the big blind is more reasonable than leading A72 into the raiser.",
        ),
    ],
)

add(
    "lesson-05-04-02-choose-oop-flop-lines",
    "Choose OOP flop lines",
    [
        _q(
            "Big blind versus button, you have a set on A72 rainbow. The button bets small. Best default?",
            "Raise. A set wants a bigger pot, even on a dry board.",
            ["Fold", "Only call and never raise a set", "Donk the next street for the minimum no matter what"],
            "Slow-playing a set on a dry board lets the button check back the turn and realize equity for free.",
        ),
        _q(
            "Big blind versus button, you have bottom pair on As Kd 4c and face a pot-size bet. Best default?",
            "Fold. Bottom pair does not beat a real value range and has little equity.",
            ["Call every time", "Check-raise all-in", "Raise small and call a jam"],
            "Out of position, weak pairs against a large bet are folds, not hero calls.",
        ),
        _q(
            "Big blind, you called a button open and flopped a nut flush draw on a dry-ish two-tone board. Facing a small bet, a sound continue is…",
            "Call or raise. You have nine outs to the nuts plus fold equity if you raise.",
            ["Fold. Draws cannot continue", "Call and stack off if you miss", "Lead all-in before the bet"],
            "Nine outs is enough to continue against a small bet. Missing later is a new decision.",
        ),
        _q(
            "You are the preflop raiser out of position, heads-up, on a dry board. A check is…",
            "Allowed. You can check-call, check-raise, or check-fold. Betting is common but not mandatory.",
            ["Illegal for the raiser", "A guaranteed loss", "Only correct with the nuts"],
            "Out of position, checking a dry board with a medium hand controls the pot.",
        ),
    ],
)

add(
    "lesson-05-04-03-oop-play-check",
    "OOP play check",
    [
        _q(
            "The usual mistake with a donk bet is…",
            "Leading a weak pair into a range that has the advantage.",
            ["Checking a set once", "Folding air to a large bet", "Calling a small bet with a flush draw"],
            "Donk bets announce a hand and fold out the bluffs you wanted to catch.",
        ),
        _q(
            "Check-raising air on every flop fails because…",
            "You are out of position on later streets when you get called.",
            ["Raises are illegal", "The raiser must fold", "Air always has 15 outs"],
            "A raise that gets called leaves you playing a big pot first to act with nothing.",
        ),
        _q(
            "Which line matches a medium pair out of position against a small bet?",
            "Check-call, and fold if later bets get too large for the hand.",
            ["All-in", "Fold to any bet including the minimum", "Donk pot on the flop before they act"],
            "Small bets can be called by hands that beat air. Large later bets are a new price.",
        ),
        _q(
            "You check-raised the flop and got called. On a blank turn with no pair, you should…",
            "Slow down more often. The call means you are behind a lot.",
            ["Automatically jam", "Assume they folded", "Bet only if you can fold out a better hand you do not block"],
            "One raise did not turn air into the nuts. Barrels need a new reason.",
        ),
    ],
)

add(
    "lesson-05-05-01-integrating-flop-concepts",
    "Integrating flop concepts",
    [
        _q(
            "Multiway, your bluffs should…",
            "Decrease. Two callers are harder to fold than one.",
            ["Increase, because more players mean more dead money you can always win", "Stay the same as heads-up", "Become all-in with air"],
            "Each extra player multiplies the chance someone has a hand. Value bet stronger hands and bluff less.",
        ),
        _q(
            "A weak range realizes equity better when…",
            "It can check back in position or see a cheap card.",
            ["It stacks off every flop", "It donks into three players", "It is forced all-in"],
            "Speculative hands and weak pairs need a low price. Big bets deny that equity.",
        ),
        _q(
            "Before you choose a flop action, name…",
            "Texture, your hand class, position, and how many players are in.",
            ["Only the size of your stack off the table", "Only whether you won the last hand", "Only the suit of the cut card"],
            "Those four facts decide bet, check, call, raise, or fold. Skipping one of them is how leaks start.",
        ),
        _q(
            "A heads-up c-bet plan copied into a four-way pot is usually…",
            "Too loose. Multiway pots are for value, not for the same bluff frequency.",
            ["Required, because the math does not change", "Tighter only for the nuts", "Illegal"],
            "Fold equity collapses as players are added. Keep the strong hands and drop the air.",
        ),
    ],
)

add(
    "lesson-05-05-02-solve-multi-factor-flop-spots",
    "Solve multi-factor flop spots",
    [
        _q(
            "You are on the button, heads-up against the big blind, with top pair on a dry board. You bet small and get raised. A set or two pair is now more likely. You should…",
            "Continue only with the top of that hand, and fold the weaker top pairs to a large raise.",
            ["Always jam top pair", "Always fold top pair, top kicker", "Call any raise because you have top pair"],
            "A raise on a dry board is stronger than a call. Kicker and price still matter. Top pair is not one action.",
        ),
        _q(
            "Three players see a flop of 8h 7h 6c. You are under the gun with ace-high and no draw. Best default?",
            "Check and give up to a bet. Multiway and wet, ace-high is air.",
            ["Pot-size bluff", "All-in", "Call a pot bet because an ace is coming"],
            "You do not have a hand or a draw, and two players remain. This is a fold.",
        ),
        _q(
            "Heads-up, in position, you have the nut flush draw and two overcards on a wet flop. Facing a small bet…",
            "Continue. You have a strong draw, not air.",
            ["Fold. Overcards do not count", "Fold. Flush draws have 2 outs", "Only continue if you are already ahead"],
            "This is a high-equity draw. Calling or raising are both real. Folding is not.",
        ),
        _q(
            "Out of position, multiway, you flop bottom pair. Someone bets and a player calls. You should…",
            "Fold. You are behind a bet and a call with a weak pair.",
            ["Raise all-in", "Call because the pot is big", "Donk the turn no matter the card"],
            "Bottom pair does not beat a bet-and-call on a multiway flop.",
        ),
    ],
)

add(
    "lesson-05-05-03-flop-integration-check",
    "Flop integration check",
    [
        _q(
            "Which spot is a clear value bet?",
            "Heads-up, in position, top pair top kicker on a dry board.",
            ["Four-way, ace-high on a wet board", "Out of position, bottom pair facing a raise", "Air on 876 with two callers"],
            "Value needs a hand that is ahead and a field that can call worse. The other spots are air or dominated.",
        ),
        _q(
            "Which spot is a clear check?",
            "In position with no pair and no draw on a board that favors the caller.",
            ["A set on a wet board", "Top pair on a dry board heads-up", "The nuts"],
            "Air without fold equity checks. Strong hands bet.",
        ),
        _q(
            "Which continue is too loose?",
            "Calling a pot-size bet out of position with bottom pair, multiway.",
            ["Calling a small bet with a nut flush draw", "Betting top pair on a dry board", "Folding air to a large bet"],
            "The price and the number of players make bottom pair a fold.",
        ),
        _q(
            "A flop plan is complete only when you also know…",
            "What you will do if you are raised or if the turn is a blank.",
            ["The other players’ hole cards", "That you will never fold", "The jackpot amount"],
            "One action is not a line. Strong players pick the flop bet and the turn plan together.",
        ),
    ],
)

add(
    "lesson-06-01-01-how-turn-cards-change-ranges",
    "How turn cards change ranges",
    [
        _q(
            "Flop As 7d 2c, turn 3h. For a preflop raiser who c-bet, this turn is mostly…",
            "A brick. It completes few draws and does not change the nuts.",
            ["A four-flush", "A card that always gives the caller the nuts", "A paired board"],
            "The three does not connect with ace-seven-deuce. Overpairs and top pair stay best.",
        ),
        _q(
            "Flop Kh 7d 3c, turn Ah. What changed?",
            "An ace is now top pair, and a heart flush draw appeared.",
            ["Nothing. Kickers do not change", "The board paired", "The pot is awarded to the preflop raiser"],
            "The ace leapfrogs kings. Anyone with the ace of hearts also picked up the nut flush draw.",
        ),
        _q(
            "A scare card is…",
            "A turn that completes an obvious draw, such as a third flush card.",
            ["Any deuce", "Only a card that pairs your hole card", "A card the dealer burns"],
            "Scare cards shift the nuts toward the draw that just got there. Bluffing them without a blocker is how stations get paid.",
        ),
        _q(
            "Who is hurt more when the third flush card comes and they have no flush?",
            "The player who was betting one pair for value. Their hand is now behind every flush.",
            ["The player who folded preflop", "Nobody. One pair still beats a flush", "Only the player with the nuts"],
            "One pair does not improve when the flush arrives. Value bets have to shrink or stop.",
        ),
    ],
)

add(
    "lesson-06-01-02-evaluate-turn-card-impact",
    "Evaluate turn card impact",
    [
        _q(
            "You c-bet KQ on K72 rainbow. The turn is a 2. Your hand…",
            "Is still top pair, but the deuce pairs the board and counterfeits some two pair less than a flush card would.",
            ["Became a flush", "Is now the worst hand automatically", "Cannot bet again"],
            "Pairing the deuce is a small change. You still have a strong one pair. It is not a flush completing.",
        ),
        _q(
            "You have the nut flush draw on the flop and the turn is a blank. Your draw…",
            "Still has about 9 outs, roughly 18% to come on the river.",
            ["Now has 0 outs", "Is already a flush", "Has 20 outs"],
            "A blank does not fill the draw and does not add flush outs. One card left means outs times about 2.",
        ),
        _q(
            "The turn pairs the top card. Who gains trips?",
            "Players who had that card in their hand, which is more often the preflop raiser on an ace-high board.",
            ["Only the small blind, by rule", "Everyone equally, including folded hands", "Only pocket pairs that do not match the ace"],
            "If the ace pairs, Ax in the raiser’s range makes trips. The caller has fewer aces.",
        ),
        _q(
            "A turn four-straight (9 on QJT) means…",
            "Any eight or king already had the straight, and one-pair hands just got much worse.",
            ["Nothing completed", "Only flushes got there", "The board cannot be a straight"],
            "Queen-jack-ten-nine is four to a straight. Kings and eights made it. Do not keep betting ace-high.",
        ),
    ],
)

add(
    "lesson-06-01-03-turn-card-effects-check",
    "Turn-card effects check",
    [
        _q(
            "Which turn is the biggest scare card on Th 8h 3c?",
            "7h, putting a third heart and a straight card out.",
            ["2c, a low offsuit brick", "3d, pairing the three", "Td, pairing the ten"],
            "The heart completes the flush and connects. Pairing the ten is a smaller change for the raiser.",
        ),
        _q(
            "You were ahead with top pair. The turn completes the obvious flush and you have none. Your equity…",
            "Dropped against any calling range that had flush draws.",
            ["Went to 100%", "Stayed the same", "Only matters if you are all-in"],
            "Draws that called the flop got there. Update the range before you barrel.",
        ),
        _q(
            "A brick favors the player who…",
            "Already had the stronger made-hand range on the flop.",
            ["Missed every draw and has no pair", "Folded", "Has fewer strong hands"],
            "When nothing completes, the flop leader is still the leader.",
        ),
        _q(
            "Before the river, re-rank the hand because…",
            "The turn can change both the nuts and how many outs remain.",
            ["The flop action is binding", "Outs never change", "The dealer will tell you the winner"],
            "A plan that ignores the turn card is a flop plan, not a turn plan.",
        ),
    ],
)

add(
    "lesson-06-02-01-barrels-checks-and-turn-sizing",
    "Barrels, checks, and turn sizing",
    [
        _q(
            "A second barrel is more attractive when…",
            "The turn helps your betting range or you still have real equity.",
            ["The turn completes the caller’s draw and you have air", "You are multiway with ace-high", "The caller has never folded"],
            "Barrel cards that improve you or pressure exactly the hands that called the flop.",
        ),
        _q(
            "A delayed bet means…",
            "You checked the flop and bet the turn.",
            ["You bet the flop and the turn and the river without looking", "You only check", "You fold the turn after betting the flop"],
            "Checking back the flop and betting a helpful turn is a delayed c-bet, not a second barrel.",
        ),
        _q(
            "Checking the turn with showdown value is right when…",
            "A bet would mostly be called by better and fold out worse.",
            ["You have the nuts", "You have a draw that must charge", "The pot is heads-up and you are facing an all-in"],
            "Thin hands that are ahead of air and behind value want a check, not a bloated pot.",
        ),
        _q(
            "Turn size should consider the river because…",
            "A large turn bet can set up an all-in river or leave you committed.",
            ["The river is not a street", "Stack size does not matter", "You must always leave exactly one big blind behind"],
            "Do not bet a size on the turn that you hate when called. Plan the stack.",
        ),
    ],
)

add(
    "lesson-06-02-02-select-turn-lines",
    "Select turn lines",
    [
        _q(
            "You c-bet top pair on K72 rainbow. The turn is a blank and you are called by one player. Best default?",
            "Bet again for value, smaller than a bluff on a scare card.",
            ["Check-fold", "All-in as the only size", "Give up because they called one street"],
            "Top pair is still ahead of a float. One call is not a set every time.",
        ),
        _q(
            "You c-bet air on K72. The turn is the third heart and you have no heart. Best default?",
            "Check. The scare card hits the caller’s draws more than your air.",
            ["Bet pot as a bluff every time", "All-in", "Bet small and call a raise"],
            "Give up when the card helps the range that continued and you have no equity and no blocker.",
        ),
        _q(
            "You checked back middle pair on the flop. The turn is a blank. A delayed bet…",
            "Can be a small value bet or a check again. It is not mandatory.",
            ["Must be all-in", "Is illegal after a flop check", "Means you had the nuts on the flop"],
            "Delay when the turn helps you or when a small bet gets worse to fold. Check again when you only have showdown.",
        ),
        _q(
            "Out of position, you check-called the flop with a draw and the turn fills it. You should…",
            "Bet or raise for value. The draw became a made hand.",
            ["Fold", "Check-fold the nuts", "Only call if they bet the minimum"],
            "When the draw arrives, stop playing it like a draw. Charge worse hands.",
        ),
    ],
)

add(
    "lesson-06-02-03-turn-lines-check",
    "Turn lines check",
    [
        _q(
            "Which turn barrel is the clearest give-up?",
            "Air, no blocker, on the card that completes the caller’s flush draw.",
            ["Top pair on a brick", "A set on any turn", "The nut flush when it completes"],
            "No equity and a card that helped them is a check.",
        ),
        _q(
            "Pot and stack planning means…",
            "Choosing a turn size that still leaves a sane river bet or a fold.",
            ["Betting your stack on every street", "Ignoring the river", "Matching the big blind only"],
            "If the turn bet commits you, be sure the hand wants to be committed.",
        ),
        _q(
            "A probe bet is…",
            "A small bet after the preflop raiser checked to you.",
            ["An all-in with air", "A check", "A preflop limp"],
            "Probing punishes a raiser who gave up the flop. It is not a license to blast.",
        ),
        _q(
            "You barrel the turn and get raised. With one pair and no draw you usually…",
            "Fold. A turn raise is a strong range.",
            ["Call because you bet", "Jam every time", "Limp"],
            "The raise represents the hands that beat one pair. Continue with strong hands and strong draws, not with weak pairs.",
        ),
    ],
)

add(
    "lesson-06-03-01-thin-and-thick-river-value",
    "Thin and thick river value",
    [
        _q(
            "Thick value is a hand that…",
            "Beats most of the hands that will call a large bet, such as a set or the nuts.",
            ["Barely beats a bluff-catcher", "Is ace-high", "Loses to every call"],
            "Bet large when worse hands still call and better hands are rare.",
        ),
        _q(
            "Thin value is a hand that…",
            "Beats some worse calls but loses to a lot of the continuing range.",
            ["Is always a check", "Is a pure bluff", "Must be all-in or it is not value"],
            "Thin value uses a smaller size, and only against opponents who call too wide.",
        ),
        _q(
            "Bet-fold means…",
            "You bet for value and fold if they raise, because their raise beats you.",
            ["You bet and must call any raise", "You check and fold", "You only bluff"],
            "A value bet is not a decision to stack off. If you would hate a raise, plan to fold to it.",
        ),
        _q(
            "Against a nit who only calls the river with better, thin value…",
            "Becomes a check. They do not pay you with worse.",
            ["Should be an overbet bluff", "Should be larger", "Is required"],
            "Value needs worse hands to call. A nit removes those calls.",
        ),
    ],
)

add(
    "lesson-06-03-02-choose-river-value-bets",
    "Choose river value bets",
    [
        _q(
            "You have the nut flush on the river against one opponent who calls too much. Best default?",
            "Bet large. Thick value.",
            ["Check so you can trap a raise that will not come", "Bet the minimum only", "Fold"],
            "The nuts want a big call from worse flushes, sets, and stubborn one-pair hands.",
        ),
        _q(
            "You have top pair, decent kicker, on a dry river against a calling station. A small value bet…",
            "Can be right. They call with worse pairs.",
            ["Is a bluff", "Must be a check because top pair is weak", "Must be all-in or nothing"],
            "Stations pay thin value. Do not turn the bet into a size only the nuts can call.",
        ),
        _q(
            "Same top pair against a tight player who folds one pair. Best default?",
            "Check. A bet gets called by better and folds out worse.",
            ["Overbet as thin value", "All-in", "Bet and call a shove"],
            "If they only continue when they beat you, the bet is not value.",
        ),
        _q(
            "You bet the river for value and face a raise. With one pair you…",
            "Fold most of the time. River raises are strong, especially live.",
            ["Always call", "Always re-raise", "Call because the bet was for value"],
            "Live river raises are value-heavy. One pair is a bluff-catcher at best, and usually a fold to the raise.",
        ),
    ],
)

add(
    "lesson-06-03-03-river-value-check",
    "River value check",
    [
        _q(
            "Which hand is thick value on a completed flush board?",
            "The ace-high flush.",
            ["Ace-high with no pair", "Bottom pair", "A missed gutshot"],
            "The nut flush beats the hands that call. The others are not value.",
        ),
        _q(
            "Sizing follows the hand: large with the nuts, smaller or none when…",
            "Only better hands call.",
            ["You have the nuts against a station", "You want a worse pair to call a station", "The bet is thick value"],
            "If the call is always better, check. If worse calls, bet.",
        ),
        _q(
            "A value bet that you will call a raise with should be…",
            "A very strong hand, not a thin one-pair bet.",
            ["Any bet", "Ace-high", "A bluff"],
            "Calling a raise is a stronger claim than betting. Do not bluff-catch yourself with a thin value bet.",
        ),
        _q(
            "Checking the nuts against a player who never bluffs and never bets is…",
            "A mistake. Bet so they can call.",
            ["Mandatory", "The only way to win", "Required by the rules"],
            "Traps need an opponent who will bet. If they will not, you must bet yourself.",
        ),
    ],
)

add(
    "lesson-06-04-01-bluff-selection-and-blockers",
    "Bluff selection and blockers",
    [
        _q(
            "A blocker bluff works better when you hold…",
            "A card that removes the nuts from their calling range, such as the ace of the flush suit when you do not have a flush.",
            ["A card that blocks their folds", "No blockers and no pair, chosen at random", "The board pair, which you then fold"],
            "Block the hands that call, not the hands that fold.",
        ),
        _q(
            "Bluffing a calling station is usually…",
            "A mistake. They call with the hands you needed to fold.",
            ["The highest-value bluff", "Required for balance", "Better than bluffing a nit"],
            "Bluffs need folds. Stations do not fold. Value-bet them instead.",
        ),
        _q(
            "An overbet bluff is for…",
            "Polarized spots: the nuts or a selected bluff, not a medium pair.",
            ["Every missed draw", "Thin value", "Bottom pair"],
            "A huge size represents a very strong hand. Medium strength should not use it.",
        ),
        _q(
            "You unblock their folds when…",
            "The cards you hold are the ones they would have folded, so more of those folds are still in the deck for them.",
            ["You hold the ace of their flush", "You have the nuts", "You bet small"],
            "Good bluffs block calls and leave their folds in the deck. Holding a hand they fold removes a bluff candidate from them and is the wrong blocker.",
        ),
    ],
)

add(
    "lesson-06-04-02-select-river-bluffs",
    "Select river bluffs",
    [
        _q(
            "The river completes a heart flush. You have Ah and no pair, no heart besides the ace. Against one thinking opponent…",
            "This is a possible bluff. You block the nut flush.",
            ["This is the nut flush already", "You must fold without betting because an ace cannot bluff", "You should value-bet ace-high"],
            "One heart in your hand is not a flush. The ace removes the best calling hand.",
        ),
        _q(
            "Same completed flush, you have 72 with no heart against a station. Best default?",
            "Check. You do not block the nuts and they will not fold.",
            ["Overbet bluff", "All-in", "Value bet"],
            "No blocker and no fold equity is a give-up.",
        ),
        _q(
            "You missed a draw and the river is a blank. The opponent has called two streets from a tight range. A bluff…",
            "Is usually a give-up. Their range is strong and the card did not scare them.",
            ["Is mandatory", "Works because blanks scare tight players", "Should be an overbet with bottom pair"],
            "Scare cards and blockers create bluffs. A blank against a strong caller does not.",
        ),
        _q(
            "Which hand should not be turned into a bluff?",
            "A medium pair that beats some worse hands and loses to a raise.",
            ["Ace-high that blocks the nuts and loses to any call", "A missed draw with the nut blocker", "Air against a folder"],
            "Medium pairs are bluff-catchers or thin value, not bluffs. Betting them as a bluff folds out worse and gets called by better.",
        ),
    ],
)

add(
    "lesson-06-04-03-river-bluffs-check",
    "River bluffs check",
    [
        _q(
            "Pick the better bluff.",
            "The ace of the flush suit, no pair, against one opponent who can fold.",
            ["72 with no blocker against a station", "Bottom pair against a nit who only calls with better", "Any hand, at random"],
            "Blocker plus fold equity. The others have neither.",
        ),
        _q(
            "Polarized means…",
            "Your betting range is very strong hands and selected bluffs, not medium strength.",
            ["You bet the same size with every hand", "You only check", "You bet only medium pairs"],
            "Overbets and large river bets tell this story. Do not put second pair in that range.",
        ),
        _q(
            "A bluff that gets called is…",
            "A failed bluff. Do not add more chips with the same air.",
            ["A value bet", "A sign you should raise again", "Profit, because you tried"],
            "Once they call, ace-high does not improve. Give up.",
        ),
        _q(
            "Live populations make pure bluffs…",
            "Less profitable, because they under-bluff and over-call in different spots. Pick opponents who actually fold.",
            ["Automatic profit", "Illegal", "Required every river"],
            "Bluff the folders. Do not bluff the callers. Do not assume a solver frequency at a live table.",
        ),
    ],
)

add(
    "lesson-06-05-01-calling-raising-and-folding-rivers",
    "Calling, raising, and folding rivers",
    [
        _q(
            "A bluff-catcher is…",
            "A hand that beats bluffs and loses to value.",
            ["The nuts", "Air", "A draw that is still live on the river"],
            "The river is the last card. Draws that missed are air. Bluff-catchers are made hands in the middle.",
        ),
        _q(
            "Live players under-bluff big river bets. The adjustment is…",
            "Fold more bluff-catchers than a solver chart says, especially against tight players.",
            ["Call every bluff-catcher", "Raise every bluff-catcher", "Fold the nuts"],
            "If they rarely bluff, a bluff-catcher is a fold. You do not need to hero-call to be balanced.",
        ),
        _q(
            "Raising the river as a bluff is…",
            "Rare. Most live river raises should be value.",
            ["The standard defense", "Required with every bluff-catcher", "Safer than calling"],
            "A raise folds out bluffs and gets called by better. Value raises are the nuts.",
        ),
        _q(
            "You beat their betting range. The action is…",
            "Call or raise for value, depending how often they continue worse.",
            ["Fold", "Only check", "Muck without looking"],
            "If you are ahead of the bet, you do not fold. Raising is for when worse hands still continue.",
        ),
    ],
)

add(
    "lesson-06-05-02-face-river-bets",
    "Face river bets",
    [
        _q(
            "A nit bets the river large. You have a medium pair. Best default?",
            "Fold. Their large bet is value.",
            ["Call. Medium pairs must hero-call nits", "Raise as a bluff", "Call because the pot is big and ignore the size"],
            "Pot odds matter, and a nit’s large river bet is still too strong for a medium pair most of the time.",
        ),
        _q(
            "A loose, aggressive player bets small on the river. You have top pair. Best default?",
            "Call. You beat bluffs and worse value.",
            ["Fold top pair to any bet", "All-in raise with no plan", "Fold because populations never bluff"],
            "Small bets from aggressive players include bluffs. Top pair is a call, not an automatic raise.",
        ),
        _q(
            "You have the second nuts and a tight player bets the river. Best default?",
            "Call, and raise only if worse hands will pay the raise.",
            ["Fold", "Always fold the second nuts", "Raise all-in with no worse hand that calls"],
            "Do not fold a monster. Do not raise off the only worse hands that would have called a smaller bet if they will only call with better.",
        ),
        _q(
            "You missed your draw and they bet the river. You should…",
            "Fold. Air does not bluff-catch.",
            ["Call because your draw was strong on the flop", "Raise", "Call if the draw was a flush draw"],
            "The river ended the draw. No pair and no blocker plan is a fold to a bet.",
        ),
    ],
)

add(
    "lesson-06-05-03-facing-river-action-check",
    "Facing river action check",
    [
        _q(
            "Which hand calls a large river bet from an unknown more often?",
            "Top pair, strong kicker, on a dry board where missed draws are possible.",
            ["Air", "A missed gutshot", "Bottom pair against a nit’s overbet"],
            "Bluff-catch with hands that beat the misses, not with air, and not against a range that never misses.",
        ),
        _q(
            "A river check-raise from a quiet player is…",
            "Very strong. Fold bluff-catchers.",
            ["Always a bluff", "A mandatory call with any pair", "Ignored"],
            "Live check-raises on the river are the nuts far more often than a bluff.",
        ),
        _q(
            "Pot odds can make a call correct when…",
            "You win often enough given the price, even if you are not a favorite.",
            ["You have air", "You are facing a bet of your entire stack with 72", "The price does not matter"],
            "A tiny bet can be called with a bluff-catcher that should fold to an overbet.",
        ),
        _q(
            "The integrated river question is…",
            "Does my hand beat bluffs, beat value, or beat neither, and does this opponent bluff?",
            ["Did I win the last hand", "What is the jackpot", "How many chips are in the rack"],
            "Hand class plus opponent. That is the decision. Chip results do not grade it.",
        ),
    ],
)

add(
    "lesson-07-01-01-limped-pot-strategy",
    "Limped pot strategy",
    [
        _q(
            "A limped pot’s ranges are…",
            "Wide and capped. Few players have the nuts, and many hands are weak.",
            ["As strong as a 4-bet pot", "Only aces", "Face-up"],
            "Nobody showed strength. Do not play it like a raised pot.",
        ),
        _q(
            "Value betting in a limped pot should be…",
            "Thinner and usually smaller. Worse hands call more often.",
            ["All-in or check only", "The same huge size as a 4-bet pot", "Illegal"],
            "Wide ranges pay small bets with worse pairs. A pot-size bet folds out the hands you beat.",
        ),
        _q(
            "Large bluffs in limped pots are a mistake because…",
            "People call too wide and your fold equity is poor.",
            ["Limped pots are always folded to", "Bluffs are mandatory", "The pot is heads-up by rule"],
            "Do not blast weak made hands or air into a family pot.",
        ),
        _q(
            "With a strong hand in a limped pot you still…",
            "Bet for value. Checking every strong hand lets them realize equity for free.",
            ["Check the nuts always", "Fold top pair", "All-in every time"],
            "Capped ranges still call. Build the pot with real hands. Just do not use a raised-pot bluff size.",
        ),
    ],
)

add(
    "lesson-07-01-02-play-limped-pots",
    "Play limped pots",
    [
        _q(
            "Four players limped. You have top pair on a dry board in position. Best default?",
            "Bet small for value.",
            ["Check because limped pots cannot be bet", "All-in", "Pot-size bluff with the same hand"],
            "Top pair is ahead of a wide field. A small bet gets calls from worse without inflating a multiway pot.",
        ),
        _q(
            "Same limped pot, you have ace-high and no draw, multiway. Best default?",
            "Check. Air does not bluff into four players.",
            ["Pot bet", "All-in", "Bet large because the pot was limped"],
            "Multiway limped pots are for made hands, not for steals.",
        ),
        _q(
            "You flop a set in a limped pot. Best default?",
            "Bet. Do not give a free card to a wide field.",
            ["Check forever", "Fold", "Bet one chip"],
            "Sets want value from the many one-pair hands that limped.",
        ),
        _q(
            "Bottom pair, limped, multiway, someone bets pot. You should…",
            "Fold. The size and the field are too strong for bottom pair.",
            ["Call", "Raise all-in", "Call and stack off"],
            "A big bet into a limped pot is more honest than a small one. Weak pairs fold.",
        ),
    ],
)

add(
    "lesson-07-01-03-limped-pots-check",
    "Limped pots check",
    [
        _q(
            "Compared with a single-raised pot, a limped pot should be played…",
            "Smaller, with fewer bluffs and thinner value.",
            ["Identically", "Only all-in", "As if someone 4-bet"],
            "The preflop action is the tell. No raise means wider, weaker ranges.",
        ),
        _q(
            "Oversized bets with one pair in a limped pot…",
            "Fold out the worse hands and get called by better.",
            ["Are the standard value size", "Always get folds", "Are required"],
            "That is the opposite of thin value.",
        ),
        _q(
            "A limped flop that is four-way changes bluffing by…",
            "Cutting it. More players, fewer successful bluffs.",
            ["Doubling it", "Making air profitable", "Removing position"],
            "Player count and pot family stack. Both say check the air.",
        ),
        _q(
            "You may still isolate a limper preflop. After the flop is already multiway and limped…",
            "The isolation failed. Play a multiway pot, not a heads-up raised pot.",
            ["The pot becomes heads-up by rule", "You must jam", "Ranges stay the same as a 3-bet pot"],
            "Name the pot you are actually in.",
        ),
    ],
)

add(
    "lesson-07-02-01-single-raised-pot-strategy",
    "Single-raised pot strategy",
    [
        _q(
            "In a single-raised pot the preflop raiser…",
            "Has the initiative and more strong hands on high dry boards.",
            ["Must check every flop", "Has a capped range like a limper", "Is always out of position"],
            "The open is the aggressor’s advantage. Use it on boards that fit the raising range.",
        ),
        _q(
            "The caller’s plan is often…",
            "Check to the raiser, continue with pairs and draws, and fold air.",
            ["Donk every board", "Stack off bottom pair", "Lead all-in on ace-high"],
            "The caller realizes equity by checking and choosing, not by leading weak hands.",
        ),
        _q(
            "In position the raiser can…",
            "Bet dry boards small and check back boards that favor the caller.",
            ["Only bet when out of position", "Never check", "Use one size on every texture"],
            "Position plus the initiative is the single-raised advantage.",
        ),
        _q(
            "Delayed lines belong in single-raised pots when…",
            "The flop was checked and the turn helps the player who bets later.",
            ["Someone is all-in preflop", "The pot was 4-bet", "The board is already the nuts for everyone"],
            "A missed flop c-bet can become a turn bet. That is a single-raised pattern, not a limped one.",
        ),
    ],
)

add(
    "lesson-07-02-02-play-single-raised-pots",
    "Play single-raised pots",
    [
        _q(
            "You opened the button, big blind called, flop A72 rainbow, you have AQ. Best default?",
            "Small value bet.",
            ["Check back the nuts-adjacent hand with no plan", "All-in", "Fold"],
            "Top pair top kicker on a dry single-raised board is a standard bet.",
        ),
        _q(
            "You are the big blind caller on 9h 8h 7c with a pair and a draw. The button bets small. Best default?",
            "Continue. You have a real hand and equity.",
            ["Fold a pair and a draw to a small bet", "All-in with no thought about the raise size", "Donk the river blind"],
            "Single-raised wet boards are where the caller’s range wakes up. Do not fold equity to a small bet.",
        ),
        _q(
            "You opened, got called, and the flop is 876 two-tone. You have ace-high. Best default?",
            "Check back. This single-raised board favors the caller.",
            ["Pot bluff", "All-in", "Bet because every open must c-bet"],
            "Initiative is not a duty to bet every flop.",
        ),
        _q(
            "Single-raised, out of position, you have a set and they bet. Best default?",
            "Raise for value.",
            ["Fold", "Only call and never raise", "Check-fold the turn"],
            "Sets in single-raised pots want a bigger pot while worse hands and draws exist.",
        ),
    ],
)

add(
    "lesson-07-02-03-srp-check",
    "SRP check",
    [
        _q(
            "A single-raised pot is not a limped pot because…",
            "Someone showed a stronger range by raising.",
            ["The blinds are dead", "Nobody can bet", "Stacks do not matter"],
            "Use the raiser’s range, not a limp range, when you put them on hands.",
        ),
        _q(
            "Which c-bet is standard?",
            "Small, in position, dry ace-high, as the raiser.",
            ["Huge, multiway, with air on 876", "A donk with bottom pair into the raiser", "All-in with a gutshot"],
            "Small on dry high boards. Not the other three.",
        ),
        _q(
            "The caller should lead most often when…",
            "The flop hits the calling range much harder than the opening range.",
            ["The flop is A72", "They have air", "They are in position and can check back"],
            "Leads are the exception inside single-raised pots.",
        ),
        _q(
            "If the flop checks through, the turn plan…",
            "Starts fresh. Either player can bet a card that helps them.",
            ["Is over. The hand checks down", "Must be an all-in", "Belongs only to the big blind"],
            "A checked flop is a delayed-bet spot, not a surrender.",
        ),
    ],
)

add(
    "lesson-07-03-01-3-bet-pot-strategy",
    "3-bet pot strategy",
    [
        _q(
            "Three-bet pots have…",
            "Stronger ranges and a lower stack-to-pot ratio than single-raised pots.",
            ["Weaker ranges than a limp", "The same SPR as a limped pot", "No position"],
            "More money is in and the hands are tighter. Commitment comes sooner.",
        ),
        _q(
            "Top pair, good kicker, in a 3-bet pot at 100bb is often…",
            "Strong enough to continue and often to stack off on dry boards.",
            ["An automatic fold", "Air", "The same as bottom pair in a family pot"],
            "The ranges are strong, so top pair good kicker is near the top, not a bluff-catcher only.",
        ),
        _q(
            "Speculative hands that miss in a 3-bet pot should…",
            "Fold more. The price to continue is higher and implied odds are worse.",
            ["Call any bet because they were suited", "All-in with no pair", "Limp"],
            "You already paid a 3-bet price. Missing does not entitle you to another street.",
        ),
        _q(
            "Bluff frequency in 3-bet pots goes…",
            "Down versus single-raised pots. Both ranges are stronger.",
            ["Up, because the pot is bigger so bluffs always work", "To 100%", "To zero even with the nuts"],
            "Strong ranges call more and fold less. Value more, bluff less.",
        ),
    ],
)

add(
    "lesson-07-03-02-play-3-bet-pots",
    "Play 3-bet pots",
    [
        _q(
            "You 3-bet preflop and the flop is A72 rainbow. You have AQ. Best default?",
            "Bet. Top pair is strong in a 3-bet pot and the board is dry.",
            ["Check-fold", "Min-bet and fold to a tiny raise", "Treat it like a limped pot and check the nuts-adjacent hand"],
            "This is value and a range advantage. Bet.",
        ),
        _q(
            "You called a 3-bet in position with 76s and missed a dry ace-high flop. Best default?",
            "Fold to a bet, or check back if they check. You have almost no equity.",
            ["Call a pot bet", "Raise all-in", "Float every ace-high board"],
            "Suited connectors need a flop. This one missed. 3-bet pots do not pay floats the way single-raised pots do.",
        ),
        _q(
            "You have KK in a 3-bet pot on 9h 8h 7c. Best default?",
            "Bet, but respect a large raise. The board is wet and your overpair is no longer the nuts.",
            ["Fold to any bet", "Check-fold the nuts", "Ignore the texture"],
            "An overpair bets for value and protection. A shove or a big raise can mean a straight or a set.",
        ),
        _q(
            "Stack-to-pot ratio is about 4. You have top pair top kicker on a dry board. Getting it in…",
            "Is often correct. There is not enough room to fold later.",
            ["Is always a fold", "Is only for flushes", "Requires 200 big blinds behind"],
            "Low SPR means one pair of good quality is a commit hand on safe boards.",
        ),
    ],
)

add(
    "lesson-07-03-03-3-bet-pots-check",
    "3-bet pots check",
    [
        _q(
            "Compared with a single-raised pot, continue…",
            "Tighter with missed hands and wider with strong one-pair hands.",
            ["Looser with every miss", "The same", "Only with air"],
            "The pot is bigger and the ranges are stronger. Missed hands go, good pairs stay.",
        ),
        _q(
            "A small pair that did not set, facing a 3-bet-pot c-bet on an ace-high board…",
            "Is usually a fold. You are behind and have little equity.",
            ["Is a stack-off", "Is the nuts", "Must call because of set value that already failed"],
            "Set-mining already failed. Do not pay a second large bet.",
        ),
        _q(
            "Position still matters in 3-bet pots because…",
            "The in-position player realizes more equity and can check back marginal hands.",
            ["3-bet pots are always all-in before the flop", "Position is removed by the 3-bet", "The caller acts last by rule"],
            "Lower SPR does not delete position. It shortens the decision tree.",
        ),
        _q(
            "Which description is a 3-bet pot?",
            "An open, a reraise, and a call. No second reraise.",
            ["Three limps", "An open and one call", "A 4-bet and a call"],
            "Count the raises. One reraise is a 3-bet pot. Another raise is a 4-bet pot.",
        ),
    ],
)

add(
    "lesson-07-04-01-4-bet-and-all-in-pot-strategy",
    "4-bet and all-in pot strategy",
    [
        _q(
            "Four-bet pots at 100bb usually have…",
            "A very low stack-to-pot ratio. Many flops are a commit-or-fold decision.",
            ["Deep implied odds for suited connectors", "The same play as a limped pot", "No ranges"],
            "A lot of money is already in. You cannot play a long postflop tree.",
        ),
        _q(
            "On a dry flop in a 4-bet pot, KK…",
            "Continues. Folding an overpair because the board has a nine is a large mistake.",
            ["Folds to any bet", "Is air", "Must be slow-played until the river"],
            "The range is aces, kings, and a few other hands. Kings are ahead of almost all of it on a dry nine-high board.",
        ),
        _q(
            "When stacks are already all-in, the skill is…",
            "Range versus range on the runout, not a new bet.",
            ["Folding the winning hand", "Betting again", "Changing your hole cards"],
            "You planned the get-in preflop or on the flop. The rest is equity.",
        ),
        _q(
            "Low SPR thresholds mean…",
            "Hands that are ahead now put the rest in, and hands with only implied odds fold.",
            ["Every hand stacks off", "No hand stacks off", "Only flushes may call"],
            "Do not call off a short stack with a gutshot. Do call off with an overpair.",
        ),
    ],
)

add(
    "lesson-07-04-02-play-4-bet-and-all-in-pots",
    "Play 4-bet and all-in pots",
    [
        _q(
            "100bb, 4-bet pot, flop 9s 4d 2c, you have KK and face a bet. Best default?",
            "Continue, usually by getting the rest in.",
            ["Fold. A nine is too scary", "Fold. Kings are a bluff", "Call and fold the turn on a blank"],
            "Dry nine-high does not beat kings in a 4-bet pot.",
        ),
        _q(
            "Same pot, you have A5s and missed. They bet. Best default?",
            "Fold. Your bluff 4-bet candidate has little equity and little room.",
            ["Stack off ace-high", "Call because you 4-bet", "Raise and call a jam with no pair"],
            "The 4-bet bluff needed a fold earlier. On this flop it is a give-up.",
        ),
        _q(
            "You are all-in preflop with QQ against a 100bb jam from the button. You should…",
            "Accept the runout. There is no more decision.",
            ["Fold after you called", "Bet the flop", "Ask for your cards back"],
            "The decision was the call. Play the board honestly when you review it. Do not invent new actions.",
        ),
        _q(
            "A wet flop in a 4-bet pot with AK and no pair, facing an all-in…",
            "Depends on the price and the range. It is not an automatic call just because you 4-bet.",
            ["Is always a call", "Is always a fold, even for a tiny price", "Is a limped-pot decision"],
            "Low SPR pushes you in with equity, but a board that hits sets and straights can make ace-high a fold if the price is bad.",
        ),
    ],
)

add(
    "lesson-07-04-03-4-bet-pots-check",
    "4-bet pots check",
    [
        _q(
            "Which hand is a clear continue on a dry 4-bet flop?",
            "KK",
            ["72o", "A missed suited connector with no pair and no draw", "J4o"],
            "Overpairs continue. Trash and missed speculative hands do not.",
        ),
        _q(
            "SPR near 1 means…",
            "The next bet is for the rest of the stack.",
            ["You have 500 big blinds behind", "You should open-limp", "Position disappears and so does the pot"],
            "Plan the all-in before you put in a small bet you cannot fold.",
        ),
        _q(
            "Reviewing an all-in pot is about…",
            "Whether the get-in was ahead of the range, not whether the river card was lucky.",
            ["The chip result only", "Blaming the dealer", "Changing the preflop range after you see the river"],
            "Decision quality, not the outcome.",
        ),
        _q(
            "A 4-bet pot and a 3-bet pot differ because…",
            "The 4-bet pot has stronger ranges and less stack behind.",
            ["They are identical", "The 4-bet pot is multiway by rule", "The 3-bet pot is always all-in"],
            "One more raise removes the marginal hands and the room to maneuver.",
        ),
    ],
)

add(
    "lesson-07-05-01-multiway-vs-heads-up-effects",
    "Multiway vs heads-up effects",
    [
        _q(
            "Adding players makes bluffs…",
            "Worse. Someone is more likely to have a hand.",
            ["Better, always", "Unchanged", "Mandatory"],
            "Fold equity is highest heads-up and lowest in a full ring pot.",
        ),
        _q(
            "Heads-up, the same top pair can…",
            "Bet and call more, because only one range remains.",
            ["Never bet", "Only fold", "Play like a nine-handed family pot"],
            "One opponent means more bluffs in their range and more folds.",
        ),
        _q(
            "Relative position multiway means…",
            "You still act after some players and before others. The player behind you matters.",
            ["Everyone acts at once", "The button is first", "Position does not exist multiway"],
            "A bet that the button can raise is worse than a bet when you close the action.",
        ),
        _q(
            "Uneven stacks multiway mean…",
            "You can only win the covered amount from each player. Side pots change who you value-bet.",
            ["The biggest stack always wins the side pot without cards", "Effective stack is the table maximum", "Short stacks cover everyone"],
            "A short all-in does not threaten the deep stack behind. Plan the side pot separately.",
        ),
    ],
)

add(
    "lesson-07-05-02-adjust-for-player-count",
    "Adjust for player count",
    [
        _q(
            "Heads-up on the river, a tight opponent checks to you and you have a medium pair. You might…",
            "Bet thin for value. One player can call worse.",
            ["Always check because medium pairs are air heads-up", "All-in bluff", "Fold to a check"],
            "Heads-up value is thinner than multiway value.",
        ),
        _q(
            "Five players on the flop, you have top pair weak kicker. Best default?",
            "Bet small or check. Do not bluff and do not stack off.",
            ["Pot bluff", "All-in", "Play it as heads-up"],
            "Weak kickers hate multiway pots. Someone has a better kicker or two pair more often.",
        ),
        _q(
            "You are between two players who have not acted. A bluff is…",
            "Worse than when you are last to act.",
            ["Better", "The same", "Required"],
            "Players behind can raise. Bluff when you close the action, not into a live button.",
        ),
        _q(
            "A short stack is all-in and a deep stack is behind. With a strong but not nut hand you…",
            "Can call the short stack and still fold to a huge side-pot bet.",
            ["Must call every side-pot bet because you called the short stack", "Ignore the deep stack", "Win both pots automatically"],
            "The two pots are different prices. Do not chain them into one decision.",
        ),
    ],
)

add(
    "lesson-07-05-03-player-count-check",
    "Player-count check",
    [
        _q(
            "Which pot allows the most bluffs?",
            "Heads-up.",
            ["Four-way", "Full ring, five players", "A family limped pot"],
            "One opponent, one range, the most folds.",
        ),
        _q(
            "Which value hand needs to be stronger as players are added?",
            "All of them. The calling range gets stronger when more people stay.",
            ["None. Value does not change", "Only bluffs get stronger", "Only the nuts get weaker"],
            "Multiway, wait for a better hand before you build a big pot.",
        ),
        _q(
            "From heads-up through full ring, the checkpoint is…",
            "Name the player count before you copy a heads-up line.",
            ["Ignore the extra players", "Use one chart for every table", "Bluff more as the table fills up"],
            "A nine-handed pot is not a heads-up pot with extra chips.",
        ),
        _q(
            "Postflop core ties together…",
            "Texture, hand class, position, street, pot family, and player count.",
            ["Only preflop charts", "Only the chip result", "Only the dealer button’s name"],
            "If you can name those and choose bet, check, call, raise, or fold, the core is in place.",
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
        if section["order"] not in (5, 6, 7):
            continue
        for unit in section["units"]:
            for lesson in unit["lessons"]:
                lesson["exerciseRefs"] = [lesson["id"]]
    for gate in catalog["milestoneGates"]:
        if gate["id"] != "postflop-core":
            continue
        required = list(gate["requiredObjectiveIds"])
        for extra in POSTFLOP_GATE_OBJECTIVES:
            if extra not in required:
                required.append(extra)
        gate["requiredObjectiveIds"] = required
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
    if len(LESSONS) != 45:
        raise SystemExit(f"expected 45 lessons, got {len(LESSONS)}")
    write_exercises()
    patch_catalog()
    write_bank()
    print(
        f"authored={len(LESSONS)} exercises={len(list(EX_DIR.glob('*.json')))} "
        f"bank={len(json.loads(BANK.read_text()))}"
    )


if __name__ == "__main__":
    main()
