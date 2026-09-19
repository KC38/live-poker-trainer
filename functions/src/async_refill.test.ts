/**
 * Unit tests for non-blocking fetches and asynchronous refill orchestration.
 */

import type {Firestore} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {describe, expect, it, vi} from "vitest";
import {fetchSituationForUser} from "./fetch_situation";
import {
  runConcurrentGenerationBatch,
  type RefillResult,
} from "./pool";
import {
  isQueuedGeneration,
  refillQueuedSetup,
  setupInputFromDocument,
} from "./refill_situation_pool";
import {minimalFoldSituation} from "./test_fixtures";
import type {TableSetupInput} from "./situation_types";

const setup: TableSetupInput = {
  mode: "random",
  seatCount: 2,
  smallBlind: 1,
  bigBlind: 2,
  ante: 0,
  startingStack: 200,
};
const fakeDb = {} as Firestore;
const newSetupState = {
  exists: false,
  situationCount: 0,
  generationStatus: undefined,
};

describe("fetchSituationForUser async refill", () => {
  it("queues an empty pool and returns unavailable without generation", async () => {
    const queueRefill = vi.fn().mockResolvedValue(true);
    const generate = vi.fn();

    await expect(
      fetchSituationForUser({
        uid: "user-1",
        rawSetup: setup,
        db: fakeDb,
        readSetupState: vi.fn().mockResolvedValue(newSetupState),
        enforceLimits: vi.fn().mockResolvedValue(undefined),
        ensureSetup: vi.fn().mockResolvedValue(undefined),
        allocate: vi.fn().mockResolvedValue(null),
        readSituationCount: vi.fn().mockResolvedValue(0),
        queueRefill,
      }),
    ).rejects.toMatchObject<HttpsError>({code: "unavailable"});

    expect(queueRefill).toHaveBeenCalledWith(
      expect.objectContaining({reason: "empty"}),
    );
    expect(generate).not.toHaveBeenCalled();
  });

  it("does not duplicate queue state across duplicate fetches", async () => {
    let queued = false;
    let queueWrites = 0;
    const queueRefill = vi.fn(async () => {
      if (queued) return false;
      queued = true;
      queueWrites += 1;
      return true;
    });
    const options = {
      uid: "user-1",
      rawSetup: setup,
      db: fakeDb,
      readSetupState: vi.fn().mockResolvedValue(newSetupState),
      enforceLimits: vi.fn().mockResolvedValue(undefined),
      ensureSetup: vi.fn().mockResolvedValue(undefined),
      allocate: vi.fn().mockResolvedValue(null),
      readSituationCount: vi.fn().mockResolvedValue(3),
      queueRefill,
    };

    await Promise.allSettled([
      fetchSituationForUser(options),
      fetchSituationForUser(options),
    ]);

    expect(queued).toBe(true);
    expect(queueWrites).toBe(1);
    expect(queueRefill.mock.results.filter(
      (result) => result.type === "return",
    )).toHaveLength(2);
  });

  it("returns allocation immediately while queueing low-water refill", async () => {
    const queueRefill = vi.fn().mockResolvedValue(true);
    const payload = minimalFoldSituation();
    const result = await fetchSituationForUser({
      uid: "user-1",
      rawSetup: setup,
      db: fakeDb,
      readSetupState: vi.fn().mockResolvedValue({
        exists: true,
        situationCount: 1,
        generationStatus: "idle",
      }),
      enforceLimits: vi.fn().mockResolvedValue(undefined),
      ensureSetup: vi.fn().mockResolvedValue(undefined),
      allocate: vi.fn().mockResolvedValue({
        situationId: "s1",
        setupKey: payload.setupKey,
        payload,
        neverServedRemaining: 1,
      }),
      queueRefill,
    });

    expect(result.situationId).toBe("s1");
    expect(result.refillTriggered).toBe(true);
    expect(queueRefill).toHaveBeenCalledWith(
      expect.objectContaining({reason: "low-water"}),
    );
  });

  it.each([
    ["queued empty setup", true, 0, "queued", true],
    ["generating empty setup", true, 0, "generating", true],
    ["first request", false, 0, undefined, true],
    ["idle empty setup", true, 0, "idle", true],
    ["available setup", true, 1, "generating", false],
  ] as const)(
    "charges prep then deal for %s when allocation succeeds",
    async (_, exists, situationCount, generationStatus, preparingFirst) => {
      const enforceLimits = vi.fn().mockResolvedValue(undefined);
      const payload = minimalFoldSituation();

      await fetchSituationForUser({
        uid: "user-1",
        rawSetup: setup,
        db: fakeDb,
        readSetupState: vi.fn().mockResolvedValue({
          exists,
          situationCount,
          generationStatus,
        }),
        enforceLimits,
        ensureSetup: vi.fn().mockResolvedValue(undefined),
        allocate: vi.fn().mockResolvedValue({
          situationId: "s1",
          setupKey: payload.setupKey,
          payload,
          neverServedRemaining: 2,
        }),
        queueRefill: vi.fn(),
      });

      expect(enforceLimits.mock.calls[0][0]).toEqual(expect.objectContaining({
        preparingPoll: preparingFirst,
      }));
      if (preparingFirst) {
        expect(enforceLimits).toHaveBeenCalledTimes(2);
        expect(enforceLimits.mock.calls[1][0]).toEqual(expect.objectContaining({
          preparingPoll: false,
        }));
      } else {
        expect(enforceLimits).toHaveBeenCalledTimes(1);
      }
    },
  );

  it("converts a deal reservation into a prep poll when a ready pool is empty", async () => {
    const enforceLimits = vi.fn().mockResolvedValue(undefined);
    const convertReservation = vi.fn().mockResolvedValue(undefined);
    const queueRefill = vi.fn().mockResolvedValue(true);

    await expect(
      fetchSituationForUser({
        uid: "user-1",
        rawSetup: setup,
        db: fakeDb,
        readSetupState: vi.fn().mockResolvedValue({
          exists: true,
          situationCount: 3,
          generationStatus: "idle",
        }),
        enforceLimits,
        convertReservation,
        ensureSetup: vi.fn().mockResolvedValue(undefined),
        allocate: vi.fn().mockResolvedValue(null),
        readSituationCount: vi.fn().mockResolvedValue(3),
        queueRefill,
      }),
    ).rejects.toMatchObject({code: "unavailable"});

    expect(enforceLimits).toHaveBeenCalledWith(expect.objectContaining({
      preparingPoll: false,
    }));
    expect(convertReservation).toHaveBeenCalledWith(expect.objectContaining({
      uid: "user-1",
    }));
    expect(queueRefill).toHaveBeenCalledWith(expect.objectContaining({
      reason: "exhausted",
    }));
  });
});

