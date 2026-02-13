#!/usr/bin/env bash
# github.sh — GitHub REST API helper
# Usage: bash github.sh <command> <subcommand> [args...]
#
# Requires: GITHUB_TOKEN environment variable

set -euo pipefail

API="https://api.github.com"

if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "Error: GITHUB_TOKEN is not set" >&2
    exit 1
fi

auth_header="Authorization: token $GITHUB_TOKEN"
accept_header="Accept: application/vnd.github.v3+json"

# --- Helpers ---

gh_get() {
    curl -sf -H "$auth_header" -H "$accept_header" "$@"
}

gh_post() {
    curl -sf -X POST -H "$auth_header" -H "$accept_header" -H "Content-Type: application/json" "$@"
}

gh_patch() {
    curl -sf -X PATCH -H "$auth_header" -H "$accept_header" -H "Content-Type: application/json" "$@"
}

gh_put() {
    curl -sf -X PUT -H "$auth_header" -H "$accept_header" -H "Content-Type: application/json" "$@"
}

gh_delete() {
    curl -sf -X DELETE -H "$auth_header" -H "$accept_header" "$@"
}

die() { echo "Error: $*" >&2; exit 1; }

# --- Parse named args ---
# Extracts --key value pairs into associative array
declare -A OPTS
parse_opts() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --*)
                key="${1#--}"
                if [[ $# -gt 1 && ! "$2" =~ ^-- ]]; then
                    OPTS["$key"]="$2"
                    shift 2
                else
                    OPTS["$key"]="true"
                    shift
                fi
                ;;
            *) shift ;;
        esac
    done
}

# =====================================================
# REPOS
# =====================================================

