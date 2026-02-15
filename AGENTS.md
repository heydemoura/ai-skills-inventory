# AGENTS.md

## Project: AI Skills Inventory

A curated collection of agent-agnostic AI skills following the [AgentSkills](https://agentskills.io) spec.

## Structure

```
ai-skill-inventory/
├── skills/           # Skill folders
│   ├── example/      # Template skill
│   ├── github/       # GitHub CLI skill
│   ├── opencode/     # OpenCode config skill
│   └── <name>/       # Each skill is a directory
│       ├── SKILL.md  # Required: skill definition with YAML frontmatter
│       ├── scripts/  # Optional: executable scripts
│       └── references/ # Optional: reference docs
├── install.sh        # Symlinks skills to ~/.agents/skills/
├── uninstall.sh      # Removes symlinks
└── README.md
```

## Skill Format

Every skill must have a `SKILL.md` with YAML frontmatter:

```markdown
---
name: my-skill
description: What this skill does — used for skill discovery and matching.
metadata: {"openclaw":{"emoji":"🔧","requires":{"anyBins":["tool1","tool2"]}}}
---

# Skill Title

Instructions for the AI agent on how to use this skill...
```

### Frontmatter Fields

- **name** (required): Skill identifier, lowercase with hyphens
- **description** (required): Clear description of what the skill does and when to use it
- **metadata** (optional): Platform-specific metadata (e.g., OpenClaw emoji, required binaries)

## Conventions

- Skills are **agent-agnostic** — they should work with any AI agent that supports the AgentSkills spec
- Skills should **not** store user-specific data — instruct the agent to store learned context in its own memory
- Scripts should be **portable** (bash, common CLI tools)
- Keep skills **self-contained** — minimize external dependencies
- Use `scripts/` for executable tools, `references/` for static documentation the agent should read
