---
name: model-routing
description: Policy for choosing which Claude model handles a piece of work. Use before spawning any subagent (Agent tool), when a task fans out into broad searches, bulk reads, log/diff summarizing, code review, security review, architecture or planning work, hard debugging, or whenever deciding between haiku, sonnet, opus, or fable.
---

# Model routing

The session runs on **sonnet** by default (`"model": "sonnet"` in
`~/.claude/settings.json`), with **opus** as the advisor
(`"advisorModel": "opus"`). This skill decides when work should go to a
different model instead.

A skill cannot switch the session's own model. Routing happens through the
Agent tool's `model` parameter (`haiku` | `sonnet` | `opus` | `fable`), or by
calling the advisor. Always use these aliases, never full model IDs.

**Standing authorization:** the user has authorized delegating to subagents
whenever a task matches a row below. That counts as "the user asked" for the
Agent tool's spawn rule. Don't delegate work you can finish in a few tool
calls yourself, because a cold subagent re-derives context and that costs
more than it saves.

## Tiers (cheapest first, prices as of 2026-10)

| Alias  | Cost (in/out per MTok) | Strength |
|--------|------------------------|----------|
| haiku  | $0.10 / $0.50          | Fast and cheap, good at mechanical reading |
| sonnet | $2 / $10               | Everyday coding, the default |
| opus   | $4 / $20               | Deeper reasoning, design, hard bugs |
| fable  | $10 / $50              | Most capable, for the hardest long-horizon work |

## Routing

| Work | Model | Notes |
|------|-------|-------|
| Broad read-only search: grep sweeps, "where is X used", locating files across a big tree | `haiku` | Use the `Explore` agent with `model: "haiku"` |
| Summarizing logs, CI output, long diffs, docs; extracting facts from many files | `haiku` | Ask for a concise conclusion, not dumps |
| Mechanical edits across many files (renames, boilerplate, format fixes) with a clear spec | `haiku` | Give an exact spec. Use `sonnet` if judgment is needed |
| Normal implementation, tests, refactors, bug fixes with an obvious cause | `sonnet` | Usually done inline, no subagent |
| Architecture, implementation planning, API design, trade-off decisions | `opus` | `Plan` agent with `model: "opus"`, or call the advisor |
| Hard debugging: intermittent failures, concurrency, a cause that stays unclear after a first pass | `opus` | |
| Code review and security review of non-trivial changes | `opus` | |
| Very long autonomous tasks, or problems `opus` already failed on | `fable` | Most expensive tier. Say why before using it |

## Advisor vs. an opus subagent

- **Advisor** (`opus`): use it for judgment on *this* conversation, such as
  picking an approach, sanity-checking before declaring done, or getting
  unstuck. It sees the full transcript, so there is no briefing cost.
- **Opus subagent**: use it for a self-contained chunk of deep work whose
  output is a result (a plan, a review, a root cause). Give it a complete
  brief, because it starts cold.

## Rules of thumb

- Escalate one tier at a time. If `haiku` output is wrong or shallow, redo it
  on `sonnet`. Don't jump straight to `fable`.
- Parallel fan-out (several independent searches) should go to `haiku`
  agents launched in one message.
- Tell the user in one line when you route something to `opus` or `fable`,
  so the spend is visible.
