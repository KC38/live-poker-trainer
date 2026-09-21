/**
 * Course ↔ Live Training bridge: isolated course pools, static warm roots,
 * attempt-token validation, and mastery callbacks that never touch liveProgress.
 */

import {randomUUID} from "node:crypto";
import {
  FieldValue,
  getFirestore,
  type Firestore,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {assertCourseLiveAccess, type LiveAccessDeps} from "./live_access";
import {
  CALIBRATION_LAUNCH_LESSON_ID,
  calibrationResultNodeId,
  curatedCourseHandById,
  curatedCourseHandForLab,
  isCourseSetupKey,
  pickCalibrationHand,
  pickWarmUpHand,
  type CuratedCourseHand,
} from "./course_live_hands";
import {courseBank, findLesson} from "./course_catalog";
import {
  completeCourseLessonForUser,
  startCourseLessonForUser,
  type CompleteCourseLessonResult,
} from "./course_session";
import {
  applyLiveAction,
  createInitialLiveState,
  hashLiveState,
  legalLiveActions,
  liveHeroToAct,
} from "./live_poker_engine";
import type {PreparedLiveNode} from "./live_tree";
import {
  COACHING_SCHEMA_VERSION,
  type CoachingActionAssessment,
  type CoachingRubric,
  type LiveActionEvent,
  type LiveHandDefinition,
  type LiveHandState,
  type LiveLegalAction,
  type LiveTableSetup,
} from "./live_types";

export const COURSE_LIVE_COLLECTION = "courseLiveSetups";

export interface CourseSessionContext {
  attemptId?: string;
  activityId?: string;
  lessonId?: string;
  handLabSpecId?: string;
  returnNodeId?: string;
  courseHandId: string;
  maxDecisions: number;
  decisionCount: number;
  scaffolding: "full" | "reduced" | "none";
  rexPrompt: string;
  kind: CuratedCourseHand["kind"];
}

export interface CourseTableSetupInput {
  mode: "course";
  /** warm_up | calibration | hand_lab */
  courseKind?: "warm_up" | "calibration" | "hand_lab";
  courseHandId?: string;
  handLabSpecId?: string;
  attemptId?: string;
  activityId?: string;
  lessonId?: string;
  returnNodeId?: string;
  seatCount?: number;
  smallBlind?: number;
  bigBlind?: number;
  maxStackDepthBb?: number;
  heroSeat?: number;
}

export interface AllocatedCourseHand {
  definition: LiveHandDefinition;
  root: PreparedLiveNode;
  setupKey: string;
  curated: CuratedCourseHand;
  courseContext: CourseSessionContext;
}

/** Parses course-mode tableSetup from the callable payload. */
export function parseCourseTableSetup(raw: unknown): CourseTableSetupInput {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new HttpsError("invalid-argument", "tableSetup must be an object.");
  }
  const data = raw as Record<string, unknown>;
  if (data.mode !== "course") {
    throw new HttpsError("invalid-argument", "Expected course tableSetup.mode.");
  }
  const courseKind = data.courseKind;
  if (
    courseKind != null &&
    courseKind !== "warm_up" &&
    courseKind !== "calibration" &&
    courseKind !== "hand_lab"
  ) {
    throw new HttpsError("invalid-argument", "Invalid courseKind.");
  }
  return {
    mode: "course",
    courseKind: courseKind as CourseTableSetupInput["courseKind"],
    courseHandId: optionalString(data.courseHandId),
    handLabSpecId: optionalString(data.handLabSpecId),
    attemptId: optionalString(data.attemptId),
    activityId: optionalString(data.activityId),
    lessonId: optionalString(data.lessonId),
    returnNodeId: optionalString(data.returnNodeId),
  };
}

/** True when the client requested course isolation mode. */
export function isCourseModeRequest(raw: unknown): boolean {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) return false;
  return (raw as {mode?: unknown}).mode === "course";
}

