/**
 * Shared lazy-tree expansion for live hands.
 *
 * Every continuation is produced once from an authoritative state. Villain
 * choices are sequential and perspective-isolated; the resulting Hero node
 * receives an all-actions coaching rubric before it is exposed. All Gemini
 * token usage from those calls is accumulated for Firestore metering.
 */

import {
  applyLiveAction,
  createInitialLiveState,
  hashLiveState,
  legalLiveActions,
  liveHeroToAct,
} from "./live_poker_engine";
import {
  assessmentForAction,
  chooseVillainAction,
  generateCoachingRubric,
} from "./live_intelligence";
import {
  addLiveUsage,
  emptyLiveUsageBreakdown,
  liveUsageFromError,
  LiveUsageError,
  type LiveUsageBreakdown,
} from "./live_usage";
import type {
  CoachingActionAssessment,
  CoachingRubric,
  LiveActionEvent,
  LiveHandDefinition,
  LiveHandState,
  LiveLegalAction,
} from "./live_types";

export interface PreparedLiveNode {
  stateHash: string;
  state: LiveHandState;
  history: LiveActionEvent[];
  legalActions: LiveLegalAction[];
  rubric: CoachingRubric | null;
}

export interface PreparedLiveEdge {
  parentStateHash: string;
  actionId: string;
  child: PreparedLiveNode;
  events: LiveActionEvent[];
  coaching: CoachingActionAssessment;
  usage: LiveUsageBreakdown;
}

export interface PreparedLiveHand {
  root: PreparedLiveNode;
  warmEdges: PreparedLiveEdge[];
  usage: LiveUsageBreakdown;
}

interface ResolvedLiveNode {
  node: PreparedLiveNode;
  usage: LiveUsageBreakdown;
}

/** Resolves forced/opponent action to the first Hero decision and warms it. */
export async function prepareLiveHand(options: {
  apiKey: string;
  hand: LiveHandDefinition;
  fetchImpl?: typeof fetch;
}): Promise<PreparedLiveHand> {
  let usage = emptyLiveUsageBreakdown();
  try {
    const initial = createInitialLiveState(options.hand);
    const rootResolved = await resolveToHeroOrTerminal({
      apiKey: options.apiKey,
      hand: options.hand,
      state: initial,
      history: [],
      fetchImpl: options.fetchImpl,
    });
    usage = addLiveUsage(usage, rootResolved.usage);
    const root = rootResolved.node;
    if (
      root.state.status !== "playing" ||
      !liveHeroToAct(options.hand, root.state)
    ) {
      throw new Error("generated hand ended before Hero received a decision");
    }
    const warmIds = selectWarmActionIds(root);
    if (warmIds.length < 3) {
      throw new Error(
        "generated first decision needs at least three non-fold branches",
      );
    }
    const warmEdges: PreparedLiveEdge[] = [];
    for (const actionId of warmIds) {
      const edge = await expandLiveHeroAction({
        apiKey: options.apiKey,
        hand: options.hand,
        parent: root,
        actionId,
        fetchImpl: options.fetchImpl,
      });
      usage = addLiveUsage(usage, edge.usage);
      warmEdges.push(edge);
    }
    return {root, warmEdges, usage};
  } catch (error) {
    throw new LiveUsageError(
      error instanceof Error ? error.message : String(error),
      addLiveUsage(usage, liveUsageFromError(error)),
    );
  }
}

/** Expands one shared Hero edge through all villains to the next Hero node. */
export async function expandLiveHeroAction(options: {
  apiKey: string;
  hand: LiveHandDefinition;
  parent: PreparedLiveNode;
  actionId: string;
  fetchImpl?: typeof fetch;
  /**
   * Live progress for the submitting client: seat actions as they land, plus
   * a coaching phase once villains are done and the next rubric is generating.
   */
  onFeed?: (update: {
    events: LiveActionEvent[];
    state: LiveHandState;
    status: "acting" | "coaching";
    waitingOnSeat: number | null;
  }) => Promise<void>;
}): Promise<PreparedLiveEdge> {
  if (!options.parent.rubric) {
    throw new Error("cannot expand a Hero node without coaching");
  }
  const selected = options.parent.legalActions.find(
    (candidate) => candidate.actionId === options.actionId,
  );
  if (!selected) throw new Error(`action ${options.actionId} is not legal`);
  const parentLen = options.parent.history.length;
  const applied = applyLiveAction({
    hand: options.hand,
    state: options.parent.state,
    actionId: options.actionId,
  });
  const history = [...options.parent.history, applied.event];
  const publish = async (
    nextHistory: LiveActionEvent[],
    state: LiveHandState,
    status: "acting" | "coaching",
  ): Promise<void> => {
    await options.onFeed?.({
      events: nextHistory.slice(parentLen),
      state,
      status,
      waitingOnSeat:
        status === "acting" && typeof state.actorSeat === "number" ?
          state.actorSeat :
          null,
    });
  };
  await publish(history, applied.state, "acting");
  const childResolved = await resolveToHeroOrTerminal({
    apiKey: options.apiKey,
    hand: options.hand,
    state: applied.state,
    history,
    fetchImpl: options.fetchImpl,
    onHistoryAppend: async (_event, nextHistory, state) => {
      await publish(nextHistory, state, "acting");
    },
    onWaiting: async (_seat, nextHistory, state) => {
      await publish(nextHistory, state, "acting");
    },
    onCoachingPhase: async (nextHistory, state) => {
      await publish(nextHistory, state, "coaching");
    },
  });
  const events = childResolved.node.history.slice(parentLen);
  return {
    parentStateHash: options.parent.stateHash,
    actionId: options.actionId,
    child: childResolved.node,
    events,
    coaching: assessmentForAction(options.parent.rubric, options.actionId),
    usage: childResolved.usage,
  };
}

