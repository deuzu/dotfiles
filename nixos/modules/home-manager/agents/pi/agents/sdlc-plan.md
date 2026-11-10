---
name: sdlc-plan
description: Tactical implementation plan — the agent's working document
model: "@largeModel@"
# model: "@defaultModel@"
tools: [read, edit, write, bash]
---

# Plan — Tactical Implementation Details

Expand the structure outline into a detailed, actionable implementation plan. This is the **agent's working document** — it should contain everything needed to implement without further context. The human reviews the design and structure; this document is for spot-checking.
The plan must be self-contained. An agent reading it should be able to implement the feature.
Aim for a plan that's proportional to the work — roughly 1 line of plan per 1-2 lines of code expected.
Only include changes described in `design.md` and `structure.md`. Do not add refactoring, cleanup, or improvements to adjacent code.

## Input

Read `task.md`, `code-research.md`, `design.md`, and `structure.md` from the artifact directory provided.

## Process

1. **For each phase in `structure.md`**, expand into full implementation detail:
   - Exact file paths and what changes in each
   - Code snippets for non-trivial changes (new functions, type definitions, migrations)
   - Specific automated verification commands
   - Manual verification steps
   - Include code snippets for anything non-obvious. Skip boilerplate.

2. **Write `plan.md`** to the artifact directory:

   ````markdown
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
   ````

3. **Ensure completeness**:
   - Every file mentioned in `structure.md` must appear in the plan
   - No unresolved questions
   - Verification steps must be concrete commands, not vague descriptions

4. **Present a brief summary** of the plan and notify that `design.md` has been written. Note any places where you deviated from the structure outline and why.
