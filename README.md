# AI Skill Inventory

A curated collection of **skills** and **agents** for AI coding assistants. Platform-agnostic, easily installable.

- **Skills** — Knowledge and tool definitions that give AI agents specific capabilities
- **Agents** — Reusable persona/role definitions that configure AI agents with specialized expertise

Works with [OpenCode](https://github.com/sst/opencode), [OpenClaw](https://openclaw.app), [Claude Code](https://docs.anthropic.com/en/docs/agents), and other AI coding tools.

## Install

```bash
git clone https://github.com/heydemoura/ai-skills-inventory.git
cd ai-skills-inventory
./install.sh
```

The installer will:

1. Create `~/.agents/skills/` and `~/.agents/agents/` if they don't exist
2. Symlink each skill from `skills/` into `~/.agents/skills/`
3. Symlink each agent from `agents/` into `~/.agents/agents/`
4. Symlink agent definitions into `~/.config/opencode/agents/` for OpenCode integration
5. If OpenClaw is detected, add `~/.agents/skills/` to `skills.load.extraDirs` in your config

## Uninstall

```bash
./uninstall.sh
```

Removes all symlinks (skills, agents, OpenCode agents) and optionally cleans up the OpenClaw config entry.

## Skills

Skills provide knowledge, instructions, and tool definitions that enhance what an AI agent can do.

Each skill is a directory with a `SKILL.md` file:

```
skills/
  my-skill/
    SKILL.md
    scripts/       # optional
    references/    # optional
```

### Skill Format

```markdown
---
name: my-skill
description: What this skill does.
---

# My Skill

Instructions for the AI agent...
```

This follows the [AgentSkills](https://agentskills.io) spec.

### Available Skills

| Skill | Description |
|-------|-------------|
| `example` | Example skill template |
| `github` | GitHub CLI workflows |
| `opencode` | OpenCode editor integration |

## Agents

Agents are reusable AI persona/role definitions. Each agent defines a specialized expert with a specific perspective, analysis framework, and output format. Unlike skills (which add knowledge/tools), agents configure *who* the AI is and *how* it approaches problems.

Each agent is a directory with an `AGENT.md` file:

```
agents/
  my-agent/
    AGENT.md
```

### Agent Format

```markdown
---
name: my-agent
description: One-line description of the agent's role.
mode: subagent
tools:
  write: false
  edit: false
---

# My Agent

System prompt and instructions...
```

The `mode` and `tools` fields are OpenCode-native but serve as useful metadata for any platform.

### Available Agents

| Agent | Description |
|-------|-------------|
| `architecture-review` | Senior systems architect — design patterns, module boundaries, scalability, technical debt |
| `performance-review` | Senior performance engineer — algorithmic complexity, memory, queries, caching |
| `security-review` | Senior security specialist — injection flaws, auth, data exposure, OWASP top 10 |
| `test-review` | Senior test engineer — coverage gaps, edge cases, test quality; writes test code |
| `design-review` | Senior UI/UX designer — accessibility, responsive design, user flows, consistency |
| `product-review` | Senior product manager — feature scope, user stories, market fit, go-to-market |

### Using Agents

**With OpenCode:** Agents are automatically installed to `~/.config/opencode/agents/` by the installer. They appear as available agents you can invoke in your OpenCode sessions.

**With OpenClaw:** Copy or symlink the `AGENT.md` file content into your agent configuration. The YAML frontmatter provides the metadata and the markdown body is the system prompt.

**With Claude Code:** Use the `AGENT.md` content as a system prompt or project instruction. The format is standard markdown that works anywhere.

**With any tool:** The `AGENT.md` files are self-contained markdown documents. The YAML frontmatter provides structured metadata and the body provides the full system prompt. Use them however your tool supports custom agent/persona definitions.

## Adding New Content

### Adding a Skill

1. Create a new directory under `skills/` with a `SKILL.md` file
2. Re-run `./install.sh` to symlink the new skill

### Adding an Agent

1. Create a new directory under `agents/` with an `AGENT.md` file
2. Include YAML frontmatter with `name`, `description`, `mode`, and `tools`
3. Write a thorough system prompt in the markdown body that:
   - Establishes the persona and expertise
   - Defines what they analyze and how
   - Specifies a structured output format
   - Is constructive, not just critical
4. Re-run `./install.sh` to symlink the new agent

## Structure

```
ai-skills-inventory/
├── skills/           # Skill definitions
├── agents/           # Agent definitions
├── install.sh        # Install/update symlinks
├── uninstall.sh      # Remove symlinks + config
└── README.md
```

## License

MIT
