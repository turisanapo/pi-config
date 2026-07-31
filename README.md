# pi configuration

Versioned configuration for the [pi coding agent](https://github.com/earendil-works/pi-coding-agent),
tracked in place at `~/.pi`.

## Contents

| Path | Purpose |
|---|---|
| `agent/AGENTS.md` | Global operating instructions loaded into every session |
| `agent/settings.json` | Default provider and model, theme, installed packages |
| `agent/agents/` | Subagent definitions: `scout`, `planner`, `reviewer`, `worker` |
| `agent/prompts/` | Prompt templates invoked as `/implement`, `/scout-and-plan`, ... |
| `agent/skills/` | Skills discovered by description matching |
| `agent/extensions/subagent/` | Extension providing the `subagent` tool |

## Setup on a new machine

```bash
git clone <this-repo> ~/.pi
```

Then supply the excluded credentials: authenticate the provider through pi, and
recreate `~/.pi/web-search.json` with a search provider API key.
