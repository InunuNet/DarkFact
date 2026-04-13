#!/bin/bash

# Antigravity Workspace Bootstrap (v3.0)
# Purpose-built workspaces via interactive QA or flags.
#
# Usage:
#   ./init.sh                                          # interactive
#   ./init.sh --type=research --no-api --docs          # flags
#   ./init.sh --type=webapp --web=static               # static web
#   ./init.sh --type=webapp --web=framework             # full framework
#   ./init.sh --type=webapp --web=firebase              # firebase
#   ./init.sh --type=python                             # python CLI/API
#   ./init.sh --type=serverops                          # server recon
#   ./init.sh --type=general                            # minimal
#   ./init.sh --type=macos                             # native macOS app
#   ./init.sh --factory                                # also install Dark Factory addon

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
DIM='\033[2m'
NC='\033[0m'

# --- Globals ---
PROJECT_NAME="$(basename "$PWD")"
TEMPLATE_PATH=""
PROJECT_TYPE=""
WEB_SUBTYPE=""
USE_API="n"
USE_DOCS="n"
USE_SECURITY="n"
USE_STYLE="n"
USE_FACTORY="n"

# --- Parse Flags ---
parse_flags() {
    for arg in "$@"; do
        case "$arg" in
            --type=*)       PROJECT_TYPE="${arg#*=}" ;;
            --web=*)        WEB_SUBTYPE="${arg#*=}" ;;
            --api)          USE_API="y" ;;
            --no-api)       USE_API="n" ;;
            --docs)         USE_DOCS="y" ;;
            --no-docs)      USE_DOCS="n" ;;
            --security)     USE_SECURITY="y" ;;
            --no-security)  USE_SECURITY="n" ;;
            --style)        USE_STYLE="y" ;;
            --no-style)     USE_STYLE="n"
USE_FACTORY="n" ;;
            --template=*)   TEMPLATE_PATH="${arg#*=}" ;;
        esac
    done
}

# --- Interactive QA ---
run_qa() {
    echo -e "${CYAN}🚀 Antigravity Project Setup${NC}"
    echo ""

    # Q1: Project type
    if [ -z "$PROJECT_TYPE" ]; then
        echo "1. What type of project is this?"
        echo "   [1] Research / Deep Dive"
        echo "   [2] Web Application"
        echo "   [3] Python CLI/API"
        echo "   [4] Server Ops / Recon"
        echo "   [5] General / Mixed"
        echo "   [6] Native macOS App"
        echo ""
        read -p "   → Choice [1-6]: " choice
        case "$choice" in
            1) PROJECT_TYPE="research" ;;
            2) PROJECT_TYPE="webapp" ;;
            3) PROJECT_TYPE="python" ;;
            4) PROJECT_TYPE="serverops" ;;
            6) PROJECT_TYPE="macos" ;;
            *) PROJECT_TYPE="general" ;;
        esac
    fi

    # Q1a: Web sub-type
    if [ "$PROJECT_TYPE" = "webapp" ] && [ -z "$WEB_SUBTYPE" ]; then
        echo ""
        echo "   What kind of web project?"
        echo "   [a] Static Site     — HTML/CSS/JS. Dashboards, landing pages, tools."
        echo "   [b] Full Web App    — Framework (Vite+React, Next.js). SPAs, admin panels."
        echo "   [c] Firebase App    — Google Firebase (Auth, Firestore, Hosting)."
        echo ""
        read -p "   → Choice [a/b/c]: " subchoice
        case "$subchoice" in
            a) WEB_SUBTYPE="static" ;;
            b) WEB_SUBTYPE="framework" ;;
            c) WEB_SUBTYPE="firebase" ;;
            *) WEB_SUBTYPE="static" ;;
        esac
    fi

    # Q2: LLM APIs
    if [ "$USE_API" = "n" ] && [ "$PROJECT_TYPE" != "serverops" ]; then
        echo ""
        read -p "2. Will you use external LLM APIs? (y/n) [n]: " USE_API
        USE_API="${USE_API:-n}"
    fi

    # Q3: Document conversion
    echo ""
    read -p "3. Do you have reference documents to convert? (y/n) [n]: " USE_DOCS
    USE_DOCS="${USE_DOCS:-n}"

    # Q4: Security (auto-yes for webapp/python/serverops)
    case "$PROJECT_TYPE" in
        webapp|python|serverops|macos) USE_SECURITY="y" ;;
        *)
            echo ""
            read -p "4. Include security hardening rules? (y/n) [n]: " USE_SECURITY
            USE_SECURITY="${USE_SECURITY:-n}"
            ;;
    esac

    # Q5: Style guide (auto-yes for webapp)
    case "$PROJECT_TYPE" in
        webapp) USE_STYLE="y" ;;
        *)
            echo ""
            read -p "5. Include UI/design rules? (y/n) [n]: " USE_STYLE
            USE_STYLE="${USE_STYLE:-n}"
            ;;
    esac

    # Q6: Dark Factory
    echo ""
    echo "6. Autonomous Agent Orchestration (Dark Factory)"
    echo "   Enables Lead/Architect/Dev/QA agents to autonomously plan and build."
    echo "   (Can install later: make add-factory)"
    read -p "   Add now? (y/N): " USE_FACTORY
    USE_FACTORY="${USE_FACTORY:-n}"
}

