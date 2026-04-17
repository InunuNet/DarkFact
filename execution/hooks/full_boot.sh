#!/usr/bin/env bash
# full_boot.sh — SessionStart command hook
# Executes the full DarkFact boot sequence and injects context into the session.
# Runs from project root. All steps are non-fatal (|| true).

WORKSPACE_FILE="WORKSPACE"
PROFILE_FILE=".agent/profile.json"

echo "════ BOOT CONTEXT ════════════════════════════════"
echo ""

# Step 0+1: Workspace verification
echo "--- WORKSPACE ---"
if [ -f "$WORKSPACE_FILE" ]; then
  WORKSPACE_NAME=$(sed 's/[[:space:]]*$//' < "$WORKSPACE_FILE" | head -1)
  echo "✅ WORKSPACE: $WORKSPACE_NAME"
else
  echo "⛔ WORKSPACE file missing — run bash init.sh"
fi
if [ -f "$PROFILE_FILE" ]; then
  python3 -c "
import json, sys
p = json.load(open('$PROFILE_FILE'))
status = p.get('status', 'active')
icon = '✅' if status != 'archive' else '⚠️ ARCHIVED'
print(f\"{icon} Project: {p.get('project_name','?')} | Type: {p.get('project_type','?')} | Onboarded: {p.get('onboarding_complete', False)}\")
" 2>/dev/null || true
fi
echo ""

# Step 2: Last session recall
echo "--- LAST SESSION ---"
python3 execution/brain.py last-session --quiet 2>/dev/null || echo "(no brain data yet)"
echo ""

# Step 4: Project context — goals
echo "--- GOALS ---"
if [ -f ".agent/memory/project/goals.md" ]; then
  cat .agent/memory/project/goals.md
else
  echo "(no goals.md)"
fi
echo ""

# Step 4: Project context — learned
echo "--- LEARNED ---"
if [ -f ".agent/memory/project/learned.md" ]; then
  cat .agent/memory/project/learned.md
else
  echo "(no learned.md)"
fi
echo ""

# Step 4: Project context — backlog (capped at 60 lines)
echo "--- BACKLOG (first 60 lines) ---"
if [ -f ".agent/memory/project/backlog.md" ]; then
  head -60 .agent/memory/project/backlog.md
else
  echo "(no backlog.md)"
fi
echo ""

# Step 7: Git remotes
echo "--- GIT REMOTES ---"
git remote -v 2>/dev/null || echo "(not a git repo)"
echo ""

echo "════ BOOT DATA LOADED — report status using standard boot format ════"
