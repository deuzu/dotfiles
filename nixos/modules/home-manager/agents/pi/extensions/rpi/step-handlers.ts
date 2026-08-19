import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { RPIWorkflow } from "./workflow";
import { runAgent } from "./runner";

export default (ctx: ExtensionContext) => ({
  init: async (workflow: RPIWorkflow) => {
    fs.mkdirSync(workflow.getArtifactsDirectory(), { recursive: true });

    const workflowFile = path.join(
      workflow.getArtifactsDirectory(),
      "workflow.json",
    );
    fs.writeFileSync(workflowFile, JSON.stringify(workflow, null, 2), "utf-8");
  },
  question: async (workflow: RPIWorkflow) => {
    ctx.ui.notify("Step 1 Question in progress...", "info");

    const step = workflow.getCurrentStep();
    const agent = step.agent;

    if (agent === undefined) {
      // notify error

      return;
    }

    try {
      await runAgent(ctx, agent.name, agent.prompt, agent.sessionId);
      // set progress bar widget
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : String(err);
      workflow.setError(errMsg);
      ctx.ui.notify(`Step 1 Question subagent failed: ${errMsg}`, "error");

      return;
    }
  },
  research: async (workflow: RPIWorkflow) => {
    ctx.ui.notify("Step 2 Research in progress...", "info");

    const step = workflow.getCurrentStep();
    const agent = step.agent;

    if (agent === undefined) {
      // notify error

      return;
    }

    try {
      await runAgent(ctx, agent.name, agent.prompt, agent.sessionId);
      // set progress bar widget
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : String(err);
      workflow.setError(errMsg);
      ctx.ui.notify(`Step 2 Research subagent failed: ${errMsg}`, "error");

      return;
    }
  },
});