/**
 * Allocates one curated course hand under courseLiveSetups.
 * Never reads or writes liveHandReceipts / liveTableSetups pools.
 */
export async function allocateCourseHandForUser(options: {
  uid: string;
  rawSetup: unknown;
  sessionId: string;
  startRequestId: string;
  db?: Firestore;
  accessDeps?: LiveAccessDeps;
}): Promise<AllocatedCourseHand> {
  const db = options.db ?? getFirestore();
  await assertCourseLiveAccess(options.uid, {
    db,
    ...options.accessDeps,
  });
  const input = parseCourseTableSetup(options.rawSetup);
  const curated = resolveCuratedHand(input);
  if (input.attemptId) {
    await assertValidCourseAttemptToken({
      db,
      uid: options.uid,
      attemptId: input.attemptId,
      activityId: input.activityId,
      lessonId: input.lessonId,
    });
  }

  const definition = curated.definition;
  const setupKey = definition.setupKey;
  if (!isCourseSetupKey(setupKey)) {
    throw new HttpsError("internal", "Course hand missing course setup key.");
  }

  const root = await ensureCourseHandReady(db, curated);
  const courseContext: CourseSessionContext = {
    attemptId: input.attemptId,
    activityId: input.activityId,
    lessonId: input.lessonId ?? curated.launchLessonId,
    handLabSpecId: curated.handLabSpecId ?? input.handLabSpecId,
    returnNodeId: courseReturnNodeId({
      courseKind: curated.kind,
      lessonId: input.lessonId ?? curated.launchLessonId,
      returnNodeId: input.returnNodeId,
    }),
    courseHandId: definition.handId,
    maxDecisions: curated.maxDecisions,
    decisionCount: 0,
    scaffolding: curated.scaffolding,
    rexPrompt: curated.rexPrompt,
    kind: curated.kind,
  };

  // Course receipt under a separate collection — never liveHandReceipts.
  const receiptRef = db
    .collection("users")
    .doc(options.uid)
    .collection("courseLiveReceipts")
    .doc(`${options.startRequestId}_${definition.handId}`);
  await receiptRef.set({
    handId: definition.handId,
    setupKey,
    sessionId: options.sessionId,
    startRequestId: options.startRequestId,
    kind: curated.kind,
    attemptId: courseContext.attemptId ?? null,
    createdAt: FieldValue.serverTimestamp(),
  }, {merge: true});

  return {definition, root, setupKey, curated, courseContext};
}

/** Loads a prepared course node from courseLiveSetups. */
export async function loadCoursePreparedNode(options: {
  db: Firestore;
  setupKey: string;
  handId: string;
  stateHash: string;
}): Promise<{hand: LiveHandDefinition; node: PreparedLiveNode}> {
  const handRef = options.db
    .collection(COURSE_LIVE_COLLECTION)
    .doc(options.setupKey)
    .collection("hands")
    .doc(options.handId);
  const [handSnap, nodeSnap] = await Promise.all([
    handRef.get(),
    handRef.collection("nodes").doc(options.stateHash).get(),
  ]);
  const hand = handSnap.data()?.definition as LiveHandDefinition | undefined;
  if (!hand || !nodeSnap.exists) {
    throw new HttpsError("internal", "Course hand definition or node missing.");
  }
  return {hand, node: preparedNodeFromData(nodeSnap.data()!)};
}

/**
 * Expands one Hero action with deterministic villains + static coaching.
 * Caps decisions per lesson stage; never touches live progress docs.
 */
