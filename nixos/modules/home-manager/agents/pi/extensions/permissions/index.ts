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

const ASK_COMMANDS = [
  /^curl(\s+.*)?$/,
  /^terraform(\s+.*)?\s+state(\s+.*)?$/,
];

export default function permissionsExtension(pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName === "bash") {
      const command = (
        (event.input as { command?: string }).command || ""
      ).trim();

      for (const pattern of DENIED_COMMANDS) {
        if (pattern.test(command)) {
          return {
            block: true,
            reason: `Permission denied for command: ${command}`,
          };
        }
      }

      for (const pattern of ASK_COMMANDS) {
        if (pattern.test(command)) {
          if (ctx.hasUI) {
            const confirmed = await ctx.ui.confirm(
              "Security Confirmation",
              `Permissions required for command: "${command}"?`,
            );
            if (!confirmed) {
              return {
                block: true,
                reason: `Permission rejected by user for command: ${command}`,
              };
            }
          }
        }
      }
    }
  });
}