# --- Build Directory Structure ---
build_core() {
    echo ""
    echo -e "📂 Building directory tree..."
    mkdir -p .agent/{identity,workflows,rules,memory/{scratch,project},skills}
    mkdir -p execution .tmp
    touch .agent/memory/scratch/.keep
    # Seed blank backlog (prevents inheriting template's own backlog)
    if [ ! -f .agent/memory/project/backlog.md ]; then
        cat <<'BLOGEOF' > .agent/memory/project/backlog.md
# Backlog

## DONE

## TODO
BLOGEOF
    fi
}

build_project_dirs() {
    case "$PROJECT_TYPE" in
        webapp)
            case "$WEB_SUBTYPE" in
                static)
                    mkdir -p public/{css,js,assets}
                    # Minimal HTML5 boilerplate
                    if [ ! -f public/index.html ]; then
                        cat <<'HTMLEOF' > public/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <title>PROJECT_NAME</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <main id="app"></main>
    <script type="module" src="js/app.js"></script>
</body>
</html>
HTMLEOF
                        sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/g" public/index.html 2>/dev/null || true
                    fi
                    # CSS design tokens
                    if [ ! -f public/css/style.css ]; then
                        cat <<'CSSEOF' > public/css/style.css
:root {
    --bg-primary: hsl(225, 20%, 8%);
    --bg-surface: hsl(225, 15%, 12%);
    --text-primary: hsl(0, 0%, 95%);
    --text-secondary: hsl(220, 10%, 60%);
    --accent: hsl(210, 100%, 60%);
    --accent-glow: hsla(210, 100%, 60%, 0.3);
    --border: hsla(0, 0%, 100%, 0.08);
    --radius: 12px;
    --transition: all 0.3s ease;
    --font: 'Inter', system-ui, -apple-system, sans-serif;
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
    font-family: var(--font);
    background: var(--bg-primary);
    color: var(--text-primary);
    min-height: 100vh;
    line-height: 1.6;
}

.glass {
    background: hsla(225, 15%, 15%, 0.6);
    backdrop-filter: blur(12px);
    border: 1px solid var(--border);
    border-radius: var(--radius);
}
CSSEOF
                    fi
                    [ ! -f public/js/app.js ] && echo "// ${PROJECT_NAME}" > public/js/app.js
                    ;;
                framework)
                    echo -e "   ${DIM}Framework scaffold: run npx manually after setup.${NC}"
                    echo -e "   ${DIM}Example: npx -y create-vite@latest ./ --template react${NC}"
                    ;;
                firebase)
                    echo -e "   ${DIM}Firebase scaffold: run firebase init manually after setup.${NC}"
                    echo -e "   ${DIM}Install: npm install -g firebase-tools${NC}"
                    # Create starter firebase.json
                    if [ ! -f firebase.json ]; then
                        cat <<'FBEOF' > firebase.json
{
  "hosting": {
    "public": "public",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{ "source": "**", "destination": "/index.html" }]
  }
}
FBEOF
                    fi
                    mkdir -p public
                    ;;
            esac
            ;;
        python)
            mkdir -p src tests
            if [ ! -f pyproject.toml ]; then
                cat <<PYEOF > pyproject.toml
[project]
name = "$PROJECT_NAME"
version = "0.1.0"
requires-python = ">=3.11"
PYEOF
            fi
            [ ! -f src/__init__.py ] && touch src/__init__.py
            ;;
        macos)
            mkdir -p Sources Tests Resources
            if [ ! -f Package.swift ]; then
                cat <<SWIFTEOF > Package.swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "$PROJECT_NAME",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "$PROJECT_NAME", path: "Sources"),
        .testTarget(name: "${PROJECT_NAME}Tests", dependencies: ["$PROJECT_NAME"], path: "Tests"),
    ]
)
SWIFTEOF
            fi

            if [ ! -f Makefile ]; then
                cat <<MKEOF > Makefile
.PHONY: build run bundle clean

build:
	swift build

run: build
	.build/debug/$PROJECT_NAME

bundle:
	swift build -c release
	mkdir -p "$PROJECT_NAME.app/Contents/MacOS"
	cp .build/release/$PROJECT_NAME "$PROJECT_NAME.app/Contents/MacOS/"
	echo "✅ $PROJECT_NAME.app bundled"

clean:
	swift package clean
MKEOF
            fi
            if [ ! -f Sources/App.swift ]; then
                cat <<'APPEOF' > Sources/App.swift
import SwiftUI

@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .font(.largeTitle)
            .padding()
    }
}
APPEOF
            fi
            ;;
    esac
}

