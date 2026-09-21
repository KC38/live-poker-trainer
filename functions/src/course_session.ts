/**
 * Authoritative course attempts, soft grading, XP, streaks, lives, mastery,
 * reviews, resume, feature gates, and Section 4 Live entitlement writes.
 *
 * Course progress is isolated from Live Training documents.
 */

import {randomUUID} from "node:crypto";
import {
  FieldValue,
  getFirestore,
  type DocumentData,
  type DocumentReference,
  type DocumentSnapshot,
  type Firestore,
  type Transaction,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {
  courseBank,
  findActivity,
  findLesson,
  lessonGrantsLiveTrainingEntitlement,
  lessonRequiresPlacementFlag,
  type ActivityStage,
  type CourseActivity,
  type CourseBank,
  type CourseChoice,
  type CourseLesson,
  type SoftGrade,
} from "./course_catalog";
import {resolveLiveAccessForUser} from "./live_access";

export const DEFAULT_LESSON_LIVES = 3;
export const XP_PER_ACCEPTED_STEP = 10;
export const XP_LESSON_COMPLETE = 25;
export const REVIEW_DELAY_MS = 24 * 60 * 60 * 1000;

const RATE_LIMIT_WINDOW_MS = 60 * 1000;
const RATE_LIMIT_START_MAX = 20;
const RATE_LIMIT_SUBMIT_MAX = 60;

const ACCEPTED_GRADES: ReadonlySet<SoftGrade> = new Set([
  "recommended",
  "strong",
  "reasonable",
]);

const MASTERY_WEIGHT: Record<SoftGrade, number> = {
  recommended: 1,
  strong: 0.85,
  reasonable: 0.7,
  questionable: 0,
  clear_mistake: 0,
};

const LIFE_ELIGIBLE_STAGES: ReadonlySet<ActivityStage> = new Set([
  "unguided",
  "checkpoint",
  "jump_test",
]);

/** Server-controlled course feature flags at appConfig/courseFlags. */
export interface CourseFlags {
  courseEnabled: boolean;
  courseStartsEnabled: boolean;
  guestCourseEnabled: boolean;
  placementTestsEnabled: boolean;
  catalogVersion: string;
  minimumClientVersion: string;
}

export type CourseGateMode = "read" | "mutate" | "start" | "placement";

export interface CourseProfile {
  catalogVersion: string;
  lifetimeXp: number;
  currentStreak: number;
  longestStreak: number;
  lastStudyLocalDate: string | null;
  timezone: string;
  acceptedAnswers: number;
  totalScoredAnswers: number;
  acceptedAccuracy: number;
  masteryByLessonId: Record<string, number>;
  completedLessonIds: string[];
  currentLessonId: string | null;
  resume: CourseResumePointer | null;
  experienceBand?: string | null;
  dailyGoalMinutes?: number | null;
  recommendedLessonId?: string | null;
  firstLessonCompletedAtMs?: number | null;
  /** Labeled academy XP. Never added to lifetimeXp or unlocks. */
  legacyLifetimeXp?: number | null;
  legacyXpCatalogVersion?: string | null;
  legacyXpLabel?: string | null;
  createdAtMs?: number;
  updatedAtMs?: number;
}

export interface CourseResumePointer {
  attemptId: string;
  lessonId: string;
  activityId: string;
  activityIndex: number;
}

export interface CourseAttempt {
  attemptId: string;
  uid: string;
  lessonId: string;
  catalogVersion: string;
  status: "in_progress" | "completed" | "remediation";
  activityIndex: number;
  currentActivityId: string;
  livesRemaining: number;
  livesMax: number;
  startRequestId: string;
  acceptedCount: number;
  scoredCount: number;
  masteryPoints: number;
  masteryWeight: number;
  jumpTestPassed: boolean;
  stepCount: number;
  createdAtMs?: number;
  updatedAtMs?: number;
  completedAtMs?: number | null;
}

export interface GradeOutcome {
  grade: SoftGrade;
  feedback: string;
  accepted: boolean;
  lifeLost: boolean;
  masteryWeight: number;
  betterChoiceId?: string;
  reversalRead?: string;
}

export interface SubmitCourseStepResult {
  attemptId: string;
  activityId: string;
  grade: SoftGrade;
  feedback: string;
  accepted: boolean;
  lifeLost: boolean;
  livesRemaining: number;
  masteryWeight: number;
  xpAwarded: number;
  remediationRequired: boolean;
  resume: CourseResumePointer;
  betterChoiceId?: string;
  reversalRead?: string;
  duplicate: boolean;
}

export interface CompleteCourseLessonResult {
  attemptId: string;
  lessonId: string;
  xpAwarded: number;
  mastery: number;
  streak: CourseProfile["currentStreak"];
  acceptedAccuracy: number;
  liveTrainingGranted: boolean;
  duplicate: boolean;
  resume: CourseResumePointer | null;
}

/** Parses course flags; missing/invalid docs fail closed (course disabled). */
export function parseCourseFlags(raw: unknown): CourseFlags {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    return disabledCourseFlags();
  }
  const data = raw as Record<string, unknown>;
  const catalogVersion = stringOrEmpty(data.catalogVersion);
  const minimumClientVersion = stringOrEmpty(data.minimumClientVersion);
  if (!catalogVersion || !minimumClientVersion) {
    return disabledCourseFlags();
  }
  return {
    courseEnabled: data.courseEnabled === true,
    courseStartsEnabled: data.courseStartsEnabled === true,
    guestCourseEnabled: data.guestCourseEnabled === true,
    placementTestsEnabled: data.placementTestsEnabled === true,
    catalogVersion,
    minimumClientVersion,
  };
}

export function disabledCourseFlags(
  catalogVersion = courseBank.catalogVersion,
  minimumClientVersion = courseBank.minClientVersion,
): CourseFlags {
  return {
    courseEnabled: false,
    courseStartsEnabled: false,
    guestCourseEnabled: false,
    placementTestsEnabled: false,
    catalogVersion,
    minimumClientVersion,
  };
}

/** Soft-grade acceptance and life-loss rules for one scored response. */
export function evaluateLifeAndAcceptance(options: {
  grade: SoftGrade;
  stage: ActivityStage;
  lifeLossEligible: boolean;
}): Pick<GradeOutcome, "accepted" | "lifeLost" | "masteryWeight"> {
  const accepted = ACCEPTED_GRADES.has(options.grade);
  const lifeLost = options.grade === "clear_mistake" &&
    options.lifeLossEligible &&
    LIFE_ELIGIBLE_STAGES.has(options.stage) &&
    options.stage !== "guided" &&
    options.stage !== "scaffolded";
  return {
    accepted,
    lifeLost,
    masteryWeight: MASTERY_WEIGHT[options.grade],
  };
}

