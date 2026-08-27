import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import type { ParsedAgentPrompt } from "./types.ts";

function parseListValue(rest: string): string[] | null {
  if (rest.startsWith("[") && rest.endsWith("]")) {
    return rest
      .slice(1, -1)
      .split(",")
      .map((s) => s.trim().replace(/^["']|["']$/g, ""))
      .filter(Boolean);
  }
  if (rest.length > 0) {
    return rest
      .split(",")
      .map((s) => s.trim().replace(/^["']|["']$/g, ""))
      .filter(Boolean);
  }
  return null;
}

/** Parse the frontmatter of an agent .md file. Supports `allowed_subagents`
 * (or `allowedSubagents`), `tools` (or `Tools`), and `model` (or `Model`) keys.
 * List keys support inline `[a, b]`, comma-separated, or YAML `- item` form;
 * `model` is a scalar (quotes stripped). Commented `# key:` lines are ignored. */
export function parseAgentFrontmatter(rawContent: string): {
  body: string;
  allowedSubagents?: string[];
  tools?: string[];
  model?: string;
} {
  if (!rawContent.startsWith("---")) {
    return { body: rawContent.trim() };
  }
  const endIndex = rawContent.indexOf("\n---", 3);
  if (endIndex === -1) {
    return { body: rawContent.trim() };
  }

  const frontmatterRaw = rawContent.slice(4, endIndex);
  const body = rawContent.slice(endIndex + 4).trim();
  const lines = frontmatterRaw.split(/\r?\n/);
  let allowedSubagents: string[] | undefined;
  let tools: string[] | undefined;
  let model: string | undefined;

  const listKeys: Array<{
    names: string[];
    assign: (value: string[]) => void;
  }> = [
    {
      names: ["allowed_subagents:", "allowedSubagents:"],
      assign: (value) => {
        allowedSubagents = value;
      },
    },
    {
      names: ["tools:", "Tools:"],
      assign: (value) => {
        tools = value;
      },
    },
  ];

  const scalarKeys: Array<{
    names: string[];
    assign: (value: string) => void;
  }> = [
    {
      names: ["model:", "Model:"],
      assign: (value) => {
        model = value;
      },
    },
  ];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    let matched = false;
    for (const key of listKeys) {
      if (!key.names.some((name) => line.startsWith(name))) {
        continue;
      }
      matched = true;
      const colonIndex = line.indexOf(":");
      const rest = line.slice(colonIndex + 1).trim();
      const inline = parseListValue(rest);
      if (inline) {
        key.assign(inline);
      } else {
        // YAML list form: key followed by `- item` lines
        const listItems: string[] = [];
        while (i + 1 < lines.length && lines[i + 1].trim().startsWith("-")) {
          i++;
          const item = lines[i]
            .trim()
            .slice(1)
            .trim()
            .replace(/^["']|["']$/g, "");
          if (item) listItems.push(item);
        }
        if (listItems.length > 0) {
          key.assign(listItems);
        }
      }
      break;
    }
    if (matched) {
      continue;
    }
    for (const key of scalarKeys) {
      if (!key.names.some((name) => line.startsWith(name))) {
        continue;
      }
      const colonIndex = line.indexOf(":");
      const value = line
        .slice(colonIndex + 1)
        .trim()
        .replace(/^["']|["']$/g, "");
      if (value) {
        key.assign(value);
      }
      break;
    }
  }

  return { body, allowedSubagents, tools, model };
}

export function parseFrontmatterBody(rawContent: string): string {
  return parseAgentFrontmatter(rawContent).body;
}

function getModuleDir(): string {
  try {
    return path.dirname(fileURLToPath(import.meta.url));
  } catch {
    return process.cwd();
  }
}

export function resolveAgentPrompt(
  cwd: string,
  agentName: string,
): ParsedAgentPrompt | null {
  const moduleDir = getModuleDir();
  const possiblePaths = [
    path.join(cwd, ".pi", "agents", `${agentName}.md`),
    path.join(cwd, ".agents", `${agentName}.md`),
    path.join(os.homedir(), ".pi", "agent", "agents", `${agentName}.md`),
    path.resolve(moduleDir, "../../agents", `${agentName}.md`),
    path.resolve(moduleDir, "../agents", `${agentName}.md`),
  ];

  for (const filePath of possiblePaths) {
    try {
      if (fs.existsSync(filePath)) {
        const content = fs.readFileSync(filePath, "utf-8");
        const { body, allowedSubagents, tools, model } =
          parseAgentFrontmatter(content);
        if (body.length > 0) {
          return {
            name: agentName,
            body,
            source: "file",
            allowedSubagents,
            tools,
            model,
          };
        }
      }
    } catch {
      // Continue searching next path
    }
  }

  return null;
}
