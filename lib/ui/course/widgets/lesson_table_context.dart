/// Compact felt + cards context for lesson select/identify activities.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

/// Tappable regions on the lesson mini-table.
enum LessonTableRegion {
  /// Hero hole cards.
  hero,

  /// Community board.
  board,

  /// Face-down villain seat(s).
  villain,

  /// Folded/muck pile.
  muck,

  /// Dealer button / dealer role chip (privacy distractor).
  dealer,

  /// Dealer button seat on a blinds layout.
  button,

  /// Small blind seat.
  smallBlind,

  /// Big blind seat.
  bigBlind,

  /// Unlabeled / empty seat distractor.
  emptySeat,

  /// Early position / UTG on a six-max position layout.
  earlyPosition,

  /// Hijack seat.
  hijack,

  /// Cutoff seat (right before the button).
  cutoff,

  /// Checkpoint distractor: seat never matters.
  seatNeverMatters,

  /// Timing: blinds post before the deal.
  beforeDeal,

  /// Timing: after the flop.
  afterFlop,

  /// Timing: only at showdown.
  showdown,

  /// Street ends when bets are matched / action equalizes.
  streetActionMatched,

  /// Distractor: flop cards appear (deal starts the street).
  streetFlopDealt,

  /// Distractor: someone folds (others may still act).
  streetSomeoneFolds,

  /// Fold-win: take the pot without showing.
  potTakeQuiet,

  /// Fold-win distractor: must always show.
  potMustShow,

  /// Fold-win distractor: dealer reveals cards.
  potDealerShows,

  /// Contested river: showdown compares hands.
  potShowdown,

  /// Showdown distractor: last bettor wins without showing.
  potLastBettor,

  /// Showdown distractor: always chop.
  potChopDefault,

  /// Side pot: unmatched chips form a side pot.
  potSideForms,

  /// Side pot distractor: short stack wins later chips too.
  potWinAll,

  /// Side pot distractor: short stack hand is dead.
  potHandDead,

  /// Open-pot size: correct total (blinds + open).
  potChipsNine,

  /// Open-pot size distractor: forgot a blind.
  potChipsSeven,

  /// Open-pot size distractor: too large.
  potChipsTwelve,

  /// Live habit: cover cards and wait your turn.
  habitCoverWait,

  /// Live habit distractor: announce / act early out of turn.
  habitActEarly,

  /// Live habit distractor: leave cards uncovered / flash them.
  habitLeaveBare,

  /// Effective stack: shorter stack rules (correct).
  effectiveStackShort,

  /// Effective stack distractor: hero's larger stack.
  effectiveStackHero,

  /// Effective stack distractor: sum of stacks.
  effectiveStackSum,

  /// Multiway pot: correct total after blinds + open + callers.
  potChipsTwentyOne,

  /// Multiway pot distractor: dropped a blind.
  potChipsEighteen,

  /// Call-price: correct call amount (matches the bet).
  callChipsTen,

  /// Call-price distractor: the pre-call pot.
  callChipsTwenty,

  /// Call-price distractor: pot after calling.
  callChipsThirty,

  /// Draw-price: call is priced in (correct).
  drawPriceCall,

  /// Draw-price distractor: fold without a made hand.
  drawPriceFold,

  /// Draw-price distractor: auto-raise every draw.
  drawPriceRaise,

  /// Verbal action: raise stands (binding).
  verbalRaiseStands,

  /// Verbal action distractor: take it back to a call.
  verbalTakeback,

  /// Verbal action distractor: only dealer decides later.
  verbalDealerChoice,

  /// Table-read checkpoint: effective stack + pot (correct).
  tableMatterEffAndPot,

  /// Table-read checkpoint distractor: only hero's larger stack.
  tableMatterHeroOnly,

  /// Table-read checkpoint distractor: ignore pot until river.
  tableMatterIgnorePot,

  /// Observe sticky: high participation note (correct).
  observeHighParticipation,

  /// Observe sticky distractor: low participation.
  observeLowParticipation,

  /// Observe sticky distractor: label archetype too early.
  observeLabelNow,

  /// Calling Station label (correct for sticky-call evidence).
  playerTypeStation,

  /// Nit label distractor (folds too much).
  playerTypeNit,

  /// Label is a working model from evidence (correct).
  labelWorkingModel,

  /// Label is a permanent personality verdict (mistake).
  labelPermanentSoul,

  /// Calling Station for limp/call/never-fold evidence.
  playerTypeStationLimp,

  /// Maniac distractor for sticky-call evidence.
  playerTypeManiac,

  /// Low sample confidence (correct after 2 hands).
  sampleConfidenceLow,

  /// Maximum certainty too early (mistake).
  sampleConfidenceMax,

  /// Bluff less because they rarely fold (correct).
  citeRarelyFolds,

  /// Bluff less because the label sounds mean (mistake).
  citeLabelMean,

  /// Narrow entry observation (correct).
  observeNarrowEntry,

  /// Wide entry distractor.
  observeWideEntry,

  /// Strong aggression when involved (correct).
  observeStrongAggression,

  /// Passive callers distractor.
  observePassiveCallers,

  /// Wait for more samples (correct).
  observeWaitSamples,

  /// Label now with two folds (mistake).
  observeLabelNowThin,

  /// Nit evidence bundle (correct).
  observeNitBundle,

  /// Station evidence bundle distractor.
  observeStationBundle,

  /// Nit label for narrow + large 3-bet evidence.
  meetNitLabel,

  /// Calling Station distractor on narrow evidence.
  meetNitStationDistractor,

  /// Nit label for fold-forever then check-raise.
  meetNitLabel2,

  /// Maniac distractor for nit evidence.
  meetNitManiacDistractor,

  /// Nit as working model (correct).
  meetNitWorkingModel,

  /// Nit as insult (mistake).
  meetNitInsult,

  /// Respect nit check-raise because range is strong.
  citeNitStrongRange,

  /// Respect because fear (mistake).
  citeNitFear,

  /// Observe wild: extreme entry / aggression (correct).
  observeExtremeEntry,

  /// Observe wild distractor: narrow and timid.
  observeNarrowTimid,

  /// Observe wild: continues pressure too wide (correct).
  observeWidePressure,

  /// Observe wild distractor: never bets.
  observeNeverBets,

  /// Observe wild: calm frequency notes (correct).
  observeCalmNotes,

  /// Observe wild distractor: revenge / ego notes.
  observeEgoNotes,

  /// Observe wild checkpoint: enters + barrels (correct).
  observeManiacBundle,

  /// Observe wild checkpoint distractor: almost never plays.
  observeWildNitBundle,

  /// Meet Maniac label (correct for extreme entry evidence).
  meetManiacLabel,

  /// Nit distractor on maniac evidence.
  meetManiacNitDistractor,

  /// Meet Maniac label for light 3-bet / never-give-up.
  meetManiacLabel2,

  /// Calling Station distractor on maniac evidence.
  meetManiacStationDistractor,

  /// Mix only Station / Nit / Maniac (correct).
  meetManiacMixThree,

  /// Mix an unlabeled loose seat too early (mistake).
  meetManiacMixEarly,

  /// Call wider vs maniac because betting range is wide (correct).
  citeManiacWideBet,

  /// Call wider to prove bravery (mistake).
  citeManiacBrave,

  /// One observation — low certainty (correct).
  confidenceOneNote,

  /// Type proven forever from one hand (mistake).
  confidenceProvenForever,

  /// Confidence rises but stays revisable (correct).
  confidenceRiseRevisable,

  /// Stay at zero forever (mistake).
  confidenceStayZero,

  /// Update/retire the station model (correct).
  confidenceUpdateModel,

  /// Keep the old label forever (mistake).
  confidenceFreezeModel,

  /// Show sample/confidence limits (correct).
  confidenceShowLimits,

  /// Destiny and aura (mistake).
  confidenceDestinyAura,

  /// S4 jump: UTG open is stronger/narrower (correct).
  jumpUtgNarrower,

  /// S4 jump: UTG open is any two (mistake).
  jumpUtgAnyTwo,

  /// S4 jump: Calling Station exploit (correct).
  jumpStationValue,

  /// S4 jump: Station bluff more (mistake).
  jumpStationBluff,

  /// S4 jump: Nit respect + steal (correct).
  jumpNitRespect,

  /// S4 jump: Nit bluff-catch light (mistake).
  jumpNitBluffCatch,

  /// S4 jump: Maniac widen catch (correct).
  jumpManiacCall,

  /// S4 jump: Maniac fold all one-pair (mistake).
  jumpManiacFoldAll,

  /// Multiway: nut flush draw (correct).
  multiwayNutFd,

  /// Multiway: weak flush draw (questionable).
  multiwayWeakFd,

  /// Multiway: complete air (mistake).
  multiwayAirStab,

  /// Multiway checkpoint: nut potential (correct).
  multiwayNutsPriority,

  /// Multiway checkpoint: any two (mistake).
  multiwayAnyTwo,

  /// Deep: implied odds for sets (correct).
  deepImpliedOdds,

  /// Deep: SPR already low (mistake).
  deepSprLow,

  /// Deep: bluff every flop (mistake).
  deepBluffEvery,

  /// Deep unguided: map turn/river plans (correct).
  deepMapPlans,

  /// Deep unguided: jam any pair now (mistake).
  deepJamNow,

  /// Deep checkpoint: position/implied/folds (correct).
  deepRewardsPos,

  /// Deep checkpoint: automatic light stacks (mistake).
  deepRewardsSpew,

  /// Implied-odds checkpoint: deep + paying (correct).
  ioDepthPay,

  /// Implied-odds checkpoint: short stacks always (mistake).
  ioShortAlways,

  /// Thin-value checkpoint: change the line when the read justifies it (correct).
  thinValueReadLine,

  /// Thin-value checkpoint: flip a coin (mistake).
  thinValueFlipCoin,

  /// Lines guided: Nit XR value-heavy (correct).
  linesNitValueHeavy,

  /// Lines guided: always a bluff (mistake).
  linesNitAlwaysBluff,

  /// Lines unguided: polarized donk (correct).
  linesDonkPolar,

  /// Lines unguided: always medium pairs (mistake).
  linesDonkMerged,

  /// Lines checkpoint: delayed after weakness (correct).
  linesDelayAfterWeak,

  /// Lines checkpoint: delay every hand (mistake).
  linesDelayAlways,

  /// Line-reading guided: bet flop / check turn → capped (correct).
  lineReadCapped,

  /// Line-reading guided: still full of nuts (mistake).
  lineReadStillNuts,

  /// Line-reading unguided: rebuild after every action (correct).
  lineReadRebuild,

  /// Line-reading unguided: lock flop forever (mistake).
  lineReadLockFlop,

  /// Line-reading checkpoint: uncapped pressure (correct).
  lineReadUncapped,

  /// Line-reading checkpoint: always bluff (mistake).
  lineReadAlwaysBluff,

  /// Timing guided: soft evidence (correct).
  timingSoftEvidence,

  /// Timing guided: proven nuts (mistake).
  timingProvenNuts,

  /// Timing guided: proven bluff (mistake).
  timingProvenBluff,

  /// Timing scaffolded: weaker / blocking (correct).
  timingWeakerBlocking,

  /// Timing scaffolded: solver known (mistake).
  timingSolverKnown,

  /// Timing unguided: reject magic tells (correct).
  timingRejectMagic,

  /// Timing unguided: trust the book (mistake).
  timingTrustBook,

  /// Timing checkpoint: tiny update (correct).
  timingTinyUpdate,

  /// Timing checkpoint: only evidence (mistake).
  timingOnlyEvidence,

  /// Table dynamics guided: stuck / tilted (correct).
  dynamicsStuckTilted,

  /// Table dynamics guided: ignore dynamics (mistake).
  dynamicsIgnore,

  /// Table dynamics scaffolded: gear change (correct).
  dynamicsGearChange,

  /// Table dynamics scaffolded: old label (mistake).
  dynamicsOldLabel,

  /// Table dynamics checkpoint: fresh samples (correct).
  dynamicsFreshSamples,

  /// Table dynamics checkpoint: permanent seats (mistake).
  dynamicsPermanentSeats,

  /// Session discipline guided: stop / move down (correct).
  disciplineStop,

  /// Session discipline guided: reload / chase (mistake).
  disciplineReload,

  /// Session discipline scaffolded: decline stakes (correct).
  disciplineDecline,

  /// Session discipline scaffolded: jump up (mistake).
  disciplineJump,

  /// Session discipline unguided: cash out (correct).
  disciplineCashOut,

  /// Session discipline unguided: stay forever (mistake).
  disciplineStay,

  /// Session discipline checkpoint: your edge (correct).
  disciplineEdge,

  /// Session discipline checkpoint: soft skills only (mistake).
  disciplineSoftOnly,

  /// S5 exit multiway: bluff more (mistake).
  s5CpBluffMore,

  /// S5 exit tell: absolute nuts claim (mistake).
  s5CpAbsoluteNuts,

  /// S5 exit stop: chase after stop-loss (mistake).
  s5CpChase,

  /// Range/nut guided: preflop raiser (correct).
  rangeAdvPfr,

  /// Range/nut guided: flatting BB (mistake).
  rangeAdvCaller,

  /// Range/nut scaffolded: wide caller nuts (correct).
  rangeAdvWideCaller,

  /// Range/nut scaffolded: PFR always nuts (mistake).
  rangeAdvPfrAlways,

  /// Range/nut checkpoint: apply pressure (correct).
  rangeAdvPress,

  /// Range/nut checkpoint: bet any two (mistake).
  rangeAdvBetAnyTwo,

  /// Equity realize guided: in position (correct).
  eqRealizeIp,

  /// Equity realize guided: out of position (mistake).
  eqRealizeOop,

  /// Equity realize scaffolded: discount / fold (correct).
  eqRealizeDiscount,

  /// Equity realize scaffolded: hero-call (mistake).
  eqRealizeHero,

  /// Equity realize unguided: fold equity (correct).
  eqRealizeFoldEq,

  /// Equity realize unguided: fancy play (mistake).
  eqRealizeFancy,

  /// Equity realize checkpoint: position + initiative (correct).
  eqRealizePosInit,

  /// Equity realize checkpoint: hope alone (mistake).
  eqRealizeHope,

  /// Capped/uncapped guided: check-turn capped (correct).
  cappedCheckTurn,

  /// Capped/uncapped guided: still full nuts (mistake).
  cappedStillNuts,

  /// Capped/uncapped unguided: uncapped XR line (correct).
  uncappedXrLine,

  /// Capped/uncapped unguided: capped air only (mistake).
  cappedAirOnly,

  /// Capped/uncapped checkpoint: attack caps (correct).
  capsAttack,

  /// Capped/uncapped checkpoint: auto-fold (mistake).
  capsAutoFold,

  /// Polar/merged guided: polarized overbet shape (correct).
  polarShape,

  /// Polar/merged guided: merged shape (mistake).
  mergedShape,

  /// Polar/merged unguided: tiny polar bluffs (correct mismatch).
  polarTinyBluffs,

  /// Polar/merged unguided: any size fine (mistake).
  polarAnySize,

  /// Polar/merged checkpoint: extract thin value (correct).
  polarThinValue,

  /// Polar/merged checkpoint: only bet nuts (mistake).
  polarOnlyNuts,

  /// Overbet guided: nuts / bluffs candidate (correct).
  overbetNutsBluffs,

  /// Overbet guided: top pair weak (mistake).
  overbetTopPairWeak,

  /// Overbet unguided: avoid random bombs (correct).
  overbetAvoid,

  /// Overbet unguided: always fine (mistake).
  overbetAlwaysFine,

  /// Overbet checkpoint: multi-street plan (correct).
  overbetMultiStreet,

  /// Overbet checkpoint: look flashy (mistake).
  overbetLookFlashy,

  /// Blockers guided: ace of the flush suit (correct).
  blockersAce,

  /// Blockers guided: no blockers (questionable).
  blockersNone,

  /// Blockers guided: fake +EV (mistake).
  blockersFakeEv,

  /// Blockers scaffolded: unblock bluffs (correct).
  blockersUnblock,

  /// Blockers scaffolded: block their air (mistake).
  blockersBlockAir,

  /// Blockers unguided: tweak evidence (correct).
  blockersTweak,

  /// Blockers unguided: replace all reasoning (mistake).
  blockersReplace,

  /// Blockers checkpoint: no fake EV (correct).
  blockersNoFakeEv,

  /// Blockers checkpoint: invent EVs (mistake).
  blockersInventEv,

  /// Min-defense guided: strong catchers (correct).
  defendStrongCatchers,

  /// Min-defense guided: any two for % (mistake).
  defendAnyTwoPct,

  /// Min-defense unguided: intuition (correct).
  defendIntuition,

  /// Min-defense unguided: exact percents (mistake).
  defendExactPercents,

  /// Min-defense checkpoint: punish over-bluffs (correct).
  defendPunishOverbluffs,

  /// Min-defense checkpoint: never fold (mistake).
  defendNeverFold,

  /// Mixed strategy scaffolded: less bluff vs station (correct).
  mixLessBluff,

  /// Mixed strategy scaffolded: same mix always (mistake).
  mixSameAlways,

  /// Mixed strategy unguided: need a reason (correct).
  mixNeedReason,

  /// Mixed strategy unguided: always random (mistake).
  mixAlwaysRandom,

  /// Mixed strategy checkpoint: purpose frequency (correct).
  mixPurposeFreq,

  /// Mixed strategy checkpoint: chaos (mistake).
  mixChaos,

  /// 3-bet/4-bet guided: high commit (correct).
  threeBetHighCommit,

  /// 3-bet/4-bet guided: 300bb deep (mistake).
  threeBetPlayDeep,

  /// 3-bet/4-bet unguided: avoid ego (correct).
  threeBetAvoidEgo,

  /// 3-bet/4-bet unguided: ego 4-bet (mistake).
  threeBetEgoFourBet,

  /// 3-bet/4-bet checkpoint: SPR / commit (correct).
  threeBetSprCommit,

  /// 3-bet/4-bet checkpoint: felt suits (mistake).
  threeBetFeltSuits,

  /// Hard folds scaffolded: cooler (correct).
  hardFoldCoolerOk,

  /// Hard folds scaffolded: fold KK (mistake).
  hardFoldFoldKk,

  /// Hard folds unguided: ego call (correct recognition).
  hardFoldEgoCall,

  /// Hard folds unguided: sound play (mistake).
  hardFoldSoundPlay,

  /// Hard folds checkpoint: cooler / mistake? (correct).
  hardFoldAskReview,

  /// Hard folds checkpoint: tilt harder (mistake).
  hardFoldTiltHarder,

  /// Observe selective guided: selective + plan (correct).
  selectivePlanOk,

  /// Observe selective guided: loose passive (mistake).
  selectiveLoosePassive,

  /// Observe selective guided: label now (mistake).
  selectiveLabelNow,

  /// Observe selective scaffolded: disciplined (correct).
  selectiveDisciplined,

  /// Observe selective scaffolded: same maniac (mistake).
  selectiveSameManiac,

  /// Observe selective unguided: keep sampling (correct).
  selectiveKeepSampling,

  /// Observe selective unguided: max certainty (mistake).
  selectiveMaxCertainty,

  /// Observe selective checkpoint: tight · plan · give (correct).
  selectiveEvidenceBundle,

  /// Observe selective checkpoint: good haircut (mistake).
  selectiveHaircut,

  /// Meet TAG label (correct for selective + disciplined evidence).
  meetTagLabel,

  /// Calling Station distractor on TAG evidence.
  meetTagStationDistractor,

  /// Meet TAG scaffolded: selective vs extreme (correct).
  meetTagSelectiveDiff,

  /// Meet TAG scaffolded: identical labels (mistake).
  meetTagIdentical,

  /// Meet TAG label for tight opens / selective c-bets.
  meetTagLabel2,

  /// Maniac distractor on TAG evidence.
  meetTagManiacDistractor,

  /// Meet TAG checkpoint: working model (correct).
  meetTagWorkingModel,

  /// Meet TAG checkpoint: insult (mistake).
  meetTagInsult,

  /// Adjust vs TAG checkpoint: selective + disciplined cite (correct).
  citeTagSelective,

  /// Adjust vs TAG checkpoint: vibes (mistake).
  citeTagVibes,

  /// LAG observe guided: wide + pressure (correct).
  lagObserveWidePressure,

  /// LAG observe guided: nit distractor.
  lagObserveNitDistractor,

  /// LAG observe guided: label now (mistake).
  lagObserveLabelNow,

  /// LAG observe scaffolded: some folds vs maniac (correct).
  lagObserveSomeFolds,

  /// LAG observe scaffolded: no difference (mistake).
  lagObserveNoDiff,

  /// LAG observe unguided: keep sampling (correct).
  lagObserveKeepSampling,

  /// LAG observe unguided: label now (mistake).
  lagObserveLockNow,

  /// LAG observe checkpoint: evidence bundle (correct).
  lagObserveBundle,

  /// LAG observe checkpoint: seem loud (mistake).
  lagObserveSeemLoud,

  /// Meet LAG label (correct for wide + pressure evidence).
  meetLagLabel,

  /// TAG distractor on LAG evidence.
  meetLagTagDistractor,

  /// Meet LAG scaffolded: pressure vs passive (correct).
  meetLagPressureDiff,

  /// Meet LAG scaffolded: same exploit (mistake).
  meetLagSameExploit,

  /// Meet LAG label for wide opens / sustained barrels.
  meetLagLabel2,

  /// Nit distractor on LAG evidence.
  meetLagNitDistractor,

  /// Meet LAG checkpoint: sample limits (correct).
  meetLagSampleLimits,

  /// Meet LAG checkpoint: destiny (mistake).
  meetLagDestiny,

  /// Adjust vs LAG unguided: usually avoid fancy bluffs (correct).
  citeLagAvoid,

  /// Adjust vs LAG unguided: bluff more (mistake).
  citeLagBluffMore,

  /// Adjust vs LAG checkpoint: wide + pressure cite (correct).
  citeLagWidePressure,

  /// Adjust vs LAG checkpoint: vibes (mistake).
  citeLagVibes,

  /// Mix five types: TAG — respect the raise (correct).
  mixFiveTagRespect,

  /// Mix five types: Calling Station — bluff more (mistake).
  mixFiveStationBluff,

  /// S6 section checkpoint: range advantage (correct).
  s6CpRangeAdvantage,

  /// S6 section checkpoint: no concept applies (mistake).
  s6CpNoConcept,

  /// S6 section checkpoint: more capped (correct).
  s6CpMoreCapped,

  /// S6 section checkpoint: more uncapped nuts (mistake).
  s6CpUncappedNuts,

  /// S6 section checkpoint: polarized (correct).
  s6CpPolarized,

  /// S6 section checkpoint: always merged thin value (mistake).
  s6CpAlwaysMerged,

  /// S6 section checkpoint: TAG label (correct).
  s6CpTag,

  /// S6 section checkpoint: LAG distractor on TAG evidence.
  s6CpLagDistractor,

  /// S6 section checkpoint: LAG label (correct).
  s6CpLag,

  /// S6 section checkpoint: Nit distractor on LAG evidence.
  s6CpNit,

  /// Preflop→flop guided: plan is sick (correct).
  preflopFlopPlanSick,

  /// Preflop→flop guided: still jam every street (mistake).
  preflopFlopStillJam,

  /// Preflop→flop scaffolded: value continues (correct).
  preflopFlopValueContinues,

  /// Preflop→flop scaffolded: auto-fold top two (mistake).
  preflopFlopAutoFold,

  /// Preflop→flop unguided: name the thesis (correct).
  preflopFlopNameThesis,

  /// Preflop→flop unguided: wing it (mistake).
  preflopFlopWingIt,

  /// Preflop→flop checkpoint: abandon quickly (correct).
  preflopFlopAbandon,

  /// Preflop→flop checkpoint: force the old line (mistake).
  preflopFlopForce,

  /// Turn-map guided: aces & blanks continue (correct).
  turnMapAcesBlanks,

  /// Turn-map guided: any card always (mistake).
  turnMapAnyCard,

  /// Turn-map scaffolded: give up (correct).
  turnMapGiveUp,

  /// Turn-map scaffolded: hero-call sunk cost (mistake).
  turnMapHeroCall,

  /// Turn-map unguided: map first (correct).
  turnMapMapFirst,

  /// Turn-map unguided: yolo barrels (mistake).
  turnMapYolo,

  /// Turn-map checkpoint: continue/kill list (correct).
  turnMapContinueKill,

  /// Turn-map checkpoint: invent later (mistake).
  turnMapInventLater,

  /// River composition scaffolded: blocks strong calls (correct).
  riverCompBlocks,

  /// River composition scaffolded: fake EV sheet (mistake).
  riverCompFakeEv,

  /// River composition unguided: check (correct).
  riverCompCheck,

  /// River composition unguided: blast off (mistake).
  riverCompBlast,

  /// River composition checkpoint: value needs calls (correct).
  riverCompRule,

  /// River composition checkpoint: bet every river (mistake).
  riverCompStyle,

  /// Pot-type guided: nut potential (correct).
  potTypeNutPotential,

  /// Pot-type guided: pure air stabs (mistake).
  potTypePureAir,

  /// Pot-type scaffolded: c-bet maps (correct).
  potTypeCbetMaps,

  /// Pot-type scaffolded: never bet (mistake).
  potTypeNeverBet,

  /// Pot-type unguided: higher commitment (correct).
  potTypeHigherCommit,

  /// Pot-type unguided: play like 300bb deep (mistake).
  potTypeDeepLike300,

  /// Pot-type checkpoint: ranges and SPR (correct).
  potTypeRangesSpr,

  /// Pot-type checkpoint: nothing material (mistake).
  potTypeNothing,

  /// HU vs multiway guided: usually no naked air (correct).
  huMwUsuallyNo,

  /// HU vs multiway guided: always yes (mistake).
  huMwAlwaysYes,

  /// HU vs multiway scaffolded: higher HU steal (correct).
  huMwHigherHu,

  /// HU vs multiway scaffolded: identical always (mistake).
  huMwIdentical,

  /// HU vs multiway unguided: thicker value (correct).
  huMwThickerValue,

  /// HU vs multiway unguided: ultra-slow (questionable).
  huMwUltraSlow,

  /// HU vs multiway checkpoint: first-class input (correct).
  huMwFirstClass,

  /// HU vs multiway checkpoint: noise (mistake).
  huMwNoise,

  /// Stack-depth guided: closer to stacking (correct).
  stackDepthCloserCommit,

  /// Stack-depth guided: play as 250bb deep (mistake).
  stackDepthPlayDeep,

  /// Stack-depth scaffolded: more attractive with depth (correct).
  stackDepthMoreAttractive,

  /// Stack-depth scaffolded: never set-mine deep (mistake).
  stackDepthNeverMine,

  /// Stack-depth unguided: 40bb effective (correct).
  stackDepth40bb,

  /// Stack-depth unguided: 200bb (mistake).
  stackDepth200bb,

  /// Stack-depth checkpoint: every hand (correct).
  stackDepthEveryHand,

  /// Stack-depth checkpoint: once per lifetime (mistake).
  stackDepthOnceLifetime,

  /// Same-cards checkpoint: baseline strategy (correct).
  sameCardsBaseline,

  /// Same-cards checkpoint: guess a type and overfit (mistake).
  sameCardsGuess,

  /// Type-board-line checkpoint: all four inputs (correct).
  typeBoardAllFour,

  /// Type-board-line checkpoint: hole-card beauty alone (mistake).
  typeBoardCardsOnly,

  /// Leak-review guided: specific actionable note (correct).
  leakReviewSpecific,

  /// Leak-review guided: vague "I am bad" (mistake).
  leakReviewVague,

  /// Leak-review scaffolded: written range family (correct).
  leakReviewWrittenRange,

  /// Leak-review scaffolded: whatever mood says (mistake).
  leakReviewMood,

  /// Leak-review unguided: after sessions on a schedule (correct).
  leakReviewOnSchedule,

  /// Leak-review unguided: never — memory is enough (mistake).
  leakReviewNever,

  /// Leak-review checkpoint: baseline before exploits (correct).
  leakReviewBaseline,

  /// Leak-review checkpoint: replace all thinking forever (mistake).
  leakReviewReplaceAll,
}

/// How the mini-table is arranged.
enum LessonTableLayout {
  /// Hole cards + optional board / villains (Your two cards).
  holeCards,

  /// Six-max seats with button / blinds chips.
  blindsSeats,

  /// Six-max seats labeled EP / HJ / CO / BTN / SB / BB.
  positionLabels,

  /// Hand-phase timing tiles for when blinds post.
  blindsTiming,

  /// Timing tiles for when a betting street ends.
  streetEndPhases,

  /// Fold-win outcome tiles (take pot / must show / dealer shows).
  potFoldWinOutcomes,

  /// Showdown outcome tiles after a river call.
  potShowdownOutcomes,

  /// Side-pot outcome tiles when short all-in.
  potSideOutcomes,

  /// Open-to-6 pot size tiles (7 / 9 / 12 chips).
  potOpenSizeOutcomes,

  /// Live-habit tiles: cover+wait / act early / leave bare.
  habitCoverOutcomes,

  /// Effective-stack tiles: shorter / hero / sum.
  effectiveStackOutcomes,

  /// Multiway pot tiles after open + callers (21 / 18 / 12).
  potMultiwayOutcomes,

  /// Call-price tiles after a bet (10 / 20 / 30).
  callPriceOutcomes,

  /// Draw call/fold/raise tiles when priced in.
  drawPriceOutcomes,

  /// Verbal declaration tiles: raise stands / takeback / dealer.
  verbalBindingOutcomes,

  /// Table-read checkpoint: effective+pot / hero only / ignore pot.
  tableReadMattersOutcomes,

  /// Observe sticky: high / low participation / label-now tiles.
  observeParticipationOutcomes,

  /// Meet Calling Station: Station vs Nit label tiles on sticky evidence.
  playerTypeStationOutcomes,

  /// Meet Calling Station: working model vs permanent verdict.
  labelModelOutcomes,

  /// Meet Calling Station: Station vs Maniac on limp/call evidence.
  playerTypeStationManiacOutcomes,

  /// Meet Calling Station: sample confidence low vs max.
  sampleConfidenceOutcomes,

  /// Adjust vs Station: why bluff less (rarely folds vs mean label).
  stationBluffCiteOutcomes,

  /// Observe narrow: narrow vs wide entry.
  observeNarrowEntryOutcomes,

  /// Observe narrow: strong aggression vs passive.
  observeNarrowAggressionOutcomes,

  /// Observe narrow: wait vs label now.
  observeNarrowSampleOutcomes,

  /// Observe narrow checkpoint: nit vs station bundle.
  observeNarrowBundleOutcomes,

  /// Observe wild: extreme vs timid entry.
  observeWildEntryOutcomes,

  /// Observe wild: wide pressure vs never bets.
  observeWildPressureOutcomes,

  /// Observe wild: calm notes vs ego.
  observeWildNotesOutcomes,

  /// Observe wild checkpoint: maniac vs nit bundle.
  observeWildBundleOutcomes,

  /// Meet Maniac: Maniac vs Nit label tiles.
  meetManiacVsNitOutcomes,

  /// Meet Maniac: Maniac vs Station label tiles.
  meetManiacVsStationOutcomes,

  /// Meet Maniac checkpoint: mix three introduced types.
  meetManiacMixOutcomes,

  /// Adjust vs Maniac: cite wide betting range.
  maniacCallCiteOutcomes,

  /// Confidence: one note vs proven forever.
  confidenceOneNoteOutcomes,

  /// Confidence: rise revisable vs stay zero.
  confidenceRiseOutcomes,

  /// Confidence: update model vs freeze.
  confidenceUpdateOutcomes,

  /// Confidence checkpoint: limits vs destiny.
  confidenceLimitsOutcomes,

  /// S4 jump: UTG range narrower vs any two.
  jumpUtgRangeOutcomes,

  /// S4 jump: station exploit tiles.
  jumpStationExploitOutcomes,

  /// S4 jump: nit exploit tiles.
  jumpNitExploitOutcomes,

  /// S4 jump: maniac exploit tiles.
  jumpManiacExploitOutcomes,

  /// Multiway guided: NFD vs weak FD vs air.
  multiwayContinueOutcomes,

  /// Multiway checkpoint: nut potential vs any two.
  multiwayPriorityOutcomes,

  /// Deep guided: implied odds vs wrong theses.
  deepImpliedOutcomes,

  /// Deep unguided: map plans vs jam now.
  deepPlanOutcomes,

  /// Deep checkpoint: depth rewards.
  deepRewardsOutcomes,

  /// Implied-odds checkpoint: when IO rise.
  impliedOddsRiseOutcomes,

