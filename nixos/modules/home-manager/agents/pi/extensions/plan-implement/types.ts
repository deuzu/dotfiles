export type ActiveMode = "plan" | "explore" | null;

export interface PlanExtensionState {
  activeMode: ActiveMode;
  isPlanModeActive: boolean;
  baselineTools: string[] | null;
  allowedSubagents: string[] | null;
}

export interface ParsedAgentPrompt {
  name: string;
  body: string;
  source: "file";
  allowedSubagents?: string[];
}

