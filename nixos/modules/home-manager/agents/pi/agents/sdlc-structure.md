---
name: sdlc-structure
description: Structure outline — vertical slices with test checkpoints
model: "@largeModel@"
# model: "@defaultModel@"
tools: [read, edit, write, bash]
---

# Structure — How Do We Get There?

Create a ~200-line structure outline that breaks the design into **vertical slices** — each independently testable. Show the signatures, types, and phase boundaries — not the full implementation.

## Input

Read `design.md` and `code-research.md` from the artifact directory provided.

## Process

1. **Break the work into vertical slices.** Each slice delivers end-to-end functionality:
   - Crosses all necessary layers (database, service, API, UI) for that slice
   - Can be tested independently after implementation
   - Has a clear verification checkpoint

   **Vertical** (correct):

   > Phase 1: Add the "reticulate" endpoint — migration, store method, API handler, basic UI button. Test: endpoint returns 200, button triggers call.

   **Horizontal** (wrong):

   > Phase 1: All database migrations. Phase 2: All service methods. Phase 3: All API endpoints. Phase 4: All UI changes.

2. **Define the phase order.** Earlier phases should establish foundations that later phases build on. If Phase 3 fails, Phases 1-2 should still be independently valuable.

3. **For each phase, list**:
   - What it accomplishes (1-2 sentences)
   - Files affected
   - Key type signatures or interface changes
   - How to verify it works (automated command + what to check manually)

4. **Write `structure.md`** to the artifact directory:

   ```markdown
   # Structure Outline

   ## Approach

   [1-2 sentences: the implementation strategy from design.md, condensed]

   ## Phase 1: [Name]

   [What this phase delivers end-to-end]

   **Files**: `path/to/file.ext`, `path/to/other.ext`
   **Key changes**:

   - `functionName(param: Type): ReturnType` — new/modified
   - `NewType { field: Type }` — new type

   **Verify**: [project test command] passes; [manual check description]

   ---

   ## Phase 2: [Name]

   ...

   ## Testing Checkpoints

   [Summary of what should be true after each phase, useful for resuming if context resets]
   ```

5. **Present the outline summary** and notify that `structure.md` has been written.
