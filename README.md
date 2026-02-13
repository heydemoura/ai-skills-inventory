# AI Skill Inventory

A curated collection of skills for AI agents. Platform-agnostic, easily installable.

## Install

```bash
git clone https://github.com/YOUR_USER/ai-skill-inventory.git
cd ai-skill-inventory
./install.sh
```

The installer will:

1. Create `~/.agents/skills/` if it doesn't exist
2. Symlink each skill from this repo into `~/.agents/skills/`
3. If OpenClaw is detected, automatically add `~/.agents/skills/` to `skills.load.extraDirs` in your config

## Uninstall

```bash
./uninstall.sh
```

Removes symlinks and (optionally) the OpenClaw config entry.

## Adding Skills

Drop a new skill folder into `skills/` with a `SKILL.md` file:

```
skills/
  my-skill/
    SKILL.md
    scripts/       # optional
    references/    # optional
```

Then re-run `./install.sh` to symlink the new skill.

## Skill Format

Each skill needs a `SKILL.md` with YAML frontmatter:

```markdown
---
name: my-skill
description: What this skill does.
---

# My Skill

Instructions for the AI agent...
```

This follows the [AgentSkills](https://agentskills.io) spec.

## Structure

```
ai-skill-inventory/
├── skills/           # Skill folders live here
├── install.sh        # Install/update symlinks
├── uninstall.sh      # Remove symlinks + config
└── README.md
```

## License

MIT
