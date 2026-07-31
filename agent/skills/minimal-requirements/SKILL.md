---
name: minimal-requirements
description: >
  Write a minimal, essentials-only requirements list as concise bullets.
  Use when the user asks to "list the requirements", "write the requirements for X",
  "what does this need to cover", or wants scope distilled to only what's essential
  before building or changing something.
---

# Minimal Requirements List

Distill a task, feature, or prompt into the smallest set of requirements that fully
defines success.

## Contract

**Input:** a subject — a task description, feature idea, prompt, or piece of code.
**Output:** a flat bullet list of requirements. No headers, no prose around it beyond
one optional framing sentence.

## Steps

1. Identify the subject and its intended outcome. If the subject is ambiguous, ask
   one clarifying question before writing anything.
2. Draft candidate requirements, then apply the essentiality test to each:
   *would the outcome be wrong or incomplete without this item?* If no — or if
   unsure — drop it.
3. Explicitly exclude: nice-to-haves, implementation details, background/context,
   and anything derivable from another item already on the list.
4. Format: one requirement per bullet, one concise line each, phrased as a
   verifiable statement (someone could check whether it's met).

## Output Format

A flat bullet list, typically 3–8 items. If the list exceeds ~10 items, re-apply
the essentiality test — the subject is either too broad or the list includes
non-essentials.
