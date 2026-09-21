/**
 * Unit tests for Live access gates and grandfathering.
 */

import {describe, expect, it} from "vitest";
import {
  DEFAULT_LIVE_ROLLOUT_CUTOFF_MS,
  LIVE_WARMUP_UNLOCK_LESSON_ID,
  assertCourseLiveAccess,
  assertUnrestrictedLiveAccess,
  resolveLiveAccessForUser,
} from "./live_access";

type DocData = Record<string, unknown> | undefined;

class MemoryDoc {
  constructor(
    private readonly store: Map<string, DocData>,
    readonly path: string,
  ) {}

  async get() {
    const data = this.store.get(this.path);
    return {
      exists: data != null,
      data: () => data,
    };
  }

  async set(data: Record<string, unknown>, opts?: {merge?: boolean}) {
    const prev = this.store.get(this.path) ?? {};
    this.store.set(
      this.path,
      opts?.merge ? {...prev, ...data} : data,
    );
  }

  collection(name: string) {
    return {
      doc: (id: string) =>
        new MemoryDoc(this.store, `${this.path}/${name}/${id}`),
    };
  }
}

function memoryDb(seed: Record<string, DocData> = {}) {
  const store = new Map<string, DocData>(Object.entries(seed));
  return {
    store,
    doc: (path: string) => new MemoryDoc(store, path),
    collection: (name: string) => ({
      doc: (id: string) => new MemoryDoc(store, `${name}/${id}`),
    }),
  };
}

describe("live access", () => {
  it("grandfathers accounts created before rollout cutoff", async () => {
    const db = memoryDb({
      "system/liveConfig": {
        rolloutCutoffMs: DEFAULT_LIVE_ROLLOUT_CUTOFF_MS,
      },
    });
    const access = await resolveLiveAccessForUser("u1", {
      db: db as never,
      getUserCreatedAtMs: async () => DEFAULT_LIVE_ROLLOUT_CUTOFF_MS - 1000,
    });
    expect(access.tier).toBe("unrestricted");
    expect(access.source).toBe("grandfathered");
    const entitlement = db.store.get("users/u1/entitlements/liveTraining");
    expect(entitlement?.unrestrictedAccess).toBe(true);
    expect(entitlement?.source).toBe("grandfathered");
  });

  it("keeps post-cutoff users locked without section 2", async () => {
    const db = memoryDb({
      "system/liveConfig": {
        rolloutCutoffMs: DEFAULT_LIVE_ROLLOUT_CUTOFF_MS,
      },
      "users/u2/course/main": {
        completedLessonIds: ["lesson-01-01-01-table-layout"],
      },
    });
    const access = await resolveLiveAccessForUser("u2", {
      db: db as never,
      getUserCreatedAtMs: async () => DEFAULT_LIVE_ROLLOUT_CUTOFF_MS + 1000,
    });
    expect(access.tier).toBe("locked");
    expect(access.warmUpAvailable).toBe(false);
  });

  it("unlocks warm-up after section 2 jump lesson", async () => {
    const db = memoryDb({
      "system/liveConfig": {
        rolloutCutoffMs: DEFAULT_LIVE_ROLLOUT_CUTOFF_MS,
      },
      "users/u3/course/main": {
        completedLessonIds: [LIVE_WARMUP_UNLOCK_LESSON_ID],
      },
    });
    const access = await resolveLiveAccessForUser("u3", {
      db: db as never,
      getUserCreatedAtMs: async () => DEFAULT_LIVE_ROLLOUT_CUTOFF_MS + 1000,
    });
    expect(access.tier).toBe("warm_up");
    expect(access.warmUpAvailable).toBe(true);
    expect(access.unrestrictedAccess).toBe(false);
    await expect(
      assertUnrestrictedLiveAccess("u3", {
        db: db as never,
        getUserCreatedAtMs: async () => DEFAULT_LIVE_ROLLOUT_CUTOFF_MS + 1000,
      }),
    ).rejects.toMatchObject({code: "permission-denied"});
    await expect(
      assertCourseLiveAccess("u3", {
        db: db as never,
        getUserCreatedAtMs: async () => DEFAULT_LIVE_ROLLOUT_CUTOFF_MS + 1000,
      }),
    ).resolves.toMatchObject({tier: "warm_up"});
  });

  it("honors server-authored unrestricted entitlement", async () => {
    const db = memoryDb({
      "users/u4/entitlements/liveTraining": {
        unrestrictedAccess: true,
        source: "section4_jump",
      },
    });
    const access = await resolveLiveAccessForUser("u4", {
      db: db as never,
      getUserCreatedAtMs: async () => DEFAULT_LIVE_ROLLOUT_CUTOFF_MS + 1000,
    });
    expect(access.tier).toBe("unrestricted");
    expect(access.source).toBe("section4_jump");
  });
});