describe("refill trigger", () => {
  it("no-ops for idle and generating states", async () => {
    const refill = vi.fn();
    expect(isQueuedGeneration({generation: {status: "idle"}})).toBe(false);
    expect(isQueuedGeneration({generation: {status: "generating"}})).toBe(false);

    for (const status of ["idle", "generating"]) {
      await expect(refillQueuedSetup({
        setupKey: "key",
        afterData: {generation: {status}},
        apiKey: "secret",
        db: fakeDb,
        refill: refill as never,
      })).resolves.toBeNull();
    }
    expect(refill).not.toHaveBeenCalled();
  });

  it("refills queued setup with a queued-only lease", async () => {
    const expected: RefillResult = {
      attempted: true,
      added: 3,
      skipped: 0,
      errors: [],
      leaseHeldByOther: false,
    };
    const refill = vi.fn().mockResolvedValue(expected);
    const result = await refillQueuedSetup({
      setupKey: "random-key",
      afterData: {
        ...setup,
        generation: {status: "queued"},
      },
      apiKey: "secret",
      db: fakeDb,
      refill: refill as never,
    });

    expect(result).toEqual(expected);
    expect(refill).toHaveBeenCalledWith(expect.objectContaining({
      force: true,
      requireQueued: true,
      setup,
    }));
  });

  it("reconstructs custom lineup, button, and hero", () => {
    expect(setupInputFromDocument({
      mode: "custom",
      seatCount: 2,
      smallBlind: 1,
      bigBlind: 2,
      ante: 0,
      startingStack: 200,
      buttonSeat: 1,
      heroSeat: 0,
      lineup: [
        {seat: 0, archetype: "HERO", name: "Hero"},
        {seat: 1, archetype: "TAG", name: "Alex"},
      ],
    })).toMatchObject({
      mode: "custom",
      buttonSeat: 1,
      heroSeat: 0,
      lineup: [
        {seat: 0, archetype: "HERO", name: "Hero"},
        {seat: 1, archetype: "TAG", name: "Alex"},
      ],
    });
  });
});

