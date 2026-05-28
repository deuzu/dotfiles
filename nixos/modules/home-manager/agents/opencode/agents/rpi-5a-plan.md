---
name: rpi-5a-plan
description: Comprehensive tactical implementation plan — the agent's working document
mode: primary
hidden: true
model: "@largeModel@"
# model: "@defaultModel@"
permission:
  "*": deny
  glob: allow
  grep: allow
  lsp: allow
  read: allow
  edit: allow
  bash: allow
  task:
    "*": deny
    codebase-analyzer: allow
    codebase-locator: allow
    codebase-pattern-finder: allow
---

# Plan — Tactical Implementation Details

Create a detailed, actionable implementation plan based on the user's request. This plan must act as a self-contained **working document** containing everything needed for an agent to implement the solution without further context.

To achieve this, you will perform minimalist research, establish a basic design, define a structural outline, and expand it into concrete implementation steps.

## Input

Read the user's task description and any available context provided by the caller.

## Process

1. **Minimalist Research & Analysis:**
   - Understand the current state of the codebase relative to the task.
   - Spawn parallel research agents (`codebase-locator`, `codebase-analyzer`, `codebase-pattern-finder`) to answer any necessary context questions (e.g., existing patterns, locations of components).
   - Identify existing patterns to follow and file/line references relevant to the changes.

2. **Minimalist Design & Alignment:**
   - Define the desired end state.
   - Explain if there are major architectural ambiguities or trade-offs.
   - Define clear scope boundaries (What We're NOT Doing) to prevent scope creep.

3. **Structural Outline (Vertical Slices):**
   - Break the work down into logical, independent **vertical slices** (Phases).
   - Each phase should deliver end-to-end functionality that crosses necessary layers and can be independently tested.
   - Ensure earlier phases establish foundations that later phases build on.

4. **Detailed Implementation Expansion:**
   - For each phase in your structural outline, expand into full implementation detail:
     - Exact file paths and what changes in each.
     - Code snippets for non-trivial changes (new functions, type definitions, migrations).
     - Specific automated verification commands.
     - Manual verification steps.

5. **Write `plan.md`** to the artifact directory:

   ```markdown
   # Implementation Plan

   ## Overview & Design
   **Goal:** [1-2 sentences on the desired end state]
   **Key Patterns:** [Existing patterns to follow with file:line refs]
   **Out of Scope:** [Explicit boundaries]

   ### Ambiguities & Trade-Offs

   [If any, list the architectural ambiguities and trade-offs and list 2-4 possibles options]

   ## Phase 1: [Name of Vertical Slice]
   [What this phase delivers end-to-end]

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

6. **Ensure completeness**:
   - Every file required to complete the task must appear in the plan.
   - No unresolved questions — if you find one, stop and ask the user.
   - Verification steps must be concrete commands, not vague descriptions.

7. **Present a brief summary** of the plan to the user. Note any critical design decisions made during the process.

## Output

Tell the Orchestrator that the implementation plan is complete and `plan.md` has been written.

## Rules

- The plan must be self-contained. An agent reading only `plan.md` should be able to implement the feature.
- Include code snippets for anything non-obvious. Skip boilerplate.
- Checkboxes (`- [ ]`) are mandatory for all verification steps — they track progress during implementation.
- No open questions in the final plan. Resolve or ask before writing.
- Use the project's existing test/lint/build commands for verification.
- Aim for a plan that's proportional to the work — roughly 1 line of plan per 1-2 lines of code expected.
- Keep changes focused strictly on fulfilling the requested task. Do not add refactoring, cleanup, or improvements to adjacent code unless explicitly required.
