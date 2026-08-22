import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import {
  saveBaselineTools,
  restoreBaselineTools,
  getReadOnlyTools,
  resetPlanState,
  DEFAULT_FALLBACK_TOOLS,
} from "./state.ts";
import { resolveAgentPrompt } from "./prompt.ts";

export const MODE_STATUS_KEY = "plan-mode";
export const PLAN_MODE_STATUS_KEY = MODE_STATUS_KEY;

export async function handleExploreCommand(
  args: string,
  ctx: ExtensionContext,
  pi: ExtensionAPI,
): Promise<void> {
  const currentTools = pi.getActiveTools();
  const explorePrompt = resolveAgentPrompt(ctx.cwd, "explore");
  if (!explorePrompt) {
    ctx.ui.notify(
      "Failed to resolve agent prompt for explore. Ensure explore.md exists.",
      "error",
    );
    return;
  }

  saveBaselineTools(currentTools, "explore", explorePrompt.allowedSubagents ?? null);

  const readOnlyTools = getReadOnlyTools(currentTools);
  pi.setActiveTools(readOnlyTools);

  pi.sendMessage({
    customType: "explore-mode-instruction",
    content: explorePrompt.body,
    display: true,
  });

  const statusText = ctx.ui.theme?.fg
    ? ctx.ui.theme.fg("accent", "Explore")
    : "Explore";
  ctx.ui.setStatus(MODE_STATUS_KEY, statusText);
  ctx.ui.notify(
    `Explore mode enabled: Read-only toolset active (${readOnlyTools.join(", ")})`,
    "info",
  );

  const task = args.trim();
  if (task.length > 0) {
    pi.sendUserMessage(task);
  }
}

export async function handlePlanCommand(
  args: string,
  ctx: ExtensionContext,
  pi: ExtensionAPI,
): Promise<void> {
  const currentTools = pi.getActiveTools();
  const planPrompt = resolveAgentPrompt(ctx.cwd, "plan");
  if (!planPrompt) {
    ctx.ui.notify(
      "Failed to resolve agent prompt for plan. Ensure plan.md exists.",
      "error",
    );
    return;
  }

  saveBaselineTools(currentTools, "plan", planPrompt.allowedSubagents ?? null);

  const readOnlyTools = getReadOnlyTools(currentTools);
  pi.setActiveTools(readOnlyTools);

  pi.sendMessage({
    customType: "plan-mode-instruction",
    content: planPrompt.body,
    display: true,
  });

  const statusText = ctx.ui.theme?.fg
    ? ctx.ui.theme.fg("accent", "Plan")
    : "Plan";
  ctx.ui.setStatus(MODE_STATUS_KEY, statusText);
  ctx.ui.notify(
    `Plan mode enabled: Read-only toolset active (${readOnlyTools.join(", ")})`,
    "info",
  );

  const task = args.trim();
  if (task.length > 0) {
    pi.sendUserMessage(task);
  }
}

export async function handleImplementCommand(
  args: string,
  ctx: ExtensionContext,
  pi: ExtensionAPI,
): Promise<void> {
  const implementPrompt = resolveAgentPrompt(ctx.cwd, "implement");
  if (!implementPrompt) {
    ctx.ui.notify(
      "Failed to resolve agent prompt for implement. Ensure implement.md exists.",
      "error",
    );
    return;
  }

  const restoredTools = restoreBaselineTools() ?? DEFAULT_FALLBACK_TOOLS;
  pi.setActiveTools(restoredTools);

  ctx.ui.setStatus(MODE_STATUS_KEY, undefined);

  pi.sendMessage({
    customType: "implement-mode-instruction",
    content: implementPrompt.body,
    display: true,
  });

  const taskMessage =
    args.trim() ||
    "Implement the approved plan phase by phase with verification checkpoints.";
  pi.sendUserMessage(taskMessage);

  resetPlanState();
  ctx.ui.notify(
    `Implementation mode enabled: Tools restored (${restoredTools.join(", ")})`,
    "info",
  );
}

