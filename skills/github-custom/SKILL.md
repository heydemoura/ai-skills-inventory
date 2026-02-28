---
name: github-custom
description: Interact with GitHub repositories — create repos, manage issues, PRs, branches, releases, and more. Uses gh CLI for authenticated operations and REST API for public reads.
metadata: {"openclaw":{"emoji":"🐙","requires":{"anyBins":["gh","curl"]}}}
---

# GitHub Skill

Interact with GitHub using two approaches:
- **`gh` CLI** — for authenticated operations (create, edit, delete, push, PRs, etc.)
- **REST API via `curl`** — for reading public repos/data without auth (faster, no login needed)

## Authentication

For `gh` CLI operations, authenticate first:
```bash
gh auth login
```

## Public Data (REST API — no auth required)

Use `curl` to read public repositories, users, and content without authentication.

### View public repo info
```bash
curl -s https://api.github.com/repos/<owner/repo> | python3 -m json.tool
```

### List public repos for a user
```bash
curl -s "https://api.github.com/users/<user>/repos?per_page=30&sort=updated"
```

### Get public file contents
```bash
curl -s https://api.github.com/repos/<owner/repo>/contents/<path> | python3 -c "import sys,json,base64; print(base64.b64decode(json.load(sys.stdin)['content']).decode())"
```

### List public releases
```bash
curl -s https://api.github.com/repos/<owner/repo>/releases
```

### List public issues
```bash
curl -s "https://api.github.com/repos/<owner/repo>/issues?state=open&per_page=30"
```

### List branches (public repo)
```bash
curl -s https://api.github.com/repos/<owner/repo>/branches
```

### Get public user profile
```bash
curl -s https://api.github.com/users/<username>
```

### Search (public)
```bash
# Search repos
curl -s "https://api.github.com/search/repositories?q=<query>&per_page=10"

# Search code
curl -s "https://api.github.com/search/code?q=<query>+repo:<owner/repo>"

# Search issues
curl -s "https://api.github.com/search/issues?q=<query>"
```

### Rate limits
- Unauthenticated: 60 requests/hour (by IP)
- Add `--jq` or pipe through `python3 -m json.tool` for readability

## Authenticated Operations (gh CLI)

Use `gh` for anything that requires write access or private data.

### Repositories
- `gh repo list [owner] --limit 20` — List repos
- `gh repo create <name> --public|--private [--description "desc"]` — Create repo
- `gh repo view <owner/repo>` — View repo details
- `gh repo clone <owner/repo>` — Clone a repo
- `gh repo delete <owner/repo> --yes` — Delete repo
- `gh repo fork <owner/repo>` — Fork a repo
- `gh repo edit <owner/repo> --description "new desc"` — Edit repo metadata

### Issues
- `gh issue list -R <owner/repo> [--state open|closed|all]` — List issues
- `gh issue create -R <owner/repo> --title "title" [--body "body"] [--label "l1,l2"]` — Create issue
- `gh issue view <number> -R <owner/repo>` — View issue
- `gh issue close <number> -R <owner/repo>` — Close issue
- `gh issue reopen <number> -R <owner/repo>` — Reopen issue
- `gh issue comment <number> -R <owner/repo> --body "comment"` — Add comment
- `gh issue edit <number> -R <owner/repo> --title "new title"` — Edit issue

### Pull Requests
- `gh pr list -R <owner/repo> [--state open|closed|merged|all]` — List PRs
- `gh pr create -R <owner/repo> --title "title" --head <branch> [--base main] [--body "desc"]` — Create PR
- `gh pr view <number> -R <owner/repo>` — View PR details
- `gh pr merge <number> -R <owner/repo> [--merge|--squash|--rebase]` — Merge PR
- `gh pr checkout <number> -R <owner/repo>` — Checkout PR locally
- `gh pr diff <number> -R <owner/repo>` — View PR diff
- `gh pr review <number> -R <owner/repo> --approve|--comment|--request-changes` — Review PR

### Releases
- `gh release list -R <owner/repo>` — List releases
- `gh release create <tag> -R <owner/repo> [--title "name"] [--notes "notes"] [--draft] [--prerelease]` — Create release
- `gh release view <tag> -R <owner/repo>` — View release
- `gh release download <tag> -R <owner/repo>` — Download release assets
- `gh release delete <tag> -R <owner/repo> --yes` — Delete release

### Search (authenticated, higher rate limit)
- `gh search repos <query> --limit 10` — Search repos
- `gh search code <query> [--repo owner/repo]` — Search code
- `gh search issues <query>` — Search issues/PRs
- `gh search prs <query>` — Search PRs specifically

### User & Auth
- `gh auth status` — Check auth status
- `gh api /user --jq '.login'` — Show authenticated user

### Gists
- `gh gist list` — List gists
- `gh gist create <file> [--desc "description"] [--public]` — Create gist from file
- `gh gist view <id>` — View gist

### Workflows (CI/CD)
- `gh run list -R <owner/repo>` — List workflow runs
- `gh run view <id> -R <owner/repo>` — View run details
- `gh run watch <id> -R <owner/repo>` — Watch run in progress
- `gh workflow list -R <owner/repo>` — List workflows
- `gh workflow run <workflow> -R <owner/repo>` — Trigger workflow

### API (for anything not covered)
- `gh api <endpoint>` — GET request
- `gh api <endpoint> -X POST -f key=value` — POST request
- `gh api <endpoint> --jq '<filter>'` — Filter JSON output

## Tips
- **Public reads** → use `curl` (no auth, fast, 60 req/hr)
- **Writes / private data** → use `gh` (authenticated, 5,000 req/hr)
- Use `-R owner/repo` to target a repo without being in its directory
- Use `--json field1,field2 --jq '.[]'` for structured output
- Docs: https://cli.github.com/manual/ | https://docs.github.com/en/rest
