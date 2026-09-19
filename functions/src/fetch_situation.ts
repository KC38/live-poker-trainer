/**
 * Authenticated fetch of exactly one unseen situation for a table setup.
 */

import {
  FieldValue,
  getFirestore,
  type DocumentSnapshot,
  type Firestore,
} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {
  ensureTableSetupDoc,
  poolRefs,
  requestPoolRefill,
} from "./pool";
import {buildSetupKey, parseTableSetupInput} from "./setup_key";
import type {SituationPayload, TableSetupInput} from "./situation_types";
import {filterUnseenSituationIds} from "./validate_situation";
import {NEVER_SERVED_LOW_WATER} from "./situation_types";

export const FETCHES_PER_HOUR = 120;
export const PREPARING_POLLS_PER_HOUR = 720;
export const DISTINCT_SETUPS_PER_DAY = 8;
const ALLOCATION_PAGE_SIZE = 100;

export interface FetchSituationResult {
  situationId: string;
  setupKey: string;
  payload: SituationPayload;
  refillTriggered: boolean;
}

interface SetupGenerationState {
  exists: boolean;
  situationCount: number;
  generationStatus?: string;
}

/**
 * Serves one unseen situation, creating a receipt atomically.
 *
 * May trigger a pool refill when never-served remaining is at/below low water
 * or when the pool is empty.
 */
export async function fetchSituationForUser(options: {
  uid: string;
  rawSetup: unknown;
  db?: Firestore;
  ensureSetup?: typeof ensureTableSetupDoc;
  allocate?: typeof allocateUnseenSituation;
  queueRefill?: typeof requestPoolRefill;
  enforceLimits?: typeof enforceSituationFetchLimits;
  convertReservation?: typeof convertDealReservationToPreparingPoll;
  readSetupState?: (
    db: Firestore,
    setupKey: string,
  ) => Promise<SetupGenerationState>;
  readSituationCount?: (db: Firestore, setupKey: string) => Promise<number>;
}): Promise<FetchSituationResult> {
  const db = options.db ?? getFirestore();
  const setup = parseTableSetupInput(options.rawSetup);
  const setupKey = buildSetupKey(setup);
  const ensureSetup = options.ensureSetup ?? ensureTableSetupDoc;
  const allocate = options.allocate ?? allocateUnseenSituation;
  const queueRefill = options.queueRefill ?? requestPoolRefill;
  const enforceLimits = options.enforceLimits ?? enforceSituationFetchLimits;
  const convertReservation =
    options.convertReservation ?? convertDealReservationToPreparingPoll;
  const readSetupState =
    options.readSetupState ??
    (async (firestore, key) => {
      const snap = await poolRefs(firestore, key).setupRef.get();
      const data = snap.data();
      return {
        exists: snap.exists,
        situationCount: Number(data?.situationCount ?? 0),
        generationStatus:
          typeof data?.generation?.status === "string" ?
            data.generation.status :
            undefined,
      };
    });
  const readSituationCount =
    options.readSituationCount ??
    (async (firestore, key) => {
      const snap = await poolRefs(firestore, key).setupRef.get();
      return Number(snap.data()?.situationCount ?? 0);
    });

  const setupState = await readSetupState(db, setupKey);
  // Derive from Firestore only; never trust a client-supplied flag.
  const preparingBeforeAllocate = isPreparingPollState(setupState);

  // Prep waits charge the poll bucket. Deal quota is reserved up front for
  // ready pools so a successful allocate cannot outrun the hourly cap, and
  // empty-pool retries never burn deal slots (see convert below).
  if (preparingBeforeAllocate) {
    await enforceLimits({
      db,
      uid: options.uid,
      setupKey,
      preparingPoll: true,
    });
  } else {
    await enforceLimits({
      db,
      uid: options.uid,
      setupKey,
      preparingPoll: false,
    });
  }

  await ensureSetup(db, setup, setupKey);
  const allocated = await allocate({
    db,
    uid: options.uid,
    setupKey,
    setup,
  });

  if (!allocated) {
    if (!preparingBeforeAllocate) {
      // Ready-looking pool had nothing unseen — this is a prep wait, not a deal.
      await convertReservation({
        db,
        uid: options.uid,
      });
    }
    const situationCount = await readSituationCount(db, setupKey);
    await queueRefill({
      db,
      setupKey,
      reason: situationCount === 0 ? "empty" : "exhausted",
    });
    throw new HttpsError(
      "unavailable",
      "Situation pool is generating. Retry in a moment.",
    );
  }

  if (preparingBeforeAllocate) {
    // Hand finally delivered after a prep wait — charge the deal quota now.
    await enforceLimits({
      db,
      uid: options.uid,
      setupKey,
      preparingPoll: false,
    });
  }

  let refillTriggered = false;
  if (allocated.neverServedRemaining <= NEVER_SERVED_LOW_WATER) {
    await queueRefill({
      db,
      setupKey,
      reason: "low-water",
    });
    // True means the low-water path requested/confirmed asynchronous refill;
    // the queue transaction may already have found an equivalent active job.
    refillTriggered = true;
  }

  return {
    situationId: allocated.situationId,
    setupKey: allocated.setupKey,
    payload: allocated.payload,
    refillTriggered,
  };
}

