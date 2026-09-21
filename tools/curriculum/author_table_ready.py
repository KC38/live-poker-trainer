#!/usr/bin/env python3
"""Author Sections 0–2 static exercises and sync generated catalogs.

Canonical exercises land in content/curriculum/v1/exercises/.
Does not overwrite an existing first-lesson file.
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
FN_CATALOG = ROOT / "functions/src/generated/curriculum_catalog.json"
FN_EX = ROOT / "functions/src/generated/exercises"
BANK = ROOT / "functions/src/generated/exercise_bank.json"

# (prompt, correct_index, choices[4], explanation)
Q = tuple[str, int, list[str], str]

LESSONS: dict[str, tuple[str, list[Q]]] = {}


def add(lesson_id: str, title: str, questions: list[Q]) -> None:
    LESSONS[lesson_id] = (title, questions)


add(
    "lesson-00-01-02-map-a-live-cash-game",
    "Map a live cash game",
    [
        (
            "A floor card says $1/$2 NL, $100–$300 buy-in. What does that mean?",
            0,
            [
                "Blinds are $1 and $2; you may buy in between $100 and $300.",
                "The tournament starts at level 1 and ends at level 2.",
                "You must buy in for exactly $200 every orbit.",
                "The big blind doubles every 20 minutes.",
            ],
            "Cash stakes are fixed blinds plus a buy-in range, not a tournament clock.",
        ),
        (
            "Which seat count is a full ring?",
            2,
            [
                "Heads-up",
                "Six-handed",
                "Nine-handed",
                "Three-handed",
            ],
            "Full ring is typically 8–9 handed. Six-handed is short-handed but not full ring.",
        ),
        (
            "Effective stack is best described as…",
            1,
            [
                "The largest stack at the table, always.",
                "The smallest stack that can still contest the pot between the players involved.",
                "The sum of every chip on the table.",
                "Only the big blind amount.",
            ],
            "You cannot win more from an opponent than they have in front of them.",
        ),
        (
            "Why does position matter more as stacks get deeper?",
            3,
            [
                "Deeper stacks remove all postflop decisions.",
                "The button must fold every hand when deep.",
                "Blinds disappear once stacks exceed 100 big blinds.",
                "More streets remain, so acting last gains more information.",
            ],
            "Deep cash play is multi-street. Acting last sees how others bet before you choose.",
        ),
    ],
)

add(
    "lesson-00-01-03-cash-poker-map-check",
    "Cash poker map check",
    [
        (
            "You bust a $1/$2 cash buy-in. The correct next step is usually…",
            1,
            [
                "You are eliminated from the casino event.",
                "Rebuy within the table cap, or rack up and leave.",
                "Wait for the bubble to burst.",
                "The dealer must seat you in a satellite.",
            ],
            "Cash has no elimination ladder. A lost buy-in ends that stack, not the game.",
        ),
        (
            "Which format uses a rising blind clock?",
            0,
            [
                "A tournament",
                "A fixed $2/$5 cash game",
                "A time-charge cash game with constant blinds",
                "Neither cash nor tournaments",
            ],
            "Tournament blinds escalate. Standard cash blinds stay at the posted stakes.",
        ),
        (
            "Hero has 200 big blinds and the villain has 40. The effective stack is…",
            2,
            [
                "200 big blinds",
                "240 big blinds",
                "40 big blinds",
                "The big blind only",
            ],
            "Effective stack is the smaller of the stacks that can go into the pot.",
        ),
        (
            "A live cash table is most unlike a tournament because…",
            3,
            [
                "Cash games ban the button.",
                "Cash chips have no dollar value.",
                "You must play until one player has every chip.",
                "You can leave between hands and chips represent withdrawable money.",
            ],
            "Cash is an optional, continuous game. Chips are money, not tournament equity.",
        ),
    ],
)

add(
    "lesson-00-02-01-table-flow-and-seating",
    "Table flow and seating",
    [
        (
            "Before you sit, the most useful first habit is…",
            0,
            [
                "Watch one orbit: seats, stacks, and who is playing which streets.",
                "Post the big blind from the rail and throw cards in.",
                "Announce your strategy to the table.",
                "Buy the maximum and open every button immediately.",
            ],
            "A quiet orbit shows action order, stack sizes, and obvious tendencies.",
        ),
        (
            "The button is…",
            1,
            [
                "The first player to act preflop in a full ring.",
                "The dealer position, last to act postflop.",
                "Always the big blind.",
                "The player who must straddle.",
            ],
            "The button acts last on the flop, turn, and river in a normal hand.",
        ),
        (
            "You are dealt in on the big blind your first hand. You should…",
            2,
            [
                "Skip the blind because you just sat down.",
                "Post both blinds twice.",
                "Post the big blind; you are live for that hand.",
                "Wait until the button passes you to post anything.",
            ],
            "A new player dealt into the big blind posts it and receives a hand.",
        ),
        (
            "Missed-blind rules vary, but a safe default is…",
            3,
            [
                "Invent a rule and enforce it yourself.",
                "Never post and keep taking free hands.",
                "Move the button yourself.",
                "Ask the dealer how this room handles a missed blind before you act.",
            ],
            "Rooms differ on posting, waiting, and dead blinds. The dealer is the source.",
        ),
    ],
)

add(
    "lesson-00-02-02-survive-your-first-orbit",
    "Survive your first orbit",
    [
        (
            "Cards are in the air and it is not your turn. You should…",
            0,
            [
                "Wait. Acting out of turn creates confusion and can bind you.",
                "Fold out of turn to speed the game up.",
                "Announce 'raise' before the player on your right.",
                "Show one card so the table can help.",
            ],
            "Act in turn. Early declarations can be binding or angle-adjacent.",
        ),
        (
            "Your neighbor bets and you have not looked yet. Best action?",
            1,
            [
                "Call while still looking at your cards.",
                "Look first, then act in turn when action reaches you.",
                "Muck face-up.",
                "Ask the dealer to pause the hand until you choose a seat.",
            ],
            "Protect the order of action. Look before it is your turn, then act once.",
        ),
        (
            "A player asks what you folded. A clean answer is…",
            2,
            [
                "Tell them the exact two cards every time.",
                "Show the fold to the whole table.",
                "Decline. Folded cards stay hidden unless a rule requires otherwise.",
                "Write the hand on a phone in the middle of the hand.",
            ],
            "You do not owe folded-hand information. Phones at the table are often restricted.",
        ),
        (
            "The first orbit goal is…",
            3,
            [
                "Win the most pots, even by guessing.",
                "Stack off light to 'see where you are'.",
                "Straddle every hand so you look active.",
                "Avoid big mistakes while you learn the table.",
            ],
            "Survival and information beat heroics on a brand-new table.",
        ),
    ],
)

add(
    "lesson-00-02-03-first-orbit-check",
    "First orbit check",
    [
        (
            "Who acts last on the flop?",
            1,
            [
                "The small blind, always.",
                "The button, if still in the hand.",
                "Under the gun.",
                "The first player who posted a blind.",
            ],
            "Postflop action starts left of the button and ends on the button.",
        ),
        (
            "You want a seat change. Do it…",
            0,
            [
                "Between hands, through the dealer, without delaying the game.",
                "Mid-hand while holding live cards.",
                "By swapping chips with a stranger.",
                "Only after winning a showdown.",
            ],
            "Seat changes happen between hands and follow the room's list or dealer.",
        ),
        (
            "Protecting your cards means…",
            2,
            [
                "Throwing them toward the muck when you call.",
                "Leaving them behind your chips, unattended.",
                "Keeping them on the felt in front of you, usually capped by a chip.",
                "Holding them up for the table to see.",
            ],
            "A chip on your cards helps stop them from being taken as a fold.",
        ),
        (
            "The dealer pushes you the pot and an argument starts. You should…",
            3,
            [
                "Scoop and leave before anyone speaks.",
                "Re-deal the board yourself.",
                "Argue over the dealer.",
                "Leave the pot, let the dealer control it, and call the floor if needed.",
            ],
            "Do not take a disputed pot. The dealer and floor resolve procedure.",
        ),
    ],
)

add(
    "lesson-00-03-01-bankroll-and-session-basics",
    "Bankroll and session basics",
    [
        (
            "A recreational cash bankroll should be…",
            0,
            [
                "Money you can lose without affecting rent, food, or debt payments.",
                "Next month's rent, because poker 'always pays it back'.",
                "A credit-card cash advance.",
                "Borrowed tournament makeup.",
            ],
            "Live cash is gambling. Only risk money already separated from living expenses.",
        ),
        (
            "A stop-loss is useful because…",
            1,
            [
                "It guarantees you win the session back.",
                "It ends a session before fatigue or chasing takes over.",
                "Rooms require one by law in every city.",
                "It raises your hourly win rate by itself.",
            ],
            "A precommitted stop is a process tool, not a promise of profit.",
        ),
        (
            "Which behavior is loss-chasing?",
            2,
            [
                "Leaving when you hit the stop you set earlier.",
                "Moving down in stakes after a downswing.",
                "Buying in again and again to 'get even tonight'.",
                "Taking a break after a bad beat.",
            ],
            "Chasing tries to erase a loss immediately. It is a common path to a bigger loss.",
        ),
        (
            "If poker stops being fun or you feel desperate to win it back…",
            3,
            [
                "Raise the stakes so one pot fixes it.",
                "Drink so the cards feel easier.",
                "Ask a stranger at the table for a private loan.",
                "Rack up, leave, and use a help line if gambling feels out of control.",
            ],
            "Leave. Higher stakes, alcohol, and credit make a bad state worse.",
        ),
    ],
)

add(
    "lesson-00-03-02-choose-a-safe-first-session",
    "Choose a safe first session",
    [
        (
            "Your plan was two buy-ins and three hours. You lose the second buy-in. Best action?",
            0,
            [
                "Stop. The plan already answered this moment.",
                "Buy in a third time because the table 'owes you'.",
                "Jump to $5/$10 to recover faster.",
                "Stay until you are ahead.",
            ],
            "A plan only works if you follow the exit you chose while calm.",
        ),
        (
            "You are tired and tilting after a bad beat. The disciplined play is…",
            1,
            [
                "Straddle to change the energy.",
                "Take a walk or end the session.",
                "Open every hand to 'reset variance'.",
                "Tell the table you are on tilt.",
            ],
            "Fatigue and tilt produce clear mistakes. Pause or leave.",
        ),
        (
            "Which game is the safer first session?",
            2,
            [
                "The biggest game if a seat is open, regardless of bankroll.",
                "A private home game that offers you credit.",
                "A public limit you chose in advance, with cash you already set aside.",
                "Whatever table has the drunkest action.",
            ],
            "Pick the stake and the money before you arrive. Do not take credit.",
        ),
        (
            "Recording the session should focus on…",
            3,
            [
                "Only the amount won.",
                "Blaming the dealer.",
                "Hands you want revenge for.",
                "Buy-ins, duration, and one or two decisions to review later.",
            ],
            "Process notes beat a single result number.",
        ),
    ],
)

add(
    "lesson-00-03-03-safe-start-check",
    "Safe-start check",
    [
        (
            "Poker bankroll money and living expenses should be…",
            1,
            [
                "The same account so you can reload from rent.",
                "Separated before you play.",
                "Borrowed if you are confident.",
                "Ignored because skill removes risk.",
            ],
            "Separation is the first safety control. Skill does not remove variance.",
        ),
        (
            "A stranger offers a private stake and wants the password to your account. You…",
            0,
            [
                "Refuse. Do not share accounts, devices, or credit.",
                "Accept if they seem friendly.",
                "Send half the password.",
                "Let them hold your chips overnight.",
            ],
            "Account sharing and informal credit are common theft setups.",
        ),
        (
            "You hit your time limit but you are stuck half a buy-in. You…",
            2,
            [
                "Must stay until you are even.",
                "Move up in stakes.",
                "May leave. A time limit is allowed to cost money.",
                "Demand the table refund the blinds.",
            ],
            "Stops are allowed to fire while you are stuck. That is what they are for.",
        ),
        (
            "Responsible-play lessons in this app are…",
            3,
            [
                "Locked until you subscribe.",
                "Optional color, not real guidance.",
                "Only for professionals.",
                "Free and not something you should skip to reach 'real' strategy.",
            ],
            "Safety content stays available. It is part of being table-ready.",
        ),
    ],
)


add(
    "lesson-01-01-01-hand-rankings-and-showdown-order",
    "Hand rankings and showdown order",
    [
        ("Which hand wins at showdown?", 0, ["A flush beats a straight.", "A straight beats a flush.", "Two pair always beats three of a kind.", "High card beats one pair when the pairs are low."], "Flush outranks straight. Three of a kind outranks two pair."),
        ("Board is Ah Kh Qh Jh Th. You hold 9c 8c. What do you play?", 1, ["A straight to the nine.", "The royal flush on the board, which plays for everyone.", "One pair of aces.", "Nothing; the board is dead."], "The best five-card hand can be the board. Everyone ties if nobody has a better flush."),
        ("You hold 7h 7c on a board of Ks Qd 7d 2c 7s. Your hand is…", 2, ["Three sevens.", "A full house.", "Four sevens.", "Two pair, sevens and kings."], "All four sevens are available: two in hand and two on the board."),
        ("'Cards speak' means…", 3, ["The dealer must accept a player's verbal claim over the cards.", "A mis-spoken hand name wins if said first.", "Folded cards can be declared live.", "The five cards determine the winner, not the player's announcement."], "Say the hand if you want, but the cards decide."),
    ],
)
add(
    "lesson-01-01-02-resolve-contested-showdowns",
    "Resolve contested showdowns",
    [
        ("You and a villain both have ace-king. Board is paired. The pot…", 0, ["Is split if neither has a better five-card hand.", "Goes to the player who tabled first.", "Goes to the bigger stack.", "Is awarded by the first verbal claim."], "Identical five-card hands chop, including kickers that do not play."),
        ("Villain says 'two pair' but tables a straight. You should…", 1, ["Accept the announcement and fold.", "Let the cards play; the straight stands.", "Call the floor only if you dislike the player.", "Muck because they mis-spoke."], "Cards speak. A mistaken announcement does not kill a better hand."),
        ("At showdown the aggressor is supposed to table first in many rooms. If they hesitate…", 2, ["You may grab their cards.", "You should muck without showing.", "Ask the dealer to control order; do not expose extra cards yourself.", "Announce their hand for them."], "Follow the dealer. Do not touch another player's cards."),
        ("Odd chips in a chopped pot are usually…", 3, ["Returned to the house as a tip automatically.", "Given to the biggest stack.", "Left for the next hand's button always.", "Awarded by a posted house rule, often to the first actor or the button side."], "Rooms differ. Do not invent a split; ask the dealer."),
    ],
)
add(
    "lesson-01-01-03-hands-and-showdowns-check",
    "Hands and showdowns check",
    [
        ("Board 9h 8h 7h 6c 2d. You have Th Jd. Villain has Ah 5d. Who wins?", 0, ["You, with a ten-high straight. Villain has no straight or flush.", "Villain, because ace high outkicks a straight.", "Chop, both play the board straight.", "You have a flush."], "Th-Jd makes T-9-8-7-6. The ace does not complete a flush or a higher straight."),
        ("Aces full of kings beats…", 1, ["Four deuces.", "Kings full of aces.", "A steel wheel only.", "Nothing; full houses always chop."], "The higher three of a kind decides. Aces full beats kings full."),
        ("You muck face-down at showdown. Your hand is…", 2, ["Still live if you remember it.", "Live if a friend speaks up.", "Dead. Mucked cards are not in the showdown.", "Saved by the board."], "A voluntary muck kills the hand. Table it if you want it considered."),
        ("Best five cards: you hold As Kd, board is Ac Ad Kc Kh 4s. You have…", 1, ["Two pair, aces and kings.", "Aces full of kings.", "Four aces.", "A straight."], "Three aces and two kings. That is aces full of kings, not four aces."),
    ],
)
add(
    "lesson-01-02-01-positions-and-action-order",
    "Positions and action order",
    [
        ("Preflop, first to act in a nine-handed game is…", 0, ["The player left of the big blind (under the gun).", "The button.", "The small blind.", "The cutoff."], "Blinds post first, then action starts under the gun and ends on the button, then blinds."),
        ("Postflop, first to act is…", 1, ["The button.", "The first remaining player left of the button.", "Under the gun, even if folded.", "The big blind, always, even when folded."], "The button is last postflop. Action begins with the next live player to the left."),
        ("Heads-up, the small blind/button…", 2, ["Acts last preflop and first postflop.", "Acts first preflop and last postflop.", "Acts first on every street.", "Posts no blind."], "Heads-up, the button posts the small blind, acts first preflop, and last postflop."),
        ("Position is an advantage mainly because…", 3, ["You are forced to bluff more.", "You post fewer blinds.", "Your cards are dealt face-up.", "You act after others and can react to their bets."], "Information and control come from acting later."),
    ],
)
add(
    "lesson-01-02-02-act-correctly-by-position",
    "Act correctly by position",
    [
        ("Six-handed, folds to you on the button. Earlier positions have folded. You…", 0, ["Act now. The blinds still follow you.", "Must wait for the cutoff who already folded.", "Are automatically all-in.", "Can skip the blinds."], "When it is your turn, act. Folded players are skipped."),
        ("You are in the small blind. Two players limp. Action is on you before the big blind. You…", 1, ["Act after the big blind.", "Act now, then the big blind closes the action if nobody raised.", "Must raise.", "Are all-in for the small blind."], "The small blind acts before the big blind preflop."),
        ("Flop is out. Button bet, small blind folded, you are the big blind. You…", 2, ["Act before the button.", "Must check.", "Face the button's bet and act now.", "Can check the option from the previous street."], "There is no free option facing a bet. Call, raise, or fold."),
        ("Someone acts out of turn and then action reaches them again. A safe approach is…", 3, ["Ignore the dealer.", "Treat every out-of-turn word as a joke.", "Change your hand.", "Follow the dealer's ruling; out-of-turn action may stand or be pulled back."], "Do not negotiate the rule at the table. The dealer applies the room rule."),
    ],
)
add(
    "lesson-01-02-03-action-and-position-check",
    "Action and position check",
    [
        ("Cutoff open-raises, button folds, small blind folds. Who is next?", 1, ["The cutoff again.", "The big blind.", "Under the gun.", "The dealer button, who already folded."], "Action continues in order. The big blind still has a decision."),
        ("Which seat has the most postflop advantage if all three see a flop?", 0, ["The button.", "The small blind.", "Under the gun.", "The player with the most chips, regardless of seat."], "The button acts last on every postflop street."),
        ("'Check' is legal when…", 2, ["Facing a bet.", "You are all-in and action is reopened.", "Nobody has bet on this street yet.", "You want to fold without saying fold."], "Checking passes the action only when there is no bet to call."),
        ("Nine-handed early position should usually…", 3, ["Open as wide as the button.", "Limp every suited hand.", "Straddle blind.", "Play tighter, because many players remain to act."], "More players behind means more chances someone wakes up with a strong hand."),
    ],
)
add(
    "lesson-01-03-01-bets-raises-and-all-ins",
    "Bets, raises, and all-ins",
    [
        ("A legal raise must be at least…", 0, ["The size of the previous full raise, subject to room and all-in exceptions.", "One chip, always.", "The whole pot or nothing.", "Twice the big blind on every street, even facing a huge bet."], "The minimum raise matches the last full raise. Short all-ins may not reopen action."),
        ("An all-in that is less than a full raise…", 1, ["Always reopens betting for the original raiser.", "Often does not reopen action for players who already acted.", "Is an illegal bet and is returned.", "Forces every caller to fold."], "Incomplete raises typically do not reopen players who already acted."),
        ("A string bet is…", 2, ["A single verbal 'raise to 50'.", "Putting out one chip to call.", "Going back to your stack for more chips after the first motion counted as a call.", "Checking and then betting after someone else acts."], "Say the amount first, or put the full bet out in one motion."),
        ("In most cardrooms, a verbal declaration in turn…", 3, ["Is a joke until chips are out.", "Can be changed after you see a reaction.", "Binds only if you repeat it twice.", "Is binding. Say what you mean once."], "Speak clearly. 'Raise' without a number may be a minimum raise."),
    ],
)
add(
    "lesson-01-03-02-apply-betting-rules-live",
    "Apply betting rules live",
    [
        ("You want to raise a $20 bet to $60. The cleanest action is…", 0, ["Say 'raise to sixty' before moving extra chips.", "Place $20, watch, then go back for $40.", "Throw one chip and say nothing.", "Announce the raise after the next player folds."], "A clear amount avoids a string-bet ruling."),
        ("Facing a bet, one oversized chip without comment is often ruled…", 1, ["An all-in.", "A call, unless you state a raise.", "A fold.", "A check."], "The one-chip rule usually means call. Announce the raise first."),
        ("Action folds to you and you may check. You should not be offered…", 2, ["A check.", "A bet.", "A free fold as if someone had bet.", "An all-in bet."], "Do not fold when checking is free. Folding for free gives up the pot."),
        ("You are unsure whether an all-in reopened the action. You…", 3, ["Guess and throw chips.", "Ask another player to decide.", "Take the pot down yourself.", "Ask the dealer before you act."], "Reopening rules are procedural. The dealer rules; the floor can review."),
    ],
)
add(
    "lesson-01-03-03-betting-mechanics-check",
    "Betting mechanics check",
    [
        ("Minimum opening raise in a no-limit game is generally…", 1, ["Half the big blind.", "A raise to at least two big blinds.", "Any amount above the big blind, even one dollar.", "The size of the pot only."], "An open must at least double the big blind, unless the house posts otherwise."),
        ("Checking is…", 0, ["Passing when there is no bet.", "The same as folding.", "A call of zero that closes the hand.", "Only legal in the big blind preflop."], "Check means 'no bet' and keeps your cards live."),
        ("You say 'call' and then try to raise after seeing a frown. That raise…", 2, ["Is always allowed.", "Is a legal string if chips remain.", "Is too late; the call stands.", "Becomes an all-in."], "The declaration bound you. Changing it is not a strategy, it is a rules problem."),
        ("All-in for less than the pot on the river…", 3, ["Is ignored.", "Wins automatically.", "Is a check.", "Is a legal bet for the chips you have; opponents may call that amount."], "You may go all-in for whatever you have left. They call the lesser amount."),
    ],
)

add("lesson-01-04-01-stacks-pots-and-side-pots", "Stacks, pots, and side pots", [
    ("Effective stack between you and one opponent is…", 0, ["The smaller of the two stacks.", "Always your stack.", "The pot plus both stacks.", "The big blind."], "You can only win what the shorter player can put in."),
    ("A side pot exists when…", 1, ["Everyone has the same stack.", "One player is all-in and others continue betting.", "The flop is paired.", "The button posts a straddle."], "Extra chips between the covering players go into a side pot the all-in player cannot win."),
    ("Unmatched chips that cannot be called are…", 2, ["Left in the pot as a bonus.", "Awarded to the dealer.", "Returned to the bettor.", "Moved to the next hand."], "If nobody can call the extra, that extra comes back."),
    ("You cover two all-in opponents who have different stacks. You might win…", 3, ["Only the main pot.", "Nothing if you have the best hand.", "A single combined pot with no eligibility rules.", "The main pot and a side pot, depending on who you beat."], "Each pot is awarded only among players who contributed to it."),
])
add("lesson-01-04-02-track-stacks-and-pots", "Track stacks and pots", [
    ("Pot is $30. Villain bets $15. Your call closes the action. The pot becomes…", 1, ["$30.", "$60.", "$45.", "$15."], "Thirty plus fifteen plus your fifteen is sixty."),
    ("You have $80 and villain has $200. You are all-in for $80 into a $40 pot. Villain calls. The pot you can win is…", 0, ["$40 + $80 + $80 = $200.", "$40 + $200.", "$80 only.", "The whole $200 stack plus the pot with no matching."], "Villain only matches your $80. Their extra $120 stays behind."),
    ("Counting the pot in a live game is easiest if you…", 2, ["Guess from the chip colors.", "Ask an opponent to count for you mid-decision and trust them.", "Track the action street by street, then confirm with the dealer if needed.", "Ignore the pot and use only your stack."], "Rebuild the pot from the bets you saw. The dealer can confirm."),
    ("A short all-in call that does not match a raise still…", 3, ["Folds the short stack.", "Reopens every previous raiser automatically.", "Is ignored.", "Creates a main pot for the all-in amount and may leave a side pot."], "Eligibility follows how much each player put in."),
])
add("lesson-01-04-03-stacks-and-pots-check", "Stacks and pots check", [
    ("Three players. A is all-in for $10, B and C each put in $50. A can win…", 0, ["Only the main pot of $30, if A has the best hand.", "The entire $110.", "Nothing, because A was all-in.", "Only B's extra chips."], "A contributed $10 and is matched by $10 from each of the others."),
    ("B and C continue after A is all-in. Their extra $40 each is…", 1, ["Added to A's pot.", "A side pot only B and C can win.", "Returned immediately.", "A tip."], "The side pot is contested by the players who put that money in."),
    ("Before calling a river bet, you should know…", 2, ["Only the dealer's name.", "The tournament clock.", "The price and the pot you are calling into.", "Your neighbor's folded cards."], "The call amount and the pot size are the minimum facts for pot odds."),
    ("If the board plays and two live players tie…", 3, ["The bigger stack wins.", "The button wins.", "Both hands are killed.", "They split the pots they are both eligible for."], "Ties split that pot. Side-pot eligibility still applies."),
])
add("lesson-01-05-01-dealer-and-floor-procedure", "Dealer and floor procedure", [
    ("A card is exposed during the deal. You should…", 0, ["Let the dealer apply the room's misdeal or exposed-card rule.", "Grab the deck and redeal.", "Ignore it and continue if you like your hand.", "Show your cards so the rule is fair."], "Misdeals and exposed cards are procedural. Do not self-deal."),
    ("You believe the dealer awarded the pot wrong. The next step is…", 1, ["Take the chips and sort it out later.", "Ask the dealer for a ruling, then the floor if it is still disputed.", "Accuse the other player of collusion immediately.", "Post the hand on social media from the table."], "Keep the dispute calm and inside the room's chain: dealer, then floor."),
    ("Protecting your action includes…", 2, ["Acting out of turn.", "Hiding cards on your lap.", "Keeping cards and chips clearly on the felt in front of you.", "Holding the deck for the dealer."], "Lap cards, hidden cards, and chips off the felt cause fouled-hand and angle problems."),
    ("Phones at the table are often restricted because…", 3, ["They are heavy.", "Dealers dislike ringtones only.", "They cannot show a clock.", "They can hide outside help or record other players' cards."], "Follow the room rule. Do not relay live hands to anyone off the table."),
])
add("lesson-01-05-02-handle-table-procedure", "Handle table procedure", [
    ("Two players show down and a third hand was mucked. That mucked hand…", 1, ["Can be retrieved if the player remembers it.", "Is dead.", "Wins if it would have been a straight.", "Is shown by the dealer on request from a friend."], "A muck is not a live hand."),
    ("Someone is speaking for the action or looking at a neighbor's hole cards. You…", 0, ["Tell the dealer. Do not police it by grabbing cards.", "Film it secretly.", "Announce their cards to the table.", "Fold every hand in protest without a word."], "Report procedure and integrity problems to the dealer or floor."),
    ("You need a table change. You…", 2, ["Pick up another player's chips as a joke.", "Move the button to your new seat.", "Ask the floor or brush and move only between hands.", "Sit down in a new game while still dealt into the old one."], "One live hand at a time. Changes go through staff."),
    ("A player wants you to soft-play their friend. The correct response is…", 3, ["Agree if the game is casual.", "Check-raise only their friend.", "Show them your cards each hand.", "Refuse. Soft-playing a partner is collusion."], "Playing a private alliance against the table is cheating, not etiquette."),
])
add("lesson-01-05-03-room-procedure-check", "Room procedure check", [
    ("The floor's job in a dispute is to…", 0, ["Apply the house rules to the facts.", "Award the pot to the regular.", "Poll the table and take a vote.", "Ignore the dealer."], "The floor decides procedure. It is not a popularity contest."),
    ("Your cards hit the muck by accident and are irretrievably mixed. Expect…", 1, ["A guaranteed refund of the pot.", "A dead hand, unless the dealer can still clearly identify them.", "An automatic win.", "A new deal of only your cards."], "Fouled or indistinguishable cards are usually dead. Protect them before that happens."),
    ("Acting in turn matters because…", 2, ["It lets you see future cards.", "The button can skip seats.", "Out-of-turn action changes what later players do and may bind you.", "Only the big blind may speak."], "Order of action is part of the game, not a courtesy."),
    ("Which request is appropriate?", 3, ["Show me the cards you folded last hand.", "Let me use your account to hold my chips.", "Tell me what to bet; I will raise you back.", "Dealer, please count the pot before I call."], "A pot count is normal. Fishing for folded cards, sharing accounts, or chip-dumping is not."),
])

add("lesson-02-01-01-chip-denominations-and-pot-math", "Chip denominations and pot math", [
    ("$1/$2 with a $200 stack is…", 1, ["50 big blinds.", "100 big blinds.", "200 big blinds.", "2 big blinds."], "Divide the stack by the big blind. 200 / 2 = 100."),
    ("A pot-sized bet into a $40 pot is…", 0, ["$40.", "$20.", "$80.", "$4."], "Pot-sized means the amount already in the pot, before your bet."),
    ("You are asked to call $25 into a $100 pot. The final pot if you call is…", 2, ["$100.", "$25.", "$150.", "$125."], "The $25 is added to the $100, so you risk 25 to win 125, and the pot becomes 150."),
    ("Converting everything to big blinds helps because…", 3, ["Chips of different colors cannot be counted.", "The casino requires BB speech.", "Dollars are illegal at the table.", "Stakes change, but 100 big blinds means the same depth at $1/$2 or $2/$5."], "Big blinds compare depth across stake sizes."),
])
add("lesson-02-01-02-account-chips-and-pots", "Account chips and pots", [
    ("$2/$5. Both blinds fold after you open to $15 and the button calls $15. Pot going to the flop is…", 0, ["$32: the $2, the $5, your $15, and the button's $15.", "$15.", "$30, ignoring blinds.", "$5."], "Posted blinds stay in the pot even when those players fold."),
    ("If you lose the count, the reliable fix is…", 1, ["Guess from chip height.", "Ask the dealer to count the pot.", "Let the bettor announce a number and ship it.", "Add only the last bet."], "A dealer count is a normal request before a big decision."),
    ("Hero shoves $90 into $30 and a covering player calls $90. Pot at showdown is…", 2, ["$90.", "$30.", "$210.", "$120."], "30 + 90 + 90 = 210."),
    ("A half-pot bet into $60 is…", 3, ["$60.", "$15.", "$120.", "$30."], "Half of 60 is 30."),
])
add("lesson-02-01-03-chip-accounting-check", "Chip accounting check", [
    ("$5/$10, stack of $1,000. Depth is…", 0, ["100 big blinds.", "200 big blinds.", "50 big blinds.", "1,000 big blinds."], "1000 / 10 = 100 big blinds."),
    ("Call $40 into a pot that will be $160 after your call. You are risking 40 to win…", 1, ["$40.", "$120.", "$160.", "$200."], "The $160 includes your call, so the amount you win if they are bluffing is $120."),
    ("Which count is wrong?", 2, ["$10 + $10 = $20.", "A $15 bet into $45 is one-third pot.", "A $50 call into a $50 pot makes the final pot $50.", "Two $25 calls of a $25 bet add $75 to the previous pot."], "A $50 pot plus a $50 call becomes $100, not $50."),
    ("Before a big call, the disciplined step is…", 3, ["Guess the pot from the chip pile's height.", "Trust the bettor's announced pot.", "Skip the count because live pots are unknowable.", "Confirm the bet size and the pot."], "Price first, then decide. Do not skip the count on a large call."),
])
add("lesson-02-02-01-equity-outs-and-draws", "Equity, outs, and draws", [
    ("A flush draw on the flop has how many outs to the flush, if no pair outs are counted?", 0, ["9.", "4.", "2.", "15."], "There are 13 cards of the suit and you already see 4, so 9 remain."),
    ("An open-ended straight draw on the flop has…", 1, ["2 outs.", "8 outs.", "9 outs.", "1 out."], "Four cards on each end complete the straight, so eight outs."),
    ("The rule of 2 and 4 says a 9-out draw has about…", 2, ["9% on the flop to the river.", "2% on the river.", "About 36% from the flop to the river, and about 18% with one card to come.", "50% exactly."], "Multiply outs by 4 with two cards to come, or by 2 with one. 9×4=36, 9×2=18."),
    ("Equity is not the same as realization because…", 3, ["Outs are always paid in full.", "Position and future bets do not matter.", "A draw cannot win unimproved.", "You may not get to see all the cards, or you may win extra when you hit."], "Fold equity, position, and stacks change how much of your raw equity you keep."),
])
add("lesson-02-02-02-estimate-equity-on-draws", "Estimate equity on draws", [
    ("Turn, 8 clean outs, one card left. A fair quick estimate is…", 1, ["8%.", "About 16%.", "32%.", "50%."], "Eight outs times two is about 16 percent with one card to come."),
    ("Flop, you have a nut flush draw and one overcard. A careful count is…", 0, ["Nine flush outs, plus any overcard outs that are still clean against the betting range.", "The nuts already.", "Two outs total.", "Zero equity if someone bets."], "Do not turn the overcard into extra flush outs. Add it only if that card actually wins."),
    ("You have 4 outs on the river. Calling is mainly about…", 2, ["Always calling because any out can hit.", "The suit color.", "Whether the price is better than about 8%, and whether the out is clean.", "The button's mood."], "Four outs is about 8 percent. You need a very good price, and the out must actually win."),
    ("A gutshot has…", 3, ["8 outs.", "9 outs.", "12 outs.", "4 outs."], "Only one rank completes a gutshot, and there are four cards of that rank."),
])
add("lesson-02-02-03-equity-and-draws-check", "Equity and draws check", [
    ("Which draw has more raw outs on the flop?", 0, ["A flush draw (9) versus a gutshot (4).", "A gutshot versus a flush draw.", "One overcard versus a flush draw.", "A backdoor draw versus a made flush."], "Nine flush outs is more than four gutshot outs."),
    ("Rule of 4 is for…", 1, ["The river only.", "The flop, with two cards still to come.", "Preflop all-ins only.", "Counting the pot."], "Two cards to come, multiply outs by about four."),
    ("An out is dirty when…", 2, ["It is the same color as the felt.", "It completes your hand and also completes a better hand for the opponent.", "It is an ace.", "The dealer burns it."], "A dirty out gives you a hand that still loses."),
    ("Seeing both remaining cards is more likely when…", 3, ["You are all-in or the price to continue is small relative to the chance you hit.", "You fold.", "You bet huge with no fold equity and no draw.", "Stacks are deep and you will fold every turn."], "All-in equity is raw equity. As a favorite to fold later, you realize less."),
])
add("lesson-02-03-01-pot-odds-and-expected-value", "Pot odds and expected value", [
    ("Pot odds are…", 0, ["The price of a call compared with the pot you can win.", "Your probability of winning the tournament.", "The rake percentage only.", "A required bluff on the river."], "You compare the cost of calling with the size of the pot you are calling into."),
    ("Call $20 into a pot that already has $80 in it, and your call closes the action. You are getting…", 1, ["1 to 1.", "5 to 1, because you win 100 for a 20 call if the $80 includes only the current pot before your call — recount: risk 20 to win 100.", "20 to 1.", "Even money on a $20 pot."], "If $80 is already there and nobody else can raise, you risk 20 to win 100. That is 5 to 1."),
    ("A call is immediately profitable on raw equity when…", 2, ["You feel confident.", "The player seems weak.", "Your chance of winning is higher than the break-even percent of the price.", "You have position, even with zero equity."], "Break-even percent is call / (pot you win + call). Equity above that is a profitable call if the out is clean and there is no more betting."),
    ("Fold equity is…", 3, ["The equity of a folded hand you already mucked.", "The chance you hit a flush.", "The rake.", "The extra value from opponents folding when you bet."], "A bet can win immediately when they fold, which a pure check cannot do."),
])
add("lesson-02-03-02-compute-pot-odds-decisions", "Compute pot odds decisions", [
    ("You must call $10 into a $40 pot. Break-even equity is about…", 1, ["10%.", "20%.", "40%.", "50%."], "Risk 10 to win 50 total after the call, so 10/50 = 20%. Or 10/(40+10)."),
    ("You have about 32% equity with a flush draw on the flop and the pot offers you 4 to 1. If you will see both cards…", 0, ["The price is better than 20% break-even, so a call can be fine before implied odds.", "You must fold every draw.", "4 to 1 means you need 50%.", "Pot odds ignore the number of outs."], "4 to 1 is 20 percent. Thirty-two percent clears that price if the draw is clean and you see both cards."),
    ("A bluff that risks $50 to win $50 needs to work…", 2, ["More than 75% of the time.", "Never; bluffs are free.", "More than half the time if you never win when called.", "Less than 10% of the time."], "Risk 50 to win 50 is even money. With no showdown value you need folds more than half the time."),
    ("Which statement about EV is right?", 3, ["A winning session proves every call was correct.", "Losing a called bluff means the call was a mistake.", "You should never call without the nuts.", "A +EV call can still lose this particular hand."], "One result is not the decision. EV is the average over the chances."),
])
add("lesson-02-03-03-pot-odds-and-ev-check", "Pot odds and EV check", [
    ("Break-even percent for a call of $25 into $75 is…", 0, ["25%.", "75%.", "10%.", "50%."], "25 / (75+25) = 25%."),
    ("You have 9% equity and the price requires 25%. A pure call is…", 1, ["Close.", "Not justified on pot odds alone.", "Mandatory because you have outs.", "Profitable because 9 is an odd number."], "Nine percent does not clear a twenty-five percent price."),
    ("Betting can be better than calling when…", 2, ["You have no hand and no fold equity.", "The pot is zero.", "Fold equity or protection adds value you do not get by only calling.", "You are facing an all-in and cannot bet."], "If they can still fold or you deny their equity, betting is a different action from calling."),
    ("Results-oriented thinking sounds like…", 3, ["I called because the price was right, and this time I lost.", "I will review the price, not the one outcome.", "Variance exists.", "I lost, so the call was wrong and I should chase it back."], "Chasing a single loss is not a pot-odds calculation."),
])
add("lesson-02-04-01-implied-and-reverse-implied-odds", "Implied and reverse implied odds", [
    ("Implied odds are…", 0, ["Chips you expect to win later when you hit, beyond the current pot.", "The current pot only.", "The rake.", "A rule that you may call any bet with a draw."], "They matter when stacks remain and you can get paid on later streets."),
    ("Reverse implied odds are…", 1, ["Extra chips you win with the nuts.", "Extra chips you lose when you hit a second-best hand.", "The same as pot odds.", "A tournament bounty."], "Dominated draws and weak pairs can 'hit' and still lose a big pot."),
    ("Implied odds are weaker when…", 2, ["Stacks are deep and the opponent will pay you off.", "You have the nuts when you hit.", "You are already all-in, or the opponent will not pay a large bet.", "Position lets you control the pot."], "If there is no more money to win, only the current price matters."),
    ("A small pair calling a huge raise out of position, deep, mainly risks…", 3, ["Too many immediate pot odds, which are excellent.", "Missing the rule of 4.", "Being unable to bluff the river with air only.", "Reverse implied odds: you flop a set rarely, and you often face large bets when you miss or are dominated."], "Set-mining needs the right price and the right stacks. It is not an automatic call."),
])
add("lesson-02-04-02-price-future-street-value", "Price future-street value", [
    ("You are all-in on the flop with a draw. Which odds matter?", 0, ["Pot odds and raw equity. There are no future bets to imply.", "Only implied odds.", "Only reverse implied odds from later bets.", "Neither, because all-in pots are not real."], "Once all-in, the rest of the cards are free. Use equity versus the current pot."),
    ("Deep stacks and a nut flush draw in position improve…", 1, ["Nothing.", "Implied odds, because you can still win more when you hit.", "The number of flush outs from 9 to 15.", "The board texture by itself."], "Position and leftover stacks let you extract more on later streets."),
    ("Calling a large river bet with a bluff-catcher is not an implied-odds call because…", 2, ["The river still has two cards to come.", "You can still bet later.", "There is no later street. You are deciding on the current price.", "Pot odds expire on the river."], "Implied odds need future betting. The river is the last card."),
    ("A dominated flush draw (you have the low flush draw, they can have the nut draw) has…", 3, ["Perfect implied odds.", "Nine outs that always win.", "No reverse implied odds.", "Reverse implied odds: some of your flush cards still lose."], "Do not count outs that make you second best as clean."),
])
add("lesson-02-04-03-future-street-value-check", "Future-street value check", [
    ("Best spot for implied odds?", 0, ["Deep stacks, nutted draw, opponent likely to pay.", "All-in for a few chips with air.", "River call with ace-high.", "A short stack already committed."], "You need money behind and a hand that can get paid when it hits."),
    ("Worst misuse of implied odds?", 1, ["Folding a draw that is not getting the right price and will not get paid.", "Calling too much because 'I might hit and stack them' with no plan.", "Counting nine clean flush outs.", "Using pot odds when stacks are all-in."], "Implied odds are not a reason to ignore a terrible price."),
    ("Rake and a tip reduce…", 2, ["The number of outs.", "Your position.", "The net pot you actually win.", "The big blind."], "What you keep is smaller than the chips in the middle. Tight games feel this more."),
    ("Set-mining a pair is more reasonable when…", 3, ["The raise is huge and stacks are shallow.", "You are out of position against a nit who will not pay a set.", "You will stack off without a set.", "The call is small relative to the effective stack you can win when you flop a set."], "A common live guide is a small price versus a deep stack, not a huge call versus a short stack."),
])
add("lesson-02-05-01-ranges-and-combo-counting", "Ranges and combo counting", [
    ("A poker range is…", 0, ["The set of hands a player can still have, not one exact hand.", "The single hand you put them on.", "Only the nuts.", "The board."], "Live reads start with every hand that would take the line, then remove what the line folds."),
    ("How many combinations of ace-king are in a fresh deck?", 1, ["6.", "16.", "12.", "4."], "AK offsuit has 12 combinations and AK suited has 4, totaling 16."),
    ("How many pocket-pair combinations of pocket aces?", 2, ["12.", "16.", "6.", "3."], "Choose 2 suits of the ace from 4: 4×3/2 = 6."),
    ("Why remove combinations as the hand continues?", 3, ["To make the range always 50%.", "Because folded cards stay in the range.", "Because the board does not matter.", "Betting, calling, and board cards make some holdings impossible or unlikely."], "A tight player's check-raise removes many weak hands they would not play that way."),
])
add("lesson-02-05-02-count-key-combinations", "Count key combinations", [
    ("Board is Ah 7c 2d. How many ace-king combinations remain?", 0, ["12. One ace is on the board, so the 4 suited AK with that ace are impossible and 12 offsuit-or-other-suit combinations remain from the original 16.", "16.", "6.", "1."], "Four aces existed. One is visible, so each AK combo using that ace is gone. 16 − 4 = 12."),
    ("Pocket pairs are fewer than offsuit broadways because…", 1, ["Pairs use two cards of the same rank, and there are only six suit pairings.", "Pairs are illegal.", "Offsuit hands have six combinations.", "The deck has more ranks than suits."], "Each pocket pair has six combinations. A specific offsuit hand like AKo has twelve."),
    ("If a nit 3-bets and you block aces with an ace in your hand…", 2, ["They have more ace combinations.", "Blockers do nothing.", "You reduce the combinations of strong aces they can hold.", "You guarantee they are bluffing."], "A blocker removes some strong combos. It does not prove a bluff."),
    ("Putting someone on exactly 7h 2c after one limp is…", 3, ["Sound range construction.", "Required before every call.", "Better than listing a range.", "Too narrow. Start with the hands that take the action."], "One exact hand is a guess. A range can be updated."),
])
add("lesson-02-05-03-ranges-and-combos-check", "Ranges and combos check", [
    ("Which count is correct?", 1, ["Pocket kings: 16 combinations.", "Pocket kings: 6 combinations.", "AK suited: 12 combinations.", "One specific suited hand: 6 combinations."], "Any pocket pair has 6 combos. One specific suited hand has 4. AKo has 12."),
    ("A range gets tighter when…", 0, ["The player, the position, and the line remove weak hands.", "You want them to be bluffing.", "The pot is small.", "You have not watched them."], "Tight lines and tight players delete combinations. Hope does not."),
    ("Using ranges at the table should stay…", 2, ["A full solver printout mid-hand.", "An excuse to ignore the action.", "A short list you can actually use: value, draws, and bluffs that took this line.", "Secret, so you never check it against the board."], "A usable range is small enough to count and still honest about the line."),
    ("Blockers are most useful when…", 3, ["You ignore the opponent's range.", "Every river call is a bluff-catch.", "You hold a card they need for their value hands or their bluffs.", "You want a reason to call without pot odds."], "A blocker changes the mix. It does not replace the price or the line."),
])


def _question(index: int, raw: Q) -> dict:
    prompt, correct_index, choices, explanation = raw
    if len(choices) != 4:
        raise SystemExit(f"need 4 choices: {prompt}")
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
    section_ids = {s["id"] for s in catalog["sections"][:3]}
    for section in catalog["sections"]:
        if section["id"] not in section_ids:
            continue
        for unit in section["units"]:
            for lesson in unit["lessons"]:
                lesson["exerciseRefs"] = [lesson["id"]]
    for gate in catalog["milestoneGates"]:
        if gate["id"] != "table-ready":
            continue
        required = list(gate["requiredObjectiveIds"])
        for extra in (
            "obj-chip-accounting",
            "obj-equity-draws",
            "obj-pot-odds-ev",
            "obj-implied-odds",
            "obj-combo-counting",
        ):
            if extra not in required:
                required.append(extra)
        gate["requiredObjectiveIds"] = required
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
        target = FN_EX / path.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, target)
    BANK.write_text(json.dumps(bank, indent=2) + "\n")


def main() -> None:
    write_exercises()
    patch_catalog()
    write_bank()
    print(f"exercises={len(list(EX_DIR.glob('*.json')))} bank={len(json.loads(BANK.read_text()))}")


if __name__ == "__main__":
    main()


