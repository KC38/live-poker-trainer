/**
 * Authenticated online live-hand sessions and incremental progress.
 *
 * Sessions reference shared tree nodes but keep a per-user versioned cursor.
 * Every Hero command is claimed by an idempotency key before model work and
 * committed once, so retries cannot duplicate chips, coaching, or progress.
 */

import {randomUUID} from "node:crypto";
import {
  FieldValue,
  getFirestore,
  type DocumentData,
  type Firestore,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {
  actionDocId,
  allocateLiveHandForUser,
  preparedNodeFromData,
} from "./live_pool";
import {
  expandLiveHeroAction,
  type PreparedLiveEdge,
  type PreparedLiveNode,
} from "./live_tree";
import {LIVE_GEMINI_MODEL} from "./live_hand_generation";
import {
  emptyLiveUsageBreakdown,
  liveGenerationMetricsIncrements,
  liveUsageFirestoreFields,
  liveUsageFromError,
} from "./live_usage";
import {livePotSize, visibleLastAction} from "./live_poker_engine";
import {buildLiveSetupKey, parseLiveTableSetup} from "./live_setup";
import type {
  CoachingActionAssessment,
  LiveActionEvent,
  LiveHandDefinition,
  LiveHandState,
  LiveHandView,
  LiveSeatView,
  StartLiveHandResult,
  SubmitLiveActionInput,
  SubmitLiveActionResult,
} from "./live_types";

const EDGE_LEASE_MS = 3 * 60 * 1000;
const DECISION_LEASE_MS = 5 * 60 * 1000;
const START_LEASE_MS = 5 * 60 * 1000;
export const MIN_LIVE_CLIENT_VERSION = "2.0.0";

interface LiveSessionDoc {
  sessionId: string;
  uid: string;
  handId: string;
  setupKey: string;
  stateHash: string;
  state: LiveHandState;
  history: LiveActionEvent[];
  stateVersion: number;
  status: LiveHandState["status"];
  coaching: CoachingActionAssessment[];
}

/** Starts one unseen hand and returns its warmed first Hero decision. */
export async function startLiveHandForUser(options: {
  uid: string;
  raw: unknown;
  db?: Firestore;
}): Promise<StartLiveHandResult> {
  const db = options.db ?? getFirestore();
  const input = record(options.raw, "request");
  const clientVersion = nonEmpty(input.clientVersion, "clientVersion");
  await assertLiveServiceAvailable(db, clientVersion);
  const setup = parseLiveTableSetup(input.tableSetup);
  const startRequestId = safeCommandKey(
    input.startRequestId,
    "startRequestId",
  );
  const setupKey = buildLiveSetupKey(setup);
  const newSessionId = randomUUID();
  const requestRef = db
    .collection("users")
    .doc(options.uid)
    .collection("liveStartRequests")
    .doc(startRequestId);
  const openRef = openSessionReference(db, options.uid);
  const claimId = randomUUID();
  const claim = await db.runTransaction(async (tx) => {
    const [snapshot, openSnapshot] = await Promise.all([
      tx.get(requestRef),
      tx.get(openRef),
    ]);
    const data = snapshot.data();
    const open = openSnapshot.data();
    if (open?.status === "playing" && typeof open.sessionId === "string") {
      return {sessionId: open.sessionId as string, claimed: false};
    }
    if (
      open?.status === "starting" &&
      open.startRequestId !== startRequestId &&
      Number(open.leaseExpiresAtMs ?? 0) > Date.now()
    ) {
      throw new HttpsError(
        "unavailable",
        "Another device is already starting a hand. Retry shortly.",
      );
    }
    if (snapshot.exists && data?.setupKey !== setupKey) {
      throw new HttpsError(
        "already-exists",
        "startRequestId was reused for another setup.",
      );
    }
    if (data?.status === "ready" && typeof data.sessionId === "string") {
      return {sessionId: data.sessionId as string, claimed: false};
    }
    if (
      data?.status === "pending" &&
      Number(data.leaseExpiresAtMs ?? 0) > Date.now()
    ) {
      throw new HttpsError(
        "unavailable",
        "This hand is still starting. Retry shortly.",
      );
    }
    const claimedSessionId =
      typeof data?.sessionId === "string" ? data.sessionId : newSessionId;
    tx.set(requestRef, {
      status: "pending",
      setupKey,
      sessionId: claimedSessionId,
      claimId,
      leaseExpiresAtMs: Date.now() + START_LEASE_MS,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    tx.set(openRef, {
      status: "starting",
      startRequestId,
      sessionId: claimedSessionId,
      claimId,
      leaseExpiresAtMs: Date.now() + START_LEASE_MS,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return {sessionId: claimedSessionId, claimed: true};
  });
  if (!claim.claimed) {
    return resumeLiveHandForUser({
      uid: options.uid,
      sessionId: claim.sessionId,
      clientVersion,
      db,
    });
  }
  const sessionId = claim.sessionId;
  const sessionRef = sessionReference(db, options.uid, sessionId);
  const recovered = await recoverAllocatedStart({
    db,
    uid: options.uid,
    startRequestId,
    sessionId,
    requestRef,
    openRef,
    claimId,
  });
  if (recovered) return recovered;
  let allocated: Awaited<ReturnType<typeof allocateLiveHandForUser>>;
  try {
    allocated = await allocateLiveHandForUser({
      uid: options.uid,
      setup,
      startRequestId,
      sessionId,
      db,
    });
  } catch (error) {
    await releaseStartClaim({db, requestRef, openRef, claimId, error});
    throw error;
  }
  const session: LiveSessionDoc = {
    sessionId,
    uid: options.uid,
    handId: allocated.definition.handId,
    setupKey: allocated.setupKey,
    stateHash: allocated.root.stateHash,
    state: allocated.root.state,
    history: allocated.root.history,
    stateVersion: 0,
    status: allocated.root.state.status,
    coaching: [],
  };
  await db.runTransaction(async (tx) => {
    const [request, open] = await Promise.all([
      tx.get(requestRef),
      tx.get(openRef),
    ]);
    if (
      request.data()?.status !== "pending" ||
      request.data()?.claimId !== claimId
    ) {
      throw new HttpsError("aborted", "Start request lease was lost.");
    }
    if (
      open.data()?.status !== "starting" ||
      open.data()?.claimId !== claimId
    ) {
      throw new HttpsError("aborted", "Open-session lease was lost.");
    }
    tx.create(sessionRef, {
      ...session,
      unseenRemainingAtAllocation: allocated.unseenRemaining,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.set(requestRef, {
      status: "ready",
      sessionId,
      claimId: null,
      leaseExpiresAtMs: null,
      completedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    tx.set(openRef, {
      status: "playing",
      sessionId,
      startRequestId,
      claimId: null,
      leaseExpiresAtMs: null,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  return {
    ok: true,
    view: projectLiveView({
      session,
      hand: allocated.definition,
      node: allocated.root,
    }),
    events: allocated.root.history,
  };
}

/** Applies one Hero action and resolves/caches its shared continuation. */
export async function submitLiveActionForUser(options: {
  uid: string;
  raw: unknown;
  apiKey: string;
  db?: Firestore;
}): Promise<SubmitLiveActionResult> {
  const db = options.db ?? getFirestore();
  const input = parseSubmitInput(options.raw);
  const sessionRef = sessionReference(db, options.uid, input.sessionId);
  const decisionRef = sessionRef.collection("decisions").doc(input.idempotencyKey);
  const decisionClaimId = randomUUID();
  const claimed = await db.runTransaction(async (tx) => {
    const [sessionSnapshot, decisionSnapshot] = await Promise.all([
      tx.get(sessionRef),
      tx.get(decisionRef),
    ]);
    if (decisionSnapshot.exists) {
      const decision = decisionSnapshot.data();
      if (!decisionCommandMatches(decision, input)) {
        throw new HttpsError(
          "already-exists",
          "idempotencyKey was reused for a different command.",
        );
      }
      if (decision?.status === "ready" && decision.result) {
        return {
          result: {
            ...(decision.result as SubmitLiveActionResult),
            replayed: true,
          },
        };
      }
      if (
        decision?.status === "pending" &&
        Number(decision.leaseExpiresAtMs ?? 0) > Date.now()
      ) {
        throw new HttpsError(
          "unavailable",
          "This decision is still resolving. Retry shortly.",
        );
      }
    }
    if (!sessionSnapshot.exists) {
      throw new HttpsError("not-found", "Live hand session not found.");
    }
    const session = sessionSnapshot.data() as LiveSessionDoc;
    validateSessionCommand(session, input);
    tx.set(decisionRef, {
      status: "pending",
      actionId: input.actionId,
      decisionId: input.decisionId,
      stateVersion: input.stateVersion,
      claimId: decisionClaimId,
      leaseExpiresAtMs: Date.now() + DECISION_LEASE_MS,
      createdAt: FieldValue.serverTimestamp(),
    });
    return {session};
  });
  if ("result" in claimed && claimed.result) return claimed.result;
  const session = claimed.session;

  try {
    const handRef = db
      .collection("liveTableSetups")
      .doc(session.setupKey)
      .collection("hands")
      .doc(session.handId);
    const nodeRef = handRef.collection("nodes").doc(session.stateHash);
    const [handSnapshot, nodeSnapshot] = await Promise.all([
      handRef.get(),
      nodeRef.get(),
    ]);
    const hand = handSnapshot.data()?.definition as
      LiveHandDefinition | undefined;
    if (!hand || !nodeSnapshot.exists) {
      throw new HttpsError("internal", "Live hand definition or node missing.");
    }
    const parent = preparedNodeFromData(nodeSnapshot.data()!);
    const edge = await getOrGenerateSharedEdge({
      db,
      handRef,
      hand,
      parent,
      actionId: input.actionId,
      apiKey: options.apiKey,
    });
    const nextSession: LiveSessionDoc = {
      ...session,
      stateHash: edge.child.stateHash,
      state: edge.child.state,
      history: edge.child.history,
      stateVersion: session.stateVersion + 1,
      status: edge.child.state.status,
      coaching: [...session.coaching, edge.coaching],
    };
    const result: SubmitLiveActionResult = {
      ok: true,
      view: projectLiveView({
        session: nextSession,
        hand,
        node: edge.child,
      }),
      events: edge.events,
      coaching: edge.coaching,
      replayed: false,
    };
    await db.runTransaction(async (tx) => {
      const [currentSession, currentDecision] = await Promise.all([
        tx.get(sessionRef),
        tx.get(decisionRef),
      ]);
      const current = currentSession.data() as LiveSessionDoc | undefined;
      if (
        !current ||
        current.stateVersion !== session.stateVersion ||
        current.stateHash !== session.stateHash
      ) {
        throw new HttpsError(
          "aborted",
          "Session advanced while this action was resolving.",
        );
      }
      if (
        currentDecision.data()?.status !== "pending" ||
        currentDecision.data()?.claimId !== decisionClaimId
      ) {
        throw new HttpsError("aborted", "Decision is no longer pending.");
      }
      tx.update(sessionRef, {
        stateHash: nextSession.stateHash,
        state: nextSession.state,
        history: nextSession.history,
        coaching: nextSession.coaching,
        stateVersion: nextSession.stateVersion,
        status: nextSession.status,
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.set(decisionRef, {
        status: "ready",
        result,
        claimId: null,
        leaseExpiresAtMs: null,
        completedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
      if (nextSession.status !== "playing") {
        completeLiveHandInTransaction({
          tx,
          db,
          uid: options.uid,
          session: nextSession,
          hand,
        });
      }
    });
    return result;
  } catch (error) {
    await db.runTransaction(async (tx) => {
      const decision = await tx.get(decisionRef);
      if (
        decision.data()?.status !== "pending" ||
        decision.data()?.claimId !== decisionClaimId
      ) {
        return;
      }
      tx.set(decisionRef, {
        status: "failed",
        claimId: null,
        leaseExpiresAtMs: null,
        error: error instanceof Error ? error.message : String(error),
        failedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
    });
    throw error;
  }
}

/** Returns the authoritative current view after a network interruption. */
export async function resumeLiveHandForUser(options: {
  uid: string;
  sessionId: string;
  clientVersion: string;
  db?: Firestore;
}): Promise<StartLiveHandResult> {
  const db = options.db ?? getFirestore();
  await assertLiveServiceAvailable(db, options.clientVersion);
  const sessionSnapshot = await sessionReference(
    db,
    options.uid,
    options.sessionId,
  ).get();
  if (!sessionSnapshot.exists) {
    throw new HttpsError("not-found", "Live hand session not found.");
  }
  const session = sessionSnapshot.data() as LiveSessionDoc;
  const handRef = db
    .collection("liveTableSetups")
    .doc(session.setupKey)
    .collection("hands")
    .doc(session.handId);
  const [handSnapshot, nodeSnapshot] = await Promise.all([
    handRef.get(),
    handRef.collection("nodes").doc(session.stateHash).get(),
  ]);
  const hand = handSnapshot.data()?.definition as LiveHandDefinition | undefined;
  if (!hand || !nodeSnapshot.exists) {
    throw new HttpsError("internal", "Live hand state unavailable.");
  }
  const node = preparedNodeFromData(nodeSnapshot.data()!);
  return {
    ok: true,
    view: projectLiveView({session, hand, node}),
    events: [],
  };
}

async function getOrGenerateSharedEdge(options: {
  db: Firestore;
  handRef: FirebaseFirestore.DocumentReference;
  hand: LiveHandDefinition;
  parent: PreparedLiveNode;
  actionId: string;
  apiKey: string;
}): Promise<PreparedLiveEdge> {
  const parentRef = options.handRef.collection("nodes").doc(
    options.parent.stateHash,
  );
  const edgeRef = parentRef.collection("actions").doc(
    actionDocId(options.actionId),
  );
  const leaseId = randomUUID();
  const claim = await options.db.runTransaction(async (tx) => {
    const edge = await tx.get(edgeRef);
    if (edge.exists && edge.data()?.status === "ready") {
      return {ready: edge.data()};
    }
    if (
      edge.exists &&
      edge.data()?.status === "generating" &&
      Number(edge.data()?.leaseExpiresAtMs ?? 0) > Date.now()
    ) {
      throw new HttpsError(
        "unavailable",
        "Another player is resolving this shared branch. Retry shortly.",
      );
    }
    tx.set(edgeRef, {
      status: "generating",
      actionId: options.actionId,
      leaseId,
      leaseExpiresAtMs: Date.now() + EDGE_LEASE_MS,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    return {ready: null};
  });
  if (claim.ready) {
    return readPreparedEdge(options.handRef, options.parent, claim.ready);
  }
  let usage = emptyLiveUsageBreakdown();
  try {
    const expanded = await expandLiveHeroAction({
      apiKey: options.apiKey,
      hand: options.hand,
      parent: options.parent,
      actionId: options.actionId,
    });
    usage = expanded.usage;
    const childRef = options.handRef.collection("nodes").doc(
      expanded.child.stateHash,
    );
    const setupKey = String(options.hand.setupKey);
    const setupRef = options.db.collection("liveTableSetups").doc(setupKey);
    const usageFields = liveUsageFirestoreFields(expanded.usage);
    const committed = await options.db.runTransaction(async (tx) => {
      const edge = await tx.get(edgeRef);
      if (
        edge.data()?.status !== "generating" ||
        edge.data()?.leaseId !== leaseId
      ) {
        return false;
      }
      tx.set(childRef, {
        stateHash: expanded.child.stateHash,
        state: expanded.child.state,
        history: expanded.child.history,
        legalActions: expanded.child.legalActions,
        rubric: expanded.child.rubric,
        createdAt: FieldValue.serverTimestamp(),
      });
      tx.set(edgeRef, {
        status: "ready",
        actionId: expanded.actionId,
        childStateHash: expanded.child.stateHash,
        events: expanded.events,
        coaching: expanded.coaching,
        modelId: LIVE_GEMINI_MODEL,
        ...usageFields,
        leaseId: null,
        leaseExpiresAtMs: null,
        generatedAt: FieldValue.serverTimestamp(),
      });
      tx.set(
        options.handRef,
        {
          runtimeUsage: liveGenerationMetricsIncrements({
            usage: expanded.usage,
            expandCount: 1,
          }),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
      tx.set(
        setupRef,
        {
          generationMetrics: liveGenerationMetricsIncrements({
            usage: expanded.usage,
            expandCount: 1,
          }),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
      return true;
    });
    if (!committed) {
      throw new HttpsError(
        "unavailable",
        "Shared branch lease changed. Retry shortly.",
      );
    }
    return expanded;
  } catch (error) {
    const failedUsage = liveUsageFromError(error);
    if (failedUsage.total.modelRequestCount > 0) {
      usage = failedUsage;
    }
    const usageFields = liveUsageFirestoreFields(usage);
    await options.db.runTransaction(async (tx) => {
      const edge = await tx.get(edgeRef);
      if (
        edge.data()?.status !== "generating" ||
        edge.data()?.leaseId !== leaseId
      ) {
        return;
      }
      tx.set(edgeRef, {
        status: "failed",
        leaseId: null,
        leaseExpiresAtMs: null,
        modelId: LIVE_GEMINI_MODEL,
        ...usageFields,
        error: error instanceof Error ? error.message : String(error),
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
      if (usage.total.modelRequestCount > 0) {
        const setupKey = String(options.hand.setupKey);
        tx.set(
          options.db.collection("liveTableSetups").doc(setupKey),
          {
            generationMetrics: liveGenerationMetricsIncrements({
              usage,
            }),
            updatedAt: FieldValue.serverTimestamp(),
          },
          {merge: true},
        );
      }
    });
    throw error;
  }
}

async function readPreparedEdge(
  handRef: FirebaseFirestore.DocumentReference,
  parent: PreparedLiveNode,
  edge: DocumentData,
): Promise<PreparedLiveEdge> {
  const childHash = String(edge.childStateHash ?? "");
  const child = await handRef.collection("nodes").doc(childHash).get();
  if (!child.exists) throw new Error("shared edge child node missing");
  return {
    parentStateHash: parent.stateHash,
    actionId: String(edge.actionId),
    child: preparedNodeFromData(child.data()!),
    events: edge.events as LiveActionEvent[],
    coaching: edge.coaching,
    usage: edge.generationUsage ?
      {
        total: edge.generationUsage,
        byPurpose: edge.usageByPurpose ?? emptyLiveUsageBreakdown().byPurpose,
      } :
      emptyLiveUsageBreakdown(),
  };
}

function projectLiveView(options: {
  session: LiveSessionDoc;
  hand: LiveHandDefinition;
  node: PreparedLiveNode;
}): LiveHandView {
  const {session, hand, node} = options;
  const showdown = node.state.terminalReason === "showdown";
  const seats: LiveSeatView[] = hand.seats.map((definition) => {
    const player = node.state.players[definition.seat];
    const reveal = definition.seat === hand.setup.heroSeat ||
      (showdown && !player.folded);
    const lastAction = visibleLastAction(player, node.state.highestBet);
    return {
      seat: definition.seat,
      name: definition.name,
      archetype: definition.archetype,
      stack: player.stack,
      streetBet: player.streetBet,
      folded: player.folded,
      allIn: player.allIn,
      ...(lastAction === undefined ? {} : {lastAction}),
      ...(reveal ? {holeCards: definition.holeCards} : {}),
      ...(definition.tendency === undefined ?
        {} :
        {tendency: definition.tendency}),
    };
  });
  return {
    sessionId: session.sessionId,
    handId: hand.handId,
    setupKey: hand.setupKey,
    decisionId: node.stateHash,
    stateVersion: session.stateVersion,
    smallBlind: hand.setup.smallBlind,
    bigBlind: hand.setup.bigBlind,
    street: node.state.street,
    board: [...node.state.board],
    pot: livePotSize(node.state),
    buttonSeat: hand.buttonSeat,
    heroSeat: hand.setup.heroSeat,
    actorSeat: node.state.actorSeat,
    status: node.state.status,
    ...(node.state.terminalReason === undefined ?
      {} :
      {terminalReason: node.state.terminalReason}),
    seats,
    legalActions:
      node.state.actorSeat === hand.setup.heroSeat ?
        node.legalActions :
        [],
    winnerSeats: [...node.state.winnerSeats],
    pots: node.state.pots.map((pot) => ({
      amount: pot.amount,
      eligibleSeats: [...pot.eligibleSeats],
      winnerSeats: [...pot.winnerSeats],
    })),
  };
}

function completeLiveHandInTransaction(options: {
  tx: FirebaseFirestore.Transaction;
  db: Firestore;
  uid: string;
  session: LiveSessionDoc;
  hand: LiveHandDefinition;
}): void {
  const receiptRef = options.db
    .collection("users")
    .doc(options.uid)
    .collection("liveHandReceipts")
    .doc(options.hand.handId);
  const historyRef = options.db
    .collection("users")
    .doc(options.uid)
    .collection("liveHandHistory")
    .doc(options.session.sessionId);
  const progressRef = options.db
    .collection("users")
    .doc(options.uid)
    .collection("liveProgress")
    .doc("main");
  const openRef = openSessionReference(options.db, options.uid);
  const hero = options.session.state.players[options.hand.setup.heroSeat];
  const start = options.hand.seats.find(
    (seat) => seat.seat === options.hand.setup.heroSeat,
  )!.startingStack;
  const heroNetChips = hero.stack - start;
  const heroNetBb = heroNetChips / options.hand.setup.bigBlind;
  const decisionProgress = qualitativeProgress(options.session, options.hand);
  const historyActions = options.session.history.map((event) => ({
    seat: event.seat,
    street: event.street,
    kind: event.kind,
    amountBb: (event.amountTo ?? 0) / options.hand.setup.bigBlind,
    isHero: event.seat === options.hand.setup.heroSeat,
    archetype: options.hand.seats.find(
      (seat) => seat.seat === event.seat,
    )?.archetype ?? "TAG",
  }));
  options.tx.set(receiptRef, {
    status: "completed",
    completedAt: FieldValue.serverTimestamp(),
    lastSessionId: options.session.sessionId,
    heroNetChips,
    heroNetBb,
  }, {merge: true});
  options.tx.set(historyRef, {
    sessionId: options.session.sessionId,
    handId: options.hand.handId,
    setupKey: options.hand.setupKey,
    actions: historyActions,
    status: options.session.status,
    heroNetChips,
    heroNetBb,
    heroSeat: options.hand.setup.heroSeat,
    wentToShowdown: options.session.state.terminalReason === "showdown",
    heroWon: options.session.state.winnerSeats.includes(
      options.hand.setup.heroSeat,
    ),
    finalPots: options.session.state.pots,
    winnerSeats: options.session.state.winnerSeats,
    coaching: options.session.coaching,
    completedAt: FieldValue.serverTimestamp(),
    createdAt: FieldValue.serverTimestamp(),
  });
  options.tx.set(progressRef, {
    handsPlayed: FieldValue.increment(1),
    netResultBb: FieldValue.increment(heroNetBb),
    decisionsReviewed: FieldValue.increment(options.session.coaching.length),
    recommendedOrStrong: FieldValue.increment(
      options.session.coaching.filter(
        (entry) => entry.rating === "recommended" || entry.rating === "strong",
      ).length,
    ),
    reasonable: FieldValue.increment(
      options.session.coaching.filter(
        (entry) => entry.rating === "reasonable",
      ).length,
    ),
    questionable: FieldValue.increment(
      options.session.coaching.filter(
        (entry) => entry.rating === "questionable",
      ).length,
    ),
    clearMistakes: FieldValue.increment(
      options.session.coaching.filter(
        (entry) => entry.rating === "clear_mistake",
      ).length,
    ),
    streetAccuracy: decisionProgress.streetAccuracy,
    archetypeAccuracy: decisionProgress.archetypeAccuracy,
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
  options.tx.delete(openRef);
}

function qualitativeProgress(
  session: LiveSessionDoc,
  hand: LiveHandDefinition,
): {
  streetAccuracy: Record<string, {
    played: FirebaseFirestore.FieldValue;
    correct: FirebaseFirestore.FieldValue;
  }>;
  archetypeAccuracy: Record<string, {
    played: FirebaseFirestore.FieldValue;
    correct: FirebaseFirestore.FieldValue;
    evBb: number;
  }>;
} {
  const heroEvents = session.history.filter(
    (event) => event.seat === hand.setup.heroSeat,
  );
  const streetCounts = new Map<string, {played: number; correct: number}>();
  const archetypeCounts = new Map<string, {played: number; correct: number}>();
  for (let index = 0; index < session.coaching.length; index++) {
    const coaching = session.coaching[index];
    const heroEvent = heroEvents[index];
    if (!heroEvent) continue;
    const correct =
      coaching.rating === "recommended" || coaching.rating === "strong";
    const street = streetCounts.get(heroEvent.street) ?? {played: 0, correct: 0};
    street.played++;
    if (correct) street.correct++;
    streetCounts.set(heroEvent.street, street);
    const precedingVillain = session.history
      .slice(0, session.history.indexOf(heroEvent))
      .reverse()
      .find((event) => event.seat !== hand.setup.heroSeat);
    const archetype = hand.seats.find(
      (seat) => seat.seat === precedingVillain?.seat,
    )?.archetype ?? hand.seats.find((seat) => seat.archetype !== "HERO")
      ?.archetype ?? "TAG";
    const archetypeCount = archetypeCounts.get(archetype) ??
      {played: 0, correct: 0};
    archetypeCount.played++;
    if (correct) archetypeCount.correct++;
    archetypeCounts.set(archetype, archetypeCount);
  }
  return {
    streetAccuracy: Object.fromEntries(
      [...streetCounts.entries()].map(([street, counts]) => [
        street,
        {
          played: FieldValue.increment(counts.played),
          correct: FieldValue.increment(counts.correct),
        },
      ]),
    ),
    archetypeAccuracy: Object.fromEntries(
      [...archetypeCounts.entries()].map(([archetype, counts]) => [
        archetype,
        {
          played: FieldValue.increment(counts.played),
          correct: FieldValue.increment(counts.correct),
          evBb: 0,
        },
      ]),
    ),
  };
}

async function assertLiveServiceAvailable(
  db: Firestore,
  clientVersion: string,
): Promise<void> {
  const config = await db.doc("system/liveConfig").get();
  const data = config.data() ?? {};
  if (data.maintenance === true) {
    throw new HttpsError(
      "failed-precondition",
      String(data.message ?? "Training is temporarily under maintenance."),
    );
  }
  const minimum = typeof data.minClientVersion === "string" ?
    data.minClientVersion :
    MIN_LIVE_CLIENT_VERSION;
  if (compareVersions(clientVersion, minimum) < 0) {
    throw new HttpsError(
      "failed-precondition",
      "A newer app version is required to train.",
    );
  }
}

function validateSessionCommand(
  session: LiveSessionDoc,
  input: SubmitLiveActionInput,
): void {
  if (session.handId !== input.handId) {
    throw new HttpsError("invalid-argument", "handId does not match session.");
  }
  if (session.status !== "playing") {
    throw new HttpsError("failed-precondition", "This hand has ended.");
  }
  if (session.stateVersion !== input.stateVersion) {
    throw new HttpsError("aborted", "Stale state version. Resume the hand.");
  }
  if (session.stateHash !== input.decisionId) {
    throw new HttpsError("aborted", "Stale decision id. Resume the hand.");
  }
}

function parseSubmitInput(raw: unknown): SubmitLiveActionInput {
  const data = record(raw, "request");
  const idempotencyKey = nonEmpty(data.idempotencyKey, "idempotencyKey");
  if (!/^[A-Za-z0-9_-]{8,100}$/.test(idempotencyKey)) {
    throw new HttpsError(
      "invalid-argument",
      "idempotencyKey must be 8-100 URL-safe characters.",
    );
  }
  const stateVersion = data.stateVersion;
  if (
    typeof stateVersion !== "number" ||
    !Number.isInteger(stateVersion) ||
    stateVersion < 0
  ) {
    throw new HttpsError("invalid-argument", "stateVersion must be >= 0.");
  }
  return {
    sessionId: nonEmpty(data.sessionId, "sessionId"),
    handId: nonEmpty(data.handId, "handId"),
    stateVersion,
    decisionId: nonEmpty(data.decisionId, "decisionId"),
    idempotencyKey,
    actionId: nonEmpty(data.actionId, "actionId"),
  };
}

function decisionCommandMatches(
  data: DocumentData | undefined,
  input: SubmitLiveActionInput,
): boolean {
  if (!data) return true;
  return data.actionId === input.actionId &&
    data.decisionId === input.decisionId &&
    Number(data.stateVersion) === input.stateVersion;
}

async function recoverAllocatedStart(options: {
  db: Firestore;
  uid: string;
  startRequestId: string;
  sessionId: string;
  requestRef: FirebaseFirestore.DocumentReference;
  openRef: FirebaseFirestore.DocumentReference;
  claimId: string;
}): Promise<StartLiveHandResult | null> {
  const receiptSnapshot = await options.db
    .collection("users")
    .doc(options.uid)
    .collection("liveHandReceipts")
    .where("startRequestId", "==", options.startRequestId)
    .limit(1)
    .get();
  if (receiptSnapshot.empty) return null;
  const receipt = receiptSnapshot.docs[0].data();
  const setupKey = String(receipt.setupKey ?? "");
  const handId = String(receipt.handId ?? receiptSnapshot.docs[0].id);
  const sessionId =
    typeof receipt.sessionId === "string" ?
      receipt.sessionId :
      options.sessionId;
  const handRef = options.db
    .collection("liveTableSetups")
    .doc(setupKey)
    .collection("hands")
    .doc(handId);
  const handSnapshot = await handRef.get();
  const definition = handSnapshot.data()?.definition as
    LiveHandDefinition | undefined;
  const rootHash = String(handSnapshot.data()?.rootStateHash ?? "");
  const rootSnapshot = await handRef.collection("nodes").doc(rootHash).get();
  if (!definition || !rootSnapshot.exists) {
    throw new HttpsError("internal", "Allocated live hand is incomplete.");
  }
  const root = preparedNodeFromData(rootSnapshot.data()!);
  const session: LiveSessionDoc = {
    sessionId,
    uid: options.uid,
    handId,
    setupKey,
    stateHash: root.stateHash,
    state: root.state,
    history: root.history,
    stateVersion: 0,
    status: root.state.status,
    coaching: [],
  };
  const sessionRef = sessionReference(options.db, options.uid, sessionId);
  await options.db.runTransaction(async (tx) => {
    const [request, open, existingSession] = await Promise.all([
      tx.get(options.requestRef),
      tx.get(options.openRef),
      tx.get(sessionRef),
    ]);
    if (
      request.data()?.status !== "pending" ||
      request.data()?.claimId !== options.claimId
    ) {
      throw new HttpsError("aborted", "Start request lease was lost.");
    }
    if (
      open.data()?.status !== "starting" ||
      open.data()?.claimId !== options.claimId
    ) {
      throw new HttpsError("aborted", "Open-session lease was lost.");
    }
    if (!existingSession.exists) {
      tx.create(sessionRef, {
        ...session,
        recovered: true,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    tx.set(options.requestRef, {
      status: "ready",
      sessionId,
      claimId: null,
      leaseExpiresAtMs: null,
      completedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    tx.set(options.openRef, {
      status: "playing",
      sessionId,
      startRequestId: options.startRequestId,
      claimId: null,
      leaseExpiresAtMs: null,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  return {
    ok: true,
    view: projectLiveView({session, hand: definition, node: root}),
    events: root.history,
  };
}

async function releaseStartClaim(options: {
  db: Firestore;
  requestRef: FirebaseFirestore.DocumentReference;
  openRef: FirebaseFirestore.DocumentReference;
  claimId: string;
  error: unknown;
}): Promise<void> {
  await options.db.runTransaction(async (tx) => {
    const [snapshot, open] = await Promise.all([
      tx.get(options.requestRef),
      tx.get(options.openRef),
    ]);
    if (
      snapshot.data()?.status !== "pending" ||
      snapshot.data()?.claimId !== options.claimId
    ) {
      return;
    }
    tx.set(options.requestRef, {
      status: "failed",
      claimId: null,
      leaseExpiresAtMs: null,
      error: options.error instanceof Error ?
        options.error.message :
        String(options.error),
      failedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    if (
      open.data()?.status === "starting" &&
      open.data()?.claimId === options.claimId
    ) {
      tx.delete(options.openRef);
    }
  });
}

function safeCommandKey(value: unknown, field: string): string {
  const key = nonEmpty(value, field);
  if (!/^[A-Za-z0-9_-]{8,100}$/.test(key)) {
    throw new HttpsError(
      "invalid-argument",
      `${field} must be 8-100 URL-safe characters.`,
    );
  }
  return key;
}

function sessionReference(db: Firestore, uid: string, sessionId: string) {
  return db
    .collection("users")
    .doc(uid)
    .collection("liveSessions")
    .doc(sessionId);
}

function openSessionReference(db: Firestore, uid: string) {
  return db
    .collection("users")
    .doc(uid)
    .collection("liveOpenSession")
    .doc("main");
}

function record(raw: unknown, field: string): Record<string, unknown> {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new HttpsError("invalid-argument", `${field} must be an object.`);
  }
  return raw as Record<string, unknown>;
}

function nonEmpty(value: unknown, field: string): string {
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  return value.trim();
}

function compareVersions(left: string, right: string): number {
  const parse = (value: string): number[] =>
    value.split(".").slice(0, 3).map((part) => Number.parseInt(part, 10) || 0);
  const a = parse(left);
  const b = parse(right);
  for (let index = 0; index < 3; index++) {
    if ((a[index] ?? 0) !== (b[index] ?? 0)) {
      return (a[index] ?? 0) - (b[index] ?? 0);
    }
  }
  return 0;
}
