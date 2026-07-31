---
name: codebase-hygiene
version: 1.1.0
description: >-
  Keep code minimal and the project structure well-organized. Use when the user asks
  to trim, simplify, declutter, or clean up the codebase, or asks "is this the simplest
  way?" / "any dead code or over-engineering?". Scope: uncommitted changes, then this
  session's work, then the whole project. Structure changes require approval before
  anything moves.
license: MIT
allowed-tools: read write edit bash grep find ls
---

# Declutter — Codebase Hygiene

Keep the codebase minimal, lean, and simple, and keep the project well-organized. Two focuses:

1. **Structure / organization** — file and folder layout, naming, placement. *Always ask for approval before moving or renaming anything.*
2. **Code** — leave nothing to trim: no dead code, no over-engineering, no needless indirection, no unused exports/params/deps. The simplest correct version that works.

This is hygiene for **code and project structure**. It is *not* for deleting build artifacts, caches, or generated files — leave those to `.gitignore`.

## Contract

**Input:** a repository path (defaults to the current working directory).

**Scope:** strict fallback hierarchy — the user may override at any point ("check the whole project", "just this file", "review PR #42"):

1. **Uncommitted / in-progress changes** (staged + unstaged + untracked, excluding ignored).
2. **Changes worked on in this session** — files this conversation actually edited or committed (including a PR opened from this session's work).
3. **The entire repo** — only when neither of the above exists (or it isn't a git repo).

**Output:** a review with concrete, minimal-diff recommendations grouped into *code simplifications* and *structure/organization*. Code fixes can be applied directly (they're easy to review in a diff); **structure changes are applied only after explicit approval.**

**Principle:** *The simplest thing that works, in the place it belongs.* Prefer deletion and inlining over addition. When a change trades clarity for brevity, don't make it.

## Steps

### 1. Resolve scope

Respect any explicit scope the user gave. Otherwise walk the hierarchy in order:

1. **Uncommitted / in-progress changes:** `git status --porcelain --untracked-files=all`. Non-empty → this is the scope.
2. **This session's work:** files this conversation edited or committed. Recover them from the conversation itself, or from the commits it made (`git show --stat <sha>...`) / the PR it opened. This is strictly *this session's* work — do not pull in someone else's recent commit or PR just because it's fresh.
3. **The entire repo:** `git ls-files`. Only when 1 and 2 are empty, or it isn't a git repo.

Read the resulting files to gather context before reviewing.

### 2. Review code for leanness

Read the in-scope files and ask of each piece: *is this the simplest implementation that works?* Look for what can go or get simpler:

- **Dead / unreachable code** — unused functions, vars, imports, exports, params, branches that can't be hit. Before flagging something as unused, grep its identifier across the whole repo (not just the diff) — dynamic use won't show in scope.
- **Over-engineering** — abstractions, config, or indirection with a single caller; premature generality; layers that only pass through. Inline or collapse.
- **Redundancy** — anything that can be simplified, omitted, or removed because redundant: duplicated logic that wants one helper; re-derived values; data fetched or stored that nothing consumes.
- **Needless defence-in-depth** — guards that can be removed: validation for states that can't occur, try/catch around code that can't throw, null checks the types already rule out, fallbacks nothing triggers.
- **Typing that can be simplified** — let inference do the work; drop annotations, casts, and generics that add nothing.
- **Needless complexity** — a loop where a map does; nested conditionals that flatten; manual work a stdlib/idiom already does.
- **Comments that restate code** — remove; keep only *why* (non-obvious rationale/constraint).
- **Unused dependencies** — declared but not imported.

Match the surrounding code's style and altitude. Don't trade readability for terseness, and don't rewrite working logic just to touch it — every suggestion must make it *simpler*, not merely *different*.

### 3. Review structure / organization

- Files in the wrong place, or a flat dump that wants subdirectories (or vice-versa).
- Inconsistent naming vs. the project's conventions.
- Misplaced concerns (a helper living next to unrelated code, tests far from source).

Propose moves as `from → to` with a reason. **Do not move or rename anything yet.**

### 4. Propose, then apply

- Present findings in the Output Format below.
- **Structure changes:** use `AskUserQuestion` (or a clear yes/no) and wait for approval. On approval, prefer `git mv` so history is preserved; then fix imports/references the move breaks.
- **Code simplifications:** apply the clear, low-risk ones directly (they show up in the diff); ask when a change is judgment-heavy or could alter behavior.
- Keep every diff minimal and reviewable. After applying, run a quick build/test/typecheck if one is readily available, and confirm nothing broke.

## Output Format

```
## Hygiene review — <repo>  (scope: uncommitted | this session's work | project)

### Code — simplify / trim
- file:line — what to remove/simplify and why  [applied | proposed]

### Structure / organization  (needs approval before moving)
- from → to — reason

### Already lean
- brief note on what's in good shape (so the user knows it was checked, not skipped)

Approve the structure moves?  Apply the code changes?
```

## Anti-Patterns

- **Moving/renaming files without approval.** Structure changes are always confirmed first.
- **Removing build artifacts / generated files.** Out of scope — that's `.gitignore`'s job.
- **Flagging "unused" from the diff alone.** Grep the whole repo; dynamic/external use hides.
- **Change for its own sake.** Every edit must make code simpler, not just different.
- **Terseness over clarity.** Don't collapse readable code into a clever one-liner.
- **Reviewing the whole project when only a small change is uncommitted.** Respect scope.
- **Turning hygiene into a refactor.** Trim and reorganize; don't redesign the logic.
