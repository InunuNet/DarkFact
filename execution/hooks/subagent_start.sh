#!/usr/bin/env bash
# Injects DarkFact context into spawned subagents
input=$(cat)
agent_type=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('agent_type','unknown'))" 2>/dev/null || echo "unknown")

agent_file=".agent/agents/${agent_type}.md"
context=""
if [ -f "$agent_file" ]; then
  # First 20 lines of the agent definition (role + constraints)
  context=$(head -20 "$agent_file" | tr '\n' ' ' | sed 's/"/\\"/g')
fi

# Also remind about learned.md
learned_reminder="Read .agent/memory/project/learned.md before starting. Check .agent/memory/project/goals.md for current priorities."

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStart\",\"additionalContext\":\"${context} ${learned_reminder}\"}}"
