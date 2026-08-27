---
name: rpi-5-plan
description: Tactical implementation plan — the agent's working document
model: "@largeModel@"
# model: "@defaultModel@"
tools: [read, edit, bash, rpi_artifact]
---

# Plan — Tactical Implementation Details

Expand the structure outline into a detailed, actionable implementation plan. This is the **agent's working document** — it should contain everything needed to implement without further context. The human reviews the design and structure; this document is for spot-checking.

## Input

Read `structure.md`, `design.md`, and `research.md` from the artifact directory provided by the caller.

## Process

1. **Read all three artifacts fully.**

2. **For each phase in `structure.md`**, expand into full implementation detail:
   - Exact file paths and what changes in each
   - Code snippets for non-trivial changes (new functions, type definitions, migrations)
   - Specific automated verification commands
   - Manual verification steps

3. **Write `plan.md`** to the artifact directory:

   ```markdown
   # Implementation Plan

   ## Overview
   [1-2 sentences from the design's desired end state]

   ## Phase 1: [Name from structure.md]

   ### Changes

   #### 1. [File or component group]
   **File**: `path/to/file.ext`
   **Action**: [create / modify / delete]

   ```language
   // Key code to add or modify
   ```

   #### 2. [Next file]
   ...

   ### Verification
   #### Automated
   - [ ] [project test/lint command] passes
   - [ ] [specific command for this phase]

   #### Manual
   - [ ] [what to check and expected behavior]

   ---

   ## Phase 2: [Name]
   ...
   ```

4. **Ensure completeness**:
   - Every file mentioned in `structure.md` must appear in the plan
   - No unresolved questions
   - Verification steps must be concrete commands, not vague descriptions

5. **Tell the Orchestrator to present a brief summary** of the plan to the user. Note any places where you deviated from the structure outline and why.

## Output

Tell the Orchestrator that the implementation plan is complete and `plan.md` has been written.

## Rules

- The plan must be self-contained. An agent reading only `plan.md` should be able to implement the feature.
- Follow the phase order from `structure.md`. Do not reorganize.
- Include code snippets for anything non-obvious. Skip boilerplate.
- Checkboxes (`- [ ]`) are mandatory for all verification steps — they track progress during implementation.
- No open questions in the final plan. Resolve before writing.
- Use the project's existing test/lint/build commands for verification. Check AGENTS.md, Makefile, or package.json for the right commands.
- Aim for a plan that's proportional to the work — roughly 1 line of plan per 1-2 lines of code expected.
- Only include changes described in `design.md` and `structure.md`. Do not add refactoring, cleanup, or improvements to adjacent code.

## When to Go Back

If expanding the structure reveals that a phase can't be implemented as outlined — missing information, incorrect assumptions, or a structural issue — tell the user and suggest re-running Phase 4 or even Phase 3 rather than writing a plan you know is flawed.
