# Copilot Instructions for ai-skills-inventory

You are working on the **ai-skills-inventory** repository — a curated collection of agent-agnostic AI skills and agents following the AgentSkills spec.

## Repository Structure

```
skills/           # AI skills (reusable capabilities)
  <skill-name>/
    SKILL.md      # Skill definition with YAML frontmatter
    scripts/      # Optional helper scripts
    references/   # Optional reference docs
agents/           # AI agent definitions (persona/role configs)
  <agent-name>/
    AGENT.md      # Agent definition with YAML frontmatter
install.sh        # Symlinks skills and agents to standard locations
uninstall.sh      # Removes symlinks
```

## Creating Skills

Each skill must have a `SKILL.md` with YAML frontmatter:

```yaml
---
name: <skill-name>
description: <one-line description>
---
```

Followed by a markdown body with:
- What the skill does
- Prerequisites and setup
- Usage instructions
- Scripts reference (if any)

Skills must be **agent-agnostic** — they should work with any AI agent (OpenCode, OpenClaw, Claude Code, etc.). Do NOT include platform-specific configuration. Instead, instruct the agent to store learned context in its own memory/workspace.

## Creating Agents

Each agent must have an `AGENT.md` with YAML frontmatter:

```yaml
---
name: <agent-name>
description: <one-line description>
model: ""
mode: subagent
tools:
  read: true
  edit: true
  write: true
  bash: true
  glob: true
  grep: true
  fetch: true
  browser: true
---
```

Followed by a markdown system prompt defining the agent's persona, expertise, and behavior.

## Guidelines

- Follow existing patterns in the repo (look at `skills/example/`, `skills/github/`, `agents/architecture-review/`)
- Include `scripts/` for any helper scripts the skill needs
- Include `references/` for API docs or other reference material
- Keep skills focused on a single capability
- Always create a PR referencing the issue number
