---
name: addguests-weekly-infra
description: Convert a raw weekly infra meeting draft into a clean, structured document. Use when asked to clean up, restructure, or finalize addguests weekly infra notes.
---

# Addguests Weekly Infra Notes Cleaner

Converts a raw weekly infra draft — typically typed quickly during a meeting and mixing French and English — into a clean, structured **English** document, in a single pass.

## Input

- The draft

It may contain mixed FR/EN prose, franglais, shorthand, TODOs, and side remarks.

## Process

1. **Read the whole draft.** Identify every distinct subject discussed.
2. **Extract, per subject:** the context and problem statement, the hypothesis (if any), the decision (if any), and the action items (if any).
3. **Translate to English.** Rewrite French fragments and franglais into clean English. Keep proper nouns, hostnames, service names, technical identifiers, and quoted text unchanged.
4. **Output the final document in one pass.** Do not ask for confirmation, and do not add any commentary before or after — the clean document is the entire output (unless the user asked to write it to a file).

## Rules

- One `##` section per subject, in the order of the draft.
- **Never invent content**: only restructure and translate what the draft actually contains. If something is ambiguous, ask the question to the user.
- Omit the `Hypothesis:` line, the `Decision:` line, or the checklist entirely when the draft contains none of them for that subject.
- Action items: one `- [ ]` checkbox per line, phrased as an actionable task starting with a verb. Include the owner when the draft mentions one.
- Preserve technical facts exactly: dates, numbers, versions, URLs, hostnames, service names.
- Subjects with no real problem statement (e.g. pure FYI items) get a one-line summary as their context instead.

## Output Format

```markdown
## <Subject 1>

<Context and problem statement>

Hypothesis: <hypothesis, if any>

Decision: <decision, if any>

- [ ] <action item 1>
- [ ] <action item n>

## <Subject 2>

...
```

## Example

Input (raw draft):

```
mercredi gros lag sur grafana, les dashboards mettent 30s a charger
le probleme c'est le volume de metrics, trop de cardinality avec les labels kubernetes
on croit que couper les labels inutiles suffira, a valider
decision: on garde que les labels utiles pour les alertes, via metric_relabel_configs
hugo il prepare la PR sur le values prometheus
```

Output:

```markdown
## Grafana dashboards slow (30s load)

Since Wednesday, Grafana dashboards take ~30s to load. Root cause: metrics volume — Kubernetes labels create too much cardinality.

Hypothesis: Dropping unneeded labels is enough to fix it; to be validated.

Decision: Keep only the labels used by alerts, via `metric_relabel_configs`.

- [ ] Hugo: prepare the PR on the Prometheus values
```
