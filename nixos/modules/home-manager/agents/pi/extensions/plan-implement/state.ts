import type { PlanExtensionState, ActiveMode } from "./types.ts";

const state: PlanExtensionState = {
  activeMode: null,
  isPlanModeActive: false,
  baselineTools: null,
  allowedSubagents: null,
  allowedTools: null,
  injectedModePrompts: new Set<string>(),
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
  // NOTE: injectedModePrompts is intentionally NOT cleared here (nor in
  // restoreBaselineTools/saveBaselineTools). Mode prompts live in the
  // conversation history for the whole session, so re-entering a mode —
  // even after /implement resets the mode state — must not re-inject them.
  // The set resets naturally per session because pi rebinds extension
  // modules on session switch (new/resume/fork).
}

export function hasModePromptBeenSent(mode: string): boolean {
  return state.injectedModePrompts.has(mode);
}

export function markModePromptSent(mode: string): void {
  state.injectedModePrompts.add(mode);
}

