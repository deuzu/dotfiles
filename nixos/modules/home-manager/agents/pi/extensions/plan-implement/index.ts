import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { isAbsolute, relative, resolve } from "node:path";
import {
  handleExploreCommand,
  handlePlanCommand,
  handlePlanLiteCommand,
  handleDesignCommand,
  handleImplementCommand,
  MODE_STATUS_KEY,
} from "./commands.ts";
import { getPlanState, resetSessionState } from "./state.ts";

export * from "./types.ts";
export * from "./state.ts";
export * from "./prompt.ts";
export * from "./commands.ts";

/** Directory (relative to the project cwd) that planning modes may manage files in. */
export const THOUGHTS_DIR = ".agents/thoughts";

/** True when target (relative or absolute) resolves inside <cwd>/.agents/thoughts/.
 * Lexical containment: survives `..` traversal and absolute paths outside the root;
 * does not resolve symlinks. */
export function isInsideThoughts(cwd: string, target: string): boolean {
  const root = resolve(cwd, THOUGHTS_DIR);
  const abs = resolve(cwd, target);
  const rel = relative(root, abs);
  return rel === "" || (!rel.startsWith("..") && !isAbsolute(rel));
}

export default function planImplementExtension(pi: ExtensionAPI): void {
  pi.on("session_start", async (event, ctx) => {
    if (event.reason !== "new") {
      return;
    }

    resetSessionState();
    ctx.ui.setStatus(MODE_STATUS_KEY, undefined);
  });

  pi.on("tool_call", async (event, ctx) => {
    const state = getPlanState();
    if (!state.isPlanModeActive) {
      return;
    }

    const modeLabel = state.activeMode ?? "explore";
    const toolName = event.toolName.toLowerCase();

    if (toolName === "agent") {
      if (state.allowedSubagents) {
        const input = event.input as { subagent_type?: string };
        const requestedSubagent = input?.subagent_type;

        if (
          requestedSubagent &&
          !state.allowedSubagents.includes(requestedSubagent)
        ) {
          return {
            block: true,
            reason: `Subagent type "${requestedSubagent}" is not allowed during ${modeLabel} mode. Allowed subagents: ${state.allowedSubagents.join(", ")}`,
          };
        }
      }
      return;
    }

    if (toolName === "write" || toolName === "edit") {
      const target = (event.input as { path?: string }).path ?? "";
      if (!isInsideThoughts(ctx.cwd, target)) {
        return {
          block: true,
          reason:
            `${modeLabel} mode restricts file management (write/edit) to ${THOUGHTS_DIR}/ ` +
            `under ${ctx.cwd}. Requested path: ${target}. ` +
            `Write your plans, notes, and artifacts under .agents/thoughts/ instead.`,
        };
      }
      return;
    }

    if (
      state.allowedTools &&
      !state.allowedTools.some((tool) => tool.toLowerCase() === toolName)
    ) {
      return {
        block: true,
        reason: `Tool "${event.toolName}" is not allowed during ${modeLabel} mode. Allowed tools: ${state.allowedTools.join(", ")}`,
      };
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

  pi.registerCommand("plan-lite", {
    description: "Switch to read-only planning mode and load simple planning instructions",
    handler: async (args: string, ctx: ExtensionContext) => {
      await handlePlanLiteCommand(args, ctx, pi);
    },
  });

  pi.registerCommand("design", {
    description: "Switch to interactive architecture-decision mode and iterate with the user on the best solution",
    handler: async (args: string, ctx: ExtensionContext) => {
      await handleDesignCommand(args, ctx, pi);
    },
  });

  pi.registerCommand("implement", {
    description: "Restore tools and begin phase-by-phase implementation of the plan",
    handler: async (args: string, ctx: ExtensionContext) => {
      await handleImplementCommand(args, ctx, pi);
    },
  });
}

