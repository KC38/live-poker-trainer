/**
 * Shared lazy-tree expansion for live hands.
 *
 * Every continuation is produced once from an authoritative state. Villain
 * choices are sequential and perspective-isolated; the resulting Hero node
 * receives an all-actions coaching rubric before it is exposed.
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
}

export interface PreparedLiveHand {
  root: PreparedLiveNode;
  warmEdges: PreparedLiveEdge[];
}

/** Resolves forced/opponent action to the first Hero decision and warms it. */
export async function prepareLiveHand(options: {
  apiKey: string;
  hand: LiveHandDefinition;
  fetchImpl?: typeof fetch;
}): Promise<PreparedLiveHand> {
  const initial = createInitialLiveState(options.hand);
  const root = await resolveToHeroOrTerminal({
    apiKey: options.apiKey,
    hand: options.hand,
    state: initial,
    history: [],
    fetchImpl: options.fetchImpl,
  });
  if (root.state.status !== "playing" || !liveHeroToAct(options.hand, root.state)) {
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
    warmEdges.push(await expandLiveHeroAction({
      apiKey: options.apiKey,
      hand: options.hand,
      parent: root,
      actionId,
      fetchImpl: options.fetchImpl,
    }));
  }
  return {root, warmEdges};
}

/** Expands one shared Hero edge through all villains to the next Hero node. */
export async function expandLiveHeroAction(options: {
  apiKey: string;
  hand: LiveHandDefinition;
  parent: PreparedLiveNode;
  actionId: string;
  fetchImpl?: typeof fetch;
}): Promise<PreparedLiveEdge> {
  if (!options.parent.rubric) {
    throw new Error("cannot expand a Hero node without coaching");
  }
  const selected = options.parent.legalActions.find(
    (candidate) => candidate.actionId === options.actionId,
  );
  if (!selected) throw new Error(`action ${options.actionId} is not legal`);
  const applied = applyLiveAction({
    hand: options.hand,
    state: options.parent.state,
    actionId: options.actionId,
  });
  const history = [...options.parent.history, applied.event];
  const child = await resolveToHeroOrTerminal({
    apiKey: options.apiKey,
    hand: options.hand,
    state: applied.state,
    history,
    fetchImpl: options.fetchImpl,
  });
  const events = child.history.slice(options.parent.history.length);
  return {
    parentStateHash: options.parent.stateHash,
    actionId: options.actionId,
    child,
    events,
    coaching: assessmentForAction(options.parent.rubric, options.actionId),
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
}): Promise<PreparedLiveNode> {
  let state = options.state;
  const history = [...options.history];
  for (let guard = 0; guard < 128; guard++) {
    if (state.status !== "playing") {
      return {
        stateHash: hashLiveState(state, history),
        state,
        history,
        legalActions: [],
        rubric: null,
      };
    }
    const legalActions = legalLiveActions(options.hand, state);
    if (liveHeroToAct(options.hand, state)) {
      const rubric = await generateCoachingRubric({
        apiKey: options.apiKey,
        hand: options.hand,
        state,
        legalActions,
        publicHistory: history,
        fetchImpl: options.fetchImpl,
      });
      return {
        stateHash: hashLiveState(state, history),
        state,
        history,
        legalActions,
        rubric,
      };
    }
    if (state.actorSeat === null || legalActions.length === 0) {
      throw new Error("playing state has no legal opponent action");
    }
    const actionId = await chooseVillainAction({
      apiKey: options.apiKey,
      hand: options.hand,
      state,
      legalActions,
      publicHistory: history,
      fetchImpl: options.fetchImpl,
    });
    const applied = applyLiveAction({
      hand: options.hand,
      state,
      actionId,
    });
    state = applied.state;
    history.push(applied.event);
  }
  throw new Error("live continuation exceeded 128 actions");
}
