import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { RPIStateMachine } from "./state.ts";

export function updateUIWidget(ctx: ExtensionContext, sm: RPIStateMachine): void {
  if (ctx.hasUI) {
    ctx.ui.setWidget("rpi-progress", sm.renderProgressBar());
  }
}

export function clearUIWidget(ctx: ExtensionContext): void {
  if (ctx.hasUI) {
    ctx.ui.setWidget("rpi-progress", undefined);
    ctx.ui.setStatus("rpi", undefined);
  }
}
