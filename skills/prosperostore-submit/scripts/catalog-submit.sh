#!/usr/bin/env bash
# List or update one PS5 app in the ProsperoStore catalogs: the official catalog and its mirror.
# Usage: catalog-submit.sh <command> [args]
#   setup                                   clone or refresh both catalogs in the workspace
#   draft <owner/repo> [--tag T] [--asset A]  print the record the catalog tooling can prove
#   check <record.json>                     check and verify the record in both catalogs
#   open <record.json> --message M --body F [--dry-run]
#                                           commit the record and open one pull request per catalog
#
# Environment:
#   PROSPERO_UPSTREAM   official catalog (default darkxex/ps5-homebrew-catalog)
#   PROSPERO_MIRROR     second catalog that gets the same record (default heydemoura/ps5-homebrew-catalog)
#   PROSPERO_WORKDIR    workspace (default ~/.cache/prosperostore-submit)
#   PROSPERO_PUSH_REPO  repository the pull request branches are pushed to (default <login>/ps5-homebrew-catalog)

set -euo pipefail

UPSTREAM="${PROSPERO_UPSTREAM:-darkxex/ps5-homebrew-catalog}"
MIRROR="${PROSPERO_MIRROR:-heydemoura/ps5-homebrew-catalog}"
WORK="${PROSPERO_WORKDIR:-$HOME/.cache/prosperostore-submit}"
MAIN="$WORK/catalog"     # worktree on the official catalog's main
SECOND="$WORK/mirror"    # worktree on the mirror's main

die() { echo "error: $*" >&2; exit 1; }
say() { echo "==> $*"; }

need() {
  for bin in git gh python3; do
    command -v "$bin" >/dev/null || die "$bin is required"
  done
  python3 -c 'import sys; sys.exit(sys.version_info < (3, 10))' || die "python3 3.10 or newer is required"
  gh auth status --hostname github.com >/dev/null 2>&1 || die "gh is not logged in to github.com (run: gh auth login)"
}

remote_url() {
  if [ "$(gh config get git_protocol 2>/dev/null || true)" = ssh ]; then
    echo "git@github.com:$1.git"
  else
    echo "https://github.com/$1.git"
  fi
}

ensure_remote() {  # name owner/repo
  if git -C "$MAIN" remote get-url "$1" >/dev/null 2>&1; then
    git -C "$MAIN" remote set-url "$1" "$(remote_url "$2")"
  else
    git -C "$MAIN" remote add "$1" "$(remote_url "$2")"
  fi
}

# Puts a worktree back on its catalog's main, dropping any record copied into it earlier.
reset_tree() {  # dir ref
  git -C "$1" checkout --quiet --force --detach "$2"
  git -C "$1" clean --quiet -fd -- apps
}

setup() {
  need
  mkdir -p "$WORK"
  if [ ! -d "$MAIN/.git" ]; then
    say "cloning $UPSTREAM into $MAIN"
    git clone --quiet --origin upstream "$(remote_url "$UPSTREAM")" "$MAIN"
  fi
  ensure_remote upstream "$UPSTREAM"
  ensure_remote mirror "$MIRROR"
  git -C "$MAIN" fetch --quiet upstream main
  git -C "$MAIN" fetch --quiet mirror main
  reset_tree "$MAIN" upstream/main
  if [ ! -e "$SECOND/.git" ]; then
    git -C "$MAIN" worktree prune
    git -C "$MAIN" worktree add --quiet --detach "$SECOND" mirror/main
  fi
  reset_tree "$SECOND" mirror/main
  local behind
  behind=$(git -C "$MAIN" rev-list --count mirror/main..upstream/main)
  say "official catalog: $UPSTREAM @ $(git -C "$MAIN" rev-parse --short upstream/main) ($MAIN)"
  say "mirror catalog:   $MIRROR @ $(git -C "$MAIN" rev-parse --short mirror/main) ($SECOND)"
  [ "$behind" -eq 0 ] || say "note: the mirror is $behind commit(s) behind the official catalog"
}

record_id() {  # path -> id (filename without .json), after checking the filename shape
  local file
  file=$(basename "$1")
  [[ $file =~ ^[A-Z]{4}[0-9]{5}(-[a-z0-9][a-z0-9-]*)?\.json$ ]] ||
    die "$file is not a record filename (<TITLEID>.json or <TITLEID>-<owner>.json)"
  echo "${file%.json}"
}

