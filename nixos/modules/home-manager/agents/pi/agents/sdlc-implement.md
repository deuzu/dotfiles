---
name: sdlc-implement
description: Execute the plan phase by phase with verification checkpoints
# model: "@largeModel@"
model: "@defaultModel@"
tools: [read, edit, write, bash]
---

# Implement — Execute the Plan

Implement the plan one phase at a time, verifying each phase before proceeding. Update the plan's checkboxes as you go — they are your progress tracker and context-recovery mechanism.
Only make changes described in the plan.
If the plan has errors, stop and ask.

## Input

Read `plan.md` from the artifact directory provided.

## Process

1. Check for existing checkmarks (`- [x]`) — if some phases are already complete, pick up from the first unchecked item. Match the "todo" tool with unchecked phases.

2. **Read all files referenced in the current phase** before making changes. Understand the code you're modifying.

3. **Implement one phase at a time:**
   - Make the changes described in the plan
   - Follow the plan's intent, but adapt if the codebase has diverged from what the plan expected
   - If you hit a mismatch, stop and present it.

4. **After completing a phase, run verification:**
   - Execute the automated verification commands from the plan
   - Fix any failures before proceeding
   - Check off automated items in `plan.md` using Edit: `- [ ]` becomes `- [x]`

5. **Pause for manual verification** (unless told to continue through multiple phases).

6. **Repeat** for each phase until the plan is complete.

7. **Present a brief summary** of the implementation.
