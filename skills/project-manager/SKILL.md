---
name: project-manager
description: Manage and provide context for all projects under ~/code. Use when working across multiple projects, integrating projects together, checking project status, adding new projects, or when any task references code/builds/configs from existing projects. Triggers on questions about project structure, dependencies, build status, or cross-project integration (e.g., "rebuild X and update Y", "what projects do I have", "add a new module to X").
metadata: {"openclaw":{"emoji":"📂","requires":{"anyBins":["bash","git"]}}}
---

# Project Manager

Provides awareness of all user projects, their structure, dependencies, and integration points.

## Project Location

All projects live under **`~/code/`**.

If your projects are stored elsewhere, symlink them (or the parent folder) into `~/code/`:

```bash
# Symlink an individual project
ln -s /path/to/my-project ~/code/my-project

# Symlink only the projects you want managed
ln -s /data/work/api-server ~/code/api-server
ln -s /data/work/frontend ~/code/frontend
```

This way you control exactly which projects the skill is aware of.

## Discovery

### Scan all projects
```bash
bash scripts/project-scan.sh
```
Scans `~/code` for projects, detects agent files (AGENTS.md, CLAUDE.md, CURSOR.md), shows git status, key build files, and disk usage.

### Learning about a project
When you encounter a new project or need deeper context:
1. Run `scripts/project-scan.sh` to get a live snapshot
2. Read the project's agent file (`AGENTS.md`, `CLAUDE.md`, `CURSOR.md`) and `README.md`
3. Examine key build files (`Makefile`, `CMakeLists.txt`, `package.json`, etc.)
4. Store what you learn in your memory (see below)

## Memory

Project knowledge lives in your **agent memory**, not in this skill's files.

### Where to store project context
- **`MEMORY.md`** → Curated project index: what each project is, its stack, key paths, status, and lessons learned
- **`memory/YYYY-MM-DD.md`** → Daily notes about project work, build results, issues encountered

### What to remember about each project
- Type and purpose
- Stack (languages, frameworks, databases)
- Key paths (source, build output, configs)
- Current status (working, broken, in-progress)
- Important lessons or gotchas

### What to remember about project relationships
- Which projects depend on each other
- Integration patterns (e.g., "when A is rebuilt, B's artifacts must be regenerated")
- Shared resources (databases, configs, services)

### Keeping it fresh
- After significant project work, update your memory with new findings
- When a project's status changes, reflect that in MEMORY.md
- Periodically re-run the scan to catch new projects or changes

## Per-Project Context

Projects use standard agent files for in-project context:
- `AGENTS.md` / `CLAUDE.md` / `CURSOR.md` — read these when working inside a specific project
- `README.md` — general project documentation

When working on a task that touches a project, read its agent file for project-specific conventions and context.

## Workflows

### Adding a New Project
1. Create or symlink the project directory under `~/code/`
2. Add an `AGENTS.md` or similar agent file with project context
3. Run the scan to verify detection
4. Update MEMORY.md with the new project's details
5. If it relates to existing projects, document the dependency in MEMORY.md

### Cross-Project Integration
When a task involves multiple projects:
1. Check your memory for known dependencies and integration patterns
2. Read agent files from each involved project for specific context
3. Follow documented integration patterns
4. After changes, verify downstream projects still work
5. Update memory with any new integration lessons

### Checking Project Status
Run `scripts/project-scan.sh` to get a live snapshot of all projects including git status and dirty files.
