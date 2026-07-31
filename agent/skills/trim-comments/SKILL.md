---
name: trim-comments
description: Remove redundant comments and docstrings, replacing them with more descriptive code. Use when the user asks to trim, strip, or remove comments or docstrings, says code is over-commented or noisy with comments, or asks "do we need all these comments?". Also applies as a final pass after writing new code, before presenting it.
allowed-tools: read write edit bash grep find
---

# Trim Comments

Comments rot: code keeps compiling when the comment below it goes stale, so every comment is a maintenance liability with no failing test to protect it. A comment is a failure of the code to be readable on its own. The fix is rarely a better comment — it's better code.

## Contract

**Input:** a scope of code — uncommitted changes by default, else the files touched this session, else files/paths the user names.

**Output:** edited files with redundant comments and docstrings removed, code rewritten to be self-explanatory where a comment was compensating, and the few necessary comments condensed. A short report of what changed.

**Side effects:** only comment/docstring deletions and readability rewrites (renames, extracted functions/constants). No behavior changes.

## Steps

1. **Scope.** Prefer the uncommitted diff (`git diff` + `git diff --staged` + untracked files). If clean, use files worked on this session. If neither, ask the user which paths.

2. **Inventory.** Read the in-scope files and list every comment and docstring.

3. **Classify each one** — in this order:
   - **Redundant** — restates what the code does, narrates the next line, section headers like `// validate input`, changelog notes ("moved from X", "updated to use Y"), commented-out code. → Delete.
   - **Compensating** — needed only because the code is unclear (cryptic name, magic number, dense expression). → Rewrite the code so the comment becomes unnecessary: rename the variable/function, extract a named constant or well-named helper, split the expression. Then delete the comment. Prefer the smallest rewrite that makes it read clearly.
   - **Genuine why** — a non-obvious constraint the code cannot express: workaround for an external bug (link the issue), performance/ordering requirement, spec or business rule, why the obvious approach was rejected. → Keep, condensed to the fewest words that convey the constraint.
   - **Load-bearing docstring** — consumed by tooling or contract: doctests, published-library public API, doc generators (Sphinx/JSDoc/rustdoc on exported symbols), framework metadata. → Keep but condense: one summary line; drop parameter/return sections that just restate names and types.

4. **Apply the edits.** For compensating rewrites, update all references to renamed symbols. Never change behavior — if making code self-explanatory would require restructuring logic, keep a condensed why-comment instead and note it in the report.

5. **Verify.** If the project has a fast check (typecheck, lint, tests for touched files), run it — rewrites touch code, not just comments.

## Litmus tests

- Would a competent reader, seeing only the code, already know this? → delete.
- Does deleting it lose information? If the lost information is *what* the code does → improve the code. If it's *why* → keep, condensed.
- Docstring on an internal function that says "Gets the user by id" above `getUserById` → delete.
- When in doubt between a clever rename and keeping a comment, prefer the rename only if it genuinely reads better — a strained 40-character function name is worse than a short comment.

## Output Format

Report in prose, briefly:
- How many comments/docstrings were deleted outright.
- Which spots were rewritten for clarity instead (name the symbol and the change).
- Which comments were kept and the one-line reason each survives.
- Result of the verification check, if run.
