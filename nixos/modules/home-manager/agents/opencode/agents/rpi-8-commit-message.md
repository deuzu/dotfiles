---
name: rpi-8-commit-message
description: Create a commit message file with context from the design discussion or from modified files.
mode: primary
hidden: true
# model: "@largeModel@"
model: "@defaultModel@"
permission:
  "*": deny
  glob: allow
  grep: allow
  read: allow
  edit: allow
  bash:
    "*": deny
    "git *": allow
    "git remote*": deny
    "git commit*": deny
    "git push*": deny
    "git config*": deny
---

# PR — Create Commit Message File

Create a commit message file with a description grounded in the design document and/or the actual diff.

## Input

Read `design.md` for context from the artifact directory provided by the caller if available.

## Process

1. **Detect the base branch** and **gather PR information:**
   - Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'` (falls back to `main`)
   - `git diff <base>...HEAD` — the full diff
   - `git log <base>...HEAD --oneline` — commit history
   - Read `design.md` for the "why" behind the changes if available

2. **Write `commit-message.txt`** using conventional commit, to the artifact directory:

   ```txt
   <type>(<optional-scope>): <description-under-70-chars>

   <2-3-bullets-on-the-what-and-why-from-design.md>

   <how-to-verify-manualy-checkboxes>
   ```

3. **Report the PR URL** to the Orchestrator.

## Output

PR created. Tell the Orchestrator the PR URL.

## Rules

- Title under 70 chars.
- The summary should explain WHY, not just WHAT.
- Reference the design and plan docs.
