#!/usr/bin/env python3
"""Author Sections 3–4 static exercises and sync generated catalogs.

Canonical exercises land in content/curriculum/v1/exercises/.
Does not overwrite an existing exercise file.
Live straddles, bomb pots, and rake are conceptual only — questions do not
require the engine to deal them.
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

PREFLOP_GATE_OBJECTIVES = (
    "obj-3bet-construction",
    "obj-squeeze-coldcall",
    "obj-4bet-allin",
    "obj-preflop-context",
)

# Extra filter tags. Existing topic tags are kept.
OBJECTIVE_TAGS: dict[str, dict[str, list[str]]] = {
    "obj-ep-mp-opens": {
        "street": ["preflop"],
        "position": ["utg", "mp"],
        "action": ["open"],
    },
    "obj-late-opens": {
        "street": ["preflop"],
        "position": ["co", "btn"],
        "action": ["open"],
        "playerCount": ["short-handed"],
    },
    "obj-vs-limpers": {
        "street": ["preflop"],
        "action": ["iso", "open"],
    },
    "obj-vs-open": {
        "street": ["preflop"],
        "action": ["call", "3bet"],
    },
    "obj-blind-defense": {
        "street": ["preflop"],
        "position": ["sb", "bb"],
        "action": ["defend"],
    },
    "obj-3bet-construction": {
        "street": ["preflop"],
        "action": ["3bet"],
    },
    "obj-squeeze-coldcall": {
        "street": ["preflop"],
        "action": ["squeeze", "cold-call"],
    },
    "obj-4bet-allin": {
        "street": ["preflop"],
        "action": ["4bet", "all-in"],
    },
    "obj-preflop-context": {
        "street": ["preflop"],
        "stack": ["short", "deep"],
        "action": ["adjust"],
    },
}


def add(lesson_id: str, title: str, questions: list[Q]) -> None:
    LESSONS[lesson_id] = (title, questions)


add(
    "lesson-03-01-01-early-and-middle-position-opens",
    "Early and middle position opens",
    [
        (
            "At a 9-handed $2/$5 game with 100 big blinds, which open is the tightest?",
            0,
            [
                "Under the gun",
                "Hijack",
                "Cutoff",
                "Button",
            ],
            "Earlier position acts first after the flop and faces more players, so the open is tighter.",
        ),
        (
            "Which hand is a standard open from under the gun at that table?",
            2,
            [
                "JTo",
                "72o",
                "AKo",
                "86s",
            ],
            "AKo is a clear early-position open. Weak offsuit broadways and low suited connectors are folds from UTG.",
        ),
        (
            "Why is AJo usually a fold from a tight 9-handed under the gun?",
            1,
            [
                "Aces are never playable in early position.",
                "It is dominated when a later player continues with a stronger ace or king.",
                "Offsuit hands cannot win at showdown.",
                "The big blind is forced to call any early open.",
            ],
            "AJo looks strong and still loses often to AK, AQ, and AJ that continue behind.",
        ),
        (
            "A normal live open with no limpers is closest to which size?",
            3,
            [
                "The minimum raise, about 2 big blinds, every time.",
                "All-in, because live cash has no postflop play.",
                "Exactly one big blind.",
                "About 3–5 big blinds, larger than a typical online open.",
            ],
            "Live opens are bigger than online 2–2.5bb opens so the field does not get a cheap flop.",
        ),
    ],
)

add(
    "lesson-03-01-02-choose-ep-mp-opens",
    "Choose EP/MP opens",
    [
        (
            "9-handed, 100bb, folded to under the gun. What do you do with 22?",
            0,
            [
                "Fold",
                "Limp, then call any raise",
                "Open all-in",
                "Open and call a 3-bet for set value",
            ],
            "A small pair under the gun is dominated by the opens behind and plays poorly at 100bb from first position.",
        ),
        (
            "Same seat, folded to you, with QQ. What is the clear mistake?",
            2,
            [
                "Opening to 3 big blinds",
                "Opening to 5 big blinds",
                "Limping so you can trap the blinds",
                "Opening and folding to a large 4-bet from a tight player",
            ],
            "Limping queens gives the table a cheap flop and invites multiway pots. Open them.",
        ),
        (
            "Middle position, folded to you, 100bb. Which hand moves from a UTG fold to an open?",
            1,
            [
                "72o",
                "AJo",
                "J4o",
                "T5o",
            ],
            "AJo is too dominated for a tight UTG open and becomes a reasonable middle-position open.",
        ),
        (
            "You are under the gun with KQs. Which plan fits a 100bb live open?",
            3,
            [
                "Limp and fold to any raise",
                "Open all-in for 100 big blinds",
                "Fold because suited kings are speculative",
                "Open to about 3–5 big blinds and continue versus a single reasonable 3-bet",
            ],
            "KQs is strong enough to open early and does not need an all-in or a limp.",
        ),
    ],
)

add(
    "lesson-03-01-03-ep-mp-opens-check",
    "EP/MP opens check",
    [
        (
            "Folded to the hijack at a 9-handed 100bb table. Which open is too loose?",
            2,
            [
                "99",
                "AQo",
                "J4o",
                "KQs",
            ],
            "J4o has no high-card strength and no suited playability. The others are standard hijack opens.",
        ),
        (
            "Under the gun opens to 3 big blinds. You are next with 76s and everyone else is still to act. Best default?",
            0,
            [
                "Fold",
                "Limp behind",
                "Call and see a flop out of position against a strong range",
                "All-in for 100 big blinds",
            ],
            "76s is a later-position hand. Calling an early open while still out of position is a clear mistake.",
        ),
        (
            "Which statement about early-position opens is right?",
            1,
            [
                "Open every suited hand from under the gun.",
                "The earlier you act, the stronger the hands you open.",
                "Position does not change an opening range.",
                "Under the gun should open wider than the button.",
            ],
            "More players remain and you will be out of position, so the range tightens.",
        ),
        (
            "100bb, middle position, folded to you with AKo. A player behind 3-bets to a normal size. What is the mistake?",
            3,
            [
                "4-betting for value",
                "Calling and playing a flop in position",
                "Continuing against an unknown 3-bettor",
                "Folding because any 3-bet means aces",
            ],
            "AKo is ahead of a normal 3-bet range. Folding it to one raise is far too tight.",
        ),
    ],
)

add(
    "lesson-03-02-01-late-position-and-short-handed-opens",
    "Late position and short-handed opens",
    [
        (
            "Folded to the button at 100bb. Which hand is now an open that was a fold under the gun?",
            1,
            [
                "Only AA",
                "76s",
                "72o at a full 9-handed table",
                "Nothing changes by position",
            ],
            "The button acts last postflop and can open suited connectors that are folds from early position.",
        ),
        (
            "The table is 6-handed instead of 9-handed. How should the earliest open change?",
            0,
            [
                "Open wider. That seat plays more like a full-ring hijack than a 9-handed UTG.",
                "Open only AA and KK.",
                "Limp every hand because fewer players means less value.",
                "Use the same 9-handed UTG range.",
            ],
            "Short-handed, the first seat is later in a full-ring sense, so the open widens.",
        ),
        (
            "Heads-up, you are the button and post the small blind. Which is true?",
            2,
            [
                "You should fold every hand except premiums.",
                "You act last preflop and first postflop.",
                "You act first preflop and last postflop, and you open much wider than in a full ring.",
                "72o is always a fold heads-up.",
            ],
            "Heads-up the button acts first preflop, last after the flop, and opens a very wide range.",
        ),
        (
            "Cutoff versus button at equal 100bb stacks, both folded to you. Who opens wider?",
            3,
            [
                "Cutoff, because more players remain.",
                "They open the same range.",
                "Cutoff, because the button is forced to fold.",
                "Button, because only the blinds remain and you act last postflop.",
            ],
            "The button steals wider. The cutoff still has the button left to act.",
        ),
    ],
)

add(
    "lesson-03-02-02-open-co-btn-and-short-handed",
    "Open CO/BTN and short-handed",
    [
        (
            "9-handed, 100bb, folded to the button with KJo. Best default?",
            1,
            [
                "Fold. Offsuit broadways are never opened.",
                "Open to about 3–5 big blinds.",
                "Limp. The button should never raise.",
                "All-in. Late position means stack off.",
            ],
            "KJo is a standard button open and a poor under-the-gun open.",
        ),
        (
            "6-handed, folded to the earliest seat with ATo at 100bb. Compared with 9-handed UTG, you should…",
            0,
            [
                "Open. This seat is much later than a full-ring UTG.",
                "Fold. The first seat is always a 9-handed UTG range.",
                "Limp. Short-handed games are passive.",
                "Open all-in for 100 big blinds.",
            ],
            "Six-handed early position is closer to a full-ring hijack or cutoff.",
        ),
        (
            "Folded to the cutoff with 72o at a 9-handed table. What do you do?",
            2,
            [
                "Open. Any two cards are a cutoff open.",
                "Limp. Seven-high plays well multiway.",
                "Fold. 72o is still too weak with the button and blinds behind.",
                "All-in so the blinds fold.",
            ],
            "The cutoff opens wide, not randomly. 72o is a fold until the game is extremely short-handed.",
        ),
        (
            "Button, 100bb, folded to you with 22. A reasonable plan is…",
            3,
            [
                "Fold. Pairs cannot be opened in late position.",
                "Open all-in.",
                "Limp and fold to a min-raise.",
                "Open, and fold to a large 3-bet from a tight blind.",
            ],
            "Small pairs open on the button for set value and position, then release versus a strong reraise.",
        ),
    ],
)

add(
    "lesson-03-02-03-late-position-opens-check",
    "Late position opens check",
    [
        (
            "Which open range is widest at the same 100bb stack?",
            3,
            [
                "9-handed under the gun",
                "9-handed hijack",
                "9-handed cutoff",
                "Heads-up button",
            ],
            "Fewer opponents and position make the heads-up button the widest open.",
        ),
        (
            "Folded to the button with A5s. What is the mistake?",
            0,
            [
                "Folding because the ace is not suited to a broadway card",
                "Opening to 3 big blinds",
                "Folding to a tight big-blind 3-bet",
                "Taking a flop in position when called",
            ],
            "Suited aces are standard button opens. They are not under-the-gun trash.",
        ),
        (
            "The game just dropped from 9-handed to 5-handed. Your unopened range should…",
            1,
            [
                "Stay frozen at the 9-handed UTG chart.",
                "Widen, because each seat is later relative to a full ring.",
                "Become limp-only.",
                "Become all-in or fold with no opens.",
            ],
            "Player count changes position. Five-handed opens are wider than full-ring opens from the same seat name.",
        ),
        (
            "Cutoff opens, and you are on the button with 100bb and JTo. Calling can be fine. What is the clear mistake?",
            2,
            [
                "Calling a single 3bb open in position",
                "Folding if a third player squeezes large",
                "3-bet shoving 100 big blinds",
                "Preferring a call over an all-in",
            ],
            "JTo can take a flop in position. Stacking off 100bb preflop with it is not a value jam.",
        ),
    ],
)

add(
    "lesson-03-03-01-opening-over-limpers-live",
    "Opening over limpers live",
    [
        (
            "One player limps and the action is on your button with AQo at 100bb. Best default?",
            1,
            [
                "Fold. A limp means the pot is already taken.",
                "Raise larger than your normal no-limper open.",
                "Limp behind. Never raise a limper.",
                "All-in for 100 big blinds.",
            ],
            "Isolate the limper with a stronger hand and a bigger size so you do not play a family pot.",
        ),
        (
            "Why does the raise get bigger when more players limp?",
            0,
            [
                "Each limper adds dead money you want to deny, so you add size.",
                "Limpers are forced to fold by the rules.",
                "The big blind shrinks after a limp.",
                "More limpers mean you should raise smaller.",
            ],
            "A common live adjustment is your normal open plus about one extra big blind per limper.",
        ),
        (
            "Three limpers, deep stacks, you are on the button with 22. Which is the clear mistake?",
            3,
            [
                "Calling and trying to flop a set",
                "Raising to isolate",
                "Folding if a player then reraises very large",
                "Folding because pairs cannot be played multiway",
            ],
            "Deep, multiway, a small pair has set value. Folding it automatically is too tight.",
        ),
        (
            "You have KTo in middle position after two limps. What is the problem with limping behind?",
            2,
            [
                "KTo is the nuts.",
                "Limping is required by the rules once someone limps.",
                "You play a dominated offsuit hand multiway and out of position against later raises.",
                "Offsuit broadways always realize equity.",
            ],
            "KTo is a raise-or-fold hand over limps, not a multiway limp.",
        ),
    ],
)

add(
    "lesson-03-03-02-attack-and-isolate-limpers",
    "Attack and isolate limpers",
    [
        (
            "Button, one limp, 100bb, you hold AJs. Which size is the isolate?",
            1,
            [
                "Call the one-chip limp",
                "Raise to about your normal open plus one big blind",
                "Raise to 1.5 big blinds total",
                "Check. The button cannot raise a limp.",
            ],
            "An isolate is a raise, sized up for the dead limp, not a flat.",
        ),
        (
            "Under the gun limps and you are in the hijack with 72o. What do you do?",
            0,
            [
                "Fold",
                "Limp behind",
                "Isolate large",
                "All-in",
            ],
            "A limp is not a signal to play trash. 72o does not isolate.",
        ),
        (
            "You isolate a limper from the cutoff and the big blind calls as well. What changed?",
            2,
            [
                "The pot is now heads-up by rule.",
                "You should automatically stack off any pair.",
                "You are multiway. Continue more carefully than in a heads-up raised pot.",
                "Your isolate was illegal.",
            ],
            "Isolation fails when extra players call. Speculative hands and bluffs go down in value.",
        ),
        (
            "Deep stacks, several limpers, button with 76s. A sound plan is…",
            3,
            [
                "Fold. Suited connectors hate multiway pots.",
                "All-in.",
                "Limp only if you will call any later raise for 100bb.",
                "Call or raise, planning to play a fit-or-fold flop rather than stack off preflop.",
            ],
            "Suited connectors gain from multiway implied odds and still should not commit 100bb with no pair.",
        ),
    ],
)

add(
    "lesson-03-03-03-limper-opens-check",
    "Limper opens check",
    [
        (
            "Which hand should isolate a single limper from the button?",
            0,
            [
                "AQo",
                "72o",
                "J4o",
                "32o",
            ],
            "Isolate hands that are ahead of a limp and play well heads-up. Trash still folds.",
        ),
        (
            "No one has opened. Two players limp. You are in the small blind with KK. Clear mistake?",
            1,
            [
                "Raising large",
                "Completing the small blind to trap",
                "Raising and continuing versus a caller",
                "Raising bigger than a no-limper open",
            ],
            "Completing kings lets the big blind see a cheap flop. Raise.",
        ),
        (
            "A limper is usually…",
            2,
            [
                "A premium that must be folded to.",
                "All-in by rule.",
                "A weaker, capped range you can attack with a raise.",
                "The same as an under-the-gun open.",
            ],
            "Limpers are weighted toward hands that did not want to raise. Punish them with position and size.",
        ),
        (
            "You want to isolate, and three players have limped. Compared with zero limpers, your raise should be…",
            3,
            [
                "Smaller, so they all call",
                "Exactly the minimum",
                "An under-raise, which is legal in no-limit",
                "Larger, because there is more dead money",
            ],
            "More limpers means more money to deny and more players to fold.",
        ),
    ],
)

add(
    "lesson-03-04-01-calling-and-3-betting-basics",
    "Calling and 3-betting basics",
    [
        (
            "Under the gun opens to 3bb. You are next to act with 72o. Best action?",
            0,
            [
                "Fold",
                "Call",
                "3-bet to 9bb as a bluff",
                "All-in for 100bb",
            ],
            "Do not continue trash against an early open. There is no blocker or playability.",
        ),
        (
            "Cutoff opens, you are on the button with AQs at 100bb. A sound continue is…",
            1,
            [
                "Fold",
                "Call or 3-bet. Both are ahead of folding.",
                "Limp after the open, which is not a legal call",
                "All-in for 100bb as the only continue",
            ],
            "AQs is too strong to fold to one late open. Calling in position or 3-betting are both real continues.",
        ),
        (
            "Which hand is a better 3-bet bluff than a call against a late open?",
            2,
            [
                "J4o",
                "72o",
                "A5s",
                "KTo, because it always dominates",
            ],
            "A5s blocks aces and can make a nut flush when called. Random offsuit hands do not.",
        ),
        (
            "You are out of position versus an early open with KJo. Why is flatting the common mistake?",
            3,
            [
                "KJo is the nuts against an early range.",
                "Position does not matter preflop.",
                "You are required to 3-bet every king.",
                "You are dominated and will play the flop first against a stronger range.",
            ],
            "KJo versus a tight early open is a fold more often than a call.",
        ),
    ],
)

add(
    "lesson-03-04-02-respond-to-an-open",
    "Respond to an open",
    [
        (
            "UTG opens, you are on the button with QQ at 100bb. What is the clear mistake?",
            0,
            [
                "Folding",
                "3-betting to about 9–12 big blinds",
                "Calling in position",
                "Continuing versus a single normal 4-bet",
            ],
            "Queens are a value continue against an early open. Folding them is a large error.",
        ),
        (
            "Button opens to 3bb, you are in the big blind with 22 and 100bb. A reasonable plan?",
            1,
            [
                "All-in",
                "Call and play fit-or-fold, looking for a set",
                "Fold. Pairs cannot call a button.",
                "3-bet to 30bb and call an all-in",
            ],
            "At 100bb the big blind can call a small button open with a pair and release when it misses.",
        ),
        (
            "Hijack opens, you are in the cutoff with ATo. Which continue is the clear mistake?",
            3,
            [
                "Folding",
                "Calling if you will play fit-or-fold in position",
                "3-betting small and folding to a 4-bet",
                "Calling and then stacking off 100bb with ace-high on a blank flop",
            ],
            "ATo can take a flop. It is not a 100bb stack-off with no pair.",
        ),
        (
            "A tight under-the-gun player opens. You are in middle position with JJ. Best default?",
            2,
            [
                "Fold. Jacks are a small pair.",
                "Limp.",
                "3-bet for value, and reevaluate a 4-bet.",
                "All-in for 100bb over the 3bb open.",
            ],
            "Jacks 3-bet an early open for value. They do not need a 100bb jam over a small open, and they do not fold.",
        ),
    ],
)

add(
    "lesson-03-04-03-facing-an-open-check",
    "Facing an open check",
    [
        (
            "Against a tighter early open, your continuing range should be…",
            1,
            [
                "Wider than against a button open",
                "Tighter than against a button open",
                "Every suited hand",
                "Only the blinds are allowed to continue",
            ],
            "An early range is stronger, so you continue fewer hands than against a steal.",
        ),
        (
            "Which spot is the best 3-bet, not a fold?",
            0,
            [
                "Button versus a cutoff open, holding AK",
                "UTG+1 versus an UTG open, holding 96o",
                "Big blind versus an UTG open, holding 72o",
                "Any hand, because 3-bets cannot be value",
            ],
            "AK is a value 3-bet against a late open. The trash hands fold.",
        ),
        (
            "You called an open in position with 76s and completely missed the flop. Default?",
            2,
            [
                "Stack off because you called preflop",
                "Check-raise every turn",
                "Give up the pot unless you have a real reason to continue",
                "The preflop call obligates you to see the river",
            ],
            "A preflop continue is not a promise to put in 100bb with no pair and no draw.",
        ),
        (
            "Cutoff opens to 3bb. You are on the button with AKo. Folding is wrong because…",
            3,
            [
                "The button must call every open",
                "AKo cannot be 3-bet",
                "Position makes folding illegal",
                "AKo is ahead of a cutoff open and should call or 3-bet",
            ],
            "This is a standard value continue, usually a 3-bet.",
        ),
    ],
)

add(
    "lesson-03-05-01-defending-and-playing-blinds",
    "Defending and playing blinds",
    [
        (
            "Why does the big blind defend more hands than the small blind against the same open?",
            0,
            [
                "The big blind already has 1bb in the pot and closes the action.",
                "The big blind acts first postflop.",
                "The small blind is required to call.",
                "The big blind can only fold or all-in.",
            ],
            "You are getting a discount and no one acts behind you preflop. You still play out of position.",
        ),
        (
            "Small blind versus a button open at 100bb. What is the preferred shape?",
            1,
            [
                "Call every hand that is not trash, then play out of position.",
                "Prefer 3-bet or fold over a flat.",
                "Complete every hand because you already posted.",
                "Fold AA so you can trap later.",
            ],
            "The small blind is the worst seat. Flatting a wide range out of position is the leak.",
        ),
        (
            "Button opens, you are the big blind with 72o and 100bb. Best action?",
            2,
            [
                "Call. The big blind defends 100% of hands.",
                "3-bet. Seven-deuce is a standard bluff.",
                "Fold.",
                "All-in.",
            ],
            "A discount is not a reason to play the worst hand. 72o still folds to a button open.",
        ),
        (
            "Button opens, you are the big blind with AJo. Folding is…",
            3,
            [
                "Required, because jacks are weak.",
                "Required, because the big blind must fold offsuit hands.",
                "The only legal option.",
                "Too tight. Call or 3-bet.",
            ],
            "AJo is a standard big-blind continue against a steal, unlike against a tight UTG open.",
        ),
    ],
)

add(
    "lesson-03-05-02-play-from-the-blinds",
    "Play from the blinds",
    [
        (
            "UTG opens, you are the small blind with KQo at 100bb. Best default?",
            0,
            [
                "Fold or 3-bet. Do not flat out of position against a tight range.",
                "Call. Offsuit broadways must flat the small blind.",
                "Complete, because you posted a small blind.",
                "All-in for 100bb.",
            ],
            "KQo is dominated by an early open and plays badly as a small-blind flat.",
        ),
        (
            "Button opens to 2.5bb, you are the big blind with 76s and 100bb. A sound continue?",
            1,
            [
                "Fold. Suited connectors are never defended.",
                "Call. You are priced in and can hit a strong flop.",
                "All-in.",
                "Limp, which does not apply after a raise.",
            ],
            "The big blind can defend suited connectors against a small button open and release when they miss.",
        ),
        (
            "You are the small blind with AA. Someone has opened. Clear mistake?",
            2,
            [
                "3-betting",
                "4-betting if they reraise small",
                "Folding",
                "Raising larger because you are out of position",
            ],
            "Aces are never a fold to a single open.",
        ),
        (
            "Both blinds called a late open and the flop is multiway. You should…",
            3,
            [
                "Bluff every missed flop because you were in the blinds",
                "Stack off any pair",
                "Ignore the extra player",
                "Continue tighter. Multiway, bluffs and weak pairs lose value.",
            ],
            "Two blinds in the pot means you did not isolate. Make hands, do not blast air.",
        ),
    ],
)

add(
    "lesson-03-05-03-blind-play-check",
    "Blind play check",
    [
        (
            "Which continue belongs in the big blind against a button open?",
            1,
            [
                "72o",
                "AJs",
                "32o",
                "Folding AA",
            ],
            "AJs is a clear defend. Trash and folding aces are not.",
        ),
        (
            "Small blind versus a hijack open with JTo at 100bb. The leak is…",
            0,
            [
                "Flatting and playing a dominated hand out of position",
                "Folding",
                "3-betting and folding to a 4-bet",
                "Noticing that you are out of position",
            ],
            "JTo does not flat well from the small blind against a solid open.",
        ),
        (
            "The big blind is not 'defending any two cards' because…",
            2,
            [
                "The big blind posted nothing",
                "Calls are illegal from the big blind",
                "Even with a discount, the worst hands lose more than the pot offers",
                "The button is forced to fold if the big blind calls",
            ],
            "Pot odds widen the defend. They do not make 72o profitable against a real open.",
        ),
        (
            "Button min-raises, big blind holds KK. What do you do?",
            3,
            [
                "Fold",
                "Call only, so you never raise kings",
                "Complete",
                "3-bet for value",
            ],
            "Kings 3-bet a steal. Slow-playing them from the big blind lets the button realize equity.",
        ),
    ],
)

add(
    "lesson-04-01-01-value-and-bluff-3-bet-ranges",
    "Value and bluff 3-bet ranges",
    [
        (
            "A value 3-bet is a hand that…",
            0,
            [
                "Is ahead of the opener’s continuing range and wants more money in.",
                "Is too weak to call and has no blockers.",
                "Must be all-in or it is not value.",
                "Is always 72o, to balance.",
            ],
            "Value 3-bets are ahead when called: big pairs and strong broadways, widened against late opens.",
        ),
        (
            "Which hand is a value 3-bet against a tight under-the-gun open?",
            1,
            [
                "76s",
                "QQ",
                "KJo",
                "ATo",
            ],
            "Queens are ahead of a tight early open. The others are dominated or speculative.",
        ),
        (
            "A bluff 3-bet should usually be…",
            2,
            [
                "Any two cards, chosen at random",
                "A hand you will stack off if you get 4-bet",
                "A suited ace or other blocker that can fold to a 4-bet",
                "A small pair you refuse to fold",
            ],
            "A5s-style bluffs block strong continues and can still make a nut flush when called.",
        ),
        (
            "In position, a live 3-bet with no limpers is often about…",
            3,
            [
                "The minimum raise",
                "100 big blinds every time",
                "Less than the original open",
                "3× the open. Out of position, closer to 4×.",
            ],
            "Use about three times the open in position and about four times from the blinds, then add size for limpers.",
        ),
    ],
)

add(
    "lesson-04-01-02-build-3-bet-ranges",
    "Build 3-bet ranges",
    [
        (
            "Button versus a cutoff open. Which set is the value 3-bet core?",
            0,
            [
                "TT+, AQ+",
                "22–55 only",
                "Every suited hand and nothing else",
                "Only 72o",
            ],
            "Against a late open, pairs from tens up and AQ or better are the value core. You can widen further against a loose opener.",
        ),
        (
            "You 3-bet A5s as a bluff and a tight player 4-bets large. Best default?",
            1,
            [
                "Call and stack off",
                "Fold",
                "5-bet all-in. Suited aces are the nuts.",
                "Limp",
            ],
            "The bluff 3-bet did its job when a tight range reraises. A5s is not a 100bb continue against that 4-bet.",
        ),
        (
            "Big blind versus a button open. Why is the 3-bet range wider than versus under the gun?",
            2,
            [
                "The button opened a stronger range than UTG.",
                "The big blind is in position.",
                "The button opens wide, so more hands are ahead and more bluffs work.",
                "UTG is forced to fold to any 3-bet.",
            ],
            "Steal ranges are wide. Early ranges are not, so you 3-bet them tighter.",
        ),
        (
            "Which construction is backwards?",
            3,
            [
                "3-bet KK for value",
                "Fold 72o to an open",
                "Use A5s as a occasional bluff 3-bet and fold to a 4-bet",
                "3-bet 72o for value and call every 4-bet with it",
            ],
            "72o is not a value hand and cannot call 4-bets.",
        ),
    ],
)

add(
    "lesson-04-01-03-3-bet-construction-check",
    "3-bet construction check",
    [
        (
            "Cutoff opens, button holds AK. The 3-bet is…",
            0,
            [
                "Value",
                "A fold",
                "A pure bluff with no showdown value",
                "Illegal in position",
            ],
            "AK is ahead of a cutoff open and of many calls. That is a value 3-bet.",
        ),
        (
            "You are in the small blind and 3-bet to the same chips you would use on the button. The usual fix is…",
            1,
            [
                "3-bet smaller out of position",
                "3-bet larger out of position, about 4× the open rather than 3×",
                "Never 3-bet from the small blind",
                "Only limp",
            ],
            "Out of position you want more folds and a bigger pot when called, so the 3-bet is larger.",
        ),
        (
            "A value 3-bet and a bluff 3-bet differ because…",
            2,
            [
                "Bluffs always go all-in and value always limps",
                "Value hands fold to an open",
                "Value continues against a 4-bet more often; bluffs with blockers usually fold",
                "There is no difference",
            ],
            "QQ continues versus many 4-bets. A5s usually does not.",
        ),
        (
            "Against a very loose button opener, a sound adjustment is…",
            3,
            [
                "Fold AK",
                "3-bet only AA",
                "Stop 3-betting",
                "Widen value 3-bets. Their open contains more dominated hands.",
            ],
            "Looser opens are attacked with a wider value range, not a tighter one.",
        ),
    ],
)

add(
    "lesson-04-02-01-squeezes-and-cold-call-criteria",
    "Squeezes and cold-call criteria",
    [
        (
            "A squeeze is…",
            1,
            [
                "A call of a single open",
                "A reraise after an open and at least one caller",
                "A limp from the small blind",
                "A check on the flop",
            ],
            "The dead money from the caller is why a squeeze is larger and stronger than a heads-up 3-bet.",
        ),
        (
            "UTG opens, hijack calls, you are on the button with AK. Best default?",
            0,
            [
                "Squeeze",
                "Fold",
                "Cold-call only. AK cannot raise.",
                "Limp",
            ],
            "AK is ahead of both ranges. Raise and take the dead money or play a bigger pot in position.",
        ),
        (
            "Which hand is a better cold-call on the button than a squeeze against a late open and one caller?",
            2,
            [
                "AA",
                "KK",
                "76s",
                "72o",
            ],
            "76s wants a cheap flop in position. Aces and kings raise. 72o folds.",
        ),
        (
            "Cold-calling out of position with KJo against an early open and a caller is a mistake because…",
            3,
            [
                "You are in position",
                "KJo is the nuts",
                "Calls are illegal",
                "You are dominated, multiway, and first to act after the flop",
            ],
            "That hand needs position and a weaker range in front of it. This spot has neither.",
        ),
    ],
)

add(
    "lesson-04-02-02-squeeze-or-cold-call",
    "Squeeze or cold call",
    [
        (
            "Cutoff opens, button calls, you are the big blind with QQ. What do you do?",
            0,
            [
                "Squeeze",
                "Fold",
                "Complete",
                "Check preflop, which is not an option after a raise",
            ],
            "Queens do not flat multiway out of position. Squeeze.",
        ),
        (
            "Hijack opens, cutoff calls, you are on the button with 76s and 100bb. A sound default?",
            1,
            [
                "All-in",
                "Cold-call and play fit-or-fold in position",
                "Fold. Suited connectors cannot call a single raise.",
                "Squeeze all-in",
            ],
            "In position against a non-early open, 76s can take a flop. It is not a 100bb jam.",
        ),
        (
            "UTG opens, two players call, you are in the small blind with ATo. Best default?",
            2,
            [
                "Call. More players means defend wider with any ace.",
                "All-in for 100bb",
                "Fold. Your ace is dominated and you are out of position multiway.",
                "Complete the small blind",
            ],
            "ATo hates a strong early range plus two callers from the worst seat.",
        ),
        (
            "You squeeze and both opponents call. On a dry flop with no pair, you should…",
            3,
            [
                "Automatically stack off",
                "Assume they both folded",
                "Ignore that the pot is multiway",
                "Bluff less. Two callers reduced your fold equity.",
            ],
            "A squeeze that gets called twice is a made-hand pot, not a pure bluff pot.",
        ),
    ],
)

add(
    "lesson-04-02-03-squeezes-and-cold-calls-check",
    "Squeezes and cold calls check",
    [
        (
            "Which action is a squeeze?",
            1,
            [
                "Open-raising after folds",
                "Reraising after a cutoff open and a button call",
                "Calling one open on the button",
                "Folding the small blind",
            ],
            "Open plus caller plus your raise is the squeeze.",
        ),
        (
            "A cold-call wants which ingredient most?",
            0,
            [
                "Position, and a hand that makes strong flops rather than one pair",
                "The worst offsuit hand",
                "Being first to act against an under-the-gun range",
                "A plan to stack off ace-high",
            ],
            "Suited connectors and small pairs realize better in position than dominated offsuit hands do.",
        ),
        (
            "Big blind, UTG open, two calls, you hold KK. Folding is…",
            2,
            [
                "Standard",
                "Required multiway",
                "A large mistake. Squeeze.",
                "The only way to trap",
            ],
            "Kings raise for value even multiway. Flatting lets the field see a cheap flop.",
        ),
        (
            "Why is a squeeze sized larger than a heads-up 3-bet?",
            3,
            [
                "The rules require an all-in",
                "Callers remove the dead money",
                "Smaller raises fold more players",
                "The caller’s chips are already in, and you need more folds",
            ],
            "Start from your 3-bet size and add size for each caller.",
        ),
    ],
)

add(
    "lesson-04-03-01-4-bet-and-preflop-all-in-trees",
    "4-bet and preflop all-in trees",
    [
        (
            "At 100bb against an unknown 3-bet, which hand is a standard continue versus a 4-bet?",
            0,
            [
                "KK",
                "A5s used as a bluff",
                "JTo",
                "22",
            ],
            "Kings continue against a 4-bet. Folding them because 'they always have aces' is a leak.",
        ),
        (
            "You 3-bet A5s and face a tight 4-bet that would commit your 100bb stack. Best default?",
            1,
            [
                "5-bet all-in",
                "Fold",
                "Call and stack off with no pair",
                "The 3-bet forces you to call any raise",
            ],
            "A blocker bluff is built to fold to strength. Do not turn it into a stack-off.",
        ),
        (
            "AA facing a 3-bet and then a 4-bet at 100bb. What is true?",
            2,
            [
                "Fold. Aces are a trap only if you limp.",
                "You may fold if the 4-bet is large.",
                "Continue. Aces are not a fold preflop at 100bb.",
                "You must limp next time.",
            ],
            "There is no 100bb preflop fold with aces against a single 4-bet.",
        ),
        (
            "A 5-bet all-in at 100bb is mainly…",
            3,
            [
                "Every suited connector",
                "The bottom of your cold-call range",
                "72o, for balance, every time",
                "The top of your range: AA, KK, and only sometimes QQ or AK",
            ],
            "Once the 4-bet is large, the jam is value-heavy. QQ and AK depend on who 4-bet. Trash does not jam.",
        ),
    ],
)

add(
    "lesson-04-03-02-navigate-4-bets-and-all-ins",
    "Navigate 4-bets and all-ins",
    [
        (
            "You open under the gun, a tight player 3-bets, you have TT at 100bb. A sound line is…",
            0,
            [
                "Call or fold to further pressure. Do not 5-bet jam as a default.",
                "5-bet all-in. Tens are the nuts.",
                "Limp after the 3-bet.",
                "Fold to the first open you already made",
            ],
            "Tens are often ahead of a 3-bet and behind a 4-bet or jam. They are not an automatic all-in.",
        ),
        (
            "Button 3-bets your cutoff open, you 4-bet KK, and the button jams 100bb. Against an unknown, the default is…",
            1,
            [
                "Fold. Kings lose to aces.",
                "Call. Kings are ahead of a button jam that includes AK and queens.",
                "Fold every time because jams are exactly AA.",
                "Calling a jam is illegal after you 4-bet",
            ],
            "A button jam is wider than a tight UTG jam. Kings are a continue; folding them only because aces exist is a leak.",
        ),
        (
            "Effective stacks are 18bb and you are reraised all-in after your open. Which idea is right?",
            2,
            [
                "Play exactly as you would at 100bb.",
                "Suited connectors go up in value because stacks are short.",
                "You are priced into more continues, and speculative hands that needed deep implied odds go down.",
                "You must fold AA because the stack is small.",
            ],
            "Short stacks remove room to fold later. Continue with hands that are ahead now, not hands that needed a deep flop.",
        ),
        (
            "You are facing an all-in and the pot already lays you 2 to 1. A hand that wins more than one-third of the time…",
            3,
            [
                "Must fold",
                "Cannot be called because it is not a favorite",
                "Must be AA or it loses money",
                "Is a call even when it is not a favorite",
            ],
            "Pot odds, not pride, decide a priced-in call. You do not need to be ahead of 50% when you are getting 2 to 1.",
        ),
    ],
)

add(
    "lesson-04-03-03-4-bets-and-all-ins-check",
    "4-bets and all-ins check",
    [
        (
            "Which fold is a clear mistake at 100bb?",
            0,
            [
                "Folding KK to a single 4-bet",
                "Folding A5s to a tight 4-bet after you used it as a bluff",
                "Folding 72o to an open",
                "Folding JTo to an under-the-gun 4-bet",
            ],
            "Kings continue. The other folds are reasonable.",
        ),
        (
            "QQ versus a tight under-the-gun 4-bet all-in at 100bb is…",
            1,
            [
                "An automatic joyous call with no thought",
                "A close spot. Against a range that is only AA and KK, queens are behind.",
                "A required fold every time, including against a loose button",
                "Illegal to call",
            ],
            "Who jammed matters. A nit’s UTG jam is heavier than a button’s. Do not use one rule for both.",
        ),
        (
            "Your 4-bet size at 100bb should usually…",
            2,
            [
                "Be a min-click that invites six callers",
                "Be smaller than the 3-bet",
                "Leave you a real decision, or commit you on purpose with the hands that want it",
                "Always be all-in with A5s",
            ],
            "A tiny 4-bet gives the 3-bettor a cheap call. A size that commits the stack is for value, not for A5s.",
        ),
        (
            "Short-stacked (about 15–20bb), a small open that you will hate folding is often replaced by…",
            3,
            [
                "A limp",
                "A 100bb-style deep 4-bet tree",
                "Folding AA",
                "A raise-all-in or a fold, because there is no room for postflop play",
            ],
            "When the remaining stack is only a few bets, decide preflop instead of open-folding a committed hand.",
        ),
    ],
)

add(
    "lesson-04-04-01-adjusting-to-table-and-stack-context",
    "Adjusting to table and stack context",
    [
        (
            "Stacks are 200bb instead of 100bb. Which hands gain?",
            0,
            [
                "Suited connectors and suited aces that can make strong hands",
                "Dominated offsuit broadways that make one pair",
                "72o",
                "Nothing. Depth does not change preflop.",
            ],
            "Deeper stacks pay implied odds for suited and connected hands and punish one-pair domination.",
        ),
        (
            "Stacks are 30bb. Which adjustment fits?",
            1,
            [
                "Call more suited connectors because implied odds increased",
                "Prefer hands that are ahead now. Speculative hands lose implied odds.",
                "Limp every pair",
                "Ignore position",
            ],
            "At 30bb you cannot win a huge pot when you flop a set, and you are committed more often with one pair.",
        ),
        (
            "A tight table open-folds too much. A sound exploit is…",
            2,
            [
                "Open only AA",
                "Stop stealing",
                "Open wider in late position and fold when they play back",
                "All-in every button",
            ],
            "Steal more against folders. Give up when a tight player 3-bets, because their continue is strong.",
        ),
        (
            "A live straddle is posted by the under-the-gun seat. This trainer does not deal straddles yet. Conceptually, you should…",
            3,
            [
                "Ignore it. A straddle is the same as no blind.",
                "Treat the straddler as an early-position open.",
                "Fold for the rest of the orbit by rule.",
                "Treat the straddle as a bigger big blind. The first voluntary actor sits to the left of the straddle.",
            ],
            "A straddle changes who is in the blinds. Do not play a 9-handed UTG chart from the seat that now acts after the straddle.",
        ),
    ],
)

add(
    "lesson-04-04-02-adjust-preflop-by-context",
    "Adjust preflop by context",
    [
        (
            "Loose callers on your left, you are under the gun with KJo at 100bb. Compared with a tight table, you should…",
            0,
            [
                "Open less often. You will be called and dominated.",
                "Open wider. Callers make KJo stronger.",
                "Limp. Loose tables require limps from UTG.",
                "All-in.",
            ],
            "When the field calls too much, remove dominated offsuit hands from early opens.",
        ),
        (
            "Same loose table, button, folded to you with KJo. Now…",
            1,
            [
                "Fold. The button uses the UTG range.",
                "Open. Position and their calling still favor a late steal that can win immediately or play in position.",
                "All-in for 200bb",
                "Limp only",
            ],
            "The same hand changes with seat. Button versus blinds is not UTG versus a calling field.",
        ),
        (
            "You cover the table with 300bb. A short stack with 20bb open-jams. With QQ you…",
            2,
            [
                "Fold because you are deep",
                "Call only if you also cover a third stack of 300bb",
                "Call the 20bb. Your extra chips behind do not change this pot.",
                "Need 300bb of equity",
            ],
            "Effective stack is the jam, 20bb, not the 300bb you cannot win.",
        ),
        (
            "The table is 4-handed at 100bb. Your earliest open should look more like…",
            3,
            [
                "A 9-handed UTG range",
                "A limp-only range",
                "AA or fold",
                "A full-ring cutoff or button range, not a full-ring UTG range",
            ],
            "Four-handed has no true early position. Opening the 9-handed UTG chart is far too tight.",
        ),
    ],
)

add(
    "lesson-04-04-03-contextual-adjustment-check",
    "Contextual adjustment check",
    [
        (
            "Which change is correct when the game gets deeper?",
            1,
            [
                "Stack off more dominated offsuit hands preflop",
                "Value suited connectors more and offsuit one-pair hands less",
                "Ignore position",
                "Open only all-in",
            ],
            "Depth rewards hands that can make the nuts and punishes big dominated pairs.",
        ),
        (
            "A nit 3-bets your button open. The exploit is…",
            0,
            [
                "Fold the bottom of your continue range. Their 3-bet is strong.",
                "4-bet all-in with 76s",
                "Assume every 3-bet is a bluff",
                "Call every hand you opened",
            ],
            "Tight 3-bets are value. Do not pay them off with the hands you opened as steals.",
        ),
        (
            "Effective stacks are 15bb, folded to the button, you have AJo. The fitting plan is…",
            2,
            [
                "Limp and fold to a jam",
                "Use a 100bb cold-call tree",
                "Raise all-in or raise an amount you are willing to call off",
                "Fold. AJo is an under-the-gun hand only.",
            ],
            "At 15bb the button does not have a deep postflop tree. Decide for the stack now.",
        ),
        (
            "Which fact about a straddle should you remember in this app?",
            3,
            [
                "The trainer deals straddles, bomb pots, and rake in every hand",
                "A straddle removes position",
                "The straddler is the button",
                "Straddles are conceptual here: the straddle acts like a larger big blind until the engine deals them",
            ],
            "Do not expect a dealt straddle in the current hand engine. Learn the position shift now and apply it live.",
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
        if section["order"] not in (3, 4):
            continue
        for unit in section["units"]:
            for lesson in unit["lessons"]:
                lesson["exerciseRefs"] = [lesson["id"]]
    for gate in catalog["milestoneGates"]:
        if gate["id"] != "preflop":
            continue
        required = list(gate["requiredObjectiveIds"])
        for extra in PREFLOP_GATE_OBJECTIVES:
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
    if len(LESSONS) != 27:
        raise SystemExit(f"expected 27 lessons, got {len(LESSONS)}")
    write_exercises()
    patch_catalog()
    write_bank()
    print(
        f"authored={len(LESSONS)} exercises={len(list(EX_DIR.glob('*.json')))} "
        f"bank={len(json.loads(BANK.read_text()))}"
    )


if __name__ == "__main__":
    main()