export async function expandCourseHeroAction(options: {
  db: Firestore;
  uid: string;
  hand: LiveHandDefinition;
  parent: PreparedLiveNode;
  actionId: string;
  courseContext: CourseSessionContext;
  curated: CuratedCourseHand;
}): Promise<{
  child: PreparedLiveNode;
  events: LiveActionEvent[];
  coaching: CoachingActionAssessment;
  courseContext: CourseSessionContext;
  courseStepRecorded: boolean;
}> {
  const selected = options.parent.legalActions.find(
    (candidate) => candidate.actionId === options.actionId,
  );
  if (!selected) {
    throw new HttpsError("invalid-argument", "Action is not legal.");
  }
  const coaching = assessmentForCourseAction(
    options.curated,
    options.parent.rubric,
    options.actionId,
    selected,
  );
  const applied = applyLiveAction({
    hand: options.hand,
    state: options.parent.state,
    actionId: options.actionId,
  });
  let state = applied.state;
  let history = [...options.parent.history, applied.event];
  const parentLen = options.parent.history.length;

  // Deterministic villains — no Gemini, no live pool writes.
  while (
    state.status === "playing" &&
    typeof state.actorSeat === "number" &&
    !liveHeroToAct(options.hand, state)
  ) {
    const legal = legalLiveActions(options.hand, state);
    const villainAction = pickDeterministicVillainAction(legal);
    const next = applyLiveAction({
      hand: options.hand,
      state,
      actionId: villainAction.actionId,
    });
    state = next.state;
    history = [...history, next.event];
  }

  const legalActions = state.status === "playing" ?
    legalLiveActions(options.hand, state) :
    [];
  const stateHash = hashLiveState(state, history);
  const decisionCount = options.courseContext.decisionCount + 1;
  const capped = decisionCount >= options.courseContext.maxDecisions;
  const forceComplete = capped && state.status === "playing";
  const finalState: LiveHandState = forceComplete ?
    {...state, status: "complete", terminalReason: "fold", actorSeat: null} :
    state;
  const finalLegal = forceComplete ? [] : legalActions;
  const rubric = finalState.status === "playing" &&
      liveHeroToAct(options.hand, finalState) ?
    buildStaticRubric(options.curated, finalLegal, stateHash) :
    null;

  const child: PreparedLiveNode = {
    stateHash: forceComplete ? hashLiveState(finalState, history) : stateHash,
    state: finalState,
    history,
    legalActions: finalLegal,
    rubric,
  };

  const handRef = options.db
    .collection(COURSE_LIVE_COLLECTION)
    .doc(options.hand.setupKey)
    .collection("hands")
    .doc(options.hand.handId);
  await handRef.collection("nodes").doc(child.stateHash).set({
    stateHash: child.stateHash,
    state: child.state,
    history: child.history,
    legalActions: child.legalActions,
    rubric: child.rubric,
  });
  await handRef
    .collection("nodes")
    .doc(options.parent.stateHash)
    .collection("actions")
    .doc(actionDocId(options.actionId))
    .set({
      status: "ready",
      actionId: options.actionId,
      childStateHash: child.stateHash,
      events: history.slice(parentLen),
      coaching,
    }, {merge: true});

  const nextContext: CourseSessionContext = {
    ...options.courseContext,
    decisionCount,
  };

  let courseStepRecorded = false;
  if (options.courseContext.attemptId && options.courseContext.activityId) {
    courseStepRecorded = await recordCourseLiveDecision({
      db: options.db,
      uid: options.uid,
      context: nextContext,
      coaching,
      actionId: options.actionId,
    });
  }

  return {
    child,
    events: history.slice(parentLen),
    coaching,
    courseContext: nextContext,
    courseStepRecorded,
  };
}

/**
 * Course hand completion — writes courseLiveHistory only.
 * Explicitly does not write liveProgress / liveHandHistory / liveHandReceipts.
 */
export function courseCompletionWrites(): {
  liveProgress: false;
  liveHandHistory: false;
  liveHandReceipts: false;
  courseLiveHistory: true;
} {
  return {
    liveProgress: false,
    liveHandHistory: false,
    liveHandReceipts: false,
    courseLiveHistory: true,
  };
}

