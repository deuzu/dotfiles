---
name: github-code-search
description: Search code example on Github.
---

## Search For Code Examples on Github

First, execute
```
gh search code --help
```

Then search code examples.
Multiple queries can be used, e.g.:
```
gh search code "monitoring_alert_policy" "renotify_interval" --language hcl --limit 15
```
Output format:
```
Showing 15 of <n> results

<repository> <filepath>
<code-snippet>

...
```

Lastly, retrieve the code files:
```
gh api repos/<repository>/contents/<filepath> --jq '.content' | base64 -d
```
