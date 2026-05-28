---
name: rpi-8-pr
description: Create a pull request with context from the design discussion
mode: primary
hidden: true
# model: "@largeModel@"
model: "@defaultModel@"
permission:
  "*": deny
  glob: allow
  grep: allow
  read: allow
  bash:
   "*": deny
   "git symbolic-ref *": allow
   "git diff *": allow
   "git log *": allow
   "git branch *": allow
   "git add *": allow
   "git commit *": allow
   "git push": allow
   "git push *": allow
---

# PR — Create the Pull Request

Create a pull request with a description grounded in the design document and the actual diff.

## Input

Read `design.md` for context from the artifact directory provided by the caller.

## Process

1. **Detect the base branch** and **gather PR information:**
   - Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'` (falls back to `main`)
   - `git diff <base>...HEAD` — the full diff
   - `git log <base>...HEAD --oneline` — commit history
   - Read `design.md` for the "why" behind the changes

2. **Create the PR** using `git commit` and `git push`:

   ```
   git commit --no-gpg-sign --message "<conventional commit under 70 chars>" --message "$(cat <<'EOF'
   ## Summary
   [2-3 bullets: what this PR does and why, drawn from design.md]

   ## Design Decisions
   [Key decisions from design.md that reviewers should understand]

   ## Changes
   [Brief description of what changed, organized by component if multi-component]

   ## How to Verify
   - [ ] [Automated verification command]
   - [ ] [Manual verification step]

   ## References
   - Design: design.md
   - Plan: plan.md
   EOF
   )"

   git push -u origin/<branch>
   ```

3. **Report the PR URL** to the Orchestrator.

## Output

PR created. Tell the Orchestrator the PR URL.

## Rules

- Title under 70 chars.
- The summary should explain WHY, not just WHAT.
- Reference the design and plan docs.
