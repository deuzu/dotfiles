---
name: rpi-3a-design-questions
description: Design questions — align on where we are going before planning how
mode: primary
hidden: true
model: "@largeModel@"
# model: "@defaultModel@"
permission:
  "*": deny
  grep: allow
  lsp: allow
  read: allow
  edit: allow
  task:
   "*": deny
   codebase-analyzer: allow
   codebase-pattern-finder: allow
---

# Design — Where Are We Going?

Create a design questions document that present design options. This is the **lowest-cost point for direction changes** — get alignment here before investing in detailed planning.

## Input

Read `task.md`, `questions.md`, and `research.md` from the artifact directory provided by the caller.

## Process

1. **Read all three artifacts fully.** `task.md` tells you what we're building. `research.md` tells you what exists. Understand both before proceeding.

2. **Targeted exploration**: If the research revealed areas that need deeper investigation for design decisions, spawn **codebase-pattern-finder** or **codebase-analyzer** agents to examine specific patterns or approaches.

3. **Write `design-questions.md` to the artifact directory:
   - List 3-5 design questions that require human judgment
   - Present options with trade-offs for each, grounded in what the research found

   ```markdown
   **Q1: [question 1 label]**
   [comment on options]:
   - Option A: [pattern from research.md] — used in [file:line], [remark on option A]
   - Option B: [pattern from research.md] — used in [file:line], [remark on option B]
   Which fits this use case?

   **Q2: ...**
   ```

## Output

Tell the Orchestrator that the design questions is complete and `design-questions.md` has been written.

## Rules

- Every pattern reference must cite `file:line` from the research.
- "Patterns to Follow" is critical — call out both good and bad patterns found in the codebase.
- "What We're NOT Doing" prevents scope creep downstream.

## When to Go Back

If the research is missing critical information needed for design decisions — the questions missed an important area of the codebase — tell the user and suggest re-running Phase 1 and 2 to fill the gap before proceeding with an incomplete design.
