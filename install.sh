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
echo "  AI Skill Inventory — Installer"
echo "═══════════════════════════════════════"
echo ""

# --- 1. Create target directory ---
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    info "Created $TARGET_DIR"
else
    info "Target directory exists: $TARGET_DIR"
fi

# --- 2. Symlink skills ---
if [ ! -d "$SKILLS_SRC" ]; then
    error "No skills/ directory found in repo"
    exit 1
fi

SKILL_COUNT=0
SKIP_COUNT=0

for skill_dir in "$SKILLS_SRC"/*/; do
    [ -d "$skill_dir" ] || continue

    skill_name="$(basename "$skill_dir")"

    # Require SKILL.md
    if [ ! -f "$skill_dir/SKILL.md" ]; then
        warn "Skipping $skill_name (no SKILL.md)"
        ((SKIP_COUNT++)) || true
        continue
    fi

    link_target="$TARGET_DIR/$skill_name"

    if [ -L "$link_target" ]; then
        # Already a symlink — check if it points to the right place
        existing="$(readlink -f "$link_target")"
        expected="$(readlink -f "$skill_dir")"
        if [ "$existing" = "$expected" ]; then
            info "Already linked: $skill_name"
        else
            warn "Updating link: $skill_name (was pointing elsewhere)"
            rm "$link_target"
            ln -s "$(readlink -f "$skill_dir")" "$link_target"
            info "Relinked: $skill_name"
        fi
    elif [ -e "$link_target" ]; then
        warn "Skipping $skill_name (target exists and is not a symlink)"
        ((SKIP_COUNT++)) || true
        continue
    else
        ln -s "$(readlink -f "$skill_dir")" "$link_target"
        info "Linked: $skill_name"
    fi

    ((SKILL_COUNT++)) || true
done

echo ""
info "Skills linked: $SKILL_COUNT"
[ "$SKIP_COUNT" -gt 0 ] && warn "Skipped: $SKIP_COUNT"

# --- 3. OpenClaw integration ---
if command -v openclaw &>/dev/null || [ -f "$OPENCLAW_CONFIG" ]; then
    echo ""
    echo "OpenClaw detected!"

    if [ ! -f "$OPENCLAW_CONFIG" ]; then
        warn "Config file not found at $OPENCLAW_CONFIG — skipping config update"
    else
        # Check if extraDirs already contains our target
        if command -v node &>/dev/null; then
            ALREADY_CONFIGURED=$(node -e "
                const fs = require('fs');
                try {
                    // Strip comments for JSON5-like configs
                    let raw = fs.readFileSync('$OPENCLAW_CONFIG', 'utf8');
                    // Simple JSON parse (won't work with full JSON5, but covers most cases)
                    const cfg = JSON.parse(raw);
                    const dirs = cfg?.skills?.load?.extraDirs || [];
                    console.log(dirs.includes('$TARGET_DIR') || dirs.includes('~/.agents/skills') ? 'yes' : 'no');
                } catch(e) {
                    console.log('error');
                }
            " 2>/dev/null || echo "error")

            if [ "$ALREADY_CONFIGURED" = "yes" ]; then
                info "OpenClaw already configured with ~/.agents/skills in extraDirs"
            elif [ "$ALREADY_CONFIGURED" = "error" ]; then
                warn "Could not parse OpenClaw config — please add manually:"
                echo ""
                echo '  "skills": { "load": { "extraDirs": ["~/.agents/skills"] } }'
                echo ""
            else
                # Patch the config
                node -e "
                    const fs = require('fs');
                    const path = '$OPENCLAW_CONFIG';
                    let raw = fs.readFileSync(path, 'utf8');
                    let cfg;
                    try { cfg = JSON.parse(raw); } catch(e) {
                        console.log('Cannot auto-patch JSON5 config. Please add manually.');
                        process.exit(1);
                    }
                    if (!cfg.skills) cfg.skills = {};
                    if (!cfg.skills.load) cfg.skills.load = {};
                    if (!cfg.skills.load.extraDirs) cfg.skills.load.extraDirs = [];
                    if (!cfg.skills.load.extraDirs.includes('~/.agents/skills')) {
                        cfg.skills.load.extraDirs.push('~/.agents/skills');
                    }
                    fs.writeFileSync(path, JSON.stringify(cfg, null, 2) + '\n');
                " 2>/dev/null

                if [ $? -eq 0 ]; then
                    info "Added ~/.agents/skills to OpenClaw skills.load.extraDirs"
                    warn "Restart OpenClaw to pick up the changes: openclaw gateway restart"
                else
                    warn "Could not auto-patch config. Please add manually:"
                    echo ""
                    echo '  "skills": { "load": { "extraDirs": ["~/.agents/skills"] } }'
                    echo ""
                fi
            fi
        else
            warn "Node.js not found — cannot auto-patch OpenClaw config"
            warn "Please add manually to $OPENCLAW_CONFIG:"
            echo ""
            echo '  "skills": { "load": { "extraDirs": ["~/.agents/skills"] } }'
            echo ""
        fi
    fi
fi

echo ""
info "Done! Your skills are ready at $TARGET_DIR"
echo ""
