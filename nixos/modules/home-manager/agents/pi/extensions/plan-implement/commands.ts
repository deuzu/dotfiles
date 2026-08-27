import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import {
  saveBaselineTools,
  restoreBaselineTools,
  resetPlanState,
} from "./state.ts";
import { resolveAgentPrompt } from "./prompt.ts";

export const MODE_STATUS_KEY = "plan-mode";
export const PLAN_MODE_STATUS_KEY = MODE_STATUS_KEY;

/** Resolve and apply the model declared in an agent .md file.
 * Returns true when the mode switch may proceed (no model declared,
 * or model resolved and set). Returns false after notifying the user
 * of the failure — the caller must abort the mode switch. */
async function applyDeclaredModel(
  ctx: ExtensionContext,
  pi: ExtensionAPI,
  modeLabel: string,
  modelId: string | undefined,
): Promise<boolean> {
  if (!modelId) {
    return true;
  }

  const registry = ctx.modelRegistry;
  let model = undefined;
  const slashIndex = modelId.indexOf("/");
  if (slashIndex > 0) {
    model = registry.find(
      modelId.slice(0, slashIndex),
      modelId.slice(slashIndex + 1),
    );
  }
  if (!model) {
    // Bare model id without provider — search all available models.
    model = registry
      .getAvailable()
      .find((m) => m.id === modelId || `${m.provider}/${m.id}` === modelId);
  }

  if (!model) {
    ctx.ui.notify(
      `Model "${modelId}" declared in the ${modeLabel} agent file could not be resolved. ${modeLabel} mode not activated.`,
      "error",
    );
    return false;
  }

  const ok = await pi.setModel(model);
  if (!ok) {
    ctx.ui.notify(
      `No API key available for model "${modelId}" declared in the ${modeLabel} agent file. ${modeLabel} mode not activated.`,
      "error",
    );
    return false;
  }
  return true;
}

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
  if (!explorePrompt.tools || explorePrompt.tools.length === 0) {
    ctx.ui.notify(
      "Agent prompt for explore must declare a tools: frontmatter list.",
      "error",
    );
    return;
  }
  if (!(await applyDeclaredModel(ctx, pi, "Explore", explorePrompt.model))) {
    return;
  }

  saveBaselineTools(
    currentTools,
    "explore",
    explorePrompt.allowedSubagents ?? null,
    explorePrompt.tools,
  );

  const readOnlyTools = explorePrompt.tools;
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
    `Explore mode enabled: Read-only toolset active (${readOnlyTools.join(", ")})${explorePrompt.model ? `, model ${explorePrompt.model}` : ""}`,
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
  if (!planPrompt.tools || planPrompt.tools.length === 0) {
    ctx.ui.notify(
      "Agent prompt for plan must declare a tools: frontmatter list.",
      "error",
    );
    return;
  }
  if (!(await applyDeclaredModel(ctx, pi, "Plan", planPrompt.model))) {
    return;
  }

  saveBaselineTools(
    currentTools,
    "plan",
    planPrompt.allowedSubagents ?? null,
    planPrompt.tools,
  );

  const readOnlyTools = planPrompt.tools;
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
    `Plan mode enabled: Read-only toolset active (${readOnlyTools.join(", ")})${planPrompt.model ? `, model ${planPrompt.model}` : ""}`,
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
  if (
    !(await applyDeclaredModel(ctx, pi, "Implement", implementPrompt.model))
  ) {
    return;
  }

  const restoredTools = restoreBaselineTools();
  if (restoredTools) {
    pi.setActiveTools(restoredTools);
  }

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
    restoredTools
      ? `Implementation mode enabled: Tools restored (${restoredTools.join(", ")})`
      : "Implementation mode enabled: Tools unchanged (no baseline to restore)",
    "info",
  );
}

