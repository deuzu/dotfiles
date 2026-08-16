---
name: rpi-6-worktree
description: Create an isolated git worktree for implementation
# model: "@largeModel@"
model: "@defaultModel@"
tools: [read, write, edit, bash]
---

# Worktree — Isolate the Implementation

Create a git worktree so implementation happens on an isolated branch without affecting your main working tree.

## Input

The artifact directory path is provided by the caller in the prompt.

## Process

1. **Determine identifiers** from the artifact directory name:
   - Branch name: derive from the directory name (e.g., `ENG-1234-description` or `2026-03-29-new-feature`)
   - Repo name: detect from `basename $(git rev-parse --show-toplevel)`
   - Worktree path: `../<branch-name>`

2. **Create the worktree:**

   ```bash
   git worktree add ../<branch-name> -b <branch-name>
   ```

3. **Copy rpi artifacts** to the worktree. Untracked files from the main tree do not appear in worktrees:
   ```bash
   mkdir -p ../<branch-name>/<artifacts-directory>
   cp -r <artifact-directory> ../<branch-name>/<artifact-directory>
   ```

## Output

Tell the Orchestrator that the worktree is created at `../<branch-name>` and rpi artifacts have been copied.

## Rules

- Worktrees do not share untracked files with the main tree. Always copy the artifact directory after creating the worktree.
- Do not start implementation.

## When to Go Back

If the plan doesn't exist yet at the provided directory, tell the user to run Phase 5 first.
