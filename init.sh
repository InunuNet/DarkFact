#!/usr/bin/env bash
# DarkFact init.sh — Project Scaffolding (v2.1)
#
# Pure infrastructure. Interactive onboarding is handled by /onboard workflow.
#
# Usage:
#   bash init.sh                     # scaffold with defaults
#   bash init.sh --name "MyProject"  # explicit project name
#
# Cross-platform: macOS, Linux, Windows (Git Bash / WSL)

set -euo pipefail

# ── Colors (skip if not a terminal) ──────────────────────────────────────────
if [ -t 1 ]; then
    GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
    DIM='\033[2m'; NC='\033[0m'
else
    GREEN=''; CYAN=''; YELLOW=''; DIM=''; NC=''
fi

# ── Detect platform ───────────────────────────────────────────────────────────
detect_platform() {
    case "$(uname -s 2>/dev/null)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)
PROJECT_NAME="$(basename "$PWD")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"

# ── Parse flags ───────────────────────────────────────────────────────────────
while [ $# -gt 0 ]; do
    case "$1" in
        --name=*) PROJECT_NAME="${1#*=}"; shift ;;
        --name)   PROJECT_NAME="$2"; shift 2 ;;
        *)        shift ;;
    esac
done

# Sanitize project name
PROJECT_NAME="$(printf '%s' "$PROJECT_NAME" | tr -cd '[:alnum:]_. -' | head -c 128)"

# ── Preflight checks ──────────────────────────────────────────────────────────
preflight() {
    for cmd in python3 git; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            printf "${YELLOW}❌ Required tool '%s' not found in PATH. Install it and re-run.${NC}\n" "$cmd" >&2
            exit 1
        fi
    done
    if [ ! -f "$TEMPLATE_DIR/.agent/profile.json" ]; then
        printf "${YELLOW}❌ Template missing at %s/.agent/profile.json${NC}\n" "$TEMPLATE_DIR" >&2
        printf "   init.sh must be run from within the DarkFact clone directory.\n" >&2
        exit 1
    fi
}

# ── Profile ───────────────────────────────────────────────────────────────────
write_profile() {
    printf "${CYAN}📋 Writing project profile...${NC}\n"
    local template_profile="$TEMPLATE_DIR/.agent/profile.json"
    local target=".agent/profile.json"

    cp "$template_profile" "$target"

    local created_at
    created_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "unknown")
    local template_version
    template_version=$(cat "$SCRIPT_DIR/.agent/version" 2>/dev/null || echo "unknown")

    python3 - <<PYEOF
import json
path = "$target"
with open(path) as f:
    p = json.load(f)
p['project_name']     = "$PROJECT_NAME"
p['primary_platform'] = "$PLATFORM"
p['created_at']       = "$created_at"
p['template_version'] = "$template_version"
p['onboarding_complete'] = False
with open(path, 'w') as f:
    json.dump(p, f, indent=2)
    f.write('\n')
PYEOF
}