/** Grades a client response against the private bank (never trusts client grade). */
export function gradeCourseResponse(options: {
  activity: CourseActivity;
  bank?: CourseBank;
  choiceId?: string;
  orderedIds?: string[];
  numericValue?: number;
}): GradeOutcome {
  const bank = options.bank ?? courseBank;
  const privateEntry = bank.gradingByActivityId[options.activity.id] as
    | Record<string, unknown>
    | undefined;

  if (options.activity.stage === "explain" ||
    options.activity.renderer === "coach_dialogue") {
    return {
      grade: "recommended",
      feedback: options.activity.accessibilityText || "Keep going.",
      ...evaluateLifeAndAcceptance({
        grade: "recommended",
        stage: options.activity.stage,
        lifeLossEligible: options.activity.lifeLossEligible,
      }),
    };
  }

  if (options.choiceId) {
    const fromActivity =
      findChoiceOnActivity(options.activity, options.choiceId);
    const fromBank = choiceGradingFromBank(
      privateEntry,
      options.choiceId,
      bank,
      options.activity,
    );
    const grading = fromActivity?.grading ?? fromBank;
    if (!grading) {
      throw new HttpsError("invalid-argument", "Unknown choiceId.");
    }
    return outcomeFromGrading(grading, options.activity);
  }

  if (options.orderedIds) {
    const correct = asStringArray(
      privateEntry?.correctSequence ??
        (options.activity as {correctSequence?: unknown}).correctSequence,
    );
    if (!correct.length) {
      throw new HttpsError(
        "failed-precondition",
        "This activity does not accept ordered responses yet.",
      );
    }
    const sequenceGrading = (privateEntry?.sequenceGrading ?? {}) as Record<
      string,
      unknown
    >;
    const matched = arraysEqual(options.orderedIds, correct);
    const grading = matched ?
      gradingRecord(sequenceGrading.correct) :
      gradingRecord(sequenceGrading.incorrect);
    if (!grading) {
      throw new HttpsError("internal", "Sequence grading is incomplete.");
    }
    return outcomeFromGrading(grading, options.activity);
  }

  if (typeof options.numericValue === "number") {
    const numeric = (privateEntry?.numericPrompt ?? {}) as Record<
      string,
      unknown
    >;
    const min = Number(numeric.acceptedMin);
    const max = Number(numeric.acceptedMax);
    if (!Number.isFinite(min) || !Number.isFinite(max)) {
      throw new HttpsError(
        "failed-precondition",
        "This activity does not accept numeric responses yet.",
      );
    }
    const matched = options.numericValue >= min && options.numericValue <= max;
    const grading = matched ?
      gradingRecord(numeric.grading) :
      gradingRecord(numeric.missGrading);
    if (!grading) {
      throw new HttpsError("internal", "Numeric grading is incomplete.");
    }
    return outcomeFromGrading(grading, options.activity);
  }

  throw new HttpsError(
    "invalid-argument",
    "Provide choiceId, orderedIds, or numericValue for this activity.",
  );
}

/** Local calendar YYYY-MM-DD for streak accounting. */
export function localDateString(nowMs: number, timeZone: string): string {
  try {
    return new Intl.DateTimeFormat("en-CA", {
      timeZone,
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    }).format(new Date(nowMs));
  } catch {
    return new Intl.DateTimeFormat("en-CA", {
      timeZone: "UTC",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    }).format(new Date(nowMs));
  }
}

/** Applies at-most-one study-day streak credit. */
export function applyStudyDayStreak(options: {
  currentStreak: number;
  longestStreak: number;
  lastStudyLocalDate: string | null;
  todayLocalDate: string;
}): {
  currentStreak: number;
  longestStreak: number;
  lastStudyLocalDate: string;
  credited: boolean;
} {
  const {todayLocalDate} = options;
  if (options.lastStudyLocalDate === todayLocalDate) {
    return {
      currentStreak: options.currentStreak,
      longestStreak: options.longestStreak,
      lastStudyLocalDate: todayLocalDate,
      credited: false,
    };
  }
  const yesterday = shiftLocalDate(todayLocalDate, -1);
  const nextStreak = options.lastStudyLocalDate === yesterday ?
    options.currentStreak + 1 :
    1;
  return {
    currentStreak: nextStreak,
    longestStreak: Math.max(options.longestStreak, nextStreak),
    lastStudyLocalDate: todayLocalDate,
    credited: true,
  };
}

export async function assertCourseAvailable(options: {
  db: Firestore;
  clientVersion: string;
  catalogVersion?: string;
  isAnonymous?: boolean;
  mode: CourseGateMode;
  requiresPlacement?: boolean;
  flags?: CourseFlags;
}): Promise<CourseFlags> {
  const flags = options.flags ?? await loadCourseFlags(options.db);
  if (!flags.courseEnabled) {
    throw new HttpsError(
      "failed-precondition",
      "Course is temporarily unavailable.",
    );
  }
  if (compareVersions(options.clientVersion, flags.minimumClientVersion) < 0) {
    throw new HttpsError(
      "failed-precondition",
      "A newer app version is required for the course.",
    );
  }
  if (
    options.catalogVersion &&
    options.catalogVersion !== flags.catalogVersion
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Course catalog version mismatch. Refresh and retry.",
    );
  }
  if (options.mode === "start" || options.mode === "placement") {
    if (!flags.courseStartsEnabled) {
      throw new HttpsError(
        "failed-precondition",
        "New course attempts are paused.",
      );
    }
    if (options.isAnonymous && !flags.guestCourseEnabled) {
      throw new HttpsError(
        "failed-precondition",
        "Guest course access is disabled.",
      );
    }
  }
  if (
    (options.mode === "placement" || options.requiresPlacement) &&
    !flags.placementTestsEnabled
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Placement and jump tests are disabled.",
    );
  }
  return flags;
}

export async function initializeCourseProfileForUser(options: {
  uid: string;
  raw: unknown;
  isAnonymous?: boolean;
  db?: Firestore;
  nowMs?: number;
}): Promise<{profile: CourseProfile; created: boolean}> {
  const db = options.db ?? getFirestore();
  const input = record(options.raw, "request");
  const clientVersion = nonEmpty(input.clientVersion, "clientVersion");
  const catalogVersion = optionalString(input.catalogVersion) ??
    courseBank.catalogVersion;
  const timezone = sanitizeTimezone(optionalString(input.timezone) ?? "UTC");
  const experienceBand = sanitizeExperienceBand(
    optionalString(input.experienceBand),
  );
  const dailyGoalMinutes = sanitizeDailyGoalMinutes(input.dailyGoalMinutes);
  const recommendedLessonId = optionalString(input.recommendedLessonId) ?? null;
  const flags = await assertCourseAvailable({
    db,
    clientVersion,
    catalogVersion,
    isAnonymous: options.isAnonymous === true,
    mode: "start",
  });
  await enforceRateLimit({
    db,
    uid: options.uid,
    bucket: "initialize",
    max: RATE_LIMIT_START_MAX,
  });
  const profileRef = courseProfileRef(db, options.uid);
  const nowMs = options.nowMs ?? Date.now();
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(profileRef);
    if (snap.exists) {
      const existing = snap.data()!;
      if (existing.tombstoned === true) {
        throw new HttpsError(
          "failed-precondition",
          "This guest progress was transferred and can no longer be used.",
        );
      }
      const patch: DocumentData = {
        updatedAt: FieldValue.serverTimestamp(),
        updatedAtMs: nowMs,
      };
      let changed = false;
      if (experienceBand && !optionalString(existing.experienceBand)) {
        patch.experienceBand = experienceBand;
        changed = true;
      }
      if (
        dailyGoalMinutes != null &&
        !Number.isFinite(Number(existing.dailyGoalMinutes))
      ) {
        patch.dailyGoalMinutes = dailyGoalMinutes;
        changed = true;
      }
      if (recommendedLessonId && !optionalString(existing.recommendedLessonId)) {
        patch.recommendedLessonId = recommendedLessonId;
        changed = true;
      }
      if (changed) tx.set(profileRef, patch, {merge: true});
      return {
        profile: profileFromData({...existing, ...patch}),
        created: false,
      };
    }
    const profile = emptyProfile({
      catalogVersion: flags.catalogVersion,
      timezone,
      nowMs,
      experienceBand,
      dailyGoalMinutes,
      recommendedLessonId,
    });
    tx.set(profileRef, {
      ...profileToFirestore(profile),
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    return {profile, created: true};
  });
}

