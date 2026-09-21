/**
 * Firestore-emulator integration for start/action idempotency and serialization.
 */

import {deleteApp, getApp, getApps, initializeApp} from "firebase-admin/app";
import {getFirestore, type Firestore} from "firebase-admin/firestore";
import {afterAll, afterEach, beforeAll, describe, expect, test} from "vitest";
import {
  applyLiveAction,
  createInitialLiveState,
  hashLiveState,
  legalLiveActions,
} from "./live_poker_engine";
import {
  actionDocId,
  recoverExpiredLiveGenerationLeases,
  refillQueuedLiveSetup,
} from "./live_pool";
import {
  startLiveHandForUser,
  submitLiveActionForUser,
  undoLiveActionForUser,
} from "./live_session";
import {buildLiveSetupKey, DEFAULT_LIVE_SETUP} from "./live_setup";
import {
  COACHING_SCHEMA_VERSION,
  LIVE_PAYLOAD_VERSION,
  type CoachingRubric,
  type LiveHandDefinition,
} from "./live_types";

const PROJECT_ID = "live-poker-trainer-rules-test";
const APP_NAME = "live-session-emulator-tests";
let db: Firestore;

function hand(): LiveHandDefinition {
  const setup = {...DEFAULT_LIVE_SETUP, seatCount: 2};
  return {
    payloadVersion: LIVE_PAYLOAD_VERSION,
    schemaVersion: "live-hand-v3.0",
    handId: "emulator-hand",
    setupKey: buildLiveSetupKey(setup),
    setup,
    buttonSeat: 0,
    seats: [
      {
        seat: 0,
        name: "Hero",
        archetype: "HERO",
        startingStack: 400,
        holeCards: ["Ah", "Qd"],
      },
      {
        seat: 1,
        name: "Alex",
        archetype: "TAG",
        startingStack: 400,
        holeCards: ["Ks", "Kh"],
      },
    ],
    runout: ["2c", "3d", "4h", "8s", "9c"],
    source: "gemini",
    modelId: "test",
  };
}

async function seedReadyHand(): Promise<{
  definition: LiveHandDefinition;
  rootHash: string;
  foldActionId: string;
}> {
  const definition = hand();
  const state = createInitialLiveState(definition);
  const legalActions = legalLiveActions(definition, state);
  const rootHash = hashLiveState(state, []);
  const assessments = legalActions.map((action, index) => ({
    actionId: action.actionId,
    rating: index === 0 ? "recommended" as const : "reasonable" as const,
    confidence: "medium" as const,
    summary: "Emulator coaching.",
    playerTypeReason: "Uses the visible profile.",
    sizingNote: "Fixed legal size.",
    tendencyKeys: ["pfr"],
  }));
  const rubric: CoachingRubric = {
    schemaVersion: COACHING_SCHEMA_VERSION,
    stateHash: rootHash,
    assessments,
    generatedBy: "test",
    criticModel: "test",
  };
  const foldActionId = legalActions.find((action) => action.kind === "FOLD")!
    .actionId;
  const folded = applyLiveAction({
    hand: definition,
    state,
    actionId: foldActionId,
  });
  const childHistory = [folded.event];
  const childHash = hashLiveState(folded.state, childHistory);
  const setupRef = db.collection("liveTableSetups").doc(definition.setupKey);
  const handRef = setupRef.collection("hands").doc(definition.handId);
  await setupRef.set({
    setupKey: definition.setupKey,
    setup: definition.setup,
    handCount: 10,
    generation: {
      status: "idle",
      leaseId: null,
      leaseExpiresAtMs: null,
      requestedBatch: 10,
    },
  });
  await handRef.set({
    handId: definition.handId,
    setupKey: definition.setupKey,
    definition,
    status: "ready",
    rootStateHash: rootHash,
    warmBranchCount: 3,
    timesServed: 0,
  });
  await handRef.collection("nodes").doc(rootHash).set({
    stateHash: rootHash,
    state,
    history: [],
    legalActions,
    rubric,
  });
  await handRef.collection("nodes").doc(childHash).set({
    stateHash: childHash,
    state: folded.state,
    history: childHistory,
    legalActions: [],
    rubric: null,
  });
  await handRef
    .collection("nodes")
    .doc(rootHash)
    .collection("actions")
    .doc(actionDocId(foldActionId))
    .set({
      status: "ready",
      actionId: foldActionId,
      childStateHash: childHash,
      events: childHistory,
      coaching: assessments.find(
        (assessment) => assessment.actionId === foldActionId,
      ),
    });
  await db.doc("system/liveConfig").set({
    maintenance: false,
    minClientVersion: "2.0.0",
    rolloutCutoffMs: Date.parse("2099-01-01T00:00:00.000Z"),
  });
  await db.doc("users/user-1/entitlements/liveTraining").set({
    unrestrictedAccess: true,
    source: "admin",
    grantedAtMs: Date.now(),
  });
  return {definition, rootHash, foldActionId};
}

