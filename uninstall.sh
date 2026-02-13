#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
TARGET_DIR="$HOME/.agents/skills"
OPENCLAW_CONFIG="$HOME/.openclaw/openclaw.json"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

echo ""
echo "═══════════════════════════════════════"
echo "  AI Skill Inventory — Uninstaller"
echo "═══════════════════════════════════════"
echo ""

# --- 1. Remove symlinks ---
REMOVED=0

if [ -d "$TARGET_DIR" ]; then
    for skill_dir in "$SKILLS_SRC"/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name="$(basename "$skill_dir")"
        link_target="$TARGET_DIR/$skill_name"

        if [ -L "$link_target" ]; then
            existing="$(readlink -f "$link_target")"
            expected="$(readlink -f "$skill_dir")"
            if [ "$existing" = "$expected" ]; then
                rm "$link_target"
                info "Removed: $skill_name"
                ((REMOVED++)) || true
            fi
        fi
    done

    # Remove target dir if empty
    if [ -z "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
        rmdir "$TARGET_DIR"
        info "Removed empty directory: $TARGET_DIR"
        # Also remove parent if empty
        [ -z "$(ls -A "$HOME/.agents" 2>/dev/null)" ] && rmdir "$HOME/.agents" 2>/dev/null && info "Removed empty directory: ~/.agents"
    fi
else
    warn "Target directory not found: $TARGET_DIR"
fi

echo ""
info "Removed $REMOVED symlink(s)"

# --- 2. OpenClaw config cleanup ---
if [ -f "$OPENCLAW_CONFIG" ] && command -v node &>/dev/null; then
    echo ""
    read -p "Remove ~/.agents/skills from OpenClaw config? [y/N] " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        node -e "
            const fs = require('fs');
            const path = '$OPENCLAW_CONFIG';
            let raw = fs.readFileSync(path, 'utf8');
            let cfg;
            try { cfg = JSON.parse(raw); } catch(e) {
                console.log('Cannot parse config. Please remove manually.');
                process.exit(1);
            }
            const dirs = cfg?.skills?.load?.extraDirs;
            if (Array.isArray(dirs)) {
                cfg.skills.load.extraDirs = dirs.filter(d => d !== '~/.agents/skills' && d !== '$TARGET_DIR');
                if (cfg.skills.load.extraDirs.length === 0) delete cfg.skills.load.extraDirs;
                if (Object.keys(cfg.skills.load).length === 0) delete cfg.skills.load;
                if (Object.keys(cfg.skills).length === 0) delete cfg.skills;
            }
            fs.writeFileSync(path, JSON.stringify(cfg, null, 2) + '\n');
        " 2>/dev/null && info "Removed from OpenClaw config" || warn "Could not auto-patch config"
    fi
fi

echo ""
info "Done!"
echo ""
