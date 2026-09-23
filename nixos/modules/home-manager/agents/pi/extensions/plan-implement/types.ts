export type ActiveMode = "plan" | "plan-lite" | "explore" | null;

export interface PlanExtensionState {
  activeMode: ActiveMode;
  isPlanModeActive: boolean;
  baselineTools: string[] | null;
  allowedSubagents: string[] | null;
  allowedTools: string[] | null;
  /** Mode keys ("plan" | "plan-lite" | "explore" | "implement") whose
   * full instruction prompt has already been injected this session. */
  injectedModePrompts: Set<string>;
}

export interface ParsedAgentPrompt {
  name: string;
  body: string;
  source: "file";
  allowedSubagents?: string[];
  tools?: string[];
  model?: string;
}