repos_list() {
    local user="${1:-}"
    if [ -n "$user" ]; then
        gh_get "$API/users/$user/repos?per_page=100&sort=updated" | python3 -c "
import sys, json
for r in json.load(sys.stdin):
    vis = '🔒' if r['private'] else '🌐'
    print(f\"{vis} {r['full_name']}  ⭐{r['stargazers_count']}  {r.get('description','') or ''}\")"
    else
        gh_get "$API/user/repos?per_page=100&sort=updated&affiliation=owner" | python3 -c "
import sys, json
for r in json.load(sys.stdin):
    vis = '🔒' if r['private'] else '🌐'
    print(f\"{vis} {r['full_name']}  ⭐{r['stargazers_count']}  {r.get('description','') or ''}\")"
    fi
}

repos_create() {
    local name="$1"; shift
    parse_opts "$@"
    local private="${OPTS[private]:-false}"
    local desc="${OPTS[description]:-}"
    [ "$private" = "true" ] && private="true" || private="false"

    gh_post -d "{\"name\":\"$name\",\"private\":$private,\"description\":\"$desc\"}" "$API/user/repos" | python3 -c "
import sys, json
r = json.load(sys.stdin)
print(f\"✓ Created: {r['full_name']}')
print(f\"  URL: {r['html_url']}')
print(f\"  Clone: {r['ssh_url']}\")"
}

repos_get() {
    local repo="$1"
    gh_get "$API/repos/$repo" | python3 -c "
import sys, json
r = json.load(sys.stdin)
print(f\"Repository: {r['full_name']}\")
print(f\"Description: {r.get('description','') or 'N/A'}\")
print(f\"Stars: {r['stargazers_count']}  Forks: {r['forks_count']}  Issues: {r['open_issues_count']}\")
print(f\"Language: {r.get('language','N/A')}  License: {(r.get('license') or {}).get('name','N/A')}\")
print(f\"URL: {r['html_url']}\")
print(f\"Clone (SSH): {r['ssh_url']}\")
print(f\"Default branch: {r['default_branch']}\")
print(f\"Created: {r['created_at']}  Updated: {r['updated_at']}\")"
}

repos_delete() {
    local repo="$1"
    gh_delete "$API/repos/$repo"
    echo "✓ Deleted: $repo"
}

repos_clone_url() {
    local repo="$1"
    gh_get "$API/repos/$repo" | python3 -c "
import sys, json
r = json.load(sys.stdin)
print(r['ssh_url'])"
}

# =====================================================
# ISSUES
# =====================================================

issues_list() {
    local repo="$1"; shift
    parse_opts "$@"
    local state="${OPTS[state]:-open}"
    gh_get "$API/repos/$repo/issues?state=$state&per_page=30" | python3 -c "
import sys, json
for i in json.load(sys.stdin):
    if 'pull_request' in i: continue
    labels = ', '.join(l['name'] for l in i.get('labels', []))
    labels_str = f' [{labels}]' if labels else ''
    print(f\"#{i['number']} {i['state'].upper()} {i['title']}{labels_str}\")"
}

issues_create() {
    local repo="$1"; shift
    parse_opts "$@"
    local title="${OPTS[title]:-}"
    local body="${OPTS[body]:-}"
    local labels="${OPTS[labels]:-}"
    [ -z "$title" ] && die "Missing --title"

    local labels_json="[]"
    if [ -n "$labels" ]; then
        labels_json=$(python3 -c "import json; print(json.dumps('$labels'.split(',')))")
    fi

    gh_post -d "{\"title\":\"$title\",\"body\":\"$body\",\"labels\":$labels_json}" "$API/repos/$repo/issues" | python3 -c "
import sys, json
i = json.load(sys.stdin)
print(f\"✓ Created issue #{i['number']}: {i['title']}\")
print(f\"  URL: {i['html_url']}\")"
}

issues_get() {
    local repo="$1" number="$2"
    gh_get "$API/repos/$repo/issues/$number" | python3 -c "
import sys, json
i = json.load(sys.stdin)
labels = ', '.join(l['name'] for l in i.get('labels', []))
print(f\"#{i['number']} [{i['state'].upper()}] {i['title']}\")
print(f\"Author: {i['user']['login']}  Created: {i['created_at']}\")
if labels: print(f'Labels: {labels}')
if i.get('body'): print(f\"\\n{i['body']}\")"
}

issues_close() {
    local repo="$1" number="$2"
    gh_patch -d '{"state":"closed"}' "$API/repos/$repo/issues/$number" > /dev/null
    echo "✓ Closed issue #$number"
}

issues_comment() {
    local repo="$1" number="$2"; shift 2
    parse_opts "$@"
    local body="${OPTS[body]:-}"
    [ -z "$body" ] && die "Missing --body"
    gh_post -d "{\"body\":\"$body\"}" "$API/repos/$repo/issues/$number/comments" | python3 -c "
import sys, json
c = json.load(sys.stdin)
print(f\"✓ Comment added: {c['html_url']}\")"
}

# =====================================================
# PULL REQUESTS
# =====================================================

prs_list() {
    local repo="$1"; shift
    parse_opts "$@"
    local state="${OPTS[state]:-open}"
    gh_get "$API/repos/$repo/pulls?state=$state&per_page=30" | python3 -c "
import sys, json
for p in json.load(sys.stdin):
    print(f\"#{p['number']} {p['state'].upper()} {p['title']}  ({p['head']['ref']} → {p['base']['ref']})\")"
}

prs_create() {
    local repo="$1"; shift
    parse_opts "$@"
    local title="${OPTS[title]:-}"
    local head="${OPTS[head]:-}"
    local base="${OPTS[base]:-main}"
    local body="${OPTS[body]:-}"
    [ -z "$title" ] && die "Missing --title"
    [ -z "$head" ] && die "Missing --head"

    gh_post -d "{\"title\":\"$title\",\"head\":\"$head\",\"base\":\"$base\",\"body\":\"$body\"}" "$API/repos/$repo/pulls" | python3 -c "
import sys, json
p = json.load(sys.stdin)
print(f\"✓ Created PR #{p['number']}: {p['title']}\")
print(f\"  {p['head']['ref']} → {p['base']['ref']}\")
print(f\"  URL: {p['html_url']}\")"
}

prs_get() {
    local repo="$1" number="$2"
    gh_get "$API/repos/$repo/pulls/$number" | python3 -c "
import sys, json
p = json.load(sys.stdin)
print(f\"#{p['number']} [{p['state'].upper()}] {p['title']}\")
print(f\"Author: {p['user']['login']}  Created: {p['created_at']}\")
print(f\"Branch: {p['head']['ref']} → {p['base']['ref']}\")
print(f\"Mergeable: {p.get('mergeable', 'N/A')}  Commits: {p['commits']}  Changed files: {p['changed_files']}\")
if p.get('body'): print(f\"\\n{p['body']}\")"
}

prs_merge() {
    local repo="$1" number="$2"; shift 2
    parse_opts "$@"
    local method="${OPTS[method]:-merge}"
    gh_put -d "{\"merge_method\":\"$method\"}" "$API/repos/$repo/pulls/$number/merge" | python3 -c "
import sys, json
r = json.load(sys.stdin)
print(f\"✓ Merged: {r.get('message', 'OK')}\")"
}

# =====================================================
# BRANCHES
# =====================================================

branches_list() {
    local repo="$1"
    gh_get "$API/repos/$repo/branches?per_page=100" | python3 -c "
import sys, json
for b in json.load(sys.stdin):
    protected = ' 🔒' if b.get('protected') else ''
    print(f\"  {b['name']}{protected}\")"
}

branches_create() {
    local repo="$1" branch="$2"; shift 2
    parse_opts "$@"
    local from="${OPTS[from]:-main}"

    # Get SHA of source branch
    local sha
    sha=$(gh_get "$API/repos/$repo/git/ref/heads/$from" | python3 -c "import sys,json; print(json.load(sys.stdin)['object']['sha'])")

    gh_post -d "{\"ref\":\"refs/heads/$branch\",\"sha\":\"$sha\"}" "$API/repos/$repo/git/refs" > /dev/null
    echo "✓ Created branch: $branch (from $from)"
}

branches_delete() {
    local repo="$1" branch="$2"
    gh_delete "$API/repos/$repo/git/refs/heads/$branch"
    echo "✓ Deleted branch: $branch"
}

# =====================================================
# RELEASES
# =====================================================

releases_list() {
    local repo="$1"
    gh_get "$API/repos/$repo/releases?per_page=10" | python3 -c "
import sys, json
for r in json.load(sys.stdin):
    draft = ' [DRAFT]' if r['draft'] else ''
    pre = ' [PRE]' if r['prerelease'] else ''
    print(f\"{r['tag_name']}  {r.get('name','')}{draft}{pre}  ({r['published_at'] or 'unpublished'})\")"
}

releases_create() {
    local repo="$1"; shift
    parse_opts "$@"
    local tag="${OPTS[tag]:-}"
    local name="${OPTS[name]:-$tag}"
    local body="${OPTS[body]:-}"
    local draft="${OPTS[draft]:-false}"
    local prerelease="${OPTS[prerelease]:-false}"
    [ -z "$tag" ] && die "Missing --tag"
    [ "$draft" = "true" ] && draft="true" || draft="false"
    [ "$prerelease" = "true" ] && prerelease="true" || prerelease="false"

    gh_post -d "{\"tag_name\":\"$tag\",\"name\":\"$name\",\"body\":\"$body\",\"draft\":$draft,\"prerelease\":$prerelease}" "$API/repos/$repo/releases" | python3 -c "
import sys, json
r = json.load(sys.stdin)
print(f\"✓ Created release: {r['tag_name']}\")
print(f\"  URL: {r['html_url']}\")"
}

releases_latest() {
    local repo="$1"
    gh_get "$API/repos/$repo/releases/latest" | python3 -c "
import sys, json
r = json.load(sys.stdin)
print(f\"{r['tag_name']}  {r.get('name','')}\")
print(f\"Published: {r['published_at']}\")
print(f\"URL: {r['html_url']}\")
if r.get('body'): print(f\"\\n{r['body']}\")"
}

# =====================================================
# SEARCH
# =====================================================

search_repos() {
    local query="$*"
    gh_get "$API/search/repositories?q=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")&per_page=10" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"Found {data['total_count']} results:\")
for r in data['items']:
    print(f\"  {r['full_name']}  ⭐{r['stargazers_count']}  {r.get('description','') or ''}\")"
}

search_code() {
    local query="$1"; shift
    parse_opts "$@"
    local repo="${OPTS[repo]:-}"
    local q="$query"
    [ -n "$repo" ] && q="$q+repo:$repo"
    gh_get "$API/search/code?q=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$q'))")&per_page=10" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"Found {data['total_count']} results:\")
for f in data['items']:
    print(f\"  {f['repository']['full_name']}/{f['path']}\")"
}

search_issues() {
    local query="$*"
    gh_get "$API/search/issues?q=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")&per_page=10" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"Found {data['total_count']} results:\")
for i in data['items']:
    kind = 'PR' if 'pull_request' in i else 'Issue'
    print(f\"  [{kind}] {i['repository_url'].split('/')[-2]}/{i['repository_url'].split('/')[-1]}#{i['number']} {i['title']}\")"
}

# =====================================================
# USER
# =====================================================

user_whoami() {
    gh_get "$API/user" | python3 -c "
import sys, json
u = json.load(sys.stdin)
print(f\"User: {u['login']}\")
print(f\"Name: {u.get('name','N/A')}\")
print(f\"Email: {u.get('email','N/A')}\")
print(f\"Repos: {u['public_repos']} public, {u.get('total_private_repos',0)} private\")
print(f\"URL: {u['html_url']}\")"
}

user_get() {
    local username="$1"
    gh_get "$API/users/$username" | python3 -c "
import sys, json
u = json.load(sys.stdin)
print(f\"User: {u['login']}\")
print(f\"Name: {u.get('name','N/A')}\")
print(f\"Bio: {u.get('bio','N/A')}\")
print(f\"Repos: {u['public_repos']}  Followers: {u['followers']}\")
print(f\"URL: {u['html_url']}\")"
}

# =====================================================
# FILES
# =====================================================

files_get() {
    local repo="$1" path="$2"; shift 2
    parse_opts "$@"
    local ref="${OPTS[ref]:-}"
    local url="$API/repos/$repo/contents/$path"
    [ -n "$ref" ] && url="$url?ref=$ref"
    gh_get "$url" | python3 -c "
import sys, json, base64
f = json.load(sys.stdin)
if f.get('encoding') == 'base64':
    print(base64.b64decode(f['content']).decode('utf-8'))
else:
    print(f.get('content', ''))"
}

files_create() {
    local repo="$1" path="$2"; shift 2
    parse_opts "$@"
    local content="${OPTS[content]:-}"
    local message="${OPTS[message]:-}"
    local branch="${OPTS[branch]:-main}"
    [ -z "$content" ] && die "Missing --content"
    [ -z "$message" ] && die "Missing --message"

    local b64
    b64=$(echo -n "$content" | base64 -w0)

    # Check if file exists (for update)
    local sha=""
    sha=$(gh_get "$API/repos/$repo/contents/$path?ref=$branch" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('sha',''))" 2>/dev/null || echo "")

    local data="{\"message\":\"$message\",\"content\":\"$b64\",\"branch\":\"$branch\""
    [ -n "$sha" ] && data="$data,\"sha\":\"$sha\""
    data="$data}"

    gh_put -d "$data" "$API/repos/$repo/contents/$path" | python3 -c "
import sys, json
r = json.load(sys.stdin)
action = 'Updated' if r['content'].get('sha') else 'Created'
print(f\"✓ {action}: {r['content']['path']}\")
print(f\"  Commit: {r['commit']['sha'][:8]}\")"
}

# =====================================================
# GISTS
# =====================================================

gists_list() {
    gh_get "$API/gists?per_page=20" | python3 -c "
import sys, json
for g in json.load(sys.stdin):
    files = ', '.join(g['files'].keys())
    vis = '🌐' if g['public'] else '🔒'
    desc = g.get('description','') or ''
    print(f\"{vis} {g['id']}  {files}  {desc}\")"
}

gists_create() {
    parse_opts "$@"
    local desc="${OPTS[description]:-}"
    local filename="${OPTS[filename]:-file.txt}"
    local content="${OPTS[content]:-}"
    local public="${OPTS[public]:-false}"
    [ -z "$content" ] && die "Missing --content"
    [ "$public" = "true" ] && public="true" || public="false"

    # Use python for proper JSON escaping
    python3 -c "
import json, subprocess
data = {
    'description': '$desc',
    'public': $public,
    'files': {'$filename': {'content': '''$content'''}}
}
print(json.dumps(data))
" | gh_post -d @- "$API/gists" | python3 -c "
import sys, json
g = json.load(sys.stdin)
print(f\"✓ Created gist: {g['id']}\")
print(f\"  URL: {g['html_url']}\")"
}

# =====================================================
# DISPATCH
# =====================================================

CMD="${1:-}"
SUB="${2:-}"
shift 2 2>/dev/null || true

case "$CMD" in
    repos)
        case "$SUB" in
            list)       repos_list "$@" ;;
            create)     repos_create "$@" ;;
            get)        repos_get "$@" ;;
            delete)     repos_delete "$@" ;;
            clone-url)  repos_clone_url "$@" ;;
            *)          die "Unknown repos command: $SUB" ;;
        esac
        ;;
    issues)
        case "$SUB" in
            list)       issues_list "$@" ;;
            create)     issues_create "$@" ;;
            get)        issues_get "$@" ;;
            close)      issues_close "$@" ;;
            comment)    issues_comment "$@" ;;
            *)          die "Unknown issues command: $SUB" ;;
        esac
        ;;
    prs)
        case "$SUB" in
            list)       prs_list "$@" ;;
            create)     prs_create "$@" ;;
            get)        prs_get "$@" ;;
            merge)      prs_merge "$@" ;;
            *)          die "Unknown prs command: $SUB" ;;
        esac
        ;;
    branches)
        case "$SUB" in
            list)       branches_list "$@" ;;
            create)     branches_create "$@" ;;
            delete)     branches_delete "$@" ;;
            *)          die "Unknown branches command: $SUB" ;;
        esac
        ;;
    releases)
        case "$SUB" in
            list)       releases_list "$@" ;;
            create)     releases_create "$@" ;;
            latest)     releases_latest "$@" ;;
            *)          die "Unknown releases command: $SUB" ;;
        esac
        ;;
    search)
        case "$SUB" in
            repos)      search_repos "$@" ;;
            code)       search_code "$@" ;;
            issues)     search_issues "$@" ;;
            *)          die "Unknown search command: $SUB" ;;
        esac
        ;;
    user)
        case "$SUB" in
            whoami)     user_whoami ;;
            get)        user_get "$@" ;;
            *)          die "Unknown user command: $SUB" ;;
        esac
        ;;
    files)
        case "$SUB" in
            get)        files_get "$@" ;;
            create)     files_create "$@" ;;
            *)          die "Unknown files command: $SUB" ;;
        esac
        ;;
    gists)
        case "$SUB" in
            list)       gists_list ;;
            create)     gists_create "$@" ;;
            *)          die "Unknown gists command: $SUB" ;;
        esac
        ;;
    *)
        echo "Usage: github.sh <command> <subcommand> [args...]"
        echo ""
        echo "Commands: repos, issues, prs, branches, releases, search, user, files, gists"
        echo ""
        echo "Run 'github.sh <command>' for subcommand help."
        exit 1
        ;;
esac
