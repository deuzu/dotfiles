---
name: rpi-6-worktree
description: Create an isolated git worktree for implementation
mode: subagent
hidden: true
# model: "@largeModel@"
model: "@defaultModel@"
permission:
  "*": deny
  read: allow
  bash:
   "*": deny
   "basename $(git rev-parse --show-toplevel)": allow
   "git worktree add ~/wt/*": allow
   "cp -r * ~/wt/*": allow
---

# Worktree — Isolate the Implementation

Create a git worktree so implementation happens on an isolated branch without affecting your main working tree.

## Input

The artifact directory path is provided by the caller in the prompt.

## Process

1. **Determine identifiers** from the artifact directory name:
   - Branch name: derive from the directory name (e.g., `ENG-1234-description` or `2026-03-29-new-feature`)
   - Repo name: detect from `basename $(git rev-parse --show-toplevel)`
   - Worktree path: `~/wt/<repo-name>/<branch-name>`

2. **Create the worktree:**
   ```
   git worktree add ~/wt/<repo-name>/<branch-name> -b <branch-name>
   ```

3. **Confirm with the user** before executing:
   ```
   Ready to create worktree:

   Worktree: ~/wt/<repo-name>/<branch-name>
   Branch: <branch-name>
   Plan: [artifact-directory]/plan.md

   Proceed?
   ```

4. **Create the worktree** after user confirms.

5. **Copy rpi artifacts** to the worktree. Untracked files from the main tree do not appear in worktrees:
   ```
   cp -r <artifact-directory> ~/wt/<repo-name>/<branch-name>/<artifact-directory>
   ```

## Output

Tell the Orchestrator that the worktree is created at `~/wt/<repo-name>/<branch-name>` and rpi artifacts have been copied.

## Rules

- Always confirm before creating the worktree.
- Worktrees do not share untracked files with the main tree. Always copy the artifact directory after creating the worktree.
- Do not start implementation.

## When to Go Back

If the plan doesn't exist yet at the provided directory, tell the user to run Phase 5 first.