# ── Core structure ────────────────────────────────────────────────────────────
scaffold_core() {
    printf "${CYAN}📂 Scaffolding core structure...${NC}\n"

    mkdir -p \
        .agent/agents \
        .agent/identity \
        .agent/memory/scratch \
        .agent/memory/project \
        .agent/rules/_core \
        .agent/rules/claude \
        .agent/rules/gemini \
        .agent/skills \
        .agent/workflows \
        .agent/providers \
        .claude/agents \
        .claude/rules \
        .claude/skills \
        .gemini/agents \
        .gemini/skills \
        .gemini/rules \
        .gemini/policies \
        execution/hooks \
        .tmp

    touch .agent/memory/scratch/.keep

    # WORKSPACE marker
    printf '%s\n' "$PROJECT_NAME" > WORKSPACE

    # ── Copy from template: clean slate (no DarkFact state) ──────────────────

    # Fresh memory files
    cp "$TEMPLATE_DIR/.agent/memory/project/goals.md"       .agent/memory/project/goals.md       2>/dev/null || cat > .agent/memory/project/goals.md << 'EOF'
# Goals

## Mission

[Set during /onboard — describe your project goal here]

## Active Goals

1. Complete onboarding — run `/onboard` to begin
EOF

    cp "$TEMPLATE_DIR/.agent/memory/project/learned.md"     .agent/memory/project/learned.md     2>/dev/null || cat > .agent/memory/project/learned.md << 'EOF'
    # Learned

    ## L1: GitHub-first Template Updates

    DarkFact projects update via 'make update-template'. This uses the 'gh' CLI to download the latest infrastructure from GitHub directly. No 'darkfact-upstream' git remote is required.

    Run 'gh auth status' to ensure you are logged in.
    EOF


    cp "$TEMPLATE_DIR/.agent/memory/project/backlog.md"     .agent/memory/project/backlog.md     2>/dev/null || cat > .agent/memory/project/backlog.md << 'EOF'
# Backlog

## TODO

- [ ] Run `/onboard` to define project goal and tech stack
EOF

    cp "$TEMPLATE_DIR/.agent/memory/project/rules.md"       .agent/memory/project/rules.md

    cat > .agent/memory/project/session_log.md << 'EOF'
# Session Log

Rolling log of work sessions. Most recent at top. Max 20 entries.

---

<!-- SESSIONS -->
EOF

    # Identity templates (filled in during /onboard)
    if [ -d "$TEMPLATE_DIR/.agent/identity" ]; then
        cp "$TEMPLATE_DIR/.agent/identity/"*.md .agent/identity/ 2>/dev/null || true
    else
        cat > .agent/identity/soul.md << 'EOF'
# Soul: Project Assistant

**Name**: [Set during /onboard]
**Role**: Primary project coordinator and agent orchestrator

Your full persona is defined during /onboard.
EOF
        cat > .agent/identity/user.md << 'EOF'
# User Profile

**Name**: [Set during /onboard]
**Role**: [Set during /onboard]

Preferences are defined during /onboard.
EOF
    fi

    # ── Copy hooks, provider configs, settings ────────────────────────────────
    cp "$SCRIPT_DIR/.claude/settings.json"  .claude/settings.json  2>/dev/null || true
    cp "$SCRIPT_DIR/.gemini/settings.json"  .gemini/settings.json  2>/dev/null || true
    cp "$SCRIPT_DIR/.gemini/policies/autonomy.toml" .gemini/policies/autonomy.toml 2>/dev/null || true

    # Copy rules (canonical source → platform dirs)
    for f in "$SCRIPT_DIR/.claude/rules/"*.md; do
        [ -f "$f" ] && cp "$f" .claude/rules/
    done

    # Copy hook scripts
    if [ -d "$SCRIPT_DIR/execution/hooks" ]; then
        cp "$SCRIPT_DIR/execution/hooks/"*.sh .         2>/dev/null || true
        cp "$SCRIPT_DIR/execution/hooks/"*.sh execution/hooks/ 2>/dev/null || true
    fi

    # Copy execution scripts
    for f in brain.py sync_agents.sh sync_skills.sh sync_rules.sh merge_profile.py; do
        [ -f "$SCRIPT_DIR/execution/$f" ] && cp "$SCRIPT_DIR/execution/$f" "execution/$f" 2>/dev/null || true
    done

    # ── Copy canonical agents, skills, workflows from DarkFact ───────────────
    for f in "$SCRIPT_DIR/.agent/agents/"*.md; do
        [ -f "$f" ] && cp "$f" .agent/agents/
    done
    for f in "$SCRIPT_DIR/.agent/skills/"*.md; do
        [ -f "$f" ] && cp "$f" .agent/skills/
    done
    for f in "$SCRIPT_DIR/.agent/workflows/"*.md; do
        [ -f "$f" ] && cp "$f" .agent/workflows/
    done

    # Provider registry
    for f in "$SCRIPT_DIR/.agent/providers/"*.json; do
        [ -f "$f" ] && cp "$f" .agent/providers/
    done
}

