import type {
  AgentToolResult,
  AgentToolUpdateCallback,
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Type, type Static } from "typebox";
import {
  rpiCommandHandler,
  rpiStatusCommandHandler,
  rpiResumeCommandHandler,
  rpiAgentCommandHandler,
} from "./commands.ts";
import {
  createArtifactDirectory,
  type CreateArtifactDirectoryResult,
} from "./tools.ts";

export * from "./types.ts";
export * from "./tools.ts";

const CreateArtifactDirParameters = Type.Object({
  path: Type.String({
    description:
      "Relative or absolute directory path to create for RPI artifacts",
  }),
});
type CreateArtifactDirParameters = Static<typeof CreateArtifactDirParameters>;

export default function rpiWorkflowExtension(pi: ExtensionAPI) {
  pi.registerCommand("rpi-agent", {
    description: "Add RPI Orchestrator instructions",
    handler: async (_args: string, ctx: ExtensionContext) => {
      await rpiAgentCommandHandler(pi, ctx);
    },
  });

  pi.registerCommand("rpi-workflow", {
    description: "Start an interactive RPI workflow",
    handler: async (args: string, ctx: ExtensionContext) =>
      await rpiCommandHandler(args, ctx),
  });

  pi.registerCommand("rpi-workflow-resume", {
    description:
      "Resume a paused or previous RPI workflow from the artifact directory",
    handler: async (_args: string, ctx: ExtensionContext) =>
      await rpiResumeCommandHandler(ctx),
  });

  pi.registerCommand("rpi-workflow-status", {
    description: "Display current RPI workflow status and progress",
    handler: async (_args: string, ctx: ExtensionContext) =>
      rpiStatusCommandHandler(ctx),
  });

  pi.registerTool({
    name: "create_artifact_dir",
    label: "Create Artifact Directory",
    description:
      "Create an artifact directory recursively under .agents/thoughts/rpi/ for an RPI workflow session",
    promptSnippet:
      "Create an artifact directory recursively under .agents/thoughts/rpi/ for storing workflow phase artifacts",
    promptGuidelines: [
      "Use create_artifact_dir to initialize the artifact directory before running phase subagents.",
    ],
    parameters: CreateArtifactDirParameters,
    async execute(
      _toolCallId: string,
      params: CreateArtifactDirParameters,
      _signal: AbortSignal | undefined,
      _onUpdate: AgentToolUpdateCallback | undefined,
      ctx: ExtensionContext,
    ): Promise<CreateArtifactDirectoryResult> {
      return createArtifactDirectory(params.path, ctx);
    },
  });
}
