import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import type { ParsedAgentPrompt } from "./types.ts";

export function parseAgentFrontmatter(rawContent: string): {
  body: string;
  allowedSubagents?: string[];
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

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (
      line.startsWith("allowed_subagents:") ||
      line.startsWith("allowedSubagents:")
    ) {
      const colonIndex = line.indexOf(":");
      const rest = line.slice(colonIndex + 1).trim();
      if (rest.startsWith("[") && rest.endsWith("]")) {
        allowedSubagents = rest
          .slice(1, -1)
          .split(",")
          .map((s) => s.trim().replace(/^["']|["']$/g, ""))
          .filter(Boolean);
      } else if (rest.length > 0) {
        allowedSubagents = rest
          .split(",")
          .map((s) => s.trim().replace(/^["']|["']$/g, ""))
          .filter(Boolean);
      } else {
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
          allowedSubagents = listItems;
        }
      }
    }
  }

  return { body, allowedSubagents };
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
        const { body, allowedSubagents } = parseAgentFrontmatter(content);
        if (body.length > 0) {
          return {
            name: agentName,
            body,
            source: "file",
            allowedSubagents,
          };
        }
      }
    } catch {
      // Continue searching next path
    }
  }

  return null;
}