export async function writeCourseLiveHistory(options: {
  db: Firestore;
  uid: string;
  sessionId: string;
  hand: LiveHandDefinition;
  courseContext: CourseSessionContext;
  coaching: CoachingActionAssessment[];
}): Promise<void> {
  await options.db
    .collection("users")
    .doc(options.uid)
    .collection("courseLiveHistory")
    .doc(options.sessionId)
    .set({
      sessionId: options.sessionId,
      handId: options.hand.handId,
      setupKey: options.hand.setupKey,
      kind: options.courseContext.kind,
      attemptId: options.courseContext.attemptId ?? null,
      activityId: options.courseContext.activityId ?? null,
      lessonId: options.courseContext.lessonId ?? null,
      returnNodeId: options.courseContext.returnNodeId ?? null,
      decisionCount: options.courseContext.decisionCount,
      coachingCount: options.coaching.length,
      isolation: courseCompletionWrites(),
      completedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
}

/**
 * Calibration resumes the lesson result node, never the lesson id itself.
 * Other course kinds keep the caller-supplied return node.
 */
export function courseReturnNodeId(input: {
  courseKind?: string;
  lessonId?: string;
  returnNodeId?: string;
}): string | undefined {
  if (
    input.courseKind === "calibration" ||
    input.lessonId === CALIBRATION_LAUNCH_LESSON_ID
  ) {
    return calibrationResultNodeId(
      input.lessonId ?? CALIBRATION_LAUNCH_LESSON_ID,
    );
  }
  return input.returnNodeId;
}

/**
 * A calibration lesson may be marked complete only after that hand was
 * actually finished (courseLiveHistory). Abandoning the table must not pass.
 */
export function calibrationHistoryAllowsComplete(
  history: {kind?: unknown; lessonId?: unknown} | null | undefined,
  lessonId: string,
): boolean {
  if (!history) return false;
  return history.kind === "calibration" &&
    history.lessonId === lessonId &&
    lessonId === CALIBRATION_LAUNCH_LESSON_ID;
}

/**
 * Marks the Section 7 calibration lesson complete after its live hand.
 * Refuses when the hand was never finished, so header-back abandon cannot
 * complete the lesson.
 */
export async function completeCalibrationWarmUpForUser(options: {
  uid: string;
  raw: unknown;
  isAnonymous?: boolean;
  db?: Firestore;
  nowMs?: number;
}): Promise<CompleteCourseLessonResult> {
  const db = options.db ?? getFirestore();
  const input = requestRecord(options.raw);
  const clientVersion = requiredString(input.clientVersion, "clientVersion");
  const lessonId = requiredString(input.lessonId, "lessonId");
  const sessionId = requiredString(input.sessionId, "sessionId");
  if (lessonId !== CALIBRATION_LAUNCH_LESSON_ID) {
    throw new HttpsError(
      "invalid-argument",
      "Only the Section 7 calibration lesson can be completed from the table.",
    );
  }
  const historyRef = db
    .collection("users")
    .doc(options.uid)
    .collection("courseLiveHistory")
    .doc(sessionId);
  const historySnap = await historyRef.get();
  const history = historySnap.data();
  if (!calibrationHistoryAllowsComplete(history, lessonId)) {
    throw new HttpsError(
      "failed-precondition",
      "Finish the calibration hand before completing the lesson.",
    );
  }

  const catalogVersion = optionalString(input.catalogVersion) ??
    courseBank.catalogVersion;
  const startRequestId = calibrationRequestKey(sessionId, "calstart");
  const idempotencyKey = calibrationRequestKey(sessionId, "caldone");
  const priorAttemptId = optionalString(history?.completedAttemptId);
  if (priorAttemptId) {
    return completeCourseLessonForUser({
      uid: options.uid,
      raw: {
        clientVersion,
        attemptId: priorAttemptId,
        idempotencyKey,
        catalogVersion,
      },
      isAnonymous: options.isAnonymous,
      db,
      nowMs: options.nowMs,
    });
  }

  const started = await startCourseLessonForUser({
    uid: options.uid,
    raw: {
      clientVersion,
      lessonId,
      catalogVersion,
      startRequestId,
      timezone: optionalString(input.timezone) ?? "UTC",
    },
    isAnonymous: options.isAnonymous,
    db,
    nowMs: options.nowMs,
  });
  const located = findLesson(lessonId);
  if (!located) {
    throw new HttpsError("not-found", "Unknown calibration lesson.");
  }
  const activities = [...located.lesson.activities].sort(
    (a, b) => a.order - b.order,
  );
  const last = activities[activities.length - 1];
  if (!last) {
    throw new HttpsError("failed-precondition", "Lesson has no activities.");
  }
  // The live hand is the capstone. Advance the attempt so completion is the
  // result node, not a restart of activity 0.
  await db
    .collection("users")
    .doc(options.uid)
    .collection("courseAttempts")
    .doc(started.attempt.attemptId)
    .set({
      activityIndex: activities.length - 1,
      currentActivityId: last.id,
      stepCount: activities.length,
      acceptedCount: activities.length,
      scoredCount: activities.length,
      masteryPoints: 1,
      masteryWeight: 1,
      status: "in_progress",
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});

  await historyRef.set({
    completedAttemptId: started.attempt.attemptId,
  }, {merge: true});

  const result = await completeCourseLessonForUser({
    uid: options.uid,
    raw: {
      clientVersion,
      attemptId: started.attempt.attemptId,
      idempotencyKey,
      catalogVersion,
    },
    isAnonymous: options.isAnonymous,
    db,
    nowMs: options.nowMs,
  });
  await historyRef.set({
    lessonCompleted: true,
  }, {merge: true});
  return result;
}

function requestRecord(raw: unknown): Record<string, unknown> {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new HttpsError("invalid-argument", "request must be an object.");
  }
  return raw as Record<string, unknown>;
}

function requiredString(value: unknown, field: string): string {
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  return value.trim();
}

function calibrationRequestKey(sessionId: string, prefix: string): string {
  const raw = `${prefix}_${sessionId}`.replace(/[^A-Za-z0-9_-]/g, "_");
  const padded = raw.length >= 8 ? raw : `${raw}_warmup`;
  return padded.slice(0, 100);
}

function resolveCuratedHand(input: CourseTableSetupInput): CuratedCourseHand {
  if (input.courseHandId) {
    const found = curatedCourseHandById(input.courseHandId);
    if (!found) {
      throw new HttpsError("not-found", "Unknown courseHandId.");
    }
    return found;
  }
  if (input.handLabSpecId) {
    const found = curatedCourseHandForLab(input.handLabSpecId);
    if (!found) {
      throw new HttpsError(
        "not-found",
        "No curated live bridge for this hand lab.",
      );
    }
    return found;
  }
  if (input.courseKind === "calibration" || input.lessonId?.includes("07-11")) {
    return pickCalibrationHand();
  }
  if (input.courseKind === "hand_lab") {
    throw new HttpsError(
      "invalid-argument",
      "hand_lab course starts require handLabSpecId.",
    );
  }
  return pickWarmUpHand();
}

async function assertValidCourseAttemptToken(options: {
  db: Firestore;
  uid: string;
  attemptId: string;
  activityId?: string;
  lessonId?: string;
}): Promise<void> {
  const snap = await options.db
    .collection("users")
    .doc(options.uid)
    .collection("courseAttempts")
    .doc(options.attemptId)
    .get();
  if (!snap.exists) {
    throw new HttpsError(
      "permission-denied",
      "Course attempt token is invalid.",
    );
  }
  const data = snap.data()!;
  if (data.status !== "in_progress" && data.status !== "remediation") {
    throw new HttpsError(
      "failed-precondition",
      "Course attempt is not open.",
    );
  }
  if (options.lessonId && data.lessonId !== options.lessonId) {
    throw new HttpsError(
      "permission-denied",
      "Course attempt lesson mismatch.",
    );
  }
  if (
    options.activityId &&
    data.currentActivityId &&
    data.currentActivityId !== options.activityId
  ) {
    // Allow if activity already advanced but still same attempt.
  }
}

async function ensureCourseHandReady(
  db: Firestore,
  curated: CuratedCourseHand,
): Promise<PreparedLiveNode> {
  const definition = curated.definition;
  const setupRef = db.collection(COURSE_LIVE_COLLECTION).doc(definition.setupKey);
  const handRef = setupRef.collection("hands").doc(definition.handId);
  const existing = await handRef.get();
  if (existing.exists && existing.data()?.status === "ready") {
    const rootHash = String(existing.data()?.rootStateHash ?? "");
    const nodeSnap = await handRef.collection("nodes").doc(rootHash).get();
    if (nodeSnap.exists) {
      return preparedNodeFromData(nodeSnap.data()!);
    }
  }

  const initial = createInitialLiveState(definition);
  let state = initial;
  let history: LiveActionEvent[] = [];
  // Advance forced posts / early folds to first Hero decision when needed.
  while (
    state.status === "playing" &&
    typeof state.actorSeat === "number" &&
    !liveHeroToAct(definition, state)
  ) {
    const legal = legalLiveActions(definition, state);
    const pick = pickDeterministicVillainAction(legal);
    const next = applyLiveAction({
      hand: definition,
      state,
      actionId: pick.actionId,
    });
    state = next.state;
    history = [...history, next.event];
  }
  if (state.status !== "playing" || !liveHeroToAct(definition, state)) {
    throw new HttpsError(
      "internal",
      "Course hand ended before Hero decision.",
    );
  }
  const legalActions = legalLiveActions(definition, state);
  const stateHash = hashLiveState(state, history);
  const rubric = buildStaticRubric(curated, legalActions, stateHash);
  const root: PreparedLiveNode = {
    stateHash,
    state,
    history,
    legalActions,
    rubric,
  };

  await setupRef.set({
    setupKey: definition.setupKey,
    setup: definition.setup,
    handCount: 1,
    poolKind: "course",
    generation: {
      status: "idle",
      leaseId: null,
      leaseExpiresAtMs: null,
      requestedBatch: 0,
    },
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
  await handRef.set({
    handId: definition.handId,
    setupKey: definition.setupKey,
    definition,
    status: "ready",
    rootStateHash: stateHash,
    warmBranchCount: 0,
    timesServed: 0,
    source: "course_authored",
  });
  await handRef.collection("nodes").doc(stateHash).set({
    stateHash,
    state,
    history,
    legalActions,
    rubric,
  });
  return root;
}

function buildStaticRubric(
  curated: CuratedCourseHand,
  legalActions: LiveLegalAction[],
  stateHash: string,
): CoachingRubric {
  const assessments = legalActions.map((action) =>
    assessmentForCourseAction(curated, null, action.actionId, action),
  );
  return {
    schemaVersion: COACHING_SCHEMA_VERSION,
    stateHash,
    assessments,
    generatedBy: "course-static",
    criticModel: "course-static",
  };
}

function assessmentForCourseAction(
  curated: CuratedCourseHand,
  rubric: CoachingRubric | null,
  actionId: string,
  action: LiveLegalAction,
): CoachingActionAssessment {
  const fromRubric = rubric?.assessments.find((row) => row.actionId === actionId);
  if (fromRubric) return fromRubric;
  const byId = curated.staticFeedback[actionId];
  if (byId) return {actionId, ...byId};
  const byBucket = curated.bucketFeedback[action.bucket] ??
    curated.bucketFeedback[action.kind];
  if (byBucket) return {actionId, ...byBucket};
  return {
    actionId,
    rating: "reasonable",
    confidence: "medium",
    summary: curated.rexPrompt,
    playerTypeReason: "Uses the visible profile.",
    sizingNote: "Fixed legal size.",
    tendencyKeys: [],
  };
}

function pickDeterministicVillainAction(
  legal: LiveLegalAction[],
): LiveLegalAction {
  const check = legal.find((action) => action.kind === "CHECK");
  if (check) return check;
  const call = legal.find((action) => action.kind === "CALL");
  if (call) return call;
  const fold = legal.find((action) => action.kind === "FOLD");
  if (fold) return fold;
  if (legal.length === 0) {
    throw new HttpsError("internal", "No legal villain actions.");
  }
  return legal[0];
}

async function recordCourseLiveDecision(options: {
  db: Firestore;
  uid: string;
  context: CourseSessionContext;
  coaching: CoachingActionAssessment;
  actionId: string;
}): Promise<boolean> {
  const attemptId = options.context.attemptId!;
  const activityId = options.context.activityId!;
  const idempotencyKey =
    `course-live-${attemptId}-${activityId}-${options.context.decisionCount}`;
  const receiptRef = options.db
    .collection("users")
    .doc(options.uid)
    .collection("courseStepReceipts")
    .doc(idempotencyKey);
  const existing = await receiptRef.get();
  if (existing.exists) return true;

  const attemptRef = options.db
    .collection("users")
    .doc(options.uid)
    .collection("courseAttempts")
    .doc(attemptId);
  const grade = options.coaching.rating;
  const accepted = grade === "recommended" ||
    grade === "strong" ||
    grade === "reasonable";
  const masteryWeight = 1;
  const masteryPoints = accepted ? 1 : 0;

  await options.db.runTransaction(async (tx) => {
    const attemptSnap = await tx.get(attemptRef);
    if (!attemptSnap.exists) return;
    const attempt = attemptSnap.data()!;
    if (attempt.status !== "in_progress" && attempt.status !== "remediation") {
      return;
    }
    tx.set(receiptRef, {
      attemptId,
      activityId,
      actionId: options.actionId,
      grade,
      accepted,
      feedback: options.coaching.summary,
      source: "course_live_bridge",
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(attemptRef, {
      acceptedCount: Number(attempt.acceptedCount ?? 0) + (accepted ? 1 : 0),
      scoredCount: Number(attempt.scoredCount ?? 0) + 1,
      stepCount: Number(attempt.stepCount ?? 0) + 1,
      masteryPoints: Number(attempt.masteryPoints ?? 0) + masteryPoints,
      masteryWeight: Number(attempt.masteryWeight ?? 0) + masteryWeight,
      lastCourseLiveActionId: options.actionId,
      lastCourseLiveGrade: grade,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
  });
  return true;
}

function preparedNodeFromData(data: FirebaseFirestore.DocumentData): PreparedLiveNode {
  return {
    stateHash: String(data.stateHash),
    state: data.state as LiveHandState,
    history: (data.history ?? []) as LiveActionEvent[],
    legalActions: (data.legalActions ?? []) as LiveLegalAction[],
    rubric: (data.rubric ?? null) as CoachingRubric | null,
  };
}

function actionDocId(actionId: string): string {
  return actionId.replace(/[^A-Za-z0-9_-]/g, "_");
}

function optionalString(value: unknown): string | undefined {
  if (typeof value !== "string" || !value.trim()) return undefined;
  return value.trim();
}

/** Compatibility: course setups never use live-v3 random keys. */
export function assertSetupKeyIsolation(
  liveKey: string,
  courseKey: string,
): void {
  if (liveKey === courseKey) {
    throw new Error("Course and live setup keys must differ.");
  }
  if (!isCourseSetupKey(courseKey)) {
    throw new Error("Course key must use course-v1 prefix.");
  }
  if (courseKey.startsWith("live-v3|")) {
    throw new Error("Course key must not use live-v3 prefix.");
  }
}

/** Helper for tests that need a LiveTableSetup-shaped course setup. */
export function courseSetupFromDefinition(
  definition: LiveHandDefinition,
): LiveTableSetup {
  return definition.setup;
}

export function newCourseStartRequestId(): string {
  return randomUUID().replace(/-/g, "").slice(0, 24);
}
