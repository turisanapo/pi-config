---
name: copy-review
description: >-
  Review the human-facing text in a pull request or diff and suggest more natural wording.
  Use when the user says "review the human-facing text", "the wording sounds unnatural",
  "sounds robotic / stiff", "review the copy", or "suggest better wording for the docs,
  messages, or help text in my changes". Takes a PR URL, PR number, branch, git range, or
  diff file; with no target, reviews the local uncommitted changes. Suggests rewrites in
  the reply and edits nothing.
allowed-tools: read bash grep find ls
---

# Copy Review

Find the text that users read in a change, and suggest wording that sounds like a fluent
writer wrote it.

## Contract

**Input:** optional target — a PR URL, PR number, branch, `<a>..<b>` range, or diff file.
No target means the local uncommitted changes, untracked files included.

**Output:** before/after suggestions in the reply, one per finding, in the format below.

**Side effects:** none. Do not edit files unless the user asks after seeing the suggestions.

## Rules

- **Do the review yourself. Do not delegate it**, even if other instructions make delegation
  the default. Tone needs one consistent reader, and a subagent's summary loses the wording.
- **Ignore ASD-STE100 / Simplified Technical English** and any similar controlled-language
  rule for the suggested text. That style is a common cause of the stiffness under review.
  Write natural, idiomatic English for the text's reader.

## Steps

1. Collect the change. Run from the repository root when the target is local:
   ```bash
   ~/.pi/agent/skills/copy-review/scripts/collect-diff.sh [target]
   ```
   If the user pasted a diff, use it. Save long output to a file and read it in parts.
2. Pick the user-facing text from the added lines:
   - User docs, READMEs, guides, skill and reference pages, changelogs.
   - UI strings, CLI help, schema and tool descriptions, error messages a user sees.
   - Example values a reader copies, such as a sample `reason` or a message string.

   Skip text for the team: PR titles and bodies, commit messages, decision logs, plans,
   code comments, docstrings, and test names. Test assertions that repeat a production
   string are mirrors, not new text.
3. For each piece, read it as its reader would. Flag what a fluent writer would not write.
   Read [references/patterns.md](references/patterns.md) for the usual causes and approved
   rewrites.
4. Write the suggestion. Rewrite the whole sentence or paragraph when the structure is the
   problem. When strings belong together, such as a doc rule and the error that enforces it,
   give them the same wording.
5. If the repository is local, search for each changed string literal (`rg -F`) and list
   the tests and docs that repeat it, so the user can update them together. A shared
   string, such as an error constant, can reach other commands; name them.

## Output Format

```
## Copy review — <target, or "local changes">

### <path>:<line>
**Now:** <current text>
**Suggested:** <rewrite>
**Why:** <one line: what reads wrong>

… one block per finding, grouped by file, most visible text first …

**Read well, no change:** <short list of reviewed text left as is>
**Mirrors to update:** <files that repeat a changed string, or "none">
**Meaning questions:** <findings where the rewrite needs a decision, or "none">
```

Quote short text in full. For a long paragraph, quote it once under **Now** and give the
full rewrite under **Suggested**.
