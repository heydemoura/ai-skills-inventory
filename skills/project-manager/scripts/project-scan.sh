#!/bin/bash
# Scan all projects and output structured info
# Usage: project-scan.sh [base_dir...]
# Defaults to ~/code if no args given

set -euo pipefail

DIRS=("${@:-$HOME/code}")

for BASE in ${DIRS[@]}; do
  [ -d "$BASE" ] || continue
  for PROJECT in "$BASE"/*/; do
    [ -d "$PROJECT" ] || continue
    NAME=$(basename "$PROJECT")

    echo "=== $BASE/$NAME ==="

    # Agent files (AGENTS.md, CLAUDE.md, CURSOR.md, README.md)
    for f in AGENTS.md CLAUDE.md CURSOR.md README.md; do
      if [ -f "$PROJECT/$f" ]; then
        echo "  [agent-file] $f"
      fi
    done

    # Git info
    if [ -d "$PROJECT/.git" ]; then
      BRANCH=$(git -C "$PROJECT" branch --show-current 2>/dev/null || echo "unknown")
      LAST_COMMIT=$(git -C "$PROJECT" log -1 --format="%h %s (%cr)" 2>/dev/null || echo "unknown")
      DIRTY=$(git -C "$PROJECT" status --porcelain 2>/dev/null | wc -l)
      echo "  git_branch: $BRANCH"
      echo "  git_last_commit: $LAST_COMMIT"
      echo "  git_dirty_files: $DIRTY"
    fi

    # Key files (build systems, configs)
    echo "  key_files:"
    for f in Makefile CMakeLists.txt package.json Cargo.toml go.mod setup.py pyproject.toml docker-compose.yml Dockerfile; do
      [ -f "$PROJECT/$f" ] && echo "    - $f"
    done

    # Size
    SIZE=$(du -sh "$PROJECT" 2>/dev/null | cut -f1)
    echo "  disk_size: $SIZE"
    echo ""
  done
done