  /// Thin-value checkpoint: read-driven line vs coin flip.
  thinValueReadOutcomes,

  /// Lines guided: Nit XR read.
  linesNitXrOutcomes,

  /// Lines unguided: donk meaning.
  linesDonkPolarOutcomes,

  /// Lines checkpoint: delayed c-bet timing.
  linesDelayOutcomes,

  /// Line-reading guided: capped vs still nuts.
  lineReadCappedOutcomes,

  /// Line-reading unguided: rebuild vs lock flop.
  lineReadRebuildOutcomes,

  /// Line-reading checkpoint: uncapped vs always bluff.
  lineReadUncappedOutcomes,

  /// Timing guided: soft evidence vs proven nuts/bluff.
  timingSoftEvidenceOutcomes,

  /// Timing scaffolded: weaker/blocking vs solver known.
  timingSizingWeakOutcomes,

  /// Timing unguided: reject magic vs trust book.
  timingRejectMagicOutcomes,

  /// Timing checkpoint: tiny update vs only evidence.
  timingTinyUpdateOutcomes,

  /// Table dynamics guided: stuck/tilted vs ignore.
  dynamicsStuckOutcomes,

  /// Table dynamics scaffolded: gear change vs old label.
  dynamicsGearOutcomes,

  /// Table dynamics checkpoint: fresh samples vs permanent seats.
  dynamicsFreshOutcomes,

  /// Session discipline guided: stop vs reload.
  disciplineStopOutcomes,

  /// Session discipline scaffolded: decline vs jump.
  disciplineStakesOutcomes,

  /// Session discipline unguided: cash out vs stay.
  disciplineCashOutOutcomes,

  /// Session discipline checkpoint: edge vs soft skills.
  disciplineEdgeOutcomes,

  /// S5 exit: nut potential vs bluff more multiway.
  s5CpMultiOutcomes,

  /// S5 exit: soft evidence vs absolute nuts.
  s5CpTellOutcomes,

  /// S5 exit: honor stop vs chase.
  s5CpStopOutcomes,

  /// Range/nut guided: PFR vs flatting BB.
  rangeAdvPfrOutcomes,

  /// Range/nut scaffolded: wide caller vs PFR always.
  rangeAdvNutsOutcomes,

  /// Range/nut checkpoint: apply pressure vs bet any two.
  rangeAdvPressOutcomes,

  /// Equity realize guided: IP vs OOP.
  eqRealizeIpOutcomes,

  /// Equity realize scaffolded: discount vs hero-call.
  eqRealizeDiscountOutcomes,

  /// Equity realize unguided: fold equity vs fancy play.
  eqRealizeAggressionOutcomes,

  /// Equity realize checkpoint: position+initiative vs hope.
  eqRealizePosOutcomes,

  /// Capped/uncapped guided: capped vs still nuts.
  cappedGuidedOutcomes,

  /// Capped/uncapped unguided: uncapped XR vs capped air.
  cappedUncappedLineOutcomes,

  /// Capped/uncapped checkpoint: attack caps vs auto-fold.
  cappedAttackOutcomes,

  /// Polar/merged guided: polarized vs merged.
  polarGuidedOutcomes,

  /// Polar/merged unguided: tiny bluffs vs any size.
  polarMismatchOutcomes,

  /// Polar/merged checkpoint: thin value vs only nuts.
  polarAimOutcomes,

  /// Overbet guided: nuts/bluffs vs top pair weak.
  overbetGuidedOutcomes,

  /// Overbet unguided: avoid vs always fine.
  overbetAvoidOutcomes,

  /// Overbet checkpoint: multi-street plan vs look flashy.
  overbetPlanOutcomes,

  /// Blockers guided: Ace blocker vs no blockers vs fake +EV.
  blockersGuidedOutcomes,

  /// Blockers scaffolded: unblock bluffs vs block their air.
  blockersUnblockOutcomes,

  /// Blockers unguided: tweak evidence vs replace all reasoning.
  blockersTweakOutcomes,

  /// Blockers checkpoint: no fake EV vs invent EVs.
  blockersEvOutcomes,

  /// Min-defense guided: strong catchers vs any two for %.
  defendGuidedOutcomes,

  /// Min-defense unguided: intuition vs exact percents.
  defendIntuitionOutcomes,

  /// Min-defense checkpoint: punish over-bluffs vs never fold.
  defendPunishOutcomes,

  /// Mixed strategy scaffolded: less bluff vs same mix.
  mixStationOutcomes,

  /// Mixed strategy unguided: need a reason vs always random.
  mixReasonOutcomes,

  /// Mixed strategy checkpoint: purpose freq vs chaos.
  mixPurposeOutcomes,

  /// 3-bet/4-bet guided: high commit vs 300bb deep.
  threeBetCommitOutcomes,

  /// 3-bet/4-bet unguided: avoid ego vs ego 4-bet.
  threeBetEgoOutcomes,

  /// 3-bet/4-bet checkpoint: SPR / commit vs felt suits.
  threeBetSprOutcomes,

  /// Hard folds scaffolded: cooler vs fold KK.
  hardFoldCoolerOutcomes,

  /// Hard folds unguided: ego call vs sound play.
  hardFoldEgoOutcomes,

  /// Hard folds checkpoint: cooler / mistake? vs tilt harder.
  hardFoldReviewOutcomes,

  /// Observe selective guided: selective + plan vs loose vs label now.
  selectiveGuidedOutcomes,

  /// Observe selective scaffolded: disciplined vs same maniac.
  selectiveDiscOutcomes,

  /// Observe selective unguided: keep sampling vs max certainty.
  selectiveSampleOutcomes,

  /// Observe selective checkpoint: tight · plan · give vs good haircut.
  selectiveBundleOutcomes,

  /// Meet TAG: TAG vs Station label tiles.
  meetTagVsStationOutcomes,

  /// Meet TAG: selective vs extreme difference.
  meetTagDiffOutcomes,

  /// Meet TAG: TAG vs Maniac label tiles.
  meetTagVsManiacOutcomes,

  /// Meet TAG: working model vs insult.
  meetTagModelOutcomes,

  /// Adjust vs TAG: selective cite vs vibes.
  tagRespectCiteOutcomes,

  /// LAG observe: wide + pressure vs nit vs label now.
  lagObserveGuidedOutcomes,

  /// LAG observe: some folds vs no difference.
  lagObserveDiscOutcomes,

  /// LAG observe: keep sampling vs label now.
  lagObserveSampleOutcomes,

  /// LAG observe: wide · barrels · folds vs seem loud.
  lagObserveBundleOutcomes,

  /// Meet LAG: LAG vs TAG label tiles.
  meetLagVsTagOutcomes,

  /// Meet LAG: pressure vs passive difference.
  meetLagDiffOutcomes,

  /// Meet LAG: LAG vs Nit label tiles.
  meetLagVsNitOutcomes,

  /// Meet LAG: sample limits vs destiny.
  meetLagLimitsOutcomes,

  /// Adjust vs LAG: usually avoid vs bluff more.
  lagAdjustAvoidOutcomes,

  /// Adjust vs LAG: wide + pressure cite vs vibes.
  lagAdjustCiteOutcomes,

  /// Mix five types checkpoint: TAG respect vs Station bluff.
  mixFiveTagRespectOutcomes,

  /// S6 section checkpoint: range advantage vs no concept.
  s6CpAdvOutcomes,

  /// S6 section checkpoint: more capped vs uncapped nuts.
  s6CpCapOutcomes,

  /// S6 section checkpoint: polarized vs always merged.
  s6CpPolarOutcomes,

  /// S6 section checkpoint: TAG vs LAG.
  s6CpTagOutcomes,

  /// S6 section checkpoint: LAG vs Nit.
  s6CpLagOutcomes,

  /// Meet Nit: Nit vs Calling Station.
  meetNitVsStationOutcomes,

  /// Meet Nit: Nit vs Maniac.
  meetNitVsManiacOutcomes,

  /// Meet Nit: working model vs insult.
  meetNitModelOutcomes,

  /// Adjust vs Nit: cite strong range vs fear.
  nitRespectCiteOutcomes,

  /// Preflop→flop guided: plan is sick vs still jam.
  preflopFlopGuidedOutcomes,

  /// Preflop→flop scaffolded: value continues vs auto-fold.
  preflopFlopScaffoldedOutcomes,

  /// Preflop→flop unguided: name thesis vs wing it.
  preflopFlopUnguidedOutcomes,

  /// Preflop→flop checkpoint: abandon vs force.
  preflopFlopCheckpointOutcomes,

  /// Turn-map guided: aces & blanks vs any card.
  turnMapGuidedOutcomes,

  /// Turn-map scaffolded: give up vs hero-call.
  turnMapScaffoldedOutcomes,

  /// Turn-map unguided: map first vs yolo.
  turnMapUnguidedOutcomes,

  /// Turn-map checkpoint: continue/kill list vs invent later.
  turnMapCheckpointOutcomes,

  /// River composition scaffolded: blocks vs fake EV.
  riverCompScaffoldedOutcomes,

  /// River composition unguided: check vs blast.
  riverCompUnguidedOutcomes,

  /// River composition checkpoint: rule vs style.
  riverCompCheckpointOutcomes,

  /// Pot-type guided: nut potential vs pure air.
  potTypeGuidedOutcomes,

  /// Pot-type scaffolded: c-bet maps vs never bet.
  potTypeScaffoldedOutcomes,

  /// Pot-type unguided: higher commitment vs 300bb deep.
  potTypeUnguidedOutcomes,

  /// Pot-type checkpoint: ranges and SPR vs nothing.
  potTypeCheckpointOutcomes,

  /// HU vs multiway guided: usually no vs always yes.
  huMwGuidedOutcomes,

  /// HU vs multiway scaffolded: higher HU vs identical.
  huMwScaffoldedOutcomes,

  /// HU vs multiway unguided: thicker value vs ultra-slow.
  huMwUnguidedOutcomes,

  /// HU vs multiway checkpoint: first-class input vs noise.
  huMwCheckpointOutcomes,

  /// Stack-depth guided: closer to stacking vs 250bb deep.
  stackDepthGuidedOutcomes,

  /// Stack-depth scaffolded: more attractive vs never set-mine.
  stackDepthScaffoldedOutcomes,

  /// Stack-depth unguided: 40bb vs 200bb effective.
  stackDepthUnguidedOutcomes,

  /// Stack-depth checkpoint: every hand vs once per lifetime.
  stackDepthCheckpointOutcomes,

  /// Same-cards checkpoint: baseline vs guess/overfit.
  sameCardsCheckpointOutcomes,

  /// Type-board-line checkpoint: all four vs hole cards only.
  typeBoardCheckpointOutcomes,

  /// Leak-review guided: specific note vs vague.
  leakReviewGuidedOutcomes,

  /// Leak-review scaffolded: written range vs mood.
  leakReviewScaffoldedOutcomes,

  /// Leak-review unguided: on a schedule vs never.
  leakReviewUnguidedOutcomes,

  /// Leak-review checkpoint: baseline vs replace all thinking.
  leakReviewCheckpointOutcomes,
}

/// Authored (or inferred) mini-table scene for a lesson activity.
class LessonTableScene {
  /// Creates a scene.
  const LessonTableScene({
    this.heroCodes = const <String>[],
    this.boardCodes = const <String>[],
    this.villainCodes = const <String>[],
    this.villainSeatCount = 1,
    this.highlight = LessonTableHighlight.none,
    this.caption,
    this.showMuck = false,
    this.showDealerChip = false,
    this.layout = LessonTableLayout.holeCards,
    this.seatCount = 6,
    this.buttonSeat = 5,
    this.numberSeats = false,
    this.showSeatNeverMatters = false,
    this.showRoleLabels = true,
  });

  /// Face-up hero hole cards (e.g. `Ah`, `Kd`).
  final List<String> heroCodes;

  /// Optional community cards in the middle.
  final List<String> boardCodes;

  /// Optional face-up villain hole cards (kicker / showdown spots).
  final List<String> villainCodes;

  /// How many other seats show face-down hole cards.
  /// Ignored when [villainCodes] is non-empty (those seats are face-up).
  final int villainSeatCount;

  /// Soft emphasis for guided teaching (pulse only — never a spoiler label).
  final LessonTableHighlight highlight;

  /// Optional short non-spoiling label under the hero rail (e.g. `You`).
  final String? caption;

  /// Show a small muck pile distractor.
  final bool showMuck;

  /// Show a dealer chip distractor (privacy questions).
  final bool showDealerChip;

  /// Table arrangement for this activity.
  final LessonTableLayout layout;

  /// Seats around the blinds layout (usually 6).
  final int seatCount;

  /// Seat index holding the dealer button (checkpoint uses 5).
  final int buttonSeat;

  /// Show absolute seat numbers (0..n-1) on the blinds layout.
  final bool numberSeats;

  /// Show a "Seat never matters" distractor under position labels.
  final bool showSeatNeverMatters;

  /// When false, identify steps hide "Button" / "SB" word labels so the
  /// chip visuals teach (Duolingo-style — no answer printed on the piece).
  final bool showRoleLabels;
}

/// Which region of the mini-table should read as the teaching target.
enum LessonTableHighlight {
  none,
  hero,
  board,
  button,
  smallBlind,
  bigBlind,
  earlyPosition,
  hijack,
  cutoff,
}

final _cardToken = RegExp(r'\b([2-9TJQKA][shdc])\b', caseSensitive: false);

/// Resolves a table scene for activities that reference the felt / hole cards.
///
/// Returns null when the activity is a pure text quiz (e.g. suit names).
LessonTableScene? resolveLessonTableScene(CourseActivity activity) {
  if (activity.renderer != ActivityRenderer.selectIdentify &&
      activity.renderer != ActivityRenderer.coachDialogue &&
      activity.renderer != ActivityRenderer.playerReadClassify) {
    return null;
  }

  switch (activity.id) {
    case 'act-01-01-01-guided-find-holes':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 1,
        // Soft pulse only — no spoiler caption.
        highlight: LessonTableHighlight.hero,
        caption: 'You',
      );
    case 'act-01-01-01-scaffolded-private':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 2,
        highlight: LessonTableHighlight.none,
        caption: 'You',
        showDealerChip: true,
      );
    case 'act-01-01-01-unguided-mix':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'You',
        showMuck: true,
      );
    case 'act-01-01-01-checkpoint-table':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 3,
        highlight: LessonTableHighlight.none,
        caption: 'You',
      );
    case 'act-01-01-01-explain-hole-cards':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.hero,
        caption: 'You',
      );
    // Suited / pair identify steps: choices are the visual. Do not put the
    // recommended hand on the felt above the options (spoils the puzzle).
    case 'act-01-01-03-explain-button':
      // Explain keeps role names so learners map words → chips.
      return const LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
        showRoleLabels: true,
      );
    case 'act-01-01-03-guided-button':
      return const LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
        showRoleLabels: false,
      );
    case 'act-01-01-03-scaffolded-blinds':
      return const LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.bigBlind,
        seatCount: 6,
        buttonSeat: 3,
        showRoleLabels: false,
      );
    case 'act-01-01-03-unguided-when':
      return const LessonTableScene(
        layout: LessonTableLayout.blindsTiming,
      );
    case 'act-01-01-03-checkpoint-layout':
      return const LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.smallBlind,
        seatCount: 6,
        buttonSeat: 5,
        numberSeats: true,
        showRoleLabels: false,
      );
    case 'act-02-01-01-explain-pos':
    case 'act-02-01-01-guided-btn':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'Six-max · postflop',
      );
    case 'act-02-01-01-scaffolded-blinds':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.smallBlind,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'Six-max · forced bets',
      );
    case 'act-02-01-01-unguided-co':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.cutoff,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'Six-max · before the button',
      );
    case 'act-02-01-01-checkpoint-edge':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
        showSeatNeverMatters: true,
        caption: 'Same hand — EP vs BTN',
      );
    case 'act-02-07-02-jump-pos':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.cutoff,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'Six-max · before the button',
      );
    case 'act-02-07-02-jump-family':
      return const LessonTableScene(
        heroCodes: ['Ah', '5h'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.hero,
        caption: 'Your holes',
      );
    case 'act-02-07-02-jump-stack':
      return const LessonTableScene(
        layout: LessonTableLayout.effectiveStackOutcomes,
        caption: 'You 120bb · Villain 55bb',
      );
    case 'act-03-01-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.potMultiwayOutcomes,
        caption: '1/2 · UTG 6 · BTN call · BB call',
      );
    case 'act-03-01-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.earlyPosition,
        seatCount: 9,
        buttonSeat: 7,
        caption: 'Nine-handed · button seat 7 · tap who opens',
      );
    case 'act-03-01-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.verbalBindingOutcomes,
        caption: 'You said "raise" · live table',
      );
    case 'act-03-01-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.tableReadMattersOutcomes,
        caption: 'Hero 140bb · Villain 55bb · pot 18',
      );
    case 'act-03-02-01-guided':
      return const LessonTableScene(
        heroCodes: ['Kh', 'Qh'],
        boardCodes: ['Ks', '9d', '2c'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'Flop · your holes',
      );
    case 'act-03-02-01-scaffolded':
      return const LessonTableScene(
        heroCodes: ['Ah', '9h'],
        boardCodes: ['Jh', '8h', '3c'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'Flop · nut flush draw',
      );
    case 'act-03-02-01-unguided':
      return const LessonTableScene(
        heroCodes: ['5h', '4h'],
        boardCodes: ['Qc', '7d', '2s'],
        villainSeatCount: 2,
        highlight: LessonTableHighlight.none,
        caption: 'Flop · multiway',
      );
    case 'act-03-02-01-checkpoint':
      return const LessonTableScene(
        heroCodes: ['Js', '8d'],
        boardCodes: ['Ts', '9s', '4d'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'Flop · open-ender',
      );
    case 'act-03-03-01-guided':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Qh'],
        boardCodes: ['Kc', '8h', '2d'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'Flop · clean outs?',
      );
    case 'act-03-03-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.callPriceOutcomes,
        caption: 'Pot 20 · villain bets 10',
      );
    case 'act-03-03-01-unguided':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Qh'],
        boardCodes: ['Kc', '8h', '2d'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'Pot 20 · bet 10 · ~8 clean outs',
      );
    case 'act-03-03-01-checkpoint':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Qh'],
        boardCodes: ['Kh', '7h', '2c'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: '200bb · pot bet · sticky caller',
      );
    case 'act-03-05-01-guided':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', '7d', '2c', '3h'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'Missed c-bet · turn blank?',
      );
    case 'act-03-05-01-checkpoint':
      return const LessonTableScene(
        heroCodes: ['Jh', '9d'],
        boardCodes: ['Kc', '8d', '3s', 'Qh'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'Air bluff · turn completes draws',
      );
    case 'act-03-06-01-checkpoint':
      return const LessonTableScene(
        heroCodes: ['Ah', '9d'],
        boardCodes: ['As', '7c', '2d', 'Kh', '3s'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'Medium one pair · big river bet',
      );
    case 'act-03-07-01-unguided':
      return const LessonTableScene(
        villainSeatCount: 2,
        highlight: LessonTableHighlight.none,
        caption: 'Multiway · deep · pick the speculative',
      );
    case 'act-03-07-01-checkpoint':
      return const LessonTableScene(
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'Seat enters 8 of last 10 pots',
      );
    case 'act-03-08-01-checkpoint':
      return const LessonTableScene(
        villainSeatCount: 2,
        highlight: LessonTableHighlight.none,
        caption: 'Seat A raises a lot · Seat B rarely enters',
      );
    case 'act-03-08-02-jump-table':
      return const LessonTableScene(
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'Pot 16 · shorter stack 40bb',
      );
    case 'act-03-08-02-jump-class':
      return const LessonTableScene(
        heroCodes: ['Jd', 'Td'],
        boardCodes: ['Qd', '9d', '3c'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'Flop · class?',
      );
    case 'act-03-08-02-jump-leak':
      return const LessonTableScene(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['As', '7c', '2d'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'Gutshot · pot 10 · bet 20',
      );
    case 'act-04-01-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.earlyPosition,
        seatCount: 9,
        buttonSeat: 7,
        caption: '1/2 · UTG opens',
      );
    case 'act-04-01-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.none,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'BTN open · BB 3-bet · BTN calls',
      );
    case 'act-04-01-01-unguided':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', '7c', '2d', 'Kh'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'Villain bet flop + turn',
      );
    case 'act-04-01-01-checkpoint':
      return const LessonTableScene(
        heroCodes: ['Qh', 'Qd'],
        boardCodes: ['Qc', '7s', '2d'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'Same board · different villain lines',
      );
    case 'act-04-02-01-unguided':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        villainSeatCount: 2,
        highlight: LessonTableHighlight.none,
        caption: 'UTG open · two callers · you BB with AKo',
      );
    case 'act-04-03-01-checkpoint':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['As', '7c', '2d'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'Flop plan ready — name the turn branches',
      );
    case 'act-04-04-01-unguided':
      return const LessonTableScene(
        heroCodes: ['Qh', 'Qd'],
        boardCodes: ['Kc', '7s', '2d'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'Two value sizes · same story',
      );
    case 'act-04-05-01-checkpoint':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', '7c', '2d'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'Stacks vs pot — decide before you jam',
      );
    case 'act-04-06-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.observeParticipationOutcomes,
        caption: 'Seat calls 7 of 9 preflops',
      );
    case 'act-04-06-01-scaffolded':
      return const LessonTableScene(
        heroCodes: ['Qh', '9d'],
        boardCodes: ['Kc', '9s', '3h', '2d', '7c'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'Called three streets · second pair ×2',
      );
    case 'act-04-06-01-unguided':
      return const LessonTableScene(
        heroCodes: ['Jh', 'Td'],
        boardCodes: ['As', '7c', '2d', '9h', '3s'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'One dramatic river call',
      );
    case 'act-04-06-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        seatCount: 6,
        buttonSeat: 3,
        highlight: LessonTableHighlight.none,
        caption: 'Bundle the evidence before labeling',
      );
    case 'act-04-06-02-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.playerTypeStationOutcomes,
        caption: 'Called 3 streets · second pair ×2',
      );
    case 'act-04-06-02-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.labelModelOutcomes,
        caption: 'Update the label as samples change',
      );
    case 'act-04-06-02-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.playerTypeStationManiacOutcomes,
        caption: 'Limps · calls raises · never folds turns',
      );
    case 'act-04-06-02-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.sampleConfidenceOutcomes,
        caption: 'Only 2 hands tagged so far',
      );
    case 'act-04-06-03-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.stationBluffCiteOutcomes,
        caption: 'Why cut bluffs vs a Calling Station?',
      );
    case 'act-04-07-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.observeNarrowEntryOutcomes,
        caption: 'Folded 20 of 22 hands',
      );
    case 'act-04-07-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.observeNarrowAggressionOutcomes,
        caption: 'Finally raises · then barrels',
      );
    case 'act-04-07-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.observeNarrowSampleOutcomes,
        caption: 'Only two folds so far',
      );
    case 'act-04-07-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.observeNarrowBundleOutcomes,
        caption: 'Bundle the pre-label notes',
      );
    case 'act-04-07-02-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.meetNitVsStationOutcomes,
        caption: '~8% hands · rare but large 3-bets',
      );
    case 'act-04-07-02-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.meetNitVsManiacOutcomes,
        caption: 'Folds forever · then check-raises a barrel',
      );
    case 'act-04-07-02-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.meetNitModelOutcomes,
        caption: 'How to treat the Nit label',
      );
    case 'act-04-07-03-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.nitRespectCiteOutcomes,
        caption: 'Why respect a Nit check-raise?',
      );
    case 'act-04-08-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.observeWildEntryOutcomes,
        caption: 'Raises or 3-bets 12 of 15 pots',
      );
    case 'act-04-08-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.observeWildPressureOutcomes,
        caption: 'Bets flop · turn · river · weak shows',
      );
    case 'act-04-08-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.observeWildNotesOutcomes,
        caption: 'Best note style vs wild aggression',
      );
    case 'act-04-08-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.observeWildBundleOutcomes,
        caption: 'Bundle the pre-label notes',
      );
    case 'act-04-08-02-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.meetManiacVsNitOutcomes,
        caption: 'Opens 60% · triple-barrels light',
      );
    case 'act-04-08-02-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.meetManiacVsStationOutcomes,
        caption: '3-bets light · never gives up rivers',
      );
    case 'act-04-08-02-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.meetManiacMixOutcomes,
        caption: 'Which types are legal to mix now?',
      );
    case 'act-04-08-03-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.maniacCallCiteOutcomes,
        caption: 'Why call wider versus a Maniac?',
      );
    case 'act-04-09-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.confidenceOneNoteOutcomes,
        caption: 'One huge bluff so far',
      );
    case 'act-04-09-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.confidenceRiseOutcomes,
        caption: '30 hands of sticky calls',
      );
    case 'act-04-09-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.confidenceUpdateOutcomes,
        caption: "Former station starts folding streets",
      );
    case 'act-04-09-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.confidenceLimitsOutcomes,
        caption: 'What belongs beside a type label?',
      );
    case 'act-04-10-02-jump-range':
      return const LessonTableScene(
        layout: LessonTableLayout.jumpUtgRangeOutcomes,
        caption: 'UTG open — describe the range',
      );
    case 'act-04-10-02-jump-station':
      return const LessonTableScene(
        layout: LessonTableLayout.jumpStationExploitOutcomes,
        caption: 'Sticky caller three streets',
      );
    case 'act-04-10-02-jump-nit':
      return const LessonTableScene(
        layout: LessonTableLayout.jumpNitExploitOutcomes,
        caption: 'Tiny range · huge check-raise',
      );
    case 'act-04-10-02-jump-maniac':
      return const LessonTableScene(
        layout: LessonTableLayout.jumpManiacExploitOutcomes,
        caption: 'Barrels forever · you have top pair',
      );
    case 'act-05-01-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.multiwayContinueOutcomes,
        caption: 'Four-way flop — best continue',
      );
    case 'act-05-01-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.multiwayPriorityOutcomes,
        caption: 'Multiway construction priority',
      );
    case 'act-05-02-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.deepImpliedOutcomes,
        caption: '200bb · why call a raise with 55?',
      );
    case 'act-05-02-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.deepPlanOutcomes,
        caption: 'SPR ~12 on the flop',
      );
    case 'act-05-02-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.deepRewardsOutcomes,
        caption: '150–300bb cash play rewards?',
      );
    case 'act-05-03-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.impliedOddsRiseOutcomes,
        caption: 'When do implied odds rise most?',
      );
    case 'act-05-04-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.thinValueReadOutcomes,
        caption: 'Same hand, different types — what changes?',
      );
    case 'act-05-05-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.linesNitXrOutcomes,
        caption: 'Nit check-raises flop — default read?',
      );
    case 'act-05-05-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.linesDonkPolarOutcomes,
        caption: 'Large BB donk on dry ace — meaning?',
      );
    case 'act-05-05-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.linesDelayOutcomes,
        caption: 'Delayed c-bet is best when?',
      );
    case 'act-05-06-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.lineReadCappedOutcomes,
        caption: 'Bet flop, check turn — range now?',
      );
    case 'act-05-06-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.lineReadRebuildOutcomes,
        caption: 'Best line-reading habit?',
      );
    case 'act-05-06-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.lineReadUncappedOutcomes,
        caption: 'XR / bet / shove usually means?',
      );
    case 'act-05-07-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.timingSoftEvidenceOutcomes,
        caption: 'Instant river shove — framing?',
      );
    case 'act-05-07-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.timingSizingWeakOutcomes,
        caption: 'Tiny flop bet into huge pot?',
      );
    case 'act-05-07-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.timingRejectMagicOutcomes,
        caption: 'Look-left means bluff?',
      );
    case 'act-05-07-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.timingTinyUpdateOutcomes,
        caption: 'Best use of live timing?',
      );
    case 'act-05-08-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.dynamicsStuckOutcomes,
        caption: 'Lost two buy-ins — note?',
      );
    case 'act-05-08-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.dynamicsGearOutcomes,
        caption: 'Solid player flats junk / donks?',
      );
    case 'act-05-08-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.dynamicsFreshOutcomes,
        caption: 'Dynamic reads should be?',
      );
    case 'act-05-09-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.disciplineStopOutcomes,
        caption: 'Hit planned stop-loss — next?',
      );
    case 'act-05-09-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.disciplineStakesOutcomes,
        caption: '40 BI for 1/2 — 2/5 opens?',
      );
    case 'act-05-09-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.disciplineCashOutOutcomes,
        caption: 'Tired, up small, table wild?',
      );
    case 'act-05-09-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.disciplineEdgeOutcomes,
        caption: 'Session discipline is part of?',
      );
    case 'act-05-09-02-cp-multi':
      return const LessonTableScene(
        layout: LessonTableLayout.s5CpMultiOutcomes,
        caption: 'Four-way pot priority?',
      );
    case 'act-05-09-02-cp-tell':
      return const LessonTableScene(
        layout: LessonTableLayout.s5CpTellOutcomes,
        caption: 'Instant shove proves?',
      );
    case 'act-05-09-02-cp-stop':
      return const LessonTableScene(
        layout: LessonTableLayout.s5CpStopOutcomes,
        caption: 'Hit stop-loss — do?',
      );
    case 'act-06-01-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.rangeAdvPfrOutcomes,
        caption: 'A-high dry flop — range advantage?',
      );
    case 'act-06-01-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.rangeAdvNutsOutcomes,
        caption: 'Paired board — nut advantage?',
      );
    case 'act-06-01-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.rangeAdvPressOutcomes,
        caption: 'Advantage is a reason to?',
      );
    case 'act-06-02-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.eqRealizeIpOutcomes,
        caption: 'Same draw OOP vs IP — better where?',
      );
    case 'act-06-02-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.eqRealizeDiscountOutcomes,
        caption: 'Weak SDV OOP vs dual barrels?',
      );
    case 'act-06-02-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.eqRealizeAggressionOutcomes,
        caption: 'Semi-bluff XR purpose?',
      );
    case 'act-06-02-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.eqRealizePosOutcomes,
        caption: 'Equity realization rises with?',
      );
    case 'act-06-03-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.cappedGuidedOutcomes,
        caption: 'Checks turn after flop bet — often?',
      );
    case 'act-06-03-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.cappedUncappedLineOutcomes,
        caption: 'XR flop, bet turn, bomb river?',
      );
    case 'act-06-03-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.cappedAttackOutcomes,
        caption: 'Caps are for?',
      );
    case 'act-06-04-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.polarGuidedOutcomes,
        caption: 'River overbet usually wants?',
      );
    case 'act-06-04-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.polarMismatchOutcomes,
        caption: 'Mismatch to avoid?',
      );
    case 'act-06-04-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.polarAimOutcomes,
        caption: 'Merged betting aims to?',
      );
    case 'act-06-05-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.overbetGuidedOutcomes,
        caption: 'Best overbet river candidate?',
      );
    case 'act-06-05-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.overbetAvoidOutcomes,
        caption: 'Random 3x pot medium?',
      );
    case 'act-06-05-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.overbetPlanOutcomes,
        caption: 'Geometric sizing primarily helps?',
      );
    case 'act-06-06-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.blockersGuidedOutcomes,
        caption: 'River bluff on flush board — better blocker?',
        boardCodes: ['Kh', '9h', '4h', '2c', '7h'],
      );
    case 'act-06-06-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.blockersUnblockOutcomes,
        caption: 'Bluff-catching a river bomb — prefer?',
      );
    case 'act-06-06-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.blockersTweakOutcomes,
        caption: 'Blockers replace?',
      );
    case 'act-06-06-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.blockersEvOutcomes,
        caption: 'Course stance on solver EV quotes?',
      );
    case 'act-06-07-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.defendGuidedOutcomes,
        caption: 'Facing a river bet. Best continue?',
      );
    case 'act-06-07-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.defendIntuitionOutcomes,
        caption: 'MDF numbers in this course?',
      );
    case 'act-06-07-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.defendPunishOutcomes,
        caption: 'Minimum defense goal?',
      );
    case 'act-06-08-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.mixStationOutcomes,
        caption: 'Versus a Calling Station, how much bluff-mixing?',
      );
    case 'act-06-08-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.mixReasonOutcomes,
        caption: 'Randomness for its own sake?',
      );
    case 'act-06-08-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.mixPurposeOutcomes,
        caption: 'Best mix description?',
      );
    case 'act-06-09-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.threeBetCommitOutcomes,
        caption: '100bb 4-bet pot. Flop top pair. Default mindset?',
      );
    case 'act-06-09-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.threeBetEgoOutcomes,
        caption: 'Light 4-bet bluff with no blockers for ego?',
      );
    case 'act-06-09-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.threeBetSprOutcomes,
        caption: 'Depth change in 3-bet pots mainly changes?',
      );
    case 'act-06-10-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.hardFoldCoolerOutcomes,
        caption: 'KK loses to AA all-in pre. Review label?',
      );
    case 'act-06-10-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.hardFoldEgoOutcomes,
        caption: 'Calling because you are "due"?',
      );
    case 'act-06-10-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.hardFoldReviewOutcomes,
        caption: 'Review question after a big loss?',
      );
    case 'act-06-11-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.selectiveGuidedOutcomes,
        caption:
            'Seat folds most hands, then 3-bets and c-bets strong boards. Note?',
      );
    case 'act-06-11-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.selectiveDiscOutcomes,
        caption: 'Same seat gives up on turns when called. Observation?',
      );
    case 'act-06-11-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.selectiveSampleOutcomes,
        caption: 'Two hands of tightness. Confidence?',
      );
    case 'act-06-11-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.selectiveBundleOutcomes,
        caption: 'Best pre-label note bundle?',
      );
    case 'act-06-11-02-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.meetTagVsStationOutcomes,
        caption: 'Folds most · 3-bets strong · barrels with a plan',
      );
    case 'act-06-11-02-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.meetTagDiffOutcomes,
        caption: 'TAG versus Maniac difference?',
      );
    case 'act-06-11-02-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.meetTagVsManiacOutcomes,
        caption: 'Opens tight · folds to 3-bets · selective c-bets',
      );
    case 'act-06-11-02-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.meetTagModelOutcomes,
        caption: 'How to treat the TAG label',
      );
    case 'act-06-11-03-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.tagRespectCiteOutcomes,
        caption: 'Versus TAG, cite which tendency?',
      );
    case 'act-06-12-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.lagObserveGuidedOutcomes,
        caption:
            'Seat opens many hands and barrels often but folds some turn raises. Note?',
      );
    case 'act-06-12-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.lagObserveDiscOutcomes,
        caption: 'Difference brewing vs maniac?',
      );
    case 'act-06-12-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.lagObserveSampleOutcomes,
        caption: 'Label after one wide open?',
      );
    case 'act-06-12-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.lagObserveBundleOutcomes,
        caption: 'Best pre-label note bundle?',
      );
    case 'act-06-12-02-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.meetLagVsTagOutcomes,
        caption: 'Opens wide · barrels often · folds some raises',
      );
    case 'act-06-12-02-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.meetLagDiffOutcomes,
        caption: 'LAG versus Calling Station?',
      );
    case 'act-06-12-02-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.meetLagVsNitOutcomes,
        caption: 'Wide opens · 3-bets light · keeps barreling',
      );
    case 'act-06-12-02-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.meetLagLimitsOutcomes,
        caption: 'Show beside the LAG label',
      );
    case 'act-06-12-03-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.lagAdjustAvoidOutcomes,
        caption: 'Inventing triple-barrel bluffs into a LAG?',
      );
    case 'act-06-12-03-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.lagAdjustCiteOutcomes,
        caption: 'LAG exploit cites?',
      );
    case 'act-06-13-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.mixFiveTagRespectOutcomes,
        caption: 'Selective entry + disciplined barrels. Label + line?',
      );
    case 'act-06-13-02-cp-adv':
      return const LessonTableScene(
        layout: LessonTableLayout.s6CpAdvOutcomes,
        caption: 'PFR on dry A-high often has?',
      );
    case 'act-06-13-02-cp-cap':
      return const LessonTableScene(
        layout: LessonTableLayout.s6CpCapOutcomes,
        caption: 'Check-back turn often makes river range?',
      );
    case 'act-06-13-02-cp-polar':
      return const LessonTableScene(
        layout: LessonTableLayout.s6CpPolarOutcomes,
        caption: 'River overbet shape?',
      );
    case 'act-06-13-02-cp-tag':
      return const LessonTableScene(
        layout: LessonTableLayout.s6CpTagOutcomes,
        caption: 'Tight entry, planned barrels. Label?',
      );
    case 'act-06-13-02-cp-lag':
      return const LessonTableScene(
        layout: LessonTableLayout.s6CpLagOutcomes,
        caption: 'Wide entry, sustained pressure. Label?',
      );
    case 'act-07-01-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.preflopFlopGuidedOutcomes,
        caption: 'AQo 3-bet · flop 872tt — update?',
      );
    case 'act-07-01-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.preflopFlopScaffoldedOutcomes,
        caption: 'BTN steal KTo · flop KT2r — update?',
      );
    case 'act-07-01-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.preflopFlopUnguidedOutcomes,
        caption: 'Best habit before acting the flop?',
      );
    case 'act-07-01-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.preflopFlopCheckpointOutcomes,
        caption: 'Dead plan response?',
      );
    case 'act-07-02-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.turnMapGuidedOutcomes,
        caption: 'AK c-bet · Q72r — good turn continue?',
      );
    case 'act-07-02-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.turnMapScaffoldedOutcomes,
        caption: 'Gutshot · brick raise — map says?',
      );
    case 'act-07-02-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.turnMapUnguidedOutcomes,
        caption: 'Bet flop with no turn idea?',
      );
    case 'act-07-02-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.turnMapCheckpointOutcomes,
        caption: 'Turn map is?',
      );
    case 'act-07-03-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.riverCompScaffoldedOutcomes,
        caption: 'Nut flush blocker — why bluff?',
      );
    case 'act-07-03-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.riverCompUnguidedOutcomes,
        caption: 'No value, no blockers, no fold equity?',
      );
    case 'act-07-03-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.riverCompCheckpointOutcomes,
        caption: 'River composition rule?',
      );
    case 'act-07-04-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.potTypeGuidedOutcomes,
        caption: 'Multiway limped pot — priority?',
      );
    case 'act-07-04-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.potTypeScaffoldedOutcomes,
        caption: 'HU SRP IP — default weapon?',
      );
    case 'act-07-04-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.potTypeUnguidedOutcomes,
        caption: '4-bet pot 100bb — mindset?',
      );
    case 'act-07-04-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.potTypeCheckpointOutcomes,
        caption: 'Pot type changes?',
      );
    case 'act-07-05-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.huMwGuidedOutcomes,
        caption: 'Four-way river — naked air bluff?',
      );
    case 'act-07-05-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.huMwScaffoldedOutcomes,
        caption: 'HU vs nit BB — steal frequency?',
      );
    case 'act-07-05-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.huMwUnguidedOutcomes,
        caption: 'Multiway top set — line lean?',
      );
    case 'act-07-05-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.huMwCheckpointOutcomes,
        caption: 'Player count is?',
      );
    case 'act-07-06-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.stackDepthGuidedOutcomes,
        caption: '35bb TPTK vs raise — lean?',
      );
    case 'act-07-06-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.stackDepthScaffoldedOutcomes,
        caption: '250bb — set-mine 55?',
      );
    case 'act-07-06-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.stackDepthUnguidedOutcomes,
        caption: 'Hero 200bb, villain 40bb — effective?',
      );
    case 'act-07-06-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.stackDepthCheckpointOutcomes,
        caption: 'Stack depth is?',
      );
    case 'act-07-07-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.sameCardsCheckpointOutcomes,
        caption: 'No type evidence yet. Default?',
      );
    case 'act-07-08-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.typeBoardCheckpointOutcomes,
        caption: 'Integrated decision uses?',
      );
    case 'act-07-09-01-guided':
      return const LessonTableScene(
        layout: LessonTableLayout.leakReviewGuidedOutcomes,
        caption: 'Best leak note?',
      );
    case 'act-07-09-01-scaffolded':
      return const LessonTableScene(
        layout: LessonTableLayout.leakReviewScaffoldedOutcomes,
        caption: 'Default BTN vs unknown BB open?',
      );
    case 'act-07-09-01-unguided':
      return const LessonTableScene(
        layout: LessonTableLayout.leakReviewUnguidedOutcomes,
        caption: 'When to review the book?',
      );
    case 'act-07-09-01-checkpoint':
      return const LessonTableScene(
        layout: LessonTableLayout.leakReviewCheckpointOutcomes,
        caption: 'Default book purpose?',
      );
    case 'act-01-04-01-unguided-end':
      return const LessonTableScene(
        layout: LessonTableLayout.streetEndPhases,
      );
    case 'act-01-04-01-checkpoint-postflop':
      return const LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'Postflop · tap who acts first',
      );
    case 'act-01-05-01-guided-fold-win':
      return const LessonTableScene(
        layout: LessonTableLayout.potFoldWinOutcomes,
        heroCodes: ['Ah', 'Kd'],
        showMuck: true,
        villainSeatCount: 0,
        caption: 'You bet · all fold',
      );
    case 'act-01-05-01-scaffolded-showdown':
      return const LessonTableScene(
        layout: LessonTableLayout.potShowdownOutcomes,
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', '7c', '2d', '9h', '3s'],
        villainSeatCount: 1,
        caption: 'River · called',
      );
    case 'act-01-05-01-checkpoint-side':
      return const LessonTableScene(
        layout: LessonTableLayout.potSideOutcomes,
        caption: 'You all-in short · others keep betting',
      );
    case 'act-01-05-01-unguided-pot':
      return const LessonTableScene(
        layout: LessonTableLayout.potOpenSizeOutcomes,
        caption: '1/2 · BTN opens 6 · blinds still to act',
      );
    case 'act-01-02-01-scaffolded-spot':
      return const LessonTableScene(
        heroCodes: ['Ac', '3d'],
        boardCodes: ['Kc', '9c', '4c', '7c', '2s'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'You',
      );
    case 'act-01-02-01-explain-ladder':
      return null;
    case 'act-01-02-02-explain-five':
      return null;
    case 'act-01-02-02-scaffolded-kicker':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Qd'],
        boardCodes: ['Kh', 'Kd', '7c', '3s', '2d'],
        villainCodes: ['As', 'Jd'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.none,
        caption: 'You (AQ)',
      );
    case 'act-01-02-02-unguided-board':
      return const LessonTableScene(
        heroCodes: ['2h', '2d'],
        boardCodes: ['Ac', 'Kc', 'Qc', 'Jc', 'Tc'],
        // Face-down villain: learner must see the board, not invent kickers.
        villainSeatCount: 1,
        highlight: LessonTableHighlight.board,
        caption: 'You',
      );
    case 'act-02-07-01-checkpoint-habit':
      return const LessonTableScene(
        layout: LessonTableLayout.habitCoverOutcomes,
        heroCodes: ['Ah', 'Kd'],
        villainSeatCount: 1,
        caption: 'Full ring · action two seats left',
      );
  }

  // Hole-card choice quizzes already render MiniCards as answers. Never invent
  // a felt from prompt keywords ("suited hole cards") — that defaulted to Ah/Kd
  // and spoiled or confused the puzzle.
  final allHoleCardChoices =
      activity.choices.isNotEmpty &&
      activity.choices.every(
        (c) => _cardToken.allMatches(c.label).length >= 2,
      );
  if (allHoleCardChoices) return null;

  final hero = <String>[];
  final board = <String>[];
  for (final choice in activity.choices) {
    final codes = _cardToken
        .allMatches(choice.label)
        .map((m) => m.group(1)!)
        .toList(growable: false);
    if (codes.length >= 2 &&
        (choice.label.toLowerCase().contains('you') ||
            choice.label.toLowerCase().contains('front') ||
            choice.label.toLowerCase().contains('seat') ||
            choice.id.contains('hero') ||
            choice.id.contains('hole'))) {
      hero
        ..clear()
        ..addAll(codes.take(2));
    } else if (codes.length >= 3 &&
        (choice.label.toLowerCase().contains('middle') ||
            choice.label.toLowerCase().contains('flop') ||
            choice.label.toLowerCase().contains('board') ||
            choice.id.contains('flop') ||
            choice.id.contains('board'))) {
      board
        ..clear()
        ..addAll(codes.take(5));
    }
  }

  final prompt = (activity.prompt ?? activity.accessibilityText).toLowerCase();
  final wantsTable =
      prompt.contains('hole') ||
      prompt.contains('table') ||
      prompt.contains('community') ||
      prompt.contains('board') ||
      prompt.contains('seat') ||
      activity.objectives.any(
        (o) =>
            o.toLowerCase().contains('hole') ||
            o.toLowerCase().contains('community') ||
            o.toLowerCase().contains('table'),
      );

  if (!wantsTable && hero.isEmpty && board.isEmpty) return null;

  return LessonTableScene(
    heroCodes: hero.isEmpty ? const ['Ah', 'Kd'] : List.unmodifiable(hero),
    boardCodes: List.unmodifiable(board),
    villainSeatCount:
        prompt.contains('dealer') || prompt.contains('who can see')
            ? 2
            : (board.isEmpty ? 1 : 1),
    highlight:
        prompt.contains('community') || prompt.contains('board')
            ? LessonTableHighlight.board
            : LessonTableHighlight.hero,
    caption: 'You',
  );
}

