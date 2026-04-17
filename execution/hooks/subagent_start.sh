#!/usr/bin/env bash
# Injects DarkFact context into spawned subagents
input=$(cat)
agent_type=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('agent_type','unknown'))" 2>/dev/null || echo "unknown")

# Agent role definition (first 30 lines)
agent_file=".agent/agents/${agent_type}.md"
agent_context=""
if [ -f "$agent_file" ]; then
  agent_context=$(head -30 "$agent_file" | tr '\n' ' ' | sed 's/"/\\"/g')
fi

# Project rules (scope boundary, PAI boundary, etc.)
rules_context=""
if [ -f ".agent/memory/project/rules.md" ]; then
  rules_context=$(cat ".agent/memory/project/rules.md" | tr '\n' ' ' | sed 's/"/\\"/g')
fi

# Recent learned lessons (last 40 lines)
learned_context=""
if [ -f ".agent/memory/project/learned.md" ]; then
  learned_context=$(tail -40 ".agent/memory/project/learned.md" | tr '\n' ' ' | sed 's/"/\\"/g')
fi

context="${agent_context} PROJECT RULES: ${rules_context} RECENT LEARNINGS: ${learned_context}"

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStart\",\"additionalContext\":\"${context}\"}}"