draft() {
  [ $# -ge 1 ] || die "usage: draft <owner/repo> [--tag T] [--asset A]"
  setup >/dev/null
  (cd "$MAIN" && GITHUB_TOKEN=$(gh auth token) python3 -m catalog draft "$@")
}

check_in() {  # dir record label
  local id status=0
  id=$(record_id "$2")
  cp "$2" "$1/apps/$id.json"
  say "$3: $(git -C "$1" status --porcelain -- apps | tr '\n' ' ')"
  (cd "$1" && python3 -m catalog check) || status=1
  (cd "$1" && GITHUB_TOKEN=$(gh auth token) python3 -m catalog verify "$id") || status=1
  return $status
}

check() {
  [ $# -eq 1 ] && [ -f "$1" ] || die "usage: check <record.json>"
  local record status=0
  record=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
  record_id "$record" >/dev/null
  setup >/dev/null
  check_in "$MAIN" "$record" "$UPSTREAM" || status=1
  check_in "$SECOND" "$record" "$MIRROR" || status=1
  reset_tree "$MAIN" upstream/main
  reset_tree "$SECOND" mirror/main
  [ $status -eq 0 ] && say "the record passes in both catalogs" || say "fix the errors above before opening pull requests"
  return $status
}

# The repository branches are pushed to: the submitter's fork in the catalog's fork network.
push_repo() {  # login dry_run
  local repo="${PROSPERO_PUSH_REPO:-$1/ps5-homebrew-catalog}" network
  if network=$(gh api "repos/$repo" --jq '.source.full_name // .full_name' 2>/dev/null); then
    [ "$network" = "$UPSTREAM" ] || die "$repo is not in $UPSTREAM's fork network; set PROSPERO_PUSH_REPO"
  elif [ "$2" = 1 ]; then
    echo "(dry run: would fork $UPSTREAM to $1)" >&2
  else
    gh repo fork "$UPSTREAM" --clone=false --default-branch-only >&2
    repo="$1/ps5-homebrew-catalog"
  fi
  echo "$repo"
}

# Commits the record on a branch in one catalog's worktree and opens (or reuses) its pull request.
submit_to() {  # dir base target branch record message body push_repo dry_run
  local dir=$1 base=$2 target=$3 branch=$4 record=$5 message=$6 body=$7 push=$8 dry=$9
  local id owner head existing
  id=$(record_id "$record")
  owner=${push%%/*}
  if git -C "$dir" fetch --quiet push "+refs/heads/$branch:refs/remotes/push/$branch" 2>/dev/null; then
    git -C "$dir" checkout --quiet --force -B "$branch" "push/$branch"   # a later round of the same PR
  else
    git -C "$dir" checkout --quiet --force -B "$branch" "$base"
  fi
  cp "$record" "$dir/apps/$id.json"
  git -C "$dir" add -- "apps/$id.json"
  if git -C "$dir" diff --cached --quiet; then
    say "$target: apps/$id.json on $branch already has this content"
  else
    git -C "$dir" commit --quiet -m "$message"
    say "$target: committed apps/$id.json on $branch"
  fi
  local changed
  changed=$(git -C "$dir" diff --name-only "$base"...HEAD)
  if [ -z "$changed" ]; then
    say "$target: main already has this apps/$id.json; no pull request needed"
    return 0
  fi
  [ "$changed" = "apps/$id.json" ] || die "$target: branch $branch changes more than apps/$id.json: $changed"

  [ "$push" = "$target" ] && head=$branch || head="$owner:$branch"
  if [ "$dry" = 1 ]; then
    say "(dry run) git push push $branch   # to $push"
  else
    git -C "$dir" push --quiet push "HEAD:refs/heads/$branch" ||
      die "push to $push failed; if it mentions the workflow scope, push over SSH or run: gh auth refresh -s workflow"
  fi
  existing=$(gh pr list -R "$target" --state open --limit 200 --json url,headRefName,headRepositoryOwner \
    --jq "map(select(.headRefName == \"$branch\" and .headRepositoryOwner.login == \"$owner\")) | .[0].url // empty")
  if [ -n "$existing" ]; then
    say "$target: pull request already open, updated: $existing"
  elif [ "$dry" = 1 ]; then
    say "(dry run) gh pr create -R $target --base main --head $head --title \"$message\" --body-file $body"
  else
    gh pr create -R "$target" --base main --head "$head" --title "$message" --body-file "$body"
  fi
}

open_prs() {
  local record="" message="" body="" dry=0
  while [ $# -gt 0 ]; do
    case $1 in
      --message) message=$2; shift 2 ;;
      --body) body=$2; shift 2 ;;
      --dry-run) dry=1; shift ;;
      -*) die "unknown option $1" ;;
      *) record=$1; shift ;;
    esac
  done
  [ -f "$record" ] && [ -n "$message" ] && [ -f "$body" ] ||
    die "usage: open <record.json> --message \"List <name> by <author>\" --body <body.md> [--dry-run]"
  record=$(cd "$(dirname "$record")" && pwd)/$(basename "$record")
  body=$(cd "$(dirname "$body")" && pwd)/$(basename "$body")
  local id login push
  id=$(record_id "$record")
  setup >/dev/null
  login=$(gh api user --jq .login)
  push=$(push_repo "$login" "$dry")
  ensure_remote push "$push"
  say "pushing branches to $push as @$login"
  submit_to "$MAIN" upstream/main "$UPSTREAM" "listing/$id" "$record" "$message" "$body" "$push" "$dry"
  submit_to "$SECOND" mirror/main "$MIRROR" "listing/$id-mirror" "$record" "$message" "$body" "$push" "$dry"
}

case ${1:-} in
  setup) shift; setup "$@" ;;
  draft) shift; draft "$@" ;;
  check) shift; check "$@" ;;
  open) shift; open_prs "$@" ;;
  *) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
