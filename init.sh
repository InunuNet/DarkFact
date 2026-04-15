#!/usr/bin/env bash
# DarkFact init.sh — Project Scaffolding (v2.0)
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

# ── Parse flags ───────────────────────────────────────────────────────────────
for arg in "$@"; do
    case "$arg" in
        --name=*) PROJECT_NAME="${arg#*=}" ;;
    esac
done

# ── Core structure ────────────────────────────────────────────────────────────
scaffold_core() {
    echo -e "${CYAN}📂 Scaffolding core structure...${NC}"

    mkdir -p \
        .agent/agents \
        .agent/identity \
        .agent/memory/scratch \
        .agent/memory/project \
        .agent/rules \
        .agent/skills \
        .agent/workflows \
        .claude/agents \
        .claude/rules \
        .claude/skills \
        .gemini/agents \
        .gemini/skills \
        execution \
        .tmp

    # Placeholders to keep git-tracked dirs
    touch .agent/memory/scratch/.keep
    touch .agent/skills/.keep

    # WORKSPACE marker — hard identity file for workspace isolation.
    # Boot Step 0 reads this to verify the agent is in the right project.
    # Never delete this file. Never copy it between projects.
    echo "$PROJECT_NAME" > WORKSPACE

    # Fresh project files (don't inherit template's context)
    cat > .agent/memory/project/goals.md << 'EOF'
# Goals

## Mission

[Set during /onboard — describe your project goal here]

## Active Goals

1. Complete onboarding — run `/onboard` to begin

## Success Criteria

- [ ] Project goal defined
- [ ] Tech stack chosen
- [ ] Initial backlog created
EOF

    cat > .agent/memory/project/learned.md << 'EOF'
# Learned

_Lessons added by the maintainer agent during session wrap-up._

## L1: Two-repo Git model — read this first

Every DarkFact project uses two Git remotes. Both must be set up.

| Remote | Points to | Purpose |
|--------|-----------|---------|
| `origin` | `github.com/InunuNet/[THIS PROJECT]` | Your project's code, history, issues |
| `darkfact-upstream` | `github.com/InunuNet/DarkFact` | Template infrastructure — pull only |

**Rules:**
- Push your work to `origin` — your project's own GitHub repo
- Pull template updates via `make update-template` (fetches from `darkfact-upstream`)
- **Never push to `darkfact-upstream`** — it's the shared template, read-only for you
- Template bug? Report via `/report-bug` → creates issue on `InunuNet/DarkFact`
- Project bug? Create issue on your own `origin` repo

Check remotes are correct: `git remote -v`
EOF

    cat > .agent/memory/project/backlog.md << 'EOF'
# Backlog

## TODO

- [ ] Run `/onboard` to define project goal and tech stack

## DONE
EOF

    : > .agent/memory/project/rules.md
}

# ── Profile ───────────────────────────────────────────────────────────────────
write_profile() {
    echo -e "📋 Writing project profile..."
    CREATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "unknown")
    TEMPLATE_VERSION=$(cat "$(dirname "$0")/.agent/version" 2>/dev/null || echo "1.0.0")

    cat > .agent/profile.json << PROFEOF
{
  "project_name": "$PROJECT_NAME",
  "project_type": "pending",
  "platform": "$PLATFORM",
  "template_version": "$TEMPLATE_VERSION",
  "onboarding_complete": false,
  "features": {
    "llm_apis": false,
    "security_rules": false,
    "style_guide": false
  },
  "created_at": "$CREATED_AT"
}
PROFEOF
}

# ── AGENTS.md + symlinks ──────────────────────────────────────────────────────
setup_instructions() {
    echo -e "🔗 Setting up instruction symlinks..."

    # Keep AGENTS.md as the source of truth
    # CLAUDE.md and GEMINI.md are symlinks
    if [ ! -f AGENTS.md ]; then
        cp "$(dirname "$0")/AGENTS.md" AGENTS.md 2>/dev/null || true
    fi

    # Cross-platform symlink creation
    rm -f CLAUDE.md GEMINI.md 2>/dev/null || true
    ln -sf AGENTS.md CLAUDE.md 2>/dev/null || \
        cp AGENTS.md CLAUDE.md 2>/dev/null || true
    ln -sf AGENTS.md GEMINI.md 2>/dev/null || \
        cp AGENTS.md GEMINI.md 2>/dev/null || true
}

# ── Gitignore ─────────────────────────────────────────────────────────────────
setup_gitignore() {
    if [ ! -f .gitignore ]; then
        echo -e "🙈 Creating .gitignore..."
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

# Agent scratch (session temp, not committed)
.agent/memory/scratch/*
!.agent/memory/scratch/.keep

# Brain (project-local, large)
.agent/memory/brain/
EOF
    fi
}

# ── Secrets (optional, macOS/Linux only) ──────────────────────────────────────
setup_secrets() {
    if [ "$PLATFORM" = "windows" ]; then
        printf "${YELLOW}   ⚠️  sops/age: install WSL for secrets support.${NC}\n"
        return
    fi

    if ! command -v sops >/dev/null 2>&1 || ! command -v age >/dev/null 2>&1; then
        printf "${DIM}   ⚠️  sops/age not installed. Run: brew install sops age${NC}\n"
        return
    fi

    if [ ! -f .sops.yaml ]; then
        mkdir -p "$HOME/.config/sops/age"
        if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then
            age-keygen -o "$HOME/.config/sops/age/keys.txt" 2>/dev/null
        fi
        PUB_KEY=$(grep "public key:" "$HOME/.config/sops/age/keys.txt" | awk '{print $4}')
        cat > .sops.yaml << SOPSEOF
creation_rules:
  - path_regex: \.env$
    key_groups:
    - age:
      - $PUB_KEY
SOPSEOF
        echo -e "   🔐 sops + age configured"
    fi
}

# ── Git init ──────────────────────────────────────────────────────────────────
setup_git() {
    if [ ! -d .git ]; then
        echo -e "🗂️  Initialising git repository..."
        git init -q
        git remote add darkfact-upstream https://github.com/InunuNet/DarkFact.git 2>/dev/null || true
    else
        # Already has git — ensure upstream remote exists
        git remote get-url darkfact-upstream >/dev/null 2>&1 || \
            git remote add darkfact-upstream https://github.com/InunuNet/DarkFact.git 2>/dev/null || true
    fi
}

# ── Sync agents ───────────────────────────────────────────────────────────────
sync_agents() {
    if [ -f execution/sync_agents.sh ]; then
        echo -e "🤖 Syncing agents..."
        bash execution/sync_agents.sh
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    echo ""
    echo -e "${CYAN}🏭 DarkFact v$(cat .agent/version 2>/dev/null || echo '1.0.0') — Project Bootstrap${NC}"
    echo -e "${DIM}   Platform: $PLATFORM | Project: $PROJECT_NAME${NC}"
    echo ""

    scaffold_core
    write_profile
    setup_instructions
    setup_gitignore
    setup_secrets
    setup_git
    sync_agents

    echo ""
    echo -e "${GREEN}✅ Workspace scaffolded.${NC}"
    echo ""
    echo -e "   Next: Run ${CYAN}/onboard${NC} in your AI agent to define your project."
    echo -e "   Or:   ${CYAN}make help${NC} to see available commands."
    echo ""
}

main "$@"
