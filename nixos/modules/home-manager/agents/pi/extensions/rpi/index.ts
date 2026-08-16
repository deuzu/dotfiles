import { spawn } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

export type RPIPhase =
  | "question"
  | "research"
  | "design"
  | "gate_design"
  | "structure"
  | "plan"
  | "gate_plan"
  | "worktree"
  | "implement"
  | "completed";

export interface RPIState {
  id: string;
  task: string;
  artifactDir: string;
  currentPhase: RPIPhase;
  status: "in_progress" | "paused" | "completed" | "aborted";
  createdAt: string;
  updatedAt: string;
  history: Array<{
    phase: string;
    completedAt: string;
    artifact?: string;
  }>;
}

function slugify(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 40);
}

function getTodayString(): string {
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

export interface RunAgentOptions {
  ownerRunId?: string;
  nodeId?: string;
  schema?: Record<string, unknown>;
  onUpdate?: (chunk: string) => void;
  signal?: AbortSignal;
  timeoutMs?: number;
}

interface ParsedAgentConfig {
  name: string;
  model?: string;
  thinkingLevel?: string;
  tools?: string[];
  systemPrompt?: string;
}

function parseAgentFile(filePath: string): ParsedAgentConfig | null {
  if (!fs.existsSync(filePath)) return null;
  try {
    const content = fs.readFileSync(filePath, "utf-8");
    if (!content.startsWith("---")) {
      return { name: path.basename(filePath, ".md"), systemPrompt: content };
    }
    const endIndex = content.indexOf("\n---", 3);
    if (endIndex === -1) {
      return { name: path.basename(filePath, ".md"), systemPrompt: content };
    }
    const frontmatterRaw = content.slice(4, endIndex);
    const body = content.slice(endIndex + 4).trim();

    const lines = frontmatterRaw.split(/\r?\n/);
    let name = path.basename(filePath, ".md");
    let model: string | undefined;
    let thinkingLevel: string | undefined;
    let tools: string[] | undefined;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();
      if (line.startsWith("name:")) {
        name = line.slice(5).trim();
      } else if (line.startsWith("model:")) {
        const val = line.slice(6).trim().replace(/^["']|["']$/g, "");
        if (val && !val.startsWith("@")) model = val;
      } else if (line.startsWith("thinkingLevel:") || line.startsWith("thinking:")) {
        const val = line.split(":")[1].trim().replace(/^["']|["']$/g, "");
        if (val) thinkingLevel = val;
      } else if (line.startsWith("tools:")) {
        const rest = line.slice(6).trim();
        if (rest.startsWith("[") && rest.endsWith("]")) {
          tools = rest
            .slice(1, -1)
            .split(",")
            .map((t) => t.trim().replace(/^["']|["']$/g, ""))
            .filter(Boolean);
        }
      }
    }

    return {
      name,
      model,
      thinkingLevel,
      tools,
      systemPrompt: body,
    };
  } catch {
    return null;
  }
}

function resolveAgentConfig(cwd: string, agentName: string): ParsedAgentConfig {
  const possiblePaths = [
    path.join(cwd, ".pi", "agents", `${agentName}.md`),
    path.join(cwd, ".agents", `${agentName}.md`),
    path.join(os.homedir(), ".pi", "agent", "agents", `${agentName}.md`),
  ];

  for (const p of possiblePaths) {
    const parsed = parseAgentFile(p);
    if (parsed) return parsed;
  }

  return {
    name: agentName,
    tools: ["read", "write", "edit", "bash"],
  };
}

export function runAgent<T = string>(
  _pi: ExtensionAPI,
  ctxOrCwd: ExtensionContext | string,
  agent: string,
  task: string,
  optionsOrSchema?: RunAgentOptions | Record<string, unknown>
): Promise<T> {
  const cwd = typeof ctxOrCwd === "string" ? ctxOrCwd : ctxOrCwd.cwd;
  const options: RunAgentOptions =
    optionsOrSchema &&
    ("ownerRunId" in optionsOrSchema ||
      "nodeId" in optionsOrSchema ||
      "schema" in optionsOrSchema ||
      "onUpdate" in optionsOrSchema ||
      "signal" in optionsOrSchema ||
      "timeoutMs" in optionsOrSchema)
      ? (optionsOrSchema as RunAgentOptions)
      : optionsOrSchema
      ? { schema: optionsOrSchema as Record<string, unknown> }
      : {};

  const agentConfig = resolveAgentConfig(cwd, agent);
  const tempFiles: string[] = [];

  return new Promise<T>((resolve, reject) => {
    const args: string[] = [
      "-p",
      "--mode",
      "json",
      "--no-session",
      "--no-context-files",
      "--no-skills",
    ];

    if (agentConfig.model) {
      args.push("--model", agentConfig.model);
    }
    if (agentConfig.thinkingLevel) {
      args.push("--thinking", agentConfig.thinkingLevel);
    }

    const tools =
      agentConfig.tools && agentConfig.tools.length > 0
        ? agentConfig.tools.join(",")
        : "read,write,edit,bash";
    args.push("--tools", tools);

    if (agentConfig.systemPrompt) {
      const tempPromptFile = path.join(
        os.tmpdir(),
        `pi-rpi-agent-${Date.now()}-${Math.random().toString(36).slice(2, 6)}.md`
      );
      fs.writeFileSync(tempPromptFile, agentConfig.systemPrompt, "utf-8");
      tempFiles.push(tempPromptFile);
      args.push("--append-system-prompt", tempPromptFile);
    }

    args.push(task);

    const cleanup = () => {
      for (const f of tempFiles) {
        try {
          if (fs.existsSync(f)) fs.unlinkSync(f);
        } catch {
          // ignore
        }
      }
    };

    let child: ReturnType<typeof spawn>;
    try {
      child = spawn("pi", args, {
        cwd,
        env: process.env,
        stdio: ["ignore", "pipe", "pipe"],
      });
    } catch (err) {
      cleanup();
      return reject(err);
    }

    let stdoutBuffer = "";
    let stderrBuffer = "";
    let latestOutput = "";
    let isSettled = false;

    const timeoutDuration = options.timeoutMs ?? 600000;
    const timer = setTimeout(() => {
      if (!isSettled) {
        isSettled = true;
        child.kill("SIGTERM");
        setTimeout(() => child.kill("SIGKILL"), 3000);
        cleanup();
        reject(new Error(`Agent ${agent} timed out after ${timeoutDuration}ms`));
      }
    }, timeoutDuration);

    if (options.signal) {
      options.signal.addEventListener(
        "abort",
        () => {
          if (!isSettled) {
            isSettled = true;
            clearTimeout(timer);
            child.kill("SIGTERM");
            setTimeout(() => child.kill("SIGKILL"), 2000);
            cleanup();
            reject(new Error("Subagent execution aborted"));
          }
        },
        { once: true }
      );
    }

    child.stdout.on("data", (chunk: Buffer) => {
      stdoutBuffer += chunk.toString("utf-8");
      const lines = stdoutBuffer.split("\n");
      stdoutBuffer = lines.pop() ?? "";

      for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed) continue;
        try {
          const event = JSON.parse(trimmed);
          if (event.type === "message_update" && event.assistantMessageEvent?.type === "text_delta") {
            const delta = event.assistantMessageEvent.delta || "";
            if (delta) options.onUpdate?.(delta);
          } else if (event.type === "turn_end" && event.message?.content) {
            const textParts = (event.message.content as Array<{ type: string; text?: string }>)
              .filter((p) => p.type === "text" && p.text)
              .map((p) => p.text!);
            if (textParts.length > 0) latestOutput = textParts.join("\n");
          } else if (event.type === "agent_end" && Array.isArray(event.messages)) {
            const assistantMsgs = event.messages.filter((m: { role: string }) => m.role === "assistant");
            if (assistantMsgs.length > 0) {
              const lastMsg = assistantMsgs[assistantMsgs.length - 1];
              if (Array.isArray(lastMsg.content)) {
                const textParts = lastMsg.content
                  .filter((p: { type: string; text?: string }) => p.type === "text" && p.text)
                  .map((p: { text: string }) => p.text);
                if (textParts.length > 0) latestOutput = textParts.join("\n");
              }
            }
          }
        } catch {
          // ignore malformed line
        }
      }
    });

    child.stderr.on("data", (chunk: Buffer) => {
      stderrBuffer += chunk.toString("utf-8");
    });

    child.on("error", (err) => {
      if (!isSettled) {
        isSettled = true;
        clearTimeout(timer);
        cleanup();
        reject(err);
      }
    });

    child.on("close", (code) => {
      if (isSettled) return;
      isSettled = true;
      clearTimeout(timer);
      cleanup();

      if (code === 0) {
        if (options.schema) {
          try {
            const json = JSON.parse(latestOutput);
            resolve(json as T);
          } catch {
            resolve(latestOutput as unknown as T);
          }
        } else {
          resolve(latestOutput as unknown as T);
        }
      } else {
        const errDetails = stderrBuffer.trim() || latestOutput.trim() || `Exit code ${code}`;
        reject(new Error(`Agent ${agent} failed (code ${code}): ${errDetails}`));
      }
    });
  });
}

function readArtifact(artifactDir: string, fileName: string): string | null {
  const filePath = path.join(artifactDir, fileName);
  if (fs.existsSync(filePath)) {
    return fs.readFileSync(filePath, "utf-8");
  }
  return null;
}

export default function rpiWorkflowExtension(pi: ExtensionAPI) {
  let activeMachine: RPIStateMachine | null = null;

  function updateUIWidget(ctx: ExtensionContext, sm: RPIStateMachine) {
    if (ctx.hasUI) {
      ctx.ui.setWidget("rpi-progress", sm.renderProgressBar());
    }
  }

  function clearUIWidget(ctx: ExtensionContext) {
    if (ctx.hasUI) {
      ctx.ui.setWidget("rpi-progress", undefined);
      ctx.ui.setStatus("rpi", undefined);
    }
  }

  async function executeWorkflowLoop(sm: RPIStateMachine, ctx: ExtensionContext) {
    activeMachine = sm;
    const state = sm.getState();
    const relArtifact = path.relative(ctx.cwd, state.artifactDir);

    while (state.status === "in_progress") {
      updateUIWidget(ctx, sm);

      switch (state.currentPhase) {
        // ==========================================
        // PHASE 1: QUESTION (Auto-advances)
        // ==========================================
        case "question": {
          ctx.ui.setStatus("rpi", "RPI [1/6 Question] ⏳ Decomposing task...");
          ctx.ui.notify("Phase 1: Decomposing task into neutral research questions...", "info");

          const prompt = `Artifact directory: ${state.artifactDir}\nTask description: ${state.task}\n\nExecute Phase 1: Create task.md and questions.md in the artifact directory.`;
          try {
            await runAgent(pi, ctx, "rpi-1-question", prompt, {
              ownerRunId: state.id,
              nodeId: `question-${Date.now()}`,
            });
            sm.recordPhaseCompletion("question", "questions.md");
            state.currentPhase = "research";
            sm.save();
          } catch (err) {
            const errMsg = err instanceof Error ? err.message : String(err);
            ctx.ui.notify(`Phase 1 subagent failed: ${errMsg}`, "error");
            state.status = "paused";
            sm.save();
            return;
          }
          break;
        }

        // ==========================================
        // PHASE 2: RESEARCH (Auto-advances)
        // ==========================================
        case "research": {
          ctx.ui.setStatus("rpi", "RPI [2/6 Research] ⏳ Exploring codebase...");
          ctx.ui.notify("Phase 2: Researching codebase and answering questions...", "info");

          const prompt = `Artifact directory: ${state.artifactDir}\n\nExecute Phase 2: Read questions.md from the artifact directory, research the codebase, and write findings to research.md.`;
          try {
            await runAgent(pi, ctx, "rpi-2-research", prompt, {
              ownerRunId: state.id,
              nodeId: `research-${Date.now()}`,
            });
            sm.recordPhaseCompletion("research", "research.md");
            state.currentPhase = "design";
            sm.save();
          } catch (err) {
            const errMsg = err instanceof Error ? err.message : String(err);
            ctx.ui.notify(`Phase 2 subagent failed: ${errMsg}`, "error");
            state.status = "paused";
            sm.save();
            return;
          }
          break;
        }

        // ==========================================
        // PHASE 3: DESIGN (Auto-advances to STOP 1)
        // ==========================================
        case "design": {
          ctx.ui.setStatus("rpi", "RPI [3/6 Design] ⏳ Formulating architecture...");
          ctx.ui.notify("Phase 3: Formulating design decisions and architectural options...", "info");

          const prompt = `Artifact directory: ${state.artifactDir}\n\nExecute Phase 3: Read task.md, questions.md, and research.md. Formulate design questions, tradeoffs, and create design.md in the artifact directory.`;
          try {
            await runAgent(pi, ctx, "rpi-3-design", prompt, {
              ownerRunId: state.id,
              nodeId: `design-${Date.now()}`,
            });
            sm.recordPhaseCompletion("design", "design.md");
            state.currentPhase = "gate_design";
            sm.save();
          } catch (err) {
            const errMsg = err instanceof Error ? err.message : String(err);
            ctx.ui.notify(`Phase 3 subagent failed: ${errMsg}`, "error");
            state.status = "paused";
            sm.save();
            return;
          }
          break;
        }

        // ==========================================
        // STOP 1: DESIGN GATE (User Confirmation)
        // ==========================================
        case "gate_design": {
          ctx.ui.setStatus("rpi", "RPI [🛑 Stop 1: Design Review] Waiting for user confirmation...");
          updateUIWidget(ctx, sm);

          const designQuestions = readArtifact(state.artifactDir, "design-questions.md");
          const designDoc = readArtifact(state.artifactDir, "design.md");

          let previewSummary = "Design phase completed.";
          if (designQuestions) {
            previewSummary = `Design Questions found:\n${designQuestions.slice(0, 300)}...`;
          } else if (designDoc) {
            previewSummary = `Design Summary:\n${designDoc.slice(0, 300)}...`;
          }

          if (ctx.hasUI) {
            const choices = [
              "Approve Design & Proceed to Structure/Plan",
              "Answer Questions / Refine Design",
              "Inspect Design Artifacts",
              "Skip to Plan",
              "Pause Workflow",
              "Abort Workflow",
            ];

            const selected = await ctx.ui.select(
              `🛑 Stop 1: Design Review (${relArtifact})`,
              choices
            );

            if (selected === choices[0]) {
              ctx.ui.notify("Design approved! Proceeding to Structure & Planning...", "info");
              state.currentPhase = "structure";
              sm.save();
            } else if (selected === choices[1]) {
              const feedback = await ctx.ui.input(
                "Enter design answers or feedback:",
                "e.g. Prefer Option A for data model..."
              );
              if (feedback) {
                ctx.ui.setStatus("rpi", "Re-running Design phase with your feedback...");
                const prompt = `Artifact directory: ${state.artifactDir}\nUser Feedback on Design: ${feedback}\n\nUpdate design.md based on this user feedback.`;
                try {
                  await runAgent(pi, ctx, "rpi-3-design", prompt, {
                    ownerRunId: state.id,
                    nodeId: `design-refine-${Date.now()}`,
                  });
                  sm.recordPhaseCompletion("design_refinement", "design.md");
                } catch (err) {
                  const errMsg = err instanceof Error ? err.message : String(err);
                  ctx.ui.notify(`Design refinement failed: ${errMsg}`, "error");
                }
              }
            } else if (selected === choices[2]) {
              const content = designDoc || designQuestions || "(No design content found)";
              ctx.ui.notify(`Design Preview:\n\n${content.slice(0, 800)}...`, "info");
            } else if (selected === choices[3]) {
              ctx.ui.notify("Skipping directly to Planning...", "warning");
              state.currentPhase = "plan";
              sm.save();
            } else if (selected === choices[4]) {
              state.status = "paused";
              sm.save();
              ctx.ui.notify("RPI Workflow paused. Resume anytime with /rpi-resume", "info");
              return;
            } else {
              state.status = "aborted";
              sm.save();
              clearUIWidget(ctx);
              ctx.ui.notify("RPI Workflow aborted.", "warning");
              return;
            }
          } else {
            state.currentPhase = "structure";
            sm.save();
          }
          break;
        }

        // ==========================================
        // PHASE 4: STRUCTURE (Auto-advances)
        // ==========================================
        case "structure": {
          ctx.ui.setStatus("rpi", "RPI [4/6 Structure] ⏳ Outlining vertical slices...");
          ctx.ui.notify("Phase 4: Outlining component structure and test checkpoints...", "info");

          const prompt = `Artifact directory: ${state.artifactDir}\n\nExecute Phase 4: Read design.md and research.md. Create vertical slices and structure.md.`;
          try {
            await runAgent(pi, ctx, "rpi-4-structure", prompt, {
              ownerRunId: state.id,
              nodeId: `structure-${Date.now()}`,
            });
            sm.recordPhaseCompletion("structure", "structure.md");
            state.currentPhase = "plan";
            sm.save();
          } catch (err) {
            const errMsg = err instanceof Error ? err.message : String(err);
            ctx.ui.notify(`Phase 4 subagent failed: ${errMsg}`, "error");
            state.status = "paused";
            sm.save();
            return;
          }
          break;
        }

        // ==========================================
        // PHASE 5: PLAN (Auto-advances to STOP 2)
        // ==========================================
        case "plan": {
          ctx.ui.setStatus("rpi", "RPI [5/6 Plan] ⏳ Generating implementation plan...");
          ctx.ui.notify("Phase 5: Generating detailed implementation plan...", "info");

          const prompt = `Artifact directory: ${state.artifactDir}\n\nExecute Phase 5: Read structure.md, design.md, and research.md. Write actionable plan.md with checkboxes and verification steps.`;
          try {
            await runAgent(pi, ctx, "rpi-5-plan", prompt, {
              ownerRunId: state.id,
              nodeId: `plan-${Date.now()}`,
            });
            sm.recordPhaseCompletion("plan", "plan.md");
            state.currentPhase = "gate_plan";
            sm.save();
          } catch (err) {
            const errMsg = err instanceof Error ? err.message : String(err);
            ctx.ui.notify(`Phase 5 subagent failed: ${errMsg}`, "error");
            state.status = "paused";
            sm.save();
            return;
          }
          break;
        }

        // ==========================================
        // STOP 2: PLAN VALIDATION GATE
        // ==========================================
        case "gate_plan": {
          ctx.ui.setStatus("rpi", "RPI [🛑 Stop 2: Plan Validation] Waiting for plan approval...");
          updateUIWidget(ctx, sm);

          const planDoc = readArtifact(state.artifactDir, "plan.md");

          if (ctx.hasUI) {
            const choices = [
              "Validate Plan & Begin Implementation",
              "Request Plan Changes / Feedback",
              "Inspect Implementation Plan",
              "Skip directly to Implement",
              "Pause Workflow",
              "Abort Workflow",
            ];

            const selected = await ctx.ui.select(
              `🛑 Stop 2: Plan Validation (${relArtifact})`,
              choices
            );

            if (selected === choices[0] || selected === choices[3]) {
              ctx.ui.notify("Plan validated! Starting Implementation phase...", "info");
              state.currentPhase = "implement";
              sm.save();
            } else if (selected === choices[1]) {
              const feedback = await ctx.ui.input(
                "Enter plan changes or feedback:",
                "e.g. Ensure we add unit tests for the token validator..."
              );
              if (feedback) {
                ctx.ui.setStatus("rpi", "Refining plan with your feedback...");
                const prompt = `Artifact directory: ${state.artifactDir}\nUser Feedback on Plan: ${feedback}\n\nUpdate plan.md based on this user feedback.`;
                try {
                  await runAgent(pi, ctx, "rpi-5-plan", prompt, {
                    ownerRunId: state.id,
                    nodeId: `plan-refine-${Date.now()}`,
                  });
                  sm.recordPhaseCompletion("plan_refinement", "plan.md");
                } catch (err) {
                  const errMsg = err instanceof Error ? err.message : String(err);
                  ctx.ui.notify(`Plan refinement failed: ${errMsg}`, "error");
                }
              }
            } else if (selected === choices[2]) {
              const content = planDoc || "(No plan content found)";
              ctx.ui.notify(`Plan Preview:\n\n${content.slice(0, 800)}...`, "info");
            } else if (selected === choices[4]) {
              state.status = "paused";
              sm.save();
              ctx.ui.notify("RPI Workflow paused. Resume anytime with /rpi-resume", "info");
              return;
            } else {
              state.status = "aborted";
              sm.save();
              clearUIWidget(ctx);
              ctx.ui.notify("RPI Workflow aborted.", "warning");
              return;
            }
          } else {
            state.currentPhase = "implement";
            sm.save();
          }
          break;
        }

        // ==========================================
        // PHASE 7: IMPLEMENTATION (Executes and STOP 3)
        // ==========================================
        case "implement": {
          ctx.ui.setStatus("rpi", "RPI [6/6 Implement] ⏳ Executing plan...");
          ctx.ui.notify("Phase 7: Executing implementation plan step-by-step...", "info");

          const prompt = `Artifact directory: ${state.artifactDir}\n\nExecute Phase 7: Read plan.md from the artifact directory and implement each phase, checking off checkboxes as you verify them.`;
          try {
            await runAgent(pi, ctx, "rpi-7-implement", prompt, {
              ownerRunId: state.id,
              nodeId: `implement-${Date.now()}`,
              onUpdate: (_chunk) => {
                // Streaming progress
              },
            });
            sm.recordPhaseCompletion("implement", "code_changes");
            state.currentPhase = "completed";
            state.status = "completed";
            sm.save();
          } catch (err) {
            const errMsg = err instanceof Error ? err.message : String(err);
            ctx.ui.notify(`Implementation failed: ${errMsg}`, "error");
            state.status = "paused";
            sm.save();
            return;
          }
          break;
        }

        // ==========================================
        // STOP 3: WORKFLOW COMPLETED
        // ==========================================
        case "completed": {
          ctx.ui.setStatus("rpi", "RPI [✓ Completed] Implementation done!");
          if (ctx.hasUI) {
            ctx.ui.setWidget("rpi-progress", [
              `✓ RPI Workflow Completed: ${state.task}`,
              `Artifacts & Plan: ${relArtifact}/`,
              `All phases executed successfully.`,
            ]);
            ctx.ui.notify("🎉 RPI Implementation complete!", "info");
          }
          return;
        }

        default:
          state.status = "aborted";
          sm.save();
          return;
      }
    }
  }

  pi.registerCommand("rpi", {
    description: "Start or continue an interactive RPI (Research-Plan-Implement) workflow",
    handler: async (args, ctx) => {
      let task = (args || "").trim();

      if (!task) {
        if (ctx.hasUI) {
          const inputTask = await ctx.ui.input(
            "RPI Workflow: Enter task description or issue",
            "e.g. Add OAuth2 login support with refresh tokens"
          );
          if (!inputTask || !inputTask.trim()) {
            ctx.ui.notify("RPI cancelled: No task provided", "warning");
            return;
          }
          task = inputTask.trim();
        } else {
          ctx.ui.notify("Please provide a task: /rpi <task description>", "error");
          return;
        }
      }

      const sm = RPIStateMachine.initNew(ctx.cwd, task);
      await executeWorkflowLoop(sm, ctx);
    },
  });

  pi.registerCommand("rpi-resume", {
    description: "Resume a paused or previous RPI workflow from .agents/thoughts/rpi/",
    handler: async (_args, ctx) => {
      const rpiBaseDir = path.join(ctx.cwd, ".agents", "thoughts", "rpi");
      if (!fs.existsSync(rpiBaseDir)) {
        ctx.ui.notify("No RPI sessions found in .agents/thoughts/rpi/", "warning");
        return;
      }

      const entries = fs.readdirSync(rpiBaseDir, { withFileTypes: true });
      const sessionDirs = entries
        .filter((e) => e.isDirectory())
        .map((e) => e.name)
        .reverse();

      if (sessionDirs.length === 0) {
        ctx.ui.notify("No RPI sessions found to resume.", "warning");
        return;
      }

      const sessionsWithState: Array<{ name: string; statePath: string; task: string; phase: string }> = [];

      for (const dirName of sessionDirs) {
        const statePath = path.join(rpiBaseDir, dirName, "state.json");
        if (fs.existsSync(statePath)) {
          try {
            const data = JSON.parse(fs.readFileSync(statePath, "utf-8")) as RPIState;
            sessionsWithState.push({
              name: dirName,
              statePath,
              task: data.task || dirName,
              phase: data.currentPhase || "unknown",
            });
          } catch {
            // ignore malformed
          }
        }
      }

      if (sessionsWithState.length === 0) {
        ctx.ui.notify("No active state.json found in RPI session directories.", "warning");
        return;
      }

      if (ctx.hasUI) {
        const options = sessionsWithState.map(
          (s) => `[${s.phase}] ${s.name} - ${s.task.slice(0, 40)}`
        );
        const selected = await ctx.ui.select("Select RPI Session to Resume", options);
        if (!selected) return;

        const idx = options.indexOf(selected);
        if (idx >= 0) {
          const target = sessionsWithState[idx];
          const sm = RPIStateMachine.load(ctx.cwd, target.statePath);
          if (sm) {
            sm.getState().status = "in_progress";
            sm.save();
            ctx.ui.notify(`Resuming RPI session: ${target.name}`, "info");
            await executeWorkflowLoop(sm, ctx);
          }
        }
      }
    },
  });

  pi.registerCommand("rpi-status", {
    description: "Display current RPI workflow status and progress",
    handler: async (_args, ctx) => {
      if (activeMachine) {
        const lines = activeMachine.renderProgressBar();
        ctx.ui.notify(lines.join("\n"), "info");
        updateUIWidget(ctx, activeMachine);
      } else {
        ctx.ui.notify("No active RPI workflow in this session. Start one with /rpi <task>", "info");
      }
    },
  });
}