# ── AGENTS.md + symlinks ──────────────────────────────────────────────────────
setup_instructions() {
    printf "🔗 Setting up instruction symlinks...\n"

    # Use generic template AGENTS.md (not DarkFact's project-specific one)
    local agents_src
    if [ -f "$TEMPLATE_DIR/AGENTS.md" ]; then
        agents_src="$TEMPLATE_DIR/AGENTS.md"
    else
        agents_src="$SCRIPT_DIR/AGENTS.md"
    fi

    cp "$agents_src" AGENTS.md 2>/dev/null || true

    rm -f CLAUDE.md GEMINI.md 2>/dev/null || true
    ln -sf AGENTS.md CLAUDE.md 2>/dev/null || cp AGENTS.md CLAUDE.md 2>/dev/null || true
    ln -sf AGENTS.md GEMINI.md 2>/dev/null || cp AGENTS.md GEMINI.md 2>/dev/null || true
}

# ── Gitignore ─────────────────────────────────────────────────────────────────
setup_gitignore() {
    [ -f .gitignore ] && return
    cat > .gitignore << 'EOF'
# OS
.DS_Store
Thumbs.db

# Temp
.tmp/
node_modules/
__pycache__/
*.pyc

# Secrets
.env
.env.enc

# Agent scratch
.agent/memory/scratch/*
!.agent/memory/scratch/.keep

# Brain (local, large)
.agent/memory/brain/
EOF
}

# ── Secrets (optional) ────────────────────────────────────────────────────────
setup_secrets() {
    [ "$PLATFORM" = "windows" ] && return
    command -v sops >/dev/null 2>&1 && command -v age >/dev/null 2>&1 || return

    if [ ! -f .sops.yaml ]; then
        mkdir -p "$HOME/.config/sops/age"
        [ -f "$HOME/.config/sops/age/keys.txt" ] || age-keygen -o "$HOME/.config/sops/age/keys.txt" 2>/dev/null
        PUB_KEY=$(grep "public key:" "$HOME/.config/sops/age/keys.txt" | awk '{print $4}')
        cat > .sops.yaml << SOPSEOF
creation_rules:
  - path_regex: \.env$
    key_groups:
    - age:
      - $PUB_KEY
SOPSEOF
        printf "   🔐 sops + age configured\n"
    fi
}

# ── Git init ──────────────────────────────────────────────────────────────────
setup_git() {
    if [ ! -d .git ]; then
        printf "🗂️  Initialising git repository...\n"
        git init -q
    fi

    if ! git remote get-url origin >/dev/null 2>&1; then
        printf "${YELLOW}   ⚠️  No 'origin' remote. Add it:${NC}\n"
        printf "      git remote add origin https://github.com/InunuNet/%s.git\n" "$PROJECT_NAME"
    fi
}

# ── Sync agents + skills ──────────────────────────────────────────────────────
sync_all() {
    [ -f execution/sync_agents.sh ] && bash execution/sync_agents.sh
    [ -f execution/sync_skills.sh ] && bash execution/sync_skills.sh
    # sync_rules only if canonical source exists
    if [ -f execution/sync_rules.sh ] && [ -d .agent/rules/_core ]; then
        bash execution/sync_rules.sh 2>/dev/null || true
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    local version
    version=$(cat "$SCRIPT_DIR/.agent/version" 2>/dev/null || echo "?")

    printf "\n"
    printf "${CYAN}🏭 DarkFact v%s — Project Bootstrap${NC}\n" "$version"
    printf "${DIM}   Platform: %s | Project: %s${NC}\n\n" "$PLATFORM" "$PROJECT_NAME"

    preflight
    scaffold_core
    write_profile
    setup_instructions
    setup_gitignore
    setup_secrets
    setup_git
    sync_all

    printf "\n${GREEN}✅ Workspace scaffolded: %s${NC}\n\n" "$PROJECT_NAME"
    printf "   Next: Open in Claude Code or Gemini CLI and run ${CYAN}/onboard${NC}\n"
    printf "   Or:   ${CYAN}make help${NC}\n\n"
}

main "$@"