describe("concurrent generation batch", () => {
  it("runs concurrently and reports partial failures accurately", async () => {
    let active = 0;
    let maxActive = 0;
    const seeds: string[] = [];
    const generateFn = vi.fn(async (options: {
      variationSeed?: string;
      maxAttempts?: number;
    }) => {
      active += 1;
      maxActive = Math.max(maxActive, active);
      seeds.push(options.variationSeed ?? "");
      await new Promise((resolve) => setTimeout(resolve, 5));
      active -= 1;
      const index = Number(options.variationSeed?.split(":").at(-1));
      expect(options.maxAttempts).toBe(3);
      if (index === 1 || index === 3) throw new Error(`failure-${index}`);
      return {
        payload: {
          ...minimalFoldSituation(),
          setupKey: `variation-${index}`,
        },
        modelId: "gemini-3.8-flash",
      };
    });
    const recordedRuns: Array<{runId: string; status: string}> = [];
    const result = await runConcurrentGenerationBatch({
      apiKey: "secret",
      setup,
      setupKey: "key",
      leaseId: "lease",
      batchSize: 5,
      generateFn: generateFn as never,
      publishFn: vi.fn(async (generated) =>
        generated.payload.setupKey !== "variation-2"
      ),
      recordRunFn: vi.fn(async (run) => {
        recordedRuns.push({runId: run.runId, status: run.status});
      }),
    });

    expect(maxActive).toBe(5);
    expect(new Set(seeds).size).toBe(5);
    expect(result.added).toBe(2);
    expect(result.skipped).toBe(1);
    expect(result.errors.sort()).toEqual(["failure-1", "failure-3"]);
    expect(recordedRuns).toHaveLength(5);
    expect(recordedRuns).toEqual(expect.arrayContaining([
      {runId: "lease-0", status: "published"},
      {runId: "lease-1", status: "failed"},
      {runId: "lease-2", status: "duplicate"},
      {runId: "lease-3", status: "failed"},
      {runId: "lease-4", status: "published"},
    ]));
  });

  it("publishes each success before slower siblings finish", async () => {
    const publishOrder: string[] = [];
    let publishedBeforeSlowFinished = false;
    let slowFinished = false;

    const generateFn = vi.fn(async (options: {
      variationSeed?: string;
    }) => {
      const index = Number(options.variationSeed?.split(":").at(-1));
      if (index === 0) {
        await new Promise((resolve) => setTimeout(resolve, 5));
        return {
          payload: {
            ...minimalFoldSituation(),
            setupKey: "fast",
          },
          modelId: "gemini-3.8-flash",
        };
      }
      await new Promise((resolve) => setTimeout(resolve, 40));
      slowFinished = true;
      return {
        payload: {
          ...minimalFoldSituation(),
          setupKey: "slow",
        },
        modelId: "gemini-3.8-flash",
      };
    });

    await runConcurrentGenerationBatch({
      apiKey: "secret",
      setup,
      setupKey: "key",
      leaseId: "lease",
      batchSize: 2,
      generateFn: generateFn as never,
      publishFn: vi.fn(async (generated) => {
        publishOrder.push(generated.payload.setupKey);
        if (!slowFinished) publishedBeforeSlowFinished = true;
        return true;
      }),
    });

    expect(publishOrder[0]).toBe("fast");
    expect(publishedBeforeSlowFinished).toBe(true);
  });
});
