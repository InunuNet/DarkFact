#!/usr/bin/env bash
# full_boot.sh — SessionStart command hook
# Executes the full DarkFact boot sequence and injects context into the session.
# Runs from project root. All steps are non-fatal (|| true).

WORKSPACE_FILE="WORKSPACE"
PROFILE_FILE=".agent/profile.json"

echo "════ BOOT CONTEXT (DarkFact Framework v2.1.0) ════"
echo "You are operating within the DarkFact Agentic Workspace."
echo "Core Mandates: Specialized agents, Tiered memory, Autonomous self-improvement."
echo ""

# Step 0: System Identity
echo "--- SYSTEM IDENTITY ---"
if [ -f "AGENTS.md" ]; then
  cat AGENTS.md
else
  echo "⛔ AGENTS.md missing — run bash init.sh"
fi
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
  PROFILE_FILE="$PROFILE_FILE" python3 -c "
import os, json
p = json.load(open(os.environ['PROFILE_FILE']))
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

# Step 3: Project rules (override base rules — injected first so they take effect)
echo "--- PROJECT RULES ---"
if [ -f ".agent/memory/project/rules.md" ]; then
  cat .agent/memory/project/rules.md
else
  echo "(no rules.md)"
fi
echo ""

# Step 4: Project context — goals
echo "--- GOALS ---"
if [ -f ".agent/memory/project/goals.md" ]; then
  cat .agent/memory/project/goals.md
else
  echo "(no goals.md)"
fi
echo ""

# Step 4: Project context — learned (capped at last 80 lines to control token cost)
echo "--- LEARNED (last 80 lines) ---"
if [ -f ".agent/memory/project/learned.md" ]; then
  LEARNED_LINES=$(wc -l < ".agent/memory/project/learned.md")
  if [ "$LEARNED_LINES" -gt 80 ]; then
    echo "[Note: learned.md has $LEARNED_LINES lines — showing last 80. Run \`cat .agent/memory/project/learned.md\` for full history.]"
  fi
  tail -80 .agent/memory/project/learned.md
else
  echo "(no learned.md)"
fi
echo ""

# Step 4: Project context — backlog (capped at 60 lines)
echo "--- BACKLOG ---"
if [ -f ".agent/memory/project/backlog.md" ]; then
  BACKLOG_LINES=$(wc -l < ".agent/memory/project/backlog.md")
  head -60 .agent/memory/project/backlog.md
  if [ "$BACKLOG_LINES" -gt 60 ]; then
    echo "[truncated — $((BACKLOG_LINES - 60)) more lines hidden. Run \`cat .agent/memory/project/backlog.md\` for full backlog.]"
  fi
else
  echo "(no backlog.md)"
fi
echo ""

# Step 5: Semantic recall — what we were working on
echo "--- RECENT WORK ---"
python3 execution/brain.py recall "$(head -3 .agent/memory/project/goals.md 2>/dev/null | tail -1 || echo 'project goals')" --n 2 2>/dev/null || true
echo ""

# Step 6: Recurring blockers (exits 1 when blockers found, 0 when none)
echo "--- BLOCKERS ---"
python3 execution/brain.py scan-blockers 2>/dev/null
echo ""

# Step 7: Git remotes
echo "--- GIT REMOTES ---"
git remote -v 2>/dev/null || echo "(not a git repo)"
echo ""

echo "════ BOOT COMPLETE — all context loaded ════"
