import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DENIED_COMMANDS = [
  /^env(\s+.*)?$/,
  /^ssh(\s+.*)?$/,
  /^sops(\s+.*)?$/,
  /^git-crypt(\s+.*)?$/,
  /^gpg(\s+.*)?$/,
  /^git\s+(add|commit|push)(\s+.*)?$/,
  /^terraform(\s+.*)?\s+(apply|destroy)(\s+.*)?$/,
];

const ASK_COMMANDS = [/^curl(\s+.*)?$/, /^terraform(\s+.*)?\s+state(\s+.*)?$/];

const SEPARATOR_RE = /\|\||&&|;|\||\r|\n|\$\(|`|\(/;

type CommandPermission = {
  permission: "deny" | "ask" | "allow";
  command: string;
  segments: string[];
};

export function extractCommands(command: string): string[] {
  return command
    .split(SEPARATOR_RE)
    .map((segment) =>
      segment
        .trim()
        .replace(/[)`'"]+$/, "")
        .replace(/^sudo\s+/, ""),
    )
    .filter(Boolean);
}

export function getCommandPermission(command: string): CommandPermission {
  const segments = extractCommands(command);

  const denyCommands = [];
  const askCommands = [];
  for (const segment of segments) {
    if (DENIED_COMMANDS.some((pattern) => pattern.test(segment))) {
      denyCommands.push(segment);
    }
    if (ASK_COMMANDS.some((pattern) => pattern.test(segment))) {
      askCommands.push(segment);
    }
  }
  if (denyCommands.length > 0) {
    return { permission: "deny", command, segments: denyCommands };
  }

  if (askCommands.length > 0) {
    return { permission: "ask", command, segments: askCommands };
  }

  return {
    permission: "allow",
    command,
    segments,
  };
}

export default function permissionsExtension(pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") {
      return;
    }

    const commandRaw = (
      (event.input as { command?: string }).command || ""
    ).trim();

    const { permission, command, segments } = getCommandPermission(commandRaw);

    if (permission === "deny") {
      return {
        block: true,
        reason: `Permission denied for command segments: ${segments.join(", ")}. Full command: ${command}`,
      };
    }

    if (permission === "ask") {
      const confirmed = ctx.hasUI && await ctx.ui.confirm(
        "Permissions Required",
        `Command: ${command}".\nSegments: \n-  ${segments.join("\n-  ")}.`,
      );

      if (!confirmed) {
        return {
          block: true,
          reason: `Permission rejected by user for command segments: ${segments.join(", ")}. Full command: ${command}`,
        };
      }
    }
  });
}
