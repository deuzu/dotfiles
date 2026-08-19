import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import {
  rpiCommandHandler,
  rpiStatusCommandHandler,
  rpiResumeCommandHandler,
} from "./commands.ts";
export * from "./types.ts";

export default function rpiWorkflowExtension(pi: ExtensionAPI) {
  pi.registerCommand("rpi", {
    description: "Start an interactive RPI workflow",
    handler: async (args: string, ctx: ExtensionContext) =>
      rpiCommandHandler(args, ctx),
  });

  pi.registerCommand("rpi-resume", {
    description:
      "Resume a paused or previous RPI workflow from the artifact directory",
    handler: async (_args: string, ctx: ExtensionContext) =>
      rpiResumeCommandHandler(ctx),
  });

  pi.registerCommand("rpi-status", {
    description: "Display current RPI workflow status and progress",
    handler: async (_args: string, ctx: ExtensionContext) =>
      rpiStatusCommandHandler(ctx),
  });
}
