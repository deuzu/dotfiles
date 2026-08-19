import * as fs from "node:fs";
import * as path from "node:path";
import type { RPIPhase, RPIState } from "./types.ts";

export function slugify(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 40);
}

export function getTodayString(): string {
  const d = new Date();
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

export class RPIStateMachine {
  private state: RPIState;
  private cwd: string;

  constructor(cwd: string, state?: RPIState) {
    this.cwd = cwd;
    if (state) {
      this.state = state;
    } else {
      this.state = {
        id: "",
        task: "",
        artifactDir: "",
        currentPhase: "question",
        status: "in_progress",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        history: [],
      };
    }
  }

  static initNew(cwd: string, task: string): RPIStateMachine {
    const today = getTodayString();
    const slug = slugify(task) || "task";
    const id = `${today}-${slug}`;
    const artifactDir = path.join(cwd, ".agents", "thoughts", "rpi", id);

    fs.mkdirSync(artifactDir, { recursive: true });

    const state: RPIState = {
      id,
      task,
      artifactDir,
      currentPhase: "question",
      status: "in_progress",
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      history: [],
    };

    const sm = new RPIStateMachine(cwd, state);
    sm.save();
    return sm;
  }

  static load(cwd: string, stateFilePath: string): RPIStateMachine | null {
    if (!fs.existsSync(stateFilePath)) return null;
    try {
      const data = JSON.parse(fs.readFileSync(stateFilePath, "utf-8")) as RPIState;
      return new RPIStateMachine(cwd, data);
    } catch {
      return null;
    }
  }

  getState(): RPIState {
    return this.state;
  }

  save() {
    this.state.updatedAt = new Date().toISOString();
    const stateFile = path.join(this.state.artifactDir, "state.json");
    try {
      fs.mkdirSync(this.state.artifactDir, { recursive: true });
      fs.writeFileSync(stateFile, JSON.stringify(this.state, null, 2), "utf-8");
    } catch (err) {
      console.error("Failed to save RPI state:", err);
    }
  }

  recordPhaseCompletion(phase: string, artifact?: string) {
    this.state.history.push({
      phase,
      completedAt: new Date().toISOString(),
      artifact,
    });
    this.save();
  }

  renderProgressBar(): string[] {
    const phases = [
      { key: "question", label: "Question" },
      { key: "research", label: "Research" },
      { key: "design", label: "Design" },
      { key: "structure", label: "Structure" },
      { key: "plan", label: "Plan" },
      { key: "implement", label: "Implement" },
    ];

    const currentKey = this.state.currentPhase.replace(/^gate_/, "");
    const completedPhases = new Set(this.state.history.map((h) => h.phase));

    const steps = phases.map((p) => {
      if (completedPhases.has(p.key)) {
        return `[✓ ${p.label}]`;
      }
      if (p.key === currentKey || this.state.currentPhase === `gate_${p.key}`) {
        return `[▶ ${p.label}]`;
      }
      return `[○ ${p.label}]`;
    });

    const relArtifactDir = path.relative(this.cwd, this.state.artifactDir) || this.state.artifactDir;

    return [
      `RPI Workflow: ${this.state.task.slice(0, 55)}${this.state.task.length > 55 ? "..." : ""}`,
      `Progress: ${steps.join(" ── ")}`,
      `Artifacts: ${relArtifactDir}/`,
    ];
  }
}
