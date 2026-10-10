/**
 * Authoritative course attempts, soft grading, XP, streaks, lives, mastery,
 * reviews, resume, feature gates, and Section 4 Live entitlement writes.
 *
 * Agent handbook: docs/agents/04-course.md and docs/agents/08-backend.md.
 *
 * Course progress is isolated from Live Training documents — never write
 * lesson completions into liveProgress / UserStatsModel.
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
import {
  adHeartAvailability,
  applyPassiveHeartRefill,
  DEFAULT_LESSON_LIVES,
  heartFieldsToFirestore,
  heartStateFromData,
  practiceHeartGrantFromCompletion,
  profileLivesFromData,
  scheduleHeartRefillAfterLoss,
} from "./course_hearts";

export {
  AD_HEART_COOLDOWN_MS,
  AD_HEART_DAILY_MAX,
  DEFAULT_LESSON_LIVES,
  GEMS_FULL_HEART_REFILL,
  HEART_REFILL_INTERVAL_MS,
  profileLivesFromData,
  refillCourseHeartsForUser,
} from "./course_hearts";

export const XP_PER_ACCEPTED_STEP = 10;
export const XP_LESSON_COMPLETE = 25;

/** Gems granted the first time a learner studies on a local calendar day. */
export const GEMS_DAILY_QUEST = 5;
export const REVIEW_DELAY_MS = 24 * 60 * 60 * 1000;

/**
 * XP one lesson grants: accepted-step awards already on the attempt,
 * plus the completion bonus. The profile increment for completion stays
 * [XP_LESSON_COMPLETE] so step XP is not applied twice.
 */
export function lessonXpTotal(stepXp: number): number {
  const steps = Number.isFinite(stepXp) && stepXp > 0 ? stepXp : 0;
  return steps + XP_LESSON_COMPLETE;
}

/**
 * Review / replay XP: one quarter of a first-run total.
 * Matches client `reviewLessonXp` (Home REVIEW CTA and end-of-lesson total).
 */
export function reviewLessonXp(earnedXp: number): number {
  if (!Number.isFinite(earnedXp) || earnedXp <= 0) return 0;
  return Math.round(earnedXp * 0.25);
}

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
  gems: number;
  /** Hearts left for this user across lessons. */
  livesRemaining: number;
  /** Heart ceiling for this user (usually [DEFAULT_LESSON_LIVES]). */
  livesMax: number;
  /** Epoch ms when the next passive +1 heart becomes available. */
  livesNextRefillAtMs?: number | null;
  /** Local calendar date for [heartsAdClaimsToday]. */
  heartsAdClaimsLocalDate?: string | null;
  /** Rewarded-ad heart claims on [heartsAdClaimsLocalDate]. */
  heartsAdClaimsToday?: number;
  /** Epoch ms of the last rewarded-ad heart claim. */
  lastHeartAdClaimAtMs?: number | null;
  /** Remaining ad hearts today (derived). */
  adClaimsRemainingToday?: number;
  /** Epoch ms when the next ad heart claim is allowed (derived). */
  nextAdClaimAtMs?: number | null;
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
  streakGoalDays?: number | null;
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
  /**
   * True when this attempt was opened from the heart-refill Practice action.
   * Completing it restores +1 heart; voluntary map reviews leave this unset.
   */
  restoreHeartOnComplete?: boolean;
  acceptedCount: number;
  scoredCount: number;
  /**
   * Accepted answers among [scoredCount] only. Excludes explain / auto-pass
   * steps so lesson accuracy is acceptedScored / scoredCount.
   *
   * Undefined on attempts written before this field existed.
   */
  acceptedScoredCount?: number;
  masteryPoints: number;
  masteryWeight: number;
  jumpTestPassed: boolean;
  stepCount: number;
  /**
   * Full (first-run rate) accepted-step XP accrued on this attempt.
   * Review runs still accumulate here at the first-run rate so completion
   * can grant [reviewLessonXp] of the total; lifetime ledger may lag until
   * complete when [isLessonReview].
   */
  xpEarned: number;
  /** Total XP granted for this completed attempt (review-scaled when applicable). */
  lessonXpAwarded?: number;
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
  /** Epoch ms of the next passive heart, after this step's life change. */
  livesNextRefillAtMs?: number | null;
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
  /** Step XP plus the completion bonus. Absent on receipts written before this field. */
  lessonXpAwarded?: number;
  /** Gems granted for today's daily quest (0 when already claimed today). */
  gemsAwarded?: number;
  /** Wallet balance after this completion. */
  gems?: number;
  /** Hearts restored by completing a practice/replay lesson. */
  heartsRestored?: number;
  livesRemaining?: number;
  livesMax?: number;
  livesNextRefillAtMs?: number | null;
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

