import type { PlanExtensionState, ActiveMode } from "./types.ts";

export const MUTATING_TOOLS: ReadonlySet<string> = new Set([
  "edit",
  "write",
  "bash",
]);

export const DEFAULT_FALLBACK_TOOLS: string[] = [
  "read",
  "edit",
  "write",
  "bash",
  "Agent",
];

const state: PlanExtensionState = {
  activeMode: null,
  isPlanModeActive: false,
  baselineTools: null,
  allowedSubagents: null,
};

export function getPlanState(): PlanExtensionState {
  return state;
}

export function saveBaselineTools(
  tools: string[],
  mode: ActiveMode = "plan",
  allowedSubagents: string[] | null = null,
): void {
  if (state.activeMode === null && state.baselineTools === null) {
    state.baselineTools = [...tools];
  }
  state.activeMode = mode;
  state.isPlanModeActive = mode !== null;
  state.allowedSubagents = allowedSubagents;
}

export function restoreBaselineTools(): string[] | null {
  const previous = state.baselineTools;
  state.baselineTools = null;
  state.activeMode = null;
  state.isPlanModeActive = false;
  state.allowedSubagents = null;
  return previous;
}

export function getReadOnlyTools(activeTools: string[]): string[] {
  return activeTools.filter((tool) => !MUTATING_TOOLS.has(tool));
}

export function resetPlanState(): void {
  state.activeMode = null;
  state.isPlanModeActive = false;
  state.baselineTools = null;
  state.allowedSubagents = null;
}

