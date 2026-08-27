import type { PlanExtensionState, ActiveMode } from "./types.ts";

const state: PlanExtensionState = {
  activeMode: null,
  isPlanModeActive: false,
  baselineTools: null,
  allowedSubagents: null,
  allowedTools: null,
};

export function getPlanState(): PlanExtensionState {
  return state;
}

export function saveBaselineTools(
  tools: string[],
  mode: ActiveMode = "plan",
  allowedSubagents: string[] | null = null,
  allowedTools: string[] | null = null,
): void {
  if (state.activeMode === null && state.baselineTools === null) {
    state.baselineTools = [...tools];
  }
  state.activeMode = mode;
  state.isPlanModeActive = mode !== null;
  state.allowedSubagents = allowedSubagents;
  state.allowedTools = allowedTools;
}

export function restoreBaselineTools(): string[] | null {
  const previous = state.baselineTools;
  state.baselineTools = null;
  state.activeMode = null;
  state.isPlanModeActive = false;
  state.allowedSubagents = null;
  state.allowedTools = null;
  return previous;
}

export function resetPlanState(): void {
  state.activeMode = null;
  state.isPlanModeActive = false;
  state.baselineTools = null;
  state.allowedSubagents = null;
  state.allowedTools = null;
}

