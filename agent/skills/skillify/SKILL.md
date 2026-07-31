---
name: skillify
description: >-
  Turn a repeated workflow, prompt pattern, or ad-hoc feature into a reusable pi skill.
  Use when the user says "skillify this", "make this a skill", "is this a skill?",
  "turn this into a skill", "add a skill for X", or when you notice yourself giving the
  same multi-step instructions across sessions. Produces a well-formed SKILL.md with a
  discoverable description, extracts deterministic logic into a script, runs a quality
  pass, and verifies the skill actually loads.
license: MIT
allowed-tools: read write edit bash grep find ls
---

# Skillify

Convert a raw feature, prompt, or repeated workflow into a proper pi skill.

Pi routes by matching the user's request against the `description` frontmatter, so the
description carries the whole routing burden. A skill that never triggers is dead weight.

## Contract

**Input:** a description of a workflow, an existing prompt or script, or a pointer to code
that gets re-explained across sessions.

**Output:** a skill at `~/.pi/agent/skills/<name>/` (global) or `<project>/.pi/skills/<name>/`
(project-local), containing at least a `SKILL.md`, plus extracted scripts and reference
files. Verified to parse, load, and run end to end.

**Guiding principle:** a skill locks in behavior. If the behavior is mediocre, you have made
mediocrity reusable. Get the quality right before finalizing.

## Checklist

Done when all applicable items pass:

1. `SKILL.md` has valid frontmatter — `name` and `description` at minimum.
2. `description` is written in the words a user would actually type, and states *when* to use
   the skill, not only what it does.
3. Body has a contract, ordered steps, and an output format.
4. Deterministic logic lives in a script, not in prose the model re-derives each run.
5. Long reference material lives in sibling files, loaded on demand.
6. Quality pass done (Phase 3) before finalizing.
7. `scripts/verify.sh <name>` passes: frontmatter parses, limits respected, skill is listed.
8. Smoke test passed — invoked once end to end, produced the intended effect.

## Phase 0: Should this be a skill?

Skills cost description budget on every request, and a bad one misfires. Only proceed if most
of these hold:

- The workflow has recurred, or the user expects to reuse it.
- There is non-trivial procedure, domain knowledge, or sequencing worth capturing.
- It has a clear, nameable trigger.
- It is not already covered by an existing skill, and not better served by a line in
  `AGENTS.md`, a prompt template, or a shell alias.

If it fails, say so and propose the lighter alternative instead of building a skill.

## Phase 1: Audit

- What triggers it? Collect the actual phrases the user would say.
- What are the steps, in order? Where is the decision logic?
- What is deterministic (script) versus judgment (prose)?
- What are the inputs, outputs, and side effects?
- **Location:** global `~/.pi/agent/skills/` when it applies across projects, project-local
  `.pi/skills/` when it is repo-specific. Use `~/.agents/skills/` or `.agents/skills/` instead
  when the skill should be shared with other agent harnesses. Ask the user when unsure.
- **Shape:** a directory with `SKILL.md`, or — for a skill with no scripts or references — a
  single `<name>.md` placed directly in `~/.pi/agent/skills/` or `.pi/skills/`, which pi
  discovers as a skill on its own. Note that bare `.md` files are ignored in the `.agents/`
  locations.
- Pick a short kebab-case `name` that collides with nothing already loaded.

## Phase 2: Write SKILL.md and code

Frontmatter fields pi supports:

| Field | Use |
|---|---|
| `name` | Required. 1-64 chars, lowercase letters, numbers, hyphens. No leading, trailing, or doubled hyphens. Need not match the directory name. |
| `description` | Required. Max 1024 chars. Leads with when-to-use trigger language. |
| `license` | Optional. |
| `compatibility` | Optional, max 500 chars. Real environment requirements only — not the harness name. |
| `allowed-tools` | Optional, experimental. **Space-delimited**, lowercase pi tool names: `read write edit bash grep find ls`. |
| `disable-model-invocation` | Optional. `true` hides the skill from the system prompt so it runs only via `/skill:<name>`. Use for destructive or expensive skills. |
| `metadata` | Optional key-value map. |

**YAML trap:** a plain unquoted `description` containing `: ` fails to parse, and pi drops a
skill whose description is missing — silently, with no entry in the skill list. Use a folded
block scalar (`>-`) whenever the text contains a colon, or quote it.

Body: one-line purpose, a Contract (input, output, side effects), ordered steps or phases, and
an explicit Output Format. Keep prose lean.

Extract deterministic work into `scripts/`, and have the body call it rather than describing an
algorithm the model re-derives, and re-gets-wrong, every run. Put long reference material in
sibling files (`references/*.md`) and instruct the body to read them on demand, keeping the
always-loaded `SKILL.md` small.

## Phase 3: Quality gate

The point where you make sure you are locking in good behavior.

Run the skill on one or two representative inputs and critique the output against explicit
dimensions: correctness, completeness, match to intent, failure handling. Fix and repeat, at
most about three cycles. Finalize only once the output is good on a realistic input, not a
trivial one.

Optionally get a second opinion from a different model to cover correlated blind spots. Treat
it as informational, not a gate.

Do not skip this because the output looks fine. That is when a second look is cheapest.

## Phase 4: Verify

```bash
./scripts/verify.sh <name>
```

The script checks that the frontmatter parses, that `name` and `description` satisfy pi's
limits, and that pi actually lists the skill. Then, by hand:

1. **Discoverability:** state a realistic user phrasing and confirm the description would route
   here without colliding with another skill. Pi keeps the first skill found on a name
   collision, so a duplicate name silently shadows.
2. **Smoke test:** invoke it once on a real input, end to end. In an existing session, run
   `/reload`, or force it with `/skill:<name>`.

## Output Format

```
## Skill created — <name>  (<path>)

**Description (routing surface):** <text>
Why it will trigger: <reason>

**Scripted vs. prose:** <what was extracted, and why>

**Quality gate:** <what was tested, what was fixed>

**Verification:** <verify.sh result, smoke test result>

**Follow-ups:** <e.g. run /reload to pick it up in this session>
```

## Anti-Patterns

- **Skill for a one-liner.** If an `AGENTS.md` line or an alias does it, do not build a skill.
- **Description that describes instead of triggers.** "Analyzes data" will not route; "use when
  the user wants to summarize a CSV" will.
- **Jargon triggers.** Write the words the user types, not internal terms.
- **Prose where a script belongs.** Re-derived logic drifts and breaks.
- **Bloated SKILL.md.** Long references belong in sibling files loaded on demand.
- **Unquoted description with a colon.** Parses as YAML mapping, skill silently disappears.
- **Duplicate name.** Shadows the existing skill with no error.
- **Finalizing before the quality gate.** Reuse cements whatever quality you shipped.
- **Over-broad `allowed-tools`.** Grant only what the skill needs.
