import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

export interface ParsedAgentConfig {
  name: string;
  model?: string;
  thinkingLevel?: string;
  tools?: string[];
  systemPrompt?: string;
}

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
        let rest = line.slice(6).trim();
        const isBracketed = rest.startsWith("[");
        if (isBracketed && rest.endsWith("]")) {
          tools = rest
            .slice(1, -1)
            .split(",")
            .map((t) => t.trim().replace(/^["']|["']$/g, ""))
            .filter(Boolean);
        } else {
          // Multi-line list: bracketed across lines or YAML dash list.
          if (isBracketed) rest = rest.slice(1).trim();

          const addItems = (s: string): void => {
            for (const t of s.split(",")) {
              const item = t.trim().replace(/^["']|["']$/g, "");
              if (item) listItems.push(item);
            }
          };
          const listItems: string[] = [];
          if (rest) addItems(rest);

          while (i + 1 < lines.length) {
            i++;
            const raw = lines[i].trim().replace(/^\[/, "").replace(/\]$/, "");
            if (raw === "" ) { if (lines[i].trim() === "]") break; continue; }
            if (raw.startsWith("-")) {
              const item = raw
                .slice(1)
                .trim()
                .replace(/^["']|["']$/g, "");
              if (item) listItems.push(item);
            } else {
              addItems(raw);
              if (lines[i].trim().includes("]")) break;
            }
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

export function resolveAgentConfig(
  cwd: string,
  agentName: string,
): ParsedAgentConfig {
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