# --- Install Optional Components ---
install_optional() {
    # API scripts
    if [ "$USE_API" = "y" ]; then
        echo -e "   🔌 API query scripts enabled"
        # They should already exist from template copy; just confirm .env has slots
        if [ ! -f .env ]; then
            cat <<'ENVEOF' > .env
# --- API KEYS ---
OPENAI_API_KEY=""
ANTHROPIC_API_KEY=""
GEMINI_API_KEY=""
ENVEOF
        fi
    fi

    # Doc conversion
    if [ "$USE_DOCS" = "y" ]; then
        echo -e "   📄 Document conversion enabled (execution/doc2md.py)"
    else
        rm -f execution/doc2md.py 2>/dev/null || true
    fi

    # Security rules
    if [ "$USE_SECURITY" != "y" ]; then
        rm -f .agent/rules/security.md 2>/dev/null || true
        rm -f execution/secrets_check.py 2>/dev/null || true
    else
        echo -e "   🔒 Security rules enabled"
    fi

    # Style guide
    if [ "$USE_STYLE" != "y" ]; then
        rm -f .agent/rules/style_guide.md 2>/dev/null || true
    else
        echo -e "   🎨 Style guide enabled"
    fi

    # Remove API scripts if not needed
    if [ "$USE_API" != "y" ]; then
        rm -f execution/claude_query.py execution/gemini_query.py \
              execution/openai_query.py execution/kimi_query.py \
              execution/xai_query.py 2>/dev/null || true
    fi
}

# --- Symlinks ---
setup_symlinks() {
    echo -e "🔗 Setting up instruction symlinks..."
    rm -f CLAUDE.md GEMINI.md 2>/dev/null || true
    ln -sf AGENTS.md CLAUDE.md
    ln -sf AGENTS.md GEMINI.md
}

# --- Profile ---
write_profile() {
    echo -e "📋 Writing project profile..."
    # Resolve template path: use flag, or detect from script location
    if [ -z "$TEMPLATE_PATH" ]; then
        # If this init.sh was copied from a template, we can't auto-detect.
        # Default to the known template location.
        TEMPLATE_PATH="/Users/vetus/ai/Workspace Template"
    fi

    cat <<PROFEOF > .agent/profile.json
{
  "project_name": "$PROJECT_NAME",
  "project_type": "$PROJECT_TYPE",
  "web_subtype": $([ -n "$WEB_SUBTYPE" ] && echo "\"$WEB_SUBTYPE\"" || echo "null"),
  "template_path": "$TEMPLATE_PATH",
  "features": {
    "llm_apis": $([ "$USE_API" = "y" ] && echo "true" || echo "false"),
    "doc_conversion": $([ "$USE_DOCS" = "y" ] && echo "true" || echo "false"),
    "security_rules": $([ "$USE_SECURITY" = "y" ] && echo "true" || echo "false"),
    "style_guide": $([ "$USE_STYLE" = "y" ] && echo "true" || echo "false")
  },
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "template_version": "$(cat .agent/version 2>/dev/null || echo '3.0')"
}
PROFEOF
}

# --- Git Ignore ---
setup_gitignore() {
    if [ ! -f .gitignore ]; then
        echo -e "🙈 Creating .gitignore..."
        cat <<'GIEOF' > .gitignore
.DS_Store
.tmp/
node_modules/
__pycache__/
.env
.agent/memory/scratch/*
!.agent/memory/scratch/.keep
GIEOF
    fi
}

# --- Secrets (sops + age) ---
setup_secrets() {
    if ! command -v sops &> /dev/null || ! command -v age &> /dev/null; then
        echo -e "   ${DIM}⚠️ sops/age not installed. Run: brew install sops age${NC}"
        return
    fi
    if [ ! -f .sops.yaml ]; then
        mkdir -p ~/.config/sops/age
        if [ ! -f ~/.config/sops/age/keys.txt ]; then
            age-keygen -o ~/.config/sops/age/keys.txt 2>/dev/null
        fi
        PUB_KEY=$(grep "public key:" ~/.config/sops/age/keys.txt | awk '{print $4}')
        cat <<SOPSEOF > .sops.yaml
creation_rules:
  - path_regex: \.env$
    key_groups:
    - age:
      - $PUB_KEY
SOPSEOF
        echo -e "   🔐 sops + age configured"
    fi
}

# --- Main ---
main() {
    parse_flags "$@"

    echo -e "${CYAN}🚀 Antigravity Bootstrap v3.0${NC}"
    echo ""

    # If no type flag, run interactive QA
    if [ -z "$PROJECT_TYPE" ]; then
        run_qa
    fi

    echo ""
    echo -e "⚡ Project: ${GREEN}$PROJECT_NAME${NC} | Type: ${GREEN}$PROJECT_TYPE${NC}$([ -n "$WEB_SUBTYPE" ] && echo " ($WEB_SUBTYPE)")"
    echo ""

    build_core
    build_project_dirs
    install_optional
    setup_symlinks
    write_profile
    setup_gitignore

    # Secrets only for types that use .env
    case "$PROJECT_TYPE" in
        webapp|python|serverops|macos) setup_secrets ;;
    esac

    echo ""
    echo -e "${GREEN}✅ Workspace is primed and ready.${NC}"
    echo -e "💡 Run ${CYAN}make help${NC} to see available commands."
}

main "$@"