/// Maps a table region tap onto an authored choice id.
String? mapTableRegionToChoiceId({
  required String activityId,
  required LessonTableRegion region,
  required List<CourseChoice> choices,
  int? seatIndex,
}) {
  final ids = {for (final c in choices) c.id};
  String? pick(String id) => ids.contains(id) ? id : null;

  switch (activityId) {
    case 'act-01-01-01-guided-find-holes':
      return switch (region) {
        LessonTableRegion.hero => pick('choice-hero-holes'),
        LessonTableRegion.board => pick('choice-board'),
        LessonTableRegion.villain => pick('choice-villain'),
        _ => null,
      };
    case 'act-01-01-01-scaffolded-private':
      // Tap what only you can see / who sees your holes.
      return switch (region) {
        LessonTableRegion.hero => pick('choice-only-you'),
        LessonTableRegion.villain || LessonTableRegion.board =>
          pick('choice-whole-table'),
        LessonTableRegion.dealer => pick('choice-dealer-only'),
        _ => null,
      };
    case 'act-01-01-01-unguided-mix':
      return switch (region) {
        LessonTableRegion.board => pick('choice-flop'),
        LessonTableRegion.hero => pick('choice-hero-again'),
        LessonTableRegion.muck || LessonTableRegion.villain =>
          pick('choice-muck'),
        _ => null,
      };
    case 'act-01-01-01-checkpoint-table':
      return switch (region) {
        LessonTableRegion.hero => pick('choice-checkpoint-holes'),
        LessonTableRegion.board => pick('choice-checkpoint-board'),
        // Tapping other face-up-looking areas / villains ≈ "everything I see".
        LessonTableRegion.villain => pick('choice-checkpoint-all'),
        _ => null,
      };
    case 'act-01-01-03-guided-button':
      return switch (region) {
        LessonTableRegion.button => pick('btn-seat'),
        LessonTableRegion.bigBlind => pick('bb-seat'),
        LessonTableRegion.emptySeat => pick('empty-seat'),
        _ => null,
      };
    case 'act-01-01-03-scaffolded-blinds':
      return switch (region) {
        LessonTableRegion.bigBlind => pick('bb-two'),
        LessonTableRegion.smallBlind => pick('sb-one'),
        LessonTableRegion.button => pick('btn-posts'),
        _ => null,
      };
    case 'act-01-01-03-unguided-when':
      return switch (region) {
        LessonTableRegion.beforeDeal => pick('before-deal'),
        LessonTableRegion.afterFlop => pick('after-flop'),
        LessonTableRegion.showdown => pick('only-showdown'),
        _ => null,
      };
    case 'act-01-01-03-checkpoint-layout':
      // Button is seat 5: SB = 0, BB = 1, right-of-button = 4.
      if (seatIndex == null) return null;
      return switch (seatIndex) {
        0 => pick('sb-seat0'),
        4 => pick('sb-seat4'),
        1 => pick('sb-seat1'),
        _ => null,
      };
    case 'act-01-02-02-unguided-board':
      // Broadway board plays for everyone — tap the shared cards to chop.
      return switch (region) {
        LessonTableRegion.board => pick('chop-broadway'),
        LessonTableRegion.hero => pick('high-card-wins'),
        LessonTableRegion.villain => pick('button-wins'),
        _ => null,
      };
    case 'act-01-04-01-unguided-end':
      return switch (region) {
        LessonTableRegion.streetActionMatched => pick('matched'),
        LessonTableRegion.streetFlopDealt => pick('three-cards'),
        LessonTableRegion.streetSomeoneFolds => pick('someone-folds'),
        _ => null,
      };
    case 'act-01-04-01-checkpoint-postflop':
      return switch (region) {
        LessonTableRegion.smallBlind => pick('sb-first'),
        LessonTableRegion.button => pick('btn-first'),
        LessonTableRegion.bigBlind => pick('bb-first-always'),
        _ => null,
      };
    case 'act-01-05-01-guided-fold-win':
      return switch (region) {
        LessonTableRegion.potTakeQuiet => pick('no-show'),
        LessonTableRegion.potMustShow => pick('must-show'),
        LessonTableRegion.potDealerShows => pick('dealer-shows'),
        _ => null,
      };
    case 'act-01-05-01-scaffolded-showdown':
      return switch (region) {
        LessonTableRegion.potShowdown => pick('showdown'),
        LessonTableRegion.potLastBettor => pick('last-bet-wins'),
        LessonTableRegion.potChopDefault => pick('chop-default'),
        _ => null,
      };
    case 'act-01-05-01-checkpoint-side':
      return switch (region) {
        LessonTableRegion.potSideForms => pick('side-exists'),
        LessonTableRegion.potWinAll => pick('you-win-all'),
        LessonTableRegion.potHandDead => pick('hand-void'),
        _ => null,
      };
    case 'act-01-05-01-unguided-pot':
      return switch (region) {
        LessonTableRegion.potChipsNine => pick('pot-9'),
        LessonTableRegion.potChipsSeven => pick('pot-7'),
        LessonTableRegion.potChipsTwelve => pick('pot-12'),
        _ => null,
      };
    case 'act-02-01-01-guided-btn':
      return switch (region) {
        LessonTableRegion.button => pick('pos-btn'),
        LessonTableRegion.bigBlind => pick('pos-bb'),
        LessonTableRegion.earlyPosition => pick('pos-ep'),
        _ => null,
      };
    case 'act-02-01-01-scaffolded-blinds':
      return switch (region) {
        LessonTableRegion.smallBlind || LessonTableRegion.bigBlind =>
          pick('sb-bb'),
        LessonTableRegion.button => pick('btn-bb'),
        LessonTableRegion.earlyPosition ||
        LessonTableRegion.hijack ||
        LessonTableRegion.cutoff =>
          pick('ep-only'),
        _ => null,
      };
    case 'act-02-01-01-unguided-co':
      return switch (region) {
        LessonTableRegion.cutoff => pick('label-co'),
        LessonTableRegion.hijack => pick('label-hj'),
        LessonTableRegion.earlyPosition => pick('label-ep'),
        _ => null,
      };
    case 'act-02-01-01-checkpoint-edge':
      return switch (region) {
        LessonTableRegion.button => pick('prefer-btn'),
        LessonTableRegion.earlyPosition => pick('prefer-ep'),
        LessonTableRegion.seatNeverMatters => pick('same-always'),
        _ => null,
      };
    case 'act-02-07-01-checkpoint-habit':
      return switch (region) {
        LessonTableRegion.habitCoverWait => pick('cover-wait'),
        LessonTableRegion.habitActEarly => pick('act-now'),
        LessonTableRegion.habitLeaveBare => pick('leave-cards'),
        _ => null,
      };
    case 'act-02-07-02-jump-pos':
      return switch (region) {
        LessonTableRegion.cutoff => pick('j2-co'),
        LessonTableRegion.hijack => pick('j2-hj'),
        LessonTableRegion.smallBlind => pick('j2-sb'),
        _ => null,
      };
    case 'act-02-07-02-jump-stack':
      return switch (region) {
        LessonTableRegion.effectiveStackShort => pick('j2-55'),
        LessonTableRegion.effectiveStackHero => pick('j2-120'),
        LessonTableRegion.effectiveStackSum => pick('j2-175'),
        _ => null,
      };
    case 'act-03-01-01-guided':
      return switch (region) {
        LessonTableRegion.potChipsTwentyOne => pick('pot-21'),
        LessonTableRegion.potChipsEighteen => pick('pot-18'),
        LessonTableRegion.potChipsTwelve => pick('pot-12'),
        _ => null,
      };
    case 'act-03-03-01-scaffolded':
      return switch (region) {
        LessonTableRegion.callChipsTen => pick('call-10'),
        LessonTableRegion.callChipsTwenty => pick('call-20'),
        LessonTableRegion.callChipsThirty => pick('call-30'),
        _ => null,
      };
    case 'act-03-03-01-unguided':
      return switch (region) {
        LessonTableRegion.drawPriceCall => pick('call-draw'),
        LessonTableRegion.drawPriceFold => pick('fold-draw'),
        LessonTableRegion.drawPriceRaise => pick('raise-auto'),
        _ => null,
      };
    case 'act-03-01-01-scaffolded':
      // Preflop open: UTG is left of the BB (earlyPosition on the felt).
      return switch (region) {
        LessonTableRegion.earlyPosition => pick('utg-first'),
        LessonTableRegion.button => pick('btn-first'),
        LessonTableRegion.smallBlind => pick('sb-first'),
        _ => null,
      };
    case 'act-03-01-01-unguided':
      return switch (region) {
        LessonTableRegion.verbalRaiseStands => pick('bound'),
        LessonTableRegion.verbalTakeback => pick('takeback'),
        LessonTableRegion.verbalDealerChoice => pick('dealer-choice'),
        _ => null,
      };
    case 'act-03-01-01-checkpoint':
      return switch (region) {
        LessonTableRegion.tableMatterEffAndPot => pick('eff-55'),
        LessonTableRegion.tableMatterHeroOnly => pick('hero-140'),
        LessonTableRegion.tableMatterIgnorePot => pick('ignore-pot'),
        _ => null,
      };
    case 'act-04-06-01-guided':
      return switch (region) {
        LessonTableRegion.observeHighParticipation => pick('high-part'),
        LessonTableRegion.observeLowParticipation => pick('low-part'),
        LessonTableRegion.observeLabelNow => pick('label-now'),
        _ => null,
      };
    case 'act-04-06-02-guided':
      return switch (region) {
        LessonTableRegion.playerTypeStation => pick('pt-station'),
        LessonTableRegion.playerTypeNit => pick('pt-nit'),
        _ => null,
      };
    case 'act-04-06-02-scaffolded':
      return switch (region) {
        LessonTableRegion.labelWorkingModel => pick('model'),
        LessonTableRegion.labelPermanentSoul => pick('soul'),
        _ => null,
      };
    case 'act-04-06-02-unguided':
      return switch (region) {
        LessonTableRegion.playerTypeStationLimp => pick('station2'),
        LessonTableRegion.playerTypeManiac => pick('maniac2'),
        _ => null,
      };
    case 'act-04-06-02-checkpoint':
      return switch (region) {
        LessonTableRegion.sampleConfidenceLow => pick('low'),
        LessonTableRegion.sampleConfidenceMax => pick('max'),
        _ => null,
      };
    case 'act-04-06-03-checkpoint':
      return switch (region) {
        LessonTableRegion.citeRarelyFolds => pick('cite-fold'),
        LessonTableRegion.citeLabelMean => pick('cite-mean'),
        _ => null,
      };
    case 'act-04-07-01-guided':
      return switch (region) {
        LessonTableRegion.observeNarrowEntry => pick('narrow'),
        LessonTableRegion.observeWideEntry => pick('wide'),
        _ => null,
      };
    case 'act-04-07-01-scaffolded':
      return switch (region) {
        LessonTableRegion.observeStrongAggression => pick('strong-aggr'),
        LessonTableRegion.observePassiveCallers => pick('passive'),
        _ => null,
      };
    case 'act-04-07-01-unguided':
      return switch (region) {
        LessonTableRegion.observeWaitSamples => pick('wait'),
        LessonTableRegion.observeLabelNowThin => pick('now'),
        _ => null,
      };
    case 'act-04-07-01-checkpoint':
      return switch (region) {
        LessonTableRegion.observeNitBundle => pick('bundle-nit'),
        LessonTableRegion.observeStationBundle => pick('bundle-station'),
        _ => null,
      };
    case 'act-04-07-02-guided':
      return switch (region) {
        LessonTableRegion.meetNitLabel => pick('pt-nit'),
        LessonTableRegion.meetNitStationDistractor => pick('pt-station-n'),
        _ => null,
      };
    case 'act-04-07-02-unguided':
      return switch (region) {
        LessonTableRegion.meetNitLabel2 => pick('nit2'),
        LessonTableRegion.meetNitManiacDistractor => pick('maniac-n'),
        _ => null,
      };
    case 'act-04-07-02-checkpoint':
      return switch (region) {
        LessonTableRegion.meetNitWorkingModel => pick('model-n'),
        LessonTableRegion.meetNitInsult => pick('insult-n'),
        _ => null,
      };
    case 'act-04-07-03-checkpoint':
      return switch (region) {
        LessonTableRegion.citeNitStrongRange => pick('cite-strong'),
        LessonTableRegion.citeNitFear => pick('cite-fear'),
        _ => null,
      };
    case 'act-04-08-01-guided':
      return switch (region) {
        LessonTableRegion.observeExtremeEntry => pick('extreme'),
        LessonTableRegion.observeNarrowTimid => pick('nit-like'),
        _ => null,
      };
    case 'act-04-08-01-scaffolded':
      return switch (region) {
        LessonTableRegion.observeWidePressure => pick('pressure'),
        LessonTableRegion.observeNeverBets => pick('passive-m'),
        _ => null,
      };
    case 'act-04-08-01-unguided':
      return switch (region) {
        LessonTableRegion.observeCalmNotes => pick('calm'),
        LessonTableRegion.observeEgoNotes => pick('ego'),
        _ => null,
      };
    case 'act-04-08-01-checkpoint':
      return switch (region) {
        LessonTableRegion.observeManiacBundle => pick('bundle-m'),
        LessonTableRegion.observeWildNitBundle => pick('bundle-n'),
        _ => null,
      };
    case 'act-04-08-02-guided':
      return switch (region) {
        LessonTableRegion.meetManiacLabel => pick('pt-maniac'),
        LessonTableRegion.meetManiacNitDistractor => pick('pt-nit-m'),
        _ => null,
      };
    case 'act-04-08-02-unguided':
      return switch (region) {
        LessonTableRegion.meetManiacLabel2 => pick('maniac2'),
        LessonTableRegion.meetManiacStationDistractor => pick('station-m'),
        _ => null,
      };
    case 'act-04-08-02-checkpoint':
      return switch (region) {
        LessonTableRegion.meetManiacMixThree => pick('three'),
        LessonTableRegion.meetManiacMixEarly => pick('early'),
        _ => null,
      };
    case 'act-04-08-03-checkpoint':
      return switch (region) {
        LessonTableRegion.citeManiacWideBet => pick('cite-wide'),
        LessonTableRegion.citeManiacBrave => pick('cite-brave'),
        _ => null,
      };
    case 'act-04-09-01-guided':
      return switch (region) {
        LessonTableRegion.confidenceOneNote => pick('one-note'),
        LessonTableRegion.confidenceProvenForever => pick('proven'),
        _ => null,
      };
    case 'act-04-09-01-scaffolded':
      return switch (region) {
        LessonTableRegion.confidenceRiseRevisable => pick('rise'),
        LessonTableRegion.confidenceStayZero => pick('zero'),
        _ => null,
      };
    case 'act-04-09-01-unguided':
      return switch (region) {
        LessonTableRegion.confidenceUpdateModel => pick('update'),
        LessonTableRegion.confidenceFreezeModel => pick('freeze'),
        _ => null,
      };
    case 'act-04-09-01-checkpoint':
      return switch (region) {
        LessonTableRegion.confidenceShowLimits => pick('limits'),
        LessonTableRegion.confidenceDestinyAura => pick('destiny'),
        _ => null,
      };
    case 'act-04-10-02-jump-range':
      return switch (region) {
        LessonTableRegion.jumpUtgNarrower => pick('j4-range'),
        LessonTableRegion.jumpUtgAnyTwo => pick('j4-any'),
        _ => null,
      };
    case 'act-04-10-02-jump-station':
      return switch (region) {
        LessonTableRegion.jumpStationValue => pick('j4-cs'),
        LessonTableRegion.jumpStationBluff => pick('j4-cs-wrong'),
        _ => null,
      };
    case 'act-04-10-02-jump-nit':
      return switch (region) {
        LessonTableRegion.jumpNitRespect => pick('j4-nit'),
        LessonTableRegion.jumpNitBluffCatch => pick('j4-nit-bluff'),
        _ => null,
      };
    case 'act-04-10-02-jump-maniac':
      return switch (region) {
        LessonTableRegion.jumpManiacCall => pick('j4-man'),
        LessonTableRegion.jumpManiacFoldAll => pick('j4-man-fold'),
        _ => null,
      };
    case 'act-05-01-01-guided':
      return switch (region) {
        LessonTableRegion.multiwayNutFd => pick('nfd'),
        LessonTableRegion.multiwayWeakFd => pick('weak-fd'),
        LessonTableRegion.multiwayAirStab => pick('air'),
        _ => null,
      };
    case 'act-05-01-01-checkpoint':
      return switch (region) {
        LessonTableRegion.multiwayNutsPriority => pick('nuts'),
        LessonTableRegion.multiwayAnyTwo => pick('any-two'),
        _ => null,
      };
    case 'act-05-02-01-guided':
      return switch (region) {
        LessonTableRegion.deepImpliedOdds => pick('impl'),
        LessonTableRegion.deepSprLow => pick('spr-low'),
        LessonTableRegion.deepBluffEvery => pick('bluff'),
        _ => null,
      };
    case 'act-05-02-01-unguided':
      return switch (region) {
        LessonTableRegion.deepMapPlans => pick('plan'),
        LessonTableRegion.deepJamNow => pick('jamnow'),
        _ => null,
      };
    case 'act-05-02-01-checkpoint':
      return switch (region) {
        LessonTableRegion.deepRewardsPos => pick('pos'),
        LessonTableRegion.deepRewardsSpew => pick('spew'),
        _ => null,
      };
    case 'act-05-03-01-checkpoint':
      return switch (region) {
        LessonTableRegion.ioDepthPay => pick('depth-pay'),
        LessonTableRegion.ioShortAlways => pick('short'),
        _ => null,
      };
    case 'act-05-04-01-checkpoint':
      return switch (region) {
        LessonTableRegion.thinValueReadLine => pick('read'),
        LessonTableRegion.thinValueFlipCoin => pick('random'),
        _ => null,
      };
    case 'act-05-05-01-guided':
      return switch (region) {
        LessonTableRegion.linesNitValueHeavy => pick('strong'),
        LessonTableRegion.linesNitAlwaysBluff => pick('air'),
        _ => null,
      };
    case 'act-05-05-01-unguided':
      return switch (region) {
        LessonTableRegion.linesDonkPolar => pick('polar'),
        LessonTableRegion.linesDonkMerged => pick('merged'),
        _ => null,
      };
    case 'act-05-05-01-checkpoint':
      return switch (region) {
        LessonTableRegion.linesDelayAfterWeak => pick('delay'),
        LessonTableRegion.linesDelayAlways => pick('always'),
        _ => null,
      };
    case 'act-05-06-01-guided':
      return switch (region) {
        LessonTableRegion.lineReadCapped => pick('capped'),
        LessonTableRegion.lineReadStillNuts => pick('nutted'),
        _ => null,
      };
    case 'act-05-06-01-unguided':
      return switch (region) {
        LessonTableRegion.lineReadRebuild => pick('update'),
        LessonTableRegion.lineReadLockFlop => pick('freeze'),
        _ => null,
      };
    case 'act-05-06-01-checkpoint':
      return switch (region) {
        LessonTableRegion.lineReadUncapped => pick('uncap'),
        LessonTableRegion.lineReadAlwaysBluff => pick('bluff'),
        _ => null,
      };
    case 'act-05-07-01-guided':
      return switch (region) {
        LessonTableRegion.timingSoftEvidence => pick('soft'),
        LessonTableRegion.timingProvenNuts => pick('nuts'),
        LessonTableRegion.timingProvenBluff => pick('air'),
        _ => null,
      };
    case 'act-05-07-01-scaffolded':
      return switch (region) {
        LessonTableRegion.timingWeakerBlocking => pick('weakish'),
        LessonTableRegion.timingSolverKnown => pick('solver'),
        _ => null,
      };
    case 'act-05-07-01-unguided':
      return switch (region) {
        LessonTableRegion.timingRejectMagic => pick('reject'),
        LessonTableRegion.timingTrustBook => pick('trust'),
        _ => null,
      };
    case 'act-05-07-01-checkpoint':
      return switch (region) {
        LessonTableRegion.timingTinyUpdate => pick('tiny'),
        LessonTableRegion.timingOnlyEvidence => pick('only'),
        _ => null,
      };
    case 'act-05-08-01-guided':
      return switch (region) {
        LessonTableRegion.dynamicsStuckTilted => pick('stuck'),
        LessonTableRegion.dynamicsIgnore => pick('ignore'),
        _ => null,
      };
    case 'act-05-08-01-scaffolded':
      return switch (region) {
        LessonTableRegion.dynamicsGearChange => pick('gear'),
        LessonTableRegion.dynamicsOldLabel => pick('same'),
        _ => null,
      };
    case 'act-05-08-01-checkpoint':
      return switch (region) {
        LessonTableRegion.dynamicsFreshSamples => pick('temp'),
        LessonTableRegion.dynamicsPermanentSeats => pick('perm'),
        _ => null,
      };
    case 'act-05-09-01-guided':
      return switch (region) {
        LessonTableRegion.disciplineStop => pick('stop'),
        LessonTableRegion.disciplineReload => pick('reload'),
        _ => null,
      };
    case 'act-05-09-01-scaffolded':
      return switch (region) {
        LessonTableRegion.disciplineDecline => pick('decline'),
        LessonTableRegion.disciplineJump => pick('jump'),
        _ => null,
      };
    case 'act-05-09-01-unguided':
      return switch (region) {
        LessonTableRegion.disciplineCashOut => pick('cash'),
        LessonTableRegion.disciplineStay => pick('punish'),
        _ => null,
      };
    case 'act-05-09-01-checkpoint':
      return switch (region) {
        LessonTableRegion.disciplineEdge => pick('edge'),
        LessonTableRegion.disciplineSoftOnly => pick('soft'),
        _ => null,
      };
    case 'act-05-09-02-cp-multi':
      return switch (region) {
        LessonTableRegion.multiwayNutsPriority => pick('nut'),
        LessonTableRegion.s5CpBluffMore => pick('bluff'),
        _ => null,
      };
    case 'act-05-09-02-cp-tell':
      return switch (region) {
        LessonTableRegion.timingSoftEvidence => pick('soft'),
        LessonTableRegion.s5CpAbsoluteNuts => pick('nuts'),
        _ => null,
      };
    case 'act-05-09-02-cp-stop':
      return switch (region) {
        LessonTableRegion.disciplineStop => pick('stop'),
        LessonTableRegion.s5CpChase => pick('chase'),
        _ => null,
      };
    case 'act-06-01-01-guided':
      return switch (region) {
        LessonTableRegion.rangeAdvPfr => pick('pfr'),
        LessonTableRegion.rangeAdvCaller => pick('caller'),
        _ => null,
      };
    case 'act-06-01-01-scaffolded':
      return switch (region) {
        LessonTableRegion.rangeAdvWideCaller => pick('caller-nuts'),
        LessonTableRegion.rangeAdvPfrAlways => pick('pfr-always'),
        _ => null,
      };
    case 'act-06-01-01-checkpoint':
      return switch (region) {
        LessonTableRegion.rangeAdvPress => pick('press'),
        LessonTableRegion.rangeAdvBetAnyTwo => pick('random'),
        _ => null,
      };
    case 'act-06-02-01-guided':
      return switch (region) {
        LessonTableRegion.eqRealizeIp => pick('ip'),
        LessonTableRegion.eqRealizeOop => pick('oop'),
        _ => null,
      };
    case 'act-06-02-01-scaffolded':
      return switch (region) {
        LessonTableRegion.eqRealizeDiscount => pick('discount'),
        LessonTableRegion.eqRealizeHero => pick('hero'),
        _ => null,
      };
    case 'act-06-02-01-unguided':
      return switch (region) {
        LessonTableRegion.eqRealizeFoldEq => pick('realize'),
        LessonTableRegion.eqRealizeFancy => pick('fancy'),
        _ => null,
      };
    case 'act-06-02-01-checkpoint':
      return switch (region) {
        LessonTableRegion.eqRealizePosInit => pick('pos'),
        LessonTableRegion.eqRealizeHope => pick('hope'),
        _ => null,
      };
    case 'act-06-03-01-guided':
      return switch (region) {
        LessonTableRegion.cappedCheckTurn => pick('cap'),
        LessonTableRegion.cappedStillNuts => pick('uncap'),
        _ => null,
      };
    case 'act-06-03-01-unguided':
      return switch (region) {
        LessonTableRegion.uncappedXrLine => pick('uncap'),
        LessonTableRegion.cappedAirOnly => pick('cap2'),
        _ => null,
      };
    case 'act-06-03-01-checkpoint':
      return switch (region) {
        LessonTableRegion.capsAttack => pick('attack'),
        LessonTableRegion.capsAutoFold => pick('fear'),
        _ => null,
      };
    case 'act-06-04-01-guided':
      return switch (region) {
        LessonTableRegion.polarShape => pick('polar'),
        LessonTableRegion.mergedShape => pick('merged'),
        _ => null,
      };
    case 'act-06-04-01-unguided':
      return switch (region) {
        LessonTableRegion.polarTinyBluffs => pick('mismatch'),
        LessonTableRegion.polarAnySize => pick('ok'),
        _ => null,
      };
    case 'act-06-04-01-checkpoint':
      return switch (region) {
        LessonTableRegion.polarThinValue => pick('thin'),
        LessonTableRegion.polarOnlyNuts => pick('only-nuts'),
        _ => null,
      };
    case 'act-06-05-01-guided':
      return switch (region) {
        LessonTableRegion.overbetNutsBluffs => pick('polar-ob'),
        LessonTableRegion.overbetTopPairWeak => pick('tpwk'),
        _ => null,
      };
    case 'act-06-05-01-unguided':
      return switch (region) {
        LessonTableRegion.overbetAvoid => pick('avoid'),
        LessonTableRegion.overbetAlwaysFine => pick('yolo'),
        _ => null,
      };
    case 'act-06-05-01-checkpoint':
      return switch (region) {
        LessonTableRegion.overbetMultiStreet => pick('multi'),
        LessonTableRegion.overbetLookFlashy => pick('style'),
        _ => null,
      };
    case 'act-06-06-01-guided':
      return switch (region) {
        LessonTableRegion.blockersAce => pick('as'),
        LessonTableRegion.blockersNone => pick('off'),
        LessonTableRegion.blockersFakeEv => pick('ev'),
        _ => null,
      };
    case 'act-06-06-01-scaffolded':
      return switch (region) {
        LessonTableRegion.blockersUnblock => pick('unblock'),
        LessonTableRegion.blockersBlockAir => pick('block-nuts'),
        _ => null,
      };
    case 'act-06-06-01-unguided':
      return switch (region) {
        LessonTableRegion.blockersTweak => pick('tweak'),
        LessonTableRegion.blockersReplace => pick('replace'),
        _ => null,
      };
    case 'act-06-06-01-checkpoint':
      return switch (region) {
        LessonTableRegion.blockersNoFakeEv => pick('no'),
        LessonTableRegion.blockersInventEv => pick('fake'),
        _ => null,
      };
    case 'act-06-07-01-guided':
      return switch (region) {
        LessonTableRegion.defendStrongCatchers => pick('strong'),
        LessonTableRegion.defendAnyTwoPct => pick('any'),
        _ => null,
      };
    case 'act-06-07-01-unguided':
      return switch (region) {
        LessonTableRegion.defendIntuition => pick('int'),
        LessonTableRegion.defendExactPercents => pick('pct'),
        _ => null,
      };
    case 'act-06-07-01-checkpoint':
      return switch (region) {
        LessonTableRegion.defendPunishOverbluffs => pick('punish'),
        LessonTableRegion.defendNeverFold => pick('call-all'),
        _ => null,
      };
    case 'act-06-08-01-scaffolded':
      return switch (region) {
        LessonTableRegion.mixLessBluff => pick('less'),
        LessonTableRegion.mixSameAlways => pick('same'),
        _ => null,
      };
    case 'act-06-08-01-unguided':
      return switch (region) {
        LessonTableRegion.mixNeedReason => pick('no'),
        LessonTableRegion.mixAlwaysRandom => pick('yes'),
        _ => null,
      };
    case 'act-06-08-01-checkpoint':
      return switch (region) {
        LessonTableRegion.mixPurposeFreq => pick('freq'),
        LessonTableRegion.mixChaos => pick('chaos'),
        _ => null,
      };
    case 'act-06-09-01-guided':
      return switch (region) {
        LessonTableRegion.threeBetHighCommit => pick('careful'),
        LessonTableRegion.threeBetPlayDeep => pick('deep'),
        _ => null,
      };
    case 'act-06-09-01-unguided':
      return switch (region) {
        LessonTableRegion.threeBetAvoidEgo => pick('avoid'),
        LessonTableRegion.threeBetEgoFourBet => pick('ego'),
        _ => null,
      };
    case 'act-06-09-01-checkpoint':
      return switch (region) {
        LessonTableRegion.threeBetSprCommit => pick('spr'),
        LessonTableRegion.threeBetFeltSuits => pick('suits'),
        _ => null,
      };
    case 'act-06-10-01-scaffolded':
      return switch (region) {
        LessonTableRegion.hardFoldCoolerOk => pick('cooler'),
        LessonTableRegion.hardFoldFoldKk => pick('mistake'),
        _ => null,
      };
    case 'act-06-10-01-unguided':
      return switch (region) {
        LessonTableRegion.hardFoldEgoCall => pick('ego'),
        LessonTableRegion.hardFoldSoundPlay => pick('ok'),
        _ => null,
      };
    case 'act-06-10-01-checkpoint':
      return switch (region) {
        LessonTableRegion.hardFoldAskReview => pick('ask'),
        LessonTableRegion.hardFoldTiltHarder => pick('rtilt'),
        _ => null,
      };
    case 'act-06-11-01-guided':
      return switch (region) {
        LessonTableRegion.selectivePlanOk => pick('sel'),
        LessonTableRegion.selectiveLoosePassive => pick('loose'),
        LessonTableRegion.selectiveLabelNow => pick('label'),
        _ => null,
      };
    case 'act-06-11-01-scaffolded':
      return switch (region) {
        LessonTableRegion.selectiveDisciplined => pick('disc'),
        LessonTableRegion.selectiveSameManiac => pick('mania'),
        _ => null,
      };
    case 'act-06-11-01-unguided':
      return switch (region) {
        LessonTableRegion.selectiveKeepSampling => pick('low'),
        LessonTableRegion.selectiveMaxCertainty => pick('max'),
        _ => null,
      };
    case 'act-06-11-01-checkpoint':
      return switch (region) {
        LessonTableRegion.selectiveEvidenceBundle => pick('bundle'),
        LessonTableRegion.selectiveHaircut => pick('vibe'),
        _ => null,
      };
    case 'act-06-11-02-guided':
      return switch (region) {
        LessonTableRegion.meetTagLabel => pick('tag'),
        LessonTableRegion.meetTagStationDistractor => pick('station'),
        _ => null,
      };
    case 'act-06-11-02-scaffolded':
      return switch (region) {
        LessonTableRegion.meetTagSelectiveDiff => pick('diff'),
        LessonTableRegion.meetTagIdentical => pick('same'),
        _ => null,
      };
    case 'act-06-11-02-unguided':
      return switch (region) {
        LessonTableRegion.meetTagLabel2 => pick('tag2'),
        LessonTableRegion.meetTagManiacDistractor => pick('mania2'),
        _ => null,
      };
    case 'act-06-11-02-checkpoint':
      return switch (region) {
        LessonTableRegion.meetTagWorkingModel => pick('model'),
        LessonTableRegion.meetTagInsult => pick('soul'),
        _ => null,
      };
    case 'act-06-11-03-checkpoint':
      return switch (region) {
        LessonTableRegion.citeTagSelective => pick('cite'),
        LessonTableRegion.citeTagVibes => pick('vague'),
        _ => null,
      };
    case 'act-06-12-01-guided':
      return switch (region) {
        LessonTableRegion.lagObserveWidePressure => pick('wide'),
        LessonTableRegion.lagObserveNitDistractor => pick('nit'),
        LessonTableRegion.lagObserveLabelNow => pick('label'),
        _ => null,
      };
    case 'act-06-12-01-scaffolded':
      return switch (region) {
        LessonTableRegion.lagObserveSomeFolds => pick('sep'),
        LessonTableRegion.lagObserveNoDiff => pick('same'),
        _ => null,
      };
    case 'act-06-12-01-unguided':
      return switch (region) {
        LessonTableRegion.lagObserveKeepSampling => pick('wait'),
        LessonTableRegion.lagObserveLockNow => pick('now'),
        _ => null,
      };
    case 'act-06-12-01-checkpoint':
      return switch (region) {
        LessonTableRegion.lagObserveBundle => pick('bundle'),
        LessonTableRegion.lagObserveSeemLoud => pick('soul'),
        _ => null,
      };
    case 'act-06-12-02-guided':
      return switch (region) {
        LessonTableRegion.meetLagLabel => pick('lag'),
        LessonTableRegion.meetLagTagDistractor => pick('tag'),
        _ => null,
      };
    case 'act-06-12-02-scaffolded':
      return switch (region) {
        LessonTableRegion.meetLagPressureDiff => pick('diff'),
        LessonTableRegion.meetLagSameExploit => pick('same'),
        _ => null,
      };
    case 'act-06-12-02-unguided':
      return switch (region) {
        LessonTableRegion.meetLagLabel2 => pick('lag2'),
        LessonTableRegion.meetLagNitDistractor => pick('nit2'),
        _ => null,
      };
    case 'act-06-12-02-checkpoint':
      return switch (region) {
        LessonTableRegion.meetLagSampleLimits => pick('limits'),
        LessonTableRegion.meetLagDestiny => pick('destiny'),
        _ => null,
      };
    case 'act-06-12-03-unguided':
      return switch (region) {
        LessonTableRegion.citeLagAvoid => pick('avoid'),
        LessonTableRegion.citeLagBluffMore => pick('more'),
        _ => null,
      };
    case 'act-06-12-03-checkpoint':
      return switch (region) {
        LessonTableRegion.citeLagWidePressure => pick('cite'),
        LessonTableRegion.citeLagVibes => pick('mood'),
        _ => null,
      };
    case 'act-06-13-01-checkpoint':
      return switch (region) {
        LessonTableRegion.mixFiveTagRespect => pick('tag'),
        LessonTableRegion.mixFiveStationBluff => pick('wrong'),
        _ => null,
      };
    case 'act-06-13-02-cp-adv':
      return switch (region) {
        LessonTableRegion.s6CpRangeAdvantage => pick('ra'),
        LessonTableRegion.s6CpNoConcept => pick('none'),
        _ => null,
      };
    case 'act-06-13-02-cp-cap':
      return switch (region) {
        LessonTableRegion.s6CpMoreCapped => pick('cap'),
        LessonTableRegion.s6CpUncappedNuts => pick('uncap'),
        _ => null,
      };
    case 'act-06-13-02-cp-polar':
      return switch (region) {
        LessonTableRegion.s6CpPolarized => pick('polar'),
        LessonTableRegion.s6CpAlwaysMerged => pick('merged'),
        _ => null,
      };
    case 'act-06-13-02-cp-tag':
      return switch (region) {
        LessonTableRegion.s6CpTag => pick('tag'),
        LessonTableRegion.s6CpLagDistractor => pick('lag'),
        _ => null,
      };
    case 'act-06-13-02-cp-lag':
      return switch (region) {
        LessonTableRegion.s6CpLag => pick('lag'),
        LessonTableRegion.s6CpNit => pick('nit'),
        _ => null,
      };
    case 'act-07-01-01-guided':
      return switch (region) {
        LessonTableRegion.preflopFlopPlanSick => pick('dead'),
        LessonTableRegion.preflopFlopStillJam => pick('jam'),
        _ => null,
      };
    case 'act-07-01-01-scaffolded':
      return switch (region) {
        LessonTableRegion.preflopFlopValueContinues => pick('value'),
        LessonTableRegion.preflopFlopAutoFold => pick('fold'),
        _ => null,
      };
    case 'act-07-01-01-unguided':
      return switch (region) {
        LessonTableRegion.preflopFlopNameThesis => pick('thesis'),
        LessonTableRegion.preflopFlopWingIt => pick('vibes'),
        _ => null,
      };
    case 'act-07-01-01-checkpoint':
      return switch (region) {
        LessonTableRegion.preflopFlopAbandon => pick('abandon'),
        LessonTableRegion.preflopFlopForce => pick('force'),
        _ => null,
      };
    case 'act-07-02-01-guided':
      return switch (region) {
        LessonTableRegion.turnMapAcesBlanks => pick('ok'),
        LessonTableRegion.turnMapAnyCard => pick('any'),
        _ => null,
      };
    case 'act-07-02-01-scaffolded':
      return switch (region) {
        LessonTableRegion.turnMapGiveUp => pick('give'),
        LessonTableRegion.turnMapHeroCall => pick('hero'),
        _ => null,
      };
    case 'act-07-02-01-unguided':
      return switch (region) {
        LessonTableRegion.turnMapMapFirst => pick('avoid'),
        LessonTableRegion.turnMapYolo => pick('yolo'),
        _ => null,
      };
    case 'act-07-02-01-checkpoint':
      return switch (region) {
        LessonTableRegion.turnMapContinueKill => pick('list'),
        LessonTableRegion.turnMapInventLater => pick('later'),
        _ => null,
      };
    case 'act-07-03-01-scaffolded':
      return switch (region) {
        LessonTableRegion.riverCompBlocks => pick('block'),
        LessonTableRegion.riverCompFakeEv => pick('ev'),
        _ => null,
      };
    case 'act-07-03-01-unguided':
      return switch (region) {
        LessonTableRegion.riverCompCheck => pick('check'),
        LessonTableRegion.riverCompBlast => pick('spew'),
        _ => null,
      };
    case 'act-07-03-01-checkpoint':
      return switch (region) {
        LessonTableRegion.riverCompRule => pick('rule'),
        LessonTableRegion.riverCompStyle => pick('random'),
        _ => null,
      };
    case 'act-07-04-01-guided':
      return switch (region) {
        LessonTableRegion.potTypeNutPotential => pick('nuts'),
        LessonTableRegion.potTypePureAir => pick('air'),
        _ => null,
      };
    case 'act-07-04-01-scaffolded':
      return switch (region) {
        LessonTableRegion.potTypeCbetMaps => pick('cb'),
        LessonTableRegion.potTypeNeverBet => pick('check'),
        _ => null,
      };
    case 'act-07-04-01-unguided':
      return switch (region) {
        LessonTableRegion.potTypeHigherCommit => pick('commit'),
        LessonTableRegion.potTypeDeepLike300 => pick('deep'),
        _ => null,
      };
    case 'act-07-04-01-checkpoint':
      return switch (region) {
        LessonTableRegion.potTypeRangesSpr => pick('both'),
        LessonTableRegion.potTypeNothing => pick('nothing'),
        _ => null,
      };
    case 'act-07-05-01-guided':
      return switch (region) {
        LessonTableRegion.huMwUsuallyNo => pick('no'),
        LessonTableRegion.huMwAlwaysYes => pick('yes'),
        _ => null,
      };
    case 'act-07-05-01-scaffolded':
      return switch (region) {
        LessonTableRegion.huMwHigherHu => pick('higher'),
        LessonTableRegion.huMwIdentical => pick('same'),
        _ => null,
      };
    case 'act-07-05-01-unguided':
      return switch (region) {
        LessonTableRegion.huMwThickerValue => pick('thick'),
        LessonTableRegion.huMwUltraSlow => pick('slow'),
        _ => null,
      };
    case 'act-07-05-01-checkpoint':
      return switch (region) {
        LessonTableRegion.huMwFirstClass => pick('input'),
        LessonTableRegion.huMwNoise => pick('ignore'),
        _ => null,
      };
    case 'act-07-06-01-guided':
      return switch (region) {
        LessonTableRegion.stackDepthCloserCommit => pick('commit'),
        LessonTableRegion.stackDepthPlayDeep => pick('deep'),
        _ => null,
      };
    case 'act-07-06-01-scaffolded':
      return switch (region) {
        LessonTableRegion.stackDepthMoreAttractive => pick('yes'),
        LessonTableRegion.stackDepthNeverMine => pick('no'),
        _ => null,
      };
    case 'act-07-06-01-unguided':
      return switch (region) {
        LessonTableRegion.stackDepth40bb => pick('40'),
        LessonTableRegion.stackDepth200bb => pick('200'),
        _ => null,
      };
    case 'act-07-06-01-checkpoint':
      return switch (region) {
        LessonTableRegion.stackDepthEveryHand => pick('every'),
        LessonTableRegion.stackDepthOnceLifetime => pick('once'),
        _ => null,
      };
    case 'act-07-07-01-checkpoint':
      return switch (region) {
        LessonTableRegion.sameCardsBaseline => pick('base'),
        LessonTableRegion.sameCardsGuess => pick('guess'),
        _ => null,
      };
    case 'act-07-08-01-checkpoint':
      return switch (region) {
        LessonTableRegion.typeBoardAllFour => pick('four'),
        LessonTableRegion.typeBoardCardsOnly => pick('one'),
        _ => null,
      };
    case 'act-07-09-01-guided':
      return switch (region) {
        LessonTableRegion.leakReviewSpecific => pick('spec'),
        LessonTableRegion.leakReviewVague => pick('vague'),
        _ => null,
      };
    case 'act-07-09-01-scaffolded':
      return switch (region) {
        LessonTableRegion.leakReviewWrittenRange => pick('book'),
        LessonTableRegion.leakReviewMood => pick('mood'),
        _ => null,
      };
    case 'act-07-09-01-unguided':
      return switch (region) {
        LessonTableRegion.leakReviewOnSchedule => pick('sched'),
        LessonTableRegion.leakReviewNever => pick('never'),
        _ => null,
      };
    case 'act-07-09-01-checkpoint':
      return switch (region) {
        LessonTableRegion.leakReviewBaseline => pick('base'),
        LessonTableRegion.leakReviewReplaceAll => pick('replace'),
        _ => null,
      };
  }
  return null;
}

