import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import { RPIWorkflow } from "./workflow.ts";
import stepHandlers from "./step-handlers.ts";

export async function rpiCommandHandler(args: string, ctx: ExtensionContext): Promise<void> {
  let task = (args || "").trim();

  if (!task && !ctx.hasUI) {
    ctx.ui.notify("Please provide a task: /rpi <task description>", "error");

    return;
  }

  if (!task && ctx.hasUI) {
    const inputTask = await ctx.ui.input(
      "RPI Workflow: Enter task description or issue",
    );

    if (!inputTask?.trim()) {
      ctx.ui.notify("RPI cancelled: No task provided", "warning");

      return;
    }

    task = inputTask.trim();
  }

  const artifactsDirectory = path.join(
    ctx.cwd,
    ".agents",
    "thoughts",
    "rpi",
    crypto.randomUUID(),
  );
  const workflow = RPIWorkflow.init(
    task,
    stepHandlers(ctx),
    artifactsDirectory,
  );
  await workflow.start();
}

export async function rpiResumeCommandHandler(ctx: ExtensionContext): Promise<void> {
  // const rpiBaseDir = path.join(ctx.cwd, ".agents", "thoughts", "rpi");
  // if (!fs.existsSync(rpiBaseDir)) {
  //   ctx.ui.notify(
  //     "RPI artifact directory not found at .agents/thoughts/rpi/",
  //     "warning",
  //   );

  //   return;
  // }

  // const entries = fs.readdirSync(rpiBaseDir, { withFileTypes: true });
  // const sessionDirs = entries
  //   .filter((e) => e.isDirectory())
  //   .map((e) => e.name)
  //   .reverse();

  // if (sessionDirs.length === 0) {
  //   ctx.ui.notify("No RPI sessions found at .agents/thoughts/rpi/", "warning");

  //   return;
  // }

  // const sessionsWithState: Array<{
  //   name: string;
  //   statePath: string;
  //   task: string;
  //   phase: string;
  // }> = [];

  // for (const dirName of sessionDirs) {
  //   const statePath = path.join(rpiBaseDir, dirName, "state.json");
  //   if (fs.existsSync(statePath)) {
  //     try {
  //       const data = JSON.parse(
  //         fs.readFileSync(statePath, "utf-8"),
  //       ) as RPIState;
  //       sessionsWithState.push({
  //         name: dirName,
  //         statePath,
  //         task: data.task || dirName,
  //         phase: data.currentPhase || "unknown",
  //       });
  //     } catch {
  //       // ignore malformed
  //     }
  //   }
  // }

  // if (sessionsWithState.length === 0) {
  //   ctx.ui.notify(
  //     "No active state.json found in RPI artifact directories.",
  //     "warning",
  //   );

  //   return;
  // }

  // if (!ctx.hasUI) {
  //   return;
  // }

  // const options = sessionsWithState.map(
  //   (s) => `[${s.phase}] ${s.name} - ${s.task.slice(0, 40)}`,
  // );
  // const selected = await ctx.ui.select("Select RPI Session to Resume", options);
  // if (!selected) {
  //   return;
  // }

  // const idx = options.indexOf(selected);
  // if (idx >= 0) {
  //   const target = sessionsWithState[idx];
  //   const sm = RPIStateMachine.load(ctx.cwd, target.statePath);
  //   if (sm) {
  //     sm.getState().status = "in_progress";
  //     sm.save();
  //     ctx.ui.notify(`Resuming RPI session: ${target.name}`, "info");
  //     await executeWorkflowLoop(sm, ctx, (active) =>
  //       sessionCtx.setActiveMachine(active),
  //     );
  //   }
  // }
}

export function rpiStatusCommandHandler(ctx: ExtensionContext): void {
  // const activeMachine = sessionCtx.getActiveMachine();

  // if (!activeMachine) {
  //   ctx.ui.notify(
  //     "No active RPI workflow in this session. Start one with /rpi <task>",
  //     "info",
  //   );
  // }

  // const lines = activeMachine.renderProgressBar();
  // ctx.ui.notify(lines.join("\n"), "info");

  // return;
}
