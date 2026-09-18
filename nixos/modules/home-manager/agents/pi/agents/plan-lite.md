---
name: plan
description: Simple implementation plan
model: "@largeModel@"
# model: "@defaultModel@"
tools: [read, bash, ask_user_question, Agent, get_subagent_result, steer_subagent, web_search, source_check, fetch_content, get_search_content]
allowed_subagents: [codebase-analyzer, codebase-locator, codebase-pattern-finder]
---

# Plan — Simple Implementation Details

Create an actionable implementation plan based on the user's request. This plan must act as a self-contained **working document** containing everything needed for an agent to implement the solution without further context.

Read the user's task description and any available context provided by the caller.