/// Whether this activity is answered by tapping the mini-table.
bool isTableRegionTapActivity(CourseActivity activity) {
  if (activity.renderer == ActivityRenderer.coachDialogue) {
    // Interactive explains: tap the demo instead of Continue.
    return activity.id == 'act-01-01-01-explain-hole-cards' ||
        activity.id == 'act-01-01-02-explain-suits' ||
        activity.id == 'act-01-01-03-explain-button' ||
        activity.id == 'act-02-01-01-explain-pos' ||
        activity.id == 'act-01-02-01-explain-ladder' ||
        activity.id == 'act-01-02-02-explain-five' ||
        activity.id == 'act-01-03-01-explain-passive' ||
        activity.id == 'act-01-03-02-explain-aggro' ||
        activity.id == 'act-01-04-01-explain-streets' ||
        activity.id == 'act-01-05-01-explain-win' ||
        activity.id == 'act-01-06-01-explain-run' ||
        activity.id == 'act-02-01-02-explain-order' ||
        activity.id == 'act-02-02-01-explain-families' ||
        activity.id == 'act-02-03-01-explain-open' ||
        activity.id == 'act-02-04-01-explain-vs' ||
        activity.id == 'act-02-05-01-explain-bb' ||
        activity.id == 'act-02-06-01-explain-habits' ||
        activity.id == 'act-02-07-01-explain-full' ||
        activity.id == 'act-03-01-01-explain' ||
        activity.id == 'act-03-02-01-explain' ||
        activity.id == 'act-03-03-01-explain' ||
        activity.id == 'act-03-04-01-explain' ||
        activity.id == 'act-03-05-01-explain' ||
        activity.id == 'act-03-06-01-explain' ||
        activity.id == 'act-03-07-01-explain' ||
        activity.id == 'act-03-08-01-explain' ||
        activity.id == 'act-04-01-01-explain' ||
        activity.id == 'act-04-02-01-explain' ||
        activity.id == 'act-04-03-01-explain' ||
        activity.id == 'act-04-04-01-explain' ||
        activity.id == 'act-04-05-01-explain' ||
        activity.id == 'act-04-06-01-explain' ||
        activity.id == 'act-04-06-02-explain' ||
        activity.id == 'act-04-06-03-explain' ||
        activity.id == 'act-04-07-01-explain' ||
        activity.id == 'act-04-07-02-explain' ||
        activity.id == 'act-04-07-03-explain' ||
        activity.id == 'act-04-08-01-explain' ||
        activity.id == 'act-04-08-02-explain' ||
        activity.id == 'act-04-08-03-explain' ||
        activity.id == 'act-04-09-01-explain' ||
        activity.id == 'act-04-10-01-explain' ||
        activity.id == 'act-05-01-01-explain' ||
        activity.id == 'act-05-02-01-explain' ||
        activity.id == 'act-05-03-01-explain' ||
        activity.id == 'act-05-04-01-explain' ||
        activity.id == 'act-05-05-01-explain' ||
        activity.id == 'act-05-06-01-explain' ||
        activity.id == 'act-05-07-01-explain' ||
        activity.id == 'act-05-08-01-explain' ||
        activity.id == 'act-05-09-01-explain' ||
        activity.id == 'act-06-01-01-explain' ||
        activity.id == 'act-06-02-01-explain' ||
        activity.id == 'act-06-03-01-explain' ||
        activity.id == 'act-06-04-01-explain' ||
        activity.id == 'act-06-05-01-explain' ||
        activity.id == 'act-06-06-01-explain' ||
        activity.id == 'act-06-07-01-explain' ||
        activity.id == 'act-06-08-01-explain' ||
        activity.id == 'act-06-09-01-explain' ||
        activity.id == 'act-06-10-01-explain' ||
        activity.id == 'act-06-11-01-explain' ||
        activity.id == 'act-06-11-02-explain' ||
        activity.id == 'act-06-11-03-explain' ||
        activity.id == 'act-06-12-01-explain' ||
        activity.id == 'act-06-12-02-explain' ||
        activity.id == 'act-06-12-03-explain' ||
        activity.id == 'act-06-13-01-explain' ||
        activity.id == 'act-07-01-01-explain' ||
        activity.id == 'act-07-02-01-explain' ||
        activity.id == 'act-07-03-01-explain' ||
        activity.id == 'act-07-04-01-explain' ||
        activity.id == 'act-07-05-01-explain' ||
        activity.id == 'act-07-06-01-explain' ||
        activity.id == 'act-07-07-01-explain' ||
        activity.id == 'act-07-08-01-explain' ||
        activity.id == 'act-07-09-01-explain' ||
        activity.id == 'act-07-10-01-explain';
  }
  if (activity.renderer != ActivityRenderer.selectIdentify &&
      activity.renderer != ActivityRenderer.playerReadClassify) {
    return false;
  }
  return activity.id.startsWith('act-01-01-01-') ||
      activity.id.startsWith('act-01-01-03-') ||
      activity.id.startsWith('act-01-04-01-') ||
      activity.id.startsWith('act-01-05-01-') ||
      activity.id.startsWith('act-02-01-01-') ||
      activity.id == 'act-02-07-01-checkpoint-habit' ||
      activity.id == 'act-02-07-02-jump-pos' ||
      activity.id == 'act-02-07-02-jump-stack' ||
      activity.id == 'act-03-01-01-guided' ||
      activity.id == 'act-03-01-01-scaffolded' ||
      activity.id == 'act-03-01-01-unguided' ||
      activity.id == 'act-03-01-01-checkpoint' ||
      activity.id == 'act-03-03-01-scaffolded' ||
      activity.id == 'act-04-06-01-guided' ||
      activity.id == 'act-04-06-02-guided' ||
      activity.id == 'act-04-06-02-scaffolded' ||
      activity.id == 'act-04-06-02-unguided' ||
      activity.id == 'act-04-06-02-checkpoint' ||
      activity.id == 'act-04-06-03-checkpoint' ||
      activity.id.startsWith('act-04-07-01-') ||
      activity.id == 'act-04-07-02-guided' ||
      activity.id == 'act-04-07-02-unguided' ||
      activity.id == 'act-04-07-02-checkpoint' ||
      activity.id == 'act-04-07-03-checkpoint' ||
      activity.id.startsWith('act-04-08-01-') ||
      activity.id == 'act-04-08-02-guided' ||
      activity.id == 'act-04-08-02-unguided' ||
      activity.id == 'act-04-08-02-checkpoint' ||
      activity.id == 'act-04-08-03-checkpoint' ||
      activity.id.startsWith('act-04-09-01-') ||
      activity.id == 'act-04-10-02-jump-range' ||
      activity.id == 'act-04-10-02-jump-station' ||
      activity.id == 'act-04-10-02-jump-nit' ||
      activity.id == 'act-04-10-02-jump-maniac' ||
      activity.id == 'act-05-01-01-guided' ||
      activity.id == 'act-05-01-01-checkpoint' ||
      activity.id == 'act-05-02-01-guided' ||
      activity.id == 'act-05-02-01-unguided' ||
      activity.id == 'act-05-02-01-checkpoint' ||
      activity.id == 'act-05-03-01-checkpoint' ||
      activity.id == 'act-05-04-01-checkpoint' ||
      activity.id == 'act-05-05-01-guided' ||
      activity.id == 'act-05-05-01-unguided' ||
      activity.id == 'act-05-05-01-checkpoint' ||
      activity.id == 'act-05-06-01-guided' ||
      activity.id == 'act-05-06-01-unguided' ||
      activity.id == 'act-05-06-01-checkpoint' ||
      activity.id == 'act-05-07-01-guided' ||
      activity.id == 'act-05-07-01-scaffolded' ||
      activity.id == 'act-05-07-01-unguided' ||
      activity.id == 'act-05-07-01-checkpoint' ||
      activity.id == 'act-05-08-01-guided' ||
      activity.id == 'act-05-08-01-scaffolded' ||
      activity.id == 'act-05-08-01-checkpoint' ||
      activity.id == 'act-05-09-01-guided' ||
      activity.id == 'act-05-09-01-scaffolded' ||
      activity.id == 'act-05-09-01-unguided' ||
      activity.id == 'act-05-09-01-checkpoint' ||
      activity.id == 'act-05-09-02-cp-multi' ||
      activity.id == 'act-05-09-02-cp-tell' ||
      activity.id == 'act-05-09-02-cp-stop' ||
      activity.id == 'act-06-01-01-guided' ||
      activity.id == 'act-06-01-01-scaffolded' ||
      activity.id == 'act-06-01-01-checkpoint' ||
      activity.id == 'act-06-02-01-guided' ||
      activity.id == 'act-06-02-01-scaffolded' ||
      activity.id == 'act-06-02-01-unguided' ||
      activity.id == 'act-06-02-01-checkpoint' ||
      activity.id == 'act-06-03-01-guided' ||
      activity.id == 'act-06-03-01-unguided' ||
      activity.id == 'act-06-03-01-checkpoint' ||
      activity.id == 'act-06-04-01-guided' ||
      activity.id == 'act-06-04-01-unguided' ||
      activity.id == 'act-06-04-01-checkpoint' ||
      activity.id == 'act-06-05-01-guided' ||
      activity.id == 'act-06-05-01-unguided' ||
      activity.id == 'act-06-05-01-checkpoint' ||
      activity.id == 'act-06-06-01-guided' ||
      activity.id == 'act-06-06-01-scaffolded' ||
      activity.id == 'act-06-06-01-unguided' ||
      activity.id == 'act-06-06-01-checkpoint' ||
      activity.id == 'act-06-07-01-guided' ||
      activity.id == 'act-06-07-01-unguided' ||
      activity.id == 'act-06-07-01-checkpoint' ||
      activity.id == 'act-06-08-01-scaffolded' ||
      activity.id == 'act-06-08-01-unguided' ||
      activity.id == 'act-06-08-01-checkpoint' ||
      activity.id == 'act-06-09-01-guided' ||
      activity.id == 'act-06-09-01-unguided' ||
      activity.id == 'act-06-09-01-checkpoint' ||
      activity.id == 'act-06-10-01-scaffolded' ||
      activity.id == 'act-06-10-01-unguided' ||
      activity.id == 'act-06-10-01-checkpoint' ||
      activity.id == 'act-06-11-01-guided' ||
      activity.id == 'act-06-11-01-scaffolded' ||
      activity.id == 'act-06-11-01-unguided' ||
      activity.id == 'act-06-11-01-checkpoint' ||
      activity.id == 'act-06-11-02-guided' ||
      activity.id == 'act-06-11-02-scaffolded' ||
      activity.id == 'act-06-11-02-unguided' ||
      activity.id == 'act-06-11-02-checkpoint' ||
      activity.id == 'act-06-11-03-checkpoint' ||
      activity.id == 'act-06-12-01-guided' ||
      activity.id == 'act-06-12-01-scaffolded' ||
      activity.id == 'act-06-12-01-unguided' ||
      activity.id == 'act-06-12-01-checkpoint' ||
      activity.id == 'act-06-12-02-guided' ||
      activity.id == 'act-06-12-02-scaffolded' ||
      activity.id == 'act-06-12-02-unguided' ||
      activity.id == 'act-06-12-02-checkpoint' ||
      activity.id == 'act-06-12-03-unguided' ||
      activity.id == 'act-06-12-03-checkpoint' ||
      activity.id == 'act-06-13-01-checkpoint' ||
      activity.id == 'act-06-13-02-cp-adv' ||
      activity.id == 'act-06-13-02-cp-cap' ||
      activity.id == 'act-06-13-02-cp-polar' ||
      activity.id == 'act-06-13-02-cp-tag' ||
      activity.id == 'act-06-13-02-cp-lag' ||
      activity.id == 'act-07-01-01-guided' ||
      activity.id == 'act-07-01-01-scaffolded' ||
      activity.id == 'act-07-01-01-unguided' ||
      activity.id == 'act-07-01-01-checkpoint' ||
      activity.id == 'act-07-02-01-guided' ||
      activity.id == 'act-07-02-01-scaffolded' ||
      activity.id == 'act-07-02-01-unguided' ||
      activity.id == 'act-07-02-01-checkpoint' ||
      activity.id == 'act-07-03-01-scaffolded' ||
      activity.id == 'act-07-03-01-unguided' ||
      activity.id == 'act-07-03-01-checkpoint' ||
      activity.id == 'act-07-04-01-guided' ||
      activity.id == 'act-07-04-01-scaffolded' ||
      activity.id == 'act-07-04-01-unguided' ||
      activity.id == 'act-07-04-01-checkpoint' ||
      activity.id == 'act-07-05-01-guided' ||
      activity.id == 'act-07-05-01-scaffolded' ||
      activity.id == 'act-07-05-01-unguided' ||
      activity.id == 'act-07-05-01-checkpoint' ||
      activity.id == 'act-07-06-01-guided' ||
      activity.id == 'act-07-06-01-scaffolded' ||
      activity.id == 'act-07-06-01-unguided' ||
      activity.id == 'act-07-06-01-checkpoint' ||
      activity.id == 'act-07-07-01-checkpoint' ||
      activity.id == 'act-07-08-01-checkpoint' ||
      activity.id == 'act-07-09-01-guided' ||
      activity.id == 'act-07-09-01-scaffolded' ||
      activity.id == 'act-07-09-01-unguided' ||
      activity.id == 'act-07-09-01-checkpoint';
}

