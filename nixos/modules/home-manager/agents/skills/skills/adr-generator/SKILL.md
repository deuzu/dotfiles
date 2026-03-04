---
name: adr-generator
description: Generate a architecture decision record
---

# Architecture Decision Record Generator

A set of instruction to generate an Architecture Decision Record (ADR), a document that captures an important architectural decision made along with its context and consequences.
The purpose of an ADR is to provide transparency and record-keeping for decisions that affect the architecture of a software project or system.
This helps teams understand why certain decisions were made, what alternatives were considered, and what the implications of those decisions are.

## Generation Steps

### Step 1 Context and Probleme Statement

Generate the "Context and Problem Statement" section then ask the user for confirmation.

### Step 2 Considered Options

Generate a list of potential options that fit criteria and solve the problem statement.
For each option, explain pros and cons.

### Step 3 Decision Outcome

Ask the user if a there is a decision outcome. If no, only write the title section, leave the content empty and skip the step 4.

### Step 4 Consequences

Ask the user if a there is are consequences of the decision. If no, only write the title section and leave the content empty.

### Step 5 Title

Generate a title for the document.

## Output Format

```markdown
## Context and Problem Statement

Describe the context and problem statement, e.g., in free form using two to three sentences or in the form of an illustrative story.
You may want to articulate the problem in form of a question and add links to collaboration boards or issue management systems.

## Considered Options

- lorem
- ipsum
- dolor

## Decision Outcome

**lorem** chosen because…

Explain the choice of the option.

### Consequences

- good, because…
- meh, because…
- bad, because…
```
