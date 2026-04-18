#!/usr/bin/env bash
# DarkFact Overlay — overlay_template.sh
# Copies new DarkFact infrastructure files into a target project.
# NEVER touches: source code, brain data, project memory content, .git
set -e

TEMPLATE="${DARKFACT_TEMPLATE:-$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.." && pwd)}"
TARGET="$1"
[[ -z "$TARGET" ]] && echo "Usage: overlay_template.sh /path/to/project" && exit 1

VERSION=$(cat "$TEMPLATE/.agent/version" 2>/dev/null || echo "unknown")
proj=$(basename "$TARGET")
echo "🔄 Overlaying DarkFact v$VERSION into: $proj"

# Step 1: Backup .agent (full snapshot)
rm -rf "$TARGET/.agent.bak"
cp -r "$TARGET/.agent" "$TARGET/.agent.bak"
echo "  ✅ Backup: .agent.bak"

# Step 2: Overlay infrastructure dirs — rsync --delete mirrors source exactly,
#          removing any orphan files from previous template versions.
rsync -a --delete "$TEMPLATE/.agent/workflows/" "$TARGET/.agent/workflows/"
rsync -a --delete "$TEMPLATE/.agent/skills/"    "$TARGET/.agent/skills/"
rsync -a --delete "$TEMPLATE/.claude/skills/"   "$TARGET/.claude/skills/"  2>/dev/null || true
rsync -a --delete "$TEMPLATE/.gemini/skills/"   "$TARGET/.gemini/skills/"  2>/dev/null || true
rsync -a --delete "$TEMPLATE/.agent/agents/"    "$TARGET/.agent/agents/"
rsync -a --delete "$TEMPLATE/.agent/rules/"     "$TARGET/.agent/rules/"
# Single files
cp "$TEMPLATE/.agent/version"      "$TARGET/.agent/version"
cp "$TEMPLATE/.agent/CHANGELOG.md" "$TARGET/.agent/CHANGELOG.md" 2>/dev/null || true
cp "$TEMPLATE/Makefile"            "$TARGET/Makefile"            2>/dev/null || true
# Execution scripts
cp "$TEMPLATE/execution/brain.py"         "$TARGET/execution/brain.py"         2>/dev/null || true
cp "$TEMPLATE/execution/sync_agents.sh"   "$TARGET/execution/sync_agents.sh"   2>/dev/null || true
cp "$TEMPLATE/execution/merge_profile.py" "$TARGET/execution/merge_profile.py" 2>/dev/null || true
# Claude Code adapter — hooks, permissions, env
cp "$TEMPLATE/.claude/settings.json" "$TARGET/.claude/settings.json" 2>/dev/null || true
# Gemini CLI adapter
cp "$TEMPLATE/.gemini/settings.json" "$TARGET/.gemini/settings.json" 2>/dev/null || true
mkdir -p "$TARGET/.gemini/policies"
cp "$TEMPLATE/.gemini/policies/autonomy.toml" "$TARGET/.gemini/policies/autonomy.toml" 2>/dev/null || true
# AGENTS.md + symlinks
cp "$TEMPLATE/AGENTS.md" "$TARGET/AGENTS.md"
ln -sf AGENTS.md "$TARGET/CLAUDE.md"  2>/dev/null || true
ln -sf AGENTS.md "$TARGET/GEMINI.md"  2>/dev/null || true
echo "  ✅ Infrastructure files overlaid"

# Step 3: Restore brain (overlay may have reset it)
if [ -d "$TARGET/.agent.bak/memory/brain" ]; then
  rm -rf "$TARGET/.agent/memory/brain"
  cp -r "$TARGET/.agent.bak/memory/brain" "$TARGET/.agent/memory/brain"
  echo "  ✅ Brain preserved"
fi

echo "  ✅ Overlay complete: $proj (v$VERSION)"