/**
 * True when the setup is empty / not ready, so client retries are prep polls.
 *
 * Includes first-touch (missing doc) and idle empty pools: those previously
 * burned the hourly deal quota before Gemini published anything.
 */
export function isPreparingPollState(state: SetupGenerationState): boolean {
  if (!state.exists) return true;
  if (state.situationCount > 0) return false;
  const status = state.generationStatus;
  return (
    status === undefined ||
    status === "idle" ||
    status === "queued" ||
    status === "generating"
  );
}

/**
 * Moves a reserved deal slot into the preparing-poll bucket.
 *
 * Used when a non-empty pool still cannot allocate (exhausted / refill), so
 * the caller is waiting on generation rather than consuming a training hand.
 */
export async function convertDealReservationToPreparingPoll(options: {
  db: Firestore;
  uid: string;
  nowMs?: number;
}): Promise<void> {
  const nowMs = options.nowMs ?? Date.now();
  const hourMs = 60 * 60 * 1000;
  const hourStartMs = Math.floor(nowMs / hourMs) * hourMs;
  const limitRef = options.db
    .collection("users")
    .doc(options.uid)
    .collection("serverLimits")
    .doc("situationFetch");

  await options.db.runTransaction(async (tx) => {
    const snap = await tx.get(limitRef);
    const data = snap.data() ?? {};

    const sameRequestHour = data.requestWindowStartMs === hourStartMs;
    const requestCount = sameRequestHour ? Number(data.requestCount ?? 0) : 0;
    if (!Number.isSafeInteger(requestCount) || requestCount < 0) {
      throw new Error("Invalid fetch quota state");
    }

    const samePollHour = data.pollWindowStartMs === hourStartMs;
    const pollCount = samePollHour ? Number(data.pollCount ?? 0) : 0;
    if (!Number.isSafeInteger(pollCount) || pollCount < 0) {
      throw new Error("Invalid preparing poll quota state");
    }
    if (pollCount >= PREPARING_POLLS_PER_HOUR) {
      const retryMinutes = Math.max(
        1,
        Math.ceil((hourStartMs + hourMs - nowMs) / 60_000),
      );
      throw new HttpsError(
        "resource-exhausted",
        `Preparing poll limit reached. Retry in about ${
          retryMinutes
        } minute(s).`,
      );
    }

    tx.set(limitRef, {
      requestWindowStartMs: hourStartMs,
      requestCount: Math.max(0, requestCount - (sameRequestHour ? 1 : 0)),
      pollWindowStartMs: hourStartMs,
      pollCount: pollCount + 1,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
  });
}

/**
 * Enforces bounded per-user fetch and distinct-setup quotas transactionally.
 */
export async function enforceSituationFetchLimits(options: {
  db: Firestore;
  uid: string;
  setupKey: string;
  preparingPoll?: boolean;
  nowMs?: number;
}): Promise<void> {
  const nowMs = options.nowMs ?? Date.now();
  const hourMs = 60 * 60 * 1000;
  const hourStartMs = Math.floor(nowMs / hourMs) * hourMs;
  const day = new Date(nowMs).toISOString().slice(0, 10);
  const limitRef = options.db
    .collection("users")
    .doc(options.uid)
    .collection("serverLimits")
    .doc("situationFetch");

  await options.db.runTransaction(async (tx) => {
    const snap = await tx.get(limitRef);
    const data = snap.data() ?? {};
    if (options.preparingPoll === true) {
      const samePollHour = data.pollWindowStartMs === hourStartMs;
      const pollCount = samePollHour ? Number(data.pollCount ?? 0) : 0;
      if (!Number.isSafeInteger(pollCount) || pollCount < 0) {
        throw new Error("Invalid preparing poll quota state");
      }
      if (pollCount >= PREPARING_POLLS_PER_HOUR) {
        const retryMinutes = Math.max(
          1,
          Math.ceil((hourStartMs + hourMs - nowMs) / 60_000),
        );
        throw new HttpsError(
          "resource-exhausted",
          `Preparing poll limit reached. Retry in about ${
            retryMinutes
          } minute(s).`,
        );
      }

      tx.set(limitRef, {
        pollWindowStartMs: hourStartMs,
        pollCount: pollCount + 1,
      }, {merge: true});
      return;
    }

    const sameHour = data.requestWindowStartMs === hourStartMs;
    const requestCount = sameHour ? Number(data.requestCount ?? 0) : 0;
    if (!Number.isSafeInteger(requestCount) || requestCount < 0) {
      throw new Error("Invalid fetch quota state");
    }
    if (requestCount >= FETCHES_PER_HOUR) {
      const retryMinutes = Math.max(
        1,
        Math.ceil((hourStartMs + hourMs - nowMs) / 60_000),
      );
      throw new HttpsError(
        "resource-exhausted",
        `Fetch limit reached. Retry in about ${retryMinutes} minute(s).`,
      );
    }

    const storedKeys = data.setupDay === day && Array.isArray(data.setupKeys) ?
      data.setupKeys.filter((key): key is string => typeof key === "string")
        .slice(0, DISTINCT_SETUPS_PER_DAY) :
      [];
    const setupKeys = [...new Set(storedKeys)];
    if (!setupKeys.includes(options.setupKey)) {
      if (setupKeys.length >= DISTINCT_SETUPS_PER_DAY) {
        throw new HttpsError(
          "resource-exhausted",
          "Daily setup limit reached. Retry after 00:00 UTC.",
        );
      }
      setupKeys.push(options.setupKey);
    }

    tx.set(limitRef, {
      requestWindowStartMs: hourStartMs,
      requestCount: requestCount + 1,
      setupDay: day,
      setupKeys,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
  });
}

export async function allocateUnseenSituation(options: {
  db: Firestore;
  uid: string;
  setupKey: string;
  setup: TableSetupInput;
}): Promise<{
  situationId: string;
  setupKey: string;
  payload: SituationPayload;
  neverServedRemaining: number;
} | null> {
  const {db, uid, setupKey} = options;
  const {situations} = poolRefs(db, setupKey);
  const receiptsCol = db
    .collection("users")
    .doc(uid)
    .collection("situationReceipts");

  const receiptSnap = await receiptsCol
    .where("setupKey", "==", setupKey)
    .select()
    .get();
  const receiptIds = new Set(receiptSnap.docs.map((d) => d.id));

  let cursor: DocumentSnapshot | undefined;
  while (true) {
    let query = situations.orderBy("timesServed", "asc").limit(
      ALLOCATION_PAGE_SIZE,
    );
    if (cursor) query = query.startAfter(cursor);
    const page = await query.get();
    if (page.empty) return null;

    const candidates = filterUnseenSituationIds(
      page.docs.map((doc) => doc.id),
      receiptIds,
    );
    for (const candidateId of candidates) {
      const allocated = await db.runTransaction(async (tx) => {
        const situationRef = situations.doc(candidateId);
        const receiptRef = receiptsCol.doc(candidateId);
        const setupRef = poolRefs(db, setupKey).setupRef;
        const [sitSnap, receiptSnapTx, setupSnap] = await Promise.all([
          tx.get(situationRef),
          tx.get(receiptRef),
          tx.get(setupRef),
        ]);
        if (!sitSnap.exists || receiptSnapTx.exists) return null;

        const payload = sitSnap.data()?.payload as SituationPayload | undefined;
        if (!payload) return null;
        const timesServed = Number(sitSnap.data()?.timesServed ?? 0);
        tx.set(receiptRef, {
          situationId: candidateId,
          setupKey,
          status: "allocated",
          allocatedAt: FieldValue.serverTimestamp(),
        });
        tx.update(situationRef, {
          timesServed: timesServed + 1,
          lastServedAt: FieldValue.serverTimestamp(),
        });

        const neverServed = Number(setupSnap.data()?.neverServedCount ?? 0);
        if (timesServed === 0) {
          tx.set(setupRef, {
            neverServedCount: FieldValue.increment(-1),
            updatedAt: FieldValue.serverTimestamp(),
          }, {merge: true});
        }
        return {
          situationId: candidateId,
          setupKey,
          payload,
          neverServedRemaining:
            timesServed === 0 ? Math.max(0, neverServed - 1) : neverServed,
        };
      });
      // A concurrent receipt or deleted/malformed candidate is not exhaustion.
      if (allocated) return allocated;
      receiptIds.add(candidateId);
    }

    if (page.size < ALLOCATION_PAGE_SIZE) return null;
    cursor = page.docs[page.docs.length - 1];
  }
}

/**
 * Pure helper: choose allocation order (never-served first).
 * Exported for unit tests.
 */
export function prioritizeCandidates(options: {
  neverServedIds: string[];
  otherIds: string[];
  receiptIds: Set<string>;
}): string[] {
  const first = filterUnseenSituationIds(options.neverServedIds, options.receiptIds);
  if (first.length > 0) return first;
  return filterUnseenSituationIds(options.otherIds, options.receiptIds);
}