export async function startCourseLessonForUser(options: {
  uid: string;
  raw: unknown;
  isAnonymous?: boolean;
  db?: Firestore;
  nowMs?: number;
}): Promise<{
  attempt: CourseAttempt;
  resume: CourseResumePointer;
  duplicate: boolean;
}> {
  const db = options.db ?? getFirestore();
  const input = record(options.raw, "request");
  const clientVersion = nonEmpty(input.clientVersion, "clientVersion");
  const lessonId = nonEmpty(input.lessonId, "lessonId");
  const startRequestId = safeKey(input.startRequestId, "startRequestId");
  const catalogVersion = optionalString(input.catalogVersion) ??
    courseBank.catalogVersion;
  const timezone = sanitizeTimezone(optionalString(input.timezone) ?? "UTC");
  const located = findLesson(lessonId);
  if (!located) {
    throw new HttpsError("not-found", "Unknown lessonId.");
  }
  const requiresPlacement = lessonRequiresPlacementFlag(located.lesson);
  await assertCourseAvailable({
    db,
    clientVersion,
    catalogVersion,
    isAnonymous: options.isAnonymous === true,
    mode: requiresPlacement ? "placement" : "start",
    requiresPlacement,
  });
  await enforceRateLimit({
    db,
    uid: options.uid,
    bucket: "start",
    max: RATE_LIMIT_START_MAX,
  });
  const activities = sortedActivities(located.lesson);
  if (!activities.length) {
    throw new HttpsError("failed-precondition", "Lesson has no activities.");
  }
  const profileRef = courseProfileRef(db, options.uid);
  const requestRef = db
    .collection("users")
    .doc(options.uid)
    .collection("courseStartRequests")
    .doc(startRequestId);
  const nowMs = options.nowMs ?? Date.now();
  const newAttemptId = randomUUID();

  return db.runTransaction(async (tx) => {
    const [requestSnap, profileSnap] = await Promise.all([
      tx.get(requestRef),
      tx.get(profileRef),
    ]);
    if (profileSnap.exists && profileSnap.data()?.tombstoned === true) {
      throw new HttpsError(
        "failed-precondition",
        "This guest progress was transferred and can no longer be used.",
      );
    }
    // Default policy: account required before lesson two for anonymous guests.
    if (options.isAnonymous === true) {
      const completed = Array.isArray(profileSnap.data()?.completedLessonIds) ?
        profileSnap.data()!.completedLessonIds as string[] :
        [];
      const resumeData = profileSnap.data()?.resume as DocumentData | undefined;
      const resumeLessonId = optionalString(resumeData?.lessonId);
      const resumingSameLesson = resumeLessonId === lessonId;
      if (completed.length >= 1 && !resumingSameLesson) {
        throw new HttpsError(
          "failed-precondition",
          "Create an account to save progress before lesson two.",
        );
      }
    }
    const existing = requestSnap.data();
    const resumeData = profileSnap.data()?.resume as DocumentData | undefined;
    const resumeAttemptId = optionalString(resumeData?.attemptId);
    const resumeLessonId = optionalString(resumeData?.lessonId);
    let priorAttemptSnap: DocumentSnapshot | null = null;
    if (
      existing?.status === "ready" &&
      typeof existing.attemptId === "string"
    ) {
      priorAttemptSnap = await tx.get(
        attemptRef(db, options.uid, existing.attemptId),
      );
    } else if (
      resumeAttemptId &&
      resumeLessonId === lessonId
    ) {
      priorAttemptSnap = await tx.get(
        attemptRef(db, options.uid, resumeAttemptId),
      );
    }

    if (priorAttemptSnap?.exists) {
      const attempt = attemptFromData(priorAttemptSnap.data()!);
      if (
        attempt.lessonId === lessonId &&
        (attempt.status === "in_progress" || attempt.status === "remediation")
      ) {
        tx.set(requestRef, {
          status: "ready",
          attemptId: attempt.attemptId,
          lessonId,
          updatedAt: FieldValue.serverTimestamp(),
        }, {merge: true});
        return {
          attempt,
          resume: resumeFromAttempt(attempt),
          duplicate: true,
        };
      }
      if (existing?.status === "ready") {
        throw new HttpsError("aborted", "Start receipt is incomplete.");
      }
    }
    if (existing && existing.lessonId && existing.lessonId !== lessonId) {
      throw new HttpsError(
        "already-exists",
        "startRequestId was reused for another lesson.",
      );
    }

    // Deep-link lock: new starts require catalog prerequisites completed.
    const completedForPrereqs = Array.isArray(
      profileSnap.data()?.completedLessonIds,
    ) ?
      profileSnap.data()!.completedLessonIds as string[] :
      [];
    const missingPrereq = located.lesson.prerequisites.find(
      (prereqId) => !completedForPrereqs.includes(prereqId),
    );
    if (missingPrereq) {
      throw new HttpsError(
        "failed-precondition",
        "Complete the previous lesson before starting this one.",
      );
    }

    ensureProfileTx(tx, profileRef, profileSnap, {
      catalogVersion,
      timezone,
      nowMs,
    });

    const first = activities[0];
    const attempt: CourseAttempt = {
      attemptId: newAttemptId,
      uid: options.uid,
      lessonId,
      catalogVersion,
      status: "in_progress",
      activityIndex: 0,
      currentActivityId: first.id,
      livesRemaining: DEFAULT_LESSON_LIVES,
      livesMax: DEFAULT_LESSON_LIVES,
      startRequestId,
      acceptedCount: 0,
      scoredCount: 0,
      masteryPoints: 0,
      masteryWeight: 0,
      jumpTestPassed: false,
      stepCount: 0,
      createdAtMs: nowMs,
      updatedAtMs: nowMs,
      completedAtMs: null,
    };
    tx.create(attemptRef(db, options.uid, newAttemptId), {
      ...attempt,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.set(requestRef, {
      status: "ready",
      attemptId: newAttemptId,
      lessonId,
      catalogVersion,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.set(profileRef, {
      currentLessonId: lessonId,
      resume: resumeFromAttempt(attempt),
      catalogVersion,
      timezone,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    return {
      attempt,
      resume: resumeFromAttempt(attempt),
      duplicate: false,
    };
  });
}

export async function submitCourseStepForUser(options: {
  uid: string;
  raw: unknown;
  isAnonymous?: boolean;
  db?: Firestore;
  nowMs?: number;
}): Promise<SubmitCourseStepResult> {
  const db = options.db ?? getFirestore();
  const input = record(options.raw, "request");
  const clientVersion = nonEmpty(input.clientVersion, "clientVersion");
  const attemptId = nonEmpty(input.attemptId, "attemptId");
  const activityId = nonEmpty(input.activityId, "activityId");
  const idempotencyKey = safeKey(input.idempotencyKey, "idempotencyKey");
  const catalogVersion = optionalString(input.catalogVersion);
  const choiceId = optionalString(input.choiceId);
  const orderedIds = optionalStringArray(input.orderedIds);
  const numericValue = optionalNumber(input.numericValue);

  // Clients never submit grades — reject if present.
  if (input.grade !== undefined || input.softGrade !== undefined) {
    throw new HttpsError(
      "invalid-argument",
      "Clients must not submit grades.",
    );
  }

  await assertCourseAvailable({
    db,
    clientVersion,
    catalogVersion: catalogVersion ?? undefined,
    isAnonymous: options.isAnonymous === true,
    mode: "mutate",
  });
  await enforceRateLimit({
    db,
    uid: options.uid,
    bucket: "submit",
    max: RATE_LIMIT_SUBMIT_MAX,
  });

  const receiptRef = db
    .collection("users")
    .doc(options.uid)
    .collection("courseStepReceipts")
    .doc(idempotencyKey);
  const attemptDoc = attemptRef(db, options.uid, attemptId);
  const profileRef = courseProfileRef(db, options.uid);
  const nowMs = options.nowMs ?? Date.now();

  return db.runTransaction(async (tx) => {
    const [receiptSnap, attemptSnap, profileSnap] = await Promise.all([
      tx.get(receiptRef),
      tx.get(attemptDoc),
      tx.get(profileRef),
    ]);
    if (receiptSnap.exists) {
      const prior = receiptSnap.data()?.result as
        | SubmitCourseStepResult
        | undefined;
      if (!prior || prior.attemptId !== attemptId) {
        throw new HttpsError(
          "already-exists",
          "idempotencyKey was reused for another step.",
        );
      }
      return {...prior, duplicate: true};
    }
    if (!attemptSnap.exists) {
      throw new HttpsError("not-found", "Unknown attemptId.");
    }
    const attempt = attemptFromData(attemptSnap.data()!);
    if (attempt.uid !== options.uid) {
      throw new HttpsError("permission-denied", "Attempt belongs to another user.");
    }
    if (attempt.status === "completed") {
      throw new HttpsError("failed-precondition", "Lesson attempt is complete.");
    }
    if (attempt.currentActivityId !== activityId) {
      throw new HttpsError(
        "aborted",
        "Stale activity. Resume the lesson and retry.",
      );
    }
    const located = findLesson(attempt.lessonId);
    if (!located) {
      throw new HttpsError("failed-precondition", "Lesson missing from catalog.");
    }
    const activity = findActivity(located.lesson, activityId);
    if (!activity) {
      throw new HttpsError("invalid-argument", "Unknown activityId.");
    }

    const outcome = gradeCourseResponse({
      activity,
      choiceId,
      orderedIds,
      numericValue,
    });

    let livesRemaining = attempt.livesRemaining;
    let lifeLost = false;
    if (outcome.lifeLost && livesRemaining > 0) {
      livesRemaining -= 1;
      lifeLost = true;
    }
    const remediationRequired = lifeLost && livesRemaining <= 0;
    const scored = activity.stage !== "explain";
    const acceptedCount = attempt.acceptedCount + (outcome.accepted ? 1 : 0);
    const scoredCount = attempt.scoredCount + (scored ? 1 : 0);
    const masteryPoints = attempt.masteryPoints + outcome.masteryWeight;
    const masteryWeight = attempt.masteryWeight + (scored ? 1 : 0);
    const jumpTestPassed = attempt.jumpTestPassed ||
      (activity.stage === "jump_test" && outcome.accepted);

    const activities = sortedActivities(located.lesson);
    const currentIndex = activities.findIndex((item) => item.id === activityId);
    const advance = outcome.accepted || activity.stage === "explain";
    const nextIndex = advance ?
      Math.min(currentIndex + 1, activities.length - 1) :
      currentIndex;
    const nextActivityId = activities[nextIndex]?.id ?? activityId;
    const stayed = !advance || currentIndex >= activities.length - 1;

    const xpAwarded = outcome.accepted ? XP_PER_ACCEPTED_STEP : 0;
    const timezone = String(profileSnap.data()?.timezone ?? "UTC");
    const today = localDateString(nowMs, timezone);
    const streak = applyStudyDayStreak({
      currentStreak: Number(profileSnap.data()?.currentStreak ?? 0),
      longestStreak: Number(profileSnap.data()?.longestStreak ?? 0),
      lastStudyLocalDate: optionalString(profileSnap.data()?.lastStudyLocalDate) ??
        null,
      todayLocalDate: today,
    });

    const nextStatus: CourseAttempt["status"] = remediationRequired ?
      "remediation" :
      attempt.status === "remediation" && outcome.accepted ?
      "in_progress" :
      attempt.status;

    const nextAttempt: CourseAttempt = {
      ...attempt,
      activityIndex: stayed && advance && currentIndex >= activities.length - 1 ?
        currentIndex :
        nextIndex,
      currentActivityId: advance && currentIndex < activities.length - 1 ?
        nextActivityId :
        activityId,
      livesRemaining,
      acceptedCount,
      scoredCount,
      masteryPoints,
      masteryWeight,
      jumpTestPassed,
      stepCount: attempt.stepCount + 1,
      status: nextStatus,
      updatedAtMs: nowMs,
    };
    // After an accepted final activity, stay on last activity until complete.
    if (advance && currentIndex >= activities.length - 1) {
      nextAttempt.currentActivityId = activityId;
      nextAttempt.activityIndex = currentIndex;
    }

    const resume = resumeFromAttempt(nextAttempt);
    const result: SubmitCourseStepResult = {
      attemptId,
      activityId,
      grade: outcome.grade,
      feedback: outcome.feedback,
      accepted: outcome.accepted,
      lifeLost,
      livesRemaining,
      masteryWeight: outcome.masteryWeight,
      xpAwarded,
      remediationRequired,
      resume,
      duplicate: false,
    };
    if (outcome.betterChoiceId) {
      result.betterChoiceId = outcome.betterChoiceId;
    }
    if (outcome.reversalRead) {
      result.reversalRead = outcome.reversalRead;
    }

    tx.set(attemptDoc, {
      ...nextAttempt,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    tx.create(receiptRef, {
      idempotencyKey,
      attemptId,
      activityId,
      choiceId: choiceId ?? null,
      orderedIds: orderedIds ?? null,
      numericValue: numericValue ?? null,
      grade: outcome.grade,
      accepted: outcome.accepted,
      lifeLost,
      xpAwarded,
      result,
      createdAt: FieldValue.serverTimestamp(),
    });

    const profileUpdate: DocumentData = {
      currentLessonId: attempt.lessonId,
      resume,
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      lastStudyLocalDate: streak.lastStudyLocalDate,
      timezone,
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (scored) {
      profileUpdate.totalScoredAnswers = FieldValue.increment(1);
    }
    if (outcome.accepted) {
      profileUpdate.acceptedAnswers = FieldValue.increment(1);
    }
    if (xpAwarded > 0) {
      profileUpdate.lifetimeXp = FieldValue.increment(xpAwarded);
      const ledgerId = `step_${idempotencyKey}`;
      tx.create(
        db.collection("users").doc(options.uid)
          .collection("courseXpLedger").doc(ledgerId),
        {
          entryId: ledgerId,
          amount: xpAwarded,
          reason: "step_accepted",
          attemptId,
          activityId,
          idempotencyKey,
          createdAt: FieldValue.serverTimestamp(),
          createdAtMs: nowMs,
        },
      );
    }
    const acceptedAnswers = Number(profileSnap.data()?.acceptedAnswers ?? 0) +
      (outcome.accepted ? 1 : 0);
    const totalScored = Number(profileSnap.data()?.totalScoredAnswers ?? 0) +
      (scored ? 1 : 0);
    profileUpdate.acceptedAccuracy = totalScored === 0 ?
      0 :
      acceptedAnswers / totalScored;
    tx.set(profileRef, profileUpdate, {merge: true});

    // Course writes must never touch Live Training progress docs.
    return result;
  });
}

export async function completeCourseLessonForUser(options: {
  uid: string;
  raw: unknown;
  isAnonymous?: boolean;
  db?: Firestore;
  nowMs?: number;
}): Promise<CompleteCourseLessonResult> {
  const db = options.db ?? getFirestore();
  const input = record(options.raw, "request");
  const clientVersion = nonEmpty(input.clientVersion, "clientVersion");
  const attemptId = nonEmpty(input.attemptId, "attemptId");
  const idempotencyKey = safeKey(
    input.idempotencyKey ?? `complete_${attemptId}`,
    "idempotencyKey",
  );
  const catalogVersion = optionalString(input.catalogVersion);

  await assertCourseAvailable({
    db,
    clientVersion,
    catalogVersion: catalogVersion ?? undefined,
    isAnonymous: options.isAnonymous === true,
    mode: "mutate",
  });
  await enforceRateLimit({
    db,
    uid: options.uid,
    bucket: "complete",
    max: RATE_LIMIT_START_MAX,
  });

  const receiptRef = db
    .collection("users")
    .doc(options.uid)
    .collection("courseStepReceipts")
    .doc(idempotencyKey);
  const attemptDoc = attemptRef(db, options.uid, attemptId);
  const profileRef = courseProfileRef(db, options.uid);
  const entitlementRef = db
    .collection("users")
    .doc(options.uid)
    .collection("entitlements")
    .doc("liveTraining");
  const nowMs = options.nowMs ?? Date.now();

  return db.runTransaction(async (tx) => {
    const [receiptSnap, attemptSnap, profileSnap, entitlementSnap] =
      await Promise.all([
        tx.get(receiptRef),
        tx.get(attemptDoc),
        tx.get(profileRef),
        tx.get(entitlementRef),
      ]);
    if (receiptSnap.exists) {
      const prior = receiptSnap.data()?.result as
        | CompleteCourseLessonResult
        | undefined;
      if (!prior || prior.attemptId !== attemptId) {
        throw new HttpsError(
          "already-exists",
          "idempotencyKey was reused for another completion.",
        );
      }
      return {...prior, duplicate: true};
    }
    if (!attemptSnap.exists) {
      throw new HttpsError("not-found", "Unknown attemptId.");
    }
    const attempt = attemptFromData(attemptSnap.data()!);
    if (attempt.status === "completed") {
      const profile = profileFromData(profileSnap.data() ?? {});
      return {
        attemptId,
        lessonId: attempt.lessonId,
        xpAwarded: 0,
        mastery: masteryRatio(attempt),
        streak: profile.currentStreak,
        acceptedAccuracy: profile.acceptedAccuracy,
        liveTrainingGranted: entitlementSnap.exists === true &&
          entitlementSnap.data()?.unrestrictedAccess === true,
        duplicate: true,
        resume: null,
      };
    }
    if (attempt.status === "remediation") {
      throw new HttpsError(
        "failed-precondition",
        "Complete remediation before finishing the lesson.",
      );
    }
    const located = findLesson(attempt.lessonId);
    if (!located) {
      throw new HttpsError("failed-precondition", "Lesson missing from catalog.");
    }
    const activities = sortedActivities(located.lesson);
    const last = activities[activities.length - 1];
    if (
      attempt.currentActivityId !== last?.id ||
      attempt.stepCount < activities.length
    ) {
      // Allow complete when every activity was accepted (stepCount covers explains).
      const allReached = attempt.activityIndex >= activities.length - 1 &&
        attempt.acceptedCount + explainCount(located.lesson) >=
          activities.length;
      if (!allReached && attempt.stepCount < activities.length) {
        throw new HttpsError(
          "failed-precondition",
          "Finish every activity before completing the lesson.",
        );
      }
    }

    const mastery = masteryRatio(attempt);
    const xpAwarded = XP_LESSON_COMPLETE;
    const timezone = String(profileSnap.data()?.timezone ?? "UTC");
    const today = localDateString(nowMs, timezone);
    const streak = applyStudyDayStreak({
      currentStreak: Number(profileSnap.data()?.currentStreak ?? 0),
      longestStreak: Number(profileSnap.data()?.longestStreak ?? 0),
      lastStudyLocalDate: optionalString(profileSnap.data()?.lastStudyLocalDate) ??
        null,
      todayLocalDate: today,
    });

    const shouldGrantLive = lessonGrantsLiveTrainingEntitlement(located) &&
      attempt.jumpTestPassed;
    let liveTrainingGranted = false;
    if (shouldGrantLive) {
      const existing = entitlementSnap.data();
      if (existing?.unrestrictedAccess === true) {
        liveTrainingGranted = true;
      } else {
        tx.set(entitlementRef, {
          unrestrictedAccess: true,
          source: "section4_jump",
          grantedAt: FieldValue.serverTimestamp(),
          grantedAtMs: nowMs,
          grantedByAttemptId: attemptId,
          grantedByLessonId: attempt.lessonId,
        });
        liveTrainingGranted = true;
      }
    }

    const completedLessonIds = uniqueStrings([
      ...(Array.isArray(profileSnap.data()?.completedLessonIds) ?
        profileSnap.data()!.completedLessonIds as string[] :
        []),
      attempt.lessonId,
    ]);
    const masteryByLessonId = {
      ...(profileSnap.data()?.masteryByLessonId as Record<string, number> ?? {}),
      [attempt.lessonId]: mastery,
    };

    const reviewId = `review_${attempt.lessonId}`;
    tx.set(
      db.collection("users").doc(options.uid)
        .collection("courseReviews").doc(reviewId),
      {
        reviewId,
        lessonId: attempt.lessonId,
        status: "scheduled",
        dueAtMs: nowMs + REVIEW_DELAY_MS,
        sourceAttemptId: attemptId,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );

    tx.set(attemptDoc, {
      status: "completed",
      completedAtMs: nowMs,
      updatedAtMs: nowMs,
      updatedAt: FieldValue.serverTimestamp(),
      completedAt: FieldValue.serverTimestamp(),
    }, {merge: true});

    const ledgerId = `complete_${idempotencyKey}`;
    tx.create(
      db.collection("users").doc(options.uid)
        .collection("courseXpLedger").doc(ledgerId),
      {
        entryId: ledgerId,
        amount: xpAwarded,
        reason: "lesson_complete",
        attemptId,
        lessonId: attempt.lessonId,
        idempotencyKey,
        createdAt: FieldValue.serverTimestamp(),
        createdAtMs: nowMs,
      },
    );

    const acceptedAnswers = Number(profileSnap.data()?.acceptedAnswers ?? 0);
    const totalScored = Number(profileSnap.data()?.totalScoredAnswers ?? 0);
    const acceptedAccuracy = totalScored === 0 ?
      0 :
      acceptedAnswers / totalScored;

    const firstLessonCompletedAtMs =
      Number(profileSnap.data()?.firstLessonCompletedAtMs ?? 0) ||
      (completedLessonIds.length === 1 ? nowMs : null);
    tx.set(profileRef, {
      lifetimeXp: FieldValue.increment(xpAwarded),
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      lastStudyLocalDate: streak.lastStudyLocalDate,
      completedLessonIds,
      masteryByLessonId,
      currentLessonId: null,
      resume: null,
      acceptedAccuracy,
      ...(firstLessonCompletedAtMs ?
        {firstLessonCompletedAtMs} :
        {}),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});

    const result: CompleteCourseLessonResult = {
      attemptId,
      lessonId: attempt.lessonId,
      xpAwarded,
      mastery,
      streak: streak.currentStreak,
      acceptedAccuracy,
      liveTrainingGranted,
      duplicate: false,
      resume: null,
    };
    tx.create(receiptRef, {
      idempotencyKey,
      attemptId,
      kind: "complete",
      result,
      createdAt: FieldValue.serverTimestamp(),
    });
    return result;
  });
}

export async function getCourseStateForUser(options: {
  uid: string;
  raw: unknown;
  isAnonymous?: boolean;
  db?: Firestore;
}): Promise<{
  available: boolean;
  flags: CourseFlags;
  profile: CourseProfile | null;
  openAttempt: CourseAttempt | null;
  reviewsDue: Array<Record<string, unknown>>;
  liveTrainingEntitlement: Record<string, unknown> | null;
  liveAccess: Record<string, unknown> | null;
}> {
  const db = options.db ?? getFirestore();
  const input = record(options.raw ?? {}, "request");
  const clientVersion = nonEmpty(input.clientVersion, "clientVersion");
  const flags = await loadCourseFlags(db);
  // Read path still fails closed on version mismatch when course is enabled.
  if (flags.courseEnabled) {
    await assertCourseAvailable({
      db,
      clientVersion,
      isAnonymous: options.isAnonymous === true,
      mode: "read",
      flags,
    });
  } else if (compareVersions(clientVersion, flags.minimumClientVersion) < 0) {
    // Keep Live Training usable; only report course unavailable.
  }

  const profileSnap = await courseProfileRef(db, options.uid).get();
  const profile = profileSnap.exists ?
    profileFromData(profileSnap.data()!) :
    null;
  let openAttempt: CourseAttempt | null = null;
  if (profile?.resume?.attemptId) {
    const snap = await attemptRef(db, options.uid, profile.resume.attemptId)
      .get();
    if (snap.exists) {
      const attempt = attemptFromData(snap.data()!);
      if (attempt.status === "in_progress" || attempt.status === "remediation") {
        openAttempt = attempt;
      }
    }
  }
  const nowMs = Date.now();
  const reviewsSnap = await db
    .collection("users")
    .doc(options.uid)
    .collection("courseReviews")
    .limit(40)
    .get();
  const reviewsDue = reviewsSnap.docs
    .map((docSnap) => {
      const data = docSnap.data();
      return {id: docSnap.id, ...data};
    })
    .filter((row) => Number((row as {dueAtMs?: unknown}).dueAtMs ?? 0) <= nowMs)
    .slice(0, 20);
  const entitlementSnap = await db
    .collection("users")
    .doc(options.uid)
    .collection("entitlements")
    .doc("liveTraining")
    .get();

  let liveAccess: Record<string, unknown> | null = null;
  if (options.isAnonymous !== true) {
    try {
      const access = await resolveLiveAccessForUser(options.uid, {db});
      liveAccess = {
        tier: access.tier,
        source: access.source,
        unrestrictedAccess: access.unrestrictedAccess,
        warmUpAvailable: access.warmUpAvailable,
        nextLessonId: access.nextLessonId,
        rolloutCutoffMs: access.rolloutCutoffMs,
      };
    } catch {
      liveAccess = {
        tier: "locked",
        source: "none",
        unrestrictedAccess: false,
        warmUpAvailable: false,
        nextLessonId: null,
        rolloutCutoffMs: null,
      };
    }
  } else {
    liveAccess = {
      tier: "locked",
      source: "none",
      unrestrictedAccess: false,
      warmUpAvailable: false,
      nextLessonId: null,
      rolloutCutoffMs: null,
    };
  }

  return {
    available: flags.courseEnabled,
    flags,
    profile,
    openAttempt,
    reviewsDue,
    liveTrainingEntitlement: entitlementSnap.exists ?
      sanitizeEntitlement(entitlementSnap.data()!) :
      null,
    liveAccess,
  };
}

async function loadCourseFlags(db: Firestore): Promise<CourseFlags> {
  try {
    const snap = await db.doc("appConfig/courseFlags").get();
    if (!snap.exists) return disabledCourseFlags();
    return parseCourseFlags(snap.data());
  } catch {
    return disabledCourseFlags();
  }
}

async function enforceRateLimit(options: {
  db: Firestore;
  uid: string;
  bucket: string;
  max: number;
  nowMs?: number;
}): Promise<void> {
  const nowMs = options.nowMs ?? Date.now();
  const ref = options.db
    .collection("users")
    .doc(options.uid)
    .collection("courseRateLimits")
    .doc(options.bucket);
  await options.db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.data() ?? {};
    const windowStartMs = Number(data.windowStartMs ?? 0);
    let count = Number(data.count ?? 0);
    if (nowMs - windowStartMs > RATE_LIMIT_WINDOW_MS) {
      count = 0;
    }
    if (count >= options.max) {
      throw new HttpsError(
        "resource-exhausted",
        "Too many course requests. Retry shortly.",
      );
    }
    tx.set(ref, {
      windowStartMs: count === 0 ? nowMs : windowStartMs || nowMs,
      count: count + 1,
      updatedAtMs: nowMs,
    }, {merge: true});
  });
}

function outcomeFromGrading(
  grading: {
    grade: SoftGrade;
    feedback: string;
    betterChoiceId?: string;
    reversalRead?: string;
  },
  activity: CourseActivity,
): GradeOutcome {
  return {
    grade: grading.grade,
    feedback: grading.feedback,
    betterChoiceId: grading.betterChoiceId,
    reversalRead: grading.reversalRead,
    ...evaluateLifeAndAcceptance({
      grade: grading.grade,
      stage: activity.stage,
      lifeLossEligible: activity.lifeLossEligible,
    }),
  };
}

function findChoiceOnActivity(
  activity: CourseActivity,
  choiceId: string,
): CourseChoice | undefined {
  const direct = activity.choices?.find((choice) => choice.id === choiceId);
  if (direct) return direct;
  const steps = (activity as {handSteps?: Array<{choices?: CourseChoice[]}>})
    .handSteps;
  if (!steps) return undefined;
  for (const step of steps) {
    const match = step.choices?.find((choice) => choice.id === choiceId);
    if (match) return match;
  }
  return undefined;
}

function choiceGradingFromBank(
  privateEntry: Record<string, unknown> | undefined,
  choiceId: string,
  bank?: CourseBank,
  activity?: CourseActivity,
): {
  grade: SoftGrade;
  feedback: string;
  betterChoiceId?: string;
  reversalRead?: string;
} | null {
  const map = privateEntry?.choiceGrading as
    | Record<string, Record<string, unknown>>
    | undefined;
  if (map?.[choiceId]) {
    return gradingRecord(map[choiceId]);
  }

  const steps = privateEntry?.handSteps;
  if (Array.isArray(steps)) {
    for (const step of steps) {
      if (!step || typeof step !== "object") continue;
      const gradingMap = (step as {choiceGrading?: Record<string, unknown>})
        .choiceGrading;
      if (gradingMap && gradingMap[choiceId]) {
        return gradingRecord(gradingMap[choiceId]);
      }
    }
  }

  const labId = (privateEntry?.handLabSpecId as string | undefined) ??
    activity?.handLabSpecId;
  if (labId && bank?.handLabsById?.[labId]) {
    const lab = bank.handLabsById[labId] as {
      decisionPoints?: Array<{choices?: CourseChoice[]}>;
    };
    for (const point of lab.decisionPoints ?? []) {
      const match = point.choices?.find((choice) => choice.id === choiceId);
      if (match?.grading) {
        return gradingRecord(match.grading);
      }
    }
  }

  return null;
}

function gradingRecord(
  raw: unknown,
): {
  grade: SoftGrade;
  feedback: string;
  betterChoiceId?: string;
  reversalRead?: string;
} | null {
  if (!raw || typeof raw !== "object") return null;
  const data = raw as Record<string, unknown>;
  const grade = data.grade;
  if (
    grade !== "recommended" &&
    grade !== "strong" &&
    grade !== "reasonable" &&
    grade !== "questionable" &&
    grade !== "clear_mistake"
  ) {
    return null;
  }
  return {
    grade,
    feedback: String(data.feedback ?? ""),
    betterChoiceId: optionalString(data.betterChoiceId),
    reversalRead: optionalString(data.reversalRead),
  };
}

const EXPERIENCE_BANDS = new Set([
  "never_played",
  "rules_known",
  "first_casino",
  "regular_live",
]);

const DAILY_GOAL_MINUTES = new Set([5, 10, 15, 20]);

function sanitizeExperienceBand(value: string | undefined): string | null {
  if (!value) return null;
  return EXPERIENCE_BANDS.has(value) ? value : null;
}

function sanitizeDailyGoalMinutes(value: unknown): number | null {
  const n = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(n)) return null;
  return DAILY_GOAL_MINUTES.has(n) ? n : null;
}

function emptyProfile(options: {
  catalogVersion: string;
  timezone: string;
  nowMs: number;
  experienceBand?: string | null;
  dailyGoalMinutes?: number | null;
  recommendedLessonId?: string | null;
}): CourseProfile {
  return {
    catalogVersion: options.catalogVersion,
    lifetimeXp: 0,
    currentStreak: 0,
    longestStreak: 0,
    lastStudyLocalDate: null,
    timezone: options.timezone,
    acceptedAnswers: 0,
    totalScoredAnswers: 0,
    acceptedAccuracy: 0,
    masteryByLessonId: {},
    completedLessonIds: [],
    currentLessonId: null,
    resume: null,
    experienceBand: options.experienceBand ?? null,
    dailyGoalMinutes: options.dailyGoalMinutes ?? null,
    recommendedLessonId: options.recommendedLessonId ?? null,
    firstLessonCompletedAtMs: null,
    legacyLifetimeXp: null,
    legacyXpCatalogVersion: null,
    legacyXpLabel: null,
    createdAtMs: options.nowMs,
    updatedAtMs: options.nowMs,
  };
}

function profileToFirestore(profile: CourseProfile): DocumentData {
  return {
    catalogVersion: profile.catalogVersion,
    lifetimeXp: profile.lifetimeXp,
    currentStreak: profile.currentStreak,
    longestStreak: profile.longestStreak,
    lastStudyLocalDate: profile.lastStudyLocalDate,
    timezone: profile.timezone,
    acceptedAnswers: profile.acceptedAnswers,
    totalScoredAnswers: profile.totalScoredAnswers,
    acceptedAccuracy: profile.acceptedAccuracy,
    masteryByLessonId: profile.masteryByLessonId,
    completedLessonIds: profile.completedLessonIds,
    currentLessonId: profile.currentLessonId,
    resume: profile.resume,
    experienceBand: profile.experienceBand ?? null,
    dailyGoalMinutes: profile.dailyGoalMinutes ?? null,
    recommendedLessonId: profile.recommendedLessonId ?? null,
    firstLessonCompletedAtMs: profile.firstLessonCompletedAtMs ?? null,
    legacyLifetimeXp: profile.legacyLifetimeXp ?? null,
    legacyXpCatalogVersion: profile.legacyXpCatalogVersion ?? null,
    legacyXpLabel: profile.legacyXpLabel ?? null,
  };
}

function profileFromData(data: DocumentData): CourseProfile {
  const acceptedAnswers = Number(data.acceptedAnswers ?? 0);
  const totalScoredAnswers = Number(data.totalScoredAnswers ?? 0);
  return {
    catalogVersion: String(data.catalogVersion ?? courseBank.catalogVersion),
    lifetimeXp: Number(data.lifetimeXp ?? 0),
    currentStreak: Number(data.currentStreak ?? 0),
    longestStreak: Number(data.longestStreak ?? 0),
    lastStudyLocalDate: optionalString(data.lastStudyLocalDate) ?? null,
    timezone: sanitizeTimezone(String(data.timezone ?? "UTC")),
    acceptedAnswers,
    totalScoredAnswers,
    acceptedAccuracy: totalScoredAnswers === 0 ?
      0 :
      Number(data.acceptedAccuracy ?? acceptedAnswers / totalScoredAnswers),
    masteryByLessonId: (data.masteryByLessonId as Record<string, number>) ?? {},
    completedLessonIds: Array.isArray(data.completedLessonIds) ?
      data.completedLessonIds.map(String) :
      [],
    currentLessonId: optionalString(data.currentLessonId) ?? null,
    resume: data.resume && typeof data.resume === "object" ?
      {
        attemptId: String((data.resume as DocumentData).attemptId ?? ""),
        lessonId: String((data.resume as DocumentData).lessonId ?? ""),
        activityId: String((data.resume as DocumentData).activityId ?? ""),
        activityIndex: Number((data.resume as DocumentData).activityIndex ?? 0),
      } :
      null,
    experienceBand: optionalString(data.experienceBand) ?? null,
    dailyGoalMinutes: Number.isFinite(Number(data.dailyGoalMinutes)) ?
      Number(data.dailyGoalMinutes) :
      null,
    recommendedLessonId: optionalString(data.recommendedLessonId) ?? null,
    firstLessonCompletedAtMs: optionalNumber(data.firstLessonCompletedAtMs) ??
      null,
    legacyLifetimeXp: optionalNumber(data.legacyLifetimeXp) ?? null,
    legacyXpCatalogVersion: optionalString(data.legacyXpCatalogVersion) ?? null,
    legacyXpLabel: data.legacyXpLabel === "legacy_academy" ?
      "legacy_academy" :
      null,
  };
}

function attemptFromData(data: DocumentData): CourseAttempt {
  return {
    attemptId: String(data.attemptId),
    uid: String(data.uid),
    lessonId: String(data.lessonId),
    catalogVersion: String(data.catalogVersion),
    status: data.status === "completed" || data.status === "remediation" ?
      data.status :
      "in_progress",
    activityIndex: Number(data.activityIndex ?? 0),
    currentActivityId: String(data.currentActivityId),
    livesRemaining: Number(data.livesRemaining ?? DEFAULT_LESSON_LIVES),
    livesMax: Number(data.livesMax ?? DEFAULT_LESSON_LIVES),
    startRequestId: String(data.startRequestId ?? ""),
    acceptedCount: Number(data.acceptedCount ?? 0),
    scoredCount: Number(data.scoredCount ?? 0),
    masteryPoints: Number(data.masteryPoints ?? 0),
    masteryWeight: Number(data.masteryWeight ?? 0),
    jumpTestPassed: data.jumpTestPassed === true,
    stepCount: Number(data.stepCount ?? 0),
    createdAtMs: optionalNumber(data.createdAtMs),
    updatedAtMs: optionalNumber(data.updatedAtMs),
    completedAtMs: optionalNumber(data.completedAtMs) ?? null,
  };
}

function resumeFromAttempt(attempt: CourseAttempt): CourseResumePointer {
  return {
    attemptId: attempt.attemptId,
    lessonId: attempt.lessonId,
    activityId: attempt.currentActivityId,
    activityIndex: attempt.activityIndex,
  };
}

function ensureProfileTx(
  tx: Transaction,
  profileRef: DocumentReference,
  profileSnap: DocumentSnapshot,
  options: {catalogVersion: string; timezone: string; nowMs: number},
): void {
  if (profileSnap.exists) return;
  const profile = emptyProfile(options);
  tx.set(profileRef, {
    ...profileToFirestore(profile),
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
}

function courseProfileRef(db: Firestore, uid: string) {
  return db.collection("users").doc(uid).collection("course").doc("main");
}

function attemptRef(db: Firestore, uid: string, attemptId: string) {
  return db.collection("users").doc(uid).collection("courseAttempts")
    .doc(attemptId);
}

function sortedActivities(lesson: CourseLesson): CourseActivity[] {
  return [...lesson.activities].sort((a, b) => a.order - b.order);
}

function masteryRatio(attempt: CourseAttempt): number {
  if (attempt.masteryWeight <= 0) return 0;
  return attempt.masteryPoints / attempt.masteryWeight;
}

function explainCount(lesson: CourseLesson): number {
  return lesson.activities.filter((activity) => activity.stage === "explain")
    .length;
}

function sanitizeEntitlement(data: DocumentData): Record<string, unknown> {
  return {
    unrestrictedAccess: data.unrestrictedAccess === true,
    source: data.source ?? null,
    grantedAtMs: data.grantedAtMs ?? null,
    grantedByLessonId: data.grantedByLessonId ?? null,
  };
}

function shiftLocalDate(isoDate: string, deltaDays: number): string {
  const [year, month, day] = isoDate.split("-").map(Number);
  const utc = Date.UTC(year, month - 1, day) + deltaDays * 86400000;
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "UTC",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(new Date(utc));
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

function arraysEqual(left: string[], right: string[]): boolean {
  if (left.length !== right.length) return false;
  return left.every((value, index) => value === right[index]);
}

function asStringArray(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];
  return raw.map(String);
}

function uniqueStrings(values: string[]): string[] {
  return [...new Set(values.filter(Boolean))];
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

function optionalString(value: unknown): string | undefined {
  if (typeof value !== "string") return undefined;
  const trimmed = value.trim();
  return trimmed ? trimmed : undefined;
}

function optionalStringArray(value: unknown): string[] | undefined {
  if (!Array.isArray(value)) return undefined;
  return value.map((item) => String(item));
}

function optionalNumber(value: unknown): number | undefined {
  if (typeof value !== "number" || !Number.isFinite(value)) return undefined;
  return value;
}

function safeKey(value: unknown, field: string): string {
  const key = nonEmpty(value, field);
  if (!/^[A-Za-z0-9_-]{8,100}$/.test(key)) {
    throw new HttpsError(
      "invalid-argument",
      `${field} must be 8-100 URL-safe characters.`,
    );
  }
  return key;
}

function stringOrEmpty(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function sanitizeTimezone(value: string): string {
  try {
    Intl.DateTimeFormat("en-US", {timeZone: value});
    return value;
  } catch {
    return "UTC";
  }
}
