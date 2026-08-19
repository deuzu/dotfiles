import * as path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { GateResult } from "./types.ts";
import type { RPIStateMachine } from "./state.ts";
import { runAgent } from "./runner.ts";
import { updateUIWidget, clearUIWidget } from "./ui.ts";
import { readArtifact } from "./workflow.ts";

export async function handleDesignGate(
  // pi: ExtensionAPI,
  ctx: ExtensionContext,
  sm: RPIStateMachine
): Promise<GateResult> {
  const state = sm.getState();
  const relArtifact = path.relative(ctx.cwd, state.artifactDir) || state.artifactDir;

  ctx.ui.setStatus("rpi", "RPI [🛑 Stop 1: Design Review] Waiting for user confirmation...");
  updateUIWidget(ctx, sm);

  const designQuestions = readArtifact(state.artifactDir, "design-questions.md");
  const designDoc = readArtifact(state.artifactDir, "design.md");

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
      return "proceed";
    } else if (selected === choices[1]) {
      const feedback = await ctx.ui.input(
        "Enter design answers or feedback:",
        "e.g. Prefer Option A for data model..."
      );
      if (feedback) {
        ctx.ui.setStatus("rpi", "Re-running Design phase with your feedback...");
        const prompt = `Artifact directory: ${state.artifactDir}\nUser Feedback on Design: ${feedback}\n\nUpdate design.md based on this user feedback.`;
        try {
          await runAgent(ctx, "rpi-3-design", prompt, {
            ownerRunId: state.id,
            nodeId: `design-refine-${Date.now()}`,
          });
          sm.recordPhaseCompletion("design_refinement", "design.md");
        } catch (err) {
          const errMsg = err instanceof Error ? err.message : String(err);
          ctx.ui.notify(`Design refinement failed: ${errMsg}`, "error");
        }
      }
      return "proceed";
    } else if (selected === choices[2]) {
      const content = designDoc || designQuestions || "(No design content found)";
      ctx.ui.notify(`Design Preview:\n\n${content.slice(0, 800)}...`, "info");
      return "proceed";
    } else if (selected === choices[3]) {
      ctx.ui.notify("Skipping directly to Planning...", "warning");
      state.currentPhase = "plan";
      sm.save();
      return "proceed";
    } else if (selected === choices[4]) {
      state.status = "paused";
      sm.save();
      ctx.ui.notify("RPI Workflow paused. Resume anytime with /rpi-resume", "info");
      return "paused";
    } else {
      state.status = "aborted";
      sm.save();
      clearUIWidget(ctx);
      ctx.ui.notify("RPI Workflow aborted.", "warning");
      return "aborted";
    }
  } else {
    state.currentPhase = "structure";
    sm.save();
    return "proceed";
  }
}

export async function handlePlanGate(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
  sm: RPIStateMachine
): Promise<GateResult> {
  const state = sm.getState();
  const relArtifact = path.relative(ctx.cwd, state.artifactDir) || state.artifactDir;

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
      return "proceed";
    } else if (selected === choices[1]) {
      const feedback = await ctx.ui.input(
        "Enter plan changes or feedback:",
        "e.g. Ensure we add unit tests for the token validator..."
      );
      if (feedback) {
        ctx.ui.setStatus("rpi", "Refining plan with your feedback...");
        const prompt = `Artifact directory: ${state.artifactDir}\nUser Feedback on Plan: ${feedback}\n\nUpdate plan.md based on this user feedback.`;
        try {
          await runAgent(ctx, "rpi-5-plan", prompt, {
            ownerRunId: state.id,
            nodeId: `plan-refine-${Date.now()}`,
          });
          sm.recordPhaseCompletion("plan_refinement", "plan.md");
        } catch (err) {
          const errMsg = err instanceof Error ? err.message : String(err);
          ctx.ui.notify(`Plan refinement failed: ${errMsg}`, "error");
        }
      }
      return "proceed";
    } else if (selected === choices[2]) {
      const content = planDoc || "(No plan content found)";
      ctx.ui.notify(`Plan Preview:\n\n${content.slice(0, 800)}...`, "info");
      return "proceed";
    } else if (selected === choices[4]) {
      state.status = "paused";
      sm.save();
      ctx.ui.notify("RPI Workflow paused. Resume anytime with /rpi-resume", "info");
      return "paused";
    } else {
      state.status = "aborted";
      sm.save();
      clearUIWidget(ctx);
      ctx.ui.notify("RPI Workflow aborted.", "warning");
      return "aborted";
    }
  } else {
    state.currentPhase = "implement";
    sm.save();
    return "proceed";
  }
}
