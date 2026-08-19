import { spawn } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { ParsedAgentConfig, RunAgentOptions } from "./types.ts";

export function parseAgentFile(filePath: string): ParsedAgentConfig | null {
  if (!fs.existsSync(filePath)) return null;
  try {
    const content = fs.readFileSync(filePath, "utf-8");
    if (!content.startsWith("---")) {
      return { name: path.basename(filePath, ".md"), systemPrompt: content };
    }
    const endIndex = content.indexOf("\n---", 3);
    if (endIndex === -1) {
      return { name: path.basename(filePath, ".md"), systemPrompt: content };
    }
    const frontmatterRaw = content.slice(4, endIndex);
    const body = content.slice(endIndex + 4).trim();

    const lines = frontmatterRaw.split(/\r?\n/);
    let name = path.basename(filePath, ".md");
    let model: string | undefined;
    let thinkingLevel: string | undefined;
    let tools: string[] | undefined;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();
      if (line.startsWith("name:")) {
        name = line.slice(5).trim();
      } else if (line.startsWith("model:")) {
        const val = line.slice(6).trim().replace(/^["']|["']$/g, "");
        if (val && !val.startsWith("@")) model = val;
      } else if (line.startsWith("thinkingLevel:") || line.startsWith("thinking:")) {
        const val = line.split(":")[1].trim().replace(/^["']|["']$/g, "");
        if (val) thinkingLevel = val;
      } else if (line.startsWith("tools:")) {
        const rest = line.slice(6).trim();
        if (rest.startsWith("[") && rest.endsWith("]")) {
          tools = rest
            .slice(1, -1)
            .split(",")
            .map((t) => t.trim().replace(/^["']|["']$/g, ""))
            .filter(Boolean);
        } else if (rest.length > 0) {
          tools = rest
            .split(",")
            .map((t) => t.trim().replace(/^["']|["']$/g, ""))
            .filter(Boolean);
        } else {
          // Multiline YAML list
          const listItems: string[] = [];
          while (i + 1 < lines.length && lines[i + 1].trim().startsWith("-")) {
            i++;
            const item = lines[i].trim().slice(1).trim().replace(/^["']|["']$/g, "");
            if (item) listItems.push(item);
          }
          if (listItems.length > 0) {
            tools = listItems;
          }
        }
      }
    }

    return {
      name,
      model,
      thinkingLevel,
      tools,
      systemPrompt: body,
    };
  } catch {
    return null;
  }
}

export function resolveAgentConfig(cwd: string, agentName: string): ParsedAgentConfig {
  const possiblePaths = [
    path.join(cwd, ".pi", "agents", `${agentName}.md`),
    path.join(cwd, ".agents", `${agentName}.md`),
    path.join(os.homedir(), ".pi", "agent", "agents", `${agentName}.md`),
    path.resolve(__dirname, "../../agents", `${agentName}.md`),
    path.resolve(__dirname, "../agents", `${agentName}.md`),
  ];

  for (const p of possiblePaths) {
    const parsed = parseAgentFile(p);
    if (parsed) return parsed;
  }

  return {
    name: agentName,
    tools: [],
  };
}

export function runAgent<T = string>(
  // _pi: ExtensionAPI,
  ctxOrCwd: ExtensionContext | string,
  agent: string,
  task: string,
  optionsOrSchema?: RunAgentOptions | Record<string, unknown>
): Promise<T> {
  const cwd = typeof ctxOrCwd === "string" ? ctxOrCwd : ctxOrCwd.cwd;
  const options: RunAgentOptions =
    optionsOrSchema &&
    ("ownerRunId" in optionsOrSchema ||
      "nodeId" in optionsOrSchema ||
      "schema" in optionsOrSchema ||
      "onUpdate" in optionsOrSchema ||
      "signal" in optionsOrSchema ||
      "timeoutMs" in optionsOrSchema)
      ? (optionsOrSchema as RunAgentOptions)
      : optionsOrSchema
      ? { schema: optionsOrSchema as Record<string, unknown> }
      : {};

  const agentConfig = resolveAgentConfig(cwd, agent);
  const tempFiles: string[] = [];

  return new Promise<T>((resolve, reject) => {
    const args: string[] = [
      "--print",
      "--mode",
      "json",
      "--no-session",
      "--no-context-files",
      "--no-skills",
    ];

    if (agentConfig.model) {
      args.push("--model", agentConfig.model);
    }
    if (agentConfig.thinkingLevel) {
      args.push("--thinking", agentConfig.thinkingLevel);
    }

    const tools =
      agentConfig.tools && agentConfig.tools.length > 0
        ? agentConfig.tools.join(",")
        : "read,write,edit,bash";
    args.push("--tools", tools);

    if (agentConfig.systemPrompt) {
      const tempPromptFile = path.join(
        os.tmpdir(),
        `pi-rpi-agent-${Date.now()}-${Math.random().toString(36).slice(2, 6)}.md`
      );
      fs.writeFileSync(tempPromptFile, agentConfig.systemPrompt, "utf-8");
      tempFiles.push(tempPromptFile);
      args.push("--append-system-prompt", tempPromptFile);
    }

    args.push(task);

    const cleanup = () => {
      for (const f of tempFiles) {
        try {
          if (fs.existsSync(f)) fs.unlinkSync(f);
        } catch {
          // ignore
        }
      }
    };

    let child: ReturnType<typeof spawn>;
    try {
      child = spawn("pi", args, {
        cwd,
        env: process.env,
        stdio: ["ignore", "pipe", "pipe"],
      });
    } catch (err) {
      cleanup();
      return reject(err);
    }

    let stdoutBuffer = "";
    let stderrBuffer = "";
    let latestOutput = "";
    let isSettled = false;

    const timeoutDuration = options.timeoutMs ?? 600000;
    const timer = setTimeout(() => {
      if (!isSettled) {
        isSettled = true;
        child.kill("SIGTERM");
        setTimeout(() => child.kill("SIGKILL"), 3000);
        cleanup();
        reject(new Error(`Agent ${agent} timed out after ${timeoutDuration}ms`));
      }
    }, timeoutDuration);

    if (options.signal) {
      options.signal.addEventListener(
        "abort",
        () => {
          if (!isSettled) {
            isSettled = true;
            clearTimeout(timer);
            child.kill("SIGTERM");
            setTimeout(() => child.kill("SIGKILL"), 2000);
            cleanup();
            reject(new Error("Subagent execution aborted"));
          }
        },
        { once: true }
      );
    }

    child.stdout.on("data", (chunk: Buffer) => {
      stdoutBuffer += chunk.toString("utf-8");
      const lines = stdoutBuffer.split("\n");
      stdoutBuffer = lines.pop() ?? "";

      for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed) continue;
        try {
          const event = JSON.parse(trimmed);
          if (event.type === "message_update" && event.assistantMessageEvent?.type === "text_delta") {
            const delta = event.assistantMessageEvent.delta || "";
            if (delta) options.onUpdate?.(delta);
          } else if (event.type === "turn_end" && event.message?.content) {
            const textParts = (event.message.content as Array<{ type: string; text?: string }>)
              .filter((p) => p.type === "text" && p.text)
              .map((p) => p.text!);
            if (textParts.length > 0) latestOutput = textParts.join("\n");
          } else if (event.type === "agent_end" && Array.isArray(event.messages)) {
            const assistantMsgs = event.messages.filter((m: { role: string }) => m.role === "assistant");
            if (assistantMsgs.length > 0) {
              const lastMsg = assistantMsgs[assistantMsgs.length - 1];
              if (Array.isArray(lastMsg.content)) {
                const textParts = lastMsg.content
                  .filter((p: { type: string; text?: string }) => p.type === "text" && p.text)
                  .map((p: { text: string }) => p.text);
                if (textParts.length > 0) latestOutput = textParts.join("\n");
              }
            }
          }
        } catch {
          // ignore malformed line
        }
      }
    });

    child.stderr.on("data", (chunk: Buffer) => {
      stderrBuffer += chunk.toString("utf-8");
    });

    child.on("error", (err) => {
      if (!isSettled) {
        isSettled = true;
        clearTimeout(timer);
        cleanup();
        reject(err);
      }
    });

    child.on("close", (code) => {
      if (isSettled) return;
      isSettled = true;
      clearTimeout(timer);
      cleanup();

      if (code === 0) {
        if (options.schema) {
          try {
            const json = JSON.parse(latestOutput);
            resolve(json as T);
          } catch {
            resolve(latestOutput as unknown as T);
          }
        } else {
          resolve(latestOutput as unknown as T);
        }
      } else {
        const errDetails = stderrBuffer.trim() || latestOutput.trim() || `Exit code ${code}`;
        reject(new Error(`Agent ${agent} failed (code ${code}): ${errDetails}`));
      }
    });
  });
}
