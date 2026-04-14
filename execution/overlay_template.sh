#!/usr/bin/env bash
# DarkFact Overlay — overlay_template.sh
# Copies new DarkFact infrastructure files into a target project.
# NEVER touches: source code, brain data, project memory content, .git
set -e

TEMPLATE="/Users/vetus/ai/DarkFact"
TARGET="$1"
[[ -z "$TARGET" ]] && echo "Usage: overlay_template.sh /path/to/project" && exit 1

proj=$(basename "$TARGET")
echo "🔄 Overlaying DarkFact v1.1.0 into: $proj"

# Step 1: Backup .agent (full snapshot)
rm -rf "$TARGET/.agent.bak"
cp -r "$TARGET/.agent" "$TARGET/.agent.bak"
echo "  ✅ Backup: .agent.bak"

# Step 2: Overlay infrastructure files (safe paths only)
# Workflows
cp -r "$TEMPLATE/.agent/workflows" "$TARGET/.agent/"
# Skills
cp -r "$TEMPLATE/.agent/skills" "$TARGET/.agent/"
# Agents
cp -r "$TEMPLATE/.agent/agents" "$TARGET/.agent/"
# Rules
cp -r "$TEMPLATE/.agent/rules" "$TARGET/.agent/"
# Version
cp "$TEMPLATE/.agent/version" "$TARGET/.agent/version"
# Execution scripts
cp "$TEMPLATE/execution/brain.py" "$TARGET/execution/brain.py" 2>/dev/null || true
cp "$TEMPLATE/execution/sync_agents.sh" "$TARGET/execution/sync_agents.sh" 2>/dev/null || true
cp "$TEMPLATE/execution/merge_profile.py" "$TARGET/execution/merge_profile.py" 2>/dev/null || true
# AGENTS.md + symlinks
cp "$TEMPLATE/AGENTS.md" "$TARGET/AGENTS.md"
ln -sf AGENTS.md "$TARGET/CLAUDE.md" 2>/dev/null || true
ln -sf AGENTS.md "$TARGET/GEMINI.md" 2>/dev/null || true
echo "  ✅ Infrastructure files overlaid"

# Step 3: Restore brain (overlay may have reset it)
if [ -d "$TARGET/.agent.bak/memory/brain" ]; then
  rm -rf "$TARGET/.agent/memory/brain"
  cp -r "$TARGET/.agent.bak/memory/brain" "$TARGET/.agent/memory/brain"
  echo "  ✅ Brain preserved"
fi

# Step 4: Add upstream remote (if missing)
git -C "$TARGET" remote add darkfact-upstream https://github.com/InunuNet/DarkFact.git 2>/dev/null || true

echo "  ✅ Overlay complete: $proj"
