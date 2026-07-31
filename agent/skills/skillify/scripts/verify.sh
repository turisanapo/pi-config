#!/usr/bin/env bash
# Verify a pi skill: frontmatter parses, limits respected, pi lists it.
set -euo pipefail

usage() { echo "usage: verify.sh <skill-name-or-path>" >&2; exit 2; }
[ $# -eq 1 ] || usage

target=$1
if [ -d "$target" ]; then
	skill_file="$target/SKILL.md"
	name=$(basename "$target")
else
	name=$target
	skill_file=""
	for candidate in \
		"$HOME/.pi/agent/skills/$name/SKILL.md" \
		"$HOME/.pi/agent/skills/$name.md" \
		".pi/skills/$name/SKILL.md" \
		".pi/skills/$name.md" \
		"$HOME/.agents/skills/$name/SKILL.md" \
		".agents/skills/$name/SKILL.md"; do
		[ -f "$candidate" ] && { skill_file=$candidate; break; }
	done
fi

[ -n "$skill_file" ] && [ -f "$skill_file" ] || { echo "FAIL: no SKILL.md found for '$name'" >&2; exit 1; }
echo "file: $skill_file"

python3 - "$skill_file" <<'PY'
import re, sys, yaml

path = sys.argv[1]
text = open(path).read()
match = re.match(r"^---\n(.*?)\n---\n", text, re.S)
if not match:
    sys.exit("FAIL: no YAML frontmatter block")

try:
    meta = yaml.safe_load(match.group(1))
except yaml.YAMLError as error:
    sys.exit(f"FAIL: frontmatter does not parse: {error}\n"
             "hint: an unquoted description containing ': ' breaks YAML; use a '>-' block scalar")

if not isinstance(meta, dict):
    sys.exit("FAIL: frontmatter is not a mapping")

problems = []
name = meta.get("name")
description = meta.get("description")

if not name:
    problems.append("name is missing")
elif not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", name):
    problems.append(f"name '{name}' must be lowercase a-z, 0-9, single hyphens, no leading/trailing hyphen")
elif len(name) > 64:
    problems.append(f"name is {len(name)} chars, max 64")

if not description:
    problems.append("description is missing — pi will not load this skill")
elif len(description) > 1024:
    problems.append(f"description is {len(description)} chars, max 1024")

tools = meta.get("allowed-tools")
if isinstance(tools, list):
    problems.append("allowed-tools is a YAML list; pi expects a space-delimited string")
elif isinstance(tools, str):
    known = {"read", "write", "edit", "bash", "grep", "find", "ls"}
    unknown = [t for t in tools.split() if t not in known]
    if unknown:
        problems.append(f"allowed-tools has unknown or non-lowercase entries: {', '.join(unknown)}")

if problems:
    sys.exit("FAIL:\n  - " + "\n  - ".join(problems))

print(f"frontmatter: ok (name={name}, description={len(description)} chars)")
PY

echo "checking discovery..."
if pi -p --no-session --no-context-files \
	"List the exact names of every skill available to you, one per line, then stop. Do not use any tools." \
	2>/dev/null | grep -qx "$name"; then
	echo "discovery: ok ($name is listed)"
	echo "PASS"
else
	echo "FAIL: pi does not list '$name' — check name collisions and skill locations" >&2
	exit 1
fi
