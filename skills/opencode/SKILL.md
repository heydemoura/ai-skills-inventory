---
name: opencode
description: Configure and manage OpenCode — the open-source AI coding agent. Covers config, agents, commands, MCP servers, providers, skills, permissions, and project setup.
---

# OpenCode Configuration Skill

Reference guide for configuring [OpenCode](https://opencode.ai), the open-source AI coding agent (terminal, desktop, and IDE extension).

## Config Files

OpenCode uses JSON/JSONC config files. Precedence (later overrides earlier):
1. Remote config (`.well-known/opencode`) — organizational defaults
2. Global: `~/.config/opencode/opencode.json` — user preferences
3. Custom: `OPENCODE_CONFIG` env var — custom overrides
4. Project: `opencode.json` in project root — project-specific
5. `.opencode/` directories — agents, commands, plugins
6. Inline: `OPENCODE_CONFIG_CONTENT` env var — runtime overrides

Schema: `https://opencode.ai/config.json`

## Quick Config Template

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  // Main model
  "model": "anthropic/claude-sonnet-4-5",
  // Cheaper model for titles, summaries
  "small_model": "anthropic/claude-haiku-4-5",
  // Theme
  "theme": "opencode",
  // Auto-update
  "autoupdate": true,
  // Provider overrides
  "provider": {},
  // Tool permissions
  "permission": {},
  // Custom agents
  "agent": {},
  // Custom commands
  "command": {},
  // MCP servers
  "mcp": {},
  // Formatters
  "formatter": {},
  // Instructions (extra rule files)
  "instructions": [],
  // Compaction
  "compaction": { "auto": true, "prune": true, "reserved": 10000 },
  // Sharing
  "share": "manual",
  // Disabled providers
  "disabled_providers": []
}
```

## Agents

Two types: **primary** (Tab to cycle) and **subagent** (invoked via `@name` or by primary agents).

Built-in: `build` (full access), `plan` (read-only), `general` (subagent, full access), `explore` (subagent, read-only).

### Define agents in JSON
```jsonc
{
  "agent": {
    "review": {
      "description": "Code review agent",
      "mode": "subagent",          // primary | subagent | all
      "model": "anthropic/claude-sonnet-4-5",
      "temperature": 0.1,          // 0.0-1.0
      "prompt": "{file:./prompts/review.txt}",
      "steps": 10,                 // max agentic iterations
      "color": "#ff6b6b",          // hex or theme color
      "tools": { "write": false, "edit": false },
      "permission": {
        "bash": { "*": "ask", "git log*": "allow" },
        "edit": "deny",
        "task": { "*": "deny", "explore": "allow" }
      }
    }
  }
}
```

### Define agents in Markdown
Place in `~/.config/opencode/agents/` (global) or `.opencode/agents/` (project).

File `review.md`:
```markdown
---
description: Code review agent
mode: subagent
model: anthropic/claude-sonnet-4-5
temperature: 0.1
tools:
  write: false
  edit: false
permission:
  edit: deny
  bash:
    "*": ask
    "git diff": allow
