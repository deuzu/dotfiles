import { spawn } from "child_process";
import * as fs from "fs";
import * as path from "path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

interface SubagentConfig {
  name: string;
  description?: string;
  tools?: string;
  model?: string;
  thinking?: string;
  systemPrompt?: string;
}

function parseAgentFile(filePath: string): { config: SubagentConfig; body: string } | null {
  if (!fs.existsSync(filePath)) return null;
  const content = fs.readFileSync(filePath, "utf-8");
  if (!content.startsWith("---")) {
    return { config: { name: path.basename(filePath, ".md") }, body: content };
  }
  const parts = content.split("---");
  if (parts.length < 3) {
    return { config: { name: path.basename(filePath, ".md") }, body: content };
  }
  const frontmatter = parts[1];
  const body = parts.slice(2).join("---").trim();

  const config: Record<string, string> = {};
  for (const line of frontmatter.split("\n")) {
    const colonIdx = line.indexOf(":");
    if (colonIdx > 0) {
      const key = line.slice(0, colonIdx).trim();
      const val = line.slice(colonIdx + 1).trim().replace(/^['"]|['"]$/g, "");
      config[key] = val;
    }
  }

  return {
    config: {
      name: config.name || path.basename(filePath, ".md"),
      description: config.description,
      tools: config.tools,
      model: config.model,
      thinking: config.thinking,
      systemPrompt: config.systemPrompt,
    },
    body,
  };
}

function findAgent(agentName: string, cwd: string): { config: SubagentConfig; body: string } | null {
  const agentDir = process.env.PI_CODING_AGENT_DIR || path.join(process.env.HOME || "", ".pi/agent");
  const candidates = [
    path.join(cwd, ".pi/agents", `${agentName}.md`),
    path.join(agentDir, "agents", `${agentName}.md`),
  ];

  for (const p of candidates) {
    const res = parseAgentFile(p);
    if (res) return res;
  }
  return null;
}

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
      const agent = findAgent(params.subagent_type, ctx.cwd);
      const args: string[] = ["-p", "--no-session"];

      if (agent) {
        if (agent.config.tools) {
          args.push("--tools", agent.config.tools);
        }
        if (agent.config.model) {
          args.push("--model", agent.config.model);
        }
        if (agent.config.thinking) {
          args.push("--thinking", agent.config.thinking);
        }
        if (agent.body) {
          args.push("--system-prompt", agent.body);
        }
      }

      args.push(params.prompt);

      return new Promise((resolve) => {
        const proc = spawn("pi", args, {
          cwd: ctx.cwd,
          env: {
            ...process.env,
            PI_OFFLINE: "1",
            PI_TELEMETRY: "0",
            PI_SKIP_VERSION_CHECK: "1",
          },
        });

        let stdout = "";
        let stderr = "";

        proc.stdout.on("data", (chunk) => {
          stdout += chunk.toString();
          onUpdate?.({
            content: [{ type: "text", text: stdout }],
            details: {},
          });
        });

        proc.stderr.on("data", (chunk) => {
          stderr += chunk.toString();
        });

        proc.on("close", (code) => {
          if (code !== 0 && !stdout) {
            resolve({
              content: [{ type: "text", text: `Subagent failed with exit code ${code}: ${stderr}` }],
              details: { error: stderr, code },
            });
          } else {
            resolve({
              content: [{ type: "text", text: stdout || "(No output from subagent)" }],
              details: { code },
            });
          }
        });

        signal?.addEventListener("abort", () => {
          proc.kill("SIGTERM");
        });
      });
    },
  });
}
