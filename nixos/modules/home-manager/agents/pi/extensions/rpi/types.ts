export type RPIPhase =
  | "question"
  | "research"
  | "design-questions"
  | "design"
  | "structure"
  | "plan"
  | "plan-review"
  | "worktree"
  | "implement"
  | "completed";

export interface RPIPhaseHistoryItem {
  phase: string;
  completedAt: string;
  artifact?: string;
}

export interface RPIState {
  id: string;
  task: string;
  artifactDir: string;
  currentPhase: RPIPhase;
  status: "in_progress" | "paused" | "completed" | "aborted";
  createdAt: string;
  updatedAt: string;
  history: RPIPhaseHistoryItem[];
}

export interface RunAgentOptions {
  ownerRunId?: string;
  nodeId?: string;
  schema?: Record<string, unknown>;
  onUpdate?: (chunk: string) => void;
  signal?: AbortSignal;
  timeoutMs?: number;
}

export interface ParsedAgentConfig {
  name: string;
  model?: string;
  thinkingLevel?: string;
  tools?: string[];
  systemPrompt?: string;
}

export type GateResult = "proceed" | "paused" | "aborted";
