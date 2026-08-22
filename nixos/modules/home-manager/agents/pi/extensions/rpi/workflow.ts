import * as path from "node:path";

type StepHandler = (workflow: RPIWorkflow) => Promise<void>;

type WorkflowStepHandlers = Record<WorkflowStepName, StepHandler>;

type WorkflowStepName = "init" | "question" | "research";

type WorkflowStep = {
  name: WorkflowStepName;
  artifacts: string[]; // todo path[]
  agent?: Agent;
  error?: string;
  startedAt: Date;
  endedAt?: Date;
};

type Agent = {
  name: string;
  prompt: string;
  sessionId: string;
};

type WorkflowState =
  | "init"
  | "in_progress"
  | "completed"
  | "paused"
  | "aborted"
  | "errored";

export class RPIWorkflow {
  private state: WorkflowState;
  private task: string;
  private artifactDirectory: string; // todo change type to specific string Path
  private currentStep: WorkflowStep;
  private stepHandlers: WorkflowStepHandlers;
  private stepHistory: WorkflowStep[];

  constructor(
    state: WorkflowState,
    task: string,
    artifactDirectory: string,
    currentStep: WorkflowStep,
    stepHandlers: WorkflowStepHandlers,
    stepHistory: WorkflowStep[] = [],
  ) {
    this.state = state;
    this.task = task;
    this.artifactDirectory = artifactDirectory;
    this.currentStep = currentStep;
    this.stepHandlers = stepHandlers;
    this.stepHistory = stepHistory;
  }

  static init(
    task: string,
    artifactDirectory: string,
    stepHandlers: WorkflowStepHandlers,
  ): RPIWorkflow {
    const step: WorkflowStep = {
      name: "init",
      artifacts: [],
      startedAt: new Date(),
    };

    return new RPIWorkflow(
      "init",
      task,
      artifactDirectory,
      step,
      stepHandlers,
    );
  }

  async start(): Promise<void> {
    this.next();

    while (this.hasEnded() === false) {
      if (this.currentStep === undefined) {
        break;
      }

      await this.stepHandlers[this.currentStep.name](this);
      this.next();
    }
  }

  hasEnded(): boolean {
    return (
      this.state === "completed" ||
      this.state === "paused" ||
      this.state === "aborted"
    );
  }

  next(): void {
    this.currentStep.endedAt = new Date();

    switch (this.currentStep?.name) {
      case "init": {
        const agent = {
          name: "rpi-1-question",
          prompt: `Task: ${this.task}, Artifact Directory: ${this.artifactDirectory}`,
          sessionId: crypto.randomUUID(),
        };
        this.to({
          name: "question",
          artifacts: ["question.md"],
          agent,
          startedAt: new Date(),
        });

        break;
      }

      case "question": {
        const agent = {
          name: "rpi-1-research",
          prompt: `Artifact Directory: ${this.artifactDirectory}`,
          sessionId: crypto.randomUUID(),
        };
        this.to({
          name: "research",
          artifacts: ["research.md"],
          agent,
          startedAt: new Date(),
        });

        break;
      }

      case "research": {
        this.setComplete();

        break;
      }
    }
  }

  to(step: WorkflowStep): void {
    this.currentStep = step;
    this.stepHistory.push(this.currentStep);
  }

  setComplete(): void {
    this.state = "completed";
    this.stepHistory.push(this.currentStep);
  }

  setError(error: Error | string): void {
    this.state = "errored";
    this.currentStep.error =
      error instanceof Error ? error.message : String(error);
    this.stepHistory.push(this.currentStep);
  }

  getArtifactsDirectory(): string {
    return this.artifactDirectory;
  }

  getCurrentStep(): WorkflowStep {
    return this.currentStep;
  }

  toJSON() {
    return {
      state: this.state,
      artifactDirectory: this.artifactDirectory,
      stepHistory: this.stepHistory,
    };
  }
}