/// Small-blind seat index clockwise from the button.
int blindsSmallBlindSeat({required int buttonSeat, required int seatCount}) {
  return (buttonSeat + 1) % seatCount;
}

/// Big-blind seat index clockwise from the button.
int blindsBigBlindSeat({required int buttonSeat, required int seatCount}) {
  return (buttonSeat + 2) % seatCount;
}

/// Early-position / UTG seat index clockwise from the button (six-max).
int positionEarlySeat({required int buttonSeat, required int seatCount}) {
  return (buttonSeat + 3) % seatCount;
}

/// Hijack seat index clockwise from the button (six-max).
int positionHijackSeat({required int buttonSeat, required int seatCount}) {
  return (buttonSeat + 4) % seatCount;
}

/// Cutoff seat index clockwise from the button (six-max).
int positionCutoffSeat({required int buttonSeat, required int seatCount}) {
  return (buttonSeat + 5) % seatCount;
}

/// Role for a seat on a blinds teaching layout.
LessonTableRegion blindsRoleForSeat({
  required int seatIndex,
  required int buttonSeat,
  required int seatCount,
}) {
  if (seatIndex == buttonSeat) return LessonTableRegion.button;
  if (seatIndex ==
      blindsSmallBlindSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.smallBlind;
  }
  if (seatIndex ==
      blindsBigBlindSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.bigBlind;
  }
  return LessonTableRegion.emptySeat;
}

/// Role for a seat on a six-max position-labels layout.
LessonTableRegion positionRoleForSeat({
  required int seatIndex,
  required int buttonSeat,
  required int seatCount,
}) {
  if (seatIndex == buttonSeat) return LessonTableRegion.button;
  if (seatIndex ==
      blindsSmallBlindSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.smallBlind;
  }
  if (seatIndex ==
      blindsBigBlindSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.bigBlind;
  }
  if (seatIndex ==
      positionEarlySeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.earlyPosition;
  }
  if (seatIndex ==
      positionHijackSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.hijack;
  }
  if (seatIndex ==
      positionCutoffSeat(buttonSeat: buttonSeat, seatCount: seatCount)) {
    return LessonTableRegion.cutoff;
  }
  return LessonTableRegion.emptySeat;
}

/// A tappable answer target on the lesson mini-table.
class LessonTableTapTarget {
  /// Creates a tap target.
  const LessonTableTapTarget(this.region, {this.seatIndex});

  final LessonTableRegion region;

  /// Absolute seat index when [region] is a blinds seat.
  final int? seatIndex;
}

/// Felt strip with hero holes, optional board, and face-down seats.
class LessonTableContext extends StatelessWidget {
  /// Creates the table context chrome.
  const LessonTableContext({
    super.key,
    required this.scene,
    this.selectedRegion,
    this.selectedSeatIndex,
    this.onRegionTap,
    this.enabled = true,
    this.showSoftPulse = false,
  });

  final LessonTableScene scene;

  /// Currently selected region (gold border).
  final LessonTableRegion? selectedRegion;

  /// Currently selected seat on a blinds layout.
  final int? selectedSeatIndex;

  /// When set, table regions are tappable answers.
  final ValueChanged<LessonTableTapTarget>? onRegionTap;

  final bool enabled;

  /// Guided soft pulse on [scene.highlight] when nothing is selected yet.
  final bool showSoftPulse;

  bool get _interactive => onRegionTap != null;

  @override
  Widget build(BuildContext context) {
    return switch (scene.layout) {
      LessonTableLayout.blindsSeats => _buildBlindsSeats(),
      LessonTableLayout.positionLabels => _buildPositionLabels(),
      LessonTableLayout.blindsTiming => _buildBlindsTiming(),
      LessonTableLayout.streetEndPhases => _buildStreetEndPhases(),
      LessonTableLayout.potFoldWinOutcomes => _buildPotFoldWinOutcomes(),
      LessonTableLayout.potShowdownOutcomes => _buildPotShowdownOutcomes(),
      LessonTableLayout.potSideOutcomes => _buildPotSideOutcomes(),
      LessonTableLayout.potOpenSizeOutcomes => _buildPotOpenSizeOutcomes(),
      LessonTableLayout.habitCoverOutcomes => _buildHabitCoverOutcomes(),
      LessonTableLayout.effectiveStackOutcomes =>
        _buildEffectiveStackOutcomes(),
      LessonTableLayout.potMultiwayOutcomes => _buildPotMultiwayOutcomes(),
      LessonTableLayout.callPriceOutcomes => _buildCallPriceOutcomes(),
      LessonTableLayout.drawPriceOutcomes => _buildDrawPriceOutcomes(),
      LessonTableLayout.verbalBindingOutcomes => _buildVerbalBindingOutcomes(),
      LessonTableLayout.tableReadMattersOutcomes =>
          _buildTableReadMattersOutcomes(),
      LessonTableLayout.observeParticipationOutcomes =>
          _buildObserveParticipationOutcomes(),
      LessonTableLayout.playerTypeStationOutcomes =>
          _buildPlayerTypeStationOutcomes(),
      LessonTableLayout.labelModelOutcomes => _buildLabelModelOutcomes(),
      LessonTableLayout.playerTypeStationManiacOutcomes =>
          _buildPlayerTypeStationManiacOutcomes(),
      LessonTableLayout.sampleConfidenceOutcomes =>
          _buildSampleConfidenceOutcomes(),
      LessonTableLayout.stationBluffCiteOutcomes =>
          _buildStationBluffCiteOutcomes(),
      LessonTableLayout.observeNarrowEntryOutcomes =>
          _buildObserveNarrowEntryOutcomes(),
      LessonTableLayout.observeNarrowAggressionOutcomes =>
          _buildObserveNarrowAggressionOutcomes(),
      LessonTableLayout.observeNarrowSampleOutcomes =>
          _buildObserveNarrowSampleOutcomes(),
      LessonTableLayout.observeNarrowBundleOutcomes =>
          _buildObserveNarrowBundleOutcomes(),
      LessonTableLayout.meetNitVsStationOutcomes =>
          _buildMeetNitVsStationOutcomes(),
      LessonTableLayout.meetNitVsManiacOutcomes =>
          _buildMeetNitVsManiacOutcomes(),
      LessonTableLayout.meetNitModelOutcomes => _buildMeetNitModelOutcomes(),
      LessonTableLayout.nitRespectCiteOutcomes =>
          _buildNitRespectCiteOutcomes(),
      LessonTableLayout.observeWildEntryOutcomes =>
          _buildObserveWildEntryOutcomes(),
      LessonTableLayout.observeWildPressureOutcomes =>
          _buildObserveWildPressureOutcomes(),
      LessonTableLayout.observeWildNotesOutcomes =>
          _buildObserveWildNotesOutcomes(),
      LessonTableLayout.observeWildBundleOutcomes =>
          _buildObserveWildBundleOutcomes(),
      LessonTableLayout.meetManiacVsNitOutcomes =>
          _buildMeetManiacVsNitOutcomes(),
      LessonTableLayout.meetManiacVsStationOutcomes =>
          _buildMeetManiacVsStationOutcomes(),
      LessonTableLayout.meetManiacMixOutcomes =>
          _buildMeetManiacMixOutcomes(),
      LessonTableLayout.maniacCallCiteOutcomes =>
          _buildManiacCallCiteOutcomes(),
      LessonTableLayout.confidenceOneNoteOutcomes =>
          _buildConfidenceOneNoteOutcomes(),
      LessonTableLayout.confidenceRiseOutcomes =>
          _buildConfidenceRiseOutcomes(),
      LessonTableLayout.confidenceUpdateOutcomes =>
          _buildConfidenceUpdateOutcomes(),
      LessonTableLayout.confidenceLimitsOutcomes =>
          _buildConfidenceLimitsOutcomes(),
      LessonTableLayout.jumpUtgRangeOutcomes =>
          _buildJumpUtgRangeOutcomes(),
      LessonTableLayout.jumpStationExploitOutcomes =>
          _buildJumpStationExploitOutcomes(),
      LessonTableLayout.jumpNitExploitOutcomes =>
          _buildJumpNitExploitOutcomes(),
      LessonTableLayout.jumpManiacExploitOutcomes =>
          _buildJumpManiacExploitOutcomes(),
      LessonTableLayout.multiwayContinueOutcomes =>
          _buildMultiwayContinueOutcomes(),
      LessonTableLayout.multiwayPriorityOutcomes =>
          _buildMultiwayPriorityOutcomes(),
      LessonTableLayout.deepImpliedOutcomes =>
          _buildDeepImpliedOutcomes(),
      LessonTableLayout.deepPlanOutcomes => _buildDeepPlanOutcomes(),
      LessonTableLayout.deepRewardsOutcomes =>
          _buildDeepRewardsOutcomes(),
      LessonTableLayout.impliedOddsRiseOutcomes =>
          _buildImpliedOddsRiseOutcomes(),
      LessonTableLayout.thinValueReadOutcomes =>
          _buildThinValueReadOutcomes(),
      LessonTableLayout.linesNitXrOutcomes => _buildLinesNitXrOutcomes(),
      LessonTableLayout.linesDonkPolarOutcomes =>
          _buildLinesDonkPolarOutcomes(),
      LessonTableLayout.linesDelayOutcomes => _buildLinesDelayOutcomes(),
      LessonTableLayout.lineReadCappedOutcomes =>
          _buildLineReadCappedOutcomes(),
      LessonTableLayout.lineReadRebuildOutcomes =>
          _buildLineReadRebuildOutcomes(),
      LessonTableLayout.lineReadUncappedOutcomes =>
          _buildLineReadUncappedOutcomes(),
      LessonTableLayout.timingSoftEvidenceOutcomes =>
          _buildTimingSoftEvidenceOutcomes(),
      LessonTableLayout.timingSizingWeakOutcomes =>
          _buildTimingSizingWeakOutcomes(),
      LessonTableLayout.timingRejectMagicOutcomes =>
          _buildTimingRejectMagicOutcomes(),
      LessonTableLayout.timingTinyUpdateOutcomes =>
          _buildTimingTinyUpdateOutcomes(),
      LessonTableLayout.dynamicsStuckOutcomes =>
          _buildDynamicsStuckOutcomes(),
      LessonTableLayout.dynamicsGearOutcomes =>
          _buildDynamicsGearOutcomes(),
      LessonTableLayout.dynamicsFreshOutcomes =>
          _buildDynamicsFreshOutcomes(),
      LessonTableLayout.disciplineStopOutcomes =>
          _buildDisciplineStopOutcomes(),
      LessonTableLayout.disciplineStakesOutcomes =>
          _buildDisciplineStakesOutcomes(),
      LessonTableLayout.disciplineCashOutOutcomes =>
          _buildDisciplineCashOutOutcomes(),
      LessonTableLayout.disciplineEdgeOutcomes =>
          _buildDisciplineEdgeOutcomes(),
      LessonTableLayout.s5CpMultiOutcomes => _buildS5CpMultiOutcomes(),
      LessonTableLayout.s5CpTellOutcomes => _buildS5CpTellOutcomes(),
      LessonTableLayout.s5CpStopOutcomes => _buildS5CpStopOutcomes(),
      LessonTableLayout.rangeAdvPfrOutcomes => _buildRangeAdvPfrOutcomes(),
      LessonTableLayout.rangeAdvNutsOutcomes => _buildRangeAdvNutsOutcomes(),
      LessonTableLayout.rangeAdvPressOutcomes =>
          _buildRangeAdvPressOutcomes(),
      LessonTableLayout.eqRealizeIpOutcomes => _buildEqRealizeIpOutcomes(),
      LessonTableLayout.eqRealizeDiscountOutcomes =>
          _buildEqRealizeDiscountOutcomes(),
      LessonTableLayout.eqRealizeAggressionOutcomes =>
          _buildEqRealizeAggressionOutcomes(),
      LessonTableLayout.eqRealizePosOutcomes => _buildEqRealizePosOutcomes(),
      LessonTableLayout.cappedGuidedOutcomes => _buildCappedGuidedOutcomes(),
      LessonTableLayout.cappedUncappedLineOutcomes =>
          _buildCappedUncappedLineOutcomes(),
      LessonTableLayout.cappedAttackOutcomes => _buildCappedAttackOutcomes(),
      LessonTableLayout.polarGuidedOutcomes => _buildPolarGuidedOutcomes(),
      LessonTableLayout.polarMismatchOutcomes => _buildPolarMismatchOutcomes(),
      LessonTableLayout.polarAimOutcomes => _buildPolarAimOutcomes(),
      LessonTableLayout.overbetGuidedOutcomes => _buildOverbetGuidedOutcomes(),
      LessonTableLayout.overbetAvoidOutcomes => _buildOverbetAvoidOutcomes(),
      LessonTableLayout.overbetPlanOutcomes => _buildOverbetPlanOutcomes(),
      LessonTableLayout.blockersGuidedOutcomes => _buildBlockersGuidedOutcomes(),
      LessonTableLayout.blockersUnblockOutcomes =>
          _buildBlockersUnblockOutcomes(),
      LessonTableLayout.blockersTweakOutcomes => _buildBlockersTweakOutcomes(),
      LessonTableLayout.blockersEvOutcomes => _buildBlockersEvOutcomes(),
      LessonTableLayout.defendGuidedOutcomes => _buildDefendGuidedOutcomes(),
      LessonTableLayout.defendIntuitionOutcomes =>
          _buildDefendIntuitionOutcomes(),
      LessonTableLayout.defendPunishOutcomes => _buildDefendPunishOutcomes(),
      LessonTableLayout.mixStationOutcomes => _buildMixStationOutcomes(),
      LessonTableLayout.mixReasonOutcomes => _buildMixReasonOutcomes(),
      LessonTableLayout.mixPurposeOutcomes => _buildMixPurposeOutcomes(),
      LessonTableLayout.threeBetCommitOutcomes =>
          _buildThreeBetCommitOutcomes(),
      LessonTableLayout.threeBetEgoOutcomes => _buildThreeBetEgoOutcomes(),
      LessonTableLayout.threeBetSprOutcomes => _buildThreeBetSprOutcomes(),
      LessonTableLayout.hardFoldCoolerOutcomes =>
          _buildHardFoldCoolerOutcomes(),
      LessonTableLayout.hardFoldEgoOutcomes => _buildHardFoldEgoOutcomes(),
      LessonTableLayout.hardFoldReviewOutcomes =>
          _buildHardFoldReviewOutcomes(),
      LessonTableLayout.selectiveGuidedOutcomes =>
          _buildSelectiveGuidedOutcomes(),
      LessonTableLayout.selectiveDiscOutcomes =>
          _buildSelectiveDiscOutcomes(),
      LessonTableLayout.selectiveSampleOutcomes =>
          _buildSelectiveSampleOutcomes(),
      LessonTableLayout.selectiveBundleOutcomes =>
          _buildSelectiveBundleOutcomes(),
      LessonTableLayout.meetTagVsStationOutcomes =>
          _buildMeetTagVsStationOutcomes(),
      LessonTableLayout.meetTagDiffOutcomes => _buildMeetTagDiffOutcomes(),
      LessonTableLayout.meetTagVsManiacOutcomes =>
          _buildMeetTagVsManiacOutcomes(),
      LessonTableLayout.meetTagModelOutcomes => _buildMeetTagModelOutcomes(),
      LessonTableLayout.tagRespectCiteOutcomes =>
          _buildTagRespectCiteOutcomes(),
      LessonTableLayout.lagObserveGuidedOutcomes =>
          _buildLagObserveGuidedOutcomes(),
      LessonTableLayout.lagObserveDiscOutcomes =>
          _buildLagObserveDiscOutcomes(),
      LessonTableLayout.lagObserveSampleOutcomes =>
          _buildLagObserveSampleOutcomes(),
      LessonTableLayout.lagObserveBundleOutcomes =>
          _buildLagObserveBundleOutcomes(),
      LessonTableLayout.meetLagVsTagOutcomes => _buildMeetLagVsTagOutcomes(),
      LessonTableLayout.meetLagDiffOutcomes => _buildMeetLagDiffOutcomes(),
      LessonTableLayout.meetLagVsNitOutcomes => _buildMeetLagVsNitOutcomes(),
      LessonTableLayout.meetLagLimitsOutcomes => _buildMeetLagLimitsOutcomes(),
      LessonTableLayout.lagAdjustAvoidOutcomes =>
          _buildLagAdjustAvoidOutcomes(),
      LessonTableLayout.lagAdjustCiteOutcomes =>
          _buildLagAdjustCiteOutcomes(),
      LessonTableLayout.mixFiveTagRespectOutcomes =>
          _buildMixFiveTagRespectOutcomes(),
      LessonTableLayout.s6CpAdvOutcomes => _buildS6CpAdvOutcomes(),
      LessonTableLayout.s6CpCapOutcomes => _buildS6CpCapOutcomes(),
      LessonTableLayout.s6CpPolarOutcomes => _buildS6CpPolarOutcomes(),
      LessonTableLayout.s6CpTagOutcomes => _buildS6CpTagOutcomes(),
      LessonTableLayout.s6CpLagOutcomes => _buildS6CpLagOutcomes(),
      LessonTableLayout.preflopFlopGuidedOutcomes =>
          _buildPreflopFlopGuidedOutcomes(),
      LessonTableLayout.preflopFlopScaffoldedOutcomes =>
          _buildPreflopFlopScaffoldedOutcomes(),
      LessonTableLayout.preflopFlopUnguidedOutcomes =>
          _buildPreflopFlopUnguidedOutcomes(),
      LessonTableLayout.preflopFlopCheckpointOutcomes =>
          _buildPreflopFlopCheckpointOutcomes(),
      LessonTableLayout.turnMapGuidedOutcomes =>
          _buildTurnMapGuidedOutcomes(),
      LessonTableLayout.turnMapScaffoldedOutcomes =>
          _buildTurnMapScaffoldedOutcomes(),
      LessonTableLayout.turnMapUnguidedOutcomes =>
          _buildTurnMapUnguidedOutcomes(),
      LessonTableLayout.turnMapCheckpointOutcomes =>
          _buildTurnMapCheckpointOutcomes(),
      LessonTableLayout.riverCompScaffoldedOutcomes =>
          _buildRiverCompScaffoldedOutcomes(),
      LessonTableLayout.riverCompUnguidedOutcomes =>
          _buildRiverCompUnguidedOutcomes(),
      LessonTableLayout.riverCompCheckpointOutcomes =>
          _buildRiverCompCheckpointOutcomes(),
      LessonTableLayout.potTypeGuidedOutcomes =>
          _buildPotTypeGuidedOutcomes(),
      LessonTableLayout.potTypeScaffoldedOutcomes =>
          _buildPotTypeScaffoldedOutcomes(),
      LessonTableLayout.potTypeUnguidedOutcomes =>
          _buildPotTypeUnguidedOutcomes(),
      LessonTableLayout.potTypeCheckpointOutcomes =>
          _buildPotTypeCheckpointOutcomes(),
      LessonTableLayout.huMwGuidedOutcomes => _buildHuMwGuidedOutcomes(),
      LessonTableLayout.huMwScaffoldedOutcomes =>
          _buildHuMwScaffoldedOutcomes(),
      LessonTableLayout.huMwUnguidedOutcomes => _buildHuMwUnguidedOutcomes(),
      LessonTableLayout.huMwCheckpointOutcomes =>
          _buildHuMwCheckpointOutcomes(),
      LessonTableLayout.stackDepthGuidedOutcomes =>
          _buildStackDepthGuidedOutcomes(),
      LessonTableLayout.stackDepthScaffoldedOutcomes =>
          _buildStackDepthScaffoldedOutcomes(),
      LessonTableLayout.stackDepthUnguidedOutcomes =>
          _buildStackDepthUnguidedOutcomes(),
      LessonTableLayout.stackDepthCheckpointOutcomes =>
          _buildStackDepthCheckpointOutcomes(),
      LessonTableLayout.sameCardsCheckpointOutcomes =>
          _buildSameCardsCheckpointOutcomes(),
      LessonTableLayout.typeBoardCheckpointOutcomes =>
          _buildTypeBoardCheckpointOutcomes(),
      LessonTableLayout.leakReviewGuidedOutcomes =>
          _buildLeakReviewGuidedOutcomes(),
      LessonTableLayout.leakReviewScaffoldedOutcomes =>
          _buildLeakReviewScaffoldedOutcomes(),
      LessonTableLayout.leakReviewUnguidedOutcomes =>
          _buildLeakReviewUnguidedOutcomes(),
      LessonTableLayout.leakReviewCheckpointOutcomes =>
          _buildLeakReviewCheckpointOutcomes(),
      LessonTableLayout.holeCards => _buildHoleCards(),
    };
  }