/**
 * Accepted accuracy for a lesson attempt: accepted scored answers / scored
 * answers. Explain auto-passes are excluded via [acceptedScoredCount].
 *
 * When [acceptedScoredCount] was never persisted (legacy attempts), subtract
 * explain activities from [acceptedCount].
 */
export function lessonAttemptAcceptedAccuracy(
  attempt: Pick<
    CourseAttempt,
    "acceptedCount" | "scoredCount" | "acceptedScoredCount"
  >,
  lesson: CourseLesson,
): number {
  if (attempt.scoredCount <= 0) return 0;
  const acceptedScored = attempt.acceptedScoredCount !== undefined ?
    attempt.acceptedScoredCount :
    Math.max(
      0,
      attempt.acceptedCount -
        sortedActivities(lesson).filter((a) => a.stage === "explain").length,
    );
  return acceptedAccuracyRatio(acceptedScored, attempt.scoredCount);
}

/** Clamped accepted / scored ratio used for profile and lesson accuracy. */
export function acceptedAccuracyRatio(
  acceptedAnswers: number,
  totalScoredAnswers: number,
): number {
  if (totalScoredAnswers <= 0) return 0;
  return Math.min(1, acceptedAnswers / totalScoredAnswers);
}

/**
 * Whether this submit counts toward scored accuracy (and mastery weight).
 * Mid-street accepts on multi-step hands do not count until the activity
 * advances; every rejection on a scored activity does.
 */
export function countsAsScoredAnswer(options: {
  scored: boolean;
  advanceActivity: boolean;
  accepted: boolean;
}): boolean {
  return options.scored &&
    (options.advanceActivity || !options.accepted);
}

/**
 * True when every activity has already been accepted and the attempt should
 * complete rather than accept another submit.
 *
 * Explain steps count as accepted, so acceptedCount is compared directly to
 * the activity list length — do not add explainCount again.
 */
export function isLessonAttemptReadyToComplete(
  attempt: Pick<CourseAttempt, "status" | "activityIndex" | "acceptedCount">,
  lesson: CourseLesson,
): boolean {
  if (attempt.status === "remediation") return false;
  const activities = sortedActivities(lesson);
  if (activities.length === 0) return false;
  if (attempt.status === "completed") return true;
  return attempt.activityIndex >= activities.length ||
    attempt.acceptedCount >= activities.length;
}

