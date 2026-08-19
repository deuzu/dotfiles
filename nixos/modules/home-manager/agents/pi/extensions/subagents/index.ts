import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { runAgent } from "./rpi/index.ts";

export default function subagentsExtension(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task",
    label: "Task Subagent",
    description: "Launch a specialized subagent to handle a specific task (e.g. codebase-locator, codebase-analyzer, rpi-1-question, etc.)",
    parameters: {
      type: "object",
      properties: {
        subagent_type: {
          type: "string",
          description: "The subagent to use (e.g. codebase-locator, codebase-analyzer, rpi-2-research, etc.)",
        },
        prompt: {
          type: "string",
          description: "The detailed prompt/instructions for the subagent",
        },
        description: {
          type: "string",
          description: "Short description of the task",
        },
      },
      required: ["subagent_type", "prompt"],
    } as any,
    async execute(toolCallId, params: any, signal, onUpdate, ctx) {
      try {
        const output = await runAgent<string>(
          pi,
          ctx,
          params.subagent_type,
          params.prompt,
          {
            signal,
            onUpdate: (_chunk) => {
              // streaming update
            },
          }
        );
        return {
          content: [{ type: "text", text: output || "(No output from subagent)" }],
          details: { status: "completed" },
        };
      } catch (err) {
        const errMsg = err instanceof Error ? err.message : String(err);
        return {
          content: [{ type: "text", text: `Subagent failed: ${errMsg}` }],
          details: { error: errMsg, status: "failed" },
        };
      }
    },
  });
}
