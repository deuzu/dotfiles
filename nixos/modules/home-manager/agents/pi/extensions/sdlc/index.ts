import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { resolveAgentConfig } from "./runner.ts";

export async function sdlcAgentCommandHandler(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
): Promise<void> {
  const config = resolveAgentConfig(ctx.cwd, "sdlc");
  if (!config.systemPrompt || !config.tools || config.tools.length === 0) {
    ctx.ui.notify("Could not load sdlc.md instructions and tools", "error");

    return;
  }

  pi.setActiveTools(config.tools);

  pi.sendMessage({
    customType: "sdlc-agent-instruction",
    content: config.systemPrompt,
    display: true,
  });

  const statusText = ctx.ui.theme?.fg
    ? ctx.ui.theme.fg("accent", "SDLC Agent")
    : "SDLC Agent";
  ctx.ui.setStatus("SDLC Agent", statusText);
  ctx.ui.notify("SDLC Agent instructions added to session", "info");
}

export default function sdlcExtension(pi: ExtensionAPI) {
  pi.registerCommand("sdlc-agent", {
    description: "Add SDLC Orchestrator instructions",
    handler: async (_args: string, ctx: ExtensionContext) => {
      await sdlcAgentCommandHandler(pi, ctx);
    },
  });
}