/** Picks three useful non-fold branches for first-decision warming. */
export function selectWarmActionIds(node: PreparedLiveNode): string[] {
  const ids: string[] = [];
  const add = (action: LiveLegalAction | undefined): void => {
    if (action && action.kind !== "FOLD" && !ids.includes(action.actionId)) {
      ids.push(action.actionId);
    }
  };
  add(node.legalActions.find((action) =>
    action.kind === "CHECK" || action.kind === "CALL",
  ));
  const recommended = node.rubric?.assessments.find(
    (assessment) => assessment.rating === "recommended",
  );
  add(node.legalActions.find((action) =>
    action.actionId === recommended?.actionId,
  ));
  for (const bucket of [
    "BET_67",
    "OPEN_3_BB",
    "RERAISE_3X",
    "RAISE_50",
    "BET_100",
    "RAISE_100",
    "ALL_IN",
  ]) {
    add(node.legalActions.find((action) => action.bucket === bucket));
    if (ids.length >= 3) break;
  }
  for (const action of node.legalActions) {
    add(action);
    if (ids.length >= 3) break;
  }
  return ids.slice(0, 3);
}

async function resolveToHeroOrTerminal(options: {
  apiKey: string;
  hand: LiveHandDefinition;
  state: LiveHandState;
  history: LiveActionEvent[];
  fetchImpl?: typeof fetch;
  onHistoryAppend?: (
    event: LiveActionEvent,
    history: LiveActionEvent[],
    state: LiveHandState,
  ) => Promise<void>;
  /** Fires before an LLM villain decision so the client can start a seat timer. */
  onWaiting?: (
    seat: number,
    history: LiveActionEvent[],
    state: LiveHandState,
  ) => Promise<void>;
  /** Fires once villains are done and the next-node rubric is about to run. */
  onCoachingPhase?: (
    history: LiveActionEvent[],
    state: LiveHandState,
  ) => Promise<void>;
}): Promise<ResolvedLiveNode> {
  let state = options.state;
  const history = [...options.history];
  let usage = emptyLiveUsageBreakdown();
  try {
    for (let guard = 0; guard < 128; guard++) {
      if (state.status !== "playing") {
        return {
          node: {
            stateHash: hashLiveState(state, history),
            state,
            history,
            legalActions: [],
            rubric: null,
          },
          usage,
        };
      }
      const legalActions = legalLiveActions(options.hand, state);
      if (liveHeroToAct(options.hand, state)) {
        await options.onCoachingPhase?.(history, state);
        const coached = await generateCoachingRubric({
          apiKey: options.apiKey,
          hand: options.hand,
          state,
          legalActions,
          publicHistory: history,
          fetchImpl: options.fetchImpl,
        });
        usage = addLiveUsage(usage, coached.usage);
        return {
          node: {
            stateHash: hashLiveState(state, history),
            state,
            history,
            legalActions,
            rubric: coached.rubric,
          },
          usage,
        };
      }
      if (state.actorSeat === null || legalActions.length === 0) {
        throw new Error("playing state has no legal opponent action");
      }
      await options.onWaiting?.(state.actorSeat, history, state);
      const villain = await chooseVillainAction({
        apiKey: options.apiKey,
        hand: options.hand,
        state,
        legalActions,
        publicHistory: history,
        fetchImpl: options.fetchImpl,
      });
      usage = addLiveUsage(usage, villain.usage);
      const applied = applyLiveAction({
        hand: options.hand,
        state,
        actionId: villain.actionId,
      });
      state = applied.state;
      history.push(applied.event);
      await options.onHistoryAppend?.(applied.event, history, state);
    }
    throw new Error("live continuation exceeded 128 actions");
  } catch (error) {
    throw new LiveUsageError(
      error instanceof Error ? error.message : String(error),
      addLiveUsage(usage, liveUsageFromError(error)),
    );
  }
}
