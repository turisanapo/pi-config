#!/usr/bin/env bash
# Print the change to review.
#   no target        local uncommitted changes, untracked files included
#   <a>..<b>         git range
#   <file>           diff file
#   anything else    PR number, URL, or branch, passed to gh
set -euo pipefail

target=${1:-}

if [ -z "$target" ]; then
	git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository: $(pwd)" >&2; exit 1; }
	if git rev-parse --verify -q HEAD >/dev/null; then
		git diff HEAD
	else
		git diff --cached
	fi
	git ls-files --others --exclude-standard -z |
		while IFS= read -r -d '' file; do
			git diff --no-index -- /dev/null "$file" || true
		done
elif [[ $target == *..* ]]; then
	git diff "$target"
elif [ -f "$target" ]; then
	cat -- "$target"
else
	gh pr diff "$target"
fi
