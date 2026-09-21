import {readFileSync} from "node:fs";
import {resolve} from "node:path";

import {
  RulesTestEnvironment,
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  Timestamp,
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import {
  deleteObject,
  getBytes,
  ref,
  uploadBytes,
} from "firebase/storage";
import {afterAll, afterEach, beforeAll, describe, it} from "vitest";

const PROJECT_ID = "live-poker-trainer-rules-test";
const BUCKET = `${PROJECT_ID}.appspot.com`;
const OWNER_UID = "owner";
const OTHER_UID = "other";

let testEnv: RulesTestEnvironment;

function validPreferences(): Record<string, unknown> {
  return {
    smallBlind: 1,
    bigBlind: 2,
    seatCount: 6,
    maxStackDepthBb: 200,
    chipDisplayMode: "dollars",
    lineupMode: "randomPool",
    customArchetypes: "",
  };
}

function validUser(): Record<string, unknown> {
  const now = Timestamp.now();
  return {
    displayName: "Owner",
    avatarRef: "builtin:spade",
    createdAt: now,
    updatedAt: now,
    preferences: validPreferences(),
  };
}

async function seedFirestore(
  path: string,
  data: Record<string, unknown>,
): Promise<void> {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), data);
  });
}

async function seedAvatar(): Promise<void> {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await uploadBytes(
      ref(context.storage(BUCKET), `avatars/${OWNER_UID}/avatar.png`),
      new Uint8Array([137, 80, 78, 71]),
      {contentType: "image/png"},
    );
  });
}

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(
        resolve(process.cwd(), "../firestore.rules"),
        "utf8",
      ),
    },
    storage: {
      rules: readFileSync(
        resolve(process.cwd(), "../storage.rules"),
        "utf8",
      ),
    },
  });
});

afterEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.clearStorage();
});

afterAll(async () => {
  await testEnv.cleanup();
});

