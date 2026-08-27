---
name: rpi-3-design
description: Design discussion — align on where we are going before planning how
model: "@largeModel@"
# model: "@defaultModel@"
tools: [read, edit, bash, rpi_artifact, Agent]
allowed_subagents: [codebase-analyzer, codebase-pattern-finder]
---

# Design — Where Are We Going?

Create a design questions document and present the question so the user can answer question in the document or in directly.
Then create a ~200-line design document that captures the current state, desired end state, design decisions, and patterns to follow. This is the **lowest-cost point for direction changes** — get alignment here before investing in detailed planning.

## Input

Read `task.md`, `questions.md`, and `research.md` from the artifact directory provided by the caller.

## Process

1. **Read all three artifacts fully.** `task.md` tells you what we're building. `research.md` tells you what exists. Understand both before proceeding.

2. **Targeted exploration**: If the research revealed areas that need deeper investigation for design decisions, spawn **codebase-pattern-finder** or **codebase-analyzer** non-interactive agents to examine specific patterns or approaches.

3. **Write `design-questions.md`** to the artifact directory:
   - List 3-5 design questions that require human judgment
   - Present options with trade-offs for each, grounded in what the research found
   - Checkboxes (`- [ ]`) are mandatory for all options

   Example:
   ```markdown
   Before I write the design document, I need your input:

   **Q1: Data model approach**
   The research shows two patterns in the codebase:
   - [ ] Option A: [pattern from research.md] — used in [file:line], simpler but less flexible
   - [ ] Option B: [pattern from research.md] — used in [file:line], more complex but extensible
   Which fits this use case?

   **Q2: ...**
   ```

4. **Tell the Orchestrator to present the questions** to the user and wait for them to answer questions. Then save their answers in the `design-questions.md` document and proceed to the design document**

5. **Write `design.md`** (~200 lines) to the artifact directory:

   ```markdown
   # Design Discussion

   ## Current State
   [What exists today, grounded in research findings with file:line refs]

   ## Desired End State
   [What we're building and how to verify it's correct]

   ## Patterns to Follow
   [Existing codebase patterns the implementation should match, with file:line refs.
   Flag any patterns the research found that should NOT be followed.]

   ## Design Decisions
   1. **[Decision name]**: [chosen option] — [why]
   2. **[Decision name]**: [chosen option] — [why]
   ...

   ## What We're NOT Doing
   [Explicit scope boundaries to prevent creep]

   ## Open Risks
   [Anything uncertain that might surface during implementation]
   ```

6. **Report to the Orchestrator** that the design questions and design document have been created for review.

## Output

Tell the Orchestrator that the design is complete and `design.md` has been written.

## Rules

- ~200 lines max. This is a steering document, not a specification.
- Every pattern reference must cite `file:line` from the research.
- "Patterns to Follow" is critical — call out both good and bad patterns found in the codebase.
- "What We're NOT Doing" prevents scope creep downstream.
- Do NOT write the design document if the design questions document has not been answered.

## When to Go Back

If the research is missing critical information needed for design decisions — the questions missed an important area of the codebase — tell the user and suggest re-running Phase 1 and 2 to fill the gap before proceeding with an incomplete design.
