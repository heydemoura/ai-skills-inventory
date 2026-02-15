#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
AGENTS_SRC="$REPO_DIR/agents"
SKILLS_TARGET="$HOME/.agents/skills"
AGENTS_TARGET="$HOME/.agents/agents"
OPENCODE_AGENTS_TARGET="$HOME/.config/opencode/agents"
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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  SKILLS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "── Skills ──"
echo ""

SKILL_REMOVED=0

if [ -d "$SKILLS_TARGET" ]; then
    for skill_dir in "$SKILLS_SRC"/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name="$(basename "$skill_dir")"
        link_target="$SKILLS_TARGET/$skill_name"

        if [ -L "$link_target" ]; then
            existing="$(readlink -f "$link_target")"
            expected="$(readlink -f "$skill_dir")"
            if [ "$existing" = "$expected" ]; then
                rm "$link_target"
                info "Removed: $skill_name"
                ((SKILL_REMOVED++)) || true
            fi
        fi
    done

    # Remove target dir if empty
    if [ -z "$(ls -A "$SKILLS_TARGET" 2>/dev/null)" ]; then
        rmdir "$SKILLS_TARGET"
        info "Removed empty directory: $SKILLS_TARGET"
    fi
else
    warn "Skills directory not found: $SKILLS_TARGET"
fi

info "Skills removed: $SKILL_REMOVED"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  AGENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo "── Agents ──"
echo ""

AGENT_REMOVED=0

if [ -d "$AGENTS_TARGET" ]; then
    for agent_dir in "$AGENTS_SRC"/*/; do
        [ -d "$agent_dir" ] || continue
        agent_name="$(basename "$agent_dir")"
        link_target="$AGENTS_TARGET/$agent_name"

        if [ -L "$link_target" ]; then
            existing="$(readlink -f "$link_target")"
            expected="$(readlink -f "$agent_dir")"
            if [ "$existing" = "$expected" ]; then
                rm "$link_target"
                info "Removed: $agent_name"
                ((AGENT_REMOVED++)) || true
            fi
        fi
    done

    # Remove target dir if empty
    if [ -z "$(ls -A "$AGENTS_TARGET" 2>/dev/null)" ]; then
        rmdir "$AGENTS_TARGET"
        info "Removed empty directory: $AGENTS_TARGET"
    fi
else
    warn "Agents directory not found: $AGENTS_TARGET"
fi

info "Agents removed: $AGENT_REMOVED"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  OPENCODE AGENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo "── OpenCode Agents ──"
echo ""

OC_REMOVED=0

if [ -d "$OPENCODE_AGENTS_TARGET" ] && [ -d "$AGENTS_SRC" ]; then
    for agent_dir in "$AGENTS_SRC"/*/; do
        [ -d "$agent_dir" ] || continue
        agent_name="$(basename "$agent_dir")"
        oc_link="$OPENCODE_AGENTS_TARGET/${agent_name}.md"

        if [ -L "$oc_link" ]; then
            existing="$(readlink -f "$oc_link")"
            expected="$(readlink -f "$agent_dir/AGENT.md")"
            if [ "$existing" = "$expected" ]; then
                rm "$oc_link"
                info "Removed OpenCode agent: ${agent_name}.md"
                ((OC_REMOVED++)) || true
            fi
        fi
    done

    # Remove dir if empty
    if [ -z "$(ls -A "$OPENCODE_AGENTS_TARGET" 2>/dev/null)" ]; then
        rmdir "$OPENCODE_AGENTS_TARGET"
        info "Removed empty directory: $OPENCODE_AGENTS_TARGET"
    fi
else
    warn "OpenCode agents directory not found or no agents source"
fi

info "OpenCode agents removed: $OC_REMOVED"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  CLEANUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Remove ~/.agents if completely empty
if [ -d "$HOME/.agents" ] && [ -z "$(ls -A "$HOME/.agents" 2>/dev/null)" ]; then
    rmdir "$HOME/.agents"
    info "Removed empty directory: ~/.agents"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  OPENCLAW CONFIG
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
                cfg.skills.load.extraDirs = dirs.filter(d => d !== '~/.agents/skills' && d !== '$SKILLS_TARGET');
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
