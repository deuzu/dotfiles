---
name: explain-diff
description: Use when the user asks for a rich explanation of a code change, diff, branch, or PR.
---

# Explain Diff

Make a rich, explanation of the specified code change.

## Sections

- Background: Explain the existing system relevant to this change. Broadly explore surrounding code for this. We don't know how much the reader already knows, so include a deep background for beginners and then a more narrow background directly relevant to the change.
- Intuition: Explain the core intuition for the code change. The focus here is to explain the essence, not the full details. Use concrete examples with toy data. Use figures and diagrams liberally.
- Code: Do a high-level walkthrough of the changes to the code. Group/order the changes in an understandable way.

## Output

- Output in markdown.
- The length of the output must be relative to the size of the diff: a single sentence or a paragraph for a small diff multiple paragraphs for a large diff.
- Use callouts for key concepts or definitions, important edge cases, etc.
- Make it engaging and written in classic style. Transitions between sections should be smooth.
