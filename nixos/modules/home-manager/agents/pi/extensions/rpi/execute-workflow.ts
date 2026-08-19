import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { RPIStateMachine } from "./state.ts";
import { runAgent } from "./runner.ts";
import { updateUIWidget } from "./ui.ts";
import { handleDesignGate, handlePlanGate } from "./gates.ts";

export function readArtifact(artifactDir: string, fileName: string): string | null {
  const filePath = path.join(artifactDir, fileName);
  if (fs.existsSync(filePath)) {
    return fs.readFileSync(filePath, "utf-8");
  }
  return null;
}

export async function executeWorkflowLoop(
  sm: RPIStateMachine,
  ctx: ExtensionContext,
  onActiveChange?: (sm: RPIStateMachine | null) => void
): Promise<void> {
  onActiveChange?.(sm);
  const state = sm.getState();
  const relArtifact = path.relative(ctx.cwd, state.artifactDir) || state.artifactDir;

  while (state.status === "in_progress") {
    updateUIWidget(ctx, sm);

    switch (state.currentPhase) {
      // ==========================================
      // PHASE 1: QUESTION (Auto-advances)
      // ==========================================
      case "question": {
        ctx.ui.setStatus("rpi", "RPI [1/6 Question] ⏳ Decomposing task...");
        ctx.ui.notify("Phase 1: Decomposing task into neutral research questions...", "info");

        const prompt = `Task: ${state.task}\nArtifact directory: ${state.artifactDir}.`;
        try {
          await runAgent(ctx, "rpi-1-question", prompt, {
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

        const prompt = `Artifact directory: ${state.artifactDir}.`;
        try {
          await runAgent(ctx, "rpi-2-research", prompt, {
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
      case "design-questions": {
        ctx.ui.setStatus("rpi", "RPI [3/6 Design] ⏳ Formulating architecture...");
        ctx.ui.notify("Phase 3: Formulating design decisions and architectural options...", "info");

        const prompt = `Artifact directory: ${state.artifactDir}.`;
        try {
          await runAgent(ctx, "rpi-3-design", prompt, {
            ownerRunId: state.id,
            nodeId: `design-${Date.now()}`,
          });
          sm.recordPhaseCompletion("design-questions", "design-questions.md");
          state.currentPhase = "design";
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
      case "design": {
        const result = await handleDesignGate(ctx, sm);
        if (result !== "proceed") {
          return;
        }
        break;
      }

      case "design": {
        ctx.ui.setStatus("rpi", "RPI [3/6 Design] ⏳ Formulating architecture...");
        ctx.ui.notify("Phase 3: Formulating design decisions and architectural options...", "info");

        const prompt = `todo responses.\nArtifact directory: ${state.artifactDir}.`;
        try {
          await runAgent(ctx, "rpi-3-design", prompt, {
            ownerRunId: state.id,
            nodeId: `design-${Date.now()}`,
          });
          sm.recordPhaseCompletion("design", "design.md");
          state.currentPhase = "structure";
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
      // PHASE 4: STRUCTURE (Auto-advances)
      // ==========================================
      case "structure": {
        ctx.ui.setStatus("rpi", "RPI [4/6 Structure] ⏳ Outlining vertical slices...");
        ctx.ui.notify("Phase 4: Outlining component structure and test checkpoints...", "info");

        const prompt = `Artifact directory: ${state.artifactDir}\n\nExecute Phase 4: Read design.md and research.md. Create vertical slices and structure.md.`;
        try {
          await runAgent(ctx, "rpi-4-structure", prompt, {
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

        const prompt = `Artifact directory: ${state.artifactDir}.`;
        try {
          await runAgent(ctx, "rpi-5-plan", prompt, {
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
        const result = await handlePlanGate(pi, ctx, sm);
        if (result !== "proceed") {
          return;
        }
        break;
      }

      // ==========================================
      // PHASE 7: IMPLEMENTATION (Executes and STOP 3)
      // ==========================================
      case "implement": {
        ctx.ui.setStatus("rpi", "RPI [6/6 Implement] ⏳ Executing plan...");
        ctx.ui.notify("Phase 7: Executing implementation plan step-by-step...", "info");

        const prompt = `Artifact directory: ${state.artifactDir}.`;
        try {
          await runAgent(ctx, "rpi-7-implement", prompt, {
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