  Widget _feltShell({required Widget child, required String semanticsLabel}) {
    return Semantics(
      label: semanticsLabel,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.feltLight, AppColors.feltDark],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.feltBorder.withValues(alpha: 0.85),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildBlindsSeats() {
    final n = scene.seatCount;
    final button = scene.buttonSeat % n;
    final sb = blindsSmallBlindSeat(buttonSeat: button, seatCount: n);
    final bb = blindsBigBlindSeat(buttonSeat: button, seatCount: n);
    final bottomRow = <int>[button, sb, bb];
    final topRow = <int>[
      for (var i = 0; i < n; i++)
        if (!bottomRow.contains(i)) i,
    ];

    LessonTableRegion roleOf(int seat) {
      final blinds = blindsRoleForSeat(
        seatIndex: seat,
        buttonSeat: button,
        seatCount: n,
      );
      if (blinds != LessonTableRegion.emptySeat) return blinds;
      // Preflop open seat (UTG) sits left of the BB — mark it when highlighted
      // so nine-handed "who opens" taps teach by seat, not by text tiles.
      if (scene.highlight == LessonTableHighlight.earlyPosition ||
          scene.highlight == LessonTableHighlight.bigBlind) {
        if (seat ==
            positionEarlySeat(buttonSeat: button, seatCount: n)) {
          return LessonTableRegion.earlyPosition;
        }
      }
      return LessonTableRegion.emptySeat;
    }

    bool pulseRole(LessonTableRegion role) {
      if (!showSoftPulse ||
          selectedRegion != null ||
          selectedSeatIndex != null) {
        return false;
      }
      return switch (scene.highlight) {
        LessonTableHighlight.button => role == LessonTableRegion.button,
        LessonTableHighlight.smallBlind =>
          role == LessonTableRegion.smallBlind,
        LessonTableHighlight.bigBlind => role == LessonTableRegion.bigBlind,
        LessonTableHighlight.earlyPosition =>
          role == LessonTableRegion.earlyPosition,
        _ => false,
      };
    }

    Widget seatChip(int seat) {
      final role = roleOf(seat);
      final selected =
          selectedSeatIndex == seat ||
          (selectedSeatIndex == null && selectedRegion == role);
      return _BlindsSeatChip(
        seatIndex: seat,
        role: role,
        numberSeats: scene.numberSeats,
        showRoleLabels: scene.showRoleLabels,
        selected: selected,
        highlighted: pulseRole(role),
        enabled: enabled && _interactive,
        onTap:
            _interactive
                ? () => onRegionTap!(
                  LessonTableTapTarget(role, seatIndex: seat),
                )
                : null,
      );
    }

    return _feltShell(
      semanticsLabel:
          _interactive
              ? 'Interactive poker table with button and blinds'
              : 'Poker table showing dealer button and blinds',
      child: Column(
        children: [
          if (topRow.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [for (final s in topRow) seatChip(s)],
            ),
          const SizedBox(height: 8),
          Text(
            scene.caption ??
                (scene.numberSeats
                    ? 'Button is seat $button · tap the small blind'
                    : 'Clockwise: button → small blind → big blind'),
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [for (final s in bottomRow) seatChip(s)],
          ),
        ],
      ),
    );
  }

  Widget _buildPositionLabels() {
    final n = scene.seatCount;
    final button = scene.buttonSeat % n;
    final sb = blindsSmallBlindSeat(buttonSeat: button, seatCount: n);
    final bb = blindsBigBlindSeat(buttonSeat: button, seatCount: n);
    final ep = positionEarlySeat(buttonSeat: button, seatCount: n);
    final hj = positionHijackSeat(buttonSeat: button, seatCount: n);
    final co = positionCutoffSeat(buttonSeat: button, seatCount: n);
    // Clockwise visual: late seats on the bottom rail, early seats on top.
    final bottomRow = <int>[co, button, sb];
    final topRow = <int>[bb, ep, hj];

    LessonTableRegion roleOf(int seat) => positionRoleForSeat(
          seatIndex: seat,
          buttonSeat: button,
          seatCount: n,
        );

    bool pulseRole(LessonTableRegion role) {
      if (!showSoftPulse ||
          selectedRegion != null ||
          selectedSeatIndex != null) {
        return false;
      }
      return switch (scene.highlight) {
        LessonTableHighlight.button => role == LessonTableRegion.button,
        LessonTableHighlight.smallBlind =>
          role == LessonTableRegion.smallBlind ||
              role == LessonTableRegion.bigBlind,
        LessonTableHighlight.bigBlind => role == LessonTableRegion.bigBlind,
        LessonTableHighlight.earlyPosition =>
          role == LessonTableRegion.earlyPosition,
        LessonTableHighlight.hijack => role == LessonTableRegion.hijack,
        LessonTableHighlight.cutoff => role == LessonTableRegion.cutoff,
        _ => false,
      };
    }

    Widget seatChip(int seat) {
      final role = roleOf(seat);
      final selected =
          selectedSeatIndex == seat ||
          (selectedSeatIndex == null && selectedRegion == role);
      return _PositionSeatChip(
        role: role,
        selected: selected,
        highlighted: pulseRole(role),
        enabled: enabled && _interactive,
        onTap: _interactive
            ? () => onRegionTap!(
                  LessonTableTapTarget(role, seatIndex: seat),
                )
            : null,
      );
    }

    return _feltShell(
      semanticsLabel: _interactive
          ? (n >= 9
              ? 'Interactive nine-handed table with position labels'
              : 'Interactive six-max table with position labels')
          : (n >= 9
              ? 'Nine-handed table showing UTG, mid, late, button, and blinds'
              : 'Six-max table showing EP, HJ, CO, button, and blinds'),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [for (final s in topRow) seatChip(s)],
          ),
          const SizedBox(height: 6),
          Text(
            scene.caption ?? 'EP · HJ · CO · BTN · SB · BB',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [for (final s in bottomRow) seatChip(s)],
          ),
          if (scene.showSeatNeverMatters) ...[
            const SizedBox(height: 8),
            _TappableRegion(
              label: 'Seat never matters',
              selected: selectedRegion == LessonTableRegion.seatNeverMatters,
              highlighted: false,
              enabled: enabled && _interactive,
              onTap: _interactive
                  ? () => onRegionTap!(
                        const LessonTableTapTarget(
                          LessonTableRegion.seatNeverMatters,
                        ),
                      )
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  'Seat never matters',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBlindsTiming() {
    Widget phase({
      required LessonTableRegion region,
      required String title,
      required String detail,
      required Widget visual,
    }) {
      final selected = selectedRegion == region;
      return Expanded(
        child: _TappableRegion(
          label: title,
          selected: selected,
          enabled: enabled && _interactive,
          onTap:
              _interactive
                  ? () => onRegionTap!(LessonTableTapTarget(region))
                  : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
            child: Column(
              children: [
                visual,
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _feltShell(
      semanticsLabel:
          _interactive
              ? 'Interactive hand timing — when blinds post'
              : 'Hand timing phases',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          phase(
            region: LessonTableRegion.beforeDeal,
            title: 'Before deal',
            detail: 'Blinds in',
            visual: const _BlindChipStack(amount: 2),
          ),
          const SizedBox(width: 6),
          phase(
            region: LessonTableRegion.afterFlop,
            title: 'After flop',
            detail: 'Board out',
            visual: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final code in const ['Qs', 'Jh', '2c']) ...[
                  MiniCard(
                    card: CardModel.fromCode(code),
                    size: MiniCardSize.tiny,
                  ),
                  const SizedBox(width: 2),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          phase(
            region: LessonTableRegion.showdown,
            title: 'Showdown',
            detail: 'Cards up',
            visual: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CardBack(size: MiniCardSize.tiny),
                SizedBox(width: 2),
                CardBack(size: MiniCardSize.tiny),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreetEndPhases() {
    Widget phase({
      required LessonTableRegion region,
      required String title,
      required String detail,
      required Widget visual,
    }) {
      final selected = selectedRegion == region;
      return Expanded(
        child: _TappableRegion(
          label: title,
          selected: selected,
          enabled: enabled && _interactive,
          onTap:
              _interactive
                  ? () => onRegionTap!(LessonTableTapTarget(region))
                  : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
            child: Column(
              children: [
                visual,
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _feltShell(
      semanticsLabel:
          _interactive
              ? 'Interactive street timing — when betting ends'
              : 'Street end phases',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          phase(
            region: LessonTableRegion.streetActionMatched,
            title: 'Bets matched',
            detail: 'Action equal',
            visual: const _BlindChipStack(amount: 3),
          ),
          const SizedBox(width: 6),
          phase(
            region: LessonTableRegion.streetFlopDealt,
            title: 'Flop appears',
            detail: 'Deal only',
            visual: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final code in const ['Qs', 'Jh', '2c']) ...[
                  MiniCard(
                    card: CardModel.fromCode(code),
                    size: MiniCardSize.tiny,
                  ),
                  const SizedBox(width: 2),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          phase(
            region: LessonTableRegion.streetSomeoneFolds,
            title: 'Someone folds',
            detail: 'Others act',
            visual: const Icon(
              Icons.person_off_outlined,
              color: AppColors.slate,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPotFoldWinOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive fold-win — tap how you take the pot',
      semanticsStatic: 'Fold-win outcomes',
      caption: scene.caption ?? 'You bet · everyone folds',
      phases: [
        (
          region: LessonTableRegion.potTakeQuiet,
          title: 'Take pot',
          detail: 'No show',
          visual: const Icon(
            Icons.savings_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.potMustShow,
          title: 'Must show',
          detail: 'Always',
          visual: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final code in const ['Ah', 'Kd']) ...[
                MiniCard(
                  card: CardModel.fromCode(code),
                  size: MiniCardSize.tiny,
                ),
                const SizedBox(width: 2),
              ],
            ],
          ),
        ),
        (
          region: LessonTableRegion.potDealerShows,
          title: 'Dealer shows',
          detail: 'Forced',
          visual: const Icon(
            Icons.visibility_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPotShowdownOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive showdown — tap what happens next',
      semanticsStatic: 'Showdown outcomes',
      caption: scene.caption ?? 'River · called',
      phases: [
        (
          region: LessonTableRegion.potShowdown,
          title: 'Showdown',
          detail: 'Best five',
          visual: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final code in const ['Ah', 'Qs']) ...[
                MiniCard(
                  card: CardModel.fromCode(code),
                  size: MiniCardSize.tiny,
                ),
                const SizedBox(width: 2),
              ],
            ],
          ),
        ),
        (
          region: LessonTableRegion.potLastBettor,
          title: 'Last bettor',
          detail: 'No show',
          visual: const Icon(
            Icons.gavel_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.potChopDefault,
          title: 'Always chop',
          detail: 'Split',
          visual: const Icon(
            Icons.call_split,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPotSideOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive side pot — tap what is true',
      semanticsStatic: 'Side pot outcomes',
      caption: scene.caption ?? 'You all-in short · others keep betting',
      phases: [
        (
          region: LessonTableRegion.potSideForms,
          title: 'Side pot',
          detail: 'Unmatched',
          visual: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PotChipDot(label: 'M', gold: true),
              SizedBox(width: 4),
              _PotChipDot(label: 'S', gold: false),
            ],
          ),
        ),
        (
          region: LessonTableRegion.potWinAll,
          title: 'Win all',
          detail: 'Later chips',
          visual: const Icon(
            Icons.all_inclusive,
            color: AppColors.slate,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.potHandDead,
          title: 'Hand dead',
          detail: 'Short out',
          visual: const Icon(
            Icons.block,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPotOpenSizeOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive pot size — tap the chip total',
      semanticsStatic: 'Open pot size outcomes',
      caption: scene.caption ?? '1/2 · BTN opens 6',
      phases: [
        (
          region: LessonTableRegion.potChipsSeven,
          title: '7 chips',
          detail: 'Miss a blind',
          visual: const _PotChipDot(label: '7', gold: false),
        ),
        (
          region: LessonTableRegion.potChipsNine,
          title: '9 chips',
          detail: '1+2+6',
          visual: const _PotChipDot(label: '9', gold: true),
        ),
        (
          region: LessonTableRegion.potChipsTwelve,
          title: '12 chips',
          detail: 'Too big',
          visual: const _PotChipDot(label: '12', gold: false),
        ),
      ],
    );
  }

  Widget _buildHabitCoverOutcomes() {
    final hero = scene.heroCodes.isEmpty
        ? const ['Ah', 'Kd']
        : scene.heroCodes.take(2).toList(growable: false);
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive live habit — tap cover and wait, act early, or leave bare',
      semanticsStatic: 'Live habit outcomes',
      caption: scene.caption ?? 'Full ring · action still left',
      phases: [
        (
          region: LessonTableRegion.habitCoverWait,
          title: 'Cover + wait',
          detail: 'Safe',
          visual: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < hero.length; i++) ...[
                    if (i > 0) const SizedBox(width: 2),
                    MiniCard(
                      card: CardModel.fromCode(hero[i]),
                      size: MiniCardSize.tiny,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.back_hand_outlined,
                color: AppColors.gold,
                size: 18,
              ),
            ],
          ),
        ),
        (
          region: LessonTableRegion.habitActEarly,
          title: 'Act early',
          detail: 'OOT',
          visual: const Icon(
            Icons.campaign_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.habitLeaveBare,
          title: 'Leave bare',
          detail: 'Flash',
          visual: const Icon(
            Icons.visibility_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildEffectiveStackOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive effective stack — tap the shorter stack',
      semanticsStatic: 'Effective stack outcomes',
      caption: scene.caption ?? 'You 120bb · Villain 55bb',
      phases: [
        (
          region: LessonTableRegion.effectiveStackShort,
          title: '55bb',
          detail: 'Shorter',
          visual: const _PotChipDot(label: '55', gold: true),
        ),
        (
          region: LessonTableRegion.effectiveStackHero,
          title: '120bb',
          detail: 'Your stack',
          visual: const _PotChipDot(label: '120', gold: false),
        ),
        (
          region: LessonTableRegion.effectiveStackSum,
          title: '175bb',
          detail: 'Added up',
          visual: const _PotChipDot(label: '175', gold: false),
        ),
      ],
    );
  }

  Widget _buildPotMultiwayOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive pot size — tap the chip total',
      semanticsStatic: 'Multiway pot size outcomes',
      caption: scene.caption ?? '1/2 · UTG opens · callers',
      phases: [
        (
          region: LessonTableRegion.potChipsEighteen,
          title: '18 chips',
          detail: 'Miss a blind',
          visual: const _PotChipDot(label: '18', gold: false),
        ),
        (
          region: LessonTableRegion.potChipsTwentyOne,
          title: '21 chips',
          detail: '1+2+6+6+6',
          visual: const _PotChipDot(label: '21', gold: true),
        ),
        (
          region: LessonTableRegion.potChipsTwelve,
          title: '12 chips',
          detail: 'Open only',
          visual: const _PotChipDot(label: '12', gold: false),
        ),
      ],
    );
  }

  Widget _buildCallPriceOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive call price — tap chips to call',
      semanticsStatic: 'Call price outcomes',
      caption: scene.caption ?? 'Pot 20 · villain bets 10',
      phases: [
        (
          region: LessonTableRegion.callChipsTwenty,
          title: '20 chips',
          detail: 'The pot',
          visual: const _PotChipDot(label: '20', gold: false),
        ),
        (
          region: LessonTableRegion.callChipsTen,
          title: '10 chips',
          detail: 'Match the bet',
          visual: const _PotChipDot(label: '10', gold: true),
        ),
        (
          region: LessonTableRegion.callChipsThirty,
          title: '30 chips',
          detail: 'After you call',
          visual: const _PotChipDot(label: '30', gold: false),
        ),
      ],
    );
  }

  Widget _buildDrawPriceOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive draw price — tap call, fold, or raise',
      semanticsStatic: 'Draw price outcomes',
      caption: scene.caption ?? 'Pot 20 · bet 10 · outs',
      phases: [
        (
          region: LessonTableRegion.drawPriceCall,
          title: 'Call',
          detail: 'Priced in',
          visual: const Icon(
            Icons.check_circle_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.drawPriceFold,
          title: 'Fold',
          detail: 'No made hand',
          visual: const Icon(
            Icons.cancel_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.drawPriceRaise,
          title: 'Raise',
          detail: 'Every draw',
          visual: const Icon(
            Icons.north_east,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildVerbalBindingOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive verbal action — tap whether the raise stands',
      semanticsStatic: 'Verbal declaration outcomes',
      caption: scene.caption ?? 'You said "raise"',
      phases: [
        (
          region: LessonTableRegion.verbalRaiseStands,
          title: 'Raise stands',
          detail: 'Binding',
          visual: const Icon(
            Icons.record_voice_over_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.verbalTakeback,
          title: 'Take back',
          detail: 'Call instead',
          visual: const Icon(
            Icons.undo,
            color: AppColors.slate,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.verbalDealerChoice,
          title: 'Dealer picks',
          detail: 'After cards',
          visual: const Icon(
            Icons.gavel_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTableReadMattersOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive table read — tap effective stack and pot',
      semanticsStatic: 'Table-read what matters outcomes',
      caption: scene.caption ?? 'Hero 140bb · Villain 55bb · pot 18',
      phases: [
        (
          region: LessonTableRegion.tableMatterEffAndPot,
          title: '55bb + pot',
          detail: 'Effective',
          visual: const _PotChipDot(label: '55', gold: true),
        ),
        (
          region: LessonTableRegion.tableMatterHeroOnly,
          title: '140bb only',
          detail: 'Your stack',
          visual: const _PotChipDot(label: '140', gold: false),
        ),
        (
          region: LessonTableRegion.tableMatterIgnorePot,
          title: 'Ignore pot',
          detail: 'Until river',
          visual: const Icon(
            Icons.visibility_off_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildObserveParticipationOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive observe — tap the participation note',
      semanticsStatic: 'Observe participation outcomes',
      caption: scene.caption ?? 'Seat calls 7 of 9 preflops',
      phases: [
        (
          region: LessonTableRegion.observeHighParticipation,
          title: 'High part.',
          detail: '7 of 9',
          visual: const _PotChipDot(label: '7/9', gold: true),
        ),
        (
          region: LessonTableRegion.observeLowParticipation,
          title: 'Low part.',
          detail: 'Rare pots',
          visual: const _PotChipDot(label: '2/9', gold: false),
        ),
        (
          region: LessonTableRegion.observeLabelNow,
          title: 'Label now',
          detail: 'Too soon',
          visual: const Icon(
            Icons.sell_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerTypeStationOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive player type — tap Calling Station or Nit',
      semanticsStatic: 'Calling Station vs Nit outcomes',
      caption: scene.caption ?? 'Called three streets · second pair',
      phases: [
        (
          region: LessonTableRegion.playerTypeStation,
          title: 'Station',
          detail: 'Sticky calls',
          visual: const Icon(
            Icons.people_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.playerTypeNit,
          title: 'Nit',
          detail: 'Overfolds',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLabelModelOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive label model — tap working model or permanent verdict',
      semanticsStatic: 'Label model outcomes',
      caption: scene.caption ?? 'Update the label as samples change',
      phases: [
        (
          region: LessonTableRegion.labelWorkingModel,
          title: 'Working model',
          detail: 'From evidence',
          visual: const Icon(
            Icons.science_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.labelPermanentSoul,
          title: 'Permanent',
          detail: 'Personality',
          visual: const Icon(
            Icons.psychology_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerTypeStationManiacOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive player type — tap Calling Station or Maniac',
      semanticsStatic: 'Calling Station vs Maniac outcomes',
      caption: scene.caption ?? 'Limps · calls raises · never folds turns',
      phases: [
        (
          region: LessonTableRegion.playerTypeStationLimp,
          title: 'Station',
          detail: 'Calls sticky',
          visual: const Icon(
            Icons.people_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.playerTypeManiac,
          title: 'Maniac',
          detail: 'Raises wild',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSampleConfidenceOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive sample confidence — tap low or maximum',
      semanticsStatic: 'Sample confidence outcomes',
      caption: scene.caption ?? 'Only 2 hands tagged so far',
      phases: [
        (
          region: LessonTableRegion.sampleConfidenceLow,
          title: 'Low',
          detail: 'Keep sampling',
          visual: const _PotChipDot(label: '2', gold: true),
        ),
        (
          region: LessonTableRegion.sampleConfidenceMax,
          title: 'Maximum',
          detail: 'Too sure',
          visual: const Icon(
            Icons.verified_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStationBluffCiteOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive bluff cite — tap why you bluff less',
      semanticsStatic: 'Station bluff cite outcomes',
      caption: scene.caption ?? 'Why cut bluffs vs a Calling Station?',
      phases: [
        (
          region: LessonTableRegion.citeRarelyFolds,
          title: 'Rarely folds',
          detail: 'Cite tendency',
          visual: const Icon(
            Icons.do_not_touch_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.citeLabelMean,
          title: 'Sounds mean',
          detail: 'Vibe only',
          visual: const Icon(
            Icons.mood_bad_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildObserveNarrowEntryOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive observe — tap narrow or wide entry',
      semanticsStatic: 'Narrow entry outcomes',
      caption: scene.caption ?? 'Folded 20 of 22 hands',
      phases: [
        (
          region: LessonTableRegion.observeNarrowEntry,
          title: 'Narrow',
          detail: '20 of 22 fold',
          visual: const _PotChipDot(label: '2', gold: true),
        ),
        (
          region: LessonTableRegion.observeWideEntry,
          title: 'Wide',
          detail: 'Many pots',
          visual: const _PotChipDot(label: '20', gold: false),
        ),
      ],
    );
  }

  Widget _buildObserveNarrowAggressionOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive observe — tap strong aggression or passive',
      semanticsStatic: 'Narrow aggression outcomes',
      caption: scene.caption ?? 'Finally raises · then barrels',
      phases: [
        (
          region: LessonTableRegion.observeStrongAggression,
          title: 'Strong heat',
          detail: 'When involved',
          visual: const Icon(
            Icons.whatshot_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.observePassiveCallers,
          title: 'Passive',
          detail: 'Just calls',
          visual: const Icon(
            Icons.pan_tool_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildObserveNarrowSampleOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive observe — tap wait or label now',
      semanticsStatic: 'Narrow sample outcomes',
      caption: scene.caption ?? 'Only two folds so far',
      phases: [
        (
          region: LessonTableRegion.observeWaitSamples,
          title: 'Wait',
          detail: 'Need samples',
          visual: const Icon(
            Icons.hourglass_empty,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.observeLabelNowThin,
          title: 'Label now',
          detail: 'Two folds',
          visual: const Icon(
            Icons.sell_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildObserveNarrowBundleOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive observe — tap the evidence bundle',
      semanticsStatic: 'Narrow bundle outcomes',
      caption: scene.caption ?? 'Bundle the pre-label notes',
      phases: [
        (
          region: LessonTableRegion.observeNitBundle,
          title: 'Few + heat',
          detail: 'Pre-label',
          visual: const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.observeStationBundle,
          title: 'Calls all',
          detail: 'Wrong note',
          visual: const Icon(
            Icons.call_received,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetNitVsStationOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive player type — tap Nit or Calling Station',
      semanticsStatic: 'Nit vs Calling Station outcomes',
      caption: scene.caption ?? '~8% hands · rare but large 3-bets',
      phases: [
        (
          region: LessonTableRegion.meetNitLabel,
          title: 'Nit',
          detail: 'Rare + strong',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetNitStationDistractor,
          title: 'Station',
          detail: 'Calls wide',
          visual: const Icon(
            Icons.people_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetNitVsManiacOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive player type — tap Nit or Maniac',
      semanticsStatic: 'Nit vs Maniac outcomes',
      caption: scene.caption ?? 'Folds forever · then check-raises a barrel',
      phases: [
        (
          region: LessonTableRegion.meetNitLabel2,
          title: 'Nit',
          detail: 'Narrow range',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetNitManiacDistractor,
          title: 'Maniac',
          detail: 'Always in',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetNitModelOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive label model — tap working model or insult',
      semanticsStatic: 'Nit model outcomes',
      caption: scene.caption ?? 'How to treat the Nit label',
      phases: [
        (
          region: LessonTableRegion.meetNitWorkingModel,
          title: 'Working model',
          detail: 'Sample limits',
          visual: const Icon(
            Icons.science_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetNitInsult,
          title: 'An insult',
          detail: 'Not technical',
          visual: const Icon(
            Icons.mood_bad_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildNitRespectCiteOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive nit respect — tap why you respect the check-raise',
      semanticsStatic: 'Nit respect cite outcomes',
      caption: scene.caption ?? 'Why respect a Nit check-raise?',
      phases: [
        (
          region: LessonTableRegion.citeNitStrongRange,
          title: 'Strong range',
          detail: 'When they raise',
          visual: const Icon(
            Icons.shield_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.citeNitFear,
          title: 'Scary vibe',
          detail: 'Not a cite',
          visual: const Icon(
            Icons.sentiment_very_dissatisfied_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildObserveWildEntryOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive observe — tap extreme entry or timid',
      semanticsStatic: 'Wild entry outcomes',
      caption: scene.caption ?? 'Raises or 3-bets 12 of 15 pots',
      phases: [
        (
          region: LessonTableRegion.observeExtremeEntry,
          title: 'Extreme',
          detail: '12 of 15 pots',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.observeNarrowTimid,
          title: 'Timid',
          detail: 'Few pots',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildObserveWildPressureOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive observe — tap wide pressure or never bets',
      semanticsStatic: 'Wild pressure outcomes',
      caption: scene.caption ?? 'Bets flop · turn · river · weak shows',
      phases: [
        (
          region: LessonTableRegion.observeWidePressure,
          title: 'Wide heat',
          detail: 'Barrels light',
          visual: const Icon(
            Icons.whatshot_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.observeNeverBets,
          title: 'Never bets',
          detail: 'Wrong note',
          visual: const Icon(
            Icons.pan_tool_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildObserveWildNotesOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive observe — tap calm notes or ego notes',
      semanticsStatic: 'Wild notes outcomes',
      caption: scene.caption ?? 'Best note style vs wild aggression',
      phases: [
        (
          region: LessonTableRegion.observeCalmNotes,
          title: 'Frequencies',
          detail: 'No ego story',
          visual: const Icon(
            Icons.edit_note_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.observeEgoNotes,
          title: 'Revenge',
          detail: 'Burns stacks',
          visual: const Icon(
            Icons.sentiment_very_dissatisfied_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildObserveWildBundleOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive observe — tap the evidence bundle',
      semanticsStatic: 'Wild bundle outcomes',
      caption: scene.caption ?? 'Bundle the pre-label notes',
      phases: [
        (
          region: LessonTableRegion.observeManiacBundle,
          title: 'Enter + barrel',
          detail: 'Pre-label',
          visual: const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.observeWildNitBundle,
          title: 'Never plays',
          detail: 'Nit note',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetManiacVsNitOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive player type — tap Maniac or Nit',
      semanticsStatic: 'Maniac vs Nit outcomes',
      caption: scene.caption ?? 'Opens 60% · triple-barrels light',
      phases: [
        (
          region: LessonTableRegion.meetManiacLabel,
          title: 'Maniac',
          detail: 'Extreme fire',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetManiacNitDistractor,
          title: 'Nit',
          detail: 'Rare entry',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetManiacVsStationOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive player type — tap Maniac or Calling Station',
      semanticsStatic: 'Maniac vs Station outcomes',
      caption: scene.caption ?? '3-bets light · never gives up rivers',
      phases: [
        (
          region: LessonTableRegion.meetManiacLabel2,
          title: 'Maniac',
          detail: 'Pressure wide',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetManiacStationDistractor,
          title: 'Station',
          detail: 'Calls wide',
          visual: const Icon(
            Icons.people_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetManiacMixOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive mix — tap introduced types or unlabeled seat',
      semanticsStatic: 'Maniac mix outcomes',
      caption: scene.caption ?? 'Which types are legal to mix now?',
      phases: [
        (
          region: LessonTableRegion.meetManiacMixThree,
          title: 'Three types',
          detail: 'Station · Nit · Maniac',
          visual: const Icon(
            Icons.groups_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetManiacMixEarly,
          title: 'Unlabeled',
          detail: 'Too early',
          visual: const Icon(
            Icons.person_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildManiacCallCiteOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive maniac cite — tap why you call wider',
      semanticsStatic: 'Maniac call cite outcomes',
      caption: scene.caption ?? 'Why call wider versus a Maniac?',
      phases: [
        (
          region: LessonTableRegion.citeManiacWideBet,
          title: 'Wide bets',
          detail: 'Too many hands',
          visual: const Icon(
            Icons.expand_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.citeManiacBrave,
          title: 'Prove brave',
          detail: 'Ego cite',
          visual: const Icon(
            Icons.sentiment_very_dissatisfied_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceOneNoteOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive confidence — tap one note or proven forever',
      semanticsStatic: 'Confidence one-note outcomes',
      caption: scene.caption ?? 'One huge bluff so far',
      phases: [
        (
          region: LessonTableRegion.confidenceOneNote,
          title: 'One note',
          detail: 'Low certainty',
          visual: const _PotChipDot(label: '1', gold: true),
        ),
        (
          region: LessonTableRegion.confidenceProvenForever,
          title: 'Proven',
          detail: 'Forever type',
          visual: const Icon(
            Icons.verified_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceRiseOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive confidence — tap rise or stay zero',
      semanticsStatic: 'Confidence rise outcomes',
      caption: scene.caption ?? '30 hands of sticky calls',
      phases: [
        (
          region: LessonTableRegion.confidenceRiseRevisable,
          title: 'Rise',
          detail: 'Still revisable',
          visual: const Icon(
            Icons.trending_up,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.confidenceStayZero,
          title: 'Stay zero',
          detail: 'Ignore samples',
          visual: const _PotChipDot(label: '0', gold: false),
        ),
      ],
    );
  }

  Widget _buildConfidenceUpdateOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive model — tap update or freeze forever',
      semanticsStatic: 'Confidence update outcomes',
      caption: scene.caption ?? "Former station starts folding streets",
      phases: [
        (
          region: LessonTableRegion.confidenceUpdateModel,
          title: 'Update',
          detail: 'Evidence flipped',
          visual: const Icon(
            Icons.sync_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.confidenceFreezeModel,
          title: 'Freeze',
          detail: 'Old label forever',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceLimitsOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive label UI — tap limits or destiny',
      semanticsStatic: 'Confidence limits outcomes',
      caption: scene.caption ?? 'What belongs beside a type label?',
      phases: [
        (
          region: LessonTableRegion.confidenceShowLimits,
          title: 'Limits',
          detail: 'Samples · confidence',
          visual: const Icon(
            Icons.rule_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.confidenceDestinyAura,
          title: 'Destiny',
          detail: 'Aura story',
          visual: const Icon(
            Icons.auto_awesome_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildJumpUtgRangeOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive jump — tap narrower or any two',
      semanticsStatic: 'UTG range jump outcomes',
      caption: scene.caption ?? 'UTG open — describe the range',
      phases: [
        (
          region: LessonTableRegion.jumpUtgNarrower,
          title: 'Narrower',
          detail: 'Stronger UTG',
          visual: const Icon(
            Icons.filter_list,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.jumpUtgAnyTwo,
          title: 'Any two',
          detail: 'Too wide',
          visual: const Icon(
            Icons.all_inclusive,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildJumpStationExploitOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive jump — tap station value or bluff more',
      semanticsStatic: 'Station jump exploit outcomes',
      caption: scene.caption ?? 'Sticky caller three streets',
      phases: [
        (
          region: LessonTableRegion.jumpStationValue,
          title: 'Value more',
          detail: 'Bluff less',
          visual: const Icon(
            Icons.savings_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.jumpStationBluff,
          title: 'Bluff more',
          detail: 'Wrong exploit',
          visual: const Icon(
            Icons.whatshot_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildJumpNitExploitOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive jump — tap respect heat or bluff-catch light',
      semanticsStatic: 'Nit jump exploit outcomes',
      caption: scene.caption ?? 'Tiny range · huge check-raise',
      phases: [
        (
          region: LessonTableRegion.jumpNitRespect,
          title: 'Respect',
          detail: 'Steal elsewhere',
          visual: const Icon(
            Icons.shield_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.jumpNitBluffCatch,
          title: 'Catch light',
          detail: 'Wrong vs heat',
          visual: const Icon(
            Icons.pan_tool_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildJumpManiacExploitOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive jump — tap call wider or fold all one-pair',
      semanticsStatic: 'Maniac jump exploit outcomes',
      caption: scene.caption ?? 'Barrels forever · you have top pair',
      phases: [
        (
          region: LessonTableRegion.jumpManiacCall,
          title: 'Call wider',
          detail: 'No ego raise',
          visual: const Icon(
            Icons.handshake_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.jumpManiacFoldAll,
          title: 'Fold all',
          detail: 'Too tight',
          visual: const Icon(
            Icons.block,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiwayContinueOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive multiway — tap nut flush draw, weak draw, or air',
      semanticsStatic: 'Multiway continue outcomes',
      caption: scene.caption ?? 'Four-way flop — best continue',
      phases: [
        (
          region: LessonTableRegion.multiwayNutFd,
          title: 'Nut FD',
          detail: 'Best equity',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.multiwayWeakFd,
          title: 'Weak FD',
          detail: 'Dominated',
          visual: const Icon(
            Icons.water_drop_outlined,
            color: AppColors.cream,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.multiwayAirStab,
          title: 'Air stab',
          detail: 'Crowds punish',
          visual: const Icon(
            Icons.air,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiwayPriorityOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive multiway — tap nut potential or any two',
      semanticsStatic: 'Multiway priority outcomes',
      caption: scene.caption ?? 'Multiway construction priority',
      phases: [
        (
          region: LessonTableRegion.multiwayNutsPriority,
          title: 'Nut potential',
          detail: 'Clean equity',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.multiwayAnyTwo,
          title: 'Any two',
          detail: 'Crowds punish',
          visual: const Icon(
            Icons.all_inclusive,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDeepImpliedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive deep stacks — tap why you call with 55',
      semanticsStatic: 'Deep implied outcomes',
      caption: scene.caption ?? '200bb · why call a raise with 55?',
      phases: [
        (
          region: LessonTableRegion.deepImpliedOdds,
          title: 'Implied',
          detail: 'They pay sets',
          visual: const Icon(
            Icons.trending_up,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.deepSprLow,
          title: 'Low SPR',
          detail: 'Wrong thesis',
          visual: const _PotChipDot(label: '1', gold: false),
        ),
        (
          region: LessonTableRegion.deepBluffEvery,
          title: 'Bluff all',
          detail: 'Not the thesis',
          visual: const Icon(
            Icons.whatshot_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDeepPlanOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive deep stacks — tap map plans or jam now',
      semanticsStatic: 'Deep plan outcomes',
      caption: scene.caption ?? 'SPR ~12 on the flop',
      phases: [
        (
          region: LessonTableRegion.deepMapPlans,
          title: 'Map streets',
          detail: 'Before commit',
          visual: const Icon(
            Icons.map_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.deepJamNow,
          title: 'Jam now',
          detail: 'Too early',
          visual: const Icon(
            Icons.flash_on,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDeepRewardsOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive deep stacks — tap what depth rewards',
      semanticsStatic: 'Deep rewards outcomes',
      caption: scene.caption ?? '150–300bb cash play rewards?',
      phases: [
        (
          region: LessonTableRegion.deepRewardsPos,
          title: 'Skill edges',
          detail: 'Pos · odds · folds',
          visual: const Icon(
            Icons.psychology_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.deepRewardsSpew,
          title: 'Light stacks',
          detail: 'Automatic',
          visual: const Icon(
            Icons.dangerous_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildImpliedOddsRiseOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive implied odds — tap when implied odds rise most',
      semanticsStatic: 'Implied odds rise outcomes',
      caption: scene.caption ?? 'When do implied odds rise most?',
      phases: [
        (
          region: LessonTableRegion.ioDepthPay,
          title: 'Depth + pay',
          detail: 'They call off',
          visual: const Icon(
            Icons.trending_up,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.ioShortAlways,
          title: 'Short always',
          detail: 'Cuts future',
          visual: const Icon(
            Icons.trending_down,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildThinValueReadOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive thin value — tap what must change with the type',
      semanticsStatic: 'Thin value read outcomes',
      caption: scene.caption ?? 'Same hand, different types — what changes?',
      phases: [
        (
          region: LessonTableRegion.thinValueReadLine,
          title: 'The line',
          detail: 'When the read fits',
          visual: const Icon(
            Icons.alt_route,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.thinValueFlipCoin,
          title: 'Coin flip',
          detail: 'Not strategy',
          visual: const Icon(
            Icons.casino_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLinesNitXrOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive lines — tap Nit check-raise default read',
      semanticsStatic: 'Lines Nit XR outcomes',
      caption: scene.caption ?? 'Nit check-raises flop — default read?',
      phases: [
        (
          region: LessonTableRegion.linesNitValueHeavy,
          title: 'Value-heavy',
          detail: 'Respect',
          visual: const Icon(
            Icons.shield_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.linesNitAlwaysBluff,
          title: 'Always bluff',
          detail: 'Wrong type',
          visual: const Icon(
            Icons.air,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLinesDonkPolarOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive lines — tap what a large donk means',
      semanticsStatic: 'Lines donk polar outcomes',
      caption: scene.caption ?? 'Large BB donk on dry ace — meaning?',
      phases: [
        (
          region: LessonTableRegion.linesDonkPolar,
          title: 'Polarized',
          detail: 'Ace or air',
          visual: const Icon(
            Icons.compare_arrows,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.linesDonkMerged,
          title: 'Medium pairs',
          detail: 'Less common',
          visual: const Icon(
            Icons.linear_scale,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLinesDelayOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive lines — tap when delayed c-bet is best',
      semanticsStatic: 'Lines delay outcomes',
      caption: scene.caption ?? 'Delayed c-bet is best when?',
      phases: [
        (
          region: LessonTableRegion.linesDelayAfterWeak,
          title: 'After weakness',
          detail: 'Flop check caps them',
          visual: const Icon(
            Icons.schedule,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.linesDelayAlways,
          title: 'Every hand',
          detail: 'Need a reason',
          visual: const Icon(
            Icons.all_inclusive,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLineReadCappedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive line reading — tap capped vs still nuts',
      semanticsStatic: 'Line reading capped outcomes',
      caption: scene.caption ?? 'Bet flop, check turn — range now?',
      phases: [
        (
          region: LessonTableRegion.lineReadCapped,
          title: 'Fewer nuts',
          detail: 'Check-back caps',
          visual: const Icon(
            Icons.vertical_align_bottom,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.lineReadStillNuts,
          title: 'Still nuts',
          detail: 'Wrong story',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLineReadRebuildOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive line reading — tap rebuild vs lock flop',
      semanticsStatic: 'Line reading rebuild outcomes',
      caption: scene.caption ?? 'Best line-reading habit?',
      phases: [
        (
          region: LessonTableRegion.lineReadRebuild,
          title: 'Rebuild',
          detail: 'Every action',
          visual: const Icon(
            Icons.refresh,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.lineReadLockFlop,
          title: 'Lock flop',
          detail: 'Stale story',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLineReadUncappedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive line reading — tap uncapped vs always bluff',
      semanticsStatic: 'Line reading uncapped outcomes',
      caption: scene.caption ?? 'XR / bet / shove usually means?',
      phases: [
        (
          region: LessonTableRegion.lineReadUncapped,
          title: 'Uncapped',
          detail: 'Respect',
          visual: const Icon(
            Icons.trending_up,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.lineReadAlwaysBluff,
          title: 'Always bluff',
          detail: 'Too absolute',
          visual: const Icon(
            Icons.air,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTimingSoftEvidenceOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive timing evidence — tap soft evidence, proven nuts, or proven bluff',
      semanticsStatic: 'Timing soft evidence outcomes',
      caption: scene.caption ?? 'Instant river shove — framing?',
      phases: [
        (
          region: LessonTableRegion.timingSoftEvidence,
          title: 'Soft evidence',
          detail: 'Slight bump',
          visual: const Icon(
            Icons.tune,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.timingProvenNuts,
          title: 'Proven nuts',
          detail: 'Overclaim',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.timingProvenBluff,
          title: 'Proven bluff',
          detail: 'Overclaim',
          visual: const Icon(
            Icons.air,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTimingSizingWeakOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive timing sizing — tap weaker/blocking vs solver known',
      semanticsStatic: 'Timing sizing weak outcomes',
      caption: scene.caption ?? 'Tiny flop bet into huge pot?',
      phases: [
        (
          region: LessonTableRegion.timingWeakerBlocking,
          title: 'Weaker / blocking',
          detail: 'Not proof',
          visual: const Icon(
            Icons.compress,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.timingSolverKnown,
          title: 'Solver known',
          detail: 'Fabricated',
          visual: const Icon(
            Icons.precision_manufacturing_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTimingRejectMagicOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive timing tells — tap reject magic vs trust book',
      semanticsStatic: 'Timing reject magic outcomes',
      caption: scene.caption ?? 'Look-left means bluff?',
      phases: [
        (
          region: LessonTableRegion.timingRejectMagic,
          title: 'Reject',
          detail: 'No magic tells',
          visual: const Icon(
            Icons.block,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.timingTrustBook,
          title: 'Trust book',
          detail: 'Out of scope',
          visual: const Icon(
            Icons.menu_book_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTimingTinyUpdateOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive timing use — tap tiny update vs only evidence',
      semanticsStatic: 'Timing tiny update outcomes',
      caption: scene.caption ?? 'Best use of live timing?',
      phases: [
        (
          region: LessonTableRegion.timingTinyUpdate,
          title: 'Tiny update',
          detail: 'Beside stronger',
          visual: const Icon(
            Icons.stacked_line_chart,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.timingOnlyEvidence,
          title: 'Only evidence',
          detail: 'Too weak',
          visual: const Icon(
            Icons.filter_1_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicsStuckOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive table dynamics — tap stuck/tilted vs ignore',
      semanticsStatic: 'Table dynamics stuck outcomes',
      caption: scene.caption ?? 'Lost two buy-ins — note?',
      phases: [
        (
          region: LessonTableRegion.dynamicsStuckTilted,
          title: 'Stuck / tilted',
          detail: 'Widen value',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.dynamicsIgnore,
          title: 'Ignore',
          detail: 'Miss evidence',
          visual: const Icon(
            Icons.visibility_off_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicsGearOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive table dynamics — tap gear change vs old label',
      semanticsStatic: 'Table dynamics gear outcomes',
      caption: scene.caption ?? 'Solid player flats junk / donks?',
      phases: [
        (
          region: LessonTableRegion.dynamicsGearChange,
          title: 'Gear change',
          detail: 'Resample',
          visual: const Icon(
            Icons.settings_suggest_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.dynamicsOldLabel,
          title: 'Old label',
          detail: 'Stale model',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicsFreshOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive table dynamics — tap fresh samples vs permanent seats',
      semanticsStatic: 'Table dynamics fresh outcomes',
      caption: scene.caption ?? 'Dynamic reads should be?',
      phases: [
        (
          region: LessonTableRegion.dynamicsFreshSamples,
          title: 'Fresh samples',
          detail: 'Update often',
          visual: const Icon(
            Icons.refresh,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.dynamicsPermanentSeats,
          title: 'Permanent seats',
          detail: 'Too rigid',
          visual: const Icon(
            Icons.push_pin_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDisciplineStopOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive session guardrails — tap stop vs reload',
      semanticsStatic: 'Session discipline stop outcomes',
      caption: scene.caption ?? 'Hit planned stop-loss — next?',
      phases: [
        (
          region: LessonTableRegion.disciplineStop,
          title: 'Stop / move down',
          detail: 'Plans beat feelings',
          visual: const Icon(
            Icons.front_hand_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.disciplineReload,
          title: 'Reload / chase',
          detail: 'Bankroll leak',
          visual: const Icon(
            Icons.replay,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDisciplineStakesOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive session guardrails — tap decline vs jump',
      semanticsStatic: 'Session discipline stakes outcomes',
      caption: scene.caption ?? '40 BI for 1/2 — 2/5 opens?',
      phases: [
        (
          region: LessonTableRegion.disciplineDecline,
          title: 'Decline',
          detail: 'Outside the plan',
          visual: const Icon(
            Icons.block,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.disciplineJump,
          title: 'Jump up',
          detail: 'Risk of ruin',
          visual: const Icon(
            Icons.trending_up,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDisciplineCashOutOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive session guardrails — tap cash out vs stay',
      semanticsStatic: 'Session discipline cash-out outcomes',
      caption: scene.caption ?? 'Tired, up small, table wild?',
      phases: [
        (
          region: LessonTableRegion.disciplineCashOut,
          title: 'Cash out',
          detail: 'Fatigue is a leak',
          visual: const Icon(
            Icons.logout,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.disciplineStay,
          title: 'Stay forever',
          detail: 'Only if sharp',
          visual: const Icon(
            Icons.nightlight_round,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDisciplineEdgeOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive session guardrails — tap your edge vs soft skills',
      semanticsStatic: 'Session discipline edge outcomes',
      caption: scene.caption ?? 'Session discipline is part of?',
      phases: [
        (
          region: LessonTableRegion.disciplineEdge,
          title: 'Your edge',
          detail: 'Same as technical skill',
          visual: const Icon(
            Icons.emoji_events_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.disciplineSoftOnly,
          title: 'Soft skills only',
          detail: 'Not optional',
          visual: const Icon(
            Icons.spa_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildS5CpMultiOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive S5 exit — tap nut potential vs bluff more',
      semanticsStatic: 'S5 exit multiway outcomes',
      caption: scene.caption ?? 'Four-way pot priority?',
      phases: [
        (
          region: LessonTableRegion.multiwayNutsPriority,
          title: 'Nut potential',
          detail: 'Over weak bluffs',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.s5CpBluffMore,
          title: 'Bluff more',
          detail: 'Crowds punish',
          visual: const Icon(
            Icons.air,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildS5CpTellOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive S5 exit — tap soft evidence vs absolute nuts',
      semanticsStatic: 'S5 exit tell outcomes',
      caption: scene.caption ?? 'Instant shove proves?',
      phases: [
        (
          region: LessonTableRegion.timingSoftEvidence,
          title: 'Soft evidence',
          detail: 'Nothing absolute',
          visual: const Icon(
            Icons.tune,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.s5CpAbsoluteNuts,
          title: 'Absolute nuts',
          detail: 'Overclaim',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildS5CpStopOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive S5 exit — tap honor stop vs chase',
      semanticsStatic: 'S5 exit stop-loss outcomes',
      caption: scene.caption ?? 'Hit stop-loss — do?',
      phases: [
        (
          region: LessonTableRegion.disciplineStop,
          title: 'Honor stop',
          detail: 'Guardrails',
          visual: const Icon(
            Icons.front_hand_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.s5CpChase,
          title: 'Chase',
          detail: 'Bankroll leak',
          visual: const Icon(
            Icons.replay,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildRangeAdvPfrOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive range advantage — tap PFR vs flatting BB',
      semanticsStatic: 'Range advantage PFR outcomes',
      caption: scene.caption ?? 'A-high dry flop — range advantage?',
      phases: [
        (
          region: LessonTableRegion.rangeAdvPfr,
          title: 'Preflop raiser',
          detail: 'Owns strong hands',
          visual: const Icon(
            Icons.north_east,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.rangeAdvCaller,
          title: 'Flatting BB',
          detail: 'Usually not',
          visual: const Icon(
            Icons.south_west,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildRangeAdvNutsOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive nut advantage — tap wide caller vs PFR always',
      semanticsStatic: 'Nut advantage outcomes',
      caption: scene.caption ?? 'Paired board — nut advantage?',
      phases: [
        (
          region: LessonTableRegion.rangeAdvWideCaller,
          title: 'Wide caller',
          detail: 'More trips / fulls',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.rangeAdvPfrAlways,
          title: 'PFR always',
          detail: 'Paired boards flip',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildRangeAdvPressOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive range advantage — tap apply pressure vs bet any two',
      semanticsStatic: 'Range advantage pressure outcomes',
      caption: scene.caption ?? 'Advantage is a reason to?',
      phases: [
        (
          region: LessonTableRegion.rangeAdvPress,
          title: 'Apply pressure',
          detail: 'With a turn plan',
          visual: const Icon(
            Icons.bolt,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.rangeAdvBetAnyTwo,
          title: 'Bet any two',
          detail: 'Still need a plan',
          visual: const Icon(
            Icons.casino_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildEqRealizeIpOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive equity realization — tap in position vs out of position',
      semanticsStatic: 'Equity realization IP outcomes',
      caption: scene.caption ?? 'Same draw OOP vs IP — better where?',
      phases: [
        (
          region: LessonTableRegion.eqRealizeIp,
          title: 'In position',
          detail: 'Realize better',
          visual: const Icon(
            Icons.chair_alt,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.eqRealizeOop,
          title: 'Out of position',
          detail: 'Realizes worse',
          visual: const Icon(
            Icons.event_seat_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildEqRealizeDiscountOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive equity realization — tap discount vs hero-call',
      semanticsStatic: 'Equity realization discount outcomes',
      caption: scene.caption ?? 'Weak SDV OOP vs dual barrels?',
      phases: [
        (
          region: LessonTableRegion.eqRealizeDiscount,
          title: 'Discount / fold',
          detail: 'OOP one-pair dies',
          visual: const Icon(
            Icons.trending_down,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.eqRealizeHero,
          title: 'Hero-call',
          detail: 'Over-realize fantasy',
          visual: const Icon(
            Icons.volunteer_activism_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildEqRealizeAggressionOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive equity realization — tap fold equity vs fancy play',
      semanticsStatic: 'Equity realization aggression outcomes',
      caption: scene.caption ?? 'Semi-bluff XR purpose?',
      phases: [
        (
          region: LessonTableRegion.eqRealizeFoldEq,
          title: 'Fold equity',
          detail: 'Deny cheap cards',
          visual: const Icon(
            Icons.flash_on,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.eqRealizeFancy,
          title: 'Fancy play',
          detail: 'Need a reason',
          visual: const Icon(
            Icons.auto_awesome_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildEqRealizePosOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive equity realization — tap position+initiative vs hope',
      semanticsStatic: 'Equity realization position outcomes',
      caption: scene.caption ?? 'Equity realization rises with?',
      phases: [
        (
          region: LessonTableRegion.eqRealizePosInit,
          title: 'Position + initiative',
          detail: 'Core levers',
          visual: const Icon(
            Icons.insights,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.eqRealizeHope,
          title: 'Hope alone',
          detail: 'Not a plan',
          visual: const Icon(
            Icons.help_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildCappedGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive capped ranges — tap capped vs uncapped',
      semanticsStatic: 'Capped range guided outcomes',
      caption: scene.caption ?? 'Checks turn after flop bet — often?',
      phases: [
        (
          region: LessonTableRegion.cappedCheckTurn,
          title: 'Capped',
          detail: 'Fewer nuts',
          visual: const Icon(
            Icons.vertical_align_bottom,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.cappedStillNuts,
          title: 'Uncapped',
          detail: 'Wrong story',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildCappedUncappedLineOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive uncapped lines — tap uncapped vs capped air',
      semanticsStatic: 'Uncapped line outcomes',
      caption: scene.caption ?? 'XR flop, bet turn, bomb river?',
      phases: [
        (
          region: LessonTableRegion.uncappedXrLine,
          title: 'Uncapped',
          detail: 'Nuts still live',
          visual: const Icon(
            Icons.local_fire_department,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.cappedAirOnly,
          title: 'Capped air',
          detail: 'Wrong read',
          visual: const Icon(
            Icons.air,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildCappedAttackOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive capped ranges — tap attack caps vs auto-fold',
      semanticsStatic: 'Capped attack outcomes',
      caption: scene.caption ?? 'Caps are for?',
      phases: [
        (
          region: LessonTableRegion.capsAttack,
          title: 'Attack caps',
          detail: 'Thin value + bluffs',
          visual: const Icon(
            Icons.bolt,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.capsAutoFold,
          title: 'Auto-fold',
          detail: 'Opposite exploit',
          visual: const Icon(
            Icons.do_not_disturb_on_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPolarGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive polar vs merged — tap polarized vs merged',
      semanticsStatic: 'Polar merged guided outcomes',
      caption: scene.caption ?? 'River overbet usually wants?',
      phases: [
        (
          region: LessonTableRegion.polarShape,
          title: 'Polarized',
          detail: 'Value or bluff',
          visual: const Icon(
            Icons.swap_vert,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.mergedShape,
          title: 'Merged',
          detail: 'Thin value only',
          visual: const Icon(
            Icons.horizontal_rule,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPolarMismatchOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive polar mismatches — tap tiny bluffs vs any size',
      semanticsStatic: 'Polar mismatch outcomes',
      caption: scene.caption ?? 'Mismatch to avoid?',
      phases: [
        (
          region: LessonTableRegion.polarTinyBluffs,
          title: 'Tiny bluffs',
          detail: 'Never get folds',
          visual: const Icon(
            Icons.warning_amber_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.polarAnySize,
          title: 'Any size',
          detail: 'Always fine?',
          visual: const Icon(
            Icons.all_inclusive,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPolarAimOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive merged aims — tap thin value vs only nuts',
      semanticsStatic: 'Polar merged aim outcomes',
      caption: scene.caption ?? 'Merged betting aims to?',
      phases: [
        (
          region: LessonTableRegion.polarThinValue,
          title: 'Thin value',
          detail: 'Extract from worse',
          visual: const Icon(
            Icons.trending_up,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.polarOnlyNuts,
          title: 'Only nuts',
          detail: 'Too polar',
          visual: const Icon(
            Icons.diamond_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildOverbetGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive overbet candidates — tap nuts/bluffs vs top pair weak',
      semanticsStatic: 'Overbet guided outcomes',
      caption: scene.caption ?? 'Best overbet river candidate?',
      phases: [
        (
          region: LessonTableRegion.overbetNutsBluffs,
          title: 'Nuts / bluffs',
          detail: 'Polar story',
          visual: const Icon(
            Icons.swap_vert,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.overbetTopPairWeak,
          title: 'Top pair weak',
          detail: 'Wrong size',
          visual: const Icon(
            Icons.horizontal_rule,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildOverbetAvoidOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive overbet discipline — tap avoid vs always fine',
      semanticsStatic: 'Overbet avoid outcomes',
      caption: scene.caption ?? 'Random 3x pot medium?',
      phases: [
        (
          region: LessonTableRegion.overbetAvoid,
          title: 'Avoid',
          detail: 'Needs a story',
          visual: const Icon(
            Icons.block,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.overbetAlwaysFine,
          title: 'Always fine',
          detail: 'Leaks stacks',
          visual: const Icon(
            Icons.all_inclusive,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildOverbetPlanOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive geometric aims — tap multi-street plan vs look flashy',
      semanticsStatic: 'Overbet plan outcomes',
      caption: scene.caption ?? 'Geometric sizing primarily helps?',
      phases: [
        (
          region: LessonTableRegion.overbetMultiStreet,
          title: 'Multi-street plan',
          detail: 'Link streets',
          visual: const Icon(
            Icons.account_tree_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.overbetLookFlashy,
          title: 'Look flashy',
          detail: 'Not the goal',
          visual: const Icon(
            Icons.auto_awesome,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBlockersGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive blockers — tap Ace blocker, no blockers, or fake +EV',
      semanticsStatic: 'Blockers guided outcomes',
      caption: scene.caption ?? 'River bluff on flush board — better blocker?',
      phases: [
        (
          region: LessonTableRegion.blockersAce,
          title: 'Ace blocker',
          detail: 'Blocks nut flush',
          visual: MiniCard(
            card: CardModel.fromCode('Ah'),
            size: MiniCardSize.tiny,
          ),
        ),
        (
          region: LessonTableRegion.blockersNone,
          title: 'No blockers',
          detail: 'Worse bluff',
          visual: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MiniCard(
                card: CardModel.fromCode('7c'),
                size: MiniCardSize.tiny,
              ),
              const SizedBox(width: 2),
              MiniCard(
                card: CardModel.fromCode('2d'),
                size: MiniCardSize.tiny,
              ),
            ],
          ),
        ),
        (
          region: LessonTableRegion.blockersFakeEv,
          title: 'Fake +EV',
          detail: 'No decimals',
          visual: const Icon(
            Icons.calculate_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBlockersUnblockOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive bluff-catch blockers — tap unblock bluffs vs block their air',
      semanticsStatic: 'Blockers unblock outcomes',
      caption: scene.caption ?? 'Bluff-catching a river bomb — prefer?',
      phases: [
        (
          region: LessonTableRegion.blockersUnblock,
          title: 'Unblock bluffs',
          detail: 'Keep their air',
          visual: const Icon(
            Icons.lock_open_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.blockersBlockAir,
          title: 'Block their air',
          detail: 'Opposite',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBlockersTweakOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive blocker role — tap tweak evidence vs replace all reasoning',
      semanticsStatic: 'Blockers tweak outcomes',
      caption: scene.caption ?? 'Blockers replace?',
      phases: [
        (
          region: LessonTableRegion.blockersTweak,
          title: 'Tweak evidence',
          detail: 'Not a wand',
          visual: const Icon(
            Icons.tune,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.blockersReplace,
          title: 'Replace all reasoning',
          detail: 'Too narrow',
          visual: const Icon(
            Icons.auto_fix_high,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBlockersEvOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive solver EV stance — tap no fake EV vs invent EVs',
      semanticsStatic: 'Blockers EV outcomes',
      caption: scene.caption ?? 'Course stance on solver EV quotes?',
      phases: [
        (
          region: LessonTableRegion.blockersNoFakeEv,
          title: 'No fake EV',
          detail: 'Decision-linked',
          visual: const Icon(
            Icons.verified_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.blockersInventEv,
          title: 'Invent EVs',
          detail: 'Forbidden',
          visual: const Icon(
            Icons.sentiment_very_dissatisfied_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDefendGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive min-defense continues — tap strong catchers vs any two for %',
      semanticsStatic: 'Defend guided outcomes',
      caption: scene.caption ?? 'Facing a river bet. Best continue?',
      phases: [
        (
          region: LessonTableRegion.defendStrongCatchers,
          title: 'Strong catchers',
          detail: 'Quality over quota',
          visual: const Icon(
            Icons.shield_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.defendAnyTwoPct,
          title: 'Any two for %',
          detail: 'Frequency theater',
          visual: const Icon(
            Icons.percent,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDefendIntuitionOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive MDF stance — tap intuition vs exact percents',
      semanticsStatic: 'Defend intuition outcomes',
      caption: scene.caption ?? 'MDF numbers in this course?',
      phases: [
        (
          region: LessonTableRegion.defendIntuition,
          title: 'Intuition',
          detail: 'Decision-linked',
          visual: const Icon(
            Icons.psychology_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.defendExactPercents,
          title: 'Exact percents',
          detail: 'Not our method',
          visual: const Icon(
            Icons.calculate_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDefendPunishOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive min-defense goal — tap punish over-bluffs vs never fold',
      semanticsStatic: 'Defend punish outcomes',
      caption: scene.caption ?? 'Minimum defense goal?',
      phases: [
        (
          region: LessonTableRegion.defendPunishOverbluffs,
          title: 'Punish over-bluffs',
          detail: 'Sensible continues',
          visual: const Icon(
            Icons.gavel_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.defendNeverFold,
          title: 'Never fold',
          detail: 'Too wide',
          visual: const Icon(
            Icons.all_inclusive,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMixStationOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive station mix — tap less bluff vs same mix',
      semanticsStatic: 'Mix station outcomes',
      caption:
          scene.caption ?? 'Versus a Calling Station, how much bluff-mixing?',
      phases: [
        (
          region: LessonTableRegion.mixLessBluff,
          title: 'Less bluff',
          detail: 'Value heavier',
          visual: const Icon(
            Icons.trending_down,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.mixSameAlways,
          title: 'Same mix',
          detail: 'Ignore type',
          visual: const Icon(
            Icons.sync_alt,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMixReasonOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive mix reason — tap need a reason vs always random',
      semanticsStatic: 'Mix reason outcomes',
      caption: scene.caption ?? 'Randomness for its own sake?',
      phases: [
        (
          region: LessonTableRegion.mixNeedReason,
          title: 'Need a reason',
          detail: 'Frequency ≠ chaos',
          visual: const Icon(
            Icons.lightbulb_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.mixAlwaysRandom,
          title: 'Always random',
          detail: 'Coin-flip theater',
          visual: const Icon(
            Icons.casino_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMixPurposeOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive mix description — tap purpose freq vs chaos',
      semanticsStatic: 'Mix purpose outcomes',
      caption: scene.caption ?? 'Best mix description?',
      phases: [
        (
          region: LessonTableRegion.mixPurposeFreq,
          title: 'Purpose freq',
          detail: 'Course standard',
          visual: const Icon(
            Icons.balance_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.mixChaos,
          title: 'Chaos',
          detail: 'Not a lifestyle',
          visual: const Icon(
            Icons.shuffle,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildThreeBetCommitOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive 4-bet mindset — tap high commit vs 300bb deep',
      semanticsStatic: '3-bet commit outcomes',
      caption:
          scene.caption ?? '100bb 4-bet pot. Flop top pair. Default mindset?',
      phases: [
        (
          region: LessonTableRegion.threeBetHighCommit,
          title: 'High commit',
          detail: 'SPR is low',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.threeBetPlayDeep,
          title: '300bb deep',
          detail: 'Wrong depth',
          visual: const Icon(
            Icons.layers_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildThreeBetEgoOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive ego 4-bet — tap avoid ego vs ego 4-bet',
      semanticsStatic: '3-bet ego outcomes',
      caption:
          scene.caption ?? 'Light 4-bet bluff with no blockers for ego?',
      phases: [
        (
          region: LessonTableRegion.threeBetAvoidEgo,
          title: 'Avoid ego',
          detail: 'Need blockers',
          visual: const Icon(
            Icons.block,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.threeBetEgoFourBet,
          title: 'Ego 4-bet',
          detail: 'Style leak',
          visual: const Icon(
            Icons.flash_on_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildThreeBetSprOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive depth change — tap SPR / commit vs felt suits',
      semanticsStatic: '3-bet SPR outcomes',
      caption:
          scene.caption ?? 'Depth change in 3-bet pots mainly changes?',
      phases: [
        (
          region: LessonTableRegion.threeBetSprCommit,
          title: 'SPR / commit',
          detail: 'Core lever',
          visual: const Icon(
            Icons.straighten,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.threeBetFeltSuits,
          title: 'Felt suits',
          detail: 'Irrelevant',
          visual: const Icon(
            Icons.palette_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildHardFoldCoolerOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive cooler review — tap cooler vs fold KK',
      semanticsStatic: 'Hard-fold cooler outcomes',
      caption:
          scene.caption ?? 'KK loses to AA all-in pre. Review label?',
      phases: [
        (
          region: LessonTableRegion.hardFoldCoolerOk,
          title: 'Cooler',
          detail: 'Not a leak',
          visual: const Icon(
            Icons.ac_unit,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.hardFoldFoldKk,
          title: 'Fold KK',
          detail: 'Wrong review',
          visual: const Icon(
            Icons.warning_amber_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildHardFoldEgoOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive due call — tap ego call vs sound play',
      semanticsStatic: 'Hard-fold ego outcomes',
      caption: scene.caption ?? 'Calling because you are "due"?',
      phases: [
        (
          region: LessonTableRegion.hardFoldEgoCall,
          title: 'Ego call',
          detail: 'Due ≠ reason',
          visual: const Icon(
            Icons.psychology_alt_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.hardFoldSoundPlay,
          title: 'Sound play',
          detail: 'Not sound',
          visual: const Icon(
            Icons.check_circle_outline,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildHardFoldReviewOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive big-loss review — tap cooler / mistake? vs tilt harder',
      semanticsStatic: 'Hard-fold review outcomes',
      caption: scene.caption ?? 'Review question after a big loss?',
      phases: [
        (
          region: LessonTableRegion.hardFoldAskReview,
          title: 'Cooler / mistake?',
          detail: 'Honest review',
          visual: const Icon(
            Icons.help_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.hardFoldTiltHarder,
          title: 'Tilt harder',
          detail: 'No',
          visual: const Icon(
            Icons.whatshot_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectiveGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive selective observe — tap selective + plan, loose passive, or label now',
      semanticsStatic: 'Selective guided outcomes',
      caption: scene.caption ??
          'Seat folds most hands, then 3-bets and c-bets strong boards. Note?',
      phases: [
        (
          region: LessonTableRegion.selectivePlanOk,
          title: 'Selective + plan',
          detail: 'Evidence',
          visual: const Icon(
            Icons.visibility_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.selectiveLoosePassive,
          title: 'Loose passive',
          detail: 'Opposite',
          visual: const Icon(
            Icons.call_received,
            color: AppColors.danger,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.selectiveLabelNow,
          title: 'Label now',
          detail: 'Too soon',
          visual: const Icon(
            Icons.sell_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectiveDiscOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive give-ups — tap disciplined vs same maniac',
      semanticsStatic: 'Selective discipline outcomes',
      caption: scene.caption ??
          'Same seat gives up on turns when called. Observation?',
      phases: [
        (
          region: LessonTableRegion.selectiveDisciplined,
          title: 'Disciplined',
          detail: 'Not spewy',
          visual: const Icon(
            Icons.rule_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.selectiveSameManiac,
          title: 'Same maniac',
          detail: 'Wrong',
          visual: const Icon(
            Icons.flash_on_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectiveSampleOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive sample confidence — tap keep sampling vs max certainty',
      semanticsStatic: 'Selective sample outcomes',
      caption: scene.caption ?? 'Two hands of tightness. Confidence?',
      phases: [
        (
          region: LessonTableRegion.selectiveKeepSampling,
          title: 'Keep sampling',
          detail: 'Working notes',
          visual: const Icon(
            Icons.science_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.selectiveMaxCertainty,
          title: 'Max certainty',
          detail: 'Too soon',
          visual: const Icon(
            Icons.verified_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectiveBundleOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive pre-label bundle — tap tight · plan · give vs good haircut',
      semanticsStatic: 'Selective bundle outcomes',
      caption: scene.caption ?? 'Best pre-label note bundle?',
      phases: [
        (
          region: LessonTableRegion.selectiveEvidenceBundle,
          title: 'Tight · plan · give',
          detail: 'Evidence',
          visual: const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.selectiveHaircut,
          title: 'Good haircut',
          detail: 'Not evidence',
          visual: const Icon(
            Icons.content_cut,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetTagVsStationOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive player type — tap TAG or Station',
      semanticsStatic: 'TAG vs Station outcomes',
      caption: scene.caption ??
          'Folds most · 3-bets strong · barrels with a plan',
      phases: [
        (
          region: LessonTableRegion.meetTagLabel,
          title: 'TAG',
          detail: 'Selective + plan',
          visual: const Icon(
            Icons.gps_fixed,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetTagStationDistractor,
          title: 'Station',
          detail: 'Calls wide',
          visual: const Icon(
            Icons.people_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetTagDiffOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive TAG vs Maniac — tap selective vs extreme or identical',
      semanticsStatic: 'TAG difference outcomes',
      caption: scene.caption ?? 'TAG versus Maniac difference?',
      phases: [
        (
          region: LessonTableRegion.meetTagSelectiveDiff,
          title: 'Selective vs extreme',
          detail: 'Discipline',
          visual: const Icon(
            Icons.compare_arrows,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetTagIdentical,
          title: 'Identical',
          detail: 'Wrong',
          visual: const Icon(
            Icons.merge_type,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetTagVsManiacOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive player type — tap TAG or Maniac',
      semanticsStatic: 'TAG vs Maniac outcomes',
      caption: scene.caption ??
          'Opens tight · folds to 3-bets · selective c-bets',
      phases: [
        (
          region: LessonTableRegion.meetTagLabel2,
          title: 'TAG',
          detail: 'Tight + selective',
          visual: const Icon(
            Icons.gps_fixed,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetTagManiacDistractor,
          title: 'Maniac',
          detail: 'Too wide',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetTagModelOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive label model — tap working model or insult',
      semanticsStatic: 'TAG model outcomes',
      caption: scene.caption ?? 'How to treat the TAG label',
      phases: [
        (
          region: LessonTableRegion.meetTagWorkingModel,
          title: 'Working model',
          detail: 'From frequencies',
          visual: const Icon(
            Icons.science_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetTagInsult,
          title: 'Insult',
          detail: 'Not technical',
          visual: const Icon(
            Icons.mood_bad_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTagRespectCiteOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive TAG cite — tap selective cite or vibes',
      semanticsStatic: 'TAG respect cite outcomes',
      caption: scene.caption ?? 'Versus TAG, cite which tendency?',
      phases: [
        (
          region: LessonTableRegion.citeTagSelective,
          title: 'Selective + disciplined',
          detail: 'Cite the tendency',
          visual: const Icon(
            Icons.gps_fixed,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.citeTagVibes,
          title: 'Vibes',
          detail: 'Not a cite',
          visual: const Icon(
            Icons.sentiment_very_dissatisfied_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLagObserveGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive LAG observe — tap wide + pressure, nit, or label now',
      semanticsStatic: 'LAG observe guided outcomes',
      caption: scene.caption ??
          'Seat opens many hands and barrels often but folds some turn raises. Note?',
      phases: [
        (
          region: LessonTableRegion.lagObserveWidePressure,
          title: 'Wide + pressure',
          detail: 'Evidence',
          visual: const Icon(
            Icons.visibility_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.lagObserveNitDistractor,
          title: 'Nit',
          detail: 'Opposite',
          visual: const Icon(
            Icons.lock_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.lagObserveLabelNow,
          title: 'Label now',
          detail: 'Too soon',
          visual: const Icon(
            Icons.sell_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLagObserveDiscOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive LAG vs maniac — tap some folds or no difference',
      semanticsStatic: 'LAG observe discipline outcomes',
      caption: scene.caption ?? 'Difference brewing vs maniac?',
      phases: [
        (
          region: LessonTableRegion.lagObserveSomeFolds,
          title: 'Some folds',
          detail: 'Not mindless',
          visual: const Icon(
            Icons.rule_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.lagObserveNoDiff,
          title: 'No difference',
          detail: 'Wrong',
          visual: const Icon(
            Icons.merge_type,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLagObserveSampleOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive sample confidence — tap keep sampling or label now',
      semanticsStatic: 'LAG observe sample outcomes',
      caption: scene.caption ?? 'Label after one wide open?',
      phases: [
        (
          region: LessonTableRegion.lagObserveKeepSampling,
          title: 'Keep sampling',
          detail: 'One hand is a note',
          visual: const Icon(
            Icons.science_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.lagObserveLockNow,
          title: 'Label now',
          detail: 'Too soon',
          visual: const Icon(
            Icons.verified_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLagObserveBundleOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive pre-label bundle — tap wide · barrels · folds or seem loud',
      semanticsStatic: 'LAG observe bundle outcomes',
      caption: scene.caption ?? 'Best pre-label note bundle?',
      phases: [
        (
          region: LessonTableRegion.lagObserveBundle,
          title: 'Wide · barrels · folds',
          detail: 'Evidence',
          visual: const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.lagObserveSeemLoud,
          title: 'Seem loud',
          detail: 'Not evidence',
          visual: const Icon(
            Icons.volume_up_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetLagVsTagOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive player type — tap LAG or TAG',
      semanticsStatic: 'LAG vs TAG outcomes',
      caption: scene.caption ??
          'Opens wide · barrels often · folds some raises',
      phases: [
        (
          region: LessonTableRegion.meetLagLabel,
          title: 'LAG',
          detail: 'Wide + pressure',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetLagTagDistractor,
          title: 'TAG',
          detail: 'Selective',
          visual: const Icon(
            Icons.gps_fixed,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetLagDiffOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive LAG vs Station — tap pressure vs passive or same exploit',
      semanticsStatic: 'LAG difference outcomes',
      caption: scene.caption ?? 'LAG versus Calling Station?',
      phases: [
        (
          region: LessonTableRegion.meetLagPressureDiff,
          title: 'Pressure vs passive',
          detail: 'Different exploits',
          visual: const Icon(
            Icons.compare_arrows,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetLagSameExploit,
          title: 'Same exploit',
          detail: 'Wrong',
          visual: const Icon(
            Icons.merge_type,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetLagVsNitOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive player type — tap LAG or Nit',
      semanticsStatic: 'LAG vs Nit outcomes',
      caption: scene.caption ??
          'Wide opens · 3-bets light · keeps barreling',
      phases: [
        (
          region: LessonTableRegion.meetLagLabel2,
          title: 'LAG',
          detail: 'Wide + barrels',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetLagNitDistractor,
          title: 'Nit',
          detail: 'Opposite',
          visual: const Icon(
            Icons.lock_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetLagLimitsOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive label limits — tap sample limits or destiny',
      semanticsStatic: 'LAG limits outcomes',
      caption: scene.caption ?? 'Show beside the LAG label',
      phases: [
        (
          region: LessonTableRegion.meetLagSampleLimits,
          title: 'Sample limits',
          detail: 'Always',
          visual: const Icon(
            Icons.science_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.meetLagDestiny,
          title: 'Destiny',
          detail: 'No',
          visual: const Icon(
            Icons.auto_awesome_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLagAdjustAvoidOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive LAG adjust — tap usually avoid or bluff more',
      semanticsStatic: 'LAG adjust avoid outcomes',
      caption:
          scene.caption ?? 'Inventing triple-barrel bluffs into a LAG?',
      phases: [
        (
          region: LessonTableRegion.citeLagAvoid,
          title: 'Usually avoid',
          detail: 'Fancy less',
          visual: const Icon(
            Icons.block,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.citeLagBluffMore,
          title: 'Bluff more',
          detail: 'Wrong direction',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLagAdjustCiteOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive LAG cite — tap wide + pressure or vibes',
      semanticsStatic: 'LAG adjust cite outcomes',
      caption: scene.caption ?? 'LAG exploit cites?',
      phases: [
        (
          region: LessonTableRegion.citeLagWidePressure,
          title: 'Wide + pressure',
          detail: 'Cite the tendency',
          visual: const Icon(
            Icons.gps_fixed,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.citeLagVibes,
          title: 'Vibes',
          detail: 'Not a cite',
          visual: const Icon(
            Icons.sentiment_very_dissatisfied_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMixFiveTagRespectOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive five-type mix — tap TAG respect or Station bluff',
      semanticsStatic: 'Mix five types TAG respect outcomes',
      caption: scene.caption ??
          'Selective entry + disciplined barrels. Label + line?',
      phases: [
        (
          region: LessonTableRegion.mixFiveTagRespect,
          title: 'TAG — respect',
          detail: 'Cite selective',
          visual: const Icon(
            Icons.gps_fixed,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.mixFiveStationBluff,
          title: 'Station — bluff',
          detail: 'Wrong model',
          visual: const Icon(
            Icons.people_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildS6CpAdvOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive S6 checkpoint — tap range advantage or no concept',
      semanticsStatic: 'S6 checkpoint range advantage outcomes',
      caption: scene.caption ?? 'PFR on dry A-high often has?',
      phases: [
        (
          region: LessonTableRegion.s6CpRangeAdvantage,
          title: 'Range advantage',
          detail: 'PFR owns A-high',
          visual: const Icon(
            Icons.north_east,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.s6CpNoConcept,
          title: 'No concept',
          detail: 'It applies',
          visual: const Icon(
            Icons.block,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildS6CpCapOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive S6 checkpoint — tap more capped or uncapped nuts',
      semanticsStatic: 'S6 checkpoint capped outcomes',
      caption: scene.caption ?? 'Check-back turn often makes river range?',
      phases: [
        (
          region: LessonTableRegion.s6CpMoreCapped,
          title: 'More capped',
          detail: 'Fewer nuts',
          visual: const Icon(
            Icons.vertical_align_bottom,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.s6CpUncappedNuts,
          title: 'Uncapped nuts',
          detail: 'Wrong story',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildS6CpPolarOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive S6 checkpoint — tap polarized or always merged',
      semanticsStatic: 'S6 checkpoint polar outcomes',
      caption: scene.caption ?? 'River overbet shape?',
      phases: [
        (
          region: LessonTableRegion.s6CpPolarized,
          title: 'Polarized',
          detail: 'Value or bluff',
          visual: const Icon(
            Icons.swap_vert,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.s6CpAlwaysMerged,
          title: 'Always merged',
          detail: 'Wrong size story',
          visual: const Icon(
            Icons.horizontal_rule,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildS6CpTagOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive S6 checkpoint — tap TAG or LAG',
      semanticsStatic: 'S6 checkpoint TAG outcomes',
      caption: scene.caption ?? 'Tight entry, planned barrels. Label?',
      phases: [
        (
          region: LessonTableRegion.s6CpTag,
          title: 'TAG',
          detail: 'Selective + plan',
          visual: const Icon(
            Icons.gps_fixed,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.s6CpLagDistractor,
          title: 'LAG',
          detail: 'Entry too tight',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildS6CpLagOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive: 'Interactive S6 checkpoint — tap LAG or Nit',
      semanticsStatic: 'S6 checkpoint LAG outcomes',
      caption: scene.caption ?? 'Wide entry, sustained pressure. Label?',
      phases: [
        (
          region: LessonTableRegion.s6CpLag,
          title: 'LAG',
          detail: 'Wide + pressure',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.s6CpNit,
          title: 'Nit',
          detail: 'Opposite',
          visual: const Icon(
            Icons.lock_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPreflopFlopGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive preflop-to-flop — tap Plan is sick or Still jam',
      semanticsStatic: 'Preflop-to-flop guided outcomes',
      caption: scene.caption ?? 'AQo 3-bet · flop 872tt — update?',
      phases: [
        (
          region: LessonTableRegion.preflopFlopPlanSick,
          title: 'Plan is sick',
          detail: 'Give up more',
          visual: const Icon(
            Icons.heart_broken_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.preflopFlopStillJam,
          title: 'Still jam',
          detail: 'Every street',
          visual: const Icon(
            Icons.bolt_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPreflopFlopScaffoldedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive preflop-to-flop — tap Value continues or Auto-fold',
      semanticsStatic: 'Preflop-to-flop scaffolded outcomes',
      caption: scene.caption ?? 'BTN steal KTo · flop KT2r — update?',
      phases: [
        (
          region: LessonTableRegion.preflopFlopValueContinues,
          title: 'Value continues',
          detail: 'Thesis improved',
          visual: const Icon(
            Icons.trending_up,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.preflopFlopAutoFold,
          title: 'Auto-fold',
          detail: 'Top two',
          visual: const Icon(
            Icons.do_not_disturb_on_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPreflopFlopUnguidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive preflop-to-flop — tap Name the thesis or Wing it',
      semanticsStatic: 'Preflop-to-flop unguided outcomes',
      caption: scene.caption ?? 'Best habit before acting the flop?',
      phases: [
        (
          region: LessonTableRegion.preflopFlopNameThesis,
          title: 'Name the thesis',
          detail: 'Before flop act',
          visual: const Icon(
            Icons.edit_note_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.preflopFlopWingIt,
          title: 'Wing it',
          detail: 'Every street',
          visual: const Icon(
            Icons.casino_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPreflopFlopCheckpointOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive preflop-to-flop — tap Abandon quickly or Force the old line',
      semanticsStatic: 'Preflop-to-flop checkpoint outcomes',
      caption: scene.caption ?? 'Dead plan response?',
      phases: [
        (
          region: LessonTableRegion.preflopFlopAbandon,
          title: 'Abandon quickly',
          detail: 'Sunk cost dies',
          visual: const Icon(
            Icons.exit_to_app,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.preflopFlopForce,
          title: 'Force the old line',
          detail: 'Leak',
          visual: const Icon(
            Icons.push_pin_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTurnMapGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive turn map — tap Aces & blanks or Any card',
      semanticsStatic: 'Turn-map guided outcomes',
      caption: scene.caption ?? 'AK c-bet · Q72r — good turn continue?',
      phases: [
        (
          region: LessonTableRegion.turnMapAcesBlanks,
          title: 'Aces & blanks',
          detail: 'With a plan',
          visual: const Icon(
            Icons.map_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.turnMapAnyCard,
          title: 'Any card',
          detail: 'Always barrel',
          visual: const Icon(
            Icons.all_inclusive,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTurnMapScaffoldedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive turn map — tap Give up or Hero-call',
      semanticsStatic: 'Turn-map scaffolded outcomes',
      caption: scene.caption ?? 'Gutshot · brick raise — map says?',
      phases: [
        (
          region: LessonTableRegion.turnMapGiveUp,
          title: 'Give up',
          detail: 'Map kill',
          visual: const Icon(
            Icons.stop_circle_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.turnMapHeroCall,
          title: 'Hero-call',
          detail: 'Sunk cost',
          visual: const Icon(
            Icons.psychology_alt_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTurnMapUnguidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive turn map — tap Map first or Yolo barrels',
      semanticsStatic: 'Turn-map unguided outcomes',
      caption: scene.caption ?? 'Bet flop with no turn idea?',
      phases: [
        (
          region: LessonTableRegion.turnMapMapFirst,
          title: 'Map first',
          detail: 'Then bet flop',
          visual: const Icon(
            Icons.checklist_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.turnMapYolo,
          title: 'Yolo barrels',
          detail: 'No map',
          visual: const Icon(
            Icons.casino_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTurnMapCheckpointOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive turn map — tap Continue/kill list or Invent later',
      semanticsStatic: 'Turn-map checkpoint outcomes',
      caption: scene.caption ?? 'Turn map is?',
      phases: [
        (
          region: LessonTableRegion.turnMapContinueKill,
          title: 'Continue/kill list',
          detail: 'Made on flop',
          visual: const Icon(
            Icons.list_alt_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.turnMapInventLater,
          title: 'Invent later',
          detail: 'Too late',
          visual: const Icon(
            Icons.hourglass_empty,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildRiverCompScaffoldedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive river composition — tap Blocks strong calls or Fake EV',
      semanticsStatic: 'River composition scaffolded outcomes',
      caption: scene.caption ?? 'Nut flush blocker — why bluff?',
      phases: [
        (
          region: LessonTableRegion.riverCompBlocks,
          title: 'Blocks strong calls',
          detail: 'Nut flush blocker',
          visual: const Icon(
            Icons.block,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.riverCompFakeEv,
          title: 'Fake EV',
          detail: 'Sheet said +0.02',
          visual: const Icon(
            Icons.calculate_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildRiverCompUnguidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive river composition — tap Check or Blast off',
      semanticsStatic: 'River composition unguided outcomes',
      caption: scene.caption ?? 'No value, no blockers, no fold equity?',
      phases: [
        (
          region: LessonTableRegion.riverCompCheck,
          title: 'Check',
          detail: 'No story',
          visual: const Icon(
            Icons.pause_circle_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.riverCompBlast,
          title: 'Blast off',
          detail: 'Spew',
          visual: const Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildRiverCompCheckpointOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive river composition — tap Value needs calls or Bet every river',
      semanticsStatic: 'River composition checkpoint outcomes',
      caption: scene.caption ?? 'River composition rule?',
      phases: [
        (
          region: LessonTableRegion.riverCompRule,
          title: 'Value needs calls',
          detail: 'Bluffs need folds',
          visual: const Icon(
            Icons.balance_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.riverCompStyle,
          title: 'Bet every river',
          detail: 'For style',
          visual: const Icon(
            Icons.style_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPotTypeGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive pot type — tap Nut potential or Pure air',
      semanticsStatic: 'Pot-type guided outcomes',
      caption: scene.caption ?? 'Multiway limped pot — priority?',
      phases: [
        (
          region: LessonTableRegion.potTypeNutPotential,
          title: 'Nut potential',
          detail: 'Strong made hands',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.potTypePureAir,
          title: 'Pure air',
          detail: 'Always stab',
          visual: const Icon(
            Icons.air,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPotTypeScaffoldedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive pot type — tap C-bet maps or Never bet',
      semanticsStatic: 'Pot-type scaffolded outcomes',
      caption: scene.caption ?? 'HU SRP IP — default weapon?',
      phases: [
        (
          region: LessonTableRegion.potTypeCbetMaps,
          title: 'C-bet maps',
          detail: 'With turn plans',
          visual: const Icon(
            Icons.map_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.potTypeNeverBet,
          title: 'Never bet',
          detail: 'Too passive',
          visual: const Icon(
            Icons.block,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPotTypeUnguidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive pot type — tap Higher commitment or 300bb deep',
      semanticsStatic: 'Pot-type unguided outcomes',
      caption: scene.caption ?? '4-bet pot 100bb — mindset?',
      phases: [
        (
          region: LessonTableRegion.potTypeHigherCommit,
          title: 'Higher commitment',
          detail: 'Fewer spewy bluffs',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.potTypeDeepLike300,
          title: '300bb deep',
          detail: 'Wrong depth',
          visual: const Icon(
            Icons.swap_vert,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildPotTypeCheckpointOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive pot type — tap Ranges and SPR or Nothing material',
      semanticsStatic: 'Pot-type checkpoint outcomes',
      caption: scene.caption ?? 'Pot type changes?',
      phases: [
        (
          region: LessonTableRegion.potTypeRangesSpr,
          title: 'Ranges and SPR',
          detail: 'Both matter',
          visual: const Icon(
            Icons.tune,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.potTypeNothing,
          title: 'Nothing material',
          detail: 'It matters',
          visual: const Icon(
            Icons.do_not_disturb_alt,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildHuMwGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive HU vs multiway — tap Usually no or Always yes',
      semanticsStatic: 'HU vs multiway guided outcomes',
      caption: scene.caption ?? 'Four-way river — naked air bluff?',
      phases: [
        (
          region: LessonTableRegion.huMwUsuallyNo,
          title: 'Usually no',
          detail: 'Someone calls',
          visual: const Icon(
            Icons.block,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.huMwAlwaysYes,
          title: 'Always yes',
          detail: 'Leak',
          visual: const Icon(
            Icons.air,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildHuMwScaffoldedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive HU vs multiway — tap Higher HU or Identical',
      semanticsStatic: 'HU vs multiway scaffolded outcomes',
      caption: scene.caption ?? 'HU vs nit BB — steal frequency?',
      phases: [
        (
          region: LessonTableRegion.huMwHigherHu,
          title: 'Higher HU',
          detail: 'Exploit the nit',
          visual: const Icon(
            Icons.trending_up,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.huMwIdentical,
          title: 'Identical',
          detail: 'Always same',
          visual: const Icon(
            Icons.drag_handle,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildHuMwUnguidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive HU vs multiway — tap Thicker value or Ultra-slow',
      semanticsStatic: 'HU vs multiway unguided outcomes',
      caption: scene.caption ?? 'Multiway top set — line lean?',
      phases: [
        (
          region: LessonTableRegion.huMwThickerValue,
          title: 'Thicker value',
          detail: 'And protection',
          visual: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.huMwUltraSlow,
          title: 'Ultra-slow',
          detail: 'Free cards risk',
          visual: const Icon(
            Icons.hourglass_empty,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildHuMwCheckpointOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive HU vs multiway — tap First-class input or Noise',
      semanticsStatic: 'HU vs multiway checkpoint outcomes',
      caption: scene.caption ?? 'Player count is?',
      phases: [
        (
          region: LessonTableRegion.huMwFirstClass,
          title: 'First-class input',
          detail: 'Plan with it',
          visual: const Icon(
            Icons.groups_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.huMwNoise,
          title: 'Noise',
          detail: 'It matters',
          visual: const Icon(
            Icons.hearing_disabled,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStackDepthGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive stack depth — tap Closer to stacking or 250bb deep',
      semanticsStatic: 'Stack-depth guided outcomes',
      caption: scene.caption ?? '35bb TPTK vs raise — lean?',
      phases: [
        (
          region: LessonTableRegion.stackDepthCloserCommit,
          title: 'Closer to stacking',
          detail: 'SPR is low',
          visual: const Icon(
            Icons.lock_outline,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.stackDepthPlayDeep,
          title: '250bb deep',
          detail: 'Wrong depth',
          visual: const Icon(
            Icons.swap_vert,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStackDepthScaffoldedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive stack depth — tap More attractive or Never set-mine',
      semanticsStatic: 'Stack-depth scaffolded outcomes',
      caption: scene.caption ?? '250bb — set-mine 55?',
      phases: [
        (
          region: LessonTableRegion.stackDepthMoreAttractive,
          title: 'More attractive',
          detail: 'With depth',
          visual: const Icon(
            Icons.trending_up,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.stackDepthNeverMine,
          title: 'Never set-mine',
          detail: 'Opposite',
          visual: const Icon(
            Icons.block,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStackDepthUnguidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive stack depth — tap 40bb or 200bb',
      semanticsStatic: 'Stack-depth unguided outcomes',
      caption: scene.caption ?? 'Hero 200bb, villain 40bb — effective?',
      phases: [
        (
          region: LessonTableRegion.stackDepth40bb,
          title: '40bb',
          detail: 'Shorter caps',
          visual: const Icon(
            Icons.vertical_align_bottom,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.stackDepth200bb,
          title: '200bb',
          detail: "Can't exceed",
          visual: const Icon(
            Icons.vertical_align_top,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStackDepthCheckpointOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive stack depth — tap Every hand or Once per lifetime',
      semanticsStatic: 'Stack-depth checkpoint outcomes',
      caption: scene.caption ?? 'Stack depth is?',
      phases: [
        (
          region: LessonTableRegion.stackDepthEveryHand,
          title: 'Every hand',
          detail: 'Recalculate',
          visual: const Icon(
            Icons.refresh,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.stackDepthOnceLifetime,
          title: 'Once per lifetime',
          detail: 'No',
          visual: const Icon(
            Icons.event_busy,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSameCardsCheckpointOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive same-cards types — tap Baseline or Guess type',
      semanticsStatic: 'Same-cards checkpoint outcomes',
      caption: scene.caption ?? 'No type evidence yet. Default?',
      phases: [
        (
          region: LessonTableRegion.sameCardsBaseline,
          title: 'Baseline',
          detail: 'Exploit needs evidence',
          visual: const Icon(
            Icons.balance,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.sameCardsGuess,
          title: 'Guess type',
          detail: 'Overfit',
          visual: const Icon(
            Icons.casino_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBoardCheckpointOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive type-board-line — tap All four or Cards only',
      semanticsStatic: 'Type-board-line checkpoint outcomes',
      caption: scene.caption ?? 'Integrated decision uses?',
      phases: [
        (
          region: LessonTableRegion.typeBoardAllFour,
          title: 'All four',
          detail: 'Type · board · line · size',
          visual: const Icon(
            Icons.hub_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.typeBoardCardsOnly,
          title: 'Cards only',
          detail: 'Hole beauty alone',
          visual: const Icon(
            Icons.style_outlined,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLeakReviewGuidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive leak review — tap Specific note or Vague',
      semanticsStatic: 'Leak-review guided outcomes',
      caption: scene.caption ?? 'Best leak note?',
      phases: [
        (
          region: LessonTableRegion.leakReviewSpecific,
          title: 'Specific note',
          detail: 'Actionable fix',
          visual: const Icon(
            Icons.edit_note,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.leakReviewVague,
          title: 'Vague',
          detail: 'Not useful',
          visual: const Icon(
            Icons.help_outline,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLeakReviewScaffoldedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive leak review — tap Written range or Mood says',
      semanticsStatic: 'Leak-review scaffolded outcomes',
      caption: scene.caption ?? 'Default BTN vs unknown BB open?',
      phases: [
        (
          region: LessonTableRegion.leakReviewWrittenRange,
          title: 'Written range',
          detail: 'From your book',
          visual: const Icon(
            Icons.menu_book_outlined,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.leakReviewMood,
          title: 'Mood says',
          detail: 'No default',
          visual: const Icon(
            Icons.mood,
            color: AppColors.danger,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLeakReviewUnguidedOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive leak review — tap On a schedule or Never',
      semanticsStatic: 'Leak-review unguided outcomes',
      caption: scene.caption ?? 'When to review the book?',
      phases: [
        (
          region: LessonTableRegion.leakReviewOnSchedule,
          title: 'On a schedule',
          detail: 'After sessions',
          visual: const Icon(
            Icons.event_repeat,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.leakReviewNever,
          title: 'Never',
          detail: 'Leaks return',
          visual: const Icon(
            Icons.block,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLeakReviewCheckpointOutcomes() {
    return _buildOutcomePhases(
      semanticsInteractive:
          'Interactive leak review — tap Baseline or Replace all',
      semanticsStatic: 'Leak-review checkpoint outcomes',
      caption: scene.caption ?? 'Default book purpose?',
      phases: [
        (
          region: LessonTableRegion.leakReviewBaseline,
          title: 'Baseline',
          detail: 'Before exploits',
          visual: const Icon(
            Icons.foundation,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        (
          region: LessonTableRegion.leakReviewReplaceAll,
          title: 'Replace all',
          detail: 'Still update',
          visual: const Icon(
            Icons.auto_fix_off,
            color: AppColors.slate,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildOutcomePhases({
    required String semanticsInteractive,
    required String semanticsStatic,
    required String caption,
    required List<
      ({
        LessonTableRegion region,
        String title,
        String detail,
        Widget visual,
      })
    >
    phases,
  }) {
    Widget phase({
      required LessonTableRegion region,
      required String title,
      required String detail,
      required Widget visual,
    }) {
      final selected = selectedRegion == region;
      return Expanded(
        child: _TappableRegion(
          label: title,
          selected: selected,
          enabled: enabled && _interactive,
          onTap:
              _interactive
                  ? () => onRegionTap!(LessonTableTapTarget(region))
                  : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Column(
              children: [
                visual,
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _feltShell(
      semanticsLabel: _interactive ? semanticsInteractive : semanticsStatic,
      child: Column(
        children: [
          Text(
            caption,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < phases.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                phase(
                  region: phases[i].region,
                  title: phases[i].title,
                  detail: phases[i].detail,
                  visual: phases[i].visual,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoleCards() {
    final hero = scene.heroCodes
        .map(CardModel.fromCode)
        .toList(growable: false);
    final board = scene.boardCodes
        .map(CardModel.fromCode)
        .toList(growable: false);
    final villainFaceUp = scene.villainCodes
        .map(CardModel.fromCode)
        .toList(growable: false);
    final pulseHero =
        showSoftPulse &&
        selectedRegion == null &&
        scene.highlight == LessonTableHighlight.hero;
    final pulseBoard =
        showSoftPulse &&
        selectedRegion == null &&
        scene.highlight == LessonTableHighlight.board;
    final showVillainRail =
        villainFaceUp.isNotEmpty ||
        scene.villainSeatCount > 0 ||
        scene.showDealerChip;

    return _feltShell(
      semanticsLabel: _semanticsLabel(hero, board, villainFaceUp),
      child: Column(
        children: [
          if (showVillainRail) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (villainFaceUp.isNotEmpty)
                  _TappableRegion(
                    label:
                        'Them ${villainFaceUp.map((c) => c.display).join(' ')}',
                    selected: selectedRegion == LessonTableRegion.villain,
                    enabled: enabled && _interactive,
                    onTap:
                        _interactive
                            ? () => onRegionTap!(
                              const LessonTableTapTarget(
                                LessonTableRegion.villain,
                              ),
                            )
                            : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Them',
                            style: GoogleFonts.manrope(
                              color: AppColors.slate,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < villainFaceUp.length; i++) ...[
                                if (i > 0) const SizedBox(width: 6),
                                MiniCard(
                                  card: villainFaceUp[i],
                                  size: MiniCardSize.small,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < scene.villainSeatCount; i++)
                    _TappableRegion(
                      label: 'Them — other seat face-down cards',
                      selected: selectedRegion == LessonTableRegion.villain,
                      enabled: enabled && _interactive,
                      onTap:
                          _interactive
                              ? () => onRegionTap!(
                                const LessonTableTapTarget(
                                  LessonTableRegion.villain,
                                ),
                              )
                              : null,
                      child: const _FaceDownPair(),
                    ),
                if (scene.showDealerChip)
                  _TappableRegion(
                    label: 'Dealer',
                    selected: selectedRegion == LessonTableRegion.dealer,
                    enabled: enabled && _interactive,
                    onTap:
                        _interactive
                            ? () => onRegionTap!(
                              const LessonTableTapTarget(
                                LessonTableRegion.dealer,
                              ),
                            )
                            : null,
                    child: const _DealerChip(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (board.isNotEmpty) ...[
            _TappableRegion(
              label: 'Board ${board.map((c) => c.display).join(' ')}',
              selected: selectedRegion == LessonTableRegion.board,
              highlighted: pulseBoard,
              enabled: enabled && _interactive,
              onTap:
                  _interactive
                      ? () => onRegionTap!(
                        const LessonTableTapTarget(LessonTableRegion.board),
                      )
                      : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < board.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      MiniCard(card: board[i], size: MiniCardSize.small),
                    ],
                  ],
                ),
              ),
            ),
            // Teach vocabulary at the moment of use (Duolingo-style label).
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'BOARD · shared',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.cream.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ],
          _TappableRegion(
            label: 'Your hole cards ${hero.map((c) => c.display).join(' ')}',
            selected: selectedRegion == LessonTableRegion.hero,
            highlighted: pulseHero,
            enabled: enabled && _interactive,
            onTap:
                _interactive
                    ? () => onRegionTap!(
                      const LessonTableTapTarget(LessonTableRegion.hero),
                    )
                    : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                children: [
                  Text(
                    scene.caption ?? 'You',
                    style: GoogleFonts.manrope(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < hero.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        MiniCard(card: hero[i], size: MiniCardSize.hero),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (scene.showMuck) ...[
            const SizedBox(height: 8),
            _TappableRegion(
              label: 'Muck pile',
              selected: selectedRegion == LessonTableRegion.muck,
              enabled: enabled && _interactive,
              onTap:
                  _interactive
                      ? () => onRegionTap!(
                        const LessonTableTapTarget(LessonTableRegion.muck),
                      )
                      : null,
              child: const _MuckPile(),
            ),
          ],
        ],
      ),
    );
  }

  String _semanticsLabel(
    List<CardModel> hero,
    List<CardModel> board,
    List<CardModel> villainFaceUp,
  ) {
    if (_interactive) {
      return 'Interactive poker table';
    }
    final heroText = hero.map((c) => c.display).join(' ');
    final parts = <String>['Your hole cards $heroText'];
    if (board.isNotEmpty) {
      parts.add('Board ${board.map((c) => c.display).join(' ')}');
    }
    if (villainFaceUp.isNotEmpty) {
      parts.add(
        'Them ${villainFaceUp.map((c) => c.display).join(' ')}',
      );
    } else if (scene.villainSeatCount > 0) {
      parts.add(
        '${scene.villainSeatCount} other '
        '${scene.villainSeatCount == 1 ? 'seat has' : 'seats have'} '
        'face-down hole cards',
      );
    }
    return parts.join('. ');
  }
}

class _TappableRegion extends StatefulWidget {
  const _TappableRegion({
    required this.label,
    required this.child,
    required this.selected,
    required this.enabled,
    this.highlighted = false,
    this.onTap,
  });

  final String label;
  final Widget child;
  final bool selected;
  final bool enabled;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  State<_TappableRegion> createState() => _TappableRegionState();
}

class _TappableRegionState extends State<_TappableRegion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _TappableRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlighted != widget.highlighted ||
        oldWidget.selected != widget.selected) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    final shouldPulse = widget.highlighted && !widget.selected;
    if (shouldPulse) {
      if (!_pulse.isAnimating) {
        _pulse.repeat(reverse: true);
      }
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep InkWell's child tree stable across pulse ticks. Glow paints in an
    // IgnorePointer overlay so the soft pulse never steals / cancels taps.
    final staticBorder = widget.selected
        ? AppColors.gold
        : widget.highlighted
        ? AppColors.gold.withValues(alpha: 0.55)
        : Colors.transparent;
    final staticFill = widget.selected
        ? AppColors.gold.withValues(alpha: 0.22)
        : widget.highlighted
        ? AppColors.gold.withValues(alpha: 0.1)
        : Colors.transparent;

    final framed = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: staticFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: staticBorder,
              width: widget.selected ? 2.4 : 1.8,
            ),
          ),
          child: widget.child,
        ),
        if (widget.highlighted && !widget.selected)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  final glow = 0.35 + (_pulse.value * 0.45);
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: glow),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.22 * glow),
                          blurRadius: 12 + (8 * _pulse.value),
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );

    if (widget.onTap == null) return framed;

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: framed,
        ),
      ),
    );
  }
}

class _PositionSeatChip extends StatelessWidget {
  const _PositionSeatChip({
    required this.role,
    required this.selected,
    required this.highlighted,
    required this.enabled,
    required this.onTap,
  });

  final LessonTableRegion role;
  final bool selected;
  final bool highlighted;
  final bool enabled;
  final VoidCallback? onTap;

  String get _code => switch (role) {
        LessonTableRegion.button => 'BTN',
        LessonTableRegion.smallBlind => 'SB',
        LessonTableRegion.bigBlind => 'BB',
        LessonTableRegion.earlyPosition => 'EP',
        LessonTableRegion.hijack => 'HJ',
        LessonTableRegion.cutoff => 'CO',
        _ => '?',
      };

  String get _subtitle => switch (role) {
        LessonTableRegion.button => 'Dealer',
        LessonTableRegion.smallBlind => 'Posts 1',
        LessonTableRegion.bigBlind => 'Posts 2',
        LessonTableRegion.earlyPosition => 'UTG',
        LessonTableRegion.hijack => 'Mid',
        LessonTableRegion.cutoff => 'Late',
        _ => '',
      };

  String get _a11y => switch (role) {
        LessonTableRegion.button => 'Button seat',
        LessonTableRegion.smallBlind => 'Small blind seat',
        LessonTableRegion.bigBlind => 'Big blind seat',
        LessonTableRegion.earlyPosition => 'UTG seat — first to act preflop',
        LessonTableRegion.hijack => 'Hijack seat',
        LessonTableRegion.cutoff => 'Cutoff seat',
        _ => 'Seat',
      };

  @override
  Widget build(BuildContext context) {
    return _TappableRegion(
      label: _a11y,
      selected: selected,
      highlighted: highlighted,
      enabled: enabled,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Column(
          children: [
            Text(
              _code,
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _subtitle,
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlindsSeatChip extends StatelessWidget {
  const _BlindsSeatChip({
    required this.seatIndex,
    required this.role,
    required this.numberSeats,
    required this.showRoleLabels,
    required this.selected,
    required this.highlighted,
    required this.enabled,
    required this.onTap,
  });

  final int seatIndex;
  final LessonTableRegion role;
  final bool numberSeats;
  final bool showRoleLabels;
  final bool selected;
  final bool highlighted;
  final bool enabled;
  final VoidCallback? onTap;

  String? get _title {
    if (numberSeats) return 'Seat $seatIndex';
    if (!showRoleLabels) return null;
    return switch (role) {
      LessonTableRegion.button => 'Button',
      LessonTableRegion.smallBlind => 'Small blind',
      LessonTableRegion.bigBlind => 'Big blind',
      _ => 'Seat',
    };
  }

  String get _a11y {
    final roleLabel = switch (role) {
      LessonTableRegion.button => 'dealer button',
      LessonTableRegion.smallBlind => 'small blind posting 1',
      LessonTableRegion.bigBlind => 'big blind posting 2',
      _ => 'empty seat',
    };
    return numberSeats ? 'Seat $seatIndex, $roleLabel' : roleLabel;
  }

  @override
  Widget build(BuildContext context) {
    final title = _title;
    return _TappableRegion(
      label: _a11y,
      selected: selected,
      highlighted: highlighted,
      enabled: enabled,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
        child: Column(
          children: [
            if (title != null) ...[
              Text(
                title,
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
            ],
            switch (role) {
              LessonTableRegion.button => const _DealerChipBadge(),
              LessonTableRegion.smallBlind => const _BlindChipStack(amount: 1),
              LessonTableRegion.bigBlind => const _BlindChipStack(amount: 2),
              _ => const _EmptySeatMark(),
            },
            // Role letter badges (D/SB/BB) only when teaching names explicitly —
            // never on identify taps where they would print the answer.
            if (showRoleLabels &&
                numberSeats &&
                role != LessonTableRegion.emptySeat) ...[
              const SizedBox(height: 4),
              Text(
                switch (role) {
                  LessonTableRegion.button => 'D',
                  LessonTableRegion.smallBlind => 'SB',
                  LessonTableRegion.bigBlind => 'BB',
                  _ => '',
                },
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DealerChipBadge extends StatelessWidget {
  const _DealerChipBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cream,
        border: Border.all(color: AppColors.bgDark, width: 2),
      ),
      child: Text(
        'D',
        style: GoogleFonts.manrope(
          color: AppColors.bgDark,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _BlindChipStack extends StatelessWidget {
  const _BlindChipStack({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < amount; i++)
            Positioned(
              top: (amount - 1 - i) * 4.0,
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == amount - 1 ? AppColors.gold : AppColors.goldMuted,
                  border: Border.all(color: AppColors.bgDark, width: 1.5),
                ),
                child: Text(
                  '$amount',
                  style: GoogleFonts.manrope(
                    color: AppColors.bgDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PotChipDot extends StatelessWidget {
  const _PotChipDot({required this.label, required this.gold});

  final String label;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final color = gold ? AppColors.gold : AppColors.slate;
    return Container(
      width: label.length > 2 ? 40 : (label.length > 1 ? 32 : 26),
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.3),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptySeatMark extends StatelessWidget {
  const _EmptySeatMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.feltDark.withValues(alpha: 0.55),
        border: Border.all(
          color: AppColors.slateDark.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Text(
        '·',
        style: GoogleFonts.manrope(
          color: AppColors.slate,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _FaceDownPair extends StatelessWidget {
  const _FaceDownPair();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Them',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardBack(size: MiniCardSize.tiny),
            SizedBox(width: 3),
            CardBack(size: MiniCardSize.tiny),
          ],
        ),
      ],
    );
  }
}

class _DealerChip extends StatelessWidget {
  const _DealerChip();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Dealer',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const _DealerChipBadge(),
      ],
    );
  }
}

class _MuckPile extends StatelessWidget {
  const _MuckPile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: -0.18,
            child: const CardBack(size: MiniCardSize.tiny),
          ),
          Transform.translate(
            offset: const Offset(-8, 2),
            child: Transform.rotate(
              angle: 0.12,
              child: const CardBack(size: MiniCardSize.tiny),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Muck',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
