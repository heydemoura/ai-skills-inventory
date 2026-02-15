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
echo "  AI Skill Inventory — Installer"
echo "═══════════════════════════════════════"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  SKILLS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "── Skills ──"
echo ""

# --- 1. Create target directory ---
if [ ! -d "$SKILLS_TARGET" ]; then
    mkdir -p "$SKILLS_TARGET"
    info "Created $SKILLS_TARGET"
else
    info "Target directory exists: $SKILLS_TARGET"
fi

# --- 2. Symlink skills ---
if [ ! -d "$SKILLS_SRC" ]; then
    warn "No skills/ directory found in repo — skipping skills"
else
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

        link_target="$SKILLS_TARGET/$skill_name"

        if [ -L "$link_target" ]; then
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
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  AGENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo "── Agents ──"
echo ""

# --- 1. Create target directory ---
if [ ! -d "$AGENTS_TARGET" ]; then
    mkdir -p "$AGENTS_TARGET"
    info "Created $AGENTS_TARGET"
else
    info "Target directory exists: $AGENTS_TARGET"
fi

# --- 2. Symlink agents ---
if [ ! -d "$AGENTS_SRC" ]; then
    warn "No agents/ directory found in repo — skipping agents"
else
    AGENT_COUNT=0
    AGENT_SKIP=0

    for agent_dir in "$AGENTS_SRC"/*/; do
        [ -d "$agent_dir" ] || continue

        agent_name="$(basename "$agent_dir")"

        # Require AGENT.md
        if [ ! -f "$agent_dir/AGENT.md" ]; then
            warn "Skipping $agent_name (no AGENT.md)"
            ((AGENT_SKIP++)) || true
            continue
        fi

        link_target="$AGENTS_TARGET/$agent_name"

        if [ -L "$link_target" ]; then
            existing="$(readlink -f "$link_target")"
            expected="$(readlink -f "$agent_dir")"
            if [ "$existing" = "$expected" ]; then
                info "Already linked: $agent_name"
            else
                warn "Updating link: $agent_name (was pointing elsewhere)"
                rm "$link_target"
                ln -s "$(readlink -f "$agent_dir")" "$link_target"
                info "Relinked: $agent_name"
            fi
        elif [ -e "$link_target" ]; then
            warn "Skipping $agent_name (target exists and is not a symlink)"
            ((AGENT_SKIP++)) || true
            continue
        else
            ln -s "$(readlink -f "$agent_dir")" "$link_target"
            info "Linked: $agent_name"
        fi

        ((AGENT_COUNT++)) || true
    done

    echo ""
    info "Agents linked: $AGENT_COUNT"
    [ "$AGENT_SKIP" -gt 0 ] && warn "Skipped: $AGENT_SKIP"
fi

# --- 3. OpenCode agent integration ---
echo ""
echo "── OpenCode Integration ──"
echo ""

if [ ! -d "$OPENCODE_AGENTS_TARGET" ]; then
    mkdir -p "$OPENCODE_AGENTS_TARGET"
    info "Created $OPENCODE_AGENTS_TARGET"
else
    info "OpenCode agents directory exists: $OPENCODE_AGENTS_TARGET"
fi

if [ -d "$AGENTS_SRC" ]; then
    OC_COUNT=0

    for agent_dir in "$AGENTS_SRC"/*/; do
        [ -d "$agent_dir" ] || continue
        agent_name="$(basename "$agent_dir")"
        [ -f "$agent_dir/AGENT.md" ] || continue

        # OpenCode expects <agent-name>.md files in the agents directory
        oc_link="$OPENCODE_AGENTS_TARGET/${agent_name}.md"
        agent_md="$(readlink -f "$agent_dir/AGENT.md")"

        if [ -L "$oc_link" ]; then
            existing="$(readlink -f "$oc_link")"
            if [ "$existing" = "$agent_md" ]; then
                info "OpenCode already linked: ${agent_name}.md"
            else
                rm "$oc_link"
                ln -s "$agent_md" "$oc_link"
                info "OpenCode relinked: ${agent_name}.md"
            fi
        elif [ -e "$oc_link" ]; then
            warn "Skipping OpenCode link for $agent_name (file exists and is not a symlink)"
            continue
        else
            ln -s "$agent_md" "$oc_link"
            info "OpenCode linked: ${agent_name}.md"
        fi

        ((OC_COUNT++)) || true
    done

    info "OpenCode agents linked: $OC_COUNT"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  OPENCLAW CONFIG
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if command -v openclaw &>/dev/null || [ -f "$OPENCLAW_CONFIG" ]; then
    echo ""
    echo "── OpenClaw Integration ──"
    echo ""

    if [ ! -f "$OPENCLAW_CONFIG" ]; then
        warn "Config file not found at $OPENCLAW_CONFIG — skipping config update"
    else
        if command -v node &>/dev/null; then
            ALREADY_CONFIGURED=$(node -e "
                const fs = require('fs');
                try {
                    let raw = fs.readFileSync('$OPENCLAW_CONFIG', 'utf8');
                    const cfg = JSON.parse(raw);
                    const dirs = cfg?.skills?.load?.extraDirs || [];
                    console.log(dirs.includes('$SKILLS_TARGET') || dirs.includes('~/.agents/skills') ? 'yes' : 'no');
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
info "Done! Your skills are at $SKILLS_TARGET and agents are at $AGENTS_TARGET"
echo ""
