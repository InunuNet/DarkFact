#!/usr/bin/env bash
# verify_workspace.sh — PreToolUse hook for Bash commands
# Validates agent is operating in the correct workspace.
# Exit 0 = allow, Exit 2 = block tool call.

WORKSPACE_FILE="WORKSPACE"
PROFILE_FILE=".agent/profile.json"

# Layer 1: WORKSPACE file must exist
if [ ! -f "$WORKSPACE_FILE" ]; then
  echo "⛔ WORKSPACE file missing — run 'bash init.sh' first" >&2
  exit 2
fi

WORKSPACE_NAME=$(sed 's/[[:space:]]*$//' < "$WORKSPACE_FILE" | head -1)
DIR_NAME=$(basename "$PWD")

# Layer 2: WORKSPACE content must match current directory name
if [ "$WORKSPACE_NAME" != "$DIR_NAME" ]; then
  echo "⛔ Workspace mismatch: WORKSPACE says '$WORKSPACE_NAME' but dir is '$DIR_NAME'" >&2
  exit 2
fi

# Layer 3: profile.json project_name must match (if file exists)
if [ -f "$PROFILE_FILE" ]; then
  PROFILE_NAME=$(grep -o '"project_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROFILE_FILE" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
  if [ -n "$PROFILE_NAME" ] && [ "$PROFILE_NAME" != "$WORKSPACE_NAME" ]; then
    echo "⛔ Profile mismatch: profile.json says '$PROFILE_NAME' but WORKSPACE says '$WORKSPACE_NAME'" >&2
    exit 2
  fi
fi

exit 0
