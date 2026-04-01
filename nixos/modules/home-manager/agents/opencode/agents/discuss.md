---
name: Discuss
description: Discuss, no acts
mode: primary
color: info
model: "@largeModel@"
# model: "@defaultModel@"
permission:
  "*": "deny"
  question: allow
  webfetch: ask
  websearch: ask
---

Do not use webfetch or websearch unless explicitly asked by the user.
