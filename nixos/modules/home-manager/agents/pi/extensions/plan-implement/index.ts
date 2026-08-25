import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import {
  handleExploreCommand,
  handlePlanCommand,
  handleImplementCommand,
} from "./commands.ts";
import { getPlanState } from "./state.ts";

export * from "./types.ts";
export * from "./state.ts";
export * from "./prompt.ts";
export * from "./commands.ts";

export default function planImplementExtension(pi: ExtensionAPI): void {
  pi.on("tool_call", async (event) => {
    const state = getPlanState();
    if (!state.isPlanModeActive || !state.allowedSubagents) {
      return;
    }

    if (event.toolName.toLowerCase() === "agent") {
      const input = event.input as { subagent_type?: string };
      const requestedSubagent = input?.subagent_type;

      if (
        requestedSubagent &&
        !state.allowedSubagents.includes(requestedSubagent)
      ) {
        const modeLabel = state.activeMode === "plan" ? "plan" : "explore";
        return {
          block: true,
          reason: `Subagent type "${requestedSubagent}" is not allowed during ${modeLabel} mode. Allowed subagents: ${state.allowedSubagents.join(", ")}`,
        };
      }
    }
  });

  pi.registerCommand("explore", {
    description: "Switch to read-only exploration mode and load code exploration instructions",
    handler: async (args: string, ctx: ExtensionContext) => {
      await handleExploreCommand(args, ctx, pi);
    },
  });

  pi.registerCommand("plan", {
    description: "Switch to read-only planning mode and load tactical planning instructions",
    handler: async (args: string, ctx: ExtensionContext) => {
      await handlePlanCommand(args, ctx, pi);
    },
  });

  pi.registerCommand("implement", {
    description: "Restore tools and begin phase-by-phase implementation of the plan",
    handler: async (args: string, ctx: ExtensionContext) => {
      await handleImplementCommand(args, ctx, pi);
    },
  });
}

