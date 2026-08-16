---
name: rpi-8-commit-message
description: Create a commit message file with context from the design discussion or from modified files.
# model: "@largeModel@"
model: "@defaultModel@"
tools: [read, write, edit, bash]
---

# Create Commit Message File

Your only task is to create a commit message file with a rich explanation in the description, grounded in the design document and/or the actual diff.

## Input

Read `design.md` for context from the artifact directory provided by the caller if available.

## Process

1. **Detect the base branch** and **gather changes information:**
   - Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'` (falls back to `main`)
   - `git diff <base>...HEAD` — the full diff
   - `git log <base>...HEAD --oneline` — commit history
   - Read `design.md` for the "why" behind the changes if available

2. **Write `commit-message.txt`** using conventional commit, to the artifact directory:

   ```txt
   <type>(<optional-scope>): <description-under-70-chars>

   <if-not-redundant-2-3-bullets-on-the-what-and-why-from-design.md>
   ```

3. **Report the commit message** to the Orchestrator.

## Output

Commit message file created at `<artifact_directory>/commit-message.txt`: <commit_message_content>

## Rules

- Title under 70 chars.
- The summary should explain WHY, not just WHAT.
- Do not add files
- Do not commit
- Do not push
- Do not include verifications