beforeAll(() => {
  const existing = getApps().find((app) => app.name === APP_NAME);
  const app = existing ?? initializeApp({projectId: PROJECT_ID}, APP_NAME);
  db = getFirestore(app);
});

afterEach(async () => {
  const host = process.env.FIRESTORE_EMULATOR_HOST;
  if (!host) throw new Error("FIRESTORE_EMULATOR_HOST is required");
  await fetch(
    `http://${host}/emulator/v1/projects/${PROJECT_ID}` +
      "/databases/(default)/documents",
    {method: "DELETE"},
  );
});

afterAll(async () => {
  if (getApps().some((app) => app.name === APP_NAME)) {
    await deleteApp(getApp(APP_NAME));
  }
});

describe("live session integration", () => {
  test("atomically fans out ten jobs and recovers an expired setup lease", async () => {
    const setupKey = buildLiveSetupKey(DEFAULT_LIVE_SETUP);
    const setupRef = db.collection("liveTableSetups").doc(setupKey);
    await setupRef.set({
      setupKey,
      setup: DEFAULT_LIVE_SETUP,
      handCount: 0,
      generation: {
        status: "queued",
        leaseId: null,
        leaseExpiresAtMs: null,
        requestedBatch: 10,
      },
    });
    const queued = await refillQueuedLiveSetup({setupKey, db});
    expect(queued.queued).toBe(10);
    expect((await db.collection("liveGenerationJobs").get()).size).toBe(10);
    expect((await setupRef.get()).data()?.generation?.status).toBe("generating");

    await setupRef.update({"generation.leaseExpiresAtMs": 1});
    expect(await recoverExpiredLiveGenerationLeases({db, nowMs: 2})).toBe(1);
    expect((await setupRef.get()).data()?.generation?.status).toBe("queued");
  });

  test("start retries return one allocated session", async () => {
    await seedReadyHand();
    const raw = {
      clientVersion: "2.0.0",
      startRequestId: "start_request_1",
      tableSetup: {...DEFAULT_LIVE_SETUP, seatCount: 2},
    };
    const first = await startLiveHandForUser({uid: "user-1", raw, db});
    const second = await startLiveHandForUser({uid: "user-1", raw, db});

    expect(second.view.sessionId).toBe(first.view.sessionId);
    const receipts = await db
      .collection("users/user-1/liveHandReceipts")
      .get();
    const sessions = await db.collection("users/user-1/liveSessions").get();
    expect(receipts.size).toBe(1);
    expect(sessions.size).toBe(1);
  });

  test("different concurrent start keys still produce one open session", async () => {
    await seedReadyHand();
    const start = (startRequestId: string) => startLiveHandForUser({
      uid: "user-1",
      db,
      raw: {
        clientVersion: "2.0.0",
        startRequestId,
        tableSetup: {...DEFAULT_LIVE_SETUP, seatCount: 2},
      },
    });
    const attempts = await Promise.allSettled([
      start("concurrent_start_1"),
      start("concurrent_start_2"),
    ]);
    const fulfilled = attempts.filter(
      (attempt): attempt is PromiseFulfilledResult<
        Awaited<ReturnType<typeof start>>
      > => attempt.status === "fulfilled",
    );
    expect(fulfilled.length).toBeGreaterThanOrEqual(1);
    expect(new Set(fulfilled.map((attempt) => attempt.value.view.sessionId)).size)
      .toBe(1);
    const resumed = await start("concurrent_start_2");
    const first = fulfilled[0].value;
    expect(resumed.view.sessionId).toBe(first.view.sessionId);
    expect((await db.collection("users/user-1/liveSessions").get()).size).toBe(1);
  });

  test("decision retries replay once and reject key reuse", async () => {
    const seeded = await seedReadyHand();
    const started = await startLiveHandForUser({
      uid: "user-1",
      db,
      raw: {
        clientVersion: "2.0.0",
        startRequestId: "start_request_2",
        tableSetup: {...DEFAULT_LIVE_SETUP, seatCount: 2},
      },
    });
    const command = {
      sessionId: started.view.sessionId,
      handId: seeded.definition.handId,
      stateVersion: 0,
      decisionId: seeded.rootHash,
      idempotencyKey: "decision_key_1",
      actionId: seeded.foldActionId,
    };
    const first = await submitLiveActionForUser({
      uid: "user-1",
      raw: command,
      apiKey: "unused",
      db,
    });
    const replay = await submitLiveActionForUser({
      uid: "user-1",
      raw: command,
      apiKey: "unused",
      db,
    });
    expect(first.replayed).toBe(false);
    expect(replay.replayed).toBe(true);
    await expect(submitLiveActionForUser({
      uid: "user-1",
      raw: {...command, actionId: "CALL:200"},
      apiKey: "unused",
      db,
    })).rejects.toMatchObject({code: "already-exists"});
  });

  test("undo restores the parent decision after a completed fold", async () => {
    const seeded = await seedReadyHand();
    const started = await startLiveHandForUser({
      uid: "user-1",
      db,
      raw: {
        clientVersion: "2.0.0",
        startRequestId: "start_request_undo",
        tableSetup: {...DEFAULT_LIVE_SETUP, seatCount: 2},
      },
    });
    const submitted = await submitLiveActionForUser({
      uid: "user-1",
      raw: {
        sessionId: started.view.sessionId,
        handId: seeded.definition.handId,
        stateVersion: 0,
        decisionId: seeded.rootHash,
        idempotencyKey: "decision_key_undo",
        actionId: seeded.foldActionId,
      },
      apiKey: "unused",
      db,
    });
    expect(submitted.view.status).not.toBe("playing");
    expect(submitted.view.stateVersion).toBe(1);

    const undone = await undoLiveActionForUser({
      uid: "user-1",
      db,
      raw: {
        sessionId: started.view.sessionId,
        stateVersion: 1,
        clientVersion: "2.0.0",
      },
    });
    expect(undone.view.stateVersion).toBe(0);
    expect(undone.view.decisionId).toBe(seeded.rootHash);
    expect(undone.view.status).toBe("playing");
    expect(undone.view.legalActions.some(
      (action) => action.actionId === seeded.foldActionId,
    )).toBe(true);

    const sessionDoc = await db
      .doc(`users/user-1/liveSessions/${started.view.sessionId}`)
      .get();
    expect(sessionDoc.data()?.undoCheckpoint).toBeUndefined();
    expect(sessionDoc.data()?.stateVersion).toBe(0);

    const history = await db
      .doc(`users/user-1/liveHandHistory/${started.view.sessionId}`)
      .get();
    expect(history.exists).toBe(false);

    const open = await db.doc("users/user-1/liveOpenSession/main").get();
    expect(open.data()?.status).toBe("playing");
    expect(open.data()?.sessionId).toBe(started.view.sessionId);

    await expect(undoLiveActionForUser({
      uid: "user-1",
      db,
      raw: {
        sessionId: started.view.sessionId,
        stateVersion: 0,
        clientVersion: "2.0.0",
      },
    })).rejects.toMatchObject({code: "failed-precondition"});
  });

  test("course warm-up never writes live receipts or progress", async () => {
    await db.doc("system/liveConfig").set({
      maintenance: false,
      minClientVersion: "2.0.0",
      rolloutCutoffMs: Date.parse("2000-01-01T00:00:00.000Z"),
    });
    await db.doc("users/course-user/course/main").set({
      completedLessonIds: ["lesson-02-07-02-section-two-jump"],
    });
    const progressBefore = await db.doc("users/course-user/liveProgress/main")
      .get();
    const started = await startLiveHandForUser({
      uid: "course-user",
      db,
      accessDeps: {
        getUserCreatedAtMs: async () => Date.parse("2026-09-22T00:00:00.000Z"),
      },
      raw: {
        clientVersion: "2.0.0",
        startRequestId: "course_start_1",
        tableSetup: {mode: "course", courseKind: "warm_up"},
      },
    });
    expect(started.view.setupKey.startsWith("course-v1|")).toBe(true);
    const receipts = await db.collection("users/course-user/liveHandReceipts")
      .get();
    expect(receipts.size).toBe(0);
    const courseReceipts = await db
      .collection("users/course-user/courseLiveReceipts")
      .get();
    expect(courseReceipts.size).toBe(1);
    const liveSetups = await db.collection("liveTableSetups").get();
    expect(liveSetups.size).toBe(0);
    const progressAfter = await db.doc("users/course-user/liveProgress/main")
      .get();
    expect(progressAfter.exists).toBe(progressBefore.exists);
    expect(progressAfter.data() ?? null).toEqual(progressBefore.data() ?? null);
  });

  test("post-cutoff users without entitlement cannot start random live", async () => {
    await seedReadyHand();
    await expect(startLiveHandForUser({
      uid: "new-user",
      db,
      accessDeps: {
        getUserCreatedAtMs: async () => Date.parse("2099-06-01T00:00:00.000Z"),
      },
      raw: {
        clientVersion: "2.0.0",
        startRequestId: "blocked_start",
        tableSetup: {...DEFAULT_LIVE_SETUP, seatCount: 2},
      },
    })).rejects.toMatchObject({code: "permission-denied"});
  });
});
