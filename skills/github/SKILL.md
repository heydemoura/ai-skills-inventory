---
name: github
description: Interact with GitHub repositories — create repos, manage issues, PRs, branches, releases, and more via the GitHub API.
metadata: {"openclaw":{"emoji":"🐙","requires":{"bins":["curl"]}}}
---

# GitHub Skill

Interact with GitHub using the REST API. Use the helper script at `{baseDir}/scripts/github.sh` for common operations.

## Setup

A GitHub personal access token (PAT) is required. The script reads it from the `GITHUB_TOKEN` environment variable.

To set it, add to your shell profile or agent config:
```bash
export GITHUB_TOKEN="ghp_..."
```

## Usage

All commands use the helper script:
```bash
bash {baseDir}/scripts/github.sh <command> [args...]
```

## Commands

### Repository
- `repos list [user]` — List repos for a user (default: authenticated user)
- `repos create <name> [--private] [--description "desc"]` — Create a new repo
- `repos get <owner/repo>` — Get repo details
- `repos delete <owner/repo>` — Delete a repo (requires delete_repo scope)
- `repos clone-url <owner/repo>` — Get clone URL

### Issues
- `issues list <owner/repo> [--state open|closed|all]` — List issues
- `issues create <owner/repo> --title "title" [--body "body"] [--labels "l1,l2"]` — Create issue
- `issues get <owner/repo> <number>` — Get issue details
- `issues close <owner/repo> <number>` — Close an issue
- `issues comment <owner/repo> <number> --body "comment"` — Add comment

### Pull Requests
- `prs list <owner/repo> [--state open|closed|all]` — List PRs
- `prs create <owner/repo> --title "title" --head <branch> [--base main] [--body "desc"]` — Create PR
- `prs get <owner/repo> <number>` — Get PR details
- `prs merge <owner/repo> <number> [--method merge|squash|rebase]` — Merge PR

### Branches
- `branches list <owner/repo>` — List branches
- `branches create <owner/repo> <branch-name> [--from main]` — Create branch
- `branches delete <owner/repo> <branch-name>` — Delete branch

### Releases
- `releases list <owner/repo>` — List releases
- `releases create <owner/repo> --tag <tag> [--name "name"] [--body "notes"] [--draft] [--prerelease]` — Create release
- `releases latest <owner/repo>` — Get latest release

### Search
- `search repos <query>` — Search repositories
- `search code <query> [--repo owner/repo]` — Search code
- `search issues <query>` — Search issues/PRs

### User
- `user whoami` — Show authenticated user info
- `user get <username>` — Get user profile

### Files
- `files get <owner/repo> <path> [--ref branch]` — Get file contents
- `files create <owner/repo> <path> --content "content" --message "commit msg" [--branch main]` — Create/update file

### Gists
- `gists list` — List your gists
- `gists create --description "desc" --filename "file.txt" --content "content" [--public]` — Create gist

## Tips
- For complex operations, combine commands or use `curl` directly with the GitHub API
- Rate limits: 5,000 requests/hour for authenticated requests
- Reference: https://docs.github.com/en/rest
