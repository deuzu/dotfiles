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
  manageArtifact,
  type ArtifactResult,
  type ManageArtifactParams,
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

const RpiArtifactParameters = Type.Object({
  action: Type.Union(
    [
      Type.Literal("create", {
        description:
          "Write a new artifact file. Fails if the file already exists.",
      }),
      Type.Literal("modify", {
        description:
          "Overwrite an existing artifact file with the full new content.",
      }),
      Type.Literal("delete", {
        description:
          "Delete an artifact file. Directories cannot be deleted.",
      }),
    ],
    { description: "Operation to perform on the artifact" },
  ),
  dir: Type.String({
    description:
      "Artifact session directory, e.g. .agents/thoughts/rpi/2026-07-12-brief-description. Must be under .agents/thoughts/rpi/.",
  }),
  path: Type.String({
    description:
      "Artifact file path, relative to dir (subdirectories allowed, e.g. plans/phase-1.md)",
  }),
  content: Type.Optional(
    Type.String({
      description: "Full file content (required for create and modify)",
    }),
  ),
});
type RpiArtifactParameters = Static<typeof RpiArtifactParameters>;

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

  pi.registerTool({
    name: "rpi_artifact",
    label: "Manage RPI Artifact",
    description:
      "Create, modify (overwrite), or delete artifact files inside an RPI workflow artifact directory (.agents/thoughts/rpi/)",
    promptSnippet:
      "Create, modify, or delete artifact files under .agents/thoughts/rpi/ for RPI workflow phases",
    promptGuidelines: [
      'Use rpi_artifact with action "create" to write new phase artifacts (questions.md, research.md, plan.md, ...) into the artifact directory.',
      'Use rpi_artifact with action "modify" to overwrite an existing artifact, and action "delete" to remove an artifact file.',
      "dir must be an RPI artifact directory under .agents/thoughts/rpi/; paths outside it are rejected. Directories cannot be deleted.",
    ],
    parameters: RpiArtifactParameters,
    async execute(
      _toolCallId: string,
      params: RpiArtifactParameters,
      _signal: AbortSignal | undefined,
      _onUpdate: AgentToolUpdateCallback | undefined,
      ctx: ExtensionContext,
    ): Promise<ArtifactResult> {
      return manageArtifact(params as ManageArtifactParams, ctx);
    },
  });
}
