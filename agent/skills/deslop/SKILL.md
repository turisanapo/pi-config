---
name: deslop
description: "Diff-scoped cleanup pass that removes AI slop from the current branch diff before review: comments that restate code, defensive checks for impossible states, type-laundering casts, one-use variables and helpers, unneeded shims, and style drift. Use when the user says \"deslop\", \"clean up the diff\", \"remove slop\", or before a review pass on AI-written changes."
---

# Deslop

Clean only the current branch diff. Preserve behavior absolutely.

## Checklist

1. Scope the pass to `git diff` against the merge base of the default branch (`git merge-base HEAD origin/main`, or the repo's default branch), plus uncommitted changes. Never run a repo-wide cleanup.
2. Inspect every changed hunk for:
   - comments a human maintainer would not write: narration, syntax explanation, and prose that restates the code;
   - defensive checks or `try`/`catch` blocks that are abnormal for the surrounding module or protect only imagined states;
   - casts that launder types, such as `as any`, `as unknown as T`, `# type: ignore`, and widen-then-assert flows;
   - intermediate variables or one-use helpers that add no domain meaning, remove no duplication, and do not simplify control flow;
   - compatibility shims, aliases, retries, and fallback branches with no named contract that needs them;
   - naming, control flow, imports, and formatting that conflict with the surrounding file.
3. Make no functional edits. If a cleanup could change behavior, leave it and report it.
4. Fix a finding inline only when the fix is trivial and behavior-neutral. Otherwise note it for the author.
5. Report the result in 1–3 sentences: whether anything changed, and each non-trivial item left for review.

Run deslop before a review pass, never instead of one. The review stays the correctness and safety gate.
