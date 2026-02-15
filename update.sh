#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_URL="https://github.com/heydemoura/ai-skills-inventory.git"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

usage() {
    echo "Usage: $0 [VERSION]"
    echo ""
    echo "Update ai-skills-inventory to the latest version or a specific commit/tag."
    echo ""
    echo "Arguments:"
    echo "  VERSION   Optional. A commit hash, tag, or branch to checkout."
    echo "            If omitted, updates to the latest version on main."
    echo ""
    echo "Examples:"
    echo "  $0              # Update to latest"
    echo "  $0 v1.2.0       # Update to tag v1.2.0"
    echo "  $0 abc1234      # Update to specific commit"
    echo "  $0 --help       # Show this help"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  PARSE ARGS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VERSION=""

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
fi

VERSION="${1:-}"

echo ""
echo "═══════════════════════════════════════"
echo "  AI Skill Inventory — Updater"
echo "═══════════════════════════════════════"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  PREFLIGHT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Must be a git repo
if [ ! -d "$REPO_DIR/.git" ]; then
    error "Not a git repository. Please clone the repo first:\n  git clone $REPO_URL"
fi

cd "$REPO_DIR"

# Check for uncommitted changes
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    warn "You have uncommitted changes in the repo"
    echo ""
    git status --short
    echo ""
    read -rp "Discard local changes and continue? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        git checkout -- .
        git clean -fd
        info "Local changes discarded"
    else
        error "Update cancelled. Commit or stash your changes first."
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  CURRENT VERSION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CURRENT_COMMIT="$(git rev-parse --short HEAD)"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'detached')"
info "Current version: $CURRENT_COMMIT ($CURRENT_BRANCH)"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  FETCH LATEST
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
info "Fetching latest changes..."
git fetch origin --tags --quiet

if [ -n "$VERSION" ]; then
    # ── Specific version ──
    info "Checking out version: $VERSION"

    if ! git cat-file -t "$VERSION" &>/dev/null; then
        # Try as a remote branch
        if git rev-parse "origin/$VERSION" &>/dev/null; then
            git checkout -B "$VERSION" "origin/$VERSION" --quiet
        else
            error "Version '$VERSION' not found. Use a valid commit hash, tag, or branch."
        fi
    else
        git checkout "$VERSION" --quiet
    fi

    NEW_COMMIT="$(git rev-parse --short HEAD)"
    info "Now at: $NEW_COMMIT"
else
    # ── Latest (main) ──
    git checkout main --quiet 2>/dev/null || git checkout -B main origin/main --quiet

    LOCAL="$(git rev-parse HEAD)"
    REMOTE="$(git rev-parse origin/main)"

    if [ "$LOCAL" = "$REMOTE" ]; then
        info "Already up to date!"
        echo ""
        exit 0
    fi

    git pull origin main --quiet
    NEW_COMMIT="$(git rev-parse --short HEAD)"

    COMMITS_BEHIND="$(git rev-list "$CURRENT_COMMIT..HEAD" --count 2>/dev/null || echo '?')"
    info "Updated: $CURRENT_COMMIT → $NEW_COMMIT ($COMMITS_BEHIND new commits)"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  CHANGELOG
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo "── What's new ──"
echo ""
git log --oneline --no-decorate "$CURRENT_COMMIT..HEAD" 2>/dev/null | head -20 || true
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  RE-INSTALL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

info "Re-running install to update symlinks..."
echo ""
bash "$REPO_DIR/install.sh"