describe("Firestore security rules", () => {
  it("denies unauthenticated and other-user root/progress/history reads", async () => {
    await seedFirestore(`users/${OWNER_UID}`, validUser());
    await seedFirestore(`users/${OWNER_UID}/progress/main`, {handsPlayed: 3});
    await seedFirestore(`users/${OWNER_UID}/handHistory/hand-1`, {result: 10});

    for (const context of [
      testEnv.unauthenticatedContext(),
      testEnv.authenticatedContext(OTHER_UID),
    ]) {
      const database = context.firestore();
      await assertFails(getDoc(doc(database, `users/${OWNER_UID}`)));
      await assertFails(
        getDoc(doc(database, `users/${OWNER_UID}/progress/main`)),
      );
      await assertFails(
        getDoc(doc(database, `users/${OWNER_UID}/handHistory/hand-1`)),
      );
      await assertFails(
        setDoc(doc(database, `users/${OWNER_UID}`), validUser()),
      );
      await assertFails(
        setDoc(
          doc(database, `users/${OWNER_UID}/progress/main`),
          {handsPlayed: 4},
        ),
      );
      await assertFails(
        setDoc(
          doc(database, `users/${OWNER_UID}/handHistory/hand-2`),
          {result: 20},
        ),
      );
    }
  });

  it("allows an owner to create, update, and read a valid root document", async () => {
    const database = testEnv.authenticatedContext(OWNER_UID).firestore();
    const userRef = doc(database, `users/${OWNER_UID}`);

    await assertSucceeds(setDoc(userRef, validUser()));
    await assertSucceeds(getDoc(userRef));
    await assertSucceeds(
      updateDoc(userRef, {
        displayName: "Updated Owner",
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it.each([
    ["stats field", {stats: {handsPlayed: 1}}],
    ["arbitrary field", {role: "admin"}],
    ["oversized display name", {displayName: "x".repeat(19)}],
    [
      "oversized avatar reference",
      {avatarRef: `https://firebasestorage.googleapis.com/${"x".repeat(2050)}`},
    ],
  ])("rejects root create with %s", async (_label, mutation) => {
    const database = testEnv.authenticatedContext(OWNER_UID).firestore();
    await assertFails(
      setDoc(doc(database, `users/${OWNER_UID}`), {
        ...validUser(),
        ...mutation,
      }),
    );
  });

  it.each([
    ["non-integer seat count", {seatCount: 6.5}],
    ["out-of-range seat count", {seatCount: 10}],
    ["out-of-range small blind", {smallBlind: 0}],
    ["out-of-range stack depth", {maxStackDepthBb: 501}],
    ["unknown preference", {unknown: true}],
  ])("rejects invalid preferences: %s", async (_label, mutation) => {
    const database = testEnv.authenticatedContext(OWNER_UID).firestore();
    await assertFails(
      setDoc(doc(database, `users/${OWNER_UID}`), {
        ...validUser(),
        preferences: {
          ...validPreferences(),
          ...mutation,
        },
      }),
    );
  });

  it("rejects createdAt mutation and client delete", async () => {
    await seedFirestore(`users/${OWNER_UID}`, validUser());
    const database = testEnv.authenticatedContext(OWNER_UID).firestore();
    const userRef = doc(database, `users/${OWNER_UID}`);

    await assertFails(
      updateDoc(userRef, {
        createdAt: Timestamp.fromMillis(1),
        updatedAt: serverTimestamp(),
      }),
    );
    await assertFails(
      updateDoc(userRef, {
        stats: {handsPlayed: 1},
        updatedAt: serverTimestamp(),
      }),
    );
    await assertFails(deleteDoc(userRef));
  });

  it("allows owner reads but denies owner writes to progress and history", async () => {
    await seedFirestore(`users/${OWNER_UID}/liveProgress/main`, {handsPlayed: 3});
    await seedFirestore(`users/${OWNER_UID}/liveHandHistory/hand-1`, {result: 10});
    await seedFirestore(`users/${OWNER_UID}/liveActionFeed/current`, {
      status: "acting",
      events: [],
    });
    await seedFirestore(`users/${OWNER_UID}/course/main`, {lifetimeXp: 10});
    await seedFirestore(`users/${OWNER_UID}/courseAttempts/attempt-1`, {
      lessonId: "lesson-1",
    });
    await seedFirestore(`users/${OWNER_UID}/courseReviews/review-1`, {
      dueAtMs: 1,
    });
    await seedFirestore(`users/${OWNER_UID}/courseXpLedger/entry-1`, {amount: 10});
    await seedFirestore(`users/${OWNER_UID}/entitlements/liveTraining`, {
      unrestrictedAccess: true,
      source: "section4_jump",
    });
    const database = testEnv.authenticatedContext(OWNER_UID).firestore();
    const progressRef = doc(database, `users/${OWNER_UID}/liveProgress/main`);
    const historyRef = doc(
      database,
      `users/${OWNER_UID}/liveHandHistory/hand-1`,
    );
    const feedRef = doc(database, `users/${OWNER_UID}/liveActionFeed/current`);
    const courseRef = doc(database, `users/${OWNER_UID}/course/main`);
    const attemptRef = doc(
      database,
      `users/${OWNER_UID}/courseAttempts/attempt-1`,
    );
    const reviewRef = doc(
      database,
      `users/${OWNER_UID}/courseReviews/review-1`,
    );
    const xpRef = doc(database, `users/${OWNER_UID}/courseXpLedger/entry-1`);
    const entitlementRef = doc(
      database,
      `users/${OWNER_UID}/entitlements/liveTraining`,
    );

    await assertSucceeds(getDoc(progressRef));
    await assertSucceeds(getDoc(historyRef));
    await assertSucceeds(getDoc(feedRef));
    await assertSucceeds(getDoc(courseRef));
    await assertSucceeds(getDoc(attemptRef));
    await assertSucceeds(getDoc(reviewRef));
    await assertSucceeds(getDoc(xpRef));
    await assertSucceeds(getDoc(entitlementRef));
    await assertFails(setDoc(progressRef, {handsPlayed: 4}));
    await assertFails(updateDoc(historyRef, {result: 20}));
    await assertFails(setDoc(feedRef, {status: "done"}));
    await assertFails(setDoc(courseRef, {lifetimeXp: 99}));
    await assertFails(setDoc(attemptRef, {lessonId: "hacked"}));
    await assertFails(setDoc(reviewRef, {dueAtMs: 2}));
    await assertFails(setDoc(xpRef, {amount: 99}));
    await assertFails(
      setDoc(entitlementRef, {unrestrictedAccess: true, source: "admin"}),
    );
    await assertFails(deleteDoc(progressRef));
  });

  it("allows signed-in users to read courseFlags but denies writes", async () => {
    await seedFirestore("appConfig/courseFlags", {
      courseEnabled: true,
      courseStartsEnabled: true,
      guestCourseEnabled: false,
      placementTestsEnabled: false,
      catalogVersion: "2.0.0",
      minimumClientVersion: "2.0.0",
    });
    const ownerDb = testEnv.authenticatedContext(OWNER_UID).firestore();
    const anonDb = testEnv.authenticatedContext("anon-user", {
      firebase: {sign_in_provider: "anonymous"},
    }).firestore();
    const unauthDb = testEnv.unauthenticatedContext().firestore();
    await assertSucceeds(getDoc(doc(ownerDb, "appConfig/courseFlags")));
    await assertSucceeds(getDoc(doc(anonDb, "appConfig/courseFlags")));
    await assertFails(
      setDoc(doc(ownerDb, "appConfig/courseFlags"), {courseEnabled: false}),
    );
    await assertFails(getDoc(doc(unauthDb, "appConfig/courseFlags")));
  });

  it("denies course receipts and rate limits even to the owner", async () => {
    await seedFirestore(
      `users/${OWNER_UID}/courseStepReceipts/key-1`,
      {accepted: true},
    );
    await seedFirestore(
      `users/${OWNER_UID}/courseStartRequests/req-1`,
      {status: "ready"},
    );
    await seedFirestore(
      `users/${OWNER_UID}/courseRateLimits/start`,
      {count: 1},
    );
    const database = testEnv.authenticatedContext(OWNER_UID).firestore();
    for (const path of [
      `users/${OWNER_UID}/courseStepReceipts/key-1`,
      `users/${OWNER_UID}/courseStartRequests/req-1`,
      `users/${OWNER_UID}/courseRateLimits/start`,
    ]) {
      const document = doc(database, path);
      await assertFails(getDoc(document));
      await assertFails(setDoc(document, {client: true}));
    }
  });

  it("denies receipts and private situation pools even to the owner", async () => {
    await seedFirestore(
      `users/${OWNER_UID}/situationReceipts/situation-1`,
      {completed: true},
    );
    await seedFirestore("tableSetups/setup-1", {active: true});
    await seedFirestore(
      "tableSetups/setup-1/situations/situation-1",
      {prompt: "private"},
    );
    await seedFirestore("scenarios/hash-1", {prompt: "legacy private"});
    await seedFirestore(
      `users/${OWNER_UID}/liveHandReceipts/hand-1`,
      {status: "allocated"},
    );
    await seedFirestore(
      `users/${OWNER_UID}/liveSessions/session-1`,
      {stateVersion: 0},
    );
    await seedFirestore("liveTableSetups/setup-1", {active: true});
    await seedFirestore(
      "liveTableSetups/setup-1/hands/hand-1",
      {definition: "private"},
    );
    const database = testEnv.authenticatedContext(OWNER_UID).firestore();

    for (const path of [
      `users/${OWNER_UID}/situationReceipts/situation-1`,
      "tableSetups/setup-1",
      "tableSetups/setup-1/situations/situation-1",
      "scenarios/hash-1",
      `users/${OWNER_UID}/liveHandReceipts/hand-1`,
      `users/${OWNER_UID}/liveSessions/session-1`,
      "liveTableSetups/setup-1",
      "liveTableSetups/setup-1/hands/hand-1",
    ]) {
      const document = doc(database, path);
      await assertFails(getDoc(document));
      await assertFails(setDoc(document, {client: true}));
    }
  });
});

describe("Storage security rules", () => {
  it("denies unauthenticated and other-user avatar reads", async () => {
    await seedAvatar();
    const avatarPath = `avatars/${OWNER_UID}/avatar.png`;
    const unauthenticatedStorage =
      testEnv.unauthenticatedContext().storage(BUCKET);
    const otherStorage =
      testEnv.authenticatedContext(OTHER_UID).storage(BUCKET);

    await assertFails(
      getBytes(ref(unauthenticatedStorage, avatarPath)),
    );
    await assertFails(
      getBytes(ref(otherStorage, avatarPath)),
    );
    await assertFails(
      uploadBytes(
        ref(unauthenticatedStorage, avatarPath),
        new Uint8Array([1]),
        {contentType: "image/png"},
      ),
    );
    await assertFails(
      uploadBytes(
        ref(otherStorage, avatarPath),
        new Uint8Array([1]),
        {contentType: "image/png"},
      ),
    );
  });

  it("allows owner PNG upload and read at the exact path", async () => {
    const storage = testEnv.authenticatedContext(OWNER_UID).storage(BUCKET);
    const avatarRef = ref(storage, `avatars/${OWNER_UID}/avatar.png`);

    await assertSucceeds(
      uploadBytes(
        avatarRef,
        new Uint8Array([137, 80, 78, 71]),
        {contentType: "image/png"},
      ),
    );
    await assertSucceeds(getBytes(avatarRef));
  });

  it("rejects wrong owner, path, content type, empty, and oversized uploads", async () => {
    const ownerStorage =
      testEnv.authenticatedContext(OWNER_UID).storage(BUCKET);
    const otherStorage =
      testEnv.authenticatedContext(OTHER_UID).storage(BUCKET);
    const avatarPath = `avatars/${OWNER_UID}/avatar.png`;

    await assertFails(
      uploadBytes(
        ref(otherStorage, avatarPath),
        new Uint8Array([1]),
        {contentType: "image/png"},
      ),
    );
    await assertFails(
      uploadBytes(
        ref(ownerStorage, `avatars/${OWNER_UID}/other.png`),
        new Uint8Array([1]),
        {contentType: "image/png"},
      ),
    );
    await assertFails(
      uploadBytes(
        ref(ownerStorage, avatarPath),
        new Uint8Array([1]),
        {contentType: "image/jpeg"},
      ),
    );
    await assertFails(
      uploadBytes(
        ref(ownerStorage, avatarPath),
        new Uint8Array(0),
        {contentType: "image/png"},
      ),
    );
    await assertFails(
      uploadBytes(
        ref(ownerStorage, avatarPath),
        new Uint8Array(1024 * 1024),
        {contentType: "image/png"},
      ),
    );
  });

  it("allows only the owner to delete the avatar", async () => {
    await seedAvatar();
    const avatarPath = `avatars/${OWNER_UID}/avatar.png`;
    const otherAvatar = ref(
      testEnv.authenticatedContext(OTHER_UID).storage(BUCKET),
      avatarPath,
    );
    const ownerAvatar = ref(
      testEnv.authenticatedContext(OWNER_UID).storage(BUCKET),
      avatarPath,
    );

    await assertFails(deleteObject(otherAvatar));
    await assertSucceeds(deleteObject(ownerAvatar));
  });
});
