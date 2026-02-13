---
name: github
description: Interact with GitHub repositories — create repos, manage issues, PRs, branches, releases, and more using the gh CLI.
metadata: {"openclaw":{"emoji":"🐙","requires":{"bins":["gh"]}}}
---

# GitHub Skill

Interact with GitHub using the `gh` CLI. Authenticate with `gh auth login` before use.

## Quick Reference

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

### Branches
- `gh api repos/<owner/repo>/branches --jq '.[].name'` — List branches
- `gh api repos/<owner/repo>/git/refs -f ref=refs/heads/<name> -f sha=<sha>` — Create branch

### Releases
- `gh release list -R <owner/repo>` — List releases
- `gh release create <tag> -R <owner/repo> [--title "name"] [--notes "notes"] [--draft] [--prerelease]` — Create release
- `gh release view <tag> -R <owner/repo>` — View release
- `gh release download <tag> -R <owner/repo>` — Download release assets
- `gh release delete <tag> -R <owner/repo> --yes` — Delete release

### Search
- `gh search repos <query> --limit 10` — Search repos
- `gh search code <query> [--repo owner/repo]` — Search code
- `gh search issues <query>` — Search issues/PRs
- `gh search prs <query>` — Search PRs specifically

### User & Auth
- `gh auth status` — Check auth status
- `gh api /user --jq '.login'` — Show authenticated user
- `gh api /users/<username>` — Get user profile

### Files & Content
- `gh api repos/<owner/repo>/contents/<path> --jq '.content' | base64 -d` — Get file contents
- `gh browse -R <owner/repo>` — Open repo in browser

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
- Use `-R owner/repo` to target a repo without being in its directory
- Use `--json field1,field2 --jq '.[]'` for structured output
- Pipe to `--jq` for filtering JSON responses
- Rate limits: 5,000 requests/hour for authenticated requests
- Docs: https://cli.github.com/manual/
