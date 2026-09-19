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
    ["first request", false, 0, undefined, false],
    ["idle empty setup", true, 0, "idle", false],
    ["available setup", true, 1, "generating", false],
  ] as const)(
    "derives preparingPoll for %s",
    async (_, exists, situationCount, generationStatus, expected) => {
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

      expect(enforceLimits).toHaveBeenCalledWith(expect.objectContaining({
        preparingPoll: expected,
      }));
    },
  );
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
        payload: minimalFoldSituation({title: `variation-${index}`}),
        modelId: "gemini-3.8-flash",
      };
    });
    let publishIndex = 0;
    const result = await runConcurrentGenerationBatch({
      apiKey: "secret",
      setup,
      setupKey: "key",
      leaseId: "lease",
      batchSize: 5,
      generateFn: generateFn as never,
      publishFn: vi.fn(async () => publishIndex++ !== 2),
    });

    expect(maxActive).toBe(5);
    expect(new Set(seeds).size).toBe(5);
    expect(result).toEqual({
      added: 2,
      skipped: 1,
      errors: ["failure-1", "failure-3"],
    });
  });
});