---
Your review instructions here...
```

### Agent options
| Option | Description |
|--------|-------------|
| `description` | What the agent does (required) |
| `mode` | `primary`, `subagent`, or `all` (default: `all`) |
| `model` | Override model (`provider/model-id`) |
| `temperature` | 0.0-1.0 (lower = more focused) |
| `steps` | Max agentic iterations |
| `prompt` | System prompt or `{file:./path}` |
| `tools` | Enable/disable tools (`true`/`false`, wildcards ok) |
| `permission` | Per-tool permissions (`allow`/`ask`/`deny`) |
| `color` | UI color (hex or theme name) |
| `hidden` | Hide from `@` autocomplete |
| `disable` | Disable the agent |
| `top_p` | Alternative to temperature for diversity |
| `default_agent` | Set default primary agent globally |

## Commands

Custom slash commands for repetitive tasks.

### JSON
```jsonc
{
  "command": {
    "test": {
      "template": "Run tests with coverage.\nFocus on failures and suggest fixes.",
      "description": "Run tests with coverage",
      "agent": "build",
      "model": "anthropic/claude-haiku-4-5",
      "subtask": false
    }
  }
}
```

### Markdown
Place in `~/.config/opencode/commands/` or `.opencode/commands/`.

File `test.md`:
```markdown
---
description: Run tests with coverage
agent: build
---
Run the full test suite with coverage. Focus on failures.
```

### Prompt features
- `$ARGUMENTS` — all args passed to the command
- `$1`, `$2`, etc. — positional args
- `` !`command` `` — inject shell output
- `@file/path` — include file content

## Providers

Model format: `provider/model-id` (e.g. `anthropic/claude-sonnet-4-5`).

Credentials stored in `~/.local/share/opencode/auth.json` via `/connect`.

### Provider config
```jsonc
{
  "provider": {
    "anthropic": {
      "options": {
        "baseURL": "https://api.anthropic.com/v1",
        "timeout": 600000,
        "setCacheKey": true
      }
    }
  },
  "disabled_providers": ["openai"]
}
```

Common providers: `anthropic`, `openai`, `google`, `amazon-bedrock`, `azure-openai`, `openrouter`, `groq`, `deepseek`, `ollama`, `opencode` (Zen).

## Tools

Built-in: `bash`, `edit`, `write`, `read`, `grep`, `glob`, `list`, `patch`, `skill`, `todowrite`, `todoread`, `webfetch`, `websearch`, `question`, `lsp` (experimental).

### Enable/disable globally
```jsonc
{ "tools": { "write": false, "bash": false } }
```

### Permissions
```jsonc
{
  "permission": {
    "edit": "allow",    // allow | ask | deny
    "bash": {
      "*": "ask",
      "git status*": "allow",
      "rm *": "deny"
    },
    "webfetch": "allow",
    "mymcp_*": "ask"    // wildcards for MCP tools
  }
}
```

## MCP Servers

### Local
```jsonc
{
  "mcp": {
    "my-server": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-command"],
      "environment": { "MY_KEY": "value" },
      "enabled": true,
      "timeout": 5000
    }
  }
}
```

### Remote
```jsonc
{
  "mcp": {
    "my-remote": {
      "type": "remote",
      "url": "https://mcp.example.com/mcp",
      "headers": { "Authorization": "Bearer KEY" },
      "enabled": true
    }
  }
}
```

### OAuth (automatic)
```jsonc
{
  "mcp": {
    "sentry": {
      "type": "remote",
      "url": "https://mcp.sentry.dev/mcp",
      "oauth": {}
    }
  }
}
```
Then run: `opencode mcp auth sentry`

### Per-agent MCP control
```jsonc
{
  "tools": { "my-mcp*": false },
  "agent": {
    "my-agent": {
      "tools": { "my-mcp*": true }
    }
  }
}
```

## Rules & Instructions

### AGENTS.md (project rules)
Place `AGENTS.md` in project root. Fallback: `CLAUDE.md`.

### Global rules
`~/.config/opencode/AGENTS.md` (fallback: `~/.claude/CLAUDE.md`)

### Extra instruction files
```jsonc
{
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md",
    "https://example.com/rules.md"
  ]
}
```

Generate with `/init` command in TUI.

## Skills

Skills are reusable `SKILL.md` definitions loaded on-demand.

Locations searched:
- `.opencode/skills/*/SKILL.md` (project)
- `~/.config/opencode/skills/*/SKILL.md` (global)
- `.agents/skills/*/SKILL.md` (project, agent-compatible)
- `~/.agents/skills/*/SKILL.md` (global, agent-compatible)
- `.claude/skills/*/SKILL.md` (Claude-compatible)
- `~/.claude/skills/*/SKILL.md` (Claude-compatible)

### Skill permissions
```jsonc
{
  "permission": {
    "skill": {
      "*": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

## Other Settings

### Compaction
```jsonc
{ "compaction": { "auto": true, "prune": true, "reserved": 10000 } }
```

### Formatters
```jsonc
{
  "formatter": {
    "prettier": { "disabled": true },
    "custom": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "extensions": [".js", ".ts", ".jsx", ".tsx"]
    }
  }
}
```

### TUI
```jsonc
{
  "tui": {
    "scroll_speed": 3,
    "scroll_acceleration": { "enabled": true },
    "diff_style": "auto"
  }
}
```

### Server
```jsonc
{
  "server": {
    "port": 4096,
    "hostname": "0.0.0.0",
    "mdns": true,
    "cors": ["http://localhost:5173"]
  }
}
```

### Watcher
```jsonc
{ "watcher": { "ignore": ["node_modules/**", "dist/**"] } }
```

## CLI Quick Reference

```bash
opencode                    # Start TUI
opencode run "prompt"       # Run single prompt
opencode serve              # Start server mode
opencode web                # Start web UI
opencode agent create       # Create new agent interactively
opencode mcp auth <name>    # Authenticate MCP server
opencode mcp list           # List MCP servers
```

### TUI Commands
- `/init` — Generate AGENTS.md for project
- `/connect` — Add provider API key
- `/models` — Select model
- `/share` — Share conversation
- `/undo` / `/redo` — Undo/redo changes
- `/help` — Show help
- `Tab` — Cycle between primary agents

## Docs
Full documentation: https://opencode.ai/docs