/** Soft-grade acceptance and life-loss rules for one scored response. */
export function evaluateLifeAndAcceptance(options: {
  grade: SoftGrade;
  stage: ActivityStage;
}): Pick<GradeOutcome, "accepted" | "lifeLost" | "masteryWeight"> {
  const accepted = ACCEPTED_GRADES.has(options.grade);
  // Any non-accepted grade costs a heart, including guided practice.
  const lifeLost = !accepted;
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

/**
 * Gems for finishing a lesson on [todayLocalDate].
 *
 * The first step submit of the day already consumes study-streak credit and
 * writes `lastStudyLocalDate`. Completion always follows that submit, so
 * keying gems off streak credit never persists the daily quest reward.
 * [lastDailyGemLocalDate] is the once-per-day stamp for the gem grant.
 */
export function dailyQuestGemsAwarded(options: {
  lastDailyGemLocalDate: string | null;
  todayLocalDate: string;
}): number {
  if (options.lastDailyGemLocalDate === options.todayLocalDate) return 0;
  return GEMS_DAILY_QUEST;
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
  const streakGoalDays = sanitizeStreakGoalDays(input.streakGoalDays);
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
      if (
        streakGoalDays != null &&
        !Number.isFinite(Number(existing.streakGoalDays))
      ) {
        patch.streakGoalDays = streakGoalDays;
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
      streakGoalDays,
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
  const restoreHeartOnComplete = input.restoreHeartOnComplete === true;
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
    // Soft save-progress CTA lives on the client. Guests may continue the
    // course anonymously; linking remains optional until they choose it.
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
        const passive = applyPassiveHeartRefill(
          heartStateFromData(
            profileSnap.exists ? profileSnap.data() : undefined,
          ),
          nowMs,
        );
        // Practice from the refill sheet reuses this open attempt. Stamp the
        // grant here — a resume that ignores the flag finishes with no heart,
        // and a first lesson at zero hearts stays unsubmittable.
        const grantHeartOnComplete =
          restoreHeartOnComplete && attempt.restoreHeartOnComplete !== true;
        const synced: CourseAttempt = {
          ...attempt,
          livesRemaining: passive.livesRemaining,
          livesMax: passive.livesMax,
          status: attempt.status === "remediation" &&
              passive.livesRemaining > 0 ?
            "in_progress" :
            attempt.status,
          ...(restoreHeartOnComplete ? {restoreHeartOnComplete: true} : {}),
        };
        if (passive.changed || synced.livesRemaining !== attempt.livesRemaining ||
          synced.status !== attempt.status || grantHeartOnComplete) {
          tx.set(profileRef, {
            ...heartFieldsToFirestore(passive),
            updatedAt: FieldValue.serverTimestamp(),
          }, {merge: true});
          tx.set(priorAttemptSnap.ref, {
            livesRemaining: synced.livesRemaining,
            livesMax: synced.livesMax,
            status: synced.status,
            ...(grantHeartOnComplete ? {restoreHeartOnComplete: true} : {}),
            updatedAt: FieldValue.serverTimestamp(),
          }, {merge: true});
        }
        tx.set(requestRef, {
          status: "ready",
          attemptId: synced.attemptId,
          lessonId,
          updatedAt: FieldValue.serverTimestamp(),
        }, {merge: true});
        return {
          attempt: synced,
          resume: resumeFromAttempt(synced),
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

    // Carry user hearts into the attempt — never reset to full per lesson.
    // Accrue any time-based hearts before the attempt snapshot is taken.
    const passive = applyPassiveHeartRefill(
      heartStateFromData(profileSnap.exists ? profileSnap.data() : undefined),
      nowMs,
    );
    const isPracticeReplay = completedForPrereqs.includes(lessonId);
    if (passive.livesRemaining <= 0 && !allowsZeroHeartPlay({
      lessonCompleted: isPracticeReplay,
      practiceLesson: isPracticeLesson(located.lesson),
      restoreHeartOnComplete,
    })) {
      throw new HttpsError(
        "failed-precondition",
        "Out of hearts. Refill before starting a lesson.",
      );
    }

    const first = activities[0];
    const attempt: CourseAttempt = {
      attemptId: newAttemptId,
      uid: options.uid,
      lessonId,
      catalogVersion,
      status: "in_progress",
      activityIndex: 0,
      currentActivityId: first.id,
      livesRemaining: passive.livesRemaining,
      livesMax: passive.livesMax,
      startRequestId,
      ...(restoreHeartOnComplete ? {restoreHeartOnComplete: true} : {}),
      acceptedCount: 0,
      scoredCount: 0,
      acceptedScoredCount: 0,
      masteryPoints: 0,
      masteryWeight: 0,
      jumpTestPassed: false,
      stepCount: 0,
      xpEarned: 0,
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
    // Practice / review of an already-completed lesson must not move the
    // course progress pointer (currentLessonId / resume). Otherwise going
    // back to review an earlier node regresses Home focus and can wipe an
    // in-progress first-run further along the path.
    const profileUpdate: DocumentData = {
      catalogVersion,
      timezone,
      ...heartFieldsToFirestore(passive),
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (!isPracticeReplay) {
      profileUpdate.currentLessonId = lessonId;
      profileUpdate.resume = resumeFromAttempt(attempt);
    }
    tx.set(profileRef, profileUpdate, {merge: true});
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
    const located = findLesson(attempt.lessonId);
    if (!located) {
      throw new HttpsError("failed-precondition", "Lesson missing from catalog.");
    }
    // First-run lessons stop at 0 hearts until a refill restores the attempt.
    // Practice / replay may start at 0 so learners can earn a heart back.
    const priorCompletedForHearts = Array.isArray(
      profileSnap.data()?.completedLessonIds,
    ) ?
      profileSnap.data()!.completedLessonIds as string[] :
      [];
    const isPracticeOrReplaySubmit = allowsZeroHeartPlay({
      lessonCompleted: priorCompletedForHearts.includes(attempt.lessonId),
      practiceLesson: isPracticeLesson(located.lesson),
      restoreHeartOnComplete: attempt.restoreHeartOnComplete === true,
    });
    // Profile is the heart wallet. Passive refill updates it while this
    // attempt stays open; grading from the stale attempt deletes accrued
    // hearts and keeps a zero-heart lesson blocked after one comes back.
    const hearts = resolveSubmitHeartState({
      attemptStatus: attempt.status,
      attemptLivesRemaining: attempt.livesRemaining,
      attemptLivesMax: attempt.livesMax,
      profileData: profileSnap.data(),
      profileExists: profileSnap.exists,
      nowMs,
      isPracticeOrReplay: isPracticeOrReplaySubmit,
    });
    if (hearts.blocked) {
      throw new HttpsError(
        "failed-precondition",
        "Out of hearts. Refill before continuing.",
      );
    }
    if (isLessonAttemptReadyToComplete(
      {...attempt, status: hearts.status},
      located.lesson,
    )) {
      throw new HttpsError(
        "failed-precondition",
        "All activities are finished. Complete the lesson.",
      );
    }
    if (attempt.currentActivityId !== activityId) {
      throw new HttpsError(
        "aborted",
        "Stale activity. Resume the lesson and retry.",
      );
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

    let livesRemaining = hearts.livesRemaining;
    const livesMax = hearts.livesMax;
    let lifeLost = false;
    let livesNextRefillAtMs = hearts.livesNextRefillAtMs;
    if (outcome.lifeLost && livesRemaining > 0) {
      livesRemaining -= 1;
      lifeLost = true;
      livesNextRefillAtMs = scheduleHeartRefillAfterLoss({
        livesRemaining,
        livesMax,
        livesNextRefillAtMs,
        nowMs,
      });
    }
    const remediationRequired = lifeLost && livesRemaining <= 0;
    const scored = activity.stage !== "explain";
    const activities = sortedActivities(located.lesson);
    const currentIndex = activities.findIndex((item) => item.id === activityId);
    // Multi-step hands grade each street in place; only the last street
    // advances the activity cursor (otherwise street 2 never appears).
    const advanceActivity = shouldAdvanceActivityAfterSubmit({
      activity,
      choiceId,
      accepted: outcome.accepted,
    });
    // One accept per activity so multi-step streets don't trip
    // isLessonAttemptReadyToComplete early via acceptedCount >= length.
    const acceptedCount = attempt.acceptedCount + (advanceActivity ? 1 : 0);
    const countsAsScored = countsAsScoredAnswer({
      scored,
      advanceActivity,
      accepted: outcome.accepted,
    });
    const scoredCount = attempt.scoredCount + (countsAsScored ? 1 : 0);
    const acceptedScoredCount = (attempt.acceptedScoredCount ?? 0) +
      (countsAsScored && outcome.accepted ? 1 : 0);
    const masteryPoints = attempt.masteryPoints + outcome.masteryWeight;
    const masteryWeight = attempt.masteryWeight + (countsAsScored ? 1 : 0);
    const jumpTestPassed = attempt.jumpTestPassed ||
      (activity.stage === "jump_test" && advanceActivity);

    const advance = advanceActivity;
    const nextIndex = advance ?
      Math.min(currentIndex + 1, activities.length - 1) :
      currentIndex;
    const nextActivityId = activities[nextIndex]?.id ?? activityId;

    // Track full first-run step XP on the attempt. Reviews defer the ledger
    // grant to completion so TOTAL XP can be 25% of what this run earned.
    const priorCompleted = Array.isArray(profileSnap.data()?.completedLessonIds) ?
      profileSnap.data()!.completedLessonIds as string[] :
      [];
    const isReview = priorCompleted.includes(attempt.lessonId);
    const fullStepXp = outcome.accepted ? XP_PER_ACCEPTED_STEP : 0;
    const xpAwarded = isReview ? 0 : fullStepXp;
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
      hearts.status === "remediation" && outcome.accepted ?
      "in_progress" :
      hearts.status;

    const nextAttempt: CourseAttempt = {
      ...attempt,
      livesMax,
      activityIndex: nextIndex,
      currentActivityId: advance && currentIndex < activities.length - 1 ?
        nextActivityId :
        activityId,
      livesRemaining,
      acceptedCount,
      scoredCount,
      acceptedScoredCount,
      masteryPoints,
      masteryWeight,
      jumpTestPassed,
      stepCount: attempt.stepCount + 1,
      xpEarned: attempt.xpEarned + fullStepXp,
      status: nextStatus,
      updatedAtMs: nowMs,
    };
    // After an accepted final activity, move the cursor past the end so
    // resume cannot re-grade the last step (double XP / extra life loss).
    if (advance && currentIndex >= activities.length - 1) {
      nextAttempt.currentActivityId = activityId;
      nextAttempt.activityIndex = activities.length;
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
      livesNextRefillAtMs,
    };
    if (outcome.betterChoiceId) {
      result.betterChoiceId = outcome.betterChoiceId;
    }
    if (outcome.reversalRead) {
      result.reversalRead = outcome.reversalRead;
    }

    // Drop optional undefined fields (e.g. lessonXpAwarded mid-lesson).
    // Firestore rejects undefined document values.
    tx.set(attemptDoc, omitUndefined({
      ...nextAttempt,
      updatedAt: FieldValue.serverTimestamp(),
    }), {merge: true});
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
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      lastStudyLocalDate: streak.lastStudyLocalDate,
      timezone,
      // Keep user hearts in sync when a life is spent (and backfill max).
      livesRemaining,
      livesMax,
      livesNextRefillAtMs,
      updatedAt: FieldValue.serverTimestamp(),
    };
    // Reviews keep the furthest-progress pointer intact.
    if (!isReview) {
      profileUpdate.currentLessonId = attempt.lessonId;
      profileUpdate.resume = resume;
    }
    // Only scored answers affect accepted accuracy (docs/architecture.md).
    // Explain auto-passes must not inflate the numerator past the denominator.
    if (countsAsScored) {
      profileUpdate.totalScoredAnswers = FieldValue.increment(1);
    }
    if (countsAsScored && outcome.accepted) {
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
      (countsAsScored && outcome.accepted ? 1 : 0);
    const totalScored = Number(profileSnap.data()?.totalScoredAnswers ?? 0) +
      (countsAsScored ? 1 : 0);
    profileUpdate.acceptedAccuracy =
      acceptedAccuracyRatio(acceptedAnswers, totalScored);
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
      const locatedCompleted = findLesson(attempt.lessonId);
      const storedLessonXp = optionalNumber(attemptSnap.data()?.lessonXpAwarded);
      const lessonXpAwardedDup = storedLessonXp ?? lessonXpTotal(attempt.xpEarned);
      return {
        attemptId,
        lessonId: attempt.lessonId,
        xpAwarded: 0,
        lessonXpAwarded: lessonXpAwardedDup,
        mastery: masteryRatio(attempt),
        streak: profile.currentStreak,
        acceptedAccuracy: locatedCompleted ?
          lessonAttemptAcceptedAccuracy(attempt, locatedCompleted.lesson) :
          profile.acceptedAccuracy,
        liveTrainingGranted: entitlementSnap.exists === true &&
          entitlementSnap.data()?.unrestrictedAccess === true,
        duplicate: true,
        resume: null,
        gemsAwarded: 0,
        gems: profile.gems,
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
    if (!isLessonAttemptReadyToComplete(attempt, located.lesson)) {
      throw new HttpsError(
        "failed-precondition",
        "Finish every activity before completing the lesson.",
      );
    }

    const priorCompleted = Array.isArray(profileSnap.data()?.completedLessonIds) ?
      profileSnap.data()!.completedLessonIds as string[] :
      [];
    const isReview = priorCompleted.includes(attempt.lessonId);

    const mastery = masteryRatio(attempt);
    const fullLessonXp = lessonXpTotal(attempt.xpEarned);
    // Reviews grant 25% of what this run earned (steps + completion).
    // First runs keep the completion bonus separate from step ledger rows.
    const xpAwarded = isReview ?
      reviewLessonXp(fullLessonXp) :
      XP_LESSON_COMPLETE;
    const lessonXpAwarded = isReview ? xpAwarded : fullLessonXp;
    const timezone = String(profileSnap.data()?.timezone ?? "UTC");
    const today = localDateString(nowMs, timezone);
    const streak = applyStudyDayStreak({
      currentStreak: Number(profileSnap.data()?.currentStreak ?? 0),
      longestStreak: Number(profileSnap.data()?.longestStreak ?? 0),
      lastStudyLocalDate: optionalString(profileSnap.data()?.lastStudyLocalDate) ??
        null,
      todayLocalDate: today,
    });
    const lastDailyGemLocalDate =
      optionalString(profileSnap.data()?.lastDailyGemLocalDate) ?? null;
    const gemsAwarded = dailyQuestGemsAwarded({
      lastDailyGemLocalDate,
      todayLocalDate: today,
    });
    const gemsBalance = Number(profileSnap.data()?.gems ?? 0) + gemsAwarded;

    const passiveHearts = applyPassiveHeartRefill(
      heartStateFromData(profileSnap.data()),
      nowMs,
    );
    const practiceGrant = practiceHeartGrantFromCompletion({
      state: {...passiveHearts, gems: gemsBalance},
      nowMs,
      restoreHeartOnComplete: attempt.restoreHeartOnComplete === true,
    });
    const heartState = practiceGrant ?? passiveHearts;

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
      ...priorCompleted,
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
      lessonXpAwarded,
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
        reason: isReview ? "lesson_review" : "lesson_complete",
        attemptId,
        lessonId: attempt.lessonId,
        idempotencyKey,
        createdAt: FieldValue.serverTimestamp(),
        createdAtMs: nowMs,
      },
    );

    const acceptedAnswers = Number(profileSnap.data()?.acceptedAnswers ?? 0);
    const totalScored = Number(profileSnap.data()?.totalScoredAnswers ?? 0);
    const profileAcceptedAccuracy =
      acceptedAccuracyRatio(acceptedAnswers, totalScored);
    // Celebration screen shows this lesson's accuracy, not lifetime profile.
    const acceptedAccuracy =
      lessonAttemptAcceptedAccuracy(attempt, located.lesson);

    const firstLessonCompletedAtMs =
      Number(profileSnap.data()?.firstLessonCompletedAtMs ?? 0) ||
      (completedLessonIds.length === 1 ? nowMs : null);
    const existingResume = profileSnap.data()?.resume as
      | DocumentData
      | undefined;
    const resumePointsHere =
      optionalString(existingResume?.attemptId) === attemptId;
    // Completing a review must not clear an unrelated first-run resume
    // further along the path. Only clear when this attempt owns the pointer.
    const clearProgressPointer = !isReview || resumePointsHere;
    tx.set(profileRef, {
      lifetimeXp: FieldValue.increment(xpAwarded),
      ...(gemsAwarded > 0 ? {
        gems: FieldValue.increment(gemsAwarded),
        lastDailyGemLocalDate: today,
      } : {}),
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      lastStudyLocalDate: streak.lastStudyLocalDate,
      completedLessonIds,
      masteryByLessonId,
      ...(clearProgressPointer ?
        {currentLessonId: null, resume: null} :
        {}),
      acceptedAccuracy: profileAcceptedAccuracy,
      ...heartFieldsToFirestore(heartState),
      ...(firstLessonCompletedAtMs ?
        {firstLessonCompletedAtMs} :
        {}),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});

    const result: CompleteCourseLessonResult = {
      attemptId,
      lessonId: attempt.lessonId,
      xpAwarded,
      lessonXpAwarded,
      mastery,
      streak: streak.currentStreak,
      acceptedAccuracy,
      liveTrainingGranted,
      duplicate: false,
      resume: null,
      gemsAwarded,
      gems: gemsBalance,
      heartsRestored: practiceGrant?.heartsRestored ?? 0,
      livesRemaining: heartState.livesRemaining,
      livesMax: heartState.livesMax,
      livesNextRefillAtMs: heartState.livesNextRefillAtMs,
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
  /**
   * Test seam. Runs after the initial heart read and before the
   * transactional persist, so a concurrent wallet write can land between
   * them. Production callers leave this unset.
   */
  beforePassiveHeartPersist?: () => Promise<void>;
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
  let profile = profileSnap.exists ?
    profileFromData(profileSnap.data()!) :
    null;
  const nowMs = Date.now();
  if (profile && profileSnap.exists) {
    const heartState = heartStateFromData(profileSnap.data());
    const preview = applyPassiveHeartRefill(heartState, nowMs);
    // Re-read inside a transaction. A blind set of the first snapshot
    // overwrites a heart spent, a gem refill, or an ad claim that committed
    // after this read (Home refresh while a lesson is in progress).
    let passive = preview;
    if (preview.changed) {
      if (options.beforePassiveHeartPersist) {
        await options.beforePassiveHeartPersist();
      }
      passive = await persistPassiveHeartRefillTx({
        db,
        uid: options.uid,
        nowMs,
      });
    }
    const localDate = localDateString(nowMs, profile.timezone);
    const availability = adHeartAvailability({
      state: passive,
      localDate,
      nowMs,
    });
    profile = {
      ...profile,
      livesRemaining: passive.livesRemaining,
      livesMax: passive.livesMax,
      livesNextRefillAtMs: passive.livesNextRefillAtMs,
      heartsAdClaimsLocalDate: passive.heartsAdClaimsLocalDate,
      heartsAdClaimsToday: passive.heartsAdClaimsToday,
      lastHeartAdClaimAtMs: passive.lastHeartAdClaimAtMs,
      adClaimsRemainingToday: availability.adClaimsRemainingToday,
      nextAdClaimAtMs: availability.nextAdClaimAtMs,
    };
  }
  let openAttempt: CourseAttempt | null = null;
  if (profile?.resume?.attemptId) {
    const snap = await attemptRef(db, options.uid, profile.resume.attemptId)
      .get();
    if (snap.exists) {
      const attempt = attemptFromData(snap.data()!);
      const completedIds = profile.completedLessonIds;
      const isPracticeReplay = completedIds.includes(attempt.lessonId);
      // Do not surface review/practice attempts as the Home resume pointer.
      if (
        !isPracticeReplay &&
        (attempt.status === "in_progress" || attempt.status === "remediation")
      ) {
        openAttempt = {
          ...attempt,
          livesRemaining: profile.livesRemaining,
          livesMax: profile.livesMax,
        };
      }
    }
  }
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

/**
 * Whether an accepted submit should move the lesson cursor to the next
 * activity. Explain steps always advance. Multi-step hands stay put until the
 * graded choice belongs to the last authored street.
 */
export function shouldAdvanceActivityAfterSubmit(options: {
  activity: CourseActivity;
  choiceId?: string | null;
  accepted: boolean;
}): boolean {
  const {activity, choiceId, accepted} = options;
  if (activity.stage === "explain") return true;
  if (!accepted) return false;
  const steps = activity.handSteps;
  if (!Array.isArray(steps) || steps.length <= 1) return true;
  if (!choiceId) return true;
  // Prefer the *last* street that owns this choiceId so duplicate ids across
  // streets (legacy content) still advance on the final street.
  let stepIndex = -1;
  for (let i = 0; i < steps.length; i++) {
    if (steps[i]?.choices?.some((choice: CourseChoice) => choice.id === choiceId)) {
      stepIndex = i;
    }
  }
  // Unknown choice: keep prior advance-on-accept behavior.
  if (stepIndex < 0) return true;
  return stepIndex >= steps.length - 1;
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
const STREAK_GOAL_DAYS = new Set([7, 14, 30, 50]);

function sanitizeExperienceBand(value: string | undefined): string | null {
  if (!value) return null;
  return EXPERIENCE_BANDS.has(value) ? value : null;
}

function sanitizeDailyGoalMinutes(value: unknown): number | null {
  const n = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(n)) return null;
  return DAILY_GOAL_MINUTES.has(n) ? n : null;
}

function sanitizeStreakGoalDays(value: unknown): number | null {
  const n = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(n)) return null;
  return STREAK_GOAL_DAYS.has(n) ? n : null;
}

function emptyProfile(options: {
  catalogVersion: string;
  timezone: string;
  nowMs: number;
  experienceBand?: string | null;
  dailyGoalMinutes?: number | null;
  streakGoalDays?: number | null;
  recommendedLessonId?: string | null;
}): CourseProfile {
  return {
    catalogVersion: options.catalogVersion,
    lifetimeXp: 0,
    gems: 0,
    livesRemaining: DEFAULT_LESSON_LIVES,
    livesMax: DEFAULT_LESSON_LIVES,
    livesNextRefillAtMs: null,
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
    streakGoalDays: options.streakGoalDays ?? null,
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
    gems: profile.gems,
    livesRemaining: profile.livesRemaining,
    livesMax: profile.livesMax,
    livesNextRefillAtMs: profile.livesNextRefillAtMs ?? null,
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
    streakGoalDays: profile.streakGoalDays ?? null,
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
  const lives = profileLivesFromData(data);
  const hearts = heartStateFromData(data);
  return {
    catalogVersion: String(data.catalogVersion ?? courseBank.catalogVersion),
    lifetimeXp: Number(data.lifetimeXp ?? 0),
    gems: Number(data.gems ?? 0),
    livesRemaining: lives.livesRemaining,
    livesMax: lives.livesMax,
    livesNextRefillAtMs: Number.isFinite(Number(data.livesNextRefillAtMs)) &&
      Number(data.livesNextRefillAtMs) > 0 ?
      Math.floor(Number(data.livesNextRefillAtMs)) :
      null,
    heartsAdClaimsLocalDate: hearts.heartsAdClaimsLocalDate,
    heartsAdClaimsToday: hearts.heartsAdClaimsToday,
    lastHeartAdClaimAtMs: hearts.lastHeartAdClaimAtMs,
    currentStreak: Number(data.currentStreak ?? 0),
    longestStreak: Number(data.longestStreak ?? 0),
    lastStudyLocalDate: optionalString(data.lastStudyLocalDate) ?? null,
    timezone: sanitizeTimezone(String(data.timezone ?? "UTC")),
    acceptedAnswers,
    totalScoredAnswers,
    acceptedAccuracy: acceptedAccuracyRatio(acceptedAnswers, totalScoredAnswers),
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
    streakGoalDays: sanitizeStreakGoalDays(data.streakGoalDays),
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
  // Omit undefined optionals so later spreads are safe to write to Firestore.
  return omitUndefined({
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
    restoreHeartOnComplete: data.restoreHeartOnComplete === true ?
      true :
      undefined,
    acceptedCount: Number(data.acceptedCount ?? 0),
    scoredCount: Number(data.scoredCount ?? 0),
    acceptedScoredCount: data.acceptedScoredCount === undefined ||
      data.acceptedScoredCount === null ?
      undefined :
      Number(data.acceptedScoredCount),
    masteryPoints: Number(data.masteryPoints ?? 0),
    masteryWeight: Number(data.masteryWeight ?? 0),
    jumpTestPassed: data.jumpTestPassed === true,
    stepCount: Number(data.stepCount ?? 0),
    xpEarned: Number(data.xpEarned ?? 0),
    lessonXpAwarded: optionalNumber(data.lessonXpAwarded),
    createdAtMs: optionalNumber(data.createdAtMs),
    updatedAtMs: optionalNumber(data.updatedAtMs),
    completedAtMs: optionalNumber(data.completedAtMs) ?? null,
  }) as CourseAttempt;
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

/**
 * Persists passive heart accrual without clobbering a newer wallet.
 *
 * The transaction re-reads the profile, so a submit or refill that landed
 * after the caller's first snapshot is included before any write.
 */
async function persistPassiveHeartRefillTx(options: {
  db: Firestore;
  uid: string;
  nowMs: number;
}): Promise<ReturnType<typeof applyPassiveHeartRefill>> {
  const profileRef = courseProfileRef(options.db, options.uid);
  return options.db.runTransaction(async (tx) => {
    const freshSnap = await tx.get(profileRef);
    if (!freshSnap.exists) {
      const missing = applyPassiveHeartRefill(
        heartStateFromData(undefined),
        options.nowMs,
      );
      return {...missing, changed: false, heartsRestored: 0};
    }
    const accrued = applyPassiveHeartRefill(
      heartStateFromData(freshSnap.data()),
      options.nowMs,
    );
    if (accrued.changed) {
      tx.set(profileRef, {
        ...heartFieldsToFirestore(accrued),
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
    }
    return accrued;
  });
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

/** Practice nodes (title/id) may play at zero hearts like a Duo practice. */
function isPracticeLesson(lesson: CourseLesson): boolean {
  const id = lesson.id.toLowerCase();
  const title = lesson.title.toLowerCase();
  return id.includes("-practice-") || title.includes("practice");
}

/**
 * True when a learner may start or submit at zero hearts.
 *
 * Already-completed lessons and practice nodes may continue. A heart-refill
 * Practice run may too, once restoreHeartOnComplete is set — including when
 * that start resumes a first lesson that has not been completed yet.
 */
export function allowsZeroHeartPlay(options: {
  lessonCompleted: boolean;
  practiceLesson: boolean;
  restoreHeartOnComplete: boolean;
}): boolean {
  return options.lessonCompleted ||
    options.practiceLesson ||
    options.restoreHeartOnComplete;
}

/**
 * First-run lessons pause at zero hearts until a refill; practice/replay may
 * keep submitting so learners can earn a heart back.
 */
export function shouldBlockSubmitForHearts(options: {
  livesRemaining: number;
  isPracticeOrReplay: boolean;
}): boolean {
  return options.livesRemaining <= 0 && !options.isPracticeOrReplay;
}

/**
 * Heart count a step submit must grade against.
 *
 * Passive refill writes the profile while an open attempt keeps the old
 * count. Submits that trust the attempt then write that stale count back
 * onto the profile, deleting the free heart, and a first-run lesson stuck
 * at zero never sees the heart that would lift the gate.
 *
 * When the profile has a numeric wallet, accrue passive hearts first and
 * grade from that. Otherwise keep the attempt count (no profile to clobber).
 */
export function resolveSubmitHeartState(options: {
  attemptStatus: CourseAttempt["status"];
  attemptLivesRemaining: number;
  attemptLivesMax: number;
  profileData: DocumentData | undefined;
  profileExists: boolean;
  nowMs: number;
  isPracticeOrReplay: boolean;
}): {
  livesRemaining: number;
  livesMax: number;
  status: CourseAttempt["status"];
  livesNextRefillAtMs: number | null;
  blocked: boolean;
} {
  const wallet = options.profileExists &&
    options.profileData != null &&
    Object.prototype.hasOwnProperty.call(options.profileData, "livesRemaining") &&
    Number.isFinite(Number(options.profileData.livesRemaining));
  if (!wallet) {
    const livesMax = options.attemptLivesMax > 0 ?
      options.attemptLivesMax :
      DEFAULT_LESSON_LIVES;
    const raw = Number(options.attemptLivesRemaining);
    const livesRemaining = Number.isFinite(raw) ?
      Math.max(0, Math.min(livesMax, Math.floor(raw))) :
      0;
    return {
      livesRemaining,
      livesMax,
      status: options.attemptStatus === "remediation" && livesRemaining > 0 ?
        "in_progress" :
        options.attemptStatus,
      livesNextRefillAtMs: null,
      blocked: shouldBlockSubmitForHearts({
        livesRemaining,
        isPracticeOrReplay: options.isPracticeOrReplay,
      }),
    };
  }
  const passive = applyPassiveHeartRefill(
    heartStateFromData(options.profileData),
    options.nowMs,
  );
  const status: CourseAttempt["status"] =
    options.attemptStatus === "remediation" && passive.livesRemaining > 0 ?
      "in_progress" :
      options.attemptStatus;
  return {
    livesRemaining: passive.livesRemaining,
    livesMax: passive.livesMax,
    status,
    livesNextRefillAtMs: passive.livesNextRefillAtMs,
    blocked: shouldBlockSubmitForHearts({
      livesRemaining: passive.livesRemaining,
      isPracticeOrReplay: options.isPracticeOrReplay,
    }),
  };
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

/**
 * Drops keys whose value is `undefined` (Firestore rejects those).
 * Keeps `null`, `0`, and empty string.
 */
export function omitUndefined<T extends Record<string, unknown>>(
  value: T,
): {[K in keyof T]?: Exclude<T[K], undefined>} {
  const out: Record<string, unknown> = {};
  for (const [key, entry] of Object.entries(value)) {
    if (entry !== undefined) out[key] = entry;
  }
  return out as {[K in keyof T]?: Exclude<T[K], undefined>};
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
